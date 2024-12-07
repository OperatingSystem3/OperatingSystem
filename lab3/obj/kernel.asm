
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
ffffffffc0200036:	01250513          	addi	a0,a0,18 # ffffffffc020a044 <edata>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	54660613          	addi	a2,a2,1350 # ffffffffc0211580 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	03e040ef          	jal	ra,ffffffffc0204088 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	50a58593          	addi	a1,a1,1290 # ffffffffc0204558 <etext+0x4>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	52250513          	addi	a0,a0,1314 # ffffffffc0204578 <etext+0x24>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	7d7020ef          	jal	ra,ffffffffc020303c <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	443000ef          	jal	ra,ffffffffc0200cb0 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	69c010ef          	jal	ra,ffffffffc0201712 <swap_init>

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
ffffffffc02000ae:	070040ef          	jal	ra,ffffffffc020411e <vprintfmt>
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
ffffffffc02000e4:	03a040ef          	jal	ra,ffffffffc020411e <vprintfmt>
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
ffffffffc0200106:	3fe30313          	addi	t1,t1,1022 # ffffffffc0211500 <is_panic>
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
ffffffffc0200134:	45050513          	addi	a0,a0,1104 # ffffffffc0204580 <etext+0x2c>
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
ffffffffc020014a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0205eb0 <default_pmm_manager+0x438>
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
ffffffffc0200164:	44050513          	addi	a0,a0,1088 # ffffffffc02045a0 <etext+0x4c>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	44a50513          	addi	a0,a0,1098 # ffffffffc02045c0 <etext+0x6c>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	3d258593          	addi	a1,a1,978 # ffffffffc0204554 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	45650513          	addi	a0,a0,1110 # ffffffffc02045e0 <etext+0x8c>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eae58593          	addi	a1,a1,-338 # ffffffffc020a044 <edata>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	46250513          	addi	a0,a0,1122 # ffffffffc0204600 <etext+0xac>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3d658593          	addi	a1,a1,982 # ffffffffc0211580 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	46e50513          	addi	a0,a0,1134 # ffffffffc0204620 <etext+0xcc>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7c158593          	addi	a1,a1,1985 # ffffffffc021197f <end+0x3ff>
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
ffffffffc02001e4:	46050513          	addi	a0,a0,1120 # ffffffffc0204640 <etext+0xec>
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
ffffffffc02001f2:	48260613          	addi	a2,a2,1154 # ffffffffc0204670 <etext+0x11c>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	48e50513          	addi	a0,a0,1166 # ffffffffc0204688 <etext+0x134>
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
ffffffffc020020e:	49660613          	addi	a2,a2,1174 # ffffffffc02046a0 <etext+0x14c>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	4ae58593          	addi	a1,a1,1198 # ffffffffc02046c0 <etext+0x16c>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	4ae50513          	addi	a0,a0,1198 # ffffffffc02046c8 <etext+0x174>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	4b060613          	addi	a2,a2,1200 # ffffffffc02046d8 <etext+0x184>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	4d058593          	addi	a1,a1,1232 # ffffffffc0204700 <etext+0x1ac>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	49050513          	addi	a0,a0,1168 # ffffffffc02046c8 <etext+0x174>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	4cc60613          	addi	a2,a2,1228 # ffffffffc0204710 <etext+0x1bc>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	4e458593          	addi	a1,a1,1252 # ffffffffc0204730 <etext+0x1dc>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	47450513          	addi	a0,a0,1140 # ffffffffc02046c8 <etext+0x174>
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
ffffffffc0200292:	4b250513          	addi	a0,a0,1202 # ffffffffc0204740 <etext+0x1ec>
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
ffffffffc02002b4:	4b850513          	addi	a0,a0,1208 # ffffffffc0204768 <etext+0x214>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	50ac0c13          	addi	s8,s8,1290 # ffffffffc02047d0 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	34a90913          	addi	s2,s2,842 # ffffffffc0205618 <commands+0xe48>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	4ba48493          	addi	s1,s1,1210 # ffffffffc0204790 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	4b8b0b13          	addi	s6,s6,1208 # ffffffffc0204798 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	3d8a0a13          	addi	s4,s4,984 # ffffffffc02046c0 <etext+0x16c>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	1ac040ef          	jal	ra,ffffffffc02044a0 <readline>
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
ffffffffc020030e:	4c6d0d13          	addi	s10,s10,1222 # ffffffffc02047d0 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	53d030ef          	jal	ra,ffffffffc0204054 <strcmp>
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
ffffffffc020032c:	529030ef          	jal	ra,ffffffffc0204054 <strcmp>
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
ffffffffc020036a:	509030ef          	jal	ra,ffffffffc0204072 <strchr>
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
ffffffffc02003a8:	4cb030ef          	jal	ra,ffffffffc0204072 <strchr>
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
ffffffffc02003c6:	3f650513          	addi	a0,a0,1014 # ffffffffc02047b8 <etext+0x264>
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
ffffffffc02003e2:	c6a78793          	addi	a5,a5,-918 # ffffffffc020a048 <ide>
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
ffffffffc02003f6:	4a5030ef          	jal	ra,ffffffffc020409a <memcpy>
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
ffffffffc020040a:	c4250513          	addi	a0,a0,-958 # ffffffffc020a048 <ide>
                   size_t nsecs) {
ffffffffc020040e:	1141                	addi	sp,sp,-16
ffffffffc0200410:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	953e                	add	a0,a0,a5
ffffffffc0200414:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200418:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041a:	481030ef          	jal	ra,ffffffffc020409a <memcpy>
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
ffffffffc0200430:	0ef73223          	sd	a5,228(a4) # ffffffffc0211510 <timebase>
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
ffffffffc0200450:	3cc50513          	addi	a0,a0,972 # ffffffffc0204818 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0a07ba23          	sd	zero,180(a5) # ffffffffc0211508 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0ae7b783          	ld	a5,174(a5) # ffffffffc0211510 <timebase>
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
ffffffffc0200528:	31450513          	addi	a0,a0,788 # ffffffffc0204838 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	ff053503          	ld	a0,-16(a0) # ffffffffc0211520 <check_mm_struct>
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
ffffffffc0200550:	30c60613          	addi	a2,a2,780 # ffffffffc0204858 <commands+0x88>
ffffffffc0200554:	07900593          	li	a1,121
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	31850513          	addi	a0,a0,792 # ffffffffc0204870 <commands+0xa0>
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
ffffffffc020058e:	2fe50513          	addi	a0,a0,766 # ffffffffc0204888 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	30650513          	addi	a0,a0,774 # ffffffffc02048a0 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	31050513          	addi	a0,a0,784 # ffffffffc02048b8 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	31a50513          	addi	a0,a0,794 # ffffffffc02048d0 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	32450513          	addi	a0,a0,804 # ffffffffc02048e8 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	32e50513          	addi	a0,a0,814 # ffffffffc0204900 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	33850513          	addi	a0,a0,824 # ffffffffc0204918 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	34250513          	addi	a0,a0,834 # ffffffffc0204930 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	34c50513          	addi	a0,a0,844 # ffffffffc0204948 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	35650513          	addi	a0,a0,854 # ffffffffc0204960 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	36050513          	addi	a0,a0,864 # ffffffffc0204978 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	36a50513          	addi	a0,a0,874 # ffffffffc0204990 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	37450513          	addi	a0,a0,884 # ffffffffc02049a8 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	37e50513          	addi	a0,a0,894 # ffffffffc02049c0 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	38850513          	addi	a0,a0,904 # ffffffffc02049d8 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	39250513          	addi	a0,a0,914 # ffffffffc02049f0 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	39c50513          	addi	a0,a0,924 # ffffffffc0204a08 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	3a650513          	addi	a0,a0,934 # ffffffffc0204a20 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	3b050513          	addi	a0,a0,944 # ffffffffc0204a38 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	3ba50513          	addi	a0,a0,954 # ffffffffc0204a50 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	3c450513          	addi	a0,a0,964 # ffffffffc0204a68 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	3ce50513          	addi	a0,a0,974 # ffffffffc0204a80 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	3d850513          	addi	a0,a0,984 # ffffffffc0204a98 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	3e250513          	addi	a0,a0,994 # ffffffffc0204ab0 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204ac8 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	3f650513          	addi	a0,a0,1014 # ffffffffc0204ae0 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	40050513          	addi	a0,a0,1024 # ffffffffc0204af8 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	40a50513          	addi	a0,a0,1034 # ffffffffc0204b10 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	41450513          	addi	a0,a0,1044 # ffffffffc0204b28 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	41e50513          	addi	a0,a0,1054 # ffffffffc0204b40 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	42850513          	addi	a0,a0,1064 # ffffffffc0204b58 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	42e50513          	addi	a0,a0,1070 # ffffffffc0204b70 <commands+0x3a0>
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
ffffffffc020075a:	43250513          	addi	a0,a0,1074 # ffffffffc0204b88 <commands+0x3b8>
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
ffffffffc0200772:	43250513          	addi	a0,a0,1074 # ffffffffc0204ba0 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	43a50513          	addi	a0,a0,1082 # ffffffffc0204bb8 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	44250513          	addi	a0,a0,1090 # ffffffffc0204bd0 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	44650513          	addi	a0,a0,1094 # ffffffffc0204be8 <commands+0x418>
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
ffffffffc02007c2:	4f270713          	addi	a4,a4,1266 # ffffffffc0204cb0 <commands+0x4e0>
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
ffffffffc02007d4:	49050513          	addi	a0,a0,1168 # ffffffffc0204c60 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	46450513          	addi	a0,a0,1124 # ffffffffc0204c40 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	41850513          	addi	a0,a0,1048 # ffffffffc0204c00 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	42c50513          	addi	a0,a0,1068 # ffffffffc0204c20 <commands+0x450>
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
ffffffffc020080e:	cfe68693          	addi	a3,a3,-770 # ffffffffc0211508 <ticks>
ffffffffc0200812:	629c                	ld	a5,0(a3)
ffffffffc0200814:	06400713          	li	a4,100
ffffffffc0200818:	00011417          	auipc	s0,0x11
ffffffffc020081c:	d0040413          	addi	s0,s0,-768 # ffffffffc0211518 <num>
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
ffffffffc020084a:	44a50513          	addi	a0,a0,1098 # ffffffffc0204c90 <commands+0x4c0>
ffffffffc020084e:	86dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200852:	bdf5                	j	ffffffffc020074e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200854:	06400593          	li	a1,100
ffffffffc0200858:	00004517          	auipc	a0,0x4
ffffffffc020085c:	42850513          	addi	a0,a0,1064 # ffffffffc0204c80 <commands+0x4b0>
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
ffffffffc0200884:	61870713          	addi	a4,a4,1560 # ffffffffc0204e98 <commands+0x6c8>
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
ffffffffc0200896:	5ee50513          	addi	a0,a0,1518 # ffffffffc0204e80 <commands+0x6b0>
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
ffffffffc02008b8:	42c50513          	addi	a0,a0,1068 # ffffffffc0204ce0 <commands+0x510>
}
ffffffffc02008bc:	6442                	ld	s0,16(sp)
ffffffffc02008be:	60e2                	ld	ra,24(sp)
ffffffffc02008c0:	64a2                	ld	s1,8(sp)
ffffffffc02008c2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008c4:	ff6ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	43850513          	addi	a0,a0,1080 # ffffffffc0204d00 <commands+0x530>
ffffffffc02008d0:	b7f5                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	44e50513          	addi	a0,a0,1102 # ffffffffc0204d20 <commands+0x550>
ffffffffc02008da:	b7cd                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	45c50513          	addi	a0,a0,1116 # ffffffffc0204d38 <commands+0x568>
ffffffffc02008e4:	bfe1                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	46250513          	addi	a0,a0,1122 # ffffffffc0204d48 <commands+0x578>
ffffffffc02008ee:	b7f9                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	47850513          	addi	a0,a0,1144 # ffffffffc0204d68 <commands+0x598>
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
ffffffffc0200912:	47260613          	addi	a2,a2,1138 # ffffffffc0204d80 <commands+0x5b0>
ffffffffc0200916:	0cf00593          	li	a1,207
ffffffffc020091a:	00004517          	auipc	a0,0x4
ffffffffc020091e:	f5650513          	addi	a0,a0,-170 # ffffffffc0204870 <commands+0xa0>
ffffffffc0200922:	fe0ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	47a50513          	addi	a0,a0,1146 # ffffffffc0204da0 <commands+0x5d0>
ffffffffc020092e:	b779                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200930:	00004517          	auipc	a0,0x4
ffffffffc0200934:	48850513          	addi	a0,a0,1160 # ffffffffc0204db8 <commands+0x5e8>
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
ffffffffc0200952:	43260613          	addi	a2,a2,1074 # ffffffffc0204d80 <commands+0x5b0>
ffffffffc0200956:	0d900593          	li	a1,217
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	f1650513          	addi	a0,a0,-234 # ffffffffc0204870 <commands+0xa0>
ffffffffc0200962:	fa0ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204dd0 <commands+0x600>
ffffffffc020096e:	b7b9                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	48050513          	addi	a0,a0,1152 # ffffffffc0204df0 <commands+0x620>
ffffffffc0200978:	b791                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	49650513          	addi	a0,a0,1174 # ffffffffc0204e10 <commands+0x640>
ffffffffc0200982:	bf2d                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204e30 <commands+0x660>
ffffffffc020098c:	bf05                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	4c250513          	addi	a0,a0,1218 # ffffffffc0204e50 <commands+0x680>
ffffffffc0200996:	b71d                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	4d050513          	addi	a0,a0,1232 # ffffffffc0204e68 <commands+0x698>
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
ffffffffc02009bc:	3c860613          	addi	a2,a2,968 # ffffffffc0204d80 <commands+0x5b0>
ffffffffc02009c0:	0ef00593          	li	a1,239
ffffffffc02009c4:	00004517          	auipc	a0,0x4
ffffffffc02009c8:	eac50513          	addi	a0,a0,-340 # ffffffffc0204870 <commands+0xa0>
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
ffffffffc02009e8:	39c60613          	addi	a2,a2,924 # ffffffffc0204d80 <commands+0x5b0>
ffffffffc02009ec:	0f600593          	li	a1,246
ffffffffc02009f0:	00004517          	auipc	a0,0x4
ffffffffc02009f4:	e8050513          	addi	a0,a0,-384 # ffffffffc0204870 <commands+0xa0>
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
ffffffffc0200ad6:	40668693          	addi	a3,a3,1030 # ffffffffc0204ed8 <commands+0x708>
ffffffffc0200ada:	00004617          	auipc	a2,0x4
ffffffffc0200ade:	41e60613          	addi	a2,a2,1054 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0200ae2:	08000593          	li	a1,128
ffffffffc0200ae6:	00004517          	auipc	a0,0x4
ffffffffc0200aea:	42a50513          	addi	a0,a0,1066 # ffffffffc0204f10 <commands+0x740>
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
ffffffffc0200afe:	200030ef          	jal	ra,ffffffffc0203cfe <kmalloc>
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
ffffffffc0200b1a:	a327a783          	lw	a5,-1486(a5) # ffffffffc0211548 <swap_init_ok>
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
ffffffffc0200b2e:	256010ef          	jal	ra,ffffffffc0201d84 <swap_init_mm>
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
ffffffffc0200b50:	1ae030ef          	jal	ra,ffffffffc0203cfe <kmalloc>
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
ffffffffc0200c1e:	30668693          	addi	a3,a3,774 # ffffffffc0204f20 <commands+0x750>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	2d660613          	addi	a2,a2,726 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0200c2a:	08700593          	li	a1,135
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	2e250513          	addi	a0,a0,738 # ffffffffc0204f10 <commands+0x740>
ffffffffc0200c36:	cccff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	32668693          	addi	a3,a3,806 # ffffffffc0204f60 <commands+0x790>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	2b660613          	addi	a2,a2,694 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0200c4a:	07f00593          	li	a1,127
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	2c250513          	addi	a0,a0,706 # ffffffffc0204f10 <commands+0x740>
ffffffffc0200c56:	cacff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c5a:	00004697          	auipc	a3,0x4
ffffffffc0200c5e:	2e668693          	addi	a3,a3,742 # ffffffffc0204f40 <commands+0x770>
ffffffffc0200c62:	00004617          	auipc	a2,0x4
ffffffffc0200c66:	29660613          	addi	a2,a2,662 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0200c6a:	07e00593          	li	a1,126
ffffffffc0200c6e:	00004517          	auipc	a0,0x4
ffffffffc0200c72:	2a250513          	addi	a0,a0,674 # ffffffffc0204f10 <commands+0x740>
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
ffffffffc0200c96:	122030ef          	jal	ra,ffffffffc0203db8 <kfree>
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
ffffffffc0200cac:	10c0306f          	j	ffffffffc0203db8 <kfree>

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
ffffffffc0200cc4:	755010ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
ffffffffc0200cc8:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200cca:	74f010ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
ffffffffc0200cce:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200cd0:	03000513          	li	a0,48
ffffffffc0200cd4:	02a030ef          	jal	ra,ffffffffc0203cfe <kmalloc>
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
ffffffffc0200cf0:	85c7a783          	lw	a5,-1956(a5) # ffffffffc0211548 <swap_init_ok>
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
ffffffffc0200d18:	7e7020ef          	jal	ra,ffffffffc0203cfe <kmalloc>
ffffffffc0200d1c:	85aa                	mv	a1,a0
ffffffffc0200d1e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d22:	f165                	bnez	a0,ffffffffc0200d02 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0200d24:	00004697          	auipc	a3,0x4
ffffffffc0200d28:	48c68693          	addi	a3,a3,1164 # ffffffffc02051b0 <commands+0x9e0>
ffffffffc0200d2c:	00004617          	auipc	a2,0x4
ffffffffc0200d30:	1cc60613          	addi	a2,a2,460 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0200d34:	0d100593          	li	a1,209
ffffffffc0200d38:	00004517          	auipc	a0,0x4
ffffffffc0200d3c:	1d850513          	addi	a0,a0,472 # ffffffffc0204f10 <commands+0x740>
ffffffffc0200d40:	bc2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d44:	040010ef          	jal	ra,ffffffffc0201d84 <swap_init_mm>
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
ffffffffc0200d6c:	793020ef          	jal	ra,ffffffffc0203cfe <kmalloc>
ffffffffc0200d70:	85aa                	mv	a1,a0
ffffffffc0200d72:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d76:	fd79                	bnez	a0,ffffffffc0200d54 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0200d78:	00004697          	auipc	a3,0x4
ffffffffc0200d7c:	43868693          	addi	a3,a3,1080 # ffffffffc02051b0 <commands+0x9e0>
ffffffffc0200d80:	00004617          	auipc	a2,0x4
ffffffffc0200d84:	17860613          	addi	a2,a2,376 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0200d88:	0d700593          	li	a1,215
ffffffffc0200d8c:	00004517          	auipc	a0,0x4
ffffffffc0200d90:	18450513          	addi	a0,a0,388 # ffffffffc0204f10 <commands+0x740>
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
ffffffffc0200e50:	23450513          	addi	a0,a0,564 # ffffffffc0205080 <commands+0x8b0>
ffffffffc0200e54:	a66ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e58:	00004697          	auipc	a3,0x4
ffffffffc0200e5c:	25068693          	addi	a3,a3,592 # ffffffffc02050a8 <commands+0x8d8>
ffffffffc0200e60:	00004617          	auipc	a2,0x4
ffffffffc0200e64:	09860613          	addi	a2,a2,152 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0200e68:	0f900593          	li	a1,249
ffffffffc0200e6c:	00004517          	auipc	a0,0x4
ffffffffc0200e70:	0a450513          	addi	a0,a0,164 # ffffffffc0204f10 <commands+0x740>
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
ffffffffc0200e8e:	72b020ef          	jal	ra,ffffffffc0203db8 <kfree>
    return listelm->next;
ffffffffc0200e92:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200e94:	fea496e3          	bne	s1,a0,ffffffffc0200e80 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200e98:	03000593          	li	a1,48
ffffffffc0200e9c:	8526                	mv	a0,s1
ffffffffc0200e9e:	71b020ef          	jal	ra,ffffffffc0203db8 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200ea2:	577010ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
ffffffffc0200ea6:	3caa1163          	bne	s4,a0,ffffffffc0201268 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200eaa:	00004517          	auipc	a0,0x4
ffffffffc0200eae:	23e50513          	addi	a0,a0,574 # ffffffffc02050e8 <commands+0x918>
ffffffffc0200eb2:	a08ff0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200eb6:	563010ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
ffffffffc0200eba:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ebc:	03000513          	li	a0,48
ffffffffc0200ec0:	63f020ef          	jal	ra,ffffffffc0203cfe <kmalloc>
ffffffffc0200ec4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ec6:	2a050163          	beqz	a0,ffffffffc0201168 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200eca:	00010797          	auipc	a5,0x10
ffffffffc0200ece:	67e7a783          	lw	a5,1662(a5) # ffffffffc0211548 <swap_init_ok>
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
ffffffffc0200eee:	66e93903          	ld	s2,1646(s2) # ffffffffc0211558 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200ef2:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200ef6:	00010717          	auipc	a4,0x10
ffffffffc0200efa:	62873523          	sd	s0,1578(a4) # ffffffffc0211520 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200efe:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200f02:	24079363          	bnez	a5,ffffffffc0201148 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f06:	03000513          	li	a0,48
ffffffffc0200f0a:	5f5020ef          	jal	ra,ffffffffc0203cfe <kmalloc>
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
ffffffffc0200f70:	733010ef          	jal	ra,ffffffffc0202ea2 <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f74:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f78:	00010717          	auipc	a4,0x10
ffffffffc0200f7c:	5e873703          	ld	a4,1512(a4) # ffffffffc0211560 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f80:	078a                	slli	a5,a5,0x2
ffffffffc0200f82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f84:	26e7f663          	bgeu	a5,a4,ffffffffc02011f0 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f88:	00005717          	auipc	a4,0x5
ffffffffc0200f8c:	3e073703          	ld	a4,992(a4) # ffffffffc0206368 <nbase>
ffffffffc0200f90:	8f99                	sub	a5,a5,a4
ffffffffc0200f92:	00379713          	slli	a4,a5,0x3
ffffffffc0200f96:	97ba                	add	a5,a5,a4
ffffffffc0200f98:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f9a:	00010517          	auipc	a0,0x10
ffffffffc0200f9e:	5ce53503          	ld	a0,1486(a0) # ffffffffc0211568 <pages>
ffffffffc0200fa2:	953e                	add	a0,a0,a5
ffffffffc0200fa4:	4585                	li	a1,1
ffffffffc0200fa6:	433010ef          	jal	ra,ffffffffc0202bd8 <free_pages>
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
ffffffffc0200fc6:	5f3020ef          	jal	ra,ffffffffc0203db8 <kfree>
    return listelm->next;
ffffffffc0200fca:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fcc:	fea416e3          	bne	s0,a0,ffffffffc0200fb8 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fd0:	03000593          	li	a1,48
ffffffffc0200fd4:	8522                	mv	a0,s0
ffffffffc0200fd6:	5e3020ef          	jal	ra,ffffffffc0203db8 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200fda:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0200fdc:	00010797          	auipc	a5,0x10
ffffffffc0200fe0:	5407b223          	sd	zero,1348(a5) # ffffffffc0211520 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fe4:	435010ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
ffffffffc0200fe8:	22a49063          	bne	s1,a0,ffffffffc0201208 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200fec:	00004517          	auipc	a0,0x4
ffffffffc0200ff0:	18c50513          	addi	a0,a0,396 # ffffffffc0205178 <commands+0x9a8>
ffffffffc0200ff4:	8c6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200ff8:	421010ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
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
ffffffffc0201018:	18450513          	addi	a0,a0,388 # ffffffffc0205198 <commands+0x9c8>
}
ffffffffc020101c:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020101e:	89cff06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201022:	563000ef          	jal	ra,ffffffffc0201d84 <swap_init_mm>
ffffffffc0201026:	b5d1                	j	ffffffffc0200eea <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	f7068693          	addi	a3,a3,-144 # ffffffffc0204f98 <commands+0x7c8>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	ec860613          	addi	a2,a2,-312 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201038:	0e000593          	li	a1,224
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	ed450513          	addi	a0,a0,-300 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201044:	8beff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	00868693          	addi	a3,a3,8 # ffffffffc0205050 <commands+0x880>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	ea860613          	addi	a2,a2,-344 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201058:	0f100593          	li	a1,241
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	eb450513          	addi	a0,a0,-332 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201064:	89eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	fb868693          	addi	a3,a3,-72 # ffffffffc0205020 <commands+0x850>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	e8860613          	addi	a2,a2,-376 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201078:	0f000593          	li	a1,240
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	e9450513          	addi	a0,a0,-364 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201084:	87eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	ef868693          	addi	a3,a3,-264 # ffffffffc0204f80 <commands+0x7b0>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	e6860613          	addi	a2,a2,-408 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201098:	0de00593          	li	a1,222
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	e7450513          	addi	a0,a0,-396 # ffffffffc0204f10 <commands+0x740>
ffffffffc02010a4:	85eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	f2868693          	addi	a3,a3,-216 # ffffffffc0204fd0 <commands+0x800>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	e4860613          	addi	a2,a2,-440 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02010b8:	0e600593          	li	a1,230
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	e5450513          	addi	a0,a0,-428 # ffffffffc0204f10 <commands+0x740>
ffffffffc02010c4:	83eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	f1868693          	addi	a3,a3,-232 # ffffffffc0204fe0 <commands+0x810>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	e2860613          	addi	a2,a2,-472 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02010d8:	0e800593          	li	a1,232
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	e3450513          	addi	a0,a0,-460 # ffffffffc0204f10 <commands+0x740>
ffffffffc02010e4:	81eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	f0868693          	addi	a3,a3,-248 # ffffffffc0204ff0 <commands+0x820>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	e0860613          	addi	a2,a2,-504 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02010f8:	0ea00593          	li	a1,234
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	e1450513          	addi	a0,a0,-492 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201104:	ffffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	ef868693          	addi	a3,a3,-264 # ffffffffc0205000 <commands+0x830>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	de860613          	addi	a2,a2,-536 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201118:	0ec00593          	li	a1,236
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	df450513          	addi	a0,a0,-524 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201124:	fdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	ee868693          	addi	a3,a3,-280 # ffffffffc0205010 <commands+0x840>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	dc860613          	addi	a2,a2,-568 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201138:	0ee00593          	li	a1,238
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	dd450513          	addi	a0,a0,-556 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201144:	fbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	fc068693          	addi	a3,a3,-64 # ffffffffc0205108 <commands+0x938>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	da860613          	addi	a2,a2,-600 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201158:	11000593          	li	a1,272
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	db450513          	addi	a0,a0,-588 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201164:	f9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201168:	00004697          	auipc	a3,0x4
ffffffffc020116c:	05868693          	addi	a3,a3,88 # ffffffffc02051c0 <commands+0x9f0>
ffffffffc0201170:	00004617          	auipc	a2,0x4
ffffffffc0201174:	d8860613          	addi	a2,a2,-632 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201178:	10d00593          	li	a1,269
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	d9450513          	addi	a0,a0,-620 # ffffffffc0204f10 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201184:	00010797          	auipc	a5,0x10
ffffffffc0201188:	3807be23          	sd	zero,924(a5) # ffffffffc0211520 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020118c:	f77fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0201190:	00004697          	auipc	a3,0x4
ffffffffc0201194:	02068693          	addi	a3,a3,32 # ffffffffc02051b0 <commands+0x9e0>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	d6060613          	addi	a2,a2,-672 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02011a0:	11400593          	li	a1,276
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	d6c50513          	addi	a0,a0,-660 # ffffffffc0204f10 <commands+0x740>
ffffffffc02011ac:	f57fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	f6868693          	addi	a3,a3,-152 # ffffffffc0205118 <commands+0x948>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	d4060613          	addi	a2,a2,-704 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02011c0:	11900593          	li	a1,281
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	d4c50513          	addi	a0,a0,-692 # ffffffffc0204f10 <commands+0x740>
ffffffffc02011cc:	f37fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02011d0:	00004697          	auipc	a3,0x4
ffffffffc02011d4:	f6868693          	addi	a3,a3,-152 # ffffffffc0205138 <commands+0x968>
ffffffffc02011d8:	00004617          	auipc	a2,0x4
ffffffffc02011dc:	d2060613          	addi	a2,a2,-736 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02011e0:	12300593          	li	a1,291
ffffffffc02011e4:	00004517          	auipc	a0,0x4
ffffffffc02011e8:	d2c50513          	addi	a0,a0,-724 # ffffffffc0204f10 <commands+0x740>
ffffffffc02011ec:	f17fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	f5860613          	addi	a2,a2,-168 # ffffffffc0205148 <commands+0x978>
ffffffffc02011f8:	06500593          	li	a1,101
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205168 <commands+0x998>
ffffffffc0201204:	efffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	eb868693          	addi	a3,a3,-328 # ffffffffc02050c0 <commands+0x8f0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	ce860613          	addi	a2,a2,-792 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201218:	13100593          	li	a1,305
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	cf450513          	addi	a0,a0,-780 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201224:	edffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	e9868693          	addi	a3,a3,-360 # ffffffffc02050c0 <commands+0x8f0>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	cc860613          	addi	a2,a2,-824 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201238:	0c000593          	li	a1,192
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	cd450513          	addi	a0,a0,-812 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201244:	ebffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	f9068693          	addi	a3,a3,-112 # ffffffffc02051d8 <commands+0xa08>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	ca860613          	addi	a2,a2,-856 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201258:	0ca00593          	li	a1,202
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	cb450513          	addi	a0,a0,-844 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201264:	e9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201268:	00004697          	auipc	a3,0x4
ffffffffc020126c:	e5868693          	addi	a3,a3,-424 # ffffffffc02050c0 <commands+0x8f0>
ffffffffc0201270:	00004617          	auipc	a2,0x4
ffffffffc0201274:	c8860613          	addi	a2,a2,-888 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201278:	0fe00593          	li	a1,254
ffffffffc020127c:	00004517          	auipc	a0,0x4
ffffffffc0201280:	c9450513          	addi	a0,a0,-876 # ffffffffc0204f10 <commands+0x740>
ffffffffc0201284:	e7ffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201288 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201288:	7139                	addi	sp,sp,-64
ffffffffc020128a:	ec4e                	sd	s3,24(sp)

    // 如果启用了测试交换LRU（Least Recently Used，最少最近使用）功能
    if(test_swap_lru) {
ffffffffc020128c:	00009997          	auipc	s3,0x9
ffffffffc0201290:	db498993          	addi	s3,s3,-588 # ffffffffc020a040 <test_swap_lru>
ffffffffc0201294:	0009a783          	lw	a5,0(s3)
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201298:	f822                	sd	s0,48(sp)
ffffffffc020129a:	f426                	sd	s1,40(sp)
ffffffffc020129c:	fc06                	sd	ra,56(sp)
ffffffffc020129e:	f04a                	sd	s2,32(sp)
ffffffffc02012a0:	84aa                	mv	s1,a0
ffffffffc02012a2:	8432                	mv	s0,a2
    if(test_swap_lru) {
ffffffffc02012a4:	cb99                	beqz	a5,ffffffffc02012ba <do_pgfault+0x32>
        pte_t* temp = NULL;
        // 获取地址addr对应的页表项（pte），并检查是否存在有效的映射（PTE_V表示有效，PTE_R表示可读）
        temp = get_pte(mm->pgdir, addr, 0);
ffffffffc02012a6:	6d08                	ld	a0,24(a0)
ffffffffc02012a8:	892e                	mv	s2,a1
ffffffffc02012aa:	4601                	li	a2,0
ffffffffc02012ac:	85a2                	mv	a1,s0
ffffffffc02012ae:	1a5010ef          	jal	ra,ffffffffc0202c52 <get_pte>
        if(temp != NULL && (*temp & (PTE_V | PTE_R))) {
ffffffffc02012b2:	c501                	beqz	a0,ffffffffc02012ba <do_pgfault+0x32>
ffffffffc02012b4:	611c                	ld	a5,0(a0)
ffffffffc02012b6:	8b8d                	andi	a5,a5,3
ffffffffc02012b8:	e7dd                	bnez	a5,ffffffffc0201366 <do_pgfault+0xde>
        }
    }

    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02012ba:	85a2                	mv	a1,s0
ffffffffc02012bc:	8526                	mv	a0,s1
ffffffffc02012be:	8adff0ef          	jal	ra,ffffffffc0200b6a <find_vma>

    pgfault_num++;
ffffffffc02012c2:	00010797          	auipc	a5,0x10
ffffffffc02012c6:	2667a783          	lw	a5,614(a5) # ffffffffc0211528 <pgfault_num>
ffffffffc02012ca:	2785                	addiw	a5,a5,1
ffffffffc02012cc:	00010717          	auipc	a4,0x10
ffffffffc02012d0:	24f72e23          	sw	a5,604(a4) # ffffffffc0211528 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02012d4:	c545                	beqz	a0,ffffffffc020137c <do_pgfault+0xf4>
ffffffffc02012d6:	651c                	ld	a5,8(a0)
ffffffffc02012d8:	0af46263          	bltu	s0,a5,ffffffffc020137c <do_pgfault+0xf4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012dc:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02012de:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012e0:	8b89                	andi	a5,a5,2
ffffffffc02012e2:	c391                	beqz	a5,ffffffffc02012e6 <do_pgfault+0x5e>
        perm |= (PTE_R | PTE_W);
ffffffffc02012e4:	4959                	li	s2,22
    }

    // 如果启用了测试交换LRU功能，去除PTE_R权限
    if(test_swap_lru) {
ffffffffc02012e6:	0009a783          	lw	a5,0(s3)
ffffffffc02012ea:	ebb9                	bnez	a5,ffffffffc0201340 <do_pgfault+0xb8>
        perm &= ~PTE_R;  // 去掉读权限
    }

    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012ec:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012ee:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012f0:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012f2:	85a2                	mv	a1,s0
