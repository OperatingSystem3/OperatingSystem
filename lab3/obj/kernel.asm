
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53e60613          	addi	a2,a2,1342 # ffffffffc0211578 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	6e3030ef          	jal	ra,ffffffffc0203f2c <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	3aa58593          	addi	a1,a1,938 # ffffffffc02043f8 <etext>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	3c250513          	addi	a0,a0,962 # ffffffffc0204418 <etext+0x20>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	67b020ef          	jal	ra,ffffffffc0202ee0 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	443000ef          	jal	ra,ffffffffc0200cb0 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	2e0010ef          	jal	ra,ffffffffc0201356 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	3ac000ef          	jal	ra,ffffffffc0200426 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3f0000ef          	jal	ra,ffffffffc0200478 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	715030ef          	jal	ra,ffffffffc0203fc2 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	6df030ef          	jal	ra,ffffffffc0203fc2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	a661                	j	ffffffffc0200478 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	3b6000ef          	jal	ra,ffffffffc02004ac <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200102:	00011317          	auipc	t1,0x11
ffffffffc0200106:	3f630313          	addi	t1,t1,1014 # ffffffffc02114f8 <is_panic>
ffffffffc020010a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020010e:	715d                	addi	sp,sp,-80
ffffffffc0200110:	ec06                	sd	ra,24(sp)
ffffffffc0200112:	e822                	sd	s0,16(sp)
ffffffffc0200114:	f436                	sd	a3,40(sp)
ffffffffc0200116:	f83a                	sd	a4,48(sp)
ffffffffc0200118:	fc3e                	sd	a5,56(sp)
ffffffffc020011a:	e0c2                	sd	a6,64(sp)
ffffffffc020011c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020011e:	020e1a63          	bnez	t3,ffffffffc0200152 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200122:	4785                	li	a5,1
ffffffffc0200124:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020012c:	862e                	mv	a2,a1
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	2f050513          	addi	a0,a0,752 # ffffffffc0204420 <etext+0x28>
    va_start(ap, fmt);
ffffffffc0200138:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020013a:	f81ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020013e:	65a2                	ld	a1,8(sp)
ffffffffc0200140:	8522                	mv	a0,s0
ffffffffc0200142:	f59ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200146:	00006517          	auipc	a0,0x6
ffffffffc020014a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205d38 <default_pmm_manager+0x4f8>
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200152:	39c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200156:	4501                	li	a0,0
ffffffffc0200158:	130000ef          	jal	ra,ffffffffc0200288 <kmonitor>
    while (1) {
ffffffffc020015c:	bfed                	j	ffffffffc0200156 <__panic+0x54>

ffffffffc020015e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020015e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200160:	00004517          	auipc	a0,0x4
ffffffffc0200164:	2e050513          	addi	a0,a0,736 # ffffffffc0204440 <etext+0x48>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	2ea50513          	addi	a0,a0,746 # ffffffffc0204460 <etext+0x68>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	27658593          	addi	a1,a1,630 # ffffffffc02043f8 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	2f650513          	addi	a0,a0,758 # ffffffffc0204480 <etext+0x88>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	30250513          	addi	a0,a0,770 # ffffffffc02044a0 <etext+0xa8>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3ce58593          	addi	a1,a1,974 # ffffffffc0211578 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	30e50513          	addi	a0,a0,782 # ffffffffc02044c0 <etext+0xc8>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7b958593          	addi	a1,a1,1977 # ffffffffc0211977 <end+0x3ff>
ffffffffc02001c6:	00000797          	auipc	a5,0x0
ffffffffc02001ca:	e6c78793          	addi	a5,a5,-404 # ffffffffc0200032 <kern_init>
ffffffffc02001ce:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001dc:	95be                	add	a1,a1,a5
ffffffffc02001de:	85a9                	srai	a1,a1,0xa
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	30050513          	addi	a0,a0,768 # ffffffffc02044e0 <etext+0xe8>
}
ffffffffc02001e8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ea:	bdc1                	j	ffffffffc02000ba <cprintf>

ffffffffc02001ec <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	32260613          	addi	a2,a2,802 # ffffffffc0204510 <etext+0x118>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	32e50513          	addi	a0,a0,814 # ffffffffc0204528 <etext+0x130>
void print_stackframe(void) {
ffffffffc0200202:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200204:	effff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200208 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	00004617          	auipc	a2,0x4
ffffffffc020020e:	33660613          	addi	a2,a2,822 # ffffffffc0204540 <etext+0x148>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	34e58593          	addi	a1,a1,846 # ffffffffc0204560 <etext+0x168>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	34e50513          	addi	a0,a0,846 # ffffffffc0204568 <etext+0x170>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	35060613          	addi	a2,a2,848 # ffffffffc0204578 <etext+0x180>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	37058593          	addi	a1,a1,880 # ffffffffc02045a0 <etext+0x1a8>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	33050513          	addi	a0,a0,816 # ffffffffc0204568 <etext+0x170>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	36c60613          	addi	a2,a2,876 # ffffffffc02045b0 <etext+0x1b8>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	38458593          	addi	a1,a1,900 # ffffffffc02045d0 <etext+0x1d8>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	31450513          	addi	a0,a0,788 # ffffffffc0204568 <etext+0x170>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
ffffffffc020026a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020026c:	ef3ff0ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    return 0;
}
ffffffffc0200270:	60a2                	ld	ra,8(sp)
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	0141                	addi	sp,sp,16
ffffffffc0200276:	8082                	ret

ffffffffc0200278 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200278:	1141                	addi	sp,sp,-16
ffffffffc020027a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020027c:	f71ff0ef          	jal	ra,ffffffffc02001ec <print_stackframe>
    return 0;
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	0141                	addi	sp,sp,16
ffffffffc0200286:	8082                	ret

ffffffffc0200288 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200288:	7115                	addi	sp,sp,-224
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	35250513          	addi	a0,a0,850 # ffffffffc02045e0 <etext+0x1e8>
kmonitor(struct trapframe *tf) {
ffffffffc0200296:	ed86                	sd	ra,216(sp)
ffffffffc0200298:	e9a2                	sd	s0,208(sp)
ffffffffc020029a:	e5a6                	sd	s1,200(sp)
ffffffffc020029c:	e1ca                	sd	s2,192(sp)
ffffffffc020029e:	fd4e                	sd	s3,184(sp)
ffffffffc02002a0:	f952                	sd	s4,176(sp)
ffffffffc02002a2:	f556                	sd	s5,168(sp)
ffffffffc02002a4:	f15a                	sd	s6,160(sp)
ffffffffc02002a6:	e962                	sd	s8,144(sp)
ffffffffc02002a8:	e566                	sd	s9,136(sp)
ffffffffc02002aa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ac:	e0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b0:	00004517          	auipc	a0,0x4
ffffffffc02002b4:	35850513          	addi	a0,a0,856 # ffffffffc0204608 <etext+0x210>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	3aac0c13          	addi	s8,s8,938 # ffffffffc0204670 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	11290913          	addi	s2,s2,274 # ffffffffc02053e0 <commands+0xd70>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	35a48493          	addi	s1,s1,858 # ffffffffc0204630 <etext+0x238>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	358b0b13          	addi	s6,s6,856 # ffffffffc0204638 <etext+0x240>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	278a0a13          	addi	s4,s4,632 # ffffffffc0204560 <etext+0x168>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	050040ef          	jal	ra,ffffffffc0204344 <readline>
ffffffffc02002f8:	842a                	mv	s0,a0
ffffffffc02002fa:	dd65                	beqz	a0,ffffffffc02002f2 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fc:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200300:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200302:	e1bd                	bnez	a1,ffffffffc0200368 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200304:	fe0c87e3          	beqz	s9,ffffffffc02002f2 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	00004d17          	auipc	s10,0x4
ffffffffc020030e:	366d0d13          	addi	s10,s10,870 # ffffffffc0204670 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	3e1030ef          	jal	ra,ffffffffc0203ef8 <strcmp>
ffffffffc020031c:	c919                	beqz	a0,ffffffffc0200332 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	2405                	addiw	s0,s0,1
ffffffffc0200320:	0b540063          	beq	s0,s5,ffffffffc02003c0 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	000d3503          	ld	a0,0(s10)
ffffffffc0200328:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032c:	3cd030ef          	jal	ra,ffffffffc0203ef8 <strcmp>
ffffffffc0200330:	f57d                	bnez	a0,ffffffffc020031e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200332:	00141793          	slli	a5,s0,0x1
ffffffffc0200336:	97a2                	add	a5,a5,s0
ffffffffc0200338:	078e                	slli	a5,a5,0x3
ffffffffc020033a:	97e2                	add	a5,a5,s8
ffffffffc020033c:	6b9c                	ld	a5,16(a5)
ffffffffc020033e:	865e                	mv	a2,s7
ffffffffc0200340:	002c                	addi	a1,sp,8
ffffffffc0200342:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200346:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200348:	fa0555e3          	bgez	a0,ffffffffc02002f2 <kmonitor+0x6a>
}
ffffffffc020034c:	60ee                	ld	ra,216(sp)
ffffffffc020034e:	644e                	ld	s0,208(sp)
ffffffffc0200350:	64ae                	ld	s1,200(sp)
ffffffffc0200352:	690e                	ld	s2,192(sp)
ffffffffc0200354:	79ea                	ld	s3,184(sp)
ffffffffc0200356:	7a4a                	ld	s4,176(sp)
ffffffffc0200358:	7aaa                	ld	s5,168(sp)
ffffffffc020035a:	7b0a                	ld	s6,160(sp)
ffffffffc020035c:	6bea                	ld	s7,152(sp)
ffffffffc020035e:	6c4a                	ld	s8,144(sp)
ffffffffc0200360:	6caa                	ld	s9,136(sp)
ffffffffc0200362:	6d0a                	ld	s10,128(sp)
ffffffffc0200364:	612d                	addi	sp,sp,224
ffffffffc0200366:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	8526                	mv	a0,s1
ffffffffc020036a:	3ad030ef          	jal	ra,ffffffffc0203f16 <strchr>
ffffffffc020036e:	c901                	beqz	a0,ffffffffc020037e <kmonitor+0xf6>
ffffffffc0200370:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200374:	00040023          	sb	zero,0(s0)
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	d5c9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc020037c:	b7f5                	j	ffffffffc0200368 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020037e:	00044783          	lbu	a5,0(s0)
ffffffffc0200382:	d3c9                	beqz	a5,ffffffffc0200304 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200384:	033c8963          	beq	s9,s3,ffffffffc02003b6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200388:	003c9793          	slli	a5,s9,0x3
ffffffffc020038c:	0118                	addi	a4,sp,128
ffffffffc020038e:	97ba                	add	a5,a5,a4
ffffffffc0200390:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200398:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	e591                	bnez	a1,ffffffffc02003a6 <kmonitor+0x11e>
ffffffffc020039c:	b7b5                	j	ffffffffc0200308 <kmonitor+0x80>
ffffffffc020039e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003a2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	d1a5                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003a6:	8526                	mv	a0,s1
ffffffffc02003a8:	36f030ef          	jal	ra,ffffffffc0203f16 <strchr>
ffffffffc02003ac:	d96d                	beqz	a0,ffffffffc020039e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	00044583          	lbu	a1,0(s0)
ffffffffc02003b2:	d9a9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003b4:	bf55                	j	ffffffffc0200368 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003be:	b7e9                	j	ffffffffc0200388 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	29650513          	addi	a0,a0,662 # ffffffffc0204658 <etext+0x260>
ffffffffc02003ca:	cf1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02003ce:	b715                	j	ffffffffc02002f2 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];//number of sectors

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }//指定的 IDE 设备编号
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_read_secs>:

////ideno: 假设挂载了多块磁盘，选择哪一块磁盘 这里我们其实只有一块“磁盘”，这个参数就没用到
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {//secno 是起始扇区号，nsecs 是要读取的扇区数量
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);//这里所谓的“硬盘IO”，只是在内存里用memcpy把数据复制来复制去
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6278793          	addi	a5,a5,-926 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {//secno 是起始扇区号，nsecs 是要读取的扇区数量
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);//这里所谓的“硬盘IO”，只是在内存里用memcpy把数据复制来复制去
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {//secno 是起始扇区号，nsecs 是要读取的扇区数量
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);//这里所谓的“硬盘IO”，只是在内存里用memcpy把数据复制来复制去
ffffffffc02003f6:	349030ef          	jal	ra,ffffffffc0203f3e <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200402:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200406:	0000a517          	auipc	a0,0xa
ffffffffc020040a:	c3a50513          	addi	a0,a0,-966 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc020040e:	1141                	addi	sp,sp,-16
ffffffffc0200410:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	953e                	add	a0,a0,a5
ffffffffc0200414:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200418:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041a:	325030ef          	jal	ra,ffffffffc0203f3e <memcpy>
    return 0;
}
ffffffffc020041e:	60a2                	ld	ra,8(sp)
ffffffffc0200420:	4501                	li	a0,0
ffffffffc0200422:	0141                	addi	sp,sp,16
ffffffffc0200424:	8082                	ret

ffffffffc0200426 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200426:	67e1                	lui	a5,0x18
ffffffffc0200428:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020042c:	00011717          	auipc	a4,0x11
ffffffffc0200430:	0cf73e23          	sd	a5,220(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200434:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200438:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	953e                	add	a0,a0,a5
ffffffffc020043c:	4601                	li	a2,0
ffffffffc020043e:	4881                	li	a7,0
ffffffffc0200440:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200444:	02000793          	li	a5,32
ffffffffc0200448:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	26c50513          	addi	a0,a0,620 # ffffffffc02046b8 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0a07b623          	sd	zero,172(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0a67b783          	ld	a5,166(a5) # ffffffffc0211508 <timebase>
ffffffffc020046a:	953e                	add	a0,a0,a5
ffffffffc020046c:	4581                	li	a1,0
ffffffffc020046e:	4601                	li	a2,0
ffffffffc0200470:	4881                	li	a7,0
ffffffffc0200472:	00000073          	ecall
ffffffffc0200476:	8082                	ret

ffffffffc0200478 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200478:	100027f3          	csrr	a5,sstatus
ffffffffc020047c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020047e:	0ff57513          	zext.b	a0,a0
ffffffffc0200482:	e799                	bnez	a5,ffffffffc0200490 <cons_putc+0x18>
ffffffffc0200484:	4581                	li	a1,0
ffffffffc0200486:	4601                	li	a2,0
ffffffffc0200488:	4885                	li	a7,1
ffffffffc020048a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020048e:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200490:	1101                	addi	sp,sp,-32
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200496:	058000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020049a:	6522                	ld	a0,8(sp)
ffffffffc020049c:	4581                	li	a1,0
ffffffffc020049e:	4601                	li	a2,0
ffffffffc02004a0:	4885                	li	a7,1
ffffffffc02004a2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004a6:	60e2                	ld	ra,24(sp)
ffffffffc02004a8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004aa:	a83d                	j	ffffffffc02004e8 <intr_enable>

ffffffffc02004ac <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004ac:	100027f3          	csrr	a5,sstatus
ffffffffc02004b0:	8b89                	andi	a5,a5,2
ffffffffc02004b2:	eb89                	bnez	a5,ffffffffc02004c4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004b4:	4501                	li	a0,0
ffffffffc02004b6:	4581                	li	a1,0
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4889                	li	a7,2
ffffffffc02004bc:	00000073          	ecall
ffffffffc02004c0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004c2:	8082                	ret
int cons_getc(void) {
ffffffffc02004c4:	1101                	addi	sp,sp,-32
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004c8:	026000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02004cc:	4501                	li	a0,0
ffffffffc02004ce:	4581                	li	a1,0
ffffffffc02004d0:	4601                	li	a2,0
ffffffffc02004d2:	4889                	li	a7,2
ffffffffc02004d4:	00000073          	ecall
ffffffffc02004d8:	2501                	sext.w	a0,a0
ffffffffc02004da:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004dc:	00c000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc02004e0:	60e2                	ld	ra,24(sp)
ffffffffc02004e2:	6522                	ld	a0,8(sp)
ffffffffc02004e4:	6105                	addi	sp,sp,32
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	1b450513          	addi	a0,a0,436 # ffffffffc02046d8 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fe853503          	ld	a0,-24(a0) # ffffffffc0211518 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	5410006f          	j	ffffffffc0201288 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	1ac60613          	addi	a2,a2,428 # ffffffffc02046f8 <commands+0x88>
ffffffffc0200554:	07900593          	li	a1,121
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	1b850513          	addi	a0,a0,440 # ffffffffc0204710 <commands+0xa0>
ffffffffc0200560:	ba3ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	4a878793          	addi	a5,a5,1192 # ffffffffc0200a10 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	19e50513          	addi	a0,a0,414 # ffffffffc0204728 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	1a650513          	addi	a0,a0,422 # ffffffffc0204740 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	1b050513          	addi	a0,a0,432 # ffffffffc0204758 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	1ba50513          	addi	a0,a0,442 # ffffffffc0204770 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	1c450513          	addi	a0,a0,452 # ffffffffc0204788 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	1ce50513          	addi	a0,a0,462 # ffffffffc02047a0 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	1d850513          	addi	a0,a0,472 # ffffffffc02047b8 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	1e250513          	addi	a0,a0,482 # ffffffffc02047d0 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	1ec50513          	addi	a0,a0,492 # ffffffffc02047e8 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	1f650513          	addi	a0,a0,502 # ffffffffc0204800 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	20050513          	addi	a0,a0,512 # ffffffffc0204818 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	20a50513          	addi	a0,a0,522 # ffffffffc0204830 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	21450513          	addi	a0,a0,532 # ffffffffc0204848 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	21e50513          	addi	a0,a0,542 # ffffffffc0204860 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	22850513          	addi	a0,a0,552 # ffffffffc0204878 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	23250513          	addi	a0,a0,562 # ffffffffc0204890 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	23c50513          	addi	a0,a0,572 # ffffffffc02048a8 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	24650513          	addi	a0,a0,582 # ffffffffc02048c0 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	25050513          	addi	a0,a0,592 # ffffffffc02048d8 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	25a50513          	addi	a0,a0,602 # ffffffffc02048f0 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	26450513          	addi	a0,a0,612 # ffffffffc0204908 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	26e50513          	addi	a0,a0,622 # ffffffffc0204920 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	27850513          	addi	a0,a0,632 # ffffffffc0204938 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	28250513          	addi	a0,a0,642 # ffffffffc0204950 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	28c50513          	addi	a0,a0,652 # ffffffffc0204968 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	29650513          	addi	a0,a0,662 # ffffffffc0204980 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	2a050513          	addi	a0,a0,672 # ffffffffc0204998 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	2aa50513          	addi	a0,a0,682 # ffffffffc02049b0 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	2b450513          	addi	a0,a0,692 # ffffffffc02049c8 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	2be50513          	addi	a0,a0,702 # ffffffffc02049e0 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	2c850513          	addi	a0,a0,712 # ffffffffc02049f8 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	2ce50513          	addi	a0,a0,718 # ffffffffc0204a10 <commands+0x3a0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	2d250513          	addi	a0,a0,722 # ffffffffc0204a28 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	2d250513          	addi	a0,a0,722 # ffffffffc0204a40 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	2da50513          	addi	a0,a0,730 # ffffffffc0204a58 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	2e250513          	addi	a0,a0,738 # ffffffffc0204a70 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	2e650513          	addi	a0,a0,742 # ffffffffc0204a88 <commands+0x418>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	08f76c63          	bltu	a4,a5,ffffffffc0200852 <interrupt_handler+0xa2>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	39270713          	addi	a4,a4,914 # ffffffffc0204b50 <commands+0x4e0>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	33050513          	addi	a0,a0,816 # ffffffffc0204b00 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	30450513          	addi	a0,a0,772 # ffffffffc0204ae0 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	2b850513          	addi	a0,a0,696 # ffffffffc0204aa0 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	2cc50513          	addi	a0,a0,716 # ffffffffc0204ac0 <commands+0x450>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e022                	sd	s0,0(sp)
ffffffffc0200804:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200806:	c59ff0ef          	jal	ra,ffffffffc020045e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc020080a:	00011697          	auipc	a3,0x11
ffffffffc020080e:	cf668693          	addi	a3,a3,-778 # ffffffffc0211500 <ticks>
ffffffffc0200812:	629c                	ld	a5,0(a3)
ffffffffc0200814:	06400713          	li	a4,100
ffffffffc0200818:	00011417          	auipc	s0,0x11
ffffffffc020081c:	cf840413          	addi	s0,s0,-776 # ffffffffc0211510 <num>
ffffffffc0200820:	0785                	addi	a5,a5,1
ffffffffc0200822:	02e7f733          	remu	a4,a5,a4
ffffffffc0200826:	e29c                	sd	a5,0(a3)
ffffffffc0200828:	c715                	beqz	a4,ffffffffc0200854 <interrupt_handler+0xa4>
                print_ticks();
                num++;
            }
            if(num==10){
ffffffffc020082a:	6018                	ld	a4,0(s0)
ffffffffc020082c:	47a9                	li	a5,10
ffffffffc020082e:	00f71863          	bne	a4,a5,ffffffffc020083e <interrupt_handler+0x8e>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200832:	4501                	li	a0,0
ffffffffc0200834:	4581                	li	a1,0
ffffffffc0200836:	4601                	li	a2,0
ffffffffc0200838:	48a1                	li	a7,8
ffffffffc020083a:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020083e:	60a2                	ld	ra,8(sp)
ffffffffc0200840:	6402                	ld	s0,0(sp)
ffffffffc0200842:	0141                	addi	sp,sp,16
ffffffffc0200844:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200846:	00004517          	auipc	a0,0x4
ffffffffc020084a:	2ea50513          	addi	a0,a0,746 # ffffffffc0204b30 <commands+0x4c0>
ffffffffc020084e:	86dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200852:	bdf5                	j	ffffffffc020074e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200854:	06400593          	li	a1,100
ffffffffc0200858:	00004517          	auipc	a0,0x4
ffffffffc020085c:	2c850513          	addi	a0,a0,712 # ffffffffc0204b20 <commands+0x4b0>
ffffffffc0200860:	85bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
                num++;
ffffffffc0200864:	601c                	ld	a5,0(s0)
ffffffffc0200866:	0785                	addi	a5,a5,1
ffffffffc0200868:	e01c                	sd	a5,0(s0)
ffffffffc020086a:	b7c1                	j	ffffffffc020082a <interrupt_handler+0x7a>

ffffffffc020086c <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020086c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200870:	1101                	addi	sp,sp,-32
ffffffffc0200872:	e822                	sd	s0,16(sp)
ffffffffc0200874:	ec06                	sd	ra,24(sp)
ffffffffc0200876:	e426                	sd	s1,8(sp)
ffffffffc0200878:	473d                	li	a4,15
ffffffffc020087a:	842a                	mv	s0,a0
ffffffffc020087c:	14f76a63          	bltu	a4,a5,ffffffffc02009d0 <exception_handler+0x164>
ffffffffc0200880:	00004717          	auipc	a4,0x4
ffffffffc0200884:	4b870713          	addi	a4,a4,1208 # ffffffffc0204d38 <commands+0x6c8>
ffffffffc0200888:	078a                	slli	a5,a5,0x2
ffffffffc020088a:	97ba                	add	a5,a5,a4
ffffffffc020088c:	439c                	lw	a5,0(a5)
ffffffffc020088e:	97ba                	add	a5,a5,a4
ffffffffc0200890:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200892:	00004517          	auipc	a0,0x4
ffffffffc0200896:	48e50513          	addi	a0,a0,1166 # ffffffffc0204d20 <commands+0x6b0>
ffffffffc020089a:	821ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020089e:	8522                	mv	a0,s0
ffffffffc02008a0:	c55ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008a4:	84aa                	mv	s1,a0
ffffffffc02008a6:	12051b63          	bnez	a0,ffffffffc02009dc <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008aa:	60e2                	ld	ra,24(sp)
ffffffffc02008ac:	6442                	ld	s0,16(sp)
ffffffffc02008ae:	64a2                	ld	s1,8(sp)
ffffffffc02008b0:	6105                	addi	sp,sp,32
ffffffffc02008b2:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008b4:	00004517          	auipc	a0,0x4
ffffffffc02008b8:	2cc50513          	addi	a0,a0,716 # ffffffffc0204b80 <commands+0x510>
}
ffffffffc02008bc:	6442                	ld	s0,16(sp)
ffffffffc02008be:	60e2                	ld	ra,24(sp)
ffffffffc02008c0:	64a2                	ld	s1,8(sp)
ffffffffc02008c2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008c4:	ff6ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	2d850513          	addi	a0,a0,728 # ffffffffc0204ba0 <commands+0x530>
ffffffffc02008d0:	b7f5                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	2ee50513          	addi	a0,a0,750 # ffffffffc0204bc0 <commands+0x550>
ffffffffc02008da:	b7cd                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	2fc50513          	addi	a0,a0,764 # ffffffffc0204bd8 <commands+0x568>
ffffffffc02008e4:	bfe1                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	30250513          	addi	a0,a0,770 # ffffffffc0204be8 <commands+0x578>
ffffffffc02008ee:	b7f9                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	31850513          	addi	a0,a0,792 # ffffffffc0204c08 <commands+0x598>
ffffffffc02008f8:	fc2ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008fc:	8522                	mv	a0,s0
ffffffffc02008fe:	bf7ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200902:	84aa                	mv	s1,a0
ffffffffc0200904:	d15d                	beqz	a0,ffffffffc02008aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200906:	8522                	mv	a0,s0
ffffffffc0200908:	e47ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020090c:	86a6                	mv	a3,s1
ffffffffc020090e:	00004617          	auipc	a2,0x4
ffffffffc0200912:	31260613          	addi	a2,a2,786 # ffffffffc0204c20 <commands+0x5b0>
ffffffffc0200916:	0cf00593          	li	a1,207
ffffffffc020091a:	00004517          	auipc	a0,0x4
ffffffffc020091e:	df650513          	addi	a0,a0,-522 # ffffffffc0204710 <commands+0xa0>
ffffffffc0200922:	fe0ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	31a50513          	addi	a0,a0,794 # ffffffffc0204c40 <commands+0x5d0>
ffffffffc020092e:	b779                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200930:	00004517          	auipc	a0,0x4
ffffffffc0200934:	32850513          	addi	a0,a0,808 # ffffffffc0204c58 <commands+0x5e8>
ffffffffc0200938:	f82ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	bb7ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200942:	84aa                	mv	s1,a0
ffffffffc0200944:	d13d                	beqz	a0,ffffffffc02008aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200946:	8522                	mv	a0,s0
ffffffffc0200948:	e07ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020094c:	86a6                	mv	a3,s1
ffffffffc020094e:	00004617          	auipc	a2,0x4
ffffffffc0200952:	2d260613          	addi	a2,a2,722 # ffffffffc0204c20 <commands+0x5b0>
ffffffffc0200956:	0d900593          	li	a1,217
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	db650513          	addi	a0,a0,-586 # ffffffffc0204710 <commands+0xa0>
ffffffffc0200962:	fa0ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	30a50513          	addi	a0,a0,778 # ffffffffc0204c70 <commands+0x600>
ffffffffc020096e:	b7b9                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	32050513          	addi	a0,a0,800 # ffffffffc0204c90 <commands+0x620>
ffffffffc0200978:	b791                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	33650513          	addi	a0,a0,822 # ffffffffc0204cb0 <commands+0x640>
ffffffffc0200982:	bf2d                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	34c50513          	addi	a0,a0,844 # ffffffffc0204cd0 <commands+0x660>
ffffffffc020098c:	bf05                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	36250513          	addi	a0,a0,866 # ffffffffc0204cf0 <commands+0x680>
ffffffffc0200996:	b71d                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	37050513          	addi	a0,a0,880 # ffffffffc0204d08 <commands+0x698>
ffffffffc02009a0:	f1aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009a4:	8522                	mv	a0,s0
ffffffffc02009a6:	b4fff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02009aa:	84aa                	mv	s1,a0
ffffffffc02009ac:	ee050fe3          	beqz	a0,ffffffffc02008aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b0:	8522                	mv	a0,s0
ffffffffc02009b2:	d9dff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009b6:	86a6                	mv	a3,s1
ffffffffc02009b8:	00004617          	auipc	a2,0x4
ffffffffc02009bc:	26860613          	addi	a2,a2,616 # ffffffffc0204c20 <commands+0x5b0>
ffffffffc02009c0:	0ef00593          	li	a1,239
ffffffffc02009c4:	00004517          	auipc	a0,0x4
ffffffffc02009c8:	d4c50513          	addi	a0,a0,-692 # ffffffffc0204710 <commands+0xa0>
ffffffffc02009cc:	f36ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            print_trapframe(tf);
ffffffffc02009d0:	8522                	mv	a0,s0
}
ffffffffc02009d2:	6442                	ld	s0,16(sp)
ffffffffc02009d4:	60e2                	ld	ra,24(sp)
ffffffffc02009d6:	64a2                	ld	s1,8(sp)
ffffffffc02009d8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009da:	bb95                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009dc:	8522                	mv	a0,s0
ffffffffc02009de:	d71ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009e2:	86a6                	mv	a3,s1
ffffffffc02009e4:	00004617          	auipc	a2,0x4
ffffffffc02009e8:	23c60613          	addi	a2,a2,572 # ffffffffc0204c20 <commands+0x5b0>
ffffffffc02009ec:	0f600593          	li	a1,246
ffffffffc02009f0:	00004517          	auipc	a0,0x4
ffffffffc02009f4:	d2050513          	addi	a0,a0,-736 # ffffffffc0204710 <commands+0xa0>
ffffffffc02009f8:	f0aff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02009fc <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009fc:	11853783          	ld	a5,280(a0)
ffffffffc0200a00:	0007c363          	bltz	a5,ffffffffc0200a06 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a04:	b5a5                	j	ffffffffc020086c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a06:	b36d                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f8bff0ef          	jal	ra,ffffffffc02009fc <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ad0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ad2:	00004697          	auipc	a3,0x4
ffffffffc0200ad6:	2a668693          	addi	a3,a3,678 # ffffffffc0204d78 <commands+0x708>
ffffffffc0200ada:	00004617          	auipc	a2,0x4
ffffffffc0200ade:	2be60613          	addi	a2,a2,702 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200ae2:	07d00593          	li	a1,125
ffffffffc0200ae6:	00004517          	auipc	a0,0x4
ffffffffc0200aea:	2ca50513          	addi	a0,a0,714 # ffffffffc0204db0 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200aee:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200af0:	e12ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200af4 <mm_create>:
mm_create(void) {
ffffffffc0200af4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200af6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200afa:	e022                	sd	s0,0(sp)
ffffffffc0200afc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200afe:	0a4030ef          	jal	ra,ffffffffc0203ba2 <kmalloc>
ffffffffc0200b02:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200b04:	c105                	beqz	a0,ffffffffc0200b24 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b06:	e408                	sd	a0,8(s0)
ffffffffc0200b08:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200b0a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200b0e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200b12:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b16:	00011797          	auipc	a5,0x11
ffffffffc0200b1a:	a227a783          	lw	a5,-1502(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0200b1e:	eb81                	bnez	a5,ffffffffc0200b2e <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200b20:	02053423          	sd	zero,40(a0)
}
ffffffffc0200b24:	60a2                	ld	ra,8(sp)
ffffffffc0200b26:	8522                	mv	a0,s0
ffffffffc0200b28:	6402                	ld	s0,0(sp)
ffffffffc0200b2a:	0141                	addi	sp,sp,16
ffffffffc0200b2c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b2e:	693000ef          	jal	ra,ffffffffc02019c0 <swap_init_mm>
}
ffffffffc0200b32:	60a2                	ld	ra,8(sp)
ffffffffc0200b34:	8522                	mv	a0,s0
ffffffffc0200b36:	6402                	ld	s0,0(sp)
ffffffffc0200b38:	0141                	addi	sp,sp,16
ffffffffc0200b3a:	8082                	ret

ffffffffc0200b3c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b3c:	1101                	addi	sp,sp,-32
ffffffffc0200b3e:	e04a                	sd	s2,0(sp)
ffffffffc0200b40:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b42:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b46:	e822                	sd	s0,16(sp)
ffffffffc0200b48:	e426                	sd	s1,8(sp)
ffffffffc0200b4a:	ec06                	sd	ra,24(sp)
ffffffffc0200b4c:	84ae                	mv	s1,a1
ffffffffc0200b4e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b50:	052030ef          	jal	ra,ffffffffc0203ba2 <kmalloc>
    if (vma != NULL) {
ffffffffc0200b54:	c509                	beqz	a0,ffffffffc0200b5e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200b56:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200b5a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200b5c:	ed00                	sd	s0,24(a0)
}
ffffffffc0200b5e:	60e2                	ld	ra,24(sp)
ffffffffc0200b60:	6442                	ld	s0,16(sp)
ffffffffc0200b62:	64a2                	ld	s1,8(sp)
ffffffffc0200b64:	6902                	ld	s2,0(sp)
ffffffffc0200b66:	6105                	addi	sp,sp,32
ffffffffc0200b68:	8082                	ret

ffffffffc0200b6a <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200b6a:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200b6c:	c505                	beqz	a0,ffffffffc0200b94 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200b6e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b70:	c501                	beqz	a0,ffffffffc0200b78 <find_vma+0xe>
ffffffffc0200b72:	651c                	ld	a5,8(a0)
ffffffffc0200b74:	02f5f263          	bgeu	a1,a5,ffffffffc0200b98 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b78:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200b7a:	00f68d63          	beq	a3,a5,ffffffffc0200b94 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200b7e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b82:	00e5e663          	bltu	a1,a4,ffffffffc0200b8e <find_vma+0x24>
ffffffffc0200b86:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b8a:	00e5ec63          	bltu	a1,a4,ffffffffc0200ba2 <find_vma+0x38>
ffffffffc0200b8e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200b90:	fef697e3          	bne	a3,a5,ffffffffc0200b7e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200b94:	4501                	li	a0,0
}
ffffffffc0200b96:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b98:	691c                	ld	a5,16(a0)
ffffffffc0200b9a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200b78 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200b9e:	ea88                	sd	a0,16(a3)
ffffffffc0200ba0:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200ba2:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200ba6:	ea88                	sd	a0,16(a3)
ffffffffc0200ba8:	8082                	ret

ffffffffc0200baa <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200baa:	6590                	ld	a2,8(a1)
ffffffffc0200bac:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200bb0:	1141                	addi	sp,sp,-16
ffffffffc0200bb2:	e406                	sd	ra,8(sp)
ffffffffc0200bb4:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bb6:	01066763          	bltu	a2,a6,ffffffffc0200bc4 <insert_vma_struct+0x1a>
ffffffffc0200bba:	a085                	j	ffffffffc0200c1a <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200bbc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200bc0:	04e66863          	bltu	a2,a4,ffffffffc0200c10 <insert_vma_struct+0x66>
ffffffffc0200bc4:	86be                	mv	a3,a5
ffffffffc0200bc6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200bc8:	fef51ae3          	bne	a0,a5,ffffffffc0200bbc <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200bcc:	02a68463          	beq	a3,a0,ffffffffc0200bf4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200bd0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200bd4:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200bd8:	08e8f163          	bgeu	a7,a4,ffffffffc0200c5a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bdc:	04e66f63          	bltu	a2,a4,ffffffffc0200c3a <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200be0:	00f50a63          	beq	a0,a5,ffffffffc0200bf4 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200be4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200be8:	05076963          	bltu	a4,a6,ffffffffc0200c3a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200bec:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200bf0:	02c77363          	bgeu	a4,a2,ffffffffc0200c16 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200bf4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200bf6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200bf8:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bfc:	e390                	sd	a2,0(a5)
ffffffffc0200bfe:	e690                	sd	a2,8(a3)
}
ffffffffc0200c00:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200c02:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200c04:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200c06:	0017079b          	addiw	a5,a4,1
ffffffffc0200c0a:	d11c                	sw	a5,32(a0)
}
ffffffffc0200c0c:	0141                	addi	sp,sp,16
ffffffffc0200c0e:	8082                	ret
    if (le_prev != list) {
ffffffffc0200c10:	fca690e3          	bne	a3,a0,ffffffffc0200bd0 <insert_vma_struct+0x26>
ffffffffc0200c14:	bfd1                	j	ffffffffc0200be8 <insert_vma_struct+0x3e>
ffffffffc0200c16:	ebbff0ef          	jal	ra,ffffffffc0200ad0 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	1a668693          	addi	a3,a3,422 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	17660613          	addi	a2,a2,374 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200c2a:	08400593          	li	a1,132
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	18250513          	addi	a0,a0,386 # ffffffffc0204db0 <commands+0x740>
ffffffffc0200c36:	cccff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	1c668693          	addi	a3,a3,454 # ffffffffc0204e00 <commands+0x790>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	15660613          	addi	a2,a2,342 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200c4a:	07c00593          	li	a1,124
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	16250513          	addi	a0,a0,354 # ffffffffc0204db0 <commands+0x740>
ffffffffc0200c56:	cacff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c5a:	00004697          	auipc	a3,0x4
ffffffffc0200c5e:	18668693          	addi	a3,a3,390 # ffffffffc0204de0 <commands+0x770>
ffffffffc0200c62:	00004617          	auipc	a2,0x4
ffffffffc0200c66:	13660613          	addi	a2,a2,310 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200c6a:	07b00593          	li	a1,123
ffffffffc0200c6e:	00004517          	auipc	a0,0x4
ffffffffc0200c72:	14250513          	addi	a0,a0,322 # ffffffffc0204db0 <commands+0x740>
ffffffffc0200c76:	c8cff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200c7a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200c7a:	1141                	addi	sp,sp,-16
ffffffffc0200c7c:	e022                	sd	s0,0(sp)
ffffffffc0200c7e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200c80:	6508                	ld	a0,8(a0)
ffffffffc0200c82:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200c84:	00a40e63          	beq	s0,a0,ffffffffc0200ca0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c88:	6118                	ld	a4,0(a0)
ffffffffc0200c8a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200c8c:	03000593          	li	a1,48
ffffffffc0200c90:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c92:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c94:	e398                	sd	a4,0(a5)
ffffffffc0200c96:	7c7020ef          	jal	ra,ffffffffc0203c5c <kfree>
    return listelm->next;
ffffffffc0200c9a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200c9c:	fea416e3          	bne	s0,a0,ffffffffc0200c88 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200ca0:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200ca2:	6402                	ld	s0,0(sp)
ffffffffc0200ca4:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200ca6:	03000593          	li	a1,48
}
ffffffffc0200caa:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200cac:	7b10206f          	j	ffffffffc0203c5c <kfree>

