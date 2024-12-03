
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
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020a060 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	59260613          	addi	a2,a2,1426 # ffffffffc02155cc <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	1d7040ef          	jal	ra,ffffffffc0204a20 <memset>

    cons_init();                // init the console
ffffffffc020004e:	4fc000ef          	jal	ra,ffffffffc020054a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	e2658593          	addi	a1,a1,-474 # ffffffffc0204e78 <etext+0x6>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	e3e50513          	addi	a0,a0,-450 # ffffffffc0204e98 <etext+0x26>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	1be000ef          	jal	ra,ffffffffc0200224 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	3fc030ef          	jal	ra,ffffffffc0203466 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	54e000ef          	jal	ra,ffffffffc02005bc <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	4d5000ef          	jal	ra,ffffffffc0200d4a <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	5fa040ef          	jal	ra,ffffffffc0204674 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	424000ef          	jal	ra,ffffffffc02004a2 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	35b010ef          	jal	ra,ffffffffc0201bdc <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	472000ef          	jal	ra,ffffffffc02004f8 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	534000ef          	jal	ra,ffffffffc02005be <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	035040ef          	jal	ra,ffffffffc02048c2 <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	4b2000ef          	jal	ra,ffffffffc020054c <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	21b040ef          	jal	ra,ffffffffc0204ada <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	1e5040ef          	jal	ra,ffffffffc0204ada <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a1a9                	j	ffffffffc020054c <cons_putc>

ffffffffc0200104 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200104:	1141                	addi	sp,sp,-16
ffffffffc0200106:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200108:	478000ef          	jal	ra,ffffffffc0200580 <cons_getc>
ffffffffc020010c:	dd75                	beqz	a0,ffffffffc0200108 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020010e:	60a2                	ld	ra,8(sp)
ffffffffc0200110:	0141                	addi	sp,sp,16
ffffffffc0200112:	8082                	ret

ffffffffc0200114 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200114:	715d                	addi	sp,sp,-80
ffffffffc0200116:	e486                	sd	ra,72(sp)
ffffffffc0200118:	e0a6                	sd	s1,64(sp)
ffffffffc020011a:	fc4a                	sd	s2,56(sp)
ffffffffc020011c:	f84e                	sd	s3,48(sp)
ffffffffc020011e:	f452                	sd	s4,40(sp)
ffffffffc0200120:	f056                	sd	s5,32(sp)
ffffffffc0200122:	ec5a                	sd	s6,24(sp)
ffffffffc0200124:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200126:	c901                	beqz	a0,ffffffffc0200136 <readline+0x22>
ffffffffc0200128:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020012a:	00005517          	auipc	a0,0x5
ffffffffc020012e:	d7650513          	addi	a0,a0,-650 # ffffffffc0204ea0 <etext+0x2e>
ffffffffc0200132:	f9bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200136:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200138:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020013a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020013c:	4aa9                	li	s5,10
ffffffffc020013e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200140:	0000ab97          	auipc	s7,0xa
ffffffffc0200144:	f20b8b93          	addi	s7,s7,-224 # ffffffffc020a060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200148:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020014c:	fb9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200150:	00054a63          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200154:	00a95a63          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc0200158:	029a5263          	bge	s4,s1,ffffffffc020017c <readline+0x68>
        c = getchar();
ffffffffc020015c:	fa9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200160:	fe055ae3          	bgez	a0,ffffffffc0200154 <readline+0x40>
            return NULL;
ffffffffc0200164:	4501                	li	a0,0
ffffffffc0200166:	a091                	j	ffffffffc02001aa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0200168:	03351463          	bne	a0,s3,ffffffffc0200190 <readline+0x7c>
ffffffffc020016c:	e8a9                	bnez	s1,ffffffffc02001be <readline+0xaa>
        c = getchar();
ffffffffc020016e:	f97ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200172:	fe0549e3          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200176:	fea959e3          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc020017a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020017c:	e42a                	sd	a0,8(sp)
ffffffffc020017e:	f85ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc0200182:	6522                	ld	a0,8(sp)
ffffffffc0200184:	009b87b3          	add	a5,s7,s1
ffffffffc0200188:	2485                	addiw	s1,s1,1
ffffffffc020018a:	00a78023          	sb	a0,0(a5)
ffffffffc020018e:	bf7d                	j	ffffffffc020014c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200190:	01550463          	beq	a0,s5,ffffffffc0200198 <readline+0x84>
ffffffffc0200194:	fb651ce3          	bne	a0,s6,ffffffffc020014c <readline+0x38>
            cputchar(c);
ffffffffc0200198:	f6bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc020019c:	0000a517          	auipc	a0,0xa
ffffffffc02001a0:	ec450513          	addi	a0,a0,-316 # ffffffffc020a060 <buf>
ffffffffc02001a4:	94aa                	add	s1,s1,a0
ffffffffc02001a6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001aa:	60a6                	ld	ra,72(sp)
ffffffffc02001ac:	6486                	ld	s1,64(sp)
ffffffffc02001ae:	7962                	ld	s2,56(sp)
ffffffffc02001b0:	79c2                	ld	s3,48(sp)
ffffffffc02001b2:	7a22                	ld	s4,40(sp)
ffffffffc02001b4:	7a82                	ld	s5,32(sp)
ffffffffc02001b6:	6b62                	ld	s6,24(sp)
ffffffffc02001b8:	6bc2                	ld	s7,16(sp)
ffffffffc02001ba:	6161                	addi	sp,sp,80
ffffffffc02001bc:	8082                	ret
            cputchar(c);
ffffffffc02001be:	4521                	li	a0,8
ffffffffc02001c0:	f43ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc02001c4:	34fd                	addiw	s1,s1,-1
ffffffffc02001c6:	b759                	j	ffffffffc020014c <readline+0x38>

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00015317          	auipc	t1,0x15
ffffffffc02001cc:	37030313          	addi	t1,t1,880 # ffffffffc0215538 <is_panic>
ffffffffc02001d0:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d4:	715d                	addi	sp,sp,-80
ffffffffc02001d6:	ec06                	sd	ra,24(sp)
ffffffffc02001d8:	e822                	sd	s0,16(sp)
ffffffffc02001da:	f436                	sd	a3,40(sp)
ffffffffc02001dc:	f83a                	sd	a4,48(sp)
ffffffffc02001de:	fc3e                	sd	a5,56(sp)
ffffffffc02001e0:	e0c2                	sd	a6,64(sp)
ffffffffc02001e2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001e4:	020e1a63          	bnez	t3,ffffffffc0200218 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001e8:	4785                	li	a5,1
ffffffffc02001ea:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02001ee:	8432                	mv	s0,a2
ffffffffc02001f0:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f2:	862e                	mv	a2,a1
ffffffffc02001f4:	85aa                	mv	a1,a0
ffffffffc02001f6:	00005517          	auipc	a0,0x5
ffffffffc02001fa:	cb250513          	addi	a0,a0,-846 # ffffffffc0204ea8 <etext+0x36>
    va_start(ap, fmt);
ffffffffc02001fe:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200200:	ecdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200204:	65a2                	ld	a1,8(sp)
ffffffffc0200206:	8522                	mv	a0,s0
ffffffffc0200208:	ea5ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020020c:	00006517          	auipc	a0,0x6
ffffffffc0200210:	72c50513          	addi	a0,a0,1836 # ffffffffc0206938 <default_pmm_manager+0x3b8>
ffffffffc0200214:	eb9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200218:	3ac000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	130000ef          	jal	ra,ffffffffc020034e <kmonitor>
    while (1) {
ffffffffc0200222:	bfed                	j	ffffffffc020021c <__panic+0x54>

ffffffffc0200224 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	00005517          	auipc	a0,0x5
ffffffffc020022a:	ca250513          	addi	a0,a0,-862 # ffffffffc0204ec8 <etext+0x56>
void print_kerninfo(void) {
ffffffffc020022e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200230:	e9dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200234:	00000597          	auipc	a1,0x0
ffffffffc0200238:	dfe58593          	addi	a1,a1,-514 # ffffffffc0200032 <kern_init>
ffffffffc020023c:	00005517          	auipc	a0,0x5
ffffffffc0200240:	cac50513          	addi	a0,a0,-852 # ffffffffc0204ee8 <etext+0x76>
ffffffffc0200244:	e89ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200248:	00005597          	auipc	a1,0x5
ffffffffc020024c:	c2a58593          	addi	a1,a1,-982 # ffffffffc0204e72 <etext>
ffffffffc0200250:	00005517          	auipc	a0,0x5
ffffffffc0200254:	cb850513          	addi	a0,a0,-840 # ffffffffc0204f08 <etext+0x96>
ffffffffc0200258:	e75ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025c:	0000a597          	auipc	a1,0xa
ffffffffc0200260:	e0458593          	addi	a1,a1,-508 # ffffffffc020a060 <buf>
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	cc450513          	addi	a0,a0,-828 # ffffffffc0204f28 <etext+0xb6>
ffffffffc020026c:	e61ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200270:	00015597          	auipc	a1,0x15
ffffffffc0200274:	35c58593          	addi	a1,a1,860 # ffffffffc02155cc <end>
ffffffffc0200278:	00005517          	auipc	a0,0x5
ffffffffc020027c:	cd050513          	addi	a0,a0,-816 # ffffffffc0204f48 <etext+0xd6>
ffffffffc0200280:	e4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200284:	00015597          	auipc	a1,0x15
ffffffffc0200288:	74758593          	addi	a1,a1,1863 # ffffffffc02159cb <end+0x3ff>
ffffffffc020028c:	00000797          	auipc	a5,0x0
ffffffffc0200290:	da678793          	addi	a5,a5,-602 # ffffffffc0200032 <kern_init>
ffffffffc0200294:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a2:	95be                	add	a1,a1,a5
ffffffffc02002a4:	85a9                	srai	a1,a1,0xa
ffffffffc02002a6:	00005517          	auipc	a0,0x5
ffffffffc02002aa:	cc250513          	addi	a0,a0,-830 # ffffffffc0204f68 <etext+0xf6>
}
ffffffffc02002ae:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	bd31                	j	ffffffffc02000cc <cprintf>

ffffffffc02002b2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b4:	00005617          	auipc	a2,0x5
ffffffffc02002b8:	ce460613          	addi	a2,a2,-796 # ffffffffc0204f98 <etext+0x126>
ffffffffc02002bc:	04d00593          	li	a1,77
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	cf050513          	addi	a0,a0,-784 # ffffffffc0204fb0 <etext+0x13e>
void print_stackframe(void) {
ffffffffc02002c8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ca:	effff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02002ce <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ce:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d0:	00005617          	auipc	a2,0x5
ffffffffc02002d4:	cf860613          	addi	a2,a2,-776 # ffffffffc0204fc8 <etext+0x156>
ffffffffc02002d8:	00005597          	auipc	a1,0x5
ffffffffc02002dc:	d1058593          	addi	a1,a1,-752 # ffffffffc0204fe8 <etext+0x176>
ffffffffc02002e0:	00005517          	auipc	a0,0x5
ffffffffc02002e4:	d1050513          	addi	a0,a0,-752 # ffffffffc0204ff0 <etext+0x17e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	de3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02002ee:	00005617          	auipc	a2,0x5
ffffffffc02002f2:	d1260613          	addi	a2,a2,-750 # ffffffffc0205000 <etext+0x18e>
ffffffffc02002f6:	00005597          	auipc	a1,0x5
ffffffffc02002fa:	d3258593          	addi	a1,a1,-718 # ffffffffc0205028 <etext+0x1b6>
ffffffffc02002fe:	00005517          	auipc	a0,0x5
ffffffffc0200302:	cf250513          	addi	a0,a0,-782 # ffffffffc0204ff0 <etext+0x17e>
ffffffffc0200306:	dc7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020030a:	00005617          	auipc	a2,0x5
ffffffffc020030e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0205038 <etext+0x1c6>
ffffffffc0200312:	00005597          	auipc	a1,0x5
ffffffffc0200316:	d4658593          	addi	a1,a1,-698 # ffffffffc0205058 <etext+0x1e6>
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	cd650513          	addi	a0,a0,-810 # ffffffffc0204ff0 <etext+0x17e>
ffffffffc0200322:	dabff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200332:	ef3ff0ef          	jal	ra,ffffffffc0200224 <print_kerninfo>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033e:	1141                	addi	sp,sp,-16
ffffffffc0200340:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200342:	f71ff0ef          	jal	ra,ffffffffc02002b2 <print_stackframe>
    return 0;
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
ffffffffc0200348:	4501                	li	a0,0
ffffffffc020034a:	0141                	addi	sp,sp,16
ffffffffc020034c:	8082                	ret

ffffffffc020034e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020034e:	7115                	addi	sp,sp,-224
ffffffffc0200350:	ed5e                	sd	s7,152(sp)
ffffffffc0200352:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200354:	00005517          	auipc	a0,0x5
ffffffffc0200358:	d1450513          	addi	a0,a0,-748 # ffffffffc0205068 <etext+0x1f6>
kmonitor(struct trapframe *tf) {
ffffffffc020035c:	ed86                	sd	ra,216(sp)
ffffffffc020035e:	e9a2                	sd	s0,208(sp)
ffffffffc0200360:	e5a6                	sd	s1,200(sp)
ffffffffc0200362:	e1ca                	sd	s2,192(sp)
ffffffffc0200364:	fd4e                	sd	s3,184(sp)
ffffffffc0200366:	f952                	sd	s4,176(sp)
ffffffffc0200368:	f556                	sd	s5,168(sp)
ffffffffc020036a:	f15a                	sd	s6,160(sp)
ffffffffc020036c:	e962                	sd	s8,144(sp)
ffffffffc020036e:	e566                	sd	s9,136(sp)
ffffffffc0200370:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200372:	d5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200376:	00005517          	auipc	a0,0x5
ffffffffc020037a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0205090 <etext+0x21e>
ffffffffc020037e:	d4fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200382:	000b8563          	beqz	s7,ffffffffc020038c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200386:	855e                	mv	a0,s7
ffffffffc0200388:	49a000ef          	jal	ra,ffffffffc0200822 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020038c:	4501                	li	a0,0
ffffffffc020038e:	4581                	li	a1,0
ffffffffc0200390:	4601                	li	a2,0
ffffffffc0200392:	48a1                	li	a7,8
ffffffffc0200394:	00000073          	ecall
ffffffffc0200398:	00005c17          	auipc	s8,0x5
ffffffffc020039c:	d68c0c13          	addi	s8,s8,-664 # ffffffffc0205100 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a0:	00005917          	auipc	s2,0x5
ffffffffc02003a4:	d1890913          	addi	s2,s2,-744 # ffffffffc02050b8 <etext+0x246>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a8:	00005497          	auipc	s1,0x5
ffffffffc02003ac:	d1848493          	addi	s1,s1,-744 # ffffffffc02050c0 <etext+0x24e>
        if (argc == MAXARGS - 1) {
ffffffffc02003b0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b2:	00005b17          	auipc	s6,0x5
ffffffffc02003b6:	d16b0b13          	addi	s6,s6,-746 # ffffffffc02050c8 <etext+0x256>
        argv[argc ++] = buf;
ffffffffc02003ba:	00005a17          	auipc	s4,0x5
ffffffffc02003be:	c2ea0a13          	addi	s4,s4,-978 # ffffffffc0204fe8 <etext+0x176>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c2:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003c4:	854a                	mv	a0,s2
ffffffffc02003c6:	d4fff0ef          	jal	ra,ffffffffc0200114 <readline>
ffffffffc02003ca:	842a                	mv	s0,a0
ffffffffc02003cc:	dd65                	beqz	a0,ffffffffc02003c4 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ce:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003d2:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	e1bd                	bnez	a1,ffffffffc020043a <kmonitor+0xec>
    if (argc == 0) {
ffffffffc02003d6:	fe0c87e3          	beqz	s9,ffffffffc02003c4 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	6582                	ld	a1,0(sp)
ffffffffc02003dc:	00005d17          	auipc	s10,0x5
ffffffffc02003e0:	d24d0d13          	addi	s10,s10,-732 # ffffffffc0205100 <commands>
        argv[argc ++] = buf;
ffffffffc02003e4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	4401                	li	s0,0
ffffffffc02003e8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ea:	602040ef          	jal	ra,ffffffffc02049ec <strcmp>
ffffffffc02003ee:	c919                	beqz	a0,ffffffffc0200404 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003f0:	2405                	addiw	s0,s0,1
ffffffffc02003f2:	0b540063          	beq	s0,s5,ffffffffc0200492 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f6:	000d3503          	ld	a0,0(s10)
ffffffffc02003fa:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003fe:	5ee040ef          	jal	ra,ffffffffc02049ec <strcmp>
ffffffffc0200402:	f57d                	bnez	a0,ffffffffc02003f0 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200404:	00141793          	slli	a5,s0,0x1
ffffffffc0200408:	97a2                	add	a5,a5,s0
ffffffffc020040a:	078e                	slli	a5,a5,0x3
ffffffffc020040c:	97e2                	add	a5,a5,s8
ffffffffc020040e:	6b9c                	ld	a5,16(a5)
ffffffffc0200410:	865e                	mv	a2,s7
ffffffffc0200412:	002c                	addi	a1,sp,8
ffffffffc0200414:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200418:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020041a:	fa0555e3          	bgez	a0,ffffffffc02003c4 <kmonitor+0x76>
}
ffffffffc020041e:	60ee                	ld	ra,216(sp)
ffffffffc0200420:	644e                	ld	s0,208(sp)
ffffffffc0200422:	64ae                	ld	s1,200(sp)
ffffffffc0200424:	690e                	ld	s2,192(sp)
ffffffffc0200426:	79ea                	ld	s3,184(sp)
ffffffffc0200428:	7a4a                	ld	s4,176(sp)
ffffffffc020042a:	7aaa                	ld	s5,168(sp)
ffffffffc020042c:	7b0a                	ld	s6,160(sp)
ffffffffc020042e:	6bea                	ld	s7,152(sp)
ffffffffc0200430:	6c4a                	ld	s8,144(sp)
ffffffffc0200432:	6caa                	ld	s9,136(sp)
ffffffffc0200434:	6d0a                	ld	s10,128(sp)
ffffffffc0200436:	612d                	addi	sp,sp,224
ffffffffc0200438:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	8526                	mv	a0,s1
ffffffffc020043c:	5ce040ef          	jal	ra,ffffffffc0204a0a <strchr>
ffffffffc0200440:	c901                	beqz	a0,ffffffffc0200450 <kmonitor+0x102>
ffffffffc0200442:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200446:	00040023          	sb	zero,0(s0)
ffffffffc020044a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020044c:	d5c9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc020044e:	b7f5                	j	ffffffffc020043a <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc0200450:	00044783          	lbu	a5,0(s0)
ffffffffc0200454:	d3c9                	beqz	a5,ffffffffc02003d6 <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc0200456:	033c8963          	beq	s9,s3,ffffffffc0200488 <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc020045a:	003c9793          	slli	a5,s9,0x3
ffffffffc020045e:	0118                	addi	a4,sp,128
ffffffffc0200460:	97ba                	add	a5,a5,a4
ffffffffc0200462:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200466:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020046a:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020046c:	e591                	bnez	a1,ffffffffc0200478 <kmonitor+0x12a>
ffffffffc020046e:	b7b5                	j	ffffffffc02003da <kmonitor+0x8c>
ffffffffc0200470:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200474:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200476:	d1a5                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200478:	8526                	mv	a0,s1
ffffffffc020047a:	590040ef          	jal	ra,ffffffffc0204a0a <strchr>
ffffffffc020047e:	d96d                	beqz	a0,ffffffffc0200470 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200480:	00044583          	lbu	a1,0(s0)
ffffffffc0200484:	d9a9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200486:	bf55                	j	ffffffffc020043a <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200488:	45c1                	li	a1,16
ffffffffc020048a:	855a                	mv	a0,s6
ffffffffc020048c:	c41ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200490:	b7e9                	j	ffffffffc020045a <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200492:	6582                	ld	a1,0(sp)
ffffffffc0200494:	00005517          	auipc	a0,0x5
ffffffffc0200498:	c5450513          	addi	a0,a0,-940 # ffffffffc02050e8 <etext+0x276>
ffffffffc020049c:	c31ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc02004a0:	b715                	j	ffffffffc02003c4 <kmonitor+0x76>

ffffffffc02004a2 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004a4:	00253513          	sltiu	a0,a0,2
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004aa:	03800513          	li	a0,56
ffffffffc02004ae:	8082                	ret

ffffffffc02004b0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	0000a797          	auipc	a5,0xa
ffffffffc02004b4:	fb078793          	addi	a5,a5,-80 # ffffffffc020a460 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004b8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004bc:	1141                	addi	sp,sp,-16
ffffffffc02004be:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c0:	95be                	add	a1,a1,a5
ffffffffc02004c2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c8:	56a040ef          	jal	ra,ffffffffc0204a32 <memcpy>
    return 0;
}
ffffffffc02004cc:	60a2                	ld	ra,8(sp)
ffffffffc02004ce:	4501                	li	a0,0
ffffffffc02004d0:	0141                	addi	sp,sp,16
ffffffffc02004d2:	8082                	ret

ffffffffc02004d4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004d4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d8:	0000a517          	auipc	a0,0xa
ffffffffc02004dc:	f8850513          	addi	a0,a0,-120 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02004e0:	1141                	addi	sp,sp,-16
ffffffffc02004e2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e4:	953e                	add	a0,a0,a5
ffffffffc02004e6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004ea:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ec:	546040ef          	jal	ra,ffffffffc0204a32 <memcpy>
    return 0;
}
ffffffffc02004f0:	60a2                	ld	ra,8(sp)
ffffffffc02004f2:	4501                	li	a0,0
ffffffffc02004f4:	0141                	addi	sp,sp,16
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004f8:	67e1                	lui	a5,0x18
ffffffffc02004fa:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004fe:	00015717          	auipc	a4,0x15
ffffffffc0200502:	04f73523          	sd	a5,74(a4) # ffffffffc0215548 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200506:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020050a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020050c:	953e                	add	a0,a0,a5
ffffffffc020050e:	4601                	li	a2,0
ffffffffc0200510:	4881                	li	a7,0
ffffffffc0200512:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200516:	02000793          	li	a5,32
ffffffffc020051a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020051e:	00005517          	auipc	a0,0x5
ffffffffc0200522:	c2a50513          	addi	a0,a0,-982 # ffffffffc0205148 <commands+0x48>
    ticks = 0;
ffffffffc0200526:	00015797          	auipc	a5,0x15
ffffffffc020052a:	0007bd23          	sd	zero,26(a5) # ffffffffc0215540 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020052e:	be79                	j	ffffffffc02000cc <cprintf>

ffffffffc0200530 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200530:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200534:	00015797          	auipc	a5,0x15
ffffffffc0200538:	0147b783          	ld	a5,20(a5) # ffffffffc0215548 <timebase>
ffffffffc020053c:	953e                	add	a0,a0,a5
ffffffffc020053e:	4581                	li	a1,0
ffffffffc0200540:	4601                	li	a2,0
ffffffffc0200542:	4881                	li	a7,0
ffffffffc0200544:	00000073          	ecall
ffffffffc0200548:	8082                	ret

ffffffffc020054a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020054a:	8082                	ret

ffffffffc020054c <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020054c:	100027f3          	csrr	a5,sstatus
ffffffffc0200550:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200552:	0ff57513          	zext.b	a0,a0
ffffffffc0200556:	e799                	bnez	a5,ffffffffc0200564 <cons_putc+0x18>
ffffffffc0200558:	4581                	li	a1,0
ffffffffc020055a:	4601                	li	a2,0
ffffffffc020055c:	4885                	li	a7,1
ffffffffc020055e:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200562:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200564:	1101                	addi	sp,sp,-32
ffffffffc0200566:	ec06                	sd	ra,24(sp)
ffffffffc0200568:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020056a:	05a000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc020056e:	6522                	ld	a0,8(sp)
ffffffffc0200570:	4581                	li	a1,0
ffffffffc0200572:	4601                	li	a2,0
ffffffffc0200574:	4885                	li	a7,1
ffffffffc0200576:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020057a:	60e2                	ld	ra,24(sp)
ffffffffc020057c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020057e:	a081                	j	ffffffffc02005be <intr_enable>

ffffffffc0200580 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200580:	100027f3          	csrr	a5,sstatus
ffffffffc0200584:	8b89                	andi	a5,a5,2
ffffffffc0200586:	eb89                	bnez	a5,ffffffffc0200598 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200588:	4501                	li	a0,0
ffffffffc020058a:	4581                	li	a1,0
ffffffffc020058c:	4601                	li	a2,0
ffffffffc020058e:	4889                	li	a7,2
ffffffffc0200590:	00000073          	ecall
ffffffffc0200594:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200596:	8082                	ret
int cons_getc(void) {
ffffffffc0200598:	1101                	addi	sp,sp,-32
ffffffffc020059a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020059c:	028000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc02005a0:	4501                	li	a0,0
ffffffffc02005a2:	4581                	li	a1,0
ffffffffc02005a4:	4601                	li	a2,0
ffffffffc02005a6:	4889                	li	a7,2
ffffffffc02005a8:	00000073          	ecall
ffffffffc02005ac:	2501                	sext.w	a0,a0
ffffffffc02005ae:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005b0:	00e000ef          	jal	ra,ffffffffc02005be <intr_enable>
}
ffffffffc02005b4:	60e2                	ld	ra,24(sp)
ffffffffc02005b6:	6522                	ld	a0,8(sp)
ffffffffc02005b8:	6105                	addi	sp,sp,32
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005bc:	8082                	ret

ffffffffc02005be <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005be:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005c2:	8082                	ret

ffffffffc02005c4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005c4:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ca:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ce:	1141                	addi	sp,sp,-16
ffffffffc02005d0:	e022                	sd	s0,0(sp)
ffffffffc02005d2:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d4:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005d8:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005de:	05500613          	li	a2,85
ffffffffc02005e2:	c399                	beqz	a5,ffffffffc02005e8 <pgfault_handler+0x1e>
ffffffffc02005e4:	04b00613          	li	a2,75
ffffffffc02005e8:	11843703          	ld	a4,280(s0)
ffffffffc02005ec:	47bd                	li	a5,15
ffffffffc02005ee:	05700693          	li	a3,87
ffffffffc02005f2:	00f70463          	beq	a4,a5,ffffffffc02005fa <pgfault_handler+0x30>
ffffffffc02005f6:	05200693          	li	a3,82
ffffffffc02005fa:	00005517          	auipc	a0,0x5
ffffffffc02005fe:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0205168 <commands+0x68>
ffffffffc0200602:	acbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00015517          	auipc	a0,0x15
ffffffffc020060a:	f4a53503          	ld	a0,-182(a0) # ffffffffc0215550 <check_mm_struct>
ffffffffc020060e:	c911                	beqz	a0,ffffffffc0200622 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200610:	11043603          	ld	a2,272(s0)
ffffffffc0200614:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200618:	6402                	ld	s0,0(sp)
ffffffffc020061a:	60a2                	ld	ra,8(sp)
ffffffffc020061c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020061e:	5010006f          	j	ffffffffc020131e <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00005617          	auipc	a2,0x5
ffffffffc0200626:	b6660613          	addi	a2,a2,-1178 # ffffffffc0205188 <commands+0x88>
ffffffffc020062a:	06200593          	li	a1,98
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	b7250513          	addi	a0,a0,-1166 # ffffffffc02051a0 <commands+0xa0>
ffffffffc0200636:	b93ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020063a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020063a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020063e:	00000797          	auipc	a5,0x0
ffffffffc0200642:	47a78793          	addi	a5,a5,1146 # ffffffffc0200ab8 <__alltraps>
ffffffffc0200646:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020064a:	000407b7          	lui	a5,0x40
ffffffffc020064e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200654:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200656:	1141                	addi	sp,sp,-16
ffffffffc0200658:	e022                	sd	s0,0(sp)
ffffffffc020065a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065c:	00005517          	auipc	a0,0x5
ffffffffc0200660:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02051b8 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	a67ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	b6450513          	addi	a0,a0,-1180 # ffffffffc02051d0 <commands+0xd0>
ffffffffc0200674:	a59ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00005517          	auipc	a0,0x5
ffffffffc020067e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02051e8 <commands+0xe8>
ffffffffc0200682:	a4bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00005517          	auipc	a0,0x5
ffffffffc020068c:	b7850513          	addi	a0,a0,-1160 # ffffffffc0205200 <commands+0x100>
ffffffffc0200690:	a3dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00005517          	auipc	a0,0x5
ffffffffc020069a:	b8250513          	addi	a0,a0,-1150 # ffffffffc0205218 <commands+0x118>
ffffffffc020069e:	a2fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00005517          	auipc	a0,0x5
ffffffffc02006a8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0205230 <commands+0x130>
ffffffffc02006ac:	a21ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00005517          	auipc	a0,0x5
ffffffffc02006b6:	b9650513          	addi	a0,a0,-1130 # ffffffffc0205248 <commands+0x148>
ffffffffc02006ba:	a13ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00005517          	auipc	a0,0x5
ffffffffc02006c4:	ba050513          	addi	a0,a0,-1120 # ffffffffc0205260 <commands+0x160>
ffffffffc02006c8:	a05ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00005517          	auipc	a0,0x5
ffffffffc02006d2:	baa50513          	addi	a0,a0,-1110 # ffffffffc0205278 <commands+0x178>
ffffffffc02006d6:	9f7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00005517          	auipc	a0,0x5
ffffffffc02006e0:	bb450513          	addi	a0,a0,-1100 # ffffffffc0205290 <commands+0x190>
ffffffffc02006e4:	9e9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00005517          	auipc	a0,0x5
ffffffffc02006ee:	bbe50513          	addi	a0,a0,-1090 # ffffffffc02052a8 <commands+0x1a8>
ffffffffc02006f2:	9dbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	bc850513          	addi	a0,a0,-1080 # ffffffffc02052c0 <commands+0x1c0>
ffffffffc0200700:	9cdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00005517          	auipc	a0,0x5
ffffffffc020070a:	bd250513          	addi	a0,a0,-1070 # ffffffffc02052d8 <commands+0x1d8>
ffffffffc020070e:	9bfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00005517          	auipc	a0,0x5
ffffffffc0200718:	bdc50513          	addi	a0,a0,-1060 # ffffffffc02052f0 <commands+0x1f0>
ffffffffc020071c:	9b1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00005517          	auipc	a0,0x5
ffffffffc0200726:	be650513          	addi	a0,a0,-1050 # ffffffffc0205308 <commands+0x208>
ffffffffc020072a:	9a3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205320 <commands+0x220>
ffffffffc0200738:	995ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00005517          	auipc	a0,0x5
ffffffffc0200742:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0205338 <commands+0x238>
ffffffffc0200746:	987ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00005517          	auipc	a0,0x5
ffffffffc0200750:	c0450513          	addi	a0,a0,-1020 # ffffffffc0205350 <commands+0x250>
ffffffffc0200754:	979ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00005517          	auipc	a0,0x5
ffffffffc020075e:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0205368 <commands+0x268>
ffffffffc0200762:	96bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00005517          	auipc	a0,0x5
ffffffffc020076c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0205380 <commands+0x280>
ffffffffc0200770:	95dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	c2250513          	addi	a0,a0,-990 # ffffffffc0205398 <commands+0x298>
ffffffffc020077e:	94fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00005517          	auipc	a0,0x5
ffffffffc0200788:	c2c50513          	addi	a0,a0,-980 # ffffffffc02053b0 <commands+0x2b0>
ffffffffc020078c:	941ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00005517          	auipc	a0,0x5
ffffffffc0200796:	c3650513          	addi	a0,a0,-970 # ffffffffc02053c8 <commands+0x2c8>
ffffffffc020079a:	933ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00005517          	auipc	a0,0x5
ffffffffc02007a4:	c4050513          	addi	a0,a0,-960 # ffffffffc02053e0 <commands+0x2e0>
ffffffffc02007a8:	925ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00005517          	auipc	a0,0x5
ffffffffc02007b2:	c4a50513          	addi	a0,a0,-950 # ffffffffc02053f8 <commands+0x2f8>
ffffffffc02007b6:	917ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	c5450513          	addi	a0,a0,-940 # ffffffffc0205410 <commands+0x310>
ffffffffc02007c4:	909ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00005517          	auipc	a0,0x5
ffffffffc02007ce:	c5e50513          	addi	a0,a0,-930 # ffffffffc0205428 <commands+0x328>
ffffffffc02007d2:	8fbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00005517          	auipc	a0,0x5
ffffffffc02007dc:	c6850513          	addi	a0,a0,-920 # ffffffffc0205440 <commands+0x340>
ffffffffc02007e0:	8edff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00005517          	auipc	a0,0x5
ffffffffc02007ea:	c7250513          	addi	a0,a0,-910 # ffffffffc0205458 <commands+0x358>
ffffffffc02007ee:	8dfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00005517          	auipc	a0,0x5
ffffffffc02007f8:	c7c50513          	addi	a0,a0,-900 # ffffffffc0205470 <commands+0x370>
ffffffffc02007fc:	8d1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00005517          	auipc	a0,0x5
ffffffffc0200806:	c8650513          	addi	a0,a0,-890 # ffffffffc0205488 <commands+0x388>
ffffffffc020080a:	8c3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00005517          	auipc	a0,0x5
ffffffffc0200818:	c8c50513          	addi	a0,a0,-884 # ffffffffc02054a0 <commands+0x3a0>
}
ffffffffc020081c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	8afff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200822 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	1141                	addi	sp,sp,-16
ffffffffc0200824:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200826:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200828:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020082a:	00005517          	auipc	a0,0x5
ffffffffc020082e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02054b8 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200832:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	899ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200838:	8522                	mv	a0,s0
ffffffffc020083a:	e1bff0ef          	jal	ra,ffffffffc0200654 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083e:	10043583          	ld	a1,256(s0)
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	c8e50513          	addi	a0,a0,-882 # ffffffffc02054d0 <commands+0x3d0>
ffffffffc020084a:	883ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084e:	10843583          	ld	a1,264(s0)
ffffffffc0200852:	00005517          	auipc	a0,0x5
ffffffffc0200856:	c9650513          	addi	a0,a0,-874 # ffffffffc02054e8 <commands+0x3e8>
ffffffffc020085a:	873ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085e:	11043583          	ld	a1,272(s0)
ffffffffc0200862:	00005517          	auipc	a0,0x5
ffffffffc0200866:	c9e50513          	addi	a0,a0,-866 # ffffffffc0205500 <commands+0x400>
ffffffffc020086a:	863ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200872:	6402                	ld	s0,0(sp)
ffffffffc0200874:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200876:	00005517          	auipc	a0,0x5
ffffffffc020087a:	ca250513          	addi	a0,a0,-862 # ffffffffc0205518 <commands+0x418>
}
ffffffffc020087e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	84dff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200884 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200884:	11853783          	ld	a5,280(a0)
ffffffffc0200888:	472d                	li	a4,11
ffffffffc020088a:	0786                	slli	a5,a5,0x1
ffffffffc020088c:	8385                	srli	a5,a5,0x1
ffffffffc020088e:	06f76c63          	bltu	a4,a5,ffffffffc0200906 <interrupt_handler+0x82>
ffffffffc0200892:	00005717          	auipc	a4,0x5
ffffffffc0200896:	d4e70713          	addi	a4,a4,-690 # ffffffffc02055e0 <commands+0x4e0>
ffffffffc020089a:	078a                	slli	a5,a5,0x2
ffffffffc020089c:	97ba                	add	a5,a5,a4
ffffffffc020089e:	439c                	lw	a5,0(a5)
ffffffffc02008a0:	97ba                	add	a5,a5,a4
ffffffffc02008a2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008a4:	00005517          	auipc	a0,0x5
ffffffffc02008a8:	cec50513          	addi	a0,a0,-788 # ffffffffc0205590 <commands+0x490>
ffffffffc02008ac:	821ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008b0:	00005517          	auipc	a0,0x5
ffffffffc02008b4:	cc050513          	addi	a0,a0,-832 # ffffffffc0205570 <commands+0x470>
ffffffffc02008b8:	815ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008bc:	00005517          	auipc	a0,0x5
ffffffffc02008c0:	c7450513          	addi	a0,a0,-908 # ffffffffc0205530 <commands+0x430>
ffffffffc02008c4:	809ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c8:	00005517          	auipc	a0,0x5
ffffffffc02008cc:	c8850513          	addi	a0,a0,-888 # ffffffffc0205550 <commands+0x450>
ffffffffc02008d0:	ffcff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d4:	1141                	addi	sp,sp,-16
ffffffffc02008d6:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d8:	c59ff0ef          	jal	ra,ffffffffc0200530 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008dc:	00015697          	auipc	a3,0x15
ffffffffc02008e0:	c6468693          	addi	a3,a3,-924 # ffffffffc0215540 <ticks>
ffffffffc02008e4:	629c                	ld	a5,0(a3)
ffffffffc02008e6:	06400713          	li	a4,100
ffffffffc02008ea:	0785                	addi	a5,a5,1
ffffffffc02008ec:	02e7f733          	remu	a4,a5,a4
ffffffffc02008f0:	e29c                	sd	a5,0(a3)
ffffffffc02008f2:	cb19                	beqz	a4,ffffffffc0200908 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008f4:	60a2                	ld	ra,8(sp)
ffffffffc02008f6:	0141                	addi	sp,sp,16
ffffffffc02008f8:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008fa:	00005517          	auipc	a0,0x5
ffffffffc02008fe:	cc650513          	addi	a0,a0,-826 # ffffffffc02055c0 <commands+0x4c0>
ffffffffc0200902:	fcaff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200906:	bf31                	j	ffffffffc0200822 <print_trapframe>
}
ffffffffc0200908:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020090a:	06400593          	li	a1,100
ffffffffc020090e:	00005517          	auipc	a0,0x5
ffffffffc0200912:	ca250513          	addi	a0,a0,-862 # ffffffffc02055b0 <commands+0x4b0>
}
ffffffffc0200916:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200918:	fb4ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc020091c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200920:	1101                	addi	sp,sp,-32
ffffffffc0200922:	e822                	sd	s0,16(sp)
ffffffffc0200924:	ec06                	sd	ra,24(sp)
ffffffffc0200926:	e426                	sd	s1,8(sp)
ffffffffc0200928:	473d                	li	a4,15
ffffffffc020092a:	842a                	mv	s0,a0
ffffffffc020092c:	14f76a63          	bltu	a4,a5,ffffffffc0200a80 <exception_handler+0x164>
ffffffffc0200930:	00005717          	auipc	a4,0x5
ffffffffc0200934:	e9870713          	addi	a4,a4,-360 # ffffffffc02057c8 <commands+0x6c8>
ffffffffc0200938:	078a                	slli	a5,a5,0x2
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	439c                	lw	a5,0(a5)
ffffffffc020093e:	97ba                	add	a5,a5,a4
ffffffffc0200940:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200942:	00005517          	auipc	a0,0x5
ffffffffc0200946:	e6e50513          	addi	a0,a0,-402 # ffffffffc02057b0 <commands+0x6b0>
ffffffffc020094a:	f82ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094e:	8522                	mv	a0,s0
ffffffffc0200950:	c7bff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200954:	84aa                	mv	s1,a0
ffffffffc0200956:	12051b63          	bnez	a0,ffffffffc0200a8c <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020095a:	60e2                	ld	ra,24(sp)
ffffffffc020095c:	6442                	ld	s0,16(sp)
ffffffffc020095e:	64a2                	ld	s1,8(sp)
ffffffffc0200960:	6105                	addi	sp,sp,32
ffffffffc0200962:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200964:	00005517          	auipc	a0,0x5
ffffffffc0200968:	cac50513          	addi	a0,a0,-852 # ffffffffc0205610 <commands+0x510>
}
ffffffffc020096c:	6442                	ld	s0,16(sp)
ffffffffc020096e:	60e2                	ld	ra,24(sp)
ffffffffc0200970:	64a2                	ld	s1,8(sp)
ffffffffc0200972:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200974:	f58ff06f          	j	ffffffffc02000cc <cprintf>
ffffffffc0200978:	00005517          	auipc	a0,0x5
ffffffffc020097c:	cb850513          	addi	a0,a0,-840 # ffffffffc0205630 <commands+0x530>
ffffffffc0200980:	b7f5                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200982:	00005517          	auipc	a0,0x5
ffffffffc0200986:	cce50513          	addi	a0,a0,-818 # ffffffffc0205650 <commands+0x550>
ffffffffc020098a:	b7cd                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098c:	00005517          	auipc	a0,0x5
ffffffffc0200990:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205668 <commands+0x568>
ffffffffc0200994:	bfe1                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200996:	00005517          	auipc	a0,0x5
ffffffffc020099a:	ce250513          	addi	a0,a0,-798 # ffffffffc0205678 <commands+0x578>
ffffffffc020099e:	b7f9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	cf850513          	addi	a0,a0,-776 # ffffffffc0205698 <commands+0x598>
ffffffffc02009a8:	f24ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ac:	8522                	mv	a0,s0
ffffffffc02009ae:	c1dff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009b2:	84aa                	mv	s1,a0
ffffffffc02009b4:	d15d                	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b6:	8522                	mv	a0,s0
ffffffffc02009b8:	e6bff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009bc:	86a6                	mv	a3,s1
ffffffffc02009be:	00005617          	auipc	a2,0x5
ffffffffc02009c2:	cf260613          	addi	a2,a2,-782 # ffffffffc02056b0 <commands+0x5b0>
ffffffffc02009c6:	0b300593          	li	a1,179
ffffffffc02009ca:	00004517          	auipc	a0,0x4
ffffffffc02009ce:	7d650513          	addi	a0,a0,2006 # ffffffffc02051a0 <commands+0xa0>
ffffffffc02009d2:	ff6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d6:	00005517          	auipc	a0,0x5
ffffffffc02009da:	cfa50513          	addi	a0,a0,-774 # ffffffffc02056d0 <commands+0x5d0>
ffffffffc02009de:	b779                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009e0:	00005517          	auipc	a0,0x5
ffffffffc02009e4:	d0850513          	addi	a0,a0,-760 # ffffffffc02056e8 <commands+0x5e8>
ffffffffc02009e8:	ee4ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ec:	8522                	mv	a0,s0
ffffffffc02009ee:	bddff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009f2:	84aa                	mv	s1,a0
ffffffffc02009f4:	d13d                	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f6:	8522                	mv	a0,s0
ffffffffc02009f8:	e2bff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fc:	86a6                	mv	a3,s1
ffffffffc02009fe:	00005617          	auipc	a2,0x5
ffffffffc0200a02:	cb260613          	addi	a2,a2,-846 # ffffffffc02056b0 <commands+0x5b0>
ffffffffc0200a06:	0bd00593          	li	a1,189
ffffffffc0200a0a:	00004517          	auipc	a0,0x4
ffffffffc0200a0e:	79650513          	addi	a0,a0,1942 # ffffffffc02051a0 <commands+0xa0>
ffffffffc0200a12:	fb6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a16:	00005517          	auipc	a0,0x5
ffffffffc0200a1a:	cea50513          	addi	a0,a0,-790 # ffffffffc0205700 <commands+0x600>
ffffffffc0200a1e:	b7b9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	d0050513          	addi	a0,a0,-768 # ffffffffc0205720 <commands+0x620>
ffffffffc0200a28:	b791                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	d1650513          	addi	a0,a0,-746 # ffffffffc0205740 <commands+0x640>
ffffffffc0200a32:	bf2d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205760 <commands+0x660>
ffffffffc0200a3c:	bf05                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3e:	00005517          	auipc	a0,0x5
ffffffffc0200a42:	d4250513          	addi	a0,a0,-702 # ffffffffc0205780 <commands+0x680>
ffffffffc0200a46:	b71d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	d5050513          	addi	a0,a0,-688 # ffffffffc0205798 <commands+0x698>
ffffffffc0200a50:	e7cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a54:	8522                	mv	a0,s0
ffffffffc0200a56:	b75ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a5a:	84aa                	mv	s1,a0
ffffffffc0200a5c:	ee050fe3          	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a60:	8522                	mv	a0,s0
ffffffffc0200a62:	dc1ff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a66:	86a6                	mv	a3,s1
ffffffffc0200a68:	00005617          	auipc	a2,0x5
ffffffffc0200a6c:	c4860613          	addi	a2,a2,-952 # ffffffffc02056b0 <commands+0x5b0>
ffffffffc0200a70:	0d300593          	li	a1,211
ffffffffc0200a74:	00004517          	auipc	a0,0x4
ffffffffc0200a78:	72c50513          	addi	a0,a0,1836 # ffffffffc02051a0 <commands+0xa0>
ffffffffc0200a7c:	f4cff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            print_trapframe(tf);
ffffffffc0200a80:	8522                	mv	a0,s0
}
ffffffffc0200a82:	6442                	ld	s0,16(sp)
ffffffffc0200a84:	60e2                	ld	ra,24(sp)
ffffffffc0200a86:	64a2                	ld	s1,8(sp)
ffffffffc0200a88:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a8a:	bb61                	j	ffffffffc0200822 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8c:	8522                	mv	a0,s0
ffffffffc0200a8e:	d95ff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a92:	86a6                	mv	a3,s1
ffffffffc0200a94:	00005617          	auipc	a2,0x5
ffffffffc0200a98:	c1c60613          	addi	a2,a2,-996 # ffffffffc02056b0 <commands+0x5b0>
ffffffffc0200a9c:	0da00593          	li	a1,218
ffffffffc0200aa0:	00004517          	auipc	a0,0x4
ffffffffc0200aa4:	70050513          	addi	a0,a0,1792 # ffffffffc02051a0 <commands+0xa0>
ffffffffc0200aa8:	f20ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200aac <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aac:	11853783          	ld	a5,280(a0)
ffffffffc0200ab0:	0007c363          	bltz	a5,ffffffffc0200ab6 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab4:	b5a5                	j	ffffffffc020091c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ab6:	b3f9                	j	ffffffffc0200884 <interrupt_handler>

ffffffffc0200ab8 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ab8:	14011073          	csrw	sscratch,sp
ffffffffc0200abc:	712d                	addi	sp,sp,-288
ffffffffc0200abe:	e406                	sd	ra,8(sp)
ffffffffc0200ac0:	ec0e                	sd	gp,24(sp)
ffffffffc0200ac2:	f012                	sd	tp,32(sp)
ffffffffc0200ac4:	f416                	sd	t0,40(sp)
ffffffffc0200ac6:	f81a                	sd	t1,48(sp)
ffffffffc0200ac8:	fc1e                	sd	t2,56(sp)
ffffffffc0200aca:	e0a2                	sd	s0,64(sp)
ffffffffc0200acc:	e4a6                	sd	s1,72(sp)
ffffffffc0200ace:	e8aa                	sd	a0,80(sp)
ffffffffc0200ad0:	ecae                	sd	a1,88(sp)
ffffffffc0200ad2:	f0b2                	sd	a2,96(sp)
ffffffffc0200ad4:	f4b6                	sd	a3,104(sp)
ffffffffc0200ad6:	f8ba                	sd	a4,112(sp)
ffffffffc0200ad8:	fcbe                	sd	a5,120(sp)
ffffffffc0200ada:	e142                	sd	a6,128(sp)
ffffffffc0200adc:	e546                	sd	a7,136(sp)
ffffffffc0200ade:	e94a                	sd	s2,144(sp)
ffffffffc0200ae0:	ed4e                	sd	s3,152(sp)
ffffffffc0200ae2:	f152                	sd	s4,160(sp)
ffffffffc0200ae4:	f556                	sd	s5,168(sp)
ffffffffc0200ae6:	f95a                	sd	s6,176(sp)
ffffffffc0200ae8:	fd5e                	sd	s7,184(sp)
ffffffffc0200aea:	e1e2                	sd	s8,192(sp)
ffffffffc0200aec:	e5e6                	sd	s9,200(sp)
ffffffffc0200aee:	e9ea                	sd	s10,208(sp)
ffffffffc0200af0:	edee                	sd	s11,216(sp)
ffffffffc0200af2:	f1f2                	sd	t3,224(sp)
ffffffffc0200af4:	f5f6                	sd	t4,232(sp)
ffffffffc0200af6:	f9fa                	sd	t5,240(sp)
ffffffffc0200af8:	fdfe                	sd	t6,248(sp)
ffffffffc0200afa:	14002473          	csrr	s0,sscratch
ffffffffc0200afe:	100024f3          	csrr	s1,sstatus
ffffffffc0200b02:	14102973          	csrr	s2,sepc
ffffffffc0200b06:	143029f3          	csrr	s3,stval
ffffffffc0200b0a:	14202a73          	csrr	s4,scause
ffffffffc0200b0e:	e822                	sd	s0,16(sp)
ffffffffc0200b10:	e226                	sd	s1,256(sp)
ffffffffc0200b12:	e64a                	sd	s2,264(sp)
ffffffffc0200b14:	ea4e                	sd	s3,272(sp)
ffffffffc0200b16:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b18:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b1a:	f93ff0ef          	jal	ra,ffffffffc0200aac <trap>

ffffffffc0200b1e <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b1e:	6492                	ld	s1,256(sp)
ffffffffc0200b20:	6932                	ld	s2,264(sp)
ffffffffc0200b22:	10049073          	csrw	sstatus,s1
ffffffffc0200b26:	14191073          	csrw	sepc,s2
ffffffffc0200b2a:	60a2                	ld	ra,8(sp)
ffffffffc0200b2c:	61e2                	ld	gp,24(sp)
ffffffffc0200b2e:	7202                	ld	tp,32(sp)
ffffffffc0200b30:	72a2                	ld	t0,40(sp)
ffffffffc0200b32:	7342                	ld	t1,48(sp)
ffffffffc0200b34:	73e2                	ld	t2,56(sp)
ffffffffc0200b36:	6406                	ld	s0,64(sp)
ffffffffc0200b38:	64a6                	ld	s1,72(sp)
ffffffffc0200b3a:	6546                	ld	a0,80(sp)
ffffffffc0200b3c:	65e6                	ld	a1,88(sp)
ffffffffc0200b3e:	7606                	ld	a2,96(sp)
ffffffffc0200b40:	76a6                	ld	a3,104(sp)
ffffffffc0200b42:	7746                	ld	a4,112(sp)
ffffffffc0200b44:	77e6                	ld	a5,120(sp)
ffffffffc0200b46:	680a                	ld	a6,128(sp)
ffffffffc0200b48:	68aa                	ld	a7,136(sp)
ffffffffc0200b4a:	694a                	ld	s2,144(sp)
ffffffffc0200b4c:	69ea                	ld	s3,152(sp)
ffffffffc0200b4e:	7a0a                	ld	s4,160(sp)
ffffffffc0200b50:	7aaa                	ld	s5,168(sp)
ffffffffc0200b52:	7b4a                	ld	s6,176(sp)
ffffffffc0200b54:	7bea                	ld	s7,184(sp)
ffffffffc0200b56:	6c0e                	ld	s8,192(sp)
ffffffffc0200b58:	6cae                	ld	s9,200(sp)
ffffffffc0200b5a:	6d4e                	ld	s10,208(sp)
ffffffffc0200b5c:	6dee                	ld	s11,216(sp)
ffffffffc0200b5e:	7e0e                	ld	t3,224(sp)
ffffffffc0200b60:	7eae                	ld	t4,232(sp)
ffffffffc0200b62:	7f4e                	ld	t5,240(sp)
ffffffffc0200b64:	7fee                	ld	t6,248(sp)
ffffffffc0200b66:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b68:	10200073          	sret

ffffffffc0200b6c <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b6c:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b6e:	bf45                	j	ffffffffc0200b1e <__trapret>
	...

ffffffffc0200b72 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b72:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200b74:	00005697          	auipc	a3,0x5
ffffffffc0200b78:	c9468693          	addi	a3,a3,-876 # ffffffffc0205808 <commands+0x708>
ffffffffc0200b7c:	00005617          	auipc	a2,0x5
ffffffffc0200b80:	cac60613          	addi	a2,a2,-852 # ffffffffc0205828 <commands+0x728>
ffffffffc0200b84:	07e00593          	li	a1,126
ffffffffc0200b88:	00005517          	auipc	a0,0x5
ffffffffc0200b8c:	cb850513          	addi	a0,a0,-840 # ffffffffc0205840 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b90:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200b92:	e36ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200b96 <mm_create>:
mm_create(void) {
ffffffffc0200b96:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200b98:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200b9c:	e022                	sd	s0,0(sp)
ffffffffc0200b9e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ba0:	67b000ef          	jal	ra,ffffffffc0201a1a <kmalloc>
ffffffffc0200ba4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ba6:	c105                	beqz	a0,ffffffffc0200bc6 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ba8:	e408                	sd	a0,8(s0)
ffffffffc0200baa:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200bac:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200bb0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200bb4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bb8:	00015797          	auipc	a5,0x15
ffffffffc0200bbc:	9c07a783          	lw	a5,-1600(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc0200bc0:	eb81                	bnez	a5,ffffffffc0200bd0 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200bc2:	02053423          	sd	zero,40(a0)
}
ffffffffc0200bc6:	60a2                	ld	ra,8(sp)
ffffffffc0200bc8:	8522                	mv	a0,s0
ffffffffc0200bca:	6402                	ld	s0,0(sp)
ffffffffc0200bcc:	0141                	addi	sp,sp,16
ffffffffc0200bce:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bd0:	746010ef          	jal	ra,ffffffffc0202316 <swap_init_mm>
}
ffffffffc0200bd4:	60a2                	ld	ra,8(sp)
ffffffffc0200bd6:	8522                	mv	a0,s0
ffffffffc0200bd8:	6402                	ld	s0,0(sp)
ffffffffc0200bda:	0141                	addi	sp,sp,16
ffffffffc0200bdc:	8082                	ret

ffffffffc0200bde <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200bde:	1101                	addi	sp,sp,-32
ffffffffc0200be0:	e04a                	sd	s2,0(sp)
ffffffffc0200be2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200be4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200be8:	e822                	sd	s0,16(sp)
ffffffffc0200bea:	e426                	sd	s1,8(sp)
ffffffffc0200bec:	ec06                	sd	ra,24(sp)
ffffffffc0200bee:	84ae                	mv	s1,a1
ffffffffc0200bf0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200bf2:	629000ef          	jal	ra,ffffffffc0201a1a <kmalloc>
    if (vma != NULL) {
ffffffffc0200bf6:	c509                	beqz	a0,ffffffffc0200c00 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200bf8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200bfc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200bfe:	cd00                	sw	s0,24(a0)
}
ffffffffc0200c00:	60e2                	ld	ra,24(sp)
ffffffffc0200c02:	6442                	ld	s0,16(sp)
ffffffffc0200c04:	64a2                	ld	s1,8(sp)
ffffffffc0200c06:	6902                	ld	s2,0(sp)
ffffffffc0200c08:	6105                	addi	sp,sp,32
ffffffffc0200c0a:	8082                	ret

ffffffffc0200c0c <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200c0c:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200c0e:	c505                	beqz	a0,ffffffffc0200c36 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200c10:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c12:	c501                	beqz	a0,ffffffffc0200c1a <find_vma+0xe>
ffffffffc0200c14:	651c                	ld	a5,8(a0)
ffffffffc0200c16:	02f5f263          	bgeu	a1,a5,ffffffffc0200c3a <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200c1a:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200c1c:	00f68d63          	beq	a3,a5,ffffffffc0200c36 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200c20:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c24:	00e5e663          	bltu	a1,a4,ffffffffc0200c30 <find_vma+0x24>
ffffffffc0200c28:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c2c:	00e5ec63          	bltu	a1,a4,ffffffffc0200c44 <find_vma+0x38>
ffffffffc0200c30:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200c32:	fef697e3          	bne	a3,a5,ffffffffc0200c20 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200c36:	4501                	li	a0,0
}
ffffffffc0200c38:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c3a:	691c                	ld	a5,16(a0)
ffffffffc0200c3c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200c1a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200c40:	ea88                	sd	a0,16(a3)
ffffffffc0200c42:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200c44:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200c48:	ea88                	sd	a0,16(a3)
ffffffffc0200c4a:	8082                	ret

ffffffffc0200c4c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c4c:	6590                	ld	a2,8(a1)
ffffffffc0200c4e:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200c52:	1141                	addi	sp,sp,-16
ffffffffc0200c54:	e406                	sd	ra,8(sp)
ffffffffc0200c56:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c58:	01066763          	bltu	a2,a6,ffffffffc0200c66 <insert_vma_struct+0x1a>
ffffffffc0200c5c:	a085                	j	ffffffffc0200cbc <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c5e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c62:	04e66863          	bltu	a2,a4,ffffffffc0200cb2 <insert_vma_struct+0x66>
ffffffffc0200c66:	86be                	mv	a3,a5
ffffffffc0200c68:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200c6a:	fef51ae3          	bne	a0,a5,ffffffffc0200c5e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200c6e:	02a68463          	beq	a3,a0,ffffffffc0200c96 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200c72:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c76:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200c7a:	08e8f163          	bgeu	a7,a4,ffffffffc0200cfc <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c7e:	04e66f63          	bltu	a2,a4,ffffffffc0200cdc <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200c82:	00f50a63          	beq	a0,a5,ffffffffc0200c96 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c86:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c8a:	05076963          	bltu	a4,a6,ffffffffc0200cdc <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200c8e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200c92:	02c77363          	bgeu	a4,a2,ffffffffc0200cb8 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200c96:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200c98:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200c9a:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200c9e:	e390                	sd	a2,0(a5)
ffffffffc0200ca0:	e690                	sd	a2,8(a3)
}
ffffffffc0200ca2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200ca4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200ca6:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200ca8:	0017079b          	addiw	a5,a4,1
ffffffffc0200cac:	d11c                	sw	a5,32(a0)
}
ffffffffc0200cae:	0141                	addi	sp,sp,16
ffffffffc0200cb0:	8082                	ret
    if (le_prev != list) {
ffffffffc0200cb2:	fca690e3          	bne	a3,a0,ffffffffc0200c72 <insert_vma_struct+0x26>
ffffffffc0200cb6:	bfd1                	j	ffffffffc0200c8a <insert_vma_struct+0x3e>
ffffffffc0200cb8:	ebbff0ef          	jal	ra,ffffffffc0200b72 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200cbc:	00005697          	auipc	a3,0x5
ffffffffc0200cc0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205850 <commands+0x750>
ffffffffc0200cc4:	00005617          	auipc	a2,0x5
ffffffffc0200cc8:	b6460613          	addi	a2,a2,-1180 # ffffffffc0205828 <commands+0x728>
ffffffffc0200ccc:	08500593          	li	a1,133
ffffffffc0200cd0:	00005517          	auipc	a0,0x5
ffffffffc0200cd4:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205840 <commands+0x740>
ffffffffc0200cd8:	cf0ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200cdc:	00005697          	auipc	a3,0x5
ffffffffc0200ce0:	bb468693          	addi	a3,a3,-1100 # ffffffffc0205890 <commands+0x790>
ffffffffc0200ce4:	00005617          	auipc	a2,0x5
ffffffffc0200ce8:	b4460613          	addi	a2,a2,-1212 # ffffffffc0205828 <commands+0x728>
ffffffffc0200cec:	07d00593          	li	a1,125
ffffffffc0200cf0:	00005517          	auipc	a0,0x5
ffffffffc0200cf4:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205840 <commands+0x740>
ffffffffc0200cf8:	cd0ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200cfc:	00005697          	auipc	a3,0x5
ffffffffc0200d00:	b7468693          	addi	a3,a3,-1164 # ffffffffc0205870 <commands+0x770>
ffffffffc0200d04:	00005617          	auipc	a2,0x5
ffffffffc0200d08:	b2460613          	addi	a2,a2,-1244 # ffffffffc0205828 <commands+0x728>
ffffffffc0200d0c:	07c00593          	li	a1,124
ffffffffc0200d10:	00005517          	auipc	a0,0x5
ffffffffc0200d14:	b3050513          	addi	a0,a0,-1232 # ffffffffc0205840 <commands+0x740>
ffffffffc0200d18:	cb0ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200d1c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200d1c:	1141                	addi	sp,sp,-16
ffffffffc0200d1e:	e022                	sd	s0,0(sp)
ffffffffc0200d20:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200d22:	6508                	ld	a0,8(a0)
ffffffffc0200d24:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200d26:	00a40c63          	beq	s0,a0,ffffffffc0200d3e <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d2a:	6118                	ld	a4,0(a0)
ffffffffc0200d2c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200d2e:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d30:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200d32:	e398                	sd	a4,0(a5)
ffffffffc0200d34:	597000ef          	jal	ra,ffffffffc0201aca <kfree>
    return listelm->next;
ffffffffc0200d38:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200d3a:	fea418e3          	bne	s0,a0,ffffffffc0200d2a <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0200d3e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200d40:	6402                	ld	s0,0(sp)
ffffffffc0200d42:	60a2                	ld	ra,8(sp)
ffffffffc0200d44:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200d46:	5850006f          	j	ffffffffc0201aca <kfree>

ffffffffc0200d4a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200d4a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200d4c:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0200d50:	fc06                	sd	ra,56(sp)
ffffffffc0200d52:	f822                	sd	s0,48(sp)
ffffffffc0200d54:	f426                	sd	s1,40(sp)
ffffffffc0200d56:	f04a                	sd	s2,32(sp)
ffffffffc0200d58:	ec4e                	sd	s3,24(sp)
ffffffffc0200d5a:	e852                	sd	s4,16(sp)
ffffffffc0200d5c:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200d5e:	4bd000ef          	jal	ra,ffffffffc0201a1a <kmalloc>
    if (mm != NULL) {
ffffffffc0200d62:	58050e63          	beqz	a0,ffffffffc02012fe <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc0200d66:	e508                	sd	a0,8(a0)
ffffffffc0200d68:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200d6a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200d6e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200d72:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d76:	00015797          	auipc	a5,0x15
ffffffffc0200d7a:	8027a783          	lw	a5,-2046(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc0200d7e:	84aa                	mv	s1,a0
ffffffffc0200d80:	e7b9                	bnez	a5,ffffffffc0200dce <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0200d82:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200d86:	03200413          	li	s0,50
ffffffffc0200d8a:	a811                	j	ffffffffc0200d9e <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc0200d8c:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d8e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d90:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200d94:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d96:	8526                	mv	a0,s1
ffffffffc0200d98:	eb5ff0ef          	jal	ra,ffffffffc0200c4c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200d9c:	cc05                	beqz	s0,ffffffffc0200dd4 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d9e:	03000513          	li	a0,48
ffffffffc0200da2:	479000ef          	jal	ra,ffffffffc0201a1a <kmalloc>
ffffffffc0200da6:	85aa                	mv	a1,a0
ffffffffc0200da8:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200dac:	f165                	bnez	a0,ffffffffc0200d8c <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc0200dae:	00005697          	auipc	a3,0x5
ffffffffc0200db2:	d5a68693          	addi	a3,a3,-678 # ffffffffc0205b08 <commands+0xa08>
ffffffffc0200db6:	00005617          	auipc	a2,0x5
ffffffffc0200dba:	a7260613          	addi	a2,a2,-1422 # ffffffffc0205828 <commands+0x728>
ffffffffc0200dbe:	0c900593          	li	a1,201
ffffffffc0200dc2:	00005517          	auipc	a0,0x5
ffffffffc0200dc6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0205840 <commands+0x740>
ffffffffc0200dca:	bfeff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200dce:	548010ef          	jal	ra,ffffffffc0202316 <swap_init_mm>
ffffffffc0200dd2:	bf55                	j	ffffffffc0200d86 <vmm_init+0x3c>
ffffffffc0200dd4:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200dd8:	1f900913          	li	s2,505
ffffffffc0200ddc:	a819                	j	ffffffffc0200df2 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0200dde:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200de0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200de2:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200de6:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200de8:	8526                	mv	a0,s1
ffffffffc0200dea:	e63ff0ef          	jal	ra,ffffffffc0200c4c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200dee:	03240a63          	beq	s0,s2,ffffffffc0200e22 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200df2:	03000513          	li	a0,48
ffffffffc0200df6:	425000ef          	jal	ra,ffffffffc0201a1a <kmalloc>
ffffffffc0200dfa:	85aa                	mv	a1,a0
ffffffffc0200dfc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200e00:	fd79                	bnez	a0,ffffffffc0200dde <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0200e02:	00005697          	auipc	a3,0x5
ffffffffc0200e06:	d0668693          	addi	a3,a3,-762 # ffffffffc0205b08 <commands+0xa08>
ffffffffc0200e0a:	00005617          	auipc	a2,0x5
ffffffffc0200e0e:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0205828 <commands+0x728>
ffffffffc0200e12:	0cf00593          	li	a1,207
ffffffffc0200e16:	00005517          	auipc	a0,0x5
ffffffffc0200e1a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0205840 <commands+0x740>
ffffffffc0200e1e:	baaff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return listelm->next;
ffffffffc0200e22:	649c                	ld	a5,8(s1)
ffffffffc0200e24:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200e26:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200e2a:	30f48e63          	beq	s1,a5,ffffffffc0201146 <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200e2e:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200e32:	ffe70613          	addi	a2,a4,-2
ffffffffc0200e36:	2ad61863          	bne	a2,a3,ffffffffc02010e6 <vmm_init+0x39c>
ffffffffc0200e3a:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200e3e:	2ae69463          	bne	a3,a4,ffffffffc02010e6 <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200e42:	0715                	addi	a4,a4,5
ffffffffc0200e44:	679c                	ld	a5,8(a5)
ffffffffc0200e46:	feb712e3          	bne	a4,a1,ffffffffc0200e2a <vmm_init+0xe0>
ffffffffc0200e4a:	4a1d                	li	s4,7
ffffffffc0200e4c:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e4e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200e52:	85a2                	mv	a1,s0
ffffffffc0200e54:	8526                	mv	a0,s1
ffffffffc0200e56:	db7ff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
ffffffffc0200e5a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200e5c:	34050563          	beqz	a0,ffffffffc02011a6 <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200e60:	00140593          	addi	a1,s0,1
ffffffffc0200e64:	8526                	mv	a0,s1
ffffffffc0200e66:	da7ff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
ffffffffc0200e6a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0200e6c:	34050d63          	beqz	a0,ffffffffc02011c6 <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200e70:	85d2                	mv	a1,s4
ffffffffc0200e72:	8526                	mv	a0,s1
ffffffffc0200e74:	d99ff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
        assert(vma3 == NULL);
ffffffffc0200e78:	36051763          	bnez	a0,ffffffffc02011e6 <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200e7c:	00340593          	addi	a1,s0,3
ffffffffc0200e80:	8526                	mv	a0,s1
ffffffffc0200e82:	d8bff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
        assert(vma4 == NULL);
ffffffffc0200e86:	2e051063          	bnez	a0,ffffffffc0201166 <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200e8a:	00440593          	addi	a1,s0,4
ffffffffc0200e8e:	8526                	mv	a0,s1
ffffffffc0200e90:	d7dff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
        assert(vma5 == NULL);
ffffffffc0200e94:	2e051963          	bnez	a0,ffffffffc0201186 <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200e98:	00893783          	ld	a5,8(s2)
ffffffffc0200e9c:	26879563          	bne	a5,s0,ffffffffc0201106 <vmm_init+0x3bc>
ffffffffc0200ea0:	01093783          	ld	a5,16(s2)
ffffffffc0200ea4:	27479163          	bne	a5,s4,ffffffffc0201106 <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200ea8:	0089b783          	ld	a5,8(s3)
ffffffffc0200eac:	26879d63          	bne	a5,s0,ffffffffc0201126 <vmm_init+0x3dc>
ffffffffc0200eb0:	0109b783          	ld	a5,16(s3)
ffffffffc0200eb4:	27479963          	bne	a5,s4,ffffffffc0201126 <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200eb8:	0415                	addi	s0,s0,5
ffffffffc0200eba:	0a15                	addi	s4,s4,5
ffffffffc0200ebc:	f9541be3          	bne	s0,s5,ffffffffc0200e52 <vmm_init+0x108>
ffffffffc0200ec0:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200ec2:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200ec4:	85a2                	mv	a1,s0
ffffffffc0200ec6:	8526                	mv	a0,s1
ffffffffc0200ec8:	d45ff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
ffffffffc0200ecc:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200ed0:	c90d                	beqz	a0,ffffffffc0200f02 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200ed2:	6914                	ld	a3,16(a0)
ffffffffc0200ed4:	6510                	ld	a2,8(a0)
ffffffffc0200ed6:	00005517          	auipc	a0,0x5
ffffffffc0200eda:	ada50513          	addi	a0,a0,-1318 # ffffffffc02059b0 <commands+0x8b0>
ffffffffc0200ede:	9eeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200ee2:	00005697          	auipc	a3,0x5
ffffffffc0200ee6:	af668693          	addi	a3,a3,-1290 # ffffffffc02059d8 <commands+0x8d8>
ffffffffc0200eea:	00005617          	auipc	a2,0x5
ffffffffc0200eee:	93e60613          	addi	a2,a2,-1730 # ffffffffc0205828 <commands+0x728>
ffffffffc0200ef2:	0f100593          	li	a1,241
ffffffffc0200ef6:	00005517          	auipc	a0,0x5
ffffffffc0200efa:	94a50513          	addi	a0,a0,-1718 # ffffffffc0205840 <commands+0x740>
ffffffffc0200efe:	acaff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200f02:	147d                	addi	s0,s0,-1
ffffffffc0200f04:	fd2410e3          	bne	s0,s2,ffffffffc0200ec4 <vmm_init+0x17a>
ffffffffc0200f08:	a801                	j	ffffffffc0200f18 <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f0a:	6118                	ld	a4,0(a0)
ffffffffc0200f0c:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200f0e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200f10:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200f12:	e398                	sd	a4,0(a5)
ffffffffc0200f14:	3b7000ef          	jal	ra,ffffffffc0201aca <kfree>
    return listelm->next;
ffffffffc0200f18:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200f1a:	fea498e3          	bne	s1,a0,ffffffffc0200f0a <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0200f1e:	8526                	mv	a0,s1
ffffffffc0200f20:	3ab000ef          	jal	ra,ffffffffc0201aca <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200f24:	00005517          	auipc	a0,0x5
ffffffffc0200f28:	acc50513          	addi	a0,a0,-1332 # ffffffffc02059f0 <commands+0x8f0>
ffffffffc0200f2c:	9a0ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200f30:	144020ef          	jal	ra,ffffffffc0203074 <nr_free_pages>
ffffffffc0200f34:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f36:	03000513          	li	a0,48
ffffffffc0200f3a:	2e1000ef          	jal	ra,ffffffffc0201a1a <kmalloc>
ffffffffc0200f3e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200f40:	2c050363          	beqz	a0,ffffffffc0201206 <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200f44:	00014797          	auipc	a5,0x14
ffffffffc0200f48:	6347a783          	lw	a5,1588(a5) # ffffffffc0215578 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200f4c:	e508                	sd	a0,8(a0)
ffffffffc0200f4e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200f50:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200f54:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200f58:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200f5c:	18079263          	bnez	a5,ffffffffc02010e0 <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc0200f60:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f64:	00014917          	auipc	s2,0x14
ffffffffc0200f68:	62493903          	ld	s2,1572(s2) # ffffffffc0215588 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200f6c:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200f70:	00014717          	auipc	a4,0x14
ffffffffc0200f74:	5e873023          	sd	s0,1504(a4) # ffffffffc0215550 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f78:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200f7c:	36079163          	bnez	a5,ffffffffc02012de <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f80:	03000513          	li	a0,48
ffffffffc0200f84:	297000ef          	jal	ra,ffffffffc0201a1a <kmalloc>
ffffffffc0200f88:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0200f8a:	2a050263          	beqz	a0,ffffffffc020122e <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc0200f8e:	002007b7          	lui	a5,0x200
ffffffffc0200f92:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0200f96:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200f98:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f9a:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0200f9e:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200fa0:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0200fa4:	ca9ff0ef          	jal	ra,ffffffffc0200c4c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200fa8:	10000593          	li	a1,256
ffffffffc0200fac:	8522                	mv	a0,s0
ffffffffc0200fae:	c5fff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
ffffffffc0200fb2:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200fb6:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200fba:	28a99a63          	bne	s3,a0,ffffffffc020124e <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc0200fbe:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200fc2:	0785                	addi	a5,a5,1
ffffffffc0200fc4:	fee79de3          	bne	a5,a4,ffffffffc0200fbe <vmm_init+0x274>
        sum += i;
ffffffffc0200fc8:	6705                	lui	a4,0x1
ffffffffc0200fca:	10000793          	li	a5,256
ffffffffc0200fce:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200fd2:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200fd6:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200fda:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200fdc:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200fde:	fec79ce3          	bne	a5,a2,ffffffffc0200fd6 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0200fe2:	28071663          	bnez	a4,ffffffffc020126e <vmm_init+0x524>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fe6:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200fea:	00014a97          	auipc	s5,0x14
ffffffffc0200fee:	5a6a8a93          	addi	s5,s5,1446 # ffffffffc0215590 <npage>
ffffffffc0200ff2:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200ff6:	078a                	slli	a5,a5,0x2
ffffffffc0200ff8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200ffa:	28c7fa63          	bgeu	a5,a2,ffffffffc020128e <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ffe:	00006a17          	auipc	s4,0x6
ffffffffc0201002:	f5aa3a03          	ld	s4,-166(s4) # ffffffffc0206f58 <nbase>
ffffffffc0201006:	414787b3          	sub	a5,a5,s4
ffffffffc020100a:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc020100c:	8799                	srai	a5,a5,0x6
ffffffffc020100e:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0201010:	00c79713          	slli	a4,a5,0xc
ffffffffc0201014:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201016:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020101a:	28c77663          	bgeu	a4,a2,ffffffffc02012a6 <vmm_init+0x55c>
ffffffffc020101e:	00014997          	auipc	s3,0x14
ffffffffc0201022:	58a9b983          	ld	s3,1418(s3) # ffffffffc02155a8 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201026:	4581                	li	a1,0
ffffffffc0201028:	854a                	mv	a0,s2
ffffffffc020102a:	99b6                	add	s3,s3,a3
ffffffffc020102c:	2a8020ef          	jal	ra,ffffffffc02032d4 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201030:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201034:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201038:	078a                	slli	a5,a5,0x2
ffffffffc020103a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020103c:	24e7f963          	bgeu	a5,a4,ffffffffc020128e <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0201040:	00014997          	auipc	s3,0x14
ffffffffc0201044:	55898993          	addi	s3,s3,1368 # ffffffffc0215598 <pages>
ffffffffc0201048:	0009b503          	ld	a0,0(s3)
ffffffffc020104c:	414787b3          	sub	a5,a5,s4
ffffffffc0201050:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201052:	953e                	add	a0,a0,a5
ffffffffc0201054:	4585                	li	a1,1
ffffffffc0201056:	7df010ef          	jal	ra,ffffffffc0203034 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020105a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020105e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201062:	078a                	slli	a5,a5,0x2
ffffffffc0201064:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201066:	22e7f463          	bgeu	a5,a4,ffffffffc020128e <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc020106a:	0009b503          	ld	a0,0(s3)
ffffffffc020106e:	414787b3          	sub	a5,a5,s4
ffffffffc0201072:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201074:	4585                	li	a1,1
ffffffffc0201076:	953e                	add	a0,a0,a5
ffffffffc0201078:	7bd010ef          	jal	ra,ffffffffc0203034 <free_pages>
    pgdir[0] = 0;
ffffffffc020107c:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc0201080:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201084:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201086:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020108a:	00a40c63          	beq	s0,a0,ffffffffc02010a2 <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc020108e:	6118                	ld	a4,0(a0)
ffffffffc0201090:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201092:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0201094:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201096:	e398                	sd	a4,0(a5)
ffffffffc0201098:	233000ef          	jal	ra,ffffffffc0201aca <kfree>
    return listelm->next;
ffffffffc020109c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020109e:	fea418e3          	bne	s0,a0,ffffffffc020108e <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc02010a2:	8522                	mv	a0,s0
ffffffffc02010a4:	227000ef          	jal	ra,ffffffffc0201aca <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc02010a8:	00014797          	auipc	a5,0x14
ffffffffc02010ac:	4a07b423          	sd	zero,1192(a5) # ffffffffc0215550 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02010b0:	7c5010ef          	jal	ra,ffffffffc0203074 <nr_free_pages>
ffffffffc02010b4:	20a49563          	bne	s1,a0,ffffffffc02012be <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02010b8:	00005517          	auipc	a0,0x5
ffffffffc02010bc:	a1850513          	addi	a0,a0,-1512 # ffffffffc0205ad0 <commands+0x9d0>
ffffffffc02010c0:	80cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02010c4:	7442                	ld	s0,48(sp)
ffffffffc02010c6:	70e2                	ld	ra,56(sp)
ffffffffc02010c8:	74a2                	ld	s1,40(sp)
ffffffffc02010ca:	7902                	ld	s2,32(sp)
ffffffffc02010cc:	69e2                	ld	s3,24(sp)
ffffffffc02010ce:	6a42                	ld	s4,16(sp)
ffffffffc02010d0:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010d2:	00005517          	auipc	a0,0x5
ffffffffc02010d6:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0205af0 <commands+0x9f0>
}
ffffffffc02010da:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010dc:	ff1fe06f          	j	ffffffffc02000cc <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02010e0:	236010ef          	jal	ra,ffffffffc0202316 <swap_init_mm>
ffffffffc02010e4:	b541                	j	ffffffffc0200f64 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02010e6:	00004697          	auipc	a3,0x4
ffffffffc02010ea:	7e268693          	addi	a3,a3,2018 # ffffffffc02058c8 <commands+0x7c8>
ffffffffc02010ee:	00004617          	auipc	a2,0x4
ffffffffc02010f2:	73a60613          	addi	a2,a2,1850 # ffffffffc0205828 <commands+0x728>
ffffffffc02010f6:	0d800593          	li	a1,216
ffffffffc02010fa:	00004517          	auipc	a0,0x4
ffffffffc02010fe:	74650513          	addi	a0,a0,1862 # ffffffffc0205840 <commands+0x740>
ffffffffc0201102:	8c6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201106:	00005697          	auipc	a3,0x5
ffffffffc020110a:	84a68693          	addi	a3,a3,-1974 # ffffffffc0205950 <commands+0x850>
ffffffffc020110e:	00004617          	auipc	a2,0x4
ffffffffc0201112:	71a60613          	addi	a2,a2,1818 # ffffffffc0205828 <commands+0x728>
ffffffffc0201116:	0e800593          	li	a1,232
ffffffffc020111a:	00004517          	auipc	a0,0x4
ffffffffc020111e:	72650513          	addi	a0,a0,1830 # ffffffffc0205840 <commands+0x740>
ffffffffc0201122:	8a6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201126:	00005697          	auipc	a3,0x5
ffffffffc020112a:	85a68693          	addi	a3,a3,-1958 # ffffffffc0205980 <commands+0x880>
ffffffffc020112e:	00004617          	auipc	a2,0x4
ffffffffc0201132:	6fa60613          	addi	a2,a2,1786 # ffffffffc0205828 <commands+0x728>
ffffffffc0201136:	0e900593          	li	a1,233
ffffffffc020113a:	00004517          	auipc	a0,0x4
ffffffffc020113e:	70650513          	addi	a0,a0,1798 # ffffffffc0205840 <commands+0x740>
ffffffffc0201142:	886ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201146:	00004697          	auipc	a3,0x4
ffffffffc020114a:	76a68693          	addi	a3,a3,1898 # ffffffffc02058b0 <commands+0x7b0>
ffffffffc020114e:	00004617          	auipc	a2,0x4
ffffffffc0201152:	6da60613          	addi	a2,a2,1754 # ffffffffc0205828 <commands+0x728>
ffffffffc0201156:	0d600593          	li	a1,214
ffffffffc020115a:	00004517          	auipc	a0,0x4
ffffffffc020115e:	6e650513          	addi	a0,a0,1766 # ffffffffc0205840 <commands+0x740>
ffffffffc0201162:	866ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma4 == NULL);
ffffffffc0201166:	00004697          	auipc	a3,0x4
ffffffffc020116a:	7ca68693          	addi	a3,a3,1994 # ffffffffc0205930 <commands+0x830>
ffffffffc020116e:	00004617          	auipc	a2,0x4
ffffffffc0201172:	6ba60613          	addi	a2,a2,1722 # ffffffffc0205828 <commands+0x728>
ffffffffc0201176:	0e400593          	li	a1,228
ffffffffc020117a:	00004517          	auipc	a0,0x4
ffffffffc020117e:	6c650513          	addi	a0,a0,1734 # ffffffffc0205840 <commands+0x740>
ffffffffc0201182:	846ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma5 == NULL);
ffffffffc0201186:	00004697          	auipc	a3,0x4
ffffffffc020118a:	7ba68693          	addi	a3,a3,1978 # ffffffffc0205940 <commands+0x840>
ffffffffc020118e:	00004617          	auipc	a2,0x4
ffffffffc0201192:	69a60613          	addi	a2,a2,1690 # ffffffffc0205828 <commands+0x728>
ffffffffc0201196:	0e600593          	li	a1,230
ffffffffc020119a:	00004517          	auipc	a0,0x4
ffffffffc020119e:	6a650513          	addi	a0,a0,1702 # ffffffffc0205840 <commands+0x740>
ffffffffc02011a2:	826ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1 != NULL);
ffffffffc02011a6:	00004697          	auipc	a3,0x4
ffffffffc02011aa:	75a68693          	addi	a3,a3,1882 # ffffffffc0205900 <commands+0x800>
ffffffffc02011ae:	00004617          	auipc	a2,0x4
ffffffffc02011b2:	67a60613          	addi	a2,a2,1658 # ffffffffc0205828 <commands+0x728>
ffffffffc02011b6:	0de00593          	li	a1,222
ffffffffc02011ba:	00004517          	auipc	a0,0x4
ffffffffc02011be:	68650513          	addi	a0,a0,1670 # ffffffffc0205840 <commands+0x740>
ffffffffc02011c2:	806ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2 != NULL);
ffffffffc02011c6:	00004697          	auipc	a3,0x4
ffffffffc02011ca:	74a68693          	addi	a3,a3,1866 # ffffffffc0205910 <commands+0x810>
ffffffffc02011ce:	00004617          	auipc	a2,0x4
ffffffffc02011d2:	65a60613          	addi	a2,a2,1626 # ffffffffc0205828 <commands+0x728>
ffffffffc02011d6:	0e000593          	li	a1,224
ffffffffc02011da:	00004517          	auipc	a0,0x4
ffffffffc02011de:	66650513          	addi	a0,a0,1638 # ffffffffc0205840 <commands+0x740>
ffffffffc02011e2:	fe7fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma3 == NULL);
ffffffffc02011e6:	00004697          	auipc	a3,0x4
ffffffffc02011ea:	73a68693          	addi	a3,a3,1850 # ffffffffc0205920 <commands+0x820>
ffffffffc02011ee:	00004617          	auipc	a2,0x4
ffffffffc02011f2:	63a60613          	addi	a2,a2,1594 # ffffffffc0205828 <commands+0x728>
ffffffffc02011f6:	0e200593          	li	a1,226
ffffffffc02011fa:	00004517          	auipc	a0,0x4
ffffffffc02011fe:	64650513          	addi	a0,a0,1606 # ffffffffc0205840 <commands+0x740>
ffffffffc0201202:	fc7fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201206:	00005697          	auipc	a3,0x5
ffffffffc020120a:	91268693          	addi	a3,a3,-1774 # ffffffffc0205b18 <commands+0xa18>
ffffffffc020120e:	00004617          	auipc	a2,0x4
ffffffffc0201212:	61a60613          	addi	a2,a2,1562 # ffffffffc0205828 <commands+0x728>
ffffffffc0201216:	10100593          	li	a1,257
ffffffffc020121a:	00004517          	auipc	a0,0x4
ffffffffc020121e:	62650513          	addi	a0,a0,1574 # ffffffffc0205840 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201222:	00014797          	auipc	a5,0x14
ffffffffc0201226:	3207b723          	sd	zero,814(a5) # ffffffffc0215550 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020122a:	f9ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(vma != NULL);
ffffffffc020122e:	00005697          	auipc	a3,0x5
ffffffffc0201232:	8da68693          	addi	a3,a3,-1830 # ffffffffc0205b08 <commands+0xa08>
ffffffffc0201236:	00004617          	auipc	a2,0x4
ffffffffc020123a:	5f260613          	addi	a2,a2,1522 # ffffffffc0205828 <commands+0x728>
ffffffffc020123e:	10800593          	li	a1,264
ffffffffc0201242:	00004517          	auipc	a0,0x4
ffffffffc0201246:	5fe50513          	addi	a0,a0,1534 # ffffffffc0205840 <commands+0x740>
ffffffffc020124a:	f7ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020124e:	00004697          	auipc	a3,0x4
ffffffffc0201252:	7d268693          	addi	a3,a3,2002 # ffffffffc0205a20 <commands+0x920>
ffffffffc0201256:	00004617          	auipc	a2,0x4
ffffffffc020125a:	5d260613          	addi	a2,a2,1490 # ffffffffc0205828 <commands+0x728>
ffffffffc020125e:	10d00593          	li	a1,269
ffffffffc0201262:	00004517          	auipc	a0,0x4
ffffffffc0201266:	5de50513          	addi	a0,a0,1502 # ffffffffc0205840 <commands+0x740>
ffffffffc020126a:	f5ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(sum == 0);
ffffffffc020126e:	00004697          	auipc	a3,0x4
ffffffffc0201272:	7d268693          	addi	a3,a3,2002 # ffffffffc0205a40 <commands+0x940>
ffffffffc0201276:	00004617          	auipc	a2,0x4
ffffffffc020127a:	5b260613          	addi	a2,a2,1458 # ffffffffc0205828 <commands+0x728>
ffffffffc020127e:	11700593          	li	a1,279
ffffffffc0201282:	00004517          	auipc	a0,0x4
ffffffffc0201286:	5be50513          	addi	a0,a0,1470 # ffffffffc0205840 <commands+0x740>
ffffffffc020128a:	f3ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020128e:	00004617          	auipc	a2,0x4
ffffffffc0201292:	7c260613          	addi	a2,a2,1986 # ffffffffc0205a50 <commands+0x950>
ffffffffc0201296:	06200593          	li	a1,98
ffffffffc020129a:	00004517          	auipc	a0,0x4
ffffffffc020129e:	7d650513          	addi	a0,a0,2006 # ffffffffc0205a70 <commands+0x970>
ffffffffc02012a2:	f27fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc02012a6:	00004617          	auipc	a2,0x4
ffffffffc02012aa:	7da60613          	addi	a2,a2,2010 # ffffffffc0205a80 <commands+0x980>
ffffffffc02012ae:	06900593          	li	a1,105
ffffffffc02012b2:	00004517          	auipc	a0,0x4
ffffffffc02012b6:	7be50513          	addi	a0,a0,1982 # ffffffffc0205a70 <commands+0x970>
ffffffffc02012ba:	f0ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02012be:	00004697          	auipc	a3,0x4
ffffffffc02012c2:	7ea68693          	addi	a3,a3,2026 # ffffffffc0205aa8 <commands+0x9a8>
ffffffffc02012c6:	00004617          	auipc	a2,0x4
ffffffffc02012ca:	56260613          	addi	a2,a2,1378 # ffffffffc0205828 <commands+0x728>
ffffffffc02012ce:	12400593          	li	a1,292
ffffffffc02012d2:	00004517          	auipc	a0,0x4
ffffffffc02012d6:	56e50513          	addi	a0,a0,1390 # ffffffffc0205840 <commands+0x740>
ffffffffc02012da:	eeffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02012de:	00004697          	auipc	a3,0x4
ffffffffc02012e2:	73268693          	addi	a3,a3,1842 # ffffffffc0205a10 <commands+0x910>
ffffffffc02012e6:	00004617          	auipc	a2,0x4
ffffffffc02012ea:	54260613          	addi	a2,a2,1346 # ffffffffc0205828 <commands+0x728>
ffffffffc02012ee:	10500593          	li	a1,261
ffffffffc02012f2:	00004517          	auipc	a0,0x4
ffffffffc02012f6:	54e50513          	addi	a0,a0,1358 # ffffffffc0205840 <commands+0x740>
ffffffffc02012fa:	ecffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(mm != NULL);
ffffffffc02012fe:	00005697          	auipc	a3,0x5
ffffffffc0201302:	83268693          	addi	a3,a3,-1998 # ffffffffc0205b30 <commands+0xa30>
ffffffffc0201306:	00004617          	auipc	a2,0x4
ffffffffc020130a:	52260613          	addi	a2,a2,1314 # ffffffffc0205828 <commands+0x728>
ffffffffc020130e:	0c200593          	li	a1,194
ffffffffc0201312:	00004517          	auipc	a0,0x4
ffffffffc0201316:	52e50513          	addi	a0,a0,1326 # ffffffffc0205840 <commands+0x740>
ffffffffc020131a:	eaffe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020131e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020131e:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201320:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0201322:	f022                	sd	s0,32(sp)
ffffffffc0201324:	ec26                	sd	s1,24(sp)
ffffffffc0201326:	f406                	sd	ra,40(sp)
ffffffffc0201328:	e84a                	sd	s2,16(sp)
ffffffffc020132a:	8432                	mv	s0,a2
ffffffffc020132c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020132e:	8dfff0ef          	jal	ra,ffffffffc0200c0c <find_vma>

    pgfault_num++;
ffffffffc0201332:	00014797          	auipc	a5,0x14
ffffffffc0201336:	2267a783          	lw	a5,550(a5) # ffffffffc0215558 <pgfault_num>
ffffffffc020133a:	2785                	addiw	a5,a5,1
ffffffffc020133c:	00014717          	auipc	a4,0x14
ffffffffc0201340:	20f72e23          	sw	a5,540(a4) # ffffffffc0215558 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201344:	c541                	beqz	a0,ffffffffc02013cc <do_pgfault+0xae>
ffffffffc0201346:	651c                	ld	a5,8(a0)
ffffffffc0201348:	08f46263          	bltu	s0,a5,ffffffffc02013cc <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020134c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020134e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201350:	8b89                	andi	a5,a5,2
ffffffffc0201352:	ebb9                	bnez	a5,ffffffffc02013a8 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201354:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201356:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201358:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020135a:	4605                	li	a2,1
ffffffffc020135c:	85a2                	mv	a1,s0
ffffffffc020135e:	551010ef          	jal	ra,ffffffffc02030ae <get_pte>
ffffffffc0201362:	c551                	beqz	a0,ffffffffc02013ee <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201364:	610c                	ld	a1,0(a0)
ffffffffc0201366:	c1b9                	beqz	a1,ffffffffc02013ac <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201368:	00014797          	auipc	a5,0x14
ffffffffc020136c:	2107a783          	lw	a5,528(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc0201370:	c7bd                	beqz	a5,ffffffffc02013de <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0201372:	85a2                	mv	a1,s0
ffffffffc0201374:	0030                	addi	a2,sp,8
ffffffffc0201376:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201378:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc020137a:	0c8010ef          	jal	ra,ffffffffc0202442 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020137e:	65a2                	ld	a1,8(sp)
ffffffffc0201380:	6c88                	ld	a0,24(s1)
ffffffffc0201382:	86ca                	mv	a3,s2
ffffffffc0201384:	8622                	mv	a2,s0
ffffffffc0201386:	7eb010ef          	jal	ra,ffffffffc0203370 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc020138a:	6622                	ld	a2,8(sp)
ffffffffc020138c:	4685                	li	a3,1
ffffffffc020138e:	85a2                	mv	a1,s0
ffffffffc0201390:	8526                	mv	a0,s1
ffffffffc0201392:	791000ef          	jal	ra,ffffffffc0202322 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0201396:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0201398:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc020139a:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc020139c:	70a2                	ld	ra,40(sp)
ffffffffc020139e:	7402                	ld	s0,32(sp)
ffffffffc02013a0:	64e2                	ld	s1,24(sp)
ffffffffc02013a2:	6942                	ld	s2,16(sp)
ffffffffc02013a4:	6145                	addi	sp,sp,48
ffffffffc02013a6:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02013a8:	495d                	li	s2,23
ffffffffc02013aa:	b76d                	j	ffffffffc0201354 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02013ac:	6c88                	ld	a0,24(s1)
ffffffffc02013ae:	864a                	mv	a2,s2
ffffffffc02013b0:	85a2                	mv	a1,s0
ffffffffc02013b2:	455020ef          	jal	ra,ffffffffc0204006 <pgdir_alloc_page>
ffffffffc02013b6:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02013b8:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02013ba:	f3ed                	bnez	a5,ffffffffc020139c <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02013bc:	00004517          	auipc	a0,0x4
ffffffffc02013c0:	7d450513          	addi	a0,a0,2004 # ffffffffc0205b90 <commands+0xa90>
ffffffffc02013c4:	d09fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013c8:	5571                	li	a0,-4
            goto failed;
ffffffffc02013ca:	bfc9                	j	ffffffffc020139c <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02013cc:	85a2                	mv	a1,s0
ffffffffc02013ce:	00004517          	auipc	a0,0x4
ffffffffc02013d2:	77250513          	addi	a0,a0,1906 # ffffffffc0205b40 <commands+0xa40>
ffffffffc02013d6:	cf7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02013da:	5575                	li	a0,-3
        goto failed;
ffffffffc02013dc:	b7c1                	j	ffffffffc020139c <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02013de:	00004517          	auipc	a0,0x4
ffffffffc02013e2:	7da50513          	addi	a0,a0,2010 # ffffffffc0205bb8 <commands+0xab8>
ffffffffc02013e6:	ce7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013ea:	5571                	li	a0,-4
            goto failed;
ffffffffc02013ec:	bf45                	j	ffffffffc020139c <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02013ee:	00004517          	auipc	a0,0x4
ffffffffc02013f2:	78250513          	addi	a0,a0,1922 # ffffffffc0205b70 <commands+0xa70>
ffffffffc02013f6:	cd7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013fa:	5571                	li	a0,-4
        goto failed;
ffffffffc02013fc:	b745                	j	ffffffffc020139c <do_pgfault+0x7e>

ffffffffc02013fe <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02013fe:	00010797          	auipc	a5,0x10
ffffffffc0201402:	06278793          	addi	a5,a5,98 # ffffffffc0211460 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201406:	f51c                	sd	a5,40(a0)
ffffffffc0201408:	e79c                	sd	a5,8(a5)
ffffffffc020140a:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020140c:	4501                	li	a0,0
ffffffffc020140e:	8082                	ret

ffffffffc0201410 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201410:	4501                	li	a0,0
ffffffffc0201412:	8082                	ret

ffffffffc0201414 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201414:	4501                	li	a0,0
ffffffffc0201416:	8082                	ret

ffffffffc0201418 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201418:	4501                	li	a0,0
ffffffffc020141a:	8082                	ret

ffffffffc020141c <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020141c:	711d                	addi	sp,sp,-96
ffffffffc020141e:	fc4e                	sd	s3,56(sp)
ffffffffc0201420:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201422:	00004517          	auipc	a0,0x4
ffffffffc0201426:	7be50513          	addi	a0,a0,1982 # ffffffffc0205be0 <commands+0xae0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020142a:	698d                	lui	s3,0x3
ffffffffc020142c:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020142e:	e0ca                	sd	s2,64(sp)
ffffffffc0201430:	ec86                	sd	ra,88(sp)
ffffffffc0201432:	e8a2                	sd	s0,80(sp)
ffffffffc0201434:	e4a6                	sd	s1,72(sp)
ffffffffc0201436:	f456                	sd	s5,40(sp)
ffffffffc0201438:	f05a                	sd	s6,32(sp)
ffffffffc020143a:	ec5e                	sd	s7,24(sp)
ffffffffc020143c:	e862                	sd	s8,16(sp)
ffffffffc020143e:	e466                	sd	s9,8(sp)
ffffffffc0201440:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201442:	c8bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201446:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc020144a:	00014917          	auipc	s2,0x14
ffffffffc020144e:	10e92903          	lw	s2,270(s2) # ffffffffc0215558 <pgfault_num>
ffffffffc0201452:	4791                	li	a5,4
ffffffffc0201454:	14f91e63          	bne	s2,a5,ffffffffc02015b0 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201458:	00004517          	auipc	a0,0x4
ffffffffc020145c:	7d850513          	addi	a0,a0,2008 # ffffffffc0205c30 <commands+0xb30>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201460:	6a85                	lui	s5,0x1
ffffffffc0201462:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201464:	c69fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201468:	00014417          	auipc	s0,0x14
ffffffffc020146c:	0f040413          	addi	s0,s0,240 # ffffffffc0215558 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201470:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201474:	4004                	lw	s1,0(s0)
ffffffffc0201476:	2481                	sext.w	s1,s1
ffffffffc0201478:	2b249c63          	bne	s1,s2,ffffffffc0201730 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020147c:	00004517          	auipc	a0,0x4
ffffffffc0201480:	7dc50513          	addi	a0,a0,2012 # ffffffffc0205c58 <commands+0xb58>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201484:	6b91                	lui	s7,0x4
ffffffffc0201486:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201488:	c45fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020148c:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0201490:	00042903          	lw	s2,0(s0)
ffffffffc0201494:	2901                	sext.w	s2,s2
ffffffffc0201496:	26991d63          	bne	s2,s1,ffffffffc0201710 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020149a:	00004517          	auipc	a0,0x4
ffffffffc020149e:	7e650513          	addi	a0,a0,2022 # ffffffffc0205c80 <commands+0xb80>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014a2:	6c89                	lui	s9,0x2
ffffffffc02014a4:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014a6:	c27fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014aa:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02014ae:	401c                	lw	a5,0(s0)
ffffffffc02014b0:	2781                	sext.w	a5,a5
ffffffffc02014b2:	23279f63          	bne	a5,s2,ffffffffc02016f0 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02014b6:	00004517          	auipc	a0,0x4
ffffffffc02014ba:	7f250513          	addi	a0,a0,2034 # ffffffffc0205ca8 <commands+0xba8>
ffffffffc02014be:	c0ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02014c2:	6795                	lui	a5,0x5
ffffffffc02014c4:	4739                	li	a4,14
ffffffffc02014c6:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02014ca:	4004                	lw	s1,0(s0)
ffffffffc02014cc:	4795                	li	a5,5
ffffffffc02014ce:	2481                	sext.w	s1,s1
ffffffffc02014d0:	20f49063          	bne	s1,a5,ffffffffc02016d0 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014d4:	00004517          	auipc	a0,0x4
ffffffffc02014d8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205c80 <commands+0xb80>
ffffffffc02014dc:	bf1fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014e0:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc02014e4:	401c                	lw	a5,0(s0)
ffffffffc02014e6:	2781                	sext.w	a5,a5
ffffffffc02014e8:	1c979463          	bne	a5,s1,ffffffffc02016b0 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02014ec:	00004517          	auipc	a0,0x4
ffffffffc02014f0:	74450513          	addi	a0,a0,1860 # ffffffffc0205c30 <commands+0xb30>
ffffffffc02014f4:	bd9fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014f8:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02014fc:	401c                	lw	a5,0(s0)
ffffffffc02014fe:	4719                	li	a4,6
ffffffffc0201500:	2781                	sext.w	a5,a5
ffffffffc0201502:	18e79763          	bne	a5,a4,ffffffffc0201690 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201506:	00004517          	auipc	a0,0x4
ffffffffc020150a:	77a50513          	addi	a0,a0,1914 # ffffffffc0205c80 <commands+0xb80>
ffffffffc020150e:	bbffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201512:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201516:	401c                	lw	a5,0(s0)
ffffffffc0201518:	471d                	li	a4,7
ffffffffc020151a:	2781                	sext.w	a5,a5
ffffffffc020151c:	14e79a63          	bne	a5,a4,ffffffffc0201670 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201520:	00004517          	auipc	a0,0x4
ffffffffc0201524:	6c050513          	addi	a0,a0,1728 # ffffffffc0205be0 <commands+0xae0>
ffffffffc0201528:	ba5fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020152c:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201530:	401c                	lw	a5,0(s0)
ffffffffc0201532:	4721                	li	a4,8
ffffffffc0201534:	2781                	sext.w	a5,a5
ffffffffc0201536:	10e79d63          	bne	a5,a4,ffffffffc0201650 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020153a:	00004517          	auipc	a0,0x4
ffffffffc020153e:	71e50513          	addi	a0,a0,1822 # ffffffffc0205c58 <commands+0xb58>
ffffffffc0201542:	b8bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201546:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc020154a:	401c                	lw	a5,0(s0)
ffffffffc020154c:	4725                	li	a4,9
ffffffffc020154e:	2781                	sext.w	a5,a5
ffffffffc0201550:	0ee79063          	bne	a5,a4,ffffffffc0201630 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201554:	00004517          	auipc	a0,0x4
ffffffffc0201558:	75450513          	addi	a0,a0,1876 # ffffffffc0205ca8 <commands+0xba8>
ffffffffc020155c:	b71fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201560:	6795                	lui	a5,0x5
ffffffffc0201562:	4739                	li	a4,14
ffffffffc0201564:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201568:	4004                	lw	s1,0(s0)
ffffffffc020156a:	47a9                	li	a5,10
ffffffffc020156c:	2481                	sext.w	s1,s1
ffffffffc020156e:	0af49163          	bne	s1,a5,ffffffffc0201610 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201572:	00004517          	auipc	a0,0x4
ffffffffc0201576:	6be50513          	addi	a0,a0,1726 # ffffffffc0205c30 <commands+0xb30>
ffffffffc020157a:	b53fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020157e:	6785                	lui	a5,0x1
ffffffffc0201580:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201584:	06979663          	bne	a5,s1,ffffffffc02015f0 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201588:	401c                	lw	a5,0(s0)
ffffffffc020158a:	472d                	li	a4,11
ffffffffc020158c:	2781                	sext.w	a5,a5
ffffffffc020158e:	04e79163          	bne	a5,a4,ffffffffc02015d0 <_fifo_check_swap+0x1b4>
}
ffffffffc0201592:	60e6                	ld	ra,88(sp)
ffffffffc0201594:	6446                	ld	s0,80(sp)
ffffffffc0201596:	64a6                	ld	s1,72(sp)
ffffffffc0201598:	6906                	ld	s2,64(sp)
ffffffffc020159a:	79e2                	ld	s3,56(sp)
ffffffffc020159c:	7a42                	ld	s4,48(sp)
ffffffffc020159e:	7aa2                	ld	s5,40(sp)
ffffffffc02015a0:	7b02                	ld	s6,32(sp)
ffffffffc02015a2:	6be2                	ld	s7,24(sp)
ffffffffc02015a4:	6c42                	ld	s8,16(sp)
ffffffffc02015a6:	6ca2                	ld	s9,8(sp)
ffffffffc02015a8:	6d02                	ld	s10,0(sp)
ffffffffc02015aa:	4501                	li	a0,0
ffffffffc02015ac:	6125                	addi	sp,sp,96
ffffffffc02015ae:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02015b0:	00004697          	auipc	a3,0x4
ffffffffc02015b4:	65868693          	addi	a3,a3,1624 # ffffffffc0205c08 <commands+0xb08>
ffffffffc02015b8:	00004617          	auipc	a2,0x4
ffffffffc02015bc:	27060613          	addi	a2,a2,624 # ffffffffc0205828 <commands+0x728>
ffffffffc02015c0:	05100593          	li	a1,81
ffffffffc02015c4:	00004517          	auipc	a0,0x4
ffffffffc02015c8:	65450513          	addi	a0,a0,1620 # ffffffffc0205c18 <commands+0xb18>
ffffffffc02015cc:	bfdfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==11);
ffffffffc02015d0:	00004697          	auipc	a3,0x4
ffffffffc02015d4:	78868693          	addi	a3,a3,1928 # ffffffffc0205d58 <commands+0xc58>
ffffffffc02015d8:	00004617          	auipc	a2,0x4
ffffffffc02015dc:	25060613          	addi	a2,a2,592 # ffffffffc0205828 <commands+0x728>
ffffffffc02015e0:	07300593          	li	a1,115
ffffffffc02015e4:	00004517          	auipc	a0,0x4
ffffffffc02015e8:	63450513          	addi	a0,a0,1588 # ffffffffc0205c18 <commands+0xb18>
ffffffffc02015ec:	bddfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02015f0:	00004697          	auipc	a3,0x4
ffffffffc02015f4:	74068693          	addi	a3,a3,1856 # ffffffffc0205d30 <commands+0xc30>
ffffffffc02015f8:	00004617          	auipc	a2,0x4
ffffffffc02015fc:	23060613          	addi	a2,a2,560 # ffffffffc0205828 <commands+0x728>
ffffffffc0201600:	07100593          	li	a1,113
ffffffffc0201604:	00004517          	auipc	a0,0x4
ffffffffc0201608:	61450513          	addi	a0,a0,1556 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020160c:	bbdfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==10);
ffffffffc0201610:	00004697          	auipc	a3,0x4
ffffffffc0201614:	71068693          	addi	a3,a3,1808 # ffffffffc0205d20 <commands+0xc20>
ffffffffc0201618:	00004617          	auipc	a2,0x4
ffffffffc020161c:	21060613          	addi	a2,a2,528 # ffffffffc0205828 <commands+0x728>
ffffffffc0201620:	06f00593          	li	a1,111
ffffffffc0201624:	00004517          	auipc	a0,0x4
ffffffffc0201628:	5f450513          	addi	a0,a0,1524 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020162c:	b9dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==9);
ffffffffc0201630:	00004697          	auipc	a3,0x4
ffffffffc0201634:	6e068693          	addi	a3,a3,1760 # ffffffffc0205d10 <commands+0xc10>
ffffffffc0201638:	00004617          	auipc	a2,0x4
ffffffffc020163c:	1f060613          	addi	a2,a2,496 # ffffffffc0205828 <commands+0x728>
ffffffffc0201640:	06c00593          	li	a1,108
ffffffffc0201644:	00004517          	auipc	a0,0x4
ffffffffc0201648:	5d450513          	addi	a0,a0,1492 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020164c:	b7dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==8);
ffffffffc0201650:	00004697          	auipc	a3,0x4
ffffffffc0201654:	6b068693          	addi	a3,a3,1712 # ffffffffc0205d00 <commands+0xc00>
ffffffffc0201658:	00004617          	auipc	a2,0x4
ffffffffc020165c:	1d060613          	addi	a2,a2,464 # ffffffffc0205828 <commands+0x728>
ffffffffc0201660:	06900593          	li	a1,105
ffffffffc0201664:	00004517          	auipc	a0,0x4
ffffffffc0201668:	5b450513          	addi	a0,a0,1460 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020166c:	b5dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==7);
ffffffffc0201670:	00004697          	auipc	a3,0x4
ffffffffc0201674:	68068693          	addi	a3,a3,1664 # ffffffffc0205cf0 <commands+0xbf0>
ffffffffc0201678:	00004617          	auipc	a2,0x4
ffffffffc020167c:	1b060613          	addi	a2,a2,432 # ffffffffc0205828 <commands+0x728>
ffffffffc0201680:	06600593          	li	a1,102
ffffffffc0201684:	00004517          	auipc	a0,0x4
ffffffffc0201688:	59450513          	addi	a0,a0,1428 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020168c:	b3dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==6);
ffffffffc0201690:	00004697          	auipc	a3,0x4
ffffffffc0201694:	65068693          	addi	a3,a3,1616 # ffffffffc0205ce0 <commands+0xbe0>
ffffffffc0201698:	00004617          	auipc	a2,0x4
ffffffffc020169c:	19060613          	addi	a2,a2,400 # ffffffffc0205828 <commands+0x728>
ffffffffc02016a0:	06300593          	li	a1,99
ffffffffc02016a4:	00004517          	auipc	a0,0x4
ffffffffc02016a8:	57450513          	addi	a0,a0,1396 # ffffffffc0205c18 <commands+0xb18>
ffffffffc02016ac:	b1dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc02016b0:	00004697          	auipc	a3,0x4
ffffffffc02016b4:	62068693          	addi	a3,a3,1568 # ffffffffc0205cd0 <commands+0xbd0>
ffffffffc02016b8:	00004617          	auipc	a2,0x4
ffffffffc02016bc:	17060613          	addi	a2,a2,368 # ffffffffc0205828 <commands+0x728>
ffffffffc02016c0:	06000593          	li	a1,96
ffffffffc02016c4:	00004517          	auipc	a0,0x4
ffffffffc02016c8:	55450513          	addi	a0,a0,1364 # ffffffffc0205c18 <commands+0xb18>
ffffffffc02016cc:	afdfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc02016d0:	00004697          	auipc	a3,0x4
ffffffffc02016d4:	60068693          	addi	a3,a3,1536 # ffffffffc0205cd0 <commands+0xbd0>
ffffffffc02016d8:	00004617          	auipc	a2,0x4
ffffffffc02016dc:	15060613          	addi	a2,a2,336 # ffffffffc0205828 <commands+0x728>
ffffffffc02016e0:	05d00593          	li	a1,93
ffffffffc02016e4:	00004517          	auipc	a0,0x4
ffffffffc02016e8:	53450513          	addi	a0,a0,1332 # ffffffffc0205c18 <commands+0xb18>
ffffffffc02016ec:	addfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc02016f0:	00004697          	auipc	a3,0x4
ffffffffc02016f4:	51868693          	addi	a3,a3,1304 # ffffffffc0205c08 <commands+0xb08>
ffffffffc02016f8:	00004617          	auipc	a2,0x4
ffffffffc02016fc:	13060613          	addi	a2,a2,304 # ffffffffc0205828 <commands+0x728>
ffffffffc0201700:	05a00593          	li	a1,90
ffffffffc0201704:	00004517          	auipc	a0,0x4
ffffffffc0201708:	51450513          	addi	a0,a0,1300 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020170c:	abdfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201710:	00004697          	auipc	a3,0x4
ffffffffc0201714:	4f868693          	addi	a3,a3,1272 # ffffffffc0205c08 <commands+0xb08>
ffffffffc0201718:	00004617          	auipc	a2,0x4
ffffffffc020171c:	11060613          	addi	a2,a2,272 # ffffffffc0205828 <commands+0x728>
ffffffffc0201720:	05700593          	li	a1,87
ffffffffc0201724:	00004517          	auipc	a0,0x4
ffffffffc0201728:	4f450513          	addi	a0,a0,1268 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020172c:	a9dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201730:	00004697          	auipc	a3,0x4
ffffffffc0201734:	4d868693          	addi	a3,a3,1240 # ffffffffc0205c08 <commands+0xb08>
ffffffffc0201738:	00004617          	auipc	a2,0x4
ffffffffc020173c:	0f060613          	addi	a2,a2,240 # ffffffffc0205828 <commands+0x728>
ffffffffc0201740:	05400593          	li	a1,84
ffffffffc0201744:	00004517          	auipc	a0,0x4
ffffffffc0201748:	4d450513          	addi	a0,a0,1236 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020174c:	a7dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201750 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201750:	751c                	ld	a5,40(a0)
{
ffffffffc0201752:	1141                	addi	sp,sp,-16
ffffffffc0201754:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201756:	cf91                	beqz	a5,ffffffffc0201772 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201758:	ee0d                	bnez	a2,ffffffffc0201792 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc020175a:	679c                	ld	a5,8(a5)
}
ffffffffc020175c:	60a2                	ld	ra,8(sp)
ffffffffc020175e:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201760:	6394                	ld	a3,0(a5)
ffffffffc0201762:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201764:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201768:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020176a:	e314                	sd	a3,0(a4)
ffffffffc020176c:	e19c                	sd	a5,0(a1)
}
ffffffffc020176e:	0141                	addi	sp,sp,16
ffffffffc0201770:	8082                	ret
         assert(head != NULL);
ffffffffc0201772:	00004697          	auipc	a3,0x4
ffffffffc0201776:	5f668693          	addi	a3,a3,1526 # ffffffffc0205d68 <commands+0xc68>
ffffffffc020177a:	00004617          	auipc	a2,0x4
ffffffffc020177e:	0ae60613          	addi	a2,a2,174 # ffffffffc0205828 <commands+0x728>
ffffffffc0201782:	04100593          	li	a1,65
ffffffffc0201786:	00004517          	auipc	a0,0x4
ffffffffc020178a:	49250513          	addi	a0,a0,1170 # ffffffffc0205c18 <commands+0xb18>
ffffffffc020178e:	a3bfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(in_tick==0);
ffffffffc0201792:	00004697          	auipc	a3,0x4
ffffffffc0201796:	5e668693          	addi	a3,a3,1510 # ffffffffc0205d78 <commands+0xc78>
ffffffffc020179a:	00004617          	auipc	a2,0x4
ffffffffc020179e:	08e60613          	addi	a2,a2,142 # ffffffffc0205828 <commands+0x728>
ffffffffc02017a2:	04200593          	li	a1,66
ffffffffc02017a6:	00004517          	auipc	a0,0x4
ffffffffc02017aa:	47250513          	addi	a0,a0,1138 # ffffffffc0205c18 <commands+0xb18>
ffffffffc02017ae:	a1bfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02017b2 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02017b2:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02017b4:	cb91                	beqz	a5,ffffffffc02017c8 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02017b6:	6394                	ld	a3,0(a5)
ffffffffc02017b8:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc02017bc:	e398                	sd	a4,0(a5)
ffffffffc02017be:	e698                	sd	a4,8(a3)
}
ffffffffc02017c0:	4501                	li	a0,0
    elm->next = next;
ffffffffc02017c2:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02017c4:	f614                	sd	a3,40(a2)
ffffffffc02017c6:	8082                	ret
{
ffffffffc02017c8:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02017ca:	00004697          	auipc	a3,0x4
ffffffffc02017ce:	5be68693          	addi	a3,a3,1470 # ffffffffc0205d88 <commands+0xc88>
ffffffffc02017d2:	00004617          	auipc	a2,0x4
ffffffffc02017d6:	05660613          	addi	a2,a2,86 # ffffffffc0205828 <commands+0x728>
ffffffffc02017da:	03200593          	li	a1,50
ffffffffc02017de:	00004517          	auipc	a0,0x4
ffffffffc02017e2:	43a50513          	addi	a0,a0,1082 # ffffffffc0205c18 <commands+0xb18>
{
ffffffffc02017e6:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02017e8:	9e1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02017ec <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02017ec:	c94d                	beqz	a0,ffffffffc020189e <slob_free+0xb2>
{
ffffffffc02017ee:	1141                	addi	sp,sp,-16
ffffffffc02017f0:	e022                	sd	s0,0(sp)
ffffffffc02017f2:	e406                	sd	ra,8(sp)
ffffffffc02017f4:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02017f6:	e9c1                	bnez	a1,ffffffffc0201886 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017f8:	100027f3          	csrr	a5,sstatus
ffffffffc02017fc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02017fe:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201800:	ebd9                	bnez	a5,ffffffffc0201896 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201802:	00009617          	auipc	a2,0x9
ffffffffc0201806:	84e60613          	addi	a2,a2,-1970 # ffffffffc020a050 <slobfree>
ffffffffc020180a:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020180c:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020180e:	679c                	ld	a5,8(a5)
ffffffffc0201810:	02877a63          	bgeu	a4,s0,ffffffffc0201844 <slob_free+0x58>
ffffffffc0201814:	00f46463          	bltu	s0,a5,ffffffffc020181c <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201818:	fef76ae3          	bltu	a4,a5,ffffffffc020180c <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc020181c:	400c                	lw	a1,0(s0)
ffffffffc020181e:	00459693          	slli	a3,a1,0x4
ffffffffc0201822:	96a2                	add	a3,a3,s0
ffffffffc0201824:	02d78a63          	beq	a5,a3,ffffffffc0201858 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201828:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020182a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020182c:	00469793          	slli	a5,a3,0x4
ffffffffc0201830:	97ba                	add	a5,a5,a4
ffffffffc0201832:	02f40e63          	beq	s0,a5,ffffffffc020186e <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201836:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201838:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020183a:	e129                	bnez	a0,ffffffffc020187c <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020183c:	60a2                	ld	ra,8(sp)
ffffffffc020183e:	6402                	ld	s0,0(sp)
ffffffffc0201840:	0141                	addi	sp,sp,16
ffffffffc0201842:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201844:	fcf764e3          	bltu	a4,a5,ffffffffc020180c <slob_free+0x20>
ffffffffc0201848:	fcf472e3          	bgeu	s0,a5,ffffffffc020180c <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc020184c:	400c                	lw	a1,0(s0)
ffffffffc020184e:	00459693          	slli	a3,a1,0x4
ffffffffc0201852:	96a2                	add	a3,a3,s0
ffffffffc0201854:	fcd79ae3          	bne	a5,a3,ffffffffc0201828 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201858:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020185a:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020185c:	9db5                	addw	a1,a1,a3
ffffffffc020185e:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201860:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201862:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201864:	00469793          	slli	a5,a3,0x4
ffffffffc0201868:	97ba                	add	a5,a5,a4
ffffffffc020186a:	fcf416e3          	bne	s0,a5,ffffffffc0201836 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020186e:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201870:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201872:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201874:	9ebd                	addw	a3,a3,a5
ffffffffc0201876:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201878:	e70c                	sd	a1,8(a4)
ffffffffc020187a:	d169                	beqz	a0,ffffffffc020183c <slob_free+0x50>
}
ffffffffc020187c:	6402                	ld	s0,0(sp)
ffffffffc020187e:	60a2                	ld	ra,8(sp)
ffffffffc0201880:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201882:	d3dfe06f          	j	ffffffffc02005be <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201886:	25bd                	addiw	a1,a1,15
ffffffffc0201888:	8191                	srli	a1,a1,0x4
ffffffffc020188a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020188c:	100027f3          	csrr	a5,sstatus
ffffffffc0201890:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201892:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201894:	d7bd                	beqz	a5,ffffffffc0201802 <slob_free+0x16>
        intr_disable();
ffffffffc0201896:	d2ffe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc020189a:	4505                	li	a0,1
ffffffffc020189c:	b79d                	j	ffffffffc0201802 <slob_free+0x16>
ffffffffc020189e:	8082                	ret

ffffffffc02018a0 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018a0:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018a2:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018a4:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018a8:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018aa:	6f8010ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
  if(!page)
ffffffffc02018ae:	c91d                	beqz	a0,ffffffffc02018e4 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02018b0:	00014697          	auipc	a3,0x14
ffffffffc02018b4:	ce86b683          	ld	a3,-792(a3) # ffffffffc0215598 <pages>
ffffffffc02018b8:	8d15                	sub	a0,a0,a3
ffffffffc02018ba:	8519                	srai	a0,a0,0x6
ffffffffc02018bc:	00005697          	auipc	a3,0x5
ffffffffc02018c0:	69c6b683          	ld	a3,1692(a3) # ffffffffc0206f58 <nbase>
ffffffffc02018c4:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02018c6:	00c51793          	slli	a5,a0,0xc
ffffffffc02018ca:	83b1                	srli	a5,a5,0xc
ffffffffc02018cc:	00014717          	auipc	a4,0x14
ffffffffc02018d0:	cc473703          	ld	a4,-828(a4) # ffffffffc0215590 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02018d4:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02018d6:	00e7fa63          	bgeu	a5,a4,ffffffffc02018ea <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02018da:	00014697          	auipc	a3,0x14
ffffffffc02018de:	cce6b683          	ld	a3,-818(a3) # ffffffffc02155a8 <va_pa_offset>
ffffffffc02018e2:	9536                	add	a0,a0,a3
}
ffffffffc02018e4:	60a2                	ld	ra,8(sp)
ffffffffc02018e6:	0141                	addi	sp,sp,16
ffffffffc02018e8:	8082                	ret
ffffffffc02018ea:	86aa                	mv	a3,a0
ffffffffc02018ec:	00004617          	auipc	a2,0x4
ffffffffc02018f0:	19460613          	addi	a2,a2,404 # ffffffffc0205a80 <commands+0x980>
ffffffffc02018f4:	06900593          	li	a1,105
ffffffffc02018f8:	00004517          	auipc	a0,0x4
ffffffffc02018fc:	17850513          	addi	a0,a0,376 # ffffffffc0205a70 <commands+0x970>
ffffffffc0201900:	8c9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201904 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201904:	1101                	addi	sp,sp,-32
ffffffffc0201906:	ec06                	sd	ra,24(sp)
ffffffffc0201908:	e822                	sd	s0,16(sp)
ffffffffc020190a:	e426                	sd	s1,8(sp)
ffffffffc020190c:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020190e:	01050713          	addi	a4,a0,16
ffffffffc0201912:	6785                	lui	a5,0x1
ffffffffc0201914:	0cf77363          	bgeu	a4,a5,ffffffffc02019da <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201918:	00f50493          	addi	s1,a0,15
ffffffffc020191c:	8091                	srli	s1,s1,0x4
ffffffffc020191e:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201920:	10002673          	csrr	a2,sstatus
ffffffffc0201924:	8a09                	andi	a2,a2,2
ffffffffc0201926:	e25d                	bnez	a2,ffffffffc02019cc <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201928:	00008917          	auipc	s2,0x8
ffffffffc020192c:	72890913          	addi	s2,s2,1832 # ffffffffc020a050 <slobfree>
ffffffffc0201930:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201934:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201936:	4398                	lw	a4,0(a5)
ffffffffc0201938:	08975e63          	bge	a4,s1,ffffffffc02019d4 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc020193c:	00d78b63          	beq	a5,a3,ffffffffc0201952 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201940:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201942:	4018                	lw	a4,0(s0)
ffffffffc0201944:	02975a63          	bge	a4,s1,ffffffffc0201978 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201948:	00093683          	ld	a3,0(s2)
ffffffffc020194c:	87a2                	mv	a5,s0
ffffffffc020194e:	fed799e3          	bne	a5,a3,ffffffffc0201940 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201952:	ee31                	bnez	a2,ffffffffc02019ae <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201954:	4501                	li	a0,0
ffffffffc0201956:	f4bff0ef          	jal	ra,ffffffffc02018a0 <__slob_get_free_pages.constprop.0>
ffffffffc020195a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020195c:	cd05                	beqz	a0,ffffffffc0201994 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020195e:	6585                	lui	a1,0x1
ffffffffc0201960:	e8dff0ef          	jal	ra,ffffffffc02017ec <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201964:	10002673          	csrr	a2,sstatus
ffffffffc0201968:	8a09                	andi	a2,a2,2
ffffffffc020196a:	ee05                	bnez	a2,ffffffffc02019a2 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc020196c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201970:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201972:	4018                	lw	a4,0(s0)
ffffffffc0201974:	fc974ae3          	blt	a4,s1,ffffffffc0201948 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201978:	04e48763          	beq	s1,a4,ffffffffc02019c6 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc020197c:	00449693          	slli	a3,s1,0x4
ffffffffc0201980:	96a2                	add	a3,a3,s0
ffffffffc0201982:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201984:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201986:	9f05                	subw	a4,a4,s1
ffffffffc0201988:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020198a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020198c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020198e:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201992:	e20d                	bnez	a2,ffffffffc02019b4 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201994:	60e2                	ld	ra,24(sp)
ffffffffc0201996:	8522                	mv	a0,s0
ffffffffc0201998:	6442                	ld	s0,16(sp)
ffffffffc020199a:	64a2                	ld	s1,8(sp)
ffffffffc020199c:	6902                	ld	s2,0(sp)
ffffffffc020199e:	6105                	addi	sp,sp,32
ffffffffc02019a0:	8082                	ret
        intr_disable();
ffffffffc02019a2:	c23fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
			cur = slobfree;
ffffffffc02019a6:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02019aa:	4605                	li	a2,1
ffffffffc02019ac:	b7d1                	j	ffffffffc0201970 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02019ae:	c11fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02019b2:	b74d                	j	ffffffffc0201954 <slob_alloc.constprop.0+0x50>
ffffffffc02019b4:	c0bfe0ef          	jal	ra,ffffffffc02005be <intr_enable>
}
ffffffffc02019b8:	60e2                	ld	ra,24(sp)
ffffffffc02019ba:	8522                	mv	a0,s0
ffffffffc02019bc:	6442                	ld	s0,16(sp)
ffffffffc02019be:	64a2                	ld	s1,8(sp)
ffffffffc02019c0:	6902                	ld	s2,0(sp)
ffffffffc02019c2:	6105                	addi	sp,sp,32
ffffffffc02019c4:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02019c6:	6418                	ld	a4,8(s0)
ffffffffc02019c8:	e798                	sd	a4,8(a5)
ffffffffc02019ca:	b7d1                	j	ffffffffc020198e <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02019cc:	bf9fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02019d0:	4605                	li	a2,1
ffffffffc02019d2:	bf99                	j	ffffffffc0201928 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019d4:	843e                	mv	s0,a5
ffffffffc02019d6:	87b6                	mv	a5,a3
ffffffffc02019d8:	b745                	j	ffffffffc0201978 <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019da:	00004697          	auipc	a3,0x4
ffffffffc02019de:	3e668693          	addi	a3,a3,998 # ffffffffc0205dc0 <commands+0xcc0>
ffffffffc02019e2:	00004617          	auipc	a2,0x4
ffffffffc02019e6:	e4660613          	addi	a2,a2,-442 # ffffffffc0205828 <commands+0x728>
ffffffffc02019ea:	06300593          	li	a1,99
ffffffffc02019ee:	00004517          	auipc	a0,0x4
ffffffffc02019f2:	3f250513          	addi	a0,a0,1010 # ffffffffc0205de0 <commands+0xce0>
ffffffffc02019f6:	fd2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02019fa <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02019fa:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02019fc:	00004517          	auipc	a0,0x4
ffffffffc0201a00:	3fc50513          	addi	a0,a0,1020 # ffffffffc0205df8 <commands+0xcf8>
kmalloc_init(void) {
ffffffffc0201a04:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201a06:	ec6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201a0a:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a0c:	00004517          	auipc	a0,0x4
ffffffffc0201a10:	40450513          	addi	a0,a0,1028 # ffffffffc0205e10 <commands+0xd10>
}
ffffffffc0201a14:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a16:	eb6fe06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0201a1a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201a1a:	1101                	addi	sp,sp,-32
ffffffffc0201a1c:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a1e:	6905                	lui	s2,0x1
{
ffffffffc0201a20:	e822                	sd	s0,16(sp)
ffffffffc0201a22:	ec06                	sd	ra,24(sp)
ffffffffc0201a24:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a26:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0201a2a:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a2c:	04a7f963          	bgeu	a5,a0,ffffffffc0201a7e <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201a30:	4561                	li	a0,24
ffffffffc0201a32:	ed3ff0ef          	jal	ra,ffffffffc0201904 <slob_alloc.constprop.0>
ffffffffc0201a36:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201a38:	c929                	beqz	a0,ffffffffc0201a8a <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201a3a:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201a3e:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a40:	00f95763          	bge	s2,a5,ffffffffc0201a4e <kmalloc+0x34>
ffffffffc0201a44:	6705                	lui	a4,0x1
ffffffffc0201a46:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201a48:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a4a:	fef74ee3          	blt	a4,a5,ffffffffc0201a46 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201a4e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201a50:	e51ff0ef          	jal	ra,ffffffffc02018a0 <__slob_get_free_pages.constprop.0>
ffffffffc0201a54:	e488                	sd	a0,8(s1)
ffffffffc0201a56:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201a58:	c525                	beqz	a0,ffffffffc0201ac0 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a5a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a5e:	8b89                	andi	a5,a5,2
ffffffffc0201a60:	ef8d                	bnez	a5,ffffffffc0201a9a <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201a62:	00014797          	auipc	a5,0x14
ffffffffc0201a66:	afe78793          	addi	a5,a5,-1282 # ffffffffc0215560 <bigblocks>
ffffffffc0201a6a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201a6c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201a6e:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201a70:	60e2                	ld	ra,24(sp)
ffffffffc0201a72:	8522                	mv	a0,s0
ffffffffc0201a74:	6442                	ld	s0,16(sp)
ffffffffc0201a76:	64a2                	ld	s1,8(sp)
ffffffffc0201a78:	6902                	ld	s2,0(sp)
ffffffffc0201a7a:	6105                	addi	sp,sp,32
ffffffffc0201a7c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a7e:	0541                	addi	a0,a0,16
ffffffffc0201a80:	e85ff0ef          	jal	ra,ffffffffc0201904 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a84:	01050413          	addi	s0,a0,16
ffffffffc0201a88:	f565                	bnez	a0,ffffffffc0201a70 <kmalloc+0x56>
ffffffffc0201a8a:	4401                	li	s0,0
}
ffffffffc0201a8c:	60e2                	ld	ra,24(sp)
ffffffffc0201a8e:	8522                	mv	a0,s0
ffffffffc0201a90:	6442                	ld	s0,16(sp)
ffffffffc0201a92:	64a2                	ld	s1,8(sp)
ffffffffc0201a94:	6902                	ld	s2,0(sp)
ffffffffc0201a96:	6105                	addi	sp,sp,32
ffffffffc0201a98:	8082                	ret
        intr_disable();
ffffffffc0201a9a:	b2bfe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a9e:	00014797          	auipc	a5,0x14
ffffffffc0201aa2:	ac278793          	addi	a5,a5,-1342 # ffffffffc0215560 <bigblocks>
ffffffffc0201aa6:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201aa8:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201aaa:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201aac:	b13fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
		return bb->pages;
ffffffffc0201ab0:	6480                	ld	s0,8(s1)
}
ffffffffc0201ab2:	60e2                	ld	ra,24(sp)
ffffffffc0201ab4:	64a2                	ld	s1,8(sp)
ffffffffc0201ab6:	8522                	mv	a0,s0
ffffffffc0201ab8:	6442                	ld	s0,16(sp)
ffffffffc0201aba:	6902                	ld	s2,0(sp)
ffffffffc0201abc:	6105                	addi	sp,sp,32
ffffffffc0201abe:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ac0:	45e1                	li	a1,24
ffffffffc0201ac2:	8526                	mv	a0,s1
ffffffffc0201ac4:	d29ff0ef          	jal	ra,ffffffffc02017ec <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201ac8:	b765                	j	ffffffffc0201a70 <kmalloc+0x56>

ffffffffc0201aca <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201aca:	c169                	beqz	a0,ffffffffc0201b8c <kfree+0xc2>
{
ffffffffc0201acc:	1101                	addi	sp,sp,-32
ffffffffc0201ace:	e822                	sd	s0,16(sp)
ffffffffc0201ad0:	ec06                	sd	ra,24(sp)
ffffffffc0201ad2:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201ad4:	03451793          	slli	a5,a0,0x34
ffffffffc0201ad8:	842a                	mv	s0,a0
ffffffffc0201ada:	e3d9                	bnez	a5,ffffffffc0201b60 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201adc:	100027f3          	csrr	a5,sstatus
ffffffffc0201ae0:	8b89                	andi	a5,a5,2
ffffffffc0201ae2:	e7d9                	bnez	a5,ffffffffc0201b70 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ae4:	00014797          	auipc	a5,0x14
ffffffffc0201ae8:	a7c7b783          	ld	a5,-1412(a5) # ffffffffc0215560 <bigblocks>
    return 0;
ffffffffc0201aec:	4601                	li	a2,0
ffffffffc0201aee:	cbad                	beqz	a5,ffffffffc0201b60 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201af0:	00014697          	auipc	a3,0x14
ffffffffc0201af4:	a7068693          	addi	a3,a3,-1424 # ffffffffc0215560 <bigblocks>
ffffffffc0201af8:	a021                	j	ffffffffc0201b00 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201afa:	01048693          	addi	a3,s1,16
ffffffffc0201afe:	c3a5                	beqz	a5,ffffffffc0201b5e <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201b00:	6798                	ld	a4,8(a5)
ffffffffc0201b02:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201b04:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201b06:	fe871ae3          	bne	a4,s0,ffffffffc0201afa <kfree+0x30>
				*last = bb->next;
ffffffffc0201b0a:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201b0c:	ee2d                	bnez	a2,ffffffffc0201b86 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201b0e:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201b12:	4098                	lw	a4,0(s1)
ffffffffc0201b14:	08f46963          	bltu	s0,a5,ffffffffc0201ba6 <kfree+0xdc>
ffffffffc0201b18:	00014697          	auipc	a3,0x14
ffffffffc0201b1c:	a906b683          	ld	a3,-1392(a3) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0201b20:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201b22:	8031                	srli	s0,s0,0xc
ffffffffc0201b24:	00014797          	auipc	a5,0x14
ffffffffc0201b28:	a6c7b783          	ld	a5,-1428(a5) # ffffffffc0215590 <npage>
ffffffffc0201b2c:	06f47163          	bgeu	s0,a5,ffffffffc0201b8e <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b30:	00005517          	auipc	a0,0x5
ffffffffc0201b34:	42853503          	ld	a0,1064(a0) # ffffffffc0206f58 <nbase>
ffffffffc0201b38:	8c09                	sub	s0,s0,a0
ffffffffc0201b3a:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b3c:	00014517          	auipc	a0,0x14
ffffffffc0201b40:	a5c53503          	ld	a0,-1444(a0) # ffffffffc0215598 <pages>
ffffffffc0201b44:	4585                	li	a1,1
ffffffffc0201b46:	9522                	add	a0,a0,s0
ffffffffc0201b48:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201b4c:	4e8010ef          	jal	ra,ffffffffc0203034 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201b50:	6442                	ld	s0,16(sp)
ffffffffc0201b52:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b54:	8526                	mv	a0,s1
}
ffffffffc0201b56:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b58:	45e1                	li	a1,24
}
ffffffffc0201b5a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b5c:	b941                	j	ffffffffc02017ec <slob_free>
ffffffffc0201b5e:	e20d                	bnez	a2,ffffffffc0201b80 <kfree+0xb6>
ffffffffc0201b60:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201b64:	6442                	ld	s0,16(sp)
ffffffffc0201b66:	60e2                	ld	ra,24(sp)
ffffffffc0201b68:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b6a:	4581                	li	a1,0
}
ffffffffc0201b6c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b6e:	b9bd                	j	ffffffffc02017ec <slob_free>
        intr_disable();
ffffffffc0201b70:	a55fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b74:	00014797          	auipc	a5,0x14
ffffffffc0201b78:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc0215560 <bigblocks>
        return 1;
ffffffffc0201b7c:	4605                	li	a2,1
ffffffffc0201b7e:	fbad                	bnez	a5,ffffffffc0201af0 <kfree+0x26>
        intr_enable();
ffffffffc0201b80:	a3ffe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201b84:	bff1                	j	ffffffffc0201b60 <kfree+0x96>
ffffffffc0201b86:	a39fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201b8a:	b751                	j	ffffffffc0201b0e <kfree+0x44>
ffffffffc0201b8c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201b8e:	00004617          	auipc	a2,0x4
ffffffffc0201b92:	ec260613          	addi	a2,a2,-318 # ffffffffc0205a50 <commands+0x950>
ffffffffc0201b96:	06200593          	li	a1,98
ffffffffc0201b9a:	00004517          	auipc	a0,0x4
ffffffffc0201b9e:	ed650513          	addi	a0,a0,-298 # ffffffffc0205a70 <commands+0x970>
ffffffffc0201ba2:	e26fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201ba6:	86a2                	mv	a3,s0
ffffffffc0201ba8:	00004617          	auipc	a2,0x4
ffffffffc0201bac:	28860613          	addi	a2,a2,648 # ffffffffc0205e30 <commands+0xd30>
ffffffffc0201bb0:	06e00593          	li	a1,110
ffffffffc0201bb4:	00004517          	auipc	a0,0x4
ffffffffc0201bb8:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205a70 <commands+0x970>
ffffffffc0201bbc:	e0cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201bc0 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201bc0:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201bc2:	00004617          	auipc	a2,0x4
ffffffffc0201bc6:	e8e60613          	addi	a2,a2,-370 # ffffffffc0205a50 <commands+0x950>
ffffffffc0201bca:	06200593          	li	a1,98
ffffffffc0201bce:	00004517          	auipc	a0,0x4
ffffffffc0201bd2:	ea250513          	addi	a0,a0,-350 # ffffffffc0205a70 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc0201bd6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201bd8:	df0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201bdc <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201bdc:	7135                	addi	sp,sp,-160
ffffffffc0201bde:	ed06                	sd	ra,152(sp)
ffffffffc0201be0:	e922                	sd	s0,144(sp)
ffffffffc0201be2:	e526                	sd	s1,136(sp)
ffffffffc0201be4:	e14a                	sd	s2,128(sp)
ffffffffc0201be6:	fcce                	sd	s3,120(sp)
ffffffffc0201be8:	f8d2                	sd	s4,112(sp)
ffffffffc0201bea:	f4d6                	sd	s5,104(sp)
ffffffffc0201bec:	f0da                	sd	s6,96(sp)
ffffffffc0201bee:	ecde                	sd	s7,88(sp)
ffffffffc0201bf0:	e8e2                	sd	s8,80(sp)
ffffffffc0201bf2:	e4e6                	sd	s9,72(sp)
ffffffffc0201bf4:	e0ea                	sd	s10,64(sp)
ffffffffc0201bf6:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201bf8:	4c6020ef          	jal	ra,ffffffffc02040be <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201bfc:	00014697          	auipc	a3,0x14
ffffffffc0201c00:	96c6b683          	ld	a3,-1684(a3) # ffffffffc0215568 <max_swap_offset>
ffffffffc0201c04:	010007b7          	lui	a5,0x1000
ffffffffc0201c08:	ff968713          	addi	a4,a3,-7
ffffffffc0201c0c:	17e1                	addi	a5,a5,-8
ffffffffc0201c0e:	42e7e063          	bltu	a5,a4,ffffffffc020202e <swap_init+0x452>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0201c12:	00008797          	auipc	a5,0x8
ffffffffc0201c16:	3ee78793          	addi	a5,a5,1006 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0201c1a:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0201c1c:	00014b97          	auipc	s7,0x14
ffffffffc0201c20:	954b8b93          	addi	s7,s7,-1708 # ffffffffc0215570 <sm>
ffffffffc0201c24:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0201c28:	9702                	jalr	a4
ffffffffc0201c2a:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0201c2c:	c10d                	beqz	a0,ffffffffc0201c4e <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201c2e:	60ea                	ld	ra,152(sp)
ffffffffc0201c30:	644a                	ld	s0,144(sp)
ffffffffc0201c32:	64aa                	ld	s1,136(sp)
ffffffffc0201c34:	79e6                	ld	s3,120(sp)
ffffffffc0201c36:	7a46                	ld	s4,112(sp)
ffffffffc0201c38:	7aa6                	ld	s5,104(sp)
ffffffffc0201c3a:	7b06                	ld	s6,96(sp)
ffffffffc0201c3c:	6be6                	ld	s7,88(sp)
ffffffffc0201c3e:	6c46                	ld	s8,80(sp)
ffffffffc0201c40:	6ca6                	ld	s9,72(sp)
ffffffffc0201c42:	6d06                	ld	s10,64(sp)
ffffffffc0201c44:	7de2                	ld	s11,56(sp)
ffffffffc0201c46:	854a                	mv	a0,s2
ffffffffc0201c48:	690a                	ld	s2,128(sp)
ffffffffc0201c4a:	610d                	addi	sp,sp,160
ffffffffc0201c4c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201c4e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c52:	00004517          	auipc	a0,0x4
ffffffffc0201c56:	23650513          	addi	a0,a0,566 # ffffffffc0205e88 <commands+0xd88>
    return listelm->next;
ffffffffc0201c5a:	00010417          	auipc	s0,0x10
ffffffffc0201c5e:	8a640413          	addi	s0,s0,-1882 # ffffffffc0211500 <free_area>
ffffffffc0201c62:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201c64:	4785                	li	a5,1
ffffffffc0201c66:	00014717          	auipc	a4,0x14
ffffffffc0201c6a:	90f72923          	sw	a5,-1774(a4) # ffffffffc0215578 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201c6e:	c5efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201c72:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0201c74:	4d01                	li	s10,0
ffffffffc0201c76:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c78:	32878b63          	beq	a5,s0,ffffffffc0201fae <swap_init+0x3d2>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201c7c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201c80:	8b09                	andi	a4,a4,2
ffffffffc0201c82:	32070863          	beqz	a4,ffffffffc0201fb2 <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc0201c86:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201c8a:	679c                	ld	a5,8(a5)
ffffffffc0201c8c:	2d85                	addiw	s11,s11,1
ffffffffc0201c8e:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c92:	fe8795e3          	bne	a5,s0,ffffffffc0201c7c <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201c96:	84ea                	mv	s1,s10
ffffffffc0201c98:	3dc010ef          	jal	ra,ffffffffc0203074 <nr_free_pages>
ffffffffc0201c9c:	42951163          	bne	a0,s1,ffffffffc02020be <swap_init+0x4e2>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201ca0:	866a                	mv	a2,s10
ffffffffc0201ca2:	85ee                	mv	a1,s11
ffffffffc0201ca4:	00004517          	auipc	a0,0x4
ffffffffc0201ca8:	22c50513          	addi	a0,a0,556 # ffffffffc0205ed0 <commands+0xdd0>
ffffffffc0201cac:	c20fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201cb0:	ee7fe0ef          	jal	ra,ffffffffc0200b96 <mm_create>
ffffffffc0201cb4:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201cb6:	46050463          	beqz	a0,ffffffffc020211e <swap_init+0x542>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201cba:	00014797          	auipc	a5,0x14
ffffffffc0201cbe:	89678793          	addi	a5,a5,-1898 # ffffffffc0215550 <check_mm_struct>
ffffffffc0201cc2:	6398                	ld	a4,0(a5)
ffffffffc0201cc4:	3c071d63          	bnez	a4,ffffffffc020209e <swap_init+0x4c2>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201cc8:	00014717          	auipc	a4,0x14
ffffffffc0201ccc:	8c070713          	addi	a4,a4,-1856 # ffffffffc0215588 <boot_pgdir>
ffffffffc0201cd0:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0201cd4:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0201cd6:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201cda:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201cde:	42079063          	bnez	a5,ffffffffc02020fe <swap_init+0x522>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201ce2:	6599                	lui	a1,0x6
ffffffffc0201ce4:	460d                	li	a2,3
ffffffffc0201ce6:	6505                	lui	a0,0x1
ffffffffc0201ce8:	ef7fe0ef          	jal	ra,ffffffffc0200bde <vma_create>
ffffffffc0201cec:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201cee:	52050463          	beqz	a0,ffffffffc0202216 <swap_init+0x63a>

     insert_vma_struct(mm, vma);
ffffffffc0201cf2:	8556                	mv	a0,s5
ffffffffc0201cf4:	f59fe0ef          	jal	ra,ffffffffc0200c4c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201cf8:	00004517          	auipc	a0,0x4
ffffffffc0201cfc:	21850513          	addi	a0,a0,536 # ffffffffc0205f10 <commands+0xe10>
ffffffffc0201d00:	bccfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201d04:	018ab503          	ld	a0,24(s5)
ffffffffc0201d08:	4605                	li	a2,1
ffffffffc0201d0a:	6585                	lui	a1,0x1
ffffffffc0201d0c:	3a2010ef          	jal	ra,ffffffffc02030ae <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201d10:	4c050363          	beqz	a0,ffffffffc02021d6 <swap_init+0x5fa>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d14:	00004517          	auipc	a0,0x4
ffffffffc0201d18:	24c50513          	addi	a0,a0,588 # ffffffffc0205f60 <commands+0xe60>
ffffffffc0201d1c:	0000f497          	auipc	s1,0xf
ffffffffc0201d20:	77448493          	addi	s1,s1,1908 # ffffffffc0211490 <check_rp>
ffffffffc0201d24:	ba8fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d28:	0000f997          	auipc	s3,0xf
ffffffffc0201d2c:	78898993          	addi	s3,s3,1928 # ffffffffc02114b0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d30:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0201d32:	4505                	li	a0,1
ffffffffc0201d34:	26e010ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0201d38:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0201d3c:	2c050963          	beqz	a0,ffffffffc020200e <swap_init+0x432>
ffffffffc0201d40:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201d42:	8b89                	andi	a5,a5,2
ffffffffc0201d44:	32079d63          	bnez	a5,ffffffffc020207e <swap_init+0x4a2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d48:	0a21                	addi	s4,s4,8
ffffffffc0201d4a:	ff3a14e3          	bne	s4,s3,ffffffffc0201d32 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201d4e:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201d50:	0000fa17          	auipc	s4,0xf
ffffffffc0201d54:	740a0a13          	addi	s4,s4,1856 # ffffffffc0211490 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0201d58:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0201d5a:	ec3e                	sd	a5,24(sp)
ffffffffc0201d5c:	641c                	ld	a5,8(s0)
ffffffffc0201d5e:	e400                	sd	s0,8(s0)
ffffffffc0201d60:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201d62:	481c                	lw	a5,16(s0)
ffffffffc0201d64:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0201d66:	0000f797          	auipc	a5,0xf
ffffffffc0201d6a:	7a07a523          	sw	zero,1962(a5) # ffffffffc0211510 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201d6e:	000a3503          	ld	a0,0(s4)
ffffffffc0201d72:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d74:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0201d76:	2be010ef          	jal	ra,ffffffffc0203034 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d7a:	ff3a1ae3          	bne	s4,s3,ffffffffc0201d6e <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201d7e:	01042a03          	lw	s4,16(s0)
ffffffffc0201d82:	4791                	li	a5,4
ffffffffc0201d84:	42fa1963          	bne	s4,a5,ffffffffc02021b6 <swap_init+0x5da>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201d88:	00004517          	auipc	a0,0x4
ffffffffc0201d8c:	26050513          	addi	a0,a0,608 # ffffffffc0205fe8 <commands+0xee8>
ffffffffc0201d90:	b3cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201d94:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201d96:	00013797          	auipc	a5,0x13
ffffffffc0201d9a:	7c07a123          	sw	zero,1986(a5) # ffffffffc0215558 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201d9e:	4629                	li	a2,10
ffffffffc0201da0:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0201da4:	00013697          	auipc	a3,0x13
ffffffffc0201da8:	7b46a683          	lw	a3,1972(a3) # ffffffffc0215558 <pgfault_num>
ffffffffc0201dac:	4585                	li	a1,1
ffffffffc0201dae:	00013797          	auipc	a5,0x13
ffffffffc0201db2:	7aa78793          	addi	a5,a5,1962 # ffffffffc0215558 <pgfault_num>
ffffffffc0201db6:	54b69063          	bne	a3,a1,ffffffffc02022f6 <swap_init+0x71a>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201dba:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0201dbe:	4398                	lw	a4,0(a5)
ffffffffc0201dc0:	2701                	sext.w	a4,a4
ffffffffc0201dc2:	3cd71a63          	bne	a4,a3,ffffffffc0202196 <swap_init+0x5ba>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201dc6:	6689                	lui	a3,0x2
ffffffffc0201dc8:	462d                	li	a2,11
ffffffffc0201dca:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201dce:	4398                	lw	a4,0(a5)
ffffffffc0201dd0:	4589                	li	a1,2
ffffffffc0201dd2:	2701                	sext.w	a4,a4
ffffffffc0201dd4:	4ab71163          	bne	a4,a1,ffffffffc0202276 <swap_init+0x69a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201dd8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201ddc:	4394                	lw	a3,0(a5)
ffffffffc0201dde:	2681                	sext.w	a3,a3
ffffffffc0201de0:	4ae69b63          	bne	a3,a4,ffffffffc0202296 <swap_init+0x6ba>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201de4:	668d                	lui	a3,0x3
ffffffffc0201de6:	4631                	li	a2,12
ffffffffc0201de8:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201dec:	4398                	lw	a4,0(a5)
ffffffffc0201dee:	458d                	li	a1,3
ffffffffc0201df0:	2701                	sext.w	a4,a4
ffffffffc0201df2:	4cb71263          	bne	a4,a1,ffffffffc02022b6 <swap_init+0x6da>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201df6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201dfa:	4394                	lw	a3,0(a5)
ffffffffc0201dfc:	2681                	sext.w	a3,a3
ffffffffc0201dfe:	4ce69c63          	bne	a3,a4,ffffffffc02022d6 <swap_init+0x6fa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201e02:	6691                	lui	a3,0x4
ffffffffc0201e04:	4635                	li	a2,13
ffffffffc0201e06:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201e0a:	4398                	lw	a4,0(a5)
ffffffffc0201e0c:	2701                	sext.w	a4,a4
ffffffffc0201e0e:	43471463          	bne	a4,s4,ffffffffc0202236 <swap_init+0x65a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201e12:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201e16:	439c                	lw	a5,0(a5)
ffffffffc0201e18:	2781                	sext.w	a5,a5
ffffffffc0201e1a:	42e79e63          	bne	a5,a4,ffffffffc0202256 <swap_init+0x67a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201e1e:	481c                	lw	a5,16(s0)
ffffffffc0201e20:	2a079f63          	bnez	a5,ffffffffc02020de <swap_init+0x502>
ffffffffc0201e24:	0000f797          	auipc	a5,0xf
ffffffffc0201e28:	68c78793          	addi	a5,a5,1676 # ffffffffc02114b0 <swap_in_seq_no>
ffffffffc0201e2c:	0000f717          	auipc	a4,0xf
ffffffffc0201e30:	6ac70713          	addi	a4,a4,1708 # ffffffffc02114d8 <swap_out_seq_no>
ffffffffc0201e34:	0000f617          	auipc	a2,0xf
ffffffffc0201e38:	6a460613          	addi	a2,a2,1700 # ffffffffc02114d8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201e3c:	56fd                	li	a3,-1
ffffffffc0201e3e:	c394                	sw	a3,0(a5)
ffffffffc0201e40:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201e42:	0791                	addi	a5,a5,4
ffffffffc0201e44:	0711                	addi	a4,a4,4
ffffffffc0201e46:	fec79ce3          	bne	a5,a2,ffffffffc0201e3e <swap_init+0x262>
ffffffffc0201e4a:	0000f717          	auipc	a4,0xf
ffffffffc0201e4e:	62670713          	addi	a4,a4,1574 # ffffffffc0211470 <check_ptep>
ffffffffc0201e52:	0000f697          	auipc	a3,0xf
ffffffffc0201e56:	63e68693          	addi	a3,a3,1598 # ffffffffc0211490 <check_rp>
ffffffffc0201e5a:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201e5c:	00013c17          	auipc	s8,0x13
ffffffffc0201e60:	734c0c13          	addi	s8,s8,1844 # ffffffffc0215590 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e64:	00013c97          	auipc	s9,0x13
ffffffffc0201e68:	734c8c93          	addi	s9,s9,1844 # ffffffffc0215598 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201e6c:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201e70:	4601                	li	a2,0
ffffffffc0201e72:	855a                	mv	a0,s6
ffffffffc0201e74:	e836                	sd	a3,16(sp)
ffffffffc0201e76:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0201e78:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201e7a:	234010ef          	jal	ra,ffffffffc02030ae <get_pte>
ffffffffc0201e7e:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201e80:	65a2                	ld	a1,8(sp)
ffffffffc0201e82:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201e84:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0201e86:	1c050063          	beqz	a0,ffffffffc0202046 <swap_init+0x46a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201e8a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201e8c:	0017f613          	andi	a2,a5,1
ffffffffc0201e90:	1c060b63          	beqz	a2,ffffffffc0202066 <swap_init+0x48a>
    if (PPN(pa) >= npage) {
ffffffffc0201e94:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e98:	078a                	slli	a5,a5,0x2
ffffffffc0201e9a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e9c:	12c7fd63          	bgeu	a5,a2,ffffffffc0201fd6 <swap_init+0x3fa>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ea0:	00005617          	auipc	a2,0x5
ffffffffc0201ea4:	0b860613          	addi	a2,a2,184 # ffffffffc0206f58 <nbase>
ffffffffc0201ea8:	00063a03          	ld	s4,0(a2)
ffffffffc0201eac:	000cb603          	ld	a2,0(s9)
ffffffffc0201eb0:	6288                	ld	a0,0(a3)
ffffffffc0201eb2:	414787b3          	sub	a5,a5,s4
ffffffffc0201eb6:	079a                	slli	a5,a5,0x6
ffffffffc0201eb8:	97b2                	add	a5,a5,a2
ffffffffc0201eba:	12f51a63          	bne	a0,a5,ffffffffc0201fee <swap_init+0x412>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201ebe:	6785                	lui	a5,0x1
ffffffffc0201ec0:	95be                	add	a1,a1,a5
ffffffffc0201ec2:	6795                	lui	a5,0x5
ffffffffc0201ec4:	0721                	addi	a4,a4,8
ffffffffc0201ec6:	06a1                	addi	a3,a3,8
ffffffffc0201ec8:	faf592e3          	bne	a1,a5,ffffffffc0201e6c <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201ecc:	00004517          	auipc	a0,0x4
ffffffffc0201ed0:	1ec50513          	addi	a0,a0,492 # ffffffffc02060b8 <commands+0xfb8>
ffffffffc0201ed4:	9f8fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0201ed8:	000bb783          	ld	a5,0(s7)
ffffffffc0201edc:	7f9c                	ld	a5,56(a5)
ffffffffc0201ede:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201ee0:	30051b63          	bnez	a0,ffffffffc02021f6 <swap_init+0x61a>

     nr_free = nr_free_store;
ffffffffc0201ee4:	77a2                	ld	a5,40(sp)
ffffffffc0201ee6:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0201ee8:	67e2                	ld	a5,24(sp)
ffffffffc0201eea:	e01c                	sd	a5,0(s0)
ffffffffc0201eec:	7782                	ld	a5,32(sp)
ffffffffc0201eee:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201ef0:	6088                	ld	a0,0(s1)
ffffffffc0201ef2:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201ef4:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0201ef6:	13e010ef          	jal	ra,ffffffffc0203034 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201efa:	ff349be3          	bne	s1,s3,ffffffffc0201ef0 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201efe:	8556                	mv	a0,s5
ffffffffc0201f00:	e1dfe0ef          	jal	ra,ffffffffc0200d1c <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201f04:	00013797          	auipc	a5,0x13
ffffffffc0201f08:	68478793          	addi	a5,a5,1668 # ffffffffc0215588 <boot_pgdir>
ffffffffc0201f0c:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201f0e:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f12:	639c                	ld	a5,0(a5)
ffffffffc0201f14:	078a                	slli	a5,a5,0x2
ffffffffc0201f16:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f18:	0ae7fd63          	bgeu	a5,a4,ffffffffc0201fd2 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f1c:	414786b3          	sub	a3,a5,s4
ffffffffc0201f20:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201f22:	8699                	srai	a3,a3,0x6
ffffffffc0201f24:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201f26:	00c69793          	slli	a5,a3,0xc
ffffffffc0201f2a:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201f2c:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f30:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201f32:	22e7f663          	bgeu	a5,a4,ffffffffc020215e <swap_init+0x582>
     free_page(pde2page(pd0[0]));
ffffffffc0201f36:	00013797          	auipc	a5,0x13
ffffffffc0201f3a:	6727b783          	ld	a5,1650(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0201f3e:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f40:	629c                	ld	a5,0(a3)
ffffffffc0201f42:	078a                	slli	a5,a5,0x2
ffffffffc0201f44:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f46:	08e7f663          	bgeu	a5,a4,ffffffffc0201fd2 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f4a:	414787b3          	sub	a5,a5,s4
ffffffffc0201f4e:	079a                	slli	a5,a5,0x6
ffffffffc0201f50:	953e                	add	a0,a0,a5
ffffffffc0201f52:	4585                	li	a1,1
ffffffffc0201f54:	0e0010ef          	jal	ra,ffffffffc0203034 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f58:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201f5c:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f60:	078a                	slli	a5,a5,0x2
ffffffffc0201f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f64:	06e7f763          	bgeu	a5,a4,ffffffffc0201fd2 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f68:	000cb503          	ld	a0,0(s9)
ffffffffc0201f6c:	414787b3          	sub	a5,a5,s4
ffffffffc0201f70:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201f72:	4585                	li	a1,1
ffffffffc0201f74:	953e                	add	a0,a0,a5
ffffffffc0201f76:	0be010ef          	jal	ra,ffffffffc0203034 <free_pages>
     pgdir[0] = 0;
ffffffffc0201f7a:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201f7e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201f82:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201f84:	00878a63          	beq	a5,s0,ffffffffc0201f98 <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201f88:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201f8c:	679c                	ld	a5,8(a5)
ffffffffc0201f8e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201f90:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201f94:	fe879ae3          	bne	a5,s0,ffffffffc0201f88 <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc0201f98:	1c0d9f63          	bnez	s11,ffffffffc0202176 <swap_init+0x59a>
     assert(total==0);
ffffffffc0201f9c:	1a0d1163          	bnez	s10,ffffffffc020213e <swap_init+0x562>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201fa0:	00004517          	auipc	a0,0x4
ffffffffc0201fa4:	16850513          	addi	a0,a0,360 # ffffffffc0206108 <commands+0x1008>
ffffffffc0201fa8:	924fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201fac:	b149                	j	ffffffffc0201c2e <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201fae:	4481                	li	s1,0
ffffffffc0201fb0:	b1e5                	j	ffffffffc0201c98 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0201fb2:	00004697          	auipc	a3,0x4
ffffffffc0201fb6:	eee68693          	addi	a3,a3,-274 # ffffffffc0205ea0 <commands+0xda0>
ffffffffc0201fba:	00004617          	auipc	a2,0x4
ffffffffc0201fbe:	86e60613          	addi	a2,a2,-1938 # ffffffffc0205828 <commands+0x728>
ffffffffc0201fc2:	0bd00593          	li	a1,189
ffffffffc0201fc6:	00004517          	auipc	a0,0x4
ffffffffc0201fca:	eb250513          	addi	a0,a0,-334 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0201fce:	9fafe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0201fd2:	befff0ef          	jal	ra,ffffffffc0201bc0 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0201fd6:	00004617          	auipc	a2,0x4
ffffffffc0201fda:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0205a50 <commands+0x950>
ffffffffc0201fde:	06200593          	li	a1,98
ffffffffc0201fe2:	00004517          	auipc	a0,0x4
ffffffffc0201fe6:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0205a70 <commands+0x970>
ffffffffc0201fea:	9defe0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201fee:	00004697          	auipc	a3,0x4
ffffffffc0201ff2:	0a268693          	addi	a3,a3,162 # ffffffffc0206090 <commands+0xf90>
ffffffffc0201ff6:	00004617          	auipc	a2,0x4
ffffffffc0201ffa:	83260613          	addi	a2,a2,-1998 # ffffffffc0205828 <commands+0x728>
ffffffffc0201ffe:	0fd00593          	li	a1,253
ffffffffc0202002:	00004517          	auipc	a0,0x4
ffffffffc0202006:	e7650513          	addi	a0,a0,-394 # ffffffffc0205e78 <commands+0xd78>
ffffffffc020200a:	9befe0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020200e:	00004697          	auipc	a3,0x4
ffffffffc0202012:	f7a68693          	addi	a3,a3,-134 # ffffffffc0205f88 <commands+0xe88>
ffffffffc0202016:	00004617          	auipc	a2,0x4
ffffffffc020201a:	81260613          	addi	a2,a2,-2030 # ffffffffc0205828 <commands+0x728>
ffffffffc020201e:	0dd00593          	li	a1,221
ffffffffc0202022:	00004517          	auipc	a0,0x4
ffffffffc0202026:	e5650513          	addi	a0,a0,-426 # ffffffffc0205e78 <commands+0xd78>
ffffffffc020202a:	99efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020202e:	00004617          	auipc	a2,0x4
ffffffffc0202032:	e2a60613          	addi	a2,a2,-470 # ffffffffc0205e58 <commands+0xd58>
ffffffffc0202036:	02a00593          	li	a1,42
ffffffffc020203a:	00004517          	auipc	a0,0x4
ffffffffc020203e:	e3e50513          	addi	a0,a0,-450 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202042:	986fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202046:	00004697          	auipc	a3,0x4
ffffffffc020204a:	00a68693          	addi	a3,a3,10 # ffffffffc0206050 <commands+0xf50>
ffffffffc020204e:	00003617          	auipc	a2,0x3
ffffffffc0202052:	7da60613          	addi	a2,a2,2010 # ffffffffc0205828 <commands+0x728>
ffffffffc0202056:	0fc00593          	li	a1,252
ffffffffc020205a:	00004517          	auipc	a0,0x4
ffffffffc020205e:	e1e50513          	addi	a0,a0,-482 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202062:	966fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202066:	00004617          	auipc	a2,0x4
ffffffffc020206a:	00260613          	addi	a2,a2,2 # ffffffffc0206068 <commands+0xf68>
ffffffffc020206e:	07400593          	li	a1,116
ffffffffc0202072:	00004517          	auipc	a0,0x4
ffffffffc0202076:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0205a70 <commands+0x970>
ffffffffc020207a:	94efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020207e:	00004697          	auipc	a3,0x4
ffffffffc0202082:	f2268693          	addi	a3,a3,-222 # ffffffffc0205fa0 <commands+0xea0>
ffffffffc0202086:	00003617          	auipc	a2,0x3
ffffffffc020208a:	7a260613          	addi	a2,a2,1954 # ffffffffc0205828 <commands+0x728>
ffffffffc020208e:	0de00593          	li	a1,222
ffffffffc0202092:	00004517          	auipc	a0,0x4
ffffffffc0202096:	de650513          	addi	a0,a0,-538 # ffffffffc0205e78 <commands+0xd78>
ffffffffc020209a:	92efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020209e:	00004697          	auipc	a3,0x4
ffffffffc02020a2:	e5a68693          	addi	a3,a3,-422 # ffffffffc0205ef8 <commands+0xdf8>
ffffffffc02020a6:	00003617          	auipc	a2,0x3
ffffffffc02020aa:	78260613          	addi	a2,a2,1922 # ffffffffc0205828 <commands+0x728>
ffffffffc02020ae:	0c800593          	li	a1,200
ffffffffc02020b2:	00004517          	auipc	a0,0x4
ffffffffc02020b6:	dc650513          	addi	a0,a0,-570 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02020ba:	90efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total == nr_free_pages());
ffffffffc02020be:	00004697          	auipc	a3,0x4
ffffffffc02020c2:	df268693          	addi	a3,a3,-526 # ffffffffc0205eb0 <commands+0xdb0>
ffffffffc02020c6:	00003617          	auipc	a2,0x3
ffffffffc02020ca:	76260613          	addi	a2,a2,1890 # ffffffffc0205828 <commands+0x728>
ffffffffc02020ce:	0c000593          	li	a1,192
ffffffffc02020d2:	00004517          	auipc	a0,0x4
ffffffffc02020d6:	da650513          	addi	a0,a0,-602 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02020da:	8eefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert( nr_free == 0);         
ffffffffc02020de:	00004697          	auipc	a3,0x4
ffffffffc02020e2:	f6268693          	addi	a3,a3,-158 # ffffffffc0206040 <commands+0xf40>
ffffffffc02020e6:	00003617          	auipc	a2,0x3
ffffffffc02020ea:	74260613          	addi	a2,a2,1858 # ffffffffc0205828 <commands+0x728>
ffffffffc02020ee:	0f400593          	li	a1,244
ffffffffc02020f2:	00004517          	auipc	a0,0x4
ffffffffc02020f6:	d8650513          	addi	a0,a0,-634 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02020fa:	8cefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02020fe:	00004697          	auipc	a3,0x4
ffffffffc0202102:	91268693          	addi	a3,a3,-1774 # ffffffffc0205a10 <commands+0x910>
ffffffffc0202106:	00003617          	auipc	a2,0x3
ffffffffc020210a:	72260613          	addi	a2,a2,1826 # ffffffffc0205828 <commands+0x728>
ffffffffc020210e:	0cd00593          	li	a1,205
ffffffffc0202112:	00004517          	auipc	a0,0x4
ffffffffc0202116:	d6650513          	addi	a0,a0,-666 # ffffffffc0205e78 <commands+0xd78>
ffffffffc020211a:	8aefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(mm != NULL);
ffffffffc020211e:	00004697          	auipc	a3,0x4
ffffffffc0202122:	a1268693          	addi	a3,a3,-1518 # ffffffffc0205b30 <commands+0xa30>
ffffffffc0202126:	00003617          	auipc	a2,0x3
ffffffffc020212a:	70260613          	addi	a2,a2,1794 # ffffffffc0205828 <commands+0x728>
ffffffffc020212e:	0c500593          	li	a1,197
ffffffffc0202132:	00004517          	auipc	a0,0x4
ffffffffc0202136:	d4650513          	addi	a0,a0,-698 # ffffffffc0205e78 <commands+0xd78>
ffffffffc020213a:	88efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total==0);
ffffffffc020213e:	00004697          	auipc	a3,0x4
ffffffffc0202142:	fba68693          	addi	a3,a3,-70 # ffffffffc02060f8 <commands+0xff8>
ffffffffc0202146:	00003617          	auipc	a2,0x3
ffffffffc020214a:	6e260613          	addi	a2,a2,1762 # ffffffffc0205828 <commands+0x728>
ffffffffc020214e:	11d00593          	li	a1,285
ffffffffc0202152:	00004517          	auipc	a0,0x4
ffffffffc0202156:	d2650513          	addi	a0,a0,-730 # ffffffffc0205e78 <commands+0xd78>
ffffffffc020215a:	86efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc020215e:	00004617          	auipc	a2,0x4
ffffffffc0202162:	92260613          	addi	a2,a2,-1758 # ffffffffc0205a80 <commands+0x980>
ffffffffc0202166:	06900593          	li	a1,105
ffffffffc020216a:	00004517          	auipc	a0,0x4
ffffffffc020216e:	90650513          	addi	a0,a0,-1786 # ffffffffc0205a70 <commands+0x970>
ffffffffc0202172:	856fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(count==0);
ffffffffc0202176:	00004697          	auipc	a3,0x4
ffffffffc020217a:	f7268693          	addi	a3,a3,-142 # ffffffffc02060e8 <commands+0xfe8>
ffffffffc020217e:	00003617          	auipc	a2,0x3
ffffffffc0202182:	6aa60613          	addi	a2,a2,1706 # ffffffffc0205828 <commands+0x728>
ffffffffc0202186:	11c00593          	li	a1,284
ffffffffc020218a:	00004517          	auipc	a0,0x4
ffffffffc020218e:	cee50513          	addi	a0,a0,-786 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202192:	836fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc0202196:	00004697          	auipc	a3,0x4
ffffffffc020219a:	e7a68693          	addi	a3,a3,-390 # ffffffffc0206010 <commands+0xf10>
ffffffffc020219e:	00003617          	auipc	a2,0x3
ffffffffc02021a2:	68a60613          	addi	a2,a2,1674 # ffffffffc0205828 <commands+0x728>
ffffffffc02021a6:	09600593          	li	a1,150
ffffffffc02021aa:	00004517          	auipc	a0,0x4
ffffffffc02021ae:	cce50513          	addi	a0,a0,-818 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02021b2:	816fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02021b6:	00004697          	auipc	a3,0x4
ffffffffc02021ba:	e0a68693          	addi	a3,a3,-502 # ffffffffc0205fc0 <commands+0xec0>
ffffffffc02021be:	00003617          	auipc	a2,0x3
ffffffffc02021c2:	66a60613          	addi	a2,a2,1642 # ffffffffc0205828 <commands+0x728>
ffffffffc02021c6:	0eb00593          	li	a1,235
ffffffffc02021ca:	00004517          	auipc	a0,0x4
ffffffffc02021ce:	cae50513          	addi	a0,a0,-850 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02021d2:	ff7fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02021d6:	00004697          	auipc	a3,0x4
ffffffffc02021da:	d7268693          	addi	a3,a3,-654 # ffffffffc0205f48 <commands+0xe48>
ffffffffc02021de:	00003617          	auipc	a2,0x3
ffffffffc02021e2:	64a60613          	addi	a2,a2,1610 # ffffffffc0205828 <commands+0x728>
ffffffffc02021e6:	0d800593          	li	a1,216
ffffffffc02021ea:	00004517          	auipc	a0,0x4
ffffffffc02021ee:	c8e50513          	addi	a0,a0,-882 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02021f2:	fd7fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(ret==0);
ffffffffc02021f6:	00004697          	auipc	a3,0x4
ffffffffc02021fa:	eea68693          	addi	a3,a3,-278 # ffffffffc02060e0 <commands+0xfe0>
ffffffffc02021fe:	00003617          	auipc	a2,0x3
ffffffffc0202202:	62a60613          	addi	a2,a2,1578 # ffffffffc0205828 <commands+0x728>
ffffffffc0202206:	10300593          	li	a1,259
ffffffffc020220a:	00004517          	auipc	a0,0x4
ffffffffc020220e:	c6e50513          	addi	a0,a0,-914 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202212:	fb7fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(vma != NULL);
ffffffffc0202216:	00004697          	auipc	a3,0x4
ffffffffc020221a:	8f268693          	addi	a3,a3,-1806 # ffffffffc0205b08 <commands+0xa08>
ffffffffc020221e:	00003617          	auipc	a2,0x3
ffffffffc0202222:	60a60613          	addi	a2,a2,1546 # ffffffffc0205828 <commands+0x728>
ffffffffc0202226:	0d000593          	li	a1,208
ffffffffc020222a:	00004517          	auipc	a0,0x4
ffffffffc020222e:	c4e50513          	addi	a0,a0,-946 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202232:	f97fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc0202236:	00004697          	auipc	a3,0x4
ffffffffc020223a:	9d268693          	addi	a3,a3,-1582 # ffffffffc0205c08 <commands+0xb08>
ffffffffc020223e:	00003617          	auipc	a2,0x3
ffffffffc0202242:	5ea60613          	addi	a2,a2,1514 # ffffffffc0205828 <commands+0x728>
ffffffffc0202246:	0a000593          	li	a1,160
ffffffffc020224a:	00004517          	auipc	a0,0x4
ffffffffc020224e:	c2e50513          	addi	a0,a0,-978 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202252:	f77fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc0202256:	00004697          	auipc	a3,0x4
ffffffffc020225a:	9b268693          	addi	a3,a3,-1614 # ffffffffc0205c08 <commands+0xb08>
ffffffffc020225e:	00003617          	auipc	a2,0x3
ffffffffc0202262:	5ca60613          	addi	a2,a2,1482 # ffffffffc0205828 <commands+0x728>
ffffffffc0202266:	0a200593          	li	a1,162
ffffffffc020226a:	00004517          	auipc	a0,0x4
ffffffffc020226e:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202272:	f57fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc0202276:	00004697          	auipc	a3,0x4
ffffffffc020227a:	daa68693          	addi	a3,a3,-598 # ffffffffc0206020 <commands+0xf20>
ffffffffc020227e:	00003617          	auipc	a2,0x3
ffffffffc0202282:	5aa60613          	addi	a2,a2,1450 # ffffffffc0205828 <commands+0x728>
ffffffffc0202286:	09800593          	li	a1,152
ffffffffc020228a:	00004517          	auipc	a0,0x4
ffffffffc020228e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202292:	f37fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc0202296:	00004697          	auipc	a3,0x4
ffffffffc020229a:	d8a68693          	addi	a3,a3,-630 # ffffffffc0206020 <commands+0xf20>
ffffffffc020229e:	00003617          	auipc	a2,0x3
ffffffffc02022a2:	58a60613          	addi	a2,a2,1418 # ffffffffc0205828 <commands+0x728>
ffffffffc02022a6:	09a00593          	li	a1,154
ffffffffc02022aa:	00004517          	auipc	a0,0x4
ffffffffc02022ae:	bce50513          	addi	a0,a0,-1074 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02022b2:	f17fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc02022b6:	00004697          	auipc	a3,0x4
ffffffffc02022ba:	d7a68693          	addi	a3,a3,-646 # ffffffffc0206030 <commands+0xf30>
ffffffffc02022be:	00003617          	auipc	a2,0x3
ffffffffc02022c2:	56a60613          	addi	a2,a2,1386 # ffffffffc0205828 <commands+0x728>
ffffffffc02022c6:	09c00593          	li	a1,156
ffffffffc02022ca:	00004517          	auipc	a0,0x4
ffffffffc02022ce:	bae50513          	addi	a0,a0,-1106 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02022d2:	ef7fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc02022d6:	00004697          	auipc	a3,0x4
ffffffffc02022da:	d5a68693          	addi	a3,a3,-678 # ffffffffc0206030 <commands+0xf30>
ffffffffc02022de:	00003617          	auipc	a2,0x3
ffffffffc02022e2:	54a60613          	addi	a2,a2,1354 # ffffffffc0205828 <commands+0x728>
ffffffffc02022e6:	09e00593          	li	a1,158
ffffffffc02022ea:	00004517          	auipc	a0,0x4
ffffffffc02022ee:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02022f2:	ed7fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc02022f6:	00004697          	auipc	a3,0x4
ffffffffc02022fa:	d1a68693          	addi	a3,a3,-742 # ffffffffc0206010 <commands+0xf10>
ffffffffc02022fe:	00003617          	auipc	a2,0x3
ffffffffc0202302:	52a60613          	addi	a2,a2,1322 # ffffffffc0205828 <commands+0x728>
ffffffffc0202306:	09400593          	li	a1,148
ffffffffc020230a:	00004517          	auipc	a0,0x4
ffffffffc020230e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0205e78 <commands+0xd78>
ffffffffc0202312:	eb7fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202316 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202316:	00013797          	auipc	a5,0x13
ffffffffc020231a:	25a7b783          	ld	a5,602(a5) # ffffffffc0215570 <sm>
ffffffffc020231e:	6b9c                	ld	a5,16(a5)
ffffffffc0202320:	8782                	jr	a5

ffffffffc0202322 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202322:	00013797          	auipc	a5,0x13
ffffffffc0202326:	24e7b783          	ld	a5,590(a5) # ffffffffc0215570 <sm>
ffffffffc020232a:	739c                	ld	a5,32(a5)
ffffffffc020232c:	8782                	jr	a5

ffffffffc020232e <swap_out>:
{
ffffffffc020232e:	711d                	addi	sp,sp,-96
ffffffffc0202330:	ec86                	sd	ra,88(sp)
ffffffffc0202332:	e8a2                	sd	s0,80(sp)
ffffffffc0202334:	e4a6                	sd	s1,72(sp)
ffffffffc0202336:	e0ca                	sd	s2,64(sp)
ffffffffc0202338:	fc4e                	sd	s3,56(sp)
ffffffffc020233a:	f852                	sd	s4,48(sp)
ffffffffc020233c:	f456                	sd	s5,40(sp)
ffffffffc020233e:	f05a                	sd	s6,32(sp)
ffffffffc0202340:	ec5e                	sd	s7,24(sp)
ffffffffc0202342:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202344:	cde9                	beqz	a1,ffffffffc020241e <swap_out+0xf0>
ffffffffc0202346:	8a2e                	mv	s4,a1
ffffffffc0202348:	892a                	mv	s2,a0
ffffffffc020234a:	8ab2                	mv	s5,a2
ffffffffc020234c:	4401                	li	s0,0
ffffffffc020234e:	00013997          	auipc	s3,0x13
ffffffffc0202352:	22298993          	addi	s3,s3,546 # ffffffffc0215570 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202356:	00004b17          	auipc	s6,0x4
ffffffffc020235a:	e32b0b13          	addi	s6,s6,-462 # ffffffffc0206188 <commands+0x1088>
                    cprintf("SWAP: failed to save\n");
ffffffffc020235e:	00004b97          	auipc	s7,0x4
ffffffffc0202362:	e12b8b93          	addi	s7,s7,-494 # ffffffffc0206170 <commands+0x1070>
ffffffffc0202366:	a825                	j	ffffffffc020239e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202368:	67a2                	ld	a5,8(sp)
ffffffffc020236a:	8626                	mv	a2,s1
ffffffffc020236c:	85a2                	mv	a1,s0
ffffffffc020236e:	7f94                	ld	a3,56(a5)
ffffffffc0202370:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202372:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202374:	82b1                	srli	a3,a3,0xc
ffffffffc0202376:	0685                	addi	a3,a3,1
ffffffffc0202378:	d55fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020237c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020237e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202380:	7d1c                	ld	a5,56(a0)
ffffffffc0202382:	83b1                	srli	a5,a5,0xc
ffffffffc0202384:	0785                	addi	a5,a5,1
ffffffffc0202386:	07a2                	slli	a5,a5,0x8
ffffffffc0202388:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020238c:	4a9000ef          	jal	ra,ffffffffc0203034 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202390:	01893503          	ld	a0,24(s2)
ffffffffc0202394:	85a6                	mv	a1,s1
ffffffffc0202396:	46b010ef          	jal	ra,ffffffffc0204000 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020239a:	048a0d63          	beq	s4,s0,ffffffffc02023f4 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020239e:	0009b783          	ld	a5,0(s3)
ffffffffc02023a2:	8656                	mv	a2,s5
ffffffffc02023a4:	002c                	addi	a1,sp,8
ffffffffc02023a6:	7b9c                	ld	a5,48(a5)
ffffffffc02023a8:	854a                	mv	a0,s2
ffffffffc02023aa:	9782                	jalr	a5
          if (r != 0) {
ffffffffc02023ac:	e12d                	bnez	a0,ffffffffc020240e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc02023ae:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02023b0:	01893503          	ld	a0,24(s2)
ffffffffc02023b4:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02023b6:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02023b8:	85a6                	mv	a1,s1
ffffffffc02023ba:	4f5000ef          	jal	ra,ffffffffc02030ae <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02023be:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02023c0:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02023c2:	8b85                	andi	a5,a5,1
ffffffffc02023c4:	cfb9                	beqz	a5,ffffffffc0202422 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02023c6:	65a2                	ld	a1,8(sp)
ffffffffc02023c8:	7d9c                	ld	a5,56(a1)
ffffffffc02023ca:	83b1                	srli	a5,a5,0xc
ffffffffc02023cc:	0785                	addi	a5,a5,1
ffffffffc02023ce:	00879513          	slli	a0,a5,0x8
ffffffffc02023d2:	5b3010ef          	jal	ra,ffffffffc0204184 <swapfs_write>
ffffffffc02023d6:	d949                	beqz	a0,ffffffffc0202368 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02023d8:	855e                	mv	a0,s7
ffffffffc02023da:	cf3fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02023de:	0009b783          	ld	a5,0(s3)
ffffffffc02023e2:	6622                	ld	a2,8(sp)
ffffffffc02023e4:	4681                	li	a3,0
ffffffffc02023e6:	739c                	ld	a5,32(a5)
ffffffffc02023e8:	85a6                	mv	a1,s1
ffffffffc02023ea:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02023ec:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02023ee:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02023f0:	fa8a17e3          	bne	s4,s0,ffffffffc020239e <swap_out+0x70>
}
ffffffffc02023f4:	60e6                	ld	ra,88(sp)
ffffffffc02023f6:	8522                	mv	a0,s0
ffffffffc02023f8:	6446                	ld	s0,80(sp)
ffffffffc02023fa:	64a6                	ld	s1,72(sp)
ffffffffc02023fc:	6906                	ld	s2,64(sp)
ffffffffc02023fe:	79e2                	ld	s3,56(sp)
ffffffffc0202400:	7a42                	ld	s4,48(sp)
ffffffffc0202402:	7aa2                	ld	s5,40(sp)
ffffffffc0202404:	7b02                	ld	s6,32(sp)
ffffffffc0202406:	6be2                	ld	s7,24(sp)
ffffffffc0202408:	6c42                	ld	s8,16(sp)
ffffffffc020240a:	6125                	addi	sp,sp,96
ffffffffc020240c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020240e:	85a2                	mv	a1,s0
ffffffffc0202410:	00004517          	auipc	a0,0x4
ffffffffc0202414:	d1850513          	addi	a0,a0,-744 # ffffffffc0206128 <commands+0x1028>
ffffffffc0202418:	cb5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc020241c:	bfe1                	j	ffffffffc02023f4 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020241e:	4401                	li	s0,0
ffffffffc0202420:	bfd1                	j	ffffffffc02023f4 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202422:	00004697          	auipc	a3,0x4
ffffffffc0202426:	d3668693          	addi	a3,a3,-714 # ffffffffc0206158 <commands+0x1058>
ffffffffc020242a:	00003617          	auipc	a2,0x3
ffffffffc020242e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0205828 <commands+0x728>
ffffffffc0202432:	06900593          	li	a1,105
ffffffffc0202436:	00004517          	auipc	a0,0x4
ffffffffc020243a:	a4250513          	addi	a0,a0,-1470 # ffffffffc0205e78 <commands+0xd78>
ffffffffc020243e:	d8bfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202442 <swap_in>:
{
ffffffffc0202442:	7179                	addi	sp,sp,-48
ffffffffc0202444:	e84a                	sd	s2,16(sp)
ffffffffc0202446:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202448:	4505                	li	a0,1
{
ffffffffc020244a:	ec26                	sd	s1,24(sp)
ffffffffc020244c:	e44e                	sd	s3,8(sp)
ffffffffc020244e:	f406                	sd	ra,40(sp)
ffffffffc0202450:	f022                	sd	s0,32(sp)
ffffffffc0202452:	84ae                	mv	s1,a1
ffffffffc0202454:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202456:	34d000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
     assert(result!=NULL);
ffffffffc020245a:	c129                	beqz	a0,ffffffffc020249c <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020245c:	842a                	mv	s0,a0
ffffffffc020245e:	01893503          	ld	a0,24(s2)
ffffffffc0202462:	4601                	li	a2,0
ffffffffc0202464:	85a6                	mv	a1,s1
ffffffffc0202466:	449000ef          	jal	ra,ffffffffc02030ae <get_pte>
ffffffffc020246a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020246c:	6108                	ld	a0,0(a0)
ffffffffc020246e:	85a2                	mv	a1,s0
ffffffffc0202470:	487010ef          	jal	ra,ffffffffc02040f6 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202474:	00093583          	ld	a1,0(s2)
ffffffffc0202478:	8626                	mv	a2,s1
ffffffffc020247a:	00004517          	auipc	a0,0x4
ffffffffc020247e:	d5e50513          	addi	a0,a0,-674 # ffffffffc02061d8 <commands+0x10d8>
ffffffffc0202482:	81a1                	srli	a1,a1,0x8
ffffffffc0202484:	c49fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202488:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020248a:	0089b023          	sd	s0,0(s3)
}
ffffffffc020248e:	7402                	ld	s0,32(sp)
ffffffffc0202490:	64e2                	ld	s1,24(sp)
ffffffffc0202492:	6942                	ld	s2,16(sp)
ffffffffc0202494:	69a2                	ld	s3,8(sp)
ffffffffc0202496:	4501                	li	a0,0
ffffffffc0202498:	6145                	addi	sp,sp,48
ffffffffc020249a:	8082                	ret
     assert(result!=NULL);
ffffffffc020249c:	00004697          	auipc	a3,0x4
ffffffffc02024a0:	d2c68693          	addi	a3,a3,-724 # ffffffffc02061c8 <commands+0x10c8>
ffffffffc02024a4:	00003617          	auipc	a2,0x3
ffffffffc02024a8:	38460613          	addi	a2,a2,900 # ffffffffc0205828 <commands+0x728>
ffffffffc02024ac:	07f00593          	li	a1,127
ffffffffc02024b0:	00004517          	auipc	a0,0x4
ffffffffc02024b4:	9c850513          	addi	a0,a0,-1592 # ffffffffc0205e78 <commands+0xd78>
ffffffffc02024b8:	d11fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02024bc <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02024bc:	0000f797          	auipc	a5,0xf
ffffffffc02024c0:	04478793          	addi	a5,a5,68 # ffffffffc0211500 <free_area>
ffffffffc02024c4:	e79c                	sd	a5,8(a5)
ffffffffc02024c6:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02024c8:	0007a823          	sw	zero,16(a5)
}
ffffffffc02024cc:	8082                	ret

ffffffffc02024ce <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02024ce:	0000f517          	auipc	a0,0xf
ffffffffc02024d2:	04256503          	lwu	a0,66(a0) # ffffffffc0211510 <free_area+0x10>
ffffffffc02024d6:	8082                	ret

ffffffffc02024d8 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02024d8:	715d                	addi	sp,sp,-80
ffffffffc02024da:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02024dc:	0000f417          	auipc	s0,0xf
ffffffffc02024e0:	02440413          	addi	s0,s0,36 # ffffffffc0211500 <free_area>
ffffffffc02024e4:	641c                	ld	a5,8(s0)
ffffffffc02024e6:	e486                	sd	ra,72(sp)
ffffffffc02024e8:	fc26                	sd	s1,56(sp)
ffffffffc02024ea:	f84a                	sd	s2,48(sp)
ffffffffc02024ec:	f44e                	sd	s3,40(sp)
ffffffffc02024ee:	f052                	sd	s4,32(sp)
ffffffffc02024f0:	ec56                	sd	s5,24(sp)
ffffffffc02024f2:	e85a                	sd	s6,16(sp)
ffffffffc02024f4:	e45e                	sd	s7,8(sp)
ffffffffc02024f6:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02024f8:	2a878d63          	beq	a5,s0,ffffffffc02027b2 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02024fc:	4481                	li	s1,0
ffffffffc02024fe:	4901                	li	s2,0
ffffffffc0202500:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202504:	8b09                	andi	a4,a4,2
ffffffffc0202506:	2a070a63          	beqz	a4,ffffffffc02027ba <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc020250a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020250e:	679c                	ld	a5,8(a5)
ffffffffc0202510:	2905                	addiw	s2,s2,1
ffffffffc0202512:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202514:	fe8796e3          	bne	a5,s0,ffffffffc0202500 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202518:	89a6                	mv	s3,s1
ffffffffc020251a:	35b000ef          	jal	ra,ffffffffc0203074 <nr_free_pages>
ffffffffc020251e:	6f351e63          	bne	a0,s3,ffffffffc0202c1a <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202522:	4505                	li	a0,1
ffffffffc0202524:	27f000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202528:	8aaa                	mv	s5,a0
ffffffffc020252a:	42050863          	beqz	a0,ffffffffc020295a <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020252e:	4505                	li	a0,1
ffffffffc0202530:	273000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202534:	89aa                	mv	s3,a0
ffffffffc0202536:	70050263          	beqz	a0,ffffffffc0202c3a <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020253a:	4505                	li	a0,1
ffffffffc020253c:	267000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202540:	8a2a                	mv	s4,a0
ffffffffc0202542:	48050c63          	beqz	a0,ffffffffc02029da <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202546:	293a8a63          	beq	s5,s3,ffffffffc02027da <default_check+0x302>
ffffffffc020254a:	28aa8863          	beq	s5,a0,ffffffffc02027da <default_check+0x302>
ffffffffc020254e:	28a98663          	beq	s3,a0,ffffffffc02027da <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202552:	000aa783          	lw	a5,0(s5)
ffffffffc0202556:	2a079263          	bnez	a5,ffffffffc02027fa <default_check+0x322>
ffffffffc020255a:	0009a783          	lw	a5,0(s3)
ffffffffc020255e:	28079e63          	bnez	a5,ffffffffc02027fa <default_check+0x322>
ffffffffc0202562:	411c                	lw	a5,0(a0)
ffffffffc0202564:	28079b63          	bnez	a5,ffffffffc02027fa <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202568:	00013797          	auipc	a5,0x13
ffffffffc020256c:	0307b783          	ld	a5,48(a5) # ffffffffc0215598 <pages>
ffffffffc0202570:	40fa8733          	sub	a4,s5,a5
ffffffffc0202574:	00005617          	auipc	a2,0x5
ffffffffc0202578:	9e463603          	ld	a2,-1564(a2) # ffffffffc0206f58 <nbase>
ffffffffc020257c:	8719                	srai	a4,a4,0x6
ffffffffc020257e:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202580:	00013697          	auipc	a3,0x13
ffffffffc0202584:	0106b683          	ld	a3,16(a3) # ffffffffc0215590 <npage>
ffffffffc0202588:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020258a:	0732                	slli	a4,a4,0xc
ffffffffc020258c:	28d77763          	bgeu	a4,a3,ffffffffc020281a <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202590:	40f98733          	sub	a4,s3,a5
ffffffffc0202594:	8719                	srai	a4,a4,0x6
ffffffffc0202596:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202598:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020259a:	4cd77063          	bgeu	a4,a3,ffffffffc0202a5a <default_check+0x582>
    return page - pages + nbase;
ffffffffc020259e:	40f507b3          	sub	a5,a0,a5
ffffffffc02025a2:	8799                	srai	a5,a5,0x6
ffffffffc02025a4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02025a6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02025a8:	30d7f963          	bgeu	a5,a3,ffffffffc02028ba <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02025ac:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02025ae:	00043c03          	ld	s8,0(s0)
ffffffffc02025b2:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02025b6:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02025ba:	e400                	sd	s0,8(s0)
ffffffffc02025bc:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02025be:	0000f797          	auipc	a5,0xf
ffffffffc02025c2:	f407a923          	sw	zero,-174(a5) # ffffffffc0211510 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02025c6:	1dd000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc02025ca:	2c051863          	bnez	a0,ffffffffc020289a <default_check+0x3c2>
    free_page(p0);
ffffffffc02025ce:	4585                	li	a1,1
ffffffffc02025d0:	8556                	mv	a0,s5
ffffffffc02025d2:	263000ef          	jal	ra,ffffffffc0203034 <free_pages>
    free_page(p1);
ffffffffc02025d6:	4585                	li	a1,1
ffffffffc02025d8:	854e                	mv	a0,s3
ffffffffc02025da:	25b000ef          	jal	ra,ffffffffc0203034 <free_pages>
    free_page(p2);
ffffffffc02025de:	4585                	li	a1,1
ffffffffc02025e0:	8552                	mv	a0,s4
ffffffffc02025e2:	253000ef          	jal	ra,ffffffffc0203034 <free_pages>
    assert(nr_free == 3);
ffffffffc02025e6:	4818                	lw	a4,16(s0)
ffffffffc02025e8:	478d                	li	a5,3
ffffffffc02025ea:	28f71863          	bne	a4,a5,ffffffffc020287a <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02025ee:	4505                	li	a0,1
ffffffffc02025f0:	1b3000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc02025f4:	89aa                	mv	s3,a0
ffffffffc02025f6:	26050263          	beqz	a0,ffffffffc020285a <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02025fa:	4505                	li	a0,1
ffffffffc02025fc:	1a7000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202600:	8aaa                	mv	s5,a0
ffffffffc0202602:	3a050c63          	beqz	a0,ffffffffc02029ba <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202606:	4505                	li	a0,1
ffffffffc0202608:	19b000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020260c:	8a2a                	mv	s4,a0
ffffffffc020260e:	38050663          	beqz	a0,ffffffffc020299a <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202612:	4505                	li	a0,1
ffffffffc0202614:	18f000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202618:	36051163          	bnez	a0,ffffffffc020297a <default_check+0x4a2>
    free_page(p0);
ffffffffc020261c:	4585                	li	a1,1
ffffffffc020261e:	854e                	mv	a0,s3
ffffffffc0202620:	215000ef          	jal	ra,ffffffffc0203034 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202624:	641c                	ld	a5,8(s0)
ffffffffc0202626:	20878a63          	beq	a5,s0,ffffffffc020283a <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc020262a:	4505                	li	a0,1
ffffffffc020262c:	177000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202630:	30a99563          	bne	s3,a0,ffffffffc020293a <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202634:	4505                	li	a0,1
ffffffffc0202636:	16d000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020263a:	2e051063          	bnez	a0,ffffffffc020291a <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020263e:	481c                	lw	a5,16(s0)
ffffffffc0202640:	2a079d63          	bnez	a5,ffffffffc02028fa <default_check+0x422>
    free_page(p);
ffffffffc0202644:	854e                	mv	a0,s3
ffffffffc0202646:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202648:	01843023          	sd	s8,0(s0)
ffffffffc020264c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202650:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202654:	1e1000ef          	jal	ra,ffffffffc0203034 <free_pages>
    free_page(p1);
ffffffffc0202658:	4585                	li	a1,1
ffffffffc020265a:	8556                	mv	a0,s5
ffffffffc020265c:	1d9000ef          	jal	ra,ffffffffc0203034 <free_pages>
    free_page(p2);
ffffffffc0202660:	4585                	li	a1,1
ffffffffc0202662:	8552                	mv	a0,s4
ffffffffc0202664:	1d1000ef          	jal	ra,ffffffffc0203034 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202668:	4515                	li	a0,5
ffffffffc020266a:	139000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020266e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202670:	26050563          	beqz	a0,ffffffffc02028da <default_check+0x402>
ffffffffc0202674:	651c                	ld	a5,8(a0)
ffffffffc0202676:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202678:	8b85                	andi	a5,a5,1
ffffffffc020267a:	54079063          	bnez	a5,ffffffffc0202bba <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020267e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202680:	00043b03          	ld	s6,0(s0)
ffffffffc0202684:	00843a83          	ld	s5,8(s0)
ffffffffc0202688:	e000                	sd	s0,0(s0)
ffffffffc020268a:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc020268c:	117000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202690:	50051563          	bnez	a0,ffffffffc0202b9a <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202694:	08098a13          	addi	s4,s3,128
ffffffffc0202698:	8552                	mv	a0,s4
ffffffffc020269a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020269c:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02026a0:	0000f797          	auipc	a5,0xf
ffffffffc02026a4:	e607a823          	sw	zero,-400(a5) # ffffffffc0211510 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02026a8:	18d000ef          	jal	ra,ffffffffc0203034 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02026ac:	4511                	li	a0,4
ffffffffc02026ae:	0f5000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc02026b2:	4c051463          	bnez	a0,ffffffffc0202b7a <default_check+0x6a2>
ffffffffc02026b6:	0889b783          	ld	a5,136(s3)
ffffffffc02026ba:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02026bc:	8b85                	andi	a5,a5,1
ffffffffc02026be:	48078e63          	beqz	a5,ffffffffc0202b5a <default_check+0x682>
ffffffffc02026c2:	0909a703          	lw	a4,144(s3)
ffffffffc02026c6:	478d                	li	a5,3
ffffffffc02026c8:	48f71963          	bne	a4,a5,ffffffffc0202b5a <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02026cc:	450d                	li	a0,3
ffffffffc02026ce:	0d5000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc02026d2:	8c2a                	mv	s8,a0
ffffffffc02026d4:	46050363          	beqz	a0,ffffffffc0202b3a <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc02026d8:	4505                	li	a0,1
ffffffffc02026da:	0c9000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc02026de:	42051e63          	bnez	a0,ffffffffc0202b1a <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc02026e2:	418a1c63          	bne	s4,s8,ffffffffc0202afa <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02026e6:	4585                	li	a1,1
ffffffffc02026e8:	854e                	mv	a0,s3
ffffffffc02026ea:	14b000ef          	jal	ra,ffffffffc0203034 <free_pages>
    free_pages(p1, 3);
ffffffffc02026ee:	458d                	li	a1,3
ffffffffc02026f0:	8552                	mv	a0,s4
ffffffffc02026f2:	143000ef          	jal	ra,ffffffffc0203034 <free_pages>
ffffffffc02026f6:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02026fa:	04098c13          	addi	s8,s3,64
ffffffffc02026fe:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202700:	8b85                	andi	a5,a5,1
ffffffffc0202702:	3c078c63          	beqz	a5,ffffffffc0202ada <default_check+0x602>
ffffffffc0202706:	0109a703          	lw	a4,16(s3)
ffffffffc020270a:	4785                	li	a5,1
ffffffffc020270c:	3cf71763          	bne	a4,a5,ffffffffc0202ada <default_check+0x602>
ffffffffc0202710:	008a3783          	ld	a5,8(s4)
ffffffffc0202714:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202716:	8b85                	andi	a5,a5,1
ffffffffc0202718:	3a078163          	beqz	a5,ffffffffc0202aba <default_check+0x5e2>
ffffffffc020271c:	010a2703          	lw	a4,16(s4)
ffffffffc0202720:	478d                	li	a5,3
ffffffffc0202722:	38f71c63          	bne	a4,a5,ffffffffc0202aba <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202726:	4505                	li	a0,1
ffffffffc0202728:	07b000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020272c:	36a99763          	bne	s3,a0,ffffffffc0202a9a <default_check+0x5c2>
    free_page(p0);
ffffffffc0202730:	4585                	li	a1,1
ffffffffc0202732:	103000ef          	jal	ra,ffffffffc0203034 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202736:	4509                	li	a0,2
ffffffffc0202738:	06b000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020273c:	32aa1f63          	bne	s4,a0,ffffffffc0202a7a <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202740:	4589                	li	a1,2
ffffffffc0202742:	0f3000ef          	jal	ra,ffffffffc0203034 <free_pages>
    free_page(p2);
ffffffffc0202746:	4585                	li	a1,1
ffffffffc0202748:	8562                	mv	a0,s8
ffffffffc020274a:	0eb000ef          	jal	ra,ffffffffc0203034 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020274e:	4515                	li	a0,5
ffffffffc0202750:	053000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202754:	89aa                	mv	s3,a0
ffffffffc0202756:	48050263          	beqz	a0,ffffffffc0202bda <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc020275a:	4505                	li	a0,1
ffffffffc020275c:	047000ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc0202760:	2c051d63          	bnez	a0,ffffffffc0202a3a <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202764:	481c                	lw	a5,16(s0)
ffffffffc0202766:	2a079a63          	bnez	a5,ffffffffc0202a1a <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020276a:	4595                	li	a1,5
ffffffffc020276c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020276e:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202772:	01643023          	sd	s6,0(s0)
ffffffffc0202776:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc020277a:	0bb000ef          	jal	ra,ffffffffc0203034 <free_pages>
    return listelm->next;
ffffffffc020277e:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202780:	00878963          	beq	a5,s0,ffffffffc0202792 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202784:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202788:	679c                	ld	a5,8(a5)
ffffffffc020278a:	397d                	addiw	s2,s2,-1
ffffffffc020278c:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020278e:	fe879be3          	bne	a5,s0,ffffffffc0202784 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202792:	26091463          	bnez	s2,ffffffffc02029fa <default_check+0x522>
    assert(total == 0);
ffffffffc0202796:	46049263          	bnez	s1,ffffffffc0202bfa <default_check+0x722>
}
ffffffffc020279a:	60a6                	ld	ra,72(sp)
ffffffffc020279c:	6406                	ld	s0,64(sp)
ffffffffc020279e:	74e2                	ld	s1,56(sp)
ffffffffc02027a0:	7942                	ld	s2,48(sp)
ffffffffc02027a2:	79a2                	ld	s3,40(sp)
ffffffffc02027a4:	7a02                	ld	s4,32(sp)
ffffffffc02027a6:	6ae2                	ld	s5,24(sp)
ffffffffc02027a8:	6b42                	ld	s6,16(sp)
ffffffffc02027aa:	6ba2                	ld	s7,8(sp)
ffffffffc02027ac:	6c02                	ld	s8,0(sp)
ffffffffc02027ae:	6161                	addi	sp,sp,80
ffffffffc02027b0:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027b2:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02027b4:	4481                	li	s1,0
ffffffffc02027b6:	4901                	li	s2,0
ffffffffc02027b8:	b38d                	j	ffffffffc020251a <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02027ba:	00003697          	auipc	a3,0x3
ffffffffc02027be:	6e668693          	addi	a3,a3,1766 # ffffffffc0205ea0 <commands+0xda0>
ffffffffc02027c2:	00003617          	auipc	a2,0x3
ffffffffc02027c6:	06660613          	addi	a2,a2,102 # ffffffffc0205828 <commands+0x728>
ffffffffc02027ca:	0f000593          	li	a1,240
ffffffffc02027ce:	00004517          	auipc	a0,0x4
ffffffffc02027d2:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0206218 <commands+0x1118>
ffffffffc02027d6:	9f3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02027da:	00004697          	auipc	a3,0x4
ffffffffc02027de:	ab668693          	addi	a3,a3,-1354 # ffffffffc0206290 <commands+0x1190>
ffffffffc02027e2:	00003617          	auipc	a2,0x3
ffffffffc02027e6:	04660613          	addi	a2,a2,70 # ffffffffc0205828 <commands+0x728>
ffffffffc02027ea:	0bd00593          	li	a1,189
ffffffffc02027ee:	00004517          	auipc	a0,0x4
ffffffffc02027f2:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0206218 <commands+0x1118>
ffffffffc02027f6:	9d3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02027fa:	00004697          	auipc	a3,0x4
ffffffffc02027fe:	abe68693          	addi	a3,a3,-1346 # ffffffffc02062b8 <commands+0x11b8>
ffffffffc0202802:	00003617          	auipc	a2,0x3
ffffffffc0202806:	02660613          	addi	a2,a2,38 # ffffffffc0205828 <commands+0x728>
ffffffffc020280a:	0be00593          	li	a1,190
ffffffffc020280e:	00004517          	auipc	a0,0x4
ffffffffc0202812:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202816:	9b3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020281a:	00004697          	auipc	a3,0x4
ffffffffc020281e:	ade68693          	addi	a3,a3,-1314 # ffffffffc02062f8 <commands+0x11f8>
ffffffffc0202822:	00003617          	auipc	a2,0x3
ffffffffc0202826:	00660613          	addi	a2,a2,6 # ffffffffc0205828 <commands+0x728>
ffffffffc020282a:	0c000593          	li	a1,192
ffffffffc020282e:	00004517          	auipc	a0,0x4
ffffffffc0202832:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202836:	993fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020283a:	00004697          	auipc	a3,0x4
ffffffffc020283e:	b4668693          	addi	a3,a3,-1210 # ffffffffc0206380 <commands+0x1280>
ffffffffc0202842:	00003617          	auipc	a2,0x3
ffffffffc0202846:	fe660613          	addi	a2,a2,-26 # ffffffffc0205828 <commands+0x728>
ffffffffc020284a:	0d900593          	li	a1,217
ffffffffc020284e:	00004517          	auipc	a0,0x4
ffffffffc0202852:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202856:	973fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020285a:	00004697          	auipc	a3,0x4
ffffffffc020285e:	9d668693          	addi	a3,a3,-1578 # ffffffffc0206230 <commands+0x1130>
ffffffffc0202862:	00003617          	auipc	a2,0x3
ffffffffc0202866:	fc660613          	addi	a2,a2,-58 # ffffffffc0205828 <commands+0x728>
ffffffffc020286a:	0d200593          	li	a1,210
ffffffffc020286e:	00004517          	auipc	a0,0x4
ffffffffc0202872:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202876:	953fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 3);
ffffffffc020287a:	00004697          	auipc	a3,0x4
ffffffffc020287e:	af668693          	addi	a3,a3,-1290 # ffffffffc0206370 <commands+0x1270>
ffffffffc0202882:	00003617          	auipc	a2,0x3
ffffffffc0202886:	fa660613          	addi	a2,a2,-90 # ffffffffc0205828 <commands+0x728>
ffffffffc020288a:	0d000593          	li	a1,208
ffffffffc020288e:	00004517          	auipc	a0,0x4
ffffffffc0202892:	98a50513          	addi	a0,a0,-1654 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202896:	933fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020289a:	00004697          	auipc	a3,0x4
ffffffffc020289e:	abe68693          	addi	a3,a3,-1346 # ffffffffc0206358 <commands+0x1258>
ffffffffc02028a2:	00003617          	auipc	a2,0x3
ffffffffc02028a6:	f8660613          	addi	a2,a2,-122 # ffffffffc0205828 <commands+0x728>
ffffffffc02028aa:	0cb00593          	li	a1,203
ffffffffc02028ae:	00004517          	auipc	a0,0x4
ffffffffc02028b2:	96a50513          	addi	a0,a0,-1686 # ffffffffc0206218 <commands+0x1118>
ffffffffc02028b6:	913fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02028ba:	00004697          	auipc	a3,0x4
ffffffffc02028be:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0206338 <commands+0x1238>
ffffffffc02028c2:	00003617          	auipc	a2,0x3
ffffffffc02028c6:	f6660613          	addi	a2,a2,-154 # ffffffffc0205828 <commands+0x728>
ffffffffc02028ca:	0c200593          	li	a1,194
ffffffffc02028ce:	00004517          	auipc	a0,0x4
ffffffffc02028d2:	94a50513          	addi	a0,a0,-1718 # ffffffffc0206218 <commands+0x1118>
ffffffffc02028d6:	8f3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != NULL);
ffffffffc02028da:	00004697          	auipc	a3,0x4
ffffffffc02028de:	ade68693          	addi	a3,a3,-1314 # ffffffffc02063b8 <commands+0x12b8>
ffffffffc02028e2:	00003617          	auipc	a2,0x3
ffffffffc02028e6:	f4660613          	addi	a2,a2,-186 # ffffffffc0205828 <commands+0x728>
ffffffffc02028ea:	0f800593          	li	a1,248
ffffffffc02028ee:	00004517          	auipc	a0,0x4
ffffffffc02028f2:	92a50513          	addi	a0,a0,-1750 # ffffffffc0206218 <commands+0x1118>
ffffffffc02028f6:	8d3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc02028fa:	00003697          	auipc	a3,0x3
ffffffffc02028fe:	74668693          	addi	a3,a3,1862 # ffffffffc0206040 <commands+0xf40>
ffffffffc0202902:	00003617          	auipc	a2,0x3
ffffffffc0202906:	f2660613          	addi	a2,a2,-218 # ffffffffc0205828 <commands+0x728>
ffffffffc020290a:	0df00593          	li	a1,223
ffffffffc020290e:	00004517          	auipc	a0,0x4
ffffffffc0202912:	90a50513          	addi	a0,a0,-1782 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202916:	8b3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020291a:	00004697          	auipc	a3,0x4
ffffffffc020291e:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0206358 <commands+0x1258>
ffffffffc0202922:	00003617          	auipc	a2,0x3
ffffffffc0202926:	f0660613          	addi	a2,a2,-250 # ffffffffc0205828 <commands+0x728>
ffffffffc020292a:	0dd00593          	li	a1,221
ffffffffc020292e:	00004517          	auipc	a0,0x4
ffffffffc0202932:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202936:	893fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020293a:	00004697          	auipc	a3,0x4
ffffffffc020293e:	a5e68693          	addi	a3,a3,-1442 # ffffffffc0206398 <commands+0x1298>
ffffffffc0202942:	00003617          	auipc	a2,0x3
ffffffffc0202946:	ee660613          	addi	a2,a2,-282 # ffffffffc0205828 <commands+0x728>
ffffffffc020294a:	0dc00593          	li	a1,220
ffffffffc020294e:	00004517          	auipc	a0,0x4
ffffffffc0202952:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202956:	873fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020295a:	00004697          	auipc	a3,0x4
ffffffffc020295e:	8d668693          	addi	a3,a3,-1834 # ffffffffc0206230 <commands+0x1130>
ffffffffc0202962:	00003617          	auipc	a2,0x3
ffffffffc0202966:	ec660613          	addi	a2,a2,-314 # ffffffffc0205828 <commands+0x728>
ffffffffc020296a:	0b900593          	li	a1,185
ffffffffc020296e:	00004517          	auipc	a0,0x4
ffffffffc0202972:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202976:	853fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020297a:	00004697          	auipc	a3,0x4
ffffffffc020297e:	9de68693          	addi	a3,a3,-1570 # ffffffffc0206358 <commands+0x1258>
ffffffffc0202982:	00003617          	auipc	a2,0x3
ffffffffc0202986:	ea660613          	addi	a2,a2,-346 # ffffffffc0205828 <commands+0x728>
ffffffffc020298a:	0d600593          	li	a1,214
ffffffffc020298e:	00004517          	auipc	a0,0x4
ffffffffc0202992:	88a50513          	addi	a0,a0,-1910 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202996:	833fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020299a:	00004697          	auipc	a3,0x4
ffffffffc020299e:	8d668693          	addi	a3,a3,-1834 # ffffffffc0206270 <commands+0x1170>
ffffffffc02029a2:	00003617          	auipc	a2,0x3
ffffffffc02029a6:	e8660613          	addi	a2,a2,-378 # ffffffffc0205828 <commands+0x728>
ffffffffc02029aa:	0d400593          	li	a1,212
ffffffffc02029ae:	00004517          	auipc	a0,0x4
ffffffffc02029b2:	86a50513          	addi	a0,a0,-1942 # ffffffffc0206218 <commands+0x1118>
ffffffffc02029b6:	813fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02029ba:	00004697          	auipc	a3,0x4
ffffffffc02029be:	89668693          	addi	a3,a3,-1898 # ffffffffc0206250 <commands+0x1150>
ffffffffc02029c2:	00003617          	auipc	a2,0x3
ffffffffc02029c6:	e6660613          	addi	a2,a2,-410 # ffffffffc0205828 <commands+0x728>
ffffffffc02029ca:	0d300593          	li	a1,211
ffffffffc02029ce:	00004517          	auipc	a0,0x4
ffffffffc02029d2:	84a50513          	addi	a0,a0,-1974 # ffffffffc0206218 <commands+0x1118>
ffffffffc02029d6:	ff2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029da:	00004697          	auipc	a3,0x4
ffffffffc02029de:	89668693          	addi	a3,a3,-1898 # ffffffffc0206270 <commands+0x1170>
ffffffffc02029e2:	00003617          	auipc	a2,0x3
ffffffffc02029e6:	e4660613          	addi	a2,a2,-442 # ffffffffc0205828 <commands+0x728>
ffffffffc02029ea:	0bb00593          	li	a1,187
ffffffffc02029ee:	00004517          	auipc	a0,0x4
ffffffffc02029f2:	82a50513          	addi	a0,a0,-2006 # ffffffffc0206218 <commands+0x1118>
ffffffffc02029f6:	fd2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(count == 0);
ffffffffc02029fa:	00004697          	auipc	a3,0x4
ffffffffc02029fe:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0206508 <commands+0x1408>
ffffffffc0202a02:	00003617          	auipc	a2,0x3
ffffffffc0202a06:	e2660613          	addi	a2,a2,-474 # ffffffffc0205828 <commands+0x728>
ffffffffc0202a0a:	12500593          	li	a1,293
ffffffffc0202a0e:	00004517          	auipc	a0,0x4
ffffffffc0202a12:	80a50513          	addi	a0,a0,-2038 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202a16:	fb2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0202a1a:	00003697          	auipc	a3,0x3
ffffffffc0202a1e:	62668693          	addi	a3,a3,1574 # ffffffffc0206040 <commands+0xf40>
ffffffffc0202a22:	00003617          	auipc	a2,0x3
ffffffffc0202a26:	e0660613          	addi	a2,a2,-506 # ffffffffc0205828 <commands+0x728>
ffffffffc0202a2a:	11a00593          	li	a1,282
ffffffffc0202a2e:	00003517          	auipc	a0,0x3
ffffffffc0202a32:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202a36:	f92fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202a3a:	00004697          	auipc	a3,0x4
ffffffffc0202a3e:	91e68693          	addi	a3,a3,-1762 # ffffffffc0206358 <commands+0x1258>
ffffffffc0202a42:	00003617          	auipc	a2,0x3
ffffffffc0202a46:	de660613          	addi	a2,a2,-538 # ffffffffc0205828 <commands+0x728>
ffffffffc0202a4a:	11800593          	li	a1,280
ffffffffc0202a4e:	00003517          	auipc	a0,0x3
ffffffffc0202a52:	7ca50513          	addi	a0,a0,1994 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202a56:	f72fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202a5a:	00004697          	auipc	a3,0x4
ffffffffc0202a5e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0206318 <commands+0x1218>
ffffffffc0202a62:	00003617          	auipc	a2,0x3
ffffffffc0202a66:	dc660613          	addi	a2,a2,-570 # ffffffffc0205828 <commands+0x728>
ffffffffc0202a6a:	0c100593          	li	a1,193
ffffffffc0202a6e:	00003517          	auipc	a0,0x3
ffffffffc0202a72:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202a76:	f52fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202a7a:	00004697          	auipc	a3,0x4
ffffffffc0202a7e:	a4e68693          	addi	a3,a3,-1458 # ffffffffc02064c8 <commands+0x13c8>
ffffffffc0202a82:	00003617          	auipc	a2,0x3
ffffffffc0202a86:	da660613          	addi	a2,a2,-602 # ffffffffc0205828 <commands+0x728>
ffffffffc0202a8a:	11200593          	li	a1,274
ffffffffc0202a8e:	00003517          	auipc	a0,0x3
ffffffffc0202a92:	78a50513          	addi	a0,a0,1930 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202a96:	f32fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202a9a:	00004697          	auipc	a3,0x4
ffffffffc0202a9e:	a0e68693          	addi	a3,a3,-1522 # ffffffffc02064a8 <commands+0x13a8>
ffffffffc0202aa2:	00003617          	auipc	a2,0x3
ffffffffc0202aa6:	d8660613          	addi	a2,a2,-634 # ffffffffc0205828 <commands+0x728>
ffffffffc0202aaa:	11000593          	li	a1,272
ffffffffc0202aae:	00003517          	auipc	a0,0x3
ffffffffc0202ab2:	76a50513          	addi	a0,a0,1898 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202ab6:	f12fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202aba:	00004697          	auipc	a3,0x4
ffffffffc0202abe:	9c668693          	addi	a3,a3,-1594 # ffffffffc0206480 <commands+0x1380>
ffffffffc0202ac2:	00003617          	auipc	a2,0x3
ffffffffc0202ac6:	d6660613          	addi	a2,a2,-666 # ffffffffc0205828 <commands+0x728>
ffffffffc0202aca:	10e00593          	li	a1,270
ffffffffc0202ace:	00003517          	auipc	a0,0x3
ffffffffc0202ad2:	74a50513          	addi	a0,a0,1866 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202ad6:	ef2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202ada:	00004697          	auipc	a3,0x4
ffffffffc0202ade:	97e68693          	addi	a3,a3,-1666 # ffffffffc0206458 <commands+0x1358>
ffffffffc0202ae2:	00003617          	auipc	a2,0x3
ffffffffc0202ae6:	d4660613          	addi	a2,a2,-698 # ffffffffc0205828 <commands+0x728>
ffffffffc0202aea:	10d00593          	li	a1,269
ffffffffc0202aee:	00003517          	auipc	a0,0x3
ffffffffc0202af2:	72a50513          	addi	a0,a0,1834 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202af6:	ed2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202afa:	00004697          	auipc	a3,0x4
ffffffffc0202afe:	94e68693          	addi	a3,a3,-1714 # ffffffffc0206448 <commands+0x1348>
ffffffffc0202b02:	00003617          	auipc	a2,0x3
ffffffffc0202b06:	d2660613          	addi	a2,a2,-730 # ffffffffc0205828 <commands+0x728>
ffffffffc0202b0a:	10800593          	li	a1,264
ffffffffc0202b0e:	00003517          	auipc	a0,0x3
ffffffffc0202b12:	70a50513          	addi	a0,a0,1802 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202b16:	eb2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202b1a:	00004697          	auipc	a3,0x4
ffffffffc0202b1e:	83e68693          	addi	a3,a3,-1986 # ffffffffc0206358 <commands+0x1258>
ffffffffc0202b22:	00003617          	auipc	a2,0x3
ffffffffc0202b26:	d0660613          	addi	a2,a2,-762 # ffffffffc0205828 <commands+0x728>
ffffffffc0202b2a:	10700593          	li	a1,263
ffffffffc0202b2e:	00003517          	auipc	a0,0x3
ffffffffc0202b32:	6ea50513          	addi	a0,a0,1770 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202b36:	e92fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202b3a:	00004697          	auipc	a3,0x4
ffffffffc0202b3e:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0206428 <commands+0x1328>
ffffffffc0202b42:	00003617          	auipc	a2,0x3
ffffffffc0202b46:	ce660613          	addi	a2,a2,-794 # ffffffffc0205828 <commands+0x728>
ffffffffc0202b4a:	10600593          	li	a1,262
ffffffffc0202b4e:	00003517          	auipc	a0,0x3
ffffffffc0202b52:	6ca50513          	addi	a0,a0,1738 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202b56:	e72fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202b5a:	00004697          	auipc	a3,0x4
ffffffffc0202b5e:	89e68693          	addi	a3,a3,-1890 # ffffffffc02063f8 <commands+0x12f8>
ffffffffc0202b62:	00003617          	auipc	a2,0x3
ffffffffc0202b66:	cc660613          	addi	a2,a2,-826 # ffffffffc0205828 <commands+0x728>
ffffffffc0202b6a:	10500593          	li	a1,261
ffffffffc0202b6e:	00003517          	auipc	a0,0x3
ffffffffc0202b72:	6aa50513          	addi	a0,a0,1706 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202b76:	e52fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202b7a:	00004697          	auipc	a3,0x4
ffffffffc0202b7e:	86668693          	addi	a3,a3,-1946 # ffffffffc02063e0 <commands+0x12e0>
ffffffffc0202b82:	00003617          	auipc	a2,0x3
ffffffffc0202b86:	ca660613          	addi	a2,a2,-858 # ffffffffc0205828 <commands+0x728>
ffffffffc0202b8a:	10400593          	li	a1,260
ffffffffc0202b8e:	00003517          	auipc	a0,0x3
ffffffffc0202b92:	68a50513          	addi	a0,a0,1674 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202b96:	e32fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202b9a:	00003697          	auipc	a3,0x3
ffffffffc0202b9e:	7be68693          	addi	a3,a3,1982 # ffffffffc0206358 <commands+0x1258>
ffffffffc0202ba2:	00003617          	auipc	a2,0x3
ffffffffc0202ba6:	c8660613          	addi	a2,a2,-890 # ffffffffc0205828 <commands+0x728>
ffffffffc0202baa:	0fe00593          	li	a1,254
ffffffffc0202bae:	00003517          	auipc	a0,0x3
ffffffffc0202bb2:	66a50513          	addi	a0,a0,1642 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202bb6:	e12fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202bba:	00004697          	auipc	a3,0x4
ffffffffc0202bbe:	80e68693          	addi	a3,a3,-2034 # ffffffffc02063c8 <commands+0x12c8>
ffffffffc0202bc2:	00003617          	auipc	a2,0x3
ffffffffc0202bc6:	c6660613          	addi	a2,a2,-922 # ffffffffc0205828 <commands+0x728>
ffffffffc0202bca:	0f900593          	li	a1,249
ffffffffc0202bce:	00003517          	auipc	a0,0x3
ffffffffc0202bd2:	64a50513          	addi	a0,a0,1610 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202bd6:	df2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202bda:	00004697          	auipc	a3,0x4
ffffffffc0202bde:	90e68693          	addi	a3,a3,-1778 # ffffffffc02064e8 <commands+0x13e8>
ffffffffc0202be2:	00003617          	auipc	a2,0x3
ffffffffc0202be6:	c4660613          	addi	a2,a2,-954 # ffffffffc0205828 <commands+0x728>
ffffffffc0202bea:	11700593          	li	a1,279
ffffffffc0202bee:	00003517          	auipc	a0,0x3
ffffffffc0202bf2:	62a50513          	addi	a0,a0,1578 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202bf6:	dd2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == 0);
ffffffffc0202bfa:	00004697          	auipc	a3,0x4
ffffffffc0202bfe:	91e68693          	addi	a3,a3,-1762 # ffffffffc0206518 <commands+0x1418>
ffffffffc0202c02:	00003617          	auipc	a2,0x3
ffffffffc0202c06:	c2660613          	addi	a2,a2,-986 # ffffffffc0205828 <commands+0x728>
ffffffffc0202c0a:	12600593          	li	a1,294
ffffffffc0202c0e:	00003517          	auipc	a0,0x3
ffffffffc0202c12:	60a50513          	addi	a0,a0,1546 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202c16:	db2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202c1a:	00003697          	auipc	a3,0x3
ffffffffc0202c1e:	29668693          	addi	a3,a3,662 # ffffffffc0205eb0 <commands+0xdb0>
ffffffffc0202c22:	00003617          	auipc	a2,0x3
ffffffffc0202c26:	c0660613          	addi	a2,a2,-1018 # ffffffffc0205828 <commands+0x728>
ffffffffc0202c2a:	0f300593          	li	a1,243
ffffffffc0202c2e:	00003517          	auipc	a0,0x3
ffffffffc0202c32:	5ea50513          	addi	a0,a0,1514 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202c36:	d92fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202c3a:	00003697          	auipc	a3,0x3
ffffffffc0202c3e:	61668693          	addi	a3,a3,1558 # ffffffffc0206250 <commands+0x1150>
ffffffffc0202c42:	00003617          	auipc	a2,0x3
ffffffffc0202c46:	be660613          	addi	a2,a2,-1050 # ffffffffc0205828 <commands+0x728>
ffffffffc0202c4a:	0ba00593          	li	a1,186
ffffffffc0202c4e:	00003517          	auipc	a0,0x3
ffffffffc0202c52:	5ca50513          	addi	a0,a0,1482 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202c56:	d72fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202c5a <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202c5a:	1141                	addi	sp,sp,-16
ffffffffc0202c5c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202c5e:	14058463          	beqz	a1,ffffffffc0202da6 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0202c62:	00659693          	slli	a3,a1,0x6
ffffffffc0202c66:	96aa                	add	a3,a3,a0
ffffffffc0202c68:	87aa                	mv	a5,a0
ffffffffc0202c6a:	02d50263          	beq	a0,a3,ffffffffc0202c8e <default_free_pages+0x34>
ffffffffc0202c6e:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202c70:	8b05                	andi	a4,a4,1
ffffffffc0202c72:	10071a63          	bnez	a4,ffffffffc0202d86 <default_free_pages+0x12c>
ffffffffc0202c76:	6798                	ld	a4,8(a5)
ffffffffc0202c78:	8b09                	andi	a4,a4,2
ffffffffc0202c7a:	10071663          	bnez	a4,ffffffffc0202d86 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0202c7e:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0202c82:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202c86:	04078793          	addi	a5,a5,64
ffffffffc0202c8a:	fed792e3          	bne	a5,a3,ffffffffc0202c6e <default_free_pages+0x14>
    base->property = n;
ffffffffc0202c8e:	2581                	sext.w	a1,a1
ffffffffc0202c90:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202c92:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202c96:	4789                	li	a5,2
ffffffffc0202c98:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202c9c:	0000f697          	auipc	a3,0xf
ffffffffc0202ca0:	86468693          	addi	a3,a3,-1948 # ffffffffc0211500 <free_area>
ffffffffc0202ca4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202ca6:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202ca8:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202cac:	9db9                	addw	a1,a1,a4
ffffffffc0202cae:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202cb0:	0ad78463          	beq	a5,a3,ffffffffc0202d58 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0202cb4:	fe878713          	addi	a4,a5,-24
ffffffffc0202cb8:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202cbc:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202cbe:	00e56a63          	bltu	a0,a4,ffffffffc0202cd2 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0202cc2:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202cc4:	04d70c63          	beq	a4,a3,ffffffffc0202d1c <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0202cc8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202cca:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202cce:	fee57ae3          	bgeu	a0,a4,ffffffffc0202cc2 <default_free_pages+0x68>
ffffffffc0202cd2:	c199                	beqz	a1,ffffffffc0202cd8 <default_free_pages+0x7e>
ffffffffc0202cd4:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202cd8:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202cda:	e390                	sd	a2,0(a5)
ffffffffc0202cdc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202cde:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202ce0:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0202ce2:	00d70d63          	beq	a4,a3,ffffffffc0202cfc <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0202ce6:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0202cea:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0202cee:	02059813          	slli	a6,a1,0x20
ffffffffc0202cf2:	01a85793          	srli	a5,a6,0x1a
ffffffffc0202cf6:	97b2                	add	a5,a5,a2
ffffffffc0202cf8:	02f50c63          	beq	a0,a5,ffffffffc0202d30 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0202cfc:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0202cfe:	00d78c63          	beq	a5,a3,ffffffffc0202d16 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0202d02:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0202d04:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0202d08:	02061593          	slli	a1,a2,0x20
ffffffffc0202d0c:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202d10:	972a                	add	a4,a4,a0
ffffffffc0202d12:	04e68a63          	beq	a3,a4,ffffffffc0202d66 <default_free_pages+0x10c>
}
ffffffffc0202d16:	60a2                	ld	ra,8(sp)
ffffffffc0202d18:	0141                	addi	sp,sp,16
ffffffffc0202d1a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202d1c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202d1e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202d20:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202d22:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202d24:	02d70763          	beq	a4,a3,ffffffffc0202d52 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0202d28:	8832                	mv	a6,a2
ffffffffc0202d2a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202d2c:	87ba                	mv	a5,a4
ffffffffc0202d2e:	bf71                	j	ffffffffc0202cca <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0202d30:	491c                	lw	a5,16(a0)
ffffffffc0202d32:	9dbd                	addw	a1,a1,a5
ffffffffc0202d34:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202d38:	57f5                	li	a5,-3
ffffffffc0202d3a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202d3e:	01853803          	ld	a6,24(a0)
ffffffffc0202d42:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0202d44:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0202d46:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0202d4a:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0202d4c:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202d50:	b77d                	j	ffffffffc0202cfe <default_free_pages+0xa4>
ffffffffc0202d52:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202d54:	873e                	mv	a4,a5
ffffffffc0202d56:	bf41                	j	ffffffffc0202ce6 <default_free_pages+0x8c>
}
ffffffffc0202d58:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202d5a:	e390                	sd	a2,0(a5)
ffffffffc0202d5c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202d5e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202d60:	ed1c                	sd	a5,24(a0)
ffffffffc0202d62:	0141                	addi	sp,sp,16
ffffffffc0202d64:	8082                	ret
            base->property += p->property;
ffffffffc0202d66:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d6a:	ff078693          	addi	a3,a5,-16
ffffffffc0202d6e:	9e39                	addw	a2,a2,a4
ffffffffc0202d70:	c910                	sw	a2,16(a0)
ffffffffc0202d72:	5775                	li	a4,-3
ffffffffc0202d74:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202d78:	6398                	ld	a4,0(a5)
ffffffffc0202d7a:	679c                	ld	a5,8(a5)
}
ffffffffc0202d7c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202d7e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202d80:	e398                	sd	a4,0(a5)
ffffffffc0202d82:	0141                	addi	sp,sp,16
ffffffffc0202d84:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202d86:	00003697          	auipc	a3,0x3
ffffffffc0202d8a:	7aa68693          	addi	a3,a3,1962 # ffffffffc0206530 <commands+0x1430>
ffffffffc0202d8e:	00003617          	auipc	a2,0x3
ffffffffc0202d92:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0205828 <commands+0x728>
ffffffffc0202d96:	08300593          	li	a1,131
ffffffffc0202d9a:	00003517          	auipc	a0,0x3
ffffffffc0202d9e:	47e50513          	addi	a0,a0,1150 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202da2:	c26fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0202da6:	00003697          	auipc	a3,0x3
ffffffffc0202daa:	78268693          	addi	a3,a3,1922 # ffffffffc0206528 <commands+0x1428>
ffffffffc0202dae:	00003617          	auipc	a2,0x3
ffffffffc0202db2:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0205828 <commands+0x728>
ffffffffc0202db6:	08000593          	li	a1,128
ffffffffc0202dba:	00003517          	auipc	a0,0x3
ffffffffc0202dbe:	45e50513          	addi	a0,a0,1118 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202dc2:	c06fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202dc6 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202dc6:	c941                	beqz	a0,ffffffffc0202e56 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0202dc8:	0000e597          	auipc	a1,0xe
ffffffffc0202dcc:	73858593          	addi	a1,a1,1848 # ffffffffc0211500 <free_area>
ffffffffc0202dd0:	0105a803          	lw	a6,16(a1)
ffffffffc0202dd4:	872a                	mv	a4,a0
ffffffffc0202dd6:	02081793          	slli	a5,a6,0x20
ffffffffc0202dda:	9381                	srli	a5,a5,0x20
ffffffffc0202ddc:	00a7ee63          	bltu	a5,a0,ffffffffc0202df8 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202de0:	87ae                	mv	a5,a1
ffffffffc0202de2:	a801                	j	ffffffffc0202df2 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202de4:	ff87a683          	lw	a3,-8(a5)
ffffffffc0202de8:	02069613          	slli	a2,a3,0x20
ffffffffc0202dec:	9201                	srli	a2,a2,0x20
ffffffffc0202dee:	00e67763          	bgeu	a2,a4,ffffffffc0202dfc <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202df2:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202df4:	feb798e3          	bne	a5,a1,ffffffffc0202de4 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202df8:	4501                	li	a0,0
}
ffffffffc0202dfa:	8082                	ret
    return listelm->prev;
ffffffffc0202dfc:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202e00:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202e04:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0202e08:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0202e0c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202e10:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202e14:	02c77863          	bgeu	a4,a2,ffffffffc0202e44 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0202e18:	071a                	slli	a4,a4,0x6
ffffffffc0202e1a:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0202e1c:	41c686bb          	subw	a3,a3,t3
ffffffffc0202e20:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202e22:	00870613          	addi	a2,a4,8
ffffffffc0202e26:	4689                	li	a3,2
ffffffffc0202e28:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202e2c:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202e30:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0202e34:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202e38:	e290                	sd	a2,0(a3)
ffffffffc0202e3a:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202e3e:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0202e40:	01173c23          	sd	a7,24(a4)
ffffffffc0202e44:	41c8083b          	subw	a6,a6,t3
ffffffffc0202e48:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202e4c:	5775                	li	a4,-3
ffffffffc0202e4e:	17c1                	addi	a5,a5,-16
ffffffffc0202e50:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202e54:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202e56:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202e58:	00003697          	auipc	a3,0x3
ffffffffc0202e5c:	6d068693          	addi	a3,a3,1744 # ffffffffc0206528 <commands+0x1428>
ffffffffc0202e60:	00003617          	auipc	a2,0x3
ffffffffc0202e64:	9c860613          	addi	a2,a2,-1592 # ffffffffc0205828 <commands+0x728>
ffffffffc0202e68:	06200593          	li	a1,98
ffffffffc0202e6c:	00003517          	auipc	a0,0x3
ffffffffc0202e70:	3ac50513          	addi	a0,a0,940 # ffffffffc0206218 <commands+0x1118>
default_alloc_pages(size_t n) {
ffffffffc0202e74:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202e76:	b52fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202e7a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202e7a:	1141                	addi	sp,sp,-16
ffffffffc0202e7c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202e7e:	c5f1                	beqz	a1,ffffffffc0202f4a <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0202e80:	00659693          	slli	a3,a1,0x6
ffffffffc0202e84:	96aa                	add	a3,a3,a0
ffffffffc0202e86:	87aa                	mv	a5,a0
ffffffffc0202e88:	00d50f63          	beq	a0,a3,ffffffffc0202ea6 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202e8c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202e8e:	8b05                	andi	a4,a4,1
ffffffffc0202e90:	cf49                	beqz	a4,ffffffffc0202f2a <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0202e92:	0007a823          	sw	zero,16(a5)
ffffffffc0202e96:	0007b423          	sd	zero,8(a5)
ffffffffc0202e9a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202e9e:	04078793          	addi	a5,a5,64
ffffffffc0202ea2:	fed795e3          	bne	a5,a3,ffffffffc0202e8c <default_init_memmap+0x12>
    base->property = n;
ffffffffc0202ea6:	2581                	sext.w	a1,a1
ffffffffc0202ea8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202eaa:	4789                	li	a5,2
ffffffffc0202eac:	00850713          	addi	a4,a0,8
ffffffffc0202eb0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202eb4:	0000e697          	auipc	a3,0xe
ffffffffc0202eb8:	64c68693          	addi	a3,a3,1612 # ffffffffc0211500 <free_area>
ffffffffc0202ebc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202ebe:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202ec0:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202ec4:	9db9                	addw	a1,a1,a4
ffffffffc0202ec6:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202ec8:	04d78a63          	beq	a5,a3,ffffffffc0202f1c <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0202ecc:	fe878713          	addi	a4,a5,-24
ffffffffc0202ed0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202ed4:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202ed6:	00e56a63          	bltu	a0,a4,ffffffffc0202eea <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0202eda:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202edc:	02d70263          	beq	a4,a3,ffffffffc0202f00 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0202ee0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202ee2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202ee6:	fee57ae3          	bgeu	a0,a4,ffffffffc0202eda <default_init_memmap+0x60>
ffffffffc0202eea:	c199                	beqz	a1,ffffffffc0202ef0 <default_init_memmap+0x76>
ffffffffc0202eec:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202ef0:	6398                	ld	a4,0(a5)
}
ffffffffc0202ef2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202ef4:	e390                	sd	a2,0(a5)
ffffffffc0202ef6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202ef8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202efa:	ed18                	sd	a4,24(a0)
ffffffffc0202efc:	0141                	addi	sp,sp,16
ffffffffc0202efe:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202f00:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202f02:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202f04:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202f06:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202f08:	00d70663          	beq	a4,a3,ffffffffc0202f14 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0202f0c:	8832                	mv	a6,a2
ffffffffc0202f0e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202f10:	87ba                	mv	a5,a4
ffffffffc0202f12:	bfc1                	j	ffffffffc0202ee2 <default_init_memmap+0x68>
}
ffffffffc0202f14:	60a2                	ld	ra,8(sp)
ffffffffc0202f16:	e290                	sd	a2,0(a3)
ffffffffc0202f18:	0141                	addi	sp,sp,16
ffffffffc0202f1a:	8082                	ret
ffffffffc0202f1c:	60a2                	ld	ra,8(sp)
ffffffffc0202f1e:	e390                	sd	a2,0(a5)
ffffffffc0202f20:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202f22:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202f24:	ed1c                	sd	a5,24(a0)
ffffffffc0202f26:	0141                	addi	sp,sp,16
ffffffffc0202f28:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202f2a:	00003697          	auipc	a3,0x3
ffffffffc0202f2e:	62e68693          	addi	a3,a3,1582 # ffffffffc0206558 <commands+0x1458>
ffffffffc0202f32:	00003617          	auipc	a2,0x3
ffffffffc0202f36:	8f660613          	addi	a2,a2,-1802 # ffffffffc0205828 <commands+0x728>
ffffffffc0202f3a:	04900593          	li	a1,73
ffffffffc0202f3e:	00003517          	auipc	a0,0x3
ffffffffc0202f42:	2da50513          	addi	a0,a0,730 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202f46:	a82fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0202f4a:	00003697          	auipc	a3,0x3
ffffffffc0202f4e:	5de68693          	addi	a3,a3,1502 # ffffffffc0206528 <commands+0x1428>
ffffffffc0202f52:	00003617          	auipc	a2,0x3
ffffffffc0202f56:	8d660613          	addi	a2,a2,-1834 # ffffffffc0205828 <commands+0x728>
ffffffffc0202f5a:	04600593          	li	a1,70
ffffffffc0202f5e:	00003517          	auipc	a0,0x3
ffffffffc0202f62:	2ba50513          	addi	a0,a0,698 # ffffffffc0206218 <commands+0x1118>
ffffffffc0202f66:	a62fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202f6a <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202f6a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202f6c:	00003617          	auipc	a2,0x3
ffffffffc0202f70:	ae460613          	addi	a2,a2,-1308 # ffffffffc0205a50 <commands+0x950>
ffffffffc0202f74:	06200593          	li	a1,98
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	af850513          	addi	a0,a0,-1288 # ffffffffc0205a70 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc0202f80:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202f82:	a46fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202f86 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0202f86:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202f88:	00003617          	auipc	a2,0x3
ffffffffc0202f8c:	0e060613          	addi	a2,a2,224 # ffffffffc0206068 <commands+0xf68>
ffffffffc0202f90:	07400593          	li	a1,116
ffffffffc0202f94:	00003517          	auipc	a0,0x3
ffffffffc0202f98:	adc50513          	addi	a0,a0,-1316 # ffffffffc0205a70 <commands+0x970>
pte2page(pte_t pte) {
ffffffffc0202f9c:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202f9e:	a2afd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202fa2 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202fa2:	7139                	addi	sp,sp,-64
ffffffffc0202fa4:	f426                	sd	s1,40(sp)
ffffffffc0202fa6:	f04a                	sd	s2,32(sp)
ffffffffc0202fa8:	ec4e                	sd	s3,24(sp)
ffffffffc0202faa:	e852                	sd	s4,16(sp)
ffffffffc0202fac:	e456                	sd	s5,8(sp)
ffffffffc0202fae:	e05a                	sd	s6,0(sp)
ffffffffc0202fb0:	fc06                	sd	ra,56(sp)
ffffffffc0202fb2:	f822                	sd	s0,48(sp)
ffffffffc0202fb4:	84aa                	mv	s1,a0
ffffffffc0202fb6:	00012917          	auipc	s2,0x12
ffffffffc0202fba:	5ea90913          	addi	s2,s2,1514 # ffffffffc02155a0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202fbe:	4a05                	li	s4,1
ffffffffc0202fc0:	00012a97          	auipc	s5,0x12
ffffffffc0202fc4:	5b8a8a93          	addi	s5,s5,1464 # ffffffffc0215578 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202fc8:	0005099b          	sext.w	s3,a0
ffffffffc0202fcc:	00012b17          	auipc	s6,0x12
ffffffffc0202fd0:	584b0b13          	addi	s6,s6,1412 # ffffffffc0215550 <check_mm_struct>
ffffffffc0202fd4:	a01d                	j	ffffffffc0202ffa <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0202fd6:	00093783          	ld	a5,0(s2)
ffffffffc0202fda:	6f9c                	ld	a5,24(a5)
ffffffffc0202fdc:	9782                	jalr	a5
ffffffffc0202fde:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202fe0:	4601                	li	a2,0
ffffffffc0202fe2:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202fe4:	ec0d                	bnez	s0,ffffffffc020301e <alloc_pages+0x7c>
ffffffffc0202fe6:	029a6c63          	bltu	s4,s1,ffffffffc020301e <alloc_pages+0x7c>
ffffffffc0202fea:	000aa783          	lw	a5,0(s5)
ffffffffc0202fee:	2781                	sext.w	a5,a5
ffffffffc0202ff0:	c79d                	beqz	a5,ffffffffc020301e <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ff2:	000b3503          	ld	a0,0(s6)
ffffffffc0202ff6:	b38ff0ef          	jal	ra,ffffffffc020232e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0202ffe:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0203000:	8526                	mv	a0,s1
ffffffffc0203002:	dbf1                	beqz	a5,ffffffffc0202fd6 <alloc_pages+0x34>
        intr_disable();
ffffffffc0203004:	dc0fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203008:	00093783          	ld	a5,0(s2)
ffffffffc020300c:	8526                	mv	a0,s1
ffffffffc020300e:	6f9c                	ld	a5,24(a5)
ffffffffc0203010:	9782                	jalr	a5
ffffffffc0203012:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203014:	daafd0ef          	jal	ra,ffffffffc02005be <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203018:	4601                	li	a2,0
ffffffffc020301a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020301c:	d469                	beqz	s0,ffffffffc0202fe6 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020301e:	70e2                	ld	ra,56(sp)
ffffffffc0203020:	8522                	mv	a0,s0
ffffffffc0203022:	7442                	ld	s0,48(sp)
ffffffffc0203024:	74a2                	ld	s1,40(sp)
ffffffffc0203026:	7902                	ld	s2,32(sp)
ffffffffc0203028:	69e2                	ld	s3,24(sp)
ffffffffc020302a:	6a42                	ld	s4,16(sp)
ffffffffc020302c:	6aa2                	ld	s5,8(sp)
ffffffffc020302e:	6b02                	ld	s6,0(sp)
ffffffffc0203030:	6121                	addi	sp,sp,64
ffffffffc0203032:	8082                	ret

ffffffffc0203034 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203034:	100027f3          	csrr	a5,sstatus
ffffffffc0203038:	8b89                	andi	a5,a5,2
ffffffffc020303a:	e799                	bnez	a5,ffffffffc0203048 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020303c:	00012797          	auipc	a5,0x12
ffffffffc0203040:	5647b783          	ld	a5,1380(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203044:	739c                	ld	a5,32(a5)
ffffffffc0203046:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0203048:	1101                	addi	sp,sp,-32
ffffffffc020304a:	ec06                	sd	ra,24(sp)
ffffffffc020304c:	e822                	sd	s0,16(sp)
ffffffffc020304e:	e426                	sd	s1,8(sp)
ffffffffc0203050:	842a                	mv	s0,a0
ffffffffc0203052:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0203054:	d70fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203058:	00012797          	auipc	a5,0x12
ffffffffc020305c:	5487b783          	ld	a5,1352(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203060:	739c                	ld	a5,32(a5)
ffffffffc0203062:	85a6                	mv	a1,s1
ffffffffc0203064:	8522                	mv	a0,s0
ffffffffc0203066:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0203068:	6442                	ld	s0,16(sp)
ffffffffc020306a:	60e2                	ld	ra,24(sp)
ffffffffc020306c:	64a2                	ld	s1,8(sp)
ffffffffc020306e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203070:	d4efd06f          	j	ffffffffc02005be <intr_enable>

ffffffffc0203074 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203074:	100027f3          	csrr	a5,sstatus
ffffffffc0203078:	8b89                	andi	a5,a5,2
ffffffffc020307a:	e799                	bnez	a5,ffffffffc0203088 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020307c:	00012797          	auipc	a5,0x12
ffffffffc0203080:	5247b783          	ld	a5,1316(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203084:	779c                	ld	a5,40(a5)
ffffffffc0203086:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0203088:	1141                	addi	sp,sp,-16
ffffffffc020308a:	e406                	sd	ra,8(sp)
ffffffffc020308c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020308e:	d36fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203092:	00012797          	auipc	a5,0x12
ffffffffc0203096:	50e7b783          	ld	a5,1294(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc020309a:	779c                	ld	a5,40(a5)
ffffffffc020309c:	9782                	jalr	a5
ffffffffc020309e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02030a0:	d1efd0ef          	jal	ra,ffffffffc02005be <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02030a4:	60a2                	ld	ra,8(sp)
ffffffffc02030a6:	8522                	mv	a0,s0
ffffffffc02030a8:	6402                	ld	s0,0(sp)
ffffffffc02030aa:	0141                	addi	sp,sp,16
ffffffffc02030ac:	8082                	ret

ffffffffc02030ae <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02030ae:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02030b2:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030b6:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02030b8:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030ba:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02030bc:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02030c0:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030c2:	f04a                	sd	s2,32(sp)
ffffffffc02030c4:	ec4e                	sd	s3,24(sp)
ffffffffc02030c6:	e852                	sd	s4,16(sp)
ffffffffc02030c8:	fc06                	sd	ra,56(sp)
ffffffffc02030ca:	f822                	sd	s0,48(sp)
ffffffffc02030cc:	e456                	sd	s5,8(sp)
ffffffffc02030ce:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02030d0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030d4:	892e                	mv	s2,a1
ffffffffc02030d6:	89b2                	mv	s3,a2
ffffffffc02030d8:	00012a17          	auipc	s4,0x12
ffffffffc02030dc:	4b8a0a13          	addi	s4,s4,1208 # ffffffffc0215590 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02030e0:	e7b5                	bnez	a5,ffffffffc020314c <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02030e2:	12060b63          	beqz	a2,ffffffffc0203218 <get_pte+0x16a>
ffffffffc02030e6:	4505                	li	a0,1
ffffffffc02030e8:	ebbff0ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc02030ec:	842a                	mv	s0,a0
ffffffffc02030ee:	12050563          	beqz	a0,ffffffffc0203218 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02030f2:	00012b17          	auipc	s6,0x12
ffffffffc02030f6:	4a6b0b13          	addi	s6,s6,1190 # ffffffffc0215598 <pages>
ffffffffc02030fa:	000b3503          	ld	a0,0(s6)
ffffffffc02030fe:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203102:	00012a17          	auipc	s4,0x12
ffffffffc0203106:	48ea0a13          	addi	s4,s4,1166 # ffffffffc0215590 <npage>
ffffffffc020310a:	40a40533          	sub	a0,s0,a0
ffffffffc020310e:	8519                	srai	a0,a0,0x6
ffffffffc0203110:	9556                	add	a0,a0,s5
ffffffffc0203112:	000a3703          	ld	a4,0(s4)
ffffffffc0203116:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020311a:	4685                	li	a3,1
ffffffffc020311c:	c014                	sw	a3,0(s0)
ffffffffc020311e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203120:	0532                	slli	a0,a0,0xc
ffffffffc0203122:	14e7f263          	bgeu	a5,a4,ffffffffc0203266 <get_pte+0x1b8>
ffffffffc0203126:	00012797          	auipc	a5,0x12
ffffffffc020312a:	4827b783          	ld	a5,1154(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc020312e:	6605                	lui	a2,0x1
ffffffffc0203130:	4581                	li	a1,0
ffffffffc0203132:	953e                	add	a0,a0,a5
ffffffffc0203134:	0ed010ef          	jal	ra,ffffffffc0204a20 <memset>
    return page - pages + nbase;
ffffffffc0203138:	000b3683          	ld	a3,0(s6)
ffffffffc020313c:	40d406b3          	sub	a3,s0,a3
ffffffffc0203140:	8699                	srai	a3,a3,0x6
ffffffffc0203142:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203144:	06aa                	slli	a3,a3,0xa
ffffffffc0203146:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020314a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020314c:	77fd                	lui	a5,0xfffff
ffffffffc020314e:	068a                	slli	a3,a3,0x2
ffffffffc0203150:	000a3703          	ld	a4,0(s4)
ffffffffc0203154:	8efd                	and	a3,a3,a5
ffffffffc0203156:	00c6d793          	srli	a5,a3,0xc
ffffffffc020315a:	0ce7f163          	bgeu	a5,a4,ffffffffc020321c <get_pte+0x16e>
ffffffffc020315e:	00012a97          	auipc	s5,0x12
ffffffffc0203162:	44aa8a93          	addi	s5,s5,1098 # ffffffffc02155a8 <va_pa_offset>
ffffffffc0203166:	000ab403          	ld	s0,0(s5)
ffffffffc020316a:	01595793          	srli	a5,s2,0x15
ffffffffc020316e:	1ff7f793          	andi	a5,a5,511
ffffffffc0203172:	96a2                	add	a3,a3,s0
ffffffffc0203174:	00379413          	slli	s0,a5,0x3
ffffffffc0203178:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020317a:	6014                	ld	a3,0(s0)
ffffffffc020317c:	0016f793          	andi	a5,a3,1
ffffffffc0203180:	e3ad                	bnez	a5,ffffffffc02031e2 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203182:	08098b63          	beqz	s3,ffffffffc0203218 <get_pte+0x16a>
ffffffffc0203186:	4505                	li	a0,1
ffffffffc0203188:	e1bff0ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020318c:	84aa                	mv	s1,a0
ffffffffc020318e:	c549                	beqz	a0,ffffffffc0203218 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203190:	00012b17          	auipc	s6,0x12
ffffffffc0203194:	408b0b13          	addi	s6,s6,1032 # ffffffffc0215598 <pages>
ffffffffc0203198:	000b3503          	ld	a0,0(s6)
ffffffffc020319c:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02031a0:	000a3703          	ld	a4,0(s4)
ffffffffc02031a4:	40a48533          	sub	a0,s1,a0
ffffffffc02031a8:	8519                	srai	a0,a0,0x6
ffffffffc02031aa:	954e                	add	a0,a0,s3
ffffffffc02031ac:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02031b0:	4685                	li	a3,1
ffffffffc02031b2:	c094                	sw	a3,0(s1)
ffffffffc02031b4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b6:	0532                	slli	a0,a0,0xc
ffffffffc02031b8:	08e7fa63          	bgeu	a5,a4,ffffffffc020324c <get_pte+0x19e>
ffffffffc02031bc:	000ab783          	ld	a5,0(s5)
ffffffffc02031c0:	6605                	lui	a2,0x1
ffffffffc02031c2:	4581                	li	a1,0
ffffffffc02031c4:	953e                	add	a0,a0,a5
ffffffffc02031c6:	05b010ef          	jal	ra,ffffffffc0204a20 <memset>
    return page - pages + nbase;
ffffffffc02031ca:	000b3683          	ld	a3,0(s6)
ffffffffc02031ce:	40d486b3          	sub	a3,s1,a3
ffffffffc02031d2:	8699                	srai	a3,a3,0x6
ffffffffc02031d4:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02031d6:	06aa                	slli	a3,a3,0xa
ffffffffc02031d8:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02031dc:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02031de:	000a3703          	ld	a4,0(s4)
ffffffffc02031e2:	068a                	slli	a3,a3,0x2
ffffffffc02031e4:	757d                	lui	a0,0xfffff
ffffffffc02031e6:	8ee9                	and	a3,a3,a0
ffffffffc02031e8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02031ec:	04e7f463          	bgeu	a5,a4,ffffffffc0203234 <get_pte+0x186>
ffffffffc02031f0:	000ab503          	ld	a0,0(s5)
ffffffffc02031f4:	00c95913          	srli	s2,s2,0xc
ffffffffc02031f8:	1ff97913          	andi	s2,s2,511
ffffffffc02031fc:	96aa                	add	a3,a3,a0
ffffffffc02031fe:	00391513          	slli	a0,s2,0x3
ffffffffc0203202:	9536                	add	a0,a0,a3
}
ffffffffc0203204:	70e2                	ld	ra,56(sp)
ffffffffc0203206:	7442                	ld	s0,48(sp)
ffffffffc0203208:	74a2                	ld	s1,40(sp)
ffffffffc020320a:	7902                	ld	s2,32(sp)
ffffffffc020320c:	69e2                	ld	s3,24(sp)
ffffffffc020320e:	6a42                	ld	s4,16(sp)
ffffffffc0203210:	6aa2                	ld	s5,8(sp)
ffffffffc0203212:	6b02                	ld	s6,0(sp)
ffffffffc0203214:	6121                	addi	sp,sp,64
ffffffffc0203216:	8082                	ret
            return NULL;
ffffffffc0203218:	4501                	li	a0,0
ffffffffc020321a:	b7ed                	j	ffffffffc0203204 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020321c:	00003617          	auipc	a2,0x3
ffffffffc0203220:	86460613          	addi	a2,a2,-1948 # ffffffffc0205a80 <commands+0x980>
ffffffffc0203224:	0e400593          	li	a1,228
ffffffffc0203228:	00003517          	auipc	a0,0x3
ffffffffc020322c:	39050513          	addi	a0,a0,912 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203230:	f99fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203234:	00003617          	auipc	a2,0x3
ffffffffc0203238:	84c60613          	addi	a2,a2,-1972 # ffffffffc0205a80 <commands+0x980>
ffffffffc020323c:	0ef00593          	li	a1,239
ffffffffc0203240:	00003517          	auipc	a0,0x3
ffffffffc0203244:	37850513          	addi	a0,a0,888 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203248:	f81fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020324c:	86aa                	mv	a3,a0
ffffffffc020324e:	00003617          	auipc	a2,0x3
ffffffffc0203252:	83260613          	addi	a2,a2,-1998 # ffffffffc0205a80 <commands+0x980>
ffffffffc0203256:	0ec00593          	li	a1,236
ffffffffc020325a:	00003517          	auipc	a0,0x3
ffffffffc020325e:	35e50513          	addi	a0,a0,862 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203262:	f67fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203266:	86aa                	mv	a3,a0
ffffffffc0203268:	00003617          	auipc	a2,0x3
ffffffffc020326c:	81860613          	addi	a2,a2,-2024 # ffffffffc0205a80 <commands+0x980>
ffffffffc0203270:	0e100593          	li	a1,225
ffffffffc0203274:	00003517          	auipc	a0,0x3
ffffffffc0203278:	34450513          	addi	a0,a0,836 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc020327c:	f4dfc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203280 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203280:	1141                	addi	sp,sp,-16
ffffffffc0203282:	e022                	sd	s0,0(sp)
ffffffffc0203284:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203286:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203288:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020328a:	e25ff0ef          	jal	ra,ffffffffc02030ae <get_pte>
    if (ptep_store != NULL) {
ffffffffc020328e:	c011                	beqz	s0,ffffffffc0203292 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203290:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203292:	c511                	beqz	a0,ffffffffc020329e <get_page+0x1e>
ffffffffc0203294:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0203296:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203298:	0017f713          	andi	a4,a5,1
ffffffffc020329c:	e709                	bnez	a4,ffffffffc02032a6 <get_page+0x26>
}
ffffffffc020329e:	60a2                	ld	ra,8(sp)
ffffffffc02032a0:	6402                	ld	s0,0(sp)
ffffffffc02032a2:	0141                	addi	sp,sp,16
ffffffffc02032a4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02032a6:	078a                	slli	a5,a5,0x2
ffffffffc02032a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032aa:	00012717          	auipc	a4,0x12
ffffffffc02032ae:	2e673703          	ld	a4,742(a4) # ffffffffc0215590 <npage>
ffffffffc02032b2:	00e7ff63          	bgeu	a5,a4,ffffffffc02032d0 <get_page+0x50>
ffffffffc02032b6:	60a2                	ld	ra,8(sp)
ffffffffc02032b8:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02032ba:	fff80537          	lui	a0,0xfff80
ffffffffc02032be:	97aa                	add	a5,a5,a0
ffffffffc02032c0:	079a                	slli	a5,a5,0x6
ffffffffc02032c2:	00012517          	auipc	a0,0x12
ffffffffc02032c6:	2d653503          	ld	a0,726(a0) # ffffffffc0215598 <pages>
ffffffffc02032ca:	953e                	add	a0,a0,a5
ffffffffc02032cc:	0141                	addi	sp,sp,16
ffffffffc02032ce:	8082                	ret
ffffffffc02032d0:	c9bff0ef          	jal	ra,ffffffffc0202f6a <pa2page.part.0>

ffffffffc02032d4 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02032d4:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02032d6:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02032d8:	ec26                	sd	s1,24(sp)
ffffffffc02032da:	f406                	sd	ra,40(sp)
ffffffffc02032dc:	f022                	sd	s0,32(sp)
ffffffffc02032de:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02032e0:	dcfff0ef          	jal	ra,ffffffffc02030ae <get_pte>
    if (ptep != NULL) {
ffffffffc02032e4:	c511                	beqz	a0,ffffffffc02032f0 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02032e6:	611c                	ld	a5,0(a0)
ffffffffc02032e8:	842a                	mv	s0,a0
ffffffffc02032ea:	0017f713          	andi	a4,a5,1
ffffffffc02032ee:	e711                	bnez	a4,ffffffffc02032fa <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02032f0:	70a2                	ld	ra,40(sp)
ffffffffc02032f2:	7402                	ld	s0,32(sp)
ffffffffc02032f4:	64e2                	ld	s1,24(sp)
ffffffffc02032f6:	6145                	addi	sp,sp,48
ffffffffc02032f8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02032fa:	078a                	slli	a5,a5,0x2
ffffffffc02032fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032fe:	00012717          	auipc	a4,0x12
ffffffffc0203302:	29273703          	ld	a4,658(a4) # ffffffffc0215590 <npage>
ffffffffc0203306:	06e7f363          	bgeu	a5,a4,ffffffffc020336c <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc020330a:	fff80537          	lui	a0,0xfff80
ffffffffc020330e:	97aa                	add	a5,a5,a0
ffffffffc0203310:	079a                	slli	a5,a5,0x6
ffffffffc0203312:	00012517          	auipc	a0,0x12
ffffffffc0203316:	28653503          	ld	a0,646(a0) # ffffffffc0215598 <pages>
ffffffffc020331a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020331c:	411c                	lw	a5,0(a0)
ffffffffc020331e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203322:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203324:	cb11                	beqz	a4,ffffffffc0203338 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203326:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020332a:	12048073          	sfence.vma	s1
}
ffffffffc020332e:	70a2                	ld	ra,40(sp)
ffffffffc0203330:	7402                	ld	s0,32(sp)
ffffffffc0203332:	64e2                	ld	s1,24(sp)
ffffffffc0203334:	6145                	addi	sp,sp,48
ffffffffc0203336:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203338:	100027f3          	csrr	a5,sstatus
ffffffffc020333c:	8b89                	andi	a5,a5,2
ffffffffc020333e:	eb89                	bnez	a5,ffffffffc0203350 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203340:	00012797          	auipc	a5,0x12
ffffffffc0203344:	2607b783          	ld	a5,608(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203348:	739c                	ld	a5,32(a5)
ffffffffc020334a:	4585                	li	a1,1
ffffffffc020334c:	9782                	jalr	a5
    if (flag) {
ffffffffc020334e:	bfe1                	j	ffffffffc0203326 <page_remove+0x52>
        intr_disable();
ffffffffc0203350:	e42a                	sd	a0,8(sp)
ffffffffc0203352:	a72fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203356:	00012797          	auipc	a5,0x12
ffffffffc020335a:	24a7b783          	ld	a5,586(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc020335e:	739c                	ld	a5,32(a5)
ffffffffc0203360:	6522                	ld	a0,8(sp)
ffffffffc0203362:	4585                	li	a1,1
ffffffffc0203364:	9782                	jalr	a5
        intr_enable();
ffffffffc0203366:	a58fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020336a:	bf75                	j	ffffffffc0203326 <page_remove+0x52>
ffffffffc020336c:	bffff0ef          	jal	ra,ffffffffc0202f6a <pa2page.part.0>

ffffffffc0203370 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203370:	7139                	addi	sp,sp,-64
ffffffffc0203372:	e852                	sd	s4,16(sp)
ffffffffc0203374:	8a32                	mv	s4,a2
ffffffffc0203376:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203378:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020337a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020337c:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020337e:	f426                	sd	s1,40(sp)
ffffffffc0203380:	fc06                	sd	ra,56(sp)
ffffffffc0203382:	f04a                	sd	s2,32(sp)
ffffffffc0203384:	ec4e                	sd	s3,24(sp)
ffffffffc0203386:	e456                	sd	s5,8(sp)
ffffffffc0203388:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020338a:	d25ff0ef          	jal	ra,ffffffffc02030ae <get_pte>
    if (ptep == NULL) {
ffffffffc020338e:	c961                	beqz	a0,ffffffffc020345e <page_insert+0xee>
    page->ref += 1;
ffffffffc0203390:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203392:	611c                	ld	a5,0(a0)
ffffffffc0203394:	89aa                	mv	s3,a0
ffffffffc0203396:	0016871b          	addiw	a4,a3,1
ffffffffc020339a:	c018                	sw	a4,0(s0)
ffffffffc020339c:	0017f713          	andi	a4,a5,1
ffffffffc02033a0:	ef05                	bnez	a4,ffffffffc02033d8 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02033a2:	00012717          	auipc	a4,0x12
ffffffffc02033a6:	1f673703          	ld	a4,502(a4) # ffffffffc0215598 <pages>
ffffffffc02033aa:	8c19                	sub	s0,s0,a4
ffffffffc02033ac:	000807b7          	lui	a5,0x80
ffffffffc02033b0:	8419                	srai	s0,s0,0x6
ffffffffc02033b2:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02033b4:	042a                	slli	s0,s0,0xa
ffffffffc02033b6:	8cc1                	or	s1,s1,s0
ffffffffc02033b8:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02033bc:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02033c0:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02033c4:	4501                	li	a0,0
}
ffffffffc02033c6:	70e2                	ld	ra,56(sp)
ffffffffc02033c8:	7442                	ld	s0,48(sp)
ffffffffc02033ca:	74a2                	ld	s1,40(sp)
ffffffffc02033cc:	7902                	ld	s2,32(sp)
ffffffffc02033ce:	69e2                	ld	s3,24(sp)
ffffffffc02033d0:	6a42                	ld	s4,16(sp)
ffffffffc02033d2:	6aa2                	ld	s5,8(sp)
ffffffffc02033d4:	6121                	addi	sp,sp,64
ffffffffc02033d6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02033d8:	078a                	slli	a5,a5,0x2
ffffffffc02033da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033dc:	00012717          	auipc	a4,0x12
ffffffffc02033e0:	1b473703          	ld	a4,436(a4) # ffffffffc0215590 <npage>
ffffffffc02033e4:	06e7ff63          	bgeu	a5,a4,ffffffffc0203462 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02033e8:	00012a97          	auipc	s5,0x12
ffffffffc02033ec:	1b0a8a93          	addi	s5,s5,432 # ffffffffc0215598 <pages>
ffffffffc02033f0:	000ab703          	ld	a4,0(s5)
ffffffffc02033f4:	fff80937          	lui	s2,0xfff80
ffffffffc02033f8:	993e                	add	s2,s2,a5
ffffffffc02033fa:	091a                	slli	s2,s2,0x6
ffffffffc02033fc:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc02033fe:	01240c63          	beq	s0,s2,ffffffffc0203416 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203402:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6aa34>
ffffffffc0203406:	fff7869b          	addiw	a3,a5,-1
ffffffffc020340a:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020340e:	c691                	beqz	a3,ffffffffc020341a <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203410:	120a0073          	sfence.vma	s4
}
ffffffffc0203414:	bf59                	j	ffffffffc02033aa <page_insert+0x3a>
ffffffffc0203416:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203418:	bf49                	j	ffffffffc02033aa <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020341a:	100027f3          	csrr	a5,sstatus
ffffffffc020341e:	8b89                	andi	a5,a5,2
ffffffffc0203420:	ef91                	bnez	a5,ffffffffc020343c <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203422:	00012797          	auipc	a5,0x12
ffffffffc0203426:	17e7b783          	ld	a5,382(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc020342a:	739c                	ld	a5,32(a5)
ffffffffc020342c:	4585                	li	a1,1
ffffffffc020342e:	854a                	mv	a0,s2
ffffffffc0203430:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203432:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203436:	120a0073          	sfence.vma	s4
ffffffffc020343a:	bf85                	j	ffffffffc02033aa <page_insert+0x3a>
        intr_disable();
ffffffffc020343c:	988fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203440:	00012797          	auipc	a5,0x12
ffffffffc0203444:	1607b783          	ld	a5,352(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203448:	739c                	ld	a5,32(a5)
ffffffffc020344a:	4585                	li	a1,1
ffffffffc020344c:	854a                	mv	a0,s2
ffffffffc020344e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203450:	96efd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203454:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203458:	120a0073          	sfence.vma	s4
ffffffffc020345c:	b7b9                	j	ffffffffc02033aa <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020345e:	5571                	li	a0,-4
ffffffffc0203460:	b79d                	j	ffffffffc02033c6 <page_insert+0x56>
ffffffffc0203462:	b09ff0ef          	jal	ra,ffffffffc0202f6a <pa2page.part.0>

ffffffffc0203466 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203466:	00003797          	auipc	a5,0x3
ffffffffc020346a:	11a78793          	addi	a5,a5,282 # ffffffffc0206580 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020346e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203470:	711d                	addi	sp,sp,-96
ffffffffc0203472:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203474:	00003517          	auipc	a0,0x3
ffffffffc0203478:	15450513          	addi	a0,a0,340 # ffffffffc02065c8 <default_pmm_manager+0x48>
    pmm_manager = &default_pmm_manager;
ffffffffc020347c:	00012b97          	auipc	s7,0x12
ffffffffc0203480:	124b8b93          	addi	s7,s7,292 # ffffffffc02155a0 <pmm_manager>
void pmm_init(void) {
ffffffffc0203484:	ec86                	sd	ra,88(sp)
ffffffffc0203486:	e4a6                	sd	s1,72(sp)
ffffffffc0203488:	fc4e                	sd	s3,56(sp)
ffffffffc020348a:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020348c:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203490:	e8a2                	sd	s0,80(sp)
ffffffffc0203492:	e0ca                	sd	s2,64(sp)
ffffffffc0203494:	f852                	sd	s4,48(sp)
ffffffffc0203496:	f456                	sd	s5,40(sp)
ffffffffc0203498:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020349a:	c33fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc020349e:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034a2:	00012997          	auipc	s3,0x12
ffffffffc02034a6:	10698993          	addi	s3,s3,262 # ffffffffc02155a8 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02034aa:	00012497          	auipc	s1,0x12
ffffffffc02034ae:	0e648493          	addi	s1,s1,230 # ffffffffc0215590 <npage>
    pmm_manager->init();
ffffffffc02034b2:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02034b4:	00012b17          	auipc	s6,0x12
ffffffffc02034b8:	0e4b0b13          	addi	s6,s6,228 # ffffffffc0215598 <pages>
    pmm_manager->init();
ffffffffc02034bc:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034be:	57f5                	li	a5,-3
ffffffffc02034c0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02034c2:	00003517          	auipc	a0,0x3
ffffffffc02034c6:	11e50513          	addi	a0,a0,286 # ffffffffc02065e0 <default_pmm_manager+0x60>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034ca:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02034ce:	bfffc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02034d2:	46c5                	li	a3,17
ffffffffc02034d4:	06ee                	slli	a3,a3,0x1b
ffffffffc02034d6:	40100613          	li	a2,1025
ffffffffc02034da:	07e005b7          	lui	a1,0x7e00
ffffffffc02034de:	16fd                	addi	a3,a3,-1
ffffffffc02034e0:	0656                	slli	a2,a2,0x15
ffffffffc02034e2:	00003517          	auipc	a0,0x3
ffffffffc02034e6:	11650513          	addi	a0,a0,278 # ffffffffc02065f8 <default_pmm_manager+0x78>
ffffffffc02034ea:	be3fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02034ee:	777d                	lui	a4,0xfffff
ffffffffc02034f0:	00013797          	auipc	a5,0x13
ffffffffc02034f4:	0db78793          	addi	a5,a5,219 # ffffffffc02165cb <end+0xfff>
ffffffffc02034f8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02034fa:	00088737          	lui	a4,0x88
ffffffffc02034fe:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203500:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203504:	4701                	li	a4,0
ffffffffc0203506:	4585                	li	a1,1
ffffffffc0203508:	fff80837          	lui	a6,0xfff80
ffffffffc020350c:	a019                	j	ffffffffc0203512 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc020350e:	000b3783          	ld	a5,0(s6)
ffffffffc0203512:	00671693          	slli	a3,a4,0x6
ffffffffc0203516:	97b6                	add	a5,a5,a3
ffffffffc0203518:	07a1                	addi	a5,a5,8
ffffffffc020351a:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020351e:	6090                	ld	a2,0(s1)
ffffffffc0203520:	0705                	addi	a4,a4,1
ffffffffc0203522:	010607b3          	add	a5,a2,a6
ffffffffc0203526:	fef764e3          	bltu	a4,a5,ffffffffc020350e <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020352a:	000b3503          	ld	a0,0(s6)
ffffffffc020352e:	079a                	slli	a5,a5,0x6
ffffffffc0203530:	c0200737          	lui	a4,0xc0200
ffffffffc0203534:	00f506b3          	add	a3,a0,a5
ffffffffc0203538:	60e6e563          	bltu	a3,a4,ffffffffc0203b42 <pmm_init+0x6dc>
ffffffffc020353c:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203540:	4745                	li	a4,17
ffffffffc0203542:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203544:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203546:	4ae6e563          	bltu	a3,a4,ffffffffc02039f0 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020354a:	00003517          	auipc	a0,0x3
ffffffffc020354e:	0d650513          	addi	a0,a0,214 # ffffffffc0206620 <default_pmm_manager+0xa0>
ffffffffc0203552:	b7bfc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203556:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020355a:	00012917          	auipc	s2,0x12
ffffffffc020355e:	02e90913          	addi	s2,s2,46 # ffffffffc0215588 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203562:	7b9c                	ld	a5,48(a5)
ffffffffc0203564:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203566:	00003517          	auipc	a0,0x3
ffffffffc020356a:	0d250513          	addi	a0,a0,210 # ffffffffc0206638 <default_pmm_manager+0xb8>
ffffffffc020356e:	b5ffc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203572:	00006697          	auipc	a3,0x6
ffffffffc0203576:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020357a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020357e:	c02007b7          	lui	a5,0xc0200
ffffffffc0203582:	5cf6ec63          	bltu	a3,a5,ffffffffc0203b5a <pmm_init+0x6f4>
ffffffffc0203586:	0009b783          	ld	a5,0(s3)
ffffffffc020358a:	8e9d                	sub	a3,a3,a5
ffffffffc020358c:	00012797          	auipc	a5,0x12
ffffffffc0203590:	fed7ba23          	sd	a3,-12(a5) # ffffffffc0215580 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203594:	100027f3          	csrr	a5,sstatus
ffffffffc0203598:	8b89                	andi	a5,a5,2
ffffffffc020359a:	48079263          	bnez	a5,ffffffffc0203a1e <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020359e:	000bb783          	ld	a5,0(s7)
ffffffffc02035a2:	779c                	ld	a5,40(a5)
ffffffffc02035a4:	9782                	jalr	a5
ffffffffc02035a6:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02035a8:	6098                	ld	a4,0(s1)
ffffffffc02035aa:	c80007b7          	lui	a5,0xc8000
ffffffffc02035ae:	83b1                	srli	a5,a5,0xc
ffffffffc02035b0:	5ee7e163          	bltu	a5,a4,ffffffffc0203b92 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02035b4:	00093503          	ld	a0,0(s2)
ffffffffc02035b8:	5a050d63          	beqz	a0,ffffffffc0203b72 <pmm_init+0x70c>
ffffffffc02035bc:	03451793          	slli	a5,a0,0x34
ffffffffc02035c0:	5a079963          	bnez	a5,ffffffffc0203b72 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02035c4:	4601                	li	a2,0
ffffffffc02035c6:	4581                	li	a1,0
ffffffffc02035c8:	cb9ff0ef          	jal	ra,ffffffffc0203280 <get_page>
ffffffffc02035cc:	62051563          	bnez	a0,ffffffffc0203bf6 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02035d0:	4505                	li	a0,1
ffffffffc02035d2:	9d1ff0ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc02035d6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02035d8:	00093503          	ld	a0,0(s2)
ffffffffc02035dc:	4681                	li	a3,0
ffffffffc02035de:	4601                	li	a2,0
ffffffffc02035e0:	85d2                	mv	a1,s4
ffffffffc02035e2:	d8fff0ef          	jal	ra,ffffffffc0203370 <page_insert>
ffffffffc02035e6:	5e051863          	bnez	a0,ffffffffc0203bd6 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02035ea:	00093503          	ld	a0,0(s2)
ffffffffc02035ee:	4601                	li	a2,0
ffffffffc02035f0:	4581                	li	a1,0
ffffffffc02035f2:	abdff0ef          	jal	ra,ffffffffc02030ae <get_pte>
ffffffffc02035f6:	5c050063          	beqz	a0,ffffffffc0203bb6 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc02035fa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02035fc:	0017f713          	andi	a4,a5,1
ffffffffc0203600:	5a070963          	beqz	a4,ffffffffc0203bb2 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203604:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203606:	078a                	slli	a5,a5,0x2
ffffffffc0203608:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020360a:	52e7fa63          	bgeu	a5,a4,ffffffffc0203b3e <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020360e:	000b3683          	ld	a3,0(s6)
ffffffffc0203612:	fff80637          	lui	a2,0xfff80
ffffffffc0203616:	97b2                	add	a5,a5,a2
ffffffffc0203618:	079a                	slli	a5,a5,0x6
ffffffffc020361a:	97b6                	add	a5,a5,a3
ffffffffc020361c:	10fa16e3          	bne	s4,a5,ffffffffc0203f28 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0203620:	000a2683          	lw	a3,0(s4)
ffffffffc0203624:	4785                	li	a5,1
ffffffffc0203626:	12f69de3          	bne	a3,a5,ffffffffc0203f60 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020362a:	00093503          	ld	a0,0(s2)
ffffffffc020362e:	77fd                	lui	a5,0xfffff
ffffffffc0203630:	6114                	ld	a3,0(a0)
ffffffffc0203632:	068a                	slli	a3,a3,0x2
ffffffffc0203634:	8efd                	and	a3,a3,a5
ffffffffc0203636:	00c6d613          	srli	a2,a3,0xc
ffffffffc020363a:	10e677e3          	bgeu	a2,a4,ffffffffc0203f48 <pmm_init+0xae2>
ffffffffc020363e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203642:	96e2                	add	a3,a3,s8
ffffffffc0203644:	0006ba83          	ld	s5,0(a3)
ffffffffc0203648:	0a8a                	slli	s5,s5,0x2
ffffffffc020364a:	00fafab3          	and	s5,s5,a5
ffffffffc020364e:	00cad793          	srli	a5,s5,0xc
ffffffffc0203652:	62e7f263          	bgeu	a5,a4,ffffffffc0203c76 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203656:	4601                	li	a2,0
ffffffffc0203658:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020365a:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020365c:	a53ff0ef          	jal	ra,ffffffffc02030ae <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203660:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203662:	5f551a63          	bne	a0,s5,ffffffffc0203c56 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0203666:	4505                	li	a0,1
ffffffffc0203668:	93bff0ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020366c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020366e:	00093503          	ld	a0,0(s2)
ffffffffc0203672:	46d1                	li	a3,20
ffffffffc0203674:	6605                	lui	a2,0x1
ffffffffc0203676:	85d6                	mv	a1,s5
ffffffffc0203678:	cf9ff0ef          	jal	ra,ffffffffc0203370 <page_insert>
ffffffffc020367c:	58051d63          	bnez	a0,ffffffffc0203c16 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203680:	00093503          	ld	a0,0(s2)
ffffffffc0203684:	4601                	li	a2,0
ffffffffc0203686:	6585                	lui	a1,0x1
ffffffffc0203688:	a27ff0ef          	jal	ra,ffffffffc02030ae <get_pte>
ffffffffc020368c:	0e050ae3          	beqz	a0,ffffffffc0203f80 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0203690:	611c                	ld	a5,0(a0)
ffffffffc0203692:	0107f713          	andi	a4,a5,16
ffffffffc0203696:	6e070d63          	beqz	a4,ffffffffc0203d90 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc020369a:	8b91                	andi	a5,a5,4
ffffffffc020369c:	6a078a63          	beqz	a5,ffffffffc0203d50 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02036a0:	00093503          	ld	a0,0(s2)
ffffffffc02036a4:	611c                	ld	a5,0(a0)
ffffffffc02036a6:	8bc1                	andi	a5,a5,16
ffffffffc02036a8:	68078463          	beqz	a5,ffffffffc0203d30 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02036ac:	000aa703          	lw	a4,0(s5)
ffffffffc02036b0:	4785                	li	a5,1
ffffffffc02036b2:	58f71263          	bne	a4,a5,ffffffffc0203c36 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02036b6:	4681                	li	a3,0
ffffffffc02036b8:	6605                	lui	a2,0x1
ffffffffc02036ba:	85d2                	mv	a1,s4
ffffffffc02036bc:	cb5ff0ef          	jal	ra,ffffffffc0203370 <page_insert>
ffffffffc02036c0:	62051863          	bnez	a0,ffffffffc0203cf0 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02036c4:	000a2703          	lw	a4,0(s4)
ffffffffc02036c8:	4789                	li	a5,2
ffffffffc02036ca:	60f71363          	bne	a4,a5,ffffffffc0203cd0 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02036ce:	000aa783          	lw	a5,0(s5)
ffffffffc02036d2:	5c079f63          	bnez	a5,ffffffffc0203cb0 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02036d6:	00093503          	ld	a0,0(s2)
ffffffffc02036da:	4601                	li	a2,0
ffffffffc02036dc:	6585                	lui	a1,0x1
ffffffffc02036de:	9d1ff0ef          	jal	ra,ffffffffc02030ae <get_pte>
ffffffffc02036e2:	5a050763          	beqz	a0,ffffffffc0203c90 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02036e6:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02036e8:	00177793          	andi	a5,a4,1
ffffffffc02036ec:	4c078363          	beqz	a5,ffffffffc0203bb2 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02036f0:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02036f2:	00271793          	slli	a5,a4,0x2
ffffffffc02036f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036f8:	44d7f363          	bgeu	a5,a3,ffffffffc0203b3e <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02036fc:	000b3683          	ld	a3,0(s6)
ffffffffc0203700:	fff80637          	lui	a2,0xfff80
ffffffffc0203704:	97b2                	add	a5,a5,a2
ffffffffc0203706:	079a                	slli	a5,a5,0x6
ffffffffc0203708:	97b6                	add	a5,a5,a3
ffffffffc020370a:	6efa1363          	bne	s4,a5,ffffffffc0203df0 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020370e:	8b41                	andi	a4,a4,16
ffffffffc0203710:	6c071063          	bnez	a4,ffffffffc0203dd0 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203714:	00093503          	ld	a0,0(s2)
ffffffffc0203718:	4581                	li	a1,0
ffffffffc020371a:	bbbff0ef          	jal	ra,ffffffffc02032d4 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020371e:	000a2703          	lw	a4,0(s4)
ffffffffc0203722:	4785                	li	a5,1
ffffffffc0203724:	68f71663          	bne	a4,a5,ffffffffc0203db0 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0203728:	000aa783          	lw	a5,0(s5)
ffffffffc020372c:	74079e63          	bnez	a5,ffffffffc0203e88 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203730:	00093503          	ld	a0,0(s2)
ffffffffc0203734:	6585                	lui	a1,0x1
ffffffffc0203736:	b9fff0ef          	jal	ra,ffffffffc02032d4 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020373a:	000a2783          	lw	a5,0(s4)
ffffffffc020373e:	72079563          	bnez	a5,ffffffffc0203e68 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0203742:	000aa783          	lw	a5,0(s5)
ffffffffc0203746:	70079163          	bnez	a5,ffffffffc0203e48 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020374a:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020374e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203750:	000a3683          	ld	a3,0(s4)
ffffffffc0203754:	068a                	slli	a3,a3,0x2
ffffffffc0203756:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203758:	3ee6f363          	bgeu	a3,a4,ffffffffc0203b3e <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020375c:	fff807b7          	lui	a5,0xfff80
ffffffffc0203760:	000b3503          	ld	a0,0(s6)
ffffffffc0203764:	96be                	add	a3,a3,a5
ffffffffc0203766:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0203768:	00d507b3          	add	a5,a0,a3
ffffffffc020376c:	4390                	lw	a2,0(a5)
ffffffffc020376e:	4785                	li	a5,1
ffffffffc0203770:	6af61c63          	bne	a2,a5,ffffffffc0203e28 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0203774:	8699                	srai	a3,a3,0x6
ffffffffc0203776:	000805b7          	lui	a1,0x80
ffffffffc020377a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020377c:	00c69613          	slli	a2,a3,0xc
ffffffffc0203780:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203782:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203784:	68e67663          	bgeu	a2,a4,ffffffffc0203e10 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203788:	0009b603          	ld	a2,0(s3)
ffffffffc020378c:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020378e:	629c                	ld	a5,0(a3)
ffffffffc0203790:	078a                	slli	a5,a5,0x2
ffffffffc0203792:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203794:	3ae7f563          	bgeu	a5,a4,ffffffffc0203b3e <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203798:	8f8d                	sub	a5,a5,a1
ffffffffc020379a:	079a                	slli	a5,a5,0x6
ffffffffc020379c:	953e                	add	a0,a0,a5
ffffffffc020379e:	100027f3          	csrr	a5,sstatus
ffffffffc02037a2:	8b89                	andi	a5,a5,2
ffffffffc02037a4:	2c079763          	bnez	a5,ffffffffc0203a72 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02037a8:	000bb783          	ld	a5,0(s7)
ffffffffc02037ac:	4585                	li	a1,1
ffffffffc02037ae:	739c                	ld	a5,32(a5)
ffffffffc02037b0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02037b2:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02037b6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02037b8:	078a                	slli	a5,a5,0x2
ffffffffc02037ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037bc:	38e7f163          	bgeu	a5,a4,ffffffffc0203b3e <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02037c0:	000b3503          	ld	a0,0(s6)
ffffffffc02037c4:	fff80737          	lui	a4,0xfff80
ffffffffc02037c8:	97ba                	add	a5,a5,a4
ffffffffc02037ca:	079a                	slli	a5,a5,0x6
ffffffffc02037cc:	953e                	add	a0,a0,a5
ffffffffc02037ce:	100027f3          	csrr	a5,sstatus
ffffffffc02037d2:	8b89                	andi	a5,a5,2
ffffffffc02037d4:	28079363          	bnez	a5,ffffffffc0203a5a <pmm_init+0x5f4>
ffffffffc02037d8:	000bb783          	ld	a5,0(s7)
ffffffffc02037dc:	4585                	li	a1,1
ffffffffc02037de:	739c                	ld	a5,32(a5)
ffffffffc02037e0:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02037e2:	00093783          	ld	a5,0(s2)
ffffffffc02037e6:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6aa34>
  asm volatile("sfence.vma");
ffffffffc02037ea:	12000073          	sfence.vma
ffffffffc02037ee:	100027f3          	csrr	a5,sstatus
ffffffffc02037f2:	8b89                	andi	a5,a5,2
ffffffffc02037f4:	24079963          	bnez	a5,ffffffffc0203a46 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02037f8:	000bb783          	ld	a5,0(s7)
ffffffffc02037fc:	779c                	ld	a5,40(a5)
ffffffffc02037fe:	9782                	jalr	a5
ffffffffc0203800:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203802:	71441363          	bne	s0,s4,ffffffffc0203f08 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203806:	00003517          	auipc	a0,0x3
ffffffffc020380a:	11a50513          	addi	a0,a0,282 # ffffffffc0206920 <default_pmm_manager+0x3a0>
ffffffffc020380e:	8bffc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0203812:	100027f3          	csrr	a5,sstatus
ffffffffc0203816:	8b89                	andi	a5,a5,2
ffffffffc0203818:	20079d63          	bnez	a5,ffffffffc0203a32 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc020381c:	000bb783          	ld	a5,0(s7)
ffffffffc0203820:	779c                	ld	a5,40(a5)
ffffffffc0203822:	9782                	jalr	a5
ffffffffc0203824:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203826:	6098                	ld	a4,0(s1)
ffffffffc0203828:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020382c:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020382e:	00c71793          	slli	a5,a4,0xc
ffffffffc0203832:	6a05                	lui	s4,0x1
ffffffffc0203834:	02f47c63          	bgeu	s0,a5,ffffffffc020386c <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203838:	00c45793          	srli	a5,s0,0xc
ffffffffc020383c:	00093503          	ld	a0,0(s2)
ffffffffc0203840:	2ee7f263          	bgeu	a5,a4,ffffffffc0203b24 <pmm_init+0x6be>
ffffffffc0203844:	0009b583          	ld	a1,0(s3)
ffffffffc0203848:	4601                	li	a2,0
ffffffffc020384a:	95a2                	add	a1,a1,s0
ffffffffc020384c:	863ff0ef          	jal	ra,ffffffffc02030ae <get_pte>
ffffffffc0203850:	2a050a63          	beqz	a0,ffffffffc0203b04 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203854:	611c                	ld	a5,0(a0)
ffffffffc0203856:	078a                	slli	a5,a5,0x2
ffffffffc0203858:	0157f7b3          	and	a5,a5,s5
ffffffffc020385c:	28879463          	bne	a5,s0,ffffffffc0203ae4 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203860:	6098                	ld	a4,0(s1)
ffffffffc0203862:	9452                	add	s0,s0,s4
ffffffffc0203864:	00c71793          	slli	a5,a4,0xc
ffffffffc0203868:	fcf468e3          	bltu	s0,a5,ffffffffc0203838 <pmm_init+0x3d2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc020386c:	00093783          	ld	a5,0(s2)
ffffffffc0203870:	639c                	ld	a5,0(a5)
ffffffffc0203872:	66079b63          	bnez	a5,ffffffffc0203ee8 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0203876:	4505                	li	a0,1
ffffffffc0203878:	f2aff0ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020387c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020387e:	00093503          	ld	a0,0(s2)
ffffffffc0203882:	4699                	li	a3,6
ffffffffc0203884:	10000613          	li	a2,256
ffffffffc0203888:	85d6                	mv	a1,s5
ffffffffc020388a:	ae7ff0ef          	jal	ra,ffffffffc0203370 <page_insert>
ffffffffc020388e:	62051d63          	bnez	a0,ffffffffc0203ec8 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0203892:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9a34>
ffffffffc0203896:	4785                	li	a5,1
ffffffffc0203898:	60f71863          	bne	a4,a5,ffffffffc0203ea8 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020389c:	00093503          	ld	a0,0(s2)
ffffffffc02038a0:	6405                	lui	s0,0x1
ffffffffc02038a2:	4699                	li	a3,6
ffffffffc02038a4:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02038a8:	85d6                	mv	a1,s5
ffffffffc02038aa:	ac7ff0ef          	jal	ra,ffffffffc0203370 <page_insert>
ffffffffc02038ae:	46051163          	bnez	a0,ffffffffc0203d10 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02038b2:	000aa703          	lw	a4,0(s5)
ffffffffc02038b6:	4789                	li	a5,2
ffffffffc02038b8:	72f71463          	bne	a4,a5,ffffffffc0203fe0 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02038bc:	00003597          	auipc	a1,0x3
ffffffffc02038c0:	19c58593          	addi	a1,a1,412 # ffffffffc0206a58 <default_pmm_manager+0x4d8>
ffffffffc02038c4:	10000513          	li	a0,256
ffffffffc02038c8:	112010ef          	jal	ra,ffffffffc02049da <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02038cc:	10040593          	addi	a1,s0,256
ffffffffc02038d0:	10000513          	li	a0,256
ffffffffc02038d4:	118010ef          	jal	ra,ffffffffc02049ec <strcmp>
ffffffffc02038d8:	6e051463          	bnez	a0,ffffffffc0203fc0 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02038dc:	000b3683          	ld	a3,0(s6)
ffffffffc02038e0:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02038e4:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02038e6:	40da86b3          	sub	a3,s5,a3
ffffffffc02038ea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02038ec:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02038ee:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02038f0:	8031                	srli	s0,s0,0xc
ffffffffc02038f2:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02038f6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02038f8:	50f77c63          	bgeu	a4,a5,ffffffffc0203e10 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02038fc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203900:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203904:	96be                	add	a3,a3,a5
ffffffffc0203906:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020390a:	09a010ef          	jal	ra,ffffffffc02049a4 <strlen>
ffffffffc020390e:	68051963          	bnez	a0,ffffffffc0203fa0 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203912:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203916:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203918:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020391c:	068a                	slli	a3,a3,0x2
ffffffffc020391e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203920:	20f6ff63          	bgeu	a3,a5,ffffffffc0203b3e <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0203924:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203926:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203928:	4ef47463          	bgeu	s0,a5,ffffffffc0203e10 <pmm_init+0x9aa>
ffffffffc020392c:	0009b403          	ld	s0,0(s3)
ffffffffc0203930:	9436                	add	s0,s0,a3
ffffffffc0203932:	100027f3          	csrr	a5,sstatus
ffffffffc0203936:	8b89                	andi	a5,a5,2
ffffffffc0203938:	18079b63          	bnez	a5,ffffffffc0203ace <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc020393c:	000bb783          	ld	a5,0(s7)
ffffffffc0203940:	4585                	li	a1,1
ffffffffc0203942:	8556                	mv	a0,s5
ffffffffc0203944:	739c                	ld	a5,32(a5)
ffffffffc0203946:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203948:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020394a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020394c:	078a                	slli	a5,a5,0x2
ffffffffc020394e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203950:	1ee7f763          	bgeu	a5,a4,ffffffffc0203b3e <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203954:	000b3503          	ld	a0,0(s6)
ffffffffc0203958:	fff80737          	lui	a4,0xfff80
ffffffffc020395c:	97ba                	add	a5,a5,a4
ffffffffc020395e:	079a                	slli	a5,a5,0x6
ffffffffc0203960:	953e                	add	a0,a0,a5
ffffffffc0203962:	100027f3          	csrr	a5,sstatus
ffffffffc0203966:	8b89                	andi	a5,a5,2
ffffffffc0203968:	14079763          	bnez	a5,ffffffffc0203ab6 <pmm_init+0x650>
ffffffffc020396c:	000bb783          	ld	a5,0(s7)
ffffffffc0203970:	4585                	li	a1,1
ffffffffc0203972:	739c                	ld	a5,32(a5)
ffffffffc0203974:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203976:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020397a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020397c:	078a                	slli	a5,a5,0x2
ffffffffc020397e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203980:	1ae7ff63          	bgeu	a5,a4,ffffffffc0203b3e <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203984:	000b3503          	ld	a0,0(s6)
ffffffffc0203988:	fff80737          	lui	a4,0xfff80
ffffffffc020398c:	97ba                	add	a5,a5,a4
ffffffffc020398e:	079a                	slli	a5,a5,0x6
ffffffffc0203990:	953e                	add	a0,a0,a5
ffffffffc0203992:	100027f3          	csrr	a5,sstatus
ffffffffc0203996:	8b89                	andi	a5,a5,2
ffffffffc0203998:	10079363          	bnez	a5,ffffffffc0203a9e <pmm_init+0x638>
ffffffffc020399c:	000bb783          	ld	a5,0(s7)
ffffffffc02039a0:	4585                	li	a1,1
ffffffffc02039a2:	739c                	ld	a5,32(a5)
ffffffffc02039a4:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02039a6:	00093783          	ld	a5,0(s2)
ffffffffc02039aa:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02039ae:	12000073          	sfence.vma
ffffffffc02039b2:	100027f3          	csrr	a5,sstatus
ffffffffc02039b6:	8b89                	andi	a5,a5,2
ffffffffc02039b8:	0c079963          	bnez	a5,ffffffffc0203a8a <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc02039bc:	000bb783          	ld	a5,0(s7)
ffffffffc02039c0:	779c                	ld	a5,40(a5)
ffffffffc02039c2:	9782                	jalr	a5
ffffffffc02039c4:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02039c6:	3a8c1563          	bne	s8,s0,ffffffffc0203d70 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02039ca:	00003517          	auipc	a0,0x3
ffffffffc02039ce:	10650513          	addi	a0,a0,262 # ffffffffc0206ad0 <default_pmm_manager+0x550>
ffffffffc02039d2:	efafc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02039d6:	6446                	ld	s0,80(sp)
ffffffffc02039d8:	60e6                	ld	ra,88(sp)
ffffffffc02039da:	64a6                	ld	s1,72(sp)
ffffffffc02039dc:	6906                	ld	s2,64(sp)
ffffffffc02039de:	79e2                	ld	s3,56(sp)
ffffffffc02039e0:	7a42                	ld	s4,48(sp)
ffffffffc02039e2:	7aa2                	ld	s5,40(sp)
ffffffffc02039e4:	7b02                	ld	s6,32(sp)
ffffffffc02039e6:	6be2                	ld	s7,24(sp)
ffffffffc02039e8:	6c42                	ld	s8,16(sp)
ffffffffc02039ea:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02039ec:	80efe06f          	j	ffffffffc02019fa <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02039f0:	6785                	lui	a5,0x1
ffffffffc02039f2:	17fd                	addi	a5,a5,-1
ffffffffc02039f4:	96be                	add	a3,a3,a5
ffffffffc02039f6:	77fd                	lui	a5,0xfffff
ffffffffc02039f8:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc02039fa:	00c7d693          	srli	a3,a5,0xc
ffffffffc02039fe:	14c6f063          	bgeu	a3,a2,ffffffffc0203b3e <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0203a02:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0203a06:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203a08:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0203a0c:	6a10                	ld	a2,16(a2)
ffffffffc0203a0e:	069a                	slli	a3,a3,0x6
ffffffffc0203a10:	00c7d593          	srli	a1,a5,0xc
ffffffffc0203a14:	9536                	add	a0,a0,a3
ffffffffc0203a16:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203a18:	0009b583          	ld	a1,0(s3)
}
ffffffffc0203a1c:	b63d                	j	ffffffffc020354a <pmm_init+0xe4>
        intr_disable();
ffffffffc0203a1e:	ba7fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203a22:	000bb783          	ld	a5,0(s7)
ffffffffc0203a26:	779c                	ld	a5,40(a5)
ffffffffc0203a28:	9782                	jalr	a5
ffffffffc0203a2a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203a2c:	b93fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203a30:	bea5                	j	ffffffffc02035a8 <pmm_init+0x142>
        intr_disable();
ffffffffc0203a32:	b93fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203a36:	000bb783          	ld	a5,0(s7)
ffffffffc0203a3a:	779c                	ld	a5,40(a5)
ffffffffc0203a3c:	9782                	jalr	a5
ffffffffc0203a3e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203a40:	b7ffc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203a44:	b3cd                	j	ffffffffc0203826 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0203a46:	b7ffc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203a4a:	000bb783          	ld	a5,0(s7)
ffffffffc0203a4e:	779c                	ld	a5,40(a5)
ffffffffc0203a50:	9782                	jalr	a5
ffffffffc0203a52:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203a54:	b6bfc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203a58:	b36d                	j	ffffffffc0203802 <pmm_init+0x39c>
ffffffffc0203a5a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203a5c:	b69fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203a60:	000bb783          	ld	a5,0(s7)
ffffffffc0203a64:	6522                	ld	a0,8(sp)
ffffffffc0203a66:	4585                	li	a1,1
ffffffffc0203a68:	739c                	ld	a5,32(a5)
ffffffffc0203a6a:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a6c:	b53fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203a70:	bb8d                	j	ffffffffc02037e2 <pmm_init+0x37c>
ffffffffc0203a72:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203a74:	b51fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203a78:	000bb783          	ld	a5,0(s7)
ffffffffc0203a7c:	6522                	ld	a0,8(sp)
ffffffffc0203a7e:	4585                	li	a1,1
ffffffffc0203a80:	739c                	ld	a5,32(a5)
ffffffffc0203a82:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a84:	b3bfc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203a88:	b32d                	j	ffffffffc02037b2 <pmm_init+0x34c>
        intr_disable();
ffffffffc0203a8a:	b3bfc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203a8e:	000bb783          	ld	a5,0(s7)
ffffffffc0203a92:	779c                	ld	a5,40(a5)
ffffffffc0203a94:	9782                	jalr	a5
ffffffffc0203a96:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203a98:	b27fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203a9c:	b72d                	j	ffffffffc02039c6 <pmm_init+0x560>
ffffffffc0203a9e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203aa0:	b25fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203aa4:	000bb783          	ld	a5,0(s7)
ffffffffc0203aa8:	6522                	ld	a0,8(sp)
ffffffffc0203aaa:	4585                	li	a1,1
ffffffffc0203aac:	739c                	ld	a5,32(a5)
ffffffffc0203aae:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ab0:	b0ffc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203ab4:	bdcd                	j	ffffffffc02039a6 <pmm_init+0x540>
ffffffffc0203ab6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203ab8:	b0dfc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203abc:	000bb783          	ld	a5,0(s7)
ffffffffc0203ac0:	6522                	ld	a0,8(sp)
ffffffffc0203ac2:	4585                	li	a1,1
ffffffffc0203ac4:	739c                	ld	a5,32(a5)
ffffffffc0203ac6:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ac8:	af7fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203acc:	b56d                	j	ffffffffc0203976 <pmm_init+0x510>
        intr_disable();
ffffffffc0203ace:	af7fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203ad2:	000bb783          	ld	a5,0(s7)
ffffffffc0203ad6:	4585                	li	a1,1
ffffffffc0203ad8:	8556                	mv	a0,s5
ffffffffc0203ada:	739c                	ld	a5,32(a5)
ffffffffc0203adc:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ade:	ae1fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203ae2:	b59d                	j	ffffffffc0203948 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203ae4:	00003697          	auipc	a3,0x3
ffffffffc0203ae8:	e9c68693          	addi	a3,a3,-356 # ffffffffc0206980 <default_pmm_manager+0x400>
ffffffffc0203aec:	00002617          	auipc	a2,0x2
ffffffffc0203af0:	d3c60613          	addi	a2,a2,-708 # ffffffffc0205828 <commands+0x728>
ffffffffc0203af4:	19e00593          	li	a1,414
ffffffffc0203af8:	00003517          	auipc	a0,0x3
ffffffffc0203afc:	ac050513          	addi	a0,a0,-1344 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203b00:	ec8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203b04:	00003697          	auipc	a3,0x3
ffffffffc0203b08:	e3c68693          	addi	a3,a3,-452 # ffffffffc0206940 <default_pmm_manager+0x3c0>
ffffffffc0203b0c:	00002617          	auipc	a2,0x2
ffffffffc0203b10:	d1c60613          	addi	a2,a2,-740 # ffffffffc0205828 <commands+0x728>
ffffffffc0203b14:	19d00593          	li	a1,413
ffffffffc0203b18:	00003517          	auipc	a0,0x3
ffffffffc0203b1c:	aa050513          	addi	a0,a0,-1376 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203b20:	ea8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203b24:	86a2                	mv	a3,s0
ffffffffc0203b26:	00002617          	auipc	a2,0x2
ffffffffc0203b2a:	f5a60613          	addi	a2,a2,-166 # ffffffffc0205a80 <commands+0x980>
ffffffffc0203b2e:	19d00593          	li	a1,413
ffffffffc0203b32:	00003517          	auipc	a0,0x3
ffffffffc0203b36:	a8650513          	addi	a0,a0,-1402 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203b3a:	e8efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203b3e:	c2cff0ef          	jal	ra,ffffffffc0202f6a <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203b42:	00002617          	auipc	a2,0x2
ffffffffc0203b46:	2ee60613          	addi	a2,a2,750 # ffffffffc0205e30 <commands+0xd30>
ffffffffc0203b4a:	07f00593          	li	a1,127
ffffffffc0203b4e:	00003517          	auipc	a0,0x3
ffffffffc0203b52:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203b56:	e72fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203b5a:	00002617          	auipc	a2,0x2
ffffffffc0203b5e:	2d660613          	addi	a2,a2,726 # ffffffffc0205e30 <commands+0xd30>
ffffffffc0203b62:	0c300593          	li	a1,195
ffffffffc0203b66:	00003517          	auipc	a0,0x3
ffffffffc0203b6a:	a5250513          	addi	a0,a0,-1454 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203b6e:	e5afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203b72:	00003697          	auipc	a3,0x3
ffffffffc0203b76:	b0668693          	addi	a3,a3,-1274 # ffffffffc0206678 <default_pmm_manager+0xf8>
ffffffffc0203b7a:	00002617          	auipc	a2,0x2
ffffffffc0203b7e:	cae60613          	addi	a2,a2,-850 # ffffffffc0205828 <commands+0x728>
ffffffffc0203b82:	16100593          	li	a1,353
ffffffffc0203b86:	00003517          	auipc	a0,0x3
ffffffffc0203b8a:	a3250513          	addi	a0,a0,-1486 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203b8e:	e3afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203b92:	00003697          	auipc	a3,0x3
ffffffffc0203b96:	ac668693          	addi	a3,a3,-1338 # ffffffffc0206658 <default_pmm_manager+0xd8>
ffffffffc0203b9a:	00002617          	auipc	a2,0x2
ffffffffc0203b9e:	c8e60613          	addi	a2,a2,-882 # ffffffffc0205828 <commands+0x728>
ffffffffc0203ba2:	16000593          	li	a1,352
ffffffffc0203ba6:	00003517          	auipc	a0,0x3
ffffffffc0203baa:	a1250513          	addi	a0,a0,-1518 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203bae:	e1afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203bb2:	bd4ff0ef          	jal	ra,ffffffffc0202f86 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203bb6:	00003697          	auipc	a3,0x3
ffffffffc0203bba:	b5268693          	addi	a3,a3,-1198 # ffffffffc0206708 <default_pmm_manager+0x188>
ffffffffc0203bbe:	00002617          	auipc	a2,0x2
ffffffffc0203bc2:	c6a60613          	addi	a2,a2,-918 # ffffffffc0205828 <commands+0x728>
ffffffffc0203bc6:	16900593          	li	a1,361
ffffffffc0203bca:	00003517          	auipc	a0,0x3
ffffffffc0203bce:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203bd2:	df6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203bd6:	00003697          	auipc	a3,0x3
ffffffffc0203bda:	b0268693          	addi	a3,a3,-1278 # ffffffffc02066d8 <default_pmm_manager+0x158>
ffffffffc0203bde:	00002617          	auipc	a2,0x2
ffffffffc0203be2:	c4a60613          	addi	a2,a2,-950 # ffffffffc0205828 <commands+0x728>
ffffffffc0203be6:	16600593          	li	a1,358
ffffffffc0203bea:	00003517          	auipc	a0,0x3
ffffffffc0203bee:	9ce50513          	addi	a0,a0,-1586 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203bf2:	dd6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203bf6:	00003697          	auipc	a3,0x3
ffffffffc0203bfa:	aba68693          	addi	a3,a3,-1350 # ffffffffc02066b0 <default_pmm_manager+0x130>
ffffffffc0203bfe:	00002617          	auipc	a2,0x2
ffffffffc0203c02:	c2a60613          	addi	a2,a2,-982 # ffffffffc0205828 <commands+0x728>
ffffffffc0203c06:	16200593          	li	a1,354
ffffffffc0203c0a:	00003517          	auipc	a0,0x3
ffffffffc0203c0e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203c12:	db6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203c16:	00003697          	auipc	a3,0x3
ffffffffc0203c1a:	b7a68693          	addi	a3,a3,-1158 # ffffffffc0206790 <default_pmm_manager+0x210>
ffffffffc0203c1e:	00002617          	auipc	a2,0x2
ffffffffc0203c22:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0205828 <commands+0x728>
ffffffffc0203c26:	17200593          	li	a1,370
ffffffffc0203c2a:	00003517          	auipc	a0,0x3
ffffffffc0203c2e:	98e50513          	addi	a0,a0,-1650 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203c32:	d96fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203c36:	00003697          	auipc	a3,0x3
ffffffffc0203c3a:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0206830 <default_pmm_manager+0x2b0>
ffffffffc0203c3e:	00002617          	auipc	a2,0x2
ffffffffc0203c42:	bea60613          	addi	a2,a2,-1046 # ffffffffc0205828 <commands+0x728>
ffffffffc0203c46:	17700593          	li	a1,375
ffffffffc0203c4a:	00003517          	auipc	a0,0x3
ffffffffc0203c4e:	96e50513          	addi	a0,a0,-1682 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203c52:	d76fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203c56:	00003697          	auipc	a3,0x3
ffffffffc0203c5a:	b1268693          	addi	a3,a3,-1262 # ffffffffc0206768 <default_pmm_manager+0x1e8>
ffffffffc0203c5e:	00002617          	auipc	a2,0x2
ffffffffc0203c62:	bca60613          	addi	a2,a2,-1078 # ffffffffc0205828 <commands+0x728>
ffffffffc0203c66:	16f00593          	li	a1,367
ffffffffc0203c6a:	00003517          	auipc	a0,0x3
ffffffffc0203c6e:	94e50513          	addi	a0,a0,-1714 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203c72:	d56fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203c76:	86d6                	mv	a3,s5
ffffffffc0203c78:	00002617          	auipc	a2,0x2
ffffffffc0203c7c:	e0860613          	addi	a2,a2,-504 # ffffffffc0205a80 <commands+0x980>
ffffffffc0203c80:	16e00593          	li	a1,366
ffffffffc0203c84:	00003517          	auipc	a0,0x3
ffffffffc0203c88:	93450513          	addi	a0,a0,-1740 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203c8c:	d3cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203c90:	00003697          	auipc	a3,0x3
ffffffffc0203c94:	b3868693          	addi	a3,a3,-1224 # ffffffffc02067c8 <default_pmm_manager+0x248>
ffffffffc0203c98:	00002617          	auipc	a2,0x2
ffffffffc0203c9c:	b9060613          	addi	a2,a2,-1136 # ffffffffc0205828 <commands+0x728>
ffffffffc0203ca0:	17c00593          	li	a1,380
ffffffffc0203ca4:	00003517          	auipc	a0,0x3
ffffffffc0203ca8:	91450513          	addi	a0,a0,-1772 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203cac:	d1cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203cb0:	00003697          	auipc	a3,0x3
ffffffffc0203cb4:	be068693          	addi	a3,a3,-1056 # ffffffffc0206890 <default_pmm_manager+0x310>
ffffffffc0203cb8:	00002617          	auipc	a2,0x2
ffffffffc0203cbc:	b7060613          	addi	a2,a2,-1168 # ffffffffc0205828 <commands+0x728>
ffffffffc0203cc0:	17b00593          	li	a1,379
ffffffffc0203cc4:	00003517          	auipc	a0,0x3
ffffffffc0203cc8:	8f450513          	addi	a0,a0,-1804 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203ccc:	cfcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203cd0:	00003697          	auipc	a3,0x3
ffffffffc0203cd4:	ba868693          	addi	a3,a3,-1112 # ffffffffc0206878 <default_pmm_manager+0x2f8>
ffffffffc0203cd8:	00002617          	auipc	a2,0x2
ffffffffc0203cdc:	b5060613          	addi	a2,a2,-1200 # ffffffffc0205828 <commands+0x728>
ffffffffc0203ce0:	17a00593          	li	a1,378
ffffffffc0203ce4:	00003517          	auipc	a0,0x3
ffffffffc0203ce8:	8d450513          	addi	a0,a0,-1836 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203cec:	cdcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203cf0:	00003697          	auipc	a3,0x3
ffffffffc0203cf4:	b5868693          	addi	a3,a3,-1192 # ffffffffc0206848 <default_pmm_manager+0x2c8>
ffffffffc0203cf8:	00002617          	auipc	a2,0x2
ffffffffc0203cfc:	b3060613          	addi	a2,a2,-1232 # ffffffffc0205828 <commands+0x728>
ffffffffc0203d00:	17900593          	li	a1,377
ffffffffc0203d04:	00003517          	auipc	a0,0x3
ffffffffc0203d08:	8b450513          	addi	a0,a0,-1868 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203d0c:	cbcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203d10:	00003697          	auipc	a3,0x3
ffffffffc0203d14:	cf068693          	addi	a3,a3,-784 # ffffffffc0206a00 <default_pmm_manager+0x480>
ffffffffc0203d18:	00002617          	auipc	a2,0x2
ffffffffc0203d1c:	b1060613          	addi	a2,a2,-1264 # ffffffffc0205828 <commands+0x728>
ffffffffc0203d20:	1a700593          	li	a1,423
ffffffffc0203d24:	00003517          	auipc	a0,0x3
ffffffffc0203d28:	89450513          	addi	a0,a0,-1900 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203d2c:	c9cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203d30:	00003697          	auipc	a3,0x3
ffffffffc0203d34:	ae868693          	addi	a3,a3,-1304 # ffffffffc0206818 <default_pmm_manager+0x298>
ffffffffc0203d38:	00002617          	auipc	a2,0x2
ffffffffc0203d3c:	af060613          	addi	a2,a2,-1296 # ffffffffc0205828 <commands+0x728>
ffffffffc0203d40:	17600593          	li	a1,374
ffffffffc0203d44:	00003517          	auipc	a0,0x3
ffffffffc0203d48:	87450513          	addi	a0,a0,-1932 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203d4c:	c7cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203d50:	00003697          	auipc	a3,0x3
ffffffffc0203d54:	ab868693          	addi	a3,a3,-1352 # ffffffffc0206808 <default_pmm_manager+0x288>
ffffffffc0203d58:	00002617          	auipc	a2,0x2
ffffffffc0203d5c:	ad060613          	addi	a2,a2,-1328 # ffffffffc0205828 <commands+0x728>
ffffffffc0203d60:	17500593          	li	a1,373
ffffffffc0203d64:	00003517          	auipc	a0,0x3
ffffffffc0203d68:	85450513          	addi	a0,a0,-1964 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203d6c:	c5cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203d70:	00003697          	auipc	a3,0x3
ffffffffc0203d74:	b9068693          	addi	a3,a3,-1136 # ffffffffc0206900 <default_pmm_manager+0x380>
ffffffffc0203d78:	00002617          	auipc	a2,0x2
ffffffffc0203d7c:	ab060613          	addi	a2,a2,-1360 # ffffffffc0205828 <commands+0x728>
ffffffffc0203d80:	1b800593          	li	a1,440
ffffffffc0203d84:	00003517          	auipc	a0,0x3
ffffffffc0203d88:	83450513          	addi	a0,a0,-1996 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203d8c:	c3cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203d90:	00003697          	auipc	a3,0x3
ffffffffc0203d94:	a6868693          	addi	a3,a3,-1432 # ffffffffc02067f8 <default_pmm_manager+0x278>
ffffffffc0203d98:	00002617          	auipc	a2,0x2
ffffffffc0203d9c:	a9060613          	addi	a2,a2,-1392 # ffffffffc0205828 <commands+0x728>
ffffffffc0203da0:	17400593          	li	a1,372
ffffffffc0203da4:	00003517          	auipc	a0,0x3
ffffffffc0203da8:	81450513          	addi	a0,a0,-2028 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203dac:	c1cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203db0:	00003697          	auipc	a3,0x3
ffffffffc0203db4:	9a068693          	addi	a3,a3,-1632 # ffffffffc0206750 <default_pmm_manager+0x1d0>
ffffffffc0203db8:	00002617          	auipc	a2,0x2
ffffffffc0203dbc:	a7060613          	addi	a2,a2,-1424 # ffffffffc0205828 <commands+0x728>
ffffffffc0203dc0:	18100593          	li	a1,385
ffffffffc0203dc4:	00002517          	auipc	a0,0x2
ffffffffc0203dc8:	7f450513          	addi	a0,a0,2036 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203dcc:	bfcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203dd0:	00003697          	auipc	a3,0x3
ffffffffc0203dd4:	ad868693          	addi	a3,a3,-1320 # ffffffffc02068a8 <default_pmm_manager+0x328>
ffffffffc0203dd8:	00002617          	auipc	a2,0x2
ffffffffc0203ddc:	a5060613          	addi	a2,a2,-1456 # ffffffffc0205828 <commands+0x728>
ffffffffc0203de0:	17e00593          	li	a1,382
ffffffffc0203de4:	00002517          	auipc	a0,0x2
ffffffffc0203de8:	7d450513          	addi	a0,a0,2004 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203dec:	bdcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203df0:	00003697          	auipc	a3,0x3
ffffffffc0203df4:	94868693          	addi	a3,a3,-1720 # ffffffffc0206738 <default_pmm_manager+0x1b8>
ffffffffc0203df8:	00002617          	auipc	a2,0x2
ffffffffc0203dfc:	a3060613          	addi	a2,a2,-1488 # ffffffffc0205828 <commands+0x728>
ffffffffc0203e00:	17d00593          	li	a1,381
ffffffffc0203e04:	00002517          	auipc	a0,0x2
ffffffffc0203e08:	7b450513          	addi	a0,a0,1972 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203e0c:	bbcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203e10:	00002617          	auipc	a2,0x2
ffffffffc0203e14:	c7060613          	addi	a2,a2,-912 # ffffffffc0205a80 <commands+0x980>
ffffffffc0203e18:	06900593          	li	a1,105
ffffffffc0203e1c:	00002517          	auipc	a0,0x2
ffffffffc0203e20:	c5450513          	addi	a0,a0,-940 # ffffffffc0205a70 <commands+0x970>
ffffffffc0203e24:	ba4fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203e28:	00003697          	auipc	a3,0x3
ffffffffc0203e2c:	ab068693          	addi	a3,a3,-1360 # ffffffffc02068d8 <default_pmm_manager+0x358>
ffffffffc0203e30:	00002617          	auipc	a2,0x2
ffffffffc0203e34:	9f860613          	addi	a2,a2,-1544 # ffffffffc0205828 <commands+0x728>
ffffffffc0203e38:	18800593          	li	a1,392
ffffffffc0203e3c:	00002517          	auipc	a0,0x2
ffffffffc0203e40:	77c50513          	addi	a0,a0,1916 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203e44:	b84fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203e48:	00003697          	auipc	a3,0x3
ffffffffc0203e4c:	a4868693          	addi	a3,a3,-1464 # ffffffffc0206890 <default_pmm_manager+0x310>
ffffffffc0203e50:	00002617          	auipc	a2,0x2
ffffffffc0203e54:	9d860613          	addi	a2,a2,-1576 # ffffffffc0205828 <commands+0x728>
ffffffffc0203e58:	18600593          	li	a1,390
ffffffffc0203e5c:	00002517          	auipc	a0,0x2
ffffffffc0203e60:	75c50513          	addi	a0,a0,1884 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203e64:	b64fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203e68:	00003697          	auipc	a3,0x3
ffffffffc0203e6c:	a5868693          	addi	a3,a3,-1448 # ffffffffc02068c0 <default_pmm_manager+0x340>
ffffffffc0203e70:	00002617          	auipc	a2,0x2
ffffffffc0203e74:	9b860613          	addi	a2,a2,-1608 # ffffffffc0205828 <commands+0x728>
ffffffffc0203e78:	18500593          	li	a1,389
ffffffffc0203e7c:	00002517          	auipc	a0,0x2
ffffffffc0203e80:	73c50513          	addi	a0,a0,1852 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203e84:	b44fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203e88:	00003697          	auipc	a3,0x3
ffffffffc0203e8c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0206890 <default_pmm_manager+0x310>
ffffffffc0203e90:	00002617          	auipc	a2,0x2
ffffffffc0203e94:	99860613          	addi	a2,a2,-1640 # ffffffffc0205828 <commands+0x728>
ffffffffc0203e98:	18200593          	li	a1,386
ffffffffc0203e9c:	00002517          	auipc	a0,0x2
ffffffffc0203ea0:	71c50513          	addi	a0,a0,1820 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203ea4:	b24fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203ea8:	00003697          	auipc	a3,0x3
ffffffffc0203eac:	b4068693          	addi	a3,a3,-1216 # ffffffffc02069e8 <default_pmm_manager+0x468>
ffffffffc0203eb0:	00002617          	auipc	a2,0x2
ffffffffc0203eb4:	97860613          	addi	a2,a2,-1672 # ffffffffc0205828 <commands+0x728>
ffffffffc0203eb8:	1a600593          	li	a1,422
ffffffffc0203ebc:	00002517          	auipc	a0,0x2
ffffffffc0203ec0:	6fc50513          	addi	a0,a0,1788 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203ec4:	b04fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203ec8:	00003697          	auipc	a3,0x3
ffffffffc0203ecc:	ae868693          	addi	a3,a3,-1304 # ffffffffc02069b0 <default_pmm_manager+0x430>
ffffffffc0203ed0:	00002617          	auipc	a2,0x2
ffffffffc0203ed4:	95860613          	addi	a2,a2,-1704 # ffffffffc0205828 <commands+0x728>
ffffffffc0203ed8:	1a500593          	li	a1,421
ffffffffc0203edc:	00002517          	auipc	a0,0x2
ffffffffc0203ee0:	6dc50513          	addi	a0,a0,1756 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203ee4:	ae4fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203ee8:	00003697          	auipc	a3,0x3
ffffffffc0203eec:	ab068693          	addi	a3,a3,-1360 # ffffffffc0206998 <default_pmm_manager+0x418>
ffffffffc0203ef0:	00002617          	auipc	a2,0x2
ffffffffc0203ef4:	93860613          	addi	a2,a2,-1736 # ffffffffc0205828 <commands+0x728>
ffffffffc0203ef8:	1a100593          	li	a1,417
ffffffffc0203efc:	00002517          	auipc	a0,0x2
ffffffffc0203f00:	6bc50513          	addi	a0,a0,1724 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203f04:	ac4fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203f08:	00003697          	auipc	a3,0x3
ffffffffc0203f0c:	9f868693          	addi	a3,a3,-1544 # ffffffffc0206900 <default_pmm_manager+0x380>
ffffffffc0203f10:	00002617          	auipc	a2,0x2
ffffffffc0203f14:	91860613          	addi	a2,a2,-1768 # ffffffffc0205828 <commands+0x728>
ffffffffc0203f18:	19000593          	li	a1,400
ffffffffc0203f1c:	00002517          	auipc	a0,0x2
ffffffffc0203f20:	69c50513          	addi	a0,a0,1692 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203f24:	aa4fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203f28:	00003697          	auipc	a3,0x3
ffffffffc0203f2c:	81068693          	addi	a3,a3,-2032 # ffffffffc0206738 <default_pmm_manager+0x1b8>
ffffffffc0203f30:	00002617          	auipc	a2,0x2
ffffffffc0203f34:	8f860613          	addi	a2,a2,-1800 # ffffffffc0205828 <commands+0x728>
ffffffffc0203f38:	16a00593          	li	a1,362
ffffffffc0203f3c:	00002517          	auipc	a0,0x2
ffffffffc0203f40:	67c50513          	addi	a0,a0,1660 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203f44:	a84fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203f48:	00002617          	auipc	a2,0x2
ffffffffc0203f4c:	b3860613          	addi	a2,a2,-1224 # ffffffffc0205a80 <commands+0x980>
ffffffffc0203f50:	16d00593          	li	a1,365
ffffffffc0203f54:	00002517          	auipc	a0,0x2
ffffffffc0203f58:	66450513          	addi	a0,a0,1636 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203f5c:	a6cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203f60:	00002697          	auipc	a3,0x2
ffffffffc0203f64:	7f068693          	addi	a3,a3,2032 # ffffffffc0206750 <default_pmm_manager+0x1d0>
ffffffffc0203f68:	00002617          	auipc	a2,0x2
ffffffffc0203f6c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0205828 <commands+0x728>
ffffffffc0203f70:	16b00593          	li	a1,363
ffffffffc0203f74:	00002517          	auipc	a0,0x2
ffffffffc0203f78:	64450513          	addi	a0,a0,1604 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203f7c:	a4cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203f80:	00003697          	auipc	a3,0x3
ffffffffc0203f84:	84868693          	addi	a3,a3,-1976 # ffffffffc02067c8 <default_pmm_manager+0x248>
ffffffffc0203f88:	00002617          	auipc	a2,0x2
ffffffffc0203f8c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0205828 <commands+0x728>
ffffffffc0203f90:	17300593          	li	a1,371
ffffffffc0203f94:	00002517          	auipc	a0,0x2
ffffffffc0203f98:	62450513          	addi	a0,a0,1572 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203f9c:	a2cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203fa0:	00003697          	auipc	a3,0x3
ffffffffc0203fa4:	b0868693          	addi	a3,a3,-1272 # ffffffffc0206aa8 <default_pmm_manager+0x528>
ffffffffc0203fa8:	00002617          	auipc	a2,0x2
ffffffffc0203fac:	88060613          	addi	a2,a2,-1920 # ffffffffc0205828 <commands+0x728>
ffffffffc0203fb0:	1af00593          	li	a1,431
ffffffffc0203fb4:	00002517          	auipc	a0,0x2
ffffffffc0203fb8:	60450513          	addi	a0,a0,1540 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203fbc:	a0cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203fc0:	00003697          	auipc	a3,0x3
ffffffffc0203fc4:	ab068693          	addi	a3,a3,-1360 # ffffffffc0206a70 <default_pmm_manager+0x4f0>
ffffffffc0203fc8:	00002617          	auipc	a2,0x2
ffffffffc0203fcc:	86060613          	addi	a2,a2,-1952 # ffffffffc0205828 <commands+0x728>
ffffffffc0203fd0:	1ac00593          	li	a1,428
ffffffffc0203fd4:	00002517          	auipc	a0,0x2
ffffffffc0203fd8:	5e450513          	addi	a0,a0,1508 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203fdc:	9ecfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203fe0:	00003697          	auipc	a3,0x3
ffffffffc0203fe4:	a6068693          	addi	a3,a3,-1440 # ffffffffc0206a40 <default_pmm_manager+0x4c0>
ffffffffc0203fe8:	00002617          	auipc	a2,0x2
ffffffffc0203fec:	84060613          	addi	a2,a2,-1984 # ffffffffc0205828 <commands+0x728>
ffffffffc0203ff0:	1a800593          	li	a1,424
ffffffffc0203ff4:	00002517          	auipc	a0,0x2
ffffffffc0203ff8:	5c450513          	addi	a0,a0,1476 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0203ffc:	9ccfc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204000 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204000:	12058073          	sfence.vma	a1
}
ffffffffc0204004:	8082                	ret

ffffffffc0204006 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204006:	7179                	addi	sp,sp,-48
ffffffffc0204008:	e84a                	sd	s2,16(sp)
ffffffffc020400a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020400c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020400e:	f022                	sd	s0,32(sp)
ffffffffc0204010:	ec26                	sd	s1,24(sp)
ffffffffc0204012:	e44e                	sd	s3,8(sp)
ffffffffc0204014:	f406                	sd	ra,40(sp)
ffffffffc0204016:	84ae                	mv	s1,a1
ffffffffc0204018:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020401a:	f89fe0ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
ffffffffc020401e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204020:	cd09                	beqz	a0,ffffffffc020403a <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204022:	85aa                	mv	a1,a0
ffffffffc0204024:	86ce                	mv	a3,s3
ffffffffc0204026:	8626                	mv	a2,s1
ffffffffc0204028:	854a                	mv	a0,s2
ffffffffc020402a:	b46ff0ef          	jal	ra,ffffffffc0203370 <page_insert>
ffffffffc020402e:	ed21                	bnez	a0,ffffffffc0204086 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0204030:	00011797          	auipc	a5,0x11
ffffffffc0204034:	5487a783          	lw	a5,1352(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc0204038:	eb89                	bnez	a5,ffffffffc020404a <pgdir_alloc_page+0x44>
}
ffffffffc020403a:	70a2                	ld	ra,40(sp)
ffffffffc020403c:	8522                	mv	a0,s0
ffffffffc020403e:	7402                	ld	s0,32(sp)
ffffffffc0204040:	64e2                	ld	s1,24(sp)
ffffffffc0204042:	6942                	ld	s2,16(sp)
ffffffffc0204044:	69a2                	ld	s3,8(sp)
ffffffffc0204046:	6145                	addi	sp,sp,48
ffffffffc0204048:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020404a:	4681                	li	a3,0
ffffffffc020404c:	8622                	mv	a2,s0
ffffffffc020404e:	85a6                	mv	a1,s1
ffffffffc0204050:	00011517          	auipc	a0,0x11
ffffffffc0204054:	50053503          	ld	a0,1280(a0) # ffffffffc0215550 <check_mm_struct>
ffffffffc0204058:	acafe0ef          	jal	ra,ffffffffc0202322 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc020405c:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc020405e:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0204060:	4785                	li	a5,1
ffffffffc0204062:	fcf70ce3          	beq	a4,a5,ffffffffc020403a <pgdir_alloc_page+0x34>
ffffffffc0204066:	00003697          	auipc	a3,0x3
ffffffffc020406a:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0206af0 <default_pmm_manager+0x570>
ffffffffc020406e:	00001617          	auipc	a2,0x1
ffffffffc0204072:	7ba60613          	addi	a2,a2,1978 # ffffffffc0205828 <commands+0x728>
ffffffffc0204076:	14800593          	li	a1,328
ffffffffc020407a:	00002517          	auipc	a0,0x2
ffffffffc020407e:	53e50513          	addi	a0,a0,1342 # ffffffffc02065b8 <default_pmm_manager+0x38>
ffffffffc0204082:	946fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204086:	100027f3          	csrr	a5,sstatus
ffffffffc020408a:	8b89                	andi	a5,a5,2
ffffffffc020408c:	eb99                	bnez	a5,ffffffffc02040a2 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc020408e:	00011797          	auipc	a5,0x11
ffffffffc0204092:	5127b783          	ld	a5,1298(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0204096:	739c                	ld	a5,32(a5)
ffffffffc0204098:	8522                	mv	a0,s0
ffffffffc020409a:	4585                	li	a1,1
ffffffffc020409c:	9782                	jalr	a5
            return NULL;
ffffffffc020409e:	4401                	li	s0,0
ffffffffc02040a0:	bf69                	j	ffffffffc020403a <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc02040a2:	d22fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02040a6:	00011797          	auipc	a5,0x11
ffffffffc02040aa:	4fa7b783          	ld	a5,1274(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc02040ae:	739c                	ld	a5,32(a5)
ffffffffc02040b0:	8522                	mv	a0,s0
ffffffffc02040b2:	4585                	li	a1,1
ffffffffc02040b4:	9782                	jalr	a5
            return NULL;
ffffffffc02040b6:	4401                	li	s0,0
        intr_enable();
ffffffffc02040b8:	d06fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02040bc:	bfbd                	j	ffffffffc020403a <pgdir_alloc_page+0x34>

ffffffffc02040be <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02040be:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040c0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02040c2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040c4:	be0fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_valid>
ffffffffc02040c8:	cd01                	beqz	a0,ffffffffc02040e0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040ca:	4505                	li	a0,1
ffffffffc02040cc:	bdefc0ef          	jal	ra,ffffffffc02004aa <ide_device_size>
}
ffffffffc02040d0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040d2:	810d                	srli	a0,a0,0x3
ffffffffc02040d4:	00011797          	auipc	a5,0x11
ffffffffc02040d8:	48a7ba23          	sd	a0,1172(a5) # ffffffffc0215568 <max_swap_offset>
}
ffffffffc02040dc:	0141                	addi	sp,sp,16
ffffffffc02040de:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02040e0:	00003617          	auipc	a2,0x3
ffffffffc02040e4:	a2860613          	addi	a2,a2,-1496 # ffffffffc0206b08 <default_pmm_manager+0x588>
ffffffffc02040e8:	45b5                	li	a1,13
ffffffffc02040ea:	00003517          	auipc	a0,0x3
ffffffffc02040ee:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0206b28 <default_pmm_manager+0x5a8>
ffffffffc02040f2:	8d6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02040f6 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc02040f6:	1141                	addi	sp,sp,-16
ffffffffc02040f8:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040fa:	00855793          	srli	a5,a0,0x8
ffffffffc02040fe:	cbb1                	beqz	a5,ffffffffc0204152 <swapfs_read+0x5c>
ffffffffc0204100:	00011717          	auipc	a4,0x11
ffffffffc0204104:	46873703          	ld	a4,1128(a4) # ffffffffc0215568 <max_swap_offset>
ffffffffc0204108:	04e7f563          	bgeu	a5,a4,ffffffffc0204152 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc020410c:	00011617          	auipc	a2,0x11
ffffffffc0204110:	48c63603          	ld	a2,1164(a2) # ffffffffc0215598 <pages>
ffffffffc0204114:	8d91                	sub	a1,a1,a2
ffffffffc0204116:	4065d613          	srai	a2,a1,0x6
ffffffffc020411a:	00003717          	auipc	a4,0x3
ffffffffc020411e:	e3e73703          	ld	a4,-450(a4) # ffffffffc0206f58 <nbase>
ffffffffc0204122:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204124:	00c61713          	slli	a4,a2,0xc
ffffffffc0204128:	8331                	srli	a4,a4,0xc
ffffffffc020412a:	00011697          	auipc	a3,0x11
ffffffffc020412e:	4666b683          	ld	a3,1126(a3) # ffffffffc0215590 <npage>
ffffffffc0204132:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204136:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204138:	02d77963          	bgeu	a4,a3,ffffffffc020416a <swapfs_read+0x74>
}
ffffffffc020413c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020413e:	00011797          	auipc	a5,0x11
ffffffffc0204142:	46a7b783          	ld	a5,1130(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0204146:	46a1                	li	a3,8
ffffffffc0204148:	963e                	add	a2,a2,a5
ffffffffc020414a:	4505                	li	a0,1
}
ffffffffc020414c:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020414e:	b62fc06f          	j	ffffffffc02004b0 <ide_read_secs>
ffffffffc0204152:	86aa                	mv	a3,a0
ffffffffc0204154:	00003617          	auipc	a2,0x3
ffffffffc0204158:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0206b40 <default_pmm_manager+0x5c0>
ffffffffc020415c:	45d1                	li	a1,20
ffffffffc020415e:	00003517          	auipc	a0,0x3
ffffffffc0204162:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0206b28 <default_pmm_manager+0x5a8>
ffffffffc0204166:	862fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020416a:	86b2                	mv	a3,a2
ffffffffc020416c:	06900593          	li	a1,105
ffffffffc0204170:	00002617          	auipc	a2,0x2
ffffffffc0204174:	91060613          	addi	a2,a2,-1776 # ffffffffc0205a80 <commands+0x980>
ffffffffc0204178:	00002517          	auipc	a0,0x2
ffffffffc020417c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205a70 <commands+0x970>
ffffffffc0204180:	848fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204184 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204184:	1141                	addi	sp,sp,-16
ffffffffc0204186:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204188:	00855793          	srli	a5,a0,0x8
ffffffffc020418c:	cbb1                	beqz	a5,ffffffffc02041e0 <swapfs_write+0x5c>
ffffffffc020418e:	00011717          	auipc	a4,0x11
ffffffffc0204192:	3da73703          	ld	a4,986(a4) # ffffffffc0215568 <max_swap_offset>
ffffffffc0204196:	04e7f563          	bgeu	a5,a4,ffffffffc02041e0 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc020419a:	00011617          	auipc	a2,0x11
ffffffffc020419e:	3fe63603          	ld	a2,1022(a2) # ffffffffc0215598 <pages>
ffffffffc02041a2:	8d91                	sub	a1,a1,a2
ffffffffc02041a4:	4065d613          	srai	a2,a1,0x6
ffffffffc02041a8:	00003717          	auipc	a4,0x3
ffffffffc02041ac:	db073703          	ld	a4,-592(a4) # ffffffffc0206f58 <nbase>
ffffffffc02041b0:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc02041b2:	00c61713          	slli	a4,a2,0xc
ffffffffc02041b6:	8331                	srli	a4,a4,0xc
ffffffffc02041b8:	00011697          	auipc	a3,0x11
ffffffffc02041bc:	3d86b683          	ld	a3,984(a3) # ffffffffc0215590 <npage>
ffffffffc02041c0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041c4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02041c6:	02d77963          	bgeu	a4,a3,ffffffffc02041f8 <swapfs_write+0x74>
}
ffffffffc02041ca:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041cc:	00011797          	auipc	a5,0x11
ffffffffc02041d0:	3dc7b783          	ld	a5,988(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc02041d4:	46a1                	li	a3,8
ffffffffc02041d6:	963e                	add	a2,a2,a5
ffffffffc02041d8:	4505                	li	a0,1
}
ffffffffc02041da:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041dc:	af8fc06f          	j	ffffffffc02004d4 <ide_write_secs>
ffffffffc02041e0:	86aa                	mv	a3,a0
ffffffffc02041e2:	00003617          	auipc	a2,0x3
ffffffffc02041e6:	95e60613          	addi	a2,a2,-1698 # ffffffffc0206b40 <default_pmm_manager+0x5c0>
ffffffffc02041ea:	45e5                	li	a1,25
ffffffffc02041ec:	00003517          	auipc	a0,0x3
ffffffffc02041f0:	93c50513          	addi	a0,a0,-1732 # ffffffffc0206b28 <default_pmm_manager+0x5a8>
ffffffffc02041f4:	fd5fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02041f8:	86b2                	mv	a3,a2
ffffffffc02041fa:	06900593          	li	a1,105
ffffffffc02041fe:	00002617          	auipc	a2,0x2
ffffffffc0204202:	88260613          	addi	a2,a2,-1918 # ffffffffc0205a80 <commands+0x980>
ffffffffc0204206:	00002517          	auipc	a0,0x2
ffffffffc020420a:	86a50513          	addi	a0,a0,-1942 # ffffffffc0205a70 <commands+0x970>
ffffffffc020420e:	fbbfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204212 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204212:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204214:	9402                	jalr	s0

	jal do_exit
ffffffffc0204216:	442000ef          	jal	ra,ffffffffc0204658 <do_exit>

ffffffffc020421a <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020421a:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020421e:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204222:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204224:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204226:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020422a:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020422e:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204232:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204236:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020423a:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020423e:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204242:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204246:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020424a:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020424e:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204252:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204256:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204258:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020425a:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc020425e:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204262:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204266:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020426a:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc020426e:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204272:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204276:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020427a:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc020427e:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204282:	8082                	ret

ffffffffc0204284 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204284:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204286:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc020428a:	e022                	sd	s0,0(sp)
ffffffffc020428c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020428e:	f8cfd0ef          	jal	ra,ffffffffc0201a1a <kmalloc>
ffffffffc0204292:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204294:	c521                	beqz	a0,ffffffffc02042dc <alloc_proc+0x58>
        *       struct trapframe *tf;                       // Trap frame for current interrupt
        *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
        *       uint32_t flags;                             // Process flag
        *       char name[PROC_NAME_LEN + 1];               // Process name
        */
        proc->state  = PROC_UNINIT;
ffffffffc0204296:	57fd                	li	a5,-1
ffffffffc0204298:	1782                	slli	a5,a5,0x20
ffffffffc020429a:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc020429c:	07000613          	li	a2,112
ffffffffc02042a0:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc02042a2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc02042a6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc02042aa:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc02042ae:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc02042b2:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02042b6:	03050513          	addi	a0,a0,48
ffffffffc02042ba:	766000ef          	jal	ra,ffffffffc0204a20 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc02042be:	00011797          	auipc	a5,0x11
ffffffffc02042c2:	2c27b783          	ld	a5,706(a5) # ffffffffc0215580 <boot_cr3>
        proc->tf = NULL;
ffffffffc02042c6:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc02042ca:	f45c                	sd	a5,168(s0)
        proc->flags = 0;
ffffffffc02042cc:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc02042d0:	463d                	li	a2,15
ffffffffc02042d2:	4581                	li	a1,0
ffffffffc02042d4:	0b440513          	addi	a0,s0,180
ffffffffc02042d8:	748000ef          	jal	ra,ffffffffc0204a20 <memset>
    }
    return proc;
}
ffffffffc02042dc:	60a2                	ld	ra,8(sp)
ffffffffc02042de:	8522                	mv	a0,s0
ffffffffc02042e0:	6402                	ld	s0,0(sp)
ffffffffc02042e2:	0141                	addi	sp,sp,16
ffffffffc02042e4:	8082                	ret

ffffffffc02042e6 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc02042e6:	00011797          	auipc	a5,0x11
ffffffffc02042ea:	2ca7b783          	ld	a5,714(a5) # ffffffffc02155b0 <current>
ffffffffc02042ee:	73c8                	ld	a0,160(a5)
ffffffffc02042f0:	87dfc06f          	j	ffffffffc0200b6c <forkrets>

ffffffffc02042f4 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02042f4:	7179                	addi	sp,sp,-48
ffffffffc02042f6:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042f8:	00011497          	auipc	s1,0x11
ffffffffc02042fc:	22048493          	addi	s1,s1,544 # ffffffffc0215518 <name.2>
init_main(void *arg) {
ffffffffc0204300:	f022                	sd	s0,32(sp)
ffffffffc0204302:	e84a                	sd	s2,16(sp)
ffffffffc0204304:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204306:	00011917          	auipc	s2,0x11
ffffffffc020430a:	2aa93903          	ld	s2,682(s2) # ffffffffc02155b0 <current>
    memset(name, 0, sizeof(name));
ffffffffc020430e:	4641                	li	a2,16
ffffffffc0204310:	4581                	li	a1,0
ffffffffc0204312:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc0204314:	f406                	sd	ra,40(sp)
ffffffffc0204316:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204318:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc020431c:	704000ef          	jal	ra,ffffffffc0204a20 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204320:	0b490593          	addi	a1,s2,180
ffffffffc0204324:	463d                	li	a2,15
ffffffffc0204326:	8526                	mv	a0,s1
ffffffffc0204328:	70a000ef          	jal	ra,ffffffffc0204a32 <memcpy>
ffffffffc020432c:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020432e:	85ce                	mv	a1,s3
ffffffffc0204330:	00003517          	auipc	a0,0x3
ffffffffc0204334:	83050513          	addi	a0,a0,-2000 # ffffffffc0206b60 <default_pmm_manager+0x5e0>
ffffffffc0204338:	d95fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020433c:	85a2                	mv	a1,s0
ffffffffc020433e:	00003517          	auipc	a0,0x3
ffffffffc0204342:	84a50513          	addi	a0,a0,-1974 # ffffffffc0206b88 <default_pmm_manager+0x608>
ffffffffc0204346:	d87fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc020434a:	00003517          	auipc	a0,0x3
ffffffffc020434e:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206b98 <default_pmm_manager+0x618>
ffffffffc0204352:	d7bfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc0204356:	70a2                	ld	ra,40(sp)
ffffffffc0204358:	7402                	ld	s0,32(sp)
ffffffffc020435a:	64e2                	ld	s1,24(sp)
ffffffffc020435c:	6942                	ld	s2,16(sp)
ffffffffc020435e:	69a2                	ld	s3,8(sp)
ffffffffc0204360:	4501                	li	a0,0
ffffffffc0204362:	6145                	addi	sp,sp,48
ffffffffc0204364:	8082                	ret

ffffffffc0204366 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204366:	7179                	addi	sp,sp,-48
ffffffffc0204368:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc020436a:	00011917          	auipc	s2,0x11
ffffffffc020436e:	24690913          	addi	s2,s2,582 # ffffffffc02155b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204372:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204374:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204378:	f406                	sd	ra,40(sp)
ffffffffc020437a:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc020437c:	02a48963          	beq	s1,a0,ffffffffc02043ae <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204380:	100027f3          	csrr	a5,sstatus
ffffffffc0204384:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204386:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204388:	e3a1                	bnez	a5,ffffffffc02043c8 <proc_run+0x62>
        lcr3(proc->cr3);
ffffffffc020438a:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020438c:	80000737          	lui	a4,0x80000
        current = proc;
ffffffffc0204390:	00a93023          	sd	a0,0(s2)
ffffffffc0204394:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204398:	8fd9                	or	a5,a5,a4
ffffffffc020439a:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(proc->context));
ffffffffc020439e:	03050593          	addi	a1,a0,48
ffffffffc02043a2:	03048513          	addi	a0,s1,48
ffffffffc02043a6:	e75ff0ef          	jal	ra,ffffffffc020421a <switch_to>
    if (flag) {
ffffffffc02043aa:	00099863          	bnez	s3,ffffffffc02043ba <proc_run+0x54>
}
ffffffffc02043ae:	70a2                	ld	ra,40(sp)
ffffffffc02043b0:	7482                	ld	s1,32(sp)
ffffffffc02043b2:	6962                	ld	s2,24(sp)
ffffffffc02043b4:	69c2                	ld	s3,16(sp)
ffffffffc02043b6:	6145                	addi	sp,sp,48
ffffffffc02043b8:	8082                	ret
ffffffffc02043ba:	70a2                	ld	ra,40(sp)
ffffffffc02043bc:	7482                	ld	s1,32(sp)
ffffffffc02043be:	6962                	ld	s2,24(sp)
ffffffffc02043c0:	69c2                	ld	s3,16(sp)
ffffffffc02043c2:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02043c4:	9fafc06f          	j	ffffffffc02005be <intr_enable>
ffffffffc02043c8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02043ca:	9fafc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02043ce:	6522                	ld	a0,8(sp)
ffffffffc02043d0:	4985                	li	s3,1
ffffffffc02043d2:	bf65                	j	ffffffffc020438a <proc_run+0x24>

ffffffffc02043d4 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043d4:	7179                	addi	sp,sp,-48
ffffffffc02043d6:	ec26                	sd	s1,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043d8:	00011497          	auipc	s1,0x11
ffffffffc02043dc:	1f048493          	addi	s1,s1,496 # ffffffffc02155c8 <nr_process>
ffffffffc02043e0:	4098                	lw	a4,0(s1)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043e2:	f406                	sd	ra,40(sp)
ffffffffc02043e4:	f022                	sd	s0,32(sp)
ffffffffc02043e6:	e84a                	sd	s2,16(sp)
ffffffffc02043e8:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043ea:	6785                	lui	a5,0x1
ffffffffc02043ec:	1cf75b63          	bge	a4,a5,ffffffffc02045c2 <do_fork+0x1ee>
ffffffffc02043f0:	892e                	mv	s2,a1
ffffffffc02043f2:	8432                	mv	s0,a2
    if((proc = alloc_proc())== NULL){
ffffffffc02043f4:	e91ff0ef          	jal	ra,ffffffffc0204284 <alloc_proc>
ffffffffc02043f8:	89aa                	mv	s3,a0
ffffffffc02043fa:	1c050963          	beqz	a0,ffffffffc02045cc <do_fork+0x1f8>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043fe:	4509                	li	a0,2
ffffffffc0204400:	ba3fe0ef          	jal	ra,ffffffffc0202fa2 <alloc_pages>
    if (page != NULL) {
ffffffffc0204404:	1a050a63          	beqz	a0,ffffffffc02045b8 <do_fork+0x1e4>
    return page - pages + nbase;
ffffffffc0204408:	00011697          	auipc	a3,0x11
ffffffffc020440c:	1906b683          	ld	a3,400(a3) # ffffffffc0215598 <pages>
ffffffffc0204410:	40d506b3          	sub	a3,a0,a3
ffffffffc0204414:	8699                	srai	a3,a3,0x6
ffffffffc0204416:	00003517          	auipc	a0,0x3
ffffffffc020441a:	b4253503          	ld	a0,-1214(a0) # ffffffffc0206f58 <nbase>
ffffffffc020441e:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204420:	00c69793          	slli	a5,a3,0xc
ffffffffc0204424:	83b1                	srli	a5,a5,0xc
ffffffffc0204426:	00011717          	auipc	a4,0x11
ffffffffc020442a:	16a73703          	ld	a4,362(a4) # ffffffffc0215590 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020442e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204430:	1ce7f063          	bgeu	a5,a4,ffffffffc02045f0 <do_fork+0x21c>
    assert(current->mm == NULL);
ffffffffc0204434:	00011797          	auipc	a5,0x11
ffffffffc0204438:	17c7b783          	ld	a5,380(a5) # ffffffffc02155b0 <current>
ffffffffc020443c:	779c                	ld	a5,40(a5)
ffffffffc020443e:	00011717          	auipc	a4,0x11
ffffffffc0204442:	16a73703          	ld	a4,362(a4) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0204446:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204448:	00d9b823          	sd	a3,16(s3)
    assert(current->mm == NULL);
ffffffffc020444c:	18079263          	bnez	a5,ffffffffc02045d0 <do_fork+0x1fc>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204450:	6789                	lui	a5,0x2
ffffffffc0204452:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0204456:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204458:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020445a:	0ad9b023          	sd	a3,160(s3)
    *(proc->tf) = *tf;
ffffffffc020445e:	87b6                	mv	a5,a3
ffffffffc0204460:	12040893          	addi	a7,s0,288
ffffffffc0204464:	00063803          	ld	a6,0(a2)
ffffffffc0204468:	6608                	ld	a0,8(a2)
ffffffffc020446a:	6a0c                	ld	a1,16(a2)
ffffffffc020446c:	6e18                	ld	a4,24(a2)
ffffffffc020446e:	0107b023          	sd	a6,0(a5)
ffffffffc0204472:	e788                	sd	a0,8(a5)
ffffffffc0204474:	eb8c                	sd	a1,16(a5)
ffffffffc0204476:	ef98                	sd	a4,24(a5)
ffffffffc0204478:	02060613          	addi	a2,a2,32
ffffffffc020447c:	02078793          	addi	a5,a5,32
ffffffffc0204480:	ff1612e3          	bne	a2,a7,ffffffffc0204464 <do_fork+0x90>
    proc->tf->gpr.a0 = 0;
ffffffffc0204484:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204488:	10090c63          	beqz	s2,ffffffffc02045a0 <do_fork+0x1cc>
    if (++ last_pid >= MAX_PID) {
ffffffffc020448c:	00006817          	auipc	a6,0x6
ffffffffc0204490:	bcc80813          	addi	a6,a6,-1076 # ffffffffc020a058 <last_pid.1>
ffffffffc0204494:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204498:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020449c:	00000717          	auipc	a4,0x0
ffffffffc02044a0:	e4a70713          	addi	a4,a4,-438 # ffffffffc02042e6 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc02044a4:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044a8:	02e9b823          	sd	a4,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044ac:	02d9bc23          	sd	a3,56(s3)
    if (++ last_pid >= MAX_PID) {
ffffffffc02044b0:	00a82023          	sw	a0,0(a6)
ffffffffc02044b4:	6789                	lui	a5,0x2
ffffffffc02044b6:	06f55e63          	bge	a0,a5,ffffffffc0204532 <do_fork+0x15e>
    if (last_pid >= next_safe) {
ffffffffc02044ba:	00006317          	auipc	t1,0x6
ffffffffc02044be:	ba230313          	addi	t1,t1,-1118 # ffffffffc020a05c <next_safe.0>
ffffffffc02044c2:	00032783          	lw	a5,0(t1)
ffffffffc02044c6:	00011417          	auipc	s0,0x11
ffffffffc02044ca:	06240413          	addi	s0,s0,98 # ffffffffc0215528 <proc_list>
ffffffffc02044ce:	06f55a63          	bge	a0,a5,ffffffffc0204542 <do_fork+0x16e>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044d2:	45a9                	li	a1,10
    proc->pid = get_pid();
ffffffffc02044d4:	00a9a223          	sw	a0,4(s3)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044d8:	2501                	sext.w	a0,a0
ffffffffc02044da:	183000ef          	jal	ra,ffffffffc0204e5c <hash32>
ffffffffc02044de:	02051793          	slli	a5,a0,0x20
ffffffffc02044e2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044e6:	0000d797          	auipc	a5,0xd
ffffffffc02044ea:	03278793          	addi	a5,a5,50 # ffffffffc0211518 <hash_list>
ffffffffc02044ee:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044f0:	6518                	ld	a4,8(a0)
ffffffffc02044f2:	0d898793          	addi	a5,s3,216
ffffffffc02044f6:	6414                	ld	a3,8(s0)
    prev->next = next->prev = elm;
ffffffffc02044f8:	e31c                	sd	a5,0(a4)
ffffffffc02044fa:	e51c                	sd	a5,8(a0)
    nr_process++;
ffffffffc02044fc:	409c                	lw	a5,0(s1)
    elm->next = next;
ffffffffc02044fe:	0ee9b023          	sd	a4,224(s3)
    elm->prev = prev;
ffffffffc0204502:	0ca9bc23          	sd	a0,216(s3)
    list_add(&proc_list,&(proc->list_link));
ffffffffc0204506:	0c898713          	addi	a4,s3,200
    prev->next = next->prev = elm;
ffffffffc020450a:	e298                	sd	a4,0(a3)
    nr_process++;
ffffffffc020450c:	2785                	addiw	a5,a5,1
    wakeup_proc(proc);
ffffffffc020450e:	854e                	mv	a0,s3
    elm->next = next;
ffffffffc0204510:	0cd9b823          	sd	a3,208(s3)
    elm->prev = prev;
ffffffffc0204514:	0c89b423          	sd	s0,200(s3)
    prev->next = next->prev = elm;
ffffffffc0204518:	e418                	sd	a4,8(s0)
    nr_process++;
ffffffffc020451a:	c09c                	sw	a5,0(s1)
    wakeup_proc(proc);
ffffffffc020451c:	3c2000ef          	jal	ra,ffffffffc02048de <wakeup_proc>
    ret = proc->pid;
ffffffffc0204520:	0049a503          	lw	a0,4(s3)
}
ffffffffc0204524:	70a2                	ld	ra,40(sp)
ffffffffc0204526:	7402                	ld	s0,32(sp)
ffffffffc0204528:	64e2                	ld	s1,24(sp)
ffffffffc020452a:	6942                	ld	s2,16(sp)
ffffffffc020452c:	69a2                	ld	s3,8(sp)
ffffffffc020452e:	6145                	addi	sp,sp,48
ffffffffc0204530:	8082                	ret
        last_pid = 1;
ffffffffc0204532:	4785                	li	a5,1
ffffffffc0204534:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204538:	4505                	li	a0,1
ffffffffc020453a:	00006317          	auipc	t1,0x6
ffffffffc020453e:	b2230313          	addi	t1,t1,-1246 # ffffffffc020a05c <next_safe.0>
    return listelm->next;
ffffffffc0204542:	00011417          	auipc	s0,0x11
ffffffffc0204546:	fe640413          	addi	s0,s0,-26 # ffffffffc0215528 <proc_list>
ffffffffc020454a:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;// 设置右边界为最大值，后面再缩小这个范围到冲突的pid的位置
ffffffffc020454e:	6789                	lui	a5,0x2
ffffffffc0204550:	00f32023          	sw	a5,0(t1)
ffffffffc0204554:	86aa                	mv	a3,a0
ffffffffc0204556:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0204558:	6e89                	lui	t4,0x2
ffffffffc020455a:	048e0a63          	beq	t3,s0,ffffffffc02045ae <do_fork+0x1da>
ffffffffc020455e:	88ae                	mv	a7,a1
ffffffffc0204560:	87f2                	mv	a5,t3
ffffffffc0204562:	6609                	lui	a2,0x2
ffffffffc0204564:	a811                	j	ffffffffc0204578 <do_fork+0x1a4>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204566:	00e6d663          	bge	a3,a4,ffffffffc0204572 <do_fork+0x19e>
ffffffffc020456a:	00c75463          	bge	a4,a2,ffffffffc0204572 <do_fork+0x19e>
ffffffffc020456e:	863a                	mv	a2,a4
ffffffffc0204570:	4885                	li	a7,1
ffffffffc0204572:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204574:	00878d63          	beq	a5,s0,ffffffffc020458e <do_fork+0x1ba>
            if (proc->pid == last_pid) {
ffffffffc0204578:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc020457c:	fed715e3          	bne	a4,a3,ffffffffc0204566 <do_fork+0x192>
                if (++ last_pid >= next_safe) {
ffffffffc0204580:	2685                	addiw	a3,a3,1
ffffffffc0204582:	02c6d163          	bge	a3,a2,ffffffffc02045a4 <do_fork+0x1d0>
ffffffffc0204586:	679c                	ld	a5,8(a5)
ffffffffc0204588:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020458a:	fe8797e3          	bne	a5,s0,ffffffffc0204578 <do_fork+0x1a4>
ffffffffc020458e:	c581                	beqz	a1,ffffffffc0204596 <do_fork+0x1c2>
ffffffffc0204590:	00d82023          	sw	a3,0(a6)
ffffffffc0204594:	8536                	mv	a0,a3
ffffffffc0204596:	f2088ee3          	beqz	a7,ffffffffc02044d2 <do_fork+0xfe>
ffffffffc020459a:	00c32023          	sw	a2,0(t1)
ffffffffc020459e:	bf15                	j	ffffffffc02044d2 <do_fork+0xfe>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045a0:	8936                	mv	s2,a3
ffffffffc02045a2:	b5ed                	j	ffffffffc020448c <do_fork+0xb8>
                    if (last_pid >= MAX_PID) {
ffffffffc02045a4:	01d6c363          	blt	a3,t4,ffffffffc02045aa <do_fork+0x1d6>
                        last_pid = 1;
ffffffffc02045a8:	4685                	li	a3,1
                    goto repeat;
ffffffffc02045aa:	4585                	li	a1,1
ffffffffc02045ac:	b77d                	j	ffffffffc020455a <do_fork+0x186>
ffffffffc02045ae:	cd81                	beqz	a1,ffffffffc02045c6 <do_fork+0x1f2>
ffffffffc02045b0:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02045b4:	8536                	mv	a0,a3
ffffffffc02045b6:	bf31                	j	ffffffffc02044d2 <do_fork+0xfe>
    kfree(proc);
ffffffffc02045b8:	854e                	mv	a0,s3
ffffffffc02045ba:	d10fd0ef          	jal	ra,ffffffffc0201aca <kfree>
    ret = -E_NO_MEM;
ffffffffc02045be:	5571                	li	a0,-4
    goto fork_out;
ffffffffc02045c0:	b795                	j	ffffffffc0204524 <do_fork+0x150>
    int ret = -E_NO_FREE_PROC;
ffffffffc02045c2:	556d                	li	a0,-5
ffffffffc02045c4:	b785                	j	ffffffffc0204524 <do_fork+0x150>
    return last_pid;
ffffffffc02045c6:	00082503          	lw	a0,0(a6)
ffffffffc02045ca:	b721                	j	ffffffffc02044d2 <do_fork+0xfe>
    ret = -E_NO_MEM;
ffffffffc02045cc:	5571                	li	a0,-4
    return ret;
ffffffffc02045ce:	bf99                	j	ffffffffc0204524 <do_fork+0x150>
    assert(current->mm == NULL);
ffffffffc02045d0:	00002697          	auipc	a3,0x2
ffffffffc02045d4:	5e868693          	addi	a3,a3,1512 # ffffffffc0206bb8 <default_pmm_manager+0x638>
ffffffffc02045d8:	00001617          	auipc	a2,0x1
ffffffffc02045dc:	25060613          	addi	a2,a2,592 # ffffffffc0205828 <commands+0x728>
ffffffffc02045e0:	10a00593          	li	a1,266
ffffffffc02045e4:	00002517          	auipc	a0,0x2
ffffffffc02045e8:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206bd0 <default_pmm_manager+0x650>
ffffffffc02045ec:	bddfb0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02045f0:	00001617          	auipc	a2,0x1
ffffffffc02045f4:	49060613          	addi	a2,a2,1168 # ffffffffc0205a80 <commands+0x980>
ffffffffc02045f8:	06900593          	li	a1,105
ffffffffc02045fc:	00001517          	auipc	a0,0x1
ffffffffc0204600:	47450513          	addi	a0,a0,1140 # ffffffffc0205a70 <commands+0x970>
ffffffffc0204604:	bc5fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204608 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204608:	7129                	addi	sp,sp,-320
ffffffffc020460a:	fa22                	sd	s0,304(sp)
ffffffffc020460c:	f626                	sd	s1,296(sp)
ffffffffc020460e:	f24a                	sd	s2,288(sp)
ffffffffc0204610:	84ae                	mv	s1,a1
ffffffffc0204612:	892a                	mv	s2,a0
ffffffffc0204614:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204616:	4581                	li	a1,0
ffffffffc0204618:	12000613          	li	a2,288
ffffffffc020461c:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020461e:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204620:	400000ef          	jal	ra,ffffffffc0204a20 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204624:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204626:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204628:	100027f3          	csrr	a5,sstatus
ffffffffc020462c:	edd7f793          	andi	a5,a5,-291
ffffffffc0204630:	1207e793          	ori	a5,a5,288
ffffffffc0204634:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204636:	860a                	mv	a2,sp
ffffffffc0204638:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020463c:	00000797          	auipc	a5,0x0
ffffffffc0204640:	bd678793          	addi	a5,a5,-1066 # ffffffffc0204212 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204644:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204646:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204648:	d8dff0ef          	jal	ra,ffffffffc02043d4 <do_fork>
}
ffffffffc020464c:	70f2                	ld	ra,312(sp)
ffffffffc020464e:	7452                	ld	s0,304(sp)
ffffffffc0204650:	74b2                	ld	s1,296(sp)
ffffffffc0204652:	7912                	ld	s2,288(sp)
ffffffffc0204654:	6131                	addi	sp,sp,320
ffffffffc0204656:	8082                	ret

ffffffffc0204658 <do_exit>:
do_exit(int error_code) {
ffffffffc0204658:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc020465a:	00002617          	auipc	a2,0x2
ffffffffc020465e:	58e60613          	addi	a2,a2,1422 # ffffffffc0206be8 <default_pmm_manager+0x668>
ffffffffc0204662:	16a00593          	li	a1,362
ffffffffc0204666:	00002517          	auipc	a0,0x2
ffffffffc020466a:	56a50513          	addi	a0,a0,1386 # ffffffffc0206bd0 <default_pmm_manager+0x650>
do_exit(int error_code) {
ffffffffc020466e:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204670:	b59fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204674 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204674:	7179                	addi	sp,sp,-48
ffffffffc0204676:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc0204678:	00011797          	auipc	a5,0x11
ffffffffc020467c:	eb078793          	addi	a5,a5,-336 # ffffffffc0215528 <proc_list>
ffffffffc0204680:	f406                	sd	ra,40(sp)
ffffffffc0204682:	f022                	sd	s0,32(sp)
ffffffffc0204684:	e84a                	sd	s2,16(sp)
ffffffffc0204686:	e44e                	sd	s3,8(sp)
ffffffffc0204688:	0000d497          	auipc	s1,0xd
ffffffffc020468c:	e9048493          	addi	s1,s1,-368 # ffffffffc0211518 <hash_list>
ffffffffc0204690:	e79c                	sd	a5,8(a5)
ffffffffc0204692:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204694:	00011717          	auipc	a4,0x11
ffffffffc0204698:	e8470713          	addi	a4,a4,-380 # ffffffffc0215518 <name.2>
ffffffffc020469c:	87a6                	mv	a5,s1
ffffffffc020469e:	e79c                	sd	a5,8(a5)
ffffffffc02046a0:	e39c                	sd	a5,0(a5)
ffffffffc02046a2:	07c1                	addi	a5,a5,16
ffffffffc02046a4:	fef71de3          	bne	a4,a5,ffffffffc020469e <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02046a8:	bddff0ef          	jal	ra,ffffffffc0204284 <alloc_proc>
ffffffffc02046ac:	00011917          	auipc	s2,0x11
ffffffffc02046b0:	f0c90913          	addi	s2,s2,-244 # ffffffffc02155b8 <idleproc>
ffffffffc02046b4:	00a93023          	sd	a0,0(s2)
ffffffffc02046b8:	18050d63          	beqz	a0,ffffffffc0204852 <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046bc:	07000513          	li	a0,112
ffffffffc02046c0:	b5afd0ef          	jal	ra,ffffffffc0201a1a <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046c4:	07000613          	li	a2,112
ffffffffc02046c8:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046ca:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046cc:	354000ef          	jal	ra,ffffffffc0204a20 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02046d0:	00093503          	ld	a0,0(s2)
ffffffffc02046d4:	85a2                	mv	a1,s0
ffffffffc02046d6:	07000613          	li	a2,112
ffffffffc02046da:	03050513          	addi	a0,a0,48
ffffffffc02046de:	36c000ef          	jal	ra,ffffffffc0204a4a <memcmp>
ffffffffc02046e2:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046e4:	453d                	li	a0,15
ffffffffc02046e6:	b34fd0ef          	jal	ra,ffffffffc0201a1a <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02046ea:	463d                	li	a2,15
ffffffffc02046ec:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046ee:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02046f0:	330000ef          	jal	ra,ffffffffc0204a20 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02046f4:	00093503          	ld	a0,0(s2)
ffffffffc02046f8:	463d                	li	a2,15
ffffffffc02046fa:	85a2                	mv	a1,s0
ffffffffc02046fc:	0b450513          	addi	a0,a0,180
ffffffffc0204700:	34a000ef          	jal	ra,ffffffffc0204a4a <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204704:	00093783          	ld	a5,0(s2)
ffffffffc0204708:	00011717          	auipc	a4,0x11
ffffffffc020470c:	e7873703          	ld	a4,-392(a4) # ffffffffc0215580 <boot_cr3>
ffffffffc0204710:	77d4                	ld	a3,168(a5)
ffffffffc0204712:	0ee68463          	beq	a3,a4,ffffffffc02047fa <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;//idleproc是第0个内核线程
    idleproc->state = PROC_RUNNABLE;//使得它从“出生”转到了“准备工作”，就差uCore调度它执行了
ffffffffc0204716:	4709                	li	a4,2
ffffffffc0204718:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;//uCore启动时设置的内核栈直接分配给idleproc使用
ffffffffc020471a:	00003717          	auipc	a4,0x3
ffffffffc020471e:	8e670713          	addi	a4,a4,-1818 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204722:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;//uCore启动时设置的内核栈直接分配给idleproc使用
ffffffffc0204726:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;//如果当前idleproc在执行，则只要此标志为1，马上就调用schedule函数要求调度器切换其他进程执行。
ffffffffc0204728:	4705                	li	a4,1
ffffffffc020472a:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020472c:	4641                	li	a2,16
ffffffffc020472e:	4581                	li	a1,0
ffffffffc0204730:	8522                	mv	a0,s0
ffffffffc0204732:	2ee000ef          	jal	ra,ffffffffc0204a20 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204736:	463d                	li	a2,15
ffffffffc0204738:	00002597          	auipc	a1,0x2
ffffffffc020473c:	4f858593          	addi	a1,a1,1272 # ffffffffc0206c30 <default_pmm_manager+0x6b0>
ffffffffc0204740:	8522                	mv	a0,s0
ffffffffc0204742:	2f0000ef          	jal	ra,ffffffffc0204a32 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204746:	00011717          	auipc	a4,0x11
ffffffffc020474a:	e8270713          	addi	a4,a4,-382 # ffffffffc02155c8 <nr_process>
ffffffffc020474e:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204750:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204754:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204756:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204758:	00002597          	auipc	a1,0x2
ffffffffc020475c:	4e058593          	addi	a1,a1,1248 # ffffffffc0206c38 <default_pmm_manager+0x6b8>
ffffffffc0204760:	00000517          	auipc	a0,0x0
ffffffffc0204764:	b9450513          	addi	a0,a0,-1132 # ffffffffc02042f4 <init_main>
    nr_process ++;
ffffffffc0204768:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020476a:	00011797          	auipc	a5,0x11
ffffffffc020476e:	e4d7b323          	sd	a3,-442(a5) # ffffffffc02155b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204772:	e97ff0ef          	jal	ra,ffffffffc0204608 <kernel_thread>
ffffffffc0204776:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0204778:	0ea05963          	blez	a0,ffffffffc020486a <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020477c:	6789                	lui	a5,0x2
ffffffffc020477e:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204782:	17f9                	addi	a5,a5,-2
ffffffffc0204784:	2501                	sext.w	a0,a0
ffffffffc0204786:	02e7e363          	bltu	a5,a4,ffffffffc02047ac <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020478a:	45a9                	li	a1,10
ffffffffc020478c:	6d0000ef          	jal	ra,ffffffffc0204e5c <hash32>
ffffffffc0204790:	02051793          	slli	a5,a0,0x20
ffffffffc0204794:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204798:	96a6                	add	a3,a3,s1
ffffffffc020479a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020479c:	a029                	j	ffffffffc02047a6 <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc020479e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc02047a2:	0a870563          	beq	a4,s0,ffffffffc020484c <proc_init+0x1d8>
    return listelm->next;
ffffffffc02047a6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02047a8:	fef69be3          	bne	a3,a5,ffffffffc020479e <proc_init+0x12a>
    return NULL;
ffffffffc02047ac:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047ae:	0b478493          	addi	s1,a5,180
ffffffffc02047b2:	4641                	li	a2,16
ffffffffc02047b4:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02047b6:	00011417          	auipc	s0,0x11
ffffffffc02047ba:	e0a40413          	addi	s0,s0,-502 # ffffffffc02155c0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047be:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02047c0:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047c2:	25e000ef          	jal	ra,ffffffffc0204a20 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02047c6:	463d                	li	a2,15
ffffffffc02047c8:	00002597          	auipc	a1,0x2
ffffffffc02047cc:	4a058593          	addi	a1,a1,1184 # ffffffffc0206c68 <default_pmm_manager+0x6e8>
ffffffffc02047d0:	8526                	mv	a0,s1
ffffffffc02047d2:	260000ef          	jal	ra,ffffffffc0204a32 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02047d6:	00093783          	ld	a5,0(s2)
ffffffffc02047da:	c7e1                	beqz	a5,ffffffffc02048a2 <proc_init+0x22e>
ffffffffc02047dc:	43dc                	lw	a5,4(a5)
ffffffffc02047de:	e3f1                	bnez	a5,ffffffffc02048a2 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02047e0:	601c                	ld	a5,0(s0)
ffffffffc02047e2:	c3c5                	beqz	a5,ffffffffc0204882 <proc_init+0x20e>
ffffffffc02047e4:	43d8                	lw	a4,4(a5)
ffffffffc02047e6:	4785                	li	a5,1
ffffffffc02047e8:	08f71d63          	bne	a4,a5,ffffffffc0204882 <proc_init+0x20e>
}
ffffffffc02047ec:	70a2                	ld	ra,40(sp)
ffffffffc02047ee:	7402                	ld	s0,32(sp)
ffffffffc02047f0:	64e2                	ld	s1,24(sp)
ffffffffc02047f2:	6942                	ld	s2,16(sp)
ffffffffc02047f4:	69a2                	ld	s3,8(sp)
ffffffffc02047f6:	6145                	addi	sp,sp,48
ffffffffc02047f8:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02047fa:	73d8                	ld	a4,160(a5)
ffffffffc02047fc:	ff09                	bnez	a4,ffffffffc0204716 <proc_init+0xa2>
ffffffffc02047fe:	f0099ce3          	bnez	s3,ffffffffc0204716 <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204802:	6394                	ld	a3,0(a5)
ffffffffc0204804:	577d                	li	a4,-1
ffffffffc0204806:	1702                	slli	a4,a4,0x20
ffffffffc0204808:	f0e697e3          	bne	a3,a4,ffffffffc0204716 <proc_init+0xa2>
ffffffffc020480c:	4798                	lw	a4,8(a5)
ffffffffc020480e:	f00714e3          	bnez	a4,ffffffffc0204716 <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204812:	6b98                	ld	a4,16(a5)
ffffffffc0204814:	f00711e3          	bnez	a4,ffffffffc0204716 <proc_init+0xa2>
ffffffffc0204818:	4f98                	lw	a4,24(a5)
ffffffffc020481a:	2701                	sext.w	a4,a4
ffffffffc020481c:	ee071de3          	bnez	a4,ffffffffc0204716 <proc_init+0xa2>
ffffffffc0204820:	7398                	ld	a4,32(a5)
ffffffffc0204822:	ee071ae3          	bnez	a4,ffffffffc0204716 <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204826:	7798                	ld	a4,40(a5)
ffffffffc0204828:	ee0717e3          	bnez	a4,ffffffffc0204716 <proc_init+0xa2>
ffffffffc020482c:	0b07a703          	lw	a4,176(a5)
ffffffffc0204830:	8d59                	or	a0,a0,a4
ffffffffc0204832:	0005071b          	sext.w	a4,a0
ffffffffc0204836:	ee0710e3          	bnez	a4,ffffffffc0204716 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc020483a:	00002517          	auipc	a0,0x2
ffffffffc020483e:	3de50513          	addi	a0,a0,990 # ffffffffc0206c18 <default_pmm_manager+0x698>
ffffffffc0204842:	88bfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    idleproc->pid = 0;//idleproc是第0个内核线程
ffffffffc0204846:	00093783          	ld	a5,0(s2)
ffffffffc020484a:	b5f1                	j	ffffffffc0204716 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020484c:	f2878793          	addi	a5,a5,-216
ffffffffc0204850:	bfb9                	j	ffffffffc02047ae <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc0204852:	00002617          	auipc	a2,0x2
ffffffffc0204856:	3ae60613          	addi	a2,a2,942 # ffffffffc0206c00 <default_pmm_manager+0x680>
ffffffffc020485a:	18200593          	li	a1,386
ffffffffc020485e:	00002517          	auipc	a0,0x2
ffffffffc0204862:	37250513          	addi	a0,a0,882 # ffffffffc0206bd0 <default_pmm_manager+0x650>
ffffffffc0204866:	963fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("create init_main failed.\n");
ffffffffc020486a:	00002617          	auipc	a2,0x2
ffffffffc020486e:	3de60613          	addi	a2,a2,990 # ffffffffc0206c48 <default_pmm_manager+0x6c8>
ffffffffc0204872:	1a200593          	li	a1,418
ffffffffc0204876:	00002517          	auipc	a0,0x2
ffffffffc020487a:	35a50513          	addi	a0,a0,858 # ffffffffc0206bd0 <default_pmm_manager+0x650>
ffffffffc020487e:	94bfb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204882:	00002697          	auipc	a3,0x2
ffffffffc0204886:	41668693          	addi	a3,a3,1046 # ffffffffc0206c98 <default_pmm_manager+0x718>
ffffffffc020488a:	00001617          	auipc	a2,0x1
ffffffffc020488e:	f9e60613          	addi	a2,a2,-98 # ffffffffc0205828 <commands+0x728>
ffffffffc0204892:	1a900593          	li	a1,425
ffffffffc0204896:	00002517          	auipc	a0,0x2
ffffffffc020489a:	33a50513          	addi	a0,a0,826 # ffffffffc0206bd0 <default_pmm_manager+0x650>
ffffffffc020489e:	92bfb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02048a2:	00002697          	auipc	a3,0x2
ffffffffc02048a6:	3ce68693          	addi	a3,a3,974 # ffffffffc0206c70 <default_pmm_manager+0x6f0>
ffffffffc02048aa:	00001617          	auipc	a2,0x1
ffffffffc02048ae:	f7e60613          	addi	a2,a2,-130 # ffffffffc0205828 <commands+0x728>
ffffffffc02048b2:	1a800593          	li	a1,424
ffffffffc02048b6:	00002517          	auipc	a0,0x2
ffffffffc02048ba:	31a50513          	addi	a0,a0,794 # ffffffffc0206bd0 <default_pmm_manager+0x650>
ffffffffc02048be:	90bfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02048c2 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02048c2:	1141                	addi	sp,sp,-16
ffffffffc02048c4:	e022                	sd	s0,0(sp)
ffffffffc02048c6:	e406                	sd	ra,8(sp)
ffffffffc02048c8:	00011417          	auipc	s0,0x11
ffffffffc02048cc:	ce840413          	addi	s0,s0,-792 # ffffffffc02155b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02048d0:	6018                	ld	a4,0(s0)
ffffffffc02048d2:	4f1c                	lw	a5,24(a4)
ffffffffc02048d4:	2781                	sext.w	a5,a5
ffffffffc02048d6:	dff5                	beqz	a5,ffffffffc02048d2 <cpu_idle+0x10>
            schedule();
ffffffffc02048d8:	038000ef          	jal	ra,ffffffffc0204910 <schedule>
ffffffffc02048dc:	bfd5                	j	ffffffffc02048d0 <cpu_idle+0xe>

ffffffffc02048de <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048de:	411c                	lw	a5,0(a0)
ffffffffc02048e0:	4705                	li	a4,1
ffffffffc02048e2:	37f9                	addiw	a5,a5,-2
ffffffffc02048e4:	00f77563          	bgeu	a4,a5,ffffffffc02048ee <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc02048e8:	4789                	li	a5,2
ffffffffc02048ea:	c11c                	sw	a5,0(a0)
ffffffffc02048ec:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc02048ee:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048f0:	00002697          	auipc	a3,0x2
ffffffffc02048f4:	3d068693          	addi	a3,a3,976 # ffffffffc0206cc0 <default_pmm_manager+0x740>
ffffffffc02048f8:	00001617          	auipc	a2,0x1
ffffffffc02048fc:	f3060613          	addi	a2,a2,-208 # ffffffffc0205828 <commands+0x728>
ffffffffc0204900:	45a5                	li	a1,9
ffffffffc0204902:	00002517          	auipc	a0,0x2
ffffffffc0204906:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206d00 <default_pmm_manager+0x780>
wakeup_proc(struct proc_struct *proc) {
ffffffffc020490a:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020490c:	8bdfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204910 <schedule>:
}

void
schedule(void) {
ffffffffc0204910:	1141                	addi	sp,sp,-16
ffffffffc0204912:	e406                	sd	ra,8(sp)
ffffffffc0204914:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204916:	100027f3          	csrr	a5,sstatus
ffffffffc020491a:	8b89                	andi	a5,a5,2
ffffffffc020491c:	4401                	li	s0,0
ffffffffc020491e:	efbd                	bnez	a5,ffffffffc020499c <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204920:	00011897          	auipc	a7,0x11
ffffffffc0204924:	c908b883          	ld	a7,-880(a7) # ffffffffc02155b0 <current>
ffffffffc0204928:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020492c:	00011517          	auipc	a0,0x11
ffffffffc0204930:	c8c53503          	ld	a0,-884(a0) # ffffffffc02155b8 <idleproc>
ffffffffc0204934:	04a88e63          	beq	a7,a0,ffffffffc0204990 <schedule+0x80>
ffffffffc0204938:	0c888693          	addi	a3,a7,200
ffffffffc020493c:	00011617          	auipc	a2,0x11
ffffffffc0204940:	bec60613          	addi	a2,a2,-1044 # ffffffffc0215528 <proc_list>
        le = last;
ffffffffc0204944:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204946:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204948:	4809                	li	a6,2
ffffffffc020494a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020494c:	00c78863          	beq	a5,a2,ffffffffc020495c <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204950:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204954:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204958:	03070163          	beq	a4,a6,ffffffffc020497a <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc020495c:	fef697e3          	bne	a3,a5,ffffffffc020494a <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204960:	ed89                	bnez	a1,ffffffffc020497a <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204962:	451c                	lw	a5,8(a0)
ffffffffc0204964:	2785                	addiw	a5,a5,1
ffffffffc0204966:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204968:	00a88463          	beq	a7,a0,ffffffffc0204970 <schedule+0x60>
            proc_run(next);
ffffffffc020496c:	9fbff0ef          	jal	ra,ffffffffc0204366 <proc_run>
    if (flag) {
ffffffffc0204970:	e819                	bnez	s0,ffffffffc0204986 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204972:	60a2                	ld	ra,8(sp)
ffffffffc0204974:	6402                	ld	s0,0(sp)
ffffffffc0204976:	0141                	addi	sp,sp,16
ffffffffc0204978:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020497a:	4198                	lw	a4,0(a1)
ffffffffc020497c:	4789                	li	a5,2
ffffffffc020497e:	fef712e3          	bne	a4,a5,ffffffffc0204962 <schedule+0x52>
ffffffffc0204982:	852e                	mv	a0,a1
ffffffffc0204984:	bff9                	j	ffffffffc0204962 <schedule+0x52>
}
ffffffffc0204986:	6402                	ld	s0,0(sp)
ffffffffc0204988:	60a2                	ld	ra,8(sp)
ffffffffc020498a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020498c:	c33fb06f          	j	ffffffffc02005be <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204990:	00011617          	auipc	a2,0x11
ffffffffc0204994:	b9860613          	addi	a2,a2,-1128 # ffffffffc0215528 <proc_list>
ffffffffc0204998:	86b2                	mv	a3,a2
ffffffffc020499a:	b76d                	j	ffffffffc0204944 <schedule+0x34>
        intr_disable();
ffffffffc020499c:	c29fb0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02049a0:	4405                	li	s0,1
ffffffffc02049a2:	bfbd                	j	ffffffffc0204920 <schedule+0x10>

ffffffffc02049a4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02049a4:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02049a8:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02049aa:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02049ac:	cb81                	beqz	a5,ffffffffc02049bc <strlen+0x18>
        cnt ++;
ffffffffc02049ae:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02049b0:	00a707b3          	add	a5,a4,a0
ffffffffc02049b4:	0007c783          	lbu	a5,0(a5)
ffffffffc02049b8:	fbfd                	bnez	a5,ffffffffc02049ae <strlen+0xa>
ffffffffc02049ba:	8082                	ret
    }
    return cnt;
}
ffffffffc02049bc:	8082                	ret

ffffffffc02049be <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02049be:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049c0:	e589                	bnez	a1,ffffffffc02049ca <strnlen+0xc>
ffffffffc02049c2:	a811                	j	ffffffffc02049d6 <strnlen+0x18>
        cnt ++;
ffffffffc02049c4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049c6:	00f58863          	beq	a1,a5,ffffffffc02049d6 <strnlen+0x18>
ffffffffc02049ca:	00f50733          	add	a4,a0,a5
ffffffffc02049ce:	00074703          	lbu	a4,0(a4)
ffffffffc02049d2:	fb6d                	bnez	a4,ffffffffc02049c4 <strnlen+0x6>
ffffffffc02049d4:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02049d6:	852e                	mv	a0,a1
ffffffffc02049d8:	8082                	ret

ffffffffc02049da <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02049da:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02049dc:	0005c703          	lbu	a4,0(a1)
ffffffffc02049e0:	0785                	addi	a5,a5,1
ffffffffc02049e2:	0585                	addi	a1,a1,1
ffffffffc02049e4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02049e8:	fb75                	bnez	a4,ffffffffc02049dc <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02049ea:	8082                	ret

ffffffffc02049ec <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049ec:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02049f0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049f4:	cb89                	beqz	a5,ffffffffc0204a06 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02049f6:	0505                	addi	a0,a0,1
ffffffffc02049f8:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049fa:	fee789e3          	beq	a5,a4,ffffffffc02049ec <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02049fe:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204a02:	9d19                	subw	a0,a0,a4
ffffffffc0204a04:	8082                	ret
ffffffffc0204a06:	4501                	li	a0,0
ffffffffc0204a08:	bfed                	j	ffffffffc0204a02 <strcmp+0x16>

ffffffffc0204a0a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204a0a:	00054783          	lbu	a5,0(a0)
ffffffffc0204a0e:	c799                	beqz	a5,ffffffffc0204a1c <strchr+0x12>
        if (*s == c) {
ffffffffc0204a10:	00f58763          	beq	a1,a5,ffffffffc0204a1e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204a14:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204a18:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204a1a:	fbfd                	bnez	a5,ffffffffc0204a10 <strchr+0x6>
    }
    return NULL;
ffffffffc0204a1c:	4501                	li	a0,0
}
ffffffffc0204a1e:	8082                	ret

ffffffffc0204a20 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204a20:	ca01                	beqz	a2,ffffffffc0204a30 <memset+0x10>
ffffffffc0204a22:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204a24:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204a26:	0785                	addi	a5,a5,1
ffffffffc0204a28:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204a2c:	fec79de3          	bne	a5,a2,ffffffffc0204a26 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204a30:	8082                	ret

ffffffffc0204a32 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204a32:	ca19                	beqz	a2,ffffffffc0204a48 <memcpy+0x16>
ffffffffc0204a34:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204a36:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204a38:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a3c:	0585                	addi	a1,a1,1
ffffffffc0204a3e:	0785                	addi	a5,a5,1
ffffffffc0204a40:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204a44:	fec59ae3          	bne	a1,a2,ffffffffc0204a38 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204a48:	8082                	ret

ffffffffc0204a4a <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204a4a:	c205                	beqz	a2,ffffffffc0204a6a <memcmp+0x20>
ffffffffc0204a4c:	962e                	add	a2,a2,a1
ffffffffc0204a4e:	a019                	j	ffffffffc0204a54 <memcmp+0xa>
ffffffffc0204a50:	00c58d63          	beq	a1,a2,ffffffffc0204a6a <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0204a54:	00054783          	lbu	a5,0(a0)
ffffffffc0204a58:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204a5c:	0505                	addi	a0,a0,1
ffffffffc0204a5e:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0204a60:	fee788e3          	beq	a5,a4,ffffffffc0204a50 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204a64:	40e7853b          	subw	a0,a5,a4
ffffffffc0204a68:	8082                	ret
    }
    return 0;
ffffffffc0204a6a:	4501                	li	a0,0
}
ffffffffc0204a6c:	8082                	ret

ffffffffc0204a6e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204a6e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a72:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204a74:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a78:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204a7a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a7e:	f022                	sd	s0,32(sp)
ffffffffc0204a80:	ec26                	sd	s1,24(sp)
ffffffffc0204a82:	e84a                	sd	s2,16(sp)
ffffffffc0204a84:	f406                	sd	ra,40(sp)
ffffffffc0204a86:	e44e                	sd	s3,8(sp)
ffffffffc0204a88:	84aa                	mv	s1,a0
ffffffffc0204a8a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204a8c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204a90:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204a92:	03067e63          	bgeu	a2,a6,ffffffffc0204ace <printnum+0x60>
ffffffffc0204a96:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204a98:	00805763          	blez	s0,ffffffffc0204aa6 <printnum+0x38>
ffffffffc0204a9c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204a9e:	85ca                	mv	a1,s2
ffffffffc0204aa0:	854e                	mv	a0,s3
ffffffffc0204aa2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204aa4:	fc65                	bnez	s0,ffffffffc0204a9c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204aa6:	1a02                	slli	s4,s4,0x20
ffffffffc0204aa8:	00002797          	auipc	a5,0x2
ffffffffc0204aac:	27078793          	addi	a5,a5,624 # ffffffffc0206d18 <default_pmm_manager+0x798>
ffffffffc0204ab0:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204ab4:	9a3e                	add	s4,s4,a5
}
ffffffffc0204ab6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ab8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204abc:	70a2                	ld	ra,40(sp)
ffffffffc0204abe:	69a2                	ld	s3,8(sp)
ffffffffc0204ac0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ac2:	85ca                	mv	a1,s2
ffffffffc0204ac4:	87a6                	mv	a5,s1
}
ffffffffc0204ac6:	6942                	ld	s2,16(sp)
ffffffffc0204ac8:	64e2                	ld	s1,24(sp)
ffffffffc0204aca:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204acc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204ace:	03065633          	divu	a2,a2,a6
ffffffffc0204ad2:	8722                	mv	a4,s0
ffffffffc0204ad4:	f9bff0ef          	jal	ra,ffffffffc0204a6e <printnum>
ffffffffc0204ad8:	b7f9                	j	ffffffffc0204aa6 <printnum+0x38>

ffffffffc0204ada <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204ada:	7119                	addi	sp,sp,-128
ffffffffc0204adc:	f4a6                	sd	s1,104(sp)
ffffffffc0204ade:	f0ca                	sd	s2,96(sp)
ffffffffc0204ae0:	ecce                	sd	s3,88(sp)
ffffffffc0204ae2:	e8d2                	sd	s4,80(sp)
ffffffffc0204ae4:	e4d6                	sd	s5,72(sp)
ffffffffc0204ae6:	e0da                	sd	s6,64(sp)
ffffffffc0204ae8:	fc5e                	sd	s7,56(sp)
ffffffffc0204aea:	f06a                	sd	s10,32(sp)
ffffffffc0204aec:	fc86                	sd	ra,120(sp)
ffffffffc0204aee:	f8a2                	sd	s0,112(sp)
ffffffffc0204af0:	f862                	sd	s8,48(sp)
ffffffffc0204af2:	f466                	sd	s9,40(sp)
ffffffffc0204af4:	ec6e                	sd	s11,24(sp)
ffffffffc0204af6:	892a                	mv	s2,a0
ffffffffc0204af8:	84ae                	mv	s1,a1
ffffffffc0204afa:	8d32                	mv	s10,a2
ffffffffc0204afc:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204afe:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b02:	5b7d                	li	s6,-1
ffffffffc0204b04:	00002a97          	auipc	s5,0x2
ffffffffc0204b08:	240a8a93          	addi	s5,s5,576 # ffffffffc0206d44 <default_pmm_manager+0x7c4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b0c:	00002b97          	auipc	s7,0x2
ffffffffc0204b10:	414b8b93          	addi	s7,s7,1044 # ffffffffc0206f20 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b14:	000d4503          	lbu	a0,0(s10)
ffffffffc0204b18:	001d0413          	addi	s0,s10,1
ffffffffc0204b1c:	01350a63          	beq	a0,s3,ffffffffc0204b30 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204b20:	c121                	beqz	a0,ffffffffc0204b60 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204b22:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b24:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b26:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b28:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b2c:	ff351ae3          	bne	a0,s3,ffffffffc0204b20 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b30:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204b34:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b38:	4c81                	li	s9,0
ffffffffc0204b3a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204b3c:	5c7d                	li	s8,-1
ffffffffc0204b3e:	5dfd                	li	s11,-1
ffffffffc0204b40:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204b44:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b46:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204b4a:	0ff5f593          	zext.b	a1,a1
ffffffffc0204b4e:	00140d13          	addi	s10,s0,1
ffffffffc0204b52:	04b56263          	bltu	a0,a1,ffffffffc0204b96 <vprintfmt+0xbc>
ffffffffc0204b56:	058a                	slli	a1,a1,0x2
ffffffffc0204b58:	95d6                	add	a1,a1,s5
ffffffffc0204b5a:	4194                	lw	a3,0(a1)
ffffffffc0204b5c:	96d6                	add	a3,a3,s5
ffffffffc0204b5e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204b60:	70e6                	ld	ra,120(sp)
ffffffffc0204b62:	7446                	ld	s0,112(sp)
ffffffffc0204b64:	74a6                	ld	s1,104(sp)
ffffffffc0204b66:	7906                	ld	s2,96(sp)
ffffffffc0204b68:	69e6                	ld	s3,88(sp)
ffffffffc0204b6a:	6a46                	ld	s4,80(sp)
ffffffffc0204b6c:	6aa6                	ld	s5,72(sp)
ffffffffc0204b6e:	6b06                	ld	s6,64(sp)
ffffffffc0204b70:	7be2                	ld	s7,56(sp)
ffffffffc0204b72:	7c42                	ld	s8,48(sp)
ffffffffc0204b74:	7ca2                	ld	s9,40(sp)
ffffffffc0204b76:	7d02                	ld	s10,32(sp)
ffffffffc0204b78:	6de2                	ld	s11,24(sp)
ffffffffc0204b7a:	6109                	addi	sp,sp,128
ffffffffc0204b7c:	8082                	ret
            padc = '0';
ffffffffc0204b7e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204b80:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b84:	846a                	mv	s0,s10
ffffffffc0204b86:	00140d13          	addi	s10,s0,1
ffffffffc0204b8a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204b8e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204b92:	fcb572e3          	bgeu	a0,a1,ffffffffc0204b56 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204b96:	85a6                	mv	a1,s1
ffffffffc0204b98:	02500513          	li	a0,37
ffffffffc0204b9c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204b9e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204ba2:	8d22                	mv	s10,s0
ffffffffc0204ba4:	f73788e3          	beq	a5,s3,ffffffffc0204b14 <vprintfmt+0x3a>
ffffffffc0204ba8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204bac:	1d7d                	addi	s10,s10,-1
ffffffffc0204bae:	ff379de3          	bne	a5,s3,ffffffffc0204ba8 <vprintfmt+0xce>
ffffffffc0204bb2:	b78d                	j	ffffffffc0204b14 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204bb4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204bb8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bbc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204bbe:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204bc2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204bc6:	02d86463          	bltu	a6,a3,ffffffffc0204bee <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204bca:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204bce:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204bd2:	0186873b          	addw	a4,a3,s8
ffffffffc0204bd6:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204bda:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204bdc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204be0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204be2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204be6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204bea:	fed870e3          	bgeu	a6,a3,ffffffffc0204bca <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204bee:	f40ddce3          	bgez	s11,ffffffffc0204b46 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204bf2:	8de2                	mv	s11,s8
ffffffffc0204bf4:	5c7d                	li	s8,-1
ffffffffc0204bf6:	bf81                	j	ffffffffc0204b46 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204bf8:	fffdc693          	not	a3,s11
ffffffffc0204bfc:	96fd                	srai	a3,a3,0x3f
ffffffffc0204bfe:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c02:	00144603          	lbu	a2,1(s0)
ffffffffc0204c06:	2d81                	sext.w	s11,s11
ffffffffc0204c08:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c0a:	bf35                	j	ffffffffc0204b46 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204c0c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c10:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204c14:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c16:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204c18:	bfd9                	j	ffffffffc0204bee <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204c1a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c1c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c20:	01174463          	blt	a4,a7,ffffffffc0204c28 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204c24:	1a088e63          	beqz	a7,ffffffffc0204de0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204c28:	000a3603          	ld	a2,0(s4)
ffffffffc0204c2c:	46c1                	li	a3,16
ffffffffc0204c2e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c30:	2781                	sext.w	a5,a5
ffffffffc0204c32:	876e                	mv	a4,s11
ffffffffc0204c34:	85a6                	mv	a1,s1
ffffffffc0204c36:	854a                	mv	a0,s2
ffffffffc0204c38:	e37ff0ef          	jal	ra,ffffffffc0204a6e <printnum>
            break;
ffffffffc0204c3c:	bde1                	j	ffffffffc0204b14 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204c3e:	000a2503          	lw	a0,0(s4)
ffffffffc0204c42:	85a6                	mv	a1,s1
ffffffffc0204c44:	0a21                	addi	s4,s4,8
ffffffffc0204c46:	9902                	jalr	s2
            break;
ffffffffc0204c48:	b5f1                	j	ffffffffc0204b14 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c4a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c4c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c50:	01174463          	blt	a4,a7,ffffffffc0204c58 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204c54:	18088163          	beqz	a7,ffffffffc0204dd6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204c58:	000a3603          	ld	a2,0(s4)
ffffffffc0204c5c:	46a9                	li	a3,10
ffffffffc0204c5e:	8a2e                	mv	s4,a1
ffffffffc0204c60:	bfc1                	j	ffffffffc0204c30 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c62:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204c66:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c68:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c6a:	bdf1                	j	ffffffffc0204b46 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204c6c:	85a6                	mv	a1,s1
ffffffffc0204c6e:	02500513          	li	a0,37
ffffffffc0204c72:	9902                	jalr	s2
            break;
ffffffffc0204c74:	b545                	j	ffffffffc0204b14 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c76:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204c7a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c7c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c7e:	b5e1                	j	ffffffffc0204b46 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204c80:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c82:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c86:	01174463          	blt	a4,a7,ffffffffc0204c8e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204c8a:	14088163          	beqz	a7,ffffffffc0204dcc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204c8e:	000a3603          	ld	a2,0(s4)
ffffffffc0204c92:	46a1                	li	a3,8
ffffffffc0204c94:	8a2e                	mv	s4,a1
ffffffffc0204c96:	bf69                	j	ffffffffc0204c30 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204c98:	03000513          	li	a0,48
ffffffffc0204c9c:	85a6                	mv	a1,s1
ffffffffc0204c9e:	e03e                	sd	a5,0(sp)
ffffffffc0204ca0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204ca2:	85a6                	mv	a1,s1
ffffffffc0204ca4:	07800513          	li	a0,120
ffffffffc0204ca8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204caa:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204cac:	6782                	ld	a5,0(sp)
ffffffffc0204cae:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204cb0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204cb4:	bfb5                	j	ffffffffc0204c30 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204cb6:	000a3403          	ld	s0,0(s4)
ffffffffc0204cba:	008a0713          	addi	a4,s4,8
ffffffffc0204cbe:	e03a                	sd	a4,0(sp)
ffffffffc0204cc0:	14040263          	beqz	s0,ffffffffc0204e04 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204cc4:	0fb05763          	blez	s11,ffffffffc0204db2 <vprintfmt+0x2d8>
ffffffffc0204cc8:	02d00693          	li	a3,45
ffffffffc0204ccc:	0cd79163          	bne	a5,a3,ffffffffc0204d8e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cd0:	00044783          	lbu	a5,0(s0)
ffffffffc0204cd4:	0007851b          	sext.w	a0,a5
ffffffffc0204cd8:	cf85                	beqz	a5,ffffffffc0204d10 <vprintfmt+0x236>
ffffffffc0204cda:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204cde:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204ce2:	000c4563          	bltz	s8,ffffffffc0204cec <vprintfmt+0x212>
ffffffffc0204ce6:	3c7d                	addiw	s8,s8,-1
ffffffffc0204ce8:	036c0263          	beq	s8,s6,ffffffffc0204d0c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204cec:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204cee:	0e0c8e63          	beqz	s9,ffffffffc0204dea <vprintfmt+0x310>
ffffffffc0204cf2:	3781                	addiw	a5,a5,-32
ffffffffc0204cf4:	0ef47b63          	bgeu	s0,a5,ffffffffc0204dea <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204cf8:	03f00513          	li	a0,63
ffffffffc0204cfc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cfe:	000a4783          	lbu	a5,0(s4)
ffffffffc0204d02:	3dfd                	addiw	s11,s11,-1
ffffffffc0204d04:	0a05                	addi	s4,s4,1
ffffffffc0204d06:	0007851b          	sext.w	a0,a5
ffffffffc0204d0a:	ffe1                	bnez	a5,ffffffffc0204ce2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204d0c:	01b05963          	blez	s11,ffffffffc0204d1e <vprintfmt+0x244>
ffffffffc0204d10:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d12:	85a6                	mv	a1,s1
ffffffffc0204d14:	02000513          	li	a0,32
ffffffffc0204d18:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d1a:	fe0d9be3          	bnez	s11,ffffffffc0204d10 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d1e:	6a02                	ld	s4,0(sp)
ffffffffc0204d20:	bbd5                	j	ffffffffc0204b14 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d22:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204d24:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204d28:	01174463          	blt	a4,a7,ffffffffc0204d30 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204d2c:	08088d63          	beqz	a7,ffffffffc0204dc6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204d30:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204d34:	0a044d63          	bltz	s0,ffffffffc0204dee <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204d38:	8622                	mv	a2,s0
ffffffffc0204d3a:	8a66                	mv	s4,s9
ffffffffc0204d3c:	46a9                	li	a3,10
ffffffffc0204d3e:	bdcd                	j	ffffffffc0204c30 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204d40:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d44:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204d46:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204d48:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204d4c:	8fb5                	xor	a5,a5,a3
ffffffffc0204d4e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d52:	02d74163          	blt	a4,a3,ffffffffc0204d74 <vprintfmt+0x29a>
ffffffffc0204d56:	00369793          	slli	a5,a3,0x3
ffffffffc0204d5a:	97de                	add	a5,a5,s7
ffffffffc0204d5c:	639c                	ld	a5,0(a5)
ffffffffc0204d5e:	cb99                	beqz	a5,ffffffffc0204d74 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204d60:	86be                	mv	a3,a5
ffffffffc0204d62:	00000617          	auipc	a2,0x0
ffffffffc0204d66:	13e60613          	addi	a2,a2,318 # ffffffffc0204ea0 <etext+0x2e>
ffffffffc0204d6a:	85a6                	mv	a1,s1
ffffffffc0204d6c:	854a                	mv	a0,s2
ffffffffc0204d6e:	0ce000ef          	jal	ra,ffffffffc0204e3c <printfmt>
ffffffffc0204d72:	b34d                	j	ffffffffc0204b14 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204d74:	00002617          	auipc	a2,0x2
ffffffffc0204d78:	fc460613          	addi	a2,a2,-60 # ffffffffc0206d38 <default_pmm_manager+0x7b8>
ffffffffc0204d7c:	85a6                	mv	a1,s1
ffffffffc0204d7e:	854a                	mv	a0,s2
ffffffffc0204d80:	0bc000ef          	jal	ra,ffffffffc0204e3c <printfmt>
ffffffffc0204d84:	bb41                	j	ffffffffc0204b14 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204d86:	00002417          	auipc	s0,0x2
ffffffffc0204d8a:	faa40413          	addi	s0,s0,-86 # ffffffffc0206d30 <default_pmm_manager+0x7b0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d8e:	85e2                	mv	a1,s8
ffffffffc0204d90:	8522                	mv	a0,s0
ffffffffc0204d92:	e43e                	sd	a5,8(sp)
ffffffffc0204d94:	c2bff0ef          	jal	ra,ffffffffc02049be <strnlen>
ffffffffc0204d98:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204d9c:	01b05b63          	blez	s11,ffffffffc0204db2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204da0:	67a2                	ld	a5,8(sp)
ffffffffc0204da2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204da6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204da8:	85a6                	mv	a1,s1
ffffffffc0204daa:	8552                	mv	a0,s4
ffffffffc0204dac:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dae:	fe0d9ce3          	bnez	s11,ffffffffc0204da6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204db2:	00044783          	lbu	a5,0(s0)
ffffffffc0204db6:	00140a13          	addi	s4,s0,1
ffffffffc0204dba:	0007851b          	sext.w	a0,a5
ffffffffc0204dbe:	d3a5                	beqz	a5,ffffffffc0204d1e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204dc0:	05e00413          	li	s0,94
ffffffffc0204dc4:	bf39                	j	ffffffffc0204ce2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204dc6:	000a2403          	lw	s0,0(s4)
ffffffffc0204dca:	b7ad                	j	ffffffffc0204d34 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204dcc:	000a6603          	lwu	a2,0(s4)
ffffffffc0204dd0:	46a1                	li	a3,8
ffffffffc0204dd2:	8a2e                	mv	s4,a1
ffffffffc0204dd4:	bdb1                	j	ffffffffc0204c30 <vprintfmt+0x156>
ffffffffc0204dd6:	000a6603          	lwu	a2,0(s4)
ffffffffc0204dda:	46a9                	li	a3,10
ffffffffc0204ddc:	8a2e                	mv	s4,a1
ffffffffc0204dde:	bd89                	j	ffffffffc0204c30 <vprintfmt+0x156>
ffffffffc0204de0:	000a6603          	lwu	a2,0(s4)
ffffffffc0204de4:	46c1                	li	a3,16
ffffffffc0204de6:	8a2e                	mv	s4,a1
ffffffffc0204de8:	b5a1                	j	ffffffffc0204c30 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204dea:	9902                	jalr	s2
ffffffffc0204dec:	bf09                	j	ffffffffc0204cfe <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204dee:	85a6                	mv	a1,s1
ffffffffc0204df0:	02d00513          	li	a0,45
ffffffffc0204df4:	e03e                	sd	a5,0(sp)
ffffffffc0204df6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204df8:	6782                	ld	a5,0(sp)
ffffffffc0204dfa:	8a66                	mv	s4,s9
ffffffffc0204dfc:	40800633          	neg	a2,s0
ffffffffc0204e00:	46a9                	li	a3,10
ffffffffc0204e02:	b53d                	j	ffffffffc0204c30 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204e04:	03b05163          	blez	s11,ffffffffc0204e26 <vprintfmt+0x34c>
ffffffffc0204e08:	02d00693          	li	a3,45
ffffffffc0204e0c:	f6d79de3          	bne	a5,a3,ffffffffc0204d86 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204e10:	00002417          	auipc	s0,0x2
ffffffffc0204e14:	f2040413          	addi	s0,s0,-224 # ffffffffc0206d30 <default_pmm_manager+0x7b0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e18:	02800793          	li	a5,40
ffffffffc0204e1c:	02800513          	li	a0,40
ffffffffc0204e20:	00140a13          	addi	s4,s0,1
ffffffffc0204e24:	bd6d                	j	ffffffffc0204cde <vprintfmt+0x204>
ffffffffc0204e26:	00002a17          	auipc	s4,0x2
ffffffffc0204e2a:	f0ba0a13          	addi	s4,s4,-245 # ffffffffc0206d31 <default_pmm_manager+0x7b1>
ffffffffc0204e2e:	02800513          	li	a0,40
ffffffffc0204e32:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e36:	05e00413          	li	s0,94
ffffffffc0204e3a:	b565                	j	ffffffffc0204ce2 <vprintfmt+0x208>

ffffffffc0204e3c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e3c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e3e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e42:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e44:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e46:	ec06                	sd	ra,24(sp)
ffffffffc0204e48:	f83a                	sd	a4,48(sp)
ffffffffc0204e4a:	fc3e                	sd	a5,56(sp)
ffffffffc0204e4c:	e0c2                	sd	a6,64(sp)
ffffffffc0204e4e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204e50:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e52:	c89ff0ef          	jal	ra,ffffffffc0204ada <vprintfmt>
}
ffffffffc0204e56:	60e2                	ld	ra,24(sp)
ffffffffc0204e58:	6161                	addi	sp,sp,80
ffffffffc0204e5a:	8082                	ret

ffffffffc0204e5c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204e5c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204e60:	2785                	addiw	a5,a5,1
ffffffffc0204e62:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204e66:	02000793          	li	a5,32
ffffffffc0204e6a:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204e6c:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204e70:	8082                	ret