ffffffffc02012f4:	4605                	li	a2,1
ffffffffc02012f6:	15d010ef          	jal	ra,ffffffffc0202c52 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02012fa:	610c                	ld	a1,0(a0)
ffffffffc02012fc:	c5a9                	beqz	a1,ffffffffc0201346 <do_pgfault+0xbe>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02012fe:	00010797          	auipc	a5,0x10
ffffffffc0201302:	24a7a783          	lw	a5,586(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0201306:	c7c1                	beqz	a5,ffffffffc020138e <do_pgfault+0x106>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0201308:	85a2                	mv	a1,s0
ffffffffc020130a:	0030                	addi	a2,sp,8
ffffffffc020130c:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc020130e:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0201310:	3a1000ef          	jal	ra,ffffffffc0201eb0 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0201314:	65a2                	ld	a1,8(sp)
ffffffffc0201316:	6c88                	ld	a0,24(s1)
ffffffffc0201318:	86ca                	mv	a3,s2
ffffffffc020131a:	8622                	mv	a2,s0
ffffffffc020131c:	421010ef          	jal	ra,ffffffffc0202f3c <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0201320:	6622                	ld	a2,8(sp)
ffffffffc0201322:	4685                	li	a3,1
ffffffffc0201324:	85a2                	mv	a1,s0
ffffffffc0201326:	8526                	mv	a0,s1
ffffffffc0201328:	269000ef          	jal	ra,ffffffffc0201d90 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc020132c:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc020132e:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0201330:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0201332:	70e2                	ld	ra,56(sp)
ffffffffc0201334:	7442                	ld	s0,48(sp)
ffffffffc0201336:	74a2                	ld	s1,40(sp)
ffffffffc0201338:	7902                	ld	s2,32(sp)
ffffffffc020133a:	69e2                	ld	s3,24(sp)
ffffffffc020133c:	6121                	addi	sp,sp,64
ffffffffc020133e:	8082                	ret
        perm &= ~PTE_R;  // 去掉读权限
ffffffffc0201340:	ffd97913          	andi	s2,s2,-3
ffffffffc0201344:	b765                	j	ffffffffc02012ec <do_pgfault+0x64>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {//进行分配和映射，应对pte为0的情况
ffffffffc0201346:	6c88                	ld	a0,24(s1)
ffffffffc0201348:	864a                	mv	a2,s2
ffffffffc020134a:	85a2                	mv	a1,s0
ffffffffc020134c:	0fb020ef          	jal	ra,ffffffffc0203c46 <pgdir_alloc_page>
ffffffffc0201350:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201352:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {//进行分配和映射，应对pte为0的情况
ffffffffc0201354:	fff9                	bnez	a5,ffffffffc0201332 <do_pgfault+0xaa>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201356:	00004517          	auipc	a0,0x4
ffffffffc020135a:	ec250513          	addi	a0,a0,-318 # ffffffffc0205218 <commands+0xa48>
ffffffffc020135e:	d5dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201362:	5571                	li	a0,-4
            goto failed;
ffffffffc0201364:	b7f9                	j	ffffffffc0201332 <do_pgfault+0xaa>
            return lru_pgfault(mm, error_code, addr);
ffffffffc0201366:	8622                	mv	a2,s0
}
ffffffffc0201368:	7442                	ld	s0,48(sp)
ffffffffc020136a:	70e2                	ld	ra,56(sp)
ffffffffc020136c:	69e2                	ld	s3,24(sp)
            return lru_pgfault(mm, error_code, addr);
ffffffffc020136e:	85ca                	mv	a1,s2
ffffffffc0201370:	8526                	mv	a0,s1
}
ffffffffc0201372:	7902                	ld	s2,32(sp)
ffffffffc0201374:	74a2                	ld	s1,40(sp)
ffffffffc0201376:	6121                	addi	sp,sp,64
            return lru_pgfault(mm, error_code, addr);
ffffffffc0201378:	68a0106f          	j	ffffffffc0202a02 <lru_pgfault>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020137c:	85a2                	mv	a1,s0
ffffffffc020137e:	00004517          	auipc	a0,0x4
ffffffffc0201382:	e6a50513          	addi	a0,a0,-406 # ffffffffc02051e8 <commands+0xa18>
ffffffffc0201386:	d35fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc020138a:	5575                	li	a0,-3
        goto failed;
ffffffffc020138c:	b75d                	j	ffffffffc0201332 <do_pgfault+0xaa>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020138e:	00004517          	auipc	a0,0x4
ffffffffc0201392:	eb250513          	addi	a0,a0,-334 # ffffffffc0205240 <commands+0xa70>
ffffffffc0201396:	d25fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc020139a:	5571                	li	a0,-4
            goto failed;
ffffffffc020139c:	bf59                	j	ffffffffc0201332 <do_pgfault+0xaa>

ffffffffc020139e <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020139e:	00010797          	auipc	a5,0x10
ffffffffc02013a2:	caa78793          	addi	a5,a5,-854 # ffffffffc0211048 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc02013a6:	f51c                	sd	a5,40(a0)
ffffffffc02013a8:	e79c                	sd	a5,8(a5)
ffffffffc02013aa:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc02013ac:	00010717          	auipc	a4,0x10
ffffffffc02013b0:	18f73223          	sd	a5,388(a4) # ffffffffc0211530 <curr_ptr>
     return 0;
}
ffffffffc02013b4:	4501                	li	a0,0
ffffffffc02013b6:	8082                	ret

ffffffffc02013b8 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02013b8:	4501                	li	a0,0
ffffffffc02013ba:	8082                	ret

ffffffffc02013bc <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02013bc:	4501                	li	a0,0
ffffffffc02013be:	8082                	ret

ffffffffc02013c0 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02013c0:	4501                	li	a0,0
ffffffffc02013c2:	8082                	ret

