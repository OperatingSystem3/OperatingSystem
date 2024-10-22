
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
ffffffffc020004a:	211010ef          	jal	ra,ffffffffc0201a5a <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201a70 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	304010ef          	jal	ra,ffffffffc020136a <pmm_init>

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
ffffffffc02000a6:	4c4010ef          	jal	ra,ffffffffc020156a <vprintfmt>
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
ffffffffc02000dc:	48e010ef          	jal	ra,ffffffffc020156a <vprintfmt>
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

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	95450513          	addi	a0,a0,-1708 # ffffffffc0201a90 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201ab0 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	90e58593          	addi	a1,a1,-1778 # ffffffffc0201a6c <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0201ad0 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	97650513          	addi	a0,a0,-1674 # ffffffffc0201af0 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2fa58593          	addi	a1,a1,762 # ffffffffc0206480 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	98250513          	addi	a0,a0,-1662 # ffffffffc0201b10 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6e558593          	addi	a1,a1,1765 # ffffffffc020687f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	97450513          	addi	a0,a0,-1676 # ffffffffc0201b30 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	99660613          	addi	a2,a2,-1642 # ffffffffc0201b60 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201b78 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0201b90 <etext+0x124>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	9c258593          	addi	a1,a1,-1598 # ffffffffc0201bb0 <etext+0x144>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201bb8 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	9c460613          	addi	a2,a2,-1596 # ffffffffc0201bc8 <etext+0x15c>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	9e458593          	addi	a1,a1,-1564 # ffffffffc0201bf0 <etext+0x184>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201bb8 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	9e060613          	addi	a2,a2,-1568 # ffffffffc0201c00 <etext+0x194>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	9f858593          	addi	a1,a1,-1544 # ffffffffc0201c20 <etext+0x1b4>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	98850513          	addi	a0,a0,-1656 # ffffffffc0201bb8 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	9c650513          	addi	a0,a0,-1594 # ffffffffc0201c30 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0201c58 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	a26c0c13          	addi	s8,s8,-1498 # ffffffffc0201cc8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	9d690913          	addi	s2,s2,-1578 # ffffffffc0201c80 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	9d648493          	addi	s1,s1,-1578 # ffffffffc0201c88 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	9d4b0b13          	addi	s6,s6,-1580 # ffffffffc0201c90 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	8eca0a13          	addi	s4,s4,-1812 # ffffffffc0201bb0 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	61c010ef          	jal	ra,ffffffffc02018ec <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	9e2d0d13          	addi	s10,s10,-1566 # ffffffffc0201cc8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	732010ef          	jal	ra,ffffffffc0201a26 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	71e010ef          	jal	ra,ffffffffc0201a26 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	6fe010ef          	jal	ra,ffffffffc0201a44 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	6c0010ef          	jal	ra,ffffffffc0201a44 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	91250513          	addi	a0,a0,-1774 # ffffffffc0201cb0 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	08430313          	addi	t1,t1,132 # ffffffffc0206430 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	93650513          	addi	a0,a0,-1738 # ffffffffc0201d10 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	76850513          	addi	a0,a0,1896 # ffffffffc0201b58 <etext+0xec>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

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
ffffffffc0200420:	59a010ef          	jal	ra,ffffffffc02019ba <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	90250513          	addi	a0,a0,-1790 # ffffffffc0201d30 <commands+0x68>
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
ffffffffc0200446:	5740106f          	j	ffffffffc02019ba <sbi_set_timer>

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
ffffffffc0200450:	5500106f          	j	ffffffffc02019a0 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5800106f          	j	ffffffffc02019d4 <sbi_console_getchar>

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
ffffffffc0200482:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201d50 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8da50513          	addi	a0,a0,-1830 # ffffffffc0201d68 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201d80 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201d98 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201db0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	90250513          	addi	a0,a0,-1790 # ffffffffc0201dc8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201de0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	91650513          	addi	a0,a0,-1770 # ffffffffc0201df8 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	92050513          	addi	a0,a0,-1760 # ffffffffc0201e10 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201e28 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	93450513          	addi	a0,a0,-1740 # ffffffffc0201e40 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201e58 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	94850513          	addi	a0,a0,-1720 # ffffffffc0201e70 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	95250513          	addi	a0,a0,-1710 # ffffffffc0201e88 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	95c50513          	addi	a0,a0,-1700 # ffffffffc0201ea0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	96650513          	addi	a0,a0,-1690 # ffffffffc0201eb8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	97050513          	addi	a0,a0,-1680 # ffffffffc0201ed0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201ee8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	98450513          	addi	a0,a0,-1660 # ffffffffc0201f00 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	98e50513          	addi	a0,a0,-1650 # ffffffffc0201f18 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	99850513          	addi	a0,a0,-1640 # ffffffffc0201f30 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201f48 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0201f60 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9b650513          	addi	a0,a0,-1610 # ffffffffc0201f78 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9c050513          	addi	a0,a0,-1600 # ffffffffc0201f90 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0201fa8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9d450513          	addi	a0,a0,-1580 # ffffffffc0201fc0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9de50513          	addi	a0,a0,-1570 # ffffffffc0201fd8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0201ff0 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0202008 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0202020 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0202038 <commands+0x370>
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
ffffffffc020064e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0202050 <commands+0x388>
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
ffffffffc0200666:	a0650513          	addi	a0,a0,-1530 # ffffffffc0202068 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0202080 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	a1650513          	addi	a0,a0,-1514 # ffffffffc0202098 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02020b0 <commands+0x3e8>
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
ffffffffc02006b4:	ae070713          	addi	a4,a4,-1312 # ffffffffc0202190 <commands+0x4c8>
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
ffffffffc02006c6:	a6650513          	addi	a0,a0,-1434 # ffffffffc0202128 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0202108 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	9f250513          	addi	a0,a0,-1550 # ffffffffc02020c8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a6850513          	addi	a0,a0,-1432 # ffffffffc0202148 <commands+0x480>
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
ffffffffc0200728:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0202170 <commands+0x4a8>
ffffffffc020072c:	b259                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020072e:	00002517          	auipc	a0,0x2
ffffffffc0200732:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02020e8 <commands+0x420>
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200738:	b729                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073a:	06400593          	li	a1,100
ffffffffc020073e:	00002517          	auipc	a0,0x2
ffffffffc0200742:	a2250513          	addi	a0,a0,-1502 # ffffffffc0202160 <commands+0x498>
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
ffffffffc0200758:	2980106f          	j	ffffffffc02019f0 <sbi_shutdown>

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
ffffffffc020077c:	a4850513          	addi	a0,a0,-1464 # ffffffffc02021c0 <commands+0x4f8>
ffffffffc0200780:	933ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200784:	10843583          	ld	a1,264(s0)
ffffffffc0200788:	00002517          	auipc	a0,0x2
ffffffffc020078c:	a6050513          	addi	a0,a0,-1440 # ffffffffc02021e8 <commands+0x520>
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
ffffffffc02007ba:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0202210 <commands+0x548>
ffffffffc02007be:	8f5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc02007c2:	10843583          	ld	a1,264(s0)
ffffffffc02007c6:	00002517          	auipc	a0,0x2
ffffffffc02007ca:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0202230 <commands+0x568>
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

ffffffffc02008a6 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008a6:	00005797          	auipc	a5,0x5
ffffffffc02008aa:	77278793          	addi	a5,a5,1906 # ffffffffc0206018 <free_area>
ffffffffc02008ae:	e79c                	sd	a5,8(a5)
ffffffffc02008b0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02008b2:	0007a823          	sw	zero,16(a5)
}
ffffffffc02008b6:	8082                	ret

ffffffffc02008b8 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02008b8:	00005517          	auipc	a0,0x5
ffffffffc02008bc:	77056503          	lwu	a0,1904(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc02008c0:	8082                	ret

ffffffffc02008c2 <best_fit_alloc_pages>:
    assert(n > 0); // 确保请求的页面数量大于0
ffffffffc02008c2:	c14d                	beqz	a0,ffffffffc0200964 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc02008c4:	00005617          	auipc	a2,0x5
ffffffffc02008c8:	75460613          	addi	a2,a2,1876 # ffffffffc0206018 <free_area>
ffffffffc02008cc:	01062803          	lw	a6,16(a2)
ffffffffc02008d0:	86aa                	mv	a3,a0
ffffffffc02008d2:	02081793          	slli	a5,a6,0x20
ffffffffc02008d6:	9381                	srli	a5,a5,0x20
ffffffffc02008d8:	08a7e463          	bltu	a5,a0,ffffffffc0200960 <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008dc:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1; // 初始化最小连续空闲页框的数量
ffffffffc02008de:	0018059b          	addiw	a1,a6,1
ffffffffc02008e2:	1582                	slli	a1,a1,0x20
ffffffffc02008e4:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL; // 用于存放找到的页面
ffffffffc02008e6:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008e8:	06c78b63          	beq	a5,a2,ffffffffc020095e <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) {
ffffffffc02008ec:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02008f0:	00d76763          	bltu	a4,a3,ffffffffc02008fe <best_fit_alloc_pages+0x3c>
ffffffffc02008f4:	00b77563          	bgeu	a4,a1,ffffffffc02008fe <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc02008f8:	fe878513          	addi	a0,a5,-24
ffffffffc02008fc:	85ba                	mv	a1,a4
ffffffffc02008fe:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200900:	fec796e3          	bne	a5,a2,ffffffffc02008ec <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200904:	cd29                	beqz	a0,ffffffffc020095e <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200906:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200908:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc020090a:	490c                	lw	a1,16(a0)
            p->property = page->property - n;  // 设置剩余页面的属性
ffffffffc020090c:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200910:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200912:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200914:	02059793          	slli	a5,a1,0x20
ffffffffc0200918:	9381                	srli	a5,a5,0x20
ffffffffc020091a:	02f6f863          	bgeu	a3,a5,ffffffffc020094a <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;  // 获取剩余页面的起始地址
ffffffffc020091e:	00269793          	slli	a5,a3,0x2
ffffffffc0200922:	97b6                	add	a5,a5,a3
ffffffffc0200924:	078e                	slli	a5,a5,0x3
ffffffffc0200926:	97aa                	add	a5,a5,a0
            p->property = page->property - n;  // 设置剩余页面的属性
ffffffffc0200928:	411585bb          	subw	a1,a1,a7
ffffffffc020092c:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020092e:	4689                	li	a3,2
ffffffffc0200930:	00878593          	addi	a1,a5,8
ffffffffc0200934:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200938:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));  // 将剩余页面插入链表
ffffffffc020093a:	01878593          	addi	a1,a5,24
        nr_free -= n;  // 更新总的空闲页面数量
ffffffffc020093e:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200942:	e28c                	sd	a1,0(a3)
ffffffffc0200944:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200946:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200948:	ef98                	sd	a4,24(a5)
ffffffffc020094a:	4118083b          	subw	a6,a6,a7
ffffffffc020094e:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200952:	57f5                	li	a5,-3
ffffffffc0200954:	00850713          	addi	a4,a0,8
ffffffffc0200958:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc020095c:	8082                	ret
}
ffffffffc020095e:	8082                	ret
        return NULL; // 如果请求的页面数量超过可用页面，返回NULL
ffffffffc0200960:	4501                	li	a0,0
ffffffffc0200962:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200964:	1141                	addi	sp,sp,-16
    assert(n > 0); // 确保请求的页面数量大于0
