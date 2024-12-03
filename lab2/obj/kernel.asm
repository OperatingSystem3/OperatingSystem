
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44660613          	addi	a2,a2,1094 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	502010ef          	jal	ra,ffffffffc020154c <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201a70 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	0f7000ef          	jal	ra,ffffffffc020095c <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	524010ef          	jal	ra,ffffffffc02015ca <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	4ee010ef          	jal	ra,ffffffffc02015ca <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013a:	00006317          	auipc	t1,0x6
ffffffffc020013e:	2f630313          	addi	t1,t1,758 # ffffffffc0206430 <is_panic>
ffffffffc0200142:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200146:	715d                	addi	sp,sp,-80
ffffffffc0200148:	ec06                	sd	ra,24(sp)
ffffffffc020014a:	e822                	sd	s0,16(sp)
ffffffffc020014c:	f436                	sd	a3,40(sp)
ffffffffc020014e:	f83a                	sd	a4,48(sp)
ffffffffc0200150:	fc3e                	sd	a5,56(sp)
ffffffffc0200152:	e0c2                	sd	a6,64(sp)
ffffffffc0200154:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200156:	020e1a63          	bnez	t3,ffffffffc020018a <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015a:	4785                	li	a5,1
ffffffffc020015c:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200164:	862e                	mv	a2,a1
ffffffffc0200166:	85aa                	mv	a1,a0
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	92850513          	addi	a0,a0,-1752 # ffffffffc0201a90 <etext+0x26>
    va_start(ap, fmt);
ffffffffc0200170:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0201b78 <etext+0x10e>
ffffffffc0200186:	f2dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020018a:	2d4000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020018e:	4501                	li	a0,0
ffffffffc0200190:	130000ef          	jal	ra,ffffffffc02002c0 <kmonitor>
    while (1) {
ffffffffc0200194:	bfed                	j	ffffffffc020018e <__panic+0x54>

ffffffffc0200196 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200198:	00002517          	auipc	a0,0x2
ffffffffc020019c:	91850513          	addi	a0,a0,-1768 # ffffffffc0201ab0 <etext+0x46>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00002517          	auipc	a0,0x2
ffffffffc02001b2:	92250513          	addi	a0,a0,-1758 # ffffffffc0201ad0 <etext+0x66>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00002597          	auipc	a1,0x2
ffffffffc02001be:	8b058593          	addi	a1,a1,-1872 # ffffffffc0201a6a <etext>
ffffffffc02001c2:	00002517          	auipc	a0,0x2
ffffffffc02001c6:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201af0 <etext+0x86>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00006597          	auipc	a1,0x6
ffffffffc02001d2:	e4a58593          	addi	a1,a1,-438 # ffffffffc0206018 <free_area>
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201b10 <etext+0xa6>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00006597          	auipc	a1,0x6
ffffffffc02001e6:	29e58593          	addi	a1,a1,670 # ffffffffc0206480 <end>
ffffffffc02001ea:	00002517          	auipc	a0,0x2
ffffffffc02001ee:	94650513          	addi	a0,a0,-1722 # ffffffffc0201b30 <etext+0xc6>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	00006597          	auipc	a1,0x6
ffffffffc02001fa:	68958593          	addi	a1,a1,1673 # ffffffffc020687f <end+0x3ff>
ffffffffc02001fe:	00000797          	auipc	a5,0x0
ffffffffc0200202:	e3478793          	addi	a5,a5,-460 # ffffffffc0200032 <kern_init>
ffffffffc0200206:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020020a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200210:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200214:	95be                	add	a1,a1,a5
ffffffffc0200216:	85a9                	srai	a1,a1,0xa
ffffffffc0200218:	00002517          	auipc	a0,0x2
ffffffffc020021c:	93850513          	addi	a0,a0,-1736 # ffffffffc0201b50 <etext+0xe6>
}
ffffffffc0200220:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	95a60613          	addi	a2,a2,-1702 # ffffffffc0201b80 <etext+0x116>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	96650513          	addi	a0,a0,-1690 # ffffffffc0201b98 <etext+0x12e>
void print_stackframe(void) {
ffffffffc020023a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200240:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200242:	00002617          	auipc	a2,0x2
ffffffffc0200246:	96e60613          	addi	a2,a2,-1682 # ffffffffc0201bb0 <etext+0x146>
ffffffffc020024a:	00002597          	auipc	a1,0x2
ffffffffc020024e:	98658593          	addi	a1,a1,-1658 # ffffffffc0201bd0 <etext+0x166>
ffffffffc0200252:	00002517          	auipc	a0,0x2
ffffffffc0200256:	98650513          	addi	a0,a0,-1658 # ffffffffc0201bd8 <etext+0x16e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00002617          	auipc	a2,0x2
ffffffffc0200264:	98860613          	addi	a2,a2,-1656 # ffffffffc0201be8 <etext+0x17e>
ffffffffc0200268:	00002597          	auipc	a1,0x2
ffffffffc020026c:	9a858593          	addi	a1,a1,-1624 # ffffffffc0201c10 <etext+0x1a6>
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	96850513          	addi	a0,a0,-1688 # ffffffffc0201bd8 <etext+0x16e>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00002617          	auipc	a2,0x2
ffffffffc0200280:	9a460613          	addi	a2,a2,-1628 # ffffffffc0201c20 <etext+0x1b6>
ffffffffc0200284:	00002597          	auipc	a1,0x2
ffffffffc0200288:	9bc58593          	addi	a1,a1,-1604 # ffffffffc0201c40 <etext+0x1d6>
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201bd8 <etext+0x16e>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a0:	1141                	addi	sp,sp,-16
ffffffffc02002a2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002a4:	ef3ff0ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
    return 0;
}
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
ffffffffc02002aa:	4501                	li	a0,0
ffffffffc02002ac:	0141                	addi	sp,sp,16
ffffffffc02002ae:	8082                	ret

ffffffffc02002b0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b0:	1141                	addi	sp,sp,-16
ffffffffc02002b2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002b4:	f71ff0ef          	jal	ra,ffffffffc0200224 <print_stackframe>
    return 0;
}
ffffffffc02002b8:	60a2                	ld	ra,8(sp)
ffffffffc02002ba:	4501                	li	a0,0
ffffffffc02002bc:	0141                	addi	sp,sp,16
ffffffffc02002be:	8082                	ret

ffffffffc02002c0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002c0:	7115                	addi	sp,sp,-224
ffffffffc02002c2:	ed5e                	sd	s7,152(sp)
ffffffffc02002c4:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002c6:	00002517          	auipc	a0,0x2
ffffffffc02002ca:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201c50 <etext+0x1e6>
kmonitor(struct trapframe *tf) {
ffffffffc02002ce:	ed86                	sd	ra,216(sp)
ffffffffc02002d0:	e9a2                	sd	s0,208(sp)
ffffffffc02002d2:	e5a6                	sd	s1,200(sp)
ffffffffc02002d4:	e1ca                	sd	s2,192(sp)
ffffffffc02002d6:	fd4e                	sd	s3,184(sp)
ffffffffc02002d8:	f952                	sd	s4,176(sp)
ffffffffc02002da:	f556                	sd	s5,168(sp)
ffffffffc02002dc:	f15a                	sd	s6,160(sp)
ffffffffc02002de:	e962                	sd	s8,144(sp)
ffffffffc02002e0:	e566                	sd	s9,136(sp)
ffffffffc02002e2:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e4:	dcfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002e8:	00002517          	auipc	a0,0x2
ffffffffc02002ec:	99050513          	addi	a0,a0,-1648 # ffffffffc0201c78 <etext+0x20e>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00002c17          	auipc	s8,0x2
ffffffffc0200302:	9eac0c13          	addi	s8,s8,-1558 # ffffffffc0201ce8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00002917          	auipc	s2,0x2
ffffffffc020030a:	99a90913          	addi	s2,s2,-1638 # ffffffffc0201ca0 <etext+0x236>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00002497          	auipc	s1,0x2
ffffffffc0200312:	99a48493          	addi	s1,s1,-1638 # ffffffffc0201ca8 <etext+0x23e>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00002b17          	auipc	s6,0x2
ffffffffc020031c:	998b0b13          	addi	s6,s6,-1640 # ffffffffc0201cb0 <etext+0x246>
        argv[argc ++] = buf;
ffffffffc0200320:	00002a17          	auipc	s4,0x2
ffffffffc0200324:	8b0a0a13          	addi	s4,s4,-1872 # ffffffffc0201bd0 <etext+0x166>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	620010ef          	jal	ra,ffffffffc020194c <readline>
ffffffffc0200330:	842a                	mv	s0,a0
ffffffffc0200332:	dd65                	beqz	a0,ffffffffc020032a <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200334:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200338:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033a:	e1bd                	bnez	a1,ffffffffc02003a0 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020033c:	fe0c87e3          	beqz	s9,ffffffffc020032a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	00002d17          	auipc	s10,0x2
ffffffffc0200346:	9a6d0d13          	addi	s10,s10,-1626 # ffffffffc0201ce8 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	1c8010ef          	jal	ra,ffffffffc0201518 <strcmp>
ffffffffc0200354:	c919                	beqz	a0,ffffffffc020036a <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200356:	2405                	addiw	s0,s0,1
ffffffffc0200358:	0b540063          	beq	s0,s5,ffffffffc02003f8 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	000d3503          	ld	a0,0(s10)
ffffffffc0200360:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200362:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200364:	1b4010ef          	jal	ra,ffffffffc0201518 <strcmp>
ffffffffc0200368:	f57d                	bnez	a0,ffffffffc0200356 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020036a:	00141793          	slli	a5,s0,0x1
ffffffffc020036e:	97a2                	add	a5,a5,s0
ffffffffc0200370:	078e                	slli	a5,a5,0x3
ffffffffc0200372:	97e2                	add	a5,a5,s8
ffffffffc0200374:	6b9c                	ld	a5,16(a5)
ffffffffc0200376:	865e                	mv	a2,s7
ffffffffc0200378:	002c                	addi	a1,sp,8
ffffffffc020037a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200380:	fa0555e3          	bgez	a0,ffffffffc020032a <kmonitor+0x6a>
}
ffffffffc0200384:	60ee                	ld	ra,216(sp)
ffffffffc0200386:	644e                	ld	s0,208(sp)
ffffffffc0200388:	64ae                	ld	s1,200(sp)
ffffffffc020038a:	690e                	ld	s2,192(sp)
ffffffffc020038c:	79ea                	ld	s3,184(sp)
ffffffffc020038e:	7a4a                	ld	s4,176(sp)
ffffffffc0200390:	7aaa                	ld	s5,168(sp)
ffffffffc0200392:	7b0a                	ld	s6,160(sp)
ffffffffc0200394:	6bea                	ld	s7,152(sp)
ffffffffc0200396:	6c4a                	ld	s8,144(sp)
ffffffffc0200398:	6caa                	ld	s9,136(sp)
ffffffffc020039a:	6d0a                	ld	s10,128(sp)
ffffffffc020039c:	612d                	addi	sp,sp,224
ffffffffc020039e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a0:	8526                	mv	a0,s1
ffffffffc02003a2:	194010ef          	jal	ra,ffffffffc0201536 <strchr>
ffffffffc02003a6:	c901                	beqz	a0,ffffffffc02003b6 <kmonitor+0xf6>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ac:	00040023          	sb	zero,0(s0)
ffffffffc02003b0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b2:	d5c9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003b4:	b7f5                	j	ffffffffc02003a0 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003b6:	00044783          	lbu	a5,0(s0)
ffffffffc02003ba:	d3c9                	beqz	a5,ffffffffc020033c <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003bc:	033c8963          	beq	s9,s3,ffffffffc02003ee <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003c0:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c4:	0118                	addi	a4,sp,128
ffffffffc02003c6:	97ba                	add	a5,a5,a4
ffffffffc02003c8:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003cc:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d0:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	e591                	bnez	a1,ffffffffc02003de <kmonitor+0x11e>
ffffffffc02003d4:	b7b5                	j	ffffffffc0200340 <kmonitor+0x80>
ffffffffc02003d6:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003da:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003dc:	d1a5                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	156010ef          	jal	ra,ffffffffc0201536 <strchr>
ffffffffc02003e4:	d96d                	beqz	a0,ffffffffc02003d6 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e6:	00044583          	lbu	a1,0(s0)
ffffffffc02003ea:	d9a9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003ec:	bf55                	j	ffffffffc02003a0 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	b7e9                	j	ffffffffc02003c0 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00002517          	auipc	a0,0x2
ffffffffc02003fe:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201cd0 <etext+0x266>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	5fa010ef          	jal	ra,ffffffffc0201a1a <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	90250513          	addi	a0,a0,-1790 # ffffffffc0201d30 <commands+0x48>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5d40106f          	j	ffffffffc0201a1a <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	5b00106f          	j	ffffffffc0201a00 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5e00106f          	j	ffffffffc0201a34 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	38878793          	addi	a5,a5,904 # ffffffffc02007f0 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201d50 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8da50513          	addi	a0,a0,-1830 # ffffffffc0201d68 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201d80 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201d98 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201db0 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	90250513          	addi	a0,a0,-1790 # ffffffffc0201dc8 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201de0 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	91650513          	addi	a0,a0,-1770 # ffffffffc0201df8 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	92050513          	addi	a0,a0,-1760 # ffffffffc0201e10 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201e28 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	93450513          	addi	a0,a0,-1740 # ffffffffc0201e40 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201e58 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	94850513          	addi	a0,a0,-1720 # ffffffffc0201e70 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	95250513          	addi	a0,a0,-1710 # ffffffffc0201e88 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	95c50513          	addi	a0,a0,-1700 # ffffffffc0201ea0 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	96650513          	addi	a0,a0,-1690 # ffffffffc0201eb8 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	97050513          	addi	a0,a0,-1680 # ffffffffc0201ed0 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201ee8 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	98450513          	addi	a0,a0,-1660 # ffffffffc0201f00 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	98e50513          	addi	a0,a0,-1650 # ffffffffc0201f18 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	99850513          	addi	a0,a0,-1640 # ffffffffc0201f30 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201f48 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0201f60 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9b650513          	addi	a0,a0,-1610 # ffffffffc0201f78 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9c050513          	addi	a0,a0,-1600 # ffffffffc0201f90 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0201fa8 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9d450513          	addi	a0,a0,-1580 # ffffffffc0201fc0 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9de50513          	addi	a0,a0,-1570 # ffffffffc0201fd8 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0201ff0 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0202008 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0202020 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0202038 <commands+0x350>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0202050 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	a0650513          	addi	a0,a0,-1530 # ffffffffc0202068 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0202080 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	a1650513          	addi	a0,a0,-1514 # ffffffffc0202098 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02020b0 <commands+0x3c8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	08f76663          	bltu	a4,a5,ffffffffc0200738 <interrupt_handler+0x96>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	ae070713          	addi	a4,a4,-1312 # ffffffffc0202190 <commands+0x4a8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	a6650513          	addi	a0,a0,-1434 # ffffffffc0202128 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0202108 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	9f250513          	addi	a0,a0,-1550 # ffffffffc02020c8 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a6850513          	addi	a0,a0,-1432 # ffffffffc0202148 <commands+0x460>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e022                	sd	s0,0(sp)
ffffffffc02006ee:	e406                	sd	ra,8(sp)
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);

            /* LAB1 EXERCISE2  2212449 */
            clock_set_next_event();