ffffffffc02013c4 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02013c4:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02013c6:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02013c8:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02013ca:	678d                	lui	a5,0x3
ffffffffc02013cc:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02013d0:	00010697          	auipc	a3,0x10
ffffffffc02013d4:	1586a683          	lw	a3,344(a3) # ffffffffc0211528 <pgfault_num>
ffffffffc02013d8:	4711                	li	a4,4
ffffffffc02013da:	0ae69363          	bne	a3,a4,ffffffffc0201480 <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02013de:	6705                	lui	a4,0x1
ffffffffc02013e0:	4629                	li	a2,10
ffffffffc02013e2:	00010797          	auipc	a5,0x10
ffffffffc02013e6:	14678793          	addi	a5,a5,326 # ffffffffc0211528 <pgfault_num>
ffffffffc02013ea:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02013ee:	4398                	lw	a4,0(a5)
ffffffffc02013f0:	2701                	sext.w	a4,a4
ffffffffc02013f2:	20d71763          	bne	a4,a3,ffffffffc0201600 <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02013f6:	6691                	lui	a3,0x4
ffffffffc02013f8:	4635                	li	a2,13
ffffffffc02013fa:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02013fe:	4394                	lw	a3,0(a5)
ffffffffc0201400:	2681                	sext.w	a3,a3
ffffffffc0201402:	1ce69f63          	bne	a3,a4,ffffffffc02015e0 <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201406:	6709                	lui	a4,0x2
ffffffffc0201408:	462d                	li	a2,11
ffffffffc020140a:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020140e:	4398                	lw	a4,0(a5)
ffffffffc0201410:	2701                	sext.w	a4,a4
ffffffffc0201412:	1ad71763          	bne	a4,a3,ffffffffc02015c0 <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201416:	6715                	lui	a4,0x5
ffffffffc0201418:	46b9                	li	a3,14
ffffffffc020141a:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020141e:	4398                	lw	a4,0(a5)
ffffffffc0201420:	4695                	li	a3,5
ffffffffc0201422:	2701                	sext.w	a4,a4
ffffffffc0201424:	16d71e63          	bne	a4,a3,ffffffffc02015a0 <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc0201428:	4394                	lw	a3,0(a5)
ffffffffc020142a:	2681                	sext.w	a3,a3
ffffffffc020142c:	14e69a63          	bne	a3,a4,ffffffffc0201580 <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc0201430:	4398                	lw	a4,0(a5)
ffffffffc0201432:	2701                	sext.w	a4,a4
ffffffffc0201434:	12d71663          	bne	a4,a3,ffffffffc0201560 <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc0201438:	4394                	lw	a3,0(a5)
ffffffffc020143a:	2681                	sext.w	a3,a3
ffffffffc020143c:	10e69263          	bne	a3,a4,ffffffffc0201540 <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc0201440:	4398                	lw	a4,0(a5)
ffffffffc0201442:	2701                	sext.w	a4,a4
ffffffffc0201444:	0cd71e63          	bne	a4,a3,ffffffffc0201520 <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc0201448:	4394                	lw	a3,0(a5)
ffffffffc020144a:	2681                	sext.w	a3,a3
ffffffffc020144c:	0ae69a63          	bne	a3,a4,ffffffffc0201500 <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201450:	6715                	lui	a4,0x5
ffffffffc0201452:	46b9                	li	a3,14
ffffffffc0201454:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0201458:	4398                	lw	a4,0(a5)
ffffffffc020145a:	4695                	li	a3,5
ffffffffc020145c:	2701                	sext.w	a4,a4
ffffffffc020145e:	08d71163          	bne	a4,a3,ffffffffc02014e0 <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201462:	6705                	lui	a4,0x1
ffffffffc0201464:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201468:	4729                	li	a4,10
ffffffffc020146a:	04e69b63          	bne	a3,a4,ffffffffc02014c0 <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc020146e:	439c                	lw	a5,0(a5)
ffffffffc0201470:	4719                	li	a4,6
ffffffffc0201472:	2781                	sext.w	a5,a5
ffffffffc0201474:	02e79663          	bne	a5,a4,ffffffffc02014a0 <_clock_check_swap+0xdc>
}
ffffffffc0201478:	60a2                	ld	ra,8(sp)
ffffffffc020147a:	4501                	li	a0,0
ffffffffc020147c:	0141                	addi	sp,sp,16
ffffffffc020147e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201480:	00004697          	auipc	a3,0x4
ffffffffc0201484:	de868693          	addi	a3,a3,-536 # ffffffffc0205268 <commands+0xa98>
ffffffffc0201488:	00004617          	auipc	a2,0x4
ffffffffc020148c:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201490:	08b00593          	li	a1,139
ffffffffc0201494:	00004517          	auipc	a0,0x4
ffffffffc0201498:	de450513          	addi	a0,a0,-540 # ffffffffc0205278 <commands+0xaa8>
ffffffffc020149c:	c67fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc02014a0:	00004697          	auipc	a3,0x4
ffffffffc02014a4:	e2868693          	addi	a3,a3,-472 # ffffffffc02052c8 <commands+0xaf8>
ffffffffc02014a8:	00004617          	auipc	a2,0x4
ffffffffc02014ac:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02014b0:	0a200593          	li	a1,162
ffffffffc02014b4:	00004517          	auipc	a0,0x4
ffffffffc02014b8:	dc450513          	addi	a0,a0,-572 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02014bc:	c47fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02014c0:	00004697          	auipc	a3,0x4
ffffffffc02014c4:	de068693          	addi	a3,a3,-544 # ffffffffc02052a0 <commands+0xad0>
ffffffffc02014c8:	00004617          	auipc	a2,0x4
ffffffffc02014cc:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02014d0:	0a000593          	li	a1,160
ffffffffc02014d4:	00004517          	auipc	a0,0x4
ffffffffc02014d8:	da450513          	addi	a0,a0,-604 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02014dc:	c27fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02014e0:	00004697          	auipc	a3,0x4
ffffffffc02014e4:	db068693          	addi	a3,a3,-592 # ffffffffc0205290 <commands+0xac0>
ffffffffc02014e8:	00004617          	auipc	a2,0x4
ffffffffc02014ec:	a1060613          	addi	a2,a2,-1520 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02014f0:	09f00593          	li	a1,159
ffffffffc02014f4:	00004517          	auipc	a0,0x4
ffffffffc02014f8:	d8450513          	addi	a0,a0,-636 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02014fc:	c07fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201500:	00004697          	auipc	a3,0x4
ffffffffc0201504:	d9068693          	addi	a3,a3,-624 # ffffffffc0205290 <commands+0xac0>
ffffffffc0201508:	00004617          	auipc	a2,0x4
ffffffffc020150c:	9f060613          	addi	a2,a2,-1552 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201510:	09d00593          	li	a1,157
ffffffffc0201514:	00004517          	auipc	a0,0x4
ffffffffc0201518:	d6450513          	addi	a0,a0,-668 # ffffffffc0205278 <commands+0xaa8>
ffffffffc020151c:	be7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201520:	00004697          	auipc	a3,0x4
ffffffffc0201524:	d7068693          	addi	a3,a3,-656 # ffffffffc0205290 <commands+0xac0>
ffffffffc0201528:	00004617          	auipc	a2,0x4
ffffffffc020152c:	9d060613          	addi	a2,a2,-1584 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201530:	09b00593          	li	a1,155
ffffffffc0201534:	00004517          	auipc	a0,0x4
ffffffffc0201538:	d4450513          	addi	a0,a0,-700 # ffffffffc0205278 <commands+0xaa8>
ffffffffc020153c:	bc7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201540:	00004697          	auipc	a3,0x4
ffffffffc0201544:	d5068693          	addi	a3,a3,-688 # ffffffffc0205290 <commands+0xac0>
ffffffffc0201548:	00004617          	auipc	a2,0x4
ffffffffc020154c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201550:	09900593          	li	a1,153
ffffffffc0201554:	00004517          	auipc	a0,0x4
ffffffffc0201558:	d2450513          	addi	a0,a0,-732 # ffffffffc0205278 <commands+0xaa8>
ffffffffc020155c:	ba7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201560:	00004697          	auipc	a3,0x4
ffffffffc0201564:	d3068693          	addi	a3,a3,-720 # ffffffffc0205290 <commands+0xac0>
ffffffffc0201568:	00004617          	auipc	a2,0x4
ffffffffc020156c:	99060613          	addi	a2,a2,-1648 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201570:	09700593          	li	a1,151
ffffffffc0201574:	00004517          	auipc	a0,0x4
ffffffffc0201578:	d0450513          	addi	a0,a0,-764 # ffffffffc0205278 <commands+0xaa8>
ffffffffc020157c:	b87fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201580:	00004697          	auipc	a3,0x4
ffffffffc0201584:	d1068693          	addi	a3,a3,-752 # ffffffffc0205290 <commands+0xac0>
ffffffffc0201588:	00004617          	auipc	a2,0x4
ffffffffc020158c:	97060613          	addi	a2,a2,-1680 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201590:	09500593          	li	a1,149
ffffffffc0201594:	00004517          	auipc	a0,0x4
ffffffffc0201598:	ce450513          	addi	a0,a0,-796 # ffffffffc0205278 <commands+0xaa8>
ffffffffc020159c:	b67fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02015a0:	00004697          	auipc	a3,0x4
ffffffffc02015a4:	cf068693          	addi	a3,a3,-784 # ffffffffc0205290 <commands+0xac0>
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	95060613          	addi	a2,a2,-1712 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02015b0:	09300593          	li	a1,147
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	cc450513          	addi	a0,a0,-828 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02015bc:	b47fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc02015c0:	00004697          	auipc	a3,0x4
ffffffffc02015c4:	ca868693          	addi	a3,a3,-856 # ffffffffc0205268 <commands+0xa98>
ffffffffc02015c8:	00004617          	auipc	a2,0x4
ffffffffc02015cc:	93060613          	addi	a2,a2,-1744 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02015d0:	09100593          	li	a1,145
ffffffffc02015d4:	00004517          	auipc	a0,0x4
ffffffffc02015d8:	ca450513          	addi	a0,a0,-860 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02015dc:	b27fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc02015e0:	00004697          	auipc	a3,0x4
ffffffffc02015e4:	c8868693          	addi	a3,a3,-888 # ffffffffc0205268 <commands+0xa98>
ffffffffc02015e8:	00004617          	auipc	a2,0x4
ffffffffc02015ec:	91060613          	addi	a2,a2,-1776 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02015f0:	08f00593          	li	a1,143
ffffffffc02015f4:	00004517          	auipc	a0,0x4
ffffffffc02015f8:	c8450513          	addi	a0,a0,-892 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02015fc:	b07fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0201600:	00004697          	auipc	a3,0x4
ffffffffc0201604:	c6868693          	addi	a3,a3,-920 # ffffffffc0205268 <commands+0xa98>
ffffffffc0201608:	00004617          	auipc	a2,0x4
ffffffffc020160c:	8f060613          	addi	a2,a2,-1808 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201610:	08d00593          	li	a1,141
ffffffffc0201614:	00004517          	auipc	a0,0x4
ffffffffc0201618:	c6450513          	addi	a0,a0,-924 # ffffffffc0205278 <commands+0xaa8>
ffffffffc020161c:	ae7fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201620 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201620:	7518                	ld	a4,40(a0)
{
ffffffffc0201622:	1101                	addi	sp,sp,-32
ffffffffc0201624:	ec06                	sd	ra,24(sp)
ffffffffc0201626:	e822                	sd	s0,16(sp)
ffffffffc0201628:	e426                	sd	s1,8(sp)
ffffffffc020162a:	e04a                	sd	s2,0(sp)
         assert(head != NULL);
ffffffffc020162c:	cf39                	beqz	a4,ffffffffc020168a <_clock_swap_out_victim+0x6a>
     assert(in_tick==0);
ffffffffc020162e:	ee35                	bnez	a2,ffffffffc02016aa <_clock_swap_out_victim+0x8a>
ffffffffc0201630:	00010917          	auipc	s2,0x10
ffffffffc0201634:	f0090913          	addi	s2,s2,-256 # ffffffffc0211530 <curr_ptr>
ffffffffc0201638:	00093403          	ld	s0,0(s2)
ffffffffc020163c:	84ae                	mv	s1,a1
ffffffffc020163e:	a031                	j	ffffffffc020164a <_clock_swap_out_victim+0x2a>
        if(!page->visited) {
ffffffffc0201640:	fe043783          	ld	a5,-32(s0)
ffffffffc0201644:	cb91                	beqz	a5,ffffffffc0201658 <_clock_swap_out_victim+0x38>
            page->visited = 0;
ffffffffc0201646:	fe043023          	sd	zero,-32(s0)
    return listelm->next;
ffffffffc020164a:	6400                	ld	s0,8(s0)
        if(curr_ptr == head)
ffffffffc020164c:	fe871ae3          	bne	a4,s0,ffffffffc0201640 <_clock_swap_out_victim+0x20>
ffffffffc0201650:	6700                	ld	s0,8(a4)
        if(!page->visited) {
ffffffffc0201652:	fe043783          	ld	a5,-32(s0)
ffffffffc0201656:	fbe5                	bnez	a5,ffffffffc0201646 <_clock_swap_out_victim+0x26>
            cprintf("curr_ptr 0xffffffff%x\n", curr_ptr);
ffffffffc0201658:	85a2                	mv	a1,s0
ffffffffc020165a:	00004517          	auipc	a0,0x4
ffffffffc020165e:	c9e50513          	addi	a0,a0,-866 # ffffffffc02052f8 <commands+0xb28>
ffffffffc0201662:	00893023          	sd	s0,0(s2)
ffffffffc0201666:	a55fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
            list_del(curr_ptr);
ffffffffc020166a:	00093783          	ld	a5,0(s2)
        struct Page *page = le2page(curr_ptr, pra_page_link);
ffffffffc020166e:	fd040413          	addi	s0,s0,-48
}
ffffffffc0201672:	60e2                	ld	ra,24(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201674:	6398                	ld	a4,0(a5)
ffffffffc0201676:	679c                	ld	a5,8(a5)
ffffffffc0201678:	6902                	ld	s2,0(sp)
ffffffffc020167a:	4501                	li	a0,0
    prev->next = next;
ffffffffc020167c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020167e:	e398                	sd	a4,0(a5)
            *ptr_page = page;//将该页面指针赋值给ptr_page作为换出页面
ffffffffc0201680:	e080                	sd	s0,0(s1)
}
ffffffffc0201682:	6442                	ld	s0,16(sp)
ffffffffc0201684:	64a2                	ld	s1,8(sp)
ffffffffc0201686:	6105                	addi	sp,sp,32
ffffffffc0201688:	8082                	ret
         assert(head != NULL);
ffffffffc020168a:	00004697          	auipc	a3,0x4
ffffffffc020168e:	c4e68693          	addi	a3,a3,-946 # ffffffffc02052d8 <commands+0xb08>
ffffffffc0201692:	00004617          	auipc	a2,0x4
ffffffffc0201696:	86660613          	addi	a2,a2,-1946 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020169a:	04900593          	li	a1,73
ffffffffc020169e:	00004517          	auipc	a0,0x4
ffffffffc02016a2:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02016a6:	a5dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(in_tick==0);
ffffffffc02016aa:	00004697          	auipc	a3,0x4
ffffffffc02016ae:	c3e68693          	addi	a3,a3,-962 # ffffffffc02052e8 <commands+0xb18>
ffffffffc02016b2:	00004617          	auipc	a2,0x4
ffffffffc02016b6:	84660613          	addi	a2,a2,-1978 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02016ba:	04a00593          	li	a1,74
ffffffffc02016be:	00004517          	auipc	a0,0x4
ffffffffc02016c2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0205278 <commands+0xaa8>
ffffffffc02016c6:	a3dfe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02016ca <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02016ca:	00010797          	auipc	a5,0x10
ffffffffc02016ce:	e667b783          	ld	a5,-410(a5) # ffffffffc0211530 <curr_ptr>
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02016d2:	7514                	ld	a3,40(a0)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02016d4:	cf89                	beqz	a5,ffffffffc02016ee <_clock_map_swappable+0x24>
    list_add(head->prev, entry);
ffffffffc02016d6:	629c                	ld	a5,0(a3)
ffffffffc02016d8:	03060713          	addi	a4,a2,48
}
ffffffffc02016dc:	4501                	li	a0,0
    __list_add(elm, listelm, listelm->next);
ffffffffc02016de:	6794                	ld	a3,8(a5)
    prev->next = next->prev = elm;
ffffffffc02016e0:	e298                	sd	a4,0(a3)
ffffffffc02016e2:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc02016e4:	fa1c                	sd	a5,48(a2)
    page->visited = 1;
ffffffffc02016e6:	4785                	li	a5,1
    elm->next = next;
ffffffffc02016e8:	fe14                	sd	a3,56(a2)
ffffffffc02016ea:	ea1c                	sd	a5,16(a2)
}
ffffffffc02016ec:	8082                	ret
{
ffffffffc02016ee:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02016f0:	00004697          	auipc	a3,0x4
ffffffffc02016f4:	c2068693          	addi	a3,a3,-992 # ffffffffc0205310 <commands+0xb40>
ffffffffc02016f8:	00004617          	auipc	a2,0x4
ffffffffc02016fc:	80060613          	addi	a2,a2,-2048 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201700:	03600593          	li	a1,54
ffffffffc0201704:	00004517          	auipc	a0,0x4
ffffffffc0201708:	b7450513          	addi	a0,a0,-1164 # ffffffffc0205278 <commands+0xaa8>
{
ffffffffc020170c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020170e:	9f5fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201712 <swap_init>:

bool test_swap_lru = true;

int
swap_init(void)
{
ffffffffc0201712:	7135                	addi	sp,sp,-160
ffffffffc0201714:	ed06                	sd	ra,152(sp)
ffffffffc0201716:	e922                	sd	s0,144(sp)
ffffffffc0201718:	e526                	sd	s1,136(sp)
ffffffffc020171a:	e14a                	sd	s2,128(sp)
ffffffffc020171c:	fcce                	sd	s3,120(sp)
ffffffffc020171e:	f8d2                	sd	s4,112(sp)
ffffffffc0201720:	f4d6                	sd	s5,104(sp)
ffffffffc0201722:	f0da                	sd	s6,96(sp)
ffffffffc0201724:	ecde                	sd	s7,88(sp)
ffffffffc0201726:	e8e2                	sd	s8,80(sp)
ffffffffc0201728:	e4e6                	sd	s9,72(sp)
ffffffffc020172a:	e0ea                	sd	s10,64(sp)
ffffffffc020172c:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020172e:	772020ef          	jal	ra,ffffffffc0203ea0 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201732:	00010697          	auipc	a3,0x10
ffffffffc0201736:	e066b683          	ld	a3,-506(a3) # ffffffffc0211538 <max_swap_offset>
ffffffffc020173a:	010007b7          	lui	a5,0x1000
ffffffffc020173e:	ff968713          	addi	a4,a3,-7
ffffffffc0201742:	17e1                	addi	a5,a5,-8
ffffffffc0201744:	3ee7e463          	bltu	a5,a4,ffffffffc0201b2c <swap_init+0x41a>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     test_swap_lru = false;
     sm = &swap_manager_clock;
ffffffffc0201748:	00009797          	auipc	a5,0x9
ffffffffc020174c:	8b878793          	addi	a5,a5,-1864 # ffffffffc020a000 <swap_manager_clock>

     int r = sm->init();
ffffffffc0201750:	6798                	ld	a4,8(a5)
     test_swap_lru = false;
ffffffffc0201752:	00009697          	auipc	a3,0x9
ffffffffc0201756:	8e06a723          	sw	zero,-1810(a3) # ffffffffc020a040 <test_swap_lru>
     sm = &swap_manager_clock;
ffffffffc020175a:	00010b17          	auipc	s6,0x10
ffffffffc020175e:	de6b0b13          	addi	s6,s6,-538 # ffffffffc0211540 <sm>
ffffffffc0201762:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0201766:	9702                	jalr	a4
ffffffffc0201768:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc020176a:	c10d                	beqz	a0,ffffffffc020178c <swap_init+0x7a>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020176c:	60ea                	ld	ra,152(sp)
ffffffffc020176e:	644a                	ld	s0,144(sp)
ffffffffc0201770:	64aa                	ld	s1,136(sp)
ffffffffc0201772:	690a                	ld	s2,128(sp)
ffffffffc0201774:	7a46                	ld	s4,112(sp)
ffffffffc0201776:	7aa6                	ld	s5,104(sp)
ffffffffc0201778:	7b06                	ld	s6,96(sp)
ffffffffc020177a:	6be6                	ld	s7,88(sp)
ffffffffc020177c:	6c46                	ld	s8,80(sp)
ffffffffc020177e:	6ca6                	ld	s9,72(sp)
ffffffffc0201780:	6d06                	ld	s10,64(sp)
ffffffffc0201782:	7de2                	ld	s11,56(sp)
ffffffffc0201784:	854e                	mv	a0,s3
ffffffffc0201786:	79e6                	ld	s3,120(sp)
ffffffffc0201788:	610d                	addi	sp,sp,160
ffffffffc020178a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020178c:	000b3783          	ld	a5,0(s6)
ffffffffc0201790:	00004517          	auipc	a0,0x4
ffffffffc0201794:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205380 <commands+0xbb0>
    return listelm->next;
ffffffffc0201798:	00010497          	auipc	s1,0x10
ffffffffc020179c:	95048493          	addi	s1,s1,-1712 # ffffffffc02110e8 <free_area>
ffffffffc02017a0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02017a2:	4785                	li	a5,1
ffffffffc02017a4:	00010717          	auipc	a4,0x10
ffffffffc02017a8:	daf72223          	sw	a5,-604(a4) # ffffffffc0211548 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02017ac:	90ffe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02017b0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02017b2:	4401                	li	s0,0
ffffffffc02017b4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02017b6:	2c978163          	beq	a5,s1,ffffffffc0201a78 <swap_init+0x366>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017ba:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02017be:	8b09                	andi	a4,a4,2
ffffffffc02017c0:	2a070e63          	beqz	a4,ffffffffc0201a7c <swap_init+0x36a>
        count ++, total += p->property;
ffffffffc02017c4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017c8:	679c                	ld	a5,8(a5)
ffffffffc02017ca:	2d05                	addiw	s10,s10,1
ffffffffc02017cc:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02017ce:	fe9796e3          	bne	a5,s1,ffffffffc02017ba <swap_init+0xa8>
     }
     assert(total == nr_free_pages());
ffffffffc02017d2:	8922                	mv	s2,s0
ffffffffc02017d4:	444010ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
ffffffffc02017d8:	47251663          	bne	a0,s2,ffffffffc0201c44 <swap_init+0x532>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02017dc:	8622                	mv	a2,s0
ffffffffc02017de:	85ea                	mv	a1,s10
ffffffffc02017e0:	00004517          	auipc	a0,0x4
ffffffffc02017e4:	be850513          	addi	a0,a0,-1048 # ffffffffc02053c8 <commands+0xbf8>
ffffffffc02017e8:	8d3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02017ec:	b08ff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
ffffffffc02017f0:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02017f2:	52050963          	beqz	a0,ffffffffc0201d24 <swap_init+0x612>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02017f6:	00010797          	auipc	a5,0x10
ffffffffc02017fa:	d2a78793          	addi	a5,a5,-726 # ffffffffc0211520 <check_mm_struct>
ffffffffc02017fe:	6398                	ld	a4,0(a5)
ffffffffc0201800:	54071263          	bnez	a4,ffffffffc0201d44 <swap_init+0x632>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201804:	00010b97          	auipc	s7,0x10
ffffffffc0201808:	d54bbb83          	ld	s7,-684(s7) # ffffffffc0211558 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc020180c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0201810:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201812:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201816:	3c071763          	bnez	a4,ffffffffc0201be4 <swap_init+0x4d2>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020181a:	6599                	lui	a1,0x6
ffffffffc020181c:	460d                	li	a2,3
ffffffffc020181e:	6505                	lui	a0,0x1
ffffffffc0201820:	b1cff0ef          	jal	ra,ffffffffc0200b3c <vma_create>
ffffffffc0201824:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201826:	3c050f63          	beqz	a0,ffffffffc0201c04 <swap_init+0x4f2>

     insert_vma_struct(mm, vma);
ffffffffc020182a:	8556                	mv	a0,s5
ffffffffc020182c:	b7eff0ef          	jal	ra,ffffffffc0200baa <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201830:	00004517          	auipc	a0,0x4
ffffffffc0201834:	bd850513          	addi	a0,a0,-1064 # ffffffffc0205408 <commands+0xc38>
ffffffffc0201838:	883fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020183c:	018ab503          	ld	a0,24(s5)
ffffffffc0201840:	4605                	li	a2,1
ffffffffc0201842:	6585                	lui	a1,0x1
ffffffffc0201844:	40e010ef          	jal	ra,ffffffffc0202c52 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201848:	3c050e63          	beqz	a0,ffffffffc0201c24 <swap_init+0x512>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020184c:	00004517          	auipc	a0,0x4
ffffffffc0201850:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0205458 <commands+0xc88>
ffffffffc0201854:	00010917          	auipc	s2,0x10
ffffffffc0201858:	82490913          	addi	s2,s2,-2012 # ffffffffc0211078 <check_rp>
ffffffffc020185c:	85ffe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201860:	00010a17          	auipc	s4,0x10
ffffffffc0201864:	838a0a13          	addi	s4,s4,-1992 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201868:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc020186a:	4505                	li	a0,1
ffffffffc020186c:	2da010ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0201870:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0201874:	28050c63          	beqz	a0,ffffffffc0201b0c <swap_init+0x3fa>
ffffffffc0201878:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc020187a:	8b89                	andi	a5,a5,2
ffffffffc020187c:	26079863          	bnez	a5,ffffffffc0201aec <swap_init+0x3da>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201880:	0c21                	addi	s8,s8,8
ffffffffc0201882:	ff4c14e3          	bne	s8,s4,ffffffffc020186a <swap_init+0x158>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201886:	609c                	ld	a5,0(s1)
ffffffffc0201888:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc020188c:	e084                	sd	s1,0(s1)
ffffffffc020188e:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0201890:	489c                	lw	a5,16(s1)
ffffffffc0201892:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0201894:	0000fc17          	auipc	s8,0xf
ffffffffc0201898:	7e4c0c13          	addi	s8,s8,2020 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc020189c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc020189e:	00010797          	auipc	a5,0x10
ffffffffc02018a2:	8407ad23          	sw	zero,-1958(a5) # ffffffffc02110f8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02018a6:	000c3503          	ld	a0,0(s8)
ffffffffc02018aa:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02018ac:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02018ae:	32a010ef          	jal	ra,ffffffffc0202bd8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02018b2:	ff4c1ae3          	bne	s8,s4,ffffffffc02018a6 <swap_init+0x194>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02018b6:	0104ac03          	lw	s8,16(s1)
ffffffffc02018ba:	4791                	li	a5,4
ffffffffc02018bc:	4afc1463          	bne	s8,a5,ffffffffc0201d64 <swap_init+0x652>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02018c0:	00004517          	auipc	a0,0x4
ffffffffc02018c4:	c2050513          	addi	a0,a0,-992 # ffffffffc02054e0 <commands+0xd10>
ffffffffc02018c8:	ff2fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02018cc:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02018ce:	00010797          	auipc	a5,0x10
ffffffffc02018d2:	c407ad23          	sw	zero,-934(a5) # ffffffffc0211528 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02018d6:	4529                	li	a0,10
ffffffffc02018d8:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02018dc:	00010597          	auipc	a1,0x10
ffffffffc02018e0:	c4c5a583          	lw	a1,-948(a1) # ffffffffc0211528 <pgfault_num>
ffffffffc02018e4:	4805                	li	a6,1
ffffffffc02018e6:	00010797          	auipc	a5,0x10
ffffffffc02018ea:	c4278793          	addi	a5,a5,-958 # ffffffffc0211528 <pgfault_num>
ffffffffc02018ee:	3f059b63          	bne	a1,a6,ffffffffc0201ce4 <swap_init+0x5d2>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02018f2:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc02018f6:	4390                	lw	a2,0(a5)
ffffffffc02018f8:	2601                	sext.w	a2,a2
ffffffffc02018fa:	40b61563          	bne	a2,a1,ffffffffc0201d04 <swap_init+0x5f2>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02018fe:	6589                	lui	a1,0x2
ffffffffc0201900:	452d                	li	a0,11
ffffffffc0201902:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201906:	4390                	lw	a2,0(a5)
ffffffffc0201908:	4809                	li	a6,2
ffffffffc020190a:	2601                	sext.w	a2,a2
ffffffffc020190c:	35061c63          	bne	a2,a6,ffffffffc0201c64 <swap_init+0x552>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201910:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201914:	438c                	lw	a1,0(a5)
ffffffffc0201916:	2581                	sext.w	a1,a1
ffffffffc0201918:	36c59663          	bne	a1,a2,ffffffffc0201c84 <swap_init+0x572>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020191c:	658d                	lui	a1,0x3
ffffffffc020191e:	4531                	li	a0,12
ffffffffc0201920:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201924:	4390                	lw	a2,0(a5)
ffffffffc0201926:	480d                	li	a6,3
ffffffffc0201928:	2601                	sext.w	a2,a2
ffffffffc020192a:	37061d63          	bne	a2,a6,ffffffffc0201ca4 <swap_init+0x592>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020192e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0201932:	438c                	lw	a1,0(a5)
ffffffffc0201934:	2581                	sext.w	a1,a1
ffffffffc0201936:	38c59763          	bne	a1,a2,ffffffffc0201cc4 <swap_init+0x5b2>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020193a:	6591                	lui	a1,0x4
ffffffffc020193c:	4535                	li	a0,13
ffffffffc020193e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201942:	4390                	lw	a2,0(a5)
ffffffffc0201944:	2601                	sext.w	a2,a2
ffffffffc0201946:	21861f63          	bne	a2,s8,ffffffffc0201b64 <swap_init+0x452>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020194a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc020194e:	439c                	lw	a5,0(a5)
ffffffffc0201950:	2781                	sext.w	a5,a5
ffffffffc0201952:	22c79963          	bne	a5,a2,ffffffffc0201b84 <swap_init+0x472>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201956:	489c                	lw	a5,16(s1)
ffffffffc0201958:	24079663          	bnez	a5,ffffffffc0201ba4 <swap_init+0x492>
ffffffffc020195c:	0000f797          	auipc	a5,0xf
ffffffffc0201960:	73c78793          	addi	a5,a5,1852 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0201964:	0000f617          	auipc	a2,0xf
ffffffffc0201968:	75c60613          	addi	a2,a2,1884 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc020196c:	0000f517          	auipc	a0,0xf
ffffffffc0201970:	75450513          	addi	a0,a0,1876 # ffffffffc02110c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201974:	55fd                	li	a1,-1
ffffffffc0201976:	c38c                	sw	a1,0(a5)
ffffffffc0201978:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc020197a:	0791                	addi	a5,a5,4
ffffffffc020197c:	0611                	addi	a2,a2,4
ffffffffc020197e:	fef51ce3          	bne	a0,a5,ffffffffc0201976 <swap_init+0x264>
ffffffffc0201982:	0000f817          	auipc	a6,0xf
ffffffffc0201986:	6d680813          	addi	a6,a6,1750 # ffffffffc0211058 <check_ptep>
ffffffffc020198a:	0000f897          	auipc	a7,0xf
ffffffffc020198e:	6ee88893          	addi	a7,a7,1774 # ffffffffc0211078 <check_rp>
ffffffffc0201992:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0201994:	00010c97          	auipc	s9,0x10
ffffffffc0201998:	bd4c8c93          	addi	s9,s9,-1068 # ffffffffc0211568 <pages>
ffffffffc020199c:	00005c17          	auipc	s8,0x5
ffffffffc02019a0:	9ccc0c13          	addi	s8,s8,-1588 # ffffffffc0206368 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02019a4:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02019a8:	4601                	li	a2,0
ffffffffc02019aa:	855e                	mv	a0,s7
ffffffffc02019ac:	ec46                	sd	a7,24(sp)
ffffffffc02019ae:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc02019b0:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02019b2:	2a0010ef          	jal	ra,ffffffffc0202c52 <get_pte>
ffffffffc02019b6:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02019b8:	65c2                	ld	a1,16(sp)
ffffffffc02019ba:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02019bc:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc02019c0:	00010317          	auipc	t1,0x10
ffffffffc02019c4:	ba030313          	addi	t1,t1,-1120 # ffffffffc0211560 <npage>
ffffffffc02019c8:	16050e63          	beqz	a0,ffffffffc0201b44 <swap_init+0x432>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02019cc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02019ce:	0017f613          	andi	a2,a5,1
ffffffffc02019d2:	0e060563          	beqz	a2,ffffffffc0201abc <swap_init+0x3aa>
    if (PPN(pa) >= npage) {
ffffffffc02019d6:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019da:	078a                	slli	a5,a5,0x2
ffffffffc02019dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019de:	0ec7fb63          	bgeu	a5,a2,ffffffffc0201ad4 <swap_init+0x3c2>
    return &pages[PPN(pa) - nbase];
ffffffffc02019e2:	000c3603          	ld	a2,0(s8)
ffffffffc02019e6:	000cb503          	ld	a0,0(s9)
ffffffffc02019ea:	0008bf03          	ld	t5,0(a7)
ffffffffc02019ee:	8f91                	sub	a5,a5,a2
ffffffffc02019f0:	00379613          	slli	a2,a5,0x3
ffffffffc02019f4:	97b2                	add	a5,a5,a2
ffffffffc02019f6:	078e                	slli	a5,a5,0x3
ffffffffc02019f8:	97aa                	add	a5,a5,a0
ffffffffc02019fa:	0aff1163          	bne	t5,a5,ffffffffc0201a9c <swap_init+0x38a>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019fe:	6785                	lui	a5,0x1
ffffffffc0201a00:	95be                	add	a1,a1,a5
ffffffffc0201a02:	6795                	lui	a5,0x5
ffffffffc0201a04:	0821                	addi	a6,a6,8
ffffffffc0201a06:	08a1                	addi	a7,a7,8
ffffffffc0201a08:	f8f59ee3          	bne	a1,a5,ffffffffc02019a4 <swap_init+0x292>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201a0c:	00004517          	auipc	a0,0x4
ffffffffc0201a10:	ba450513          	addi	a0,a0,-1116 # ffffffffc02055b0 <commands+0xde0>
ffffffffc0201a14:	ea6fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201a18:	000b3783          	ld	a5,0(s6)
ffffffffc0201a1c:	7f9c                	ld	a5,56(a5)
ffffffffc0201a1e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201a20:	1a051263          	bnez	a0,ffffffffc0201bc4 <swap_init+0x4b2>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201a24:	00093503          	ld	a0,0(s2)
ffffffffc0201a28:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a2a:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0201a2c:	1ac010ef          	jal	ra,ffffffffc0202bd8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a30:	ff491ae3          	bne	s2,s4,ffffffffc0201a24 <swap_init+0x312>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201a34:	8556                	mv	a0,s5
ffffffffc0201a36:	a44ff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201a3a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0201a3c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0201a40:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0201a42:	7782                	ld	a5,32(sp)
ffffffffc0201a44:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201a46:	009d8a63          	beq	s11,s1,ffffffffc0201a5a <swap_init+0x348>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201a4a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0201a4e:	008dbd83          	ld	s11,8(s11)
ffffffffc0201a52:	3d7d                	addiw	s10,s10,-1
ffffffffc0201a54:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201a56:	fe9d9ae3          	bne	s11,s1,ffffffffc0201a4a <swap_init+0x338>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201a5a:	8622                	mv	a2,s0
ffffffffc0201a5c:	85ea                	mv	a1,s10
ffffffffc0201a5e:	00004517          	auipc	a0,0x4
ffffffffc0201a62:	b8250513          	addi	a0,a0,-1150 # ffffffffc02055e0 <commands+0xe10>
ffffffffc0201a66:	e54fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201a6a:	00004517          	auipc	a0,0x4
ffffffffc0201a6e:	b9650513          	addi	a0,a0,-1130 # ffffffffc0205600 <commands+0xe30>
ffffffffc0201a72:	e48fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201a76:	b9dd                	j	ffffffffc020176c <swap_init+0x5a>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201a78:	4901                	li	s2,0
ffffffffc0201a7a:	bba9                	j	ffffffffc02017d4 <swap_init+0xc2>
        assert(PageProperty(p));
ffffffffc0201a7c:	00004697          	auipc	a3,0x4
ffffffffc0201a80:	91c68693          	addi	a3,a3,-1764 # ffffffffc0205398 <commands+0xbc8>
ffffffffc0201a84:	00003617          	auipc	a2,0x3
ffffffffc0201a88:	47460613          	addi	a2,a2,1140 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201a8c:	0bf00593          	li	a1,191
ffffffffc0201a90:	00004517          	auipc	a0,0x4
ffffffffc0201a94:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201a98:	e6afe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201a9c:	00004697          	auipc	a3,0x4
ffffffffc0201aa0:	aec68693          	addi	a3,a3,-1300 # ffffffffc0205588 <commands+0xdb8>
ffffffffc0201aa4:	00003617          	auipc	a2,0x3
ffffffffc0201aa8:	45460613          	addi	a2,a2,1108 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201aac:	0ff00593          	li	a1,255
ffffffffc0201ab0:	00004517          	auipc	a0,0x4
ffffffffc0201ab4:	8c050513          	addi	a0,a0,-1856 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201ab8:	e4afe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201abc:	00004617          	auipc	a2,0x4
ffffffffc0201ac0:	aa460613          	addi	a2,a2,-1372 # ffffffffc0205560 <commands+0xd90>
ffffffffc0201ac4:	07000593          	li	a1,112
ffffffffc0201ac8:	00003517          	auipc	a0,0x3
ffffffffc0201acc:	6a050513          	addi	a0,a0,1696 # ffffffffc0205168 <commands+0x998>
ffffffffc0201ad0:	e32fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201ad4:	00003617          	auipc	a2,0x3
ffffffffc0201ad8:	67460613          	addi	a2,a2,1652 # ffffffffc0205148 <commands+0x978>
ffffffffc0201adc:	06500593          	li	a1,101
ffffffffc0201ae0:	00003517          	auipc	a0,0x3
ffffffffc0201ae4:	68850513          	addi	a0,a0,1672 # ffffffffc0205168 <commands+0x998>
ffffffffc0201ae8:	e1afe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201aec:	00004697          	auipc	a3,0x4
ffffffffc0201af0:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0205498 <commands+0xcc8>
ffffffffc0201af4:	00003617          	auipc	a2,0x3
ffffffffc0201af8:	40460613          	addi	a2,a2,1028 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201afc:	0e000593          	li	a1,224
ffffffffc0201b00:	00004517          	auipc	a0,0x4
ffffffffc0201b04:	87050513          	addi	a0,a0,-1936 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201b08:	dfafe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201b0c:	00004697          	auipc	a3,0x4
ffffffffc0201b10:	97468693          	addi	a3,a3,-1676 # ffffffffc0205480 <commands+0xcb0>
ffffffffc0201b14:	00003617          	auipc	a2,0x3
ffffffffc0201b18:	3e460613          	addi	a2,a2,996 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201b1c:	0df00593          	li	a1,223
ffffffffc0201b20:	00004517          	auipc	a0,0x4
ffffffffc0201b24:	85050513          	addi	a0,a0,-1968 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201b28:	ddafe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201b2c:	00004617          	auipc	a2,0x4
ffffffffc0201b30:	82460613          	addi	a2,a2,-2012 # ffffffffc0205350 <commands+0xb80>
ffffffffc0201b34:	02a00593          	li	a1,42
ffffffffc0201b38:	00004517          	auipc	a0,0x4
ffffffffc0201b3c:	83850513          	addi	a0,a0,-1992 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201b40:	dc2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201b44:	00004697          	auipc	a3,0x4
ffffffffc0201b48:	a0468693          	addi	a3,a3,-1532 # ffffffffc0205548 <commands+0xd78>
ffffffffc0201b4c:	00003617          	auipc	a2,0x3
ffffffffc0201b50:	3ac60613          	addi	a2,a2,940 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201b54:	0fe00593          	li	a1,254
ffffffffc0201b58:	00004517          	auipc	a0,0x4
ffffffffc0201b5c:	81850513          	addi	a0,a0,-2024 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201b60:	da2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201b64:	00003697          	auipc	a3,0x3
ffffffffc0201b68:	70468693          	addi	a3,a3,1796 # ffffffffc0205268 <commands+0xa98>
ffffffffc0201b6c:	00003617          	auipc	a2,0x3
ffffffffc0201b70:	38c60613          	addi	a2,a2,908 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201b74:	0a200593          	li	a1,162
ffffffffc0201b78:	00003517          	auipc	a0,0x3
ffffffffc0201b7c:	7f850513          	addi	a0,a0,2040 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201b80:	d82fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201b84:	00003697          	auipc	a3,0x3
ffffffffc0201b88:	6e468693          	addi	a3,a3,1764 # ffffffffc0205268 <commands+0xa98>
ffffffffc0201b8c:	00003617          	auipc	a2,0x3
ffffffffc0201b90:	36c60613          	addi	a2,a2,876 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201b94:	0a400593          	li	a1,164
ffffffffc0201b98:	00003517          	auipc	a0,0x3
ffffffffc0201b9c:	7d850513          	addi	a0,a0,2008 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201ba0:	d62fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc0201ba4:	00004697          	auipc	a3,0x4
ffffffffc0201ba8:	99468693          	addi	a3,a3,-1644 # ffffffffc0205538 <commands+0xd68>
ffffffffc0201bac:	00003617          	auipc	a2,0x3
ffffffffc0201bb0:	34c60613          	addi	a2,a2,844 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201bb4:	0f600593          	li	a1,246
ffffffffc0201bb8:	00003517          	auipc	a0,0x3
ffffffffc0201bbc:	7b850513          	addi	a0,a0,1976 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201bc0:	d42fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0201bc4:	00004697          	auipc	a3,0x4
ffffffffc0201bc8:	a1468693          	addi	a3,a3,-1516 # ffffffffc02055d8 <commands+0xe08>
ffffffffc0201bcc:	00003617          	auipc	a2,0x3
ffffffffc0201bd0:	32c60613          	addi	a2,a2,812 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201bd4:	10500593          	li	a1,261
ffffffffc0201bd8:	00003517          	auipc	a0,0x3
ffffffffc0201bdc:	79850513          	addi	a0,a0,1944 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201be0:	d22fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201be4:	00003697          	auipc	a3,0x3
ffffffffc0201be8:	52468693          	addi	a3,a3,1316 # ffffffffc0205108 <commands+0x938>
ffffffffc0201bec:	00003617          	auipc	a2,0x3
ffffffffc0201bf0:	30c60613          	addi	a2,a2,780 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201bf4:	0cf00593          	li	a1,207
ffffffffc0201bf8:	00003517          	auipc	a0,0x3
ffffffffc0201bfc:	77850513          	addi	a0,a0,1912 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201c00:	d02fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201c04:	00003697          	auipc	a3,0x3
ffffffffc0201c08:	5ac68693          	addi	a3,a3,1452 # ffffffffc02051b0 <commands+0x9e0>
ffffffffc0201c0c:	00003617          	auipc	a2,0x3
ffffffffc0201c10:	2ec60613          	addi	a2,a2,748 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201c14:	0d200593          	li	a1,210
ffffffffc0201c18:	00003517          	auipc	a0,0x3
ffffffffc0201c1c:	75850513          	addi	a0,a0,1880 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201c20:	ce2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201c24:	00004697          	auipc	a3,0x4
ffffffffc0201c28:	81c68693          	addi	a3,a3,-2020 # ffffffffc0205440 <commands+0xc70>
ffffffffc0201c2c:	00003617          	auipc	a2,0x3
ffffffffc0201c30:	2cc60613          	addi	a2,a2,716 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201c34:	0da00593          	li	a1,218
ffffffffc0201c38:	00003517          	auipc	a0,0x3
ffffffffc0201c3c:	73850513          	addi	a0,a0,1848 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201c40:	cc2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201c44:	00003697          	auipc	a3,0x3
ffffffffc0201c48:	76468693          	addi	a3,a3,1892 # ffffffffc02053a8 <commands+0xbd8>
ffffffffc0201c4c:	00003617          	auipc	a2,0x3
ffffffffc0201c50:	2ac60613          	addi	a2,a2,684 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201c54:	0c200593          	li	a1,194
ffffffffc0201c58:	00003517          	auipc	a0,0x3
ffffffffc0201c5c:	71850513          	addi	a0,a0,1816 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201c60:	ca2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201c64:	00004697          	auipc	a3,0x4
ffffffffc0201c68:	8b468693          	addi	a3,a3,-1868 # ffffffffc0205518 <commands+0xd48>
ffffffffc0201c6c:	00003617          	auipc	a2,0x3
ffffffffc0201c70:	28c60613          	addi	a2,a2,652 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201c74:	09a00593          	li	a1,154
ffffffffc0201c78:	00003517          	auipc	a0,0x3
ffffffffc0201c7c:	6f850513          	addi	a0,a0,1784 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201c80:	c82fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201c84:	00004697          	auipc	a3,0x4
ffffffffc0201c88:	89468693          	addi	a3,a3,-1900 # ffffffffc0205518 <commands+0xd48>
ffffffffc0201c8c:	00003617          	auipc	a2,0x3
ffffffffc0201c90:	26c60613          	addi	a2,a2,620 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201c94:	09c00593          	li	a1,156
ffffffffc0201c98:	00003517          	auipc	a0,0x3
ffffffffc0201c9c:	6d850513          	addi	a0,a0,1752 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201ca0:	c62fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201ca4:	00004697          	auipc	a3,0x4
ffffffffc0201ca8:	88468693          	addi	a3,a3,-1916 # ffffffffc0205528 <commands+0xd58>
ffffffffc0201cac:	00003617          	auipc	a2,0x3
ffffffffc0201cb0:	24c60613          	addi	a2,a2,588 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201cb4:	09e00593          	li	a1,158
ffffffffc0201cb8:	00003517          	auipc	a0,0x3
ffffffffc0201cbc:	6b850513          	addi	a0,a0,1720 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201cc0:	c42fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201cc4:	00004697          	auipc	a3,0x4
ffffffffc0201cc8:	86468693          	addi	a3,a3,-1948 # ffffffffc0205528 <commands+0xd58>
ffffffffc0201ccc:	00003617          	auipc	a2,0x3
ffffffffc0201cd0:	22c60613          	addi	a2,a2,556 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201cd4:	0a000593          	li	a1,160
ffffffffc0201cd8:	00003517          	auipc	a0,0x3
ffffffffc0201cdc:	69850513          	addi	a0,a0,1688 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201ce0:	c22fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201ce4:	00004697          	auipc	a3,0x4
ffffffffc0201ce8:	82468693          	addi	a3,a3,-2012 # ffffffffc0205508 <commands+0xd38>
ffffffffc0201cec:	00003617          	auipc	a2,0x3
ffffffffc0201cf0:	20c60613          	addi	a2,a2,524 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201cf4:	09600593          	li	a1,150
ffffffffc0201cf8:	00003517          	auipc	a0,0x3
ffffffffc0201cfc:	67850513          	addi	a0,a0,1656 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201d00:	c02fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201d04:	00004697          	auipc	a3,0x4
ffffffffc0201d08:	80468693          	addi	a3,a3,-2044 # ffffffffc0205508 <commands+0xd38>
ffffffffc0201d0c:	00003617          	auipc	a2,0x3
ffffffffc0201d10:	1ec60613          	addi	a2,a2,492 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201d14:	09800593          	li	a1,152
ffffffffc0201d18:	00003517          	auipc	a0,0x3
ffffffffc0201d1c:	65850513          	addi	a0,a0,1624 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201d20:	be2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201d24:	00003697          	auipc	a3,0x3
ffffffffc0201d28:	4b468693          	addi	a3,a3,1204 # ffffffffc02051d8 <commands+0xa08>
ffffffffc0201d2c:	00003617          	auipc	a2,0x3
ffffffffc0201d30:	1cc60613          	addi	a2,a2,460 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201d34:	0c700593          	li	a1,199
ffffffffc0201d38:	00003517          	auipc	a0,0x3
ffffffffc0201d3c:	63850513          	addi	a0,a0,1592 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201d40:	bc2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201d44:	00003697          	auipc	a3,0x3
ffffffffc0201d48:	6ac68693          	addi	a3,a3,1708 # ffffffffc02053f0 <commands+0xc20>
ffffffffc0201d4c:	00003617          	auipc	a2,0x3
ffffffffc0201d50:	1ac60613          	addi	a2,a2,428 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201d54:	0ca00593          	li	a1,202
ffffffffc0201d58:	00003517          	auipc	a0,0x3
ffffffffc0201d5c:	61850513          	addi	a0,a0,1560 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201d60:	ba2fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201d64:	00003697          	auipc	a3,0x3
ffffffffc0201d68:	75468693          	addi	a3,a3,1876 # ffffffffc02054b8 <commands+0xce8>
ffffffffc0201d6c:	00003617          	auipc	a2,0x3
ffffffffc0201d70:	18c60613          	addi	a2,a2,396 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201d74:	0ed00593          	li	a1,237
ffffffffc0201d78:	00003517          	auipc	a0,0x3
ffffffffc0201d7c:	5f850513          	addi	a0,a0,1528 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201d80:	b82fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201d84 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201d84:	0000f797          	auipc	a5,0xf
ffffffffc0201d88:	7bc7b783          	ld	a5,1980(a5) # ffffffffc0211540 <sm>
ffffffffc0201d8c:	6b9c                	ld	a5,16(a5)
ffffffffc0201d8e:	8782                	jr	a5

ffffffffc0201d90 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201d90:	0000f797          	auipc	a5,0xf
ffffffffc0201d94:	7b07b783          	ld	a5,1968(a5) # ffffffffc0211540 <sm>
ffffffffc0201d98:	739c                	ld	a5,32(a5)
ffffffffc0201d9a:	8782                	jr	a5

ffffffffc0201d9c <swap_out>:
{
ffffffffc0201d9c:	711d                	addi	sp,sp,-96
ffffffffc0201d9e:	ec86                	sd	ra,88(sp)
ffffffffc0201da0:	e8a2                	sd	s0,80(sp)
ffffffffc0201da2:	e4a6                	sd	s1,72(sp)
ffffffffc0201da4:	e0ca                	sd	s2,64(sp)
ffffffffc0201da6:	fc4e                	sd	s3,56(sp)
ffffffffc0201da8:	f852                	sd	s4,48(sp)
ffffffffc0201daa:	f456                	sd	s5,40(sp)
ffffffffc0201dac:	f05a                	sd	s6,32(sp)
ffffffffc0201dae:	ec5e                	sd	s7,24(sp)
ffffffffc0201db0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201db2:	cde9                	beqz	a1,ffffffffc0201e8c <swap_out+0xf0>
ffffffffc0201db4:	8a2e                	mv	s4,a1
ffffffffc0201db6:	892a                	mv	s2,a0
ffffffffc0201db8:	8ab2                	mv	s5,a2
ffffffffc0201dba:	4401                	li	s0,0
ffffffffc0201dbc:	0000f997          	auipc	s3,0xf
ffffffffc0201dc0:	78498993          	addi	s3,s3,1924 # ffffffffc0211540 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201dc4:	00004b17          	auipc	s6,0x4
ffffffffc0201dc8:	8bcb0b13          	addi	s6,s6,-1860 # ffffffffc0205680 <commands+0xeb0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201dcc:	00004b97          	auipc	s7,0x4
ffffffffc0201dd0:	89cb8b93          	addi	s7,s7,-1892 # ffffffffc0205668 <commands+0xe98>
ffffffffc0201dd4:	a825                	j	ffffffffc0201e0c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201dd6:	67a2                	ld	a5,8(sp)
ffffffffc0201dd8:	8626                	mv	a2,s1
ffffffffc0201dda:	85a2                	mv	a1,s0
ffffffffc0201ddc:	63b4                	ld	a3,64(a5)
ffffffffc0201dde:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201de0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201de2:	82b1                	srli	a3,a3,0xc
ffffffffc0201de4:	0685                	addi	a3,a3,1
ffffffffc0201de6:	ad4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201dea:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201dec:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201dee:	613c                	ld	a5,64(a0)
ffffffffc0201df0:	83b1                	srli	a5,a5,0xc
ffffffffc0201df2:	0785                	addi	a5,a5,1
ffffffffc0201df4:	07a2                	slli	a5,a5,0x8
ffffffffc0201df6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201dfa:	5df000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201dfe:	01893503          	ld	a0,24(s2)
ffffffffc0201e02:	85a6                	mv	a1,s1
ffffffffc0201e04:	63d010ef          	jal	ra,ffffffffc0203c40 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201e08:	048a0d63          	beq	s4,s0,ffffffffc0201e62 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201e0c:	0009b783          	ld	a5,0(s3)
ffffffffc0201e10:	8656                	mv	a2,s5
ffffffffc0201e12:	002c                	addi	a1,sp,8
ffffffffc0201e14:	7b9c                	ld	a5,48(a5)
ffffffffc0201e16:	854a                	mv	a0,s2
ffffffffc0201e18:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201e1a:	e12d                	bnez	a0,ffffffffc0201e7c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201e1c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201e1e:	01893503          	ld	a0,24(s2)
ffffffffc0201e22:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201e24:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201e26:	85a6                	mv	a1,s1
ffffffffc0201e28:	62b000ef          	jal	ra,ffffffffc0202c52 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201e2c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201e2e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201e30:	8b85                	andi	a5,a5,1
ffffffffc0201e32:	cfb9                	beqz	a5,ffffffffc0201e90 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201e34:	65a2                	ld	a1,8(sp)
ffffffffc0201e36:	61bc                	ld	a5,64(a1)
ffffffffc0201e38:	83b1                	srli	a5,a5,0xc
ffffffffc0201e3a:	0785                	addi	a5,a5,1
ffffffffc0201e3c:	00879513          	slli	a0,a5,0x8
ffffffffc0201e40:	132020ef          	jal	ra,ffffffffc0203f72 <swapfs_write>
ffffffffc0201e44:	d949                	beqz	a0,ffffffffc0201dd6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201e46:	855e                	mv	a0,s7
ffffffffc0201e48:	a72fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201e4c:	0009b783          	ld	a5,0(s3)
ffffffffc0201e50:	6622                	ld	a2,8(sp)
ffffffffc0201e52:	4681                	li	a3,0
ffffffffc0201e54:	739c                	ld	a5,32(a5)
ffffffffc0201e56:	85a6                	mv	a1,s1
ffffffffc0201e58:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201e5a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201e5c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201e5e:	fa8a17e3          	bne	s4,s0,ffffffffc0201e0c <swap_out+0x70>
}
ffffffffc0201e62:	60e6                	ld	ra,88(sp)
ffffffffc0201e64:	8522                	mv	a0,s0
ffffffffc0201e66:	6446                	ld	s0,80(sp)
ffffffffc0201e68:	64a6                	ld	s1,72(sp)
ffffffffc0201e6a:	6906                	ld	s2,64(sp)
ffffffffc0201e6c:	79e2                	ld	s3,56(sp)
ffffffffc0201e6e:	7a42                	ld	s4,48(sp)
ffffffffc0201e70:	7aa2                	ld	s5,40(sp)
ffffffffc0201e72:	7b02                	ld	s6,32(sp)
ffffffffc0201e74:	6be2                	ld	s7,24(sp)
ffffffffc0201e76:	6c42                	ld	s8,16(sp)
ffffffffc0201e78:	6125                	addi	sp,sp,96
ffffffffc0201e7a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201e7c:	85a2                	mv	a1,s0
ffffffffc0201e7e:	00003517          	auipc	a0,0x3
ffffffffc0201e82:	7a250513          	addi	a0,a0,1954 # ffffffffc0205620 <commands+0xe50>
ffffffffc0201e86:	a34fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201e8a:	bfe1                	j	ffffffffc0201e62 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201e8c:	4401                	li	s0,0
ffffffffc0201e8e:	bfd1                	j	ffffffffc0201e62 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201e90:	00003697          	auipc	a3,0x3
ffffffffc0201e94:	7c068693          	addi	a3,a3,1984 # ffffffffc0205650 <commands+0xe80>
ffffffffc0201e98:	00003617          	auipc	a2,0x3
ffffffffc0201e9c:	06060613          	addi	a2,a2,96 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201ea0:	06b00593          	li	a1,107
ffffffffc0201ea4:	00003517          	auipc	a0,0x3
ffffffffc0201ea8:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201eac:	a56fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201eb0 <swap_in>:
{
ffffffffc0201eb0:	7179                	addi	sp,sp,-48
ffffffffc0201eb2:	e84a                	sd	s2,16(sp)
ffffffffc0201eb4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201eb6:	4505                	li	a0,1
{
ffffffffc0201eb8:	ec26                	sd	s1,24(sp)
ffffffffc0201eba:	e44e                	sd	s3,8(sp)
ffffffffc0201ebc:	f406                	sd	ra,40(sp)
ffffffffc0201ebe:	f022                	sd	s0,32(sp)
ffffffffc0201ec0:	84ae                	mv	s1,a1
ffffffffc0201ec2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201ec4:	483000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201ec8:	c129                	beqz	a0,ffffffffc0201f0a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201eca:	842a                	mv	s0,a0
ffffffffc0201ecc:	01893503          	ld	a0,24(s2)
ffffffffc0201ed0:	4601                	li	a2,0
ffffffffc0201ed2:	85a6                	mv	a1,s1
ffffffffc0201ed4:	57f000ef          	jal	ra,ffffffffc0202c52 <get_pte>
ffffffffc0201ed8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201eda:	6108                	ld	a0,0(a0)
ffffffffc0201edc:	85a2                	mv	a1,s0
ffffffffc0201ede:	7fb010ef          	jal	ra,ffffffffc0203ed8 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201ee2:	00093583          	ld	a1,0(s2)
ffffffffc0201ee6:	8626                	mv	a2,s1
ffffffffc0201ee8:	00003517          	auipc	a0,0x3
ffffffffc0201eec:	7e850513          	addi	a0,a0,2024 # ffffffffc02056d0 <commands+0xf00>
ffffffffc0201ef0:	81a1                	srli	a1,a1,0x8
ffffffffc0201ef2:	9c8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201ef6:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201ef8:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201efc:	7402                	ld	s0,32(sp)
ffffffffc0201efe:	64e2                	ld	s1,24(sp)
ffffffffc0201f00:	6942                	ld	s2,16(sp)
ffffffffc0201f02:	69a2                	ld	s3,8(sp)
ffffffffc0201f04:	4501                	li	a0,0
ffffffffc0201f06:	6145                	addi	sp,sp,48
ffffffffc0201f08:	8082                	ret
     assert(result!=NULL);
ffffffffc0201f0a:	00003697          	auipc	a3,0x3
ffffffffc0201f0e:	7b668693          	addi	a3,a3,1974 # ffffffffc02056c0 <commands+0xef0>
ffffffffc0201f12:	00003617          	auipc	a2,0x3
ffffffffc0201f16:	fe660613          	addi	a2,a2,-26 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0201f1a:	08100593          	li	a1,129
ffffffffc0201f1e:	00003517          	auipc	a0,0x3
ffffffffc0201f22:	45250513          	addi	a0,a0,1106 # ffffffffc0205370 <commands+0xba0>
ffffffffc0201f26:	9dcfe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201f2a <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201f2a:	0000f797          	auipc	a5,0xf
ffffffffc0201f2e:	1be78793          	addi	a5,a5,446 # ffffffffc02110e8 <free_area>
ffffffffc0201f32:	e79c                	sd	a5,8(a5)
ffffffffc0201f34:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201f36:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201f3a:	8082                	ret

ffffffffc0201f3c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201f3c:	0000f517          	auipc	a0,0xf
ffffffffc0201f40:	1bc56503          	lwu	a0,444(a0) # ffffffffc02110f8 <free_area+0x10>
ffffffffc0201f44:	8082                	ret

ffffffffc0201f46 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201f46:	715d                	addi	sp,sp,-80
ffffffffc0201f48:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201f4a:	0000f417          	auipc	s0,0xf
ffffffffc0201f4e:	19e40413          	addi	s0,s0,414 # ffffffffc02110e8 <free_area>
ffffffffc0201f52:	641c                	ld	a5,8(s0)
ffffffffc0201f54:	e486                	sd	ra,72(sp)
ffffffffc0201f56:	fc26                	sd	s1,56(sp)
ffffffffc0201f58:	f84a                	sd	s2,48(sp)
ffffffffc0201f5a:	f44e                	sd	s3,40(sp)
ffffffffc0201f5c:	f052                	sd	s4,32(sp)
ffffffffc0201f5e:	ec56                	sd	s5,24(sp)
ffffffffc0201f60:	e85a                	sd	s6,16(sp)
ffffffffc0201f62:	e45e                	sd	s7,8(sp)
ffffffffc0201f64:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201f66:	2c878763          	beq	a5,s0,ffffffffc0202234 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201f6a:	4481                	li	s1,0
ffffffffc0201f6c:	4901                	li	s2,0
ffffffffc0201f6e:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201f72:	8b09                	andi	a4,a4,2
ffffffffc0201f74:	2c070463          	beqz	a4,ffffffffc020223c <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201f78:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201f7c:	679c                	ld	a5,8(a5)
ffffffffc0201f7e:	2905                	addiw	s2,s2,1
ffffffffc0201f80:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201f82:	fe8796e3          	bne	a5,s0,ffffffffc0201f6e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201f86:	89a6                	mv	s3,s1
ffffffffc0201f88:	491000ef          	jal	ra,ffffffffc0202c18 <nr_free_pages>
ffffffffc0201f8c:	71351863          	bne	a0,s3,ffffffffc020269c <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201f90:	4505                	li	a0,1
ffffffffc0201f92:	3b5000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0201f96:	8a2a                	mv	s4,a0
ffffffffc0201f98:	44050263          	beqz	a0,ffffffffc02023dc <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201f9c:	4505                	li	a0,1
ffffffffc0201f9e:	3a9000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0201fa2:	89aa                	mv	s3,a0
ffffffffc0201fa4:	70050c63          	beqz	a0,ffffffffc02026bc <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201fa8:	4505                	li	a0,1
ffffffffc0201faa:	39d000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0201fae:	8aaa                	mv	s5,a0
ffffffffc0201fb0:	4a050663          	beqz	a0,ffffffffc020245c <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201fb4:	2b3a0463          	beq	s4,s3,ffffffffc020225c <default_check+0x316>
ffffffffc0201fb8:	2aaa0263          	beq	s4,a0,ffffffffc020225c <default_check+0x316>
ffffffffc0201fbc:	2aa98063          	beq	s3,a0,ffffffffc020225c <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201fc0:	000a2783          	lw	a5,0(s4)
ffffffffc0201fc4:	2a079c63          	bnez	a5,ffffffffc020227c <default_check+0x336>
ffffffffc0201fc8:	0009a783          	lw	a5,0(s3)
ffffffffc0201fcc:	2a079863          	bnez	a5,ffffffffc020227c <default_check+0x336>
ffffffffc0201fd0:	411c                	lw	a5,0(a0)
ffffffffc0201fd2:	2a079563          	bnez	a5,ffffffffc020227c <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fd6:	0000f797          	auipc	a5,0xf
ffffffffc0201fda:	5927b783          	ld	a5,1426(a5) # ffffffffc0211568 <pages>
ffffffffc0201fde:	40fa0733          	sub	a4,s4,a5
ffffffffc0201fe2:	870d                	srai	a4,a4,0x3
ffffffffc0201fe4:	00004597          	auipc	a1,0x4
ffffffffc0201fe8:	37c5b583          	ld	a1,892(a1) # ffffffffc0206360 <error_string+0x38>
ffffffffc0201fec:	02b70733          	mul	a4,a4,a1
ffffffffc0201ff0:	00004617          	auipc	a2,0x4
ffffffffc0201ff4:	37863603          	ld	a2,888(a2) # ffffffffc0206368 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201ff8:	0000f697          	auipc	a3,0xf
ffffffffc0201ffc:	5686b683          	ld	a3,1384(a3) # ffffffffc0211560 <npage>
ffffffffc0202000:	06b2                	slli	a3,a3,0xc
ffffffffc0202002:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202004:	0732                	slli	a4,a4,0xc
ffffffffc0202006:	28d77b63          	bgeu	a4,a3,ffffffffc020229c <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020200a:	40f98733          	sub	a4,s3,a5
ffffffffc020200e:	870d                	srai	a4,a4,0x3
ffffffffc0202010:	02b70733          	mul	a4,a4,a1
ffffffffc0202014:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202016:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202018:	4cd77263          	bgeu	a4,a3,ffffffffc02024dc <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020201c:	40f507b3          	sub	a5,a0,a5
ffffffffc0202020:	878d                	srai	a5,a5,0x3
ffffffffc0202022:	02b787b3          	mul	a5,a5,a1
ffffffffc0202026:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202028:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020202a:	30d7f963          	bgeu	a5,a3,ffffffffc020233c <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc020202e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202030:	00043c03          	ld	s8,0(s0)
ffffffffc0202034:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202038:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020203c:	e400                	sd	s0,8(s0)
ffffffffc020203e:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202040:	0000f797          	auipc	a5,0xf
ffffffffc0202044:	0a07ac23          	sw	zero,184(a5) # ffffffffc02110f8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202048:	2ff000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc020204c:	2c051863          	bnez	a0,ffffffffc020231c <default_check+0x3d6>
    free_page(p0);
ffffffffc0202050:	4585                	li	a1,1
ffffffffc0202052:	8552                	mv	a0,s4
ffffffffc0202054:	385000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    free_page(p1);
ffffffffc0202058:	4585                	li	a1,1
ffffffffc020205a:	854e                	mv	a0,s3
ffffffffc020205c:	37d000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    free_page(p2);
ffffffffc0202060:	4585                	li	a1,1
ffffffffc0202062:	8556                	mv	a0,s5
ffffffffc0202064:	375000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    assert(nr_free == 3);
ffffffffc0202068:	4818                	lw	a4,16(s0)
ffffffffc020206a:	478d                	li	a5,3
ffffffffc020206c:	28f71863          	bne	a4,a5,ffffffffc02022fc <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202070:	4505                	li	a0,1
ffffffffc0202072:	2d5000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202076:	89aa                	mv	s3,a0
ffffffffc0202078:	26050263          	beqz	a0,ffffffffc02022dc <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020207c:	4505                	li	a0,1
ffffffffc020207e:	2c9000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202082:	8aaa                	mv	s5,a0
ffffffffc0202084:	3a050c63          	beqz	a0,ffffffffc020243c <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202088:	4505                	li	a0,1
ffffffffc020208a:	2bd000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc020208e:	8a2a                	mv	s4,a0
ffffffffc0202090:	38050663          	beqz	a0,ffffffffc020241c <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0202094:	4505                	li	a0,1
ffffffffc0202096:	2b1000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc020209a:	36051163          	bnez	a0,ffffffffc02023fc <default_check+0x4b6>
    free_page(p0);
ffffffffc020209e:	4585                	li	a1,1
ffffffffc02020a0:	854e                	mv	a0,s3
ffffffffc02020a2:	337000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02020a6:	641c                	ld	a5,8(s0)
ffffffffc02020a8:	20878a63          	beq	a5,s0,ffffffffc02022bc <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc02020ac:	4505                	li	a0,1
ffffffffc02020ae:	299000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02020b2:	30a99563          	bne	s3,a0,ffffffffc02023bc <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc02020b6:	4505                	li	a0,1
ffffffffc02020b8:	28f000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02020bc:	2e051063          	bnez	a0,ffffffffc020239c <default_check+0x456>
    assert(nr_free == 0);
ffffffffc02020c0:	481c                	lw	a5,16(s0)
ffffffffc02020c2:	2a079d63          	bnez	a5,ffffffffc020237c <default_check+0x436>
    free_page(p);
ffffffffc02020c6:	854e                	mv	a0,s3
ffffffffc02020c8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02020ca:	01843023          	sd	s8,0(s0)
ffffffffc02020ce:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02020d2:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02020d6:	303000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    free_page(p1);
ffffffffc02020da:	4585                	li	a1,1
ffffffffc02020dc:	8556                	mv	a0,s5
ffffffffc02020de:	2fb000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    free_page(p2);
ffffffffc02020e2:	4585                	li	a1,1
ffffffffc02020e4:	8552                	mv	a0,s4
ffffffffc02020e6:	2f3000ef          	jal	ra,ffffffffc0202bd8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02020ea:	4515                	li	a0,5
ffffffffc02020ec:	25b000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02020f0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02020f2:	26050563          	beqz	a0,ffffffffc020235c <default_check+0x416>
ffffffffc02020f6:	651c                	ld	a5,8(a0)
ffffffffc02020f8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02020fa:	8b85                	andi	a5,a5,1
ffffffffc02020fc:	54079063          	bnez	a5,ffffffffc020263c <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202100:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202102:	00043b03          	ld	s6,0(s0)
ffffffffc0202106:	00843a83          	ld	s5,8(s0)
ffffffffc020210a:	e000                	sd	s0,0(s0)
ffffffffc020210c:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc020210e:	239000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202112:	50051563          	bnez	a0,ffffffffc020261c <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202116:	09098a13          	addi	s4,s3,144
ffffffffc020211a:	8552                	mv	a0,s4
ffffffffc020211c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020211e:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202122:	0000f797          	auipc	a5,0xf
ffffffffc0202126:	fc07ab23          	sw	zero,-42(a5) # ffffffffc02110f8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020212a:	2af000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020212e:	4511                	li	a0,4
ffffffffc0202130:	217000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202134:	4c051463          	bnez	a0,ffffffffc02025fc <default_check+0x6b6>
ffffffffc0202138:	0989b783          	ld	a5,152(s3)
ffffffffc020213c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020213e:	8b85                	andi	a5,a5,1
ffffffffc0202140:	48078e63          	beqz	a5,ffffffffc02025dc <default_check+0x696>
ffffffffc0202144:	0a89a703          	lw	a4,168(s3)
ffffffffc0202148:	478d                	li	a5,3
ffffffffc020214a:	48f71963          	bne	a4,a5,ffffffffc02025dc <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020214e:	450d                	li	a0,3
ffffffffc0202150:	1f7000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202154:	8c2a                	mv	s8,a0
ffffffffc0202156:	46050363          	beqz	a0,ffffffffc02025bc <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc020215a:	4505                	li	a0,1
ffffffffc020215c:	1eb000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202160:	42051e63          	bnez	a0,ffffffffc020259c <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0202164:	418a1c63          	bne	s4,s8,ffffffffc020257c <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202168:	4585                	li	a1,1
ffffffffc020216a:	854e                	mv	a0,s3
ffffffffc020216c:	26d000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    free_pages(p1, 3);
ffffffffc0202170:	458d                	li	a1,3
ffffffffc0202172:	8552                	mv	a0,s4
ffffffffc0202174:	265000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
ffffffffc0202178:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020217c:	04898c13          	addi	s8,s3,72
ffffffffc0202180:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202182:	8b85                	andi	a5,a5,1
ffffffffc0202184:	3c078c63          	beqz	a5,ffffffffc020255c <default_check+0x616>
ffffffffc0202188:	0189a703          	lw	a4,24(s3)
ffffffffc020218c:	4785                	li	a5,1
ffffffffc020218e:	3cf71763          	bne	a4,a5,ffffffffc020255c <default_check+0x616>
ffffffffc0202192:	008a3783          	ld	a5,8(s4)
ffffffffc0202196:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202198:	8b85                	andi	a5,a5,1
ffffffffc020219a:	3a078163          	beqz	a5,ffffffffc020253c <default_check+0x5f6>
ffffffffc020219e:	018a2703          	lw	a4,24(s4)
ffffffffc02021a2:	478d                	li	a5,3
ffffffffc02021a4:	38f71c63          	bne	a4,a5,ffffffffc020253c <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02021a8:	4505                	li	a0,1
ffffffffc02021aa:	19d000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02021ae:	36a99763          	bne	s3,a0,ffffffffc020251c <default_check+0x5d6>
    free_page(p0);
ffffffffc02021b2:	4585                	li	a1,1
ffffffffc02021b4:	225000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02021b8:	4509                	li	a0,2
ffffffffc02021ba:	18d000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02021be:	32aa1f63          	bne	s4,a0,ffffffffc02024fc <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc02021c2:	4589                	li	a1,2
ffffffffc02021c4:	215000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    free_page(p2);
ffffffffc02021c8:	4585                	li	a1,1
ffffffffc02021ca:	8562                	mv	a0,s8
ffffffffc02021cc:	20d000ef          	jal	ra,ffffffffc0202bd8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02021d0:	4515                	li	a0,5
ffffffffc02021d2:	175000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02021d6:	89aa                	mv	s3,a0
ffffffffc02021d8:	48050263          	beqz	a0,ffffffffc020265c <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc02021dc:	4505                	li	a0,1
ffffffffc02021de:	169000ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02021e2:	2c051d63          	bnez	a0,ffffffffc02024bc <default_check+0x576>

    assert(nr_free == 0);
ffffffffc02021e6:	481c                	lw	a5,16(s0)
ffffffffc02021e8:	2a079a63          	bnez	a5,ffffffffc020249c <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02021ec:	4595                	li	a1,5
ffffffffc02021ee:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02021f0:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02021f4:	01643023          	sd	s6,0(s0)
ffffffffc02021f8:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02021fc:	1dd000ef          	jal	ra,ffffffffc0202bd8 <free_pages>
    return listelm->next;
ffffffffc0202200:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202202:	00878963          	beq	a5,s0,ffffffffc0202214 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202206:	ff87a703          	lw	a4,-8(a5)
ffffffffc020220a:	679c                	ld	a5,8(a5)
ffffffffc020220c:	397d                	addiw	s2,s2,-1
ffffffffc020220e:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202210:	fe879be3          	bne	a5,s0,ffffffffc0202206 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0202214:	26091463          	bnez	s2,ffffffffc020247c <default_check+0x536>
    assert(total == 0);
ffffffffc0202218:	46049263          	bnez	s1,ffffffffc020267c <default_check+0x736>
}
ffffffffc020221c:	60a6                	ld	ra,72(sp)
ffffffffc020221e:	6406                	ld	s0,64(sp)
ffffffffc0202220:	74e2                	ld	s1,56(sp)
ffffffffc0202222:	7942                	ld	s2,48(sp)
ffffffffc0202224:	79a2                	ld	s3,40(sp)
ffffffffc0202226:	7a02                	ld	s4,32(sp)
ffffffffc0202228:	6ae2                	ld	s5,24(sp)
ffffffffc020222a:	6b42                	ld	s6,16(sp)
ffffffffc020222c:	6ba2                	ld	s7,8(sp)
ffffffffc020222e:	6c02                	ld	s8,0(sp)
ffffffffc0202230:	6161                	addi	sp,sp,80
ffffffffc0202232:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202234:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202236:	4481                	li	s1,0
ffffffffc0202238:	4901                	li	s2,0
ffffffffc020223a:	b3b9                	j	ffffffffc0201f88 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020223c:	00003697          	auipc	a3,0x3
ffffffffc0202240:	15c68693          	addi	a3,a3,348 # ffffffffc0205398 <commands+0xbc8>
ffffffffc0202244:	00003617          	auipc	a2,0x3
ffffffffc0202248:	cb460613          	addi	a2,a2,-844 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020224c:	0f000593          	li	a1,240
ffffffffc0202250:	00003517          	auipc	a0,0x3
ffffffffc0202254:	4c050513          	addi	a0,a0,1216 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202258:	eabfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020225c:	00003697          	auipc	a3,0x3
ffffffffc0202260:	52c68693          	addi	a3,a3,1324 # ffffffffc0205788 <commands+0xfb8>
ffffffffc0202264:	00003617          	auipc	a2,0x3
ffffffffc0202268:	c9460613          	addi	a2,a2,-876 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020226c:	0bd00593          	li	a1,189
ffffffffc0202270:	00003517          	auipc	a0,0x3
ffffffffc0202274:	4a050513          	addi	a0,a0,1184 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202278:	e8bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020227c:	00003697          	auipc	a3,0x3
ffffffffc0202280:	53468693          	addi	a3,a3,1332 # ffffffffc02057b0 <commands+0xfe0>
ffffffffc0202284:	00003617          	auipc	a2,0x3
ffffffffc0202288:	c7460613          	addi	a2,a2,-908 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020228c:	0be00593          	li	a1,190
ffffffffc0202290:	00003517          	auipc	a0,0x3
ffffffffc0202294:	48050513          	addi	a0,a0,1152 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202298:	e6bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020229c:	00003697          	auipc	a3,0x3
ffffffffc02022a0:	55468693          	addi	a3,a3,1364 # ffffffffc02057f0 <commands+0x1020>
ffffffffc02022a4:	00003617          	auipc	a2,0x3
ffffffffc02022a8:	c5460613          	addi	a2,a2,-940 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02022ac:	0c000593          	li	a1,192
ffffffffc02022b0:	00003517          	auipc	a0,0x3
ffffffffc02022b4:	46050513          	addi	a0,a0,1120 # ffffffffc0205710 <commands+0xf40>
ffffffffc02022b8:	e4bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02022bc:	00003697          	auipc	a3,0x3
ffffffffc02022c0:	5bc68693          	addi	a3,a3,1468 # ffffffffc0205878 <commands+0x10a8>
ffffffffc02022c4:	00003617          	auipc	a2,0x3
ffffffffc02022c8:	c3460613          	addi	a2,a2,-972 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02022cc:	0d900593          	li	a1,217
ffffffffc02022d0:	00003517          	auipc	a0,0x3
ffffffffc02022d4:	44050513          	addi	a0,a0,1088 # ffffffffc0205710 <commands+0xf40>
ffffffffc02022d8:	e2bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02022dc:	00003697          	auipc	a3,0x3
ffffffffc02022e0:	44c68693          	addi	a3,a3,1100 # ffffffffc0205728 <commands+0xf58>
ffffffffc02022e4:	00003617          	auipc	a2,0x3
ffffffffc02022e8:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02022ec:	0d200593          	li	a1,210
ffffffffc02022f0:	00003517          	auipc	a0,0x3
ffffffffc02022f4:	42050513          	addi	a0,a0,1056 # ffffffffc0205710 <commands+0xf40>
ffffffffc02022f8:	e0bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc02022fc:	00003697          	auipc	a3,0x3
ffffffffc0202300:	56c68693          	addi	a3,a3,1388 # ffffffffc0205868 <commands+0x1098>
ffffffffc0202304:	00003617          	auipc	a2,0x3
ffffffffc0202308:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020230c:	0d000593          	li	a1,208
ffffffffc0202310:	00003517          	auipc	a0,0x3
ffffffffc0202314:	40050513          	addi	a0,a0,1024 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202318:	debfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020231c:	00003697          	auipc	a3,0x3
ffffffffc0202320:	53468693          	addi	a3,a3,1332 # ffffffffc0205850 <commands+0x1080>
ffffffffc0202324:	00003617          	auipc	a2,0x3
ffffffffc0202328:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020232c:	0cb00593          	li	a1,203
ffffffffc0202330:	00003517          	auipc	a0,0x3
ffffffffc0202334:	3e050513          	addi	a0,a0,992 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202338:	dcbfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020233c:	00003697          	auipc	a3,0x3
ffffffffc0202340:	4f468693          	addi	a3,a3,1268 # ffffffffc0205830 <commands+0x1060>
ffffffffc0202344:	00003617          	auipc	a2,0x3
ffffffffc0202348:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020234c:	0c200593          	li	a1,194
ffffffffc0202350:	00003517          	auipc	a0,0x3
ffffffffc0202354:	3c050513          	addi	a0,a0,960 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202358:	dabfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc020235c:	00003697          	auipc	a3,0x3
ffffffffc0202360:	55468693          	addi	a3,a3,1364 # ffffffffc02058b0 <commands+0x10e0>
ffffffffc0202364:	00003617          	auipc	a2,0x3
ffffffffc0202368:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020236c:	0f800593          	li	a1,248
ffffffffc0202370:	00003517          	auipc	a0,0x3
ffffffffc0202374:	3a050513          	addi	a0,a0,928 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202378:	d8bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc020237c:	00003697          	auipc	a3,0x3
ffffffffc0202380:	1bc68693          	addi	a3,a3,444 # ffffffffc0205538 <commands+0xd68>
ffffffffc0202384:	00003617          	auipc	a2,0x3
ffffffffc0202388:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020238c:	0df00593          	li	a1,223
ffffffffc0202390:	00003517          	auipc	a0,0x3
ffffffffc0202394:	38050513          	addi	a0,a0,896 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202398:	d6bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020239c:	00003697          	auipc	a3,0x3
ffffffffc02023a0:	4b468693          	addi	a3,a3,1204 # ffffffffc0205850 <commands+0x1080>
ffffffffc02023a4:	00003617          	auipc	a2,0x3
ffffffffc02023a8:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02023ac:	0dd00593          	li	a1,221
ffffffffc02023b0:	00003517          	auipc	a0,0x3
ffffffffc02023b4:	36050513          	addi	a0,a0,864 # ffffffffc0205710 <commands+0xf40>
ffffffffc02023b8:	d4bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02023bc:	00003697          	auipc	a3,0x3
ffffffffc02023c0:	4d468693          	addi	a3,a3,1236 # ffffffffc0205890 <commands+0x10c0>
ffffffffc02023c4:	00003617          	auipc	a2,0x3
ffffffffc02023c8:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02023cc:	0dc00593          	li	a1,220
ffffffffc02023d0:	00003517          	auipc	a0,0x3
ffffffffc02023d4:	34050513          	addi	a0,a0,832 # ffffffffc0205710 <commands+0xf40>
ffffffffc02023d8:	d2bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02023dc:	00003697          	auipc	a3,0x3
ffffffffc02023e0:	34c68693          	addi	a3,a3,844 # ffffffffc0205728 <commands+0xf58>
ffffffffc02023e4:	00003617          	auipc	a2,0x3
ffffffffc02023e8:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02023ec:	0b900593          	li	a1,185
ffffffffc02023f0:	00003517          	auipc	a0,0x3
ffffffffc02023f4:	32050513          	addi	a0,a0,800 # ffffffffc0205710 <commands+0xf40>
ffffffffc02023f8:	d0bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02023fc:	00003697          	auipc	a3,0x3
ffffffffc0202400:	45468693          	addi	a3,a3,1108 # ffffffffc0205850 <commands+0x1080>
ffffffffc0202404:	00003617          	auipc	a2,0x3
ffffffffc0202408:	af460613          	addi	a2,a2,-1292 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020240c:	0d600593          	li	a1,214
ffffffffc0202410:	00003517          	auipc	a0,0x3
ffffffffc0202414:	30050513          	addi	a0,a0,768 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202418:	cebfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020241c:	00003697          	auipc	a3,0x3
ffffffffc0202420:	34c68693          	addi	a3,a3,844 # ffffffffc0205768 <commands+0xf98>
ffffffffc0202424:	00003617          	auipc	a2,0x3
ffffffffc0202428:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020242c:	0d400593          	li	a1,212
ffffffffc0202430:	00003517          	auipc	a0,0x3
ffffffffc0202434:	2e050513          	addi	a0,a0,736 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202438:	ccbfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020243c:	00003697          	auipc	a3,0x3
ffffffffc0202440:	30c68693          	addi	a3,a3,780 # ffffffffc0205748 <commands+0xf78>
ffffffffc0202444:	00003617          	auipc	a2,0x3
ffffffffc0202448:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020244c:	0d300593          	li	a1,211
ffffffffc0202450:	00003517          	auipc	a0,0x3
ffffffffc0202454:	2c050513          	addi	a0,a0,704 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202458:	cabfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020245c:	00003697          	auipc	a3,0x3
ffffffffc0202460:	30c68693          	addi	a3,a3,780 # ffffffffc0205768 <commands+0xf98>
ffffffffc0202464:	00003617          	auipc	a2,0x3
ffffffffc0202468:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020246c:	0bb00593          	li	a1,187
ffffffffc0202470:	00003517          	auipc	a0,0x3
ffffffffc0202474:	2a050513          	addi	a0,a0,672 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202478:	c8bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc020247c:	00003697          	auipc	a3,0x3
ffffffffc0202480:	58468693          	addi	a3,a3,1412 # ffffffffc0205a00 <commands+0x1230>
ffffffffc0202484:	00003617          	auipc	a2,0x3
ffffffffc0202488:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020248c:	12500593          	li	a1,293
ffffffffc0202490:	00003517          	auipc	a0,0x3
ffffffffc0202494:	28050513          	addi	a0,a0,640 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202498:	c6bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc020249c:	00003697          	auipc	a3,0x3
ffffffffc02024a0:	09c68693          	addi	a3,a3,156 # ffffffffc0205538 <commands+0xd68>
ffffffffc02024a4:	00003617          	auipc	a2,0x3
ffffffffc02024a8:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02024ac:	11a00593          	li	a1,282
ffffffffc02024b0:	00003517          	auipc	a0,0x3
ffffffffc02024b4:	26050513          	addi	a0,a0,608 # ffffffffc0205710 <commands+0xf40>
ffffffffc02024b8:	c4bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02024bc:	00003697          	auipc	a3,0x3
ffffffffc02024c0:	39468693          	addi	a3,a3,916 # ffffffffc0205850 <commands+0x1080>
ffffffffc02024c4:	00003617          	auipc	a2,0x3
ffffffffc02024c8:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02024cc:	11800593          	li	a1,280
ffffffffc02024d0:	00003517          	auipc	a0,0x3
ffffffffc02024d4:	24050513          	addi	a0,a0,576 # ffffffffc0205710 <commands+0xf40>
ffffffffc02024d8:	c2bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02024dc:	00003697          	auipc	a3,0x3
ffffffffc02024e0:	33468693          	addi	a3,a3,820 # ffffffffc0205810 <commands+0x1040>
ffffffffc02024e4:	00003617          	auipc	a2,0x3
ffffffffc02024e8:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02024ec:	0c100593          	li	a1,193
ffffffffc02024f0:	00003517          	auipc	a0,0x3
ffffffffc02024f4:	22050513          	addi	a0,a0,544 # ffffffffc0205710 <commands+0xf40>
ffffffffc02024f8:	c0bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02024fc:	00003697          	auipc	a3,0x3
ffffffffc0202500:	4c468693          	addi	a3,a3,1220 # ffffffffc02059c0 <commands+0x11f0>
ffffffffc0202504:	00003617          	auipc	a2,0x3
ffffffffc0202508:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020250c:	11200593          	li	a1,274
ffffffffc0202510:	00003517          	auipc	a0,0x3
ffffffffc0202514:	20050513          	addi	a0,a0,512 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202518:	bebfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020251c:	00003697          	auipc	a3,0x3
ffffffffc0202520:	48468693          	addi	a3,a3,1156 # ffffffffc02059a0 <commands+0x11d0>
ffffffffc0202524:	00003617          	auipc	a2,0x3
ffffffffc0202528:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020252c:	11000593          	li	a1,272
ffffffffc0202530:	00003517          	auipc	a0,0x3
ffffffffc0202534:	1e050513          	addi	a0,a0,480 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202538:	bcbfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020253c:	00003697          	auipc	a3,0x3
ffffffffc0202540:	43c68693          	addi	a3,a3,1084 # ffffffffc0205978 <commands+0x11a8>
ffffffffc0202544:	00003617          	auipc	a2,0x3
ffffffffc0202548:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020254c:	10e00593          	li	a1,270
ffffffffc0202550:	00003517          	auipc	a0,0x3
ffffffffc0202554:	1c050513          	addi	a0,a0,448 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202558:	babfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020255c:	00003697          	auipc	a3,0x3
ffffffffc0202560:	3f468693          	addi	a3,a3,1012 # ffffffffc0205950 <commands+0x1180>
ffffffffc0202564:	00003617          	auipc	a2,0x3
ffffffffc0202568:	99460613          	addi	a2,a2,-1644 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020256c:	10d00593          	li	a1,269
ffffffffc0202570:	00003517          	auipc	a0,0x3
ffffffffc0202574:	1a050513          	addi	a0,a0,416 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202578:	b8bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020257c:	00003697          	auipc	a3,0x3
ffffffffc0202580:	3c468693          	addi	a3,a3,964 # ffffffffc0205940 <commands+0x1170>
ffffffffc0202584:	00003617          	auipc	a2,0x3
ffffffffc0202588:	97460613          	addi	a2,a2,-1676 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020258c:	10800593          	li	a1,264
ffffffffc0202590:	00003517          	auipc	a0,0x3
ffffffffc0202594:	18050513          	addi	a0,a0,384 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202598:	b6bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020259c:	00003697          	auipc	a3,0x3
ffffffffc02025a0:	2b468693          	addi	a3,a3,692 # ffffffffc0205850 <commands+0x1080>
ffffffffc02025a4:	00003617          	auipc	a2,0x3
ffffffffc02025a8:	95460613          	addi	a2,a2,-1708 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02025ac:	10700593          	li	a1,263
ffffffffc02025b0:	00003517          	auipc	a0,0x3
ffffffffc02025b4:	16050513          	addi	a0,a0,352 # ffffffffc0205710 <commands+0xf40>
ffffffffc02025b8:	b4bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02025bc:	00003697          	auipc	a3,0x3
ffffffffc02025c0:	36468693          	addi	a3,a3,868 # ffffffffc0205920 <commands+0x1150>
ffffffffc02025c4:	00003617          	auipc	a2,0x3
ffffffffc02025c8:	93460613          	addi	a2,a2,-1740 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02025cc:	10600593          	li	a1,262
ffffffffc02025d0:	00003517          	auipc	a0,0x3
ffffffffc02025d4:	14050513          	addi	a0,a0,320 # ffffffffc0205710 <commands+0xf40>
ffffffffc02025d8:	b2bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02025dc:	00003697          	auipc	a3,0x3
ffffffffc02025e0:	31468693          	addi	a3,a3,788 # ffffffffc02058f0 <commands+0x1120>
ffffffffc02025e4:	00003617          	auipc	a2,0x3
ffffffffc02025e8:	91460613          	addi	a2,a2,-1772 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02025ec:	10500593          	li	a1,261
ffffffffc02025f0:	00003517          	auipc	a0,0x3
ffffffffc02025f4:	12050513          	addi	a0,a0,288 # ffffffffc0205710 <commands+0xf40>
ffffffffc02025f8:	b0bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02025fc:	00003697          	auipc	a3,0x3
ffffffffc0202600:	2dc68693          	addi	a3,a3,732 # ffffffffc02058d8 <commands+0x1108>
ffffffffc0202604:	00003617          	auipc	a2,0x3
ffffffffc0202608:	8f460613          	addi	a2,a2,-1804 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020260c:	10400593          	li	a1,260
ffffffffc0202610:	00003517          	auipc	a0,0x3
ffffffffc0202614:	10050513          	addi	a0,a0,256 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202618:	aebfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020261c:	00003697          	auipc	a3,0x3
ffffffffc0202620:	23468693          	addi	a3,a3,564 # ffffffffc0205850 <commands+0x1080>
ffffffffc0202624:	00003617          	auipc	a2,0x3
ffffffffc0202628:	8d460613          	addi	a2,a2,-1836 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020262c:	0fe00593          	li	a1,254
ffffffffc0202630:	00003517          	auipc	a0,0x3
ffffffffc0202634:	0e050513          	addi	a0,a0,224 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202638:	acbfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc020263c:	00003697          	auipc	a3,0x3
ffffffffc0202640:	28468693          	addi	a3,a3,644 # ffffffffc02058c0 <commands+0x10f0>
ffffffffc0202644:	00003617          	auipc	a2,0x3
ffffffffc0202648:	8b460613          	addi	a2,a2,-1868 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020264c:	0f900593          	li	a1,249
ffffffffc0202650:	00003517          	auipc	a0,0x3
ffffffffc0202654:	0c050513          	addi	a0,a0,192 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202658:	aabfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020265c:	00003697          	auipc	a3,0x3
ffffffffc0202660:	38468693          	addi	a3,a3,900 # ffffffffc02059e0 <commands+0x1210>
ffffffffc0202664:	00003617          	auipc	a2,0x3
ffffffffc0202668:	89460613          	addi	a2,a2,-1900 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020266c:	11700593          	li	a1,279
ffffffffc0202670:	00003517          	auipc	a0,0x3
ffffffffc0202674:	0a050513          	addi	a0,a0,160 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202678:	a8bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc020267c:	00003697          	auipc	a3,0x3
ffffffffc0202680:	39468693          	addi	a3,a3,916 # ffffffffc0205a10 <commands+0x1240>
ffffffffc0202684:	00003617          	auipc	a2,0x3
ffffffffc0202688:	87460613          	addi	a2,a2,-1932 # ffffffffc0204ef8 <commands+0x728>
ffffffffc020268c:	12600593          	li	a1,294
ffffffffc0202690:	00003517          	auipc	a0,0x3
ffffffffc0202694:	08050513          	addi	a0,a0,128 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202698:	a6bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc020269c:	00003697          	auipc	a3,0x3
ffffffffc02026a0:	d0c68693          	addi	a3,a3,-756 # ffffffffc02053a8 <commands+0xbd8>
ffffffffc02026a4:	00003617          	auipc	a2,0x3
ffffffffc02026a8:	85460613          	addi	a2,a2,-1964 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02026ac:	0f300593          	li	a1,243
ffffffffc02026b0:	00003517          	auipc	a0,0x3
ffffffffc02026b4:	06050513          	addi	a0,a0,96 # ffffffffc0205710 <commands+0xf40>
ffffffffc02026b8:	a4bfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02026bc:	00003697          	auipc	a3,0x3
ffffffffc02026c0:	08c68693          	addi	a3,a3,140 # ffffffffc0205748 <commands+0xf78>
ffffffffc02026c4:	00003617          	auipc	a2,0x3
ffffffffc02026c8:	83460613          	addi	a2,a2,-1996 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02026cc:	0ba00593          	li	a1,186
ffffffffc02026d0:	00003517          	auipc	a0,0x3
ffffffffc02026d4:	04050513          	addi	a0,a0,64 # ffffffffc0205710 <commands+0xf40>
ffffffffc02026d8:	a2bfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02026dc <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02026dc:	1141                	addi	sp,sp,-16
ffffffffc02026de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02026e0:	14058a63          	beqz	a1,ffffffffc0202834 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02026e4:	00359693          	slli	a3,a1,0x3
ffffffffc02026e8:	96ae                	add	a3,a3,a1
ffffffffc02026ea:	068e                	slli	a3,a3,0x3
ffffffffc02026ec:	96aa                	add	a3,a3,a0
ffffffffc02026ee:	87aa                	mv	a5,a0
ffffffffc02026f0:	02d50263          	beq	a0,a3,ffffffffc0202714 <default_free_pages+0x38>
ffffffffc02026f4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02026f6:	8b05                	andi	a4,a4,1
ffffffffc02026f8:	10071e63          	bnez	a4,ffffffffc0202814 <default_free_pages+0x138>
ffffffffc02026fc:	6798                	ld	a4,8(a5)
ffffffffc02026fe:	8b09                	andi	a4,a4,2
ffffffffc0202700:	10071a63          	bnez	a4,ffffffffc0202814 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202704:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202708:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020270c:	04878793          	addi	a5,a5,72
ffffffffc0202710:	fed792e3          	bne	a5,a3,ffffffffc02026f4 <default_free_pages+0x18>
    base->property = n;
ffffffffc0202714:	2581                	sext.w	a1,a1
ffffffffc0202716:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202718:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020271c:	4789                	li	a5,2
ffffffffc020271e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202722:	0000f697          	auipc	a3,0xf
ffffffffc0202726:	9c668693          	addi	a3,a3,-1594 # ffffffffc02110e8 <free_area>
ffffffffc020272a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020272c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020272e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202732:	9db9                	addw	a1,a1,a4
ffffffffc0202734:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202736:	0ad78863          	beq	a5,a3,ffffffffc02027e6 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc020273a:	fe078713          	addi	a4,a5,-32
ffffffffc020273e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202742:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202744:	00e56a63          	bltu	a0,a4,ffffffffc0202758 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0202748:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020274a:	06d70263          	beq	a4,a3,ffffffffc02027ae <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020274e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202750:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202754:	fee57ae3          	bgeu	a0,a4,ffffffffc0202748 <default_free_pages+0x6c>
ffffffffc0202758:	c199                	beqz	a1,ffffffffc020275e <default_free_pages+0x82>
ffffffffc020275a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020275e:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202760:	e390                	sd	a2,0(a5)
ffffffffc0202762:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202764:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202766:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc0202768:	02d70063          	beq	a4,a3,ffffffffc0202788 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc020276c:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0202770:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0202774:	02081613          	slli	a2,a6,0x20
ffffffffc0202778:	9201                	srli	a2,a2,0x20
ffffffffc020277a:	00361793          	slli	a5,a2,0x3
ffffffffc020277e:	97b2                	add	a5,a5,a2
ffffffffc0202780:	078e                	slli	a5,a5,0x3
ffffffffc0202782:	97ae                	add	a5,a5,a1
ffffffffc0202784:	02f50f63          	beq	a0,a5,ffffffffc02027c2 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0202788:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc020278a:	00d70f63          	beq	a4,a3,ffffffffc02027a8 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc020278e:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0202790:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0202794:	02059613          	slli	a2,a1,0x20
ffffffffc0202798:	9201                	srli	a2,a2,0x20
ffffffffc020279a:	00361793          	slli	a5,a2,0x3
ffffffffc020279e:	97b2                	add	a5,a5,a2
ffffffffc02027a0:	078e                	slli	a5,a5,0x3
ffffffffc02027a2:	97aa                	add	a5,a5,a0
ffffffffc02027a4:	04f68863          	beq	a3,a5,ffffffffc02027f4 <default_free_pages+0x118>
}
ffffffffc02027a8:	60a2                	ld	ra,8(sp)
ffffffffc02027aa:	0141                	addi	sp,sp,16
ffffffffc02027ac:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02027ae:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02027b0:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02027b2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02027b4:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02027b6:	02d70563          	beq	a4,a3,ffffffffc02027e0 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02027ba:	8832                	mv	a6,a2
ffffffffc02027bc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02027be:	87ba                	mv	a5,a4
ffffffffc02027c0:	bf41                	j	ffffffffc0202750 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02027c2:	4d1c                	lw	a5,24(a0)
ffffffffc02027c4:	0107883b          	addw	a6,a5,a6
ffffffffc02027c8:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02027cc:	57f5                	li	a5,-3
ffffffffc02027ce:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02027d2:	7110                	ld	a2,32(a0)
ffffffffc02027d4:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc02027d6:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02027d8:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02027da:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02027dc:	e390                	sd	a2,0(a5)
ffffffffc02027de:	b775                	j	ffffffffc020278a <default_free_pages+0xae>
ffffffffc02027e0:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02027e2:	873e                	mv	a4,a5
ffffffffc02027e4:	b761                	j	ffffffffc020276c <default_free_pages+0x90>
}
ffffffffc02027e6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02027e8:	e390                	sd	a2,0(a5)
ffffffffc02027ea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02027ec:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02027ee:	f11c                	sd	a5,32(a0)
ffffffffc02027f0:	0141                	addi	sp,sp,16
ffffffffc02027f2:	8082                	ret
            base->property += p->property;
ffffffffc02027f4:	ff872783          	lw	a5,-8(a4)
ffffffffc02027f8:	fe870693          	addi	a3,a4,-24
ffffffffc02027fc:	9dbd                	addw	a1,a1,a5
ffffffffc02027fe:	cd0c                	sw	a1,24(a0)
ffffffffc0202800:	57f5                	li	a5,-3
ffffffffc0202802:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202806:	6314                	ld	a3,0(a4)
ffffffffc0202808:	671c                	ld	a5,8(a4)
}
ffffffffc020280a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020280c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020280e:	e394                	sd	a3,0(a5)
ffffffffc0202810:	0141                	addi	sp,sp,16
ffffffffc0202812:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202814:	00003697          	auipc	a3,0x3
ffffffffc0202818:	21468693          	addi	a3,a3,532 # ffffffffc0205a28 <commands+0x1258>
ffffffffc020281c:	00002617          	auipc	a2,0x2
ffffffffc0202820:	6dc60613          	addi	a2,a2,1756 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0202824:	08300593          	li	a1,131
ffffffffc0202828:	00003517          	auipc	a0,0x3
ffffffffc020282c:	ee850513          	addi	a0,a0,-280 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202830:	8d3fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202834:	00003697          	auipc	a3,0x3
ffffffffc0202838:	1ec68693          	addi	a3,a3,492 # ffffffffc0205a20 <commands+0x1250>
ffffffffc020283c:	00002617          	auipc	a2,0x2
ffffffffc0202840:	6bc60613          	addi	a2,a2,1724 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0202844:	08000593          	li	a1,128
ffffffffc0202848:	00003517          	auipc	a0,0x3
ffffffffc020284c:	ec850513          	addi	a0,a0,-312 # ffffffffc0205710 <commands+0xf40>
ffffffffc0202850:	8b3fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202854 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202854:	c959                	beqz	a0,ffffffffc02028ea <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202856:	0000f597          	auipc	a1,0xf
ffffffffc020285a:	89258593          	addi	a1,a1,-1902 # ffffffffc02110e8 <free_area>
ffffffffc020285e:	0105a803          	lw	a6,16(a1)
ffffffffc0202862:	862a                	mv	a2,a0
ffffffffc0202864:	02081793          	slli	a5,a6,0x20
ffffffffc0202868:	9381                	srli	a5,a5,0x20
ffffffffc020286a:	00a7ee63          	bltu	a5,a0,ffffffffc0202886 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020286e:	87ae                	mv	a5,a1
ffffffffc0202870:	a801                	j	ffffffffc0202880 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202872:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202876:	02071693          	slli	a3,a4,0x20
ffffffffc020287a:	9281                	srli	a3,a3,0x20
ffffffffc020287c:	00c6f763          	bgeu	a3,a2,ffffffffc020288a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202880:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202882:	feb798e3          	bne	a5,a1,ffffffffc0202872 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202886:	4501                	li	a0,0
}
ffffffffc0202888:	8082                	ret
    return listelm->prev;
