
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
ffffffffc020003a:	00054617          	auipc	a2,0x54
ffffffffc020003e:	64e60613          	addi	a2,a2,1614 # ffffffffc0254688 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	18c010ef          	jal	ra,ffffffffc02011d6 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	6a650513          	addi	a0,a0,1702 # ffffffffc02016f8 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	0bd000ef          	jal	ra,ffffffffc0200922 <pmm_init>

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
ffffffffc02000a6:	1ae010ef          	jal	ra,ffffffffc0201254 <vprintfmt>
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
ffffffffc02000dc:	178010ef          	jal	ra,ffffffffc0201254 <vprintfmt>
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
ffffffffc020013a:	00054317          	auipc	t1,0x54
ffffffffc020013e:	4f630313          	addi	t1,t1,1270 # ffffffffc0254630 <is_panic>
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
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	5b050513          	addi	a0,a0,1456 # ffffffffc0201718 <etext+0x24>
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
ffffffffc0200182:	f8a50513          	addi	a0,a0,-118 # ffffffffc0202108 <commands+0x798>
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
ffffffffc0200198:	00001517          	auipc	a0,0x1
ffffffffc020019c:	5a050513          	addi	a0,a0,1440 # ffffffffc0201738 <etext+0x44>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0201758 <etext+0x64>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	53a58593          	addi	a1,a1,1338 # ffffffffc02016f4 <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	5b650513          	addi	a0,a0,1462 # ffffffffc0201778 <etext+0x84>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00006597          	auipc	a1,0x6
ffffffffc02001d2:	e4a58593          	addi	a1,a1,-438 # ffffffffc0206018 <free_area>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	5c250513          	addi	a0,a0,1474 # ffffffffc0201798 <etext+0xa4>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00054597          	auipc	a1,0x54
ffffffffc02001e6:	4a658593          	addi	a1,a1,1190 # ffffffffc0254688 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	5ce50513          	addi	a0,a0,1486 # ffffffffc02017b8 <etext+0xc4>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	00055597          	auipc	a1,0x55
ffffffffc02001fa:	89158593          	addi	a1,a1,-1903 # ffffffffc0254a87 <end+0x3ff>
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
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	5c050513          	addi	a0,a0,1472 # ffffffffc02017d8 <etext+0xe4>
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
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	5e260613          	addi	a2,a2,1506 # ffffffffc0201808 <etext+0x114>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201820 <etext+0x12c>
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
ffffffffc0200242:	00001617          	auipc	a2,0x1
ffffffffc0200246:	5f660613          	addi	a2,a2,1526 # ffffffffc0201838 <etext+0x144>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	60e58593          	addi	a1,a1,1550 # ffffffffc0201858 <etext+0x164>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	60e50513          	addi	a0,a0,1550 # ffffffffc0201860 <etext+0x16c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	61060613          	addi	a2,a2,1552 # ffffffffc0201870 <etext+0x17c>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	63058593          	addi	a1,a1,1584 # ffffffffc0201898 <etext+0x1a4>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	5f050513          	addi	a0,a0,1520 # ffffffffc0201860 <etext+0x16c>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	62c60613          	addi	a2,a2,1580 # ffffffffc02018a8 <etext+0x1b4>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	64458593          	addi	a1,a1,1604 # ffffffffc02018c8 <etext+0x1d4>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	5d450513          	addi	a0,a0,1492 # ffffffffc0201860 <etext+0x16c>
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
ffffffffc02002c6:	00001517          	auipc	a0,0x1
ffffffffc02002ca:	61250513          	addi	a0,a0,1554 # ffffffffc02018d8 <etext+0x1e4>
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
ffffffffc02002e8:	00001517          	auipc	a0,0x1
ffffffffc02002ec:	61850513          	addi	a0,a0,1560 # ffffffffc0201900 <etext+0x20c>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	672c0c13          	addi	s8,s8,1650 # ffffffffc0201970 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	62290913          	addi	s2,s2,1570 # ffffffffc0201928 <etext+0x234>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	62248493          	addi	s1,s1,1570 # ffffffffc0201930 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	620b0b13          	addi	s6,s6,1568 # ffffffffc0201938 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	538a0a13          	addi	s4,s4,1336 # ffffffffc0201858 <etext+0x164>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	2aa010ef          	jal	ra,ffffffffc02015d6 <readline>
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
ffffffffc0200342:	00001d17          	auipc	s10,0x1
ffffffffc0200346:	62ed0d13          	addi	s10,s10,1582 # ffffffffc0201970 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	653000ef          	jal	ra,ffffffffc02011a2 <strcmp>
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
ffffffffc0200364:	63f000ef          	jal	ra,ffffffffc02011a2 <strcmp>
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
ffffffffc02003a2:	61f000ef          	jal	ra,ffffffffc02011c0 <strchr>
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
ffffffffc02003e0:	5e1000ef          	jal	ra,ffffffffc02011c0 <strchr>
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
ffffffffc02003fa:	00001517          	auipc	a0,0x1
ffffffffc02003fe:	55e50513          	addi	a0,a0,1374 # ffffffffc0201958 <etext+0x264>
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
ffffffffc0200420:	284010ef          	jal	ra,ffffffffc02016a4 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00054797          	auipc	a5,0x54
ffffffffc020042a:	2007b923          	sd	zero,530(a5) # ffffffffc0254638 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	58a50513          	addi	a0,a0,1418 # ffffffffc02019b8 <commands+0x48>
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
ffffffffc0200446:	25e0106f          	j	ffffffffc02016a4 <sbi_set_timer>

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
ffffffffc0200450:	23a0106f          	j	ffffffffc020168a <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	26a0106f          	j	ffffffffc02016be <sbi_console_getchar>

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
ffffffffc0200482:	55a50513          	addi	a0,a0,1370 # ffffffffc02019d8 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	56250513          	addi	a0,a0,1378 # ffffffffc02019f0 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	56c50513          	addi	a0,a0,1388 # ffffffffc0201a08 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	57650513          	addi	a0,a0,1398 # ffffffffc0201a20 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	58050513          	addi	a0,a0,1408 # ffffffffc0201a38 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	58a50513          	addi	a0,a0,1418 # ffffffffc0201a50 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	59450513          	addi	a0,a0,1428 # ffffffffc0201a68 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	59e50513          	addi	a0,a0,1438 # ffffffffc0201a80 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	5a850513          	addi	a0,a0,1448 # ffffffffc0201a98 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	5b250513          	addi	a0,a0,1458 # ffffffffc0201ab0 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	5bc50513          	addi	a0,a0,1468 # ffffffffc0201ac8 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	5c650513          	addi	a0,a0,1478 # ffffffffc0201ae0 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	5d050513          	addi	a0,a0,1488 # ffffffffc0201af8 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	5da50513          	addi	a0,a0,1498 # ffffffffc0201b10 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	5e450513          	addi	a0,a0,1508 # ffffffffc0201b28 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201b40 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	5f850513          	addi	a0,a0,1528 # ffffffffc0201b58 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	60250513          	addi	a0,a0,1538 # ffffffffc0201b70 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	60c50513          	addi	a0,a0,1548 # ffffffffc0201b88 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	61650513          	addi	a0,a0,1558 # ffffffffc0201ba0 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	62050513          	addi	a0,a0,1568 # ffffffffc0201bb8 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	62a50513          	addi	a0,a0,1578 # ffffffffc0201bd0 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	63450513          	addi	a0,a0,1588 # ffffffffc0201be8 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	63e50513          	addi	a0,a0,1598 # ffffffffc0201c00 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	64850513          	addi	a0,a0,1608 # ffffffffc0201c18 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	65250513          	addi	a0,a0,1618 # ffffffffc0201c30 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	65c50513          	addi	a0,a0,1628 # ffffffffc0201c48 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	66650513          	addi	a0,a0,1638 # ffffffffc0201c60 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	67050513          	addi	a0,a0,1648 # ffffffffc0201c78 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	67a50513          	addi	a0,a0,1658 # ffffffffc0201c90 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	68450513          	addi	a0,a0,1668 # ffffffffc0201ca8 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	68a50513          	addi	a0,a0,1674 # ffffffffc0201cc0 <commands+0x350>
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
ffffffffc020064e:	68e50513          	addi	a0,a0,1678 # ffffffffc0201cd8 <commands+0x368>
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
ffffffffc0200666:	68e50513          	addi	a0,a0,1678 # ffffffffc0201cf0 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	69650513          	addi	a0,a0,1686 # ffffffffc0201d08 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	69e50513          	addi	a0,a0,1694 # ffffffffc0201d20 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	6a250513          	addi	a0,a0,1698 # ffffffffc0201d38 <commands+0x3c8>
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
ffffffffc02006b4:	76870713          	addi	a4,a4,1896 # ffffffffc0201e18 <commands+0x4a8>
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
ffffffffc02006c6:	6ee50513          	addi	a0,a0,1774 # ffffffffc0201db0 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	6c450513          	addi	a0,a0,1732 # ffffffffc0201d90 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	67a50513          	addi	a0,a0,1658 # ffffffffc0201d50 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	6f050513          	addi	a0,a0,1776 # ffffffffc0201dd0 <commands+0x460>
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
ffffffffc02006f4:	00054697          	auipc	a3,0x54
ffffffffc02006f8:	f4468693          	addi	a3,a3,-188 # ffffffffc0254638 <ticks>
ffffffffc02006fc:	629c                	ld	a5,0(a3)
ffffffffc02006fe:	06400713          	li	a4,100
ffffffffc0200702:	00054417          	auipc	s0,0x54
ffffffffc0200706:	f3e40413          	addi	s0,s0,-194 # ffffffffc0254640 <num>
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
ffffffffc0200728:	6d450513          	addi	a0,a0,1748 # ffffffffc0201df8 <commands+0x488>
ffffffffc020072c:	b259                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020072e:	00001517          	auipc	a0,0x1
ffffffffc0200732:	64250513          	addi	a0,a0,1602 # ffffffffc0201d70 <commands+0x400>
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200738:	b729                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073a:	06400593          	li	a1,100
ffffffffc020073e:	00001517          	auipc	a0,0x1
ffffffffc0200742:	6aa50513          	addi	a0,a0,1706 # ffffffffc0201de8 <commands+0x478>
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
ffffffffc0200758:	7830006f          	j	ffffffffc02016da <sbi_shutdown>

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
ffffffffc020077c:	6d050513          	addi	a0,a0,1744 # ffffffffc0201e48 <commands+0x4d8>
ffffffffc0200780:	933ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200784:	10843583          	ld	a1,264(s0)
ffffffffc0200788:	00001517          	auipc	a0,0x1
ffffffffc020078c:	6e850513          	addi	a0,a0,1768 # ffffffffc0201e70 <commands+0x500>
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
ffffffffc02007ba:	6e250513          	addi	a0,a0,1762 # ffffffffc0201e98 <commands+0x528>
ffffffffc02007be:	8f5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc02007c2:	10843583          	ld	a1,264(s0)
ffffffffc02007c6:	00001517          	auipc	a0,0x1
ffffffffc02007ca:	6f250513          	addi	a0,a0,1778 # ffffffffc0201eb8 <commands+0x548>
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
ffffffffc02008ae:	00054797          	auipc	a5,0x54
ffffffffc02008b2:	daa7b783          	ld	a5,-598(a5) # ffffffffc0254658 <pmm_manager>
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
ffffffffc02008c6:	00054797          	auipc	a5,0x54
ffffffffc02008ca:	d927b783          	ld	a5,-622(a5) # ffffffffc0254658 <pmm_manager>
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
ffffffffc02008ec:	00054797          	auipc	a5,0x54
ffffffffc02008f0:	d6c7b783          	ld	a5,-660(a5) # ffffffffc0254658 <pmm_manager>
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
ffffffffc0200908:	00054797          	auipc	a5,0x54
ffffffffc020090c:	d507b783          	ld	a5,-688(a5) # ffffffffc0254658 <pmm_manager>
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