ffffffffc0200966:	00002697          	auipc	a3,0x2
ffffffffc020096a:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0202250 <commands+0x588>
ffffffffc020096e:	00002617          	auipc	a2,0x2
ffffffffc0200972:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0202258 <commands+0x590>
ffffffffc0200976:	06e00593          	li	a1,110
ffffffffc020097a:	00002517          	auipc	a0,0x2
ffffffffc020097e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0202270 <commands+0x5a8>
best_fit_alloc_pages(size_t n) {
ffffffffc0200982:	e406                	sd	ra,8(sp)
    assert(n > 0); // 确保请求的页面数量大于0
ffffffffc0200984:	a29ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200988 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200988:	715d                	addi	sp,sp,-80
ffffffffc020098a:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020098c:	00005417          	auipc	s0,0x5
ffffffffc0200990:	68c40413          	addi	s0,s0,1676 # ffffffffc0206018 <free_area>
ffffffffc0200994:	641c                	ld	a5,8(s0)
ffffffffc0200996:	e486                	sd	ra,72(sp)
ffffffffc0200998:	fc26                	sd	s1,56(sp)
ffffffffc020099a:	f84a                	sd	s2,48(sp)
ffffffffc020099c:	f44e                	sd	s3,40(sp)
ffffffffc020099e:	f052                	sd	s4,32(sp)
ffffffffc02009a0:	ec56                	sd	s5,24(sp)
ffffffffc02009a2:	e85a                	sd	s6,16(sp)
ffffffffc02009a4:	e45e                	sd	s7,8(sp)
ffffffffc02009a6:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009a8:	26878b63          	beq	a5,s0,ffffffffc0200c1e <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc02009ac:	4481                	li	s1,0
ffffffffc02009ae:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009b0:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02009b4:	8b09                	andi	a4,a4,2
ffffffffc02009b6:	26070863          	beqz	a4,ffffffffc0200c26 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc02009ba:	ff87a703          	lw	a4,-8(a5)
ffffffffc02009be:	679c                	ld	a5,8(a5)
ffffffffc02009c0:	2905                	addiw	s2,s2,1
ffffffffc02009c2:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009c4:	fe8796e3          	bne	a5,s0,ffffffffc02009b0 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02009c8:	89a6                	mv	s3,s1
ffffffffc02009ca:	167000ef          	jal	ra,ffffffffc0201330 <nr_free_pages>
ffffffffc02009ce:	33351c63          	bne	a0,s3,ffffffffc0200d06 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02009d2:	4505                	li	a0,1
ffffffffc02009d4:	0df000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc02009d8:	8a2a                	mv	s4,a0
ffffffffc02009da:	36050663          	beqz	a0,ffffffffc0200d46 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009de:	4505                	li	a0,1
ffffffffc02009e0:	0d3000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc02009e4:	89aa                	mv	s3,a0
ffffffffc02009e6:	34050063          	beqz	a0,ffffffffc0200d26 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009ea:	4505                	li	a0,1
ffffffffc02009ec:	0c7000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc02009f0:	8aaa                	mv	s5,a0
ffffffffc02009f2:	2c050a63          	beqz	a0,ffffffffc0200cc6 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02009f6:	253a0863          	beq	s4,s3,ffffffffc0200c46 <best_fit_check+0x2be>
ffffffffc02009fa:	24aa0663          	beq	s4,a0,ffffffffc0200c46 <best_fit_check+0x2be>
ffffffffc02009fe:	24a98463          	beq	s3,a0,ffffffffc0200c46 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200a02:	000a2783          	lw	a5,0(s4)
ffffffffc0200a06:	26079063          	bnez	a5,ffffffffc0200c66 <best_fit_check+0x2de>
ffffffffc0200a0a:	0009a783          	lw	a5,0(s3)
ffffffffc0200a0e:	24079c63          	bnez	a5,ffffffffc0200c66 <best_fit_check+0x2de>
ffffffffc0200a12:	411c                	lw	a5,0(a0)
ffffffffc0200a14:	24079963          	bnez	a5,ffffffffc0200c66 <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a18:	00006797          	auipc	a5,0x6
ffffffffc0200a1c:	a387b783          	ld	a5,-1480(a5) # ffffffffc0206450 <pages>
ffffffffc0200a20:	40fa0733          	sub	a4,s4,a5
ffffffffc0200a24:	870d                	srai	a4,a4,0x3
ffffffffc0200a26:	00002597          	auipc	a1,0x2
ffffffffc0200a2a:	f1a5b583          	ld	a1,-230(a1) # ffffffffc0202940 <error_string+0x38>
ffffffffc0200a2e:	02b70733          	mul	a4,a4,a1
ffffffffc0200a32:	00002617          	auipc	a2,0x2
ffffffffc0200a36:	f1663603          	ld	a2,-234(a2) # ffffffffc0202948 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200a3a:	00006697          	auipc	a3,0x6
ffffffffc0200a3e:	a0e6b683          	ld	a3,-1522(a3) # ffffffffc0206448 <npage>
ffffffffc0200a42:	06b2                	slli	a3,a3,0xc
ffffffffc0200a44:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a46:	0732                	slli	a4,a4,0xc
ffffffffc0200a48:	22d77f63          	bgeu	a4,a3,ffffffffc0200c86 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a4c:	40f98733          	sub	a4,s3,a5
ffffffffc0200a50:	870d                	srai	a4,a4,0x3
ffffffffc0200a52:	02b70733          	mul	a4,a4,a1
ffffffffc0200a56:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a58:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a5a:	3ed77663          	bgeu	a4,a3,ffffffffc0200e46 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a5e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a62:	878d                	srai	a5,a5,0x3
ffffffffc0200a64:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a68:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a6a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a6c:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200e26 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200a70:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a72:	00043c03          	ld	s8,0(s0)
ffffffffc0200a76:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a7a:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200a7e:	e400                	sd	s0,8(s0)
ffffffffc0200a80:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200a82:	00005797          	auipc	a5,0x5
ffffffffc0200a86:	5a07a323          	sw	zero,1446(a5) # ffffffffc0206028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a8a:	029000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200a8e:	36051c63          	bnez	a0,ffffffffc0200e06 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200a92:	4585                	li	a1,1
ffffffffc0200a94:	8552                	mv	a0,s4
ffffffffc0200a96:	05b000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    free_page(p1);
ffffffffc0200a9a:	4585                	li	a1,1
ffffffffc0200a9c:	854e                	mv	a0,s3
ffffffffc0200a9e:	053000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    free_page(p2);
ffffffffc0200aa2:	4585                	li	a1,1
ffffffffc0200aa4:	8556                	mv	a0,s5
ffffffffc0200aa6:	04b000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    assert(nr_free == 3);
ffffffffc0200aaa:	4818                	lw	a4,16(s0)
ffffffffc0200aac:	478d                	li	a5,3
ffffffffc0200aae:	32f71c63          	bne	a4,a5,ffffffffc0200de6 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ab2:	4505                	li	a0,1
ffffffffc0200ab4:	7fe000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200ab8:	89aa                	mv	s3,a0
ffffffffc0200aba:	30050663          	beqz	a0,ffffffffc0200dc6 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200abe:	4505                	li	a0,1
ffffffffc0200ac0:	7f2000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200ac4:	8aaa                	mv	s5,a0
ffffffffc0200ac6:	2e050063          	beqz	a0,ffffffffc0200da6 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200aca:	4505                	li	a0,1
ffffffffc0200acc:	7e6000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200ad0:	8a2a                	mv	s4,a0
ffffffffc0200ad2:	2a050a63          	beqz	a0,ffffffffc0200d86 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200ad6:	4505                	li	a0,1
ffffffffc0200ad8:	7da000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200adc:	28051563          	bnez	a0,ffffffffc0200d66 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200ae0:	4585                	li	a1,1
ffffffffc0200ae2:	854e                	mv	a0,s3
ffffffffc0200ae4:	00d000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ae8:	641c                	ld	a5,8(s0)
ffffffffc0200aea:	1a878e63          	beq	a5,s0,ffffffffc0200ca6 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200aee:	4505                	li	a0,1
ffffffffc0200af0:	7c2000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200af4:	52a99963          	bne	s3,a0,ffffffffc0201026 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200af8:	4505                	li	a0,1
ffffffffc0200afa:	7b8000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200afe:	50051463          	bnez	a0,ffffffffc0201006 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200b02:	481c                	lw	a5,16(s0)
ffffffffc0200b04:	4e079163          	bnez	a5,ffffffffc0200fe6 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200b08:	854e                	mv	a0,s3
ffffffffc0200b0a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200b0c:	01843023          	sd	s8,0(s0)
ffffffffc0200b10:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200b14:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200b18:	7d8000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    free_page(p1);
ffffffffc0200b1c:	4585                	li	a1,1
ffffffffc0200b1e:	8556                	mv	a0,s5
ffffffffc0200b20:	7d0000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    free_page(p2);
ffffffffc0200b24:	4585                	li	a1,1
ffffffffc0200b26:	8552                	mv	a0,s4
ffffffffc0200b28:	7c8000ef          	jal	ra,ffffffffc02012f0 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200b2c:	4515                	li	a0,5
ffffffffc0200b2e:	784000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200b32:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200b34:	48050963          	beqz	a0,ffffffffc0200fc6 <best_fit_check+0x63e>
ffffffffc0200b38:	651c                	ld	a5,8(a0)
ffffffffc0200b3a:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200b3c:	8b85                	andi	a5,a5,1
ffffffffc0200b3e:	46079463          	bnez	a5,ffffffffc0200fa6 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b42:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b44:	00043a83          	ld	s5,0(s0)
ffffffffc0200b48:	00843a03          	ld	s4,8(s0)
ffffffffc0200b4c:	e000                	sd	s0,0(s0)
ffffffffc0200b4e:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200b50:	762000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200b54:	42051963          	bnez	a0,ffffffffc0200f86 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b58:	4589                	li	a1,2
ffffffffc0200b5a:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b5e:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200b62:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b66:	00005797          	auipc	a5,0x5
ffffffffc0200b6a:	4c07a123          	sw	zero,1218(a5) # ffffffffc0206028 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b6e:	782000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b72:	8562                	mv	a0,s8
ffffffffc0200b74:	4585                	li	a1,1
ffffffffc0200b76:	77a000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b7a:	4511                	li	a0,4
ffffffffc0200b7c:	736000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200b80:	3e051363          	bnez	a0,ffffffffc0200f66 <best_fit_check+0x5de>
ffffffffc0200b84:	0309b783          	ld	a5,48(s3)
ffffffffc0200b88:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b8a:	8b85                	andi	a5,a5,1
ffffffffc0200b8c:	3a078d63          	beqz	a5,ffffffffc0200f46 <best_fit_check+0x5be>
ffffffffc0200b90:	0389a703          	lw	a4,56(s3)
ffffffffc0200b94:	4789                	li	a5,2
ffffffffc0200b96:	3af71863          	bne	a4,a5,ffffffffc0200f46 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b9a:	4505                	li	a0,1
ffffffffc0200b9c:	716000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200ba0:	8baa                	mv	s7,a0
ffffffffc0200ba2:	38050263          	beqz	a0,ffffffffc0200f26 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ba6:	4509                	li	a0,2
ffffffffc0200ba8:	70a000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200bac:	34050d63          	beqz	a0,ffffffffc0200f06 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200bb0:	337c1b63          	bne	s8,s7,ffffffffc0200ee6 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200bb4:	854e                	mv	a0,s3
ffffffffc0200bb6:	4595                	li	a1,5
ffffffffc0200bb8:	738000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200bbc:	4515                	li	a0,5
ffffffffc0200bbe:	6f4000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200bc2:	89aa                	mv	s3,a0
ffffffffc0200bc4:	30050163          	beqz	a0,ffffffffc0200ec6 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200bc8:	4505                	li	a0,1
ffffffffc0200bca:	6e8000ef          	jal	ra,ffffffffc02012b2 <alloc_pages>
ffffffffc0200bce:	2c051c63          	bnez	a0,ffffffffc0200ea6 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200bd2:	481c                	lw	a5,16(s0)
ffffffffc0200bd4:	2a079963          	bnez	a5,ffffffffc0200e86 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200bd8:	4595                	li	a1,5
ffffffffc0200bda:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200bdc:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200be0:	01543023          	sd	s5,0(s0)
ffffffffc0200be4:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200be8:	708000ef          	jal	ra,ffffffffc02012f0 <free_pages>
    return listelm->next;
ffffffffc0200bec:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bee:	00878963          	beq	a5,s0,ffffffffc0200c00 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bf2:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bf6:	679c                	ld	a5,8(a5)
ffffffffc0200bf8:	397d                	addiw	s2,s2,-1
ffffffffc0200bfa:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bfc:	fe879be3          	bne	a5,s0,ffffffffc0200bf2 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200c00:	26091363          	bnez	s2,ffffffffc0200e66 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200c04:	e0ed                	bnez	s1,ffffffffc0200ce6 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200c06:	60a6                	ld	ra,72(sp)
ffffffffc0200c08:	6406                	ld	s0,64(sp)
ffffffffc0200c0a:	74e2                	ld	s1,56(sp)
ffffffffc0200c0c:	7942                	ld	s2,48(sp)
ffffffffc0200c0e:	79a2                	ld	s3,40(sp)
ffffffffc0200c10:	7a02                	ld	s4,32(sp)
ffffffffc0200c12:	6ae2                	ld	s5,24(sp)
ffffffffc0200c14:	6b42                	ld	s6,16(sp)
ffffffffc0200c16:	6ba2                	ld	s7,8(sp)
ffffffffc0200c18:	6c02                	ld	s8,0(sp)
ffffffffc0200c1a:	6161                	addi	sp,sp,80
ffffffffc0200c1c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c1e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200c20:	4481                	li	s1,0
ffffffffc0200c22:	4901                	li	s2,0
ffffffffc0200c24:	b35d                	j	ffffffffc02009ca <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200c26:	00001697          	auipc	a3,0x1
ffffffffc0200c2a:	66268693          	addi	a3,a3,1634 # ffffffffc0202288 <commands+0x5c0>
ffffffffc0200c2e:	00001617          	auipc	a2,0x1
ffffffffc0200c32:	62a60613          	addi	a2,a2,1578 # ffffffffc0202258 <commands+0x590>
ffffffffc0200c36:	12400593          	li	a1,292
ffffffffc0200c3a:	00001517          	auipc	a0,0x1
ffffffffc0200c3e:	63650513          	addi	a0,a0,1590 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200c42:	f6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c46:	00001697          	auipc	a3,0x1
ffffffffc0200c4a:	6d268693          	addi	a3,a3,1746 # ffffffffc0202318 <commands+0x650>
ffffffffc0200c4e:	00001617          	auipc	a2,0x1
ffffffffc0200c52:	60a60613          	addi	a2,a2,1546 # ffffffffc0202258 <commands+0x590>
ffffffffc0200c56:	0f000593          	li	a1,240
ffffffffc0200c5a:	00001517          	auipc	a0,0x1
ffffffffc0200c5e:	61650513          	addi	a0,a0,1558 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200c62:	f4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c66:	00001697          	auipc	a3,0x1
ffffffffc0200c6a:	6da68693          	addi	a3,a3,1754 # ffffffffc0202340 <commands+0x678>
ffffffffc0200c6e:	00001617          	auipc	a2,0x1
ffffffffc0200c72:	5ea60613          	addi	a2,a2,1514 # ffffffffc0202258 <commands+0x590>
ffffffffc0200c76:	0f100593          	li	a1,241
ffffffffc0200c7a:	00001517          	auipc	a0,0x1
ffffffffc0200c7e:	5f650513          	addi	a0,a0,1526 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200c82:	f2aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c86:	00001697          	auipc	a3,0x1
ffffffffc0200c8a:	6fa68693          	addi	a3,a3,1786 # ffffffffc0202380 <commands+0x6b8>
ffffffffc0200c8e:	00001617          	auipc	a2,0x1
ffffffffc0200c92:	5ca60613          	addi	a2,a2,1482 # ffffffffc0202258 <commands+0x590>
ffffffffc0200c96:	0f300593          	li	a1,243
ffffffffc0200c9a:	00001517          	auipc	a0,0x1
ffffffffc0200c9e:	5d650513          	addi	a0,a0,1494 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200ca2:	f0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ca6:	00001697          	auipc	a3,0x1
ffffffffc0200caa:	76268693          	addi	a3,a3,1890 # ffffffffc0202408 <commands+0x740>
ffffffffc0200cae:	00001617          	auipc	a2,0x1
ffffffffc0200cb2:	5aa60613          	addi	a2,a2,1450 # ffffffffc0202258 <commands+0x590>
ffffffffc0200cb6:	10c00593          	li	a1,268
ffffffffc0200cba:	00001517          	auipc	a0,0x1
ffffffffc0200cbe:	5b650513          	addi	a0,a0,1462 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200cc2:	eeaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cc6:	00001697          	auipc	a3,0x1
ffffffffc0200cca:	63268693          	addi	a3,a3,1586 # ffffffffc02022f8 <commands+0x630>
ffffffffc0200cce:	00001617          	auipc	a2,0x1
ffffffffc0200cd2:	58a60613          	addi	a2,a2,1418 # ffffffffc0202258 <commands+0x590>
ffffffffc0200cd6:	0ee00593          	li	a1,238
ffffffffc0200cda:	00001517          	auipc	a0,0x1
ffffffffc0200cde:	59650513          	addi	a0,a0,1430 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200ce2:	ecaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200ce6:	00002697          	auipc	a3,0x2
ffffffffc0200cea:	85268693          	addi	a3,a3,-1966 # ffffffffc0202538 <commands+0x870>
ffffffffc0200cee:	00001617          	auipc	a2,0x1
ffffffffc0200cf2:	56a60613          	addi	a2,a2,1386 # ffffffffc0202258 <commands+0x590>
ffffffffc0200cf6:	16600593          	li	a1,358
ffffffffc0200cfa:	00001517          	auipc	a0,0x1
ffffffffc0200cfe:	57650513          	addi	a0,a0,1398 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200d02:	eaaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200d06:	00001697          	auipc	a3,0x1
ffffffffc0200d0a:	59268693          	addi	a3,a3,1426 # ffffffffc0202298 <commands+0x5d0>
ffffffffc0200d0e:	00001617          	auipc	a2,0x1
ffffffffc0200d12:	54a60613          	addi	a2,a2,1354 # ffffffffc0202258 <commands+0x590>
ffffffffc0200d16:	12700593          	li	a1,295
ffffffffc0200d1a:	00001517          	auipc	a0,0x1
ffffffffc0200d1e:	55650513          	addi	a0,a0,1366 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200d22:	e8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d26:	00001697          	auipc	a3,0x1
ffffffffc0200d2a:	5b268693          	addi	a3,a3,1458 # ffffffffc02022d8 <commands+0x610>
ffffffffc0200d2e:	00001617          	auipc	a2,0x1
ffffffffc0200d32:	52a60613          	addi	a2,a2,1322 # ffffffffc0202258 <commands+0x590>
ffffffffc0200d36:	0ed00593          	li	a1,237
ffffffffc0200d3a:	00001517          	auipc	a0,0x1
ffffffffc0200d3e:	53650513          	addi	a0,a0,1334 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200d42:	e6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d46:	00001697          	auipc	a3,0x1
ffffffffc0200d4a:	57268693          	addi	a3,a3,1394 # ffffffffc02022b8 <commands+0x5f0>
ffffffffc0200d4e:	00001617          	auipc	a2,0x1
ffffffffc0200d52:	50a60613          	addi	a2,a2,1290 # ffffffffc0202258 <commands+0x590>
ffffffffc0200d56:	0ec00593          	li	a1,236
ffffffffc0200d5a:	00001517          	auipc	a0,0x1
ffffffffc0200d5e:	51650513          	addi	a0,a0,1302 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200d62:	e4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d66:	00001697          	auipc	a3,0x1
ffffffffc0200d6a:	67a68693          	addi	a3,a3,1658 # ffffffffc02023e0 <commands+0x718>
ffffffffc0200d6e:	00001617          	auipc	a2,0x1
ffffffffc0200d72:	4ea60613          	addi	a2,a2,1258 # ffffffffc0202258 <commands+0x590>
ffffffffc0200d76:	10900593          	li	a1,265
ffffffffc0200d7a:	00001517          	auipc	a0,0x1
ffffffffc0200d7e:	4f650513          	addi	a0,a0,1270 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200d82:	e2aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d86:	00001697          	auipc	a3,0x1
ffffffffc0200d8a:	57268693          	addi	a3,a3,1394 # ffffffffc02022f8 <commands+0x630>
ffffffffc0200d8e:	00001617          	auipc	a2,0x1
ffffffffc0200d92:	4ca60613          	addi	a2,a2,1226 # ffffffffc0202258 <commands+0x590>
ffffffffc0200d96:	10700593          	li	a1,263
ffffffffc0200d9a:	00001517          	auipc	a0,0x1
ffffffffc0200d9e:	4d650513          	addi	a0,a0,1238 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200da2:	e0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200da6:	00001697          	auipc	a3,0x1
ffffffffc0200daa:	53268693          	addi	a3,a3,1330 # ffffffffc02022d8 <commands+0x610>
ffffffffc0200dae:	00001617          	auipc	a2,0x1
ffffffffc0200db2:	4aa60613          	addi	a2,a2,1194 # ffffffffc0202258 <commands+0x590>
ffffffffc0200db6:	10600593          	li	a1,262
ffffffffc0200dba:	00001517          	auipc	a0,0x1
ffffffffc0200dbe:	4b650513          	addi	a0,a0,1206 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200dc2:	deaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dc6:	00001697          	auipc	a3,0x1
ffffffffc0200dca:	4f268693          	addi	a3,a3,1266 # ffffffffc02022b8 <commands+0x5f0>
ffffffffc0200dce:	00001617          	auipc	a2,0x1
ffffffffc0200dd2:	48a60613          	addi	a2,a2,1162 # ffffffffc0202258 <commands+0x590>
ffffffffc0200dd6:	10500593          	li	a1,261
ffffffffc0200dda:	00001517          	auipc	a0,0x1
ffffffffc0200dde:	49650513          	addi	a0,a0,1174 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200de2:	dcaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200de6:	00001697          	auipc	a3,0x1
ffffffffc0200dea:	61268693          	addi	a3,a3,1554 # ffffffffc02023f8 <commands+0x730>
ffffffffc0200dee:	00001617          	auipc	a2,0x1
ffffffffc0200df2:	46a60613          	addi	a2,a2,1130 # ffffffffc0202258 <commands+0x590>
ffffffffc0200df6:	10300593          	li	a1,259
ffffffffc0200dfa:	00001517          	auipc	a0,0x1
ffffffffc0200dfe:	47650513          	addi	a0,a0,1142 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200e02:	daaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e06:	00001697          	auipc	a3,0x1
ffffffffc0200e0a:	5da68693          	addi	a3,a3,1498 # ffffffffc02023e0 <commands+0x718>
ffffffffc0200e0e:	00001617          	auipc	a2,0x1
ffffffffc0200e12:	44a60613          	addi	a2,a2,1098 # ffffffffc0202258 <commands+0x590>
ffffffffc0200e16:	0fe00593          	li	a1,254
ffffffffc0200e1a:	00001517          	auipc	a0,0x1
ffffffffc0200e1e:	45650513          	addi	a0,a0,1110 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200e22:	d8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e26:	00001697          	auipc	a3,0x1
ffffffffc0200e2a:	59a68693          	addi	a3,a3,1434 # ffffffffc02023c0 <commands+0x6f8>
ffffffffc0200e2e:	00001617          	auipc	a2,0x1
ffffffffc0200e32:	42a60613          	addi	a2,a2,1066 # ffffffffc0202258 <commands+0x590>
ffffffffc0200e36:	0f500593          	li	a1,245
ffffffffc0200e3a:	00001517          	auipc	a0,0x1
ffffffffc0200e3e:	43650513          	addi	a0,a0,1078 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200e42:	d6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e46:	00001697          	auipc	a3,0x1
ffffffffc0200e4a:	55a68693          	addi	a3,a3,1370 # ffffffffc02023a0 <commands+0x6d8>
ffffffffc0200e4e:	00001617          	auipc	a2,0x1
ffffffffc0200e52:	40a60613          	addi	a2,a2,1034 # ffffffffc0202258 <commands+0x590>
ffffffffc0200e56:	0f400593          	li	a1,244
ffffffffc0200e5a:	00001517          	auipc	a0,0x1
ffffffffc0200e5e:	41650513          	addi	a0,a0,1046 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200e62:	d4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e66:	00001697          	auipc	a3,0x1
ffffffffc0200e6a:	6c268693          	addi	a3,a3,1730 # ffffffffc0202528 <commands+0x860>
ffffffffc0200e6e:	00001617          	auipc	a2,0x1
ffffffffc0200e72:	3ea60613          	addi	a2,a2,1002 # ffffffffc0202258 <commands+0x590>
ffffffffc0200e76:	16500593          	li	a1,357
ffffffffc0200e7a:	00001517          	auipc	a0,0x1
ffffffffc0200e7e:	3f650513          	addi	a0,a0,1014 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200e82:	d2aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e86:	00001697          	auipc	a3,0x1
ffffffffc0200e8a:	5ba68693          	addi	a3,a3,1466 # ffffffffc0202440 <commands+0x778>
ffffffffc0200e8e:	00001617          	auipc	a2,0x1
ffffffffc0200e92:	3ca60613          	addi	a2,a2,970 # ffffffffc0202258 <commands+0x590>
ffffffffc0200e96:	15a00593          	li	a1,346
ffffffffc0200e9a:	00001517          	auipc	a0,0x1
ffffffffc0200e9e:	3d650513          	addi	a0,a0,982 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200ea2:	d0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ea6:	00001697          	auipc	a3,0x1
ffffffffc0200eaa:	53a68693          	addi	a3,a3,1338 # ffffffffc02023e0 <commands+0x718>
ffffffffc0200eae:	00001617          	auipc	a2,0x1
ffffffffc0200eb2:	3aa60613          	addi	a2,a2,938 # ffffffffc0202258 <commands+0x590>
ffffffffc0200eb6:	15400593          	li	a1,340
ffffffffc0200eba:	00001517          	auipc	a0,0x1
ffffffffc0200ebe:	3b650513          	addi	a0,a0,950 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200ec2:	ceaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ec6:	00001697          	auipc	a3,0x1
ffffffffc0200eca:	64268693          	addi	a3,a3,1602 # ffffffffc0202508 <commands+0x840>
ffffffffc0200ece:	00001617          	auipc	a2,0x1
ffffffffc0200ed2:	38a60613          	addi	a2,a2,906 # ffffffffc0202258 <commands+0x590>
ffffffffc0200ed6:	15300593          	li	a1,339
ffffffffc0200eda:	00001517          	auipc	a0,0x1
ffffffffc0200ede:	39650513          	addi	a0,a0,918 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200ee2:	ccaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ee6:	00001697          	auipc	a3,0x1
ffffffffc0200eea:	61268693          	addi	a3,a3,1554 # ffffffffc02024f8 <commands+0x830>
ffffffffc0200eee:	00001617          	auipc	a2,0x1
ffffffffc0200ef2:	36a60613          	addi	a2,a2,874 # ffffffffc0202258 <commands+0x590>
ffffffffc0200ef6:	14b00593          	li	a1,331
ffffffffc0200efa:	00001517          	auipc	a0,0x1
ffffffffc0200efe:	37650513          	addi	a0,a0,886 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200f02:	caaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200f06:	00001697          	auipc	a3,0x1
ffffffffc0200f0a:	5da68693          	addi	a3,a3,1498 # ffffffffc02024e0 <commands+0x818>
ffffffffc0200f0e:	00001617          	auipc	a2,0x1
ffffffffc0200f12:	34a60613          	addi	a2,a2,842 # ffffffffc0202258 <commands+0x590>
ffffffffc0200f16:	14a00593          	li	a1,330
ffffffffc0200f1a:	00001517          	auipc	a0,0x1
ffffffffc0200f1e:	35650513          	addi	a0,a0,854 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200f22:	c8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f26:	00001697          	auipc	a3,0x1
ffffffffc0200f2a:	59a68693          	addi	a3,a3,1434 # ffffffffc02024c0 <commands+0x7f8>
ffffffffc0200f2e:	00001617          	auipc	a2,0x1
ffffffffc0200f32:	32a60613          	addi	a2,a2,810 # ffffffffc0202258 <commands+0x590>
ffffffffc0200f36:	14900593          	li	a1,329
ffffffffc0200f3a:	00001517          	auipc	a0,0x1
ffffffffc0200f3e:	33650513          	addi	a0,a0,822 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200f42:	c6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f46:	00001697          	auipc	a3,0x1
ffffffffc0200f4a:	54a68693          	addi	a3,a3,1354 # ffffffffc0202490 <commands+0x7c8>
ffffffffc0200f4e:	00001617          	auipc	a2,0x1
ffffffffc0200f52:	30a60613          	addi	a2,a2,778 # ffffffffc0202258 <commands+0x590>
ffffffffc0200f56:	14700593          	li	a1,327
ffffffffc0200f5a:	00001517          	auipc	a0,0x1
ffffffffc0200f5e:	31650513          	addi	a0,a0,790 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200f62:	c4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f66:	00001697          	auipc	a3,0x1
ffffffffc0200f6a:	51268693          	addi	a3,a3,1298 # ffffffffc0202478 <commands+0x7b0>
ffffffffc0200f6e:	00001617          	auipc	a2,0x1
ffffffffc0200f72:	2ea60613          	addi	a2,a2,746 # ffffffffc0202258 <commands+0x590>
ffffffffc0200f76:	14600593          	li	a1,326
ffffffffc0200f7a:	00001517          	auipc	a0,0x1
ffffffffc0200f7e:	2f650513          	addi	a0,a0,758 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200f82:	c2aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f86:	00001697          	auipc	a3,0x1
ffffffffc0200f8a:	45a68693          	addi	a3,a3,1114 # ffffffffc02023e0 <commands+0x718>
ffffffffc0200f8e:	00001617          	auipc	a2,0x1
ffffffffc0200f92:	2ca60613          	addi	a2,a2,714 # ffffffffc0202258 <commands+0x590>
ffffffffc0200f96:	13a00593          	li	a1,314
ffffffffc0200f9a:	00001517          	auipc	a0,0x1
ffffffffc0200f9e:	2d650513          	addi	a0,a0,726 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200fa2:	c0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200fa6:	00001697          	auipc	a3,0x1
ffffffffc0200faa:	4ba68693          	addi	a3,a3,1210 # ffffffffc0202460 <commands+0x798>
ffffffffc0200fae:	00001617          	auipc	a2,0x1
ffffffffc0200fb2:	2aa60613          	addi	a2,a2,682 # ffffffffc0202258 <commands+0x590>
ffffffffc0200fb6:	13100593          	li	a1,305
ffffffffc0200fba:	00001517          	auipc	a0,0x1
ffffffffc0200fbe:	2b650513          	addi	a0,a0,694 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200fc2:	beaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200fc6:	00001697          	auipc	a3,0x1
ffffffffc0200fca:	48a68693          	addi	a3,a3,1162 # ffffffffc0202450 <commands+0x788>
ffffffffc0200fce:	00001617          	auipc	a2,0x1
ffffffffc0200fd2:	28a60613          	addi	a2,a2,650 # ffffffffc0202258 <commands+0x590>
ffffffffc0200fd6:	13000593          	li	a1,304
ffffffffc0200fda:	00001517          	auipc	a0,0x1
ffffffffc0200fde:	29650513          	addi	a0,a0,662 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0200fe2:	bcaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200fe6:	00001697          	auipc	a3,0x1
ffffffffc0200fea:	45a68693          	addi	a3,a3,1114 # ffffffffc0202440 <commands+0x778>
ffffffffc0200fee:	00001617          	auipc	a2,0x1
ffffffffc0200ff2:	26a60613          	addi	a2,a2,618 # ffffffffc0202258 <commands+0x590>
ffffffffc0200ff6:	11200593          	li	a1,274
ffffffffc0200ffa:	00001517          	auipc	a0,0x1
ffffffffc0200ffe:	27650513          	addi	a0,a0,630 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0201002:	baaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201006:	00001697          	auipc	a3,0x1
ffffffffc020100a:	3da68693          	addi	a3,a3,986 # ffffffffc02023e0 <commands+0x718>
ffffffffc020100e:	00001617          	auipc	a2,0x1
ffffffffc0201012:	24a60613          	addi	a2,a2,586 # ffffffffc0202258 <commands+0x590>
ffffffffc0201016:	11000593          	li	a1,272
ffffffffc020101a:	00001517          	auipc	a0,0x1
ffffffffc020101e:	25650513          	addi	a0,a0,598 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0201022:	b8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201026:	00001697          	auipc	a3,0x1
ffffffffc020102a:	3fa68693          	addi	a3,a3,1018 # ffffffffc0202420 <commands+0x758>
ffffffffc020102e:	00001617          	auipc	a2,0x1
ffffffffc0201032:	22a60613          	addi	a2,a2,554 # ffffffffc0202258 <commands+0x590>
ffffffffc0201036:	10f00593          	li	a1,271
ffffffffc020103a:	00001517          	auipc	a0,0x1
ffffffffc020103e:	23650513          	addi	a0,a0,566 # ffffffffc0202270 <commands+0x5a8>
ffffffffc0201042:	b6aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201046 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201046:	1141                	addi	sp,sp,-16
ffffffffc0201048:	e406                	sd	ra,8(sp)
    assert(n > 0); // 确保释放的页数大于0
ffffffffc020104a:	14058a63          	beqz	a1,ffffffffc020119e <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020104e:	00259693          	slli	a3,a1,0x2
ffffffffc0201052:	96ae                	add	a3,a3,a1
ffffffffc0201054:	068e                	slli	a3,a3,0x3
ffffffffc0201056:	96aa                	add	a3,a3,a0
ffffffffc0201058:	87aa                	mv	a5,a0
ffffffffc020105a:	02d50263          	beq	a0,a3,ffffffffc020107e <best_fit_free_pages+0x38>
ffffffffc020105e:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页块没有被保留且没有属性标记
ffffffffc0201060:	8b05                	andi	a4,a4,1
ffffffffc0201062:	10071e63          	bnez	a4,ffffffffc020117e <best_fit_free_pages+0x138>
ffffffffc0201066:	6798                	ld	a4,8(a5)
ffffffffc0201068:	8b09                	andi	a4,a4,2
ffffffffc020106a:	10071a63          	bnez	a4,ffffffffc020117e <best_fit_free_pages+0x138>
        p->flags = 0; // 清除页的标志
ffffffffc020106e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201072:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201076:	02878793          	addi	a5,a5,40
ffffffffc020107a:	fed792e3          	bne	a5,a3,ffffffffc020105e <best_fit_free_pages+0x18>
    base->property = n;  // 设置当前页块的属性为释放的页数
ffffffffc020107e:	2581                	sext.w	a1,a1
ffffffffc0201080:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);  // 标记当前页块为已分配
ffffffffc0201082:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201086:	4789                	li	a5,2
ffffffffc0201088:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;  // 增加空闲页块总数
ffffffffc020108c:	00005697          	auipc	a3,0x5
ffffffffc0201090:	f8c68693          	addi	a3,a3,-116 # ffffffffc0206018 <free_area>
ffffffffc0201094:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201096:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201098:	01850613          	addi	a2,a0,24
    nr_free += n;  // 增加空闲页块总数