ffffffffc020288a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020288e:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202892:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc0202896:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc020289a:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020289e:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02028a2:	02d67b63          	bgeu	a2,a3,ffffffffc02028d8 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02028a6:	00361693          	slli	a3,a2,0x3
ffffffffc02028aa:	96b2                	add	a3,a3,a2
ffffffffc02028ac:	068e                	slli	a3,a3,0x3
ffffffffc02028ae:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02028b0:	41c7073b          	subw	a4,a4,t3
ffffffffc02028b4:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02028b6:	00868613          	addi	a2,a3,8
ffffffffc02028ba:	4709                	li	a4,2
ffffffffc02028bc:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02028c0:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02028c4:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02028c8:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02028cc:	e310                	sd	a2,0(a4)
ffffffffc02028ce:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02028d2:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02028d4:	0316b023          	sd	a7,32(a3)
ffffffffc02028d8:	41c8083b          	subw	a6,a6,t3
ffffffffc02028dc:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02028e0:	5775                	li	a4,-3
ffffffffc02028e2:	17a1                	addi	a5,a5,-24
ffffffffc02028e4:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02028e8:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02028ea:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02028ec:	00003697          	auipc	a3,0x3
ffffffffc02028f0:	13468693          	addi	a3,a3,308 # ffffffffc0205a20 <commands+0x1250>
ffffffffc02028f4:	00002617          	auipc	a2,0x2
ffffffffc02028f8:	60460613          	addi	a2,a2,1540 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02028fc:	06200593          	li	a1,98
ffffffffc0202900:	00003517          	auipc	a0,0x3
ffffffffc0202904:	e1050513          	addi	a0,a0,-496 # ffffffffc0205710 <commands+0xf40>
default_alloc_pages(size_t n) {
ffffffffc0202908:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020290a:	ff8fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020290e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020290e:	1141                	addi	sp,sp,-16
ffffffffc0202910:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202912:	c9e1                	beqz	a1,ffffffffc02029e2 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202914:	00359693          	slli	a3,a1,0x3
ffffffffc0202918:	96ae                	add	a3,a3,a1
ffffffffc020291a:	068e                	slli	a3,a3,0x3
ffffffffc020291c:	96aa                	add	a3,a3,a0
ffffffffc020291e:	87aa                	mv	a5,a0
ffffffffc0202920:	00d50f63          	beq	a0,a3,ffffffffc020293e <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202924:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202926:	8b05                	andi	a4,a4,1
ffffffffc0202928:	cf49                	beqz	a4,ffffffffc02029c2 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc020292a:	0007ac23          	sw	zero,24(a5)
ffffffffc020292e:	0007b423          	sd	zero,8(a5)
ffffffffc0202932:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202936:	04878793          	addi	a5,a5,72
ffffffffc020293a:	fed795e3          	bne	a5,a3,ffffffffc0202924 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020293e:	2581                	sext.w	a1,a1
ffffffffc0202940:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202942:	4789                	li	a5,2
ffffffffc0202944:	00850713          	addi	a4,a0,8
ffffffffc0202948:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020294c:	0000e697          	auipc	a3,0xe
ffffffffc0202950:	79c68693          	addi	a3,a3,1948 # ffffffffc02110e8 <free_area>
ffffffffc0202954:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202956:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202958:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020295c:	9db9                	addw	a1,a1,a4
ffffffffc020295e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202960:	04d78a63          	beq	a5,a3,ffffffffc02029b4 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0202964:	fe078713          	addi	a4,a5,-32
ffffffffc0202968:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020296c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020296e:	00e56a63          	bltu	a0,a4,ffffffffc0202982 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0202972:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202974:	02d70263          	beq	a4,a3,ffffffffc0202998 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0202978:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020297a:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020297e:	fee57ae3          	bgeu	a0,a4,ffffffffc0202972 <default_init_memmap+0x64>
ffffffffc0202982:	c199                	beqz	a1,ffffffffc0202988 <default_init_memmap+0x7a>
ffffffffc0202984:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202988:	6398                	ld	a4,0(a5)
}
ffffffffc020298a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020298c:	e390                	sd	a2,0(a5)
ffffffffc020298e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202990:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202992:	f118                	sd	a4,32(a0)
ffffffffc0202994:	0141                	addi	sp,sp,16
ffffffffc0202996:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202998:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020299a:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc020299c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020299e:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02029a0:	00d70663          	beq	a4,a3,ffffffffc02029ac <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02029a4:	8832                	mv	a6,a2
ffffffffc02029a6:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02029a8:	87ba                	mv	a5,a4
ffffffffc02029aa:	bfc1                	j	ffffffffc020297a <default_init_memmap+0x6c>
}
ffffffffc02029ac:	60a2                	ld	ra,8(sp)
ffffffffc02029ae:	e290                	sd	a2,0(a3)
ffffffffc02029b0:	0141                	addi	sp,sp,16
ffffffffc02029b2:	8082                	ret
ffffffffc02029b4:	60a2                	ld	ra,8(sp)
ffffffffc02029b6:	e390                	sd	a2,0(a5)
ffffffffc02029b8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02029ba:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02029bc:	f11c                	sd	a5,32(a0)
ffffffffc02029be:	0141                	addi	sp,sp,16
ffffffffc02029c0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02029c2:	00003697          	auipc	a3,0x3
ffffffffc02029c6:	08e68693          	addi	a3,a3,142 # ffffffffc0205a50 <commands+0x1280>
ffffffffc02029ca:	00002617          	auipc	a2,0x2
ffffffffc02029ce:	52e60613          	addi	a2,a2,1326 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02029d2:	04900593          	li	a1,73
ffffffffc02029d6:	00003517          	auipc	a0,0x3
ffffffffc02029da:	d3a50513          	addi	a0,a0,-710 # ffffffffc0205710 <commands+0xf40>
ffffffffc02029de:	f24fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc02029e2:	00003697          	auipc	a3,0x3
ffffffffc02029e6:	03e68693          	addi	a3,a3,62 # ffffffffc0205a20 <commands+0x1250>
ffffffffc02029ea:	00002617          	auipc	a2,0x2
ffffffffc02029ee:	50e60613          	addi	a2,a2,1294 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02029f2:	04600593          	li	a1,70
ffffffffc02029f6:	00003517          	auipc	a0,0x3
ffffffffc02029fa:	d1a50513          	addi	a0,a0,-742 # ffffffffc0205710 <commands+0xf40>
ffffffffc02029fe:	f04fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a02 <lru_pgfault>:
    }
    return 0;
}

