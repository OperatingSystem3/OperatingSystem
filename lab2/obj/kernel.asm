
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
ffffffffc020003a:	00007617          	auipc	a2,0x7
ffffffffc020003e:	92660613          	addi	a2,a2,-1754 # ffffffffc0206960 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	476010ef          	jal	ra,ffffffffc02014c0 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	48650513          	addi	a0,a0,1158 # ffffffffc02014d8 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	041000ef          	jal	ra,ffffffffc02008a6 <pmm_init>

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
ffffffffc02000a6:	72b000ef          	jal	ra,ffffffffc0200fd0 <vprintfmt>
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
ffffffffc02000dc:	6f5000ef          	jal	ra,ffffffffc0200fd0 <vprintfmt>
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
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	3bc50513          	addi	a0,a0,956 # ffffffffc02014f8 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	3c650513          	addi	a0,a0,966 # ffffffffc0201518 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	37458593          	addi	a1,a1,884 # ffffffffc02014d2 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	3d250513          	addi	a0,a0,978 # ffffffffc0201538 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	3de50513          	addi	a0,a0,990 # ffffffffc0201558 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	7da58593          	addi	a1,a1,2010 # ffffffffc0206960 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	3ea50513          	addi	a0,a0,1002 # ffffffffc0201578 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00007597          	auipc	a1,0x7
ffffffffc020019e:	bc558593          	addi	a1,a1,-1083 # ffffffffc0206d5f <end+0x3ff>
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
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	3dc50513          	addi	a0,a0,988 # ffffffffc0201598 <etext+0xc6>
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
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	3fe60613          	addi	a2,a2,1022 # ffffffffc02015c8 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	40a50513          	addi	a0,a0,1034 # ffffffffc02015e0 <etext+0x10e>
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
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	41260613          	addi	a2,a2,1042 # ffffffffc02015f8 <etext+0x126>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	42a58593          	addi	a1,a1,1066 # ffffffffc0201618 <etext+0x146>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	42a50513          	addi	a0,a0,1066 # ffffffffc0201620 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	42c60613          	addi	a2,a2,1068 # ffffffffc0201630 <etext+0x15e>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	44c58593          	addi	a1,a1,1100 # ffffffffc0201658 <etext+0x186>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	40c50513          	addi	a0,a0,1036 # ffffffffc0201620 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	44860613          	addi	a2,a2,1096 # ffffffffc0201668 <etext+0x196>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	46058593          	addi	a1,a1,1120 # ffffffffc0201688 <etext+0x1b6>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	3f050513          	addi	a0,a0,1008 # ffffffffc0201620 <etext+0x14e>
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
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	42e50513          	addi	a0,a0,1070 # ffffffffc0201698 <etext+0x1c6>
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
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	43450513          	addi	a0,a0,1076 # ffffffffc02016c0 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	48ec0c13          	addi	s8,s8,1166 # ffffffffc0201730 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	43e90913          	addi	s2,s2,1086 # ffffffffc02016e8 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	43e48493          	addi	s1,s1,1086 # ffffffffc02016f0 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	43cb0b13          	addi	s6,s6,1084 # ffffffffc02016f8 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	354a0a13          	addi	s4,s4,852 # ffffffffc0201618 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	082010ef          	jal	ra,ffffffffc0201352 <readline>
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
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	44ad0d13          	addi	s10,s10,1098 # ffffffffc0201730 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	198010ef          	jal	ra,ffffffffc020148c <strcmp>
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
ffffffffc0200308:	184010ef          	jal	ra,ffffffffc020148c <strcmp>
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
ffffffffc0200346:	164010ef          	jal	ra,ffffffffc02014aa <strchr>
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
ffffffffc0200384:	126010ef          	jal	ra,ffffffffc02014aa <strchr>
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
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	37a50513          	addi	a0,a0,890 # ffffffffc0201718 <etext+0x246>
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
ffffffffc02003b0:	55430313          	addi	t1,t1,1364 # ffffffffc0206900 <is_panic>
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
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	39e50513          	addi	a0,a0,926 # ffffffffc0201778 <commands+0x48>
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
ffffffffc02003f4:	1d050513          	addi	a0,a0,464 # ffffffffc02015c0 <etext+0xee>
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
ffffffffc0200420:	000010ef          	jal	ra,ffffffffc0201420 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	4e07b123          	sd	zero,1250(a5) # ffffffffc0206908 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	36a50513          	addi	a0,a0,874 # ffffffffc0201798 <commands+0x68>
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
ffffffffc0200446:	7db0006f          	j	ffffffffc0201420 <sbi_set_timer>

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
ffffffffc0200450:	7b70006f          	j	ffffffffc0201406 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	7e70006f          	j	ffffffffc020143a <sbi_console_getchar>

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
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	33a50513          	addi	a0,a0,826 # ffffffffc02017b8 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	34250513          	addi	a0,a0,834 # ffffffffc02017d0 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	34c50513          	addi	a0,a0,844 # ffffffffc02017e8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	35650513          	addi	a0,a0,854 # ffffffffc0201800 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	36050513          	addi	a0,a0,864 # ffffffffc0201818 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	36a50513          	addi	a0,a0,874 # ffffffffc0201830 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	37450513          	addi	a0,a0,884 # ffffffffc0201848 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	37e50513          	addi	a0,a0,894 # ffffffffc0201860 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	38850513          	addi	a0,a0,904 # ffffffffc0201878 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	39250513          	addi	a0,a0,914 # ffffffffc0201890 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	39c50513          	addi	a0,a0,924 # ffffffffc02018a8 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	3a650513          	addi	a0,a0,934 # ffffffffc02018c0 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	3b050513          	addi	a0,a0,944 # ffffffffc02018d8 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	3ba50513          	addi	a0,a0,954 # ffffffffc02018f0 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	3c450513          	addi	a0,a0,964 # ffffffffc0201908 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	3ce50513          	addi	a0,a0,974 # ffffffffc0201920 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	3d850513          	addi	a0,a0,984 # ffffffffc0201938 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	3e250513          	addi	a0,a0,994 # ffffffffc0201950 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	3ec50513          	addi	a0,a0,1004 # ffffffffc0201968 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	3f650513          	addi	a0,a0,1014 # ffffffffc0201980 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	40050513          	addi	a0,a0,1024 # ffffffffc0201998 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	40a50513          	addi	a0,a0,1034 # ffffffffc02019b0 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	41450513          	addi	a0,a0,1044 # ffffffffc02019c8 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	41e50513          	addi	a0,a0,1054 # ffffffffc02019e0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	42850513          	addi	a0,a0,1064 # ffffffffc02019f8 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	43250513          	addi	a0,a0,1074 # ffffffffc0201a10 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	43c50513          	addi	a0,a0,1084 # ffffffffc0201a28 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	44650513          	addi	a0,a0,1094 # ffffffffc0201a40 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	45050513          	addi	a0,a0,1104 # ffffffffc0201a58 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	45a50513          	addi	a0,a0,1114 # ffffffffc0201a70 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	46450513          	addi	a0,a0,1124 # ffffffffc0201a88 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	46a50513          	addi	a0,a0,1130 # ffffffffc0201aa0 <commands+0x370>
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
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	46e50513          	addi	a0,a0,1134 # ffffffffc0201ab8 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	46e50513          	addi	a0,a0,1134 # ffffffffc0201ad0 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	47650513          	addi	a0,a0,1142 # ffffffffc0201ae8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	47e50513          	addi	a0,a0,1150 # ffffffffc0201b00 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	48250513          	addi	a0,a0,1154 # ffffffffc0201b18 <commands+0x3e8>
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
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	54870713          	addi	a4,a4,1352 # ffffffffc0201bf8 <commands+0x4c8>
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
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	4ce50513          	addi	a0,a0,1230 # ffffffffc0201b90 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	4a450513          	addi	a0,a0,1188 # ffffffffc0201b70 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	45a50513          	addi	a0,a0,1114 # ffffffffc0201b30 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	4d050513          	addi	a0,a0,1232 # ffffffffc0201bb0 <commands+0x480>
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
ffffffffc02006f8:	21468693          	addi	a3,a3,532 # ffffffffc0206908 <ticks>
ffffffffc02006fc:	629c                	ld	a5,0(a3)
ffffffffc02006fe:	06400713          	li	a4,100
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	20e40413          	addi	s0,s0,526 # ffffffffc0206910 <num>
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
ffffffffc0200724:	00001517          	auipc	a0,0x1
ffffffffc0200728:	4b450513          	addi	a0,a0,1204 # ffffffffc0201bd8 <commands+0x4a8>
ffffffffc020072c:	b259                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020072e:	00001517          	auipc	a0,0x1
ffffffffc0200732:	42250513          	addi	a0,a0,1058 # ffffffffc0201b50 <commands+0x420>
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200738:	b729                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073a:	06400593          	li	a1,100
ffffffffc020073e:	00001517          	auipc	a0,0x1
ffffffffc0200742:	48a50513          	addi	a0,a0,1162 # ffffffffc0201bc8 <commands+0x498>
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
ffffffffc0200758:	4ff0006f          	j	ffffffffc0201456 <sbi_shutdown>

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
ffffffffc0200778:	00001517          	auipc	a0,0x1
ffffffffc020077c:	4b050513          	addi	a0,a0,1200 # ffffffffc0201c28 <commands+0x4f8>
ffffffffc0200780:	933ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200784:	10843583          	ld	a1,264(s0)
ffffffffc0200788:	00001517          	auipc	a0,0x1
ffffffffc020078c:	4c850513          	addi	a0,a0,1224 # ffffffffc0201c50 <commands+0x520>
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
ffffffffc02007b6:	00001517          	auipc	a0,0x1
ffffffffc02007ba:	4c250513          	addi	a0,a0,1218 # ffffffffc0201c78 <commands+0x548>
ffffffffc02007be:	8f5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc02007c2:	10843583          	ld	a1,264(s0)
ffffffffc02007c6:	00001517          	auipc	a0,0x1
ffffffffc02007ca:	4d250513          	addi	a0,a0,1234 # ffffffffc0201c98 <commands+0x568>
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

ffffffffc02008a6 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &slub_pmm_manager;
ffffffffc02008a6:	00001797          	auipc	a5,0x1
ffffffffc02008aa:	60278793          	addi	a5,a5,1538 # ffffffffc0201ea8 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008ae:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008b0:	1101                	addi	sp,sp,-32
ffffffffc02008b2:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008b4:	00001517          	auipc	a0,0x1
ffffffffc02008b8:	40450513          	addi	a0,a0,1028 # ffffffffc0201cb8 <commands+0x588>
    pmm_manager = &slub_pmm_manager;