ffffffffc02006f0:	d4bff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f4:	00006697          	auipc	a3,0x6
ffffffffc02006f8:	d4468693          	addi	a3,a3,-700 # ffffffffc0206438 <ticks>
ffffffffc02006fc:	629c                	ld	a5,0(a3)
ffffffffc02006fe:	06400713          	li	a4,100
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	d3e40413          	addi	s0,s0,-706 # ffffffffc0206440 <num>
ffffffffc020070a:	0785                	addi	a5,a5,1
ffffffffc020070c:	02e7f733          	remu	a4,a5,a4
ffffffffc0200710:	e29c                	sd	a5,0(a3)
ffffffffc0200712:	c705                	beqz	a4,ffffffffc020073a <interrupt_handler+0x98>
                print_ticks();
                num++;
            }
            if(num==10){
ffffffffc0200714:	6018                	ld	a4,0(s0)
ffffffffc0200716:	47a9                	li	a5,10
ffffffffc0200718:	02f70d63          	beq	a4,a5,ffffffffc0200752 <interrupt_handler+0xb0>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020071c:	60a2                	ld	ra,8(sp)
ffffffffc020071e:	6402                	ld	s0,0(sp)
ffffffffc0200720:	0141                	addi	sp,sp,16
ffffffffc0200722:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200724:	00002517          	auipc	a0,0x2
ffffffffc0200728:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0202170 <commands+0x488>
ffffffffc020072c:	b259                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020072e:	00002517          	auipc	a0,0x2
ffffffffc0200732:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02020e8 <commands+0x400>
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200738:	b729                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073a:	06400593          	li	a1,100
ffffffffc020073e:	00002517          	auipc	a0,0x2
ffffffffc0200742:	a2250513          	addi	a0,a0,-1502 # ffffffffc0202160 <commands+0x478>
ffffffffc0200746:	96dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                num++;
ffffffffc020074a:	601c                	ld	a5,0(s0)
ffffffffc020074c:	0785                	addi	a5,a5,1
ffffffffc020074e:	e01c                	sd	a5,0(s0)
ffffffffc0200750:	b7d1                	j	ffffffffc0200714 <interrupt_handler+0x72>
}
ffffffffc0200752:	6402                	ld	s0,0(sp)
ffffffffc0200754:	60a2                	ld	ra,8(sp)
ffffffffc0200756:	0141                	addi	sp,sp,16
                sbi_shutdown();
ffffffffc0200758:	2f80106f          	j	ffffffffc0201a50 <sbi_shutdown>

ffffffffc020075c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc020075c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200760:	1141                	addi	sp,sp,-16
ffffffffc0200762:	e022                	sd	s0,0(sp)
ffffffffc0200764:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc0200766:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200768:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc020076a:	04e78663          	beq	a5,a4,ffffffffc02007b6 <exception_handler+0x5a>
ffffffffc020076e:	02f76c63          	bltu	a4,a5,ffffffffc02007a6 <exception_handler+0x4a>
ffffffffc0200772:	4709                	li	a4,2
ffffffffc0200774:	02e79563          	bne	a5,a4,ffffffffc020079e <exception_handler+0x42>
            // 非法指令异常处理
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction\n");
ffffffffc0200778:	00002517          	auipc	a0,0x2
ffffffffc020077c:	a4850513          	addi	a0,a0,-1464 # ffffffffc02021c0 <commands+0x4d8>
ffffffffc0200780:	933ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200784:	10843583          	ld	a1,264(s0)
ffffffffc0200788:	00002517          	auipc	a0,0x2
ffffffffc020078c:	a6050513          	addi	a0,a0,-1440 # ffffffffc02021e8 <commands+0x500>
ffffffffc0200790:	923ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc+=4;
ffffffffc0200794:	10843783          	ld	a5,264(s0)
ffffffffc0200798:	0791                	addi	a5,a5,4
ffffffffc020079a:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020079e:	60a2                	ld	ra,8(sp)
ffffffffc02007a0:	6402                	ld	s0,0(sp)
ffffffffc02007a2:	0141                	addi	sp,sp,16
ffffffffc02007a4:	8082                	ret
    switch (tf->cause) {
ffffffffc02007a6:	17f1                	addi	a5,a5,-4
ffffffffc02007a8:	471d                	li	a4,7
ffffffffc02007aa:	fef77ae3          	bgeu	a4,a5,ffffffffc020079e <exception_handler+0x42>
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
ffffffffc02007b2:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc02007b4:	b579                	j	ffffffffc0200642 <print_trapframe>
            cprintf("Exception type: breakpoint\n");
ffffffffc02007b6:	00002517          	auipc	a0,0x2
ffffffffc02007ba:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0202210 <commands+0x528>
ffffffffc02007be:	8f5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc02007c2:	10843583          	ld	a1,264(s0)
ffffffffc02007c6:	00002517          	auipc	a0,0x2
ffffffffc02007ca:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0202230 <commands+0x548>
ffffffffc02007ce:	8e5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc+=2;     //断点异常指令占两个字节  
ffffffffc02007d2:	10843783          	ld	a5,264(s0)
}
ffffffffc02007d6:	60a2                	ld	ra,8(sp)
            tf->epc+=2;     //断点异常指令占两个字节  
ffffffffc02007d8:	0789                	addi	a5,a5,2
ffffffffc02007da:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007de:	6402                	ld	s0,0(sp)
ffffffffc02007e0:	0141                	addi	sp,sp,16
ffffffffc02007e2:	8082                	ret

ffffffffc02007e4 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007e4:	11853783          	ld	a5,280(a0)
ffffffffc02007e8:	0007c363          	bltz	a5,ffffffffc02007ee <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007ec:	bf85                	j	ffffffffc020075c <exception_handler>
        interrupt_handler(tf);
ffffffffc02007ee:	bd55                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc02007f0 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007f0:	14011073          	csrw	sscratch,sp
ffffffffc02007f4:	712d                	addi	sp,sp,-288
ffffffffc02007f6:	e002                	sd	zero,0(sp)
ffffffffc02007f8:	e406                	sd	ra,8(sp)
ffffffffc02007fa:	ec0e                	sd	gp,24(sp)
ffffffffc02007fc:	f012                	sd	tp,32(sp)
ffffffffc02007fe:	f416                	sd	t0,40(sp)
ffffffffc0200800:	f81a                	sd	t1,48(sp)
ffffffffc0200802:	fc1e                	sd	t2,56(sp)
ffffffffc0200804:	e0a2                	sd	s0,64(sp)
ffffffffc0200806:	e4a6                	sd	s1,72(sp)
ffffffffc0200808:	e8aa                	sd	a0,80(sp)
ffffffffc020080a:	ecae                	sd	a1,88(sp)
ffffffffc020080c:	f0b2                	sd	a2,96(sp)
ffffffffc020080e:	f4b6                	sd	a3,104(sp)
ffffffffc0200810:	f8ba                	sd	a4,112(sp)
ffffffffc0200812:	fcbe                	sd	a5,120(sp)
ffffffffc0200814:	e142                	sd	a6,128(sp)
ffffffffc0200816:	e546                	sd	a7,136(sp)
ffffffffc0200818:	e94a                	sd	s2,144(sp)
ffffffffc020081a:	ed4e                	sd	s3,152(sp)
ffffffffc020081c:	f152                	sd	s4,160(sp)
ffffffffc020081e:	f556                	sd	s5,168(sp)
ffffffffc0200820:	f95a                	sd	s6,176(sp)
ffffffffc0200822:	fd5e                	sd	s7,184(sp)
ffffffffc0200824:	e1e2                	sd	s8,192(sp)
ffffffffc0200826:	e5e6                	sd	s9,200(sp)
ffffffffc0200828:	e9ea                	sd	s10,208(sp)
ffffffffc020082a:	edee                	sd	s11,216(sp)
ffffffffc020082c:	f1f2                	sd	t3,224(sp)
ffffffffc020082e:	f5f6                	sd	t4,232(sp)
ffffffffc0200830:	f9fa                	sd	t5,240(sp)
ffffffffc0200832:	fdfe                	sd	t6,248(sp)
ffffffffc0200834:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200838:	100024f3          	csrr	s1,sstatus
ffffffffc020083c:	14102973          	csrr	s2,sepc
ffffffffc0200840:	143029f3          	csrr	s3,stval
ffffffffc0200844:	14202a73          	csrr	s4,scause
ffffffffc0200848:	e822                	sd	s0,16(sp)
ffffffffc020084a:	e226                	sd	s1,256(sp)
ffffffffc020084c:	e64a                	sd	s2,264(sp)
ffffffffc020084e:	ea4e                	sd	s3,272(sp)
ffffffffc0200850:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200852:	850a                	mv	a0,sp
    jal trap
ffffffffc0200854:	f91ff0ef          	jal	ra,ffffffffc02007e4 <trap>

ffffffffc0200858 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200858:	6492                	ld	s1,256(sp)
ffffffffc020085a:	6932                	ld	s2,264(sp)
ffffffffc020085c:	10049073          	csrw	sstatus,s1
ffffffffc0200860:	14191073          	csrw	sepc,s2
ffffffffc0200864:	60a2                	ld	ra,8(sp)
ffffffffc0200866:	61e2                	ld	gp,24(sp)
ffffffffc0200868:	7202                	ld	tp,32(sp)
ffffffffc020086a:	72a2                	ld	t0,40(sp)
ffffffffc020086c:	7342                	ld	t1,48(sp)
ffffffffc020086e:	73e2                	ld	t2,56(sp)
ffffffffc0200870:	6406                	ld	s0,64(sp)
ffffffffc0200872:	64a6                	ld	s1,72(sp)
ffffffffc0200874:	6546                	ld	a0,80(sp)
ffffffffc0200876:	65e6                	ld	a1,88(sp)
ffffffffc0200878:	7606                	ld	a2,96(sp)
ffffffffc020087a:	76a6                	ld	a3,104(sp)
ffffffffc020087c:	7746                	ld	a4,112(sp)
ffffffffc020087e:	77e6                	ld	a5,120(sp)
ffffffffc0200880:	680a                	ld	a6,128(sp)
ffffffffc0200882:	68aa                	ld	a7,136(sp)
ffffffffc0200884:	694a                	ld	s2,144(sp)
ffffffffc0200886:	69ea                	ld	s3,152(sp)
ffffffffc0200888:	7a0a                	ld	s4,160(sp)
ffffffffc020088a:	7aaa                	ld	s5,168(sp)
ffffffffc020088c:	7b4a                	ld	s6,176(sp)
ffffffffc020088e:	7bea                	ld	s7,184(sp)
ffffffffc0200890:	6c0e                	ld	s8,192(sp)
ffffffffc0200892:	6cae                	ld	s9,200(sp)
ffffffffc0200894:	6d4e                	ld	s10,208(sp)
ffffffffc0200896:	6dee                	ld	s11,216(sp)
ffffffffc0200898:	7e0e                	ld	t3,224(sp)
ffffffffc020089a:	7eae                	ld	t4,232(sp)
ffffffffc020089c:	7f4e                	ld	t5,240(sp)
ffffffffc020089e:	7fee                	ld	t6,248(sp)
ffffffffc02008a0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02008a2:	10200073          	sret