// 处理页面错误，进行LRU页面调度
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202a02:	7179                	addi	sp,sp,-48
ffffffffc0202a04:	ec26                	sd	s1,24(sp)
    cprintf("lru page fault at 0x%x\n", addr);  // 打印缺页的虚拟地址
ffffffffc0202a06:	85b2                	mv	a1,a2
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202a08:	84aa                	mv	s1,a0
    cprintf("lru page fault at 0x%x\n", addr);  // 打印缺页的虚拟地址
ffffffffc0202a0a:	00003517          	auipc	a0,0x3
ffffffffc0202a0e:	0a650513          	addi	a0,a0,166 # ffffffffc0205ab0 <default_pmm_manager+0x38>
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202a12:	e84a                	sd	s2,16(sp)
ffffffffc0202a14:	f406                	sd	ra,40(sp)
ffffffffc0202a16:	f022                	sd	s0,32(sp)
ffffffffc0202a18:	e44e                	sd	s3,8(sp)
ffffffffc0202a1a:	8932                	mv	s2,a2
    cprintf("lru page fault at 0x%x\n", addr);  // 打印缺页的虚拟地址
ffffffffc0202a1c:	e9efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if(swap_init_ok) 
ffffffffc0202a20:	0000f797          	auipc	a5,0xf
ffffffffc0202a24:	b287a783          	lw	a5,-1240(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0202a28:	ebc9                	bnez	a5,ffffffffc0202aba <lru_pgfault+0xb8>
        unable_page_read(mm);  // 如果初始化了交换机制，更新页面访问权限
    
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);  // 获取页面的页表项
ffffffffc0202a2a:	6c88                	ld	a0,24(s1)
ffffffffc0202a2c:	4601                	li	a2,0
ffffffffc0202a2e:	85ca                	mv	a1,s2
ffffffffc0202a30:	222000ef          	jal	ra,ffffffffc0202c52 <get_pte>
    *ptep |= PTE_R;  // 设置页面为可读
ffffffffc0202a34:	6114                	ld	a3,0(a0)

    if(!swap_init_ok) 
ffffffffc0202a36:	0000f717          	auipc	a4,0xf
ffffffffc0202a3a:	b1272703          	lw	a4,-1262(a4) # ffffffffc0211548 <swap_init_ok>
    *ptep |= PTE_R;  // 设置页面为可读
ffffffffc0202a3e:	0026e793          	ori	a5,a3,2
ffffffffc0202a42:	e11c                	sd	a5,0(a0)
    if(!swap_init_ok) 