ffffffffc0200cb0 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200cb0:	715d                	addi	sp,sp,-80
ffffffffc0200cb2:	e486                	sd	ra,72(sp)
ffffffffc0200cb4:	f44e                	sd	s3,40(sp)
ffffffffc0200cb6:	f052                	sd	s4,32(sp)
ffffffffc0200cb8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cba:	fc26                	sd	s1,56(sp)
ffffffffc0200cbc:	f84a                	sd	s2,48(sp)
ffffffffc0200cbe:	ec56                	sd	s5,24(sp)
ffffffffc0200cc0:	e85a                	sd	s6,16(sp)
ffffffffc0200cc2:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200cc4:	5f9010ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
ffffffffc0200cc8:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200cca:	5f3010ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
ffffffffc0200cce:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200cd0:	03000513          	li	a0,48
ffffffffc0200cd4:	6cf020ef          	jal	ra,ffffffffc0203ba2 <kmalloc>
    if (mm != NULL) {
ffffffffc0200cd8:	56050863          	beqz	a0,ffffffffc0201248 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0200cdc:	e508                	sd	a0,8(a0)
ffffffffc0200cde:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200ce0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200ce4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ce8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200cec:	00011797          	auipc	a5,0x11
ffffffffc0200cf0:	84c7a783          	lw	a5,-1972(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0200cf4:	84aa                	mv	s1,a0
ffffffffc0200cf6:	e7b9                	bnez	a5,ffffffffc0200d44 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0200cf8:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200cfc:	03200413          	li	s0,50
ffffffffc0200d00:	a811                	j	ffffffffc0200d14 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0200d02:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d04:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d06:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200d0a:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d0c:	8526                	mv	a0,s1
ffffffffc0200d0e:	e9dff0ef          	jal	ra,ffffffffc0200baa <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200d12:	cc05                	beqz	s0,ffffffffc0200d4a <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d14:	03000513          	li	a0,48
ffffffffc0200d18:	68b020ef          	jal	ra,ffffffffc0203ba2 <kmalloc>
ffffffffc0200d1c:	85aa                	mv	a1,a0
ffffffffc0200d1e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d22:	f165                	bnez	a0,ffffffffc0200d02 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0200d24:	00004697          	auipc	a3,0x4
ffffffffc0200d28:	32c68693          	addi	a3,a3,812 # ffffffffc0205050 <commands+0x9e0>
ffffffffc0200d2c:	00004617          	auipc	a2,0x4
ffffffffc0200d30:	06c60613          	addi	a2,a2,108 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200d34:	0ce00593          	li	a1,206
ffffffffc0200d38:	00004517          	auipc	a0,0x4
ffffffffc0200d3c:	07850513          	addi	a0,a0,120 # ffffffffc0204db0 <commands+0x740>
ffffffffc0200d40:	bc2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d44:	47d000ef          	jal	ra,ffffffffc02019c0 <swap_init_mm>
ffffffffc0200d48:	bf55                	j	ffffffffc0200cfc <vmm_init+0x4c>
ffffffffc0200d4a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d4e:	1f900913          	li	s2,505
ffffffffc0200d52:	a819                	j	ffffffffc0200d68 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0200d54:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d56:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d58:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d5c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d5e:	8526                	mv	a0,s1
ffffffffc0200d60:	e4bff0ef          	jal	ra,ffffffffc0200baa <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d64:	03240a63          	beq	s0,s2,ffffffffc0200d98 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d68:	03000513          	li	a0,48
ffffffffc0200d6c:	637020ef          	jal	ra,ffffffffc0203ba2 <kmalloc>
ffffffffc0200d70:	85aa                	mv	a1,a0
ffffffffc0200d72:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d76:	fd79                	bnez	a0,ffffffffc0200d54 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0200d78:	00004697          	auipc	a3,0x4
ffffffffc0200d7c:	2d868693          	addi	a3,a3,728 # ffffffffc0205050 <commands+0x9e0>
ffffffffc0200d80:	00004617          	auipc	a2,0x4
ffffffffc0200d84:	01860613          	addi	a2,a2,24 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200d88:	0d400593          	li	a1,212
ffffffffc0200d8c:	00004517          	auipc	a0,0x4
ffffffffc0200d90:	02450513          	addi	a0,a0,36 # ffffffffc0204db0 <commands+0x740>
ffffffffc0200d94:	b6eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0200d98:	649c                	ld	a5,8(s1)
ffffffffc0200d9a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200d9c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200da0:	2ef48463          	beq	s1,a5,ffffffffc0201088 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200da4:	fe87b603          	ld	a2,-24(a5)
ffffffffc0200da8:	ffe70693          	addi	a3,a4,-2
ffffffffc0200dac:	26d61e63          	bne	a2,a3,ffffffffc0201028 <vmm_init+0x378>
ffffffffc0200db0:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200db4:	26e69a63          	bne	a3,a4,ffffffffc0201028 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200db8:	0715                	addi	a4,a4,5
ffffffffc0200dba:	679c                	ld	a5,8(a5)
ffffffffc0200dbc:	feb712e3          	bne	a4,a1,ffffffffc0200da0 <vmm_init+0xf0>
ffffffffc0200dc0:	4b1d                	li	s6,7
ffffffffc0200dc2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200dc4:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200dc8:	85a2                	mv	a1,s0
ffffffffc0200dca:	8526                	mv	a0,s1
ffffffffc0200dcc:	d9fff0ef          	jal	ra,ffffffffc0200b6a <find_vma>
ffffffffc0200dd0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200dd2:	2c050b63          	beqz	a0,ffffffffc02010a8 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200dd6:	00140593          	addi	a1,s0,1
ffffffffc0200dda:	8526                	mv	a0,s1
ffffffffc0200ddc:	d8fff0ef          	jal	ra,ffffffffc0200b6a <find_vma>
ffffffffc0200de0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0200de2:	2e050363          	beqz	a0,ffffffffc02010c8 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200de6:	85da                	mv	a1,s6
ffffffffc0200de8:	8526                	mv	a0,s1
ffffffffc0200dea:	d81ff0ef          	jal	ra,ffffffffc0200b6a <find_vma>
        assert(vma3 == NULL);
ffffffffc0200dee:	2e051d63          	bnez	a0,ffffffffc02010e8 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200df2:	00340593          	addi	a1,s0,3
ffffffffc0200df6:	8526                	mv	a0,s1
ffffffffc0200df8:	d73ff0ef          	jal	ra,ffffffffc0200b6a <find_vma>
        assert(vma4 == NULL);
ffffffffc0200dfc:	30051663          	bnez	a0,ffffffffc0201108 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200e00:	00440593          	addi	a1,s0,4
ffffffffc0200e04:	8526                	mv	a0,s1
ffffffffc0200e06:	d65ff0ef          	jal	ra,ffffffffc0200b6a <find_vma>
        assert(vma5 == NULL);
ffffffffc0200e0a:	30051f63          	bnez	a0,ffffffffc0201128 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200e0e:	00893783          	ld	a5,8(s2)
ffffffffc0200e12:	24879b63          	bne	a5,s0,ffffffffc0201068 <vmm_init+0x3b8>
ffffffffc0200e16:	01093783          	ld	a5,16(s2)
ffffffffc0200e1a:	25679763          	bne	a5,s6,ffffffffc0201068 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200e1e:	008ab783          	ld	a5,8(s5)
ffffffffc0200e22:	22879363          	bne	a5,s0,ffffffffc0201048 <vmm_init+0x398>
ffffffffc0200e26:	010ab783          	ld	a5,16(s5)
ffffffffc0200e2a:	21679f63          	bne	a5,s6,ffffffffc0201048 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e2e:	0415                	addi	s0,s0,5
ffffffffc0200e30:	0b15                	addi	s6,s6,5
ffffffffc0200e32:	f9741be3          	bne	s0,s7,ffffffffc0200dc8 <vmm_init+0x118>
ffffffffc0200e36:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e38:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200e3a:	85a2                	mv	a1,s0
ffffffffc0200e3c:	8526                	mv	a0,s1
ffffffffc0200e3e:	d2dff0ef          	jal	ra,ffffffffc0200b6a <find_vma>
ffffffffc0200e42:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200e46:	c90d                	beqz	a0,ffffffffc0200e78 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200e48:	6914                	ld	a3,16(a0)
ffffffffc0200e4a:	6510                	ld	a2,8(a0)
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	0d450513          	addi	a0,a0,212 # ffffffffc0204f20 <commands+0x8b0>
ffffffffc0200e54:	a66ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e58:	00004697          	auipc	a3,0x4
ffffffffc0200e5c:	0f068693          	addi	a3,a3,240 # ffffffffc0204f48 <commands+0x8d8>
ffffffffc0200e60:	00004617          	auipc	a2,0x4
ffffffffc0200e64:	f3860613          	addi	a2,a2,-200 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200e68:	0f600593          	li	a1,246
ffffffffc0200e6c:	00004517          	auipc	a0,0x4
ffffffffc0200e70:	f4450513          	addi	a0,a0,-188 # ffffffffc0204db0 <commands+0x740>
ffffffffc0200e74:	a8eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200e78:	147d                	addi	s0,s0,-1
ffffffffc0200e7a:	fd2410e3          	bne	s0,s2,ffffffffc0200e3a <vmm_init+0x18a>
ffffffffc0200e7e:	a811                	j	ffffffffc0200e92 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e80:	6118                	ld	a4,0(a0)
ffffffffc0200e82:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200e84:	03000593          	li	a1,48
ffffffffc0200e88:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200e8a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200e8c:	e398                	sd	a4,0(a5)
ffffffffc0200e8e:	5cf020ef          	jal	ra,ffffffffc0203c5c <kfree>
    return listelm->next;
ffffffffc0200e92:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200e94:	fea496e3          	bne	s1,a0,ffffffffc0200e80 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200e98:	03000593          	li	a1,48
ffffffffc0200e9c:	8526                	mv	a0,s1
ffffffffc0200e9e:	5bf020ef          	jal	ra,ffffffffc0203c5c <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200ea2:	41b010ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
ffffffffc0200ea6:	3caa1163          	bne	s4,a0,ffffffffc0201268 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200eaa:	00004517          	auipc	a0,0x4
ffffffffc0200eae:	0de50513          	addi	a0,a0,222 # ffffffffc0204f88 <commands+0x918>
ffffffffc0200eb2:	a08ff0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200eb6:	407010ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
ffffffffc0200eba:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ebc:	03000513          	li	a0,48
ffffffffc0200ec0:	4e3020ef          	jal	ra,ffffffffc0203ba2 <kmalloc>
ffffffffc0200ec4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ec6:	2a050163          	beqz	a0,ffffffffc0201168 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200eca:	00010797          	auipc	a5,0x10
ffffffffc0200ece:	66e7a783          	lw	a5,1646(a5) # ffffffffc0211538 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200ed2:	e508                	sd	a0,8(a0)
ffffffffc0200ed4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200ed6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200eda:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ede:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ee2:	14079063          	bnez	a5,ffffffffc0201022 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0200ee6:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200eea:	00010917          	auipc	s2,0x10
ffffffffc0200eee:	66693903          	ld	s2,1638(s2) # ffffffffc0211550 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200ef2:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200ef6:	00010717          	auipc	a4,0x10
ffffffffc0200efa:	62873123          	sd	s0,1570(a4) # ffffffffc0211518 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200efe:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200f02:	24079363          	bnez	a5,ffffffffc0201148 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f06:	03000513          	li	a0,48
ffffffffc0200f0a:	499020ef          	jal	ra,ffffffffc0203ba2 <kmalloc>
ffffffffc0200f0e:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0200f10:	28050063          	beqz	a0,ffffffffc0201190 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0200f14:	002007b7          	lui	a5,0x200
ffffffffc0200f18:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0200f1c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200f1e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f20:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f24:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200f26:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f2a:	c81ff0ef          	jal	ra,ffffffffc0200baa <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f2e:	10000593          	li	a1,256
ffffffffc0200f32:	8522                	mv	a0,s0
ffffffffc0200f34:	c37ff0ef          	jal	ra,ffffffffc0200b6a <find_vma>
ffffffffc0200f38:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f3c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f40:	26aa1863          	bne	s4,a0,ffffffffc02011b0 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0200f44:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200f48:	0785                	addi	a5,a5,1
ffffffffc0200f4a:	fee79de3          	bne	a5,a4,ffffffffc0200f44 <vmm_init+0x294>
        sum += i;
ffffffffc0200f4e:	6705                	lui	a4,0x1
ffffffffc0200f50:	10000793          	li	a5,256
ffffffffc0200f54:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200f58:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200f5c:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200f60:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200f62:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200f64:	fec79ce3          	bne	a5,a2,ffffffffc0200f5c <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0200f68:	26071463          	bnez	a4,ffffffffc02011d0 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200f6c:	4581                	li	a1,0
ffffffffc0200f6e:	854a                	mv	a0,s2
ffffffffc0200f70:	5d7010ef          	jal	ra,ffffffffc0202d46 <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f74:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f78:	00010717          	auipc	a4,0x10
ffffffffc0200f7c:	5e073703          	ld	a4,1504(a4) # ffffffffc0211558 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f80:	078a                	slli	a5,a5,0x2
ffffffffc0200f82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f84:	26e7f663          	bgeu	a5,a4,ffffffffc02011f0 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f88:	00005717          	auipc	a4,0x5
ffffffffc0200f8c:	26873703          	ld	a4,616(a4) # ffffffffc02061f0 <nbase>
ffffffffc0200f90:	8f99                	sub	a5,a5,a4
ffffffffc0200f92:	00379713          	slli	a4,a5,0x3
ffffffffc0200f96:	97ba                	add	a5,a5,a4
ffffffffc0200f98:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f9a:	00010517          	auipc	a0,0x10
ffffffffc0200f9e:	5c653503          	ld	a0,1478(a0) # ffffffffc0211560 <pages>
ffffffffc0200fa2:	953e                	add	a0,a0,a5
ffffffffc0200fa4:	4585                	li	a1,1
ffffffffc0200fa6:	2d7010ef          	jal	ra,ffffffffc0202a7c <free_pages>
    return listelm->next;
ffffffffc0200faa:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0200fac:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0200fb0:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fb4:	00a40e63          	beq	s0,a0,ffffffffc0200fd0 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fb8:	6118                	ld	a4,0(a0)
ffffffffc0200fba:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200fbc:	03000593          	li	a1,48
ffffffffc0200fc0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200fc2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fc4:	e398                	sd	a4,0(a5)
ffffffffc0200fc6:	497020ef          	jal	ra,ffffffffc0203c5c <kfree>
    return listelm->next;
ffffffffc0200fca:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fcc:	fea416e3          	bne	s0,a0,ffffffffc0200fb8 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fd0:	03000593          	li	a1,48
ffffffffc0200fd4:	8522                	mv	a0,s0
ffffffffc0200fd6:	487020ef          	jal	ra,ffffffffc0203c5c <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200fda:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0200fdc:	00010797          	auipc	a5,0x10
ffffffffc0200fe0:	5207be23          	sd	zero,1340(a5) # ffffffffc0211518 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fe4:	2d9010ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
ffffffffc0200fe8:	22a49063          	bne	s1,a0,ffffffffc0201208 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200fec:	00004517          	auipc	a0,0x4
ffffffffc0200ff0:	02c50513          	addi	a0,a0,44 # ffffffffc0205018 <commands+0x9a8>
ffffffffc0200ff4:	8c6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200ff8:	2c5010ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0200ffc:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200ffe:	22a99563          	bne	s3,a0,ffffffffc0201228 <vmm_init+0x578>
}
ffffffffc0201002:	6406                	ld	s0,64(sp)
ffffffffc0201004:	60a6                	ld	ra,72(sp)
ffffffffc0201006:	74e2                	ld	s1,56(sp)
ffffffffc0201008:	7942                	ld	s2,48(sp)
ffffffffc020100a:	79a2                	ld	s3,40(sp)
ffffffffc020100c:	7a02                	ld	s4,32(sp)
ffffffffc020100e:	6ae2                	ld	s5,24(sp)
ffffffffc0201010:	6b42                	ld	s6,16(sp)
ffffffffc0201012:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201014:	00004517          	auipc	a0,0x4
ffffffffc0201018:	02450513          	addi	a0,a0,36 # ffffffffc0205038 <commands+0x9c8>
}
ffffffffc020101c:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020101e:	89cff06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201022:	19f000ef          	jal	ra,ffffffffc02019c0 <swap_init_mm>
ffffffffc0201026:	b5d1                	j	ffffffffc0200eea <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	e1068693          	addi	a3,a3,-496 # ffffffffc0204e38 <commands+0x7c8>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	d6860613          	addi	a2,a2,-664 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201038:	0dd00593          	li	a1,221
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	d7450513          	addi	a0,a0,-652 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201044:	8beff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	ea868693          	addi	a3,a3,-344 # ffffffffc0204ef0 <commands+0x880>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	d4860613          	addi	a2,a2,-696 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201058:	0ee00593          	li	a1,238
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	d5450513          	addi	a0,a0,-684 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201064:	89eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	e5868693          	addi	a3,a3,-424 # ffffffffc0204ec0 <commands+0x850>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	d2860613          	addi	a2,a2,-728 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201078:	0ed00593          	li	a1,237
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	d3450513          	addi	a0,a0,-716 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201084:	87eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	d9868693          	addi	a3,a3,-616 # ffffffffc0204e20 <commands+0x7b0>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	d0860613          	addi	a2,a2,-760 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201098:	0db00593          	li	a1,219
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	d1450513          	addi	a0,a0,-748 # ffffffffc0204db0 <commands+0x740>
ffffffffc02010a4:	85eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	dc868693          	addi	a3,a3,-568 # ffffffffc0204e70 <commands+0x800>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	ce860613          	addi	a2,a2,-792 # ffffffffc0204d98 <commands+0x728>
ffffffffc02010b8:	0e300593          	li	a1,227
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	cf450513          	addi	a0,a0,-780 # ffffffffc0204db0 <commands+0x740>
ffffffffc02010c4:	83eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	db868693          	addi	a3,a3,-584 # ffffffffc0204e80 <commands+0x810>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	cc860613          	addi	a2,a2,-824 # ffffffffc0204d98 <commands+0x728>
ffffffffc02010d8:	0e500593          	li	a1,229
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	cd450513          	addi	a0,a0,-812 # ffffffffc0204db0 <commands+0x740>
ffffffffc02010e4:	81eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	da868693          	addi	a3,a3,-600 # ffffffffc0204e90 <commands+0x820>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	ca860613          	addi	a2,a2,-856 # ffffffffc0204d98 <commands+0x728>
ffffffffc02010f8:	0e700593          	li	a1,231
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	cb450513          	addi	a0,a0,-844 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201104:	ffffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	d9868693          	addi	a3,a3,-616 # ffffffffc0204ea0 <commands+0x830>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	c8860613          	addi	a2,a2,-888 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201118:	0e900593          	li	a1,233
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	c9450513          	addi	a0,a0,-876 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201124:	fdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	d8868693          	addi	a3,a3,-632 # ffffffffc0204eb0 <commands+0x840>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	c6860613          	addi	a2,a2,-920 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201138:	0eb00593          	li	a1,235
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	c7450513          	addi	a0,a0,-908 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201144:	fbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	e6068693          	addi	a3,a3,-416 # ffffffffc0204fa8 <commands+0x938>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	c4860613          	addi	a2,a2,-952 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201158:	10d00593          	li	a1,269
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	c5450513          	addi	a0,a0,-940 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201164:	f9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201168:	00004697          	auipc	a3,0x4
ffffffffc020116c:	ef868693          	addi	a3,a3,-264 # ffffffffc0205060 <commands+0x9f0>
ffffffffc0201170:	00004617          	auipc	a2,0x4
ffffffffc0201174:	c2860613          	addi	a2,a2,-984 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201178:	10a00593          	li	a1,266
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	c3450513          	addi	a0,a0,-972 # ffffffffc0204db0 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201184:	00010797          	auipc	a5,0x10
ffffffffc0201188:	3807ba23          	sd	zero,916(a5) # ffffffffc0211518 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020118c:	f77fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0201190:	00004697          	auipc	a3,0x4
ffffffffc0201194:	ec068693          	addi	a3,a3,-320 # ffffffffc0205050 <commands+0x9e0>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	c0060613          	addi	a2,a2,-1024 # ffffffffc0204d98 <commands+0x728>
ffffffffc02011a0:	11100593          	li	a1,273
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0204db0 <commands+0x740>
ffffffffc02011ac:	f57fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	e0868693          	addi	a3,a3,-504 # ffffffffc0204fb8 <commands+0x948>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	be060613          	addi	a2,a2,-1056 # ffffffffc0204d98 <commands+0x728>
ffffffffc02011c0:	11600593          	li	a1,278
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	bec50513          	addi	a0,a0,-1044 # ffffffffc0204db0 <commands+0x740>
ffffffffc02011cc:	f37fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02011d0:	00004697          	auipc	a3,0x4
ffffffffc02011d4:	e0868693          	addi	a3,a3,-504 # ffffffffc0204fd8 <commands+0x968>
ffffffffc02011d8:	00004617          	auipc	a2,0x4
ffffffffc02011dc:	bc060613          	addi	a2,a2,-1088 # ffffffffc0204d98 <commands+0x728>
ffffffffc02011e0:	12000593          	li	a1,288
ffffffffc02011e4:	00004517          	auipc	a0,0x4
ffffffffc02011e8:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0204db0 <commands+0x740>
ffffffffc02011ec:	f17fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	df860613          	addi	a2,a2,-520 # ffffffffc0204fe8 <commands+0x978>
ffffffffc02011f8:	06500593          	li	a1,101
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	e0c50513          	addi	a0,a0,-500 # ffffffffc0205008 <commands+0x998>
ffffffffc0201204:	efffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	d5868693          	addi	a3,a3,-680 # ffffffffc0204f60 <commands+0x8f0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201218:	12e00593          	li	a1,302
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	b9450513          	addi	a0,a0,-1132 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201224:	edffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	d3868693          	addi	a3,a3,-712 # ffffffffc0204f60 <commands+0x8f0>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201238:	0bd00593          	li	a1,189
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	b7450513          	addi	a0,a0,-1164 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201244:	ebffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	e3068693          	addi	a3,a3,-464 # ffffffffc0205078 <commands+0xa08>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201258:	0c700593          	li	a1,199
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	b5450513          	addi	a0,a0,-1196 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201264:	e9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201268:	00004697          	auipc	a3,0x4
ffffffffc020126c:	cf868693          	addi	a3,a3,-776 # ffffffffc0204f60 <commands+0x8f0>
ffffffffc0201270:	00004617          	auipc	a2,0x4
ffffffffc0201274:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201278:	0fb00593          	li	a1,251
ffffffffc020127c:	00004517          	auipc	a0,0x4
ffffffffc0201280:	b3450513          	addi	a0,a0,-1228 # ffffffffc0204db0 <commands+0x740>
ffffffffc0201284:	e7ffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201288 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201288:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020128a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020128c:	f022                	sd	s0,32(sp)
ffffffffc020128e:	ec26                	sd	s1,24(sp)
ffffffffc0201290:	f406                	sd	ra,40(sp)
ffffffffc0201292:	e84a                	sd	s2,16(sp)
ffffffffc0201294:	8432                	mv	s0,a2
ffffffffc0201296:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201298:	8d3ff0ef          	jal	ra,ffffffffc0200b6a <find_vma>

    pgfault_num++;