ffffffffc0200922 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200922:	00002797          	auipc	a5,0x2
ffffffffc0200926:	93678793          	addi	a5,a5,-1738 # ffffffffc0202258 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020092a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020092c:	1101                	addi	sp,sp,-32
ffffffffc020092e:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200930:	00001517          	auipc	a0,0x1
ffffffffc0200934:	5a850513          	addi	a0,a0,1448 # ffffffffc0201ed8 <commands+0x568>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200938:	00054497          	auipc	s1,0x54
ffffffffc020093c:	d2048493          	addi	s1,s1,-736 # ffffffffc0254658 <pmm_manager>
void pmm_init(void) {
ffffffffc0200940:	ec06                	sd	ra,24(sp)
ffffffffc0200942:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200944:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200946:	f6cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020094a:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020094c:	00054417          	auipc	s0,0x54
ffffffffc0200950:	d2440413          	addi	s0,s0,-732 # ffffffffc0254670 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200954:	679c                	ld	a5,8(a5)
ffffffffc0200956:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200958:	57f5                	li	a5,-3
ffffffffc020095a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020095c:	00001517          	auipc	a0,0x1
ffffffffc0200960:	59450513          	addi	a0,a0,1428 # ffffffffc0201ef0 <commands+0x580>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200964:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200966:	f4cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020096a:	46c5                	li	a3,17
ffffffffc020096c:	06ee                	slli	a3,a3,0x1b
ffffffffc020096e:	40100613          	li	a2,1025
ffffffffc0200972:	16fd                	addi	a3,a3,-1
ffffffffc0200974:	07e005b7          	lui	a1,0x7e00
ffffffffc0200978:	0656                	slli	a2,a2,0x15
ffffffffc020097a:	00001517          	auipc	a0,0x1
ffffffffc020097e:	58e50513          	addi	a0,a0,1422 # ffffffffc0201f08 <commands+0x598>
ffffffffc0200982:	f30ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200986:	777d                	lui	a4,0xfffff
ffffffffc0200988:	00055797          	auipc	a5,0x55
ffffffffc020098c:	cff78793          	addi	a5,a5,-769 # ffffffffc0255687 <end+0xfff>
ffffffffc0200990:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200992:	00054517          	auipc	a0,0x54
ffffffffc0200996:	cb650513          	addi	a0,a0,-842 # ffffffffc0254648 <npage>
ffffffffc020099a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020099e:	00054597          	auipc	a1,0x54
ffffffffc02009a2:	cb258593          	addi	a1,a1,-846 # ffffffffc0254650 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02009a6:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009a8:	e19c                	sd	a5,0(a1)
ffffffffc02009aa:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009ac:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009ae:	4885                	li	a7,1
ffffffffc02009b0:	fff80837          	lui	a6,0xfff80
ffffffffc02009b4:	a011                	j	ffffffffc02009b8 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02009b6:	619c                	ld	a5,0(a1)
ffffffffc02009b8:	97b6                	add	a5,a5,a3
ffffffffc02009ba:	07a1                	addi	a5,a5,8
ffffffffc02009bc:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009c0:	611c                	ld	a5,0(a0)
ffffffffc02009c2:	0705                	addi	a4,a4,1
ffffffffc02009c4:	02868693          	addi	a3,a3,40
ffffffffc02009c8:	01078633          	add	a2,a5,a6
ffffffffc02009cc:	fec765e3          	bltu	a4,a2,ffffffffc02009b6 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009d0:	6190                	ld	a2,0(a1)
ffffffffc02009d2:	00279713          	slli	a4,a5,0x2
ffffffffc02009d6:	973e                	add	a4,a4,a5
ffffffffc02009d8:	fec006b7          	lui	a3,0xfec00
ffffffffc02009dc:	070e                	slli	a4,a4,0x3
ffffffffc02009de:	96b2                	add	a3,a3,a2
ffffffffc02009e0:	96ba                	add	a3,a3,a4
ffffffffc02009e2:	c0200737          	lui	a4,0xc0200
ffffffffc02009e6:	08e6ef63          	bltu	a3,a4,ffffffffc0200a84 <pmm_init+0x162>
ffffffffc02009ea:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02009ec:	45c5                	li	a1,17
ffffffffc02009ee:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009f0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02009f2:	04b6e863          	bltu	a3,a1,ffffffffc0200a42 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02009f6:	609c                	ld	a5,0(s1)
ffffffffc02009f8:	7b9c                	ld	a5,48(a5)
ffffffffc02009fa:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02009fc:	00001517          	auipc	a0,0x1
ffffffffc0200a00:	5a450513          	addi	a0,a0,1444 # ffffffffc0201fa0 <commands+0x630>
ffffffffc0200a04:	eaeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200a08:	00004597          	auipc	a1,0x4
ffffffffc0200a0c:	5f858593          	addi	a1,a1,1528 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200a10:	00054797          	auipc	a5,0x54
ffffffffc0200a14:	c4b7bc23          	sd	a1,-936(a5) # ffffffffc0254668 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a18:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a1c:	08f5e063          	bltu	a1,a5,ffffffffc0200a9c <pmm_init+0x17a>
ffffffffc0200a20:	6010                	ld	a2,0(s0)
}
ffffffffc0200a22:	6442                	ld	s0,16(sp)
ffffffffc0200a24:	60e2                	ld	ra,24(sp)
ffffffffc0200a26:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a28:	40c58633          	sub	a2,a1,a2
ffffffffc0200a2c:	00054797          	auipc	a5,0x54
ffffffffc0200a30:	c2c7ba23          	sd	a2,-972(a5) # ffffffffc0254660 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a34:	00001517          	auipc	a0,0x1
ffffffffc0200a38:	58c50513          	addi	a0,a0,1420 # ffffffffc0201fc0 <commands+0x650>
}
ffffffffc0200a3c:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a3e:	e74ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200a42:	6705                	lui	a4,0x1
ffffffffc0200a44:	177d                	addi	a4,a4,-1
ffffffffc0200a46:	96ba                	add	a3,a3,a4
ffffffffc0200a48:	777d                	lui	a4,0xfffff
ffffffffc0200a4a:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200a4c:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200a50:	00f57e63          	bgeu	a0,a5,ffffffffc0200a6c <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a54:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a56:	982a                	add	a6,a6,a0
ffffffffc0200a58:	00281513          	slli	a0,a6,0x2
ffffffffc0200a5c:	9542                	add	a0,a0,a6
ffffffffc0200a5e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a60:	8d95                	sub	a1,a1,a3
ffffffffc0200a62:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a64:	81b1                	srli	a1,a1,0xc
ffffffffc0200a66:	9532                	add	a0,a0,a2
ffffffffc0200a68:	9782                	jalr	a5
}
ffffffffc0200a6a:	b771                	j	ffffffffc02009f6 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200a6c:	00001617          	auipc	a2,0x1
ffffffffc0200a70:	50460613          	addi	a2,a2,1284 # ffffffffc0201f70 <commands+0x600>
ffffffffc0200a74:	06b00593          	li	a1,107
ffffffffc0200a78:	00001517          	auipc	a0,0x1
ffffffffc0200a7c:	51850513          	addi	a0,a0,1304 # ffffffffc0201f90 <commands+0x620>
ffffffffc0200a80:	ebaff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a84:	00001617          	auipc	a2,0x1
ffffffffc0200a88:	4b460613          	addi	a2,a2,1204 # ffffffffc0201f38 <commands+0x5c8>
ffffffffc0200a8c:	06f00593          	li	a1,111
ffffffffc0200a90:	00001517          	auipc	a0,0x1
ffffffffc0200a94:	4d050513          	addi	a0,a0,1232 # ffffffffc0201f60 <commands+0x5f0>
ffffffffc0200a98:	ea2ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a9c:	86ae                	mv	a3,a1
ffffffffc0200a9e:	00001617          	auipc	a2,0x1
ffffffffc0200aa2:	49a60613          	addi	a2,a2,1178 # ffffffffc0201f38 <commands+0x5c8>
ffffffffc0200aa6:	08a00593          	li	a1,138
ffffffffc0200aaa:	00001517          	auipc	a0,0x1
ffffffffc0200aae:	4b650513          	addi	a0,a0,1206 # ffffffffc0201f60 <commands+0x5f0>
ffffffffc0200ab2:	e88ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200ab6 <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ab6:	00005797          	auipc	a5,0x5
ffffffffc0200aba:	56278793          	addi	a5,a5,1378 # ffffffffc0206018 <free_area>
ffffffffc0200abe:	e79c                	sd	a5,8(a5)
ffffffffc0200ac0:	e39c                	sd	a5,0(a5)


static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200ac2:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ac6:	8082                	ret