ffffffffc02008a6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008a6:	100027f3          	csrr	a5,sstatus
ffffffffc02008aa:	8b89                	andi	a5,a5,2
ffffffffc02008ac:	e799                	bnez	a5,ffffffffc02008ba <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02008ae:	00006797          	auipc	a5,0x6
ffffffffc02008b2:	baa7b783          	ld	a5,-1110(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02008b6:	6f9c                	ld	a5,24(a5)
ffffffffc02008b8:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02008ba:	1141                	addi	sp,sp,-16
ffffffffc02008bc:	e406                	sd	ra,8(sp)
ffffffffc02008be:	e022                	sd	s0,0(sp)
ffffffffc02008c0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02008c2:	b9dff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02008c6:	00006797          	auipc	a5,0x6
ffffffffc02008ca:	b927b783          	ld	a5,-1134(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02008ce:	6f9c                	ld	a5,24(a5)
ffffffffc02008d0:	8522                	mv	a0,s0
ffffffffc02008d2:	9782                	jalr	a5
ffffffffc02008d4:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02008d6:	b83ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02008da:	60a2                	ld	ra,8(sp)
ffffffffc02008dc:	8522                	mv	a0,s0
ffffffffc02008de:	6402                	ld	s0,0(sp)
ffffffffc02008e0:	0141                	addi	sp,sp,16
ffffffffc02008e2:	8082                	ret

ffffffffc02008e4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008e4:	100027f3          	csrr	a5,sstatus
ffffffffc02008e8:	8b89                	andi	a5,a5,2
ffffffffc02008ea:	e799                	bnez	a5,ffffffffc02008f8 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02008ec:	00006797          	auipc	a5,0x6
ffffffffc02008f0:	b6c7b783          	ld	a5,-1172(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02008f4:	739c                	ld	a5,32(a5)
ffffffffc02008f6:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02008f8:	1101                	addi	sp,sp,-32
ffffffffc02008fa:	ec06                	sd	ra,24(sp)
ffffffffc02008fc:	e822                	sd	s0,16(sp)
ffffffffc02008fe:	e426                	sd	s1,8(sp)
ffffffffc0200900:	842a                	mv	s0,a0
ffffffffc0200902:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200904:	b5bff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200908:	00006797          	auipc	a5,0x6
ffffffffc020090c:	b507b783          	ld	a5,-1200(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200910:	739c                	ld	a5,32(a5)
ffffffffc0200912:	85a6                	mv	a1,s1
ffffffffc0200914:	8522                	mv	a0,s0
ffffffffc0200916:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200918:	6442                	ld	s0,16(sp)
ffffffffc020091a:	60e2                	ld	ra,24(sp)
ffffffffc020091c:	64a2                	ld	s1,8(sp)
ffffffffc020091e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200920:	be25                	j	ffffffffc0200458 <intr_enable>

ffffffffc0200922 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200922:	100027f3          	csrr	a5,sstatus
ffffffffc0200926:	8b89                	andi	a5,a5,2
ffffffffc0200928:	e799                	bnez	a5,ffffffffc0200936 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020092a:	00006797          	auipc	a5,0x6
ffffffffc020092e:	b2e7b783          	ld	a5,-1234(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200932:	779c                	ld	a5,40(a5)
ffffffffc0200934:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200936:	1141                	addi	sp,sp,-16
ffffffffc0200938:	e406                	sd	ra,8(sp)
ffffffffc020093a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020093c:	b23ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200940:	00006797          	auipc	a5,0x6
ffffffffc0200944:	b187b783          	ld	a5,-1256(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0200948:	779c                	ld	a5,40(a5)
ffffffffc020094a:	9782                	jalr	a5
ffffffffc020094c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020094e:	b0bff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200952:	60a2                	ld	ra,8(sp)
ffffffffc0200954:	8522                	mv	a0,s0
ffffffffc0200956:	6402                	ld	s0,0(sp)
ffffffffc0200958:	0141                	addi	sp,sp,16
ffffffffc020095a:	8082                	ret

ffffffffc020095c <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020095c:	00002797          	auipc	a5,0x2
ffffffffc0200960:	d6478793          	addi	a5,a5,-668 # ffffffffc02026c0 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200964:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200966:	1101                	addi	sp,sp,-32
ffffffffc0200968:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020096a:	00002517          	auipc	a0,0x2
ffffffffc020096e:	8e650513          	addi	a0,a0,-1818 # ffffffffc0202250 <commands+0x568>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200972:	00006497          	auipc	s1,0x6
ffffffffc0200976:	ae648493          	addi	s1,s1,-1306 # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc020097a:	ec06                	sd	ra,24(sp)
ffffffffc020097c:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020097e:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200980:	f32ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200984:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200986:	00006417          	auipc	s0,0x6
ffffffffc020098a:	aea40413          	addi	s0,s0,-1302 # ffffffffc0206470 <va_pa_offset>
    pmm_manager->init();
ffffffffc020098e:	679c                	ld	a5,8(a5)
ffffffffc0200990:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200992:	57f5                	li	a5,-3
ffffffffc0200994:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200996:	00002517          	auipc	a0,0x2
ffffffffc020099a:	8d250513          	addi	a0,a0,-1838 # ffffffffc0202268 <commands+0x580>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020099e:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02009a0:	f12ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02009a4:	46c5                	li	a3,17
ffffffffc02009a6:	06ee                	slli	a3,a3,0x1b
ffffffffc02009a8:	40100613          	li	a2,1025
ffffffffc02009ac:	16fd                	addi	a3,a3,-1
ffffffffc02009ae:	07e005b7          	lui	a1,0x7e00
ffffffffc02009b2:	0656                	slli	a2,a2,0x15
ffffffffc02009b4:	00002517          	auipc	a0,0x2
ffffffffc02009b8:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0202280 <commands+0x598>
ffffffffc02009bc:	ef6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009c0:	777d                	lui	a4,0xfffff
ffffffffc02009c2:	00007797          	auipc	a5,0x7
ffffffffc02009c6:	abd78793          	addi	a5,a5,-1347 # ffffffffc020747f <end+0xfff>
ffffffffc02009ca:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02009cc:	00006517          	auipc	a0,0x6
ffffffffc02009d0:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0206448 <npage>
ffffffffc02009d4:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009d8:	00006597          	auipc	a1,0x6
ffffffffc02009dc:	a7858593          	addi	a1,a1,-1416 # ffffffffc0206450 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02009e0:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009e2:	e19c                	sd	a5,0(a1)
ffffffffc02009e4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009e6:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009e8:	4885                	li	a7,1
ffffffffc02009ea:	fff80837          	lui	a6,0xfff80
ffffffffc02009ee:	a011                	j	ffffffffc02009f2 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02009f0:	619c                	ld	a5,0(a1)
ffffffffc02009f2:	97b6                	add	a5,a5,a3
ffffffffc02009f4:	07a1                	addi	a5,a5,8
ffffffffc02009f6:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009fa:	611c                	ld	a5,0(a0)
ffffffffc02009fc:	0705                	addi	a4,a4,1
ffffffffc02009fe:	02868693          	addi	a3,a3,40
ffffffffc0200a02:	01078633          	add	a2,a5,a6
ffffffffc0200a06:	fec765e3          	bltu	a4,a2,ffffffffc02009f0 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a0a:	6190                	ld	a2,0(a1)
ffffffffc0200a0c:	00279713          	slli	a4,a5,0x2
ffffffffc0200a10:	973e                	add	a4,a4,a5
ffffffffc0200a12:	fec006b7          	lui	a3,0xfec00
ffffffffc0200a16:	070e                	slli	a4,a4,0x3
ffffffffc0200a18:	96b2                	add	a3,a3,a2
ffffffffc0200a1a:	96ba                	add	a3,a3,a4
ffffffffc0200a1c:	c0200737          	lui	a4,0xc0200
ffffffffc0200a20:	08e6ef63          	bltu	a3,a4,ffffffffc0200abe <pmm_init+0x162>
ffffffffc0200a24:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200a26:	45c5                	li	a1,17
ffffffffc0200a28:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a2a:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200a2c:	04b6e863          	bltu	a3,a1,ffffffffc0200a7c <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200a30:	609c                	ld	a5,0(s1)
ffffffffc0200a32:	7b9c                	ld	a5,48(a5)
ffffffffc0200a34:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200a36:	00002517          	auipc	a0,0x2
ffffffffc0200a3a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0202318 <commands+0x630>
ffffffffc0200a3e:	e74ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200a42:	00004597          	auipc	a1,0x4
ffffffffc0200a46:	5be58593          	addi	a1,a1,1470 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200a4a:	00006797          	auipc	a5,0x6
ffffffffc0200a4e:	a0b7bf23          	sd	a1,-1506(a5) # ffffffffc0206468 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a52:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a56:	08f5e063          	bltu	a1,a5,ffffffffc0200ad6 <pmm_init+0x17a>
ffffffffc0200a5a:	6010                	ld	a2,0(s0)
}
ffffffffc0200a5c:	6442                	ld	s0,16(sp)
ffffffffc0200a5e:	60e2                	ld	ra,24(sp)
ffffffffc0200a60:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a62:	40c58633          	sub	a2,a1,a2
ffffffffc0200a66:	00006797          	auipc	a5,0x6
ffffffffc0200a6a:	9ec7bd23          	sd	a2,-1542(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a6e:	00002517          	auipc	a0,0x2
ffffffffc0200a72:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0202338 <commands+0x650>
}
ffffffffc0200a76:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a78:	e3aff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200a7c:	6705                	lui	a4,0x1
ffffffffc0200a7e:	177d                	addi	a4,a4,-1
ffffffffc0200a80:	96ba                	add	a3,a3,a4
ffffffffc0200a82:	777d                	lui	a4,0xfffff
ffffffffc0200a84:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200a86:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200a8a:	00f57e63          	bgeu	a0,a5,ffffffffc0200aa6 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a8e:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a90:	982a                	add	a6,a6,a0
ffffffffc0200a92:	00281513          	slli	a0,a6,0x2
ffffffffc0200a96:	9542                	add	a0,a0,a6
ffffffffc0200a98:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a9a:	8d95                	sub	a1,a1,a3
ffffffffc0200a9c:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a9e:	81b1                	srli	a1,a1,0xc
ffffffffc0200aa0:	9532                	add	a0,a0,a2
ffffffffc0200aa2:	9782                	jalr	a5
}
ffffffffc0200aa4:	b771                	j	ffffffffc0200a30 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200aa6:	00002617          	auipc	a2,0x2
ffffffffc0200aaa:	84260613          	addi	a2,a2,-1982 # ffffffffc02022e8 <commands+0x600>
ffffffffc0200aae:	06b00593          	li	a1,107
ffffffffc0200ab2:	00002517          	auipc	a0,0x2
ffffffffc0200ab6:	85650513          	addi	a0,a0,-1962 # ffffffffc0202308 <commands+0x620>
ffffffffc0200aba:	e80ff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200abe:	00001617          	auipc	a2,0x1
ffffffffc0200ac2:	7f260613          	addi	a2,a2,2034 # ffffffffc02022b0 <commands+0x5c8>
ffffffffc0200ac6:	07000593          	li	a1,112
ffffffffc0200aca:	00002517          	auipc	a0,0x2
ffffffffc0200ace:	80e50513          	addi	a0,a0,-2034 # ffffffffc02022d8 <commands+0x5f0>
ffffffffc0200ad2:	e68ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ad6:	86ae                	mv	a3,a1
ffffffffc0200ad8:	00001617          	auipc	a2,0x1
ffffffffc0200adc:	7d860613          	addi	a2,a2,2008 # ffffffffc02022b0 <commands+0x5c8>
ffffffffc0200ae0:	08b00593          	li	a1,139
ffffffffc0200ae4:	00001517          	auipc	a0,0x1
ffffffffc0200ae8:	7f450513          	addi	a0,a0,2036 # ffffffffc02022d8 <commands+0x5f0>
ffffffffc0200aec:	e4eff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200af0 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200af0:	00005797          	auipc	a5,0x5
ffffffffc0200af4:	52878793          	addi	a5,a5,1320 # ffffffffc0206018 <free_area>
ffffffffc0200af8:	e79c                	sd	a5,8(a5)
ffffffffc0200afa:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200afc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b00:	8082                	ret

ffffffffc0200b02 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b02:	00005517          	auipc	a0,0x5
ffffffffc0200b06:	52656503          	lwu	a0,1318(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200b0a:	8082                	ret

ffffffffc0200b0c <best_fit_alloc_pages>:
    assert(n > 0); // 确保请求的页面数量大于0
ffffffffc0200b0c:	c14d                	beqz	a0,ffffffffc0200bae <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200b0e:	00005617          	auipc	a2,0x5
ffffffffc0200b12:	50a60613          	addi	a2,a2,1290 # ffffffffc0206018 <free_area>
ffffffffc0200b16:	01062803          	lw	a6,16(a2)
ffffffffc0200b1a:	86aa                	mv	a3,a0
ffffffffc0200b1c:	02081793          	slli	a5,a6,0x20
ffffffffc0200b20:	9381                	srli	a5,a5,0x20
ffffffffc0200b22:	08a7e463          	bltu	a5,a0,ffffffffc0200baa <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b26:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1; // 初始化最小连续空闲页框的数量
ffffffffc0200b28:	0018059b          	addiw	a1,a6,1
ffffffffc0200b2c:	1582                	slli	a1,a1,0x20
ffffffffc0200b2e:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL; // 用于存放找到的页面
ffffffffc0200b30:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b32:	06c78b63          	beq	a5,a2,ffffffffc0200ba8 <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) {
ffffffffc0200b36:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200b3a:	00d76763          	bltu	a4,a3,ffffffffc0200b48 <best_fit_alloc_pages+0x3c>
ffffffffc0200b3e:	00b77563          	bgeu	a4,a1,ffffffffc0200b48 <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200b42:	fe878513          	addi	a0,a5,-24
ffffffffc0200b46:	85ba                	mv	a1,a4
ffffffffc0200b48:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4a:	fec796e3          	bne	a5,a2,ffffffffc0200b36 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200b4e:	cd29                	beqz	a0,ffffffffc0200ba8 <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b50:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200b52:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200b54:	490c                	lw	a1,16(a0)
            p->property = page->property - n;  // 设置剩余页面的属性
ffffffffc0200b56:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b5a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b5c:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200b5e:	02059793          	slli	a5,a1,0x20
ffffffffc0200b62:	9381                	srli	a5,a5,0x20
ffffffffc0200b64:	02f6f863          	bgeu	a3,a5,ffffffffc0200b94 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;  // 获取剩余页面的起始地址
ffffffffc0200b68:	00269793          	slli	a5,a3,0x2
ffffffffc0200b6c:	97b6                	add	a5,a5,a3
ffffffffc0200b6e:	078e                	slli	a5,a5,0x3
ffffffffc0200b70:	97aa                	add	a5,a5,a0
            p->property = page->property - n;  // 设置剩余页面的属性
ffffffffc0200b72:	411585bb          	subw	a1,a1,a7
ffffffffc0200b76:	cb8c                	sw	a1,16(a5)
ffffffffc0200b78:	4689                	li	a3,2
ffffffffc0200b7a:	00878593          	addi	a1,a5,8
ffffffffc0200b7e:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b82:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));  // 将剩余页面插入链表
ffffffffc0200b84:	01878593          	addi	a1,a5,24
        nr_free -= n;  // 更新总的空闲页面数量
ffffffffc0200b88:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200b8c:	e28c                	sd	a1,0(a3)
ffffffffc0200b8e:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200b90:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200b92:	ef98                	sd	a4,24(a5)
ffffffffc0200b94:	4118083b          	subw	a6,a6,a7
ffffffffc0200b98:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b9c:	57f5                	li	a5,-3
ffffffffc0200b9e:	00850713          	addi	a4,a0,8
ffffffffc0200ba2:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200ba6:	8082                	ret
}
ffffffffc0200ba8:	8082                	ret
        return NULL; // 如果请求的页面数量超过可用页面，返回NULL
ffffffffc0200baa:	4501                	li	a0,0
ffffffffc0200bac:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200bae:	1141                	addi	sp,sp,-16
    assert(n > 0); // 确保请求的页面数量大于0
ffffffffc0200bb0:	00001697          	auipc	a3,0x1
ffffffffc0200bb4:	7c868693          	addi	a3,a3,1992 # ffffffffc0202378 <commands+0x690>
ffffffffc0200bb8:	00001617          	auipc	a2,0x1
ffffffffc0200bbc:	7c860613          	addi	a2,a2,1992 # ffffffffc0202380 <commands+0x698>
ffffffffc0200bc0:	06e00593          	li	a1,110
ffffffffc0200bc4:	00001517          	auipc	a0,0x1
ffffffffc0200bc8:	7d450513          	addi	a0,a0,2004 # ffffffffc0202398 <commands+0x6b0>
best_fit_alloc_pages(size_t n) {
ffffffffc0200bcc:	e406                	sd	ra,8(sp)
    assert(n > 0); // 确保请求的页面数量大于0
ffffffffc0200bce:	d6cff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200bd2 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200bd2:	715d                	addi	sp,sp,-80
ffffffffc0200bd4:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200bd6:	00005417          	auipc	s0,0x5
ffffffffc0200bda:	44240413          	addi	s0,s0,1090 # ffffffffc0206018 <free_area>
ffffffffc0200bde:	641c                	ld	a5,8(s0)
ffffffffc0200be0:	e486                	sd	ra,72(sp)
ffffffffc0200be2:	fc26                	sd	s1,56(sp)
ffffffffc0200be4:	f84a                	sd	s2,48(sp)
ffffffffc0200be6:	f44e                	sd	s3,40(sp)
ffffffffc0200be8:	f052                	sd	s4,32(sp)
ffffffffc0200bea:	ec56                	sd	s5,24(sp)
ffffffffc0200bec:	e85a                	sd	s6,16(sp)
ffffffffc0200bee:	e45e                	sd	s7,8(sp)
ffffffffc0200bf0:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bf2:	26878b63          	beq	a5,s0,ffffffffc0200e68 <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200bf6:	4481                	li	s1,0
ffffffffc0200bf8:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bfa:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bfe:	8b09                	andi	a4,a4,2
ffffffffc0200c00:	26070863          	beqz	a4,ffffffffc0200e70 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200c04:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c08:	679c                	ld	a5,8(a5)
ffffffffc0200c0a:	2905                	addiw	s2,s2,1
ffffffffc0200c0c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c0e:	fe8796e3          	bne	a5,s0,ffffffffc0200bfa <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200c12:	89a6                	mv	s3,s1
ffffffffc0200c14:	d0fff0ef          	jal	ra,ffffffffc0200922 <nr_free_pages>
ffffffffc0200c18:	33351c63          	bne	a0,s3,ffffffffc0200f50 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c1c:	4505                	li	a0,1
ffffffffc0200c1e:	c89ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200c22:	8a2a                	mv	s4,a0
ffffffffc0200c24:	36050663          	beqz	a0,ffffffffc0200f90 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c28:	4505                	li	a0,1
ffffffffc0200c2a:	c7dff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200c2e:	89aa                	mv	s3,a0
ffffffffc0200c30:	34050063          	beqz	a0,ffffffffc0200f70 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c34:	4505                	li	a0,1
ffffffffc0200c36:	c71ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200c3a:	8aaa                	mv	s5,a0
ffffffffc0200c3c:	2c050a63          	beqz	a0,ffffffffc0200f10 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c40:	253a0863          	beq	s4,s3,ffffffffc0200e90 <best_fit_check+0x2be>
ffffffffc0200c44:	24aa0663          	beq	s4,a0,ffffffffc0200e90 <best_fit_check+0x2be>
ffffffffc0200c48:	24a98463          	beq	s3,a0,ffffffffc0200e90 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c4c:	000a2783          	lw	a5,0(s4)
ffffffffc0200c50:	26079063          	bnez	a5,ffffffffc0200eb0 <best_fit_check+0x2de>
ffffffffc0200c54:	0009a783          	lw	a5,0(s3)
ffffffffc0200c58:	24079c63          	bnez	a5,ffffffffc0200eb0 <best_fit_check+0x2de>
ffffffffc0200c5c:	411c                	lw	a5,0(a0)
ffffffffc0200c5e:	24079963          	bnez	a5,ffffffffc0200eb0 <best_fit_check+0x2de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c62:	00005797          	auipc	a5,0x5
ffffffffc0200c66:	7ee7b783          	ld	a5,2030(a5) # ffffffffc0206450 <pages>
ffffffffc0200c6a:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c6e:	870d                	srai	a4,a4,0x3
ffffffffc0200c70:	00002597          	auipc	a1,0x2
ffffffffc0200c74:	cd85b583          	ld	a1,-808(a1) # ffffffffc0202948 <nbase+0x8>
ffffffffc0200c78:	02b70733          	mul	a4,a4,a1
ffffffffc0200c7c:	00002617          	auipc	a2,0x2
ffffffffc0200c80:	cc463603          	ld	a2,-828(a2) # ffffffffc0202940 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c84:	00005697          	auipc	a3,0x5
ffffffffc0200c88:	7c46b683          	ld	a3,1988(a3) # ffffffffc0206448 <npage>
ffffffffc0200c8c:	06b2                	slli	a3,a3,0xc
ffffffffc0200c8e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c90:	0732                	slli	a4,a4,0xc
ffffffffc0200c92:	22d77f63          	bgeu	a4,a3,ffffffffc0200ed0 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c96:	40f98733          	sub	a4,s3,a5
ffffffffc0200c9a:	870d                	srai	a4,a4,0x3
ffffffffc0200c9c:	02b70733          	mul	a4,a4,a1
ffffffffc0200ca0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ca2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ca4:	3ed77663          	bgeu	a4,a3,ffffffffc0201090 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ca8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200cac:	878d                	srai	a5,a5,0x3
ffffffffc0200cae:	02b787b3          	mul	a5,a5,a1
ffffffffc0200cb2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cb4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cb6:	3ad7fd63          	bgeu	a5,a3,ffffffffc0201070 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200cba:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cbc:	00043c03          	ld	s8,0(s0)
ffffffffc0200cc0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200cc4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200cc8:	e400                	sd	s0,8(s0)
ffffffffc0200cca:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200ccc:	00005797          	auipc	a5,0x5
ffffffffc0200cd0:	3407ae23          	sw	zero,860(a5) # ffffffffc0206028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cd4:	bd3ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200cd8:	36051c63          	bnez	a0,ffffffffc0201050 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200cdc:	4585                	li	a1,1
ffffffffc0200cde:	8552                	mv	a0,s4
ffffffffc0200ce0:	c05ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    free_page(p1);
ffffffffc0200ce4:	4585                	li	a1,1
ffffffffc0200ce6:	854e                	mv	a0,s3
ffffffffc0200ce8:	bfdff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    free_page(p2);
ffffffffc0200cec:	4585                	li	a1,1
ffffffffc0200cee:	8556                	mv	a0,s5
ffffffffc0200cf0:	bf5ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    assert(nr_free == 3);
ffffffffc0200cf4:	4818                	lw	a4,16(s0)
ffffffffc0200cf6:	478d                	li	a5,3
ffffffffc0200cf8:	32f71c63          	bne	a4,a5,ffffffffc0201030 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cfc:	4505                	li	a0,1
ffffffffc0200cfe:	ba9ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d02:	89aa                	mv	s3,a0
ffffffffc0200d04:	30050663          	beqz	a0,ffffffffc0201010 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d08:	4505                	li	a0,1
ffffffffc0200d0a:	b9dff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d0e:	8aaa                	mv	s5,a0
ffffffffc0200d10:	2e050063          	beqz	a0,ffffffffc0200ff0 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d14:	4505                	li	a0,1
ffffffffc0200d16:	b91ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d1a:	8a2a                	mv	s4,a0
ffffffffc0200d1c:	2a050a63          	beqz	a0,ffffffffc0200fd0 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200d20:	4505                	li	a0,1
ffffffffc0200d22:	b85ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d26:	28051563          	bnez	a0,ffffffffc0200fb0 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200d2a:	4585                	li	a1,1
ffffffffc0200d2c:	854e                	mv	a0,s3
ffffffffc0200d2e:	bb7ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d32:	641c                	ld	a5,8(s0)
ffffffffc0200d34:	1a878e63          	beq	a5,s0,ffffffffc0200ef0 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200d38:	4505                	li	a0,1
ffffffffc0200d3a:	b6dff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d3e:	52a99963          	bne	s3,a0,ffffffffc0201270 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200d42:	4505                	li	a0,1
ffffffffc0200d44:	b63ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d48:	50051463          	bnez	a0,ffffffffc0201250 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200d4c:	481c                	lw	a5,16(s0)
ffffffffc0200d4e:	4e079163          	bnez	a5,ffffffffc0201230 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200d52:	854e                	mv	a0,s3
ffffffffc0200d54:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d56:	01843023          	sd	s8,0(s0)
ffffffffc0200d5a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200d5e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200d62:	b83ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    free_page(p1);
ffffffffc0200d66:	4585                	li	a1,1
ffffffffc0200d68:	8556                	mv	a0,s5
ffffffffc0200d6a:	b7bff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    free_page(p2);
ffffffffc0200d6e:	4585                	li	a1,1
ffffffffc0200d70:	8552                	mv	a0,s4
ffffffffc0200d72:	b73ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d76:	4515                	li	a0,5
ffffffffc0200d78:	b2fff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d7c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d7e:	48050963          	beqz	a0,ffffffffc0201210 <best_fit_check+0x63e>
ffffffffc0200d82:	651c                	ld	a5,8(a0)
ffffffffc0200d84:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d86:	8b85                	andi	a5,a5,1
ffffffffc0200d88:	46079463          	bnez	a5,ffffffffc02011f0 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d8c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d8e:	00043a83          	ld	s5,0(s0)
ffffffffc0200d92:	00843a03          	ld	s4,8(s0)
ffffffffc0200d96:	e000                	sd	s0,0(s0)
ffffffffc0200d98:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200d9a:	b0dff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200d9e:	42051963          	bnez	a0,ffffffffc02011d0 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200da2:	4589                	li	a1,2
ffffffffc0200da4:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200da8:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200dac:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200db0:	00005797          	auipc	a5,0x5
ffffffffc0200db4:	2607ac23          	sw	zero,632(a5) # ffffffffc0206028 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200db8:	b2dff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200dbc:	8562                	mv	a0,s8
ffffffffc0200dbe:	4585                	li	a1,1
ffffffffc0200dc0:	b25ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dc4:	4511                	li	a0,4
ffffffffc0200dc6:	ae1ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200dca:	3e051363          	bnez	a0,ffffffffc02011b0 <best_fit_check+0x5de>
ffffffffc0200dce:	0309b783          	ld	a5,48(s3)
ffffffffc0200dd2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200dd4:	8b85                	andi	a5,a5,1
ffffffffc0200dd6:	3a078d63          	beqz	a5,ffffffffc0201190 <best_fit_check+0x5be>
ffffffffc0200dda:	0389a703          	lw	a4,56(s3)
ffffffffc0200dde:	4789                	li	a5,2
ffffffffc0200de0:	3af71863          	bne	a4,a5,ffffffffc0201190 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200de4:	4505                	li	a0,1
ffffffffc0200de6:	ac1ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200dea:	8baa                	mv	s7,a0
ffffffffc0200dec:	38050263          	beqz	a0,ffffffffc0201170 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200df0:	4509                	li	a0,2
ffffffffc0200df2:	ab5ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200df6:	34050d63          	beqz	a0,ffffffffc0201150 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200dfa:	337c1b63          	bne	s8,s7,ffffffffc0201130 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200dfe:	854e                	mv	a0,s3
ffffffffc0200e00:	4595                	li	a1,5
ffffffffc0200e02:	ae3ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e06:	4515                	li	a0,5
ffffffffc0200e08:	a9fff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200e0c:	89aa                	mv	s3,a0
ffffffffc0200e0e:	30050163          	beqz	a0,ffffffffc0201110 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200e12:	4505                	li	a0,1
ffffffffc0200e14:	a93ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200e18:	2c051c63          	bnez	a0,ffffffffc02010f0 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200e1c:	481c                	lw	a5,16(s0)
ffffffffc0200e1e:	2a079963          	bnez	a5,ffffffffc02010d0 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e22:	4595                	li	a1,5
ffffffffc0200e24:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e26:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200e2a:	01543023          	sd	s5,0(s0)
ffffffffc0200e2e:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200e32:	ab3ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    return listelm->next;
ffffffffc0200e36:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e38:	00878963          	beq	a5,s0,ffffffffc0200e4a <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e3c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e40:	679c                	ld	a5,8(a5)
ffffffffc0200e42:	397d                	addiw	s2,s2,-1
ffffffffc0200e44:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e46:	fe879be3          	bne	a5,s0,ffffffffc0200e3c <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200e4a:	26091363          	bnez	s2,ffffffffc02010b0 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200e4e:	e0ed                	bnez	s1,ffffffffc0200f30 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200e50:	60a6                	ld	ra,72(sp)
ffffffffc0200e52:	6406                	ld	s0,64(sp)
ffffffffc0200e54:	74e2                	ld	s1,56(sp)
ffffffffc0200e56:	7942                	ld	s2,48(sp)
ffffffffc0200e58:	79a2                	ld	s3,40(sp)
ffffffffc0200e5a:	7a02                	ld	s4,32(sp)
ffffffffc0200e5c:	6ae2                	ld	s5,24(sp)
ffffffffc0200e5e:	6b42                	ld	s6,16(sp)
ffffffffc0200e60:	6ba2                	ld	s7,8(sp)
ffffffffc0200e62:	6c02                	ld	s8,0(sp)
ffffffffc0200e64:	6161                	addi	sp,sp,80
ffffffffc0200e66:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e68:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e6a:	4481                	li	s1,0
ffffffffc0200e6c:	4901                	li	s2,0
ffffffffc0200e6e:	b35d                	j	ffffffffc0200c14 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e70:	00001697          	auipc	a3,0x1
ffffffffc0200e74:	54068693          	addi	a3,a3,1344 # ffffffffc02023b0 <commands+0x6c8>
ffffffffc0200e78:	00001617          	auipc	a2,0x1
ffffffffc0200e7c:	50860613          	addi	a2,a2,1288 # ffffffffc0202380 <commands+0x698>
ffffffffc0200e80:	12400593          	li	a1,292
ffffffffc0200e84:	00001517          	auipc	a0,0x1
ffffffffc0200e88:	51450513          	addi	a0,a0,1300 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200e8c:	aaeff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e90:	00001697          	auipc	a3,0x1
ffffffffc0200e94:	5b068693          	addi	a3,a3,1456 # ffffffffc0202440 <commands+0x758>
ffffffffc0200e98:	00001617          	auipc	a2,0x1
ffffffffc0200e9c:	4e860613          	addi	a2,a2,1256 # ffffffffc0202380 <commands+0x698>
ffffffffc0200ea0:	0f000593          	li	a1,240
ffffffffc0200ea4:	00001517          	auipc	a0,0x1
ffffffffc0200ea8:	4f450513          	addi	a0,a0,1268 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200eac:	a8eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb0:	00001697          	auipc	a3,0x1
ffffffffc0200eb4:	5b868693          	addi	a3,a3,1464 # ffffffffc0202468 <commands+0x780>
ffffffffc0200eb8:	00001617          	auipc	a2,0x1
ffffffffc0200ebc:	4c860613          	addi	a2,a2,1224 # ffffffffc0202380 <commands+0x698>
ffffffffc0200ec0:	0f100593          	li	a1,241
ffffffffc0200ec4:	00001517          	auipc	a0,0x1
ffffffffc0200ec8:	4d450513          	addi	a0,a0,1236 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200ecc:	a6eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ed0:	00001697          	auipc	a3,0x1
ffffffffc0200ed4:	5d868693          	addi	a3,a3,1496 # ffffffffc02024a8 <commands+0x7c0>
ffffffffc0200ed8:	00001617          	auipc	a2,0x1
ffffffffc0200edc:	4a860613          	addi	a2,a2,1192 # ffffffffc0202380 <commands+0x698>
ffffffffc0200ee0:	0f300593          	li	a1,243
ffffffffc0200ee4:	00001517          	auipc	a0,0x1
ffffffffc0200ee8:	4b450513          	addi	a0,a0,1204 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200eec:	a4eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ef0:	00001697          	auipc	a3,0x1
ffffffffc0200ef4:	64068693          	addi	a3,a3,1600 # ffffffffc0202530 <commands+0x848>
ffffffffc0200ef8:	00001617          	auipc	a2,0x1
ffffffffc0200efc:	48860613          	addi	a2,a2,1160 # ffffffffc0202380 <commands+0x698>
ffffffffc0200f00:	10c00593          	li	a1,268
ffffffffc0200f04:	00001517          	auipc	a0,0x1
ffffffffc0200f08:	49450513          	addi	a0,a0,1172 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200f0c:	a2eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f10:	00001697          	auipc	a3,0x1
ffffffffc0200f14:	51068693          	addi	a3,a3,1296 # ffffffffc0202420 <commands+0x738>
ffffffffc0200f18:	00001617          	auipc	a2,0x1
ffffffffc0200f1c:	46860613          	addi	a2,a2,1128 # ffffffffc0202380 <commands+0x698>
ffffffffc0200f20:	0ee00593          	li	a1,238
ffffffffc0200f24:	00001517          	auipc	a0,0x1
ffffffffc0200f28:	47450513          	addi	a0,a0,1140 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200f2c:	a0eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(total == 0);
ffffffffc0200f30:	00001697          	auipc	a3,0x1
ffffffffc0200f34:	73068693          	addi	a3,a3,1840 # ffffffffc0202660 <commands+0x978>
ffffffffc0200f38:	00001617          	auipc	a2,0x1
ffffffffc0200f3c:	44860613          	addi	a2,a2,1096 # ffffffffc0202380 <commands+0x698>
ffffffffc0200f40:	16600593          	li	a1,358
ffffffffc0200f44:	00001517          	auipc	a0,0x1
ffffffffc0200f48:	45450513          	addi	a0,a0,1108 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200f4c:	9eeff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(total == nr_free_pages());
ffffffffc0200f50:	00001697          	auipc	a3,0x1
ffffffffc0200f54:	47068693          	addi	a3,a3,1136 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200f58:	00001617          	auipc	a2,0x1
ffffffffc0200f5c:	42860613          	addi	a2,a2,1064 # ffffffffc0202380 <commands+0x698>
ffffffffc0200f60:	12700593          	li	a1,295
ffffffffc0200f64:	00001517          	auipc	a0,0x1
ffffffffc0200f68:	43450513          	addi	a0,a0,1076 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200f6c:	9ceff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f70:	00001697          	auipc	a3,0x1
ffffffffc0200f74:	49068693          	addi	a3,a3,1168 # ffffffffc0202400 <commands+0x718>
ffffffffc0200f78:	00001617          	auipc	a2,0x1
ffffffffc0200f7c:	40860613          	addi	a2,a2,1032 # ffffffffc0202380 <commands+0x698>
ffffffffc0200f80:	0ed00593          	li	a1,237
ffffffffc0200f84:	00001517          	auipc	a0,0x1
ffffffffc0200f88:	41450513          	addi	a0,a0,1044 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200f8c:	9aeff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f90:	00001697          	auipc	a3,0x1
ffffffffc0200f94:	45068693          	addi	a3,a3,1104 # ffffffffc02023e0 <commands+0x6f8>
ffffffffc0200f98:	00001617          	auipc	a2,0x1
ffffffffc0200f9c:	3e860613          	addi	a2,a2,1000 # ffffffffc0202380 <commands+0x698>
ffffffffc0200fa0:	0ec00593          	li	a1,236
ffffffffc0200fa4:	00001517          	auipc	a0,0x1
ffffffffc0200fa8:	3f450513          	addi	a0,a0,1012 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200fac:	98eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb0:	00001697          	auipc	a3,0x1
ffffffffc0200fb4:	55868693          	addi	a3,a3,1368 # ffffffffc0202508 <commands+0x820>
ffffffffc0200fb8:	00001617          	auipc	a2,0x1
ffffffffc0200fbc:	3c860613          	addi	a2,a2,968 # ffffffffc0202380 <commands+0x698>
ffffffffc0200fc0:	10900593          	li	a1,265
ffffffffc0200fc4:	00001517          	auipc	a0,0x1
ffffffffc0200fc8:	3d450513          	addi	a0,a0,980 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200fcc:	96eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd0:	00001697          	auipc	a3,0x1
ffffffffc0200fd4:	45068693          	addi	a3,a3,1104 # ffffffffc0202420 <commands+0x738>
ffffffffc0200fd8:	00001617          	auipc	a2,0x1
ffffffffc0200fdc:	3a860613          	addi	a2,a2,936 # ffffffffc0202380 <commands+0x698>
ffffffffc0200fe0:	10700593          	li	a1,263
ffffffffc0200fe4:	00001517          	auipc	a0,0x1
ffffffffc0200fe8:	3b450513          	addi	a0,a0,948 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0200fec:	94eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ff0:	00001697          	auipc	a3,0x1
ffffffffc0200ff4:	41068693          	addi	a3,a3,1040 # ffffffffc0202400 <commands+0x718>
ffffffffc0200ff8:	00001617          	auipc	a2,0x1
ffffffffc0200ffc:	38860613          	addi	a2,a2,904 # ffffffffc0202380 <commands+0x698>
ffffffffc0201000:	10600593          	li	a1,262
ffffffffc0201004:	00001517          	auipc	a0,0x1
ffffffffc0201008:	39450513          	addi	a0,a0,916 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020100c:	92eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201010:	00001697          	auipc	a3,0x1
ffffffffc0201014:	3d068693          	addi	a3,a3,976 # ffffffffc02023e0 <commands+0x6f8>
ffffffffc0201018:	00001617          	auipc	a2,0x1
ffffffffc020101c:	36860613          	addi	a2,a2,872 # ffffffffc0202380 <commands+0x698>
ffffffffc0201020:	10500593          	li	a1,261
ffffffffc0201024:	00001517          	auipc	a0,0x1
ffffffffc0201028:	37450513          	addi	a0,a0,884 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020102c:	90eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 3);
ffffffffc0201030:	00001697          	auipc	a3,0x1
ffffffffc0201034:	4f068693          	addi	a3,a3,1264 # ffffffffc0202520 <commands+0x838>
ffffffffc0201038:	00001617          	auipc	a2,0x1
ffffffffc020103c:	34860613          	addi	a2,a2,840 # ffffffffc0202380 <commands+0x698>
ffffffffc0201040:	10300593          	li	a1,259
ffffffffc0201044:	00001517          	auipc	a0,0x1
ffffffffc0201048:	35450513          	addi	a0,a0,852 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020104c:	8eeff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201050:	00001697          	auipc	a3,0x1
ffffffffc0201054:	4b868693          	addi	a3,a3,1208 # ffffffffc0202508 <commands+0x820>
ffffffffc0201058:	00001617          	auipc	a2,0x1
ffffffffc020105c:	32860613          	addi	a2,a2,808 # ffffffffc0202380 <commands+0x698>
ffffffffc0201060:	0fe00593          	li	a1,254
ffffffffc0201064:	00001517          	auipc	a0,0x1
ffffffffc0201068:	33450513          	addi	a0,a0,820 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020106c:	8ceff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201070:	00001697          	auipc	a3,0x1
ffffffffc0201074:	47868693          	addi	a3,a3,1144 # ffffffffc02024e8 <commands+0x800>
ffffffffc0201078:	00001617          	auipc	a2,0x1
ffffffffc020107c:	30860613          	addi	a2,a2,776 # ffffffffc0202380 <commands+0x698>
ffffffffc0201080:	0f500593          	li	a1,245
ffffffffc0201084:	00001517          	auipc	a0,0x1
ffffffffc0201088:	31450513          	addi	a0,a0,788 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020108c:	8aeff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201090:	00001697          	auipc	a3,0x1
ffffffffc0201094:	43868693          	addi	a3,a3,1080 # ffffffffc02024c8 <commands+0x7e0>
ffffffffc0201098:	00001617          	auipc	a2,0x1
ffffffffc020109c:	2e860613          	addi	a2,a2,744 # ffffffffc0202380 <commands+0x698>
ffffffffc02010a0:	0f400593          	li	a1,244
ffffffffc02010a4:	00001517          	auipc	a0,0x1
ffffffffc02010a8:	2f450513          	addi	a0,a0,756 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02010ac:	88eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(count == 0);
ffffffffc02010b0:	00001697          	auipc	a3,0x1
ffffffffc02010b4:	5a068693          	addi	a3,a3,1440 # ffffffffc0202650 <commands+0x968>
ffffffffc02010b8:	00001617          	auipc	a2,0x1
ffffffffc02010bc:	2c860613          	addi	a2,a2,712 # ffffffffc0202380 <commands+0x698>
ffffffffc02010c0:	16500593          	li	a1,357
ffffffffc02010c4:	00001517          	auipc	a0,0x1
ffffffffc02010c8:	2d450513          	addi	a0,a0,724 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02010cc:	86eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 0);
ffffffffc02010d0:	00001697          	auipc	a3,0x1
ffffffffc02010d4:	49868693          	addi	a3,a3,1176 # ffffffffc0202568 <commands+0x880>
ffffffffc02010d8:	00001617          	auipc	a2,0x1
ffffffffc02010dc:	2a860613          	addi	a2,a2,680 # ffffffffc0202380 <commands+0x698>
ffffffffc02010e0:	15a00593          	li	a1,346
ffffffffc02010e4:	00001517          	auipc	a0,0x1
ffffffffc02010e8:	2b450513          	addi	a0,a0,692 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02010ec:	84eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010f0:	00001697          	auipc	a3,0x1
ffffffffc02010f4:	41868693          	addi	a3,a3,1048 # ffffffffc0202508 <commands+0x820>
ffffffffc02010f8:	00001617          	auipc	a2,0x1
ffffffffc02010fc:	28860613          	addi	a2,a2,648 # ffffffffc0202380 <commands+0x698>
ffffffffc0201100:	15400593          	li	a1,340
ffffffffc0201104:	00001517          	auipc	a0,0x1
ffffffffc0201108:	29450513          	addi	a0,a0,660 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020110c:	82eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201110:	00001697          	auipc	a3,0x1
ffffffffc0201114:	52068693          	addi	a3,a3,1312 # ffffffffc0202630 <commands+0x948>
ffffffffc0201118:	00001617          	auipc	a2,0x1
ffffffffc020111c:	26860613          	addi	a2,a2,616 # ffffffffc0202380 <commands+0x698>
ffffffffc0201120:	15300593          	li	a1,339
ffffffffc0201124:	00001517          	auipc	a0,0x1
ffffffffc0201128:	27450513          	addi	a0,a0,628 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020112c:	80eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 + 4 == p1);
ffffffffc0201130:	00001697          	auipc	a3,0x1
ffffffffc0201134:	4f068693          	addi	a3,a3,1264 # ffffffffc0202620 <commands+0x938>
ffffffffc0201138:	00001617          	auipc	a2,0x1
ffffffffc020113c:	24860613          	addi	a2,a2,584 # ffffffffc0202380 <commands+0x698>
ffffffffc0201140:	14b00593          	li	a1,331
ffffffffc0201144:	00001517          	auipc	a0,0x1
ffffffffc0201148:	25450513          	addi	a0,a0,596 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020114c:	feffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201150:	00001697          	auipc	a3,0x1
ffffffffc0201154:	4b868693          	addi	a3,a3,1208 # ffffffffc0202608 <commands+0x920>
ffffffffc0201158:	00001617          	auipc	a2,0x1
ffffffffc020115c:	22860613          	addi	a2,a2,552 # ffffffffc0202380 <commands+0x698>
ffffffffc0201160:	14a00593          	li	a1,330
ffffffffc0201164:	00001517          	auipc	a0,0x1
ffffffffc0201168:	23450513          	addi	a0,a0,564 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020116c:	fcffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201170:	00001697          	auipc	a3,0x1
ffffffffc0201174:	47868693          	addi	a3,a3,1144 # ffffffffc02025e8 <commands+0x900>
ffffffffc0201178:	00001617          	auipc	a2,0x1
ffffffffc020117c:	20860613          	addi	a2,a2,520 # ffffffffc0202380 <commands+0x698>
ffffffffc0201180:	14900593          	li	a1,329
ffffffffc0201184:	00001517          	auipc	a0,0x1
ffffffffc0201188:	21450513          	addi	a0,a0,532 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020118c:	faffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0201190:	00001697          	auipc	a3,0x1
ffffffffc0201194:	42868693          	addi	a3,a3,1064 # ffffffffc02025b8 <commands+0x8d0>
ffffffffc0201198:	00001617          	auipc	a2,0x1
ffffffffc020119c:	1e860613          	addi	a2,a2,488 # ffffffffc0202380 <commands+0x698>
ffffffffc02011a0:	14700593          	li	a1,327
ffffffffc02011a4:	00001517          	auipc	a0,0x1
ffffffffc02011a8:	1f450513          	addi	a0,a0,500 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02011ac:	f8ffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011b0:	00001697          	auipc	a3,0x1
ffffffffc02011b4:	3f068693          	addi	a3,a3,1008 # ffffffffc02025a0 <commands+0x8b8>
ffffffffc02011b8:	00001617          	auipc	a2,0x1
ffffffffc02011bc:	1c860613          	addi	a2,a2,456 # ffffffffc0202380 <commands+0x698>
ffffffffc02011c0:	14600593          	li	a1,326
ffffffffc02011c4:	00001517          	auipc	a0,0x1
ffffffffc02011c8:	1d450513          	addi	a0,a0,468 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02011cc:	f6ffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d0:	00001697          	auipc	a3,0x1
ffffffffc02011d4:	33868693          	addi	a3,a3,824 # ffffffffc0202508 <commands+0x820>
ffffffffc02011d8:	00001617          	auipc	a2,0x1
ffffffffc02011dc:	1a860613          	addi	a2,a2,424 # ffffffffc0202380 <commands+0x698>
ffffffffc02011e0:	13a00593          	li	a1,314
ffffffffc02011e4:	00001517          	auipc	a0,0x1
ffffffffc02011e8:	1b450513          	addi	a0,a0,436 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02011ec:	f4ffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!PageProperty(p0));
ffffffffc02011f0:	00001697          	auipc	a3,0x1
ffffffffc02011f4:	39868693          	addi	a3,a3,920 # ffffffffc0202588 <commands+0x8a0>
ffffffffc02011f8:	00001617          	auipc	a2,0x1
ffffffffc02011fc:	18860613          	addi	a2,a2,392 # ffffffffc0202380 <commands+0x698>
ffffffffc0201200:	13100593          	li	a1,305
ffffffffc0201204:	00001517          	auipc	a0,0x1
ffffffffc0201208:	19450513          	addi	a0,a0,404 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020120c:	f2ffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 != NULL);
ffffffffc0201210:	00001697          	auipc	a3,0x1
ffffffffc0201214:	36868693          	addi	a3,a3,872 # ffffffffc0202578 <commands+0x890>
ffffffffc0201218:	00001617          	auipc	a2,0x1
ffffffffc020121c:	16860613          	addi	a2,a2,360 # ffffffffc0202380 <commands+0x698>
ffffffffc0201220:	13000593          	li	a1,304
ffffffffc0201224:	00001517          	auipc	a0,0x1
ffffffffc0201228:	17450513          	addi	a0,a0,372 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020122c:	f0ffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 0);
ffffffffc0201230:	00001697          	auipc	a3,0x1
ffffffffc0201234:	33868693          	addi	a3,a3,824 # ffffffffc0202568 <commands+0x880>
ffffffffc0201238:	00001617          	auipc	a2,0x1
ffffffffc020123c:	14860613          	addi	a2,a2,328 # ffffffffc0202380 <commands+0x698>
ffffffffc0201240:	11200593          	li	a1,274
ffffffffc0201244:	00001517          	auipc	a0,0x1
ffffffffc0201248:	15450513          	addi	a0,a0,340 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020124c:	eeffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201250:	00001697          	auipc	a3,0x1
ffffffffc0201254:	2b868693          	addi	a3,a3,696 # ffffffffc0202508 <commands+0x820>
ffffffffc0201258:	00001617          	auipc	a2,0x1
ffffffffc020125c:	12860613          	addi	a2,a2,296 # ffffffffc0202380 <commands+0x698>
ffffffffc0201260:	11000593          	li	a1,272
ffffffffc0201264:	00001517          	auipc	a0,0x1
ffffffffc0201268:	13450513          	addi	a0,a0,308 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020126c:	ecffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201270:	00001697          	auipc	a3,0x1
ffffffffc0201274:	2d868693          	addi	a3,a3,728 # ffffffffc0202548 <commands+0x860>
ffffffffc0201278:	00001617          	auipc	a2,0x1
ffffffffc020127c:	10860613          	addi	a2,a2,264 # ffffffffc0202380 <commands+0x698>
ffffffffc0201280:	10f00593          	li	a1,271
ffffffffc0201284:	00001517          	auipc	a0,0x1
ffffffffc0201288:	11450513          	addi	a0,a0,276 # ffffffffc0202398 <commands+0x6b0>
ffffffffc020128c:	eaffe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201290 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201290:	1141                	addi	sp,sp,-16
ffffffffc0201292:	e406                	sd	ra,8(sp)
    assert(n > 0); // 确保释放的页数大于0