ffffffffc0202a44:	eb09                	bnez	a4,ffffffffc0202a56 <lru_pgfault+0x54>
            list_add(head, le);  // 将该页面重新添加到链表头部
            break;
        }
    }
    return 0;
}
ffffffffc0202a46:	70a2                	ld	ra,40(sp)
ffffffffc0202a48:	7402                	ld	s0,32(sp)
ffffffffc0202a4a:	64e2                	ld	s1,24(sp)
ffffffffc0202a4c:	6942                	ld	s2,16(sp)
ffffffffc0202a4e:	69a2                	ld	s3,8(sp)
ffffffffc0202a50:	4501                	li	a0,0
ffffffffc0202a52:	6145                	addi	sp,sp,48
ffffffffc0202a54:	8082                	ret
    if (!(pte & PTE_V)) {
ffffffffc0202a56:	8a85                	andi	a3,a3,1
ffffffffc0202a58:	c2d9                	beqz	a3,ffffffffc0202ade <lru_pgfault+0xdc>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a5a:	078a                	slli	a5,a5,0x2
ffffffffc0202a5c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a5e:	0000f717          	auipc	a4,0xf
ffffffffc0202a62:	b0273703          	ld	a4,-1278(a4) # ffffffffc0211560 <npage>
ffffffffc0202a66:	08e7f863          	bgeu	a5,a4,ffffffffc0202af6 <lru_pgfault+0xf4>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a6a:	00004717          	auipc	a4,0x4
ffffffffc0202a6e:	8fe73703          	ld	a4,-1794(a4) # ffffffffc0206368 <nbase>
ffffffffc0202a72:	8f99                	sub	a5,a5,a4
ffffffffc0202a74:	00379613          	slli	a2,a5,0x3
    list_entry_t *head = (list_entry_t*) mm->sm_priv, *le = head;
ffffffffc0202a78:	7494                	ld	a3,40(s1)
ffffffffc0202a7a:	97b2                	add	a5,a5,a2
ffffffffc0202a7c:	078e                	slli	a5,a5,0x3
ffffffffc0202a7e:	0000f617          	auipc	a2,0xf
ffffffffc0202a82:	aea63603          	ld	a2,-1302(a2) # ffffffffc0211568 <pages>
ffffffffc0202a86:	963e                	add	a2,a2,a5
ffffffffc0202a88:	87b6                	mv	a5,a3
    return listelm->prev;
ffffffffc0202a8a:	639c                	ld	a5,0(a5)
    while ((le = list_prev(le)) != head)
ffffffffc0202a8c:	faf68de3          	beq	a3,a5,ffffffffc0202a46 <lru_pgfault+0x44>
        struct Page* curr = le2page(le, pra_page_link);
ffffffffc0202a90:	fd078713          	addi	a4,a5,-48
        if(page == curr) {
ffffffffc0202a94:	fee61be3          	bne	a2,a4,ffffffffc0202a8a <lru_pgfault+0x88>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202a98:	638c                	ld	a1,0(a5)
ffffffffc0202a9a:	6790                	ld	a2,8(a5)
}
ffffffffc0202a9c:	70a2                	ld	ra,40(sp)
ffffffffc0202a9e:	7402                	ld	s0,32(sp)
    prev->next = next;
ffffffffc0202aa0:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202aa2:	6698                	ld	a4,8(a3)
    next->prev = prev;
ffffffffc0202aa4:	e20c                	sd	a1,0(a2)
ffffffffc0202aa6:	64e2                	ld	s1,24(sp)
    prev->next = next->prev = elm;
ffffffffc0202aa8:	e31c                	sd	a5,0(a4)
ffffffffc0202aaa:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc0202aac:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0202aae:	e394                	sd	a3,0(a5)
ffffffffc0202ab0:	6942                	ld	s2,16(sp)
ffffffffc0202ab2:	69a2                	ld	s3,8(sp)
ffffffffc0202ab4:	4501                	li	a0,0
ffffffffc0202ab6:	6145                	addi	sp,sp,48
ffffffffc0202ab8:	8082                	ret
    list_entry_t *head = (list_entry_t*) mm->sm_priv, *le = head;
ffffffffc0202aba:	0284b983          	ld	s3,40(s1)
    return listelm->prev;
ffffffffc0202abe:	0009b403          	ld	s0,0(s3)
    while ((le = list_prev(le)) != head)
ffffffffc0202ac2:	f68984e3          	beq	s3,s0,ffffffffc0202a2a <lru_pgfault+0x28>
        ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc0202ac6:	680c                	ld	a1,16(s0)
ffffffffc0202ac8:	6c88                	ld	a0,24(s1)
ffffffffc0202aca:	4601                	li	a2,0
ffffffffc0202acc:	186000ef          	jal	ra,ffffffffc0202c52 <get_pte>
        *ptep &= ~PTE_R;  // 清除页面的读权限
ffffffffc0202ad0:	611c                	ld	a5,0(a0)
ffffffffc0202ad2:	6000                	ld	s0,0(s0)
ffffffffc0202ad4:	9bf5                	andi	a5,a5,-3
ffffffffc0202ad6:	e11c                	sd	a5,0(a0)
    while ((le = list_prev(le)) != head)
ffffffffc0202ad8:	fe8997e3          	bne	s3,s0,ffffffffc0202ac6 <lru_pgfault+0xc4>
ffffffffc0202adc:	b7b9                	j	ffffffffc0202a2a <lru_pgfault+0x28>
        panic("pte2page called with invalid pte");
ffffffffc0202ade:	00003617          	auipc	a2,0x3
ffffffffc0202ae2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0205560 <commands+0xd90>
ffffffffc0202ae6:	07000593          	li	a1,112
ffffffffc0202aea:	00002517          	auipc	a0,0x2
ffffffffc0202aee:	67e50513          	addi	a0,a0,1662 # ffffffffc0205168 <commands+0x998>
ffffffffc0202af2:	e10fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202af6:	00002617          	auipc	a2,0x2
ffffffffc0202afa:	65260613          	addi	a2,a2,1618 # ffffffffc0205148 <commands+0x978>
ffffffffc0202afe:	06500593          	li	a1,101
ffffffffc0202b02:	00002517          	auipc	a0,0x2
ffffffffc0202b06:	66650513          	addi	a0,a0,1638 # ffffffffc0205168 <commands+0x998>
ffffffffc0202b0a:	df8fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b0e <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202b0e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202b10:	00002617          	auipc	a2,0x2
ffffffffc0202b14:	63860613          	addi	a2,a2,1592 # ffffffffc0205148 <commands+0x978>
ffffffffc0202b18:	06500593          	li	a1,101
ffffffffc0202b1c:	00002517          	auipc	a0,0x2
ffffffffc0202b20:	64c50513          	addi	a0,a0,1612 # ffffffffc0205168 <commands+0x998>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202b24:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202b26:	ddcfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b2a <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202b2a:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202b2c:	00003617          	auipc	a2,0x3
ffffffffc0202b30:	a3460613          	addi	a2,a2,-1484 # ffffffffc0205560 <commands+0xd90>
ffffffffc0202b34:	07000593          	li	a1,112
ffffffffc0202b38:	00002517          	auipc	a0,0x2
ffffffffc0202b3c:	63050513          	addi	a0,a0,1584 # ffffffffc0205168 <commands+0x998>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202b40:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202b42:	dc0fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b46 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202b46:	7139                	addi	sp,sp,-64
ffffffffc0202b48:	f426                	sd	s1,40(sp)
ffffffffc0202b4a:	f04a                	sd	s2,32(sp)
ffffffffc0202b4c:	ec4e                	sd	s3,24(sp)
ffffffffc0202b4e:	e852                	sd	s4,16(sp)
ffffffffc0202b50:	e456                	sd	s5,8(sp)
ffffffffc0202b52:	e05a                	sd	s6,0(sp)
ffffffffc0202b54:	fc06                	sd	ra,56(sp)
ffffffffc0202b56:	f822                	sd	s0,48(sp)
ffffffffc0202b58:	84aa                	mv	s1,a0
ffffffffc0202b5a:	0000f917          	auipc	s2,0xf
ffffffffc0202b5e:	a1690913          	addi	s2,s2,-1514 # ffffffffc0211570 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202b62:	4a05                	li	s4,1
ffffffffc0202b64:	0000fa97          	auipc	s5,0xf
ffffffffc0202b68:	9e4a8a93          	addi	s5,s5,-1564 # ffffffffc0211548 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b6c:	0005099b          	sext.w	s3,a0
ffffffffc0202b70:	0000fb17          	auipc	s6,0xf
ffffffffc0202b74:	9b0b0b13          	addi	s6,s6,-1616 # ffffffffc0211520 <check_mm_struct>
ffffffffc0202b78:	a01d                	j	ffffffffc0202b9e <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202b7a:	00093783          	ld	a5,0(s2)
ffffffffc0202b7e:	6f9c                	ld	a5,24(a5)
ffffffffc0202b80:	9782                	jalr	a5
ffffffffc0202b82:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b84:	4601                	li	a2,0
ffffffffc0202b86:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202b88:	ec0d                	bnez	s0,ffffffffc0202bc2 <alloc_pages+0x7c>
ffffffffc0202b8a:	029a6c63          	bltu	s4,s1,ffffffffc0202bc2 <alloc_pages+0x7c>
ffffffffc0202b8e:	000aa783          	lw	a5,0(s5)
ffffffffc0202b92:	2781                	sext.w	a5,a5
ffffffffc0202b94:	c79d                	beqz	a5,ffffffffc0202bc2 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b96:	000b3503          	ld	a0,0(s6)
ffffffffc0202b9a:	a02ff0ef          	jal	ra,ffffffffc0201d9c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b9e:	100027f3          	csrr	a5,sstatus
ffffffffc0202ba2:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202ba4:	8526                	mv	a0,s1
ffffffffc0202ba6:	dbf1                	beqz	a5,ffffffffc0202b7a <alloc_pages+0x34>
        intr_disable();
ffffffffc0202ba8:	947fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202bac:	00093783          	ld	a5,0(s2)
ffffffffc0202bb0:	8526                	mv	a0,s1
ffffffffc0202bb2:	6f9c                	ld	a5,24(a5)
ffffffffc0202bb4:	9782                	jalr	a5
ffffffffc0202bb6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bb8:	931fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202bbc:	4601                	li	a2,0
ffffffffc0202bbe:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202bc0:	d469                	beqz	s0,ffffffffc0202b8a <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202bc2:	70e2                	ld	ra,56(sp)
ffffffffc0202bc4:	8522                	mv	a0,s0
ffffffffc0202bc6:	7442                	ld	s0,48(sp)
ffffffffc0202bc8:	74a2                	ld	s1,40(sp)
ffffffffc0202bca:	7902                	ld	s2,32(sp)
ffffffffc0202bcc:	69e2                	ld	s3,24(sp)
ffffffffc0202bce:	6a42                	ld	s4,16(sp)
ffffffffc0202bd0:	6aa2                	ld	s5,8(sp)
ffffffffc0202bd2:	6b02                	ld	s6,0(sp)
ffffffffc0202bd4:	6121                	addi	sp,sp,64
ffffffffc0202bd6:	8082                	ret

ffffffffc0202bd8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202bd8:	100027f3          	csrr	a5,sstatus
ffffffffc0202bdc:	8b89                	andi	a5,a5,2
ffffffffc0202bde:	e799                	bnez	a5,ffffffffc0202bec <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202be0:	0000f797          	auipc	a5,0xf
ffffffffc0202be4:	9907b783          	ld	a5,-1648(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0202be8:	739c                	ld	a5,32(a5)
ffffffffc0202bea:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202bec:	1101                	addi	sp,sp,-32
ffffffffc0202bee:	ec06                	sd	ra,24(sp)
ffffffffc0202bf0:	e822                	sd	s0,16(sp)
ffffffffc0202bf2:	e426                	sd	s1,8(sp)
ffffffffc0202bf4:	842a                	mv	s0,a0
ffffffffc0202bf6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202bf8:	8f7fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202bfc:	0000f797          	auipc	a5,0xf
ffffffffc0202c00:	9747b783          	ld	a5,-1676(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0202c04:	739c                	ld	a5,32(a5)
ffffffffc0202c06:	85a6                	mv	a1,s1
ffffffffc0202c08:	8522                	mv	a0,s0
ffffffffc0202c0a:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202c0c:	6442                	ld	s0,16(sp)
ffffffffc0202c0e:	60e2                	ld	ra,24(sp)
ffffffffc0202c10:	64a2                	ld	s1,8(sp)
ffffffffc0202c12:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202c14:	8d5fd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202c18 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c18:	100027f3          	csrr	a5,sstatus
ffffffffc0202c1c:	8b89                	andi	a5,a5,2
ffffffffc0202c1e:	e799                	bnez	a5,ffffffffc0202c2c <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202c20:	0000f797          	auipc	a5,0xf
ffffffffc0202c24:	9507b783          	ld	a5,-1712(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0202c28:	779c                	ld	a5,40(a5)
ffffffffc0202c2a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202c2c:	1141                	addi	sp,sp,-16
ffffffffc0202c2e:	e406                	sd	ra,8(sp)
ffffffffc0202c30:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202c32:	8bdfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202c36:	0000f797          	auipc	a5,0xf
ffffffffc0202c3a:	93a7b783          	ld	a5,-1734(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0202c3e:	779c                	ld	a5,40(a5)
ffffffffc0202c40:	9782                	jalr	a5
ffffffffc0202c42:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202c44:	8a5fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202c48:	60a2                	ld	ra,8(sp)
ffffffffc0202c4a:	8522                	mv	a0,s0
ffffffffc0202c4c:	6402                	ld	s0,0(sp)
ffffffffc0202c4e:	0141                	addi	sp,sp,16
ffffffffc0202c50:	8082                	ret

ffffffffc0202c52 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c52:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202c56:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c5a:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c5c:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c5e:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c60:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c64:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c66:	f84a                	sd	s2,48(sp)
ffffffffc0202c68:	f44e                	sd	s3,40(sp)
ffffffffc0202c6a:	f052                	sd	s4,32(sp)
ffffffffc0202c6c:	e486                	sd	ra,72(sp)
ffffffffc0202c6e:	e0a2                	sd	s0,64(sp)
ffffffffc0202c70:	ec56                	sd	s5,24(sp)
ffffffffc0202c72:	e85a                	sd	s6,16(sp)
ffffffffc0202c74:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c76:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c7a:	892e                	mv	s2,a1
ffffffffc0202c7c:	8a32                	mv	s4,a2
ffffffffc0202c7e:	0000f997          	auipc	s3,0xf
ffffffffc0202c82:	8e298993          	addi	s3,s3,-1822 # ffffffffc0211560 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c86:	efb5                	bnez	a5,ffffffffc0202d02 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c88:	14060c63          	beqz	a2,ffffffffc0202de0 <get_pte+0x18e>
ffffffffc0202c8c:	4505                	li	a0,1
ffffffffc0202c8e:	eb9ff0ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202c92:	842a                	mv	s0,a0
ffffffffc0202c94:	14050663          	beqz	a0,ffffffffc0202de0 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c98:	0000fb97          	auipc	s7,0xf
ffffffffc0202c9c:	8d0b8b93          	addi	s7,s7,-1840 # ffffffffc0211568 <pages>
ffffffffc0202ca0:	000bb503          	ld	a0,0(s7)
ffffffffc0202ca4:	00003b17          	auipc	s6,0x3
ffffffffc0202ca8:	6bcb3b03          	ld	s6,1724(s6) # ffffffffc0206360 <error_string+0x38>
ffffffffc0202cac:	00080ab7          	lui	s5,0x80
ffffffffc0202cb0:	40a40533          	sub	a0,s0,a0
ffffffffc0202cb4:	850d                	srai	a0,a0,0x3
ffffffffc0202cb6:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cba:	0000f997          	auipc	s3,0xf
ffffffffc0202cbe:	8a698993          	addi	s3,s3,-1882 # ffffffffc0211560 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202cc2:	4785                	li	a5,1
ffffffffc0202cc4:	0009b703          	ld	a4,0(s3)
ffffffffc0202cc8:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cca:	9556                	add	a0,a0,s5
ffffffffc0202ccc:	00c51793          	slli	a5,a0,0xc
ffffffffc0202cd0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cd2:	0532                	slli	a0,a0,0xc
ffffffffc0202cd4:	14e7fd63          	bgeu	a5,a4,ffffffffc0202e2e <get_pte+0x1dc>
ffffffffc0202cd8:	0000f797          	auipc	a5,0xf
ffffffffc0202cdc:	8a07b783          	ld	a5,-1888(a5) # ffffffffc0211578 <va_pa_offset>
ffffffffc0202ce0:	6605                	lui	a2,0x1
ffffffffc0202ce2:	4581                	li	a1,0
ffffffffc0202ce4:	953e                	add	a0,a0,a5
ffffffffc0202ce6:	3a2010ef          	jal	ra,ffffffffc0204088 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cea:	000bb683          	ld	a3,0(s7)
ffffffffc0202cee:	40d406b3          	sub	a3,s0,a3
ffffffffc0202cf2:	868d                	srai	a3,a3,0x3
ffffffffc0202cf4:	036686b3          	mul	a3,a3,s6
ffffffffc0202cf8:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202cfa:	06aa                	slli	a3,a3,0xa
ffffffffc0202cfc:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202d00:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202d02:	77fd                	lui	a5,0xfffff
ffffffffc0202d04:	068a                	slli	a3,a3,0x2
ffffffffc0202d06:	0009b703          	ld	a4,0(s3)
ffffffffc0202d0a:	8efd                	and	a3,a3,a5
ffffffffc0202d0c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202d10:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202de4 <get_pte+0x192>
ffffffffc0202d14:	0000fa97          	auipc	s5,0xf
ffffffffc0202d18:	864a8a93          	addi	s5,s5,-1948 # ffffffffc0211578 <va_pa_offset>
ffffffffc0202d1c:	000ab403          	ld	s0,0(s5)
ffffffffc0202d20:	01595793          	srli	a5,s2,0x15
ffffffffc0202d24:	1ff7f793          	andi	a5,a5,511
ffffffffc0202d28:	96a2                	add	a3,a3,s0
ffffffffc0202d2a:	00379413          	slli	s0,a5,0x3
ffffffffc0202d2e:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202d30:	6014                	ld	a3,0(s0)
ffffffffc0202d32:	0016f793          	andi	a5,a3,1
ffffffffc0202d36:	ebad                	bnez	a5,ffffffffc0202da8 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202d38:	0a0a0463          	beqz	s4,ffffffffc0202de0 <get_pte+0x18e>
ffffffffc0202d3c:	4505                	li	a0,1
ffffffffc0202d3e:	e09ff0ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0202d42:	84aa                	mv	s1,a0
ffffffffc0202d44:	cd51                	beqz	a0,ffffffffc0202de0 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d46:	0000fb97          	auipc	s7,0xf
ffffffffc0202d4a:	822b8b93          	addi	s7,s7,-2014 # ffffffffc0211568 <pages>
ffffffffc0202d4e:	000bb503          	ld	a0,0(s7)
ffffffffc0202d52:	00003b17          	auipc	s6,0x3
ffffffffc0202d56:	60eb3b03          	ld	s6,1550(s6) # ffffffffc0206360 <error_string+0x38>
ffffffffc0202d5a:	00080a37          	lui	s4,0x80
ffffffffc0202d5e:	40a48533          	sub	a0,s1,a0
ffffffffc0202d62:	850d                	srai	a0,a0,0x3
ffffffffc0202d64:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202d68:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d6a:	0009b703          	ld	a4,0(s3)
ffffffffc0202d6e:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d70:	9552                	add	a0,a0,s4
ffffffffc0202d72:	00c51793          	slli	a5,a0,0xc
ffffffffc0202d76:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d78:	0532                	slli	a0,a0,0xc
ffffffffc0202d7a:	08e7fd63          	bgeu	a5,a4,ffffffffc0202e14 <get_pte+0x1c2>
ffffffffc0202d7e:	000ab783          	ld	a5,0(s5)
ffffffffc0202d82:	6605                	lui	a2,0x1
ffffffffc0202d84:	4581                	li	a1,0
ffffffffc0202d86:	953e                	add	a0,a0,a5
ffffffffc0202d88:	300010ef          	jal	ra,ffffffffc0204088 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d8c:	000bb683          	ld	a3,0(s7)
ffffffffc0202d90:	40d486b3          	sub	a3,s1,a3
ffffffffc0202d94:	868d                	srai	a3,a3,0x3
ffffffffc0202d96:	036686b3          	mul	a3,a3,s6
ffffffffc0202d9a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202d9c:	06aa                	slli	a3,a3,0xa
ffffffffc0202d9e:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202da2:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202da4:	0009b703          	ld	a4,0(s3)
ffffffffc0202da8:	068a                	slli	a3,a3,0x2
ffffffffc0202daa:	757d                	lui	a0,0xfffff
ffffffffc0202dac:	8ee9                	and	a3,a3,a0
ffffffffc0202dae:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202db2:	04e7f563          	bgeu	a5,a4,ffffffffc0202dfc <get_pte+0x1aa>
ffffffffc0202db6:	000ab503          	ld	a0,0(s5)
ffffffffc0202dba:	00c95913          	srli	s2,s2,0xc
ffffffffc0202dbe:	1ff97913          	andi	s2,s2,511
ffffffffc0202dc2:	96aa                	add	a3,a3,a0
ffffffffc0202dc4:	00391513          	slli	a0,s2,0x3
ffffffffc0202dc8:	9536                	add	a0,a0,a3
}
ffffffffc0202dca:	60a6                	ld	ra,72(sp)
ffffffffc0202dcc:	6406                	ld	s0,64(sp)
ffffffffc0202dce:	74e2                	ld	s1,56(sp)
ffffffffc0202dd0:	7942                	ld	s2,48(sp)
ffffffffc0202dd2:	79a2                	ld	s3,40(sp)
ffffffffc0202dd4:	7a02                	ld	s4,32(sp)
ffffffffc0202dd6:	6ae2                	ld	s5,24(sp)
ffffffffc0202dd8:	6b42                	ld	s6,16(sp)
ffffffffc0202dda:	6ba2                	ld	s7,8(sp)
ffffffffc0202ddc:	6161                	addi	sp,sp,80
ffffffffc0202dde:	8082                	ret
            return NULL;
ffffffffc0202de0:	4501                	li	a0,0
ffffffffc0202de2:	b7e5                	j	ffffffffc0202dca <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202de4:	00003617          	auipc	a2,0x3
ffffffffc0202de8:	ce460613          	addi	a2,a2,-796 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0202dec:	10200593          	li	a1,258
ffffffffc0202df0:	00003517          	auipc	a0,0x3
ffffffffc0202df4:	d0050513          	addi	a0,a0,-768 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0202df8:	b0afd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202dfc:	00003617          	auipc	a2,0x3
ffffffffc0202e00:	ccc60613          	addi	a2,a2,-820 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0202e04:	10f00593          	li	a1,271
ffffffffc0202e08:	00003517          	auipc	a0,0x3
ffffffffc0202e0c:	ce850513          	addi	a0,a0,-792 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0202e10:	af2fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202e14:	86aa                	mv	a3,a0
ffffffffc0202e16:	00003617          	auipc	a2,0x3
ffffffffc0202e1a:	cb260613          	addi	a2,a2,-846 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0202e1e:	10b00593          	li	a1,267
ffffffffc0202e22:	00003517          	auipc	a0,0x3
ffffffffc0202e26:	cce50513          	addi	a0,a0,-818 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0202e2a:	ad8fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202e2e:	86aa                	mv	a3,a0
ffffffffc0202e30:	00003617          	auipc	a2,0x3
ffffffffc0202e34:	c9860613          	addi	a2,a2,-872 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0202e38:	0ff00593          	li	a1,255
ffffffffc0202e3c:	00003517          	auipc	a0,0x3
ffffffffc0202e40:	cb450513          	addi	a0,a0,-844 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0202e44:	abefd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202e48 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202e48:	1141                	addi	sp,sp,-16
ffffffffc0202e4a:	e022                	sd	s0,0(sp)
ffffffffc0202e4c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e4e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202e50:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e52:	e01ff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202e56:	c011                	beqz	s0,ffffffffc0202e5a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202e58:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202e5a:	c511                	beqz	a0,ffffffffc0202e66 <get_page+0x1e>
ffffffffc0202e5c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202e5e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202e60:	0017f713          	andi	a4,a5,1
ffffffffc0202e64:	e709                	bnez	a4,ffffffffc0202e6e <get_page+0x26>
}
ffffffffc0202e66:	60a2                	ld	ra,8(sp)
ffffffffc0202e68:	6402                	ld	s0,0(sp)
ffffffffc0202e6a:	0141                	addi	sp,sp,16
ffffffffc0202e6c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e6e:	078a                	slli	a5,a5,0x2
ffffffffc0202e70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e72:	0000e717          	auipc	a4,0xe
ffffffffc0202e76:	6ee73703          	ld	a4,1774(a4) # ffffffffc0211560 <npage>
ffffffffc0202e7a:	02e7f263          	bgeu	a5,a4,ffffffffc0202e9e <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e7e:	fff80537          	lui	a0,0xfff80
ffffffffc0202e82:	97aa                	add	a5,a5,a0
ffffffffc0202e84:	60a2                	ld	ra,8(sp)
ffffffffc0202e86:	6402                	ld	s0,0(sp)
ffffffffc0202e88:	00379513          	slli	a0,a5,0x3
ffffffffc0202e8c:	97aa                	add	a5,a5,a0
ffffffffc0202e8e:	078e                	slli	a5,a5,0x3
ffffffffc0202e90:	0000e517          	auipc	a0,0xe
ffffffffc0202e94:	6d853503          	ld	a0,1752(a0) # ffffffffc0211568 <pages>
ffffffffc0202e98:	953e                	add	a0,a0,a5
ffffffffc0202e9a:	0141                	addi	sp,sp,16
ffffffffc0202e9c:	8082                	ret
ffffffffc0202e9e:	c71ff0ef          	jal	ra,ffffffffc0202b0e <pa2page.part.0>

ffffffffc0202ea2 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202ea2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ea4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202ea6:	ec06                	sd	ra,24(sp)
ffffffffc0202ea8:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202eaa:	da9ff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
    if (ptep != NULL) {
ffffffffc0202eae:	c511                	beqz	a0,ffffffffc0202eba <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202eb0:	611c                	ld	a5,0(a0)
ffffffffc0202eb2:	842a                	mv	s0,a0
ffffffffc0202eb4:	0017f713          	andi	a4,a5,1
ffffffffc0202eb8:	e709                	bnez	a4,ffffffffc0202ec2 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202eba:	60e2                	ld	ra,24(sp)
ffffffffc0202ebc:	6442                	ld	s0,16(sp)
ffffffffc0202ebe:	6105                	addi	sp,sp,32
ffffffffc0202ec0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ec2:	078a                	slli	a5,a5,0x2
ffffffffc0202ec4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ec6:	0000e717          	auipc	a4,0xe
ffffffffc0202eca:	69a73703          	ld	a4,1690(a4) # ffffffffc0211560 <npage>
ffffffffc0202ece:	06e7f563          	bgeu	a5,a4,ffffffffc0202f38 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ed2:	fff80737          	lui	a4,0xfff80
ffffffffc0202ed6:	97ba                	add	a5,a5,a4
ffffffffc0202ed8:	00379513          	slli	a0,a5,0x3
ffffffffc0202edc:	97aa                	add	a5,a5,a0
ffffffffc0202ede:	078e                	slli	a5,a5,0x3
ffffffffc0202ee0:	0000e517          	auipc	a0,0xe
ffffffffc0202ee4:	68853503          	ld	a0,1672(a0) # ffffffffc0211568 <pages>
ffffffffc0202ee8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202eea:	411c                	lw	a5,0(a0)
ffffffffc0202eec:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202ef0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202ef2:	cb09                	beqz	a4,ffffffffc0202f04 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202ef4:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202ef8:	12000073          	sfence.vma
}
ffffffffc0202efc:	60e2                	ld	ra,24(sp)
ffffffffc0202efe:	6442                	ld	s0,16(sp)
ffffffffc0202f00:	6105                	addi	sp,sp,32
ffffffffc0202f02:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f04:	100027f3          	csrr	a5,sstatus
ffffffffc0202f08:	8b89                	andi	a5,a5,2
ffffffffc0202f0a:	eb89                	bnez	a5,ffffffffc0202f1c <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202f0c:	0000e797          	auipc	a5,0xe
ffffffffc0202f10:	6647b783          	ld	a5,1636(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0202f14:	739c                	ld	a5,32(a5)
ffffffffc0202f16:	4585                	li	a1,1
ffffffffc0202f18:	9782                	jalr	a5
    if (flag) {
ffffffffc0202f1a:	bfe9                	j	ffffffffc0202ef4 <page_remove+0x52>
        intr_disable();
ffffffffc0202f1c:	e42a                	sd	a0,8(sp)
ffffffffc0202f1e:	dd0fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202f22:	0000e797          	auipc	a5,0xe
ffffffffc0202f26:	64e7b783          	ld	a5,1614(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0202f2a:	739c                	ld	a5,32(a5)
ffffffffc0202f2c:	6522                	ld	a0,8(sp)
ffffffffc0202f2e:	4585                	li	a1,1
ffffffffc0202f30:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f32:	db6fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202f36:	bf7d                	j	ffffffffc0202ef4 <page_remove+0x52>
ffffffffc0202f38:	bd7ff0ef          	jal	ra,ffffffffc0202b0e <pa2page.part.0>

ffffffffc0202f3c <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f3c:	7179                	addi	sp,sp,-48
ffffffffc0202f3e:	87b2                	mv	a5,a2
ffffffffc0202f40:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f42:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f44:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f46:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f48:	ec26                	sd	s1,24(sp)
ffffffffc0202f4a:	f406                	sd	ra,40(sp)
ffffffffc0202f4c:	e84a                	sd	s2,16(sp)
ffffffffc0202f4e:	e44e                	sd	s3,8(sp)
ffffffffc0202f50:	e052                	sd	s4,0(sp)
ffffffffc0202f52:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f54:	cffff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
    if (ptep == NULL) {
ffffffffc0202f58:	cd71                	beqz	a0,ffffffffc0203034 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202f5a:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202f5c:	611c                	ld	a5,0(a0)
ffffffffc0202f5e:	89aa                	mv	s3,a0
ffffffffc0202f60:	0016871b          	addiw	a4,a3,1
ffffffffc0202f64:	c018                	sw	a4,0(s0)
ffffffffc0202f66:	0017f713          	andi	a4,a5,1
ffffffffc0202f6a:	e331                	bnez	a4,ffffffffc0202fae <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202f6c:	0000e797          	auipc	a5,0xe
ffffffffc0202f70:	5fc7b783          	ld	a5,1532(a5) # ffffffffc0211568 <pages>
ffffffffc0202f74:	40f407b3          	sub	a5,s0,a5
ffffffffc0202f78:	878d                	srai	a5,a5,0x3
ffffffffc0202f7a:	00003417          	auipc	s0,0x3
ffffffffc0202f7e:	3e643403          	ld	s0,998(s0) # ffffffffc0206360 <error_string+0x38>
ffffffffc0202f82:	028787b3          	mul	a5,a5,s0
ffffffffc0202f86:	00080437          	lui	s0,0x80
ffffffffc0202f8a:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202f8c:	07aa                	slli	a5,a5,0xa
ffffffffc0202f8e:	8cdd                	or	s1,s1,a5
ffffffffc0202f90:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202f94:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f98:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202f9c:	4501                	li	a0,0
}
ffffffffc0202f9e:	70a2                	ld	ra,40(sp)
ffffffffc0202fa0:	7402                	ld	s0,32(sp)
ffffffffc0202fa2:	64e2                	ld	s1,24(sp)
ffffffffc0202fa4:	6942                	ld	s2,16(sp)
ffffffffc0202fa6:	69a2                	ld	s3,8(sp)
ffffffffc0202fa8:	6a02                	ld	s4,0(sp)
ffffffffc0202faa:	6145                	addi	sp,sp,48
ffffffffc0202fac:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202fae:	00279713          	slli	a4,a5,0x2
ffffffffc0202fb2:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fb4:	0000e797          	auipc	a5,0xe
ffffffffc0202fb8:	5ac7b783          	ld	a5,1452(a5) # ffffffffc0211560 <npage>
ffffffffc0202fbc:	06f77e63          	bgeu	a4,a5,ffffffffc0203038 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fc0:	fff807b7          	lui	a5,0xfff80
ffffffffc0202fc4:	973e                	add	a4,a4,a5
ffffffffc0202fc6:	0000ea17          	auipc	s4,0xe
ffffffffc0202fca:	5a2a0a13          	addi	s4,s4,1442 # ffffffffc0211568 <pages>
ffffffffc0202fce:	000a3783          	ld	a5,0(s4)
ffffffffc0202fd2:	00371913          	slli	s2,a4,0x3
ffffffffc0202fd6:	993a                	add	s2,s2,a4
ffffffffc0202fd8:	090e                	slli	s2,s2,0x3
ffffffffc0202fda:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202fdc:	03240063          	beq	s0,s2,ffffffffc0202ffc <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202fe0:	00092783          	lw	a5,0(s2)
ffffffffc0202fe4:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202fe8:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202fec:	cb11                	beqz	a4,ffffffffc0203000 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202fee:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202ff2:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ff6:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202ffa:	bfad                	j	ffffffffc0202f74 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202ffc:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202ffe:	bf9d                	j	ffffffffc0202f74 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203000:	100027f3          	csrr	a5,sstatus
ffffffffc0203004:	8b89                	andi	a5,a5,2
ffffffffc0203006:	eb91                	bnez	a5,ffffffffc020301a <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203008:	0000e797          	auipc	a5,0xe
ffffffffc020300c:	5687b783          	ld	a5,1384(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0203010:	739c                	ld	a5,32(a5)
ffffffffc0203012:	4585                	li	a1,1
ffffffffc0203014:	854a                	mv	a0,s2
ffffffffc0203016:	9782                	jalr	a5
    if (flag) {
ffffffffc0203018:	bfd9                	j	ffffffffc0202fee <page_insert+0xb2>
        intr_disable();
ffffffffc020301a:	cd4fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020301e:	0000e797          	auipc	a5,0xe
ffffffffc0203022:	5527b783          	ld	a5,1362(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0203026:	739c                	ld	a5,32(a5)
ffffffffc0203028:	4585                	li	a1,1
ffffffffc020302a:	854a                	mv	a0,s2
ffffffffc020302c:	9782                	jalr	a5
        intr_enable();
ffffffffc020302e:	cbafd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203032:	bf75                	j	ffffffffc0202fee <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0203034:	5571                	li	a0,-4
ffffffffc0203036:	b7a5                	j	ffffffffc0202f9e <page_insert+0x62>
ffffffffc0203038:	ad7ff0ef          	jal	ra,ffffffffc0202b0e <pa2page.part.0>

ffffffffc020303c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020303c:	00003797          	auipc	a5,0x3
ffffffffc0203040:	a3c78793          	addi	a5,a5,-1476 # ffffffffc0205a78 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203044:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203046:	7159                	addi	sp,sp,-112
ffffffffc0203048:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020304a:	00003517          	auipc	a0,0x3
ffffffffc020304e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0205b00 <default_pmm_manager+0x88>
    pmm_manager = &default_pmm_manager;
ffffffffc0203052:	0000eb97          	auipc	s7,0xe
ffffffffc0203056:	51eb8b93          	addi	s7,s7,1310 # ffffffffc0211570 <pmm_manager>
void pmm_init(void) {
ffffffffc020305a:	f486                	sd	ra,104(sp)
ffffffffc020305c:	f0a2                	sd	s0,96(sp)
ffffffffc020305e:	eca6                	sd	s1,88(sp)
ffffffffc0203060:	e8ca                	sd	s2,80(sp)
ffffffffc0203062:	e4ce                	sd	s3,72(sp)
ffffffffc0203064:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203066:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc020306a:	e0d2                	sd	s4,64(sp)
ffffffffc020306c:	fc56                	sd	s5,56(sp)
ffffffffc020306e:	f062                	sd	s8,32(sp)
ffffffffc0203070:	ec66                	sd	s9,24(sp)
ffffffffc0203072:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203074:	846fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0203078:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020307c:	4445                	li	s0,17
ffffffffc020307e:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0203082:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203084:	0000e997          	auipc	s3,0xe
ffffffffc0203088:	4f498993          	addi	s3,s3,1268 # ffffffffc0211578 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020308c:	0000e497          	auipc	s1,0xe
ffffffffc0203090:	4d448493          	addi	s1,s1,1236 # ffffffffc0211560 <npage>
    pmm_manager->init();
ffffffffc0203094:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203096:	57f5                	li	a5,-3
ffffffffc0203098:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020309a:	07e006b7          	lui	a3,0x7e00
ffffffffc020309e:	01b41613          	slli	a2,s0,0x1b
ffffffffc02030a2:	01591593          	slli	a1,s2,0x15
ffffffffc02030a6:	00003517          	auipc	a0,0x3
ffffffffc02030aa:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205b18 <default_pmm_manager+0xa0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02030ae:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc02030b2:	808fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc02030b6:	00003517          	auipc	a0,0x3
ffffffffc02030ba:	a9250513          	addi	a0,a0,-1390 # ffffffffc0205b48 <default_pmm_manager+0xd0>
ffffffffc02030be:	ffdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02030c2:	01b41693          	slli	a3,s0,0x1b
ffffffffc02030c6:	16fd                	addi	a3,a3,-1
ffffffffc02030c8:	07e005b7          	lui	a1,0x7e00
ffffffffc02030cc:	01591613          	slli	a2,s2,0x15
ffffffffc02030d0:	00003517          	auipc	a0,0x3
ffffffffc02030d4:	a9050513          	addi	a0,a0,-1392 # ffffffffc0205b60 <default_pmm_manager+0xe8>
ffffffffc02030d8:	fe3fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02030dc:	777d                	lui	a4,0xfffff
ffffffffc02030de:	0000f797          	auipc	a5,0xf
ffffffffc02030e2:	4a178793          	addi	a5,a5,1185 # ffffffffc021257f <end+0xfff>
ffffffffc02030e6:	8ff9                	and	a5,a5,a4
ffffffffc02030e8:	0000eb17          	auipc	s6,0xe
ffffffffc02030ec:	480b0b13          	addi	s6,s6,1152 # ffffffffc0211568 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02030f0:	00088737          	lui	a4,0x88
ffffffffc02030f4:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02030f6:	00fb3023          	sd	a5,0(s6)
ffffffffc02030fa:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02030fc:	4701                	li	a4,0
ffffffffc02030fe:	4505                	li	a0,1
ffffffffc0203100:	fff805b7          	lui	a1,0xfff80
ffffffffc0203104:	a019                	j	ffffffffc020310a <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0203106:	000b3783          	ld	a5,0(s6)
ffffffffc020310a:	97b6                	add	a5,a5,a3
ffffffffc020310c:	07a1                	addi	a5,a5,8
ffffffffc020310e:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203112:	609c                	ld	a5,0(s1)
ffffffffc0203114:	0705                	addi	a4,a4,1
ffffffffc0203116:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc020311a:	00b78633          	add	a2,a5,a1
ffffffffc020311e:	fec764e3          	bltu	a4,a2,ffffffffc0203106 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203122:	000b3503          	ld	a0,0(s6)
ffffffffc0203126:	00379693          	slli	a3,a5,0x3
ffffffffc020312a:	96be                	add	a3,a3,a5
ffffffffc020312c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0203130:	972a                	add	a4,a4,a0
ffffffffc0203132:	068e                	slli	a3,a3,0x3
ffffffffc0203134:	96ba                	add	a3,a3,a4
ffffffffc0203136:	c0200737          	lui	a4,0xc0200
ffffffffc020313a:	64e6e463          	bltu	a3,a4,ffffffffc0203782 <pmm_init+0x746>
ffffffffc020313e:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0203142:	4645                	li	a2,17
ffffffffc0203144:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203146:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0203148:	4ec6e263          	bltu	a3,a2,ffffffffc020362c <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020314c:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203150:	0000e917          	auipc	s2,0xe
ffffffffc0203154:	40890913          	addi	s2,s2,1032 # ffffffffc0211558 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203158:	7b9c                	ld	a5,48(a5)
ffffffffc020315a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020315c:	00003517          	auipc	a0,0x3
ffffffffc0203160:	a5450513          	addi	a0,a0,-1452 # ffffffffc0205bb0 <default_pmm_manager+0x138>
ffffffffc0203164:	f57fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203168:	00006697          	auipc	a3,0x6
ffffffffc020316c:	e9868693          	addi	a3,a3,-360 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0203170:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203174:	c02007b7          	lui	a5,0xc0200
ffffffffc0203178:	62f6e163          	bltu	a3,a5,ffffffffc020379a <pmm_init+0x75e>
ffffffffc020317c:	0009b783          	ld	a5,0(s3)
ffffffffc0203180:	8e9d                	sub	a3,a3,a5
ffffffffc0203182:	0000e797          	auipc	a5,0xe
ffffffffc0203186:	3cd7b723          	sd	a3,974(a5) # ffffffffc0211550 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020318a:	100027f3          	csrr	a5,sstatus
ffffffffc020318e:	8b89                	andi	a5,a5,2
ffffffffc0203190:	4c079763          	bnez	a5,ffffffffc020365e <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203194:	000bb783          	ld	a5,0(s7)
ffffffffc0203198:	779c                	ld	a5,40(a5)
ffffffffc020319a:	9782                	jalr	a5
ffffffffc020319c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020319e:	6098                	ld	a4,0(s1)
ffffffffc02031a0:	c80007b7          	lui	a5,0xc8000
ffffffffc02031a4:	83b1                	srli	a5,a5,0xc
ffffffffc02031a6:	62e7e663          	bltu	a5,a4,ffffffffc02037d2 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02031aa:	00093503          	ld	a0,0(s2)
ffffffffc02031ae:	60050263          	beqz	a0,ffffffffc02037b2 <pmm_init+0x776>
ffffffffc02031b2:	03451793          	slli	a5,a0,0x34
ffffffffc02031b6:	5e079e63          	bnez	a5,ffffffffc02037b2 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02031ba:	4601                	li	a2,0
ffffffffc02031bc:	4581                	li	a1,0
ffffffffc02031be:	c8bff0ef          	jal	ra,ffffffffc0202e48 <get_page>
ffffffffc02031c2:	66051a63          	bnez	a0,ffffffffc0203836 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02031c6:	4505                	li	a0,1
ffffffffc02031c8:	97fff0ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc02031cc:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02031ce:	00093503          	ld	a0,0(s2)
ffffffffc02031d2:	4681                	li	a3,0
ffffffffc02031d4:	4601                	li	a2,0
ffffffffc02031d6:	85d2                	mv	a1,s4
ffffffffc02031d8:	d65ff0ef          	jal	ra,ffffffffc0202f3c <page_insert>
ffffffffc02031dc:	62051d63          	bnez	a0,ffffffffc0203816 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02031e0:	00093503          	ld	a0,0(s2)
ffffffffc02031e4:	4601                	li	a2,0
ffffffffc02031e6:	4581                	li	a1,0
ffffffffc02031e8:	a6bff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
ffffffffc02031ec:	60050563          	beqz	a0,ffffffffc02037f6 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc02031f0:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02031f2:	0017f713          	andi	a4,a5,1
ffffffffc02031f6:	5e070e63          	beqz	a4,ffffffffc02037f2 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc02031fa:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031fc:	078a                	slli	a5,a5,0x2
ffffffffc02031fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203200:	56c7ff63          	bgeu	a5,a2,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203204:	fff80737          	lui	a4,0xfff80
ffffffffc0203208:	97ba                	add	a5,a5,a4
ffffffffc020320a:	000b3683          	ld	a3,0(s6)
ffffffffc020320e:	00379713          	slli	a4,a5,0x3
ffffffffc0203212:	97ba                	add	a5,a5,a4
ffffffffc0203214:	078e                	slli	a5,a5,0x3
ffffffffc0203216:	97b6                	add	a5,a5,a3
ffffffffc0203218:	14fa18e3          	bne	s4,a5,ffffffffc0203b68 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc020321c:	000a2703          	lw	a4,0(s4)
ffffffffc0203220:	4785                	li	a5,1
ffffffffc0203222:	16f71fe3          	bne	a4,a5,ffffffffc0203ba0 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203226:	00093503          	ld	a0,0(s2)
ffffffffc020322a:	77fd                	lui	a5,0xfffff
ffffffffc020322c:	6114                	ld	a3,0(a0)
ffffffffc020322e:	068a                	slli	a3,a3,0x2
ffffffffc0203230:	8efd                	and	a3,a3,a5
ffffffffc0203232:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203236:	14c779e3          	bgeu	a4,a2,ffffffffc0203b88 <pmm_init+0xb4c>
ffffffffc020323a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020323e:	96e2                	add	a3,a3,s8
ffffffffc0203240:	0006ba83          	ld	s5,0(a3)
ffffffffc0203244:	0a8a                	slli	s5,s5,0x2
ffffffffc0203246:	00fafab3          	and	s5,s5,a5
ffffffffc020324a:	00cad793          	srli	a5,s5,0xc
ffffffffc020324e:	66c7f463          	bgeu	a5,a2,ffffffffc02038b6 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203252:	4601                	li	a2,0
ffffffffc0203254:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203256:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203258:	9fbff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020325c:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020325e:	63551c63          	bne	a0,s5,ffffffffc0203896 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0203262:	4505                	li	a0,1
ffffffffc0203264:	8e3ff0ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0203268:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020326a:	00093503          	ld	a0,0(s2)
ffffffffc020326e:	46d1                	li	a3,20
ffffffffc0203270:	6605                	lui	a2,0x1
ffffffffc0203272:	85d6                	mv	a1,s5
ffffffffc0203274:	cc9ff0ef          	jal	ra,ffffffffc0202f3c <page_insert>
ffffffffc0203278:	5c051f63          	bnez	a0,ffffffffc0203856 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020327c:	00093503          	ld	a0,0(s2)
ffffffffc0203280:	4601                	li	a2,0
ffffffffc0203282:	6585                	lui	a1,0x1
ffffffffc0203284:	9cfff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
ffffffffc0203288:	12050ce3          	beqz	a0,ffffffffc0203bc0 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc020328c:	611c                	ld	a5,0(a0)
ffffffffc020328e:	0107f713          	andi	a4,a5,16
ffffffffc0203292:	72070f63          	beqz	a4,ffffffffc02039d0 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0203296:	8b91                	andi	a5,a5,4
ffffffffc0203298:	6e078c63          	beqz	a5,ffffffffc0203990 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020329c:	00093503          	ld	a0,0(s2)
ffffffffc02032a0:	611c                	ld	a5,0(a0)
ffffffffc02032a2:	8bc1                	andi	a5,a5,16
ffffffffc02032a4:	6c078663          	beqz	a5,ffffffffc0203970 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc02032a8:	000aa703          	lw	a4,0(s5)
ffffffffc02032ac:	4785                	li	a5,1
ffffffffc02032ae:	5cf71463          	bne	a4,a5,ffffffffc0203876 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02032b2:	4681                	li	a3,0
ffffffffc02032b4:	6605                	lui	a2,0x1
ffffffffc02032b6:	85d2                	mv	a1,s4
ffffffffc02032b8:	c85ff0ef          	jal	ra,ffffffffc0202f3c <page_insert>
ffffffffc02032bc:	66051a63          	bnez	a0,ffffffffc0203930 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc02032c0:	000a2703          	lw	a4,0(s4)
ffffffffc02032c4:	4789                	li	a5,2
ffffffffc02032c6:	64f71563          	bne	a4,a5,ffffffffc0203910 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc02032ca:	000aa783          	lw	a5,0(s5)
ffffffffc02032ce:	62079163          	bnez	a5,ffffffffc02038f0 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02032d2:	00093503          	ld	a0,0(s2)
ffffffffc02032d6:	4601                	li	a2,0
ffffffffc02032d8:	6585                	lui	a1,0x1
ffffffffc02032da:	979ff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
ffffffffc02032de:	5e050963          	beqz	a0,ffffffffc02038d0 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc02032e2:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02032e4:	00177793          	andi	a5,a4,1
ffffffffc02032e8:	50078563          	beqz	a5,ffffffffc02037f2 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc02032ec:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02032ee:	00271793          	slli	a5,a4,0x2
ffffffffc02032f2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032f4:	48d7f563          	bgeu	a5,a3,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02032f8:	fff806b7          	lui	a3,0xfff80
ffffffffc02032fc:	97b6                	add	a5,a5,a3
ffffffffc02032fe:	000b3603          	ld	a2,0(s6)
ffffffffc0203302:	00379693          	slli	a3,a5,0x3
ffffffffc0203306:	97b6                	add	a5,a5,a3
ffffffffc0203308:	078e                	slli	a5,a5,0x3
ffffffffc020330a:	97b2                	add	a5,a5,a2
ffffffffc020330c:	72fa1263          	bne	s4,a5,ffffffffc0203a30 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203310:	8b41                	andi	a4,a4,16
ffffffffc0203312:	6e071f63          	bnez	a4,ffffffffc0203a10 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203316:	00093503          	ld	a0,0(s2)
ffffffffc020331a:	4581                	li	a1,0
ffffffffc020331c:	b87ff0ef          	jal	ra,ffffffffc0202ea2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203320:	000a2703          	lw	a4,0(s4)
ffffffffc0203324:	4785                	li	a5,1
ffffffffc0203326:	6cf71563          	bne	a4,a5,ffffffffc02039f0 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc020332a:	000aa783          	lw	a5,0(s5)
ffffffffc020332e:	78079d63          	bnez	a5,ffffffffc0203ac8 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203332:	00093503          	ld	a0,0(s2)
ffffffffc0203336:	6585                	lui	a1,0x1
ffffffffc0203338:	b6bff0ef          	jal	ra,ffffffffc0202ea2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020333c:	000a2783          	lw	a5,0(s4)
ffffffffc0203340:	76079463          	bnez	a5,ffffffffc0203aa8 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0203344:	000aa783          	lw	a5,0(s5)
ffffffffc0203348:	74079063          	bnez	a5,ffffffffc0203a88 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020334c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203350:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203352:	000a3783          	ld	a5,0(s4)
ffffffffc0203356:	078a                	slli	a5,a5,0x2
ffffffffc0203358:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020335a:	42c7f263          	bgeu	a5,a2,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020335e:	fff80737          	lui	a4,0xfff80
ffffffffc0203362:	973e                	add	a4,a4,a5
ffffffffc0203364:	00371793          	slli	a5,a4,0x3
ffffffffc0203368:	000b3503          	ld	a0,0(s6)
ffffffffc020336c:	97ba                	add	a5,a5,a4
ffffffffc020336e:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0203370:	00f50733          	add	a4,a0,a5
ffffffffc0203374:	4314                	lw	a3,0(a4)
ffffffffc0203376:	4705                	li	a4,1
ffffffffc0203378:	6ee69863          	bne	a3,a4,ffffffffc0203a68 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020337c:	4037d693          	srai	a3,a5,0x3
ffffffffc0203380:	00003c97          	auipc	s9,0x3
ffffffffc0203384:	fe0cbc83          	ld	s9,-32(s9) # ffffffffc0206360 <error_string+0x38>
ffffffffc0203388:	039686b3          	mul	a3,a3,s9
ffffffffc020338c:	000805b7          	lui	a1,0x80
ffffffffc0203390:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203392:	00c69713          	slli	a4,a3,0xc
ffffffffc0203396:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203398:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020339a:	6ac77b63          	bgeu	a4,a2,ffffffffc0203a50 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020339e:	0009b703          	ld	a4,0(s3)
ffffffffc02033a2:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02033a4:	629c                	ld	a5,0(a3)
ffffffffc02033a6:	078a                	slli	a5,a5,0x2
ffffffffc02033a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033aa:	3cc7fa63          	bgeu	a5,a2,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033ae:	8f8d                	sub	a5,a5,a1
ffffffffc02033b0:	00379713          	slli	a4,a5,0x3
ffffffffc02033b4:	97ba                	add	a5,a5,a4
ffffffffc02033b6:	078e                	slli	a5,a5,0x3
ffffffffc02033b8:	953e                	add	a0,a0,a5
ffffffffc02033ba:	100027f3          	csrr	a5,sstatus
ffffffffc02033be:	8b89                	andi	a5,a5,2
ffffffffc02033c0:	2e079963          	bnez	a5,ffffffffc02036b2 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc02033c4:	000bb783          	ld	a5,0(s7)
ffffffffc02033c8:	4585                	li	a1,1
ffffffffc02033ca:	739c                	ld	a5,32(a5)
ffffffffc02033cc:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02033ce:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02033d2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033d4:	078a                	slli	a5,a5,0x2
ffffffffc02033d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033d8:	3ae7f363          	bgeu	a5,a4,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033dc:	fff80737          	lui	a4,0xfff80
ffffffffc02033e0:	97ba                	add	a5,a5,a4
ffffffffc02033e2:	000b3503          	ld	a0,0(s6)
ffffffffc02033e6:	00379713          	slli	a4,a5,0x3
ffffffffc02033ea:	97ba                	add	a5,a5,a4
ffffffffc02033ec:	078e                	slli	a5,a5,0x3
ffffffffc02033ee:	953e                	add	a0,a0,a5
ffffffffc02033f0:	100027f3          	csrr	a5,sstatus
ffffffffc02033f4:	8b89                	andi	a5,a5,2
ffffffffc02033f6:	2a079263          	bnez	a5,ffffffffc020369a <pmm_init+0x65e>
ffffffffc02033fa:	000bb783          	ld	a5,0(s7)
ffffffffc02033fe:	4585                	li	a1,1
ffffffffc0203400:	739c                	ld	a5,32(a5)
ffffffffc0203402:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203404:	00093783          	ld	a5,0(s2)
ffffffffc0203408:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda80>
ffffffffc020340c:	100027f3          	csrr	a5,sstatus
ffffffffc0203410:	8b89                	andi	a5,a5,2
ffffffffc0203412:	26079a63          	bnez	a5,ffffffffc0203686 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203416:	000bb783          	ld	a5,0(s7)
ffffffffc020341a:	779c                	ld	a5,40(a5)
ffffffffc020341c:	9782                	jalr	a5
ffffffffc020341e:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0203420:	73441463          	bne	s0,s4,ffffffffc0203b48 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203424:	00003517          	auipc	a0,0x3
ffffffffc0203428:	a7450513          	addi	a0,a0,-1420 # ffffffffc0205e98 <default_pmm_manager+0x420>
ffffffffc020342c:	c8ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203430:	100027f3          	csrr	a5,sstatus
ffffffffc0203434:	8b89                	andi	a5,a5,2
ffffffffc0203436:	22079e63          	bnez	a5,ffffffffc0203672 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020343a:	000bb783          	ld	a5,0(s7)
ffffffffc020343e:	779c                	ld	a5,40(a5)
ffffffffc0203440:	9782                	jalr	a5
ffffffffc0203442:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203444:	6098                	ld	a4,0(s1)
ffffffffc0203446:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020344a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020344c:	00c71793          	slli	a5,a4,0xc
ffffffffc0203450:	6a05                	lui	s4,0x1
ffffffffc0203452:	02f47c63          	bgeu	s0,a5,ffffffffc020348a <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203456:	00c45793          	srli	a5,s0,0xc
ffffffffc020345a:	00093503          	ld	a0,0(s2)
ffffffffc020345e:	30e7f363          	bgeu	a5,a4,ffffffffc0203764 <pmm_init+0x728>
ffffffffc0203462:	0009b583          	ld	a1,0(s3)
ffffffffc0203466:	4601                	li	a2,0
ffffffffc0203468:	95a2                	add	a1,a1,s0
ffffffffc020346a:	fe8ff0ef          	jal	ra,ffffffffc0202c52 <get_pte>
ffffffffc020346e:	2c050b63          	beqz	a0,ffffffffc0203744 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203472:	611c                	ld	a5,0(a0)
ffffffffc0203474:	078a                	slli	a5,a5,0x2
ffffffffc0203476:	0157f7b3          	and	a5,a5,s5
ffffffffc020347a:	2a879563          	bne	a5,s0,ffffffffc0203724 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020347e:	6098                	ld	a4,0(s1)
ffffffffc0203480:	9452                	add	s0,s0,s4
ffffffffc0203482:	00c71793          	slli	a5,a4,0xc
ffffffffc0203486:	fcf468e3          	bltu	s0,a5,ffffffffc0203456 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020348a:	00093783          	ld	a5,0(s2)
ffffffffc020348e:	639c                	ld	a5,0(a5)
ffffffffc0203490:	68079c63          	bnez	a5,ffffffffc0203b28 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0203494:	4505                	li	a0,1
ffffffffc0203496:	eb0ff0ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc020349a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020349c:	00093503          	ld	a0,0(s2)
ffffffffc02034a0:	4699                	li	a3,6
ffffffffc02034a2:	10000613          	li	a2,256
ffffffffc02034a6:	85d6                	mv	a1,s5
ffffffffc02034a8:	a95ff0ef          	jal	ra,ffffffffc0202f3c <page_insert>
ffffffffc02034ac:	64051e63          	bnez	a0,ffffffffc0203b08 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc02034b0:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda80>
ffffffffc02034b4:	4785                	li	a5,1
ffffffffc02034b6:	62f71963          	bne	a4,a5,ffffffffc0203ae8 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02034ba:	00093503          	ld	a0,0(s2)
ffffffffc02034be:	6405                	lui	s0,0x1
ffffffffc02034c0:	4699                	li	a3,6
ffffffffc02034c2:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02034c6:	85d6                	mv	a1,s5
ffffffffc02034c8:	a75ff0ef          	jal	ra,ffffffffc0202f3c <page_insert>
ffffffffc02034cc:	48051263          	bnez	a0,ffffffffc0203950 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc02034d0:	000aa703          	lw	a4,0(s5)
ffffffffc02034d4:	4789                	li	a5,2
ffffffffc02034d6:	74f71563          	bne	a4,a5,ffffffffc0203c20 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02034da:	00003597          	auipc	a1,0x3
ffffffffc02034de:	af658593          	addi	a1,a1,-1290 # ffffffffc0205fd0 <default_pmm_manager+0x558>
ffffffffc02034e2:	10000513          	li	a0,256
ffffffffc02034e6:	35d000ef          	jal	ra,ffffffffc0204042 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02034ea:	10040593          	addi	a1,s0,256
ffffffffc02034ee:	10000513          	li	a0,256
ffffffffc02034f2:	363000ef          	jal	ra,ffffffffc0204054 <strcmp>
ffffffffc02034f6:	70051563          	bnez	a0,ffffffffc0203c00 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02034fa:	000b3683          	ld	a3,0(s6)
ffffffffc02034fe:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203502:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203504:	40da86b3          	sub	a3,s5,a3
ffffffffc0203508:	868d                	srai	a3,a3,0x3
ffffffffc020350a:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020350e:	609c                	ld	a5,0(s1)
ffffffffc0203510:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203512:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203514:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203518:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020351a:	52f77b63          	bgeu	a4,a5,ffffffffc0203a50 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020351e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203522:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203526:	96be                	add	a3,a3,a5
ffffffffc0203528:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb80>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020352c:	2e1000ef          	jal	ra,ffffffffc020400c <strlen>
ffffffffc0203530:	6a051863          	bnez	a0,ffffffffc0203be0 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203534:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203538:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020353a:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020353e:	078a                	slli	a5,a5,0x2
ffffffffc0203540:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203542:	22e7fe63          	bgeu	a5,a4,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203546:	41a787b3          	sub	a5,a5,s10
ffffffffc020354a:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020354e:	96be                	add	a3,a3,a5
ffffffffc0203550:	03968cb3          	mul	s9,a3,s9
ffffffffc0203554:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203558:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020355a:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020355c:	4ee47a63          	bgeu	s0,a4,ffffffffc0203a50 <pmm_init+0xa14>
ffffffffc0203560:	0009b403          	ld	s0,0(s3)
ffffffffc0203564:	9436                	add	s0,s0,a3
ffffffffc0203566:	100027f3          	csrr	a5,sstatus
ffffffffc020356a:	8b89                	andi	a5,a5,2
ffffffffc020356c:	1a079163          	bnez	a5,ffffffffc020370e <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203570:	000bb783          	ld	a5,0(s7)
ffffffffc0203574:	4585                	li	a1,1
ffffffffc0203576:	8556                	mv	a0,s5
ffffffffc0203578:	739c                	ld	a5,32(a5)
ffffffffc020357a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020357c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020357e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203580:	078a                	slli	a5,a5,0x2
ffffffffc0203582:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203584:	1ee7fd63          	bgeu	a5,a4,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203588:	fff80737          	lui	a4,0xfff80
ffffffffc020358c:	97ba                	add	a5,a5,a4
ffffffffc020358e:	000b3503          	ld	a0,0(s6)
ffffffffc0203592:	00379713          	slli	a4,a5,0x3
ffffffffc0203596:	97ba                	add	a5,a5,a4
ffffffffc0203598:	078e                	slli	a5,a5,0x3
ffffffffc020359a:	953e                	add	a0,a0,a5
ffffffffc020359c:	100027f3          	csrr	a5,sstatus
ffffffffc02035a0:	8b89                	andi	a5,a5,2
ffffffffc02035a2:	14079a63          	bnez	a5,ffffffffc02036f6 <pmm_init+0x6ba>
ffffffffc02035a6:	000bb783          	ld	a5,0(s7)
ffffffffc02035aa:	4585                	li	a1,1
ffffffffc02035ac:	739c                	ld	a5,32(a5)
ffffffffc02035ae:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02035b4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b6:	078a                	slli	a5,a5,0x2
ffffffffc02035b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02035ba:	1ce7f263          	bgeu	a5,a4,ffffffffc020377e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02035be:	fff80737          	lui	a4,0xfff80
ffffffffc02035c2:	97ba                	add	a5,a5,a4
ffffffffc02035c4:	000b3503          	ld	a0,0(s6)
ffffffffc02035c8:	00379713          	slli	a4,a5,0x3
ffffffffc02035cc:	97ba                	add	a5,a5,a4
ffffffffc02035ce:	078e                	slli	a5,a5,0x3
ffffffffc02035d0:	953e                	add	a0,a0,a5
ffffffffc02035d2:	100027f3          	csrr	a5,sstatus
ffffffffc02035d6:	8b89                	andi	a5,a5,2
ffffffffc02035d8:	10079363          	bnez	a5,ffffffffc02036de <pmm_init+0x6a2>
ffffffffc02035dc:	000bb783          	ld	a5,0(s7)
ffffffffc02035e0:	4585                	li	a1,1
ffffffffc02035e2:	739c                	ld	a5,32(a5)
ffffffffc02035e4:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02035e6:	00093783          	ld	a5,0(s2)
ffffffffc02035ea:	0007b023          	sd	zero,0(a5)
ffffffffc02035ee:	100027f3          	csrr	a5,sstatus
ffffffffc02035f2:	8b89                	andi	a5,a5,2
ffffffffc02035f4:	0c079b63          	bnez	a5,ffffffffc02036ca <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02035f8:	000bb783          	ld	a5,0(s7)
ffffffffc02035fc:	779c                	ld	a5,40(a5)
ffffffffc02035fe:	9782                	jalr	a5
ffffffffc0203600:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0203602:	3a8c1763          	bne	s8,s0,ffffffffc02039b0 <pmm_init+0x974>
}
ffffffffc0203606:	7406                	ld	s0,96(sp)
ffffffffc0203608:	70a6                	ld	ra,104(sp)
ffffffffc020360a:	64e6                	ld	s1,88(sp)
ffffffffc020360c:	6946                	ld	s2,80(sp)
ffffffffc020360e:	69a6                	ld	s3,72(sp)
ffffffffc0203610:	6a06                	ld	s4,64(sp)
ffffffffc0203612:	7ae2                	ld	s5,56(sp)
ffffffffc0203614:	7b42                	ld	s6,48(sp)
ffffffffc0203616:	7ba2                	ld	s7,40(sp)
ffffffffc0203618:	7c02                	ld	s8,32(sp)
ffffffffc020361a:	6ce2                	ld	s9,24(sp)
ffffffffc020361c:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020361e:	00003517          	auipc	a0,0x3
ffffffffc0203622:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0206048 <default_pmm_manager+0x5d0>
}
ffffffffc0203626:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203628:	a93fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020362c:	6705                	lui	a4,0x1
ffffffffc020362e:	177d                	addi	a4,a4,-1
ffffffffc0203630:	96ba                	add	a3,a3,a4
ffffffffc0203632:	777d                	lui	a4,0xfffff
ffffffffc0203634:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0203636:	00c75693          	srli	a3,a4,0xc
ffffffffc020363a:	14f6f263          	bgeu	a3,a5,ffffffffc020377e <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc020363e:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0203642:	95b6                	add	a1,a1,a3
ffffffffc0203644:	00359793          	slli	a5,a1,0x3
ffffffffc0203648:	97ae                	add	a5,a5,a1
ffffffffc020364a:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020364e:	40e60733          	sub	a4,a2,a4
ffffffffc0203652:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0203654:	00c75593          	srli	a1,a4,0xc
ffffffffc0203658:	953e                	add	a0,a0,a5
ffffffffc020365a:	9682                	jalr	a3
}
ffffffffc020365c:	bcc5                	j	ffffffffc020314c <pmm_init+0x110>
        intr_disable();
ffffffffc020365e:	e91fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203662:	000bb783          	ld	a5,0(s7)
ffffffffc0203666:	779c                	ld	a5,40(a5)
ffffffffc0203668:	9782                	jalr	a5
ffffffffc020366a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020366c:	e7dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203670:	b63d                	j	ffffffffc020319e <pmm_init+0x162>
        intr_disable();
ffffffffc0203672:	e7dfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203676:	000bb783          	ld	a5,0(s7)
ffffffffc020367a:	779c                	ld	a5,40(a5)
ffffffffc020367c:	9782                	jalr	a5
ffffffffc020367e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203680:	e69fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203684:	b3c1                	j	ffffffffc0203444 <pmm_init+0x408>
        intr_disable();
ffffffffc0203686:	e69fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020368a:	000bb783          	ld	a5,0(s7)
ffffffffc020368e:	779c                	ld	a5,40(a5)
ffffffffc0203690:	9782                	jalr	a5
ffffffffc0203692:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203694:	e55fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203698:	b361                	j	ffffffffc0203420 <pmm_init+0x3e4>
ffffffffc020369a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020369c:	e53fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02036a0:	000bb783          	ld	a5,0(s7)
ffffffffc02036a4:	6522                	ld	a0,8(sp)
ffffffffc02036a6:	4585                	li	a1,1
ffffffffc02036a8:	739c                	ld	a5,32(a5)
ffffffffc02036aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02036ac:	e3dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036b0:	bb91                	j	ffffffffc0203404 <pmm_init+0x3c8>
ffffffffc02036b2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036b4:	e3bfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036b8:	000bb783          	ld	a5,0(s7)
ffffffffc02036bc:	6522                	ld	a0,8(sp)
ffffffffc02036be:	4585                	li	a1,1
ffffffffc02036c0:	739c                	ld	a5,32(a5)
ffffffffc02036c2:	9782                	jalr	a5
        intr_enable();
ffffffffc02036c4:	e25fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036c8:	b319                	j	ffffffffc02033ce <pmm_init+0x392>
        intr_disable();
ffffffffc02036ca:	e25fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02036ce:	000bb783          	ld	a5,0(s7)
ffffffffc02036d2:	779c                	ld	a5,40(a5)
ffffffffc02036d4:	9782                	jalr	a5
ffffffffc02036d6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02036d8:	e11fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036dc:	b71d                	j	ffffffffc0203602 <pmm_init+0x5c6>
ffffffffc02036de:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036e0:	e0ffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02036e4:	000bb783          	ld	a5,0(s7)
ffffffffc02036e8:	6522                	ld	a0,8(sp)
ffffffffc02036ea:	4585                	li	a1,1
ffffffffc02036ec:	739c                	ld	a5,32(a5)
ffffffffc02036ee:	9782                	jalr	a5
        intr_enable();
ffffffffc02036f0:	df9fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036f4:	bdcd                	j	ffffffffc02035e6 <pmm_init+0x5aa>
ffffffffc02036f6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036f8:	df7fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036fc:	000bb783          	ld	a5,0(s7)
ffffffffc0203700:	6522                	ld	a0,8(sp)
ffffffffc0203702:	4585                	li	a1,1
ffffffffc0203704:	739c                	ld	a5,32(a5)
ffffffffc0203706:	9782                	jalr	a5
        intr_enable();
ffffffffc0203708:	de1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020370c:	b555                	j	ffffffffc02035b0 <pmm_init+0x574>
        intr_disable();
ffffffffc020370e:	de1fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203712:	000bb783          	ld	a5,0(s7)
ffffffffc0203716:	4585                	li	a1,1
ffffffffc0203718:	8556                	mv	a0,s5
ffffffffc020371a:	739c                	ld	a5,32(a5)
ffffffffc020371c:	9782                	jalr	a5
        intr_enable();
ffffffffc020371e:	dcbfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203722:	bda9                	j	ffffffffc020357c <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203724:	00002697          	auipc	a3,0x2
ffffffffc0203728:	7d468693          	addi	a3,a3,2004 # ffffffffc0205ef8 <default_pmm_manager+0x480>
ffffffffc020372c:	00001617          	auipc	a2,0x1
ffffffffc0203730:	7cc60613          	addi	a2,a2,1996 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203734:	1ce00593          	li	a1,462
ffffffffc0203738:	00002517          	auipc	a0,0x2
ffffffffc020373c:	3b850513          	addi	a0,a0,952 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203740:	9c3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203744:	00002697          	auipc	a3,0x2
ffffffffc0203748:	77468693          	addi	a3,a3,1908 # ffffffffc0205eb8 <default_pmm_manager+0x440>
ffffffffc020374c:	00001617          	auipc	a2,0x1
ffffffffc0203750:	7ac60613          	addi	a2,a2,1964 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203754:	1cd00593          	li	a1,461
ffffffffc0203758:	00002517          	auipc	a0,0x2
ffffffffc020375c:	39850513          	addi	a0,a0,920 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203760:	9a3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203764:	86a2                	mv	a3,s0
ffffffffc0203766:	00002617          	auipc	a2,0x2
ffffffffc020376a:	36260613          	addi	a2,a2,866 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc020376e:	1cd00593          	li	a1,461
ffffffffc0203772:	00002517          	auipc	a0,0x2
ffffffffc0203776:	37e50513          	addi	a0,a0,894 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc020377a:	989fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020377e:	b90ff0ef          	jal	ra,ffffffffc0202b0e <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203782:	00002617          	auipc	a2,0x2
ffffffffc0203786:	40660613          	addi	a2,a2,1030 # ffffffffc0205b88 <default_pmm_manager+0x110>
ffffffffc020378a:	07700593          	li	a1,119
ffffffffc020378e:	00002517          	auipc	a0,0x2
ffffffffc0203792:	36250513          	addi	a0,a0,866 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203796:	96dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020379a:	00002617          	auipc	a2,0x2
ffffffffc020379e:	3ee60613          	addi	a2,a2,1006 # ffffffffc0205b88 <default_pmm_manager+0x110>
ffffffffc02037a2:	0bd00593          	li	a1,189
ffffffffc02037a6:	00002517          	auipc	a0,0x2
ffffffffc02037aa:	34a50513          	addi	a0,a0,842 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02037ae:	955fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02037b2:	00002697          	auipc	a3,0x2
ffffffffc02037b6:	43e68693          	addi	a3,a3,1086 # ffffffffc0205bf0 <default_pmm_manager+0x178>
ffffffffc02037ba:	00001617          	auipc	a2,0x1
ffffffffc02037be:	73e60613          	addi	a2,a2,1854 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02037c2:	19300593          	li	a1,403
ffffffffc02037c6:	00002517          	auipc	a0,0x2
ffffffffc02037ca:	32a50513          	addi	a0,a0,810 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02037ce:	935fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02037d2:	00002697          	auipc	a3,0x2
ffffffffc02037d6:	3fe68693          	addi	a3,a3,1022 # ffffffffc0205bd0 <default_pmm_manager+0x158>
ffffffffc02037da:	00001617          	auipc	a2,0x1
ffffffffc02037de:	71e60613          	addi	a2,a2,1822 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02037e2:	19200593          	li	a1,402
ffffffffc02037e6:	00002517          	auipc	a0,0x2
ffffffffc02037ea:	30a50513          	addi	a0,a0,778 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02037ee:	915fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02037f2:	b38ff0ef          	jal	ra,ffffffffc0202b2a <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02037f6:	00002697          	auipc	a3,0x2
ffffffffc02037fa:	48a68693          	addi	a3,a3,1162 # ffffffffc0205c80 <default_pmm_manager+0x208>
ffffffffc02037fe:	00001617          	auipc	a2,0x1
ffffffffc0203802:	6fa60613          	addi	a2,a2,1786 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203806:	19a00593          	li	a1,410
ffffffffc020380a:	00002517          	auipc	a0,0x2
ffffffffc020380e:	2e650513          	addi	a0,a0,742 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203812:	8f1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203816:	00002697          	auipc	a3,0x2
ffffffffc020381a:	43a68693          	addi	a3,a3,1082 # ffffffffc0205c50 <default_pmm_manager+0x1d8>
ffffffffc020381e:	00001617          	auipc	a2,0x1
ffffffffc0203822:	6da60613          	addi	a2,a2,1754 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203826:	19800593          	li	a1,408
ffffffffc020382a:	00002517          	auipc	a0,0x2
ffffffffc020382e:	2c650513          	addi	a0,a0,710 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203832:	8d1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203836:	00002697          	auipc	a3,0x2
ffffffffc020383a:	3f268693          	addi	a3,a3,1010 # ffffffffc0205c28 <default_pmm_manager+0x1b0>
ffffffffc020383e:	00001617          	auipc	a2,0x1
ffffffffc0203842:	6ba60613          	addi	a2,a2,1722 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203846:	19400593          	li	a1,404
ffffffffc020384a:	00002517          	auipc	a0,0x2
ffffffffc020384e:	2a650513          	addi	a0,a0,678 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203852:	8b1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203856:	00002697          	auipc	a3,0x2
ffffffffc020385a:	4b268693          	addi	a3,a3,1202 # ffffffffc0205d08 <default_pmm_manager+0x290>
ffffffffc020385e:	00001617          	auipc	a2,0x1
ffffffffc0203862:	69a60613          	addi	a2,a2,1690 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203866:	1a300593          	li	a1,419
ffffffffc020386a:	00002517          	auipc	a0,0x2
ffffffffc020386e:	28650513          	addi	a0,a0,646 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203872:	891fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203876:	00002697          	auipc	a3,0x2
ffffffffc020387a:	53268693          	addi	a3,a3,1330 # ffffffffc0205da8 <default_pmm_manager+0x330>
ffffffffc020387e:	00001617          	auipc	a2,0x1
ffffffffc0203882:	67a60613          	addi	a2,a2,1658 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203886:	1a800593          	li	a1,424
ffffffffc020388a:	00002517          	auipc	a0,0x2
ffffffffc020388e:	26650513          	addi	a0,a0,614 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203892:	871fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203896:	00002697          	auipc	a3,0x2
ffffffffc020389a:	44a68693          	addi	a3,a3,1098 # ffffffffc0205ce0 <default_pmm_manager+0x268>
ffffffffc020389e:	00001617          	auipc	a2,0x1
ffffffffc02038a2:	65a60613          	addi	a2,a2,1626 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02038a6:	1a000593          	li	a1,416
ffffffffc02038aa:	00002517          	auipc	a0,0x2
ffffffffc02038ae:	24650513          	addi	a0,a0,582 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02038b2:	851fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02038b6:	86d6                	mv	a3,s5
ffffffffc02038b8:	00002617          	auipc	a2,0x2
ffffffffc02038bc:	21060613          	addi	a2,a2,528 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc02038c0:	19f00593          	li	a1,415
ffffffffc02038c4:	00002517          	auipc	a0,0x2
ffffffffc02038c8:	22c50513          	addi	a0,a0,556 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02038cc:	837fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02038d0:	00002697          	auipc	a3,0x2
ffffffffc02038d4:	47068693          	addi	a3,a3,1136 # ffffffffc0205d40 <default_pmm_manager+0x2c8>
ffffffffc02038d8:	00001617          	auipc	a2,0x1
ffffffffc02038dc:	62060613          	addi	a2,a2,1568 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02038e0:	1ad00593          	li	a1,429
ffffffffc02038e4:	00002517          	auipc	a0,0x2
ffffffffc02038e8:	20c50513          	addi	a0,a0,524 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02038ec:	817fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038f0:	00002697          	auipc	a3,0x2
ffffffffc02038f4:	51868693          	addi	a3,a3,1304 # ffffffffc0205e08 <default_pmm_manager+0x390>
ffffffffc02038f8:	00001617          	auipc	a2,0x1
ffffffffc02038fc:	60060613          	addi	a2,a2,1536 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203900:	1ac00593          	li	a1,428
ffffffffc0203904:	00002517          	auipc	a0,0x2
ffffffffc0203908:	1ec50513          	addi	a0,a0,492 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc020390c:	ff6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203910:	00002697          	auipc	a3,0x2
ffffffffc0203914:	4e068693          	addi	a3,a3,1248 # ffffffffc0205df0 <default_pmm_manager+0x378>
ffffffffc0203918:	00001617          	auipc	a2,0x1
ffffffffc020391c:	5e060613          	addi	a2,a2,1504 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203920:	1ab00593          	li	a1,427
ffffffffc0203924:	00002517          	auipc	a0,0x2
ffffffffc0203928:	1cc50513          	addi	a0,a0,460 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc020392c:	fd6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203930:	00002697          	auipc	a3,0x2
ffffffffc0203934:	49068693          	addi	a3,a3,1168 # ffffffffc0205dc0 <default_pmm_manager+0x348>
ffffffffc0203938:	00001617          	auipc	a2,0x1
ffffffffc020393c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203940:	1aa00593          	li	a1,426
ffffffffc0203944:	00002517          	auipc	a0,0x2
ffffffffc0203948:	1ac50513          	addi	a0,a0,428 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc020394c:	fb6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203950:	00002697          	auipc	a3,0x2
ffffffffc0203954:	62868693          	addi	a3,a3,1576 # ffffffffc0205f78 <default_pmm_manager+0x500>
ffffffffc0203958:	00001617          	auipc	a2,0x1
ffffffffc020395c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203960:	1d800593          	li	a1,472
ffffffffc0203964:	00002517          	auipc	a0,0x2
ffffffffc0203968:	18c50513          	addi	a0,a0,396 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc020396c:	f96fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203970:	00002697          	auipc	a3,0x2
ffffffffc0203974:	42068693          	addi	a3,a3,1056 # ffffffffc0205d90 <default_pmm_manager+0x318>
ffffffffc0203978:	00001617          	auipc	a2,0x1
ffffffffc020397c:	58060613          	addi	a2,a2,1408 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203980:	1a700593          	li	a1,423
ffffffffc0203984:	00002517          	auipc	a0,0x2
ffffffffc0203988:	16c50513          	addi	a0,a0,364 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc020398c:	f76fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203990:	00002697          	auipc	a3,0x2
ffffffffc0203994:	3f068693          	addi	a3,a3,1008 # ffffffffc0205d80 <default_pmm_manager+0x308>
ffffffffc0203998:	00001617          	auipc	a2,0x1
ffffffffc020399c:	56060613          	addi	a2,a2,1376 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02039a0:	1a600593          	li	a1,422
ffffffffc02039a4:	00002517          	auipc	a0,0x2
ffffffffc02039a8:	14c50513          	addi	a0,a0,332 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02039ac:	f56fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02039b0:	00002697          	auipc	a3,0x2
ffffffffc02039b4:	4c868693          	addi	a3,a3,1224 # ffffffffc0205e78 <default_pmm_manager+0x400>
ffffffffc02039b8:	00001617          	auipc	a2,0x1
ffffffffc02039bc:	54060613          	addi	a2,a2,1344 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02039c0:	1e800593          	li	a1,488
ffffffffc02039c4:	00002517          	auipc	a0,0x2
ffffffffc02039c8:	12c50513          	addi	a0,a0,300 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02039cc:	f36fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02039d0:	00002697          	auipc	a3,0x2
ffffffffc02039d4:	3a068693          	addi	a3,a3,928 # ffffffffc0205d70 <default_pmm_manager+0x2f8>
ffffffffc02039d8:	00001617          	auipc	a2,0x1
ffffffffc02039dc:	52060613          	addi	a2,a2,1312 # ffffffffc0204ef8 <commands+0x728>
ffffffffc02039e0:	1a500593          	li	a1,421
ffffffffc02039e4:	00002517          	auipc	a0,0x2
ffffffffc02039e8:	10c50513          	addi	a0,a0,268 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc02039ec:	f16fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02039f0:	00002697          	auipc	a3,0x2
ffffffffc02039f4:	2d868693          	addi	a3,a3,728 # ffffffffc0205cc8 <default_pmm_manager+0x250>
ffffffffc02039f8:	00001617          	auipc	a2,0x1
ffffffffc02039fc:	50060613          	addi	a2,a2,1280 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203a00:	1b200593          	li	a1,434
ffffffffc0203a04:	00002517          	auipc	a0,0x2
ffffffffc0203a08:	0ec50513          	addi	a0,a0,236 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203a0c:	ef6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203a10:	00002697          	auipc	a3,0x2
ffffffffc0203a14:	41068693          	addi	a3,a3,1040 # ffffffffc0205e20 <default_pmm_manager+0x3a8>
ffffffffc0203a18:	00001617          	auipc	a2,0x1
ffffffffc0203a1c:	4e060613          	addi	a2,a2,1248 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203a20:	1af00593          	li	a1,431
ffffffffc0203a24:	00002517          	auipc	a0,0x2
ffffffffc0203a28:	0cc50513          	addi	a0,a0,204 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203a2c:	ed6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a30:	00002697          	auipc	a3,0x2
ffffffffc0203a34:	28068693          	addi	a3,a3,640 # ffffffffc0205cb0 <default_pmm_manager+0x238>
ffffffffc0203a38:	00001617          	auipc	a2,0x1
ffffffffc0203a3c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203a40:	1ae00593          	li	a1,430
ffffffffc0203a44:	00002517          	auipc	a0,0x2
ffffffffc0203a48:	0ac50513          	addi	a0,a0,172 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203a4c:	eb6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a50:	00002617          	auipc	a2,0x2
ffffffffc0203a54:	07860613          	addi	a2,a2,120 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0203a58:	06a00593          	li	a1,106
ffffffffc0203a5c:	00001517          	auipc	a0,0x1
ffffffffc0203a60:	70c50513          	addi	a0,a0,1804 # ffffffffc0205168 <commands+0x998>
ffffffffc0203a64:	e9efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203a68:	00002697          	auipc	a3,0x2
ffffffffc0203a6c:	3e868693          	addi	a3,a3,1000 # ffffffffc0205e50 <default_pmm_manager+0x3d8>
ffffffffc0203a70:	00001617          	auipc	a2,0x1
ffffffffc0203a74:	48860613          	addi	a2,a2,1160 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203a78:	1b900593          	li	a1,441
ffffffffc0203a7c:	00002517          	auipc	a0,0x2
ffffffffc0203a80:	07450513          	addi	a0,a0,116 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203a84:	e7efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203a88:	00002697          	auipc	a3,0x2
ffffffffc0203a8c:	38068693          	addi	a3,a3,896 # ffffffffc0205e08 <default_pmm_manager+0x390>
ffffffffc0203a90:	00001617          	auipc	a2,0x1
ffffffffc0203a94:	46860613          	addi	a2,a2,1128 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203a98:	1b700593          	li	a1,439
ffffffffc0203a9c:	00002517          	auipc	a0,0x2
ffffffffc0203aa0:	05450513          	addi	a0,a0,84 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203aa4:	e5efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203aa8:	00002697          	auipc	a3,0x2
ffffffffc0203aac:	39068693          	addi	a3,a3,912 # ffffffffc0205e38 <default_pmm_manager+0x3c0>
ffffffffc0203ab0:	00001617          	auipc	a2,0x1
ffffffffc0203ab4:	44860613          	addi	a2,a2,1096 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203ab8:	1b600593          	li	a1,438
ffffffffc0203abc:	00002517          	auipc	a0,0x2
ffffffffc0203ac0:	03450513          	addi	a0,a0,52 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203ac4:	e3efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203ac8:	00002697          	auipc	a3,0x2
ffffffffc0203acc:	34068693          	addi	a3,a3,832 # ffffffffc0205e08 <default_pmm_manager+0x390>
ffffffffc0203ad0:	00001617          	auipc	a2,0x1
ffffffffc0203ad4:	42860613          	addi	a2,a2,1064 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203ad8:	1b300593          	li	a1,435
ffffffffc0203adc:	00002517          	auipc	a0,0x2
ffffffffc0203ae0:	01450513          	addi	a0,a0,20 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203ae4:	e1efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203ae8:	00002697          	auipc	a3,0x2
ffffffffc0203aec:	47868693          	addi	a3,a3,1144 # ffffffffc0205f60 <default_pmm_manager+0x4e8>
ffffffffc0203af0:	00001617          	auipc	a2,0x1
ffffffffc0203af4:	40860613          	addi	a2,a2,1032 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203af8:	1d700593          	li	a1,471
ffffffffc0203afc:	00002517          	auipc	a0,0x2
ffffffffc0203b00:	ff450513          	addi	a0,a0,-12 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203b04:	dfefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203b08:	00002697          	auipc	a3,0x2
ffffffffc0203b0c:	42068693          	addi	a3,a3,1056 # ffffffffc0205f28 <default_pmm_manager+0x4b0>
ffffffffc0203b10:	00001617          	auipc	a2,0x1
ffffffffc0203b14:	3e860613          	addi	a2,a2,1000 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203b18:	1d600593          	li	a1,470
ffffffffc0203b1c:	00002517          	auipc	a0,0x2
ffffffffc0203b20:	fd450513          	addi	a0,a0,-44 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203b24:	ddefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203b28:	00002697          	auipc	a3,0x2
ffffffffc0203b2c:	3e868693          	addi	a3,a3,1000 # ffffffffc0205f10 <default_pmm_manager+0x498>
ffffffffc0203b30:	00001617          	auipc	a2,0x1
ffffffffc0203b34:	3c860613          	addi	a2,a2,968 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203b38:	1d200593          	li	a1,466
ffffffffc0203b3c:	00002517          	auipc	a0,0x2
ffffffffc0203b40:	fb450513          	addi	a0,a0,-76 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203b44:	dbefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203b48:	00002697          	auipc	a3,0x2
ffffffffc0203b4c:	33068693          	addi	a3,a3,816 # ffffffffc0205e78 <default_pmm_manager+0x400>
ffffffffc0203b50:	00001617          	auipc	a2,0x1
ffffffffc0203b54:	3a860613          	addi	a2,a2,936 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203b58:	1c000593          	li	a1,448
ffffffffc0203b5c:	00002517          	auipc	a0,0x2
ffffffffc0203b60:	f9450513          	addi	a0,a0,-108 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203b64:	d9efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203b68:	00002697          	auipc	a3,0x2
ffffffffc0203b6c:	14868693          	addi	a3,a3,328 # ffffffffc0205cb0 <default_pmm_manager+0x238>
ffffffffc0203b70:	00001617          	auipc	a2,0x1
ffffffffc0203b74:	38860613          	addi	a2,a2,904 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203b78:	19b00593          	li	a1,411
ffffffffc0203b7c:	00002517          	auipc	a0,0x2
ffffffffc0203b80:	f7450513          	addi	a0,a0,-140 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203b84:	d7efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203b88:	00002617          	auipc	a2,0x2
ffffffffc0203b8c:	f4060613          	addi	a2,a2,-192 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0203b90:	19e00593          	li	a1,414
ffffffffc0203b94:	00002517          	auipc	a0,0x2
ffffffffc0203b98:	f5c50513          	addi	a0,a0,-164 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203b9c:	d66fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203ba0:	00002697          	auipc	a3,0x2
ffffffffc0203ba4:	12868693          	addi	a3,a3,296 # ffffffffc0205cc8 <default_pmm_manager+0x250>
ffffffffc0203ba8:	00001617          	auipc	a2,0x1
ffffffffc0203bac:	35060613          	addi	a2,a2,848 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203bb0:	19c00593          	li	a1,412
ffffffffc0203bb4:	00002517          	auipc	a0,0x2
ffffffffc0203bb8:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203bbc:	d46fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203bc0:	00002697          	auipc	a3,0x2
ffffffffc0203bc4:	18068693          	addi	a3,a3,384 # ffffffffc0205d40 <default_pmm_manager+0x2c8>
ffffffffc0203bc8:	00001617          	auipc	a2,0x1
ffffffffc0203bcc:	33060613          	addi	a2,a2,816 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203bd0:	1a400593          	li	a1,420
ffffffffc0203bd4:	00002517          	auipc	a0,0x2
ffffffffc0203bd8:	f1c50513          	addi	a0,a0,-228 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203bdc:	d26fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203be0:	00002697          	auipc	a3,0x2
ffffffffc0203be4:	44068693          	addi	a3,a3,1088 # ffffffffc0206020 <default_pmm_manager+0x5a8>
ffffffffc0203be8:	00001617          	auipc	a2,0x1
ffffffffc0203bec:	31060613          	addi	a2,a2,784 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203bf0:	1e000593          	li	a1,480
ffffffffc0203bf4:	00002517          	auipc	a0,0x2
ffffffffc0203bf8:	efc50513          	addi	a0,a0,-260 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203bfc:	d06fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203c00:	00002697          	auipc	a3,0x2
ffffffffc0203c04:	3e868693          	addi	a3,a3,1000 # ffffffffc0205fe8 <default_pmm_manager+0x570>
ffffffffc0203c08:	00001617          	auipc	a2,0x1
ffffffffc0203c0c:	2f060613          	addi	a2,a2,752 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203c10:	1dd00593          	li	a1,477
ffffffffc0203c14:	00002517          	auipc	a0,0x2
ffffffffc0203c18:	edc50513          	addi	a0,a0,-292 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203c1c:	ce6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203c20:	00002697          	auipc	a3,0x2
ffffffffc0203c24:	39868693          	addi	a3,a3,920 # ffffffffc0205fb8 <default_pmm_manager+0x540>
ffffffffc0203c28:	00001617          	auipc	a2,0x1
ffffffffc0203c2c:	2d060613          	addi	a2,a2,720 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203c30:	1d900593          	li	a1,473
ffffffffc0203c34:	00002517          	auipc	a0,0x2
ffffffffc0203c38:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203c3c:	cc6fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c40 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203c40:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203c44:	8082                	ret

ffffffffc0203c46 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203c46:	7179                	addi	sp,sp,-48
ffffffffc0203c48:	e84a                	sd	s2,16(sp)
ffffffffc0203c4a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203c4c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203c4e:	f022                	sd	s0,32(sp)
ffffffffc0203c50:	ec26                	sd	s1,24(sp)
ffffffffc0203c52:	e44e                	sd	s3,8(sp)
ffffffffc0203c54:	f406                	sd	ra,40(sp)
ffffffffc0203c56:	84ae                	mv	s1,a1
ffffffffc0203c58:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203c5a:	eedfe0ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
ffffffffc0203c5e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203c60:	cd09                	beqz	a0,ffffffffc0203c7a <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203c62:	85aa                	mv	a1,a0
ffffffffc0203c64:	86ce                	mv	a3,s3
ffffffffc0203c66:	8626                	mv	a2,s1
ffffffffc0203c68:	854a                	mv	a0,s2
ffffffffc0203c6a:	ad2ff0ef          	jal	ra,ffffffffc0202f3c <page_insert>
ffffffffc0203c6e:	ed21                	bnez	a0,ffffffffc0203cc6 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203c70:	0000e797          	auipc	a5,0xe
ffffffffc0203c74:	8d87a783          	lw	a5,-1832(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0203c78:	eb89                	bnez	a5,ffffffffc0203c8a <pgdir_alloc_page+0x44>
}
ffffffffc0203c7a:	70a2                	ld	ra,40(sp)
ffffffffc0203c7c:	8522                	mv	a0,s0
ffffffffc0203c7e:	7402                	ld	s0,32(sp)
ffffffffc0203c80:	64e2                	ld	s1,24(sp)
ffffffffc0203c82:	6942                	ld	s2,16(sp)
ffffffffc0203c84:	69a2                	ld	s3,8(sp)
ffffffffc0203c86:	6145                	addi	sp,sp,48
ffffffffc0203c88:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203c8a:	4681                	li	a3,0
ffffffffc0203c8c:	8622                	mv	a2,s0
ffffffffc0203c8e:	85a6                	mv	a1,s1
ffffffffc0203c90:	0000e517          	auipc	a0,0xe
ffffffffc0203c94:	89053503          	ld	a0,-1904(a0) # ffffffffc0211520 <check_mm_struct>
ffffffffc0203c98:	8f8fe0ef          	jal	ra,ffffffffc0201d90 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203c9c:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203c9e:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203ca0:	4785                	li	a5,1
ffffffffc0203ca2:	fcf70ce3          	beq	a4,a5,ffffffffc0203c7a <pgdir_alloc_page+0x34>
ffffffffc0203ca6:	00002697          	auipc	a3,0x2
ffffffffc0203caa:	3c268693          	addi	a3,a3,962 # ffffffffc0206068 <default_pmm_manager+0x5f0>
ffffffffc0203cae:	00001617          	auipc	a2,0x1
ffffffffc0203cb2:	24a60613          	addi	a2,a2,586 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203cb6:	17a00593          	li	a1,378
ffffffffc0203cba:	00002517          	auipc	a0,0x2
ffffffffc0203cbe:	e3650513          	addi	a0,a0,-458 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203cc2:	c40fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203cc6:	100027f3          	csrr	a5,sstatus
ffffffffc0203cca:	8b89                	andi	a5,a5,2
ffffffffc0203ccc:	eb99                	bnez	a5,ffffffffc0203ce2 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cce:	0000e797          	auipc	a5,0xe
ffffffffc0203cd2:	8a27b783          	ld	a5,-1886(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0203cd6:	739c                	ld	a5,32(a5)
ffffffffc0203cd8:	8522                	mv	a0,s0
ffffffffc0203cda:	4585                	li	a1,1
ffffffffc0203cdc:	9782                	jalr	a5
            return NULL;
ffffffffc0203cde:	4401                	li	s0,0
ffffffffc0203ce0:	bf69                	j	ffffffffc0203c7a <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203ce2:	80dfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203ce6:	0000e797          	auipc	a5,0xe
ffffffffc0203cea:	88a7b783          	ld	a5,-1910(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0203cee:	739c                	ld	a5,32(a5)
ffffffffc0203cf0:	8522                	mv	a0,s0
ffffffffc0203cf2:	4585                	li	a1,1
ffffffffc0203cf4:	9782                	jalr	a5
            return NULL;
ffffffffc0203cf6:	4401                	li	s0,0
        intr_enable();
ffffffffc0203cf8:	ff0fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203cfc:	bfbd                	j	ffffffffc0203c7a <pgdir_alloc_page+0x34>

ffffffffc0203cfe <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203cfe:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d00:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203d02:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d04:	fff50713          	addi	a4,a0,-1
ffffffffc0203d08:	17f9                	addi	a5,a5,-2
ffffffffc0203d0a:	04e7ea63          	bltu	a5,a4,ffffffffc0203d5e <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203d0e:	6785                	lui	a5,0x1
ffffffffc0203d10:	17fd                	addi	a5,a5,-1
ffffffffc0203d12:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203d14:	8131                	srli	a0,a0,0xc
ffffffffc0203d16:	e31fe0ef          	jal	ra,ffffffffc0202b46 <alloc_pages>
    assert(base != NULL);
ffffffffc0203d1a:	cd3d                	beqz	a0,ffffffffc0203d98 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d1c:	0000e797          	auipc	a5,0xe
ffffffffc0203d20:	84c7b783          	ld	a5,-1972(a5) # ffffffffc0211568 <pages>
ffffffffc0203d24:	8d1d                	sub	a0,a0,a5
ffffffffc0203d26:	00002697          	auipc	a3,0x2
ffffffffc0203d2a:	63a6b683          	ld	a3,1594(a3) # ffffffffc0206360 <error_string+0x38>
ffffffffc0203d2e:	850d                	srai	a0,a0,0x3
ffffffffc0203d30:	02d50533          	mul	a0,a0,a3
ffffffffc0203d34:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d38:	0000e717          	auipc	a4,0xe
ffffffffc0203d3c:	82873703          	ld	a4,-2008(a4) # ffffffffc0211560 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d40:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d42:	00c51793          	slli	a5,a0,0xc
ffffffffc0203d46:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d48:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d4a:	02e7fa63          	bgeu	a5,a4,ffffffffc0203d7e <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203d4e:	60a2                	ld	ra,8(sp)
ffffffffc0203d50:	0000e797          	auipc	a5,0xe
ffffffffc0203d54:	8287b783          	ld	a5,-2008(a5) # ffffffffc0211578 <va_pa_offset>
ffffffffc0203d58:	953e                	add	a0,a0,a5
ffffffffc0203d5a:	0141                	addi	sp,sp,16
ffffffffc0203d5c:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d5e:	00002697          	auipc	a3,0x2
ffffffffc0203d62:	32268693          	addi	a3,a3,802 # ffffffffc0206080 <default_pmm_manager+0x608>
ffffffffc0203d66:	00001617          	auipc	a2,0x1
ffffffffc0203d6a:	19260613          	addi	a2,a2,402 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203d6e:	1f000593          	li	a1,496
ffffffffc0203d72:	00002517          	auipc	a0,0x2
ffffffffc0203d76:	d7e50513          	addi	a0,a0,-642 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203d7a:	b88fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203d7e:	86aa                	mv	a3,a0
ffffffffc0203d80:	00002617          	auipc	a2,0x2
ffffffffc0203d84:	d4860613          	addi	a2,a2,-696 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0203d88:	06a00593          	li	a1,106
ffffffffc0203d8c:	00001517          	auipc	a0,0x1
ffffffffc0203d90:	3dc50513          	addi	a0,a0,988 # ffffffffc0205168 <commands+0x998>
ffffffffc0203d94:	b6efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203d98:	00002697          	auipc	a3,0x2
ffffffffc0203d9c:	30868693          	addi	a3,a3,776 # ffffffffc02060a0 <default_pmm_manager+0x628>
ffffffffc0203da0:	00001617          	auipc	a2,0x1
ffffffffc0203da4:	15860613          	addi	a2,a2,344 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203da8:	1f300593          	li	a1,499
ffffffffc0203dac:	00002517          	auipc	a0,0x2
ffffffffc0203db0:	d4450513          	addi	a0,a0,-700 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203db4:	b4efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203db8 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203db8:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203dba:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203dbc:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203dbe:	fff58713          	addi	a4,a1,-1
ffffffffc0203dc2:	17f9                	addi	a5,a5,-2
ffffffffc0203dc4:	0ae7ee63          	bltu	a5,a4,ffffffffc0203e80 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203dc8:	cd41                	beqz	a0,ffffffffc0203e60 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203dca:	6785                	lui	a5,0x1
ffffffffc0203dcc:	17fd                	addi	a5,a5,-1
ffffffffc0203dce:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203dd0:	c02007b7          	lui	a5,0xc0200
ffffffffc0203dd4:	81b1                	srli	a1,a1,0xc
ffffffffc0203dd6:	06f56863          	bltu	a0,a5,ffffffffc0203e46 <kfree+0x8e>
ffffffffc0203dda:	0000d697          	auipc	a3,0xd
ffffffffc0203dde:	79e6b683          	ld	a3,1950(a3) # ffffffffc0211578 <va_pa_offset>
ffffffffc0203de2:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203de4:	8131                	srli	a0,a0,0xc
ffffffffc0203de6:	0000d797          	auipc	a5,0xd
ffffffffc0203dea:	77a7b783          	ld	a5,1914(a5) # ffffffffc0211560 <npage>
ffffffffc0203dee:	04f57a63          	bgeu	a0,a5,ffffffffc0203e42 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203df2:	fff806b7          	lui	a3,0xfff80
ffffffffc0203df6:	9536                	add	a0,a0,a3
ffffffffc0203df8:	00351793          	slli	a5,a0,0x3
ffffffffc0203dfc:	953e                	add	a0,a0,a5
ffffffffc0203dfe:	050e                	slli	a0,a0,0x3
ffffffffc0203e00:	0000d797          	auipc	a5,0xd
ffffffffc0203e04:	7687b783          	ld	a5,1896(a5) # ffffffffc0211568 <pages>
ffffffffc0203e08:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203e0a:	100027f3          	csrr	a5,sstatus
ffffffffc0203e0e:	8b89                	andi	a5,a5,2
ffffffffc0203e10:	eb89                	bnez	a5,ffffffffc0203e22 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e12:	0000d797          	auipc	a5,0xd
ffffffffc0203e16:	75e7b783          	ld	a5,1886(a5) # ffffffffc0211570 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203e1a:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e1c:	739c                	ld	a5,32(a5)
}
ffffffffc0203e1e:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e20:	8782                	jr	a5
        intr_disable();
ffffffffc0203e22:	e42a                	sd	a0,8(sp)
ffffffffc0203e24:	e02e                	sd	a1,0(sp)
ffffffffc0203e26:	ec8fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203e2a:	0000d797          	auipc	a5,0xd
ffffffffc0203e2e:	7467b783          	ld	a5,1862(a5) # ffffffffc0211570 <pmm_manager>
ffffffffc0203e32:	6582                	ld	a1,0(sp)
ffffffffc0203e34:	6522                	ld	a0,8(sp)
ffffffffc0203e36:	739c                	ld	a5,32(a5)
ffffffffc0203e38:	9782                	jalr	a5
}
ffffffffc0203e3a:	60e2                	ld	ra,24(sp)
ffffffffc0203e3c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203e3e:	eaafc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203e42:	ccdfe0ef          	jal	ra,ffffffffc0202b0e <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203e46:	86aa                	mv	a3,a0
ffffffffc0203e48:	00002617          	auipc	a2,0x2
ffffffffc0203e4c:	d4060613          	addi	a2,a2,-704 # ffffffffc0205b88 <default_pmm_manager+0x110>
ffffffffc0203e50:	06c00593          	li	a1,108
ffffffffc0203e54:	00001517          	auipc	a0,0x1
ffffffffc0203e58:	31450513          	addi	a0,a0,788 # ffffffffc0205168 <commands+0x998>
ffffffffc0203e5c:	aa6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203e60:	00002697          	auipc	a3,0x2
ffffffffc0203e64:	25068693          	addi	a3,a3,592 # ffffffffc02060b0 <default_pmm_manager+0x638>
ffffffffc0203e68:	00001617          	auipc	a2,0x1
ffffffffc0203e6c:	09060613          	addi	a2,a2,144 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203e70:	1fa00593          	li	a1,506
ffffffffc0203e74:	00002517          	auipc	a0,0x2
ffffffffc0203e78:	c7c50513          	addi	a0,a0,-900 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203e7c:	a86fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203e80:	00002697          	auipc	a3,0x2
ffffffffc0203e84:	20068693          	addi	a3,a3,512 # ffffffffc0206080 <default_pmm_manager+0x608>
ffffffffc0203e88:	00001617          	auipc	a2,0x1
ffffffffc0203e8c:	07060613          	addi	a2,a2,112 # ffffffffc0204ef8 <commands+0x728>
ffffffffc0203e90:	1f900593          	li	a1,505
ffffffffc0203e94:	00002517          	auipc	a0,0x2
ffffffffc0203e98:	c5c50513          	addi	a0,a0,-932 # ffffffffc0205af0 <default_pmm_manager+0x78>
ffffffffc0203e9c:	a66fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ea0 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203ea0:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ea2:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203ea4:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ea6:	d2cfc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203eaa:	cd01                	beqz	a0,ffffffffc0203ec2 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203eac:	4505                	li	a0,1
ffffffffc0203eae:	d2afc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203eb2:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203eb4:	810d                	srli	a0,a0,0x3
ffffffffc0203eb6:	0000d797          	auipc	a5,0xd
ffffffffc0203eba:	68a7b123          	sd	a0,1666(a5) # ffffffffc0211538 <max_swap_offset>
}
ffffffffc0203ebe:	0141                	addi	sp,sp,16
ffffffffc0203ec0:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203ec2:	00002617          	auipc	a2,0x2
ffffffffc0203ec6:	1fe60613          	addi	a2,a2,510 # ffffffffc02060c0 <default_pmm_manager+0x648>
ffffffffc0203eca:	45b5                	li	a1,13
ffffffffc0203ecc:	00002517          	auipc	a0,0x2
ffffffffc0203ed0:	21450513          	addi	a0,a0,532 # ffffffffc02060e0 <default_pmm_manager+0x668>
ffffffffc0203ed4:	a2efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ed8 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203ed8:	1141                	addi	sp,sp,-16
ffffffffc0203eda:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203edc:	00855793          	srli	a5,a0,0x8
ffffffffc0203ee0:	c3a5                	beqz	a5,ffffffffc0203f40 <swapfs_read+0x68>
ffffffffc0203ee2:	0000d717          	auipc	a4,0xd
ffffffffc0203ee6:	65673703          	ld	a4,1622(a4) # ffffffffc0211538 <max_swap_offset>
ffffffffc0203eea:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f40 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203eee:	0000d617          	auipc	a2,0xd
ffffffffc0203ef2:	67a63603          	ld	a2,1658(a2) # ffffffffc0211568 <pages>
ffffffffc0203ef6:	8d91                	sub	a1,a1,a2
ffffffffc0203ef8:	4035d613          	srai	a2,a1,0x3
ffffffffc0203efc:	00002597          	auipc	a1,0x2
ffffffffc0203f00:	4645b583          	ld	a1,1124(a1) # ffffffffc0206360 <error_string+0x38>
ffffffffc0203f04:	02b60633          	mul	a2,a2,a1
ffffffffc0203f08:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f0c:	00002797          	auipc	a5,0x2
ffffffffc0203f10:	45c7b783          	ld	a5,1116(a5) # ffffffffc0206368 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f14:	0000d717          	auipc	a4,0xd
ffffffffc0203f18:	64c73703          	ld	a4,1612(a4) # ffffffffc0211560 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f1c:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f1e:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f22:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f24:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f26:	02e7f963          	bgeu	a5,a4,ffffffffc0203f58 <swapfs_read+0x80>
}
ffffffffc0203f2a:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f2c:	0000d797          	auipc	a5,0xd
ffffffffc0203f30:	64c7b783          	ld	a5,1612(a5) # ffffffffc0211578 <va_pa_offset>
ffffffffc0203f34:	46a1                	li	a3,8
ffffffffc0203f36:	963e                	add	a2,a2,a5
ffffffffc0203f38:	4505                	li	a0,1
}
ffffffffc0203f3a:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f3c:	ca2fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203f40:	86aa                	mv	a3,a0
ffffffffc0203f42:	00002617          	auipc	a2,0x2
ffffffffc0203f46:	1b660613          	addi	a2,a2,438 # ffffffffc02060f8 <default_pmm_manager+0x680>
ffffffffc0203f4a:	45d1                	li	a1,20
ffffffffc0203f4c:	00002517          	auipc	a0,0x2
ffffffffc0203f50:	19450513          	addi	a0,a0,404 # ffffffffc02060e0 <default_pmm_manager+0x668>
ffffffffc0203f54:	9aefc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203f58:	86b2                	mv	a3,a2
ffffffffc0203f5a:	06a00593          	li	a1,106
ffffffffc0203f5e:	00002617          	auipc	a2,0x2
ffffffffc0203f62:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0203f66:	00001517          	auipc	a0,0x1
ffffffffc0203f6a:	20250513          	addi	a0,a0,514 # ffffffffc0205168 <commands+0x998>
ffffffffc0203f6e:	994fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f72 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f72:	1141                	addi	sp,sp,-16
ffffffffc0203f74:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f76:	00855793          	srli	a5,a0,0x8
ffffffffc0203f7a:	c3a5                	beqz	a5,ffffffffc0203fda <swapfs_write+0x68>
ffffffffc0203f7c:	0000d717          	auipc	a4,0xd
ffffffffc0203f80:	5bc73703          	ld	a4,1468(a4) # ffffffffc0211538 <max_swap_offset>
ffffffffc0203f84:	04e7fb63          	bgeu	a5,a4,ffffffffc0203fda <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f88:	0000d617          	auipc	a2,0xd
ffffffffc0203f8c:	5e063603          	ld	a2,1504(a2) # ffffffffc0211568 <pages>
ffffffffc0203f90:	8d91                	sub	a1,a1,a2
ffffffffc0203f92:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f96:	00002597          	auipc	a1,0x2
ffffffffc0203f9a:	3ca5b583          	ld	a1,970(a1) # ffffffffc0206360 <error_string+0x38>
ffffffffc0203f9e:	02b60633          	mul	a2,a2,a1
ffffffffc0203fa2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203fa6:	00002797          	auipc	a5,0x2
ffffffffc0203faa:	3c27b783          	ld	a5,962(a5) # ffffffffc0206368 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fae:	0000d717          	auipc	a4,0xd
ffffffffc0203fb2:	5b273703          	ld	a4,1458(a4) # ffffffffc0211560 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fb6:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fb8:	00c61793          	slli	a5,a2,0xc
ffffffffc0203fbc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fbe:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fc0:	02e7f963          	bgeu	a5,a4,ffffffffc0203ff2 <swapfs_write+0x80>
}
ffffffffc0203fc4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fc6:	0000d797          	auipc	a5,0xd
ffffffffc0203fca:	5b27b783          	ld	a5,1458(a5) # ffffffffc0211578 <va_pa_offset>
ffffffffc0203fce:	46a1                	li	a3,8
ffffffffc0203fd0:	963e                	add	a2,a2,a5
ffffffffc0203fd2:	4505                	li	a0,1
}
ffffffffc0203fd4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fd6:	c2cfc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203fda:	86aa                	mv	a3,a0
ffffffffc0203fdc:	00002617          	auipc	a2,0x2
ffffffffc0203fe0:	11c60613          	addi	a2,a2,284 # ffffffffc02060f8 <default_pmm_manager+0x680>
ffffffffc0203fe4:	45e5                	li	a1,25
ffffffffc0203fe6:	00002517          	auipc	a0,0x2
ffffffffc0203fea:	0fa50513          	addi	a0,a0,250 # ffffffffc02060e0 <default_pmm_manager+0x668>
ffffffffc0203fee:	914fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203ff2:	86b2                	mv	a3,a2
ffffffffc0203ff4:	06a00593          	li	a1,106
ffffffffc0203ff8:	00002617          	auipc	a2,0x2
ffffffffc0203ffc:	ad060613          	addi	a2,a2,-1328 # ffffffffc0205ac8 <default_pmm_manager+0x50>
ffffffffc0204000:	00001517          	auipc	a0,0x1
ffffffffc0204004:	16850513          	addi	a0,a0,360 # ffffffffc0205168 <commands+0x998>
ffffffffc0204008:	8fafc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020400c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020400c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204010:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204012:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204014:	cb81                	beqz	a5,ffffffffc0204024 <strlen+0x18>
        cnt ++;
ffffffffc0204016:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204018:	00a707b3          	add	a5,a4,a0
ffffffffc020401c:	0007c783          	lbu	a5,0(a5)
ffffffffc0204020:	fbfd                	bnez	a5,ffffffffc0204016 <strlen+0xa>
ffffffffc0204022:	8082                	ret
    }
    return cnt;
}
ffffffffc0204024:	8082                	ret