ffffffffc020129c:	00010797          	auipc	a5,0x10
ffffffffc02012a0:	2847a783          	lw	a5,644(a5) # ffffffffc0211520 <pgfault_num>
ffffffffc02012a4:	2785                	addiw	a5,a5,1
ffffffffc02012a6:	00010717          	auipc	a4,0x10
ffffffffc02012aa:	26f72d23          	sw	a5,634(a4) # ffffffffc0211520 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02012ae:	c159                	beqz	a0,ffffffffc0201334 <do_pgfault+0xac>
ffffffffc02012b0:	651c                	ld	a5,8(a0)
ffffffffc02012b2:	08f46163          	bltu	s0,a5,ffffffffc0201334 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012b6:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02012b8:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012ba:	8b89                	andi	a5,a5,2
ffffffffc02012bc:	ebb1                	bnez	a5,ffffffffc0201310 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012be:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012c0:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012c2:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012c4:	85a2                	mv	a1,s0
ffffffffc02012c6:	4605                	li	a2,1
ffffffffc02012c8:	02f010ef          	jal	ra,ffffffffc0202af6 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02012cc:	610c                	ld	a1,0(a0)
ffffffffc02012ce:	c1b9                	beqz	a1,ffffffffc0201314 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02012d0:	00010797          	auipc	a5,0x10
ffffffffc02012d4:	2687a783          	lw	a5,616(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc02012d8:	c7bd                	beqz	a5,ffffffffc0201346 <do_pgfault+0xbe>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc02012da:	85a2                	mv	a1,s0
ffffffffc02012dc:	0030                	addi	a2,sp,8
ffffffffc02012de:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02012e0:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc02012e2:	00b000ef          	jal	ra,ffffffffc0201aec <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc02012e6:	65a2                	ld	a1,8(sp)
ffffffffc02012e8:	6c88                	ld	a0,24(s1)
ffffffffc02012ea:	86ca                	mv	a3,s2
ffffffffc02012ec:	8622                	mv	a2,s0
ffffffffc02012ee:	2f3010ef          	jal	ra,ffffffffc0202de0 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc02012f2:	6622                	ld	a2,8(sp)
ffffffffc02012f4:	4685                	li	a3,1
ffffffffc02012f6:	85a2                	mv	a1,s0
ffffffffc02012f8:	8526                	mv	a0,s1
ffffffffc02012fa:	6d2000ef          	jal	ra,ffffffffc02019cc <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02012fe:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0201300:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0201302:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0201304:	70a2                	ld	ra,40(sp)
ffffffffc0201306:	7402                	ld	s0,32(sp)
ffffffffc0201308:	64e2                	ld	s1,24(sp)
ffffffffc020130a:	6942                	ld	s2,16(sp)
ffffffffc020130c:	6145                	addi	sp,sp,48
ffffffffc020130e:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0201310:	4959                	li	s2,22
ffffffffc0201312:	b775                	j	ffffffffc02012be <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201314:	6c88                	ld	a0,24(s1)
ffffffffc0201316:	864a                	mv	a2,s2
ffffffffc0201318:	85a2                	mv	a1,s0
ffffffffc020131a:	7d0020ef          	jal	ra,ffffffffc0203aea <pgdir_alloc_page>
ffffffffc020131e:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201320:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201322:	f3ed                	bnez	a5,ffffffffc0201304 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201324:	00004517          	auipc	a0,0x4
ffffffffc0201328:	d9450513          	addi	a0,a0,-620 # ffffffffc02050b8 <commands+0xa48>
ffffffffc020132c:	d8ffe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201330:	5571                	li	a0,-4
            goto failed;
ffffffffc0201332:	bfc9                	j	ffffffffc0201304 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201334:	85a2                	mv	a1,s0
ffffffffc0201336:	00004517          	auipc	a0,0x4
ffffffffc020133a:	d5250513          	addi	a0,a0,-686 # ffffffffc0205088 <commands+0xa18>
ffffffffc020133e:	d7dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0201342:	5575                	li	a0,-3
        goto failed;
ffffffffc0201344:	b7c1                	j	ffffffffc0201304 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201346:	00004517          	auipc	a0,0x4
ffffffffc020134a:	d9a50513          	addi	a0,a0,-614 # ffffffffc02050e0 <commands+0xa70>
ffffffffc020134e:	d6dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201352:	5571                	li	a0,-4
            goto failed;
ffffffffc0201354:	bf45                	j	ffffffffc0201304 <do_pgfault+0x7c>

ffffffffc0201356 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201356:	7135                	addi	sp,sp,-160
ffffffffc0201358:	ed06                	sd	ra,152(sp)
ffffffffc020135a:	e922                	sd	s0,144(sp)
ffffffffc020135c:	e526                	sd	s1,136(sp)
ffffffffc020135e:	e14a                	sd	s2,128(sp)
ffffffffc0201360:	fcce                	sd	s3,120(sp)
ffffffffc0201362:	f8d2                	sd	s4,112(sp)
ffffffffc0201364:	f4d6                	sd	s5,104(sp)
ffffffffc0201366:	f0da                	sd	s6,96(sp)
ffffffffc0201368:	ecde                	sd	s7,88(sp)
ffffffffc020136a:	e8e2                	sd	s8,80(sp)
ffffffffc020136c:	e4e6                	sd	s9,72(sp)
ffffffffc020136e:	e0ea                	sd	s10,64(sp)
ffffffffc0201370:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201372:	1d3020ef          	jal	ra,ffffffffc0203d44 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201376:	00010697          	auipc	a3,0x10
ffffffffc020137a:	1b26b683          	ld	a3,434(a3) # ffffffffc0211528 <max_swap_offset>
ffffffffc020137e:	010007b7          	lui	a5,0x1000
ffffffffc0201382:	ff968713          	addi	a4,a3,-7
ffffffffc0201386:	17e1                	addi	a5,a5,-8
ffffffffc0201388:	3ee7e063          	bltu	a5,a4,ffffffffc0201768 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020138c:	00009797          	auipc	a5,0x9
ffffffffc0201390:	c7478793          	addi	a5,a5,-908 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0201394:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0201396:	00010b17          	auipc	s6,0x10
ffffffffc020139a:	19ab0b13          	addi	s6,s6,410 # ffffffffc0211530 <sm>
ffffffffc020139e:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02013a2:	9702                	jalr	a4
ffffffffc02013a4:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02013a6:	c10d                	beqz	a0,ffffffffc02013c8 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02013a8:	60ea                	ld	ra,152(sp)
ffffffffc02013aa:	644a                	ld	s0,144(sp)
ffffffffc02013ac:	64aa                	ld	s1,136(sp)
ffffffffc02013ae:	690a                	ld	s2,128(sp)
ffffffffc02013b0:	7a46                	ld	s4,112(sp)
ffffffffc02013b2:	7aa6                	ld	s5,104(sp)
ffffffffc02013b4:	7b06                	ld	s6,96(sp)
ffffffffc02013b6:	6be6                	ld	s7,88(sp)
ffffffffc02013b8:	6c46                	ld	s8,80(sp)
ffffffffc02013ba:	6ca6                	ld	s9,72(sp)
ffffffffc02013bc:	6d06                	ld	s10,64(sp)
ffffffffc02013be:	7de2                	ld	s11,56(sp)
ffffffffc02013c0:	854e                	mv	a0,s3
ffffffffc02013c2:	79e6                	ld	s3,120(sp)
ffffffffc02013c4:	610d                	addi	sp,sp,160
ffffffffc02013c6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013c8:	000b3783          	ld	a5,0(s6)
ffffffffc02013cc:	00004517          	auipc	a0,0x4
ffffffffc02013d0:	d6c50513          	addi	a0,a0,-660 # ffffffffc0205138 <commands+0xac8>
ffffffffc02013d4:	00010497          	auipc	s1,0x10
ffffffffc02013d8:	cfc48493          	addi	s1,s1,-772 # ffffffffc02110d0 <free_area>
ffffffffc02013dc:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02013de:	4785                	li	a5,1
ffffffffc02013e0:	00010717          	auipc	a4,0x10
ffffffffc02013e4:	14f72c23          	sw	a5,344(a4) # ffffffffc0211538 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013e8:	cd3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02013ec:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02013ee:	4401                	li	s0,0
ffffffffc02013f0:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013f2:	2c978163          	beq	a5,s1,ffffffffc02016b4 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013f6:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02013fa:	8b09                	andi	a4,a4,2
ffffffffc02013fc:	2a070e63          	beqz	a4,ffffffffc02016b8 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0201400:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201404:	679c                	ld	a5,8(a5)
ffffffffc0201406:	2d05                	addiw	s10,s10,1
ffffffffc0201408:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020140a:	fe9796e3          	bne	a5,s1,ffffffffc02013f6 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020140e:	8922                	mv	s2,s0
ffffffffc0201410:	6ac010ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
ffffffffc0201414:	47251663          	bne	a0,s2,ffffffffc0201880 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201418:	8622                	mv	a2,s0
ffffffffc020141a:	85ea                	mv	a1,s10
ffffffffc020141c:	00004517          	auipc	a0,0x4
ffffffffc0201420:	d6450513          	addi	a0,a0,-668 # ffffffffc0205180 <commands+0xb10>
ffffffffc0201424:	c97fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201428:	eccff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
ffffffffc020142c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020142e:	52050963          	beqz	a0,ffffffffc0201960 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201432:	00010797          	auipc	a5,0x10
ffffffffc0201436:	0e678793          	addi	a5,a5,230 # ffffffffc0211518 <check_mm_struct>
ffffffffc020143a:	6398                	ld	a4,0(a5)
ffffffffc020143c:	54071263          	bnez	a4,ffffffffc0201980 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201440:	00010b97          	auipc	s7,0x10
ffffffffc0201444:	110bbb83          	ld	s7,272(s7) # ffffffffc0211550 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0201448:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc020144c:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020144e:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201452:	3c071763          	bnez	a4,ffffffffc0201820 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201456:	6599                	lui	a1,0x6
ffffffffc0201458:	460d                	li	a2,3
ffffffffc020145a:	6505                	lui	a0,0x1
ffffffffc020145c:	ee0ff0ef          	jal	ra,ffffffffc0200b3c <vma_create>
ffffffffc0201460:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201462:	3c050f63          	beqz	a0,ffffffffc0201840 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0201466:	8556                	mv	a0,s5
ffffffffc0201468:	f42ff0ef          	jal	ra,ffffffffc0200baa <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020146c:	00004517          	auipc	a0,0x4
ffffffffc0201470:	d5450513          	addi	a0,a0,-684 # ffffffffc02051c0 <commands+0xb50>
ffffffffc0201474:	c47fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201478:	018ab503          	ld	a0,24(s5)
ffffffffc020147c:	4605                	li	a2,1
ffffffffc020147e:	6585                	lui	a1,0x1
ffffffffc0201480:	676010ef          	jal	ra,ffffffffc0202af6 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201484:	3c050e63          	beqz	a0,ffffffffc0201860 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201488:	00004517          	auipc	a0,0x4
ffffffffc020148c:	d8850513          	addi	a0,a0,-632 # ffffffffc0205210 <commands+0xba0>
ffffffffc0201490:	00010917          	auipc	s2,0x10
ffffffffc0201494:	bd090913          	addi	s2,s2,-1072 # ffffffffc0211060 <check_rp>
ffffffffc0201498:	c23fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020149c:	00010a17          	auipc	s4,0x10
ffffffffc02014a0:	be4a0a13          	addi	s4,s4,-1052 # ffffffffc0211080 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02014a4:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc02014a6:	4505                	li	a0,1
ffffffffc02014a8:	542010ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc02014ac:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02014b0:	28050c63          	beqz	a0,ffffffffc0201748 <swap_init+0x3f2>
ffffffffc02014b4:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02014b6:	8b89                	andi	a5,a5,2
ffffffffc02014b8:	26079863          	bnez	a5,ffffffffc0201728 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014bc:	0c21                	addi	s8,s8,8
ffffffffc02014be:	ff4c14e3          	bne	s8,s4,ffffffffc02014a6 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02014c2:	609c                	ld	a5,0(s1)
ffffffffc02014c4:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc02014c8:	e084                	sd	s1,0(s1)
ffffffffc02014ca:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc02014cc:	489c                	lw	a5,16(s1)
ffffffffc02014ce:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc02014d0:	00010c17          	auipc	s8,0x10
ffffffffc02014d4:	b90c0c13          	addi	s8,s8,-1136 # ffffffffc0211060 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02014d8:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02014da:	00010797          	auipc	a5,0x10
ffffffffc02014de:	c007a323          	sw	zero,-1018(a5) # ffffffffc02110e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02014e2:	000c3503          	ld	a0,0(s8)
ffffffffc02014e6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014e8:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02014ea:	592010ef          	jal	ra,ffffffffc0202a7c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014ee:	ff4c1ae3          	bne	s8,s4,ffffffffc02014e2 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02014f2:	0104ac03          	lw	s8,16(s1)
ffffffffc02014f6:	4791                	li	a5,4
ffffffffc02014f8:	4afc1463          	bne	s8,a5,ffffffffc02019a0 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02014fc:	00004517          	auipc	a0,0x4
ffffffffc0201500:	d9c50513          	addi	a0,a0,-612 # ffffffffc0205298 <commands+0xc28>
ffffffffc0201504:	bb7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201508:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020150a:	00010797          	auipc	a5,0x10
ffffffffc020150e:	0007ab23          	sw	zero,22(a5) # ffffffffc0211520 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201512:	4529                	li	a0,10
ffffffffc0201514:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0201518:	00010597          	auipc	a1,0x10
ffffffffc020151c:	0085a583          	lw	a1,8(a1) # ffffffffc0211520 <pgfault_num>
ffffffffc0201520:	4805                	li	a6,1
ffffffffc0201522:	00010797          	auipc	a5,0x10
ffffffffc0201526:	ffe78793          	addi	a5,a5,-2 # ffffffffc0211520 <pgfault_num>
ffffffffc020152a:	3f059b63          	bne	a1,a6,ffffffffc0201920 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020152e:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0201532:	4390                	lw	a2,0(a5)
ffffffffc0201534:	2601                	sext.w	a2,a2
ffffffffc0201536:	40b61563          	bne	a2,a1,ffffffffc0201940 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020153a:	6589                	lui	a1,0x2
ffffffffc020153c:	452d                	li	a0,11
ffffffffc020153e:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201542:	4390                	lw	a2,0(a5)
ffffffffc0201544:	4809                	li	a6,2
ffffffffc0201546:	2601                	sext.w	a2,a2
ffffffffc0201548:	35061c63          	bne	a2,a6,ffffffffc02018a0 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020154c:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201550:	438c                	lw	a1,0(a5)
ffffffffc0201552:	2581                	sext.w	a1,a1
ffffffffc0201554:	36c59663          	bne	a1,a2,ffffffffc02018c0 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201558:	658d                	lui	a1,0x3
ffffffffc020155a:	4531                	li	a0,12
ffffffffc020155c:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201560:	4390                	lw	a2,0(a5)
ffffffffc0201562:	480d                	li	a6,3
ffffffffc0201564:	2601                	sext.w	a2,a2
ffffffffc0201566:	37061d63          	bne	a2,a6,ffffffffc02018e0 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020156a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc020156e:	438c                	lw	a1,0(a5)
ffffffffc0201570:	2581                	sext.w	a1,a1
ffffffffc0201572:	38c59763          	bne	a1,a2,ffffffffc0201900 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201576:	6591                	lui	a1,0x4
ffffffffc0201578:	4535                	li	a0,13
ffffffffc020157a:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc020157e:	4390                	lw	a2,0(a5)
ffffffffc0201580:	2601                	sext.w	a2,a2
ffffffffc0201582:	21861f63          	bne	a2,s8,ffffffffc02017a0 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201586:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc020158a:	439c                	lw	a5,0(a5)
ffffffffc020158c:	2781                	sext.w	a5,a5
ffffffffc020158e:	22c79963          	bne	a5,a2,ffffffffc02017c0 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201592:	489c                	lw	a5,16(s1)
ffffffffc0201594:	24079663          	bnez	a5,ffffffffc02017e0 <swap_init+0x48a>
ffffffffc0201598:	00010797          	auipc	a5,0x10
ffffffffc020159c:	ae878793          	addi	a5,a5,-1304 # ffffffffc0211080 <swap_in_seq_no>
ffffffffc02015a0:	00010617          	auipc	a2,0x10
ffffffffc02015a4:	b0860613          	addi	a2,a2,-1272 # ffffffffc02110a8 <swap_out_seq_no>
ffffffffc02015a8:	00010517          	auipc	a0,0x10
ffffffffc02015ac:	b0050513          	addi	a0,a0,-1280 # ffffffffc02110a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02015b0:	55fd                	li	a1,-1
ffffffffc02015b2:	c38c                	sw	a1,0(a5)
ffffffffc02015b4:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02015b6:	0791                	addi	a5,a5,4
ffffffffc02015b8:	0611                	addi	a2,a2,4
ffffffffc02015ba:	fef51ce3          	bne	a0,a5,ffffffffc02015b2 <swap_init+0x25c>
ffffffffc02015be:	00010817          	auipc	a6,0x10
ffffffffc02015c2:	a8280813          	addi	a6,a6,-1406 # ffffffffc0211040 <check_ptep>
ffffffffc02015c6:	00010897          	auipc	a7,0x10
ffffffffc02015ca:	a9a88893          	addi	a7,a7,-1382 # ffffffffc0211060 <check_rp>
ffffffffc02015ce:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc02015d0:	00010c97          	auipc	s9,0x10
ffffffffc02015d4:	f90c8c93          	addi	s9,s9,-112 # ffffffffc0211560 <pages>
ffffffffc02015d8:	00005c17          	auipc	s8,0x5
ffffffffc02015dc:	c18c0c13          	addi	s8,s8,-1000 # ffffffffc02061f0 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02015e0:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015e4:	4601                	li	a2,0
ffffffffc02015e6:	855e                	mv	a0,s7
ffffffffc02015e8:	ec46                	sd	a7,24(sp)
ffffffffc02015ea:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc02015ec:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015ee:	508010ef          	jal	ra,ffffffffc0202af6 <get_pte>
ffffffffc02015f2:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02015f4:	65c2                	ld	a1,16(sp)
ffffffffc02015f6:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015f8:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc02015fc:	00010317          	auipc	t1,0x10
ffffffffc0201600:	f5c30313          	addi	t1,t1,-164 # ffffffffc0211558 <npage>
ffffffffc0201604:	16050e63          	beqz	a0,ffffffffc0201780 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201608:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020160a:	0017f613          	andi	a2,a5,1
ffffffffc020160e:	0e060563          	beqz	a2,ffffffffc02016f8 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0201612:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201616:	078a                	slli	a5,a5,0x2
ffffffffc0201618:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020161a:	0ec7fb63          	bgeu	a5,a2,ffffffffc0201710 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020161e:	000c3603          	ld	a2,0(s8)
ffffffffc0201622:	000cb503          	ld	a0,0(s9)
ffffffffc0201626:	0008bf03          	ld	t5,0(a7)
ffffffffc020162a:	8f91                	sub	a5,a5,a2
ffffffffc020162c:	00379613          	slli	a2,a5,0x3
ffffffffc0201630:	97b2                	add	a5,a5,a2
ffffffffc0201632:	078e                	slli	a5,a5,0x3
ffffffffc0201634:	97aa                	add	a5,a5,a0
ffffffffc0201636:	0aff1163          	bne	t5,a5,ffffffffc02016d8 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020163a:	6785                	lui	a5,0x1
ffffffffc020163c:	95be                	add	a1,a1,a5
ffffffffc020163e:	6795                	lui	a5,0x5
ffffffffc0201640:	0821                	addi	a6,a6,8
ffffffffc0201642:	08a1                	addi	a7,a7,8
ffffffffc0201644:	f8f59ee3          	bne	a1,a5,ffffffffc02015e0 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201648:	00004517          	auipc	a0,0x4
ffffffffc020164c:	d3050513          	addi	a0,a0,-720 # ffffffffc0205378 <commands+0xd08>
ffffffffc0201650:	a6bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201654:	000b3783          	ld	a5,0(s6)
ffffffffc0201658:	7f9c                	ld	a5,56(a5)
ffffffffc020165a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020165c:	1a051263          	bnez	a0,ffffffffc0201800 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201660:	00093503          	ld	a0,0(s2)
ffffffffc0201664:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201666:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0201668:	414010ef          	jal	ra,ffffffffc0202a7c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020166c:	ff491ae3          	bne	s2,s4,ffffffffc0201660 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201670:	8556                	mv	a0,s5
ffffffffc0201672:	e08ff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201676:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0201678:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc020167c:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc020167e:	7782                	ld	a5,32(sp)
ffffffffc0201680:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201682:	009d8a63          	beq	s11,s1,ffffffffc0201696 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201686:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc020168a:	008dbd83          	ld	s11,8(s11)
ffffffffc020168e:	3d7d                	addiw	s10,s10,-1
ffffffffc0201690:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201692:	fe9d9ae3          	bne	s11,s1,ffffffffc0201686 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201696:	8622                	mv	a2,s0
ffffffffc0201698:	85ea                	mv	a1,s10
ffffffffc020169a:	00004517          	auipc	a0,0x4
ffffffffc020169e:	d0e50513          	addi	a0,a0,-754 # ffffffffc02053a8 <commands+0xd38>
ffffffffc02016a2:	a19fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc02016a6:	00004517          	auipc	a0,0x4
ffffffffc02016aa:	d2250513          	addi	a0,a0,-734 # ffffffffc02053c8 <commands+0xd58>
ffffffffc02016ae:	a0dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc02016b2:	b9dd                	j	ffffffffc02013a8 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02016b4:	4901                	li	s2,0
ffffffffc02016b6:	bba9                	j	ffffffffc0201410 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc02016b8:	00004697          	auipc	a3,0x4
ffffffffc02016bc:	a9868693          	addi	a3,a3,-1384 # ffffffffc0205150 <commands+0xae0>
ffffffffc02016c0:	00003617          	auipc	a2,0x3
ffffffffc02016c4:	6d860613          	addi	a2,a2,1752 # ffffffffc0204d98 <commands+0x728>
ffffffffc02016c8:	0ba00593          	li	a1,186
ffffffffc02016cc:	00004517          	auipc	a0,0x4
ffffffffc02016d0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0205128 <commands+0xab8>
ffffffffc02016d4:	a2ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02016d8:	00004697          	auipc	a3,0x4
ffffffffc02016dc:	c7868693          	addi	a3,a3,-904 # ffffffffc0205350 <commands+0xce0>
ffffffffc02016e0:	00003617          	auipc	a2,0x3
ffffffffc02016e4:	6b860613          	addi	a2,a2,1720 # ffffffffc0204d98 <commands+0x728>
ffffffffc02016e8:	0fa00593          	li	a1,250
ffffffffc02016ec:	00004517          	auipc	a0,0x4
ffffffffc02016f0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0205128 <commands+0xab8>
ffffffffc02016f4:	a0ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02016f8:	00004617          	auipc	a2,0x4
ffffffffc02016fc:	c3060613          	addi	a2,a2,-976 # ffffffffc0205328 <commands+0xcb8>
ffffffffc0201700:	07000593          	li	a1,112
ffffffffc0201704:	00004517          	auipc	a0,0x4
ffffffffc0201708:	90450513          	addi	a0,a0,-1788 # ffffffffc0205008 <commands+0x998>
ffffffffc020170c:	9f7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201710:	00004617          	auipc	a2,0x4
ffffffffc0201714:	8d860613          	addi	a2,a2,-1832 # ffffffffc0204fe8 <commands+0x978>
ffffffffc0201718:	06500593          	li	a1,101
ffffffffc020171c:	00004517          	auipc	a0,0x4
ffffffffc0201720:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0205008 <commands+0x998>
ffffffffc0201724:	9dffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201728:	00004697          	auipc	a3,0x4
ffffffffc020172c:	b2868693          	addi	a3,a3,-1240 # ffffffffc0205250 <commands+0xbe0>
ffffffffc0201730:	00003617          	auipc	a2,0x3
ffffffffc0201734:	66860613          	addi	a2,a2,1640 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201738:	0db00593          	li	a1,219
ffffffffc020173c:	00004517          	auipc	a0,0x4
ffffffffc0201740:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0205128 <commands+0xab8>
ffffffffc0201744:	9bffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201748:	00004697          	auipc	a3,0x4
ffffffffc020174c:	af068693          	addi	a3,a3,-1296 # ffffffffc0205238 <commands+0xbc8>
ffffffffc0201750:	00003617          	auipc	a2,0x3
ffffffffc0201754:	64860613          	addi	a2,a2,1608 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201758:	0da00593          	li	a1,218
ffffffffc020175c:	00004517          	auipc	a0,0x4
ffffffffc0201760:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0205128 <commands+0xab8>
ffffffffc0201764:	99ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201768:	00004617          	auipc	a2,0x4
ffffffffc020176c:	9a060613          	addi	a2,a2,-1632 # ffffffffc0205108 <commands+0xa98>
ffffffffc0201770:	02700593          	li	a1,39
ffffffffc0201774:	00004517          	auipc	a0,0x4
ffffffffc0201778:	9b450513          	addi	a0,a0,-1612 # ffffffffc0205128 <commands+0xab8>
ffffffffc020177c:	987fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201780:	00004697          	auipc	a3,0x4
ffffffffc0201784:	b9068693          	addi	a3,a3,-1136 # ffffffffc0205310 <commands+0xca0>
ffffffffc0201788:	00003617          	auipc	a2,0x3
ffffffffc020178c:	61060613          	addi	a2,a2,1552 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201790:	0f900593          	li	a1,249
ffffffffc0201794:	00004517          	auipc	a0,0x4
ffffffffc0201798:	99450513          	addi	a0,a0,-1644 # ffffffffc0205128 <commands+0xab8>
ffffffffc020179c:	967fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017a0:	00004697          	auipc	a3,0x4
ffffffffc02017a4:	b5068693          	addi	a3,a3,-1200 # ffffffffc02052f0 <commands+0xc80>
ffffffffc02017a8:	00003617          	auipc	a2,0x3
ffffffffc02017ac:	5f060613          	addi	a2,a2,1520 # ffffffffc0204d98 <commands+0x728>
ffffffffc02017b0:	09d00593          	li	a1,157
ffffffffc02017b4:	00004517          	auipc	a0,0x4
ffffffffc02017b8:	97450513          	addi	a0,a0,-1676 # ffffffffc0205128 <commands+0xab8>
ffffffffc02017bc:	947fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017c0:	00004697          	auipc	a3,0x4
ffffffffc02017c4:	b3068693          	addi	a3,a3,-1232 # ffffffffc02052f0 <commands+0xc80>
ffffffffc02017c8:	00003617          	auipc	a2,0x3
ffffffffc02017cc:	5d060613          	addi	a2,a2,1488 # ffffffffc0204d98 <commands+0x728>
ffffffffc02017d0:	09f00593          	li	a1,159
ffffffffc02017d4:	00004517          	auipc	a0,0x4
ffffffffc02017d8:	95450513          	addi	a0,a0,-1708 # ffffffffc0205128 <commands+0xab8>
ffffffffc02017dc:	927fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc02017e0:	00004697          	auipc	a3,0x4
ffffffffc02017e4:	b2068693          	addi	a3,a3,-1248 # ffffffffc0205300 <commands+0xc90>
ffffffffc02017e8:	00003617          	auipc	a2,0x3
ffffffffc02017ec:	5b060613          	addi	a2,a2,1456 # ffffffffc0204d98 <commands+0x728>
ffffffffc02017f0:	0f100593          	li	a1,241
ffffffffc02017f4:	00004517          	auipc	a0,0x4
ffffffffc02017f8:	93450513          	addi	a0,a0,-1740 # ffffffffc0205128 <commands+0xab8>
ffffffffc02017fc:	907fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0201800:	00004697          	auipc	a3,0x4
ffffffffc0201804:	ba068693          	addi	a3,a3,-1120 # ffffffffc02053a0 <commands+0xd30>
ffffffffc0201808:	00003617          	auipc	a2,0x3
ffffffffc020180c:	59060613          	addi	a2,a2,1424 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201810:	10000593          	li	a1,256
ffffffffc0201814:	00004517          	auipc	a0,0x4
ffffffffc0201818:	91450513          	addi	a0,a0,-1772 # ffffffffc0205128 <commands+0xab8>
ffffffffc020181c:	8e7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201820:	00003697          	auipc	a3,0x3
ffffffffc0201824:	78868693          	addi	a3,a3,1928 # ffffffffc0204fa8 <commands+0x938>
ffffffffc0201828:	00003617          	auipc	a2,0x3
ffffffffc020182c:	57060613          	addi	a2,a2,1392 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201830:	0ca00593          	li	a1,202
ffffffffc0201834:	00004517          	auipc	a0,0x4
ffffffffc0201838:	8f450513          	addi	a0,a0,-1804 # ffffffffc0205128 <commands+0xab8>
ffffffffc020183c:	8c7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201840:	00004697          	auipc	a3,0x4
ffffffffc0201844:	81068693          	addi	a3,a3,-2032 # ffffffffc0205050 <commands+0x9e0>
ffffffffc0201848:	00003617          	auipc	a2,0x3
ffffffffc020184c:	55060613          	addi	a2,a2,1360 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201850:	0cd00593          	li	a1,205
ffffffffc0201854:	00004517          	auipc	a0,0x4
ffffffffc0201858:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205128 <commands+0xab8>
ffffffffc020185c:	8a7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201860:	00004697          	auipc	a3,0x4
ffffffffc0201864:	99868693          	addi	a3,a3,-1640 # ffffffffc02051f8 <commands+0xb88>
ffffffffc0201868:	00003617          	auipc	a2,0x3
ffffffffc020186c:	53060613          	addi	a2,a2,1328 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201870:	0d500593          	li	a1,213
ffffffffc0201874:	00004517          	auipc	a0,0x4
ffffffffc0201878:	8b450513          	addi	a0,a0,-1868 # ffffffffc0205128 <commands+0xab8>
ffffffffc020187c:	887fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201880:	00004697          	auipc	a3,0x4
ffffffffc0201884:	8e068693          	addi	a3,a3,-1824 # ffffffffc0205160 <commands+0xaf0>
ffffffffc0201888:	00003617          	auipc	a2,0x3
ffffffffc020188c:	51060613          	addi	a2,a2,1296 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201890:	0bd00593          	li	a1,189
ffffffffc0201894:	00004517          	auipc	a0,0x4
ffffffffc0201898:	89450513          	addi	a0,a0,-1900 # ffffffffc0205128 <commands+0xab8>
ffffffffc020189c:	867fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018a0:	00004697          	auipc	a3,0x4
ffffffffc02018a4:	a3068693          	addi	a3,a3,-1488 # ffffffffc02052d0 <commands+0xc60>
ffffffffc02018a8:	00003617          	auipc	a2,0x3
ffffffffc02018ac:	4f060613          	addi	a2,a2,1264 # ffffffffc0204d98 <commands+0x728>
ffffffffc02018b0:	09500593          	li	a1,149
ffffffffc02018b4:	00004517          	auipc	a0,0x4
ffffffffc02018b8:	87450513          	addi	a0,a0,-1932 # ffffffffc0205128 <commands+0xab8>
ffffffffc02018bc:	847fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018c0:	00004697          	auipc	a3,0x4
ffffffffc02018c4:	a1068693          	addi	a3,a3,-1520 # ffffffffc02052d0 <commands+0xc60>
ffffffffc02018c8:	00003617          	auipc	a2,0x3
ffffffffc02018cc:	4d060613          	addi	a2,a2,1232 # ffffffffc0204d98 <commands+0x728>
ffffffffc02018d0:	09700593          	li	a1,151
ffffffffc02018d4:	00004517          	auipc	a0,0x4
ffffffffc02018d8:	85450513          	addi	a0,a0,-1964 # ffffffffc0205128 <commands+0xab8>
ffffffffc02018dc:	827fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018e0:	00004697          	auipc	a3,0x4
ffffffffc02018e4:	a0068693          	addi	a3,a3,-1536 # ffffffffc02052e0 <commands+0xc70>
ffffffffc02018e8:	00003617          	auipc	a2,0x3
ffffffffc02018ec:	4b060613          	addi	a2,a2,1200 # ffffffffc0204d98 <commands+0x728>
ffffffffc02018f0:	09900593          	li	a1,153
ffffffffc02018f4:	00004517          	auipc	a0,0x4
ffffffffc02018f8:	83450513          	addi	a0,a0,-1996 # ffffffffc0205128 <commands+0xab8>
ffffffffc02018fc:	807fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201900:	00004697          	auipc	a3,0x4
ffffffffc0201904:	9e068693          	addi	a3,a3,-1568 # ffffffffc02052e0 <commands+0xc70>
ffffffffc0201908:	00003617          	auipc	a2,0x3
ffffffffc020190c:	49060613          	addi	a2,a2,1168 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201910:	09b00593          	li	a1,155
ffffffffc0201914:	00004517          	auipc	a0,0x4
ffffffffc0201918:	81450513          	addi	a0,a0,-2028 # ffffffffc0205128 <commands+0xab8>
ffffffffc020191c:	fe6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201920:	00004697          	auipc	a3,0x4
ffffffffc0201924:	9a068693          	addi	a3,a3,-1632 # ffffffffc02052c0 <commands+0xc50>
ffffffffc0201928:	00003617          	auipc	a2,0x3
ffffffffc020192c:	47060613          	addi	a2,a2,1136 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201930:	09100593          	li	a1,145
ffffffffc0201934:	00003517          	auipc	a0,0x3
ffffffffc0201938:	7f450513          	addi	a0,a0,2036 # ffffffffc0205128 <commands+0xab8>
ffffffffc020193c:	fc6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201940:	00004697          	auipc	a3,0x4
ffffffffc0201944:	98068693          	addi	a3,a3,-1664 # ffffffffc02052c0 <commands+0xc50>
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	45060613          	addi	a2,a2,1104 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201950:	09300593          	li	a1,147
ffffffffc0201954:	00003517          	auipc	a0,0x3
ffffffffc0201958:	7d450513          	addi	a0,a0,2004 # ffffffffc0205128 <commands+0xab8>
ffffffffc020195c:	fa6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201960:	00003697          	auipc	a3,0x3
ffffffffc0201964:	71868693          	addi	a3,a3,1816 # ffffffffc0205078 <commands+0xa08>
ffffffffc0201968:	00003617          	auipc	a2,0x3
ffffffffc020196c:	43060613          	addi	a2,a2,1072 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201970:	0c200593          	li	a1,194
ffffffffc0201974:	00003517          	auipc	a0,0x3
ffffffffc0201978:	7b450513          	addi	a0,a0,1972 # ffffffffc0205128 <commands+0xab8>
ffffffffc020197c:	f86fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201980:	00004697          	auipc	a3,0x4
ffffffffc0201984:	82868693          	addi	a3,a3,-2008 # ffffffffc02051a8 <commands+0xb38>
ffffffffc0201988:	00003617          	auipc	a2,0x3
ffffffffc020198c:	41060613          	addi	a2,a2,1040 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201990:	0c500593          	li	a1,197
ffffffffc0201994:	00003517          	auipc	a0,0x3
ffffffffc0201998:	79450513          	addi	a0,a0,1940 # ffffffffc0205128 <commands+0xab8>
ffffffffc020199c:	f66fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02019a0:	00004697          	auipc	a3,0x4
ffffffffc02019a4:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205270 <commands+0xc00>
ffffffffc02019a8:	00003617          	auipc	a2,0x3
ffffffffc02019ac:	3f060613          	addi	a2,a2,1008 # ffffffffc0204d98 <commands+0x728>
ffffffffc02019b0:	0e800593          	li	a1,232
ffffffffc02019b4:	00003517          	auipc	a0,0x3
ffffffffc02019b8:	77450513          	addi	a0,a0,1908 # ffffffffc0205128 <commands+0xab8>
ffffffffc02019bc:	f46fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02019c0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02019c0:	00010797          	auipc	a5,0x10
ffffffffc02019c4:	b707b783          	ld	a5,-1168(a5) # ffffffffc0211530 <sm>
ffffffffc02019c8:	6b9c                	ld	a5,16(a5)
ffffffffc02019ca:	8782                	jr	a5

ffffffffc02019cc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02019cc:	00010797          	auipc	a5,0x10
ffffffffc02019d0:	b647b783          	ld	a5,-1180(a5) # ffffffffc0211530 <sm>
ffffffffc02019d4:	739c                	ld	a5,32(a5)
ffffffffc02019d6:	8782                	jr	a5

ffffffffc02019d8 <swap_out>:
{
ffffffffc02019d8:	711d                	addi	sp,sp,-96
ffffffffc02019da:	ec86                	sd	ra,88(sp)
ffffffffc02019dc:	e8a2                	sd	s0,80(sp)
ffffffffc02019de:	e4a6                	sd	s1,72(sp)
ffffffffc02019e0:	e0ca                	sd	s2,64(sp)
ffffffffc02019e2:	fc4e                	sd	s3,56(sp)
ffffffffc02019e4:	f852                	sd	s4,48(sp)
ffffffffc02019e6:	f456                	sd	s5,40(sp)
ffffffffc02019e8:	f05a                	sd	s6,32(sp)
ffffffffc02019ea:	ec5e                	sd	s7,24(sp)
ffffffffc02019ec:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02019ee:	cde9                	beqz	a1,ffffffffc0201ac8 <swap_out+0xf0>
ffffffffc02019f0:	8a2e                	mv	s4,a1
ffffffffc02019f2:	892a                	mv	s2,a0
ffffffffc02019f4:	8ab2                	mv	s5,a2
ffffffffc02019f6:	4401                	li	s0,0
ffffffffc02019f8:	00010997          	auipc	s3,0x10
ffffffffc02019fc:	b3898993          	addi	s3,s3,-1224 # ffffffffc0211530 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201a00:	00004b17          	auipc	s6,0x4
ffffffffc0201a04:	a48b0b13          	addi	s6,s6,-1464 # ffffffffc0205448 <commands+0xdd8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a08:	00004b97          	auipc	s7,0x4
ffffffffc0201a0c:	a28b8b93          	addi	s7,s7,-1496 # ffffffffc0205430 <commands+0xdc0>
ffffffffc0201a10:	a825                	j	ffffffffc0201a48 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201a12:	67a2                	ld	a5,8(sp)
ffffffffc0201a14:	8626                	mv	a2,s1
ffffffffc0201a16:	85a2                	mv	a1,s0
ffffffffc0201a18:	63b4                	ld	a3,64(a5)
ffffffffc0201a1a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201a1c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201a1e:	82b1                	srli	a3,a3,0xc
ffffffffc0201a20:	0685                	addi	a3,a3,1
ffffffffc0201a22:	e98fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a26:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201a28:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a2a:	613c                	ld	a5,64(a0)
ffffffffc0201a2c:	83b1                	srli	a5,a5,0xc
ffffffffc0201a2e:	0785                	addi	a5,a5,1
ffffffffc0201a30:	07a2                	slli	a5,a5,0x8
ffffffffc0201a32:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201a36:	046010ef          	jal	ra,ffffffffc0202a7c <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201a3a:	01893503          	ld	a0,24(s2)
ffffffffc0201a3e:	85a6                	mv	a1,s1
ffffffffc0201a40:	0a4020ef          	jal	ra,ffffffffc0203ae4 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201a44:	048a0d63          	beq	s4,s0,ffffffffc0201a9e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201a48:	0009b783          	ld	a5,0(s3)
ffffffffc0201a4c:	8656                	mv	a2,s5
ffffffffc0201a4e:	002c                	addi	a1,sp,8
ffffffffc0201a50:	7b9c                	ld	a5,48(a5)
ffffffffc0201a52:	854a                	mv	a0,s2
ffffffffc0201a54:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201a56:	e12d                	bnez	a0,ffffffffc0201ab8 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201a58:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a5a:	01893503          	ld	a0,24(s2)
ffffffffc0201a5e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201a60:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a62:	85a6                	mv	a1,s1
ffffffffc0201a64:	092010ef          	jal	ra,ffffffffc0202af6 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a68:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a6a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a6c:	8b85                	andi	a5,a5,1
ffffffffc0201a6e:	cfb9                	beqz	a5,ffffffffc0201acc <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201a70:	65a2                	ld	a1,8(sp)
ffffffffc0201a72:	61bc                	ld	a5,64(a1)
ffffffffc0201a74:	83b1                	srli	a5,a5,0xc
ffffffffc0201a76:	0785                	addi	a5,a5,1
ffffffffc0201a78:	00879513          	slli	a0,a5,0x8
ffffffffc0201a7c:	39a020ef          	jal	ra,ffffffffc0203e16 <swapfs_write>
ffffffffc0201a80:	d949                	beqz	a0,ffffffffc0201a12 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a82:	855e                	mv	a0,s7
ffffffffc0201a84:	e36fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a88:	0009b783          	ld	a5,0(s3)
ffffffffc0201a8c:	6622                	ld	a2,8(sp)
ffffffffc0201a8e:	4681                	li	a3,0
ffffffffc0201a90:	739c                	ld	a5,32(a5)
ffffffffc0201a92:	85a6                	mv	a1,s1
ffffffffc0201a94:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201a96:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a98:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201a9a:	fa8a17e3          	bne	s4,s0,ffffffffc0201a48 <swap_out+0x70>
}
ffffffffc0201a9e:	60e6                	ld	ra,88(sp)
ffffffffc0201aa0:	8522                	mv	a0,s0
ffffffffc0201aa2:	6446                	ld	s0,80(sp)
ffffffffc0201aa4:	64a6                	ld	s1,72(sp)
ffffffffc0201aa6:	6906                	ld	s2,64(sp)
ffffffffc0201aa8:	79e2                	ld	s3,56(sp)
ffffffffc0201aaa:	7a42                	ld	s4,48(sp)
ffffffffc0201aac:	7aa2                	ld	s5,40(sp)
ffffffffc0201aae:	7b02                	ld	s6,32(sp)
ffffffffc0201ab0:	6be2                	ld	s7,24(sp)
ffffffffc0201ab2:	6c42                	ld	s8,16(sp)
ffffffffc0201ab4:	6125                	addi	sp,sp,96
ffffffffc0201ab6:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201ab8:	85a2                	mv	a1,s0
ffffffffc0201aba:	00004517          	auipc	a0,0x4
ffffffffc0201abe:	92e50513          	addi	a0,a0,-1746 # ffffffffc02053e8 <commands+0xd78>
ffffffffc0201ac2:	df8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201ac6:	bfe1                	j	ffffffffc0201a9e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201ac8:	4401                	li	s0,0
ffffffffc0201aca:	bfd1                	j	ffffffffc0201a9e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201acc:	00004697          	auipc	a3,0x4
ffffffffc0201ad0:	94c68693          	addi	a3,a3,-1716 # ffffffffc0205418 <commands+0xda8>
ffffffffc0201ad4:	00003617          	auipc	a2,0x3
ffffffffc0201ad8:	2c460613          	addi	a2,a2,708 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201adc:	06600593          	li	a1,102
ffffffffc0201ae0:	00003517          	auipc	a0,0x3
ffffffffc0201ae4:	64850513          	addi	a0,a0,1608 # ffffffffc0205128 <commands+0xab8>
ffffffffc0201ae8:	e1afe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201aec <swap_in>:
{
ffffffffc0201aec:	7179                	addi	sp,sp,-48
ffffffffc0201aee:	e84a                	sd	s2,16(sp)
ffffffffc0201af0:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201af2:	4505                	li	a0,1
{
ffffffffc0201af4:	ec26                	sd	s1,24(sp)
ffffffffc0201af6:	e44e                	sd	s3,8(sp)
ffffffffc0201af8:	f406                	sd	ra,40(sp)
ffffffffc0201afa:	f022                	sd	s0,32(sp)
ffffffffc0201afc:	84ae                	mv	s1,a1
ffffffffc0201afe:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201b00:	6eb000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
     assert(result!=NULL);
ffffffffc0201b04:	c129                	beqz	a0,ffffffffc0201b46 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201b06:	842a                	mv	s0,a0
ffffffffc0201b08:	01893503          	ld	a0,24(s2)
ffffffffc0201b0c:	4601                	li	a2,0
ffffffffc0201b0e:	85a6                	mv	a1,s1
ffffffffc0201b10:	7e7000ef          	jal	ra,ffffffffc0202af6 <get_pte>
ffffffffc0201b14:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201b16:	6108                	ld	a0,0(a0)
ffffffffc0201b18:	85a2                	mv	a1,s0
ffffffffc0201b1a:	262020ef          	jal	ra,ffffffffc0203d7c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201b1e:	00093583          	ld	a1,0(s2)
ffffffffc0201b22:	8626                	mv	a2,s1
ffffffffc0201b24:	00004517          	auipc	a0,0x4
ffffffffc0201b28:	97450513          	addi	a0,a0,-1676 # ffffffffc0205498 <commands+0xe28>
ffffffffc0201b2c:	81a1                	srli	a1,a1,0x8
ffffffffc0201b2e:	d8cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201b32:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201b34:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201b38:	7402                	ld	s0,32(sp)
ffffffffc0201b3a:	64e2                	ld	s1,24(sp)
ffffffffc0201b3c:	6942                	ld	s2,16(sp)
ffffffffc0201b3e:	69a2                	ld	s3,8(sp)
ffffffffc0201b40:	4501                	li	a0,0
ffffffffc0201b42:	6145                	addi	sp,sp,48
ffffffffc0201b44:	8082                	ret
     assert(result!=NULL);
ffffffffc0201b46:	00004697          	auipc	a3,0x4
ffffffffc0201b4a:	94268693          	addi	a3,a3,-1726 # ffffffffc0205488 <commands+0xe18>
ffffffffc0201b4e:	00003617          	auipc	a2,0x3
ffffffffc0201b52:	24a60613          	addi	a2,a2,586 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201b56:	07c00593          	li	a1,124
ffffffffc0201b5a:	00003517          	auipc	a0,0x3
ffffffffc0201b5e:	5ce50513          	addi	a0,a0,1486 # ffffffffc0205128 <commands+0xab8>
ffffffffc0201b62:	da0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201b66 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201b66:	0000f797          	auipc	a5,0xf
ffffffffc0201b6a:	56a78793          	addi	a5,a5,1386 # ffffffffc02110d0 <free_area>
ffffffffc0201b6e:	e79c                	sd	a5,8(a5)
ffffffffc0201b70:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201b72:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201b76:	8082                	ret

ffffffffc0201b78 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201b78:	0000f517          	auipc	a0,0xf
ffffffffc0201b7c:	56856503          	lwu	a0,1384(a0) # ffffffffc02110e0 <free_area+0x10>
ffffffffc0201b80:	8082                	ret

ffffffffc0201b82 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201b82:	715d                	addi	sp,sp,-80
ffffffffc0201b84:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201b86:	0000f417          	auipc	s0,0xf
ffffffffc0201b8a:	54a40413          	addi	s0,s0,1354 # ffffffffc02110d0 <free_area>
ffffffffc0201b8e:	641c                	ld	a5,8(s0)
ffffffffc0201b90:	e486                	sd	ra,72(sp)
ffffffffc0201b92:	fc26                	sd	s1,56(sp)
ffffffffc0201b94:	f84a                	sd	s2,48(sp)
ffffffffc0201b96:	f44e                	sd	s3,40(sp)
ffffffffc0201b98:	f052                	sd	s4,32(sp)
ffffffffc0201b9a:	ec56                	sd	s5,24(sp)
ffffffffc0201b9c:	e85a                	sd	s6,16(sp)
ffffffffc0201b9e:	e45e                	sd	s7,8(sp)
ffffffffc0201ba0:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201ba2:	2c878763          	beq	a5,s0,ffffffffc0201e70 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201ba6:	4481                	li	s1,0
ffffffffc0201ba8:	4901                	li	s2,0
ffffffffc0201baa:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201bae:	8b09                	andi	a4,a4,2
ffffffffc0201bb0:	2c070463          	beqz	a4,ffffffffc0201e78 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201bb4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201bb8:	679c                	ld	a5,8(a5)
ffffffffc0201bba:	2905                	addiw	s2,s2,1
ffffffffc0201bbc:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201bbe:	fe8796e3          	bne	a5,s0,ffffffffc0201baa <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201bc2:	89a6                	mv	s3,s1
ffffffffc0201bc4:	6f9000ef          	jal	ra,ffffffffc0202abc <nr_free_pages>
ffffffffc0201bc8:	71351863          	bne	a0,s3,ffffffffc02022d8 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201bcc:	4505                	li	a0,1
ffffffffc0201bce:	61d000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201bd2:	8a2a                	mv	s4,a0
ffffffffc0201bd4:	44050263          	beqz	a0,ffffffffc0202018 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201bd8:	4505                	li	a0,1
ffffffffc0201bda:	611000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201bde:	89aa                	mv	s3,a0
ffffffffc0201be0:	70050c63          	beqz	a0,ffffffffc02022f8 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201be4:	4505                	li	a0,1
ffffffffc0201be6:	605000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201bea:	8aaa                	mv	s5,a0
ffffffffc0201bec:	4a050663          	beqz	a0,ffffffffc0202098 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201bf0:	2b3a0463          	beq	s4,s3,ffffffffc0201e98 <default_check+0x316>
ffffffffc0201bf4:	2aaa0263          	beq	s4,a0,ffffffffc0201e98 <default_check+0x316>
ffffffffc0201bf8:	2aa98063          	beq	s3,a0,ffffffffc0201e98 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201bfc:	000a2783          	lw	a5,0(s4)
ffffffffc0201c00:	2a079c63          	bnez	a5,ffffffffc0201eb8 <default_check+0x336>
ffffffffc0201c04:	0009a783          	lw	a5,0(s3)
ffffffffc0201c08:	2a079863          	bnez	a5,ffffffffc0201eb8 <default_check+0x336>
ffffffffc0201c0c:	411c                	lw	a5,0(a0)
ffffffffc0201c0e:	2a079563          	bnez	a5,ffffffffc0201eb8 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c12:	00010797          	auipc	a5,0x10
ffffffffc0201c16:	94e7b783          	ld	a5,-1714(a5) # ffffffffc0211560 <pages>
ffffffffc0201c1a:	40fa0733          	sub	a4,s4,a5
ffffffffc0201c1e:	870d                	srai	a4,a4,0x3
ffffffffc0201c20:	00004597          	auipc	a1,0x4
ffffffffc0201c24:	5c85b583          	ld	a1,1480(a1) # ffffffffc02061e8 <error_string+0x38>
ffffffffc0201c28:	02b70733          	mul	a4,a4,a1
ffffffffc0201c2c:	00004617          	auipc	a2,0x4
ffffffffc0201c30:	5c463603          	ld	a2,1476(a2) # ffffffffc02061f0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201c34:	00010697          	auipc	a3,0x10
ffffffffc0201c38:	9246b683          	ld	a3,-1756(a3) # ffffffffc0211558 <npage>
ffffffffc0201c3c:	06b2                	slli	a3,a3,0xc
ffffffffc0201c3e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c40:	0732                	slli	a4,a4,0xc
ffffffffc0201c42:	28d77b63          	bgeu	a4,a3,ffffffffc0201ed8 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c46:	40f98733          	sub	a4,s3,a5
ffffffffc0201c4a:	870d                	srai	a4,a4,0x3
ffffffffc0201c4c:	02b70733          	mul	a4,a4,a1
ffffffffc0201c50:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c52:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201c54:	4cd77263          	bgeu	a4,a3,ffffffffc0202118 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c58:	40f507b3          	sub	a5,a0,a5
ffffffffc0201c5c:	878d                	srai	a5,a5,0x3
ffffffffc0201c5e:	02b787b3          	mul	a5,a5,a1
ffffffffc0201c62:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c64:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201c66:	30d7f963          	bgeu	a5,a3,ffffffffc0201f78 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0201c6a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201c6c:	00043c03          	ld	s8,0(s0)
ffffffffc0201c70:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201c74:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201c78:	e400                	sd	s0,8(s0)
ffffffffc0201c7a:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201c7c:	0000f797          	auipc	a5,0xf
ffffffffc0201c80:	4607a223          	sw	zero,1124(a5) # ffffffffc02110e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201c84:	567000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201c88:	2c051863          	bnez	a0,ffffffffc0201f58 <default_check+0x3d6>
    free_page(p0);
ffffffffc0201c8c:	4585                	li	a1,1
ffffffffc0201c8e:	8552                	mv	a0,s4
ffffffffc0201c90:	5ed000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    free_page(p1);
ffffffffc0201c94:	4585                	li	a1,1
ffffffffc0201c96:	854e                	mv	a0,s3
ffffffffc0201c98:	5e5000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    free_page(p2);
ffffffffc0201c9c:	4585                	li	a1,1
ffffffffc0201c9e:	8556                	mv	a0,s5
ffffffffc0201ca0:	5dd000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    assert(nr_free == 3);
ffffffffc0201ca4:	4818                	lw	a4,16(s0)
ffffffffc0201ca6:	478d                	li	a5,3
ffffffffc0201ca8:	28f71863          	bne	a4,a5,ffffffffc0201f38 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201cac:	4505                	li	a0,1
ffffffffc0201cae:	53d000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201cb2:	89aa                	mv	s3,a0
ffffffffc0201cb4:	26050263          	beqz	a0,ffffffffc0201f18 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201cb8:	4505                	li	a0,1
ffffffffc0201cba:	531000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201cbe:	8aaa                	mv	s5,a0
ffffffffc0201cc0:	3a050c63          	beqz	a0,ffffffffc0202078 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201cc4:	4505                	li	a0,1
ffffffffc0201cc6:	525000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201cca:	8a2a                	mv	s4,a0
ffffffffc0201ccc:	38050663          	beqz	a0,ffffffffc0202058 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0201cd0:	4505                	li	a0,1
ffffffffc0201cd2:	519000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201cd6:	36051163          	bnez	a0,ffffffffc0202038 <default_check+0x4b6>
    free_page(p0);
ffffffffc0201cda:	4585                	li	a1,1
ffffffffc0201cdc:	854e                	mv	a0,s3
ffffffffc0201cde:	59f000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201ce2:	641c                	ld	a5,8(s0)
ffffffffc0201ce4:	20878a63          	beq	a5,s0,ffffffffc0201ef8 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0201ce8:	4505                	li	a0,1
ffffffffc0201cea:	501000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201cee:	30a99563          	bne	s3,a0,ffffffffc0201ff8 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0201cf2:	4505                	li	a0,1
ffffffffc0201cf4:	4f7000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201cf8:	2e051063          	bnez	a0,ffffffffc0201fd8 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0201cfc:	481c                	lw	a5,16(s0)
ffffffffc0201cfe:	2a079d63          	bnez	a5,ffffffffc0201fb8 <default_check+0x436>
    free_page(p);
ffffffffc0201d02:	854e                	mv	a0,s3
ffffffffc0201d04:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201d06:	01843023          	sd	s8,0(s0)
ffffffffc0201d0a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201d0e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201d12:	56b000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    free_page(p1);
ffffffffc0201d16:	4585                	li	a1,1
ffffffffc0201d18:	8556                	mv	a0,s5
ffffffffc0201d1a:	563000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    free_page(p2);
ffffffffc0201d1e:	4585                	li	a1,1
ffffffffc0201d20:	8552                	mv	a0,s4
ffffffffc0201d22:	55b000ef          	jal	ra,ffffffffc0202a7c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201d26:	4515                	li	a0,5
ffffffffc0201d28:	4c3000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201d2c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201d2e:	26050563          	beqz	a0,ffffffffc0201f98 <default_check+0x416>
ffffffffc0201d32:	651c                	ld	a5,8(a0)
ffffffffc0201d34:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201d36:	8b85                	andi	a5,a5,1
ffffffffc0201d38:	54079063          	bnez	a5,ffffffffc0202278 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201d3c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201d3e:	00043b03          	ld	s6,0(s0)
ffffffffc0201d42:	00843a83          	ld	s5,8(s0)
ffffffffc0201d46:	e000                	sd	s0,0(s0)
ffffffffc0201d48:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201d4a:	4a1000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201d4e:	50051563          	bnez	a0,ffffffffc0202258 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201d52:	09098a13          	addi	s4,s3,144
ffffffffc0201d56:	8552                	mv	a0,s4
ffffffffc0201d58:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201d5a:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201d5e:	0000f797          	auipc	a5,0xf
ffffffffc0201d62:	3807a123          	sw	zero,898(a5) # ffffffffc02110e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201d66:	517000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d6a:	4511                	li	a0,4
ffffffffc0201d6c:	47f000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201d70:	4c051463          	bnez	a0,ffffffffc0202238 <default_check+0x6b6>
ffffffffc0201d74:	0989b783          	ld	a5,152(s3)
ffffffffc0201d78:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201d7a:	8b85                	andi	a5,a5,1
ffffffffc0201d7c:	48078e63          	beqz	a5,ffffffffc0202218 <default_check+0x696>
ffffffffc0201d80:	0a89a703          	lw	a4,168(s3)
ffffffffc0201d84:	478d                	li	a5,3
ffffffffc0201d86:	48f71963          	bne	a4,a5,ffffffffc0202218 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201d8a:	450d                	li	a0,3
ffffffffc0201d8c:	45f000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201d90:	8c2a                	mv	s8,a0
ffffffffc0201d92:	46050363          	beqz	a0,ffffffffc02021f8 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0201d96:	4505                	li	a0,1
ffffffffc0201d98:	453000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201d9c:	42051e63          	bnez	a0,ffffffffc02021d8 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0201da0:	418a1c63          	bne	s4,s8,ffffffffc02021b8 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201da4:	4585                	li	a1,1
ffffffffc0201da6:	854e                	mv	a0,s3
ffffffffc0201da8:	4d5000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    free_pages(p1, 3);
ffffffffc0201dac:	458d                	li	a1,3
ffffffffc0201dae:	8552                	mv	a0,s4
ffffffffc0201db0:	4cd000ef          	jal	ra,ffffffffc0202a7c <free_pages>
ffffffffc0201db4:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201db8:	04898c13          	addi	s8,s3,72
ffffffffc0201dbc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201dbe:	8b85                	andi	a5,a5,1
ffffffffc0201dc0:	3c078c63          	beqz	a5,ffffffffc0202198 <default_check+0x616>
ffffffffc0201dc4:	0189a703          	lw	a4,24(s3)
ffffffffc0201dc8:	4785                	li	a5,1
ffffffffc0201dca:	3cf71763          	bne	a4,a5,ffffffffc0202198 <default_check+0x616>
ffffffffc0201dce:	008a3783          	ld	a5,8(s4)
ffffffffc0201dd2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201dd4:	8b85                	andi	a5,a5,1
ffffffffc0201dd6:	3a078163          	beqz	a5,ffffffffc0202178 <default_check+0x5f6>
ffffffffc0201dda:	018a2703          	lw	a4,24(s4)
ffffffffc0201dde:	478d                	li	a5,3
ffffffffc0201de0:	38f71c63          	bne	a4,a5,ffffffffc0202178 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201de4:	4505                	li	a0,1
ffffffffc0201de6:	405000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201dea:	36a99763          	bne	s3,a0,ffffffffc0202158 <default_check+0x5d6>
    free_page(p0);
ffffffffc0201dee:	4585                	li	a1,1
ffffffffc0201df0:	48d000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201df4:	4509                	li	a0,2
ffffffffc0201df6:	3f5000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201dfa:	32aa1f63          	bne	s4,a0,ffffffffc0202138 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0201dfe:	4589                	li	a1,2
ffffffffc0201e00:	47d000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    free_page(p2);
ffffffffc0201e04:	4585                	li	a1,1
ffffffffc0201e06:	8562                	mv	a0,s8
ffffffffc0201e08:	475000ef          	jal	ra,ffffffffc0202a7c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201e0c:	4515                	li	a0,5
ffffffffc0201e0e:	3dd000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201e12:	89aa                	mv	s3,a0
ffffffffc0201e14:	48050263          	beqz	a0,ffffffffc0202298 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0201e18:	4505                	li	a0,1
ffffffffc0201e1a:	3d1000ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0201e1e:	2c051d63          	bnez	a0,ffffffffc02020f8 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0201e22:	481c                	lw	a5,16(s0)
ffffffffc0201e24:	2a079a63          	bnez	a5,ffffffffc02020d8 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201e28:	4595                	li	a1,5
ffffffffc0201e2a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201e2c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201e30:	01643023          	sd	s6,0(s0)
ffffffffc0201e34:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201e38:	445000ef          	jal	ra,ffffffffc0202a7c <free_pages>
    return listelm->next;
ffffffffc0201e3c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e3e:	00878963          	beq	a5,s0,ffffffffc0201e50 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201e42:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201e46:	679c                	ld	a5,8(a5)
ffffffffc0201e48:	397d                	addiw	s2,s2,-1
ffffffffc0201e4a:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e4c:	fe879be3          	bne	a5,s0,ffffffffc0201e42 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0201e50:	26091463          	bnez	s2,ffffffffc02020b8 <default_check+0x536>
    assert(total == 0);
ffffffffc0201e54:	46049263          	bnez	s1,ffffffffc02022b8 <default_check+0x736>
}
ffffffffc0201e58:	60a6                	ld	ra,72(sp)
ffffffffc0201e5a:	6406                	ld	s0,64(sp)
ffffffffc0201e5c:	74e2                	ld	s1,56(sp)
ffffffffc0201e5e:	7942                	ld	s2,48(sp)
ffffffffc0201e60:	79a2                	ld	s3,40(sp)
ffffffffc0201e62:	7a02                	ld	s4,32(sp)
ffffffffc0201e64:	6ae2                	ld	s5,24(sp)
ffffffffc0201e66:	6b42                	ld	s6,16(sp)
ffffffffc0201e68:	6ba2                	ld	s7,8(sp)
ffffffffc0201e6a:	6c02                	ld	s8,0(sp)
ffffffffc0201e6c:	6161                	addi	sp,sp,80
ffffffffc0201e6e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e70:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201e72:	4481                	li	s1,0
ffffffffc0201e74:	4901                	li	s2,0
ffffffffc0201e76:	b3b9                	j	ffffffffc0201bc4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201e78:	00003697          	auipc	a3,0x3
ffffffffc0201e7c:	2d868693          	addi	a3,a3,728 # ffffffffc0205150 <commands+0xae0>
ffffffffc0201e80:	00003617          	auipc	a2,0x3
ffffffffc0201e84:	f1860613          	addi	a2,a2,-232 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201e88:	0f000593          	li	a1,240
ffffffffc0201e8c:	00003517          	auipc	a0,0x3
ffffffffc0201e90:	64c50513          	addi	a0,a0,1612 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201e94:	a6efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201e98:	00003697          	auipc	a3,0x3
ffffffffc0201e9c:	6b868693          	addi	a3,a3,1720 # ffffffffc0205550 <commands+0xee0>
ffffffffc0201ea0:	00003617          	auipc	a2,0x3
ffffffffc0201ea4:	ef860613          	addi	a2,a2,-264 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201ea8:	0bd00593          	li	a1,189
ffffffffc0201eac:	00003517          	auipc	a0,0x3
ffffffffc0201eb0:	62c50513          	addi	a0,a0,1580 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201eb4:	a4efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201eb8:	00003697          	auipc	a3,0x3
ffffffffc0201ebc:	6c068693          	addi	a3,a3,1728 # ffffffffc0205578 <commands+0xf08>
ffffffffc0201ec0:	00003617          	auipc	a2,0x3
ffffffffc0201ec4:	ed860613          	addi	a2,a2,-296 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201ec8:	0be00593          	li	a1,190
ffffffffc0201ecc:	00003517          	auipc	a0,0x3
ffffffffc0201ed0:	60c50513          	addi	a0,a0,1548 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201ed4:	a2efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201ed8:	00003697          	auipc	a3,0x3
ffffffffc0201edc:	6e068693          	addi	a3,a3,1760 # ffffffffc02055b8 <commands+0xf48>
ffffffffc0201ee0:	00003617          	auipc	a2,0x3
ffffffffc0201ee4:	eb860613          	addi	a2,a2,-328 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201ee8:	0c000593          	li	a1,192
ffffffffc0201eec:	00003517          	auipc	a0,0x3
ffffffffc0201ef0:	5ec50513          	addi	a0,a0,1516 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201ef4:	a0efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201ef8:	00003697          	auipc	a3,0x3
ffffffffc0201efc:	74868693          	addi	a3,a3,1864 # ffffffffc0205640 <commands+0xfd0>
ffffffffc0201f00:	00003617          	auipc	a2,0x3
ffffffffc0201f04:	e9860613          	addi	a2,a2,-360 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201f08:	0d900593          	li	a1,217
ffffffffc0201f0c:	00003517          	auipc	a0,0x3
ffffffffc0201f10:	5cc50513          	addi	a0,a0,1484 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201f14:	9eefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201f18:	00003697          	auipc	a3,0x3
ffffffffc0201f1c:	5d868693          	addi	a3,a3,1496 # ffffffffc02054f0 <commands+0xe80>
ffffffffc0201f20:	00003617          	auipc	a2,0x3
ffffffffc0201f24:	e7860613          	addi	a2,a2,-392 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201f28:	0d200593          	li	a1,210
ffffffffc0201f2c:	00003517          	auipc	a0,0x3
ffffffffc0201f30:	5ac50513          	addi	a0,a0,1452 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201f34:	9cefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0201f38:	00003697          	auipc	a3,0x3
ffffffffc0201f3c:	6f868693          	addi	a3,a3,1784 # ffffffffc0205630 <commands+0xfc0>
ffffffffc0201f40:	00003617          	auipc	a2,0x3
ffffffffc0201f44:	e5860613          	addi	a2,a2,-424 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201f48:	0d000593          	li	a1,208
ffffffffc0201f4c:	00003517          	auipc	a0,0x3
ffffffffc0201f50:	58c50513          	addi	a0,a0,1420 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201f54:	9aefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201f58:	00003697          	auipc	a3,0x3
ffffffffc0201f5c:	6c068693          	addi	a3,a3,1728 # ffffffffc0205618 <commands+0xfa8>
ffffffffc0201f60:	00003617          	auipc	a2,0x3
ffffffffc0201f64:	e3860613          	addi	a2,a2,-456 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201f68:	0cb00593          	li	a1,203
ffffffffc0201f6c:	00003517          	auipc	a0,0x3
ffffffffc0201f70:	56c50513          	addi	a0,a0,1388 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201f74:	98efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201f78:	00003697          	auipc	a3,0x3
ffffffffc0201f7c:	68068693          	addi	a3,a3,1664 # ffffffffc02055f8 <commands+0xf88>
ffffffffc0201f80:	00003617          	auipc	a2,0x3
ffffffffc0201f84:	e1860613          	addi	a2,a2,-488 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201f88:	0c200593          	li	a1,194
ffffffffc0201f8c:	00003517          	auipc	a0,0x3
ffffffffc0201f90:	54c50513          	addi	a0,a0,1356 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201f94:	96efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0201f98:	00003697          	auipc	a3,0x3
ffffffffc0201f9c:	6e068693          	addi	a3,a3,1760 # ffffffffc0205678 <commands+0x1008>
ffffffffc0201fa0:	00003617          	auipc	a2,0x3
ffffffffc0201fa4:	df860613          	addi	a2,a2,-520 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201fa8:	0f800593          	li	a1,248
ffffffffc0201fac:	00003517          	auipc	a0,0x3
ffffffffc0201fb0:	52c50513          	addi	a0,a0,1324 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201fb4:	94efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0201fb8:	00003697          	auipc	a3,0x3
ffffffffc0201fbc:	34868693          	addi	a3,a3,840 # ffffffffc0205300 <commands+0xc90>
ffffffffc0201fc0:	00003617          	auipc	a2,0x3
ffffffffc0201fc4:	dd860613          	addi	a2,a2,-552 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201fc8:	0df00593          	li	a1,223
ffffffffc0201fcc:	00003517          	auipc	a0,0x3
ffffffffc0201fd0:	50c50513          	addi	a0,a0,1292 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201fd4:	92efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201fd8:	00003697          	auipc	a3,0x3
ffffffffc0201fdc:	64068693          	addi	a3,a3,1600 # ffffffffc0205618 <commands+0xfa8>
ffffffffc0201fe0:	00003617          	auipc	a2,0x3
ffffffffc0201fe4:	db860613          	addi	a2,a2,-584 # ffffffffc0204d98 <commands+0x728>
ffffffffc0201fe8:	0dd00593          	li	a1,221
ffffffffc0201fec:	00003517          	auipc	a0,0x3
ffffffffc0201ff0:	4ec50513          	addi	a0,a0,1260 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0201ff4:	90efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201ff8:	00003697          	auipc	a3,0x3
ffffffffc0201ffc:	66068693          	addi	a3,a3,1632 # ffffffffc0205658 <commands+0xfe8>
ffffffffc0202000:	00003617          	auipc	a2,0x3
ffffffffc0202004:	d9860613          	addi	a2,a2,-616 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202008:	0dc00593          	li	a1,220
ffffffffc020200c:	00003517          	auipc	a0,0x3
ffffffffc0202010:	4cc50513          	addi	a0,a0,1228 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202014:	8eefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202018:	00003697          	auipc	a3,0x3
ffffffffc020201c:	4d868693          	addi	a3,a3,1240 # ffffffffc02054f0 <commands+0xe80>
ffffffffc0202020:	00003617          	auipc	a2,0x3
ffffffffc0202024:	d7860613          	addi	a2,a2,-648 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202028:	0b900593          	li	a1,185
ffffffffc020202c:	00003517          	auipc	a0,0x3
ffffffffc0202030:	4ac50513          	addi	a0,a0,1196 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202034:	8cefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202038:	00003697          	auipc	a3,0x3
ffffffffc020203c:	5e068693          	addi	a3,a3,1504 # ffffffffc0205618 <commands+0xfa8>
ffffffffc0202040:	00003617          	auipc	a2,0x3
ffffffffc0202044:	d5860613          	addi	a2,a2,-680 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202048:	0d600593          	li	a1,214
ffffffffc020204c:	00003517          	auipc	a0,0x3
ffffffffc0202050:	48c50513          	addi	a0,a0,1164 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202054:	8aefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202058:	00003697          	auipc	a3,0x3
ffffffffc020205c:	4d868693          	addi	a3,a3,1240 # ffffffffc0205530 <commands+0xec0>
ffffffffc0202060:	00003617          	auipc	a2,0x3
ffffffffc0202064:	d3860613          	addi	a2,a2,-712 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202068:	0d400593          	li	a1,212
ffffffffc020206c:	00003517          	auipc	a0,0x3
ffffffffc0202070:	46c50513          	addi	a0,a0,1132 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202074:	88efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202078:	00003697          	auipc	a3,0x3
ffffffffc020207c:	49868693          	addi	a3,a3,1176 # ffffffffc0205510 <commands+0xea0>
ffffffffc0202080:	00003617          	auipc	a2,0x3
ffffffffc0202084:	d1860613          	addi	a2,a2,-744 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202088:	0d300593          	li	a1,211
ffffffffc020208c:	00003517          	auipc	a0,0x3
ffffffffc0202090:	44c50513          	addi	a0,a0,1100 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202094:	86efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202098:	00003697          	auipc	a3,0x3
ffffffffc020209c:	49868693          	addi	a3,a3,1176 # ffffffffc0205530 <commands+0xec0>
ffffffffc02020a0:	00003617          	auipc	a2,0x3
ffffffffc02020a4:	cf860613          	addi	a2,a2,-776 # ffffffffc0204d98 <commands+0x728>
ffffffffc02020a8:	0bb00593          	li	a1,187
ffffffffc02020ac:	00003517          	auipc	a0,0x3
ffffffffc02020b0:	42c50513          	addi	a0,a0,1068 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02020b4:	84efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc02020b8:	00003697          	auipc	a3,0x3
ffffffffc02020bc:	71068693          	addi	a3,a3,1808 # ffffffffc02057c8 <commands+0x1158>
ffffffffc02020c0:	00003617          	auipc	a2,0x3
ffffffffc02020c4:	cd860613          	addi	a2,a2,-808 # ffffffffc0204d98 <commands+0x728>
ffffffffc02020c8:	12500593          	li	a1,293
ffffffffc02020cc:	00003517          	auipc	a0,0x3
ffffffffc02020d0:	40c50513          	addi	a0,a0,1036 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02020d4:	82efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02020d8:	00003697          	auipc	a3,0x3
ffffffffc02020dc:	22868693          	addi	a3,a3,552 # ffffffffc0205300 <commands+0xc90>
ffffffffc02020e0:	00003617          	auipc	a2,0x3
ffffffffc02020e4:	cb860613          	addi	a2,a2,-840 # ffffffffc0204d98 <commands+0x728>
ffffffffc02020e8:	11a00593          	li	a1,282
ffffffffc02020ec:	00003517          	auipc	a0,0x3
ffffffffc02020f0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02020f4:	80efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020f8:	00003697          	auipc	a3,0x3
ffffffffc02020fc:	52068693          	addi	a3,a3,1312 # ffffffffc0205618 <commands+0xfa8>
ffffffffc0202100:	00003617          	auipc	a2,0x3
ffffffffc0202104:	c9860613          	addi	a2,a2,-872 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202108:	11800593          	li	a1,280
ffffffffc020210c:	00003517          	auipc	a0,0x3
ffffffffc0202110:	3cc50513          	addi	a0,a0,972 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202114:	feffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202118:	00003697          	auipc	a3,0x3
ffffffffc020211c:	4c068693          	addi	a3,a3,1216 # ffffffffc02055d8 <commands+0xf68>
ffffffffc0202120:	00003617          	auipc	a2,0x3
ffffffffc0202124:	c7860613          	addi	a2,a2,-904 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202128:	0c100593          	li	a1,193
ffffffffc020212c:	00003517          	auipc	a0,0x3
ffffffffc0202130:	3ac50513          	addi	a0,a0,940 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202134:	fcffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202138:	00003697          	auipc	a3,0x3
ffffffffc020213c:	65068693          	addi	a3,a3,1616 # ffffffffc0205788 <commands+0x1118>
ffffffffc0202140:	00003617          	auipc	a2,0x3
ffffffffc0202144:	c5860613          	addi	a2,a2,-936 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202148:	11200593          	li	a1,274
ffffffffc020214c:	00003517          	auipc	a0,0x3
ffffffffc0202150:	38c50513          	addi	a0,a0,908 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202154:	faffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202158:	00003697          	auipc	a3,0x3
ffffffffc020215c:	61068693          	addi	a3,a3,1552 # ffffffffc0205768 <commands+0x10f8>
ffffffffc0202160:	00003617          	auipc	a2,0x3
ffffffffc0202164:	c3860613          	addi	a2,a2,-968 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202168:	11000593          	li	a1,272
ffffffffc020216c:	00003517          	auipc	a0,0x3
ffffffffc0202170:	36c50513          	addi	a0,a0,876 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202174:	f8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202178:	00003697          	auipc	a3,0x3
ffffffffc020217c:	5c868693          	addi	a3,a3,1480 # ffffffffc0205740 <commands+0x10d0>
ffffffffc0202180:	00003617          	auipc	a2,0x3
ffffffffc0202184:	c1860613          	addi	a2,a2,-1000 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202188:	10e00593          	li	a1,270
ffffffffc020218c:	00003517          	auipc	a0,0x3
ffffffffc0202190:	34c50513          	addi	a0,a0,844 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202194:	f6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202198:	00003697          	auipc	a3,0x3
ffffffffc020219c:	58068693          	addi	a3,a3,1408 # ffffffffc0205718 <commands+0x10a8>
ffffffffc02021a0:	00003617          	auipc	a2,0x3
ffffffffc02021a4:	bf860613          	addi	a2,a2,-1032 # ffffffffc0204d98 <commands+0x728>
ffffffffc02021a8:	10d00593          	li	a1,269
ffffffffc02021ac:	00003517          	auipc	a0,0x3
ffffffffc02021b0:	32c50513          	addi	a0,a0,812 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02021b4:	f4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02021b8:	00003697          	auipc	a3,0x3
ffffffffc02021bc:	55068693          	addi	a3,a3,1360 # ffffffffc0205708 <commands+0x1098>
ffffffffc02021c0:	00003617          	auipc	a2,0x3
ffffffffc02021c4:	bd860613          	addi	a2,a2,-1064 # ffffffffc0204d98 <commands+0x728>
ffffffffc02021c8:	10800593          	li	a1,264
ffffffffc02021cc:	00003517          	auipc	a0,0x3
ffffffffc02021d0:	30c50513          	addi	a0,a0,780 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02021d4:	f2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021d8:	00003697          	auipc	a3,0x3
ffffffffc02021dc:	44068693          	addi	a3,a3,1088 # ffffffffc0205618 <commands+0xfa8>
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	bb860613          	addi	a2,a2,-1096 # ffffffffc0204d98 <commands+0x728>
ffffffffc02021e8:	10700593          	li	a1,263
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	2ec50513          	addi	a0,a0,748 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02021f4:	f0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02021f8:	00003697          	auipc	a3,0x3
ffffffffc02021fc:	4f068693          	addi	a3,a3,1264 # ffffffffc02056e8 <commands+0x1078>
ffffffffc0202200:	00003617          	auipc	a2,0x3
ffffffffc0202204:	b9860613          	addi	a2,a2,-1128 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202208:	10600593          	li	a1,262
ffffffffc020220c:	00003517          	auipc	a0,0x3
ffffffffc0202210:	2cc50513          	addi	a0,a0,716 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202214:	eeffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202218:	00003697          	auipc	a3,0x3
ffffffffc020221c:	4a068693          	addi	a3,a3,1184 # ffffffffc02056b8 <commands+0x1048>
ffffffffc0202220:	00003617          	auipc	a2,0x3
ffffffffc0202224:	b7860613          	addi	a2,a2,-1160 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202228:	10500593          	li	a1,261
ffffffffc020222c:	00003517          	auipc	a0,0x3
ffffffffc0202230:	2ac50513          	addi	a0,a0,684 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202234:	ecffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202238:	00003697          	auipc	a3,0x3
ffffffffc020223c:	46868693          	addi	a3,a3,1128 # ffffffffc02056a0 <commands+0x1030>
ffffffffc0202240:	00003617          	auipc	a2,0x3
ffffffffc0202244:	b5860613          	addi	a2,a2,-1192 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202248:	10400593          	li	a1,260
ffffffffc020224c:	00003517          	auipc	a0,0x3
ffffffffc0202250:	28c50513          	addi	a0,a0,652 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202254:	eaffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202258:	00003697          	auipc	a3,0x3
ffffffffc020225c:	3c068693          	addi	a3,a3,960 # ffffffffc0205618 <commands+0xfa8>
ffffffffc0202260:	00003617          	auipc	a2,0x3
ffffffffc0202264:	b3860613          	addi	a2,a2,-1224 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202268:	0fe00593          	li	a1,254
ffffffffc020226c:	00003517          	auipc	a0,0x3
ffffffffc0202270:	26c50513          	addi	a0,a0,620 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202274:	e8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202278:	00003697          	auipc	a3,0x3
ffffffffc020227c:	41068693          	addi	a3,a3,1040 # ffffffffc0205688 <commands+0x1018>
ffffffffc0202280:	00003617          	auipc	a2,0x3
ffffffffc0202284:	b1860613          	addi	a2,a2,-1256 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202288:	0f900593          	li	a1,249
ffffffffc020228c:	00003517          	auipc	a0,0x3
ffffffffc0202290:	24c50513          	addi	a0,a0,588 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202294:	e6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202298:	00003697          	auipc	a3,0x3
ffffffffc020229c:	51068693          	addi	a3,a3,1296 # ffffffffc02057a8 <commands+0x1138>
ffffffffc02022a0:	00003617          	auipc	a2,0x3
ffffffffc02022a4:	af860613          	addi	a2,a2,-1288 # ffffffffc0204d98 <commands+0x728>
ffffffffc02022a8:	11700593          	li	a1,279
ffffffffc02022ac:	00003517          	auipc	a0,0x3
ffffffffc02022b0:	22c50513          	addi	a0,a0,556 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02022b4:	e4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc02022b8:	00003697          	auipc	a3,0x3
ffffffffc02022bc:	52068693          	addi	a3,a3,1312 # ffffffffc02057d8 <commands+0x1168>
ffffffffc02022c0:	00003617          	auipc	a2,0x3
ffffffffc02022c4:	ad860613          	addi	a2,a2,-1320 # ffffffffc0204d98 <commands+0x728>
ffffffffc02022c8:	12600593          	li	a1,294
ffffffffc02022cc:	00003517          	auipc	a0,0x3
ffffffffc02022d0:	20c50513          	addi	a0,a0,524 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02022d4:	e2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02022d8:	00003697          	auipc	a3,0x3
ffffffffc02022dc:	e8868693          	addi	a3,a3,-376 # ffffffffc0205160 <commands+0xaf0>
ffffffffc02022e0:	00003617          	auipc	a2,0x3
ffffffffc02022e4:	ab860613          	addi	a2,a2,-1352 # ffffffffc0204d98 <commands+0x728>
ffffffffc02022e8:	0f300593          	li	a1,243
ffffffffc02022ec:	00003517          	auipc	a0,0x3
ffffffffc02022f0:	1ec50513          	addi	a0,a0,492 # ffffffffc02054d8 <commands+0xe68>
ffffffffc02022f4:	e0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02022f8:	00003697          	auipc	a3,0x3
ffffffffc02022fc:	21868693          	addi	a3,a3,536 # ffffffffc0205510 <commands+0xea0>
ffffffffc0202300:	00003617          	auipc	a2,0x3
ffffffffc0202304:	a9860613          	addi	a2,a2,-1384 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202308:	0ba00593          	li	a1,186
ffffffffc020230c:	00003517          	auipc	a0,0x3
ffffffffc0202310:	1cc50513          	addi	a0,a0,460 # ffffffffc02054d8 <commands+0xe68>
ffffffffc0202314:	deffd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202318 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202318:	1141                	addi	sp,sp,-16
ffffffffc020231a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020231c:	14058a63          	beqz	a1,ffffffffc0202470 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202320:	00359693          	slli	a3,a1,0x3
ffffffffc0202324:	96ae                	add	a3,a3,a1
ffffffffc0202326:	068e                	slli	a3,a3,0x3
ffffffffc0202328:	96aa                	add	a3,a3,a0
ffffffffc020232a:	87aa                	mv	a5,a0
ffffffffc020232c:	02d50263          	beq	a0,a3,ffffffffc0202350 <default_free_pages+0x38>
ffffffffc0202330:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202332:	8b05                	andi	a4,a4,1
ffffffffc0202334:	10071e63          	bnez	a4,ffffffffc0202450 <default_free_pages+0x138>
ffffffffc0202338:	6798                	ld	a4,8(a5)
ffffffffc020233a:	8b09                	andi	a4,a4,2
ffffffffc020233c:	10071a63          	bnez	a4,ffffffffc0202450 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202340:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202344:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202348:	04878793          	addi	a5,a5,72
ffffffffc020234c:	fed792e3          	bne	a5,a3,ffffffffc0202330 <default_free_pages+0x18>
    base->property = n;
ffffffffc0202350:	2581                	sext.w	a1,a1
ffffffffc0202352:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202354:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202358:	4789                	li	a5,2
ffffffffc020235a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020235e:	0000f697          	auipc	a3,0xf
ffffffffc0202362:	d7268693          	addi	a3,a3,-654 # ffffffffc02110d0 <free_area>
ffffffffc0202366:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202368:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020236a:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020236e:	9db9                	addw	a1,a1,a4
ffffffffc0202370:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202372:	0ad78863          	beq	a5,a3,ffffffffc0202422 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202376:	fe078713          	addi	a4,a5,-32
ffffffffc020237a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020237e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202380:	00e56a63          	bltu	a0,a4,ffffffffc0202394 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0202384:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202386:	06d70263          	beq	a4,a3,ffffffffc02023ea <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020238a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020238c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202390:	fee57ae3          	bgeu	a0,a4,ffffffffc0202384 <default_free_pages+0x6c>
ffffffffc0202394:	c199                	beqz	a1,ffffffffc020239a <default_free_pages+0x82>
ffffffffc0202396:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020239a:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020239c:	e390                	sd	a2,0(a5)
ffffffffc020239e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02023a0:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02023a2:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02023a4:	02d70063          	beq	a4,a3,ffffffffc02023c4 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02023a8:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02023ac:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02023b0:	02081613          	slli	a2,a6,0x20
ffffffffc02023b4:	9201                	srli	a2,a2,0x20
ffffffffc02023b6:	00361793          	slli	a5,a2,0x3
ffffffffc02023ba:	97b2                	add	a5,a5,a2
ffffffffc02023bc:	078e                	slli	a5,a5,0x3
ffffffffc02023be:	97ae                	add	a5,a5,a1
ffffffffc02023c0:	02f50f63          	beq	a0,a5,ffffffffc02023fe <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02023c4:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02023c6:	00d70f63          	beq	a4,a3,ffffffffc02023e4 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02023ca:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02023cc:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02023d0:	02059613          	slli	a2,a1,0x20
ffffffffc02023d4:	9201                	srli	a2,a2,0x20
ffffffffc02023d6:	00361793          	slli	a5,a2,0x3
ffffffffc02023da:	97b2                	add	a5,a5,a2
ffffffffc02023dc:	078e                	slli	a5,a5,0x3
ffffffffc02023de:	97aa                	add	a5,a5,a0
ffffffffc02023e0:	04f68863          	beq	a3,a5,ffffffffc0202430 <default_free_pages+0x118>
}
ffffffffc02023e4:	60a2                	ld	ra,8(sp)
ffffffffc02023e6:	0141                	addi	sp,sp,16
ffffffffc02023e8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02023ea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02023ec:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02023ee:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02023f0:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023f2:	02d70563          	beq	a4,a3,ffffffffc020241c <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02023f6:	8832                	mv	a6,a2
ffffffffc02023f8:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02023fa:	87ba                	mv	a5,a4
ffffffffc02023fc:	bf41                	j	ffffffffc020238c <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02023fe:	4d1c                	lw	a5,24(a0)
ffffffffc0202400:	0107883b          	addw	a6,a5,a6
ffffffffc0202404:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202408:	57f5                	li	a5,-3
ffffffffc020240a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020240e:	7110                	ld	a2,32(a0)
ffffffffc0202410:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc0202412:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0202414:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0202416:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0202418:	e390                	sd	a2,0(a5)
ffffffffc020241a:	b775                	j	ffffffffc02023c6 <default_free_pages+0xae>
ffffffffc020241c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020241e:	873e                	mv	a4,a5
ffffffffc0202420:	b761                	j	ffffffffc02023a8 <default_free_pages+0x90>
}
ffffffffc0202422:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202424:	e390                	sd	a2,0(a5)
ffffffffc0202426:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202428:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020242a:	f11c                	sd	a5,32(a0)
ffffffffc020242c:	0141                	addi	sp,sp,16
ffffffffc020242e:	8082                	ret
            base->property += p->property;
