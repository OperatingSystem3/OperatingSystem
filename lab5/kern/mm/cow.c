#include <cow.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>

// 设置进程的页目录
static int
setup_pgdir(struct mm_struct *mm) {
    // 定义一个指向Page结构体的指针，用于存储分配的内存页面
    struct Page *page;
    // 尝试分配一页物理内存，如果失败则返回内存不足的错误
    if ((page = alloc_page()) == NULL) {
        return -E_NO_MEM;  // 返回-ENOMEM，表示内存分配失败
    }
    // 获取分配到的物理页面的内核虚拟地址，并将该地址赋值给页目录指针
    pde_t *pgdir = page2kva(page);
    // 将启动时的页目录（boot_pgdir）内容拷贝到新的页目录中
    memcpy(pgdir, boot_pgdir, PGSIZE);
    // 将新创建的页目录的地址赋给进程的页目录字段
    mm->pgdir = pgdir;
    // 返回0，表示成功设置页目录
    return 0;
}
// 释放进程的页目录所占的物理内存
static void
put_pgdir(struct mm_struct *mm) {
    // 将进程的页目录（虚拟地址）转换成对应的物理页面，并释放这页物理内存
    free_page(kva2page(mm->pgdir));
}

// 复制虚拟内存空间（COW拷贝内存）
int
cow_copy_mm(struct proc_struct *proc) {
    // 定义当前进程的内存管理结构指针和旧进程的内存管理结构指针
    struct mm_struct *mm, *oldmm = current->mm;
    /* current is a kernel thread */
    // 如果当前进程没有用户空间（即是内核线程），直接返回0
    if (oldmm == NULL) {
        return 0;
    }
    // 定义返回值
    int ret = 0;
    // 创建新的内存管理结构，如果创建失败，则跳转到bad_mm
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    // 设置新的页目录，若失败则跳转到bad_pgdir_cleanup_mm
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    // 锁住旧进程的内存管理结构，防止并发修改
    lock_mm(oldmm);
    {
        // 复制旧进程的内存映射（COW策略）
        ret = cow_copy_mmap(mm, oldmm);
    }
    // 解锁旧进程的内存管理结构
    unlock_mm(oldmm);
    // 如果内存映射复制失败，则跳转到bad_dup_cleanup_mmap
    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }
good_mm:
    // 增加新内存管理结构的引用计数
    mm_count_inc(mm);
    // 设置新进程的内存管理结构
    proc->mm = mm;
    // 设置新进程的页目录物理地址（cr3寄存器）
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    // 清理内存映射并释放页目录
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    // 销毁新创建的内存管理结构
    mm_destroy(mm);
bad_mm:
    return ret;  // 返回错误代码
}

int
cow_copy_mmap(struct mm_struct *to, struct mm_struct *from) {
    // 断言 to 和 from 都不为 NULL
    assert(to != NULL && from != NULL);
    // 初始化 mmap 列表，并设置 le 为从列表开始的位置
    list_entry_t *list = &(from->mmap_list), *le = list;
    // 遍历 from 的 mmap_list 列表，逐个复制虚拟内存区域（vma）
    while ((le = list_prev(le)) != list) {
        struct vma_struct *vma, *nvma;
        // 获取当前列表项对应的 vma 结构体
        vma = le2vma(le, list_link);
        // 创建一个新的 vma 结构，复制原 vma 的起始地址、结束地址和标志
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        // 如果创建新的 vma 失败，返回内存不足的错误码
        if (nvma == NULL) {
            return -E_NO_MEM;
        }
        // 将新创建的 vma 插入到目标 mm_struct 的 vma 列表中
        insert_vma_struct(to, nvma);
        // 调用 cow_copy_range 函数，复制页表内容：将目标进程的页表指向原进程的相同地址范围
        // 即实现 "copy on write" 语义，复制指定的内存范围
        if (cow_copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end) != 0) {
            return -E_NO_MEM;  // 如果复制失败，返回内存不足的错误码
        }
    }
    // 如果所有操作都成功，返回 0
    return 0;
}

int cow_copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end) {
    // 断言起始地址和结束地址都为页对齐（即都能被 PGSIZE 整除）
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    // 断言给定的地址范围是用户访问的地址空间
    assert(USER_ACCESS(start, end));
    // 从 start 到 end 遍历每一页，逐一设置页表项
    do {
        // 获取从源页表（from）中 start 地址处的页表项（ptep）
        pte_t *ptep = get_pte(from, start, 0);
        // 如果该页表项为空（即没有映射），则跳到下一页，继续处理
        if (ptep == NULL) {
            // 将 start 移动到下一页的页表项（页表项大小为 PTSIZE）
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // 如果该页表项有效（PTE_V 表示该页表项有效），则进行复制
        if (*ptep & PTE_V) {
            // 清除 PTE_W 标志，禁止写权限（启用写时复制 COW）
            *ptep &= ~PTE_W;
            // 获取当前页的权限，保留用户权限并去除写权限
            uint32_t perm = (*ptep & PTE_USER & ~PTE_W);
            // 从页表项中获取对应的物理页（struct Page）
            struct Page *page = pte2page(*ptep);
            // 断言该页存在（即对应的物理页不为空）
            assert(page != NULL);
            // 将该物理页插入目标页表（to），并设置合适的权限
            int ret = page_insert(to, page, start, perm);
            // 断言插入操作成功
            assert(ret == 0);
        }
        // 将 start 指针向前移动一页大小（PGSIZE），处理下一页
        start += PGSIZE;
    } while (start != 0 && start < end);  // 遍历直到 start 达到 end 或溢出
    // 返回 0，表示操作成功
    return 0;
}

// 处理写时复制（COW）缺页异常的函数
int 
cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = 0;  // 初始化返回值，用于后续函数的返回
    pte_t *ptep = NULL;  // 页表项指针初始化为空
    // 获取指定虚拟地址(addr)的页表项，第三个参数为0，表示只查询页表项，不进行其他操作
    ptep = get_pte(mm->pgdir, addr, 0);
    // 设置新的页表项权限：将原权限中的用户权限（PTE_USER）保留，并添加写权限（PTE_W）
    uint32_t perm = (*ptep & PTE_USER) | PTE_W;
    // 获取该页表项所对应的物理页面指针（即当前映射的物理内存页面）
    struct Page *page = pte2page(*ptep);
    // 为写时复制（COW）分配一页新的物理内存
    struct Page *npage = alloc_page();
    // 断言，确保原页面和新分配的页面都不为空
    assert(page != NULL);
    assert(npage != NULL);
    // 将原页面的内核虚拟地址映射到 `src` 指针中
    uintptr_t* src = page2kva(page);
    // 将新分配的页面的内核虚拟地址映射到 `dst` 指针中
    uintptr_t* dst = page2kva(npage);
    // 将原页面的数据拷贝到新分配的页面中
    memcpy(dst, src, PGSIZE);
    // 将虚拟地址 `addr` 向下对齐到页大小的边界，确保以页为单位操作
    uintptr_t start = ROUNDDOWN(addr, PGSIZE);
    // 清空原页表项，表示当前虚拟页不再指向原物理页
    *ptep = 0;
    // 将新页面插入到进程的页表中，设置新的页表项指向新分配的页面，并设置权限
    ret = page_insert(mm->pgdir, npage, start, perm);
    // 重新获取该地址的页表项（确认插入是否成功）
    ptep = get_pte(mm->pgdir, addr, 0);
    // 返回操作结果，通常是成功插入新页面或失败（返回相应的错误码）
    return ret;
}