ffffffffc0201294:	14058a63          	beqz	a1,ffffffffc02013e8 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0201298:	00259693          	slli	a3,a1,0x2
ffffffffc020129c:	96ae                	add	a3,a3,a1
ffffffffc020129e:	068e                	slli	a3,a3,0x3
ffffffffc02012a0:	96aa                	add	a3,a3,a0
ffffffffc02012a2:	87aa                	mv	a5,a0
ffffffffc02012a4:	02d50263          	beq	a0,a3,ffffffffc02012c8 <best_fit_free_pages+0x38>
ffffffffc02012a8:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页块没有被保留且没有属性标记
ffffffffc02012aa:	8b05                	andi	a4,a4,1
ffffffffc02012ac:	10071e63          	bnez	a4,ffffffffc02013c8 <best_fit_free_pages+0x138>
ffffffffc02012b0:	6798                	ld	a4,8(a5)
ffffffffc02012b2:	8b09                	andi	a4,a4,2
ffffffffc02012b4:	10071a63          	bnez	a4,ffffffffc02013c8 <best_fit_free_pages+0x138>
        p->flags = 0; // 清除页的标志
ffffffffc02012b8:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012bc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012c0:	02878793          	addi	a5,a5,40
ffffffffc02012c4:	fed792e3          	bne	a5,a3,ffffffffc02012a8 <best_fit_free_pages+0x18>
    base->property = n;  // 设置当前页块的属性为释放的页数