ffffffffc0202430:	ff872783          	lw	a5,-8(a4)
ffffffffc0202434:	fe870693          	addi	a3,a4,-24
ffffffffc0202438:	9dbd                	addw	a1,a1,a5
ffffffffc020243a:	cd0c                	sw	a1,24(a0)
ffffffffc020243c:	57f5                	li	a5,-3
ffffffffc020243e:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202442:	6314                	ld	a3,0(a4)
ffffffffc0202444:	671c                	ld	a5,8(a4)
}
ffffffffc0202446:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202448:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020244a:	e394                	sd	a3,0(a5)
ffffffffc020244c:	0141                	addi	sp,sp,16
ffffffffc020244e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202450:	00003697          	auipc	a3,0x3
ffffffffc0202454:	3a068693          	addi	a3,a3,928 # ffffffffc02057f0 <commands+0x1180>
ffffffffc0202458:	00003617          	auipc	a2,0x3
ffffffffc020245c:	94060613          	addi	a2,a2,-1728 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202460:	08300593          	li	a1,131
ffffffffc0202464:	00003517          	auipc	a0,0x3
ffffffffc0202468:	07450513          	addi	a0,a0,116 # ffffffffc02054d8 <commands+0xe68>
ffffffffc020246c:	c97fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202470:	00003697          	auipc	a3,0x3
ffffffffc0202474:	37868693          	addi	a3,a3,888 # ffffffffc02057e8 <commands+0x1178>
ffffffffc0202478:	00003617          	auipc	a2,0x3
ffffffffc020247c:	92060613          	addi	a2,a2,-1760 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202480:	08000593          	li	a1,128
ffffffffc0202484:	00003517          	auipc	a0,0x3
ffffffffc0202488:	05450513          	addi	a0,a0,84 # ffffffffc02054d8 <commands+0xe68>
ffffffffc020248c:	c77fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202490 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202490:	c959                	beqz	a0,ffffffffc0202526 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202492:	0000f597          	auipc	a1,0xf
ffffffffc0202496:	c3e58593          	addi	a1,a1,-962 # ffffffffc02110d0 <free_area>
ffffffffc020249a:	0105a803          	lw	a6,16(a1)
ffffffffc020249e:	862a                	mv	a2,a0
ffffffffc02024a0:	02081793          	slli	a5,a6,0x20
ffffffffc02024a4:	9381                	srli	a5,a5,0x20
ffffffffc02024a6:	00a7ee63          	bltu	a5,a0,ffffffffc02024c2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02024aa:	87ae                	mv	a5,a1
ffffffffc02024ac:	a801                	j	ffffffffc02024bc <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02024ae:	ff87a703          	lw	a4,-8(a5)
ffffffffc02024b2:	02071693          	slli	a3,a4,0x20
ffffffffc02024b6:	9281                	srli	a3,a3,0x20
ffffffffc02024b8:	00c6f763          	bgeu	a3,a2,ffffffffc02024c6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02024bc:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02024be:	feb798e3          	bne	a5,a1,ffffffffc02024ae <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02024c2:	4501                	li	a0,0
}
ffffffffc02024c4:	8082                	ret
    return listelm->prev;
ffffffffc02024c6:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02024ca:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02024ce:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02024d2:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02024d6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02024da:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02024de:	02d67b63          	bgeu	a2,a3,ffffffffc0202514 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02024e2:	00361693          	slli	a3,a2,0x3
ffffffffc02024e6:	96b2                	add	a3,a3,a2
ffffffffc02024e8:	068e                	slli	a3,a3,0x3
ffffffffc02024ea:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02024ec:	41c7073b          	subw	a4,a4,t3
ffffffffc02024f0:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024f2:	00868613          	addi	a2,a3,8
ffffffffc02024f6:	4709                	li	a4,2
ffffffffc02024f8:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02024fc:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202500:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0202504:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202508:	e310                	sd	a2,0(a4)
ffffffffc020250a:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020250e:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202510:	0316b023          	sd	a7,32(a3)
ffffffffc0202514:	41c8083b          	subw	a6,a6,t3
ffffffffc0202518:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020251c:	5775                	li	a4,-3
ffffffffc020251e:	17a1                	addi	a5,a5,-24
ffffffffc0202520:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202524:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202526:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202528:	00003697          	auipc	a3,0x3
ffffffffc020252c:	2c068693          	addi	a3,a3,704 # ffffffffc02057e8 <commands+0x1178>
ffffffffc0202530:	00003617          	auipc	a2,0x3
ffffffffc0202534:	86860613          	addi	a2,a2,-1944 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202538:	06200593          	li	a1,98
ffffffffc020253c:	00003517          	auipc	a0,0x3
ffffffffc0202540:	f9c50513          	addi	a0,a0,-100 # ffffffffc02054d8 <commands+0xe68>
default_alloc_pages(size_t n) {
ffffffffc0202544:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202546:	bbdfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020254a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020254a:	1141                	addi	sp,sp,-16
ffffffffc020254c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020254e:	c9e1                	beqz	a1,ffffffffc020261e <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202550:	00359693          	slli	a3,a1,0x3
ffffffffc0202554:	96ae                	add	a3,a3,a1
ffffffffc0202556:	068e                	slli	a3,a3,0x3
ffffffffc0202558:	96aa                	add	a3,a3,a0
ffffffffc020255a:	87aa                	mv	a5,a0
ffffffffc020255c:	00d50f63          	beq	a0,a3,ffffffffc020257a <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202560:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202562:	8b05                	andi	a4,a4,1
ffffffffc0202564:	cf49                	beqz	a4,ffffffffc02025fe <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202566:	0007ac23          	sw	zero,24(a5)
ffffffffc020256a:	0007b423          	sd	zero,8(a5)
ffffffffc020256e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202572:	04878793          	addi	a5,a5,72
ffffffffc0202576:	fed795e3          	bne	a5,a3,ffffffffc0202560 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020257a:	2581                	sext.w	a1,a1
ffffffffc020257c:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020257e:	4789                	li	a5,2
ffffffffc0202580:	00850713          	addi	a4,a0,8
ffffffffc0202584:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202588:	0000f697          	auipc	a3,0xf
ffffffffc020258c:	b4868693          	addi	a3,a3,-1208 # ffffffffc02110d0 <free_area>
ffffffffc0202590:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202592:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202594:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202598:	9db9                	addw	a1,a1,a4
ffffffffc020259a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020259c:	04d78a63          	beq	a5,a3,ffffffffc02025f0 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02025a0:	fe078713          	addi	a4,a5,-32
ffffffffc02025a4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02025a8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02025aa:	00e56a63          	bltu	a0,a4,ffffffffc02025be <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02025ae:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02025b0:	02d70263          	beq	a4,a3,ffffffffc02025d4 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02025b4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02025b6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02025ba:	fee57ae3          	bgeu	a0,a4,ffffffffc02025ae <default_init_memmap+0x64>
ffffffffc02025be:	c199                	beqz	a1,ffffffffc02025c4 <default_init_memmap+0x7a>
ffffffffc02025c0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02025c4:	6398                	ld	a4,0(a5)
}
ffffffffc02025c6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02025c8:	e390                	sd	a2,0(a5)
ffffffffc02025ca:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02025cc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025ce:	f118                	sd	a4,32(a0)
ffffffffc02025d0:	0141                	addi	sp,sp,16
ffffffffc02025d2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02025d4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025d6:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02025d8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02025da:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02025dc:	00d70663          	beq	a4,a3,ffffffffc02025e8 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02025e0:	8832                	mv	a6,a2
ffffffffc02025e2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02025e4:	87ba                	mv	a5,a4
ffffffffc02025e6:	bfc1                	j	ffffffffc02025b6 <default_init_memmap+0x6c>
}
ffffffffc02025e8:	60a2                	ld	ra,8(sp)
ffffffffc02025ea:	e290                	sd	a2,0(a3)
ffffffffc02025ec:	0141                	addi	sp,sp,16
ffffffffc02025ee:	8082                	ret
ffffffffc02025f0:	60a2                	ld	ra,8(sp)
ffffffffc02025f2:	e390                	sd	a2,0(a5)
ffffffffc02025f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025f6:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025f8:	f11c                	sd	a5,32(a0)
ffffffffc02025fa:	0141                	addi	sp,sp,16
ffffffffc02025fc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02025fe:	00003697          	auipc	a3,0x3
ffffffffc0202602:	21a68693          	addi	a3,a3,538 # ffffffffc0205818 <commands+0x11a8>
ffffffffc0202606:	00002617          	auipc	a2,0x2
ffffffffc020260a:	79260613          	addi	a2,a2,1938 # ffffffffc0204d98 <commands+0x728>
ffffffffc020260e:	04900593          	li	a1,73
ffffffffc0202612:	00003517          	auipc	a0,0x3
ffffffffc0202616:	ec650513          	addi	a0,a0,-314 # ffffffffc02054d8 <commands+0xe68>
ffffffffc020261a:	ae9fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc020261e:	00003697          	auipc	a3,0x3
ffffffffc0202622:	1ca68693          	addi	a3,a3,458 # ffffffffc02057e8 <commands+0x1178>
ffffffffc0202626:	00002617          	auipc	a2,0x2
ffffffffc020262a:	77260613          	addi	a2,a2,1906 # ffffffffc0204d98 <commands+0x728>
ffffffffc020262e:	04600593          	li	a1,70
ffffffffc0202632:	00003517          	auipc	a0,0x3
ffffffffc0202636:	ea650513          	addi	a0,a0,-346 # ffffffffc02054d8 <commands+0xe68>
ffffffffc020263a:	ac9fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020263e <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020263e:	0000f797          	auipc	a5,0xf
ffffffffc0202642:	aaa78793          	addi	a5,a5,-1366 # ffffffffc02110e8 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc0202646:	f51c                	sd	a5,40(a0)
ffffffffc0202648:	e79c                	sd	a5,8(a5)
ffffffffc020264a:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc020264c:	0000f717          	auipc	a4,0xf
ffffffffc0202650:	eef73a23          	sd	a5,-268(a4) # ffffffffc0211540 <curr_ptr>
     return 0;
}
ffffffffc0202654:	4501                	li	a0,0
ffffffffc0202656:	8082                	ret