ffffffffc020109c:	9db9                	addw	a1,a1,a4
ffffffffc020109e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) { // 如果空闲链表为空，直接添加当前页块
ffffffffc02010a0:	0ad78863          	beq	a5,a3,ffffffffc0201150 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02010a4:	fe878713          	addi	a4,a5,-24
ffffffffc02010a8:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) { // 如果空闲链表为空，直接添加当前页块
ffffffffc02010ac:	4581                	li	a1,0
            if (base < page) {
ffffffffc02010ae:	00e56a63          	bltu	a0,a4,ffffffffc02010c2 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc02010b2:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010b4:	06d70263          	beq	a4,a3,ffffffffc0201118 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02010b8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010ba:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010be:	fee57ae3          	bgeu	a0,a4,ffffffffc02010b2 <best_fit_free_pages+0x6c>
ffffffffc02010c2:	c199                	beqz	a1,ffffffffc02010c8 <best_fit_free_pages+0x82>
ffffffffc02010c4:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010c8:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010ca:	e390                	sd	a2,0(a5)
ffffffffc02010cc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010ce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010d0:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02010d2:	02d70063          	beq	a4,a3,ffffffffc02010f2 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02010d6:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02010da:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc02010de:	02081613          	slli	a2,a6,0x20
ffffffffc02010e2:	9201                	srli	a2,a2,0x20
ffffffffc02010e4:	00261793          	slli	a5,a2,0x2
ffffffffc02010e8:	97b2                	add	a5,a5,a2
ffffffffc02010ea:	078e                	slli	a5,a5,0x3
ffffffffc02010ec:	97ae                	add	a5,a5,a1
ffffffffc02010ee:	02f50f63          	beq	a0,a5,ffffffffc020112c <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc02010f2:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02010f4:	00d70f63          	beq	a4,a3,ffffffffc0201112 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02010f8:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02010fa:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02010fe:	02059613          	slli	a2,a1,0x20
ffffffffc0201102:	9201                	srli	a2,a2,0x20
ffffffffc0201104:	00261793          	slli	a5,a2,0x2
ffffffffc0201108:	97b2                	add	a5,a5,a2
ffffffffc020110a:	078e                	slli	a5,a5,0x3
ffffffffc020110c:	97aa                	add	a5,a5,a0
ffffffffc020110e:	04f68863          	beq	a3,a5,ffffffffc020115e <best_fit_free_pages+0x118>
}
ffffffffc0201112:	60a2                	ld	ra,8(sp)
ffffffffc0201114:	0141                	addi	sp,sp,16
ffffffffc0201116:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201118:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020111a:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020111c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020111e:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201120:	02d70563          	beq	a4,a3,ffffffffc020114a <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201124:	8832                	mv	a6,a2
ffffffffc0201126:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201128:	87ba                	mv	a5,a4
ffffffffc020112a:	bf41                	j	ffffffffc02010ba <best_fit_free_pages+0x74>
            p->property += base->property;  // 更新前一个空闲页块的大小
ffffffffc020112c:	491c                	lw	a5,16(a0)
ffffffffc020112e:	0107883b          	addw	a6,a5,a6
ffffffffc0201132:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201136:	57f5                	li	a5,-3
ffffffffc0201138:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020113c:	6d10                	ld	a2,24(a0)
ffffffffc020113e:	711c                	ld	a5,32(a0)
            base = p;  // 更新指针，继续检查合并后的连续空闲页块
ffffffffc0201140:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0201142:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201144:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201146:	e390                	sd	a2,0(a5)
ffffffffc0201148:	b775                	j	ffffffffc02010f4 <best_fit_free_pages+0xae>
ffffffffc020114a:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020114c:	873e                	mv	a4,a5
ffffffffc020114e:	b761                	j	ffffffffc02010d6 <best_fit_free_pages+0x90>
}
ffffffffc0201150:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201152:	e390                	sd	a2,0(a5)
ffffffffc0201154:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201156:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201158:	ed1c                	sd	a5,24(a0)
ffffffffc020115a:	0141                	addi	sp,sp,16
ffffffffc020115c:	8082                	ret
            base->property += p->property;  // 合并当前页块和后一个空闲页块
