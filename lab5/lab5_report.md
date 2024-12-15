[TOC]

# lab 5 用户程序

**小组成员：徐亚民，肖胜杰，张天歌**

## 练习0：填写已有实验

`alloc_proc`函数更改：

```cpp
//lab5新增
proc->wait_state = 0;
proc->cptr = NULL; // Child Pointer 表示当前进程的子进程
proc->optr = NULL; // Older Sibling Pointer 表示当前进程的上一个兄弟进程
proc->yptr = NULL; // Younger Sibling Pointer 表示当前进程的下一个兄弟进程
```

`do_fork`更改：其中`set_links()`为实验五新增用户进程关系函数

```c++
   /*    -------------------
    *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
    *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */

    proc = alloc_proc();                // 分配并初始化一个新的进程结构体
    proc->parent = current;             // 设置新进程的父进程为当前进程
    assert(current->wait_state == 0);
    setup_kstack(proc);                 // 为新进程设置内核栈
    copy_mm(clone_flags, proc);         // 复制父进程的内存管理信息到新进程
    copy_thread(proc, stack, tf);       // 复制线程信息，包括栈和寄存器状态 
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        int pid = get_pid();           // 获取一个新的进程ID
        proc->pid = pid;               // 设置新进程的进程ID 
        hash_proc(proc);               //将proc_struct插入hash_list && proc_list
        set_links(proc);
    }
    local_intr_restore(intr_flag);
    wakeup_proc(proc);              // 调用wakeup_proc使新子进程RUNNABLE
    ret = proc->pid;                  // 返回新进程的进程ID
 
```

## 练习1: 加载应用程序并执行

### 1.1编程实现：

```cpp
    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 YOUR CODE: 2211123
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. 
     */
    tf->gpr.sp = USTACKTOP;
    tf->epc = elf-> e_entry;
    //用户态下，sstatus的SPP位清零，代表异常来自用户态，之后需要返回用户态；SPIE位清零，表示不启用中断。
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE);
```

这三行代码设计的核心目标是正确地初始化 `trapframe` 中的关键字段，以确保用户程序能够正常从内核模式切换到用户模式，并且在需要时能够正确返回内核模式。下面是每一行代码的设计思路和背景：

**1. tf->gpr.sp = USTACKTOP;**

- **设计思路**: 设置用户程序的栈顶地址，确保在用户程序运行时，栈指针（SP）指向一个有效的用户栈空间。
- **背景**: 操作系统为新用户进程分配独立的栈空间，并将 `sp` 初始化为栈顶位置，避免无效指针引发异常。

**2. tf->epc = elf->e_entry;**

- **设计思路**: 提取 ELF 的 `e_entry` 字段，设置到 `epc`，确保用户程序的控制流从正确的地址开始。
- **背景:**
  - ELF 文件（可执行与链接格式）是用户程序的载体，`e_entry` 字段定义了程序的入口点。
  - 在加载用户程序时，操作系统需要解析 ELF 文件，提取 `e_entry` 值，用于初始化进程的 `epc`。
  - 当执行 `sret`（从陷阱返回）指令时，硬件会根据 `epc` 的值跳转到用户程序的入口执行指令。

**3. tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);**

- **设计目的**: 初始化状态寄存器（`status`），确保正确的特权模式和中断设置，使得用户程序能够在用户模式（U-Mode）下安全运行。
- 背景:
  - `SSTATUS_SPP`（Supervisor Previous Privilege Level）:
    - 控制从陷阱返回后，处理器返回的特权模式。
    - 置 0 表示返回用户模式（U-Mode）；置 1 表示返回管理模式（S-Mode）。
    - 在初始化用户程序时，需要清除 `SSTATUS_SPP` 位，以确保通过 `sret` 指令从内核返回用户模式。
  - `SSTATUS_SPIE`（Supervisor Previous Interrupt Enable）:
    - 控制从陷阱返回后，中断是否启用。
    - 设置为 1 表示允许中断；清除为 0 表示禁用中断。
    - 在初始化用户程序时，需要清除该位，以确保从陷阱返回后中断逻辑正确。
- 设计思路:
  - 使用位运算（清除 SSTATUS_SPP和 SSTATUS_SPIE）确保硬件在执行 `sret`时：
    - 切换到用户模式（U-Mode）
    - 恢复用户模式下的中断状态。。

### 1.2简要描述简要描述这个用户态进程被`ucore`选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过：

当 `init` 进程将用户态进程创建完毕后，整个用户态进程从被调度运行到执行用户程序第一条指令的过程如下：

1. **创建并唤醒线程**：
    在 `init_main` 中，通过 `kernel_thread` 调用 `do_fork` 创建用户态进程，并唤醒线程，线程状态变为 `PROC_RUNNABLE`，表示线程可以运行。
2. **调度执行 `user_main`**：
    调度器选择该进程运行，进入 `user_main` 函数。在 `user_main` 中，通过宏 `KERNEL_EXECVE` 调用 `kernel_execve`。
3. **触发断点异常**：
    `kernel_execve` 通过执行 `ebreak` 指令触发断点异常。控制权转移到中断入口 `__alltraps`，随后依次进入 `trap`、`trap_dispatch` 和 `exception_handler`。
4. **执行系统调用 `sys_exec`**：
    在 `CAUSE_BREAKPOINT` 处，通过 `syscall` 函数，根据系统调用号，进入 `sys_exec`，随后调用 `do_execve`。
5. **加载用户程序**：
    在 `do_execve` 中调用 `load_icode`，完成用户程序的加载。具体步骤包括：
   - 回收当前进程内存空间；
   - 加载 ELF 文件，将用户程序段映射到内存；
   - 设置用户栈顶 (`tf->gpr.sp = USTACKTOP`)；
   - 设置程序入口点 (`tf->epc = elf->e_entry`)；
   - 配置用户态寄存器状态 (`tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE)`)，确保中断返回后切换到用户态。
6. **中断返回**：
    加载完成后，通过中断处理流程返回，在 `__trapret` 中调用 `sret` 指令完成从内核态到用户态的切换，开始执行用户程序的入口指令。

## 练习2: 父进程复制自己的内存空间给子进程



## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现



## 扩展练习 Challenge

### 1.实现 Copy on Write （COW）机制



### 2.说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？