ffffffffc0200ac8 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ac8:	00005517          	auipc	a0,0x5
ffffffffc0200acc:	56056503          	lwu	a0,1376(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200ad0:	8082                	ret

ffffffffc0200ad2 <buddy_check>:

static void
buddy_check(void) {
ffffffffc0200ad2:	7179                	addi	sp,sp,-48
    struct Page *p0, *p1,*p2;
    p0 = p1 = NULL;
    p2=NULL;
    struct Page *p3, *p4,*p5;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ad4:	4505                	li	a0,1
buddy_check(void) {
ffffffffc0200ad6:	f406                	sd	ra,40(sp)
ffffffffc0200ad8:	f022                	sd	s0,32(sp)
ffffffffc0200ada:	ec26                	sd	s1,24(sp)
ffffffffc0200adc:	e84a                	sd	s2,16(sp)
ffffffffc0200ade:	e44e                	sd	s3,8(sp)
ffffffffc0200ae0:	e052                	sd	s4,0(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ae2:	dc5ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200ae6:	1c050d63          	beqz	a0,ffffffffc0200cc0 <buddy_check+0x1ee>
ffffffffc0200aea:	842a                	mv	s0,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200aec:	4505                	li	a0,1
ffffffffc0200aee:	db9ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200af2:	892a                	mv	s2,a0
ffffffffc0200af4:	20050663          	beqz	a0,ffffffffc0200d00 <buddy_check+0x22e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200af8:	4505                	li	a0,1
ffffffffc0200afa:	dadff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200afe:	84aa                	mv	s1,a0
ffffffffc0200b00:	1e050063          	beqz	a0,ffffffffc0200ce0 <buddy_check+0x20e>
    free_page(p0);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	4585                	li	a1,1
ffffffffc0200b08:	dddff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    free_page(p1);
ffffffffc0200b0c:	854a                	mv	a0,s2
ffffffffc0200b0e:	4585                	li	a1,1
ffffffffc0200b10:	dd5ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    free_page(p2);
ffffffffc0200b14:	4585                	li	a1,1
ffffffffc0200b16:	8526                	mv	a0,s1
ffffffffc0200b18:	dcdff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    
    p0=alloc_pages(70);
ffffffffc0200b1c:	04600513          	li	a0,70
ffffffffc0200b20:	d87ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200b24:	8a2a                	mv	s4,a0
    p1=alloc_pages(35);
ffffffffc0200b26:	02300513          	li	a0,35
ffffffffc0200b2a:	d7dff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200b2e:	842a                	mv	s0,a0
    //注意，一个结构体指针是20个字节，有3个int,3*4，还有一个双向链表,两个指针是8。加载一起是20。
    cprintf("p0 %p\n",p0);
ffffffffc0200b30:	85d2                	mv	a1,s4
ffffffffc0200b32:	00001517          	auipc	a0,0x1
ffffffffc0200b36:	55e50513          	addi	a0,a0,1374 # ffffffffc0202090 <commands+0x720>
ffffffffc0200b3a:	d78ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p1 %p\n",p1);
ffffffffc0200b3e:	85a2                	mv	a1,s0
ffffffffc0200b40:	00001517          	auipc	a0,0x1
ffffffffc0200b44:	55850513          	addi	a0,a0,1368 # ffffffffc0202098 <commands+0x728>
ffffffffc0200b48:	d6aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p1-p0 equal %p ?=128\n",p1-p0);//应该差128
ffffffffc0200b4c:	414405b3          	sub	a1,s0,s4
ffffffffc0200b50:	00002997          	auipc	s3,0x2
ffffffffc0200b54:	9889b983          	ld	s3,-1656(s3) # ffffffffc02024d8 <error_string+0x38>
ffffffffc0200b58:	858d                	srai	a1,a1,0x3
ffffffffc0200b5a:	033585b3          	mul	a1,a1,s3
ffffffffc0200b5e:	00001517          	auipc	a0,0x1
ffffffffc0200b62:	54250513          	addi	a0,a0,1346 # ffffffffc02020a0 <commands+0x730>
ffffffffc0200b66:	d4cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p2=alloc_pages(257);
ffffffffc0200b6a:	10100513          	li	a0,257
ffffffffc0200b6e:	d39ff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200b72:	84aa                	mv	s1,a0
    cprintf("p2 %p\n",p2);
ffffffffc0200b74:	85aa                	mv	a1,a0
ffffffffc0200b76:	00001517          	auipc	a0,0x1
ffffffffc0200b7a:	54250513          	addi	a0,a0,1346 # ffffffffc02020b8 <commands+0x748>
ffffffffc0200b7e:	d34ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p2-p1 equal %p ?=128+256\n",p2-p1);//应该差384
ffffffffc0200b82:	408485b3          	sub	a1,s1,s0
ffffffffc0200b86:	858d                	srai	a1,a1,0x3
ffffffffc0200b88:	033585b3          	mul	a1,a1,s3
ffffffffc0200b8c:	00001517          	auipc	a0,0x1
ffffffffc0200b90:	53450513          	addi	a0,a0,1332 # ffffffffc02020c0 <commands+0x750>
ffffffffc0200b94:	d1eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p3=alloc_pages(63);
ffffffffc0200b98:	03f00513          	li	a0,63
ffffffffc0200b9c:	d0bff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200ba0:	892a                	mv	s2,a0
    cprintf("p3 %p\n",p3);
ffffffffc0200ba2:	85aa                	mv	a1,a0
ffffffffc0200ba4:	00001517          	auipc	a0,0x1
ffffffffc0200ba8:	53c50513          	addi	a0,a0,1340 # ffffffffc02020e0 <commands+0x770>
ffffffffc0200bac:	d06ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p3-p1 equal %p ?=64\n",p3-p1);//应该差64
ffffffffc0200bb0:	408905b3          	sub	a1,s2,s0
ffffffffc0200bb4:	858d                	srai	a1,a1,0x3
ffffffffc0200bb6:	033585b3          	mul	a1,a1,s3
ffffffffc0200bba:	00001517          	auipc	a0,0x1
ffffffffc0200bbe:	52e50513          	addi	a0,a0,1326 # ffffffffc02020e8 <commands+0x778>
ffffffffc0200bc2:	cf0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    free_pages(p0,70);    
ffffffffc0200bc6:	04600593          	li	a1,70
ffffffffc0200bca:	8552                	mv	a0,s4
ffffffffc0200bcc:	d19ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    cprintf("free p0!\n");
ffffffffc0200bd0:	00001517          	auipc	a0,0x1
ffffffffc0200bd4:	53050513          	addi	a0,a0,1328 # ffffffffc0202100 <commands+0x790>
ffffffffc0200bd8:	cdaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p1,35);
ffffffffc0200bdc:	02300593          	li	a1,35
ffffffffc0200be0:	8522                	mv	a0,s0
ffffffffc0200be2:	d03ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    cprintf("free p1!\n");
ffffffffc0200be6:	00001517          	auipc	a0,0x1
ffffffffc0200bea:	52a50513          	addi	a0,a0,1322 # ffffffffc0202110 <commands+0x7a0>
ffffffffc0200bee:	cc4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p3,63);    
ffffffffc0200bf2:	03f00593          	li	a1,63
ffffffffc0200bf6:	854a                	mv	a0,s2
ffffffffc0200bf8:	cedff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    cprintf("free p3!\n");
ffffffffc0200bfc:	00001517          	auipc	a0,0x1
ffffffffc0200c00:	52450513          	addi	a0,a0,1316 # ffffffffc0202120 <commands+0x7b0>
ffffffffc0200c04:	caeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p4=alloc_pages(255);
ffffffffc0200c08:	0ff00513          	li	a0,255
ffffffffc0200c0c:	c9bff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200c10:	842a                	mv	s0,a0
    cprintf("p4 %p\n",p4);
ffffffffc0200c12:	85aa                	mv	a1,a0
ffffffffc0200c14:	00001517          	auipc	a0,0x1
ffffffffc0200c18:	51c50513          	addi	a0,a0,1308 # ffffffffc0202130 <commands+0x7c0>
ffffffffc0200c1c:	c96ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p2-p4 equal %p ?=512\n",p2-p4);//应该差512
ffffffffc0200c20:	408485b3          	sub	a1,s1,s0
ffffffffc0200c24:	858d                	srai	a1,a1,0x3
ffffffffc0200c26:	033585b3          	mul	a1,a1,s3
ffffffffc0200c2a:	00001517          	auipc	a0,0x1
ffffffffc0200c2e:	50e50513          	addi	a0,a0,1294 # ffffffffc0202138 <commands+0x7c8>
ffffffffc0200c32:	c80ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p5=alloc_pages(255);
ffffffffc0200c36:	0ff00513          	li	a0,255
ffffffffc0200c3a:	c6dff0ef          	jal	ra,ffffffffc02008a6 <alloc_pages>
ffffffffc0200c3e:	892a                	mv	s2,a0
    cprintf("p5 %p\n",p5);
ffffffffc0200c40:	85aa                	mv	a1,a0
ffffffffc0200c42:	00001517          	auipc	a0,0x1
ffffffffc0200c46:	50e50513          	addi	a0,a0,1294 # ffffffffc0202150 <commands+0x7e0>
ffffffffc0200c4a:	c68ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p5-p4 equal %p ?=256\n",p5-p4);//应该差256
ffffffffc0200c4e:	408905b3          	sub	a1,s2,s0
ffffffffc0200c52:	858d                	srai	a1,a1,0x3
ffffffffc0200c54:	033585b3          	mul	a1,a1,s3
ffffffffc0200c58:	00001517          	auipc	a0,0x1
ffffffffc0200c5c:	50050513          	addi	a0,a0,1280 # ffffffffc0202158 <commands+0x7e8>
ffffffffc0200c60:	c52ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        free_pages(p2,257);    
ffffffffc0200c64:	10100593          	li	a1,257
ffffffffc0200c68:	8526                	mv	a0,s1
ffffffffc0200c6a:	c7bff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    cprintf("free p2!\n");
ffffffffc0200c6e:	00001517          	auipc	a0,0x1
ffffffffc0200c72:	50250513          	addi	a0,a0,1282 # ffffffffc0202170 <commands+0x800>
ffffffffc0200c76:	c3cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        free_pages(p4,255);    
ffffffffc0200c7a:	0ff00593          	li	a1,255
ffffffffc0200c7e:	8522                	mv	a0,s0
ffffffffc0200c80:	c65ff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    cprintf("free p4!\n"); 
ffffffffc0200c84:	00001517          	auipc	a0,0x1
ffffffffc0200c88:	4fc50513          	addi	a0,a0,1276 # ffffffffc0202180 <commands+0x810>
ffffffffc0200c8c:	c26ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            free_pages(p5,255);    
ffffffffc0200c90:	854a                	mv	a0,s2
ffffffffc0200c92:	0ff00593          	li	a1,255
ffffffffc0200c96:	c4fff0ef          	jal	ra,ffffffffc02008e4 <free_pages>
    cprintf("free p5!\n");   
ffffffffc0200c9a:	00001517          	auipc	a0,0x1
ffffffffc0200c9e:	4f650513          	addi	a0,a0,1270 # ffffffffc0202190 <commands+0x820>
ffffffffc0200ca2:	c10ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("CHECK DONE!\n") ;

}
ffffffffc0200ca6:	7402                	ld	s0,32(sp)
ffffffffc0200ca8:	70a2                	ld	ra,40(sp)
ffffffffc0200caa:	64e2                	ld	s1,24(sp)
ffffffffc0200cac:	6942                	ld	s2,16(sp)
ffffffffc0200cae:	69a2                	ld	s3,8(sp)
ffffffffc0200cb0:	6a02                	ld	s4,0(sp)
    cprintf("CHECK DONE!\n") ;
ffffffffc0200cb2:	00001517          	auipc	a0,0x1
ffffffffc0200cb6:	4ee50513          	addi	a0,a0,1262 # ffffffffc02021a0 <commands+0x830>
}
ffffffffc0200cba:	6145                	addi	sp,sp,48
    cprintf("CHECK DONE!\n") ;
ffffffffc0200cbc:	bf6ff06f          	j	ffffffffc02000b2 <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cc0:	00001697          	auipc	a3,0x1
ffffffffc0200cc4:	34068693          	addi	a3,a3,832 # ffffffffc0202000 <commands+0x690>
ffffffffc0200cc8:	00001617          	auipc	a2,0x1
ffffffffc0200ccc:	35860613          	addi	a2,a2,856 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0200cd0:	0e400593          	li	a1,228
ffffffffc0200cd4:	00001517          	auipc	a0,0x1
ffffffffc0200cd8:	36450513          	addi	a0,a0,868 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0200cdc:	c5eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ce0:	00001697          	auipc	a3,0x1
ffffffffc0200ce4:	39068693          	addi	a3,a3,912 # ffffffffc0202070 <commands+0x700>
ffffffffc0200ce8:	00001617          	auipc	a2,0x1
ffffffffc0200cec:	33860613          	addi	a2,a2,824 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0200cf0:	0e600593          	li	a1,230
ffffffffc0200cf4:	00001517          	auipc	a0,0x1
ffffffffc0200cf8:	34450513          	addi	a0,a0,836 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0200cfc:	c3eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d00:	00001697          	auipc	a3,0x1
ffffffffc0200d04:	35068693          	addi	a3,a3,848 # ffffffffc0202050 <commands+0x6e0>
ffffffffc0200d08:	00001617          	auipc	a2,0x1
ffffffffc0200d0c:	31860613          	addi	a2,a2,792 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0200d10:	0e500593          	li	a1,229
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	32450513          	addi	a0,a0,804 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0200d1c:	c1eff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200d20 <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200d20:	7179                	addi	sp,sp,-48
ffffffffc0200d22:	f406                	sd	ra,40(sp)
ffffffffc0200d24:	f022                	sd	s0,32(sp)
ffffffffc0200d26:	ec26                	sd	s1,24(sp)
ffffffffc0200d28:	e84a                	sd	s2,16(sp)
ffffffffc0200d2a:	e44e                	sd	s3,8(sp)
ffffffffc0200d2c:	e052                	sd	s4,0(sp)
    assert(n>0);
ffffffffc0200d2e:	12058e63          	beqz	a1,ffffffffc0200e6a <buddy_free_pages+0x14a>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200d32:	00005917          	auipc	s2,0x5
ffffffffc0200d36:	2e690913          	addi	s2,s2,742 # ffffffffc0206018 <free_area>
    struct Page *base_page = le2page(list_next(le), page_link); 
ffffffffc0200d3a:	00893783          	ld	a5,8(s2)
ffffffffc0200d3e:	84aa                	mv	s1,a0
    unsigned int offset= base - base_page; // 释放块的偏移量
ffffffffc0200d40:	00001417          	auipc	s0,0x1
ffffffffc0200d44:	79843403          	ld	s0,1944(s0) # ffffffffc02024d8 <error_string+0x38>
    struct Page *base_page = le2page(list_next(le), page_link); 
ffffffffc0200d48:	17a1                	addi	a5,a5,-24
    unsigned int offset= base - base_page; // 释放块的偏移量
ffffffffc0200d4a:	40f487b3          	sub	a5,s1,a5
ffffffffc0200d4e:	878d                	srai	a5,a5,0x3
ffffffffc0200d50:	0287843b          	mulw	s0,a5,s0
    cprintf("free page offset %d\n),",offset);
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	46450513          	addi	a0,a0,1124 # ffffffffc02021b8 <commands+0x848>
    n = base->property; // 从property中拿到空闲块的大小