ffffffffc0204026 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204026:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204028:	e589                	bnez	a1,ffffffffc0204032 <strnlen+0xc>
ffffffffc020402a:	a811                	j	ffffffffc020403e <strnlen+0x18>
        cnt ++;
ffffffffc020402c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020402e:	00f58863          	beq	a1,a5,ffffffffc020403e <strnlen+0x18>
ffffffffc0204032:	00f50733          	add	a4,a0,a5
ffffffffc0204036:	00074703          	lbu	a4,0(a4)
ffffffffc020403a:	fb6d                	bnez	a4,ffffffffc020402c <strnlen+0x6>
ffffffffc020403c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020403e:	852e                	mv	a0,a1
ffffffffc0204040:	8082                	ret

ffffffffc0204042 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204042:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204044:	0005c703          	lbu	a4,0(a1)
ffffffffc0204048:	0785                	addi	a5,a5,1
ffffffffc020404a:	0585                	addi	a1,a1,1
ffffffffc020404c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204050:	fb75                	bnez	a4,ffffffffc0204044 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204052:	8082                	ret

ffffffffc0204054 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204054:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204058:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020405c:	cb89                	beqz	a5,ffffffffc020406e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020405e:	0505                	addi	a0,a0,1
ffffffffc0204060:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204062:	fee789e3          	beq	a5,a4,ffffffffc0204054 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204066:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020406a:	9d19                	subw	a0,a0,a4
ffffffffc020406c:	8082                	ret
ffffffffc020406e:	4501                	li	a0,0
ffffffffc0204070:	bfed                	j	ffffffffc020406a <strcmp+0x16>