ffffffffc020115e:	ff872783          	lw	a5,-8(a4)
ffffffffc0201162:	ff070693          	addi	a3,a4,-16
ffffffffc0201166:	9dbd                	addw	a1,a1,a5
ffffffffc0201168:	c90c                	sw	a1,16(a0)
ffffffffc020116a:	57f5                	li	a5,-3
ffffffffc020116c:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201170:	6314                	ld	a3,0(a4)
ffffffffc0201172:	671c                	ld	a5,8(a4)
}
ffffffffc0201174:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201176:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201178:	e394                	sd	a3,0(a5)
ffffffffc020117a:	0141                	addi	sp,sp,16
ffffffffc020117c:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页块没有被保留且没有属性标记
ffffffffc020117e:	00001697          	auipc	a3,0x1
ffffffffc0201182:	3ca68693          	addi	a3,a3,970 # ffffffffc0202548 <commands+0x880>
ffffffffc0201186:	00001617          	auipc	a2,0x1
ffffffffc020118a:	0d260613          	addi	a2,a2,210 # ffffffffc0202258 <commands+0x590>
ffffffffc020118e:	0a200593          	li	a1,162
ffffffffc0201192:	00001517          	auipc	a0,0x1
ffffffffc0201196:	0de50513          	addi	a0,a0,222 # ffffffffc0202270 <commands+0x5a8>
ffffffffc020119a:	a12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0); // 确保释放的页数大于0
ffffffffc020119e:	00001697          	auipc	a3,0x1
ffffffffc02011a2:	0b268693          	addi	a3,a3,178 # ffffffffc0202250 <commands+0x588>
ffffffffc02011a6:	00001617          	auipc	a2,0x1
ffffffffc02011aa:	0b260613          	addi	a2,a2,178 # ffffffffc0202258 <commands+0x590>
ffffffffc02011ae:	09d00593          	li	a1,157
ffffffffc02011b2:	00001517          	auipc	a0,0x1
ffffffffc02011b6:	0be50513          	addi	a0,a0,190 # ffffffffc0202270 <commands+0x5a8>
ffffffffc02011ba:	9f2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011be <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011be:	1141                	addi	sp,sp,-16
ffffffffc02011c0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011c2:	c9e1                	beqz	a1,ffffffffc0201292 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02011c4:	00259693          	slli	a3,a1,0x2
ffffffffc02011c8:	96ae                	add	a3,a3,a1
ffffffffc02011ca:	068e                	slli	a3,a3,0x3
ffffffffc02011cc:	96aa                	add	a3,a3,a0
ffffffffc02011ce:	87aa                	mv	a5,a0
ffffffffc02011d0:	00d50f63          	beq	a0,a3,ffffffffc02011ee <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011d4:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02011d6:	8b05                	andi	a4,a4,1
ffffffffc02011d8:	cf49                	beqz	a4,ffffffffc0201272 <best_fit_init_memmap+0xb4>
        p->flags = 0;