ffffffffc02012c8:	2581                	sext.w	a1,a1
ffffffffc02012ca:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02012cc:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012d0:	4789                	li	a5,2
ffffffffc02012d2:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;  // 增加空闲页块总数
ffffffffc02012d6:	00005697          	auipc	a3,0x5
ffffffffc02012da:	d4268693          	addi	a3,a3,-702 # ffffffffc0206018 <free_area>
ffffffffc02012de:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012e0:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012e2:	01850613          	addi	a2,a0,24
    nr_free += n;  // 增加空闲页块总数
ffffffffc02012e6:	9db9                	addw	a1,a1,a4
ffffffffc02012e8:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) { // 如果空闲链表为空，直接添加当前页块
ffffffffc02012ea:	0ad78863          	beq	a5,a3,ffffffffc020139a <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012ee:	fe878713          	addi	a4,a5,-24
ffffffffc02012f2:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) { // 如果空闲链表为空，直接添加当前页块
ffffffffc02012f6:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012f8:	00e56a63          	bltu	a0,a4,ffffffffc020130c <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc02012fc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012fe:	06d70263          	beq	a4,a3,ffffffffc0201362 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201302:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201304:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201308:	fee57ae3          	bgeu	a0,a4,ffffffffc02012fc <best_fit_free_pages+0x6c>
ffffffffc020130c:	c199                	beqz	a1,ffffffffc0201312 <best_fit_free_pages+0x82>
ffffffffc020130e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201312:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201314:	e390                	sd	a2,0(a5)
ffffffffc0201316:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201318:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020131a:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020131c:	02d70063          	beq	a4,a3,ffffffffc020133c <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201320:	ff872803          	lw	a6,-8(a4) # ffffffffffffeff8 <end+0x3fdf8b78>
        p = le2page(le, page_link);
ffffffffc0201324:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201328:	02081613          	slli	a2,a6,0x20
ffffffffc020132c:	9201                	srli	a2,a2,0x20
ffffffffc020132e:	00261793          	slli	a5,a2,0x2
ffffffffc0201332:	97b2                	add	a5,a5,a2
ffffffffc0201334:	078e                	slli	a5,a5,0x3
ffffffffc0201336:	97ae                	add	a5,a5,a1
ffffffffc0201338:	02f50f63          	beq	a0,a5,ffffffffc0201376 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc020133c:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc020133e:	00d70f63          	beq	a4,a3,ffffffffc020135c <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201342:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201344:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201348:	02059613          	slli	a2,a1,0x20
ffffffffc020134c:	9201                	srli	a2,a2,0x20
ffffffffc020134e:	00261793          	slli	a5,a2,0x2
ffffffffc0201352:	97b2                	add	a5,a5,a2
ffffffffc0201354:	078e                	slli	a5,a5,0x3
ffffffffc0201356:	97aa                	add	a5,a5,a0
ffffffffc0201358:	04f68863          	beq	a3,a5,ffffffffc02013a8 <best_fit_free_pages+0x118>
}
ffffffffc020135c:	60a2                	ld	ra,8(sp)
ffffffffc020135e:	0141                	addi	sp,sp,16
ffffffffc0201360:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201362:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201364:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201366:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201368:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136a:	02d70563          	beq	a4,a3,ffffffffc0201394 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc020136e:	8832                	mv	a6,a2
ffffffffc0201370:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201372:	87ba                	mv	a5,a4
ffffffffc0201374:	bf41                	j	ffffffffc0201304 <best_fit_free_pages+0x74>
            p->property += base->property;  // 更新前一个空闲页块的大小