ffffffffc0202658 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0202658:	4501                	li	a0,0
ffffffffc020265a:	8082                	ret

ffffffffc020265c <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020265c:	4501                	li	a0,0
ffffffffc020265e:	8082                	ret

ffffffffc0202660 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202660:	4501                	li	a0,0
ffffffffc0202662:	8082                	ret

ffffffffc0202664 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0202664:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202666:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0202668:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020266a:	678d                	lui	a5,0x3
ffffffffc020266c:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202670:	0000f697          	auipc	a3,0xf
ffffffffc0202674:	eb06a683          	lw	a3,-336(a3) # ffffffffc0211520 <pgfault_num>
ffffffffc0202678:	4711                	li	a4,4
ffffffffc020267a:	0ae69363          	bne	a3,a4,ffffffffc0202720 <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020267e:	6705                	lui	a4,0x1
ffffffffc0202680:	4629                	li	a2,10
ffffffffc0202682:	0000f797          	auipc	a5,0xf
ffffffffc0202686:	e9e78793          	addi	a5,a5,-354 # ffffffffc0211520 <pgfault_num>
ffffffffc020268a:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc020268e:	4398                	lw	a4,0(a5)
ffffffffc0202690:	2701                	sext.w	a4,a4
ffffffffc0202692:	20d71763          	bne	a4,a3,ffffffffc02028a0 <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202696:	6691                	lui	a3,0x4
ffffffffc0202698:	4635                	li	a2,13
ffffffffc020269a:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020269e:	4394                	lw	a3,0(a5)
ffffffffc02026a0:	2681                	sext.w	a3,a3
ffffffffc02026a2:	1ce69f63          	bne	a3,a4,ffffffffc0202880 <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026a6:	6709                	lui	a4,0x2
ffffffffc02026a8:	462d                	li	a2,11
ffffffffc02026aa:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02026ae:	4398                	lw	a4,0(a5)
ffffffffc02026b0:	2701                	sext.w	a4,a4
ffffffffc02026b2:	1ad71763          	bne	a4,a3,ffffffffc0202860 <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026b6:	6715                	lui	a4,0x5
ffffffffc02026b8:	46b9                	li	a3,14
ffffffffc02026ba:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02026be:	4398                	lw	a4,0(a5)
ffffffffc02026c0:	4695                	li	a3,5
ffffffffc02026c2:	2701                	sext.w	a4,a4
ffffffffc02026c4:	16d71e63          	bne	a4,a3,ffffffffc0202840 <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc02026c8:	4394                	lw	a3,0(a5)
ffffffffc02026ca:	2681                	sext.w	a3,a3
ffffffffc02026cc:	14e69a63          	bne	a3,a4,ffffffffc0202820 <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc02026d0:	4398                	lw	a4,0(a5)
ffffffffc02026d2:	2701                	sext.w	a4,a4
ffffffffc02026d4:	12d71663          	bne	a4,a3,ffffffffc0202800 <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc02026d8:	4394                	lw	a3,0(a5)
ffffffffc02026da:	2681                	sext.w	a3,a3
ffffffffc02026dc:	10e69263          	bne	a3,a4,ffffffffc02027e0 <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc02026e0:	4398                	lw	a4,0(a5)
ffffffffc02026e2:	2701                	sext.w	a4,a4
ffffffffc02026e4:	0cd71e63          	bne	a4,a3,ffffffffc02027c0 <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc02026e8:	4394                	lw	a3,0(a5)
ffffffffc02026ea:	2681                	sext.w	a3,a3
ffffffffc02026ec:	0ae69a63          	bne	a3,a4,ffffffffc02027a0 <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026f0:	6715                	lui	a4,0x5
ffffffffc02026f2:	46b9                	li	a3,14
ffffffffc02026f4:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02026f8:	4398                	lw	a4,0(a5)
ffffffffc02026fa:	4695                	li	a3,5
ffffffffc02026fc:	2701                	sext.w	a4,a4
ffffffffc02026fe:	08d71163          	bne	a4,a3,ffffffffc0202780 <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202702:	6705                	lui	a4,0x1
ffffffffc0202704:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202708:	4729                	li	a4,10
ffffffffc020270a:	04e69b63          	bne	a3,a4,ffffffffc0202760 <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc020270e:	439c                	lw	a5,0(a5)
ffffffffc0202710:	4719                	li	a4,6
ffffffffc0202712:	2781                	sext.w	a5,a5
ffffffffc0202714:	02e79663          	bne	a5,a4,ffffffffc0202740 <_clock_check_swap+0xdc>
}
ffffffffc0202718:	60a2                	ld	ra,8(sp)
ffffffffc020271a:	4501                	li	a0,0
ffffffffc020271c:	0141                	addi	sp,sp,16
ffffffffc020271e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202720:	00003697          	auipc	a3,0x3
ffffffffc0202724:	bd068693          	addi	a3,a3,-1072 # ffffffffc02052f0 <commands+0xc80>
ffffffffc0202728:	00002617          	auipc	a2,0x2
ffffffffc020272c:	67060613          	addi	a2,a2,1648 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202730:	08b00593          	li	a1,139
ffffffffc0202734:	00003517          	auipc	a0,0x3
ffffffffc0202738:	14450513          	addi	a0,a0,324 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020273c:	9c7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc0202740:	00003697          	auipc	a3,0x3
ffffffffc0202744:	18868693          	addi	a3,a3,392 # ffffffffc02058c8 <default_pmm_manager+0x88>
ffffffffc0202748:	00002617          	auipc	a2,0x2
ffffffffc020274c:	65060613          	addi	a2,a2,1616 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202750:	0a200593          	li	a1,162
ffffffffc0202754:	00003517          	auipc	a0,0x3
ffffffffc0202758:	12450513          	addi	a0,a0,292 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020275c:	9a7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202760:	00003697          	auipc	a3,0x3
ffffffffc0202764:	14068693          	addi	a3,a3,320 # ffffffffc02058a0 <default_pmm_manager+0x60>
ffffffffc0202768:	00002617          	auipc	a2,0x2
ffffffffc020276c:	63060613          	addi	a2,a2,1584 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202770:	0a000593          	li	a1,160
ffffffffc0202774:	00003517          	auipc	a0,0x3
ffffffffc0202778:	10450513          	addi	a0,a0,260 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020277c:	987fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202780:	00003697          	auipc	a3,0x3
ffffffffc0202784:	11068693          	addi	a3,a3,272 # ffffffffc0205890 <default_pmm_manager+0x50>
ffffffffc0202788:	00002617          	auipc	a2,0x2
ffffffffc020278c:	61060613          	addi	a2,a2,1552 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202790:	09f00593          	li	a1,159
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	0e450513          	addi	a0,a0,228 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020279c:	967fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027a0:	00003697          	auipc	a3,0x3
ffffffffc02027a4:	0f068693          	addi	a3,a3,240 # ffffffffc0205890 <default_pmm_manager+0x50>
ffffffffc02027a8:	00002617          	auipc	a2,0x2
ffffffffc02027ac:	5f060613          	addi	a2,a2,1520 # ffffffffc0204d98 <commands+0x728>
ffffffffc02027b0:	09d00593          	li	a1,157
ffffffffc02027b4:	00003517          	auipc	a0,0x3
ffffffffc02027b8:	0c450513          	addi	a0,a0,196 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc02027bc:	947fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027c0:	00003697          	auipc	a3,0x3
ffffffffc02027c4:	0d068693          	addi	a3,a3,208 # ffffffffc0205890 <default_pmm_manager+0x50>
ffffffffc02027c8:	00002617          	auipc	a2,0x2
ffffffffc02027cc:	5d060613          	addi	a2,a2,1488 # ffffffffc0204d98 <commands+0x728>
ffffffffc02027d0:	09b00593          	li	a1,155
ffffffffc02027d4:	00003517          	auipc	a0,0x3
ffffffffc02027d8:	0a450513          	addi	a0,a0,164 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc02027dc:	927fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027e0:	00003697          	auipc	a3,0x3
ffffffffc02027e4:	0b068693          	addi	a3,a3,176 # ffffffffc0205890 <default_pmm_manager+0x50>
ffffffffc02027e8:	00002617          	auipc	a2,0x2
ffffffffc02027ec:	5b060613          	addi	a2,a2,1456 # ffffffffc0204d98 <commands+0x728>
ffffffffc02027f0:	09900593          	li	a1,153
ffffffffc02027f4:	00003517          	auipc	a0,0x3
ffffffffc02027f8:	08450513          	addi	a0,a0,132 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc02027fc:	907fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202800:	00003697          	auipc	a3,0x3
ffffffffc0202804:	09068693          	addi	a3,a3,144 # ffffffffc0205890 <default_pmm_manager+0x50>
ffffffffc0202808:	00002617          	auipc	a2,0x2
ffffffffc020280c:	59060613          	addi	a2,a2,1424 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202810:	09700593          	li	a1,151
ffffffffc0202814:	00003517          	auipc	a0,0x3
ffffffffc0202818:	06450513          	addi	a0,a0,100 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020281c:	8e7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202820:	00003697          	auipc	a3,0x3
ffffffffc0202824:	07068693          	addi	a3,a3,112 # ffffffffc0205890 <default_pmm_manager+0x50>
ffffffffc0202828:	00002617          	auipc	a2,0x2
ffffffffc020282c:	57060613          	addi	a2,a2,1392 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202830:	09500593          	li	a1,149
ffffffffc0202834:	00003517          	auipc	a0,0x3
ffffffffc0202838:	04450513          	addi	a0,a0,68 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020283c:	8c7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202840:	00003697          	auipc	a3,0x3
ffffffffc0202844:	05068693          	addi	a3,a3,80 # ffffffffc0205890 <default_pmm_manager+0x50>
ffffffffc0202848:	00002617          	auipc	a2,0x2
ffffffffc020284c:	55060613          	addi	a2,a2,1360 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202850:	09300593          	li	a1,147
ffffffffc0202854:	00003517          	auipc	a0,0x3
ffffffffc0202858:	02450513          	addi	a0,a0,36 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020285c:	8a7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202860:	00003697          	auipc	a3,0x3
ffffffffc0202864:	a9068693          	addi	a3,a3,-1392 # ffffffffc02052f0 <commands+0xc80>
ffffffffc0202868:	00002617          	auipc	a2,0x2
ffffffffc020286c:	53060613          	addi	a2,a2,1328 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202870:	09100593          	li	a1,145
ffffffffc0202874:	00003517          	auipc	a0,0x3
ffffffffc0202878:	00450513          	addi	a0,a0,4 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020287c:	887fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202880:	00003697          	auipc	a3,0x3
ffffffffc0202884:	a7068693          	addi	a3,a3,-1424 # ffffffffc02052f0 <commands+0xc80>
ffffffffc0202888:	00002617          	auipc	a2,0x2
ffffffffc020288c:	51060613          	addi	a2,a2,1296 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202890:	08f00593          	li	a1,143
ffffffffc0202894:	00003517          	auipc	a0,0x3
ffffffffc0202898:	fe450513          	addi	a0,a0,-28 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc020289c:	867fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc02028a0:	00003697          	auipc	a3,0x3
ffffffffc02028a4:	a5068693          	addi	a3,a3,-1456 # ffffffffc02052f0 <commands+0xc80>
ffffffffc02028a8:	00002617          	auipc	a2,0x2
ffffffffc02028ac:	4f060613          	addi	a2,a2,1264 # ffffffffc0204d98 <commands+0x728>
ffffffffc02028b0:	08d00593          	li	a1,141
ffffffffc02028b4:	00003517          	auipc	a0,0x3
ffffffffc02028b8:	fc450513          	addi	a0,a0,-60 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc02028bc:	847fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02028c0 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02028c0:	7518                	ld	a4,40(a0)
{
ffffffffc02028c2:	1101                	addi	sp,sp,-32
ffffffffc02028c4:	ec06                	sd	ra,24(sp)
ffffffffc02028c6:	e822                	sd	s0,16(sp)
ffffffffc02028c8:	e426                	sd	s1,8(sp)
ffffffffc02028ca:	e04a                	sd	s2,0(sp)
         assert(head != NULL);
ffffffffc02028cc:	cf39                	beqz	a4,ffffffffc020292a <_clock_swap_out_victim+0x6a>
     assert(in_tick==0);
ffffffffc02028ce:	ee35                	bnez	a2,ffffffffc020294a <_clock_swap_out_victim+0x8a>
ffffffffc02028d0:	0000f917          	auipc	s2,0xf
ffffffffc02028d4:	c7090913          	addi	s2,s2,-912 # ffffffffc0211540 <curr_ptr>
ffffffffc02028d8:	00093403          	ld	s0,0(s2)
ffffffffc02028dc:	84ae                	mv	s1,a1
ffffffffc02028de:	a031                	j	ffffffffc02028ea <_clock_swap_out_victim+0x2a>
        if(!page->visited) {
ffffffffc02028e0:	fe043783          	ld	a5,-32(s0)
ffffffffc02028e4:	cb91                	beqz	a5,ffffffffc02028f8 <_clock_swap_out_victim+0x38>
            page->visited = 0;
ffffffffc02028e6:	fe043023          	sd	zero,-32(s0)
    return listelm->next;
ffffffffc02028ea:	6400                	ld	s0,8(s0)
        if(curr_ptr == head)
ffffffffc02028ec:	fe871ae3          	bne	a4,s0,ffffffffc02028e0 <_clock_swap_out_victim+0x20>
ffffffffc02028f0:	6700                	ld	s0,8(a4)
        if(!page->visited) {
ffffffffc02028f2:	fe043783          	ld	a5,-32(s0)
ffffffffc02028f6:	fbe5                	bnez	a5,ffffffffc02028e6 <_clock_swap_out_victim+0x26>
            cprintf("curr_ptr 0xffffffff%x\n", curr_ptr);
ffffffffc02028f8:	85a2                	mv	a1,s0
ffffffffc02028fa:	00003517          	auipc	a0,0x3
ffffffffc02028fe:	ffe50513          	addi	a0,a0,-2 # ffffffffc02058f8 <default_pmm_manager+0xb8>
ffffffffc0202902:	00893023          	sd	s0,0(s2)
ffffffffc0202906:	fb4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
            list_del(curr_ptr);
ffffffffc020290a:	00093783          	ld	a5,0(s2)
        struct Page *page = le2page(curr_ptr, pra_page_link);
ffffffffc020290e:	fd040413          	addi	s0,s0,-48
}
ffffffffc0202912:	60e2                	ld	ra,24(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202914:	6398                	ld	a4,0(a5)
ffffffffc0202916:	679c                	ld	a5,8(a5)
ffffffffc0202918:	6902                	ld	s2,0(sp)
ffffffffc020291a:	4501                	li	a0,0
    prev->next = next;
ffffffffc020291c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020291e:	e398                	sd	a4,0(a5)
            *ptr_page = page;//将该页面指针赋值给ptr_page作为换出页面
ffffffffc0202920:	e080                	sd	s0,0(s1)
}
ffffffffc0202922:	6442                	ld	s0,16(sp)
ffffffffc0202924:	64a2                	ld	s1,8(sp)
ffffffffc0202926:	6105                	addi	sp,sp,32
ffffffffc0202928:	8082                	ret
         assert(head != NULL);
ffffffffc020292a:	00003697          	auipc	a3,0x3
ffffffffc020292e:	fae68693          	addi	a3,a3,-82 # ffffffffc02058d8 <default_pmm_manager+0x98>
ffffffffc0202932:	00002617          	auipc	a2,0x2
ffffffffc0202936:	46660613          	addi	a2,a2,1126 # ffffffffc0204d98 <commands+0x728>
ffffffffc020293a:	04900593          	li	a1,73
ffffffffc020293e:	00003517          	auipc	a0,0x3
ffffffffc0202942:	f3a50513          	addi	a0,a0,-198 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc0202946:	fbcfd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(in_tick==0);
ffffffffc020294a:	00003697          	auipc	a3,0x3
ffffffffc020294e:	f9e68693          	addi	a3,a3,-98 # ffffffffc02058e8 <default_pmm_manager+0xa8>
ffffffffc0202952:	00002617          	auipc	a2,0x2
ffffffffc0202956:	44660613          	addi	a2,a2,1094 # ffffffffc0204d98 <commands+0x728>
ffffffffc020295a:	04a00593          	li	a1,74
ffffffffc020295e:	00003517          	auipc	a0,0x3
ffffffffc0202962:	f1a50513          	addi	a0,a0,-230 # ffffffffc0205878 <default_pmm_manager+0x38>
ffffffffc0202966:	f9cfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020296a <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020296a:	0000f797          	auipc	a5,0xf
ffffffffc020296e:	bd67b783          	ld	a5,-1066(a5) # ffffffffc0211540 <curr_ptr>
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202972:	7514                	ld	a3,40(a0)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0202974:	cf89                	beqz	a5,ffffffffc020298e <_clock_map_swappable+0x24>
    list_add(head->prev, entry);
ffffffffc0202976:	629c                	ld	a5,0(a3)
ffffffffc0202978:	03060713          	addi	a4,a2,48
}
ffffffffc020297c:	4501                	li	a0,0
    __list_add(elm, listelm, listelm->next);
ffffffffc020297e:	6794                	ld	a3,8(a5)
    prev->next = next->prev = elm;
ffffffffc0202980:	e298                	sd	a4,0(a3)
ffffffffc0202982:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0202984:	fa1c                	sd	a5,48(a2)
    page->visited = 1;
ffffffffc0202986:	4785                	li	a5,1
    elm->next = next;
ffffffffc0202988:	fe14                	sd	a3,56(a2)
ffffffffc020298a:	ea1c                	sd	a5,16(a2)
}
ffffffffc020298c:	8082                	ret
{
ffffffffc020298e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0202990:	00003697          	auipc	a3,0x3
ffffffffc0202994:	f8068693          	addi	a3,a3,-128 # ffffffffc0205910 <default_pmm_manager+0xd0>
ffffffffc0202998:	00002617          	auipc	a2,0x2
ffffffffc020299c:	40060613          	addi	a2,a2,1024 # ffffffffc0204d98 <commands+0x728>
ffffffffc02029a0:	03600593          	li	a1,54
ffffffffc02029a4:	00003517          	auipc	a0,0x3
ffffffffc02029a8:	ed450513          	addi	a0,a0,-300 # ffffffffc0205878 <default_pmm_manager+0x38>
{
ffffffffc02029ac:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02029ae:	f54fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02029b2 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029b2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02029b4:	00002617          	auipc	a2,0x2
ffffffffc02029b8:	63460613          	addi	a2,a2,1588 # ffffffffc0204fe8 <commands+0x978>
ffffffffc02029bc:	06500593          	li	a1,101
ffffffffc02029c0:	00002517          	auipc	a0,0x2
ffffffffc02029c4:	64850513          	addi	a0,a0,1608 # ffffffffc0205008 <commands+0x998>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029c8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02029ca:	f38fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02029ce <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02029ce:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02029d0:	00003617          	auipc	a2,0x3
ffffffffc02029d4:	95860613          	addi	a2,a2,-1704 # ffffffffc0205328 <commands+0xcb8>
ffffffffc02029d8:	07000593          	li	a1,112
ffffffffc02029dc:	00002517          	auipc	a0,0x2
ffffffffc02029e0:	62c50513          	addi	a0,a0,1580 # ffffffffc0205008 <commands+0x998>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02029e4:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02029e6:	f1cfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02029ea <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02029ea:	7139                	addi	sp,sp,-64
ffffffffc02029ec:	f426                	sd	s1,40(sp)
ffffffffc02029ee:	f04a                	sd	s2,32(sp)
ffffffffc02029f0:	ec4e                	sd	s3,24(sp)
ffffffffc02029f2:	e852                	sd	s4,16(sp)
ffffffffc02029f4:	e456                	sd	s5,8(sp)
ffffffffc02029f6:	e05a                	sd	s6,0(sp)
ffffffffc02029f8:	fc06                	sd	ra,56(sp)
ffffffffc02029fa:	f822                	sd	s0,48(sp)
ffffffffc02029fc:	84aa                	mv	s1,a0
ffffffffc02029fe:	0000f917          	auipc	s2,0xf
ffffffffc0202a02:	b6a90913          	addi	s2,s2,-1174 # ffffffffc0211568 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a06:	4a05                	li	s4,1
ffffffffc0202a08:	0000fa97          	auipc	s5,0xf
ffffffffc0202a0c:	b30a8a93          	addi	s5,s5,-1232 # ffffffffc0211538 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a10:	0005099b          	sext.w	s3,a0
ffffffffc0202a14:	0000fb17          	auipc	s6,0xf
ffffffffc0202a18:	b04b0b13          	addi	s6,s6,-1276 # ffffffffc0211518 <check_mm_struct>
ffffffffc0202a1c:	a01d                	j	ffffffffc0202a42 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a1e:	00093783          	ld	a5,0(s2)
ffffffffc0202a22:	6f9c                	ld	a5,24(a5)
ffffffffc0202a24:	9782                	jalr	a5
ffffffffc0202a26:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a28:	4601                	li	a2,0
ffffffffc0202a2a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a2c:	ec0d                	bnez	s0,ffffffffc0202a66 <alloc_pages+0x7c>
ffffffffc0202a2e:	029a6c63          	bltu	s4,s1,ffffffffc0202a66 <alloc_pages+0x7c>
ffffffffc0202a32:	000aa783          	lw	a5,0(s5)
ffffffffc0202a36:	2781                	sext.w	a5,a5
ffffffffc0202a38:	c79d                	beqz	a5,ffffffffc0202a66 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a3a:	000b3503          	ld	a0,0(s6)
ffffffffc0202a3e:	f9bfe0ef          	jal	ra,ffffffffc02019d8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a42:	100027f3          	csrr	a5,sstatus
ffffffffc0202a46:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a48:	8526                	mv	a0,s1
ffffffffc0202a4a:	dbf1                	beqz	a5,ffffffffc0202a1e <alloc_pages+0x34>
        intr_disable();
ffffffffc0202a4c:	aa3fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202a50:	00093783          	ld	a5,0(s2)
ffffffffc0202a54:	8526                	mv	a0,s1
ffffffffc0202a56:	6f9c                	ld	a5,24(a5)
ffffffffc0202a58:	9782                	jalr	a5
ffffffffc0202a5a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a5c:	a8dfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a60:	4601                	li	a2,0
ffffffffc0202a62:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a64:	d469                	beqz	s0,ffffffffc0202a2e <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202a66:	70e2                	ld	ra,56(sp)
ffffffffc0202a68:	8522                	mv	a0,s0
ffffffffc0202a6a:	7442                	ld	s0,48(sp)
ffffffffc0202a6c:	74a2                	ld	s1,40(sp)
ffffffffc0202a6e:	7902                	ld	s2,32(sp)
ffffffffc0202a70:	69e2                	ld	s3,24(sp)
ffffffffc0202a72:	6a42                	ld	s4,16(sp)
ffffffffc0202a74:	6aa2                	ld	s5,8(sp)
ffffffffc0202a76:	6b02                	ld	s6,0(sp)
ffffffffc0202a78:	6121                	addi	sp,sp,64
ffffffffc0202a7a:	8082                	ret

ffffffffc0202a7c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a7c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a80:	8b89                	andi	a5,a5,2
ffffffffc0202a82:	e799                	bnez	a5,ffffffffc0202a90 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202a84:	0000f797          	auipc	a5,0xf
ffffffffc0202a88:	ae47b783          	ld	a5,-1308(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202a8c:	739c                	ld	a5,32(a5)
ffffffffc0202a8e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202a90:	1101                	addi	sp,sp,-32
ffffffffc0202a92:	ec06                	sd	ra,24(sp)
ffffffffc0202a94:	e822                	sd	s0,16(sp)
ffffffffc0202a96:	e426                	sd	s1,8(sp)
ffffffffc0202a98:	842a                	mv	s0,a0
ffffffffc0202a9a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202a9c:	a53fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202aa0:	0000f797          	auipc	a5,0xf
ffffffffc0202aa4:	ac87b783          	ld	a5,-1336(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202aa8:	739c                	ld	a5,32(a5)
ffffffffc0202aaa:	85a6                	mv	a1,s1
ffffffffc0202aac:	8522                	mv	a0,s0
ffffffffc0202aae:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202ab0:	6442                	ld	s0,16(sp)
ffffffffc0202ab2:	60e2                	ld	ra,24(sp)
ffffffffc0202ab4:	64a2                	ld	s1,8(sp)
ffffffffc0202ab6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202ab8:	a31fd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202abc <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202abc:	100027f3          	csrr	a5,sstatus
ffffffffc0202ac0:	8b89                	andi	a5,a5,2
ffffffffc0202ac2:	e799                	bnez	a5,ffffffffc0202ad0 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202ac4:	0000f797          	auipc	a5,0xf
ffffffffc0202ac8:	aa47b783          	ld	a5,-1372(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202acc:	779c                	ld	a5,40(a5)
ffffffffc0202ace:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202ad0:	1141                	addi	sp,sp,-16
ffffffffc0202ad2:	e406                	sd	ra,8(sp)
ffffffffc0202ad4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202ad6:	a19fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202ada:	0000f797          	auipc	a5,0xf
ffffffffc0202ade:	a8e7b783          	ld	a5,-1394(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202ae2:	779c                	ld	a5,40(a5)
ffffffffc0202ae4:	9782                	jalr	a5
ffffffffc0202ae6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202ae8:	a01fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202aec:	60a2                	ld	ra,8(sp)
ffffffffc0202aee:	8522                	mv	a0,s0
ffffffffc0202af0:	6402                	ld	s0,0(sp)
ffffffffc0202af2:	0141                	addi	sp,sp,16
ffffffffc0202af4:	8082                	ret

ffffffffc0202af6 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202af6:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202afa:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202afe:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b00:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b02:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b04:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b08:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b0a:	f84a                	sd	s2,48(sp)
ffffffffc0202b0c:	f44e                	sd	s3,40(sp)
ffffffffc0202b0e:	f052                	sd	s4,32(sp)
ffffffffc0202b10:	e486                	sd	ra,72(sp)
ffffffffc0202b12:	e0a2                	sd	s0,64(sp)
ffffffffc0202b14:	ec56                	sd	s5,24(sp)
ffffffffc0202b16:	e85a                	sd	s6,16(sp)
ffffffffc0202b18:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b1a:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b1e:	892e                	mv	s2,a1
ffffffffc0202b20:	8a32                	mv	s4,a2
ffffffffc0202b22:	0000f997          	auipc	s3,0xf
ffffffffc0202b26:	a3698993          	addi	s3,s3,-1482 # ffffffffc0211558 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b2a:	efb5                	bnez	a5,ffffffffc0202ba6 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202b2c:	14060c63          	beqz	a2,ffffffffc0202c84 <get_pte+0x18e>
ffffffffc0202b30:	4505                	li	a0,1
ffffffffc0202b32:	eb9ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202b36:	842a                	mv	s0,a0
ffffffffc0202b38:	14050663          	beqz	a0,ffffffffc0202c84 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b3c:	0000fb97          	auipc	s7,0xf
ffffffffc0202b40:	a24b8b93          	addi	s7,s7,-1500 # ffffffffc0211560 <pages>
ffffffffc0202b44:	000bb503          	ld	a0,0(s7)
ffffffffc0202b48:	00003b17          	auipc	s6,0x3
ffffffffc0202b4c:	6a0b3b03          	ld	s6,1696(s6) # ffffffffc02061e8 <error_string+0x38>
ffffffffc0202b50:	00080ab7          	lui	s5,0x80
ffffffffc0202b54:	40a40533          	sub	a0,s0,a0
ffffffffc0202b58:	850d                	srai	a0,a0,0x3
ffffffffc0202b5a:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202b5e:	0000f997          	auipc	s3,0xf
ffffffffc0202b62:	9fa98993          	addi	s3,s3,-1542 # ffffffffc0211558 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b66:	4785                	li	a5,1
ffffffffc0202b68:	0009b703          	ld	a4,0(s3)
ffffffffc0202b6c:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b6e:	9556                	add	a0,a0,s5
ffffffffc0202b70:	00c51793          	slli	a5,a0,0xc
ffffffffc0202b74:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b76:	0532                	slli	a0,a0,0xc
ffffffffc0202b78:	14e7fd63          	bgeu	a5,a4,ffffffffc0202cd2 <get_pte+0x1dc>
ffffffffc0202b7c:	0000f797          	auipc	a5,0xf
ffffffffc0202b80:	9f47b783          	ld	a5,-1548(a5) # ffffffffc0211570 <va_pa_offset>
ffffffffc0202b84:	6605                	lui	a2,0x1
ffffffffc0202b86:	4581                	li	a1,0
ffffffffc0202b88:	953e                	add	a0,a0,a5
ffffffffc0202b8a:	3a2010ef          	jal	ra,ffffffffc0203f2c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b8e:	000bb683          	ld	a3,0(s7)
ffffffffc0202b92:	40d406b3          	sub	a3,s0,a3
ffffffffc0202b96:	868d                	srai	a3,a3,0x3
ffffffffc0202b98:	036686b3          	mul	a3,a3,s6
ffffffffc0202b9c:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202b9e:	06aa                	slli	a3,a3,0xa
ffffffffc0202ba0:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202ba4:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202ba6:	77fd                	lui	a5,0xfffff
ffffffffc0202ba8:	068a                	slli	a3,a3,0x2
ffffffffc0202baa:	0009b703          	ld	a4,0(s3)
ffffffffc0202bae:	8efd                	and	a3,a3,a5
ffffffffc0202bb0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202bb4:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202c88 <get_pte+0x192>
ffffffffc0202bb8:	0000fa97          	auipc	s5,0xf
ffffffffc0202bbc:	9b8a8a93          	addi	s5,s5,-1608 # ffffffffc0211570 <va_pa_offset>
ffffffffc0202bc0:	000ab403          	ld	s0,0(s5)
ffffffffc0202bc4:	01595793          	srli	a5,s2,0x15
ffffffffc0202bc8:	1ff7f793          	andi	a5,a5,511
ffffffffc0202bcc:	96a2                	add	a3,a3,s0
ffffffffc0202bce:	00379413          	slli	s0,a5,0x3
ffffffffc0202bd2:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202bd4:	6014                	ld	a3,0(s0)
ffffffffc0202bd6:	0016f793          	andi	a5,a3,1
ffffffffc0202bda:	ebad                	bnez	a5,ffffffffc0202c4c <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202bdc:	0a0a0463          	beqz	s4,ffffffffc0202c84 <get_pte+0x18e>
ffffffffc0202be0:	4505                	li	a0,1
ffffffffc0202be2:	e09ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0202be6:	84aa                	mv	s1,a0
ffffffffc0202be8:	cd51                	beqz	a0,ffffffffc0202c84 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bea:	0000fb97          	auipc	s7,0xf
ffffffffc0202bee:	976b8b93          	addi	s7,s7,-1674 # ffffffffc0211560 <pages>
ffffffffc0202bf2:	000bb503          	ld	a0,0(s7)
ffffffffc0202bf6:	00003b17          	auipc	s6,0x3
ffffffffc0202bfa:	5f2b3b03          	ld	s6,1522(s6) # ffffffffc02061e8 <error_string+0x38>
ffffffffc0202bfe:	00080a37          	lui	s4,0x80
ffffffffc0202c02:	40a48533          	sub	a0,s1,a0
ffffffffc0202c06:	850d                	srai	a0,a0,0x3
ffffffffc0202c08:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c0c:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c0e:	0009b703          	ld	a4,0(s3)
ffffffffc0202c12:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c14:	9552                	add	a0,a0,s4
ffffffffc0202c16:	00c51793          	slli	a5,a0,0xc
ffffffffc0202c1a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c1c:	0532                	slli	a0,a0,0xc
ffffffffc0202c1e:	08e7fd63          	bgeu	a5,a4,ffffffffc0202cb8 <get_pte+0x1c2>
ffffffffc0202c22:	000ab783          	ld	a5,0(s5)
ffffffffc0202c26:	6605                	lui	a2,0x1
ffffffffc0202c28:	4581                	li	a1,0
ffffffffc0202c2a:	953e                	add	a0,a0,a5
ffffffffc0202c2c:	300010ef          	jal	ra,ffffffffc0203f2c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c30:	000bb683          	ld	a3,0(s7)
ffffffffc0202c34:	40d486b3          	sub	a3,s1,a3
ffffffffc0202c38:	868d                	srai	a3,a3,0x3
ffffffffc0202c3a:	036686b3          	mul	a3,a3,s6
ffffffffc0202c3e:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c40:	06aa                	slli	a3,a3,0xa
ffffffffc0202c42:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c46:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c48:	0009b703          	ld	a4,0(s3)
ffffffffc0202c4c:	068a                	slli	a3,a3,0x2
ffffffffc0202c4e:	757d                	lui	a0,0xfffff
ffffffffc0202c50:	8ee9                	and	a3,a3,a0
ffffffffc0202c52:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c56:	04e7f563          	bgeu	a5,a4,ffffffffc0202ca0 <get_pte+0x1aa>
ffffffffc0202c5a:	000ab503          	ld	a0,0(s5)
ffffffffc0202c5e:	00c95913          	srli	s2,s2,0xc
ffffffffc0202c62:	1ff97913          	andi	s2,s2,511
ffffffffc0202c66:	96aa                	add	a3,a3,a0
ffffffffc0202c68:	00391513          	slli	a0,s2,0x3
ffffffffc0202c6c:	9536                	add	a0,a0,a3
}
ffffffffc0202c6e:	60a6                	ld	ra,72(sp)
ffffffffc0202c70:	6406                	ld	s0,64(sp)
ffffffffc0202c72:	74e2                	ld	s1,56(sp)
ffffffffc0202c74:	7942                	ld	s2,48(sp)
ffffffffc0202c76:	79a2                	ld	s3,40(sp)
ffffffffc0202c78:	7a02                	ld	s4,32(sp)
ffffffffc0202c7a:	6ae2                	ld	s5,24(sp)
ffffffffc0202c7c:	6b42                	ld	s6,16(sp)
ffffffffc0202c7e:	6ba2                	ld	s7,8(sp)
ffffffffc0202c80:	6161                	addi	sp,sp,80
ffffffffc0202c82:	8082                	ret
            return NULL;
ffffffffc0202c84:	4501                	li	a0,0
ffffffffc0202c86:	b7e5                	j	ffffffffc0202c6e <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c88:	00003617          	auipc	a2,0x3
ffffffffc0202c8c:	cc860613          	addi	a2,a2,-824 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0202c90:	10200593          	li	a1,258
ffffffffc0202c94:	00003517          	auipc	a0,0x3
ffffffffc0202c98:	ce450513          	addi	a0,a0,-796 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0202c9c:	c66fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202ca0:	00003617          	auipc	a2,0x3
ffffffffc0202ca4:	cb060613          	addi	a2,a2,-848 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0202ca8:	10f00593          	li	a1,271
ffffffffc0202cac:	00003517          	auipc	a0,0x3
ffffffffc0202cb0:	ccc50513          	addi	a0,a0,-820 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0202cb4:	c4efd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cb8:	86aa                	mv	a3,a0
ffffffffc0202cba:	00003617          	auipc	a2,0x3
ffffffffc0202cbe:	c9660613          	addi	a2,a2,-874 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0202cc2:	10b00593          	li	a1,267
ffffffffc0202cc6:	00003517          	auipc	a0,0x3
ffffffffc0202cca:	cb250513          	addi	a0,a0,-846 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0202cce:	c34fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cd2:	86aa                	mv	a3,a0
ffffffffc0202cd4:	00003617          	auipc	a2,0x3
ffffffffc0202cd8:	c7c60613          	addi	a2,a2,-900 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0202cdc:	0ff00593          	li	a1,255
ffffffffc0202ce0:	00003517          	auipc	a0,0x3
ffffffffc0202ce4:	c9850513          	addi	a0,a0,-872 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0202ce8:	c1afd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202cec <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202cec:	1141                	addi	sp,sp,-16
ffffffffc0202cee:	e022                	sd	s0,0(sp)
ffffffffc0202cf0:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cf2:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202cf4:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cf6:	e01ff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202cfa:	c011                	beqz	s0,ffffffffc0202cfe <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202cfc:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202cfe:	c511                	beqz	a0,ffffffffc0202d0a <get_page+0x1e>
ffffffffc0202d00:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202d02:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d04:	0017f713          	andi	a4,a5,1
ffffffffc0202d08:	e709                	bnez	a4,ffffffffc0202d12 <get_page+0x26>
}
ffffffffc0202d0a:	60a2                	ld	ra,8(sp)
ffffffffc0202d0c:	6402                	ld	s0,0(sp)
ffffffffc0202d0e:	0141                	addi	sp,sp,16
ffffffffc0202d10:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d12:	078a                	slli	a5,a5,0x2
ffffffffc0202d14:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d16:	0000f717          	auipc	a4,0xf
ffffffffc0202d1a:	84273703          	ld	a4,-1982(a4) # ffffffffc0211558 <npage>
ffffffffc0202d1e:	02e7f263          	bgeu	a5,a4,ffffffffc0202d42 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d22:	fff80537          	lui	a0,0xfff80
ffffffffc0202d26:	97aa                	add	a5,a5,a0
ffffffffc0202d28:	60a2                	ld	ra,8(sp)
ffffffffc0202d2a:	6402                	ld	s0,0(sp)
ffffffffc0202d2c:	00379513          	slli	a0,a5,0x3
ffffffffc0202d30:	97aa                	add	a5,a5,a0
ffffffffc0202d32:	078e                	slli	a5,a5,0x3
ffffffffc0202d34:	0000f517          	auipc	a0,0xf
ffffffffc0202d38:	82c53503          	ld	a0,-2004(a0) # ffffffffc0211560 <pages>
ffffffffc0202d3c:	953e                	add	a0,a0,a5
ffffffffc0202d3e:	0141                	addi	sp,sp,16
ffffffffc0202d40:	8082                	ret
ffffffffc0202d42:	c71ff0ef          	jal	ra,ffffffffc02029b2 <pa2page.part.0>

ffffffffc0202d46 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d46:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d48:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d4a:	ec06                	sd	ra,24(sp)
ffffffffc0202d4c:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d4e:	da9ff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
    if (ptep != NULL) {
ffffffffc0202d52:	c511                	beqz	a0,ffffffffc0202d5e <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202d54:	611c                	ld	a5,0(a0)
ffffffffc0202d56:	842a                	mv	s0,a0
ffffffffc0202d58:	0017f713          	andi	a4,a5,1
ffffffffc0202d5c:	e709                	bnez	a4,ffffffffc0202d66 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202d5e:	60e2                	ld	ra,24(sp)
ffffffffc0202d60:	6442                	ld	s0,16(sp)
ffffffffc0202d62:	6105                	addi	sp,sp,32
ffffffffc0202d64:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d66:	078a                	slli	a5,a5,0x2
ffffffffc0202d68:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d6a:	0000e717          	auipc	a4,0xe
ffffffffc0202d6e:	7ee73703          	ld	a4,2030(a4) # ffffffffc0211558 <npage>
ffffffffc0202d72:	06e7f563          	bgeu	a5,a4,ffffffffc0202ddc <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d76:	fff80737          	lui	a4,0xfff80
ffffffffc0202d7a:	97ba                	add	a5,a5,a4
ffffffffc0202d7c:	00379513          	slli	a0,a5,0x3
ffffffffc0202d80:	97aa                	add	a5,a5,a0
ffffffffc0202d82:	078e                	slli	a5,a5,0x3
ffffffffc0202d84:	0000e517          	auipc	a0,0xe
ffffffffc0202d88:	7dc53503          	ld	a0,2012(a0) # ffffffffc0211560 <pages>
ffffffffc0202d8c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202d8e:	411c                	lw	a5,0(a0)
ffffffffc0202d90:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202d94:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202d96:	cb09                	beqz	a4,ffffffffc0202da8 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202d98:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202d9c:	12000073          	sfence.vma
}
ffffffffc0202da0:	60e2                	ld	ra,24(sp)
ffffffffc0202da2:	6442                	ld	s0,16(sp)
ffffffffc0202da4:	6105                	addi	sp,sp,32
ffffffffc0202da6:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202da8:	100027f3          	csrr	a5,sstatus
ffffffffc0202dac:	8b89                	andi	a5,a5,2
ffffffffc0202dae:	eb89                	bnez	a5,ffffffffc0202dc0 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202db0:	0000e797          	auipc	a5,0xe
ffffffffc0202db4:	7b87b783          	ld	a5,1976(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202db8:	739c                	ld	a5,32(a5)
ffffffffc0202dba:	4585                	li	a1,1
ffffffffc0202dbc:	9782                	jalr	a5
    if (flag) {
ffffffffc0202dbe:	bfe9                	j	ffffffffc0202d98 <page_remove+0x52>
        intr_disable();
ffffffffc0202dc0:	e42a                	sd	a0,8(sp)
ffffffffc0202dc2:	f2cfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202dc6:	0000e797          	auipc	a5,0xe
ffffffffc0202dca:	7a27b783          	ld	a5,1954(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202dce:	739c                	ld	a5,32(a5)
ffffffffc0202dd0:	6522                	ld	a0,8(sp)
ffffffffc0202dd2:	4585                	li	a1,1
ffffffffc0202dd4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202dd6:	f12fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202dda:	bf7d                	j	ffffffffc0202d98 <page_remove+0x52>
ffffffffc0202ddc:	bd7ff0ef          	jal	ra,ffffffffc02029b2 <pa2page.part.0>

ffffffffc0202de0 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202de0:	7179                	addi	sp,sp,-48
ffffffffc0202de2:	87b2                	mv	a5,a2
ffffffffc0202de4:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202de6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202de8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202dea:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202dec:	ec26                	sd	s1,24(sp)
ffffffffc0202dee:	f406                	sd	ra,40(sp)
ffffffffc0202df0:	e84a                	sd	s2,16(sp)
ffffffffc0202df2:	e44e                	sd	s3,8(sp)
ffffffffc0202df4:	e052                	sd	s4,0(sp)
ffffffffc0202df6:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202df8:	cffff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
    if (ptep == NULL) {
ffffffffc0202dfc:	cd71                	beqz	a0,ffffffffc0202ed8 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202dfe:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202e00:	611c                	ld	a5,0(a0)
ffffffffc0202e02:	89aa                	mv	s3,a0
ffffffffc0202e04:	0016871b          	addiw	a4,a3,1
ffffffffc0202e08:	c018                	sw	a4,0(s0)
ffffffffc0202e0a:	0017f713          	andi	a4,a5,1
ffffffffc0202e0e:	e331                	bnez	a4,ffffffffc0202e52 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e10:	0000e797          	auipc	a5,0xe
ffffffffc0202e14:	7507b783          	ld	a5,1872(a5) # ffffffffc0211560 <pages>
ffffffffc0202e18:	40f407b3          	sub	a5,s0,a5
ffffffffc0202e1c:	878d                	srai	a5,a5,0x3
ffffffffc0202e1e:	00003417          	auipc	s0,0x3
ffffffffc0202e22:	3ca43403          	ld	s0,970(s0) # ffffffffc02061e8 <error_string+0x38>
ffffffffc0202e26:	028787b3          	mul	a5,a5,s0
ffffffffc0202e2a:	00080437          	lui	s0,0x80
ffffffffc0202e2e:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202e30:	07aa                	slli	a5,a5,0xa
ffffffffc0202e32:	8cdd                	or	s1,s1,a5
ffffffffc0202e34:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202e38:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e3c:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202e40:	4501                	li	a0,0
}
ffffffffc0202e42:	70a2                	ld	ra,40(sp)
ffffffffc0202e44:	7402                	ld	s0,32(sp)
ffffffffc0202e46:	64e2                	ld	s1,24(sp)
ffffffffc0202e48:	6942                	ld	s2,16(sp)
ffffffffc0202e4a:	69a2                	ld	s3,8(sp)
ffffffffc0202e4c:	6a02                	ld	s4,0(sp)
ffffffffc0202e4e:	6145                	addi	sp,sp,48
ffffffffc0202e50:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e52:	00279713          	slli	a4,a5,0x2
ffffffffc0202e56:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e58:	0000e797          	auipc	a5,0xe
ffffffffc0202e5c:	7007b783          	ld	a5,1792(a5) # ffffffffc0211558 <npage>
ffffffffc0202e60:	06f77e63          	bgeu	a4,a5,ffffffffc0202edc <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e64:	fff807b7          	lui	a5,0xfff80
ffffffffc0202e68:	973e                	add	a4,a4,a5
ffffffffc0202e6a:	0000ea17          	auipc	s4,0xe
ffffffffc0202e6e:	6f6a0a13          	addi	s4,s4,1782 # ffffffffc0211560 <pages>
ffffffffc0202e72:	000a3783          	ld	a5,0(s4)
ffffffffc0202e76:	00371913          	slli	s2,a4,0x3
ffffffffc0202e7a:	993a                	add	s2,s2,a4
ffffffffc0202e7c:	090e                	slli	s2,s2,0x3
ffffffffc0202e7e:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202e80:	03240063          	beq	s0,s2,ffffffffc0202ea0 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202e84:	00092783          	lw	a5,0(s2)
ffffffffc0202e88:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e8c:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202e90:	cb11                	beqz	a4,ffffffffc0202ea4 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e92:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e96:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e9a:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202e9e:	bfad                	j	ffffffffc0202e18 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202ea0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202ea2:	bf9d                	j	ffffffffc0202e18 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ea4:	100027f3          	csrr	a5,sstatus
ffffffffc0202ea8:	8b89                	andi	a5,a5,2
ffffffffc0202eaa:	eb91                	bnez	a5,ffffffffc0202ebe <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202eac:	0000e797          	auipc	a5,0xe
ffffffffc0202eb0:	6bc7b783          	ld	a5,1724(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202eb4:	739c                	ld	a5,32(a5)
ffffffffc0202eb6:	4585                	li	a1,1
ffffffffc0202eb8:	854a                	mv	a0,s2
ffffffffc0202eba:	9782                	jalr	a5
    if (flag) {
ffffffffc0202ebc:	bfd9                	j	ffffffffc0202e92 <page_insert+0xb2>
        intr_disable();
ffffffffc0202ebe:	e30fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202ec2:	0000e797          	auipc	a5,0xe
ffffffffc0202ec6:	6a67b783          	ld	a5,1702(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0202eca:	739c                	ld	a5,32(a5)
ffffffffc0202ecc:	4585                	li	a1,1
ffffffffc0202ece:	854a                	mv	a0,s2
ffffffffc0202ed0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ed2:	e16fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202ed6:	bf75                	j	ffffffffc0202e92 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0202ed8:	5571                	li	a0,-4
ffffffffc0202eda:	b7a5                	j	ffffffffc0202e42 <page_insert+0x62>
ffffffffc0202edc:	ad7ff0ef          	jal	ra,ffffffffc02029b2 <pa2page.part.0>

ffffffffc0202ee0 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202ee0:	00003797          	auipc	a5,0x3
ffffffffc0202ee4:	96078793          	addi	a5,a5,-1696 # ffffffffc0205840 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202ee8:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202eea:	7159                	addi	sp,sp,-112
ffffffffc0202eec:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202eee:	00003517          	auipc	a0,0x3
ffffffffc0202ef2:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0205988 <default_pmm_manager+0x148>
    pmm_manager = &default_pmm_manager;
ffffffffc0202ef6:	0000eb97          	auipc	s7,0xe
ffffffffc0202efa:	672b8b93          	addi	s7,s7,1650 # ffffffffc0211568 <pmm_manager>
void pmm_init(void) {
ffffffffc0202efe:	f486                	sd	ra,104(sp)
ffffffffc0202f00:	f0a2                	sd	s0,96(sp)
ffffffffc0202f02:	eca6                	sd	s1,88(sp)
ffffffffc0202f04:	e8ca                	sd	s2,80(sp)
ffffffffc0202f06:	e4ce                	sd	s3,72(sp)
ffffffffc0202f08:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202f0a:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202f0e:	e0d2                	sd	s4,64(sp)
ffffffffc0202f10:	fc56                	sd	s5,56(sp)
ffffffffc0202f12:	f062                	sd	s8,32(sp)
ffffffffc0202f14:	ec66                	sd	s9,24(sp)
ffffffffc0202f16:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f18:	9a2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0202f1c:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f20:	4445                	li	s0,17
ffffffffc0202f22:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0202f26:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f28:	0000e997          	auipc	s3,0xe
ffffffffc0202f2c:	64898993          	addi	s3,s3,1608 # ffffffffc0211570 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202f30:	0000e497          	auipc	s1,0xe
ffffffffc0202f34:	62848493          	addi	s1,s1,1576 # ffffffffc0211558 <npage>
    pmm_manager->init();
ffffffffc0202f38:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f3a:	57f5                	li	a5,-3
ffffffffc0202f3c:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f3e:	07e006b7          	lui	a3,0x7e00
ffffffffc0202f42:	01b41613          	slli	a2,s0,0x1b
ffffffffc0202f46:	01591593          	slli	a1,s2,0x15
ffffffffc0202f4a:	00003517          	auipc	a0,0x3
ffffffffc0202f4e:	a5650513          	addi	a0,a0,-1450 # ffffffffc02059a0 <default_pmm_manager+0x160>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f52:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f56:	964fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202f5a:	00003517          	auipc	a0,0x3
ffffffffc0202f5e:	a7650513          	addi	a0,a0,-1418 # ffffffffc02059d0 <default_pmm_manager+0x190>
ffffffffc0202f62:	958fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202f66:	01b41693          	slli	a3,s0,0x1b
ffffffffc0202f6a:	16fd                	addi	a3,a3,-1
ffffffffc0202f6c:	07e005b7          	lui	a1,0x7e00
ffffffffc0202f70:	01591613          	slli	a2,s2,0x15
ffffffffc0202f74:	00003517          	auipc	a0,0x3
ffffffffc0202f78:	a7450513          	addi	a0,a0,-1420 # ffffffffc02059e8 <default_pmm_manager+0x1a8>
ffffffffc0202f7c:	93efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f80:	777d                	lui	a4,0xfffff
ffffffffc0202f82:	0000f797          	auipc	a5,0xf
ffffffffc0202f86:	5f578793          	addi	a5,a5,1525 # ffffffffc0212577 <end+0xfff>
ffffffffc0202f8a:	8ff9                	and	a5,a5,a4
ffffffffc0202f8c:	0000eb17          	auipc	s6,0xe
ffffffffc0202f90:	5d4b0b13          	addi	s6,s6,1492 # ffffffffc0211560 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202f94:	00088737          	lui	a4,0x88
ffffffffc0202f98:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f9a:	00fb3023          	sd	a5,0(s6)
ffffffffc0202f9e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202fa0:	4701                	li	a4,0
ffffffffc0202fa2:	4505                	li	a0,1
ffffffffc0202fa4:	fff805b7          	lui	a1,0xfff80
ffffffffc0202fa8:	a019                	j	ffffffffc0202fae <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0202faa:	000b3783          	ld	a5,0(s6)
ffffffffc0202fae:	97b6                	add	a5,a5,a3
ffffffffc0202fb0:	07a1                	addi	a5,a5,8
ffffffffc0202fb2:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202fb6:	609c                	ld	a5,0(s1)
ffffffffc0202fb8:	0705                	addi	a4,a4,1
ffffffffc0202fba:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0202fbe:	00b78633          	add	a2,a5,a1
ffffffffc0202fc2:	fec764e3          	bltu	a4,a2,ffffffffc0202faa <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202fc6:	000b3503          	ld	a0,0(s6)
ffffffffc0202fca:	00379693          	slli	a3,a5,0x3
ffffffffc0202fce:	96be                	add	a3,a3,a5
ffffffffc0202fd0:	fdc00737          	lui	a4,0xfdc00
ffffffffc0202fd4:	972a                	add	a4,a4,a0
ffffffffc0202fd6:	068e                	slli	a3,a3,0x3
ffffffffc0202fd8:	96ba                	add	a3,a3,a4
ffffffffc0202fda:	c0200737          	lui	a4,0xc0200
ffffffffc0202fde:	64e6e463          	bltu	a3,a4,ffffffffc0203626 <pmm_init+0x746>
ffffffffc0202fe2:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0202fe6:	4645                	li	a2,17
ffffffffc0202fe8:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202fea:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0202fec:	4ec6e263          	bltu	a3,a2,ffffffffc02034d0 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202ff0:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202ff4:	0000e917          	auipc	s2,0xe
ffffffffc0202ff8:	55c90913          	addi	s2,s2,1372 # ffffffffc0211550 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202ffc:	7b9c                	ld	a5,48(a5)
ffffffffc0202ffe:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203000:	00003517          	auipc	a0,0x3
ffffffffc0203004:	a3850513          	addi	a0,a0,-1480 # ffffffffc0205a38 <default_pmm_manager+0x1f8>
ffffffffc0203008:	8b2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020300c:	00006697          	auipc	a3,0x6
ffffffffc0203010:	ff468693          	addi	a3,a3,-12 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0203014:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203018:	c02007b7          	lui	a5,0xc0200
ffffffffc020301c:	62f6e163          	bltu	a3,a5,ffffffffc020363e <pmm_init+0x75e>
ffffffffc0203020:	0009b783          	ld	a5,0(s3)
ffffffffc0203024:	8e9d                	sub	a3,a3,a5
ffffffffc0203026:	0000e797          	auipc	a5,0xe
ffffffffc020302a:	52d7b123          	sd	a3,1314(a5) # ffffffffc0211548 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020302e:	100027f3          	csrr	a5,sstatus
ffffffffc0203032:	8b89                	andi	a5,a5,2
ffffffffc0203034:	4c079763          	bnez	a5,ffffffffc0203502 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203038:	000bb783          	ld	a5,0(s7)
ffffffffc020303c:	779c                	ld	a5,40(a5)
ffffffffc020303e:	9782                	jalr	a5
ffffffffc0203040:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203042:	6098                	ld	a4,0(s1)
ffffffffc0203044:	c80007b7          	lui	a5,0xc8000
ffffffffc0203048:	83b1                	srli	a5,a5,0xc
ffffffffc020304a:	62e7e663          	bltu	a5,a4,ffffffffc0203676 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020304e:	00093503          	ld	a0,0(s2)
ffffffffc0203052:	60050263          	beqz	a0,ffffffffc0203656 <pmm_init+0x776>
ffffffffc0203056:	03451793          	slli	a5,a0,0x34
ffffffffc020305a:	5e079e63          	bnez	a5,ffffffffc0203656 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020305e:	4601                	li	a2,0
ffffffffc0203060:	4581                	li	a1,0
ffffffffc0203062:	c8bff0ef          	jal	ra,ffffffffc0202cec <get_page>
ffffffffc0203066:	66051a63          	bnez	a0,ffffffffc02036da <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020306a:	4505                	li	a0,1
ffffffffc020306c:	97fff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0203070:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203072:	00093503          	ld	a0,0(s2)
ffffffffc0203076:	4681                	li	a3,0
ffffffffc0203078:	4601                	li	a2,0
ffffffffc020307a:	85d2                	mv	a1,s4
ffffffffc020307c:	d65ff0ef          	jal	ra,ffffffffc0202de0 <page_insert>
ffffffffc0203080:	62051d63          	bnez	a0,ffffffffc02036ba <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203084:	00093503          	ld	a0,0(s2)
ffffffffc0203088:	4601                	li	a2,0
ffffffffc020308a:	4581                	li	a1,0
ffffffffc020308c:	a6bff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
ffffffffc0203090:	60050563          	beqz	a0,ffffffffc020369a <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0203094:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203096:	0017f713          	andi	a4,a5,1
ffffffffc020309a:	5e070e63          	beqz	a4,ffffffffc0203696 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020309e:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02030a0:	078a                	slli	a5,a5,0x2
ffffffffc02030a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02030a4:	56c7ff63          	bgeu	a5,a2,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02030a8:	fff80737          	lui	a4,0xfff80
ffffffffc02030ac:	97ba                	add	a5,a5,a4
ffffffffc02030ae:	000b3683          	ld	a3,0(s6)
ffffffffc02030b2:	00379713          	slli	a4,a5,0x3
ffffffffc02030b6:	97ba                	add	a5,a5,a4
ffffffffc02030b8:	078e                	slli	a5,a5,0x3
ffffffffc02030ba:	97b6                	add	a5,a5,a3
ffffffffc02030bc:	14fa18e3          	bne	s4,a5,ffffffffc0203a0c <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc02030c0:	000a2703          	lw	a4,0(s4)
ffffffffc02030c4:	4785                	li	a5,1
ffffffffc02030c6:	16f71fe3          	bne	a4,a5,ffffffffc0203a44 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02030ca:	00093503          	ld	a0,0(s2)
ffffffffc02030ce:	77fd                	lui	a5,0xfffff
ffffffffc02030d0:	6114                	ld	a3,0(a0)
ffffffffc02030d2:	068a                	slli	a3,a3,0x2
ffffffffc02030d4:	8efd                	and	a3,a3,a5
ffffffffc02030d6:	00c6d713          	srli	a4,a3,0xc
ffffffffc02030da:	14c779e3          	bgeu	a4,a2,ffffffffc0203a2c <pmm_init+0xb4c>
ffffffffc02030de:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030e2:	96e2                	add	a3,a3,s8
ffffffffc02030e4:	0006ba83          	ld	s5,0(a3)
ffffffffc02030e8:	0a8a                	slli	s5,s5,0x2
ffffffffc02030ea:	00fafab3          	and	s5,s5,a5
ffffffffc02030ee:	00cad793          	srli	a5,s5,0xc
ffffffffc02030f2:	66c7f463          	bgeu	a5,a2,ffffffffc020375a <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030f6:	4601                	li	a2,0
ffffffffc02030f8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030fa:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030fc:	9fbff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203100:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203102:	63551c63          	bne	a0,s5,ffffffffc020373a <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0203106:	4505                	li	a0,1
ffffffffc0203108:	8e3ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc020310c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020310e:	00093503          	ld	a0,0(s2)
ffffffffc0203112:	46d1                	li	a3,20
ffffffffc0203114:	6605                	lui	a2,0x1
ffffffffc0203116:	85d6                	mv	a1,s5
ffffffffc0203118:	cc9ff0ef          	jal	ra,ffffffffc0202de0 <page_insert>
ffffffffc020311c:	5c051f63          	bnez	a0,ffffffffc02036fa <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203120:	00093503          	ld	a0,0(s2)
ffffffffc0203124:	4601                	li	a2,0
ffffffffc0203126:	6585                	lui	a1,0x1
ffffffffc0203128:	9cfff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
ffffffffc020312c:	12050ce3          	beqz	a0,ffffffffc0203a64 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0203130:	611c                	ld	a5,0(a0)
ffffffffc0203132:	0107f713          	andi	a4,a5,16
ffffffffc0203136:	72070f63          	beqz	a4,ffffffffc0203874 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc020313a:	8b91                	andi	a5,a5,4
ffffffffc020313c:	6e078c63          	beqz	a5,ffffffffc0203834 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203140:	00093503          	ld	a0,0(s2)
ffffffffc0203144:	611c                	ld	a5,0(a0)
ffffffffc0203146:	8bc1                	andi	a5,a5,16
ffffffffc0203148:	6c078663          	beqz	a5,ffffffffc0203814 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc020314c:	000aa703          	lw	a4,0(s5)
ffffffffc0203150:	4785                	li	a5,1
ffffffffc0203152:	5cf71463          	bne	a4,a5,ffffffffc020371a <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203156:	4681                	li	a3,0
ffffffffc0203158:	6605                	lui	a2,0x1
ffffffffc020315a:	85d2                	mv	a1,s4
ffffffffc020315c:	c85ff0ef          	jal	ra,ffffffffc0202de0 <page_insert>
ffffffffc0203160:	66051a63          	bnez	a0,ffffffffc02037d4 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0203164:	000a2703          	lw	a4,0(s4)
ffffffffc0203168:	4789                	li	a5,2
ffffffffc020316a:	64f71563          	bne	a4,a5,ffffffffc02037b4 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc020316e:	000aa783          	lw	a5,0(s5)
ffffffffc0203172:	62079163          	bnez	a5,ffffffffc0203794 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203176:	00093503          	ld	a0,0(s2)
ffffffffc020317a:	4601                	li	a2,0
ffffffffc020317c:	6585                	lui	a1,0x1
ffffffffc020317e:	979ff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
ffffffffc0203182:	5e050963          	beqz	a0,ffffffffc0203774 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0203186:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203188:	00177793          	andi	a5,a4,1
ffffffffc020318c:	50078563          	beqz	a5,ffffffffc0203696 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0203190:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203192:	00271793          	slli	a5,a4,0x2
ffffffffc0203196:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203198:	48d7f563          	bgeu	a5,a3,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020319c:	fff806b7          	lui	a3,0xfff80
ffffffffc02031a0:	97b6                	add	a5,a5,a3
ffffffffc02031a2:	000b3603          	ld	a2,0(s6)
ffffffffc02031a6:	00379693          	slli	a3,a5,0x3
ffffffffc02031aa:	97b6                	add	a5,a5,a3
ffffffffc02031ac:	078e                	slli	a5,a5,0x3
ffffffffc02031ae:	97b2                	add	a5,a5,a2
ffffffffc02031b0:	72fa1263          	bne	s4,a5,ffffffffc02038d4 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc02031b4:	8b41                	andi	a4,a4,16
ffffffffc02031b6:	6e071f63          	bnez	a4,ffffffffc02038b4 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02031ba:	00093503          	ld	a0,0(s2)
ffffffffc02031be:	4581                	li	a1,0
ffffffffc02031c0:	b87ff0ef          	jal	ra,ffffffffc0202d46 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02031c4:	000a2703          	lw	a4,0(s4)
ffffffffc02031c8:	4785                	li	a5,1
ffffffffc02031ca:	6cf71563          	bne	a4,a5,ffffffffc0203894 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc02031ce:	000aa783          	lw	a5,0(s5)
ffffffffc02031d2:	78079d63          	bnez	a5,ffffffffc020396c <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02031d6:	00093503          	ld	a0,0(s2)
ffffffffc02031da:	6585                	lui	a1,0x1
ffffffffc02031dc:	b6bff0ef          	jal	ra,ffffffffc0202d46 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02031e0:	000a2783          	lw	a5,0(s4)
ffffffffc02031e4:	76079463          	bnez	a5,ffffffffc020394c <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc02031e8:	000aa783          	lw	a5,0(s5)
ffffffffc02031ec:	74079063          	bnez	a5,ffffffffc020392c <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02031f0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02031f4:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031f6:	000a3783          	ld	a5,0(s4)
ffffffffc02031fa:	078a                	slli	a5,a5,0x2
ffffffffc02031fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031fe:	42c7f263          	bgeu	a5,a2,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203202:	fff80737          	lui	a4,0xfff80
ffffffffc0203206:	973e                	add	a4,a4,a5
ffffffffc0203208:	00371793          	slli	a5,a4,0x3
ffffffffc020320c:	000b3503          	ld	a0,0(s6)
ffffffffc0203210:	97ba                	add	a5,a5,a4
ffffffffc0203212:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0203214:	00f50733          	add	a4,a0,a5
ffffffffc0203218:	4314                	lw	a3,0(a4)
ffffffffc020321a:	4705                	li	a4,1
ffffffffc020321c:	6ee69863          	bne	a3,a4,ffffffffc020390c <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203220:	4037d693          	srai	a3,a5,0x3
ffffffffc0203224:	00003c97          	auipc	s9,0x3
ffffffffc0203228:	fc4cbc83          	ld	s9,-60(s9) # ffffffffc02061e8 <error_string+0x38>
ffffffffc020322c:	039686b3          	mul	a3,a3,s9
ffffffffc0203230:	000805b7          	lui	a1,0x80
ffffffffc0203234:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203236:	00c69713          	slli	a4,a3,0xc
ffffffffc020323a:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020323c:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020323e:	6ac77b63          	bgeu	a4,a2,ffffffffc02038f4 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203242:	0009b703          	ld	a4,0(s3)
ffffffffc0203246:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0203248:	629c                	ld	a5,0(a3)
ffffffffc020324a:	078a                	slli	a5,a5,0x2
ffffffffc020324c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020324e:	3cc7fa63          	bgeu	a5,a2,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203252:	8f8d                	sub	a5,a5,a1
ffffffffc0203254:	00379713          	slli	a4,a5,0x3
ffffffffc0203258:	97ba                	add	a5,a5,a4
ffffffffc020325a:	078e                	slli	a5,a5,0x3
ffffffffc020325c:	953e                	add	a0,a0,a5
ffffffffc020325e:	100027f3          	csrr	a5,sstatus
ffffffffc0203262:	8b89                	andi	a5,a5,2
ffffffffc0203264:	2e079963          	bnez	a5,ffffffffc0203556 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203268:	000bb783          	ld	a5,0(s7)
ffffffffc020326c:	4585                	li	a1,1
ffffffffc020326e:	739c                	ld	a5,32(a5)
ffffffffc0203270:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203272:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203276:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203278:	078a                	slli	a5,a5,0x2
ffffffffc020327a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020327c:	3ae7f363          	bgeu	a5,a4,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203280:	fff80737          	lui	a4,0xfff80
ffffffffc0203284:	97ba                	add	a5,a5,a4
ffffffffc0203286:	000b3503          	ld	a0,0(s6)
ffffffffc020328a:	00379713          	slli	a4,a5,0x3
ffffffffc020328e:	97ba                	add	a5,a5,a4
ffffffffc0203290:	078e                	slli	a5,a5,0x3
ffffffffc0203292:	953e                	add	a0,a0,a5
ffffffffc0203294:	100027f3          	csrr	a5,sstatus
ffffffffc0203298:	8b89                	andi	a5,a5,2
ffffffffc020329a:	2a079263          	bnez	a5,ffffffffc020353e <pmm_init+0x65e>
ffffffffc020329e:	000bb783          	ld	a5,0(s7)
ffffffffc02032a2:	4585                	li	a1,1
ffffffffc02032a4:	739c                	ld	a5,32(a5)
ffffffffc02032a6:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02032a8:	00093783          	ld	a5,0(s2)
ffffffffc02032ac:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda88>
ffffffffc02032b0:	100027f3          	csrr	a5,sstatus
ffffffffc02032b4:	8b89                	andi	a5,a5,2
ffffffffc02032b6:	26079a63          	bnez	a5,ffffffffc020352a <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02032ba:	000bb783          	ld	a5,0(s7)
ffffffffc02032be:	779c                	ld	a5,40(a5)
ffffffffc02032c0:	9782                	jalr	a5
ffffffffc02032c2:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02032c4:	73441463          	bne	s0,s4,ffffffffc02039ec <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02032c8:	00003517          	auipc	a0,0x3
ffffffffc02032cc:	a5850513          	addi	a0,a0,-1448 # ffffffffc0205d20 <default_pmm_manager+0x4e0>
ffffffffc02032d0:	debfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02032d4:	100027f3          	csrr	a5,sstatus
ffffffffc02032d8:	8b89                	andi	a5,a5,2
ffffffffc02032da:	22079e63          	bnez	a5,ffffffffc0203516 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02032de:	000bb783          	ld	a5,0(s7)
ffffffffc02032e2:	779c                	ld	a5,40(a5)
ffffffffc02032e4:	9782                	jalr	a5
ffffffffc02032e6:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032e8:	6098                	ld	a4,0(s1)
ffffffffc02032ea:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02032ee:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032f0:	00c71793          	slli	a5,a4,0xc
ffffffffc02032f4:	6a05                	lui	s4,0x1
ffffffffc02032f6:	02f47c63          	bgeu	s0,a5,ffffffffc020332e <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02032fa:	00c45793          	srli	a5,s0,0xc
ffffffffc02032fe:	00093503          	ld	a0,0(s2)
ffffffffc0203302:	30e7f363          	bgeu	a5,a4,ffffffffc0203608 <pmm_init+0x728>
ffffffffc0203306:	0009b583          	ld	a1,0(s3)
ffffffffc020330a:	4601                	li	a2,0
ffffffffc020330c:	95a2                	add	a1,a1,s0
ffffffffc020330e:	fe8ff0ef          	jal	ra,ffffffffc0202af6 <get_pte>
ffffffffc0203312:	2c050b63          	beqz	a0,ffffffffc02035e8 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203316:	611c                	ld	a5,0(a0)
ffffffffc0203318:	078a                	slli	a5,a5,0x2
ffffffffc020331a:	0157f7b3          	and	a5,a5,s5
ffffffffc020331e:	2a879563          	bne	a5,s0,ffffffffc02035c8 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203322:	6098                	ld	a4,0(s1)
ffffffffc0203324:	9452                	add	s0,s0,s4
ffffffffc0203326:	00c71793          	slli	a5,a4,0xc
ffffffffc020332a:	fcf468e3          	bltu	s0,a5,ffffffffc02032fa <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020332e:	00093783          	ld	a5,0(s2)
ffffffffc0203332:	639c                	ld	a5,0(a5)
ffffffffc0203334:	68079c63          	bnez	a5,ffffffffc02039cc <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0203338:	4505                	li	a0,1
ffffffffc020333a:	eb0ff0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc020333e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203340:	00093503          	ld	a0,0(s2)
ffffffffc0203344:	4699                	li	a3,6
ffffffffc0203346:	10000613          	li	a2,256
ffffffffc020334a:	85d6                	mv	a1,s5
ffffffffc020334c:	a95ff0ef          	jal	ra,ffffffffc0202de0 <page_insert>
ffffffffc0203350:	64051e63          	bnez	a0,ffffffffc02039ac <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0203354:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda88>
ffffffffc0203358:	4785                	li	a5,1
ffffffffc020335a:	62f71963          	bne	a4,a5,ffffffffc020398c <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020335e:	00093503          	ld	a0,0(s2)
ffffffffc0203362:	6405                	lui	s0,0x1
ffffffffc0203364:	4699                	li	a3,6
ffffffffc0203366:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc020336a:	85d6                	mv	a1,s5
ffffffffc020336c:	a75ff0ef          	jal	ra,ffffffffc0202de0 <page_insert>
ffffffffc0203370:	48051263          	bnez	a0,ffffffffc02037f4 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0203374:	000aa703          	lw	a4,0(s5)
ffffffffc0203378:	4789                	li	a5,2
ffffffffc020337a:	74f71563          	bne	a4,a5,ffffffffc0203ac4 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020337e:	00003597          	auipc	a1,0x3
ffffffffc0203382:	ada58593          	addi	a1,a1,-1318 # ffffffffc0205e58 <default_pmm_manager+0x618>
ffffffffc0203386:	10000513          	li	a0,256
ffffffffc020338a:	35d000ef          	jal	ra,ffffffffc0203ee6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020338e:	10040593          	addi	a1,s0,256
ffffffffc0203392:	10000513          	li	a0,256
ffffffffc0203396:	363000ef          	jal	ra,ffffffffc0203ef8 <strcmp>
ffffffffc020339a:	70051563          	bnez	a0,ffffffffc0203aa4 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020339e:	000b3683          	ld	a3,0(s6)
ffffffffc02033a2:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033a6:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033a8:	40da86b3          	sub	a3,s5,a3
ffffffffc02033ac:	868d                	srai	a3,a3,0x3
ffffffffc02033ae:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033b2:	609c                	ld	a5,0(s1)
ffffffffc02033b4:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033b6:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033b8:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02033bc:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033be:	52f77b63          	bgeu	a4,a5,ffffffffc02038f4 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033c2:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033c6:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033ca:	96be                	add	a3,a3,a5
ffffffffc02033cc:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb88>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033d0:	2e1000ef          	jal	ra,ffffffffc0203eb0 <strlen>
ffffffffc02033d4:	6a051863          	bnez	a0,ffffffffc0203a84 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02033d8:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02033dc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033de:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02033e2:	078a                	slli	a5,a5,0x2
ffffffffc02033e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033e6:	22e7fe63          	bgeu	a5,a4,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033ea:	41a787b3          	sub	a5,a5,s10
ffffffffc02033ee:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033f2:	96be                	add	a3,a3,a5
ffffffffc02033f4:	03968cb3          	mul	s9,a3,s9
ffffffffc02033f8:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033fc:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02033fe:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203400:	4ee47a63          	bgeu	s0,a4,ffffffffc02038f4 <pmm_init+0xa14>
ffffffffc0203404:	0009b403          	ld	s0,0(s3)
ffffffffc0203408:	9436                	add	s0,s0,a3
ffffffffc020340a:	100027f3          	csrr	a5,sstatus
ffffffffc020340e:	8b89                	andi	a5,a5,2
ffffffffc0203410:	1a079163          	bnez	a5,ffffffffc02035b2 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203414:	000bb783          	ld	a5,0(s7)
ffffffffc0203418:	4585                	li	a1,1
ffffffffc020341a:	8556                	mv	a0,s5
ffffffffc020341c:	739c                	ld	a5,32(a5)
ffffffffc020341e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203420:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203422:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203424:	078a                	slli	a5,a5,0x2
ffffffffc0203426:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203428:	1ee7fd63          	bgeu	a5,a4,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020342c:	fff80737          	lui	a4,0xfff80
ffffffffc0203430:	97ba                	add	a5,a5,a4
ffffffffc0203432:	000b3503          	ld	a0,0(s6)
ffffffffc0203436:	00379713          	slli	a4,a5,0x3
ffffffffc020343a:	97ba                	add	a5,a5,a4
ffffffffc020343c:	078e                	slli	a5,a5,0x3
ffffffffc020343e:	953e                	add	a0,a0,a5
ffffffffc0203440:	100027f3          	csrr	a5,sstatus
ffffffffc0203444:	8b89                	andi	a5,a5,2
ffffffffc0203446:	14079a63          	bnez	a5,ffffffffc020359a <pmm_init+0x6ba>
ffffffffc020344a:	000bb783          	ld	a5,0(s7)
ffffffffc020344e:	4585                	li	a1,1
ffffffffc0203450:	739c                	ld	a5,32(a5)
ffffffffc0203452:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203454:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203458:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020345a:	078a                	slli	a5,a5,0x2
ffffffffc020345c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020345e:	1ce7f263          	bgeu	a5,a4,ffffffffc0203622 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203462:	fff80737          	lui	a4,0xfff80
ffffffffc0203466:	97ba                	add	a5,a5,a4
ffffffffc0203468:	000b3503          	ld	a0,0(s6)
ffffffffc020346c:	00379713          	slli	a4,a5,0x3
ffffffffc0203470:	97ba                	add	a5,a5,a4
ffffffffc0203472:	078e                	slli	a5,a5,0x3
ffffffffc0203474:	953e                	add	a0,a0,a5
ffffffffc0203476:	100027f3          	csrr	a5,sstatus
ffffffffc020347a:	8b89                	andi	a5,a5,2
ffffffffc020347c:	10079363          	bnez	a5,ffffffffc0203582 <pmm_init+0x6a2>
ffffffffc0203480:	000bb783          	ld	a5,0(s7)
ffffffffc0203484:	4585                	li	a1,1
ffffffffc0203486:	739c                	ld	a5,32(a5)
ffffffffc0203488:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020348a:	00093783          	ld	a5,0(s2)
ffffffffc020348e:	0007b023          	sd	zero,0(a5)
ffffffffc0203492:	100027f3          	csrr	a5,sstatus
ffffffffc0203496:	8b89                	andi	a5,a5,2
ffffffffc0203498:	0c079b63          	bnez	a5,ffffffffc020356e <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020349c:	000bb783          	ld	a5,0(s7)
ffffffffc02034a0:	779c                	ld	a5,40(a5)
ffffffffc02034a2:	9782                	jalr	a5
ffffffffc02034a4:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02034a6:	3a8c1763          	bne	s8,s0,ffffffffc0203854 <pmm_init+0x974>
}
ffffffffc02034aa:	7406                	ld	s0,96(sp)
ffffffffc02034ac:	70a6                	ld	ra,104(sp)
ffffffffc02034ae:	64e6                	ld	s1,88(sp)
ffffffffc02034b0:	6946                	ld	s2,80(sp)
ffffffffc02034b2:	69a6                	ld	s3,72(sp)
ffffffffc02034b4:	6a06                	ld	s4,64(sp)
ffffffffc02034b6:	7ae2                	ld	s5,56(sp)
ffffffffc02034b8:	7b42                	ld	s6,48(sp)
ffffffffc02034ba:	7ba2                	ld	s7,40(sp)
ffffffffc02034bc:	7c02                	ld	s8,32(sp)
ffffffffc02034be:	6ce2                	ld	s9,24(sp)
ffffffffc02034c0:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02034c2:	00003517          	auipc	a0,0x3
ffffffffc02034c6:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0205ed0 <default_pmm_manager+0x690>
}
ffffffffc02034ca:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02034cc:	beffc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02034d0:	6705                	lui	a4,0x1
ffffffffc02034d2:	177d                	addi	a4,a4,-1
ffffffffc02034d4:	96ba                	add	a3,a3,a4
ffffffffc02034d6:	777d                	lui	a4,0xfffff
ffffffffc02034d8:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02034da:	00c75693          	srli	a3,a4,0xc
ffffffffc02034de:	14f6f263          	bgeu	a3,a5,ffffffffc0203622 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02034e2:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02034e6:	95b6                	add	a1,a1,a3
ffffffffc02034e8:	00359793          	slli	a5,a1,0x3
ffffffffc02034ec:	97ae                	add	a5,a5,a1
ffffffffc02034ee:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02034f2:	40e60733          	sub	a4,a2,a4
ffffffffc02034f6:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02034f8:	00c75593          	srli	a1,a4,0xc
ffffffffc02034fc:	953e                	add	a0,a0,a5
ffffffffc02034fe:	9682                	jalr	a3
}
ffffffffc0203500:	bcc5                	j	ffffffffc0202ff0 <pmm_init+0x110>
        intr_disable();
ffffffffc0203502:	fedfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203506:	000bb783          	ld	a5,0(s7)
ffffffffc020350a:	779c                	ld	a5,40(a5)
ffffffffc020350c:	9782                	jalr	a5
ffffffffc020350e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203510:	fd9fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203514:	b63d                	j	ffffffffc0203042 <pmm_init+0x162>
        intr_disable();
ffffffffc0203516:	fd9fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020351a:	000bb783          	ld	a5,0(s7)
ffffffffc020351e:	779c                	ld	a5,40(a5)
ffffffffc0203520:	9782                	jalr	a5
ffffffffc0203522:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203524:	fc5fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203528:	b3c1                	j	ffffffffc02032e8 <pmm_init+0x408>
        intr_disable();
ffffffffc020352a:	fc5fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020352e:	000bb783          	ld	a5,0(s7)
ffffffffc0203532:	779c                	ld	a5,40(a5)
ffffffffc0203534:	9782                	jalr	a5
ffffffffc0203536:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203538:	fb1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020353c:	b361                	j	ffffffffc02032c4 <pmm_init+0x3e4>
ffffffffc020353e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203540:	faffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203544:	000bb783          	ld	a5,0(s7)
ffffffffc0203548:	6522                	ld	a0,8(sp)
ffffffffc020354a:	4585                	li	a1,1
ffffffffc020354c:	739c                	ld	a5,32(a5)
ffffffffc020354e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203550:	f99fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203554:	bb91                	j	ffffffffc02032a8 <pmm_init+0x3c8>
ffffffffc0203556:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203558:	f97fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020355c:	000bb783          	ld	a5,0(s7)
ffffffffc0203560:	6522                	ld	a0,8(sp)
ffffffffc0203562:	4585                	li	a1,1
ffffffffc0203564:	739c                	ld	a5,32(a5)
ffffffffc0203566:	9782                	jalr	a5
        intr_enable();
ffffffffc0203568:	f81fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020356c:	b319                	j	ffffffffc0203272 <pmm_init+0x392>
        intr_disable();
ffffffffc020356e:	f81fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203572:	000bb783          	ld	a5,0(s7)
ffffffffc0203576:	779c                	ld	a5,40(a5)
ffffffffc0203578:	9782                	jalr	a5
ffffffffc020357a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020357c:	f6dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203580:	b71d                	j	ffffffffc02034a6 <pmm_init+0x5c6>
ffffffffc0203582:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203584:	f6bfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203588:	000bb783          	ld	a5,0(s7)
ffffffffc020358c:	6522                	ld	a0,8(sp)
ffffffffc020358e:	4585                	li	a1,1
ffffffffc0203590:	739c                	ld	a5,32(a5)
ffffffffc0203592:	9782                	jalr	a5
        intr_enable();
ffffffffc0203594:	f55fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203598:	bdcd                	j	ffffffffc020348a <pmm_init+0x5aa>
ffffffffc020359a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020359c:	f53fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035a0:	000bb783          	ld	a5,0(s7)
ffffffffc02035a4:	6522                	ld	a0,8(sp)
ffffffffc02035a6:	4585                	li	a1,1
ffffffffc02035a8:	739c                	ld	a5,32(a5)
ffffffffc02035aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02035ac:	f3dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035b0:	b555                	j	ffffffffc0203454 <pmm_init+0x574>
        intr_disable();
ffffffffc02035b2:	f3dfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035b6:	000bb783          	ld	a5,0(s7)
ffffffffc02035ba:	4585                	li	a1,1
ffffffffc02035bc:	8556                	mv	a0,s5
ffffffffc02035be:	739c                	ld	a5,32(a5)
ffffffffc02035c0:	9782                	jalr	a5
        intr_enable();
ffffffffc02035c2:	f27fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035c6:	bda9                	j	ffffffffc0203420 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02035c8:	00002697          	auipc	a3,0x2
ffffffffc02035cc:	7b868693          	addi	a3,a3,1976 # ffffffffc0205d80 <default_pmm_manager+0x540>
ffffffffc02035d0:	00001617          	auipc	a2,0x1
ffffffffc02035d4:	7c860613          	addi	a2,a2,1992 # ffffffffc0204d98 <commands+0x728>
ffffffffc02035d8:	1ce00593          	li	a1,462
ffffffffc02035dc:	00002517          	auipc	a0,0x2
ffffffffc02035e0:	39c50513          	addi	a0,a0,924 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02035e4:	b1ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02035e8:	00002697          	auipc	a3,0x2
ffffffffc02035ec:	75868693          	addi	a3,a3,1880 # ffffffffc0205d40 <default_pmm_manager+0x500>
ffffffffc02035f0:	00001617          	auipc	a2,0x1
ffffffffc02035f4:	7a860613          	addi	a2,a2,1960 # ffffffffc0204d98 <commands+0x728>
ffffffffc02035f8:	1cd00593          	li	a1,461
ffffffffc02035fc:	00002517          	auipc	a0,0x2
ffffffffc0203600:	37c50513          	addi	a0,a0,892 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203604:	afffc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203608:	86a2                	mv	a3,s0
ffffffffc020360a:	00002617          	auipc	a2,0x2
ffffffffc020360e:	34660613          	addi	a2,a2,838 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0203612:	1cd00593          	li	a1,461
ffffffffc0203616:	00002517          	auipc	a0,0x2
ffffffffc020361a:	36250513          	addi	a0,a0,866 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc020361e:	ae5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203622:	b90ff0ef          	jal	ra,ffffffffc02029b2 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203626:	00002617          	auipc	a2,0x2
ffffffffc020362a:	3ea60613          	addi	a2,a2,1002 # ffffffffc0205a10 <default_pmm_manager+0x1d0>
ffffffffc020362e:	07700593          	li	a1,119
ffffffffc0203632:	00002517          	auipc	a0,0x2
ffffffffc0203636:	34650513          	addi	a0,a0,838 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc020363a:	ac9fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020363e:	00002617          	auipc	a2,0x2
ffffffffc0203642:	3d260613          	addi	a2,a2,978 # ffffffffc0205a10 <default_pmm_manager+0x1d0>
ffffffffc0203646:	0bd00593          	li	a1,189
ffffffffc020364a:	00002517          	auipc	a0,0x2
ffffffffc020364e:	32e50513          	addi	a0,a0,814 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203652:	ab1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203656:	00002697          	auipc	a3,0x2
ffffffffc020365a:	42268693          	addi	a3,a3,1058 # ffffffffc0205a78 <default_pmm_manager+0x238>
ffffffffc020365e:	00001617          	auipc	a2,0x1
ffffffffc0203662:	73a60613          	addi	a2,a2,1850 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203666:	19300593          	li	a1,403
ffffffffc020366a:	00002517          	auipc	a0,0x2
ffffffffc020366e:	30e50513          	addi	a0,a0,782 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203672:	a91fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203676:	00002697          	auipc	a3,0x2
ffffffffc020367a:	3e268693          	addi	a3,a3,994 # ffffffffc0205a58 <default_pmm_manager+0x218>
ffffffffc020367e:	00001617          	auipc	a2,0x1
ffffffffc0203682:	71a60613          	addi	a2,a2,1818 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203686:	19200593          	li	a1,402
ffffffffc020368a:	00002517          	auipc	a0,0x2
ffffffffc020368e:	2ee50513          	addi	a0,a0,750 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203692:	a71fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203696:	b38ff0ef          	jal	ra,ffffffffc02029ce <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020369a:	00002697          	auipc	a3,0x2
ffffffffc020369e:	46e68693          	addi	a3,a3,1134 # ffffffffc0205b08 <default_pmm_manager+0x2c8>
ffffffffc02036a2:	00001617          	auipc	a2,0x1
ffffffffc02036a6:	6f660613          	addi	a2,a2,1782 # ffffffffc0204d98 <commands+0x728>
ffffffffc02036aa:	19a00593          	li	a1,410
ffffffffc02036ae:	00002517          	auipc	a0,0x2
ffffffffc02036b2:	2ca50513          	addi	a0,a0,714 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02036b6:	a4dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02036ba:	00002697          	auipc	a3,0x2
ffffffffc02036be:	41e68693          	addi	a3,a3,1054 # ffffffffc0205ad8 <default_pmm_manager+0x298>
ffffffffc02036c2:	00001617          	auipc	a2,0x1
ffffffffc02036c6:	6d660613          	addi	a2,a2,1750 # ffffffffc0204d98 <commands+0x728>
ffffffffc02036ca:	19800593          	li	a1,408
ffffffffc02036ce:	00002517          	auipc	a0,0x2
ffffffffc02036d2:	2aa50513          	addi	a0,a0,682 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02036d6:	a2dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02036da:	00002697          	auipc	a3,0x2
ffffffffc02036de:	3d668693          	addi	a3,a3,982 # ffffffffc0205ab0 <default_pmm_manager+0x270>
ffffffffc02036e2:	00001617          	auipc	a2,0x1
ffffffffc02036e6:	6b660613          	addi	a2,a2,1718 # ffffffffc0204d98 <commands+0x728>
ffffffffc02036ea:	19400593          	li	a1,404
ffffffffc02036ee:	00002517          	auipc	a0,0x2
ffffffffc02036f2:	28a50513          	addi	a0,a0,650 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02036f6:	a0dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02036fa:	00002697          	auipc	a3,0x2
ffffffffc02036fe:	49668693          	addi	a3,a3,1174 # ffffffffc0205b90 <default_pmm_manager+0x350>
ffffffffc0203702:	00001617          	auipc	a2,0x1
ffffffffc0203706:	69660613          	addi	a2,a2,1686 # ffffffffc0204d98 <commands+0x728>
ffffffffc020370a:	1a300593          	li	a1,419
ffffffffc020370e:	00002517          	auipc	a0,0x2
ffffffffc0203712:	26a50513          	addi	a0,a0,618 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203716:	9edfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020371a:	00002697          	auipc	a3,0x2
ffffffffc020371e:	51668693          	addi	a3,a3,1302 # ffffffffc0205c30 <default_pmm_manager+0x3f0>
ffffffffc0203722:	00001617          	auipc	a2,0x1
ffffffffc0203726:	67660613          	addi	a2,a2,1654 # ffffffffc0204d98 <commands+0x728>
ffffffffc020372a:	1a800593          	li	a1,424
ffffffffc020372e:	00002517          	auipc	a0,0x2
ffffffffc0203732:	24a50513          	addi	a0,a0,586 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203736:	9cdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020373a:	00002697          	auipc	a3,0x2
ffffffffc020373e:	42e68693          	addi	a3,a3,1070 # ffffffffc0205b68 <default_pmm_manager+0x328>
ffffffffc0203742:	00001617          	auipc	a2,0x1
ffffffffc0203746:	65660613          	addi	a2,a2,1622 # ffffffffc0204d98 <commands+0x728>
ffffffffc020374a:	1a000593          	li	a1,416
ffffffffc020374e:	00002517          	auipc	a0,0x2
ffffffffc0203752:	22a50513          	addi	a0,a0,554 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203756:	9adfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020375a:	86d6                	mv	a3,s5
ffffffffc020375c:	00002617          	auipc	a2,0x2
ffffffffc0203760:	1f460613          	addi	a2,a2,500 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0203764:	19f00593          	li	a1,415
ffffffffc0203768:	00002517          	auipc	a0,0x2
ffffffffc020376c:	21050513          	addi	a0,a0,528 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203770:	993fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203774:	00002697          	auipc	a3,0x2
ffffffffc0203778:	45468693          	addi	a3,a3,1108 # ffffffffc0205bc8 <default_pmm_manager+0x388>
ffffffffc020377c:	00001617          	auipc	a2,0x1
ffffffffc0203780:	61c60613          	addi	a2,a2,1564 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203784:	1ad00593          	li	a1,429
ffffffffc0203788:	00002517          	auipc	a0,0x2
ffffffffc020378c:	1f050513          	addi	a0,a0,496 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203790:	973fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203794:	00002697          	auipc	a3,0x2
ffffffffc0203798:	4fc68693          	addi	a3,a3,1276 # ffffffffc0205c90 <default_pmm_manager+0x450>
ffffffffc020379c:	00001617          	auipc	a2,0x1
ffffffffc02037a0:	5fc60613          	addi	a2,a2,1532 # ffffffffc0204d98 <commands+0x728>
ffffffffc02037a4:	1ac00593          	li	a1,428
ffffffffc02037a8:	00002517          	auipc	a0,0x2
ffffffffc02037ac:	1d050513          	addi	a0,a0,464 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02037b0:	953fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02037b4:	00002697          	auipc	a3,0x2
ffffffffc02037b8:	4c468693          	addi	a3,a3,1220 # ffffffffc0205c78 <default_pmm_manager+0x438>
ffffffffc02037bc:	00001617          	auipc	a2,0x1
ffffffffc02037c0:	5dc60613          	addi	a2,a2,1500 # ffffffffc0204d98 <commands+0x728>
ffffffffc02037c4:	1ab00593          	li	a1,427
ffffffffc02037c8:	00002517          	auipc	a0,0x2
ffffffffc02037cc:	1b050513          	addi	a0,a0,432 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02037d0:	933fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02037d4:	00002697          	auipc	a3,0x2
ffffffffc02037d8:	47468693          	addi	a3,a3,1140 # ffffffffc0205c48 <default_pmm_manager+0x408>
ffffffffc02037dc:	00001617          	auipc	a2,0x1
ffffffffc02037e0:	5bc60613          	addi	a2,a2,1468 # ffffffffc0204d98 <commands+0x728>
ffffffffc02037e4:	1aa00593          	li	a1,426
ffffffffc02037e8:	00002517          	auipc	a0,0x2
ffffffffc02037ec:	19050513          	addi	a0,a0,400 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02037f0:	913fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02037f4:	00002697          	auipc	a3,0x2
ffffffffc02037f8:	60c68693          	addi	a3,a3,1548 # ffffffffc0205e00 <default_pmm_manager+0x5c0>
ffffffffc02037fc:	00001617          	auipc	a2,0x1
ffffffffc0203800:	59c60613          	addi	a2,a2,1436 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203804:	1d800593          	li	a1,472
ffffffffc0203808:	00002517          	auipc	a0,0x2
ffffffffc020380c:	17050513          	addi	a0,a0,368 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203810:	8f3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203814:	00002697          	auipc	a3,0x2
ffffffffc0203818:	40468693          	addi	a3,a3,1028 # ffffffffc0205c18 <default_pmm_manager+0x3d8>
ffffffffc020381c:	00001617          	auipc	a2,0x1
ffffffffc0203820:	57c60613          	addi	a2,a2,1404 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203824:	1a700593          	li	a1,423
ffffffffc0203828:	00002517          	auipc	a0,0x2
ffffffffc020382c:	15050513          	addi	a0,a0,336 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203830:	8d3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203834:	00002697          	auipc	a3,0x2
ffffffffc0203838:	3d468693          	addi	a3,a3,980 # ffffffffc0205c08 <default_pmm_manager+0x3c8>
ffffffffc020383c:	00001617          	auipc	a2,0x1
ffffffffc0203840:	55c60613          	addi	a2,a2,1372 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203844:	1a600593          	li	a1,422
ffffffffc0203848:	00002517          	auipc	a0,0x2
ffffffffc020384c:	13050513          	addi	a0,a0,304 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203850:	8b3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203854:	00002697          	auipc	a3,0x2
ffffffffc0203858:	4ac68693          	addi	a3,a3,1196 # ffffffffc0205d00 <default_pmm_manager+0x4c0>
ffffffffc020385c:	00001617          	auipc	a2,0x1
ffffffffc0203860:	53c60613          	addi	a2,a2,1340 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203864:	1e800593          	li	a1,488
ffffffffc0203868:	00002517          	auipc	a0,0x2
ffffffffc020386c:	11050513          	addi	a0,a0,272 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203870:	893fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203874:	00002697          	auipc	a3,0x2
ffffffffc0203878:	38468693          	addi	a3,a3,900 # ffffffffc0205bf8 <default_pmm_manager+0x3b8>
ffffffffc020387c:	00001617          	auipc	a2,0x1
ffffffffc0203880:	51c60613          	addi	a2,a2,1308 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203884:	1a500593          	li	a1,421
ffffffffc0203888:	00002517          	auipc	a0,0x2
ffffffffc020388c:	0f050513          	addi	a0,a0,240 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203890:	873fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203894:	00002697          	auipc	a3,0x2
ffffffffc0203898:	2bc68693          	addi	a3,a3,700 # ffffffffc0205b50 <default_pmm_manager+0x310>
ffffffffc020389c:	00001617          	auipc	a2,0x1
ffffffffc02038a0:	4fc60613          	addi	a2,a2,1276 # ffffffffc0204d98 <commands+0x728>
ffffffffc02038a4:	1b200593          	li	a1,434
ffffffffc02038a8:	00002517          	auipc	a0,0x2
ffffffffc02038ac:	0d050513          	addi	a0,a0,208 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02038b0:	853fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02038b4:	00002697          	auipc	a3,0x2
ffffffffc02038b8:	3f468693          	addi	a3,a3,1012 # ffffffffc0205ca8 <default_pmm_manager+0x468>
ffffffffc02038bc:	00001617          	auipc	a2,0x1
ffffffffc02038c0:	4dc60613          	addi	a2,a2,1244 # ffffffffc0204d98 <commands+0x728>
ffffffffc02038c4:	1af00593          	li	a1,431
ffffffffc02038c8:	00002517          	auipc	a0,0x2
ffffffffc02038cc:	0b050513          	addi	a0,a0,176 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02038d0:	833fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02038d4:	00002697          	auipc	a3,0x2
ffffffffc02038d8:	26468693          	addi	a3,a3,612 # ffffffffc0205b38 <default_pmm_manager+0x2f8>
ffffffffc02038dc:	00001617          	auipc	a2,0x1
ffffffffc02038e0:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204d98 <commands+0x728>
ffffffffc02038e4:	1ae00593          	li	a1,430
ffffffffc02038e8:	00002517          	auipc	a0,0x2
ffffffffc02038ec:	09050513          	addi	a0,a0,144 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02038f0:	813fc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02038f4:	00002617          	auipc	a2,0x2
ffffffffc02038f8:	05c60613          	addi	a2,a2,92 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc02038fc:	06a00593          	li	a1,106
ffffffffc0203900:	00001517          	auipc	a0,0x1
ffffffffc0203904:	70850513          	addi	a0,a0,1800 # ffffffffc0205008 <commands+0x998>
ffffffffc0203908:	ffafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020390c:	00002697          	auipc	a3,0x2
ffffffffc0203910:	3cc68693          	addi	a3,a3,972 # ffffffffc0205cd8 <default_pmm_manager+0x498>
ffffffffc0203914:	00001617          	auipc	a2,0x1
ffffffffc0203918:	48460613          	addi	a2,a2,1156 # ffffffffc0204d98 <commands+0x728>
ffffffffc020391c:	1b900593          	li	a1,441
ffffffffc0203920:	00002517          	auipc	a0,0x2
ffffffffc0203924:	05850513          	addi	a0,a0,88 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203928:	fdafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020392c:	00002697          	auipc	a3,0x2
ffffffffc0203930:	36468693          	addi	a3,a3,868 # ffffffffc0205c90 <default_pmm_manager+0x450>
ffffffffc0203934:	00001617          	auipc	a2,0x1
ffffffffc0203938:	46460613          	addi	a2,a2,1124 # ffffffffc0204d98 <commands+0x728>
ffffffffc020393c:	1b700593          	li	a1,439
ffffffffc0203940:	00002517          	auipc	a0,0x2
ffffffffc0203944:	03850513          	addi	a0,a0,56 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203948:	fbafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020394c:	00002697          	auipc	a3,0x2
ffffffffc0203950:	37468693          	addi	a3,a3,884 # ffffffffc0205cc0 <default_pmm_manager+0x480>
ffffffffc0203954:	00001617          	auipc	a2,0x1
ffffffffc0203958:	44460613          	addi	a2,a2,1092 # ffffffffc0204d98 <commands+0x728>
ffffffffc020395c:	1b600593          	li	a1,438
ffffffffc0203960:	00002517          	auipc	a0,0x2
ffffffffc0203964:	01850513          	addi	a0,a0,24 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203968:	f9afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020396c:	00002697          	auipc	a3,0x2
ffffffffc0203970:	32468693          	addi	a3,a3,804 # ffffffffc0205c90 <default_pmm_manager+0x450>
ffffffffc0203974:	00001617          	auipc	a2,0x1
ffffffffc0203978:	42460613          	addi	a2,a2,1060 # ffffffffc0204d98 <commands+0x728>
ffffffffc020397c:	1b300593          	li	a1,435
ffffffffc0203980:	00002517          	auipc	a0,0x2
ffffffffc0203984:	ff850513          	addi	a0,a0,-8 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203988:	f7afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020398c:	00002697          	auipc	a3,0x2
ffffffffc0203990:	45c68693          	addi	a3,a3,1116 # ffffffffc0205de8 <default_pmm_manager+0x5a8>
ffffffffc0203994:	00001617          	auipc	a2,0x1
ffffffffc0203998:	40460613          	addi	a2,a2,1028 # ffffffffc0204d98 <commands+0x728>
ffffffffc020399c:	1d700593          	li	a1,471
ffffffffc02039a0:	00002517          	auipc	a0,0x2
ffffffffc02039a4:	fd850513          	addi	a0,a0,-40 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02039a8:	f5afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02039ac:	00002697          	auipc	a3,0x2
ffffffffc02039b0:	40468693          	addi	a3,a3,1028 # ffffffffc0205db0 <default_pmm_manager+0x570>
ffffffffc02039b4:	00001617          	auipc	a2,0x1
ffffffffc02039b8:	3e460613          	addi	a2,a2,996 # ffffffffc0204d98 <commands+0x728>
ffffffffc02039bc:	1d600593          	li	a1,470
ffffffffc02039c0:	00002517          	auipc	a0,0x2
ffffffffc02039c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02039c8:	f3afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02039cc:	00002697          	auipc	a3,0x2
ffffffffc02039d0:	3cc68693          	addi	a3,a3,972 # ffffffffc0205d98 <default_pmm_manager+0x558>
ffffffffc02039d4:	00001617          	auipc	a2,0x1
ffffffffc02039d8:	3c460613          	addi	a2,a2,964 # ffffffffc0204d98 <commands+0x728>
ffffffffc02039dc:	1d200593          	li	a1,466
ffffffffc02039e0:	00002517          	auipc	a0,0x2
ffffffffc02039e4:	f9850513          	addi	a0,a0,-104 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc02039e8:	f1afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02039ec:	00002697          	auipc	a3,0x2
ffffffffc02039f0:	31468693          	addi	a3,a3,788 # ffffffffc0205d00 <default_pmm_manager+0x4c0>
ffffffffc02039f4:	00001617          	auipc	a2,0x1
ffffffffc02039f8:	3a460613          	addi	a2,a2,932 # ffffffffc0204d98 <commands+0x728>
ffffffffc02039fc:	1c000593          	li	a1,448
ffffffffc0203a00:	00002517          	auipc	a0,0x2
ffffffffc0203a04:	f7850513          	addi	a0,a0,-136 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203a08:	efafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a0c:	00002697          	auipc	a3,0x2
ffffffffc0203a10:	12c68693          	addi	a3,a3,300 # ffffffffc0205b38 <default_pmm_manager+0x2f8>
ffffffffc0203a14:	00001617          	auipc	a2,0x1
ffffffffc0203a18:	38460613          	addi	a2,a2,900 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203a1c:	19b00593          	li	a1,411
ffffffffc0203a20:	00002517          	auipc	a0,0x2
ffffffffc0203a24:	f5850513          	addi	a0,a0,-168 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203a28:	edafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203a2c:	00002617          	auipc	a2,0x2
ffffffffc0203a30:	f2460613          	addi	a2,a2,-220 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0203a34:	19e00593          	li	a1,414
ffffffffc0203a38:	00002517          	auipc	a0,0x2
ffffffffc0203a3c:	f4050513          	addi	a0,a0,-192 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203a40:	ec2fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203a44:	00002697          	auipc	a3,0x2
ffffffffc0203a48:	10c68693          	addi	a3,a3,268 # ffffffffc0205b50 <default_pmm_manager+0x310>
ffffffffc0203a4c:	00001617          	auipc	a2,0x1
ffffffffc0203a50:	34c60613          	addi	a2,a2,844 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203a54:	19c00593          	li	a1,412
ffffffffc0203a58:	00002517          	auipc	a0,0x2
ffffffffc0203a5c:	f2050513          	addi	a0,a0,-224 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203a60:	ea2fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203a64:	00002697          	auipc	a3,0x2
ffffffffc0203a68:	16468693          	addi	a3,a3,356 # ffffffffc0205bc8 <default_pmm_manager+0x388>
ffffffffc0203a6c:	00001617          	auipc	a2,0x1
ffffffffc0203a70:	32c60613          	addi	a2,a2,812 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203a74:	1a400593          	li	a1,420
ffffffffc0203a78:	00002517          	auipc	a0,0x2
ffffffffc0203a7c:	f0050513          	addi	a0,a0,-256 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203a80:	e82fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203a84:	00002697          	auipc	a3,0x2
ffffffffc0203a88:	42468693          	addi	a3,a3,1060 # ffffffffc0205ea8 <default_pmm_manager+0x668>
ffffffffc0203a8c:	00001617          	auipc	a2,0x1
ffffffffc0203a90:	30c60613          	addi	a2,a2,780 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203a94:	1e000593          	li	a1,480
ffffffffc0203a98:	00002517          	auipc	a0,0x2
ffffffffc0203a9c:	ee050513          	addi	a0,a0,-288 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203aa0:	e62fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203aa4:	00002697          	auipc	a3,0x2
ffffffffc0203aa8:	3cc68693          	addi	a3,a3,972 # ffffffffc0205e70 <default_pmm_manager+0x630>
ffffffffc0203aac:	00001617          	auipc	a2,0x1
ffffffffc0203ab0:	2ec60613          	addi	a2,a2,748 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203ab4:	1dd00593          	li	a1,477
ffffffffc0203ab8:	00002517          	auipc	a0,0x2
ffffffffc0203abc:	ec050513          	addi	a0,a0,-320 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203ac0:	e42fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203ac4:	00002697          	auipc	a3,0x2
ffffffffc0203ac8:	37c68693          	addi	a3,a3,892 # ffffffffc0205e40 <default_pmm_manager+0x600>
ffffffffc0203acc:	00001617          	auipc	a2,0x1
ffffffffc0203ad0:	2cc60613          	addi	a2,a2,716 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203ad4:	1d900593          	li	a1,473
ffffffffc0203ad8:	00002517          	auipc	a0,0x2
ffffffffc0203adc:	ea050513          	addi	a0,a0,-352 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203ae0:	e22fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ae4 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203ae4:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203ae8:	8082                	ret

ffffffffc0203aea <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203aea:	7179                	addi	sp,sp,-48
ffffffffc0203aec:	e84a                	sd	s2,16(sp)
ffffffffc0203aee:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203af0:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203af2:	f022                	sd	s0,32(sp)
ffffffffc0203af4:	ec26                	sd	s1,24(sp)
ffffffffc0203af6:	e44e                	sd	s3,8(sp)
ffffffffc0203af8:	f406                	sd	ra,40(sp)
ffffffffc0203afa:	84ae                	mv	s1,a1
ffffffffc0203afc:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203afe:	eedfe0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
ffffffffc0203b02:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203b04:	cd09                	beqz	a0,ffffffffc0203b1e <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203b06:	85aa                	mv	a1,a0
ffffffffc0203b08:	86ce                	mv	a3,s3
ffffffffc0203b0a:	8626                	mv	a2,s1
ffffffffc0203b0c:	854a                	mv	a0,s2
ffffffffc0203b0e:	ad2ff0ef          	jal	ra,ffffffffc0202de0 <page_insert>
ffffffffc0203b12:	ed21                	bnez	a0,ffffffffc0203b6a <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203b14:	0000e797          	auipc	a5,0xe
ffffffffc0203b18:	a247a783          	lw	a5,-1500(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0203b1c:	eb89                	bnez	a5,ffffffffc0203b2e <pgdir_alloc_page+0x44>
}
ffffffffc0203b1e:	70a2                	ld	ra,40(sp)
ffffffffc0203b20:	8522                	mv	a0,s0
ffffffffc0203b22:	7402                	ld	s0,32(sp)
ffffffffc0203b24:	64e2                	ld	s1,24(sp)
ffffffffc0203b26:	6942                	ld	s2,16(sp)
ffffffffc0203b28:	69a2                	ld	s3,8(sp)
ffffffffc0203b2a:	6145                	addi	sp,sp,48
ffffffffc0203b2c:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203b2e:	4681                	li	a3,0
ffffffffc0203b30:	8622                	mv	a2,s0
ffffffffc0203b32:	85a6                	mv	a1,s1
ffffffffc0203b34:	0000e517          	auipc	a0,0xe
ffffffffc0203b38:	9e453503          	ld	a0,-1564(a0) # ffffffffc0211518 <check_mm_struct>
ffffffffc0203b3c:	e91fd0ef          	jal	ra,ffffffffc02019cc <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203b40:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203b42:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203b44:	4785                	li	a5,1
ffffffffc0203b46:	fcf70ce3          	beq	a4,a5,ffffffffc0203b1e <pgdir_alloc_page+0x34>
ffffffffc0203b4a:	00002697          	auipc	a3,0x2
ffffffffc0203b4e:	3a668693          	addi	a3,a3,934 # ffffffffc0205ef0 <default_pmm_manager+0x6b0>
ffffffffc0203b52:	00001617          	auipc	a2,0x1
ffffffffc0203b56:	24660613          	addi	a2,a2,582 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203b5a:	17a00593          	li	a1,378
ffffffffc0203b5e:	00002517          	auipc	a0,0x2
ffffffffc0203b62:	e1a50513          	addi	a0,a0,-486 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203b66:	d9cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b6a:	100027f3          	csrr	a5,sstatus
ffffffffc0203b6e:	8b89                	andi	a5,a5,2
ffffffffc0203b70:	eb99                	bnez	a5,ffffffffc0203b86 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203b72:	0000e797          	auipc	a5,0xe
ffffffffc0203b76:	9f67b783          	ld	a5,-1546(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0203b7a:	739c                	ld	a5,32(a5)
ffffffffc0203b7c:	8522                	mv	a0,s0
ffffffffc0203b7e:	4585                	li	a1,1
ffffffffc0203b80:	9782                	jalr	a5
            return NULL;
ffffffffc0203b82:	4401                	li	s0,0
ffffffffc0203b84:	bf69                	j	ffffffffc0203b1e <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203b86:	969fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203b8a:	0000e797          	auipc	a5,0xe
ffffffffc0203b8e:	9de7b783          	ld	a5,-1570(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0203b92:	739c                	ld	a5,32(a5)
ffffffffc0203b94:	8522                	mv	a0,s0
ffffffffc0203b96:	4585                	li	a1,1
ffffffffc0203b98:	9782                	jalr	a5
            return NULL;
ffffffffc0203b9a:	4401                	li	s0,0
        intr_enable();
ffffffffc0203b9c:	94dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203ba0:	bfbd                	j	ffffffffc0203b1e <pgdir_alloc_page+0x34>

ffffffffc0203ba2 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203ba2:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203ba4:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203ba6:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203ba8:	fff50713          	addi	a4,a0,-1
ffffffffc0203bac:	17f9                	addi	a5,a5,-2
ffffffffc0203bae:	04e7ea63          	bltu	a5,a4,ffffffffc0203c02 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203bb2:	6785                	lui	a5,0x1
ffffffffc0203bb4:	17fd                	addi	a5,a5,-1
ffffffffc0203bb6:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203bb8:	8131                	srli	a0,a0,0xc
ffffffffc0203bba:	e31fe0ef          	jal	ra,ffffffffc02029ea <alloc_pages>
    assert(base != NULL);
ffffffffc0203bbe:	cd3d                	beqz	a0,ffffffffc0203c3c <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203bc0:	0000e797          	auipc	a5,0xe
ffffffffc0203bc4:	9a07b783          	ld	a5,-1632(a5) # ffffffffc0211560 <pages>
ffffffffc0203bc8:	8d1d                	sub	a0,a0,a5
ffffffffc0203bca:	00002697          	auipc	a3,0x2
ffffffffc0203bce:	61e6b683          	ld	a3,1566(a3) # ffffffffc02061e8 <error_string+0x38>
ffffffffc0203bd2:	850d                	srai	a0,a0,0x3
ffffffffc0203bd4:	02d50533          	mul	a0,a0,a3
ffffffffc0203bd8:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bdc:	0000e717          	auipc	a4,0xe
ffffffffc0203be0:	97c73703          	ld	a4,-1668(a4) # ffffffffc0211558 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203be4:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203be6:	00c51793          	slli	a5,a0,0xc
ffffffffc0203bea:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203bec:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bee:	02e7fa63          	bgeu	a5,a4,ffffffffc0203c22 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203bf2:	60a2                	ld	ra,8(sp)
ffffffffc0203bf4:	0000e797          	auipc	a5,0xe
ffffffffc0203bf8:	97c7b783          	ld	a5,-1668(a5) # ffffffffc0211570 <va_pa_offset>
ffffffffc0203bfc:	953e                	add	a0,a0,a5
ffffffffc0203bfe:	0141                	addi	sp,sp,16
ffffffffc0203c00:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c02:	00002697          	auipc	a3,0x2
ffffffffc0203c06:	30668693          	addi	a3,a3,774 # ffffffffc0205f08 <default_pmm_manager+0x6c8>
ffffffffc0203c0a:	00001617          	auipc	a2,0x1
ffffffffc0203c0e:	18e60613          	addi	a2,a2,398 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203c12:	1f000593          	li	a1,496
ffffffffc0203c16:	00002517          	auipc	a0,0x2
ffffffffc0203c1a:	d6250513          	addi	a0,a0,-670 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203c1e:	ce4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203c22:	86aa                	mv	a3,a0
ffffffffc0203c24:	00002617          	auipc	a2,0x2
ffffffffc0203c28:	d2c60613          	addi	a2,a2,-724 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0203c2c:	06a00593          	li	a1,106
ffffffffc0203c30:	00001517          	auipc	a0,0x1
ffffffffc0203c34:	3d850513          	addi	a0,a0,984 # ffffffffc0205008 <commands+0x998>
ffffffffc0203c38:	ccafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203c3c:	00002697          	auipc	a3,0x2
ffffffffc0203c40:	2ec68693          	addi	a3,a3,748 # ffffffffc0205f28 <default_pmm_manager+0x6e8>
ffffffffc0203c44:	00001617          	auipc	a2,0x1
ffffffffc0203c48:	15460613          	addi	a2,a2,340 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203c4c:	1f300593          	li	a1,499
ffffffffc0203c50:	00002517          	auipc	a0,0x2
ffffffffc0203c54:	d2850513          	addi	a0,a0,-728 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203c58:	caafc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c5c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203c5c:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c5e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203c60:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c62:	fff58713          	addi	a4,a1,-1
ffffffffc0203c66:	17f9                	addi	a5,a5,-2
ffffffffc0203c68:	0ae7ee63          	bltu	a5,a4,ffffffffc0203d24 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203c6c:	cd41                	beqz	a0,ffffffffc0203d04 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203c6e:	6785                	lui	a5,0x1
ffffffffc0203c70:	17fd                	addi	a5,a5,-1
ffffffffc0203c72:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203c74:	c02007b7          	lui	a5,0xc0200
ffffffffc0203c78:	81b1                	srli	a1,a1,0xc
ffffffffc0203c7a:	06f56863          	bltu	a0,a5,ffffffffc0203cea <kfree+0x8e>
ffffffffc0203c7e:	0000e697          	auipc	a3,0xe
ffffffffc0203c82:	8f26b683          	ld	a3,-1806(a3) # ffffffffc0211570 <va_pa_offset>
ffffffffc0203c86:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203c88:	8131                	srli	a0,a0,0xc
ffffffffc0203c8a:	0000e797          	auipc	a5,0xe
ffffffffc0203c8e:	8ce7b783          	ld	a5,-1842(a5) # ffffffffc0211558 <npage>
ffffffffc0203c92:	04f57a63          	bgeu	a0,a5,ffffffffc0203ce6 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c96:	fff806b7          	lui	a3,0xfff80
ffffffffc0203c9a:	9536                	add	a0,a0,a3
ffffffffc0203c9c:	00351793          	slli	a5,a0,0x3
ffffffffc0203ca0:	953e                	add	a0,a0,a5
ffffffffc0203ca2:	050e                	slli	a0,a0,0x3
ffffffffc0203ca4:	0000e797          	auipc	a5,0xe
ffffffffc0203ca8:	8bc7b783          	ld	a5,-1860(a5) # ffffffffc0211560 <pages>
ffffffffc0203cac:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203cae:	100027f3          	csrr	a5,sstatus
ffffffffc0203cb2:	8b89                	andi	a5,a5,2
ffffffffc0203cb4:	eb89                	bnez	a5,ffffffffc0203cc6 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cb6:	0000e797          	auipc	a5,0xe
ffffffffc0203cba:	8b27b783          	ld	a5,-1870(a5) # ffffffffc0211568 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203cbe:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cc0:	739c                	ld	a5,32(a5)
}
ffffffffc0203cc2:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cc4:	8782                	jr	a5
        intr_disable();
ffffffffc0203cc6:	e42a                	sd	a0,8(sp)
ffffffffc0203cc8:	e02e                	sd	a1,0(sp)
ffffffffc0203cca:	825fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203cce:	0000e797          	auipc	a5,0xe
ffffffffc0203cd2:	89a7b783          	ld	a5,-1894(a5) # ffffffffc0211568 <pmm_manager>
ffffffffc0203cd6:	6582                	ld	a1,0(sp)
ffffffffc0203cd8:	6522                	ld	a0,8(sp)
ffffffffc0203cda:	739c                	ld	a5,32(a5)
ffffffffc0203cdc:	9782                	jalr	a5
}
ffffffffc0203cde:	60e2                	ld	ra,24(sp)
ffffffffc0203ce0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203ce2:	807fc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203ce6:	ccdfe0ef          	jal	ra,ffffffffc02029b2 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203cea:	86aa                	mv	a3,a0
ffffffffc0203cec:	00002617          	auipc	a2,0x2
ffffffffc0203cf0:	d2460613          	addi	a2,a2,-732 # ffffffffc0205a10 <default_pmm_manager+0x1d0>
ffffffffc0203cf4:	06c00593          	li	a1,108
ffffffffc0203cf8:	00001517          	auipc	a0,0x1
ffffffffc0203cfc:	31050513          	addi	a0,a0,784 # ffffffffc0205008 <commands+0x998>
ffffffffc0203d00:	c02fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203d04:	00002697          	auipc	a3,0x2
ffffffffc0203d08:	23468693          	addi	a3,a3,564 # ffffffffc0205f38 <default_pmm_manager+0x6f8>
ffffffffc0203d0c:	00001617          	auipc	a2,0x1
ffffffffc0203d10:	08c60613          	addi	a2,a2,140 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203d14:	1fa00593          	li	a1,506
ffffffffc0203d18:	00002517          	auipc	a0,0x2
ffffffffc0203d1c:	c6050513          	addi	a0,a0,-928 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203d20:	be2fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d24:	00002697          	auipc	a3,0x2
ffffffffc0203d28:	1e468693          	addi	a3,a3,484 # ffffffffc0205f08 <default_pmm_manager+0x6c8>
ffffffffc0203d2c:	00001617          	auipc	a2,0x1
ffffffffc0203d30:	06c60613          	addi	a2,a2,108 # ffffffffc0204d98 <commands+0x728>
ffffffffc0203d34:	1f900593          	li	a1,505
ffffffffc0203d38:	00002517          	auipc	a0,0x2
ffffffffc0203d3c:	c4050513          	addi	a0,a0,-960 # ffffffffc0205978 <default_pmm_manager+0x138>
ffffffffc0203d40:	bc2fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d44 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203d44:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d46:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203d48:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d4a:	e88fc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203d4e:	cd01                	beqz	a0,ffffffffc0203d66 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d50:	4505                	li	a0,1
ffffffffc0203d52:	e86fc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203d56:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d58:	810d                	srli	a0,a0,0x3
ffffffffc0203d5a:	0000d797          	auipc	a5,0xd
ffffffffc0203d5e:	7ca7b723          	sd	a0,1998(a5) # ffffffffc0211528 <max_swap_offset>
}
ffffffffc0203d62:	0141                	addi	sp,sp,16
ffffffffc0203d64:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203d66:	00002617          	auipc	a2,0x2
ffffffffc0203d6a:	1e260613          	addi	a2,a2,482 # ffffffffc0205f48 <default_pmm_manager+0x708>
ffffffffc0203d6e:	45b5                	li	a1,13
ffffffffc0203d70:	00002517          	auipc	a0,0x2
ffffffffc0203d74:	1f850513          	addi	a0,a0,504 # ffffffffc0205f68 <default_pmm_manager+0x728>
ffffffffc0203d78:	b8afc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d7c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203d7c:	1141                	addi	sp,sp,-16
ffffffffc0203d7e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d80:	00855793          	srli	a5,a0,0x8
ffffffffc0203d84:	c3a5                	beqz	a5,ffffffffc0203de4 <swapfs_read+0x68>
ffffffffc0203d86:	0000d717          	auipc	a4,0xd
ffffffffc0203d8a:	7a273703          	ld	a4,1954(a4) # ffffffffc0211528 <max_swap_offset>
ffffffffc0203d8e:	04e7fb63          	bgeu	a5,a4,ffffffffc0203de4 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d92:	0000d617          	auipc	a2,0xd
ffffffffc0203d96:	7ce63603          	ld	a2,1998(a2) # ffffffffc0211560 <pages>
ffffffffc0203d9a:	8d91                	sub	a1,a1,a2
ffffffffc0203d9c:	4035d613          	srai	a2,a1,0x3
ffffffffc0203da0:	00002597          	auipc	a1,0x2
ffffffffc0203da4:	4485b583          	ld	a1,1096(a1) # ffffffffc02061e8 <error_string+0x38>
ffffffffc0203da8:	02b60633          	mul	a2,a2,a1
ffffffffc0203dac:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203db0:	00002797          	auipc	a5,0x2
ffffffffc0203db4:	4407b783          	ld	a5,1088(a5) # ffffffffc02061f0 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203db8:	0000d717          	auipc	a4,0xd
ffffffffc0203dbc:	7a073703          	ld	a4,1952(a4) # ffffffffc0211558 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dc0:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203dc2:	00c61793          	slli	a5,a2,0xc
ffffffffc0203dc6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203dc8:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203dca:	02e7f963          	bgeu	a5,a4,ffffffffc0203dfc <swapfs_read+0x80>
}
ffffffffc0203dce:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dd0:	0000d797          	auipc	a5,0xd
ffffffffc0203dd4:	7a07b783          	ld	a5,1952(a5) # ffffffffc0211570 <va_pa_offset>
ffffffffc0203dd8:	46a1                	li	a3,8
ffffffffc0203dda:	963e                	add	a2,a2,a5
ffffffffc0203ddc:	4505                	li	a0,1
}
ffffffffc0203dde:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203de0:	dfefc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203de4:	86aa                	mv	a3,a0
ffffffffc0203de6:	00002617          	auipc	a2,0x2
ffffffffc0203dea:	19a60613          	addi	a2,a2,410 # ffffffffc0205f80 <default_pmm_manager+0x740>
ffffffffc0203dee:	45d1                	li	a1,20
ffffffffc0203df0:	00002517          	auipc	a0,0x2
ffffffffc0203df4:	17850513          	addi	a0,a0,376 # ffffffffc0205f68 <default_pmm_manager+0x728>
ffffffffc0203df8:	b0afc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203dfc:	86b2                	mv	a3,a2
ffffffffc0203dfe:	06a00593          	li	a1,106
ffffffffc0203e02:	00002617          	auipc	a2,0x2
ffffffffc0203e06:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0203e0a:	00001517          	auipc	a0,0x1
ffffffffc0203e0e:	1fe50513          	addi	a0,a0,510 # ffffffffc0205008 <commands+0x998>
ffffffffc0203e12:	af0fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e16 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203e16:	1141                	addi	sp,sp,-16
ffffffffc0203e18:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e1a:	00855793          	srli	a5,a0,0x8
ffffffffc0203e1e:	c3a5                	beqz	a5,ffffffffc0203e7e <swapfs_write+0x68>
ffffffffc0203e20:	0000d717          	auipc	a4,0xd
ffffffffc0203e24:	70873703          	ld	a4,1800(a4) # ffffffffc0211528 <max_swap_offset>
ffffffffc0203e28:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e7e <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e2c:	0000d617          	auipc	a2,0xd
ffffffffc0203e30:	73463603          	ld	a2,1844(a2) # ffffffffc0211560 <pages>
ffffffffc0203e34:	8d91                	sub	a1,a1,a2
ffffffffc0203e36:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e3a:	00002597          	auipc	a1,0x2
ffffffffc0203e3e:	3ae5b583          	ld	a1,942(a1) # ffffffffc02061e8 <error_string+0x38>
ffffffffc0203e42:	02b60633          	mul	a2,a2,a1
ffffffffc0203e46:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e4a:	00002797          	auipc	a5,0x2
ffffffffc0203e4e:	3a67b783          	ld	a5,934(a5) # ffffffffc02061f0 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e52:	0000d717          	auipc	a4,0xd
ffffffffc0203e56:	70673703          	ld	a4,1798(a4) # ffffffffc0211558 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e5a:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e5c:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e60:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e62:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e64:	02e7f963          	bgeu	a5,a4,ffffffffc0203e96 <swapfs_write+0x80>
}
ffffffffc0203e68:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e6a:	0000d797          	auipc	a5,0xd
ffffffffc0203e6e:	7067b783          	ld	a5,1798(a5) # ffffffffc0211570 <va_pa_offset>
ffffffffc0203e72:	46a1                	li	a3,8
ffffffffc0203e74:	963e                	add	a2,a2,a5
ffffffffc0203e76:	4505                	li	a0,1
}
ffffffffc0203e78:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e7a:	d88fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203e7e:	86aa                	mv	a3,a0
ffffffffc0203e80:	00002617          	auipc	a2,0x2
ffffffffc0203e84:	10060613          	addi	a2,a2,256 # ffffffffc0205f80 <default_pmm_manager+0x740>
ffffffffc0203e88:	45e5                	li	a1,25
ffffffffc0203e8a:	00002517          	auipc	a0,0x2
ffffffffc0203e8e:	0de50513          	addi	a0,a0,222 # ffffffffc0205f68 <default_pmm_manager+0x728>
ffffffffc0203e92:	a70fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203e96:	86b2                	mv	a3,a2
ffffffffc0203e98:	06a00593          	li	a1,106
ffffffffc0203e9c:	00002617          	auipc	a2,0x2
ffffffffc0203ea0:	ab460613          	addi	a2,a2,-1356 # ffffffffc0205950 <default_pmm_manager+0x110>
ffffffffc0203ea4:	00001517          	auipc	a0,0x1
ffffffffc0203ea8:	16450513          	addi	a0,a0,356 # ffffffffc0205008 <commands+0x998>
ffffffffc0203eac:	a56fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203eb0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203eb0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203eb4:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203eb6:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203eb8:	cb81                	beqz	a5,ffffffffc0203ec8 <strlen+0x18>
        cnt ++;
ffffffffc0203eba:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203ebc:	00a707b3          	add	a5,a4,a0
ffffffffc0203ec0:	0007c783          	lbu	a5,0(a5)
ffffffffc0203ec4:	fbfd                	bnez	a5,ffffffffc0203eba <strlen+0xa>
ffffffffc0203ec6:	8082                	ret
    }
    return cnt;
}
ffffffffc0203ec8:	8082                	ret

ffffffffc0203eca <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203eca:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203ecc:	e589                	bnez	a1,ffffffffc0203ed6 <strnlen+0xc>
ffffffffc0203ece:	a811                	j	ffffffffc0203ee2 <strnlen+0x18>
        cnt ++;
ffffffffc0203ed0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203ed2:	00f58863          	beq	a1,a5,ffffffffc0203ee2 <strnlen+0x18>
ffffffffc0203ed6:	00f50733          	add	a4,a0,a5
ffffffffc0203eda:	00074703          	lbu	a4,0(a4)
ffffffffc0203ede:	fb6d                	bnez	a4,ffffffffc0203ed0 <strnlen+0x6>
ffffffffc0203ee0:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203ee2:	852e                	mv	a0,a1
ffffffffc0203ee4:	8082                	ret

ffffffffc0203ee6 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203ee6:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203ee8:	0005c703          	lbu	a4,0(a1)
ffffffffc0203eec:	0785                	addi	a5,a5,1
ffffffffc0203eee:	0585                	addi	a1,a1,1
ffffffffc0203ef0:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203ef4:	fb75                	bnez	a4,ffffffffc0203ee8 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203ef6:	8082                	ret

ffffffffc0203ef8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203ef8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203efc:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f00:	cb89                	beqz	a5,ffffffffc0203f12 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203f02:	0505                	addi	a0,a0,1
ffffffffc0203f04:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f06:	fee789e3          	beq	a5,a4,ffffffffc0203ef8 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203f0a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203f0e:	9d19                	subw	a0,a0,a4
ffffffffc0203f10:	8082                	ret
ffffffffc0203f12:	4501                	li	a0,0
ffffffffc0203f14:	bfed                	j	ffffffffc0203f0e <strcmp+0x16>

ffffffffc0203f16 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203f16:	00054783          	lbu	a5,0(a0)
ffffffffc0203f1a:	c799                	beqz	a5,ffffffffc0203f28 <strchr+0x12>
        if (*s == c) {
ffffffffc0203f1c:	00f58763          	beq	a1,a5,ffffffffc0203f2a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203f20:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203f24:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203f26:	fbfd                	bnez	a5,ffffffffc0203f1c <strchr+0x6>
    }
    return NULL;
ffffffffc0203f28:	4501                	li	a0,0
}
ffffffffc0203f2a:	8082                	ret