ffffffffc0204072 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204072:	00054783          	lbu	a5,0(a0)
ffffffffc0204076:	c799                	beqz	a5,ffffffffc0204084 <strchr+0x12>
        if (*s == c) {
ffffffffc0204078:	00f58763          	beq	a1,a5,ffffffffc0204086 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020407c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204080:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204082:	fbfd                	bnez	a5,ffffffffc0204078 <strchr+0x6>
    }
    return NULL;
ffffffffc0204084:	4501                	li	a0,0
}
ffffffffc0204086:	8082                	ret

ffffffffc0204088 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204088:	ca01                	beqz	a2,ffffffffc0204098 <memset+0x10>
ffffffffc020408a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020408c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020408e:	0785                	addi	a5,a5,1
ffffffffc0204090:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204094:	fec79de3          	bne	a5,a2,ffffffffc020408e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204098:	8082                	ret

ffffffffc020409a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020409a:	ca19                	beqz	a2,ffffffffc02040b0 <memcpy+0x16>
ffffffffc020409c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020409e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02040a0:	0005c703          	lbu	a4,0(a1)
ffffffffc02040a4:	0585                	addi	a1,a1,1
ffffffffc02040a6:	0785                	addi	a5,a5,1
ffffffffc02040a8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02040ac:	fec59ae3          	bne	a1,a2,ffffffffc02040a0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02040b0:	8082                	ret

ffffffffc02040b2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02040b2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040b6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02040b8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040bc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02040be:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040c2:	f022                	sd	s0,32(sp)
ffffffffc02040c4:	ec26                	sd	s1,24(sp)
ffffffffc02040c6:	e84a                	sd	s2,16(sp)
ffffffffc02040c8:	f406                	sd	ra,40(sp)
ffffffffc02040ca:	e44e                	sd	s3,8(sp)
ffffffffc02040cc:	84aa                	mv	s1,a0
ffffffffc02040ce:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02040d0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02040d4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02040d6:	03067e63          	bgeu	a2,a6,ffffffffc0204112 <printnum+0x60>
ffffffffc02040da:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02040dc:	00805763          	blez	s0,ffffffffc02040ea <printnum+0x38>
ffffffffc02040e0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02040e2:	85ca                	mv	a1,s2
ffffffffc02040e4:	854e                	mv	a0,s3
ffffffffc02040e6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02040e8:	fc65                	bnez	s0,ffffffffc02040e0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040ea:	1a02                	slli	s4,s4,0x20
ffffffffc02040ec:	00002797          	auipc	a5,0x2
ffffffffc02040f0:	02c78793          	addi	a5,a5,44 # ffffffffc0206118 <default_pmm_manager+0x6a0>
ffffffffc02040f4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02040f8:	9a3e                	add	s4,s4,a5
}
ffffffffc02040fa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040fc:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204100:	70a2                	ld	ra,40(sp)
ffffffffc0204102:	69a2                	ld	s3,8(sp)
ffffffffc0204104:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204106:	85ca                	mv	a1,s2
ffffffffc0204108:	87a6                	mv	a5,s1
}
ffffffffc020410a:	6942                	ld	s2,16(sp)
ffffffffc020410c:	64e2                	ld	s1,24(sp)
ffffffffc020410e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204110:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204112:	03065633          	divu	a2,a2,a6
ffffffffc0204116:	8722                	mv	a4,s0
ffffffffc0204118:	f9bff0ef          	jal	ra,ffffffffc02040b2 <printnum>
ffffffffc020411c:	b7f9                	j	ffffffffc02040ea <printnum+0x38>

ffffffffc020411e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020411e:	7119                	addi	sp,sp,-128
ffffffffc0204120:	f4a6                	sd	s1,104(sp)
ffffffffc0204122:	f0ca                	sd	s2,96(sp)
ffffffffc0204124:	ecce                	sd	s3,88(sp)
ffffffffc0204126:	e8d2                	sd	s4,80(sp)
ffffffffc0204128:	e4d6                	sd	s5,72(sp)
ffffffffc020412a:	e0da                	sd	s6,64(sp)
ffffffffc020412c:	fc5e                	sd	s7,56(sp)
ffffffffc020412e:	f06a                	sd	s10,32(sp)
ffffffffc0204130:	fc86                	sd	ra,120(sp)
ffffffffc0204132:	f8a2                	sd	s0,112(sp)
ffffffffc0204134:	f862                	sd	s8,48(sp)
ffffffffc0204136:	f466                	sd	s9,40(sp)
ffffffffc0204138:	ec6e                	sd	s11,24(sp)
ffffffffc020413a:	892a                	mv	s2,a0
ffffffffc020413c:	84ae                	mv	s1,a1
ffffffffc020413e:	8d32                	mv	s10,a2
ffffffffc0204140:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204142:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204146:	5b7d                	li	s6,-1
ffffffffc0204148:	00002a97          	auipc	s5,0x2
ffffffffc020414c:	004a8a93          	addi	s5,s5,4 # ffffffffc020614c <default_pmm_manager+0x6d4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204150:	00002b97          	auipc	s7,0x2
ffffffffc0204154:	1d8b8b93          	addi	s7,s7,472 # ffffffffc0206328 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204158:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc020415c:	001d0413          	addi	s0,s10,1
ffffffffc0204160:	01350a63          	beq	a0,s3,ffffffffc0204174 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204164:	c121                	beqz	a0,ffffffffc02041a4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204166:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204168:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020416a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020416c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204170:	ff351ae3          	bne	a0,s3,ffffffffc0204164 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204174:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204178:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020417c:	4c81                	li	s9,0
ffffffffc020417e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204180:	5c7d                	li	s8,-1
ffffffffc0204182:	5dfd                	li	s11,-1
ffffffffc0204184:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204188:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020418a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020418e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204192:	00140d13          	addi	s10,s0,1
ffffffffc0204196:	04b56263          	bltu	a0,a1,ffffffffc02041da <vprintfmt+0xbc>
ffffffffc020419a:	058a                	slli	a1,a1,0x2
ffffffffc020419c:	95d6                	add	a1,a1,s5
ffffffffc020419e:	4194                	lw	a3,0(a1)
ffffffffc02041a0:	96d6                	add	a3,a3,s5
ffffffffc02041a2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02041a4:	70e6                	ld	ra,120(sp)
ffffffffc02041a6:	7446                	ld	s0,112(sp)
ffffffffc02041a8:	74a6                	ld	s1,104(sp)
ffffffffc02041aa:	7906                	ld	s2,96(sp)
ffffffffc02041ac:	69e6                	ld	s3,88(sp)
ffffffffc02041ae:	6a46                	ld	s4,80(sp)
ffffffffc02041b0:	6aa6                	ld	s5,72(sp)
ffffffffc02041b2:	6b06                	ld	s6,64(sp)
ffffffffc02041b4:	7be2                	ld	s7,56(sp)
ffffffffc02041b6:	7c42                	ld	s8,48(sp)
ffffffffc02041b8:	7ca2                	ld	s9,40(sp)
ffffffffc02041ba:	7d02                	ld	s10,32(sp)
ffffffffc02041bc:	6de2                	ld	s11,24(sp)
ffffffffc02041be:	6109                	addi	sp,sp,128
ffffffffc02041c0:	8082                	ret
            padc = '0';
ffffffffc02041c2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02041c4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041c8:	846a                	mv	s0,s10
ffffffffc02041ca:	00140d13          	addi	s10,s0,1
ffffffffc02041ce:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02041d2:	0ff5f593          	zext.b	a1,a1
ffffffffc02041d6:	fcb572e3          	bgeu	a0,a1,ffffffffc020419a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02041da:	85a6                	mv	a1,s1
ffffffffc02041dc:	02500513          	li	a0,37
ffffffffc02041e0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02041e2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02041e6:	8d22                	mv	s10,s0
ffffffffc02041e8:	f73788e3          	beq	a5,s3,ffffffffc0204158 <vprintfmt+0x3a>
ffffffffc02041ec:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02041f0:	1d7d                	addi	s10,s10,-1
ffffffffc02041f2:	ff379de3          	bne	a5,s3,ffffffffc02041ec <vprintfmt+0xce>
ffffffffc02041f6:	b78d                	j	ffffffffc0204158 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02041f8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02041fc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204200:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204202:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204206:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020420a:	02d86463          	bltu	a6,a3,ffffffffc0204232 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020420e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204212:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204216:	0186873b          	addw	a4,a3,s8
ffffffffc020421a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020421e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204220:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204224:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204226:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020422a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020422e:	fed870e3          	bgeu	a6,a3,ffffffffc020420e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204232:	f40ddce3          	bgez	s11,ffffffffc020418a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204236:	8de2                	mv	s11,s8
ffffffffc0204238:	5c7d                	li	s8,-1
ffffffffc020423a:	bf81                	j	ffffffffc020418a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020423c:	fffdc693          	not	a3,s11
ffffffffc0204240:	96fd                	srai	a3,a3,0x3f
ffffffffc0204242:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204246:	00144603          	lbu	a2,1(s0)
ffffffffc020424a:	2d81                	sext.w	s11,s11
ffffffffc020424c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020424e:	bf35                	j	ffffffffc020418a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204250:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204254:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204258:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020425a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020425c:	bfd9                	j	ffffffffc0204232 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020425e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204260:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204264:	01174463          	blt	a4,a7,ffffffffc020426c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204268:	1a088e63          	beqz	a7,ffffffffc0204424 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020426c:	000a3603          	ld	a2,0(s4)
ffffffffc0204270:	46c1                	li	a3,16
ffffffffc0204272:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204274:	2781                	sext.w	a5,a5
ffffffffc0204276:	876e                	mv	a4,s11
ffffffffc0204278:	85a6                	mv	a1,s1
ffffffffc020427a:	854a                	mv	a0,s2
ffffffffc020427c:	e37ff0ef          	jal	ra,ffffffffc02040b2 <printnum>
            break;
ffffffffc0204280:	bde1                	j	ffffffffc0204158 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204282:	000a2503          	lw	a0,0(s4)
ffffffffc0204286:	85a6                	mv	a1,s1
ffffffffc0204288:	0a21                	addi	s4,s4,8
ffffffffc020428a:	9902                	jalr	s2
            break;
ffffffffc020428c:	b5f1                	j	ffffffffc0204158 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020428e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204290:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204294:	01174463          	blt	a4,a7,ffffffffc020429c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204298:	18088163          	beqz	a7,ffffffffc020441a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020429c:	000a3603          	ld	a2,0(s4)
ffffffffc02042a0:	46a9                	li	a3,10
ffffffffc02042a2:	8a2e                	mv	s4,a1
ffffffffc02042a4:	bfc1                	j	ffffffffc0204274 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042a6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02042aa:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042ac:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042ae:	bdf1                	j	ffffffffc020418a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02042b0:	85a6                	mv	a1,s1
ffffffffc02042b2:	02500513          	li	a0,37
ffffffffc02042b6:	9902                	jalr	s2
            break;
ffffffffc02042b8:	b545                	j	ffffffffc0204158 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042ba:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02042be:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042c0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042c2:	b5e1                	j	ffffffffc020418a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02042c4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02042c6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02042ca:	01174463          	blt	a4,a7,ffffffffc02042d2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02042ce:	14088163          	beqz	a7,ffffffffc0204410 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02042d2:	000a3603          	ld	a2,0(s4)
ffffffffc02042d6:	46a1                	li	a3,8
ffffffffc02042d8:	8a2e                	mv	s4,a1
ffffffffc02042da:	bf69                	j	ffffffffc0204274 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02042dc:	03000513          	li	a0,48
ffffffffc02042e0:	85a6                	mv	a1,s1
ffffffffc02042e2:	e03e                	sd	a5,0(sp)
ffffffffc02042e4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02042e6:	85a6                	mv	a1,s1
ffffffffc02042e8:	07800513          	li	a0,120
ffffffffc02042ec:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02042ee:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02042f0:	6782                	ld	a5,0(sp)
ffffffffc02042f2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02042f4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02042f8:	bfb5                	j	ffffffffc0204274 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02042fa:	000a3403          	ld	s0,0(s4)
ffffffffc02042fe:	008a0713          	addi	a4,s4,8
ffffffffc0204302:	e03a                	sd	a4,0(sp)
ffffffffc0204304:	14040263          	beqz	s0,ffffffffc0204448 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204308:	0fb05763          	blez	s11,ffffffffc02043f6 <vprintfmt+0x2d8>
ffffffffc020430c:	02d00693          	li	a3,45
ffffffffc0204310:	0cd79163          	bne	a5,a3,ffffffffc02043d2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204314:	00044783          	lbu	a5,0(s0)
ffffffffc0204318:	0007851b          	sext.w	a0,a5
ffffffffc020431c:	cf85                	beqz	a5,ffffffffc0204354 <vprintfmt+0x236>
ffffffffc020431e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204322:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204326:	000c4563          	bltz	s8,ffffffffc0204330 <vprintfmt+0x212>
ffffffffc020432a:	3c7d                	addiw	s8,s8,-1
ffffffffc020432c:	036c0263          	beq	s8,s6,ffffffffc0204350 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204330:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204332:	0e0c8e63          	beqz	s9,ffffffffc020442e <vprintfmt+0x310>
ffffffffc0204336:	3781                	addiw	a5,a5,-32
ffffffffc0204338:	0ef47b63          	bgeu	s0,a5,ffffffffc020442e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020433c:	03f00513          	li	a0,63
ffffffffc0204340:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204342:	000a4783          	lbu	a5,0(s4)
ffffffffc0204346:	3dfd                	addiw	s11,s11,-1
ffffffffc0204348:	0a05                	addi	s4,s4,1
ffffffffc020434a:	0007851b          	sext.w	a0,a5
ffffffffc020434e:	ffe1                	bnez	a5,ffffffffc0204326 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204350:	01b05963          	blez	s11,ffffffffc0204362 <vprintfmt+0x244>
ffffffffc0204354:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204356:	85a6                	mv	a1,s1
ffffffffc0204358:	02000513          	li	a0,32
ffffffffc020435c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020435e:	fe0d9be3          	bnez	s11,ffffffffc0204354 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204362:	6a02                	ld	s4,0(sp)
ffffffffc0204364:	bbd5                	j	ffffffffc0204158 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204366:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204368:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020436c:	01174463          	blt	a4,a7,ffffffffc0204374 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204370:	08088d63          	beqz	a7,ffffffffc020440a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204374:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204378:	0a044d63          	bltz	s0,ffffffffc0204432 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020437c:	8622                	mv	a2,s0
ffffffffc020437e:	8a66                	mv	s4,s9
ffffffffc0204380:	46a9                	li	a3,10
ffffffffc0204382:	bdcd                	j	ffffffffc0204274 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204384:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204388:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020438a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020438c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204390:	8fb5                	xor	a5,a5,a3
ffffffffc0204392:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204396:	02d74163          	blt	a4,a3,ffffffffc02043b8 <vprintfmt+0x29a>
ffffffffc020439a:	00369793          	slli	a5,a3,0x3
ffffffffc020439e:	97de                	add	a5,a5,s7
ffffffffc02043a0:	639c                	ld	a5,0(a5)
ffffffffc02043a2:	cb99                	beqz	a5,ffffffffc02043b8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02043a4:	86be                	mv	a3,a5
ffffffffc02043a6:	00002617          	auipc	a2,0x2
ffffffffc02043aa:	da260613          	addi	a2,a2,-606 # ffffffffc0206148 <default_pmm_manager+0x6d0>
ffffffffc02043ae:	85a6                	mv	a1,s1
ffffffffc02043b0:	854a                	mv	a0,s2
ffffffffc02043b2:	0ce000ef          	jal	ra,ffffffffc0204480 <printfmt>
ffffffffc02043b6:	b34d                	j	ffffffffc0204158 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02043b8:	00002617          	auipc	a2,0x2
ffffffffc02043bc:	d8060613          	addi	a2,a2,-640 # ffffffffc0206138 <default_pmm_manager+0x6c0>
ffffffffc02043c0:	85a6                	mv	a1,s1
ffffffffc02043c2:	854a                	mv	a0,s2
ffffffffc02043c4:	0bc000ef          	jal	ra,ffffffffc0204480 <printfmt>
ffffffffc02043c8:	bb41                	j	ffffffffc0204158 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02043ca:	00002417          	auipc	s0,0x2
ffffffffc02043ce:	d6640413          	addi	s0,s0,-666 # ffffffffc0206130 <default_pmm_manager+0x6b8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043d2:	85e2                	mv	a1,s8
ffffffffc02043d4:	8522                	mv	a0,s0
ffffffffc02043d6:	e43e                	sd	a5,8(sp)
ffffffffc02043d8:	c4fff0ef          	jal	ra,ffffffffc0204026 <strnlen>
ffffffffc02043dc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02043e0:	01b05b63          	blez	s11,ffffffffc02043f6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02043e4:	67a2                	ld	a5,8(sp)
ffffffffc02043e6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043ea:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02043ec:	85a6                	mv	a1,s1
ffffffffc02043ee:	8552                	mv	a0,s4
ffffffffc02043f0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043f2:	fe0d9ce3          	bnez	s11,ffffffffc02043ea <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043f6:	00044783          	lbu	a5,0(s0)
ffffffffc02043fa:	00140a13          	addi	s4,s0,1
ffffffffc02043fe:	0007851b          	sext.w	a0,a5
ffffffffc0204402:	d3a5                	beqz	a5,ffffffffc0204362 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204404:	05e00413          	li	s0,94
ffffffffc0204408:	bf39                	j	ffffffffc0204326 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020440a:	000a2403          	lw	s0,0(s4)
ffffffffc020440e:	b7ad                	j	ffffffffc0204378 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204410:	000a6603          	lwu	a2,0(s4)
ffffffffc0204414:	46a1                	li	a3,8
ffffffffc0204416:	8a2e                	mv	s4,a1
ffffffffc0204418:	bdb1                	j	ffffffffc0204274 <vprintfmt+0x156>
ffffffffc020441a:	000a6603          	lwu	a2,0(s4)
ffffffffc020441e:	46a9                	li	a3,10
ffffffffc0204420:	8a2e                	mv	s4,a1
ffffffffc0204422:	bd89                	j	ffffffffc0204274 <vprintfmt+0x156>
ffffffffc0204424:	000a6603          	lwu	a2,0(s4)
ffffffffc0204428:	46c1                	li	a3,16
ffffffffc020442a:	8a2e                	mv	s4,a1
ffffffffc020442c:	b5a1                	j	ffffffffc0204274 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020442e:	9902                	jalr	s2
ffffffffc0204430:	bf09                	j	ffffffffc0204342 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204432:	85a6                	mv	a1,s1
ffffffffc0204434:	02d00513          	li	a0,45
ffffffffc0204438:	e03e                	sd	a5,0(sp)
ffffffffc020443a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020443c:	6782                	ld	a5,0(sp)
ffffffffc020443e:	8a66                	mv	s4,s9
ffffffffc0204440:	40800633          	neg	a2,s0
ffffffffc0204444:	46a9                	li	a3,10
ffffffffc0204446:	b53d                	j	ffffffffc0204274 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204448:	03b05163          	blez	s11,ffffffffc020446a <vprintfmt+0x34c>
ffffffffc020444c:	02d00693          	li	a3,45
ffffffffc0204450:	f6d79de3          	bne	a5,a3,ffffffffc02043ca <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204454:	00002417          	auipc	s0,0x2
ffffffffc0204458:	cdc40413          	addi	s0,s0,-804 # ffffffffc0206130 <default_pmm_manager+0x6b8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020445c:	02800793          	li	a5,40
ffffffffc0204460:	02800513          	li	a0,40
ffffffffc0204464:	00140a13          	addi	s4,s0,1
ffffffffc0204468:	bd6d                	j	ffffffffc0204322 <vprintfmt+0x204>
ffffffffc020446a:	00002a17          	auipc	s4,0x2
ffffffffc020446e:	cc7a0a13          	addi	s4,s4,-825 # ffffffffc0206131 <default_pmm_manager+0x6b9>
ffffffffc0204472:	02800513          	li	a0,40
ffffffffc0204476:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020447a:	05e00413          	li	s0,94
ffffffffc020447e:	b565                	j	ffffffffc0204326 <vprintfmt+0x208>

ffffffffc0204480 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204480:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204482:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204486:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204488:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020448a:	ec06                	sd	ra,24(sp)
ffffffffc020448c:	f83a                	sd	a4,48(sp)
ffffffffc020448e:	fc3e                	sd	a5,56(sp)
ffffffffc0204490:	e0c2                	sd	a6,64(sp)
ffffffffc0204492:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204494:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204496:	c89ff0ef          	jal	ra,ffffffffc020411e <vprintfmt>
}
ffffffffc020449a:	60e2                	ld	ra,24(sp)
ffffffffc020449c:	6161                	addi	sp,sp,80
ffffffffc020449e:	8082                	ret

ffffffffc02044a0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02044a0:	715d                	addi	sp,sp,-80
ffffffffc02044a2:	e486                	sd	ra,72(sp)
ffffffffc02044a4:	e0a6                	sd	s1,64(sp)
ffffffffc02044a6:	fc4a                	sd	s2,56(sp)
ffffffffc02044a8:	f84e                	sd	s3,48(sp)
ffffffffc02044aa:	f452                	sd	s4,40(sp)
ffffffffc02044ac:	f056                	sd	s5,32(sp)
ffffffffc02044ae:	ec5a                	sd	s6,24(sp)
ffffffffc02044b0:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02044b2:	c901                	beqz	a0,ffffffffc02044c2 <readline+0x22>
ffffffffc02044b4:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02044b6:	00002517          	auipc	a0,0x2
ffffffffc02044ba:	c9250513          	addi	a0,a0,-878 # ffffffffc0206148 <default_pmm_manager+0x6d0>
ffffffffc02044be:	bfdfb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02044c2:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044c4:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02044c6:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02044c8:	4aa9                	li	s5,10
ffffffffc02044ca:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02044cc:	0000db97          	auipc	s7,0xd
ffffffffc02044d0:	c34b8b93          	addi	s7,s7,-972 # ffffffffc0211100 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044d4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02044d8:	c1bfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044dc:	00054a63          	bltz	a0,ffffffffc02044f0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044e0:	00a95a63          	bge	s2,a0,ffffffffc02044f4 <readline+0x54>
ffffffffc02044e4:	029a5263          	bge	s4,s1,ffffffffc0204508 <readline+0x68>
        c = getchar();
ffffffffc02044e8:	c0bfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044ec:	fe055ae3          	bgez	a0,ffffffffc02044e0 <readline+0x40>
            return NULL;
ffffffffc02044f0:	4501                	li	a0,0
ffffffffc02044f2:	a091                	j	ffffffffc0204536 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02044f4:	03351463          	bne	a0,s3,ffffffffc020451c <readline+0x7c>
ffffffffc02044f8:	e8a9                	bnez	s1,ffffffffc020454a <readline+0xaa>
        c = getchar();
ffffffffc02044fa:	bf9fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044fe:	fe0549e3          	bltz	a0,ffffffffc02044f0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204502:	fea959e3          	bge	s2,a0,ffffffffc02044f4 <readline+0x54>
ffffffffc0204506:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204508:	e42a                	sd	a0,8(sp)
ffffffffc020450a:	be7fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc020450e:	6522                	ld	a0,8(sp)
ffffffffc0204510:	009b87b3          	add	a5,s7,s1
ffffffffc0204514:	2485                	addiw	s1,s1,1
ffffffffc0204516:	00a78023          	sb	a0,0(a5)
ffffffffc020451a:	bf7d                	j	ffffffffc02044d8 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020451c:	01550463          	beq	a0,s5,ffffffffc0204524 <readline+0x84>
ffffffffc0204520:	fb651ce3          	bne	a0,s6,ffffffffc02044d8 <readline+0x38>
            cputchar(c);
ffffffffc0204524:	bcdfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204528:	0000d517          	auipc	a0,0xd
ffffffffc020452c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0211100 <buf>
ffffffffc0204530:	94aa                	add	s1,s1,a0
ffffffffc0204532:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204536:	60a6                	ld	ra,72(sp)
ffffffffc0204538:	6486                	ld	s1,64(sp)
ffffffffc020453a:	7962                	ld	s2,56(sp)
ffffffffc020453c:	79c2                	ld	s3,48(sp)
ffffffffc020453e:	7a22                	ld	s4,40(sp)
ffffffffc0204540:	7a82                	ld	s5,32(sp)
ffffffffc0204542:	6b62                	ld	s6,24(sp)
ffffffffc0204544:	6bc2                	ld	s7,16(sp)
ffffffffc0204546:	6161                	addi	sp,sp,80
ffffffffc0204548:	8082                	ret
            cputchar(c);
ffffffffc020454a:	4521                	li	a0,8
ffffffffc020454c:	ba5fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0204550:	34fd                	addiw	s1,s1,-1
ffffffffc0204552:	b759                	j	ffffffffc02044d8 <readline+0x38>