ffffffffc0201376:	491c                	lw	a5,16(a0)
ffffffffc0201378:	0107883b          	addw	a6,a5,a6
ffffffffc020137c:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201380:	57f5                	li	a5,-3
ffffffffc0201382:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201386:	6d10                	ld	a2,24(a0)
ffffffffc0201388:	711c                	ld	a5,32(a0)
            base = p;  // 更新指针，继续检查合并后的连续空闲页块
ffffffffc020138a:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc020138c:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc020138e:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201390:	e390                	sd	a2,0(a5)
ffffffffc0201392:	b775                	j	ffffffffc020133e <best_fit_free_pages+0xae>
ffffffffc0201394:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201396:	873e                	mv	a4,a5
ffffffffc0201398:	b761                	j	ffffffffc0201320 <best_fit_free_pages+0x90>
}
ffffffffc020139a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020139c:	e390                	sd	a2,0(a5)
ffffffffc020139e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013a0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013a2:	ed1c                	sd	a5,24(a0)
ffffffffc02013a4:	0141                	addi	sp,sp,16
ffffffffc02013a6:	8082                	ret
            base->property += p->property;  // 合并当前页块和后一个空闲页块
ffffffffc02013a8:	ff872783          	lw	a5,-8(a4)
ffffffffc02013ac:	ff070693          	addi	a3,a4,-16
ffffffffc02013b0:	9dbd                	addw	a1,a1,a5
ffffffffc02013b2:	c90c                	sw	a1,16(a0)
ffffffffc02013b4:	57f5                	li	a5,-3
ffffffffc02013b6:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013ba:	6314                	ld	a3,0(a4)
ffffffffc02013bc:	671c                	ld	a5,8(a4)
}
ffffffffc02013be:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013c0:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013c2:	e394                	sd	a3,0(a5)
ffffffffc02013c4:	0141                	addi	sp,sp,16
ffffffffc02013c6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页块没有被保留且没有属性标记
ffffffffc02013c8:	00001697          	auipc	a3,0x1
ffffffffc02013cc:	2a868693          	addi	a3,a3,680 # ffffffffc0202670 <commands+0x988>
ffffffffc02013d0:	00001617          	auipc	a2,0x1
ffffffffc02013d4:	fb060613          	addi	a2,a2,-80 # ffffffffc0202380 <commands+0x698>
ffffffffc02013d8:	0a200593          	li	a1,162
ffffffffc02013dc:	00001517          	auipc	a0,0x1
ffffffffc02013e0:	fbc50513          	addi	a0,a0,-68 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02013e4:	d57fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0); // 确保释放的页数大于0
ffffffffc02013e8:	00001697          	auipc	a3,0x1
ffffffffc02013ec:	f9068693          	addi	a3,a3,-112 # ffffffffc0202378 <commands+0x690>
ffffffffc02013f0:	00001617          	auipc	a2,0x1
ffffffffc02013f4:	f9060613          	addi	a2,a2,-112 # ffffffffc0202380 <commands+0x698>
ffffffffc02013f8:	09d00593          	li	a1,157
ffffffffc02013fc:	00001517          	auipc	a0,0x1
ffffffffc0201400:	f9c50513          	addi	a0,a0,-100 # ffffffffc0202398 <commands+0x6b0>
ffffffffc0201404:	d37fe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201408 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201408:	1141                	addi	sp,sp,-16
ffffffffc020140a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020140c:	c9e1                	beqz	a1,ffffffffc02014dc <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020140e:	00259693          	slli	a3,a1,0x2
ffffffffc0201412:	96ae                	add	a3,a3,a1
ffffffffc0201414:	068e                	slli	a3,a3,0x3
ffffffffc0201416:	96aa                	add	a3,a3,a0
ffffffffc0201418:	87aa                	mv	a5,a0
ffffffffc020141a:	00d50f63          	beq	a0,a3,ffffffffc0201438 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020141e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201420:	8b05                	andi	a4,a4,1
ffffffffc0201422:	cf49                	beqz	a4,ffffffffc02014bc <best_fit_init_memmap+0xb4>
        p->flags = 0;
ffffffffc0201424:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201428:	0007a823          	sw	zero,16(a5)
ffffffffc020142c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201430:	02878793          	addi	a5,a5,40
ffffffffc0201434:	fed795e3          	bne	a5,a3,ffffffffc020141e <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0201438:	2581                	sext.w	a1,a1
ffffffffc020143a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020143c:	4789                	li	a5,2
ffffffffc020143e:	00850713          	addi	a4,a0,8
ffffffffc0201442:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201446:	00005697          	auipc	a3,0x5
ffffffffc020144a:	bd268693          	addi	a3,a3,-1070 # ffffffffc0206018 <free_area>
ffffffffc020144e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201450:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201452:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201456:	9db9                	addw	a1,a1,a4
ffffffffc0201458:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020145a:	04d78a63          	beq	a5,a3,ffffffffc02014ae <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020145e:	fe878713          	addi	a4,a5,-24
ffffffffc0201462:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201466:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201468:	00e56a63          	bltu	a0,a4,ffffffffc020147c <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc020146c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc020146e:	02d70263          	beq	a4,a3,ffffffffc0201492 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201472:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201474:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201478:	fee57ae3          	bgeu	a0,a4,ffffffffc020146c <best_fit_init_memmap+0x64>
ffffffffc020147c:	c199                	beqz	a1,ffffffffc0201482 <best_fit_init_memmap+0x7a>
ffffffffc020147e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201482:	6398                	ld	a4,0(a5)
}
ffffffffc0201484:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201486:	e390                	sd	a2,0(a5)
ffffffffc0201488:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020148a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020148c:	ed18                	sd	a4,24(a0)
ffffffffc020148e:	0141                	addi	sp,sp,16
ffffffffc0201490:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201492:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201494:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201496:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201498:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020149a:	00d70663          	beq	a4,a3,ffffffffc02014a6 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020149e:	8832                	mv	a6,a2
ffffffffc02014a0:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02014a2:	87ba                	mv	a5,a4
ffffffffc02014a4:	bfc1                	j	ffffffffc0201474 <best_fit_init_memmap+0x6c>
}
ffffffffc02014a6:	60a2                	ld	ra,8(sp)
ffffffffc02014a8:	e290                	sd	a2,0(a3)
ffffffffc02014aa:	0141                	addi	sp,sp,16
ffffffffc02014ac:	8082                	ret
ffffffffc02014ae:	60a2                	ld	ra,8(sp)
ffffffffc02014b0:	e390                	sd	a2,0(a5)
ffffffffc02014b2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014b4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014b6:	ed1c                	sd	a5,24(a0)
ffffffffc02014b8:	0141                	addi	sp,sp,16
ffffffffc02014ba:	8082                	ret
        assert(PageReserved(p));