ffffffffc0200d5c:	0104a983          	lw	s3,16(s1)
ffffffffc0200d60:	02099a13          	slli	s4,s3,0x20
ffffffffc0200d64:	020a5a13          	srli	s4,s4,0x20
    cprintf("free page offset %d\n),",offset);
ffffffffc0200d68:	85a2                	mv	a1,s0
ffffffffc0200d6a:	b48ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    assert(self&&offset >= 0&&offset < self->size); // 是否合法
ffffffffc0200d6e:	00005817          	auipc	a6,0x5
ffffffffc0200d72:	2c280813          	addi	a6,a6,706 # ffffffffc0206030 <root>
ffffffffc0200d76:	00082783          	lw	a5,0(a6)
ffffffffc0200d7a:	0cf47863          	bgeu	s0,a5,ffffffffc0200e4a <buddy_free_pages+0x12a>
    for (; p != base + n; p ++) { // 释放每一页
ffffffffc0200d7e:	002a1613          	slli	a2,s4,0x2
ffffffffc0200d82:	9652                	add	a2,a2,s4
ffffffffc0200d84:	060e                	slli	a2,a2,0x3
ffffffffc0200d86:	9626                	add	a2,a2,s1
ffffffffc0200d88:	8726                	mv	a4,s1
ffffffffc0200d8a:	00c48b63          	beq	s1,a2,ffffffffc0200da0 <buddy_free_pages+0x80>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d8e:	6714                	ld	a3,8(a4)
        assert(!PageReserved(p));
ffffffffc0200d90:	8a85                	andi	a3,a3,1
ffffffffc0200d92:	eec1                	bnez	a3,ffffffffc0200e2a <buddy_free_pages+0x10a>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d94:	00072023          	sw	zero,0(a4) # fffffffffffff000 <end+0x3fdaa978>
    for (; p != base + n; p ++) { // 释放每一页
ffffffffc0200d98:	02870713          	addi	a4,a4,40
ffffffffc0200d9c:	fec719e3          	bne	a4,a2,ffffffffc0200d8e <buddy_free_pages+0x6e>
    nr_free += n;
ffffffffc0200da0:	01092683          	lw	a3,16(s2)
    index = offset + self->size - 1;   //从原始的分配节点的最底节点开始改变longest
ffffffffc0200da4:	37fd                	addiw	a5,a5,-1
ffffffffc0200da6:	9fa1                	addw	a5,a5,s0
    self[index].longest = node_size;   //这里是node_size，也就是从1那层开始改变
ffffffffc0200da8:	02079613          	slli	a2,a5,0x20
    base->property = 0; // 当前页不再管辖任何空闲块
ffffffffc0200dac:	0004a823          	sw	zero,16(s1)
    nr_free += n;
ffffffffc0200db0:	013686bb          	addw	a3,a3,s3
    self[index].longest = node_size;   //这里是node_size，也就是从1那层开始改变
ffffffffc0200db4:	01d65713          	srli	a4,a2,0x1d
ffffffffc0200db8:	9742                	add	a4,a4,a6
    nr_free += n;
ffffffffc0200dba:	00d92823          	sw	a3,16(s2)
    self[index].longest = node_size;   //这里是node_size，也就是从1那层开始改变
ffffffffc0200dbe:	4685                	li	a3,1
ffffffffc0200dc0:	c354                	sw	a3,4(a4)
    node_size = 1;
ffffffffc0200dc2:	4585                	li	a1,1
    while (index) {//向上合并，修改父节点的记录值
ffffffffc0200dc4:	cba1                	beqz	a5,ffffffffc0200e14 <buddy_free_pages+0xf4>
        index = PARENT(index);
ffffffffc0200dc6:	2785                	addiw	a5,a5,1
ffffffffc0200dc8:	0017d61b          	srliw	a2,a5,0x1
ffffffffc0200dcc:	367d                	addiw	a2,a2,-1
        right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200dce:	ffe7f713          	andi	a4,a5,-2
        left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200dd2:	0016169b          	slliw	a3,a2,0x1
ffffffffc0200dd6:	2685                	addiw	a3,a3,1
        right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200dd8:	1702                	slli	a4,a4,0x20
        left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200dda:	02069793          	slli	a5,a3,0x20
        right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200dde:	9301                	srli	a4,a4,0x20
        left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200de0:	01d7d693          	srli	a3,a5,0x1d
        right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200de4:	070e                	slli	a4,a4,0x3
ffffffffc0200de6:	9742                	add	a4,a4,a6
        left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200de8:	96c2                	add	a3,a3,a6
        right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200dea:	4348                	lw	a0,4(a4)
        left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200dec:	42d4                	lw	a3,4(a3)
            self[index].longest = node_size;
ffffffffc0200dee:	02061793          	slli	a5,a2,0x20
ffffffffc0200df2:	01d7d713          	srli	a4,a5,0x1d
        node_size *= 2;
ffffffffc0200df6:	0015959b          	slliw	a1,a1,0x1
        if (left_longest + right_longest == node_size) 
ffffffffc0200dfa:	00a6833b          	addw	t1,a3,a0
        index = PARENT(index);
ffffffffc0200dfe:	0006079b          	sext.w	a5,a2
            self[index].longest = node_size;
ffffffffc0200e02:	9742                	add	a4,a4,a6
        if (left_longest + right_longest == node_size) 
ffffffffc0200e04:	02b30063          	beq	t1,a1,ffffffffc0200e24 <buddy_free_pages+0x104>
            self[index].longest = MAX(left_longest, right_longest);
ffffffffc0200e08:	8636                	mv	a2,a3
ffffffffc0200e0a:	00a6f363          	bgeu	a3,a0,ffffffffc0200e10 <buddy_free_pages+0xf0>
ffffffffc0200e0e:	862a                	mv	a2,a0
ffffffffc0200e10:	c350                	sw	a2,4(a4)
    while (index) {//向上合并，修改父节点的记录值
ffffffffc0200e12:	fbd5                	bnez	a5,ffffffffc0200dc6 <buddy_free_pages+0xa6>
}
ffffffffc0200e14:	70a2                	ld	ra,40(sp)
ffffffffc0200e16:	7402                	ld	s0,32(sp)
ffffffffc0200e18:	64e2                	ld	s1,24(sp)
ffffffffc0200e1a:	6942                	ld	s2,16(sp)
ffffffffc0200e1c:	69a2                	ld	s3,8(sp)
ffffffffc0200e1e:	6a02                	ld	s4,0(sp)
ffffffffc0200e20:	6145                	addi	sp,sp,48
ffffffffc0200e22:	8082                	ret
            self[index].longest = node_size;
ffffffffc0200e24:	c34c                	sw	a1,4(a4)
    while (index) {//向上合并，修改父节点的记录值
ffffffffc0200e26:	f3c5                	bnez	a5,ffffffffc0200dc6 <buddy_free_pages+0xa6>
ffffffffc0200e28:	b7f5                	j	ffffffffc0200e14 <buddy_free_pages+0xf4>
        assert(!PageReserved(p));
ffffffffc0200e2a:	00001697          	auipc	a3,0x1
ffffffffc0200e2e:	3ce68693          	addi	a3,a3,974 # ffffffffc02021f8 <commands+0x888>
ffffffffc0200e32:	00001617          	auipc	a2,0x1
ffffffffc0200e36:	1ee60613          	addi	a2,a2,494 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0200e3a:	0d000593          	li	a1,208
ffffffffc0200e3e:	00001517          	auipc	a0,0x1
ffffffffc0200e42:	1fa50513          	addi	a0,a0,506 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0200e46:	af4ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(self&&offset >= 0&&offset < self->size); // 是否合法
ffffffffc0200e4a:	00001697          	auipc	a3,0x1
ffffffffc0200e4e:	38668693          	addi	a3,a3,902 # ffffffffc02021d0 <commands+0x860>
ffffffffc0200e52:	00001617          	auipc	a2,0x1
ffffffffc0200e56:	1ce60613          	addi	a2,a2,462 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0200e5a:	0cc00593          	li	a1,204
ffffffffc0200e5e:	00001517          	auipc	a0,0x1
ffffffffc0200e62:	1da50513          	addi	a0,a0,474 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0200e66:	ad4ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n>0);
ffffffffc0200e6a:	00001697          	auipc	a3,0x1
ffffffffc0200e6e:	34668693          	addi	a3,a3,838 # ffffffffc02021b0 <commands+0x840>
ffffffffc0200e72:	00001617          	auipc	a2,0x1
ffffffffc0200e76:	1ae60613          	addi	a2,a2,430 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0200e7a:	0c400593          	li	a1,196
ffffffffc0200e7e:	00001517          	auipc	a0,0x1
ffffffffc0200e82:	1ba50513          	addi	a0,a0,442 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0200e86:	ab4ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200e8a <buddy_alloc_pages>:
buddy_alloc_pages(size_t n) {
ffffffffc0200e8a:	1101                	addi	sp,sp,-32
ffffffffc0200e8c:	ec06                	sd	ra,24(sp)
ffffffffc0200e8e:	e822                	sd	s0,16(sp)
ffffffffc0200e90:	e426                	sd	s1,8(sp)
ffffffffc0200e92:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc0200e94:	14050c63          	beqz	a0,ffffffffc0200fec <buddy_alloc_pages+0x162>
    if (n > nr_free) {
ffffffffc0200e98:	00005497          	auipc	s1,0x5
ffffffffc0200e9c:	18048493          	addi	s1,s1,384 # ffffffffc0206018 <free_area>
ffffffffc0200ea0:	0104e783          	lwu	a5,16(s1)
ffffffffc0200ea4:	12a7e163          	bltu	a5,a0,ffffffffc0200fc6 <buddy_alloc_pages+0x13c>
    else if (!IS_POWER_OF_2(n)) // 不为2的幂时，向上取
ffffffffc0200ea8:	fff50793          	addi	a5,a0,-1
ffffffffc0200eac:	8fe9                	and	a5,a5,a0
        n = fixsize(n);
ffffffffc0200eae:	0005041b          	sext.w	s0,a0
    else if (!IS_POWER_OF_2(n)) // 不为2的幂时，向上取
ffffffffc0200eb2:	ebed                	bnez	a5,ffffffffc0200fa4 <buddy_alloc_pages+0x11a>
    if (self[0].longest < size)  // 假设根节点在索引 0
ffffffffc0200eb4:	00005817          	auipc	a6,0x5
ffffffffc0200eb8:	17c80813          	addi	a6,a6,380 # ffffffffc0206030 <root>
ffffffffc0200ebc:	00482783          	lw	a5,4(a6)
ffffffffc0200ec0:	1287e263          	bltu	a5,s0,ffffffffc0200fe4 <buddy_alloc_pages+0x15a>
    for (node_size = self->size; node_size > size; node_size /= 2) {
ffffffffc0200ec4:	00082883          	lw	a7,0(a6)
ffffffffc0200ec8:	11147763          	bgeu	s0,a7,ffffffffc0200fd6 <buddy_alloc_pages+0x14c>
ffffffffc0200ecc:	86c6                	mv	a3,a7
    unsigned index = 0;  
ffffffffc0200ece:	4781                	li	a5,0
        unsigned left_index = LEFT_LEAF(index);
ffffffffc0200ed0:	0017961b          	slliw	a2,a5,0x1
ffffffffc0200ed4:	0016079b          	addiw	a5,a2,1
        if (self[left_index].longest >= size) {
ffffffffc0200ed8:	02079593          	slli	a1,a5,0x20
ffffffffc0200edc:	01d5d713          	srli	a4,a1,0x1d
ffffffffc0200ee0:	9742                	add	a4,a4,a6
ffffffffc0200ee2:	4348                	lw	a0,4(a4)
        unsigned right_index = RIGHT_LEAF(index);
ffffffffc0200ee4:	0026071b          	addiw	a4,a2,2
ffffffffc0200ee8:	0007059b          	sext.w	a1,a4
        if (self[left_index].longest >= size) {
ffffffffc0200eec:	00856a63          	bltu	a0,s0,ffffffffc0200f00 <buddy_alloc_pages+0x76>
            if (self[right_index].longest >= size) {
ffffffffc0200ef0:	1702                	slli	a4,a4,0x20
ffffffffc0200ef2:	8375                	srli	a4,a4,0x1d
ffffffffc0200ef4:	9742                	add	a4,a4,a6
ffffffffc0200ef6:	4358                	lw	a4,4(a4)
ffffffffc0200ef8:	00876763          	bltu	a4,s0,ffffffffc0200f06 <buddy_alloc_pages+0x7c>
                index = (self[left_index].longest <= self[right_index].longest) ? left_index : right_index;
ffffffffc0200efc:	00a77563          	bgeu	a4,a0,ffffffffc0200f06 <buddy_alloc_pages+0x7c>
ffffffffc0200f00:	87ae                	mv	a5,a1
    offset = (index + 1) * node_size - self->size;  
ffffffffc0200f02:	0036059b          	addiw	a1,a2,3
    for (node_size = self->size; node_size > size; node_size /= 2) {
ffffffffc0200f06:	0016d69b          	srliw	a3,a3,0x1
ffffffffc0200f0a:	fcd463e3          	bltu	s0,a3,ffffffffc0200ed0 <buddy_alloc_pages+0x46>
    offset = (index + 1) * node_size - self->size;  
ffffffffc0200f0e:	02b686bb          	mulw	a3,a3,a1
    self[index].longest = 0;
ffffffffc0200f12:	02079613          	slli	a2,a5,0x20
ffffffffc0200f16:	01d65713          	srli	a4,a2,0x1d
ffffffffc0200f1a:	9742                	add	a4,a4,a6
ffffffffc0200f1c:	00072223          	sw	zero,4(a4)
    unsigned long offset = buddy2_alloc(root, n);
ffffffffc0200f20:	411685bb          	subw	a1,a3,a7
    struct Page *page = base+offset; // 找到空闲块的第一页
ffffffffc0200f24:	00259e93          	slli	t4,a1,0x2
ffffffffc0200f28:	9eae                	add	t4,t4,a1
ffffffffc0200f2a:	0e8e                	slli	t4,t4,0x3
ffffffffc0200f2c:	1ea1                	addi	t4,t4,-24
    while (index) {
ffffffffc0200f2e:	c7b1                	beqz	a5,ffffffffc0200f7a <buddy_alloc_pages+0xf0>
        index = PARENT(index);
ffffffffc0200f30:	2785                	addiw	a5,a5,1
ffffffffc0200f32:	0017d61b          	srliw	a2,a5,0x1
ffffffffc0200f36:	367d                	addiw	a2,a2,-1
        self[index].longest = MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc0200f38:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200f3c:	0016169b          	slliw	a3,a2,0x1
ffffffffc0200f40:	2685                	addiw	a3,a3,1
ffffffffc0200f42:	1702                	slli	a4,a4,0x20
ffffffffc0200f44:	02069793          	slli	a5,a3,0x20
ffffffffc0200f48:	9301                	srli	a4,a4,0x20
ffffffffc0200f4a:	01d7d693          	srli	a3,a5,0x1d
ffffffffc0200f4e:	070e                	slli	a4,a4,0x3
ffffffffc0200f50:	9742                	add	a4,a4,a6
ffffffffc0200f52:	96c2                	add	a3,a3,a6
ffffffffc0200f54:	00472883          	lw	a7,4(a4)
ffffffffc0200f58:	42d4                	lw	a3,4(a3)
ffffffffc0200f5a:	02061793          	slli	a5,a2,0x20
ffffffffc0200f5e:	01d7d713          	srli	a4,a5,0x1d
ffffffffc0200f62:	0008831b          	sext.w	t1,a7
ffffffffc0200f66:	00068e1b          	sext.w	t3,a3
        index = PARENT(index);
ffffffffc0200f6a:	0006079b          	sext.w	a5,a2
        self[index].longest = MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc0200f6e:	9742                	add	a4,a4,a6
ffffffffc0200f70:	006e7363          	bgeu	t3,t1,ffffffffc0200f76 <buddy_alloc_pages+0xec>
ffffffffc0200f74:	86c6                	mv	a3,a7
ffffffffc0200f76:	c354                	sw	a3,4(a4)
    while (index) {
ffffffffc0200f78:	ffc5                	bnez	a5,ffffffffc0200f30 <buddy_alloc_pages+0xa6>
    struct Page *page = base+offset; // 找到空闲块的第一页
ffffffffc0200f7a:	0084b903          	ld	s2,8(s1)
    cprintf("alloc page offset %ld\n",offset);
ffffffffc0200f7e:	00001517          	auipc	a0,0x1
ffffffffc0200f82:	29a50513          	addi	a0,a0,666 # ffffffffc0202218 <commands+0x8a8>
    struct Page *page = base+offset; // 找到空闲块的第一页
ffffffffc0200f86:	9976                	add	s2,s2,t4
    cprintf("alloc page offset %ld\n",offset);
ffffffffc0200f88:	92aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    nr_free -= n; // 总的空闲块数减少
ffffffffc0200f8c:	489c                	lw	a5,16(s1)
}
ffffffffc0200f8e:	60e2                	ld	ra,24(sp)
ffffffffc0200f90:	854a                	mv	a0,s2
    nr_free -= n; // 总的空闲块数减少
ffffffffc0200f92:	9f81                	subw	a5,a5,s0
ffffffffc0200f94:	c89c                	sw	a5,16(s1)
    page->property = n; // 记录空闲块的大小
ffffffffc0200f96:	00892823          	sw	s0,16(s2)
}
ffffffffc0200f9a:	6442                	ld	s0,16(sp)
ffffffffc0200f9c:	64a2                	ld	s1,8(sp)
ffffffffc0200f9e:	6902                	ld	s2,0(sp)
ffffffffc0200fa0:	6105                	addi	sp,sp,32
ffffffffc0200fa2:	8082                	ret
  size |= size >> 1;
ffffffffc0200fa4:	0014579b          	srliw	a5,s0,0x1
ffffffffc0200fa8:	8c5d                	or	s0,s0,a5
  size |= size >> 2;
ffffffffc0200faa:	0024579b          	srliw	a5,s0,0x2
ffffffffc0200fae:	8c5d                	or	s0,s0,a5
  size |= size >> 4;
ffffffffc0200fb0:	0044579b          	srliw	a5,s0,0x4
ffffffffc0200fb4:	8c5d                	or	s0,s0,a5
  size |= size >> 8;
ffffffffc0200fb6:	0084579b          	srliw	a5,s0,0x8
ffffffffc0200fba:	8c5d                	or	s0,s0,a5
  size |= size >> 16;
ffffffffc0200fbc:	0104579b          	srliw	a5,s0,0x10
ffffffffc0200fc0:	8c5d                	or	s0,s0,a5
  return size+1;
ffffffffc0200fc2:	2405                	addiw	s0,s0,1
ffffffffc0200fc4:	bdc5                	j	ffffffffc0200eb4 <buddy_alloc_pages+0x2a>
}
ffffffffc0200fc6:	60e2                	ld	ra,24(sp)
ffffffffc0200fc8:	6442                	ld	s0,16(sp)
        return NULL;
ffffffffc0200fca:	4901                	li	s2,0
}
ffffffffc0200fcc:	64a2                	ld	s1,8(sp)
ffffffffc0200fce:	854a                	mv	a0,s2
ffffffffc0200fd0:	6902                	ld	s2,0(sp)
ffffffffc0200fd2:	6105                	addi	sp,sp,32
ffffffffc0200fd4:	8082                	ret
    self[index].longest = 0;
ffffffffc0200fd6:	00005797          	auipc	a5,0x5
ffffffffc0200fda:	0407af23          	sw	zero,94(a5) # ffffffffc0206034 <root+0x4>
ffffffffc0200fde:	5ea1                	li	t4,-24
ffffffffc0200fe0:	4581                	li	a1,0
ffffffffc0200fe2:	bf61                	j	ffffffffc0200f7a <buddy_alloc_pages+0xf0>
ffffffffc0200fe4:	55fd                	li	a1,-1
ffffffffc0200fe6:	fc000e93          	li	t4,-64
ffffffffc0200fea:	bf41                	j	ffffffffc0200f7a <buddy_alloc_pages+0xf0>
    assert(n > 0);
ffffffffc0200fec:	00001697          	auipc	a3,0x1
ffffffffc0200ff0:	22468693          	addi	a3,a3,548 # ffffffffc0202210 <commands+0x8a0>
ffffffffc0200ff4:	00001617          	auipc	a2,0x1
ffffffffc0200ff8:	02c60613          	addi	a2,a2,44 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0200ffc:	09600593          	li	a1,150
ffffffffc0201000:	00001517          	auipc	a0,0x1
ffffffffc0201004:	03850513          	addi	a0,a0,56 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0201008:	932ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc020100c <buddy2_new>:
    if (size < 1 || !IS_POWER_OF_2(size))
ffffffffc020100c:	02a05d63          	blez	a0,ffffffffc0201046 <buddy2_new+0x3a>
ffffffffc0201010:	fff5079b          	addiw	a5,a0,-1
ffffffffc0201014:	8fe9                	and	a5,a5,a0
ffffffffc0201016:	2781                	sext.w	a5,a5
ffffffffc0201018:	e79d                	bnez	a5,ffffffffc0201046 <buddy2_new+0x3a>
    node_size = size * 2;   // 总结点数是size*2
ffffffffc020101a:	0015161b          	slliw	a2,a0,0x1
    root[0].size = size;
ffffffffc020101e:	00005717          	auipc	a4,0x5
ffffffffc0201022:	00a72923          	sw	a0,18(a4) # ffffffffc0206030 <root>
    for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0201026:	fff6059b          	addiw	a1,a2,-1
ffffffffc020102a:	00005697          	auipc	a3,0x5
ffffffffc020102e:	00a68693          	addi	a3,a3,10 # ffffffffc0206034 <root+0x4>
            node_size /= 2;
ffffffffc0201032:	873e                	mv	a4,a5
        if (IS_POWER_OF_2(i+1)) // 下一层
ffffffffc0201034:	2785                	addiw	a5,a5,1
ffffffffc0201036:	8f7d                	and	a4,a4,a5
ffffffffc0201038:	e319                	bnez	a4,ffffffffc020103e <buddy2_new+0x32>
            node_size /= 2;
ffffffffc020103a:	0016561b          	srliw	a2,a2,0x1
        root[i].longest = node_size;   
ffffffffc020103e:	c290                	sw	a2,0(a3)
    for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0201040:	06a1                	addi	a3,a3,8
ffffffffc0201042:	fef598e3          	bne	a1,a5,ffffffffc0201032 <buddy2_new+0x26>
}
ffffffffc0201046:	8082                	ret

ffffffffc0201048 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0201048:	1141                	addi	sp,sp,-16
ffffffffc020104a:	e406                	sd	ra,8(sp)
ffffffffc020104c:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc020104e:	10058c63          	beqz	a1,ffffffffc0201166 <buddy_init_memmap+0x11e>
    for (; p != base + n; p ++) { // 初始化每一页
ffffffffc0201052:	00259693          	slli	a3,a1,0x2
ffffffffc0201056:	96ae                	add	a3,a3,a1
ffffffffc0201058:	068e                	slli	a3,a3,0x3
ffffffffc020105a:	96aa                	add	a3,a3,a0
ffffffffc020105c:	87aa                	mv	a5,a0
ffffffffc020105e:	00d50f63          	beq	a0,a3,ffffffffc020107c <buddy_init_memmap+0x34>
ffffffffc0201062:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201064:	8b05                	andi	a4,a4,1
ffffffffc0201066:	c365                	beqz	a4,ffffffffc0201146 <buddy_init_memmap+0xfe>
        p->flags = p->property = 0;
ffffffffc0201068:	0007a823          	sw	zero,16(a5)
ffffffffc020106c:	0007b423          	sd	zero,8(a5)
ffffffffc0201070:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) { // 初始化每一页
ffffffffc0201074:	02878793          	addi	a5,a5,40
ffffffffc0201078:	fed795e3          	bne	a5,a3,ffffffffc0201062 <buddy_init_memmap+0x1a>
    nr_free += n; // 空闲块总数
ffffffffc020107c:	00005697          	auipc	a3,0x5
ffffffffc0201080:	f9c68693          	addi	a3,a3,-100 # ffffffffc0206018 <free_area>
ffffffffc0201084:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201086:	669c                	ld	a5,8(a3)
    base->property = 0; 
ffffffffc0201088:	00052823          	sw	zero,16(a0)
    nr_free += n; // 空闲块总数
ffffffffc020108c:	9f2d                	addw	a4,a4,a1
ffffffffc020108e:	ca98                	sw	a4,16(a3)
ffffffffc0201090:	0005841b          	sext.w	s0,a1
        list_add(&free_list, &(base->page_link));
ffffffffc0201094:	01850613          	addi	a2,a0,24
    if (list_empty(&free_list)) { 
ffffffffc0201098:	0ad78263          	beq	a5,a3,ffffffffc020113c <buddy_init_memmap+0xf4>
            struct Page* page = le2page(le, page_link); 
ffffffffc020109c:	fe878713          	addi	a4,a5,-24
ffffffffc02010a0:	0006b883          	ld	a7,0(a3)
    if (list_empty(&free_list)) { 
ffffffffc02010a4:	4801                	li	a6,0
            if (base < page) {
ffffffffc02010a6:	00e56a63          	bltu	a0,a4,ffffffffc02010ba <buddy_init_memmap+0x72>
    return listelm->next;
ffffffffc02010aa:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010ac:	02d70f63          	beq	a4,a3,ffffffffc02010ea <buddy_init_memmap+0xa2>
    for (; p != base + n; p ++) { // 初始化每一页
ffffffffc02010b0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link); 
ffffffffc02010b2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010b6:	fee57ae3          	bgeu	a0,a4,ffffffffc02010aa <buddy_init_memmap+0x62>
ffffffffc02010ba:	00080463          	beqz	a6,ffffffffc02010c2 <buddy_init_memmap+0x7a>
ffffffffc02010be:	0116b023          	sd	a7,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010c2:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02010c4:	e390                	sd	a2,0(a5)
ffffffffc02010c6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010c8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010ca:	ed18                	sd	a4,24(a0)
    if(IS_POWER_OF_2(n)) { // 如果是2的幂次方，那么就可以用来初始化树
ffffffffc02010cc:	fff58793          	addi	a5,a1,-1
ffffffffc02010d0:	8dfd                	and	a1,a1,a5
ffffffffc02010d2:	e595                	bnez	a1,ffffffffc02010fe <buddy_init_memmap+0xb6>
        buddy2_new(n);
ffffffffc02010d4:	8522                	mv	a0,s0
ffffffffc02010d6:	f37ff0ef          	jal	ra,ffffffffc020100c <buddy2_new>
}
ffffffffc02010da:	60a2                	ld	ra,8(sp)
    total_size=n;
ffffffffc02010dc:	00053797          	auipc	a5,0x53
ffffffffc02010e0:	5887ae23          	sw	s0,1436(a5) # ffffffffc0254678 <total_size>
}
ffffffffc02010e4:	6402                	ld	s0,0(sp)
ffffffffc02010e6:	0141                	addi	sp,sp,16
ffffffffc02010e8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02010ea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010ec:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02010ee:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010f0:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010f2:	04d70363          	beq	a4,a3,ffffffffc0201138 <buddy_init_memmap+0xf0>
    prev->next = next->prev = elm;
ffffffffc02010f6:	88b2                	mv	a7,a2
ffffffffc02010f8:	4805                	li	a6,1
    for (; p != base + n; p ++) { // 初始化每一页
ffffffffc02010fa:	87ba                	mv	a5,a4
ffffffffc02010fc:	bf5d                	j	ffffffffc02010b2 <buddy_init_memmap+0x6a>
  size |= size >> 1;
ffffffffc02010fe:	0014579b          	srliw	a5,s0,0x1
ffffffffc0201102:	8fc1                	or	a5,a5,s0
  size |= size >> 2;
ffffffffc0201104:	0027d71b          	srliw	a4,a5,0x2
ffffffffc0201108:	8fd9                	or	a5,a5,a4
  size |= size >> 4;
ffffffffc020110a:	0047d71b          	srliw	a4,a5,0x4
ffffffffc020110e:	8fd9                	or	a5,a5,a4
  size |= size >> 8;
ffffffffc0201110:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0201114:	8fd9                	or	a5,a5,a4
  size |= size >> 16;
ffffffffc0201116:	0107d51b          	srliw	a0,a5,0x10
ffffffffc020111a:	8fc9                	or	a5,a5,a0
  return size+1;
ffffffffc020111c:	0017851b          	addiw	a0,a5,1
        buddy2_new(fixsize(n)>>1);
ffffffffc0201120:	0015551b          	srliw	a0,a0,0x1
ffffffffc0201124:	ee9ff0ef          	jal	ra,ffffffffc020100c <buddy2_new>
}
ffffffffc0201128:	60a2                	ld	ra,8(sp)
    total_size=n;
ffffffffc020112a:	00053797          	auipc	a5,0x53
ffffffffc020112e:	5487a723          	sw	s0,1358(a5) # ffffffffc0254678 <total_size>
}
ffffffffc0201132:	6402                	ld	s0,0(sp)
ffffffffc0201134:	0141                	addi	sp,sp,16
ffffffffc0201136:	8082                	ret
ffffffffc0201138:	e290                	sd	a2,0(a3)
ffffffffc020113a:	bf49                	j	ffffffffc02010cc <buddy_init_memmap+0x84>
ffffffffc020113c:	e390                	sd	a2,0(a5)
ffffffffc020113e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201140:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201142:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201144:	b761                	j	ffffffffc02010cc <buddy_init_memmap+0x84>
        assert(PageReserved(p));
ffffffffc0201146:	00001697          	auipc	a3,0x1
ffffffffc020114a:	0ea68693          	addi	a3,a3,234 # ffffffffc0202230 <commands+0x8c0>
ffffffffc020114e:	00001617          	auipc	a2,0x1
ffffffffc0201152:	ed260613          	addi	a2,a2,-302 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0201156:	04800593          	li	a1,72
ffffffffc020115a:	00001517          	auipc	a0,0x1
ffffffffc020115e:	ede50513          	addi	a0,a0,-290 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0201162:	fd9fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0201166:	00001697          	auipc	a3,0x1
ffffffffc020116a:	0aa68693          	addi	a3,a3,170 # ffffffffc0202210 <commands+0x8a0>
ffffffffc020116e:	00001617          	auipc	a2,0x1
ffffffffc0201172:	eb260613          	addi	a2,a2,-334 # ffffffffc0202020 <commands+0x6b0>
ffffffffc0201176:	04500593          	li	a1,69
ffffffffc020117a:	00001517          	auipc	a0,0x1
ffffffffc020117e:	ebe50513          	addi	a0,a0,-322 # ffffffffc0202038 <commands+0x6c8>
ffffffffc0201182:	fb9fe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201186 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201186:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201188:	e589                	bnez	a1,ffffffffc0201192 <strnlen+0xc>
ffffffffc020118a:	a811                	j	ffffffffc020119e <strnlen+0x18>
        cnt ++;
ffffffffc020118c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020118e:	00f58863          	beq	a1,a5,ffffffffc020119e <strnlen+0x18>
ffffffffc0201192:	00f50733          	add	a4,a0,a5
ffffffffc0201196:	00074703          	lbu	a4,0(a4)
ffffffffc020119a:	fb6d                	bnez	a4,ffffffffc020118c <strnlen+0x6>
ffffffffc020119c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020119e:	852e                	mv	a0,a1
ffffffffc02011a0:	8082                	ret

ffffffffc02011a2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02011a2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02011a6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02011aa:	cb89                	beqz	a5,ffffffffc02011bc <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02011ac:	0505                	addi	a0,a0,1
ffffffffc02011ae:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02011b0:	fee789e3          	beq	a5,a4,ffffffffc02011a2 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02011b4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02011b8:	9d19                	subw	a0,a0,a4
ffffffffc02011ba:	8082                	ret
ffffffffc02011bc:	4501                	li	a0,0
ffffffffc02011be:	bfed                	j	ffffffffc02011b8 <strcmp+0x16>

ffffffffc02011c0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02011c0:	00054783          	lbu	a5,0(a0)
ffffffffc02011c4:	c799                	beqz	a5,ffffffffc02011d2 <strchr+0x12>
        if (*s == c) {
ffffffffc02011c6:	00f58763          	beq	a1,a5,ffffffffc02011d4 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02011ca:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02011ce:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02011d0:	fbfd                	bnez	a5,ffffffffc02011c6 <strchr+0x6>
    }
    return NULL;
ffffffffc02011d2:	4501                	li	a0,0
}
ffffffffc02011d4:	8082                	ret

ffffffffc02011d6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02011d6:	ca01                	beqz	a2,ffffffffc02011e6 <memset+0x10>
ffffffffc02011d8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02011da:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02011dc:	0785                	addi	a5,a5,1
ffffffffc02011de:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02011e2:	fec79de3          	bne	a5,a2,ffffffffc02011dc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02011e6:	8082                	ret

ffffffffc02011e8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02011e8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011ec:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02011ee:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011f2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02011f4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011f8:	f022                	sd	s0,32(sp)
ffffffffc02011fa:	ec26                	sd	s1,24(sp)
ffffffffc02011fc:	e84a                	sd	s2,16(sp)
ffffffffc02011fe:	f406                	sd	ra,40(sp)
ffffffffc0201200:	e44e                	sd	s3,8(sp)
ffffffffc0201202:	84aa                	mv	s1,a0
ffffffffc0201204:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201206:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020120a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020120c:	03067e63          	bgeu	a2,a6,ffffffffc0201248 <printnum+0x60>
ffffffffc0201210:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201212:	00805763          	blez	s0,ffffffffc0201220 <printnum+0x38>
ffffffffc0201216:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201218:	85ca                	mv	a1,s2
ffffffffc020121a:	854e                	mv	a0,s3
ffffffffc020121c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020121e:	fc65                	bnez	s0,ffffffffc0201216 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201220:	1a02                	slli	s4,s4,0x20
ffffffffc0201222:	00001797          	auipc	a5,0x1
ffffffffc0201226:	06e78793          	addi	a5,a5,110 # ffffffffc0202290 <buddy_pmm_manager+0x38>
ffffffffc020122a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020122e:	9a3e                	add	s4,s4,a5
}
ffffffffc0201230:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201232:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201236:	70a2                	ld	ra,40(sp)
ffffffffc0201238:	69a2                	ld	s3,8(sp)
ffffffffc020123a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020123c:	85ca                	mv	a1,s2
ffffffffc020123e:	87a6                	mv	a5,s1
}
ffffffffc0201240:	6942                	ld	s2,16(sp)
ffffffffc0201242:	64e2                	ld	s1,24(sp)
ffffffffc0201244:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201246:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201248:	03065633          	divu	a2,a2,a6
ffffffffc020124c:	8722                	mv	a4,s0
ffffffffc020124e:	f9bff0ef          	jal	ra,ffffffffc02011e8 <printnum>
ffffffffc0201252:	b7f9                	j	ffffffffc0201220 <printnum+0x38>

ffffffffc0201254 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201254:	7119                	addi	sp,sp,-128
ffffffffc0201256:	f4a6                	sd	s1,104(sp)
ffffffffc0201258:	f0ca                	sd	s2,96(sp)
ffffffffc020125a:	ecce                	sd	s3,88(sp)
ffffffffc020125c:	e8d2                	sd	s4,80(sp)
ffffffffc020125e:	e4d6                	sd	s5,72(sp)
ffffffffc0201260:	e0da                	sd	s6,64(sp)
ffffffffc0201262:	fc5e                	sd	s7,56(sp)
ffffffffc0201264:	f06a                	sd	s10,32(sp)
ffffffffc0201266:	fc86                	sd	ra,120(sp)
ffffffffc0201268:	f8a2                	sd	s0,112(sp)
ffffffffc020126a:	f862                	sd	s8,48(sp)
ffffffffc020126c:	f466                	sd	s9,40(sp)
ffffffffc020126e:	ec6e                	sd	s11,24(sp)
ffffffffc0201270:	892a                	mv	s2,a0
ffffffffc0201272:	84ae                	mv	s1,a1
ffffffffc0201274:	8d32                	mv	s10,a2
ffffffffc0201276:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201278:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020127c:	5b7d                	li	s6,-1
ffffffffc020127e:	00001a97          	auipc	s5,0x1
ffffffffc0201282:	046a8a93          	addi	s5,s5,70 # ffffffffc02022c4 <buddy_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201286:	00001b97          	auipc	s7,0x1
ffffffffc020128a:	21ab8b93          	addi	s7,s7,538 # ffffffffc02024a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020128e:	000d4503          	lbu	a0,0(s10)
ffffffffc0201292:	001d0413          	addi	s0,s10,1
ffffffffc0201296:	01350a63          	beq	a0,s3,ffffffffc02012aa <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020129a:	c121                	beqz	a0,ffffffffc02012da <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020129c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020129e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02012a0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012a2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02012a6:	ff351ae3          	bne	a0,s3,ffffffffc020129a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012aa:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02012ae:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02012b2:	4c81                	li	s9,0
ffffffffc02012b4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02012b6:	5c7d                	li	s8,-1
ffffffffc02012b8:	5dfd                	li	s11,-1
ffffffffc02012ba:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02012be:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012c0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02012c4:	0ff5f593          	zext.b	a1,a1
ffffffffc02012c8:	00140d13          	addi	s10,s0,1
ffffffffc02012cc:	04b56263          	bltu	a0,a1,ffffffffc0201310 <vprintfmt+0xbc>
ffffffffc02012d0:	058a                	slli	a1,a1,0x2
ffffffffc02012d2:	95d6                	add	a1,a1,s5
ffffffffc02012d4:	4194                	lw	a3,0(a1)
ffffffffc02012d6:	96d6                	add	a3,a3,s5
ffffffffc02012d8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02012da:	70e6                	ld	ra,120(sp)
ffffffffc02012dc:	7446                	ld	s0,112(sp)
ffffffffc02012de:	74a6                	ld	s1,104(sp)
ffffffffc02012e0:	7906                	ld	s2,96(sp)
ffffffffc02012e2:	69e6                	ld	s3,88(sp)
ffffffffc02012e4:	6a46                	ld	s4,80(sp)
ffffffffc02012e6:	6aa6                	ld	s5,72(sp)
ffffffffc02012e8:	6b06                	ld	s6,64(sp)
ffffffffc02012ea:	7be2                	ld	s7,56(sp)
ffffffffc02012ec:	7c42                	ld	s8,48(sp)
ffffffffc02012ee:	7ca2                	ld	s9,40(sp)
ffffffffc02012f0:	7d02                	ld	s10,32(sp)
ffffffffc02012f2:	6de2                	ld	s11,24(sp)
ffffffffc02012f4:	6109                	addi	sp,sp,128
ffffffffc02012f6:	8082                	ret
            padc = '0';
ffffffffc02012f8:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02012fa:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012fe:	846a                	mv	s0,s10
ffffffffc0201300:	00140d13          	addi	s10,s0,1
ffffffffc0201304:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201308:	0ff5f593          	zext.b	a1,a1
ffffffffc020130c:	fcb572e3          	bgeu	a0,a1,ffffffffc02012d0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201310:	85a6                	mv	a1,s1
ffffffffc0201312:	02500513          	li	a0,37
ffffffffc0201316:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201318:	fff44783          	lbu	a5,-1(s0)
ffffffffc020131c:	8d22                	mv	s10,s0
ffffffffc020131e:	f73788e3          	beq	a5,s3,ffffffffc020128e <vprintfmt+0x3a>
ffffffffc0201322:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201326:	1d7d                	addi	s10,s10,-1
ffffffffc0201328:	ff379de3          	bne	a5,s3,ffffffffc0201322 <vprintfmt+0xce>
ffffffffc020132c:	b78d                	j	ffffffffc020128e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020132e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201332:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201336:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201338:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020133c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201340:	02d86463          	bltu	a6,a3,ffffffffc0201368 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201344:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201348:	002c169b          	slliw	a3,s8,0x2
ffffffffc020134c:	0186873b          	addw	a4,a3,s8
ffffffffc0201350:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201354:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201356:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020135a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020135c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201360:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201364:	fed870e3          	bgeu	a6,a3,ffffffffc0201344 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201368:	f40ddce3          	bgez	s11,ffffffffc02012c0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020136c:	8de2                	mv	s11,s8
ffffffffc020136e:	5c7d                	li	s8,-1
ffffffffc0201370:	bf81                	j	ffffffffc02012c0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201372:	fffdc693          	not	a3,s11
ffffffffc0201376:	96fd                	srai	a3,a3,0x3f
ffffffffc0201378:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020137c:	00144603          	lbu	a2,1(s0)
ffffffffc0201380:	2d81                	sext.w	s11,s11
ffffffffc0201382:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201384:	bf35                	j	ffffffffc02012c0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201386:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020138a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020138e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201390:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201392:	bfd9                	j	ffffffffc0201368 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201394:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201396:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020139a:	01174463          	blt	a4,a7,ffffffffc02013a2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020139e:	1a088e63          	beqz	a7,ffffffffc020155a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02013a2:	000a3603          	ld	a2,0(s4)
ffffffffc02013a6:	46c1                	li	a3,16
ffffffffc02013a8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02013aa:	2781                	sext.w	a5,a5
ffffffffc02013ac:	876e                	mv	a4,s11
ffffffffc02013ae:	85a6                	mv	a1,s1
ffffffffc02013b0:	854a                	mv	a0,s2
ffffffffc02013b2:	e37ff0ef          	jal	ra,ffffffffc02011e8 <printnum>
            break;
ffffffffc02013b6:	bde1                	j	ffffffffc020128e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02013b8:	000a2503          	lw	a0,0(s4)
ffffffffc02013bc:	85a6                	mv	a1,s1
ffffffffc02013be:	0a21                	addi	s4,s4,8
ffffffffc02013c0:	9902                	jalr	s2
            break;
ffffffffc02013c2:	b5f1                	j	ffffffffc020128e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013c4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013c6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02013ca:	01174463          	blt	a4,a7,ffffffffc02013d2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02013ce:	18088163          	beqz	a7,ffffffffc0201550 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02013d2:	000a3603          	ld	a2,0(s4)
ffffffffc02013d6:	46a9                	li	a3,10
ffffffffc02013d8:	8a2e                	mv	s4,a1
ffffffffc02013da:	bfc1                	j	ffffffffc02013aa <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013dc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02013e0:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013e2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013e4:	bdf1                	j	ffffffffc02012c0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02013e6:	85a6                	mv	a1,s1
ffffffffc02013e8:	02500513          	li	a0,37
ffffffffc02013ec:	9902                	jalr	s2
            break;
ffffffffc02013ee:	b545                	j	ffffffffc020128e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013f0:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02013f4:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013f6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013f8:	b5e1                	j	ffffffffc02012c0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02013fa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013fc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201400:	01174463          	blt	a4,a7,ffffffffc0201408 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201404:	14088163          	beqz	a7,ffffffffc0201546 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201408:	000a3603          	ld	a2,0(s4)
ffffffffc020140c:	46a1                	li	a3,8
ffffffffc020140e:	8a2e                	mv	s4,a1
ffffffffc0201410:	bf69                	j	ffffffffc02013aa <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201412:	03000513          	li	a0,48
ffffffffc0201416:	85a6                	mv	a1,s1
ffffffffc0201418:	e03e                	sd	a5,0(sp)
ffffffffc020141a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020141c:	85a6                	mv	a1,s1
ffffffffc020141e:	07800513          	li	a0,120
ffffffffc0201422:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201424:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201426:	6782                	ld	a5,0(sp)
ffffffffc0201428:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020142a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020142e:	bfb5                	j	ffffffffc02013aa <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201430:	000a3403          	ld	s0,0(s4)
ffffffffc0201434:	008a0713          	addi	a4,s4,8
ffffffffc0201438:	e03a                	sd	a4,0(sp)
ffffffffc020143a:	14040263          	beqz	s0,ffffffffc020157e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020143e:	0fb05763          	blez	s11,ffffffffc020152c <vprintfmt+0x2d8>
ffffffffc0201442:	02d00693          	li	a3,45
ffffffffc0201446:	0cd79163          	bne	a5,a3,ffffffffc0201508 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020144a:	00044783          	lbu	a5,0(s0)
ffffffffc020144e:	0007851b          	sext.w	a0,a5
ffffffffc0201452:	cf85                	beqz	a5,ffffffffc020148a <vprintfmt+0x236>
ffffffffc0201454:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201458:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020145c:	000c4563          	bltz	s8,ffffffffc0201466 <vprintfmt+0x212>
ffffffffc0201460:	3c7d                	addiw	s8,s8,-1
ffffffffc0201462:	036c0263          	beq	s8,s6,ffffffffc0201486 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201466:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201468:	0e0c8e63          	beqz	s9,ffffffffc0201564 <vprintfmt+0x310>
ffffffffc020146c:	3781                	addiw	a5,a5,-32
ffffffffc020146e:	0ef47b63          	bgeu	s0,a5,ffffffffc0201564 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201472:	03f00513          	li	a0,63
ffffffffc0201476:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201478:	000a4783          	lbu	a5,0(s4)
ffffffffc020147c:	3dfd                	addiw	s11,s11,-1
ffffffffc020147e:	0a05                	addi	s4,s4,1
ffffffffc0201480:	0007851b          	sext.w	a0,a5
ffffffffc0201484:	ffe1                	bnez	a5,ffffffffc020145c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201486:	01b05963          	blez	s11,ffffffffc0201498 <vprintfmt+0x244>
ffffffffc020148a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020148c:	85a6                	mv	a1,s1
ffffffffc020148e:	02000513          	li	a0,32
ffffffffc0201492:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201494:	fe0d9be3          	bnez	s11,ffffffffc020148a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201498:	6a02                	ld	s4,0(sp)
ffffffffc020149a:	bbd5                	j	ffffffffc020128e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020149c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020149e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02014a2:	01174463          	blt	a4,a7,ffffffffc02014aa <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02014a6:	08088d63          	beqz	a7,ffffffffc0201540 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02014aa:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02014ae:	0a044d63          	bltz	s0,ffffffffc0201568 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02014b2:	8622                	mv	a2,s0
ffffffffc02014b4:	8a66                	mv	s4,s9
ffffffffc02014b6:	46a9                	li	a3,10
ffffffffc02014b8:	bdcd                	j	ffffffffc02013aa <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02014ba:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014be:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014c0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02014c2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014c6:	8fb5                	xor	a5,a5,a3
ffffffffc02014c8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014cc:	02d74163          	blt	a4,a3,ffffffffc02014ee <vprintfmt+0x29a>
ffffffffc02014d0:	00369793          	slli	a5,a3,0x3
ffffffffc02014d4:	97de                	add	a5,a5,s7
ffffffffc02014d6:	639c                	ld	a5,0(a5)
ffffffffc02014d8:	cb99                	beqz	a5,ffffffffc02014ee <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014da:	86be                	mv	a3,a5
ffffffffc02014dc:	00001617          	auipc	a2,0x1
ffffffffc02014e0:	de460613          	addi	a2,a2,-540 # ffffffffc02022c0 <buddy_pmm_manager+0x68>
ffffffffc02014e4:	85a6                	mv	a1,s1
ffffffffc02014e6:	854a                	mv	a0,s2
ffffffffc02014e8:	0ce000ef          	jal	ra,ffffffffc02015b6 <printfmt>
ffffffffc02014ec:	b34d                	j	ffffffffc020128e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02014ee:	00001617          	auipc	a2,0x1
ffffffffc02014f2:	dc260613          	addi	a2,a2,-574 # ffffffffc02022b0 <buddy_pmm_manager+0x58>
ffffffffc02014f6:	85a6                	mv	a1,s1
ffffffffc02014f8:	854a                	mv	a0,s2
ffffffffc02014fa:	0bc000ef          	jal	ra,ffffffffc02015b6 <printfmt>
ffffffffc02014fe:	bb41                	j	ffffffffc020128e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201500:	00001417          	auipc	s0,0x1
ffffffffc0201504:	da840413          	addi	s0,s0,-600 # ffffffffc02022a8 <buddy_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201508:	85e2                	mv	a1,s8
ffffffffc020150a:	8522                	mv	a0,s0
ffffffffc020150c:	e43e                	sd	a5,8(sp)
ffffffffc020150e:	c79ff0ef          	jal	ra,ffffffffc0201186 <strnlen>
ffffffffc0201512:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201516:	01b05b63          	blez	s11,ffffffffc020152c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020151a:	67a2                	ld	a5,8(sp)
ffffffffc020151c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201520:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201522:	85a6                	mv	a1,s1
ffffffffc0201524:	8552                	mv	a0,s4
ffffffffc0201526:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201528:	fe0d9ce3          	bnez	s11,ffffffffc0201520 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020152c:	00044783          	lbu	a5,0(s0)
ffffffffc0201530:	00140a13          	addi	s4,s0,1
ffffffffc0201534:	0007851b          	sext.w	a0,a5
ffffffffc0201538:	d3a5                	beqz	a5,ffffffffc0201498 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020153a:	05e00413          	li	s0,94
ffffffffc020153e:	bf39                	j	ffffffffc020145c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201540:	000a2403          	lw	s0,0(s4)
ffffffffc0201544:	b7ad                	j	ffffffffc02014ae <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201546:	000a6603          	lwu	a2,0(s4)
ffffffffc020154a:	46a1                	li	a3,8
ffffffffc020154c:	8a2e                	mv	s4,a1
ffffffffc020154e:	bdb1                	j	ffffffffc02013aa <vprintfmt+0x156>
ffffffffc0201550:	000a6603          	lwu	a2,0(s4)
ffffffffc0201554:	46a9                	li	a3,10
ffffffffc0201556:	8a2e                	mv	s4,a1
ffffffffc0201558:	bd89                	j	ffffffffc02013aa <vprintfmt+0x156>
ffffffffc020155a:	000a6603          	lwu	a2,0(s4)
ffffffffc020155e:	46c1                	li	a3,16
ffffffffc0201560:	8a2e                	mv	s4,a1
ffffffffc0201562:	b5a1                	j	ffffffffc02013aa <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201564:	9902                	jalr	s2
ffffffffc0201566:	bf09                	j	ffffffffc0201478 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201568:	85a6                	mv	a1,s1
ffffffffc020156a:	02d00513          	li	a0,45
ffffffffc020156e:	e03e                	sd	a5,0(sp)
ffffffffc0201570:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201572:	6782                	ld	a5,0(sp)
ffffffffc0201574:	8a66                	mv	s4,s9
ffffffffc0201576:	40800633          	neg	a2,s0
ffffffffc020157a:	46a9                	li	a3,10
ffffffffc020157c:	b53d                	j	ffffffffc02013aa <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020157e:	03b05163          	blez	s11,ffffffffc02015a0 <vprintfmt+0x34c>
ffffffffc0201582:	02d00693          	li	a3,45
ffffffffc0201586:	f6d79de3          	bne	a5,a3,ffffffffc0201500 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020158a:	00001417          	auipc	s0,0x1
ffffffffc020158e:	d1e40413          	addi	s0,s0,-738 # ffffffffc02022a8 <buddy_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201592:	02800793          	li	a5,40
ffffffffc0201596:	02800513          	li	a0,40
ffffffffc020159a:	00140a13          	addi	s4,s0,1
ffffffffc020159e:	bd6d                	j	ffffffffc0201458 <vprintfmt+0x204>
ffffffffc02015a0:	00001a17          	auipc	s4,0x1
ffffffffc02015a4:	d09a0a13          	addi	s4,s4,-759 # ffffffffc02022a9 <buddy_pmm_manager+0x51>
ffffffffc02015a8:	02800513          	li	a0,40
ffffffffc02015ac:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015b0:	05e00413          	li	s0,94
ffffffffc02015b4:	b565                	j	ffffffffc020145c <vprintfmt+0x208>

ffffffffc02015b6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015b6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02015b8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015bc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015be:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015c0:	ec06                	sd	ra,24(sp)
ffffffffc02015c2:	f83a                	sd	a4,48(sp)
ffffffffc02015c4:	fc3e                	sd	a5,56(sp)
ffffffffc02015c6:	e0c2                	sd	a6,64(sp)
ffffffffc02015c8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02015ca:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015cc:	c89ff0ef          	jal	ra,ffffffffc0201254 <vprintfmt>
}
ffffffffc02015d0:	60e2                	ld	ra,24(sp)
ffffffffc02015d2:	6161                	addi	sp,sp,80
ffffffffc02015d4:	8082                	ret

ffffffffc02015d6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02015d6:	715d                	addi	sp,sp,-80
ffffffffc02015d8:	e486                	sd	ra,72(sp)
ffffffffc02015da:	e0a6                	sd	s1,64(sp)
ffffffffc02015dc:	fc4a                	sd	s2,56(sp)
ffffffffc02015de:	f84e                	sd	s3,48(sp)
ffffffffc02015e0:	f452                	sd	s4,40(sp)
ffffffffc02015e2:	f056                	sd	s5,32(sp)
ffffffffc02015e4:	ec5a                	sd	s6,24(sp)
ffffffffc02015e6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02015e8:	c901                	beqz	a0,ffffffffc02015f8 <readline+0x22>
ffffffffc02015ea:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02015ec:	00001517          	auipc	a0,0x1
ffffffffc02015f0:	cd450513          	addi	a0,a0,-812 # ffffffffc02022c0 <buddy_pmm_manager+0x68>
ffffffffc02015f4:	abffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc02015f8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02015fa:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02015fc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02015fe:	4aa9                	li	s5,10
ffffffffc0201600:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201602:	00053b97          	auipc	s7,0x53
ffffffffc0201606:	c2eb8b93          	addi	s7,s7,-978 # ffffffffc0254230 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020160a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020160e:	b1dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201612:	00054a63          	bltz	a0,ffffffffc0201626 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201616:	00a95a63          	bge	s2,a0,ffffffffc020162a <readline+0x54>
ffffffffc020161a:	029a5263          	bge	s4,s1,ffffffffc020163e <readline+0x68>
        c = getchar();
ffffffffc020161e:	b0dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201622:	fe055ae3          	bgez	a0,ffffffffc0201616 <readline+0x40>
            return NULL;
ffffffffc0201626:	4501                	li	a0,0
ffffffffc0201628:	a091                	j	ffffffffc020166c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020162a:	03351463          	bne	a0,s3,ffffffffc0201652 <readline+0x7c>
ffffffffc020162e:	e8a9                	bnez	s1,ffffffffc0201680 <readline+0xaa>
        c = getchar();
ffffffffc0201630:	afbfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201634:	fe0549e3          	bltz	a0,ffffffffc0201626 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201638:	fea959e3          	bge	s2,a0,ffffffffc020162a <readline+0x54>
ffffffffc020163c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020163e:	e42a                	sd	a0,8(sp)
ffffffffc0201640:	aa9fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201644:	6522                	ld	a0,8(sp)
ffffffffc0201646:	009b87b3          	add	a5,s7,s1
ffffffffc020164a:	2485                	addiw	s1,s1,1
ffffffffc020164c:	00a78023          	sb	a0,0(a5)
ffffffffc0201650:	bf7d                	j	ffffffffc020160e <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201652:	01550463          	beq	a0,s5,ffffffffc020165a <readline+0x84>
ffffffffc0201656:	fb651ce3          	bne	a0,s6,ffffffffc020160e <readline+0x38>
            cputchar(c);
ffffffffc020165a:	a8ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020165e:	00053517          	auipc	a0,0x53
ffffffffc0201662:	bd250513          	addi	a0,a0,-1070 # ffffffffc0254230 <buf>
ffffffffc0201666:	94aa                	add	s1,s1,a0
ffffffffc0201668:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020166c:	60a6                	ld	ra,72(sp)
ffffffffc020166e:	6486                	ld	s1,64(sp)
ffffffffc0201670:	7962                	ld	s2,56(sp)
ffffffffc0201672:	79c2                	ld	s3,48(sp)
ffffffffc0201674:	7a22                	ld	s4,40(sp)
ffffffffc0201676:	7a82                	ld	s5,32(sp)
ffffffffc0201678:	6b62                	ld	s6,24(sp)
ffffffffc020167a:	6bc2                	ld	s7,16(sp)
ffffffffc020167c:	6161                	addi	sp,sp,80
ffffffffc020167e:	8082                	ret
            cputchar(c);
ffffffffc0201680:	4521                	li	a0,8
ffffffffc0201682:	a67fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201686:	34fd                	addiw	s1,s1,-1
ffffffffc0201688:	b759                	j	ffffffffc020160e <readline+0x38>

ffffffffc020168a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020168a:	4781                	li	a5,0
ffffffffc020168c:	00005717          	auipc	a4,0x5
ffffffffc0201690:	97c73703          	ld	a4,-1668(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201694:	88ba                	mv	a7,a4
ffffffffc0201696:	852a                	mv	a0,a0
ffffffffc0201698:	85be                	mv	a1,a5
ffffffffc020169a:	863e                	mv	a2,a5
ffffffffc020169c:	00000073          	ecall
ffffffffc02016a0:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02016a2:	8082                	ret

ffffffffc02016a4 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02016a4:	4781                	li	a5,0
ffffffffc02016a6:	00053717          	auipc	a4,0x53
ffffffffc02016aa:	fda73703          	ld	a4,-38(a4) # ffffffffc0254680 <SBI_SET_TIMER>
ffffffffc02016ae:	88ba                	mv	a7,a4
ffffffffc02016b0:	852a                	mv	a0,a0
ffffffffc02016b2:	85be                	mv	a1,a5
ffffffffc02016b4:	863e                	mv	a2,a5
ffffffffc02016b6:	00000073          	ecall
ffffffffc02016ba:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02016bc:	8082                	ret

ffffffffc02016be <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02016be:	4501                	li	a0,0
ffffffffc02016c0:	00005797          	auipc	a5,0x5
ffffffffc02016c4:	9407b783          	ld	a5,-1728(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02016c8:	88be                	mv	a7,a5
ffffffffc02016ca:	852a                	mv	a0,a0
ffffffffc02016cc:	85aa                	mv	a1,a0
ffffffffc02016ce:	862a                	mv	a2,a0
ffffffffc02016d0:	00000073          	ecall
ffffffffc02016d4:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc02016d6:	2501                	sext.w	a0,a0
ffffffffc02016d8:	8082                	ret

ffffffffc02016da <sbi_shutdown>:
    __asm__ volatile (
ffffffffc02016da:	4781                	li	a5,0
ffffffffc02016dc:	00005717          	auipc	a4,0x5
ffffffffc02016e0:	93473703          	ld	a4,-1740(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc02016e4:	88ba                	mv	a7,a4
ffffffffc02016e6:	853e                	mv	a0,a5
ffffffffc02016e8:	85be                	mv	a1,a5
ffffffffc02016ea:	863e                	mv	a2,a5
ffffffffc02016ec:	00000073          	ecall
ffffffffc02016f0:	87aa                	mv	a5,a0

void sbi_shutdown(void) {
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc02016f2:	8082                	ret