ffffffffc02011da:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc02011de:	0007a823          	sw	zero,16(a5)
ffffffffc02011e2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011e6:	02878793          	addi	a5,a5,40
ffffffffc02011ea:	fed795e3          	bne	a5,a3,ffffffffc02011d4 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc02011ee:	2581                	sext.w	a1,a1
ffffffffc02011f0:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011f2:	4789                	li	a5,2
ffffffffc02011f4:	00850713          	addi	a4,a0,8
ffffffffc02011f8:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02011fc:	00005697          	auipc	a3,0x5
ffffffffc0201200:	e1c68693          	addi	a3,a3,-484 # ffffffffc0206018 <free_area>
ffffffffc0201204:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201206:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201208:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020120c:	9db9                	addw	a1,a1,a4
ffffffffc020120e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201210:	04d78a63          	beq	a5,a3,ffffffffc0201264 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201214:	fe878713          	addi	a4,a5,-24
ffffffffc0201218:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020121c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020121e:	00e56a63          	bltu	a0,a4,ffffffffc0201232 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201222:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc0201224:	02d70263          	beq	a4,a3,ffffffffc0201248 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201228:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020122a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020122e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201222 <best_fit_init_memmap+0x64>
ffffffffc0201232:	c199                	beqz	a1,ffffffffc0201238 <best_fit_init_memmap+0x7a>
ffffffffc0201234:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201238:	6398                	ld	a4,0(a5)
}
ffffffffc020123a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020123c:	e390                	sd	a2,0(a5)
ffffffffc020123e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201240:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201242:	ed18                	sd	a4,24(a0)
ffffffffc0201244:	0141                	addi	sp,sp,16
ffffffffc0201246:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201248:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020124a:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020124c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020124e:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201250:	00d70663          	beq	a4,a3,ffffffffc020125c <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0201254:	8832                	mv	a6,a2
ffffffffc0201256:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201258:	87ba                	mv	a5,a4
ffffffffc020125a:	bfc1                	j	ffffffffc020122a <best_fit_init_memmap+0x6c>
}
ffffffffc020125c:	60a2                	ld	ra,8(sp)
ffffffffc020125e:	e290                	sd	a2,0(a3)
ffffffffc0201260:	0141                	addi	sp,sp,16
ffffffffc0201262:	8082                	ret
ffffffffc0201264:	60a2                	ld	ra,8(sp)
ffffffffc0201266:	e390                	sd	a2,0(a5)
ffffffffc0201268:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020126a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020126c:	ed1c                	sd	a5,24(a0)
ffffffffc020126e:	0141                	addi	sp,sp,16
ffffffffc0201270:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201272:	00001697          	auipc	a3,0x1
ffffffffc0201276:	2fe68693          	addi	a3,a3,766 # ffffffffc0202570 <commands+0x8a8>
ffffffffc020127a:	00001617          	auipc	a2,0x1
ffffffffc020127e:	fde60613          	addi	a2,a2,-34 # ffffffffc0202258 <commands+0x590>
ffffffffc0201282:	04a00593          	li	a1,74
ffffffffc0201286:	00001517          	auipc	a0,0x1
ffffffffc020128a:	fea50513          	addi	a0,a0,-22 # ffffffffc0202270 <commands+0x5a8>
ffffffffc020128e:	91eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201292:	00001697          	auipc	a3,0x1
ffffffffc0201296:	fbe68693          	addi	a3,a3,-66 # ffffffffc0202250 <commands+0x588>
ffffffffc020129a:	00001617          	auipc	a2,0x1
ffffffffc020129e:	fbe60613          	addi	a2,a2,-66 # ffffffffc0202258 <commands+0x590>
ffffffffc02012a2:	04700593          	li	a1,71
ffffffffc02012a6:	00001517          	auipc	a0,0x1
ffffffffc02012aa:	fca50513          	addi	a0,a0,-54 # ffffffffc0202270 <commands+0x5a8>
ffffffffc02012ae:	8feff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012b2 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012b2:	100027f3          	csrr	a5,sstatus
ffffffffc02012b6:	8b89                	andi	a5,a5,2
ffffffffc02012b8:	e799                	bnez	a5,ffffffffc02012c6 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012ba:	00005797          	auipc	a5,0x5
ffffffffc02012be:	19e7b783          	ld	a5,414(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02012c2:	6f9c                	ld	a5,24(a5)
ffffffffc02012c4:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02012c6:	1141                	addi	sp,sp,-16
ffffffffc02012c8:	e406                	sd	ra,8(sp)
ffffffffc02012ca:	e022                	sd	s0,0(sp)
ffffffffc02012cc:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012ce:	990ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012d2:	00005797          	auipc	a5,0x5
ffffffffc02012d6:	1867b783          	ld	a5,390(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02012da:	6f9c                	ld	a5,24(a5)
ffffffffc02012dc:	8522                	mv	a0,s0
ffffffffc02012de:	9782                	jalr	a5
ffffffffc02012e0:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02012e2:	976ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012e6:	60a2                	ld	ra,8(sp)
ffffffffc02012e8:	8522                	mv	a0,s0
ffffffffc02012ea:	6402                	ld	s0,0(sp)
ffffffffc02012ec:	0141                	addi	sp,sp,16
ffffffffc02012ee:	8082                	ret

ffffffffc02012f0 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012f0:	100027f3          	csrr	a5,sstatus
ffffffffc02012f4:	8b89                	andi	a5,a5,2
ffffffffc02012f6:	e799                	bnez	a5,ffffffffc0201304 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02012f8:	00005797          	auipc	a5,0x5
ffffffffc02012fc:	1607b783          	ld	a5,352(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201300:	739c                	ld	a5,32(a5)
ffffffffc0201302:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201304:	1101                	addi	sp,sp,-32
ffffffffc0201306:	ec06                	sd	ra,24(sp)
ffffffffc0201308:	e822                	sd	s0,16(sp)
ffffffffc020130a:	e426                	sd	s1,8(sp)
ffffffffc020130c:	842a                	mv	s0,a0
ffffffffc020130e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201310:	94eff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201314:	00005797          	auipc	a5,0x5
ffffffffc0201318:	1447b783          	ld	a5,324(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc020131c:	739c                	ld	a5,32(a5)
ffffffffc020131e:	85a6                	mv	a1,s1
ffffffffc0201320:	8522                	mv	a0,s0
ffffffffc0201322:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201324:	6442                	ld	s0,16(sp)
ffffffffc0201326:	60e2                	ld	ra,24(sp)
ffffffffc0201328:	64a2                	ld	s1,8(sp)
ffffffffc020132a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020132c:	92cff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201330 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201330:	100027f3          	csrr	a5,sstatus
ffffffffc0201334:	8b89                	andi	a5,a5,2
ffffffffc0201336:	e799                	bnez	a5,ffffffffc0201344 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201338:	00005797          	auipc	a5,0x5
ffffffffc020133c:	1207b783          	ld	a5,288(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201340:	779c                	ld	a5,40(a5)
ffffffffc0201342:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201344:	1141                	addi	sp,sp,-16
ffffffffc0201346:	e406                	sd	ra,8(sp)
ffffffffc0201348:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020134a:	914ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020134e:	00005797          	auipc	a5,0x5
ffffffffc0201352:	10a7b783          	ld	a5,266(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201356:	779c                	ld	a5,40(a5)
ffffffffc0201358:	9782                	jalr	a5
ffffffffc020135a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020135c:	8fcff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201360:	60a2                	ld	ra,8(sp)
ffffffffc0201362:	8522                	mv	a0,s0
ffffffffc0201364:	6402                	ld	s0,0(sp)
ffffffffc0201366:	0141                	addi	sp,sp,16
ffffffffc0201368:	8082                	ret

ffffffffc020136a <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020136a:	00001797          	auipc	a5,0x1
ffffffffc020136e:	22e78793          	addi	a5,a5,558 # ffffffffc0202598 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201372:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201374:	1101                	addi	sp,sp,-32
ffffffffc0201376:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201378:	00001517          	auipc	a0,0x1
ffffffffc020137c:	25850513          	addi	a0,a0,600 # ffffffffc02025d0 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201380:	00005497          	auipc	s1,0x5
ffffffffc0201384:	0d848493          	addi	s1,s1,216 # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0201388:	ec06                	sd	ra,24(sp)
ffffffffc020138a:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020138c:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020138e:	d25fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0201392:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201394:	00005417          	auipc	s0,0x5
ffffffffc0201398:	0dc40413          	addi	s0,s0,220 # ffffffffc0206470 <va_pa_offset>
    pmm_manager->init();
ffffffffc020139c:	679c                	ld	a5,8(a5)
ffffffffc020139e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013a0:	57f5                	li	a5,-3
ffffffffc02013a2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013a4:	00001517          	auipc	a0,0x1
ffffffffc02013a8:	24450513          	addi	a0,a0,580 # ffffffffc02025e8 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013ac:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02013ae:	d05fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013b2:	46c5                	li	a3,17
ffffffffc02013b4:	06ee                	slli	a3,a3,0x1b
ffffffffc02013b6:	40100613          	li	a2,1025
ffffffffc02013ba:	16fd                	addi	a3,a3,-1
ffffffffc02013bc:	07e005b7          	lui	a1,0x7e00
ffffffffc02013c0:	0656                	slli	a2,a2,0x15
ffffffffc02013c2:	00001517          	auipc	a0,0x1
ffffffffc02013c6:	23e50513          	addi	a0,a0,574 # ffffffffc0202600 <best_fit_pmm_manager+0x68>
ffffffffc02013ca:	ce9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013ce:	777d                	lui	a4,0xfffff
ffffffffc02013d0:	00006797          	auipc	a5,0x6
ffffffffc02013d4:	0af78793          	addi	a5,a5,175 # ffffffffc020747f <end+0xfff>
ffffffffc02013d8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02013da:	00005517          	auipc	a0,0x5
ffffffffc02013de:	06e50513          	addi	a0,a0,110 # ffffffffc0206448 <npage>
ffffffffc02013e2:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013e6:	00005597          	auipc	a1,0x5
ffffffffc02013ea:	06a58593          	addi	a1,a1,106 # ffffffffc0206450 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02013ee:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013f0:	e19c                	sd	a5,0(a1)
ffffffffc02013f2:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013f4:	4701                	li	a4,0
ffffffffc02013f6:	4885                	li	a7,1
ffffffffc02013f8:	fff80837          	lui	a6,0xfff80
ffffffffc02013fc:	a011                	j	ffffffffc0201400 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02013fe:	619c                	ld	a5,0(a1)
ffffffffc0201400:	97b6                	add	a5,a5,a3
ffffffffc0201402:	07a1                	addi	a5,a5,8
ffffffffc0201404:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201408:	611c                	ld	a5,0(a0)
ffffffffc020140a:	0705                	addi	a4,a4,1
ffffffffc020140c:	02868693          	addi	a3,a3,40
ffffffffc0201410:	01078633          	add	a2,a5,a6
ffffffffc0201414:	fec765e3          	bltu	a4,a2,ffffffffc02013fe <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201418:	6190                	ld	a2,0(a1)
ffffffffc020141a:	00279713          	slli	a4,a5,0x2
ffffffffc020141e:	973e                	add	a4,a4,a5
ffffffffc0201420:	fec006b7          	lui	a3,0xfec00
ffffffffc0201424:	070e                	slli	a4,a4,0x3
ffffffffc0201426:	96b2                	add	a3,a3,a2
ffffffffc0201428:	96ba                	add	a3,a3,a4
ffffffffc020142a:	c0200737          	lui	a4,0xc0200
ffffffffc020142e:	08e6ef63          	bltu	a3,a4,ffffffffc02014cc <pmm_init+0x162>
ffffffffc0201432:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201434:	45c5                	li	a1,17
ffffffffc0201436:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201438:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020143a:	04b6e863          	bltu	a3,a1,ffffffffc020148a <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020143e:	609c                	ld	a5,0(s1)
ffffffffc0201440:	7b9c                	ld	a5,48(a5)
ffffffffc0201442:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201444:	00001517          	auipc	a0,0x1
ffffffffc0201448:	25450513          	addi	a0,a0,596 # ffffffffc0202698 <best_fit_pmm_manager+0x100>
ffffffffc020144c:	c67fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201450:	00004597          	auipc	a1,0x4
ffffffffc0201454:	bb058593          	addi	a1,a1,-1104 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201458:	00005797          	auipc	a5,0x5
ffffffffc020145c:	00b7b823          	sd	a1,16(a5) # ffffffffc0206468 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201460:	c02007b7          	lui	a5,0xc0200
ffffffffc0201464:	08f5e063          	bltu	a1,a5,ffffffffc02014e4 <pmm_init+0x17a>
ffffffffc0201468:	6010                	ld	a2,0(s0)
}
ffffffffc020146a:	6442                	ld	s0,16(sp)
ffffffffc020146c:	60e2                	ld	ra,24(sp)
ffffffffc020146e:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201470:	40c58633          	sub	a2,a1,a2
ffffffffc0201474:	00005797          	auipc	a5,0x5
ffffffffc0201478:	fec7b623          	sd	a2,-20(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020147c:	00001517          	auipc	a0,0x1
ffffffffc0201480:	23c50513          	addi	a0,a0,572 # ffffffffc02026b8 <best_fit_pmm_manager+0x120>
}
ffffffffc0201484:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201486:	c2dfe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020148a:	6705                	lui	a4,0x1
ffffffffc020148c:	177d                	addi	a4,a4,-1
ffffffffc020148e:	96ba                	add	a3,a3,a4
ffffffffc0201490:	777d                	lui	a4,0xfffff
ffffffffc0201492:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201494:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201498:	00f57e63          	bgeu	a0,a5,ffffffffc02014b4 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc020149c:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020149e:	982a                	add	a6,a6,a0
ffffffffc02014a0:	00281513          	slli	a0,a6,0x2
ffffffffc02014a4:	9542                	add	a0,a0,a6
ffffffffc02014a6:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014a8:	8d95                	sub	a1,a1,a3
ffffffffc02014aa:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014ac:	81b1                	srli	a1,a1,0xc
ffffffffc02014ae:	9532                	add	a0,a0,a2
ffffffffc02014b0:	9782                	jalr	a5
}
ffffffffc02014b2:	b771                	j	ffffffffc020143e <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02014b4:	00001617          	auipc	a2,0x1
ffffffffc02014b8:	1b460613          	addi	a2,a2,436 # ffffffffc0202668 <best_fit_pmm_manager+0xd0>
ffffffffc02014bc:	06b00593          	li	a1,107
ffffffffc02014c0:	00001517          	auipc	a0,0x1
ffffffffc02014c4:	1c850513          	addi	a0,a0,456 # ffffffffc0202688 <best_fit_pmm_manager+0xf0>
ffffffffc02014c8:	ee5fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014cc:	00001617          	auipc	a2,0x1
ffffffffc02014d0:	16460613          	addi	a2,a2,356 # ffffffffc0202630 <best_fit_pmm_manager+0x98>
ffffffffc02014d4:	06e00593          	li	a1,110
ffffffffc02014d8:	00001517          	auipc	a0,0x1
ffffffffc02014dc:	18050513          	addi	a0,a0,384 # ffffffffc0202658 <best_fit_pmm_manager+0xc0>
ffffffffc02014e0:	ecdfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014e4:	86ae                	mv	a3,a1
ffffffffc02014e6:	00001617          	auipc	a2,0x1
ffffffffc02014ea:	14a60613          	addi	a2,a2,330 # ffffffffc0202630 <best_fit_pmm_manager+0x98>
ffffffffc02014ee:	08900593          	li	a1,137
ffffffffc02014f2:	00001517          	auipc	a0,0x1
ffffffffc02014f6:	16650513          	addi	a0,a0,358 # ffffffffc0202658 <best_fit_pmm_manager+0xc0>
ffffffffc02014fa:	eb3fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02014fe <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02014fe:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201502:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201504:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201508:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020150a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020150e:	f022                	sd	s0,32(sp)
ffffffffc0201510:	ec26                	sd	s1,24(sp)
ffffffffc0201512:	e84a                	sd	s2,16(sp)
ffffffffc0201514:	f406                	sd	ra,40(sp)
ffffffffc0201516:	e44e                	sd	s3,8(sp)
ffffffffc0201518:	84aa                	mv	s1,a0
ffffffffc020151a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020151c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201520:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201522:	03067e63          	bgeu	a2,a6,ffffffffc020155e <printnum+0x60>
ffffffffc0201526:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201528:	00805763          	blez	s0,ffffffffc0201536 <printnum+0x38>
ffffffffc020152c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020152e:	85ca                	mv	a1,s2
ffffffffc0201530:	854e                	mv	a0,s3
ffffffffc0201532:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201534:	fc65                	bnez	s0,ffffffffc020152c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201536:	1a02                	slli	s4,s4,0x20
ffffffffc0201538:	00001797          	auipc	a5,0x1
ffffffffc020153c:	1c078793          	addi	a5,a5,448 # ffffffffc02026f8 <best_fit_pmm_manager+0x160>
ffffffffc0201540:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201544:	9a3e                	add	s4,s4,a5
}
ffffffffc0201546:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201548:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020154c:	70a2                	ld	ra,40(sp)
ffffffffc020154e:	69a2                	ld	s3,8(sp)
ffffffffc0201550:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201552:	85ca                	mv	a1,s2
ffffffffc0201554:	87a6                	mv	a5,s1
}
ffffffffc0201556:	6942                	ld	s2,16(sp)
ffffffffc0201558:	64e2                	ld	s1,24(sp)
ffffffffc020155a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020155c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020155e:	03065633          	divu	a2,a2,a6
ffffffffc0201562:	8722                	mv	a4,s0
ffffffffc0201564:	f9bff0ef          	jal	ra,ffffffffc02014fe <printnum>
ffffffffc0201568:	b7f9                	j	ffffffffc0201536 <printnum+0x38>

ffffffffc020156a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020156a:	7119                	addi	sp,sp,-128
ffffffffc020156c:	f4a6                	sd	s1,104(sp)
ffffffffc020156e:	f0ca                	sd	s2,96(sp)
ffffffffc0201570:	ecce                	sd	s3,88(sp)
ffffffffc0201572:	e8d2                	sd	s4,80(sp)
ffffffffc0201574:	e4d6                	sd	s5,72(sp)
ffffffffc0201576:	e0da                	sd	s6,64(sp)
ffffffffc0201578:	fc5e                	sd	s7,56(sp)
ffffffffc020157a:	f06a                	sd	s10,32(sp)
ffffffffc020157c:	fc86                	sd	ra,120(sp)
ffffffffc020157e:	f8a2                	sd	s0,112(sp)
ffffffffc0201580:	f862                	sd	s8,48(sp)
ffffffffc0201582:	f466                	sd	s9,40(sp)
ffffffffc0201584:	ec6e                	sd	s11,24(sp)
ffffffffc0201586:	892a                	mv	s2,a0
ffffffffc0201588:	84ae                	mv	s1,a1
ffffffffc020158a:	8d32                	mv	s10,a2
ffffffffc020158c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020158e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201592:	5b7d                	li	s6,-1
ffffffffc0201594:	00001a97          	auipc	s5,0x1
ffffffffc0201598:	198a8a93          	addi	s5,s5,408 # ffffffffc020272c <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020159c:	00001b97          	auipc	s7,0x1
ffffffffc02015a0:	36cb8b93          	addi	s7,s7,876 # ffffffffc0202908 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015a4:	000d4503          	lbu	a0,0(s10)
ffffffffc02015a8:	001d0413          	addi	s0,s10,1
ffffffffc02015ac:	01350a63          	beq	a0,s3,ffffffffc02015c0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02015b0:	c121                	beqz	a0,ffffffffc02015f0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02015b2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015b4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02015b6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015b8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02015bc:	ff351ae3          	bne	a0,s3,ffffffffc02015b0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015c0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02015c4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02015c8:	4c81                	li	s9,0
ffffffffc02015ca:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02015cc:	5c7d                	li	s8,-1
ffffffffc02015ce:	5dfd                	li	s11,-1
ffffffffc02015d0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02015d4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015d6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015da:	0ff5f593          	zext.b	a1,a1
ffffffffc02015de:	00140d13          	addi	s10,s0,1
ffffffffc02015e2:	04b56263          	bltu	a0,a1,ffffffffc0201626 <vprintfmt+0xbc>
ffffffffc02015e6:	058a                	slli	a1,a1,0x2
ffffffffc02015e8:	95d6                	add	a1,a1,s5
ffffffffc02015ea:	4194                	lw	a3,0(a1)
ffffffffc02015ec:	96d6                	add	a3,a3,s5
ffffffffc02015ee:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02015f0:	70e6                	ld	ra,120(sp)
ffffffffc02015f2:	7446                	ld	s0,112(sp)
ffffffffc02015f4:	74a6                	ld	s1,104(sp)
ffffffffc02015f6:	7906                	ld	s2,96(sp)
ffffffffc02015f8:	69e6                	ld	s3,88(sp)
ffffffffc02015fa:	6a46                	ld	s4,80(sp)
ffffffffc02015fc:	6aa6                	ld	s5,72(sp)
ffffffffc02015fe:	6b06                	ld	s6,64(sp)
ffffffffc0201600:	7be2                	ld	s7,56(sp)
ffffffffc0201602:	7c42                	ld	s8,48(sp)
ffffffffc0201604:	7ca2                	ld	s9,40(sp)
ffffffffc0201606:	7d02                	ld	s10,32(sp)
ffffffffc0201608:	6de2                	ld	s11,24(sp)
ffffffffc020160a:	6109                	addi	sp,sp,128
ffffffffc020160c:	8082                	ret
            padc = '0';
ffffffffc020160e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201610:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201614:	846a                	mv	s0,s10
ffffffffc0201616:	00140d13          	addi	s10,s0,1
ffffffffc020161a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020161e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201622:	fcb572e3          	bgeu	a0,a1,ffffffffc02015e6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201626:	85a6                	mv	a1,s1
ffffffffc0201628:	02500513          	li	a0,37
ffffffffc020162c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020162e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201632:	8d22                	mv	s10,s0
ffffffffc0201634:	f73788e3          	beq	a5,s3,ffffffffc02015a4 <vprintfmt+0x3a>
ffffffffc0201638:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020163c:	1d7d                	addi	s10,s10,-1
ffffffffc020163e:	ff379de3          	bne	a5,s3,ffffffffc0201638 <vprintfmt+0xce>
ffffffffc0201642:	b78d                	j	ffffffffc02015a4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201644:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201648:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020164e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201652:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201656:	02d86463          	bltu	a6,a3,ffffffffc020167e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020165a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020165e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201662:	0186873b          	addw	a4,a3,s8
ffffffffc0201666:	0017171b          	slliw	a4,a4,0x1
ffffffffc020166a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020166c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201670:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201672:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201676:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020167a:	fed870e3          	bgeu	a6,a3,ffffffffc020165a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020167e:	f40ddce3          	bgez	s11,ffffffffc02015d6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201682:	8de2                	mv	s11,s8
ffffffffc0201684:	5c7d                	li	s8,-1
ffffffffc0201686:	bf81                	j	ffffffffc02015d6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201688:	fffdc693          	not	a3,s11
ffffffffc020168c:	96fd                	srai	a3,a3,0x3f
ffffffffc020168e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201692:	00144603          	lbu	a2,1(s0)
ffffffffc0201696:	2d81                	sext.w	s11,s11
ffffffffc0201698:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020169a:	bf35                	j	ffffffffc02015d6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020169c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016a0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02016a4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016a6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02016a8:	bfd9                	j	ffffffffc020167e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02016aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016b0:	01174463          	blt	a4,a7,ffffffffc02016b8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02016b4:	1a088e63          	beqz	a7,ffffffffc0201870 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02016b8:	000a3603          	ld	a2,0(s4)
ffffffffc02016bc:	46c1                	li	a3,16
ffffffffc02016be:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02016c0:	2781                	sext.w	a5,a5
ffffffffc02016c2:	876e                	mv	a4,s11
ffffffffc02016c4:	85a6                	mv	a1,s1
ffffffffc02016c6:	854a                	mv	a0,s2
ffffffffc02016c8:	e37ff0ef          	jal	ra,ffffffffc02014fe <printnum>
            break;
ffffffffc02016cc:	bde1                	j	ffffffffc02015a4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02016ce:	000a2503          	lw	a0,0(s4)
ffffffffc02016d2:	85a6                	mv	a1,s1
ffffffffc02016d4:	0a21                	addi	s4,s4,8
ffffffffc02016d6:	9902                	jalr	s2
            break;
ffffffffc02016d8:	b5f1                	j	ffffffffc02015a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016da:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016dc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016e0:	01174463          	blt	a4,a7,ffffffffc02016e8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02016e4:	18088163          	beqz	a7,ffffffffc0201866 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02016e8:	000a3603          	ld	a2,0(s4)
ffffffffc02016ec:	46a9                	li	a3,10
ffffffffc02016ee:	8a2e                	mv	s4,a1
ffffffffc02016f0:	bfc1                	j	ffffffffc02016c0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016f6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016fa:	bdf1                	j	ffffffffc02015d6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02016fc:	85a6                	mv	a1,s1
ffffffffc02016fe:	02500513          	li	a0,37
ffffffffc0201702:	9902                	jalr	s2
            break;
ffffffffc0201704:	b545                	j	ffffffffc02015a4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201706:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020170a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020170c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020170e:	b5e1                	j	ffffffffc02015d6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201710:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201712:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201716:	01174463          	blt	a4,a7,ffffffffc020171e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020171a:	14088163          	beqz	a7,ffffffffc020185c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020171e:	000a3603          	ld	a2,0(s4)
ffffffffc0201722:	46a1                	li	a3,8
ffffffffc0201724:	8a2e                	mv	s4,a1
ffffffffc0201726:	bf69                	j	ffffffffc02016c0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201728:	03000513          	li	a0,48
ffffffffc020172c:	85a6                	mv	a1,s1
ffffffffc020172e:	e03e                	sd	a5,0(sp)
ffffffffc0201730:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201732:	85a6                	mv	a1,s1
ffffffffc0201734:	07800513          	li	a0,120
ffffffffc0201738:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020173a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020173c:	6782                	ld	a5,0(sp)
ffffffffc020173e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201740:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201744:	bfb5                	j	ffffffffc02016c0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201746:	000a3403          	ld	s0,0(s4)
ffffffffc020174a:	008a0713          	addi	a4,s4,8
ffffffffc020174e:	e03a                	sd	a4,0(sp)
ffffffffc0201750:	14040263          	beqz	s0,ffffffffc0201894 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201754:	0fb05763          	blez	s11,ffffffffc0201842 <vprintfmt+0x2d8>
ffffffffc0201758:	02d00693          	li	a3,45
ffffffffc020175c:	0cd79163          	bne	a5,a3,ffffffffc020181e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201760:	00044783          	lbu	a5,0(s0)
ffffffffc0201764:	0007851b          	sext.w	a0,a5
ffffffffc0201768:	cf85                	beqz	a5,ffffffffc02017a0 <vprintfmt+0x236>
ffffffffc020176a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020176e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201772:	000c4563          	bltz	s8,ffffffffc020177c <vprintfmt+0x212>
ffffffffc0201776:	3c7d                	addiw	s8,s8,-1
ffffffffc0201778:	036c0263          	beq	s8,s6,ffffffffc020179c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020177c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020177e:	0e0c8e63          	beqz	s9,ffffffffc020187a <vprintfmt+0x310>
ffffffffc0201782:	3781                	addiw	a5,a5,-32
ffffffffc0201784:	0ef47b63          	bgeu	s0,a5,ffffffffc020187a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201788:	03f00513          	li	a0,63
ffffffffc020178c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020178e:	000a4783          	lbu	a5,0(s4)
ffffffffc0201792:	3dfd                	addiw	s11,s11,-1
ffffffffc0201794:	0a05                	addi	s4,s4,1
ffffffffc0201796:	0007851b          	sext.w	a0,a5
ffffffffc020179a:	ffe1                	bnez	a5,ffffffffc0201772 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020179c:	01b05963          	blez	s11,ffffffffc02017ae <vprintfmt+0x244>
ffffffffc02017a0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017a2:	85a6                	mv	a1,s1
ffffffffc02017a4:	02000513          	li	a0,32
ffffffffc02017a8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017aa:	fe0d9be3          	bnez	s11,ffffffffc02017a0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017ae:	6a02                	ld	s4,0(sp)
ffffffffc02017b0:	bbd5                	j	ffffffffc02015a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017b2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017b4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02017b8:	01174463          	blt	a4,a7,ffffffffc02017c0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02017bc:	08088d63          	beqz	a7,ffffffffc0201856 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02017c0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02017c4:	0a044d63          	bltz	s0,ffffffffc020187e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02017c8:	8622                	mv	a2,s0
ffffffffc02017ca:	8a66                	mv	s4,s9
ffffffffc02017cc:	46a9                	li	a3,10
ffffffffc02017ce:	bdcd                	j	ffffffffc02016c0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02017d0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017d4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017d6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02017d8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017dc:	8fb5                	xor	a5,a5,a3
ffffffffc02017de:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017e2:	02d74163          	blt	a4,a3,ffffffffc0201804 <vprintfmt+0x29a>
ffffffffc02017e6:	00369793          	slli	a5,a3,0x3
ffffffffc02017ea:	97de                	add	a5,a5,s7
ffffffffc02017ec:	639c                	ld	a5,0(a5)
ffffffffc02017ee:	cb99                	beqz	a5,ffffffffc0201804 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017f0:	86be                	mv	a3,a5
ffffffffc02017f2:	00001617          	auipc	a2,0x1
ffffffffc02017f6:	f3660613          	addi	a2,a2,-202 # ffffffffc0202728 <best_fit_pmm_manager+0x190>
ffffffffc02017fa:	85a6                	mv	a1,s1
ffffffffc02017fc:	854a                	mv	a0,s2
ffffffffc02017fe:	0ce000ef          	jal	ra,ffffffffc02018cc <printfmt>
ffffffffc0201802:	b34d                	j	ffffffffc02015a4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201804:	00001617          	auipc	a2,0x1
ffffffffc0201808:	f1460613          	addi	a2,a2,-236 # ffffffffc0202718 <best_fit_pmm_manager+0x180>
ffffffffc020180c:	85a6                	mv	a1,s1
ffffffffc020180e:	854a                	mv	a0,s2
ffffffffc0201810:	0bc000ef          	jal	ra,ffffffffc02018cc <printfmt>
ffffffffc0201814:	bb41                	j	ffffffffc02015a4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201816:	00001417          	auipc	s0,0x1
ffffffffc020181a:	efa40413          	addi	s0,s0,-262 # ffffffffc0202710 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020181e:	85e2                	mv	a1,s8
ffffffffc0201820:	8522                	mv	a0,s0
ffffffffc0201822:	e43e                	sd	a5,8(sp)
ffffffffc0201824:	1e6000ef          	jal	ra,ffffffffc0201a0a <strnlen>
ffffffffc0201828:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020182c:	01b05b63          	blez	s11,ffffffffc0201842 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201830:	67a2                	ld	a5,8(sp)
ffffffffc0201832:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201836:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201838:	85a6                	mv	a1,s1
ffffffffc020183a:	8552                	mv	a0,s4
ffffffffc020183c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020183e:	fe0d9ce3          	bnez	s11,ffffffffc0201836 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201842:	00044783          	lbu	a5,0(s0)
ffffffffc0201846:	00140a13          	addi	s4,s0,1
ffffffffc020184a:	0007851b          	sext.w	a0,a5
ffffffffc020184e:	d3a5                	beqz	a5,ffffffffc02017ae <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201850:	05e00413          	li	s0,94
ffffffffc0201854:	bf39                	j	ffffffffc0201772 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201856:	000a2403          	lw	s0,0(s4)
ffffffffc020185a:	b7ad                	j	ffffffffc02017c4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020185c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201860:	46a1                	li	a3,8
ffffffffc0201862:	8a2e                	mv	s4,a1
ffffffffc0201864:	bdb1                	j	ffffffffc02016c0 <vprintfmt+0x156>
ffffffffc0201866:	000a6603          	lwu	a2,0(s4)
ffffffffc020186a:	46a9                	li	a3,10
ffffffffc020186c:	8a2e                	mv	s4,a1
ffffffffc020186e:	bd89                	j	ffffffffc02016c0 <vprintfmt+0x156>
ffffffffc0201870:	000a6603          	lwu	a2,0(s4)
ffffffffc0201874:	46c1                	li	a3,16
ffffffffc0201876:	8a2e                	mv	s4,a1
ffffffffc0201878:	b5a1                	j	ffffffffc02016c0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020187a:	9902                	jalr	s2
ffffffffc020187c:	bf09                	j	ffffffffc020178e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020187e:	85a6                	mv	a1,s1
ffffffffc0201880:	02d00513          	li	a0,45
ffffffffc0201884:	e03e                	sd	a5,0(sp)
ffffffffc0201886:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201888:	6782                	ld	a5,0(sp)
ffffffffc020188a:	8a66                	mv	s4,s9
ffffffffc020188c:	40800633          	neg	a2,s0
ffffffffc0201890:	46a9                	li	a3,10
ffffffffc0201892:	b53d                	j	ffffffffc02016c0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201894:	03b05163          	blez	s11,ffffffffc02018b6 <vprintfmt+0x34c>
ffffffffc0201898:	02d00693          	li	a3,45
ffffffffc020189c:	f6d79de3          	bne	a5,a3,ffffffffc0201816 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02018a0:	00001417          	auipc	s0,0x1
ffffffffc02018a4:	e7040413          	addi	s0,s0,-400 # ffffffffc0202710 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a8:	02800793          	li	a5,40
ffffffffc02018ac:	02800513          	li	a0,40
ffffffffc02018b0:	00140a13          	addi	s4,s0,1
ffffffffc02018b4:	bd6d                	j	ffffffffc020176e <vprintfmt+0x204>
ffffffffc02018b6:	00001a17          	auipc	s4,0x1
ffffffffc02018ba:	e5ba0a13          	addi	s4,s4,-421 # ffffffffc0202711 <best_fit_pmm_manager+0x179>
ffffffffc02018be:	02800513          	li	a0,40
ffffffffc02018c2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018c6:	05e00413          	li	s0,94
ffffffffc02018ca:	b565                	j	ffffffffc0201772 <vprintfmt+0x208>

ffffffffc02018cc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018cc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02018ce:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018d2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018d4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018d6:	ec06                	sd	ra,24(sp)
ffffffffc02018d8:	f83a                	sd	a4,48(sp)
ffffffffc02018da:	fc3e                	sd	a5,56(sp)
ffffffffc02018dc:	e0c2                	sd	a6,64(sp)
ffffffffc02018de:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02018e0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018e2:	c89ff0ef          	jal	ra,ffffffffc020156a <vprintfmt>
}
ffffffffc02018e6:	60e2                	ld	ra,24(sp)
ffffffffc02018e8:	6161                	addi	sp,sp,80
ffffffffc02018ea:	8082                	ret

ffffffffc02018ec <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02018ec:	715d                	addi	sp,sp,-80
ffffffffc02018ee:	e486                	sd	ra,72(sp)
ffffffffc02018f0:	e0a6                	sd	s1,64(sp)
ffffffffc02018f2:	fc4a                	sd	s2,56(sp)
ffffffffc02018f4:	f84e                	sd	s3,48(sp)
ffffffffc02018f6:	f452                	sd	s4,40(sp)
ffffffffc02018f8:	f056                	sd	s5,32(sp)
ffffffffc02018fa:	ec5a                	sd	s6,24(sp)
ffffffffc02018fc:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02018fe:	c901                	beqz	a0,ffffffffc020190e <readline+0x22>
ffffffffc0201900:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201902:	00001517          	auipc	a0,0x1
ffffffffc0201906:	e2650513          	addi	a0,a0,-474 # ffffffffc0202728 <best_fit_pmm_manager+0x190>
ffffffffc020190a:	fa8fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020190e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201910:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201912:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201914:	4aa9                	li	s5,10
ffffffffc0201916:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201918:	00004b97          	auipc	s7,0x4
ffffffffc020191c:	718b8b93          	addi	s7,s7,1816 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201920:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201924:	807fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201928:	00054a63          	bltz	a0,ffffffffc020193c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020192c:	00a95a63          	bge	s2,a0,ffffffffc0201940 <readline+0x54>
ffffffffc0201930:	029a5263          	bge	s4,s1,ffffffffc0201954 <readline+0x68>
        c = getchar();
ffffffffc0201934:	ff6fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201938:	fe055ae3          	bgez	a0,ffffffffc020192c <readline+0x40>
            return NULL;
ffffffffc020193c:	4501                	li	a0,0
ffffffffc020193e:	a091                	j	ffffffffc0201982 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201940:	03351463          	bne	a0,s3,ffffffffc0201968 <readline+0x7c>
ffffffffc0201944:	e8a9                	bnez	s1,ffffffffc0201996 <readline+0xaa>
        c = getchar();
ffffffffc0201946:	fe4fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020194a:	fe0549e3          	bltz	a0,ffffffffc020193c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020194e:	fea959e3          	bge	s2,a0,ffffffffc0201940 <readline+0x54>
ffffffffc0201952:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201954:	e42a                	sd	a0,8(sp)
ffffffffc0201956:	f92fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020195a:	6522                	ld	a0,8(sp)
ffffffffc020195c:	009b87b3          	add	a5,s7,s1
ffffffffc0201960:	2485                	addiw	s1,s1,1
ffffffffc0201962:	00a78023          	sb	a0,0(a5)
ffffffffc0201966:	bf7d                	j	ffffffffc0201924 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201968:	01550463          	beq	a0,s5,ffffffffc0201970 <readline+0x84>
ffffffffc020196c:	fb651ce3          	bne	a0,s6,ffffffffc0201924 <readline+0x38>
            cputchar(c);
ffffffffc0201970:	f78fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201974:	00004517          	auipc	a0,0x4
ffffffffc0201978:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206030 <buf>
ffffffffc020197c:	94aa                	add	s1,s1,a0
ffffffffc020197e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201982:	60a6                	ld	ra,72(sp)
ffffffffc0201984:	6486                	ld	s1,64(sp)
ffffffffc0201986:	7962                	ld	s2,56(sp)
ffffffffc0201988:	79c2                	ld	s3,48(sp)
ffffffffc020198a:	7a22                	ld	s4,40(sp)
ffffffffc020198c:	7a82                	ld	s5,32(sp)
ffffffffc020198e:	6b62                	ld	s6,24(sp)
ffffffffc0201990:	6bc2                	ld	s7,16(sp)
ffffffffc0201992:	6161                	addi	sp,sp,80
ffffffffc0201994:	8082                	ret
            cputchar(c);
ffffffffc0201996:	4521                	li	a0,8
ffffffffc0201998:	f50fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc020199c:	34fd                	addiw	s1,s1,-1
ffffffffc020199e:	b759                	j	ffffffffc0201924 <readline+0x38>

ffffffffc02019a0 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02019a0:	4781                	li	a5,0
ffffffffc02019a2:	00004717          	auipc	a4,0x4
ffffffffc02019a6:	66673703          	ld	a4,1638(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02019aa:	88ba                	mv	a7,a4
ffffffffc02019ac:	852a                	mv	a0,a0
ffffffffc02019ae:	85be                	mv	a1,a5
ffffffffc02019b0:	863e                	mv	a2,a5
ffffffffc02019b2:	00000073          	ecall
ffffffffc02019b6:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02019b8:	8082                	ret

ffffffffc02019ba <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02019ba:	4781                	li	a5,0
ffffffffc02019bc:	00005717          	auipc	a4,0x5
ffffffffc02019c0:	abc73703          	ld	a4,-1348(a4) # ffffffffc0206478 <SBI_SET_TIMER>
ffffffffc02019c4:	88ba                	mv	a7,a4
ffffffffc02019c6:	852a                	mv	a0,a0
ffffffffc02019c8:	85be                	mv	a1,a5
ffffffffc02019ca:	863e                	mv	a2,a5
ffffffffc02019cc:	00000073          	ecall
ffffffffc02019d0:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02019d2:	8082                	ret

ffffffffc02019d4 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02019d4:	4501                	li	a0,0
ffffffffc02019d6:	00004797          	auipc	a5,0x4
ffffffffc02019da:	62a7b783          	ld	a5,1578(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02019de:	88be                	mv	a7,a5
ffffffffc02019e0:	852a                	mv	a0,a0
ffffffffc02019e2:	85aa                	mv	a1,a0
ffffffffc02019e4:	862a                	mv	a2,a0
ffffffffc02019e6:	00000073          	ecall
ffffffffc02019ea:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc02019ec:	2501                	sext.w	a0,a0
ffffffffc02019ee:	8082                	ret

ffffffffc02019f0 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc02019f0:	4781                	li	a5,0
ffffffffc02019f2:	00004717          	auipc	a4,0x4
ffffffffc02019f6:	61e73703          	ld	a4,1566(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc02019fa:	88ba                	mv	a7,a4
ffffffffc02019fc:	853e                	mv	a0,a5
ffffffffc02019fe:	85be                	mv	a1,a5
ffffffffc0201a00:	863e                	mv	a2,a5
ffffffffc0201a02:	00000073          	ecall
ffffffffc0201a06:	87aa                	mv	a5,a0

void sbi_shutdown(void) {
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201a08:	8082                	ret

ffffffffc0201a0a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201a0a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a0c:	e589                	bnez	a1,ffffffffc0201a16 <strnlen+0xc>
ffffffffc0201a0e:	a811                	j	ffffffffc0201a22 <strnlen+0x18>
        cnt ++;
ffffffffc0201a10:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a12:	00f58863          	beq	a1,a5,ffffffffc0201a22 <strnlen+0x18>
ffffffffc0201a16:	00f50733          	add	a4,a0,a5
ffffffffc0201a1a:	00074703          	lbu	a4,0(a4)
ffffffffc0201a1e:	fb6d                	bnez	a4,ffffffffc0201a10 <strnlen+0x6>
ffffffffc0201a20:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a22:	852e                	mv	a0,a1
ffffffffc0201a24:	8082                	ret

ffffffffc0201a26 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a26:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a2a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a2e:	cb89                	beqz	a5,ffffffffc0201a40 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a30:	0505                	addi	a0,a0,1
ffffffffc0201a32:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a34:	fee789e3          	beq	a5,a4,ffffffffc0201a26 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a38:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a3c:	9d19                	subw	a0,a0,a4
ffffffffc0201a3e:	8082                	ret
ffffffffc0201a40:	4501                	li	a0,0
ffffffffc0201a42:	bfed                	j	ffffffffc0201a3c <strcmp+0x16>

ffffffffc0201a44 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a44:	00054783          	lbu	a5,0(a0)
ffffffffc0201a48:	c799                	beqz	a5,ffffffffc0201a56 <strchr+0x12>
        if (*s == c) {
ffffffffc0201a4a:	00f58763          	beq	a1,a5,ffffffffc0201a58 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201a4e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201a52:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201a54:	fbfd                	bnez	a5,ffffffffc0201a4a <strchr+0x6>
    }
    return NULL;
ffffffffc0201a56:	4501                	li	a0,0
}
ffffffffc0201a58:	8082                	ret

ffffffffc0201a5a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a5a:	ca01                	beqz	a2,ffffffffc0201a6a <memset+0x10>
ffffffffc0201a5c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a5e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a60:	0785                	addi	a5,a5,1
ffffffffc0201a62:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a66:	fec79de3          	bne	a5,a2,ffffffffc0201a60 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a6a:	8082                	ret