ffffffffc02014bc:	00001697          	auipc	a3,0x1
ffffffffc02014c0:	1dc68693          	addi	a3,a3,476 # ffffffffc0202698 <commands+0x9b0>
ffffffffc02014c4:	00001617          	auipc	a2,0x1
ffffffffc02014c8:	ebc60613          	addi	a2,a2,-324 # ffffffffc0202380 <commands+0x698>
ffffffffc02014cc:	04a00593          	li	a1,74
ffffffffc02014d0:	00001517          	auipc	a0,0x1
ffffffffc02014d4:	ec850513          	addi	a0,a0,-312 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02014d8:	c63fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc02014dc:	00001697          	auipc	a3,0x1
ffffffffc02014e0:	e9c68693          	addi	a3,a3,-356 # ffffffffc0202378 <commands+0x690>
ffffffffc02014e4:	00001617          	auipc	a2,0x1
ffffffffc02014e8:	e9c60613          	addi	a2,a2,-356 # ffffffffc0202380 <commands+0x698>
ffffffffc02014ec:	04700593          	li	a1,71
ffffffffc02014f0:	00001517          	auipc	a0,0x1
ffffffffc02014f4:	ea850513          	addi	a0,a0,-344 # ffffffffc0202398 <commands+0x6b0>
ffffffffc02014f8:	c43fe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc02014fc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02014fc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02014fe:	e589                	bnez	a1,ffffffffc0201508 <strnlen+0xc>
ffffffffc0201500:	a811                	j	ffffffffc0201514 <strnlen+0x18>
        cnt ++;
ffffffffc0201502:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201504:	00f58863          	beq	a1,a5,ffffffffc0201514 <strnlen+0x18>
ffffffffc0201508:	00f50733          	add	a4,a0,a5
ffffffffc020150c:	00074703          	lbu	a4,0(a4)
ffffffffc0201510:	fb6d                	bnez	a4,ffffffffc0201502 <strnlen+0x6>
ffffffffc0201512:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201514:	852e                	mv	a0,a1
ffffffffc0201516:	8082                	ret

ffffffffc0201518 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201518:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020151c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201520:	cb89                	beqz	a5,ffffffffc0201532 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201522:	0505                	addi	a0,a0,1
ffffffffc0201524:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201526:	fee789e3          	beq	a5,a4,ffffffffc0201518 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020152a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020152e:	9d19                	subw	a0,a0,a4
ffffffffc0201530:	8082                	ret
ffffffffc0201532:	4501                	li	a0,0
ffffffffc0201534:	bfed                	j	ffffffffc020152e <strcmp+0x16>

ffffffffc0201536 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201536:	00054783          	lbu	a5,0(a0)
ffffffffc020153a:	c799                	beqz	a5,ffffffffc0201548 <strchr+0x12>
        if (*s == c) {
ffffffffc020153c:	00f58763          	beq	a1,a5,ffffffffc020154a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201540:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201544:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201546:	fbfd                	bnez	a5,ffffffffc020153c <strchr+0x6>
    }
    return NULL;
ffffffffc0201548:	4501                	li	a0,0
}
ffffffffc020154a:	8082                	ret

ffffffffc020154c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020154c:	ca01                	beqz	a2,ffffffffc020155c <memset+0x10>
ffffffffc020154e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201550:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201552:	0785                	addi	a5,a5,1
ffffffffc0201554:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201558:	fec79de3          	bne	a5,a2,ffffffffc0201552 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020155c:	8082                	ret

ffffffffc020155e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020155e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201562:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201564:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201568:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020156a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020156e:	f022                	sd	s0,32(sp)
ffffffffc0201570:	ec26                	sd	s1,24(sp)
ffffffffc0201572:	e84a                	sd	s2,16(sp)
ffffffffc0201574:	f406                	sd	ra,40(sp)
ffffffffc0201576:	e44e                	sd	s3,8(sp)
ffffffffc0201578:	84aa                	mv	s1,a0
ffffffffc020157a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020157c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201580:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201582:	03067e63          	bgeu	a2,a6,ffffffffc02015be <printnum+0x60>
ffffffffc0201586:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201588:	00805763          	blez	s0,ffffffffc0201596 <printnum+0x38>
ffffffffc020158c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020158e:	85ca                	mv	a1,s2
ffffffffc0201590:	854e                	mv	a0,s3
ffffffffc0201592:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201594:	fc65                	bnez	s0,ffffffffc020158c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201596:	1a02                	slli	s4,s4,0x20
ffffffffc0201598:	00001797          	auipc	a5,0x1
ffffffffc020159c:	16078793          	addi	a5,a5,352 # ffffffffc02026f8 <best_fit_pmm_manager+0x38>
ffffffffc02015a0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015a4:	9a3e                	add	s4,s4,a5
}
ffffffffc02015a6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015a8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015ac:	70a2                	ld	ra,40(sp)
ffffffffc02015ae:	69a2                	ld	s3,8(sp)
ffffffffc02015b0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015b2:	85ca                	mv	a1,s2
ffffffffc02015b4:	87a6                	mv	a5,s1
}
ffffffffc02015b6:	6942                	ld	s2,16(sp)
ffffffffc02015b8:	64e2                	ld	s1,24(sp)
ffffffffc02015ba:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015bc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015be:	03065633          	divu	a2,a2,a6
ffffffffc02015c2:	8722                	mv	a4,s0
ffffffffc02015c4:	f9bff0ef          	jal	ra,ffffffffc020155e <printnum>
ffffffffc02015c8:	b7f9                	j	ffffffffc0201596 <printnum+0x38>

ffffffffc02015ca <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015ca:	7119                	addi	sp,sp,-128
ffffffffc02015cc:	f4a6                	sd	s1,104(sp)
ffffffffc02015ce:	f0ca                	sd	s2,96(sp)
ffffffffc02015d0:	ecce                	sd	s3,88(sp)
ffffffffc02015d2:	e8d2                	sd	s4,80(sp)
ffffffffc02015d4:	e4d6                	sd	s5,72(sp)
ffffffffc02015d6:	e0da                	sd	s6,64(sp)
ffffffffc02015d8:	fc5e                	sd	s7,56(sp)
ffffffffc02015da:	f06a                	sd	s10,32(sp)
ffffffffc02015dc:	fc86                	sd	ra,120(sp)
ffffffffc02015de:	f8a2                	sd	s0,112(sp)
ffffffffc02015e0:	f862                	sd	s8,48(sp)
ffffffffc02015e2:	f466                	sd	s9,40(sp)
ffffffffc02015e4:	ec6e                	sd	s11,24(sp)
ffffffffc02015e6:	892a                	mv	s2,a0
ffffffffc02015e8:	84ae                	mv	s1,a1
ffffffffc02015ea:	8d32                	mv	s10,a2
ffffffffc02015ec:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015ee:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015f2:	5b7d                	li	s6,-1
ffffffffc02015f4:	00001a97          	auipc	s5,0x1
ffffffffc02015f8:	138a8a93          	addi	s5,s5,312 # ffffffffc020272c <best_fit_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015fc:	00001b97          	auipc	s7,0x1
ffffffffc0201600:	30cb8b93          	addi	s7,s7,780 # ffffffffc0202908 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201604:	000d4503          	lbu	a0,0(s10)
ffffffffc0201608:	001d0413          	addi	s0,s10,1
ffffffffc020160c:	01350a63          	beq	a0,s3,ffffffffc0201620 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201610:	c121                	beqz	a0,ffffffffc0201650 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201612:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201614:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201616:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201618:	fff44503          	lbu	a0,-1(s0)
ffffffffc020161c:	ff351ae3          	bne	a0,s3,ffffffffc0201610 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201620:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201624:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201628:	4c81                	li	s9,0
ffffffffc020162a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020162c:	5c7d                	li	s8,-1
ffffffffc020162e:	5dfd                	li	s11,-1
ffffffffc0201630:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201634:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201636:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020163a:	0ff5f593          	zext.b	a1,a1
ffffffffc020163e:	00140d13          	addi	s10,s0,1
ffffffffc0201642:	04b56263          	bltu	a0,a1,ffffffffc0201686 <vprintfmt+0xbc>
ffffffffc0201646:	058a                	slli	a1,a1,0x2
ffffffffc0201648:	95d6                	add	a1,a1,s5
ffffffffc020164a:	4194                	lw	a3,0(a1)
ffffffffc020164c:	96d6                	add	a3,a3,s5
ffffffffc020164e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201650:	70e6                	ld	ra,120(sp)
ffffffffc0201652:	7446                	ld	s0,112(sp)
ffffffffc0201654:	74a6                	ld	s1,104(sp)
ffffffffc0201656:	7906                	ld	s2,96(sp)
ffffffffc0201658:	69e6                	ld	s3,88(sp)
ffffffffc020165a:	6a46                	ld	s4,80(sp)
ffffffffc020165c:	6aa6                	ld	s5,72(sp)
ffffffffc020165e:	6b06                	ld	s6,64(sp)
ffffffffc0201660:	7be2                	ld	s7,56(sp)
ffffffffc0201662:	7c42                	ld	s8,48(sp)
ffffffffc0201664:	7ca2                	ld	s9,40(sp)
ffffffffc0201666:	7d02                	ld	s10,32(sp)
ffffffffc0201668:	6de2                	ld	s11,24(sp)
ffffffffc020166a:	6109                	addi	sp,sp,128
ffffffffc020166c:	8082                	ret
            padc = '0';
ffffffffc020166e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201670:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201674:	846a                	mv	s0,s10
ffffffffc0201676:	00140d13          	addi	s10,s0,1
ffffffffc020167a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020167e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201682:	fcb572e3          	bgeu	a0,a1,ffffffffc0201646 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201686:	85a6                	mv	a1,s1
ffffffffc0201688:	02500513          	li	a0,37
ffffffffc020168c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020168e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201692:	8d22                	mv	s10,s0
ffffffffc0201694:	f73788e3          	beq	a5,s3,ffffffffc0201604 <vprintfmt+0x3a>
ffffffffc0201698:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020169c:	1d7d                	addi	s10,s10,-1
ffffffffc020169e:	ff379de3          	bne	a5,s3,ffffffffc0201698 <vprintfmt+0xce>
ffffffffc02016a2:	b78d                	j	ffffffffc0201604 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02016a4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02016a8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ac:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02016ae:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02016b2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016b6:	02d86463          	bltu	a6,a3,ffffffffc02016de <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02016ba:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02016be:	002c169b          	slliw	a3,s8,0x2
ffffffffc02016c2:	0186873b          	addw	a4,a3,s8
ffffffffc02016c6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02016ca:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02016cc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02016d0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02016d2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02016d6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016da:	fed870e3          	bgeu	a6,a3,ffffffffc02016ba <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02016de:	f40ddce3          	bgez	s11,ffffffffc0201636 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02016e2:	8de2                	mv	s11,s8
ffffffffc02016e4:	5c7d                	li	s8,-1
ffffffffc02016e6:	bf81                	j	ffffffffc0201636 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02016e8:	fffdc693          	not	a3,s11
ffffffffc02016ec:	96fd                	srai	a3,a3,0x3f
ffffffffc02016ee:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f2:	00144603          	lbu	a2,1(s0)
ffffffffc02016f6:	2d81                	sext.w	s11,s11
ffffffffc02016f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016fa:	bf35                	j	ffffffffc0201636 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02016fc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201700:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201704:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201706:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201708:	bfd9                	j	ffffffffc02016de <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020170a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020170c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201710:	01174463          	blt	a4,a7,ffffffffc0201718 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201714:	1a088e63          	beqz	a7,ffffffffc02018d0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201718:	000a3603          	ld	a2,0(s4)
ffffffffc020171c:	46c1                	li	a3,16
ffffffffc020171e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201720:	2781                	sext.w	a5,a5
ffffffffc0201722:	876e                	mv	a4,s11
ffffffffc0201724:	85a6                	mv	a1,s1
ffffffffc0201726:	854a                	mv	a0,s2
ffffffffc0201728:	e37ff0ef          	jal	ra,ffffffffc020155e <printnum>
            break;
ffffffffc020172c:	bde1                	j	ffffffffc0201604 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020172e:	000a2503          	lw	a0,0(s4)
ffffffffc0201732:	85a6                	mv	a1,s1
ffffffffc0201734:	0a21                	addi	s4,s4,8
ffffffffc0201736:	9902                	jalr	s2
            break;
ffffffffc0201738:	b5f1                	j	ffffffffc0201604 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020173a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020173c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201740:	01174463          	blt	a4,a7,ffffffffc0201748 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201744:	18088163          	beqz	a7,ffffffffc02018c6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201748:	000a3603          	ld	a2,0(s4)
ffffffffc020174c:	46a9                	li	a3,10
ffffffffc020174e:	8a2e                	mv	s4,a1
ffffffffc0201750:	bfc1                	j	ffffffffc0201720 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201752:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201756:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201758:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020175a:	bdf1                	j	ffffffffc0201636 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020175c:	85a6                	mv	a1,s1
ffffffffc020175e:	02500513          	li	a0,37
ffffffffc0201762:	9902                	jalr	s2
            break;