ffffffffc0203f2c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203f2c:	ca01                	beqz	a2,ffffffffc0203f3c <memset+0x10>
ffffffffc0203f2e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203f30:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203f32:	0785                	addi	a5,a5,1
ffffffffc0203f34:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203f38:	fec79de3          	bne	a5,a2,ffffffffc0203f32 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203f3c:	8082                	ret

ffffffffc0203f3e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203f3e:	ca19                	beqz	a2,ffffffffc0203f54 <memcpy+0x16>
ffffffffc0203f40:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203f42:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203f44:	0005c703          	lbu	a4,0(a1)
ffffffffc0203f48:	0585                	addi	a1,a1,1
ffffffffc0203f4a:	0785                	addi	a5,a5,1
ffffffffc0203f4c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203f50:	fec59ae3          	bne	a1,a2,ffffffffc0203f44 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203f54:	8082                	ret

ffffffffc0203f56 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203f56:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f5a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203f5c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f60:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203f62:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f66:	f022                	sd	s0,32(sp)
ffffffffc0203f68:	ec26                	sd	s1,24(sp)
ffffffffc0203f6a:	e84a                	sd	s2,16(sp)
ffffffffc0203f6c:	f406                	sd	ra,40(sp)
ffffffffc0203f6e:	e44e                	sd	s3,8(sp)
ffffffffc0203f70:	84aa                	mv	s1,a0
ffffffffc0203f72:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203f74:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203f78:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203f7a:	03067e63          	bgeu	a2,a6,ffffffffc0203fb6 <printnum+0x60>
ffffffffc0203f7e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203f80:	00805763          	blez	s0,ffffffffc0203f8e <printnum+0x38>
ffffffffc0203f84:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203f86:	85ca                	mv	a1,s2
ffffffffc0203f88:	854e                	mv	a0,s3
ffffffffc0203f8a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203f8c:	fc65                	bnez	s0,ffffffffc0203f84 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f8e:	1a02                	slli	s4,s4,0x20
ffffffffc0203f90:	00002797          	auipc	a5,0x2
ffffffffc0203f94:	01078793          	addi	a5,a5,16 # ffffffffc0205fa0 <default_pmm_manager+0x760>
ffffffffc0203f98:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203f9c:	9a3e                	add	s4,s4,a5
}
ffffffffc0203f9e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fa0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203fa4:	70a2                	ld	ra,40(sp)
ffffffffc0203fa6:	69a2                	ld	s3,8(sp)
ffffffffc0203fa8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203faa:	85ca                	mv	a1,s2
ffffffffc0203fac:	87a6                	mv	a5,s1
}
ffffffffc0203fae:	6942                	ld	s2,16(sp)
ffffffffc0203fb0:	64e2                	ld	s1,24(sp)
ffffffffc0203fb2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fb4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203fb6:	03065633          	divu	a2,a2,a6
ffffffffc0203fba:	8722                	mv	a4,s0
ffffffffc0203fbc:	f9bff0ef          	jal	ra,ffffffffc0203f56 <printnum>
ffffffffc0203fc0:	b7f9                	j	ffffffffc0203f8e <printnum+0x38>

