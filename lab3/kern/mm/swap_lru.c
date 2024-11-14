#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

extern list_entry_t pra_list_head;  // 全局变量，用于存储页面的链表头

// 初始化内存管理结构体中的LRU链表
static int
_lru_init_mm(struct mm_struct *mm)
{
    // 初始化LRU链表
    list_init(&pra_list_head);
    // 将mm结构体中的私有数据成员sm_priv指向LRU链表的头部
    mm->sm_priv = &pra_list_head;
    return 0;
}

// 处理页面的映射，使页面可交换
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head = (list_entry_t*) mm->sm_priv;  // 获取LRU链表头
    list_entry_t *entry = &(page->pra_page_link);  // 获取当前页面的链表节点
    assert(entry != NULL && head != NULL);  // 确保链表节点和链表头有效
    
    // 将页面加入到LRU链表中
    list_add((list_entry_t*) mm->sm_priv, entry);
    return 0;
}

// 选择要换出的牺牲页面
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
    list_entry_t *head = (list_entry_t*) mm->sm_priv;  // 获取LRU链表头
    assert(head != NULL);  // 确保链表头有效
    assert(in_tick == 0);  // 确保in_tick参数为0
    
    // 选择链表中最不常用的页面（LRU算法：链表尾部的页面最久未使用）
    list_entry_t* entry = list_prev(head);
    
    // 如果链表不为空
    if (entry != head) {
        list_del(entry);  // 从链表中删除该页面
        *ptr_page = le2page(entry, pra_page_link);  // 获取页面并返回
    } else {
        *ptr_page = NULL;  // 如果链表为空，表示没有可交换的页面
    }
    return 0;
}

// 打印当前LRU链表的状态，用于调试
static void
print_mm_list() {
    cprintf("--------begin----------\n");
    list_entry_t *head = &pra_list_head, *le = head;
    while ((le = list_next(le)) != head)  // 遍历LRU链表
    {
        struct Page* page = le2page(le, pra_page_link);  // 获取链表中的页面
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);  // 打印页面的虚拟地址
    }
    cprintf("---------end-----------\n");
}

// 模拟LRU算法的交换过程
static int
_lru_check_swap(void) {
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;  // 模拟写操作，访问虚拟地址0x3000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;  // 模拟写操作，访问虚拟地址0x1000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;  // 模拟写操作，访问虚拟地址0x2000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;  // 模拟写操作，访问虚拟地址0x5000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;  // 模拟再次写操作，访问虚拟地址0x2000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;  // 模拟再次写操作，访问虚拟地址0x1000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;  // 模拟再次写操作，访问虚拟地址0x2000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;  // 模拟再次写操作，访问虚拟地址0x3000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;  // 模拟写操作，访问虚拟地址0x4000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;  // 模拟写操作，访问虚拟地址0x5000
    print_mm_list();  // 打印链表状态
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);  // 确保虚拟地址0x1000的值为0x0a
    *(unsigned char *)0x1000 = 0x0a;  // 模拟写操作，访问虚拟地址0x1000
    print_mm_list();  // 打印链表状态
    return 0;
}

static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }

// 当无法读取页面时，更新页面的访问权限
static int
unable_page_read(struct mm_struct *mm) {
    list_entry_t *head = (list_entry_t*) mm->sm_priv, *le = head;
    // 遍历LRU链表中的页面，清除它们的读权限
    while ((le = list_prev(le)) != head)
    {
        struct Page* page = le2page(le, pra_page_link);
        pte_t* ptep = NULL;
        ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
        *ptep &= ~PTE_R;  // 清除页面的读权限
    }
    return 0;
}

// 处理页面错误，进行LRU页面调度
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    cprintf("lru page fault at 0x%x\n", addr);  // 打印缺页的虚拟地址
    if(swap_init_ok) 
        unable_page_read(mm);  // 如果初始化了交换机制，更新页面访问权限
    
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);  // 获取页面的页表项
    *ptep |= PTE_R;  // 设置页面为可读

    if(!swap_init_ok) 
        return 0;  // 如果交换机制未初始化，直接返回

    // 获取当前缺页的页面
    struct Page* page = pte2page(*ptep);
    list_entry_t *head = (list_entry_t*) mm->sm_priv, *le = head;
    
    // 遍历LRU链表，寻找当前页面
    while ((le = list_prev(le)) != head)
    {
        struct Page* curr = le2page(le, pra_page_link);
        if(page == curr) {
            list_del(le);  // 从链表中删除该页面
            list_add(head, le);  // 将该页面重新添加到链表头部
            break;
        }
    }
    return 0;
}

struct swap_manager swap_manager_lru =
{
    .name            = "lru swap manager",
    .init            = &_lru_init,
    .init_mm         = &_lru_init_mm,
    .tick_event      = &_lru_tick_event,
    .map_swappable   = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap      = &_lru_check_swap,
};