ffffffffc0201764:	b545                	j	ffffffffc0201604 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201766:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020176a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020176c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020176e:	b5e1                	j	ffffffffc0201636 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201770:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201772:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201776:	01174463          	blt	a4,a7,ffffffffc020177e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020177a:	14088163          	beqz	a7,ffffffffc02018bc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020177e:	000a3603          	ld	a2,0(s4)
ffffffffc0201782:	46a1                	li	a3,8
ffffffffc0201784:	8a2e                	mv	s4,a1
ffffffffc0201786:	bf69                	j	ffffffffc0201720 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201788:	03000513          	li	a0,48
ffffffffc020178c:	85a6                	mv	a1,s1
ffffffffc020178e:	e03e                	sd	a5,0(sp)
ffffffffc0201790:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201792:	85a6                	mv	a1,s1
ffffffffc0201794:	07800513          	li	a0,120
ffffffffc0201798:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020179a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020179c:	6782                	ld	a5,0(sp)
ffffffffc020179e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017a0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02017a4:	bfb5                	j	ffffffffc0201720 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017a6:	000a3403          	ld	s0,0(s4)
ffffffffc02017aa:	008a0713          	addi	a4,s4,8
ffffffffc02017ae:	e03a                	sd	a4,0(sp)
ffffffffc02017b0:	14040263          	beqz	s0,ffffffffc02018f4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02017b4:	0fb05763          	blez	s11,ffffffffc02018a2 <vprintfmt+0x2d8>
ffffffffc02017b8:	02d00693          	li	a3,45
ffffffffc02017bc:	0cd79163          	bne	a5,a3,ffffffffc020187e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017c0:	00044783          	lbu	a5,0(s0)
ffffffffc02017c4:	0007851b          	sext.w	a0,a5
ffffffffc02017c8:	cf85                	beqz	a5,ffffffffc0201800 <vprintfmt+0x236>
ffffffffc02017ca:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017ce:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017d2:	000c4563          	bltz	s8,ffffffffc02017dc <vprintfmt+0x212>
ffffffffc02017d6:	3c7d                	addiw	s8,s8,-1
ffffffffc02017d8:	036c0263          	beq	s8,s6,ffffffffc02017fc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02017dc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017de:	0e0c8e63          	beqz	s9,ffffffffc02018da <vprintfmt+0x310>
ffffffffc02017e2:	3781                	addiw	a5,a5,-32
ffffffffc02017e4:	0ef47b63          	bgeu	s0,a5,ffffffffc02018da <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02017e8:	03f00513          	li	a0,63
ffffffffc02017ec:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ee:	000a4783          	lbu	a5,0(s4)
ffffffffc02017f2:	3dfd                	addiw	s11,s11,-1
ffffffffc02017f4:	0a05                	addi	s4,s4,1
ffffffffc02017f6:	0007851b          	sext.w	a0,a5
ffffffffc02017fa:	ffe1                	bnez	a5,ffffffffc02017d2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02017fc:	01b05963          	blez	s11,ffffffffc020180e <vprintfmt+0x244>
ffffffffc0201800:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201802:	85a6                	mv	a1,s1
ffffffffc0201804:	02000513          	li	a0,32
ffffffffc0201808:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020180a:	fe0d9be3          	bnez	s11,ffffffffc0201800 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020180e:	6a02                	ld	s4,0(sp)
ffffffffc0201810:	bbd5                	j	ffffffffc0201604 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201812:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201814:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201818:	01174463          	blt	a4,a7,ffffffffc0201820 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020181c:	08088d63          	beqz	a7,ffffffffc02018b6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201820:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201824:	0a044d63          	bltz	s0,ffffffffc02018de <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201828:	8622                	mv	a2,s0
ffffffffc020182a:	8a66                	mv	s4,s9
ffffffffc020182c:	46a9                	li	a3,10
ffffffffc020182e:	bdcd                	j	ffffffffc0201720 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201830:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201834:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201836:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201838:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020183c:	8fb5                	xor	a5,a5,a3
ffffffffc020183e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201842:	02d74163          	blt	a4,a3,ffffffffc0201864 <vprintfmt+0x29a>
ffffffffc0201846:	00369793          	slli	a5,a3,0x3
ffffffffc020184a:	97de                	add	a5,a5,s7
ffffffffc020184c:	639c                	ld	a5,0(a5)
ffffffffc020184e:	cb99                	beqz	a5,ffffffffc0201864 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201850:	86be                	mv	a3,a5
ffffffffc0201852:	00001617          	auipc	a2,0x1
ffffffffc0201856:	ed660613          	addi	a2,a2,-298 # ffffffffc0202728 <best_fit_pmm_manager+0x68>
ffffffffc020185a:	85a6                	mv	a1,s1
ffffffffc020185c:	854a                	mv	a0,s2
ffffffffc020185e:	0ce000ef          	jal	ra,ffffffffc020192c <printfmt>
ffffffffc0201862:	b34d                	j	ffffffffc0201604 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201864:	00001617          	auipc	a2,0x1
ffffffffc0201868:	eb460613          	addi	a2,a2,-332 # ffffffffc0202718 <best_fit_pmm_manager+0x58>
ffffffffc020186c:	85a6                	mv	a1,s1
ffffffffc020186e:	854a                	mv	a0,s2
ffffffffc0201870:	0bc000ef          	jal	ra,ffffffffc020192c <printfmt>
ffffffffc0201874:	bb41                	j	ffffffffc0201604 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201876:	00001417          	auipc	s0,0x1
ffffffffc020187a:	e9a40413          	addi	s0,s0,-358 # ffffffffc0202710 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020187e:	85e2                	mv	a1,s8
ffffffffc0201880:	8522                	mv	a0,s0
ffffffffc0201882:	e43e                	sd	a5,8(sp)
ffffffffc0201884:	c79ff0ef          	jal	ra,ffffffffc02014fc <strnlen>
ffffffffc0201888:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020188c:	01b05b63          	blez	s11,ffffffffc02018a2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201890:	67a2                	ld	a5,8(sp)
ffffffffc0201892:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201896:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201898:	85a6                	mv	a1,s1
ffffffffc020189a:	8552                	mv	a0,s4
ffffffffc020189c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020189e:	fe0d9ce3          	bnez	s11,ffffffffc0201896 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a2:	00044783          	lbu	a5,0(s0)
ffffffffc02018a6:	00140a13          	addi	s4,s0,1
ffffffffc02018aa:	0007851b          	sext.w	a0,a5
ffffffffc02018ae:	d3a5                	beqz	a5,ffffffffc020180e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018b0:	05e00413          	li	s0,94
ffffffffc02018b4:	bf39                	j	ffffffffc02017d2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02018b6:	000a2403          	lw	s0,0(s4)
ffffffffc02018ba:	b7ad                	j	ffffffffc0201824 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02018bc:	000a6603          	lwu	a2,0(s4)
ffffffffc02018c0:	46a1                	li	a3,8
ffffffffc02018c2:	8a2e                	mv	s4,a1
ffffffffc02018c4:	bdb1                	j	ffffffffc0201720 <vprintfmt+0x156>
ffffffffc02018c6:	000a6603          	lwu	a2,0(s4)
ffffffffc02018ca:	46a9                	li	a3,10
ffffffffc02018cc:	8a2e                	mv	s4,a1
ffffffffc02018ce:	bd89                	j	ffffffffc0201720 <vprintfmt+0x156>
ffffffffc02018d0:	000a6603          	lwu	a2,0(s4)
ffffffffc02018d4:	46c1                	li	a3,16
ffffffffc02018d6:	8a2e                	mv	s4,a1
ffffffffc02018d8:	b5a1                	j	ffffffffc0201720 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02018da:	9902                	jalr	s2
ffffffffc02018dc:	bf09                	j	ffffffffc02017ee <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02018de:	85a6                	mv	a1,s1
ffffffffc02018e0:	02d00513          	li	a0,45
ffffffffc02018e4:	e03e                	sd	a5,0(sp)
ffffffffc02018e6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018e8:	6782                	ld	a5,0(sp)
ffffffffc02018ea:	8a66                	mv	s4,s9
ffffffffc02018ec:	40800633          	neg	a2,s0
ffffffffc02018f0:	46a9                	li	a3,10
ffffffffc02018f2:	b53d                	j	ffffffffc0201720 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02018f4:	03b05163          	blez	s11,ffffffffc0201916 <vprintfmt+0x34c>
ffffffffc02018f8:	02d00693          	li	a3,45
ffffffffc02018fc:	f6d79de3          	bne	a5,a3,ffffffffc0201876 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201900:	00001417          	auipc	s0,0x1
ffffffffc0201904:	e1040413          	addi	s0,s0,-496 # ffffffffc0202710 <best_fit_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201908:	02800793          	li	a5,40
ffffffffc020190c:	02800513          	li	a0,40
ffffffffc0201910:	00140a13          	addi	s4,s0,1
ffffffffc0201914:	bd6d                	j	ffffffffc02017ce <vprintfmt+0x204>
ffffffffc0201916:	00001a17          	auipc	s4,0x1
ffffffffc020191a:	dfba0a13          	addi	s4,s4,-517 # ffffffffc0202711 <best_fit_pmm_manager+0x51>
ffffffffc020191e:	02800513          	li	a0,40
ffffffffc0201922:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201926:	05e00413          	li	s0,94
ffffffffc020192a:	b565                	j	ffffffffc02017d2 <vprintfmt+0x208>

ffffffffc020192c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020192c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020192e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201932:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201934:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201936:	ec06                	sd	ra,24(sp)
ffffffffc0201938:	f83a                	sd	a4,48(sp)
ffffffffc020193a:	fc3e                	sd	a5,56(sp)
ffffffffc020193c:	e0c2                	sd	a6,64(sp)
ffffffffc020193e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201940:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201942:	c89ff0ef          	jal	ra,ffffffffc02015ca <vprintfmt>
}
ffffffffc0201946:	60e2                	ld	ra,24(sp)
ffffffffc0201948:	6161                	addi	sp,sp,80
ffffffffc020194a:	8082                	ret

ffffffffc020194c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020194c:	715d                	addi	sp,sp,-80
ffffffffc020194e:	e486                	sd	ra,72(sp)
ffffffffc0201950:	e0a6                	sd	s1,64(sp)
ffffffffc0201952:	fc4a                	sd	s2,56(sp)
ffffffffc0201954:	f84e                	sd	s3,48(sp)
ffffffffc0201956:	f452                	sd	s4,40(sp)
ffffffffc0201958:	f056                	sd	s5,32(sp)
ffffffffc020195a:	ec5a                	sd	s6,24(sp)
ffffffffc020195c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020195e:	c901                	beqz	a0,ffffffffc020196e <readline+0x22>
ffffffffc0201960:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201962:	00001517          	auipc	a0,0x1
ffffffffc0201966:	dc650513          	addi	a0,a0,-570 # ffffffffc0202728 <best_fit_pmm_manager+0x68>
ffffffffc020196a:	f48fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020196e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201970:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201972:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201974:	4aa9                	li	s5,10
ffffffffc0201976:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201978:	00004b97          	auipc	s7,0x4
ffffffffc020197c:	6b8b8b93          	addi	s7,s7,1720 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201980:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201984:	fa6fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201988:	00054a63          	bltz	a0,ffffffffc020199c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020198c:	00a95a63          	bge	s2,a0,ffffffffc02019a0 <readline+0x54>
ffffffffc0201990:	029a5263          	bge	s4,s1,ffffffffc02019b4 <readline+0x68>
        c = getchar();
ffffffffc0201994:	f96fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201998:	fe055ae3          	bgez	a0,ffffffffc020198c <readline+0x40>
            return NULL;
ffffffffc020199c:	4501                	li	a0,0
ffffffffc020199e:	a091                	j	ffffffffc02019e2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02019a0:	03351463          	bne	a0,s3,ffffffffc02019c8 <readline+0x7c>
ffffffffc02019a4:	e8a9                	bnez	s1,ffffffffc02019f6 <readline+0xaa>
        c = getchar();
ffffffffc02019a6:	f84fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02019aa:	fe0549e3          	bltz	a0,ffffffffc020199c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019ae:	fea959e3          	bge	s2,a0,ffffffffc02019a0 <readline+0x54>
ffffffffc02019b2:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019b4:	e42a                	sd	a0,8(sp)
ffffffffc02019b6:	f32fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02019ba:	6522                	ld	a0,8(sp)
ffffffffc02019bc:	009b87b3          	add	a5,s7,s1
ffffffffc02019c0:	2485                	addiw	s1,s1,1
ffffffffc02019c2:	00a78023          	sb	a0,0(a5)
ffffffffc02019c6:	bf7d                	j	ffffffffc0201984 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02019c8:	01550463          	beq	a0,s5,ffffffffc02019d0 <readline+0x84>
ffffffffc02019cc:	fb651ce3          	bne	a0,s6,ffffffffc0201984 <readline+0x38>
            cputchar(c);
ffffffffc02019d0:	f18fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02019d4:	00004517          	auipc	a0,0x4
ffffffffc02019d8:	65c50513          	addi	a0,a0,1628 # ffffffffc0206030 <buf>
ffffffffc02019dc:	94aa                	add	s1,s1,a0
ffffffffc02019de:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019e2:	60a6                	ld	ra,72(sp)
ffffffffc02019e4:	6486                	ld	s1,64(sp)
ffffffffc02019e6:	7962                	ld	s2,56(sp)
ffffffffc02019e8:	79c2                	ld	s3,48(sp)
ffffffffc02019ea:	7a22                	ld	s4,40(sp)
ffffffffc02019ec:	7a82                	ld	s5,32(sp)
ffffffffc02019ee:	6b62                	ld	s6,24(sp)
ffffffffc02019f0:	6bc2                	ld	s7,16(sp)
ffffffffc02019f2:	6161                	addi	sp,sp,80
ffffffffc02019f4:	8082                	ret
            cputchar(c);
ffffffffc02019f6:	4521                	li	a0,8
ffffffffc02019f8:	ef0fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02019fc:	34fd                	addiw	s1,s1,-1
ffffffffc02019fe:	b759                	j	ffffffffc0201984 <readline+0x38>

ffffffffc0201a00 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201a00:	4781                	li	a5,0
ffffffffc0201a02:	00004717          	auipc	a4,0x4
ffffffffc0201a06:	60673703          	ld	a4,1542(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201a0a:	88ba                	mv	a7,a4
ffffffffc0201a0c:	852a                	mv	a0,a0
ffffffffc0201a0e:	85be                	mv	a1,a5
ffffffffc0201a10:	863e                	mv	a2,a5
ffffffffc0201a12:	00000073          	ecall
ffffffffc0201a16:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201a18:	8082                	ret

ffffffffc0201a1a <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201a1a:	4781                	li	a5,0
ffffffffc0201a1c:	00005717          	auipc	a4,0x5
ffffffffc0201a20:	a5c73703          	ld	a4,-1444(a4) # ffffffffc0206478 <SBI_SET_TIMER>
ffffffffc0201a24:	88ba                	mv	a7,a4
ffffffffc0201a26:	852a                	mv	a0,a0
ffffffffc0201a28:	85be                	mv	a1,a5
ffffffffc0201a2a:	863e                	mv	a2,a5
ffffffffc0201a2c:	00000073          	ecall
ffffffffc0201a30:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201a32:	8082                	ret

ffffffffc0201a34 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201a34:	4501                	li	a0,0
ffffffffc0201a36:	00004797          	auipc	a5,0x4
ffffffffc0201a3a:	5ca7b783          	ld	a5,1482(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201a3e:	88be                	mv	a7,a5
ffffffffc0201a40:	852a                	mv	a0,a0
ffffffffc0201a42:	85aa                	mv	a1,a0
ffffffffc0201a44:	862a                	mv	a2,a0
ffffffffc0201a46:	00000073          	ecall
ffffffffc0201a4a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201a4c:	2501                	sext.w	a0,a0
ffffffffc0201a4e:	8082                	ret

ffffffffc0201a50 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201a50:	4781                	li	a5,0
ffffffffc0201a52:	00004717          	auipc	a4,0x4
ffffffffc0201a56:	5be73703          	ld	a4,1470(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc0201a5a:	88ba                	mv	a7,a4
ffffffffc0201a5c:	853e                	mv	a0,a5
ffffffffc0201a5e:	85be                	mv	a1,a5
ffffffffc0201a60:	863e                	mv	a2,a5
ffffffffc0201a62:	00000073          	ecall
ffffffffc0201a66:	87aa                	mv	a5,a0

void sbi_shutdown(void) {
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201a68:	8082                	ret