ffffffffc02008bc:	00006497          	auipc	s1,0x6
ffffffffc02008c0:	06c48493          	addi	s1,s1,108 # ffffffffc0206928 <pmm_manager>
void pmm_init(void) {
ffffffffc02008c4:	ec06                	sd	ra,24(sp)
ffffffffc02008c6:	e822                	sd	s0,16(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc02008c8:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008ca:	fe8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02008ce:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008d0:	00006417          	auipc	s0,0x6
ffffffffc02008d4:	07040413          	addi	s0,s0,112 # ffffffffc0206940 <va_pa_offset>
    pmm_manager->init();
ffffffffc02008d8:	679c                	ld	a5,8(a5)
ffffffffc02008da:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008dc:	57f5                	li	a5,-3
ffffffffc02008de:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008e0:	00001517          	auipc	a0,0x1
ffffffffc02008e4:	3f050513          	addi	a0,a0,1008 # ffffffffc0201cd0 <commands+0x5a0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008e8:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02008ea:	fc8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02008ee:	46c5                	li	a3,17
ffffffffc02008f0:	06ee                	slli	a3,a3,0x1b
ffffffffc02008f2:	40100613          	li	a2,1025
ffffffffc02008f6:	16fd                	addi	a3,a3,-1
ffffffffc02008f8:	07e005b7          	lui	a1,0x7e00
ffffffffc02008fc:	0656                	slli	a2,a2,0x15
ffffffffc02008fe:	00001517          	auipc	a0,0x1
ffffffffc0200902:	3ea50513          	addi	a0,a0,1002 # ffffffffc0201ce8 <commands+0x5b8>
ffffffffc0200906:	facff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020090a:	777d                	lui	a4,0xfffff
ffffffffc020090c:	00007797          	auipc	a5,0x7
ffffffffc0200910:	05378793          	addi	a5,a5,83 # ffffffffc020795f <end+0xfff>
ffffffffc0200914:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200916:	00006517          	auipc	a0,0x6
ffffffffc020091a:	00250513          	addi	a0,a0,2 # ffffffffc0206918 <npage>
ffffffffc020091e:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200922:	00006597          	auipc	a1,0x6
ffffffffc0200926:	ffe58593          	addi	a1,a1,-2 # ffffffffc0206920 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020092a:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020092c:	e19c                	sd	a5,0(a1)
ffffffffc020092e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200930:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200932:	4885                	li	a7,1
ffffffffc0200934:	fff80837          	lui	a6,0xfff80
ffffffffc0200938:	a011                	j	ffffffffc020093c <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020093a:	619c                	ld	a5,0(a1)
ffffffffc020093c:	97b6                	add	a5,a5,a3
ffffffffc020093e:	07a1                	addi	a5,a5,8
ffffffffc0200940:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200944:	611c                	ld	a5,0(a0)
ffffffffc0200946:	0705                	addi	a4,a4,1
ffffffffc0200948:	02868693          	addi	a3,a3,40
ffffffffc020094c:	01078633          	add	a2,a5,a6
ffffffffc0200950:	fec765e3          	bltu	a4,a2,ffffffffc020093a <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200954:	6190                	ld	a2,0(a1)
ffffffffc0200956:	00279713          	slli	a4,a5,0x2
ffffffffc020095a:	973e                	add	a4,a4,a5
ffffffffc020095c:	fec006b7          	lui	a3,0xfec00
ffffffffc0200960:	070e                	slli	a4,a4,0x3
ffffffffc0200962:	96b2                	add	a3,a3,a2
ffffffffc0200964:	96ba                	add	a3,a3,a4
ffffffffc0200966:	c0200737          	lui	a4,0xc0200
ffffffffc020096a:	08e6ef63          	bltu	a3,a4,ffffffffc0200a08 <pmm_init+0x162>
ffffffffc020096e:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200970:	45c5                	li	a1,17
ffffffffc0200972:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200974:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200976:	04b6e863          	bltu	a3,a1,ffffffffc02009c6 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020097a:	609c                	ld	a5,0(s1)
ffffffffc020097c:	7b9c                	ld	a5,48(a5)
ffffffffc020097e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200980:	00001517          	auipc	a0,0x1
ffffffffc0200984:	40050513          	addi	a0,a0,1024 # ffffffffc0201d80 <commands+0x650>
ffffffffc0200988:	f2aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020098c:	00004597          	auipc	a1,0x4
ffffffffc0200990:	67458593          	addi	a1,a1,1652 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200994:	00006797          	auipc	a5,0x6
ffffffffc0200998:	fab7b223          	sd	a1,-92(a5) # ffffffffc0206938 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020099c:	c02007b7          	lui	a5,0xc0200
ffffffffc02009a0:	08f5e063          	bltu	a1,a5,ffffffffc0200a20 <pmm_init+0x17a>
ffffffffc02009a4:	6010                	ld	a2,0(s0)
}
ffffffffc02009a6:	6442                	ld	s0,16(sp)
ffffffffc02009a8:	60e2                	ld	ra,24(sp)
ffffffffc02009aa:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02009ac:	40c58633          	sub	a2,a1,a2
ffffffffc02009b0:	00006797          	auipc	a5,0x6
ffffffffc02009b4:	f8c7b023          	sd	a2,-128(a5) # ffffffffc0206930 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009b8:	00001517          	auipc	a0,0x1
ffffffffc02009bc:	3e850513          	addi	a0,a0,1000 # ffffffffc0201da0 <commands+0x670>
}
ffffffffc02009c0:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009c2:	ef0ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02009c6:	6705                	lui	a4,0x1
ffffffffc02009c8:	177d                	addi	a4,a4,-1
ffffffffc02009ca:	96ba                	add	a3,a3,a4
ffffffffc02009cc:	777d                	lui	a4,0xfffff
ffffffffc02009ce:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009d0:	00c6d513          	srli	a0,a3,0xc
ffffffffc02009d4:	00f57e63          	bgeu	a0,a5,ffffffffc02009f0 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02009d8:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009da:	982a                	add	a6,a6,a0
ffffffffc02009dc:	00281513          	slli	a0,a6,0x2
ffffffffc02009e0:	9542                	add	a0,a0,a6
ffffffffc02009e2:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02009e4:	8d95                	sub	a1,a1,a3
ffffffffc02009e6:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02009e8:	81b1                	srli	a1,a1,0xc
ffffffffc02009ea:	9532                	add	a0,a0,a2
ffffffffc02009ec:	9782                	jalr	a5
}
ffffffffc02009ee:	b771                	j	ffffffffc020097a <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02009f0:	00001617          	auipc	a2,0x1
ffffffffc02009f4:	36060613          	addi	a2,a2,864 # ffffffffc0201d50 <commands+0x620>
ffffffffc02009f8:	06b00593          	li	a1,107
ffffffffc02009fc:	00001517          	auipc	a0,0x1
ffffffffc0200a00:	37450513          	addi	a0,a0,884 # ffffffffc0201d70 <commands+0x640>
ffffffffc0200a04:	9a9ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a08:	00001617          	auipc	a2,0x1
ffffffffc0200a0c:	31060613          	addi	a2,a2,784 # ffffffffc0201d18 <commands+0x5e8>
ffffffffc0200a10:	07000593          	li	a1,112
ffffffffc0200a14:	00001517          	auipc	a0,0x1
ffffffffc0200a18:	32c50513          	addi	a0,a0,812 # ffffffffc0201d40 <commands+0x610>
ffffffffc0200a1c:	991ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a20:	86ae                	mv	a3,a1
ffffffffc0200a22:	00001617          	auipc	a2,0x1
ffffffffc0200a26:	2f660613          	addi	a2,a2,758 # ffffffffc0201d18 <commands+0x5e8>
ffffffffc0200a2a:	08b00593          	li	a1,139
ffffffffc0200a2e:	00001517          	auipc	a0,0x1
ffffffffc0200a32:	31250513          	addi	a0,a0,786 # ffffffffc0201d40 <commands+0x610>
ffffffffc0200a36:	977ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a3a <buddy_nr_free_pages>:
}

// 获取当前空闲页面数量的函数
static size_t buddy_nr_free_pages(void) {
    return total_nr_free;
}
ffffffffc0200a3a:	00006517          	auipc	a0,0x6
ffffffffc0200a3e:	f1a56503          	lwu	a0,-230(a0) # ffffffffc0206954 <total_nr_free>
ffffffffc0200a42:	8082                	ret

ffffffffc0200a44 <slub_init>:
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a44:	00005797          	auipc	a5,0x5
ffffffffc0200a48:	5d478793          	addi	a5,a5,1492 # ffffffffc0206018 <free_area>
ffffffffc0200a4c:	00005717          	auipc	a4,0x5
ffffffffc0200a50:	73470713          	addi	a4,a4,1844 # ffffffffc0206180 <k_cache_nodes+0x48>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a54:	e79c                	sd	a5,8(a5)
ffffffffc0200a56:	e39c                	sd	a5,0(a5)
        free_area[i].nr_free = 0;
ffffffffc0200a58:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a5c:	07e1                	addi	a5,a5,24
ffffffffc0200a5e:	fee79be3          	bne	a5,a4,ffffffffc0200a54 <slub_init+0x10>
    max_order=0;
ffffffffc0200a62:	00006897          	auipc	a7,0x6
ffffffffc0200a66:	8e688893          	addi	a7,a7,-1818 # ffffffffc0206348 <kmallo_caches>
ffffffffc0200a6a:	00006797          	auipc	a5,0x6
ffffffffc0200a6e:	ee07a323          	sw	zero,-282(a5) # ffffffffc0206950 <max_order>
    total_nr_free=0;
ffffffffc0200a72:	00006797          	auipc	a5,0x6
ffffffffc0200a76:	ee07a123          	sw	zero,-286(a5) # ffffffffc0206954 <total_nr_free>
{
     elm->next=NULL;
}