ffffffffc0203fc2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203fc2:	7119                	addi	sp,sp,-128
ffffffffc0203fc4:	f4a6                	sd	s1,104(sp)
ffffffffc0203fc6:	f0ca                	sd	s2,96(sp)
ffffffffc0203fc8:	ecce                	sd	s3,88(sp)
ffffffffc0203fca:	e8d2                	sd	s4,80(sp)
ffffffffc0203fcc:	e4d6                	sd	s5,72(sp)
ffffffffc0203fce:	e0da                	sd	s6,64(sp)
ffffffffc0203fd0:	fc5e                	sd	s7,56(sp)
ffffffffc0203fd2:	f06a                	sd	s10,32(sp)
ffffffffc0203fd4:	fc86                	sd	ra,120(sp)
ffffffffc0203fd6:	f8a2                	sd	s0,112(sp)
ffffffffc0203fd8:	f862                	sd	s8,48(sp)
ffffffffc0203fda:	f466                	sd	s9,40(sp)
ffffffffc0203fdc:	ec6e                	sd	s11,24(sp)
ffffffffc0203fde:	892a                	mv	s2,a0
ffffffffc0203fe0:	84ae                	mv	s1,a1
ffffffffc0203fe2:	8d32                	mv	s10,a2
ffffffffc0203fe4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fe6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203fea:	5b7d                	li	s6,-1
ffffffffc0203fec:	00002a97          	auipc	s5,0x2
ffffffffc0203ff0:	fe8a8a93          	addi	s5,s5,-24 # ffffffffc0205fd4 <default_pmm_manager+0x794>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203ff4:	00002b97          	auipc	s7,0x2
ffffffffc0203ff8:	1bcb8b93          	addi	s7,s7,444 # ffffffffc02061b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ffc:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204000:	001d0413          	addi	s0,s10,1
ffffffffc0204004:	01350a63          	beq	a0,s3,ffffffffc0204018 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204008:	c121                	beqz	a0,ffffffffc0204048 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020400a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020400c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020400e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204010:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204014:	ff351ae3          	bne	a0,s3,ffffffffc0204008 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204018:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020401c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204020:	4c81                	li	s9,0
ffffffffc0204022:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204024:	5c7d                	li	s8,-1
ffffffffc0204026:	5dfd                	li	s11,-1
ffffffffc0204028:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020402c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020402e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204032:	0ff5f593          	zext.b	a1,a1
ffffffffc0204036:	00140d13          	addi	s10,s0,1
ffffffffc020403a:	04b56263          	bltu	a0,a1,ffffffffc020407e <vprintfmt+0xbc>
ffffffffc020403e:	058a                	slli	a1,a1,0x2
ffffffffc0204040:	95d6                	add	a1,a1,s5
ffffffffc0204042:	4194                	lw	a3,0(a1)
ffffffffc0204044:	96d6                	add	a3,a3,s5
ffffffffc0204046:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204048:	70e6                	ld	ra,120(sp)
ffffffffc020404a:	7446                	ld	s0,112(sp)
ffffffffc020404c:	74a6                	ld	s1,104(sp)
ffffffffc020404e:	7906                	ld	s2,96(sp)
ffffffffc0204050:	69e6                	ld	s3,88(sp)
ffffffffc0204052:	6a46                	ld	s4,80(sp)
ffffffffc0204054:	6aa6                	ld	s5,72(sp)
ffffffffc0204056:	6b06                	ld	s6,64(sp)
ffffffffc0204058:	7be2                	ld	s7,56(sp)
ffffffffc020405a:	7c42                	ld	s8,48(sp)
ffffffffc020405c:	7ca2                	ld	s9,40(sp)
ffffffffc020405e:	7d02                	ld	s10,32(sp)
ffffffffc0204060:	6de2                	ld	s11,24(sp)
ffffffffc0204062:	6109                	addi	sp,sp,128
ffffffffc0204064:	8082                	ret
            padc = '0';
ffffffffc0204066:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204068:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020406c:	846a                	mv	s0,s10
ffffffffc020406e:	00140d13          	addi	s10,s0,1
ffffffffc0204072:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204076:	0ff5f593          	zext.b	a1,a1
ffffffffc020407a:	fcb572e3          	bgeu	a0,a1,ffffffffc020403e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020407e:	85a6                	mv	a1,s1
ffffffffc0204080:	02500513          	li	a0,37
ffffffffc0204084:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204086:	fff44783          	lbu	a5,-1(s0)
ffffffffc020408a:	8d22                	mv	s10,s0
ffffffffc020408c:	f73788e3          	beq	a5,s3,ffffffffc0203ffc <vprintfmt+0x3a>
ffffffffc0204090:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204094:	1d7d                	addi	s10,s10,-1
ffffffffc0204096:	ff379de3          	bne	a5,s3,ffffffffc0204090 <vprintfmt+0xce>
ffffffffc020409a:	b78d                	j	ffffffffc0203ffc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020409c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02040a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040a4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02040a6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02040aa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040ae:	02d86463          	bltu	a6,a3,ffffffffc02040d6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02040b2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040b6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02040ba:	0186873b          	addw	a4,a3,s8
ffffffffc02040be:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040c2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02040c4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02040c8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040ca:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02040ce:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040d2:	fed870e3          	bgeu	a6,a3,ffffffffc02040b2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02040d6:	f40ddce3          	bgez	s11,ffffffffc020402e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02040da:	8de2                	mv	s11,s8
ffffffffc02040dc:	5c7d                	li	s8,-1
ffffffffc02040de:	bf81                	j	ffffffffc020402e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02040e0:	fffdc693          	not	a3,s11
ffffffffc02040e4:	96fd                	srai	a3,a3,0x3f
ffffffffc02040e6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040ea:	00144603          	lbu	a2,1(s0)
ffffffffc02040ee:	2d81                	sext.w	s11,s11
ffffffffc02040f0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040f2:	bf35                	j	ffffffffc020402e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02040f4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02040fc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040fe:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204100:	bfd9                	j	ffffffffc02040d6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204102:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204104:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204108:	01174463          	blt	a4,a7,ffffffffc0204110 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020410c:	1a088e63          	beqz	a7,ffffffffc02042c8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204110:	000a3603          	ld	a2,0(s4)
ffffffffc0204114:	46c1                	li	a3,16
ffffffffc0204116:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204118:	2781                	sext.w	a5,a5
ffffffffc020411a:	876e                	mv	a4,s11
ffffffffc020411c:	85a6                	mv	a1,s1
ffffffffc020411e:	854a                	mv	a0,s2
ffffffffc0204120:	e37ff0ef          	jal	ra,ffffffffc0203f56 <printnum>
            break;
ffffffffc0204124:	bde1                	j	ffffffffc0203ffc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204126:	000a2503          	lw	a0,0(s4)
ffffffffc020412a:	85a6                	mv	a1,s1
ffffffffc020412c:	0a21                	addi	s4,s4,8
ffffffffc020412e:	9902                	jalr	s2
            break;
ffffffffc0204130:	b5f1                	j	ffffffffc0203ffc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204132:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204134:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204138:	01174463          	blt	a4,a7,ffffffffc0204140 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020413c:	18088163          	beqz	a7,ffffffffc02042be <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204140:	000a3603          	ld	a2,0(s4)
ffffffffc0204144:	46a9                	li	a3,10
ffffffffc0204146:	8a2e                	mv	s4,a1
ffffffffc0204148:	bfc1                	j	ffffffffc0204118 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020414a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020414e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204150:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204152:	bdf1                	j	ffffffffc020402e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204154:	85a6                	mv	a1,s1
ffffffffc0204156:	02500513          	li	a0,37
ffffffffc020415a:	9902                	jalr	s2
            break;
ffffffffc020415c:	b545                	j	ffffffffc0203ffc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020415e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204162:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204164:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204166:	b5e1                	j	ffffffffc020402e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204168:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020416a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020416e:	01174463          	blt	a4,a7,ffffffffc0204176 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204172:	14088163          	beqz	a7,ffffffffc02042b4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204176:	000a3603          	ld	a2,0(s4)
ffffffffc020417a:	46a1                	li	a3,8
ffffffffc020417c:	8a2e                	mv	s4,a1
ffffffffc020417e:	bf69                	j	ffffffffc0204118 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204180:	03000513          	li	a0,48
ffffffffc0204184:	85a6                	mv	a1,s1
ffffffffc0204186:	e03e                	sd	a5,0(sp)
ffffffffc0204188:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020418a:	85a6                	mv	a1,s1
ffffffffc020418c:	07800513          	li	a0,120
ffffffffc0204190:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204192:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204194:	6782                	ld	a5,0(sp)
ffffffffc0204196:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204198:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020419c:	bfb5                	j	ffffffffc0204118 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020419e:	000a3403          	ld	s0,0(s4)
ffffffffc02041a2:	008a0713          	addi	a4,s4,8
ffffffffc02041a6:	e03a                	sd	a4,0(sp)
ffffffffc02041a8:	14040263          	beqz	s0,ffffffffc02042ec <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02041ac:	0fb05763          	blez	s11,ffffffffc020429a <vprintfmt+0x2d8>
ffffffffc02041b0:	02d00693          	li	a3,45
ffffffffc02041b4:	0cd79163          	bne	a5,a3,ffffffffc0204276 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041b8:	00044783          	lbu	a5,0(s0)
ffffffffc02041bc:	0007851b          	sext.w	a0,a5
ffffffffc02041c0:	cf85                	beqz	a5,ffffffffc02041f8 <vprintfmt+0x236>
ffffffffc02041c2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041c6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041ca:	000c4563          	bltz	s8,ffffffffc02041d4 <vprintfmt+0x212>
ffffffffc02041ce:	3c7d                	addiw	s8,s8,-1
ffffffffc02041d0:	036c0263          	beq	s8,s6,ffffffffc02041f4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02041d4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041d6:	0e0c8e63          	beqz	s9,ffffffffc02042d2 <vprintfmt+0x310>
ffffffffc02041da:	3781                	addiw	a5,a5,-32
ffffffffc02041dc:	0ef47b63          	bgeu	s0,a5,ffffffffc02042d2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02041e0:	03f00513          	li	a0,63
ffffffffc02041e4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041e6:	000a4783          	lbu	a5,0(s4)
ffffffffc02041ea:	3dfd                	addiw	s11,s11,-1
ffffffffc02041ec:	0a05                	addi	s4,s4,1
ffffffffc02041ee:	0007851b          	sext.w	a0,a5
ffffffffc02041f2:	ffe1                	bnez	a5,ffffffffc02041ca <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02041f4:	01b05963          	blez	s11,ffffffffc0204206 <vprintfmt+0x244>
ffffffffc02041f8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02041fa:	85a6                	mv	a1,s1
ffffffffc02041fc:	02000513          	li	a0,32
ffffffffc0204200:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204202:	fe0d9be3          	bnez	s11,ffffffffc02041f8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204206:	6a02                	ld	s4,0(sp)
ffffffffc0204208:	bbd5                	j	ffffffffc0203ffc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020420a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020420c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204210:	01174463          	blt	a4,a7,ffffffffc0204218 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204214:	08088d63          	beqz	a7,ffffffffc02042ae <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204218:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020421c:	0a044d63          	bltz	s0,ffffffffc02042d6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204220:	8622                	mv	a2,s0
ffffffffc0204222:	8a66                	mv	s4,s9
ffffffffc0204224:	46a9                	li	a3,10
ffffffffc0204226:	bdcd                	j	ffffffffc0204118 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204228:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020422c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020422e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204230:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204234:	8fb5                	xor	a5,a5,a3
ffffffffc0204236:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020423a:	02d74163          	blt	a4,a3,ffffffffc020425c <vprintfmt+0x29a>
ffffffffc020423e:	00369793          	slli	a5,a3,0x3
ffffffffc0204242:	97de                	add	a5,a5,s7
ffffffffc0204244:	639c                	ld	a5,0(a5)
ffffffffc0204246:	cb99                	beqz	a5,ffffffffc020425c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204248:	86be                	mv	a3,a5
ffffffffc020424a:	00002617          	auipc	a2,0x2
ffffffffc020424e:	d8660613          	addi	a2,a2,-634 # ffffffffc0205fd0 <default_pmm_manager+0x790>
ffffffffc0204252:	85a6                	mv	a1,s1
ffffffffc0204254:	854a                	mv	a0,s2
ffffffffc0204256:	0ce000ef          	jal	ra,ffffffffc0204324 <printfmt>
ffffffffc020425a:	b34d                	j	ffffffffc0203ffc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020425c:	00002617          	auipc	a2,0x2
ffffffffc0204260:	d6460613          	addi	a2,a2,-668 # ffffffffc0205fc0 <default_pmm_manager+0x780>
ffffffffc0204264:	85a6                	mv	a1,s1
ffffffffc0204266:	854a                	mv	a0,s2
ffffffffc0204268:	0bc000ef          	jal	ra,ffffffffc0204324 <printfmt>
ffffffffc020426c:	bb41                	j	ffffffffc0203ffc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020426e:	00002417          	auipc	s0,0x2
ffffffffc0204272:	d4a40413          	addi	s0,s0,-694 # ffffffffc0205fb8 <default_pmm_manager+0x778>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204276:	85e2                	mv	a1,s8
ffffffffc0204278:	8522                	mv	a0,s0
ffffffffc020427a:	e43e                	sd	a5,8(sp)
ffffffffc020427c:	c4fff0ef          	jal	ra,ffffffffc0203eca <strnlen>
ffffffffc0204280:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204284:	01b05b63          	blez	s11,ffffffffc020429a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204288:	67a2                	ld	a5,8(sp)
ffffffffc020428a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020428e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204290:	85a6                	mv	a1,s1
ffffffffc0204292:	8552                	mv	a0,s4
ffffffffc0204294:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204296:	fe0d9ce3          	bnez	s11,ffffffffc020428e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020429a:	00044783          	lbu	a5,0(s0)
ffffffffc020429e:	00140a13          	addi	s4,s0,1
ffffffffc02042a2:	0007851b          	sext.w	a0,a5
ffffffffc02042a6:	d3a5                	beqz	a5,ffffffffc0204206 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042a8:	05e00413          	li	s0,94
ffffffffc02042ac:	bf39                	j	ffffffffc02041ca <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02042ae:	000a2403          	lw	s0,0(s4)
ffffffffc02042b2:	b7ad                	j	ffffffffc020421c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02042b4:	000a6603          	lwu	a2,0(s4)
ffffffffc02042b8:	46a1                	li	a3,8
ffffffffc02042ba:	8a2e                	mv	s4,a1
ffffffffc02042bc:	bdb1                	j	ffffffffc0204118 <vprintfmt+0x156>
ffffffffc02042be:	000a6603          	lwu	a2,0(s4)
ffffffffc02042c2:	46a9                	li	a3,10
ffffffffc02042c4:	8a2e                	mv	s4,a1
ffffffffc02042c6:	bd89                	j	ffffffffc0204118 <vprintfmt+0x156>
ffffffffc02042c8:	000a6603          	lwu	a2,0(s4)
ffffffffc02042cc:	46c1                	li	a3,16
ffffffffc02042ce:	8a2e                	mv	s4,a1
ffffffffc02042d0:	b5a1                	j	ffffffffc0204118 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02042d2:	9902                	jalr	s2
ffffffffc02042d4:	bf09                	j	ffffffffc02041e6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02042d6:	85a6                	mv	a1,s1
ffffffffc02042d8:	02d00513          	li	a0,45
ffffffffc02042dc:	e03e                	sd	a5,0(sp)
ffffffffc02042de:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02042e0:	6782                	ld	a5,0(sp)
ffffffffc02042e2:	8a66                	mv	s4,s9
ffffffffc02042e4:	40800633          	neg	a2,s0
ffffffffc02042e8:	46a9                	li	a3,10
ffffffffc02042ea:	b53d                	j	ffffffffc0204118 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02042ec:	03b05163          	blez	s11,ffffffffc020430e <vprintfmt+0x34c>
ffffffffc02042f0:	02d00693          	li	a3,45
ffffffffc02042f4:	f6d79de3          	bne	a5,a3,ffffffffc020426e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02042f8:	00002417          	auipc	s0,0x2
ffffffffc02042fc:	cc040413          	addi	s0,s0,-832 # ffffffffc0205fb8 <default_pmm_manager+0x778>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204300:	02800793          	li	a5,40
ffffffffc0204304:	02800513          	li	a0,40
ffffffffc0204308:	00140a13          	addi	s4,s0,1
ffffffffc020430c:	bd6d                	j	ffffffffc02041c6 <vprintfmt+0x204>
ffffffffc020430e:	00002a17          	auipc	s4,0x2
ffffffffc0204312:	caba0a13          	addi	s4,s4,-853 # ffffffffc0205fb9 <default_pmm_manager+0x779>
ffffffffc0204316:	02800513          	li	a0,40
ffffffffc020431a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020431e:	05e00413          	li	s0,94
ffffffffc0204322:	b565                	j	ffffffffc02041ca <vprintfmt+0x208>

ffffffffc0204324 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204324:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204326:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020432a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020432c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020432e:	ec06                	sd	ra,24(sp)
ffffffffc0204330:	f83a                	sd	a4,48(sp)
ffffffffc0204332:	fc3e                	sd	a5,56(sp)
ffffffffc0204334:	e0c2                	sd	a6,64(sp)
ffffffffc0204336:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204338:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020433a:	c89ff0ef          	jal	ra,ffffffffc0203fc2 <vprintfmt>
}
ffffffffc020433e:	60e2                	ld	ra,24(sp)
ffffffffc0204340:	6161                	addi	sp,sp,80
ffffffffc0204342:	8082                	ret

ffffffffc0204344 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204344:	715d                	addi	sp,sp,-80
ffffffffc0204346:	e486                	sd	ra,72(sp)
ffffffffc0204348:	e0a6                	sd	s1,64(sp)
ffffffffc020434a:	fc4a                	sd	s2,56(sp)
ffffffffc020434c:	f84e                	sd	s3,48(sp)
ffffffffc020434e:	f452                	sd	s4,40(sp)
ffffffffc0204350:	f056                	sd	s5,32(sp)
ffffffffc0204352:	ec5a                	sd	s6,24(sp)
ffffffffc0204354:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204356:	c901                	beqz	a0,ffffffffc0204366 <readline+0x22>
ffffffffc0204358:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020435a:	00002517          	auipc	a0,0x2
ffffffffc020435e:	c7650513          	addi	a0,a0,-906 # ffffffffc0205fd0 <default_pmm_manager+0x790>
ffffffffc0204362:	d59fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0204366:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204368:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020436a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020436c:	4aa9                	li	s5,10
ffffffffc020436e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204370:	0000db97          	auipc	s7,0xd
ffffffffc0204374:	d88b8b93          	addi	s7,s7,-632 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204378:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020437c:	d77fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204380:	00054a63          	bltz	a0,ffffffffc0204394 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204384:	00a95a63          	bge	s2,a0,ffffffffc0204398 <readline+0x54>
ffffffffc0204388:	029a5263          	bge	s4,s1,ffffffffc02043ac <readline+0x68>
        c = getchar();
ffffffffc020438c:	d67fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204390:	fe055ae3          	bgez	a0,ffffffffc0204384 <readline+0x40>
            return NULL;
ffffffffc0204394:	4501                	li	a0,0
ffffffffc0204396:	a091                	j	ffffffffc02043da <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204398:	03351463          	bne	a0,s3,ffffffffc02043c0 <readline+0x7c>
ffffffffc020439c:	e8a9                	bnez	s1,ffffffffc02043ee <readline+0xaa>
        c = getchar();
ffffffffc020439e:	d55fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043a2:	fe0549e3          	bltz	a0,ffffffffc0204394 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043a6:	fea959e3          	bge	s2,a0,ffffffffc0204398 <readline+0x54>
ffffffffc02043aa:	4481                	li	s1,0
            cputchar(c);
ffffffffc02043ac:	e42a                	sd	a0,8(sp)
ffffffffc02043ae:	d43fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02043b2:	6522                	ld	a0,8(sp)
ffffffffc02043b4:	009b87b3          	add	a5,s7,s1
ffffffffc02043b8:	2485                	addiw	s1,s1,1
ffffffffc02043ba:	00a78023          	sb	a0,0(a5)
ffffffffc02043be:	bf7d                	j	ffffffffc020437c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02043c0:	01550463          	beq	a0,s5,ffffffffc02043c8 <readline+0x84>
ffffffffc02043c4:	fb651ce3          	bne	a0,s6,ffffffffc020437c <readline+0x38>
            cputchar(c);
ffffffffc02043c8:	d29fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02043cc:	0000d517          	auipc	a0,0xd
ffffffffc02043d0:	d2c50513          	addi	a0,a0,-724 # ffffffffc02110f8 <buf>
ffffffffc02043d4:	94aa                	add	s1,s1,a0
ffffffffc02043d6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02043da:	60a6                	ld	ra,72(sp)
ffffffffc02043dc:	6486                	ld	s1,64(sp)
ffffffffc02043de:	7962                	ld	s2,56(sp)
ffffffffc02043e0:	79c2                	ld	s3,48(sp)
ffffffffc02043e2:	7a22                	ld	s4,40(sp)
ffffffffc02043e4:	7a82                	ld	s5,32(sp)
ffffffffc02043e6:	6b62                	ld	s6,24(sp)
ffffffffc02043e8:	6bc2                	ld	s7,16(sp)
ffffffffc02043ea:	6161                	addi	sp,sp,80
ffffffffc02043ec:	8082                	ret
            cputchar(c);
ffffffffc02043ee:	4521                	li	a0,8
ffffffffc02043f0:	d01fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02043f4:	34fd                	addiw	s1,s1,-1
ffffffffc02043f6:	b759                	j	ffffffffc020437c <readline+0x38>