static void init_kmallo_caches(){
    for(int i=0;i<11;i++)
ffffffffc0200a7a:	00005697          	auipc	a3,0x5
ffffffffc0200a7e:	5b668693          	addi	a3,a3,1462 # ffffffffc0206030 <k_cache_cpus>
ffffffffc0200a82:	00005797          	auipc	a5,0x5
ffffffffc0200a86:	6c678793          	addi	a5,a5,1734 # ffffffffc0206148 <k_cache_nodes+0x10>
ffffffffc0200a8a:	8746                	mv	a4,a7
    total_nr_free=0;
ffffffffc0200a8c:	4601                	li	a2,0
    for(int i=0;i<11;i++)
ffffffffc0200a8e:	4581                	li	a1,0
    {   if(i==0)
    {
     kmallo_caches[i].size=calculate_bufferpool(96);
     kmallo_caches[i].offset=96;
    }
        else if(i==1)
ffffffffc0200a90:	4f05                	li	t5,1
    {
     kmallo_caches[i].size=calculate_bufferpool(192);
     kmallo_caches[i].offset=192;
        }
        else{
     kmallo_caches[i].size=calculate_bufferpool(1<<(i+1));
ffffffffc0200a92:	6305                	lui	t1,0x1
ffffffffc0200a94:	4e85                	li	t4,1
    for(int i=0;i<11;i++)
ffffffffc0200a96:	42ad                	li	t0,11
     kmallo_caches[i].offset=192;
ffffffffc0200a98:	0c000393          	li	t2,192
     kmallo_caches[i].offset=96;
ffffffffc0200a9c:	06000f93          	li	t6,96
ffffffffc0200aa0:	a835                	j	ffffffffc0200adc <slub_init+0x98>
     kmallo_caches[i].offset=1<<(i+1);
ffffffffc0200aa2:	00be9e3b          	sllw	t3,t4,a1
        else if(i==1)
ffffffffc0200aa6:	07e60363          	beq	a2,t5,ffffffffc0200b0c <slub_init+0xc8>
     k_cache_nodes[i].nr_full==0;
     k_cache_nodes[i].nr_partial==0;
     list_init(&(k_cache_nodes[i].page_link_partial));
     list_init(&(k_cache_nodes[i].page_link_full));
    kmallo_caches[i].free_blocks=0;
    kmallo_caches[i].cpu_slab=&(k_cache_cpus[i]);
ffffffffc0200aaa:	ef14                	sd	a3,24(a4)
     kmallo_caches[i].size=calculate_bufferpool(1<<(i+1));
ffffffffc0200aac:	00673023          	sd	t1,0(a4)
     kmallo_caches[i].offset=1<<(i+1);
ffffffffc0200ab0:	01c73423          	sd	t3,8(a4)
     elm->next=NULL;
ffffffffc0200ab4:	0006b423          	sd	zero,8(a3)
     k_cache_cpus[i].page=NULL;
ffffffffc0200ab8:	0006b823          	sd	zero,16(a3)
ffffffffc0200abc:	e79c                	sd	a5,8(a5)
ffffffffc0200abe:	e39c                	sd	a5,0(a5)
ffffffffc0200ac0:	ef88                	sd	a0,24(a5)
ffffffffc0200ac2:	eb88                	sd	a0,16(a5)
    kmallo_caches[i].free_blocks=0;
ffffffffc0200ac4:	00072823          	sw	zero,16(a4)
    kmallo_caches[i].node=&(k_cache_nodes[i]);
ffffffffc0200ac8:	03073023          	sd	a6,32(a4)
    for(int i=0;i<11;i++)
ffffffffc0200acc:	04558563          	beq	a1,t0,ffffffffc0200b16 <slub_init+0xd2>
ffffffffc0200ad0:	2605                	addiw	a2,a2,1
ffffffffc0200ad2:	06e1                	addi	a3,a3,24
ffffffffc0200ad4:	03078793          	addi	a5,a5,48
ffffffffc0200ad8:	02870713          	addi	a4,a4,40
        else if(i==1)
ffffffffc0200adc:	01078513          	addi	a0,a5,16
     kmallo_caches[i].size=calculate_bufferpool(1<<(i+1));
ffffffffc0200ae0:	2585                	addiw	a1,a1,1
ffffffffc0200ae2:	ff078813          	addi	a6,a5,-16
    {   if(i==0)
ffffffffc0200ae6:	fe55                	bnez	a2,ffffffffc0200aa2 <slub_init+0x5e>
     kmallo_caches[i].size=calculate_bufferpool(96);
ffffffffc0200ae8:	0068b023          	sd	t1,0(a7)
     kmallo_caches[i].offset=96;
ffffffffc0200aec:	01f8b423          	sd	t6,8(a7)
     elm->next=NULL;
ffffffffc0200af0:	0006b423          	sd	zero,8(a3)
     k_cache_cpus[i].page=NULL;
ffffffffc0200af4:	0006b823          	sd	zero,16(a3)
ffffffffc0200af8:	e79c                	sd	a5,8(a5)
ffffffffc0200afa:	e39c                	sd	a5,0(a5)
ffffffffc0200afc:	ef88                	sd	a0,24(a5)
ffffffffc0200afe:	eb88                	sd	a0,16(a5)
    kmallo_caches[i].free_blocks=0;
ffffffffc0200b00:	00072823          	sw	zero,16(a4)
    kmallo_caches[i].cpu_slab=&(k_cache_cpus[i]);
ffffffffc0200b04:	ef14                	sd	a3,24(a4)
    kmallo_caches[i].node=&(k_cache_nodes[i]);
ffffffffc0200b06:	03073023          	sd	a6,32(a4)
    for(int i=0;i<11;i++)
ffffffffc0200b0a:	b7d9                	j	ffffffffc0200ad0 <slub_init+0x8c>
     kmallo_caches[i].size=calculate_bufferpool(192);
ffffffffc0200b0c:	0268b423          	sd	t1,40(a7)
     kmallo_caches[i].offset=192;
ffffffffc0200b10:	0278b823          	sd	t2,48(a7)
ffffffffc0200b14:	bff1                	j	ffffffffc0200af0 <slub_init+0xac>

static void
slub_init(void)
{   buddy_init();//初始化所有空闲链表
    init_kmallo_caches();//初始化前三个总框
}
ffffffffc0200b16:	8082                	ret

ffffffffc0200b18 <slub_check>:

static void
slub_check(void) {


    cprintf("You are going to check your code!!!\n");
ffffffffc0200b18:	00001517          	auipc	a0,0x1
ffffffffc0200b1c:	2c850513          	addi	a0,a0,712 # ffffffffc0201de0 <commands+0x6b0>
ffffffffc0200b20:	d92ff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc0200b24 <slub_init_memap>:
{
ffffffffc0200b24:	1101                	addi	sp,sp,-32
ffffffffc0200b26:	ec06                	sd	ra,24(sp)
ffffffffc0200b28:	e822                	sd	s0,16(sp)
ffffffffc0200b2a:	e426                	sd	s1,8(sp)
ffffffffc0200b2c:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc0200b2e:	cdf1                	beqz	a1,ffffffffc0200c0a <slub_init_memap+0xe6>
    if (n & (n - 1)) 
ffffffffc0200b30:	fff58793          	addi	a5,a1,-1
ffffffffc0200b34:	8fed                	and	a5,a5,a1
ffffffffc0200b36:	842e                	mv	s0,a1
ffffffffc0200b38:	84aa                	mv	s1,a0
ffffffffc0200b3a:	c799                	beqz	a5,ffffffffc0200b48 <slub_init_memap+0x24>
ffffffffc0200b3c:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200b3e:	8005                	srli	s0,s0,0x1
            res = res << 1;
ffffffffc0200b40:	0786                	slli	a5,a5,0x1
        while (n) {
ffffffffc0200b42:	fc75                	bnez	s0,ffffffffc0200b3e <slub_init_memap+0x1a>
        return res>>1; 
ffffffffc0200b44:	0017d413          	srli	s0,a5,0x1
    while (n >> 1) {
ffffffffc0200b48:	00145793          	srli	a5,s0,0x1
    unsigned int order = 0;
ffffffffc0200b4c:	4581                	li	a1,0
    while (n >> 1) {
ffffffffc0200b4e:	c781                	beqz	a5,ffffffffc0200b56 <slub_init_memap+0x32>
ffffffffc0200b50:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200b52:	2585                	addiw	a1,a1,1
    while (n >> 1) {
ffffffffc0200b54:	fff5                	bnez	a5,ffffffffc0200b50 <slub_init_memap+0x2c>
    max_order = order;
ffffffffc0200b56:	00006917          	auipc	s2,0x6
ffffffffc0200b5a:	dfa90913          	addi	s2,s2,-518 # ffffffffc0206950 <max_order>
    cprintf("------------------------------maxorder %d\n",max_order);
ffffffffc0200b5e:	00001517          	auipc	a0,0x1
ffffffffc0200b62:	2da50513          	addi	a0,a0,730 # ffffffffc0201e38 <commands+0x708>
    buddy_start=base;
ffffffffc0200b66:	00006797          	auipc	a5,0x6
ffffffffc0200b6a:	de97b123          	sd	s1,-542(a5) # ffffffffc0206948 <buddy_start>
    max_order = order;
ffffffffc0200b6e:	00b92023          	sw	a1,0(s2)
    total_nr_free = pnum;
ffffffffc0200b72:	00006797          	auipc	a5,0x6
ffffffffc0200b76:	de87a123          	sw	s0,-542(a5) # ffffffffc0206954 <total_nr_free>
    cprintf("------------------------------maxorder %d\n",max_order);
ffffffffc0200b7a:	d38ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (; p != base + pnum; p ++) {
ffffffffc0200b7e:	00241693          	slli	a3,s0,0x2
ffffffffc0200b82:	96a2                	add	a3,a3,s0
ffffffffc0200b84:	068e                	slli	a3,a3,0x3
ffffffffc0200b86:	96a6                	add	a3,a3,s1
ffffffffc0200b88:	02d48063          	beq	s1,a3,ffffffffc0200ba8 <slub_init_memap+0x84>
ffffffffc0200b8c:	87a6                	mv	a5,s1
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b8e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200b90:	8b05                	andi	a4,a4,1
ffffffffc0200b92:	cf21                	beqz	a4,ffffffffc0200bea <slub_init_memap+0xc6>
        p->flags = 0;
ffffffffc0200b94:	0007b423          	sd	zero,8(a5)
        p->property =0;   
ffffffffc0200b98:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200b9c:	0007a023          	sw	zero,0(a5)
    for (; p != base + pnum; p ++) {
ffffffffc0200ba0:	02878793          	addi	a5,a5,40
ffffffffc0200ba4:	fef695e3          	bne	a3,a5,ffffffffc0200b8e <slub_init_memap+0x6a>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ba8:	00096703          	lwu	a4,0(s2)
    list_add(&(free_area[max_order].free_list), &(base->page_link)); // 将第一页base插入对应的链表中
ffffffffc0200bac:	01848693          	addi	a3,s1,24
ffffffffc0200bb0:	00171793          	slli	a5,a4,0x1
ffffffffc0200bb4:	97ba                	add	a5,a5,a4
ffffffffc0200bb6:	00379713          	slli	a4,a5,0x3
ffffffffc0200bba:	00005797          	auipc	a5,0x5
ffffffffc0200bbe:	45e78793          	addi	a5,a5,1118 # ffffffffc0206018 <free_area>
ffffffffc0200bc2:	97ba                	add	a5,a5,a4
ffffffffc0200bc4:	6798                	ld	a4,8(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bc6:	e314                	sd	a3,0(a4)
ffffffffc0200bc8:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc0200bca:	f098                	sd	a4,32(s1)
    elm->prev = prev;
ffffffffc0200bcc:	ec9c                	sd	a5,24(s1)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200bce:	00848713          	addi	a4,s1,8
ffffffffc0200bd2:	4789                	li	a5,2
ffffffffc0200bd4:	40f7302f          	amoor.d	zero,a5,(a4)
    base->property = max_order;           // 将第一页base的property设为最大块的2幂
ffffffffc0200bd8:	00092783          	lw	a5,0(s2)
}
ffffffffc0200bdc:	60e2                	ld	ra,24(sp)
ffffffffc0200bde:	6442                	ld	s0,16(sp)
    base->property = max_order;           // 将第一页base的property设为最大块的2幂
ffffffffc0200be0:	c89c                	sw	a5,16(s1)
}
ffffffffc0200be2:	6902                	ld	s2,0(sp)
ffffffffc0200be4:	64a2                	ld	s1,8(sp)
ffffffffc0200be6:	6105                	addi	sp,sp,32
ffffffffc0200be8:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200bea:	00001697          	auipc	a3,0x1
ffffffffc0200bee:	27e68693          	addi	a3,a3,638 # ffffffffc0201e68 <commands+0x738>
ffffffffc0200bf2:	00001617          	auipc	a2,0x1
ffffffffc0200bf6:	21e60613          	addi	a2,a2,542 # ffffffffc0201e10 <commands+0x6e0>
ffffffffc0200bfa:	05800593          	li	a1,88
ffffffffc0200bfe:	00001517          	auipc	a0,0x1
ffffffffc0200c02:	22a50513          	addi	a0,a0,554 # ffffffffc0201e28 <commands+0x6f8>
ffffffffc0200c06:	fa6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200c0a:	00001697          	auipc	a3,0x1
ffffffffc0200c0e:	1fe68693          	addi	a3,a3,510 # ffffffffc0201e08 <commands+0x6d8>
ffffffffc0200c12:	00001617          	auipc	a2,0x1
ffffffffc0200c16:	1fe60613          	addi	a2,a2,510 # ffffffffc0201e10 <commands+0x6e0>
ffffffffc0200c1a:	04c00593          	li	a1,76
ffffffffc0200c1e:	00001517          	auipc	a0,0x1
ffffffffc0200c22:	20a50513          	addi	a0,a0,522 # ffffffffc0201e28 <commands+0x6f8>
ffffffffc0200c26:	f86ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c2a <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200c2a:	1101                	addi	sp,sp,-32
ffffffffc0200c2c:	ec06                	sd	ra,24(sp)
ffffffffc0200c2e:	e822                	sd	s0,16(sp)
ffffffffc0200c30:	e426                	sd	s1,8(sp)
ffffffffc0200c32:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc0200c34:	18058c63          	beqz	a1,ffffffffc0200dcc <buddy_free_pages+0x1a2>
    unsigned int pnum = 1 << (base->property);
ffffffffc0200c38:	491c                	lw	a5,16(a0)
    if (n & (n - 1)) 
ffffffffc0200c3a:	fff58713          	addi	a4,a1,-1
    unsigned int pnum = 1 << (base->property);
ffffffffc0200c3e:	4405                	li	s0,1
    if (n & (n - 1)) 
ffffffffc0200c40:	8f6d                	and	a4,a4,a1
    unsigned int pnum = 1 << (base->property);
ffffffffc0200c42:	883e                	mv	a6,a5
ffffffffc0200c44:	00f4143b          	sllw	s0,s0,a5
    if (n & (n - 1)) 
ffffffffc0200c48:	16071c63          	bnez	a4,ffffffffc0200dc0 <buddy_free_pages+0x196>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200c4c:	02041713          	slli	a4,s0,0x20
ffffffffc0200c50:	9301                	srli	a4,a4,0x20
ffffffffc0200c52:	18b71d63          	bne	a4,a1,ffffffffc0200dec <buddy_free_pages+0x1c2>
    unsigned long idx=base-buddy_start;
ffffffffc0200c56:	00006f97          	auipc	t6,0x6
ffffffffc0200c5a:	cf2f8f93          	addi	t6,t6,-782 # ffffffffc0206948 <buddy_start>
ffffffffc0200c5e:	000fb603          	ld	a2,0(t6)
    for(;order<max_order;order++)
ffffffffc0200c62:	00006f17          	auipc	t5,0x6
ffffffffc0200c66:	ceef0f13          	addi	t5,t5,-786 # ffffffffc0206950 <max_order>
ffffffffc0200c6a:	000f2703          	lw	a4,0(t5)
    unsigned long idx=base-buddy_start;
ffffffffc0200c6e:	40c505b3          	sub	a1,a0,a2
ffffffffc0200c72:	858d                	srai	a1,a1,0x3
ffffffffc0200c74:	00001897          	auipc	a7,0x1
ffffffffc0200c78:	4bc8b883          	ld	a7,1212(a7) # ffffffffc0202130 <nbase+0x8>
ffffffffc0200c7c:	031585b3          	mul	a1,a1,a7
    for(;order<max_order;order++)
ffffffffc0200c80:	0ee7f563          	bgeu	a5,a4,ffffffffc0200d6a <buddy_free_pages+0x140>
        idx&=buddy_idx;  //一对伙伴块的父结点的索引
ffffffffc0200c84:	5efd                	li	t4,-1
ffffffffc0200c86:	00259693          	slli	a3,a1,0x2
ffffffffc0200c8a:	00006397          	auipc	t2,0x6
ffffffffc0200c8e:	c9638393          	addi	t2,t2,-874 # ffffffffc0206920 <pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c92:	00001317          	auipc	t1,0x1
ffffffffc0200c96:	49633303          	ld	t1,1174(t1) # ffffffffc0202128 <nbase>
    unsigned int buddy_ppn = page2ppn(buddy_start) + ((1 << order) ^ (page2ppn(page) - page2ppn(buddy_start))); 
ffffffffc0200c9a:	4285                	li	t0,1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200c9c:	5e75                	li	t3,-3
        idx&=buddy_idx;  //一对伙伴块的父结点的索引
ffffffffc0200c9e:	020ede93          	srli	t4,t4,0x20
ffffffffc0200ca2:	a0bd                	j	ffffffffc0200d10 <buddy_free_pages+0xe6>
        return page + (buddy_ppn - page2ppn(page));
ffffffffc0200ca4:	40e78733          	sub	a4,a5,a4
ffffffffc0200ca8:	00271793          	slli	a5,a4,0x2
ffffffffc0200cac:	97ba                	add	a5,a5,a4
ffffffffc0200cae:	078e                	slli	a5,a5,0x3
ffffffffc0200cb0:	97aa                	add	a5,a5,a0
        if(buddy_page->property!=order||PageProperty(buddy_page)!=1){
ffffffffc0200cb2:	4b84                	lw	s1,16(a5)
        unsigned int buddy_idx=buddy_page-buddy_start;
ffffffffc0200cb4:	40c78633          	sub	a2,a5,a2
ffffffffc0200cb8:	860d                	srai	a2,a2,0x3
ffffffffc0200cba:	03160733          	mul	a4,a2,a7
        if(buddy_page->property!=order||PageProperty(buddy_page)!=1){
ffffffffc0200cbe:	0b049663          	bne	s1,a6,ffffffffc0200d6a <buddy_free_pages+0x140>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200cc2:	6790                	ld	a2,8(a5)
ffffffffc0200cc4:	8a09                	andi	a2,a2,2
ffffffffc0200cc6:	c255                	beqz	a2,ffffffffc0200d6a <buddy_free_pages+0x140>
        buddy_page->property=0;
ffffffffc0200cc8:	0007a823          	sw	zero,16(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ccc:	00878613          	addi	a2,a5,8
ffffffffc0200cd0:	61c6302f          	amoand.d	zero,t3,(a2)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200cd4:	6f88                	ld	a0,24(a5)
ffffffffc0200cd6:	739c                	ld	a5,32(a5)
        (buddy_start+idx)->property=0;
ffffffffc0200cd8:	000fb603          	ld	a2,0(t6)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200cdc:	e51c                	sd	a5,8(a0)
    next->prev = prev;
ffffffffc0200cde:	e388                	sd	a0,0(a5)
ffffffffc0200ce0:	96b2                	add	a3,a3,a2
ffffffffc0200ce2:	0006a823          	sw	zero,16(a3)
ffffffffc0200ce6:	00868793          	addi	a5,a3,8
ffffffffc0200cea:	61c7b02f          	amoand.d	zero,t3,(a5)
        idx&=buddy_idx;  //一对伙伴块的父结点的索引
ffffffffc0200cee:	01d77733          	and	a4,a4,t4
ffffffffc0200cf2:	8df9                	and	a1,a1,a4
        page=buddy_start+idx; 
ffffffffc0200cf4:	00259693          	slli	a3,a1,0x2
ffffffffc0200cf8:	00b68533          	add	a0,a3,a1
ffffffffc0200cfc:	050e                	slli	a0,a0,0x3
    for(;order<max_order;order++)
ffffffffc0200cfe:	000f2703          	lw	a4,0(t5)
        page->property=order+1;
ffffffffc0200d02:	2805                	addiw	a6,a6,1
        page=buddy_start+idx; 
ffffffffc0200d04:	9532                	add	a0,a0,a2
        page->property=order+1;
ffffffffc0200d06:	01052823          	sw	a6,16(a0)
    for(;order<max_order;order++)
ffffffffc0200d0a:	06e87063          	bgeu	a6,a4,ffffffffc0200d6a <buddy_free_pages+0x140>
ffffffffc0200d0e:	87c2                	mv	a5,a6
ffffffffc0200d10:	0003b703          	ld	a4,0(t2)
        buddy_page=getBuddyPage(buddy_start+idx);
ffffffffc0200d14:	96ae                	add	a3,a3,a1
ffffffffc0200d16:	068e                	slli	a3,a3,0x3
ffffffffc0200d18:	00d60533          	add	a0,a2,a3
ffffffffc0200d1c:	40e604b3          	sub	s1,a2,a4
ffffffffc0200d20:	40e50733          	sub	a4,a0,a4
ffffffffc0200d24:	848d                	srai	s1,s1,0x3
ffffffffc0200d26:	870d                	srai	a4,a4,0x3
ffffffffc0200d28:	031484b3          	mul	s1,s1,a7
    unsigned int buddy_ppn = page2ppn(buddy_start) + ((1 << order) ^ (page2ppn(page) - page2ppn(buddy_start))); 
ffffffffc0200d2c:	00f297bb          	sllw	a5,t0,a5
ffffffffc0200d30:	03170733          	mul	a4,a4,a7
ffffffffc0200d34:	00648933          	add	s2,s1,t1
ffffffffc0200d38:	409704bb          	subw	s1,a4,s1
ffffffffc0200d3c:	8fa5                	xor	a5,a5,s1
ffffffffc0200d3e:	012787bb          	addw	a5,a5,s2
    if (buddy_ppn > page2ppn(page)) {
ffffffffc0200d42:	1782                	slli	a5,a5,0x20
ffffffffc0200d44:	971a                	add	a4,a4,t1
ffffffffc0200d46:	9381                	srli	a5,a5,0x20
ffffffffc0200d48:	f4f76ee3          	bltu	a4,a5,ffffffffc0200ca4 <buddy_free_pages+0x7a>
        return page - (page2ppn(page) - buddy_ppn);
ffffffffc0200d4c:	8f1d                	sub	a4,a4,a5
ffffffffc0200d4e:	00271793          	slli	a5,a4,0x2
ffffffffc0200d52:	97ba                	add	a5,a5,a4
ffffffffc0200d54:	078e                	slli	a5,a5,0x3
ffffffffc0200d56:	40f507b3          	sub	a5,a0,a5
        if(buddy_page->property!=order||PageProperty(buddy_page)!=1){
ffffffffc0200d5a:	4b84                	lw	s1,16(a5)
        unsigned int buddy_idx=buddy_page-buddy_start;
ffffffffc0200d5c:	40c78633          	sub	a2,a5,a2
ffffffffc0200d60:	860d                	srai	a2,a2,0x3
ffffffffc0200d62:	03160733          	mul	a4,a2,a7
        if(buddy_page->property!=order||PageProperty(buddy_page)!=1){
ffffffffc0200d66:	f5048ee3          	beq	s1,a6,ffffffffc0200cc2 <buddy_free_pages+0x98>
    page->property=order;
ffffffffc0200d6a:	01052823          	sw	a6,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d6e:	4789                	li	a5,2
ffffffffc0200d70:	00850713          	addi	a4,a0,8
ffffffffc0200d74:	40f7302f          	amoor.d	zero,a5,(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d78:	1802                	slli	a6,a6,0x20
ffffffffc0200d7a:	02085813          	srli	a6,a6,0x20
ffffffffc0200d7e:	00181793          	slli	a5,a6,0x1
ffffffffc0200d82:	983e                	add	a6,a6,a5
ffffffffc0200d84:	00381793          	slli	a5,a6,0x3
ffffffffc0200d88:	00005817          	auipc	a6,0x5
ffffffffc0200d8c:	29080813          	addi	a6,a6,656 # ffffffffc0206018 <free_area>
ffffffffc0200d90:	983e                	add	a6,a6,a5
    total_nr_free += pnum;
ffffffffc0200d92:	00006717          	auipc	a4,0x6
ffffffffc0200d96:	bc270713          	addi	a4,a4,-1086 # ffffffffc0206954 <total_nr_free>
ffffffffc0200d9a:	00883683          	ld	a3,8(a6)
ffffffffc0200d9e:	431c                	lw	a5,0(a4)
    list_add(&(free_area[order].free_list),&(page->page_link));
ffffffffc0200da0:	01850613          	addi	a2,a0,24
    prev->next = next->prev = elm;
ffffffffc0200da4:	e290                	sd	a2,0(a3)
    total_nr_free += pnum;
ffffffffc0200da6:	9c3d                	addw	s0,s0,a5
}
ffffffffc0200da8:	60e2                	ld	ra,24(sp)
    total_nr_free += pnum;
ffffffffc0200daa:	c300                	sw	s0,0(a4)
}
ffffffffc0200dac:	6442                	ld	s0,16(sp)
ffffffffc0200dae:	00c83423          	sd	a2,8(a6)
    elm->next = next;
ffffffffc0200db2:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200db4:	01053c23          	sd	a6,24(a0)
ffffffffc0200db8:	64a2                	ld	s1,8(sp)
ffffffffc0200dba:	6902                	ld	s2,0(sp)
ffffffffc0200dbc:	6105                	addi	sp,sp,32
ffffffffc0200dbe:	8082                	ret
ffffffffc0200dc0:	4705                	li	a4,1
            n = n >> 1;
ffffffffc0200dc2:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200dc4:	0706                	slli	a4,a4,0x1
        while (n) {
ffffffffc0200dc6:	fdf5                	bnez	a1,ffffffffc0200dc2 <buddy_free_pages+0x198>
            res = res << 1;
ffffffffc0200dc8:	85ba                	mv	a1,a4
ffffffffc0200dca:	b549                	j	ffffffffc0200c4c <buddy_free_pages+0x22>
    assert(n > 0);
ffffffffc0200dcc:	00001697          	auipc	a3,0x1
ffffffffc0200dd0:	03c68693          	addi	a3,a3,60 # ffffffffc0201e08 <commands+0x6d8>
ffffffffc0200dd4:	00001617          	auipc	a2,0x1
ffffffffc0200dd8:	03c60613          	addi	a2,a2,60 # ffffffffc0201e10 <commands+0x6e0>
ffffffffc0200ddc:	0a100593          	li	a1,161
ffffffffc0200de0:	00001517          	auipc	a0,0x1
ffffffffc0200de4:	04850513          	addi	a0,a0,72 # ffffffffc0201e28 <commands+0x6f8>
ffffffffc0200de8:	dc4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200dec:	00001697          	auipc	a3,0x1
ffffffffc0200df0:	08c68693          	addi	a3,a3,140 # ffffffffc0201e78 <commands+0x748>
ffffffffc0200df4:	00001617          	auipc	a2,0x1
ffffffffc0200df8:	01c60613          	addi	a2,a2,28 # ffffffffc0201e10 <commands+0x6e0>
ffffffffc0200dfc:	0a300593          	li	a1,163
ffffffffc0200e00:	00001517          	auipc	a0,0x1
ffffffffc0200e04:	02850513          	addi	a0,a0,40 # ffffffffc0201e28 <commands+0x6f8>
ffffffffc0200e08:	da4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e0c <buddy_alloc_pages>:
buddy_alloc_pages(size_t n) {
ffffffffc0200e0c:	1101                	addi	sp,sp,-32
ffffffffc0200e0e:	ec06                	sd	ra,24(sp)
ffffffffc0200e10:	e822                	sd	s0,16(sp)
ffffffffc0200e12:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200e14:	12050863          	beqz	a0,ffffffffc0200f44 <buddy_alloc_pages+0x138>
    if (n > total_nr_free) {
ffffffffc0200e18:	00006e97          	auipc	t4,0x6
ffffffffc0200e1c:	b3ce8e93          	addi	t4,t4,-1220 # ffffffffc0206954 <total_nr_free>
ffffffffc0200e20:	000ee783          	lwu	a5,0(t4)
ffffffffc0200e24:	86aa                	mv	a3,a0
        return NULL;
ffffffffc0200e26:	4501                	li	a0,0
    if (n > total_nr_free) {
ffffffffc0200e28:	10d7e163          	bltu	a5,a3,ffffffffc0200f2a <buddy_alloc_pages+0x11e>
    if (n & (n - 1)) 
ffffffffc0200e2c:	fff68793          	addi	a5,a3,-1
ffffffffc0200e30:	8ff5                	and	a5,a5,a3
ffffffffc0200e32:	c791                	beqz	a5,ffffffffc0200e3e <buddy_alloc_pages+0x32>
ffffffffc0200e34:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200e36:	8285                	srli	a3,a3,0x1
            res = res << 1;
ffffffffc0200e38:	0786                	slli	a5,a5,0x1
        while (n) {
ffffffffc0200e3a:	fef5                	bnez	a3,ffffffffc0200e36 <buddy_alloc_pages+0x2a>
            res = res << 1;
ffffffffc0200e3c:	86be                	mv	a3,a5
    while (n >> 1) {
ffffffffc0200e3e:	0016d793          	srli	a5,a3,0x1
    for(int o=order;o<=max_order;o++)  
ffffffffc0200e42:	00006517          	auipc	a0,0x6
ffffffffc0200e46:	b0e52503          	lw	a0,-1266(a0) # ffffffffc0206950 <max_order>
    unsigned int order = 0;
ffffffffc0200e4a:	4581                	li	a1,0
    while (n >> 1) {
ffffffffc0200e4c:	cbf5                	beqz	a5,ffffffffc0200f40 <buddy_alloc_pages+0x134>
ffffffffc0200e4e:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200e50:	2585                	addiw	a1,a1,1
    while (n >> 1) {
ffffffffc0200e52:	fff5                	bnez	a5,ffffffffc0200e4e <buddy_alloc_pages+0x42>
    int order = getOrderOf2(pnum);
ffffffffc0200e54:	00058f1b          	sext.w	t5,a1
    for(int o=order;o<=max_order;o++)  
ffffffffc0200e58:	0cb56e63          	bltu	a0,a1,ffffffffc0200f34 <buddy_alloc_pages+0x128>
ffffffffc0200e5c:	001f1793          	slli	a5,t5,0x1
ffffffffc0200e60:	97fa                	add	a5,a5,t5
ffffffffc0200e62:	078e                	slli	a5,a5,0x3
ffffffffc0200e64:	00005f97          	auipc	t6,0x5
ffffffffc0200e68:	1b4f8f93          	addi	t6,t6,436 # ffffffffc0206018 <free_area>
ffffffffc0200e6c:	97fe                	add	a5,a5,t6
    int order = getOrderOf2(pnum);
ffffffffc0200e6e:	877a                	mv	a4,t5
ffffffffc0200e70:	a029                	j	ffffffffc0200e7a <buddy_alloc_pages+0x6e>
    for(int o=order;o<=max_order;o++)  
ffffffffc0200e72:	2705                	addiw	a4,a4,1
ffffffffc0200e74:	07e1                	addi	a5,a5,24
ffffffffc0200e76:	0ae56f63          	bltu	a0,a4,ffffffffc0200f34 <buddy_alloc_pages+0x128>
    return list->next == list;
ffffffffc0200e7a:	6790                	ld	a2,8(a5)
        if (!list_empty(&(free_area[o].free_list))) {
ffffffffc0200e7c:	fef60be3          	beq	a2,a5,ffffffffc0200e72 <buddy_alloc_pages+0x66>
            page = le2page(list_next(&(free_area[o].free_list)), page_link);
ffffffffc0200e80:	fe860513          	addi	a0,a2,-24
            if(o!=order)
ffffffffc0200e84:	87b2                	mv	a5,a2
ffffffffc0200e86:	09e70163          	beq	a4,t5,ffffffffc0200f08 <buddy_alloc_pages+0xfc>
                for (int i = o - 1; i >= order; --i) {
ffffffffc0200e8a:	fff7031b          	addiw	t1,a4,-1
ffffffffc0200e8e:	07e34d63          	blt	t1,t5,ffffffffc0200f08 <buddy_alloc_pages+0xfc>
ffffffffc0200e92:	00131893          	slli	a7,t1,0x1
ffffffffc0200e96:	989a                	add	a7,a7,t1
ffffffffc0200e98:	088e                	slli	a7,a7,0x3
ffffffffc0200e9a:	98fe                	add	a7,a7,t6
ffffffffc0200e9c:	00006497          	auipc	s1,0x6
ffffffffc0200ea0:	aac48493          	addi	s1,s1,-1364 # ffffffffc0206948 <buddy_start>
ffffffffc0200ea4:	00001417          	auipc	s0,0x1
ffffffffc0200ea8:	28c43403          	ld	s0,652(s0) # ffffffffc0202130 <nbase+0x8>
                    idx += 1 << i;
ffffffffc0200eac:	4385                	li	t2,1
ffffffffc0200eae:	4289                	li	t0,2
                    unsigned long idx = page-buddy_start;
ffffffffc0200eb0:	609c                	ld	a5,0(s1)
                    idx += 1 << i;
ffffffffc0200eb2:	00639e3b          	sllw	t3,t2,t1
                    unsigned long idx = page-buddy_start;
ffffffffc0200eb6:	40f50833          	sub	a6,a0,a5
ffffffffc0200eba:	40385813          	srai	a6,a6,0x3
ffffffffc0200ebe:	02880833          	mul	a6,a6,s0
                    idx += 1 << i;
ffffffffc0200ec2:	9e42                	add	t3,t3,a6
                    struct Page *new_page = buddy_start+idx;
ffffffffc0200ec4:	002e1813          	slli	a6,t3,0x2
ffffffffc0200ec8:	9872                	add	a6,a6,t3
ffffffffc0200eca:	080e                	slli	a6,a6,0x3
ffffffffc0200ecc:	97c2                	add	a5,a5,a6
                    new_page->property = i;
ffffffffc0200ece:	0067a823          	sw	t1,16(a5)
ffffffffc0200ed2:	00878813          	addi	a6,a5,8
ffffffffc0200ed6:	4058302f          	amoor.d	zero,t0,(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200eda:	0088b803          	ld	a6,8(a7)
                    list_add(&(free_area[i].free_list), &(new_page->page_link)); 
ffffffffc0200ede:	01878e13          	addi	t3,a5,24
                for (int i = o - 1; i >= order; --i) {
ffffffffc0200ee2:	337d                	addiw	t1,t1,-1
    prev->next = next->prev = elm;
ffffffffc0200ee4:	01c83023          	sd	t3,0(a6)
ffffffffc0200ee8:	01c8b423          	sd	t3,8(a7)
    elm->prev = prev;
ffffffffc0200eec:	0117bc23          	sd	a7,24(a5)
    elm->next = next;
ffffffffc0200ef0:	0307b023          	sd	a6,32(a5)
ffffffffc0200ef4:	18a1                	addi	a7,a7,-24
ffffffffc0200ef6:	fbe35de3          	bge	t1,t5,ffffffffc0200eb0 <buddy_alloc_pages+0xa4>
    return listelm->next;
ffffffffc0200efa:	00171793          	slli	a5,a4,0x1
ffffffffc0200efe:	973e                	add	a4,a4,a5
ffffffffc0200f00:	070e                	slli	a4,a4,0x3
ffffffffc0200f02:	9fba                	add	t6,t6,a4
ffffffffc0200f04:	008fb783          	ld	a5,8(t6)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f08:	6398                	ld	a4,0(a5)
ffffffffc0200f0a:	679c                	ld	a5,8(a5)
            page->property=order;
ffffffffc0200f0c:	feb62c23          	sw	a1,-8(a2)
    prev->next = next;
ffffffffc0200f10:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200f12:	e398                	sd	a4,0(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200f14:	57f5                	li	a5,-3
ffffffffc0200f16:	ff060713          	addi	a4,a2,-16
ffffffffc0200f1a:	60f7302f          	amoand.d	zero,a5,(a4)
            total_nr_free -= pnum;
ffffffffc0200f1e:	000ea783          	lw	a5,0(t4)
ffffffffc0200f22:	40d786bb          	subw	a3,a5,a3
ffffffffc0200f26:	00dea023          	sw	a3,0(t4)
}
ffffffffc0200f2a:	60e2                	ld	ra,24(sp)
ffffffffc0200f2c:	6442                	ld	s0,16(sp)
ffffffffc0200f2e:	64a2                	ld	s1,8(sp)
ffffffffc0200f30:	6105                	addi	sp,sp,32
ffffffffc0200f32:	8082                	ret
ffffffffc0200f34:	60e2                	ld	ra,24(sp)
ffffffffc0200f36:	6442                	ld	s0,16(sp)
ffffffffc0200f38:	64a2                	ld	s1,8(sp)
        return NULL;
ffffffffc0200f3a:	4501                	li	a0,0
}
ffffffffc0200f3c:	6105                	addi	sp,sp,32
ffffffffc0200f3e:	8082                	ret
    int order = getOrderOf2(pnum);
ffffffffc0200f40:	4f01                	li	t5,0
ffffffffc0200f42:	bf29                	j	ffffffffc0200e5c <buddy_alloc_pages+0x50>
    assert(n > 0);
ffffffffc0200f44:	00001697          	auipc	a3,0x1
ffffffffc0200f48:	ec468693          	addi	a3,a3,-316 # ffffffffc0201e08 <commands+0x6d8>
ffffffffc0200f4c:	00001617          	auipc	a2,0x1
ffffffffc0200f50:	ec460613          	addi	a2,a2,-316 # ffffffffc0201e10 <commands+0x6e0>
ffffffffc0200f54:	06800593          	li	a1,104
ffffffffc0200f58:	00001517          	auipc	a0,0x1
ffffffffc0200f5c:	ed050513          	addi	a0,a0,-304 # ffffffffc0201e28 <commands+0x6f8>
ffffffffc0200f60:	c4cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f64 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200f64:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f68:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200f6a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f6e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200f70:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f74:	f022                	sd	s0,32(sp)
ffffffffc0200f76:	ec26                	sd	s1,24(sp)
ffffffffc0200f78:	e84a                	sd	s2,16(sp)
ffffffffc0200f7a:	f406                	sd	ra,40(sp)
ffffffffc0200f7c:	e44e                	sd	s3,8(sp)
ffffffffc0200f7e:	84aa                	mv	s1,a0
ffffffffc0200f80:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200f82:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200f86:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200f88:	03067e63          	bgeu	a2,a6,ffffffffc0200fc4 <printnum+0x60>
ffffffffc0200f8c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200f8e:	00805763          	blez	s0,ffffffffc0200f9c <printnum+0x38>
ffffffffc0200f92:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200f94:	85ca                	mv	a1,s2
ffffffffc0200f96:	854e                	mv	a0,s3
ffffffffc0200f98:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200f9a:	fc65                	bnez	s0,ffffffffc0200f92 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f9c:	1a02                	slli	s4,s4,0x20
ffffffffc0200f9e:	00001797          	auipc	a5,0x1
ffffffffc0200fa2:	f4278793          	addi	a5,a5,-190 # ffffffffc0201ee0 <slub_pmm_manager+0x38>
ffffffffc0200fa6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200faa:	9a3e                	add	s4,s4,a5
}
ffffffffc0200fac:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fae:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200fb2:	70a2                	ld	ra,40(sp)
ffffffffc0200fb4:	69a2                	ld	s3,8(sp)
ffffffffc0200fb6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fb8:	85ca                	mv	a1,s2
ffffffffc0200fba:	87a6                	mv	a5,s1
}
ffffffffc0200fbc:	6942                	ld	s2,16(sp)
ffffffffc0200fbe:	64e2                	ld	s1,24(sp)
ffffffffc0200fc0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fc2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200fc4:	03065633          	divu	a2,a2,a6
ffffffffc0200fc8:	8722                	mv	a4,s0
ffffffffc0200fca:	f9bff0ef          	jal	ra,ffffffffc0200f64 <printnum>
ffffffffc0200fce:	b7f9                	j	ffffffffc0200f9c <printnum+0x38>

ffffffffc0200fd0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200fd0:	7119                	addi	sp,sp,-128
ffffffffc0200fd2:	f4a6                	sd	s1,104(sp)
ffffffffc0200fd4:	f0ca                	sd	s2,96(sp)
ffffffffc0200fd6:	ecce                	sd	s3,88(sp)
ffffffffc0200fd8:	e8d2                	sd	s4,80(sp)
ffffffffc0200fda:	e4d6                	sd	s5,72(sp)
ffffffffc0200fdc:	e0da                	sd	s6,64(sp)
ffffffffc0200fde:	fc5e                	sd	s7,56(sp)
ffffffffc0200fe0:	f06a                	sd	s10,32(sp)
ffffffffc0200fe2:	fc86                	sd	ra,120(sp)
ffffffffc0200fe4:	f8a2                	sd	s0,112(sp)
ffffffffc0200fe6:	f862                	sd	s8,48(sp)
ffffffffc0200fe8:	f466                	sd	s9,40(sp)
ffffffffc0200fea:	ec6e                	sd	s11,24(sp)
ffffffffc0200fec:	892a                	mv	s2,a0
ffffffffc0200fee:	84ae                	mv	s1,a1
ffffffffc0200ff0:	8d32                	mv	s10,a2
ffffffffc0200ff2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200ff4:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200ff8:	5b7d                	li	s6,-1
ffffffffc0200ffa:	00001a97          	auipc	s5,0x1
ffffffffc0200ffe:	f1aa8a93          	addi	s5,s5,-230 # ffffffffc0201f14 <slub_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201002:	00001b97          	auipc	s7,0x1
ffffffffc0201006:	0eeb8b93          	addi	s7,s7,238 # ffffffffc02020f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020100a:	000d4503          	lbu	a0,0(s10)
ffffffffc020100e:	001d0413          	addi	s0,s10,1
ffffffffc0201012:	01350a63          	beq	a0,s3,ffffffffc0201026 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201016:	c121                	beqz	a0,ffffffffc0201056 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201018:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020101a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020101c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020101e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201022:	ff351ae3          	bne	a0,s3,ffffffffc0201016 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201026:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020102a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020102e:	4c81                	li	s9,0
ffffffffc0201030:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201032:	5c7d                	li	s8,-1
ffffffffc0201034:	5dfd                	li	s11,-1
ffffffffc0201036:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020103a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020103c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201040:	0ff5f593          	zext.b	a1,a1
ffffffffc0201044:	00140d13          	addi	s10,s0,1
ffffffffc0201048:	04b56263          	bltu	a0,a1,ffffffffc020108c <vprintfmt+0xbc>
ffffffffc020104c:	058a                	slli	a1,a1,0x2
ffffffffc020104e:	95d6                	add	a1,a1,s5
ffffffffc0201050:	4194                	lw	a3,0(a1)
ffffffffc0201052:	96d6                	add	a3,a3,s5
ffffffffc0201054:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201056:	70e6                	ld	ra,120(sp)
ffffffffc0201058:	7446                	ld	s0,112(sp)
ffffffffc020105a:	74a6                	ld	s1,104(sp)
ffffffffc020105c:	7906                	ld	s2,96(sp)
ffffffffc020105e:	69e6                	ld	s3,88(sp)
ffffffffc0201060:	6a46                	ld	s4,80(sp)
ffffffffc0201062:	6aa6                	ld	s5,72(sp)
ffffffffc0201064:	6b06                	ld	s6,64(sp)
ffffffffc0201066:	7be2                	ld	s7,56(sp)
ffffffffc0201068:	7c42                	ld	s8,48(sp)
ffffffffc020106a:	7ca2                	ld	s9,40(sp)
ffffffffc020106c:	7d02                	ld	s10,32(sp)
ffffffffc020106e:	6de2                	ld	s11,24(sp)
ffffffffc0201070:	6109                	addi	sp,sp,128
ffffffffc0201072:	8082                	ret
            padc = '0';
ffffffffc0201074:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201076:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020107a:	846a                	mv	s0,s10
ffffffffc020107c:	00140d13          	addi	s10,s0,1
ffffffffc0201080:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201084:	0ff5f593          	zext.b	a1,a1
ffffffffc0201088:	fcb572e3          	bgeu	a0,a1,ffffffffc020104c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020108c:	85a6                	mv	a1,s1
ffffffffc020108e:	02500513          	li	a0,37
ffffffffc0201092:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201094:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201098:	8d22                	mv	s10,s0
ffffffffc020109a:	f73788e3          	beq	a5,s3,ffffffffc020100a <vprintfmt+0x3a>
ffffffffc020109e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02010a2:	1d7d                	addi	s10,s10,-1
ffffffffc02010a4:	ff379de3          	bne	a5,s3,ffffffffc020109e <vprintfmt+0xce>
ffffffffc02010a8:	b78d                	j	ffffffffc020100a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02010aa:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02010ae:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010b2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02010b4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02010b8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02010bc:	02d86463          	bltu	a6,a3,ffffffffc02010e4 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02010c0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02010c4:	002c169b          	slliw	a3,s8,0x2
ffffffffc02010c8:	0186873b          	addw	a4,a3,s8
ffffffffc02010cc:	0017171b          	slliw	a4,a4,0x1
ffffffffc02010d0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02010d2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02010d6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02010d8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02010dc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02010e0:	fed870e3          	bgeu	a6,a3,ffffffffc02010c0 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02010e4:	f40ddce3          	bgez	s11,ffffffffc020103c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02010e8:	8de2                	mv	s11,s8
ffffffffc02010ea:	5c7d                	li	s8,-1
ffffffffc02010ec:	bf81                	j	ffffffffc020103c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02010ee:	fffdc693          	not	a3,s11
ffffffffc02010f2:	96fd                	srai	a3,a3,0x3f
ffffffffc02010f4:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010f8:	00144603          	lbu	a2,1(s0)
ffffffffc02010fc:	2d81                	sext.w	s11,s11
ffffffffc02010fe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201100:	bf35                	j	ffffffffc020103c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201102:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201106:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020110a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020110c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020110e:	bfd9                	j	ffffffffc02010e4 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201110:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201112:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201116:	01174463          	blt	a4,a7,ffffffffc020111e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020111a:	1a088e63          	beqz	a7,ffffffffc02012d6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020111e:	000a3603          	ld	a2,0(s4)
ffffffffc0201122:	46c1                	li	a3,16
ffffffffc0201124:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201126:	2781                	sext.w	a5,a5
ffffffffc0201128:	876e                	mv	a4,s11
ffffffffc020112a:	85a6                	mv	a1,s1
ffffffffc020112c:	854a                	mv	a0,s2
ffffffffc020112e:	e37ff0ef          	jal	ra,ffffffffc0200f64 <printnum>
            break;
ffffffffc0201132:	bde1                	j	ffffffffc020100a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201134:	000a2503          	lw	a0,0(s4)
ffffffffc0201138:	85a6                	mv	a1,s1
ffffffffc020113a:	0a21                	addi	s4,s4,8
ffffffffc020113c:	9902                	jalr	s2
            break;
ffffffffc020113e:	b5f1                	j	ffffffffc020100a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201140:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201142:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201146:	01174463          	blt	a4,a7,ffffffffc020114e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020114a:	18088163          	beqz	a7,ffffffffc02012cc <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020114e:	000a3603          	ld	a2,0(s4)
ffffffffc0201152:	46a9                	li	a3,10
ffffffffc0201154:	8a2e                	mv	s4,a1
ffffffffc0201156:	bfc1                	j	ffffffffc0201126 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201158:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020115c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020115e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201160:	bdf1                	j	ffffffffc020103c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201162:	85a6                	mv	a1,s1
ffffffffc0201164:	02500513          	li	a0,37
ffffffffc0201168:	9902                	jalr	s2
            break;
ffffffffc020116a:	b545                	j	ffffffffc020100a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020116c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201170:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201172:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201174:	b5e1                	j	ffffffffc020103c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201176:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201178:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020117c:	01174463          	blt	a4,a7,ffffffffc0201184 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201180:	14088163          	beqz	a7,ffffffffc02012c2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201184:	000a3603          	ld	a2,0(s4)
ffffffffc0201188:	46a1                	li	a3,8
ffffffffc020118a:	8a2e                	mv	s4,a1
ffffffffc020118c:	bf69                	j	ffffffffc0201126 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020118e:	03000513          	li	a0,48
ffffffffc0201192:	85a6                	mv	a1,s1
ffffffffc0201194:	e03e                	sd	a5,0(sp)
ffffffffc0201196:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201198:	85a6                	mv	a1,s1
ffffffffc020119a:	07800513          	li	a0,120
ffffffffc020119e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011a0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02011a2:	6782                	ld	a5,0(sp)
ffffffffc02011a4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011a6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02011aa:	bfb5                	j	ffffffffc0201126 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02011ac:	000a3403          	ld	s0,0(s4)
ffffffffc02011b0:	008a0713          	addi	a4,s4,8
ffffffffc02011b4:	e03a                	sd	a4,0(sp)
ffffffffc02011b6:	14040263          	beqz	s0,ffffffffc02012fa <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02011ba:	0fb05763          	blez	s11,ffffffffc02012a8 <vprintfmt+0x2d8>
ffffffffc02011be:	02d00693          	li	a3,45
ffffffffc02011c2:	0cd79163          	bne	a5,a3,ffffffffc0201284 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011c6:	00044783          	lbu	a5,0(s0)
ffffffffc02011ca:	0007851b          	sext.w	a0,a5
ffffffffc02011ce:	cf85                	beqz	a5,ffffffffc0201206 <vprintfmt+0x236>
ffffffffc02011d0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011d4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011d8:	000c4563          	bltz	s8,ffffffffc02011e2 <vprintfmt+0x212>
ffffffffc02011dc:	3c7d                	addiw	s8,s8,-1
ffffffffc02011de:	036c0263          	beq	s8,s6,ffffffffc0201202 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02011e2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011e4:	0e0c8e63          	beqz	s9,ffffffffc02012e0 <vprintfmt+0x310>
ffffffffc02011e8:	3781                	addiw	a5,a5,-32
ffffffffc02011ea:	0ef47b63          	bgeu	s0,a5,ffffffffc02012e0 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02011ee:	03f00513          	li	a0,63
ffffffffc02011f2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011f4:	000a4783          	lbu	a5,0(s4)
ffffffffc02011f8:	3dfd                	addiw	s11,s11,-1
ffffffffc02011fa:	0a05                	addi	s4,s4,1
ffffffffc02011fc:	0007851b          	sext.w	a0,a5
ffffffffc0201200:	ffe1                	bnez	a5,ffffffffc02011d8 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201202:	01b05963          	blez	s11,ffffffffc0201214 <vprintfmt+0x244>
ffffffffc0201206:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201208:	85a6                	mv	a1,s1
ffffffffc020120a:	02000513          	li	a0,32
ffffffffc020120e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201210:	fe0d9be3          	bnez	s11,ffffffffc0201206 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201214:	6a02                	ld	s4,0(sp)
ffffffffc0201216:	bbd5                	j	ffffffffc020100a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201218:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020121a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020121e:	01174463          	blt	a4,a7,ffffffffc0201226 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201222:	08088d63          	beqz	a7,ffffffffc02012bc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201226:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020122a:	0a044d63          	bltz	s0,ffffffffc02012e4 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020122e:	8622                	mv	a2,s0
ffffffffc0201230:	8a66                	mv	s4,s9
ffffffffc0201232:	46a9                	li	a3,10
ffffffffc0201234:	bdcd                	j	ffffffffc0201126 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201236:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020123a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020123c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020123e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201242:	8fb5                	xor	a5,a5,a3
ffffffffc0201244:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201248:	02d74163          	blt	a4,a3,ffffffffc020126a <vprintfmt+0x29a>
ffffffffc020124c:	00369793          	slli	a5,a3,0x3
ffffffffc0201250:	97de                	add	a5,a5,s7
ffffffffc0201252:	639c                	ld	a5,0(a5)
ffffffffc0201254:	cb99                	beqz	a5,ffffffffc020126a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201256:	86be                	mv	a3,a5
ffffffffc0201258:	00001617          	auipc	a2,0x1
ffffffffc020125c:	cb860613          	addi	a2,a2,-840 # ffffffffc0201f10 <slub_pmm_manager+0x68>
ffffffffc0201260:	85a6                	mv	a1,s1
ffffffffc0201262:	854a                	mv	a0,s2
ffffffffc0201264:	0ce000ef          	jal	ra,ffffffffc0201332 <printfmt>
ffffffffc0201268:	b34d                	j	ffffffffc020100a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020126a:	00001617          	auipc	a2,0x1
ffffffffc020126e:	c9660613          	addi	a2,a2,-874 # ffffffffc0201f00 <slub_pmm_manager+0x58>
ffffffffc0201272:	85a6                	mv	a1,s1
ffffffffc0201274:	854a                	mv	a0,s2
ffffffffc0201276:	0bc000ef          	jal	ra,ffffffffc0201332 <printfmt>
ffffffffc020127a:	bb41                	j	ffffffffc020100a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020127c:	00001417          	auipc	s0,0x1
ffffffffc0201280:	c7c40413          	addi	s0,s0,-900 # ffffffffc0201ef8 <slub_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201284:	85e2                	mv	a1,s8
ffffffffc0201286:	8522                	mv	a0,s0
ffffffffc0201288:	e43e                	sd	a5,8(sp)
ffffffffc020128a:	1e6000ef          	jal	ra,ffffffffc0201470 <strnlen>
ffffffffc020128e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201292:	01b05b63          	blez	s11,ffffffffc02012a8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201296:	67a2                	ld	a5,8(sp)
ffffffffc0201298:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020129c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020129e:	85a6                	mv	a1,s1
ffffffffc02012a0:	8552                	mv	a0,s4
ffffffffc02012a2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012a4:	fe0d9ce3          	bnez	s11,ffffffffc020129c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012a8:	00044783          	lbu	a5,0(s0)
ffffffffc02012ac:	00140a13          	addi	s4,s0,1
ffffffffc02012b0:	0007851b          	sext.w	a0,a5
ffffffffc02012b4:	d3a5                	beqz	a5,ffffffffc0201214 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012b6:	05e00413          	li	s0,94
ffffffffc02012ba:	bf39                	j	ffffffffc02011d8 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02012bc:	000a2403          	lw	s0,0(s4)
ffffffffc02012c0:	b7ad                	j	ffffffffc020122a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02012c2:	000a6603          	lwu	a2,0(s4)
ffffffffc02012c6:	46a1                	li	a3,8
ffffffffc02012c8:	8a2e                	mv	s4,a1
ffffffffc02012ca:	bdb1                	j	ffffffffc0201126 <vprintfmt+0x156>
ffffffffc02012cc:	000a6603          	lwu	a2,0(s4)
ffffffffc02012d0:	46a9                	li	a3,10
ffffffffc02012d2:	8a2e                	mv	s4,a1
ffffffffc02012d4:	bd89                	j	ffffffffc0201126 <vprintfmt+0x156>
ffffffffc02012d6:	000a6603          	lwu	a2,0(s4)
ffffffffc02012da:	46c1                	li	a3,16
ffffffffc02012dc:	8a2e                	mv	s4,a1
ffffffffc02012de:	b5a1                	j	ffffffffc0201126 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02012e0:	9902                	jalr	s2
ffffffffc02012e2:	bf09                	j	ffffffffc02011f4 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02012e4:	85a6                	mv	a1,s1
ffffffffc02012e6:	02d00513          	li	a0,45
ffffffffc02012ea:	e03e                	sd	a5,0(sp)
ffffffffc02012ec:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02012ee:	6782                	ld	a5,0(sp)
ffffffffc02012f0:	8a66                	mv	s4,s9
ffffffffc02012f2:	40800633          	neg	a2,s0
ffffffffc02012f6:	46a9                	li	a3,10
ffffffffc02012f8:	b53d                	j	ffffffffc0201126 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02012fa:	03b05163          	blez	s11,ffffffffc020131c <vprintfmt+0x34c>
ffffffffc02012fe:	02d00693          	li	a3,45
ffffffffc0201302:	f6d79de3          	bne	a5,a3,ffffffffc020127c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201306:	00001417          	auipc	s0,0x1
ffffffffc020130a:	bf240413          	addi	s0,s0,-1038 # ffffffffc0201ef8 <slub_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020130e:	02800793          	li	a5,40
ffffffffc0201312:	02800513          	li	a0,40
ffffffffc0201316:	00140a13          	addi	s4,s0,1
ffffffffc020131a:	bd6d                	j	ffffffffc02011d4 <vprintfmt+0x204>
ffffffffc020131c:	00001a17          	auipc	s4,0x1
ffffffffc0201320:	bdda0a13          	addi	s4,s4,-1059 # ffffffffc0201ef9 <slub_pmm_manager+0x51>
ffffffffc0201324:	02800513          	li	a0,40
ffffffffc0201328:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020132c:	05e00413          	li	s0,94
ffffffffc0201330:	b565                	j	ffffffffc02011d8 <vprintfmt+0x208>

ffffffffc0201332 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201332:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201334:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201338:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020133a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020133c:	ec06                	sd	ra,24(sp)
ffffffffc020133e:	f83a                	sd	a4,48(sp)
ffffffffc0201340:	fc3e                	sd	a5,56(sp)
ffffffffc0201342:	e0c2                	sd	a6,64(sp)
ffffffffc0201344:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201346:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201348:	c89ff0ef          	jal	ra,ffffffffc0200fd0 <vprintfmt>
}
ffffffffc020134c:	60e2                	ld	ra,24(sp)
ffffffffc020134e:	6161                	addi	sp,sp,80
ffffffffc0201350:	8082                	ret

ffffffffc0201352 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201352:	715d                	addi	sp,sp,-80
ffffffffc0201354:	e486                	sd	ra,72(sp)
ffffffffc0201356:	e0a6                	sd	s1,64(sp)
ffffffffc0201358:	fc4a                	sd	s2,56(sp)
ffffffffc020135a:	f84e                	sd	s3,48(sp)
ffffffffc020135c:	f452                	sd	s4,40(sp)
ffffffffc020135e:	f056                	sd	s5,32(sp)
ffffffffc0201360:	ec5a                	sd	s6,24(sp)
ffffffffc0201362:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201364:	c901                	beqz	a0,ffffffffc0201374 <readline+0x22>
ffffffffc0201366:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201368:	00001517          	auipc	a0,0x1
ffffffffc020136c:	ba850513          	addi	a0,a0,-1112 # ffffffffc0201f10 <slub_pmm_manager+0x68>
ffffffffc0201370:	d43fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201374:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201376:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201378:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020137a:	4aa9                	li	s5,10
ffffffffc020137c:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020137e:	00005b97          	auipc	s7,0x5
ffffffffc0201382:	182b8b93          	addi	s7,s7,386 # ffffffffc0206500 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201386:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020138a:	da1fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020138e:	00054a63          	bltz	a0,ffffffffc02013a2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201392:	00a95a63          	bge	s2,a0,ffffffffc02013a6 <readline+0x54>
ffffffffc0201396:	029a5263          	bge	s4,s1,ffffffffc02013ba <readline+0x68>
        c = getchar();
ffffffffc020139a:	d91fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020139e:	fe055ae3          	bgez	a0,ffffffffc0201392 <readline+0x40>
            return NULL;
ffffffffc02013a2:	4501                	li	a0,0
ffffffffc02013a4:	a091                	j	ffffffffc02013e8 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02013a6:	03351463          	bne	a0,s3,ffffffffc02013ce <readline+0x7c>
ffffffffc02013aa:	e8a9                	bnez	s1,ffffffffc02013fc <readline+0xaa>
        c = getchar();
ffffffffc02013ac:	d7ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013b0:	fe0549e3          	bltz	a0,ffffffffc02013a2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013b4:	fea959e3          	bge	s2,a0,ffffffffc02013a6 <readline+0x54>
ffffffffc02013b8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02013ba:	e42a                	sd	a0,8(sp)
ffffffffc02013bc:	d2dfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02013c0:	6522                	ld	a0,8(sp)
ffffffffc02013c2:	009b87b3          	add	a5,s7,s1
ffffffffc02013c6:	2485                	addiw	s1,s1,1
ffffffffc02013c8:	00a78023          	sb	a0,0(a5)
ffffffffc02013cc:	bf7d                	j	ffffffffc020138a <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02013ce:	01550463          	beq	a0,s5,ffffffffc02013d6 <readline+0x84>
ffffffffc02013d2:	fb651ce3          	bne	a0,s6,ffffffffc020138a <readline+0x38>
            cputchar(c);
ffffffffc02013d6:	d13fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02013da:	00005517          	auipc	a0,0x5
ffffffffc02013de:	12650513          	addi	a0,a0,294 # ffffffffc0206500 <buf>
ffffffffc02013e2:	94aa                	add	s1,s1,a0
ffffffffc02013e4:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02013e8:	60a6                	ld	ra,72(sp)
ffffffffc02013ea:	6486                	ld	s1,64(sp)
ffffffffc02013ec:	7962                	ld	s2,56(sp)
ffffffffc02013ee:	79c2                	ld	s3,48(sp)
ffffffffc02013f0:	7a22                	ld	s4,40(sp)
ffffffffc02013f2:	7a82                	ld	s5,32(sp)
ffffffffc02013f4:	6b62                	ld	s6,24(sp)
ffffffffc02013f6:	6bc2                	ld	s7,16(sp)
ffffffffc02013f8:	6161                	addi	sp,sp,80
ffffffffc02013fa:	8082                	ret
            cputchar(c);
ffffffffc02013fc:	4521                	li	a0,8
ffffffffc02013fe:	cebfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201402:	34fd                	addiw	s1,s1,-1
ffffffffc0201404:	b759                	j	ffffffffc020138a <readline+0x38>

ffffffffc0201406 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201406:	4781                	li	a5,0
ffffffffc0201408:	00005717          	auipc	a4,0x5
ffffffffc020140c:	c0073703          	ld	a4,-1024(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201410:	88ba                	mv	a7,a4
ffffffffc0201412:	852a                	mv	a0,a0
ffffffffc0201414:	85be                	mv	a1,a5
ffffffffc0201416:	863e                	mv	a2,a5
ffffffffc0201418:	00000073          	ecall
ffffffffc020141c:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020141e:	8082                	ret

ffffffffc0201420 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201420:	4781                	li	a5,0
ffffffffc0201422:	00005717          	auipc	a4,0x5
ffffffffc0201426:	53673703          	ld	a4,1334(a4) # ffffffffc0206958 <SBI_SET_TIMER>
ffffffffc020142a:	88ba                	mv	a7,a4
ffffffffc020142c:	852a                	mv	a0,a0
ffffffffc020142e:	85be                	mv	a1,a5
ffffffffc0201430:	863e                	mv	a2,a5
ffffffffc0201432:	00000073          	ecall
ffffffffc0201436:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201438:	8082                	ret

ffffffffc020143a <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020143a:	4501                	li	a0,0
ffffffffc020143c:	00005797          	auipc	a5,0x5
ffffffffc0201440:	bc47b783          	ld	a5,-1084(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201444:	88be                	mv	a7,a5
ffffffffc0201446:	852a                	mv	a0,a0
ffffffffc0201448:	85aa                	mv	a1,a0
ffffffffc020144a:	862a                	mv	a2,a0
ffffffffc020144c:	00000073          	ecall
ffffffffc0201450:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201452:	2501                	sext.w	a0,a0
ffffffffc0201454:	8082                	ret

ffffffffc0201456 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201456:	4781                	li	a5,0
ffffffffc0201458:	00005717          	auipc	a4,0x5
ffffffffc020145c:	bb873703          	ld	a4,-1096(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc0201460:	88ba                	mv	a7,a4
ffffffffc0201462:	853e                	mv	a0,a5
ffffffffc0201464:	85be                	mv	a1,a5
ffffffffc0201466:	863e                	mv	a2,a5
ffffffffc0201468:	00000073          	ecall
ffffffffc020146c:	87aa                	mv	a5,a0

void sbi_shutdown(void) {
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc020146e:	8082                	ret

ffffffffc0201470 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201470:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201472:	e589                	bnez	a1,ffffffffc020147c <strnlen+0xc>
ffffffffc0201474:	a811                	j	ffffffffc0201488 <strnlen+0x18>
        cnt ++;
ffffffffc0201476:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201478:	00f58863          	beq	a1,a5,ffffffffc0201488 <strnlen+0x18>
ffffffffc020147c:	00f50733          	add	a4,a0,a5
ffffffffc0201480:	00074703          	lbu	a4,0(a4)
ffffffffc0201484:	fb6d                	bnez	a4,ffffffffc0201476 <strnlen+0x6>
ffffffffc0201486:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201488:	852e                	mv	a0,a1
ffffffffc020148a:	8082                	ret

ffffffffc020148c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020148c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201490:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201494:	cb89                	beqz	a5,ffffffffc02014a6 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201496:	0505                	addi	a0,a0,1
ffffffffc0201498:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020149a:	fee789e3          	beq	a5,a4,ffffffffc020148c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020149e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02014a2:	9d19                	subw	a0,a0,a4
ffffffffc02014a4:	8082                	ret
ffffffffc02014a6:	4501                	li	a0,0
ffffffffc02014a8:	bfed                	j	ffffffffc02014a2 <strcmp+0x16>

ffffffffc02014aa <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02014aa:	00054783          	lbu	a5,0(a0)
ffffffffc02014ae:	c799                	beqz	a5,ffffffffc02014bc <strchr+0x12>
        if (*s == c) {
ffffffffc02014b0:	00f58763          	beq	a1,a5,ffffffffc02014be <strchr+0x14>
    while (*s != '\0') {
ffffffffc02014b4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02014b8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02014ba:	fbfd                	bnez	a5,ffffffffc02014b0 <strchr+0x6>
    }
    return NULL;
ffffffffc02014bc:	4501                	li	a0,0
}
ffffffffc02014be:	8082                	ret

ffffffffc02014c0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02014c0:	ca01                	beqz	a2,ffffffffc02014d0 <memset+0x10>
ffffffffc02014c2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02014c4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02014c6:	0785                	addi	a5,a5,1
ffffffffc02014c8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02014cc:	fec79de3          	bne	a5,a2,ffffffffc02014c6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02014d0:	8082                	ret
