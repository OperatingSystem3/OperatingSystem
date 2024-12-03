
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
ffffffffc0200036:	02650513          	addi	a0,a0,38 # ffffffffc020a058 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	58a60613          	addi	a2,a2,1418 # ffffffffc02155c4 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	059040ef          	jal	ra,ffffffffc02048a2 <memset>

    cons_init();                // init the console
ffffffffc020004e:	4fc000ef          	jal	ra,ffffffffc020054a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	ca658593          	addi	a1,a1,-858 # ffffffffc0204cf8 <etext+0x4>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	cbe50513          	addi	a0,a0,-834 # ffffffffc0204d18 <etext+0x24>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	1be000ef          	jal	ra,ffffffffc0200224 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	4c2030ef          	jal	ra,ffffffffc020352c <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	54e000ef          	jal	ra,ffffffffc02005bc <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	4d5000ef          	jal	ra,ffffffffc0200d4a <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	452040ef          	jal	ra,ffffffffc02044cc <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	424000ef          	jal	ra,ffffffffc02004a2 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	38b010ef          	jal	ra,ffffffffc0201c0c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	472000ef          	jal	ra,ffffffffc02004f8 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	534000ef          	jal	ra,ffffffffc02005be <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	6e8040ef          	jal	ra,ffffffffc0204776 <cpu_idle>

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
ffffffffc02000c0:	09d040ef          	jal	ra,ffffffffc020495c <vprintfmt>
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
ffffffffc02000f6:	067040ef          	jal	ra,ffffffffc020495c <vprintfmt>
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
ffffffffc020012e:	bf650513          	addi	a0,a0,-1034 # ffffffffc0204d20 <etext+0x2c>
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
ffffffffc0200144:	f18b8b93          	addi	s7,s7,-232 # ffffffffc020a058 <buf>
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
ffffffffc02001a0:	ebc50513          	addi	a0,a0,-324 # ffffffffc020a058 <buf>
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
ffffffffc02001cc:	36830313          	addi	t1,t1,872 # ffffffffc0215530 <is_panic>
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
ffffffffc02001fa:	b3250513          	addi	a0,a0,-1230 # ffffffffc0204d28 <etext+0x34>
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
ffffffffc0200210:	5ac50513          	addi	a0,a0,1452 # ffffffffc02067b8 <default_pmm_manager+0x3b8>
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
ffffffffc020022a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0204d48 <etext+0x54>
void print_kerninfo(void) {
ffffffffc020022e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200230:	e9dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200234:	00000597          	auipc	a1,0x0
ffffffffc0200238:	dfe58593          	addi	a1,a1,-514 # ffffffffc0200032 <kern_init>
ffffffffc020023c:	00005517          	auipc	a0,0x5
ffffffffc0200240:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0204d68 <etext+0x74>
ffffffffc0200244:	e89ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200248:	00005597          	auipc	a1,0x5
ffffffffc020024c:	aac58593          	addi	a1,a1,-1364 # ffffffffc0204cf4 <etext>
ffffffffc0200250:	00005517          	auipc	a0,0x5
ffffffffc0200254:	b3850513          	addi	a0,a0,-1224 # ffffffffc0204d88 <etext+0x94>
ffffffffc0200258:	e75ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025c:	0000a597          	auipc	a1,0xa
ffffffffc0200260:	dfc58593          	addi	a1,a1,-516 # ffffffffc020a058 <buf>
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	b4450513          	addi	a0,a0,-1212 # ffffffffc0204da8 <etext+0xb4>
ffffffffc020026c:	e61ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200270:	00015597          	auipc	a1,0x15
ffffffffc0200274:	35458593          	addi	a1,a1,852 # ffffffffc02155c4 <end>
ffffffffc0200278:	00005517          	auipc	a0,0x5
ffffffffc020027c:	b5050513          	addi	a0,a0,-1200 # ffffffffc0204dc8 <etext+0xd4>
ffffffffc0200280:	e4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200284:	00015597          	auipc	a1,0x15
ffffffffc0200288:	73f58593          	addi	a1,a1,1855 # ffffffffc02159c3 <end+0x3ff>
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
ffffffffc02002aa:	b4250513          	addi	a0,a0,-1214 # ffffffffc0204de8 <etext+0xf4>
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
ffffffffc02002b8:	b6460613          	addi	a2,a2,-1180 # ffffffffc0204e18 <etext+0x124>
ffffffffc02002bc:	04d00593          	li	a1,77
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	b7050513          	addi	a0,a0,-1168 # ffffffffc0204e30 <etext+0x13c>
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
ffffffffc02002d4:	b7860613          	addi	a2,a2,-1160 # ffffffffc0204e48 <etext+0x154>
ffffffffc02002d8:	00005597          	auipc	a1,0x5
ffffffffc02002dc:	b9058593          	addi	a1,a1,-1136 # ffffffffc0204e68 <etext+0x174>
ffffffffc02002e0:	00005517          	auipc	a0,0x5
ffffffffc02002e4:	b9050513          	addi	a0,a0,-1136 # ffffffffc0204e70 <etext+0x17c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	de3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02002ee:	00005617          	auipc	a2,0x5
ffffffffc02002f2:	b9260613          	addi	a2,a2,-1134 # ffffffffc0204e80 <etext+0x18c>
ffffffffc02002f6:	00005597          	auipc	a1,0x5
ffffffffc02002fa:	bb258593          	addi	a1,a1,-1102 # ffffffffc0204ea8 <etext+0x1b4>
ffffffffc02002fe:	00005517          	auipc	a0,0x5
ffffffffc0200302:	b7250513          	addi	a0,a0,-1166 # ffffffffc0204e70 <etext+0x17c>
ffffffffc0200306:	dc7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020030a:	00005617          	auipc	a2,0x5
ffffffffc020030e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204eb8 <etext+0x1c4>
ffffffffc0200312:	00005597          	auipc	a1,0x5
ffffffffc0200316:	bc658593          	addi	a1,a1,-1082 # ffffffffc0204ed8 <etext+0x1e4>
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0204e70 <etext+0x17c>
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
ffffffffc0200358:	b9450513          	addi	a0,a0,-1132 # ffffffffc0204ee8 <etext+0x1f4>
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
ffffffffc020037a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0204f10 <etext+0x21c>
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
ffffffffc020039c:	be8c0c13          	addi	s8,s8,-1048 # ffffffffc0204f80 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a0:	00005917          	auipc	s2,0x5
ffffffffc02003a4:	b9890913          	addi	s2,s2,-1128 # ffffffffc0204f38 <etext+0x244>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a8:	00005497          	auipc	s1,0x5
ffffffffc02003ac:	b9848493          	addi	s1,s1,-1128 # ffffffffc0204f40 <etext+0x24c>
        if (argc == MAXARGS - 1) {
ffffffffc02003b0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b2:	00005b17          	auipc	s6,0x5
ffffffffc02003b6:	b96b0b13          	addi	s6,s6,-1130 # ffffffffc0204f48 <etext+0x254>
        argv[argc ++] = buf;
ffffffffc02003ba:	00005a17          	auipc	s4,0x5
ffffffffc02003be:	aaea0a13          	addi	s4,s4,-1362 # ffffffffc0204e68 <etext+0x174>
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
ffffffffc02003e0:	ba4d0d13          	addi	s10,s10,-1116 # ffffffffc0204f80 <commands>
        argv[argc ++] = buf;
ffffffffc02003e4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	4401                	li	s0,0
ffffffffc02003e8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ea:	484040ef          	jal	ra,ffffffffc020486e <strcmp>
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
ffffffffc02003fe:	470040ef          	jal	ra,ffffffffc020486e <strcmp>
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
ffffffffc020043c:	450040ef          	jal	ra,ffffffffc020488c <strchr>
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
ffffffffc020047a:	412040ef          	jal	ra,ffffffffc020488c <strchr>
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
ffffffffc0200498:	ad450513          	addi	a0,a0,-1324 # ffffffffc0204f68 <etext+0x274>
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
ffffffffc02004b4:	fa878793          	addi	a5,a5,-88 # ffffffffc020a458 <ide>
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
ffffffffc02004c8:	3ec040ef          	jal	ra,ffffffffc02048b4 <memcpy>
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
ffffffffc02004dc:	f8050513          	addi	a0,a0,-128 # ffffffffc020a458 <ide>
                   size_t nsecs) {
ffffffffc02004e0:	1141                	addi	sp,sp,-16
ffffffffc02004e2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e4:	953e                	add	a0,a0,a5
ffffffffc02004e6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004ea:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ec:	3c8040ef          	jal	ra,ffffffffc02048b4 <memcpy>
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
ffffffffc0200502:	04f73123          	sd	a5,66(a4) # ffffffffc0215540 <timebase>
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
ffffffffc0200522:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0204fc8 <commands+0x48>
    ticks = 0;
ffffffffc0200526:	00015797          	auipc	a5,0x15
ffffffffc020052a:	0007b923          	sd	zero,18(a5) # ffffffffc0215538 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020052e:	be79                	j	ffffffffc02000cc <cprintf>

ffffffffc0200530 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200530:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200534:	00015797          	auipc	a5,0x15
ffffffffc0200538:	00c7b783          	ld	a5,12(a5) # ffffffffc0215540 <timebase>
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
ffffffffc02005fe:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0204fe8 <commands+0x68>
ffffffffc0200602:	acbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00015517          	auipc	a0,0x15
ffffffffc020060a:	f4253503          	ld	a0,-190(a0) # ffffffffc0215548 <check_mm_struct>
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
ffffffffc020061e:	51f0006f          	j	ffffffffc020133c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00005617          	auipc	a2,0x5
ffffffffc0200626:	9e660613          	addi	a2,a2,-1562 # ffffffffc0205008 <commands+0x88>
ffffffffc020062a:	06200593          	li	a1,98
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	9f250513          	addi	a0,a0,-1550 # ffffffffc0205020 <commands+0xa0>
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
ffffffffc0200660:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0205038 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	a67ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205050 <commands+0xd0>
ffffffffc0200674:	a59ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00005517          	auipc	a0,0x5
ffffffffc020067e:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0205068 <commands+0xe8>
ffffffffc0200682:	a4bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00005517          	auipc	a0,0x5
ffffffffc020068c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205080 <commands+0x100>
ffffffffc0200690:	a3dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00005517          	auipc	a0,0x5
ffffffffc020069a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0205098 <commands+0x118>
ffffffffc020069e:	a2fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00005517          	auipc	a0,0x5
ffffffffc02006a8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02050b0 <commands+0x130>
ffffffffc02006ac:	a21ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00005517          	auipc	a0,0x5
ffffffffc02006b6:	a1650513          	addi	a0,a0,-1514 # ffffffffc02050c8 <commands+0x148>
ffffffffc02006ba:	a13ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00005517          	auipc	a0,0x5
ffffffffc02006c4:	a2050513          	addi	a0,a0,-1504 # ffffffffc02050e0 <commands+0x160>
ffffffffc02006c8:	a05ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00005517          	auipc	a0,0x5
ffffffffc02006d2:	a2a50513          	addi	a0,a0,-1494 # ffffffffc02050f8 <commands+0x178>
ffffffffc02006d6:	9f7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00005517          	auipc	a0,0x5
ffffffffc02006e0:	a3450513          	addi	a0,a0,-1484 # ffffffffc0205110 <commands+0x190>
ffffffffc02006e4:	9e9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00005517          	auipc	a0,0x5
ffffffffc02006ee:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0205128 <commands+0x1a8>
ffffffffc02006f2:	9dbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	a4850513          	addi	a0,a0,-1464 # ffffffffc0205140 <commands+0x1c0>
ffffffffc0200700:	9cdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00005517          	auipc	a0,0x5
ffffffffc020070a:	a5250513          	addi	a0,a0,-1454 # ffffffffc0205158 <commands+0x1d8>
ffffffffc020070e:	9bfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00005517          	auipc	a0,0x5
ffffffffc0200718:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0205170 <commands+0x1f0>
ffffffffc020071c:	9b1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00005517          	auipc	a0,0x5
ffffffffc0200726:	a6650513          	addi	a0,a0,-1434 # ffffffffc0205188 <commands+0x208>
ffffffffc020072a:	9a3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	a7050513          	addi	a0,a0,-1424 # ffffffffc02051a0 <commands+0x220>
ffffffffc0200738:	995ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00005517          	auipc	a0,0x5
ffffffffc0200742:	a7a50513          	addi	a0,a0,-1414 # ffffffffc02051b8 <commands+0x238>
ffffffffc0200746:	987ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00005517          	auipc	a0,0x5
ffffffffc0200750:	a8450513          	addi	a0,a0,-1404 # ffffffffc02051d0 <commands+0x250>
ffffffffc0200754:	979ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00005517          	auipc	a0,0x5
ffffffffc020075e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02051e8 <commands+0x268>
ffffffffc0200762:	96bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00005517          	auipc	a0,0x5
ffffffffc020076c:	a9850513          	addi	a0,a0,-1384 # ffffffffc0205200 <commands+0x280>
ffffffffc0200770:	95dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	aa250513          	addi	a0,a0,-1374 # ffffffffc0205218 <commands+0x298>
ffffffffc020077e:	94fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00005517          	auipc	a0,0x5
ffffffffc0200788:	aac50513          	addi	a0,a0,-1364 # ffffffffc0205230 <commands+0x2b0>
ffffffffc020078c:	941ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00005517          	auipc	a0,0x5
ffffffffc0200796:	ab650513          	addi	a0,a0,-1354 # ffffffffc0205248 <commands+0x2c8>
ffffffffc020079a:	933ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00005517          	auipc	a0,0x5
ffffffffc02007a4:	ac050513          	addi	a0,a0,-1344 # ffffffffc0205260 <commands+0x2e0>
ffffffffc02007a8:	925ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00005517          	auipc	a0,0x5
ffffffffc02007b2:	aca50513          	addi	a0,a0,-1334 # ffffffffc0205278 <commands+0x2f8>
ffffffffc02007b6:	917ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	ad450513          	addi	a0,a0,-1324 # ffffffffc0205290 <commands+0x310>
ffffffffc02007c4:	909ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00005517          	auipc	a0,0x5
ffffffffc02007ce:	ade50513          	addi	a0,a0,-1314 # ffffffffc02052a8 <commands+0x328>
ffffffffc02007d2:	8fbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00005517          	auipc	a0,0x5
ffffffffc02007dc:	ae850513          	addi	a0,a0,-1304 # ffffffffc02052c0 <commands+0x340>
ffffffffc02007e0:	8edff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00005517          	auipc	a0,0x5
ffffffffc02007ea:	af250513          	addi	a0,a0,-1294 # ffffffffc02052d8 <commands+0x358>
ffffffffc02007ee:	8dfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00005517          	auipc	a0,0x5
ffffffffc02007f8:	afc50513          	addi	a0,a0,-1284 # ffffffffc02052f0 <commands+0x370>
ffffffffc02007fc:	8d1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00005517          	auipc	a0,0x5
ffffffffc0200806:	b0650513          	addi	a0,a0,-1274 # ffffffffc0205308 <commands+0x388>
ffffffffc020080a:	8c3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00005517          	auipc	a0,0x5
ffffffffc0200818:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0205320 <commands+0x3a0>
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
ffffffffc020082e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0205338 <commands+0x3b8>
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
ffffffffc0200846:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0205350 <commands+0x3d0>
ffffffffc020084a:	883ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084e:	10843583          	ld	a1,264(s0)
ffffffffc0200852:	00005517          	auipc	a0,0x5
ffffffffc0200856:	b1650513          	addi	a0,a0,-1258 # ffffffffc0205368 <commands+0x3e8>
ffffffffc020085a:	873ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085e:	11043583          	ld	a1,272(s0)
ffffffffc0200862:	00005517          	auipc	a0,0x5
ffffffffc0200866:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0205380 <commands+0x400>
ffffffffc020086a:	863ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200872:	6402                	ld	s0,0(sp)
ffffffffc0200874:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200876:	00005517          	auipc	a0,0x5
ffffffffc020087a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0205398 <commands+0x418>
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
ffffffffc0200896:	bce70713          	addi	a4,a4,-1074 # ffffffffc0205460 <commands+0x4e0>
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
ffffffffc02008a8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0205410 <commands+0x490>
ffffffffc02008ac:	821ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008b0:	00005517          	auipc	a0,0x5
ffffffffc02008b4:	b4050513          	addi	a0,a0,-1216 # ffffffffc02053f0 <commands+0x470>
ffffffffc02008b8:	815ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008bc:	00005517          	auipc	a0,0x5
ffffffffc02008c0:	af450513          	addi	a0,a0,-1292 # ffffffffc02053b0 <commands+0x430>
ffffffffc02008c4:	809ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c8:	00005517          	auipc	a0,0x5
ffffffffc02008cc:	b0850513          	addi	a0,a0,-1272 # ffffffffc02053d0 <commands+0x450>
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
ffffffffc02008e0:	c5c68693          	addi	a3,a3,-932 # ffffffffc0215538 <ticks>
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
ffffffffc02008fe:	b4650513          	addi	a0,a0,-1210 # ffffffffc0205440 <commands+0x4c0>
ffffffffc0200902:	fcaff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200906:	bf31                	j	ffffffffc0200822 <print_trapframe>
}
ffffffffc0200908:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020090a:	06400593          	li	a1,100
ffffffffc020090e:	00005517          	auipc	a0,0x5
ffffffffc0200912:	b2250513          	addi	a0,a0,-1246 # ffffffffc0205430 <commands+0x4b0>
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
ffffffffc0200934:	d1870713          	addi	a4,a4,-744 # ffffffffc0205648 <commands+0x6c8>
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
ffffffffc0200946:	cee50513          	addi	a0,a0,-786 # ffffffffc0205630 <commands+0x6b0>
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
ffffffffc0200968:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0205490 <commands+0x510>
}
ffffffffc020096c:	6442                	ld	s0,16(sp)
ffffffffc020096e:	60e2                	ld	ra,24(sp)
ffffffffc0200970:	64a2                	ld	s1,8(sp)
ffffffffc0200972:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200974:	f58ff06f          	j	ffffffffc02000cc <cprintf>
ffffffffc0200978:	00005517          	auipc	a0,0x5
ffffffffc020097c:	b3850513          	addi	a0,a0,-1224 # ffffffffc02054b0 <commands+0x530>
ffffffffc0200980:	b7f5                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200982:	00005517          	auipc	a0,0x5
ffffffffc0200986:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02054d0 <commands+0x550>
ffffffffc020098a:	b7cd                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098c:	00005517          	auipc	a0,0x5
ffffffffc0200990:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02054e8 <commands+0x568>
ffffffffc0200994:	bfe1                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200996:	00005517          	auipc	a0,0x5
ffffffffc020099a:	b6250513          	addi	a0,a0,-1182 # ffffffffc02054f8 <commands+0x578>
ffffffffc020099e:	b7f9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	b7850513          	addi	a0,a0,-1160 # ffffffffc0205518 <commands+0x598>
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
ffffffffc02009c2:	b7260613          	addi	a2,a2,-1166 # ffffffffc0205530 <commands+0x5b0>
ffffffffc02009c6:	0b300593          	li	a1,179
ffffffffc02009ca:	00004517          	auipc	a0,0x4
ffffffffc02009ce:	65650513          	addi	a0,a0,1622 # ffffffffc0205020 <commands+0xa0>
ffffffffc02009d2:	ff6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d6:	00005517          	auipc	a0,0x5
ffffffffc02009da:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0205550 <commands+0x5d0>
ffffffffc02009de:	b779                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009e0:	00005517          	auipc	a0,0x5
ffffffffc02009e4:	b8850513          	addi	a0,a0,-1144 # ffffffffc0205568 <commands+0x5e8>
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
ffffffffc0200a02:	b3260613          	addi	a2,a2,-1230 # ffffffffc0205530 <commands+0x5b0>
ffffffffc0200a06:	0bd00593          	li	a1,189
ffffffffc0200a0a:	00004517          	auipc	a0,0x4
ffffffffc0200a0e:	61650513          	addi	a0,a0,1558 # ffffffffc0205020 <commands+0xa0>
ffffffffc0200a12:	fb6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a16:	00005517          	auipc	a0,0x5
ffffffffc0200a1a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0205580 <commands+0x600>
ffffffffc0200a1e:	b7b9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	b8050513          	addi	a0,a0,-1152 # ffffffffc02055a0 <commands+0x620>
ffffffffc0200a28:	b791                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02055c0 <commands+0x640>
ffffffffc0200a32:	bf2d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	bac50513          	addi	a0,a0,-1108 # ffffffffc02055e0 <commands+0x660>
ffffffffc0200a3c:	bf05                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3e:	00005517          	auipc	a0,0x5
ffffffffc0200a42:	bc250513          	addi	a0,a0,-1086 # ffffffffc0205600 <commands+0x680>
ffffffffc0200a46:	b71d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	bd050513          	addi	a0,a0,-1072 # ffffffffc0205618 <commands+0x698>
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
ffffffffc0200a6c:	ac860613          	addi	a2,a2,-1336 # ffffffffc0205530 <commands+0x5b0>
ffffffffc0200a70:	0d300593          	li	a1,211
ffffffffc0200a74:	00004517          	auipc	a0,0x4
ffffffffc0200a78:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205020 <commands+0xa0>
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
ffffffffc0200a98:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0205530 <commands+0x5b0>
ffffffffc0200a9c:	0da00593          	li	a1,218
ffffffffc0200aa0:	00004517          	auipc	a0,0x4
ffffffffc0200aa4:	58050513          	addi	a0,a0,1408 # ffffffffc0205020 <commands+0xa0>
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
ffffffffc0200b78:	b1468693          	addi	a3,a3,-1260 # ffffffffc0205688 <commands+0x708>
ffffffffc0200b7c:	00005617          	auipc	a2,0x5
ffffffffc0200b80:	b2c60613          	addi	a2,a2,-1236 # ffffffffc02056a8 <commands+0x728>
ffffffffc0200b84:	07e00593          	li	a1,126
ffffffffc0200b88:	00005517          	auipc	a0,0x5
ffffffffc0200b8c:	b3850513          	addi	a0,a0,-1224 # ffffffffc02056c0 <commands+0x740>
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
ffffffffc0200ba0:	6a5000ef          	jal	ra,ffffffffc0201a44 <kmalloc>
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
ffffffffc0200bbc:	9b87a783          	lw	a5,-1608(a5) # ffffffffc0215570 <swap_init_ok>
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
ffffffffc0200bd0:	79c010ef          	jal	ra,ffffffffc020236c <swap_init_mm>
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
ffffffffc0200bf2:	653000ef          	jal	ra,ffffffffc0201a44 <kmalloc>
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
ffffffffc0200cc0:	a1468693          	addi	a3,a3,-1516 # ffffffffc02056d0 <commands+0x750>
ffffffffc0200cc4:	00005617          	auipc	a2,0x5
ffffffffc0200cc8:	9e460613          	addi	a2,a2,-1564 # ffffffffc02056a8 <commands+0x728>
ffffffffc0200ccc:	08500593          	li	a1,133
ffffffffc0200cd0:	00005517          	auipc	a0,0x5
ffffffffc0200cd4:	9f050513          	addi	a0,a0,-1552 # ffffffffc02056c0 <commands+0x740>
ffffffffc0200cd8:	cf0ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200cdc:	00005697          	auipc	a3,0x5
ffffffffc0200ce0:	a3468693          	addi	a3,a3,-1484 # ffffffffc0205710 <commands+0x790>
ffffffffc0200ce4:	00005617          	auipc	a2,0x5
ffffffffc0200ce8:	9c460613          	addi	a2,a2,-1596 # ffffffffc02056a8 <commands+0x728>
ffffffffc0200cec:	07d00593          	li	a1,125
ffffffffc0200cf0:	00005517          	auipc	a0,0x5
ffffffffc0200cf4:	9d050513          	addi	a0,a0,-1584 # ffffffffc02056c0 <commands+0x740>
ffffffffc0200cf8:	cd0ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200cfc:	00005697          	auipc	a3,0x5
ffffffffc0200d00:	9f468693          	addi	a3,a3,-1548 # ffffffffc02056f0 <commands+0x770>
ffffffffc0200d04:	00005617          	auipc	a2,0x5
ffffffffc0200d08:	9a460613          	addi	a2,a2,-1628 # ffffffffc02056a8 <commands+0x728>
ffffffffc0200d0c:	07c00593          	li	a1,124
ffffffffc0200d10:	00005517          	auipc	a0,0x5
ffffffffc0200d14:	9b050513          	addi	a0,a0,-1616 # ffffffffc02056c0 <commands+0x740>
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
ffffffffc0200d34:	5c1000ef          	jal	ra,ffffffffc0201af4 <kfree>
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
ffffffffc0200d46:	5af0006f          	j	ffffffffc0201af4 <kfree>

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
ffffffffc0200d5e:	4e7000ef          	jal	ra,ffffffffc0201a44 <kmalloc>
    if (mm != NULL) {
ffffffffc0200d62:	5a050d63          	beqz	a0,ffffffffc020131c <vmm_init+0x5d2>
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
ffffffffc0200d76:	00014797          	auipc	a5,0x14
ffffffffc0200d7a:	7fa7a783          	lw	a5,2042(a5) # ffffffffc0215570 <swap_init_ok>
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
ffffffffc0200da2:	4a3000ef          	jal	ra,ffffffffc0201a44 <kmalloc>
ffffffffc0200da6:	85aa                	mv	a1,a0
ffffffffc0200da8:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200dac:	f165                	bnez	a0,ffffffffc0200d8c <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc0200dae:	00005697          	auipc	a3,0x5
ffffffffc0200db2:	bda68693          	addi	a3,a3,-1062 # ffffffffc0205988 <commands+0xa08>
ffffffffc0200db6:	00005617          	auipc	a2,0x5
ffffffffc0200dba:	8f260613          	addi	a2,a2,-1806 # ffffffffc02056a8 <commands+0x728>
ffffffffc0200dbe:	0c900593          	li	a1,201
ffffffffc0200dc2:	00005517          	auipc	a0,0x5
ffffffffc0200dc6:	8fe50513          	addi	a0,a0,-1794 # ffffffffc02056c0 <commands+0x740>
ffffffffc0200dca:	bfeff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200dce:	59e010ef          	jal	ra,ffffffffc020236c <swap_init_mm>
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
ffffffffc0200df6:	44f000ef          	jal	ra,ffffffffc0201a44 <kmalloc>
ffffffffc0200dfa:	85aa                	mv	a1,a0
ffffffffc0200dfc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200e00:	fd79                	bnez	a0,ffffffffc0200dde <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0200e02:	00005697          	auipc	a3,0x5
ffffffffc0200e06:	b8668693          	addi	a3,a3,-1146 # ffffffffc0205988 <commands+0xa08>
ffffffffc0200e0a:	00005617          	auipc	a2,0x5
ffffffffc0200e0e:	89e60613          	addi	a2,a2,-1890 # ffffffffc02056a8 <commands+0x728>
ffffffffc0200e12:	0cf00593          	li	a1,207
ffffffffc0200e16:	00005517          	auipc	a0,0x5
ffffffffc0200e1a:	8aa50513          	addi	a0,a0,-1878 # ffffffffc02056c0 <commands+0x740>
ffffffffc0200e1e:	baaff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return listelm->next;
ffffffffc0200e22:	649c                	ld	a5,8(s1)
ffffffffc0200e24:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200e26:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200e2a:	32f48d63          	beq	s1,a5,ffffffffc0201164 <vmm_init+0x41a>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200e2e:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200e32:	ffe70613          	addi	a2,a4,-2
ffffffffc0200e36:	2cd61763          	bne	a2,a3,ffffffffc0201104 <vmm_init+0x3ba>
ffffffffc0200e3a:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200e3e:	2ce69363          	bne	a3,a4,ffffffffc0201104 <vmm_init+0x3ba>
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
ffffffffc0200e5c:	36050463          	beqz	a0,ffffffffc02011c4 <vmm_init+0x47a>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200e60:	00140593          	addi	a1,s0,1
ffffffffc0200e64:	8526                	mv	a0,s1
ffffffffc0200e66:	da7ff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
ffffffffc0200e6a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0200e6c:	36050c63          	beqz	a0,ffffffffc02011e4 <vmm_init+0x49a>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200e70:	85d2                	mv	a1,s4
ffffffffc0200e72:	8526                	mv	a0,s1
ffffffffc0200e74:	d99ff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
        assert(vma3 == NULL);
ffffffffc0200e78:	38051663          	bnez	a0,ffffffffc0201204 <vmm_init+0x4ba>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200e7c:	00340593          	addi	a1,s0,3
ffffffffc0200e80:	8526                	mv	a0,s1
ffffffffc0200e82:	d8bff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
        assert(vma4 == NULL);
ffffffffc0200e86:	2e051f63          	bnez	a0,ffffffffc0201184 <vmm_init+0x43a>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200e8a:	00440593          	addi	a1,s0,4
ffffffffc0200e8e:	8526                	mv	a0,s1
ffffffffc0200e90:	d7dff0ef          	jal	ra,ffffffffc0200c0c <find_vma>
        assert(vma5 == NULL);
ffffffffc0200e94:	30051863          	bnez	a0,ffffffffc02011a4 <vmm_init+0x45a>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200e98:	00893783          	ld	a5,8(s2)
ffffffffc0200e9c:	28879463          	bne	a5,s0,ffffffffc0201124 <vmm_init+0x3da>
ffffffffc0200ea0:	01093783          	ld	a5,16(s2)
ffffffffc0200ea4:	29479063          	bne	a5,s4,ffffffffc0201124 <vmm_init+0x3da>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200ea8:	0089b783          	ld	a5,8(s3)
ffffffffc0200eac:	28879c63          	bne	a5,s0,ffffffffc0201144 <vmm_init+0x3fa>
ffffffffc0200eb0:	0109b783          	ld	a5,16(s3)
ffffffffc0200eb4:	29479863          	bne	a5,s4,ffffffffc0201144 <vmm_init+0x3fa>
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
ffffffffc0200eda:	95a50513          	addi	a0,a0,-1702 # ffffffffc0205830 <commands+0x8b0>
ffffffffc0200ede:	9eeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200ee2:	00005697          	auipc	a3,0x5
ffffffffc0200ee6:	97668693          	addi	a3,a3,-1674 # ffffffffc0205858 <commands+0x8d8>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	7be60613          	addi	a2,a2,1982 # ffffffffc02056a8 <commands+0x728>
ffffffffc0200ef2:	0f100593          	li	a1,241
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	7ca50513          	addi	a0,a0,1994 # ffffffffc02056c0 <commands+0x740>
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
ffffffffc0200f14:	3e1000ef          	jal	ra,ffffffffc0201af4 <kfree>
    return listelm->next;
ffffffffc0200f18:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200f1a:	fea498e3          	bne	s1,a0,ffffffffc0200f0a <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0200f1e:	8526                	mv	a0,s1
ffffffffc0200f20:	3d5000ef          	jal	ra,ffffffffc0201af4 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200f24:	00005517          	auipc	a0,0x5
ffffffffc0200f28:	94c50513          	addi	a0,a0,-1716 # ffffffffc0205870 <commands+0x8f0>
ffffffffc0200f2c:	9a0ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200f30:	1c4020ef          	jal	ra,ffffffffc02030f4 <nr_free_pages>
ffffffffc0200f34:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f36:	03000513          	li	a0,48
ffffffffc0200f3a:	30b000ef          	jal	ra,ffffffffc0201a44 <kmalloc>
ffffffffc0200f3e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200f40:	2e050263          	beqz	a0,ffffffffc0201224 <vmm_init+0x4da>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200f44:	00014797          	auipc	a5,0x14
ffffffffc0200f48:	62c7a783          	lw	a5,1580(a5) # ffffffffc0215570 <swap_init_ok>
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
ffffffffc0200f5c:	1a079163          	bnez	a5,ffffffffc02010fe <vmm_init+0x3b4>
        else mm->sm_priv = NULL;
ffffffffc0200f60:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f64:	00014917          	auipc	s2,0x14
ffffffffc0200f68:	61c93903          	ld	s2,1564(s2) # ffffffffc0215580 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200f6c:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200f70:	00014717          	auipc	a4,0x14
ffffffffc0200f74:	5c873c23          	sd	s0,1496(a4) # ffffffffc0215548 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f78:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200f7c:	38079063          	bnez	a5,ffffffffc02012fc <vmm_init+0x5b2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f80:	03000513          	li	a0,48
ffffffffc0200f84:	2c1000ef          	jal	ra,ffffffffc0201a44 <kmalloc>
ffffffffc0200f88:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0200f8a:	2c050163          	beqz	a0,ffffffffc020124c <vmm_init+0x502>
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
ffffffffc0200fba:	2aa99963          	bne	s3,a0,ffffffffc020126c <vmm_init+0x522>
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
ffffffffc0200fe2:	2a071563          	bnez	a4,ffffffffc020128c <vmm_init+0x542>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fe6:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200fea:	00014a97          	auipc	s5,0x14
ffffffffc0200fee:	59ea8a93          	addi	s5,s5,1438 # ffffffffc0215588 <npage>
ffffffffc0200ff2:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200ff6:	078a                	slli	a5,a5,0x2
ffffffffc0200ff8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200ffa:	2ac7f963          	bgeu	a5,a2,ffffffffc02012ac <vmm_init+0x562>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ffe:	00006a17          	auipc	s4,0x6
ffffffffc0201002:	d72a3a03          	ld	s4,-654(s4) # ffffffffc0206d70 <nbase>
ffffffffc0201006:	41478733          	sub	a4,a5,s4
ffffffffc020100a:	00371793          	slli	a5,a4,0x3
ffffffffc020100e:	97ba                	add	a5,a5,a4
ffffffffc0201010:	078e                	slli	a5,a5,0x3
    return page - pages + nbase;
ffffffffc0201012:	00006717          	auipc	a4,0x6
ffffffffc0201016:	d5673703          	ld	a4,-682(a4) # ffffffffc0206d68 <error_string+0x38>
ffffffffc020101a:	878d                	srai	a5,a5,0x3
ffffffffc020101c:	02e787b3          	mul	a5,a5,a4
ffffffffc0201020:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0201022:	00c79713          	slli	a4,a5,0xc
ffffffffc0201026:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201028:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020102c:	28c77c63          	bgeu	a4,a2,ffffffffc02012c4 <vmm_init+0x57a>
ffffffffc0201030:	00014997          	auipc	s3,0x14
ffffffffc0201034:	5709b983          	ld	s3,1392(s3) # ffffffffc02155a0 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201038:	4581                	li	a1,0
ffffffffc020103a:	854a                	mv	a0,s2
ffffffffc020103c:	99b6                	add	s3,s3,a3
ffffffffc020103e:	340020ef          	jal	ra,ffffffffc020337e <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201042:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201046:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020104a:	078a                	slli	a5,a5,0x2
ffffffffc020104c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020104e:	24e7ff63          	bgeu	a5,a4,ffffffffc02012ac <vmm_init+0x562>
    return &pages[PPN(pa) - nbase];
ffffffffc0201052:	414787b3          	sub	a5,a5,s4
ffffffffc0201056:	00014997          	auipc	s3,0x14
ffffffffc020105a:	53a98993          	addi	s3,s3,1338 # ffffffffc0215590 <pages>
ffffffffc020105e:	00379713          	slli	a4,a5,0x3
ffffffffc0201062:	0009b503          	ld	a0,0(s3)
ffffffffc0201066:	97ba                	add	a5,a5,a4
ffffffffc0201068:	078e                	slli	a5,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020106a:	953e                	add	a0,a0,a5
ffffffffc020106c:	4585                	li	a1,1
ffffffffc020106e:	046020ef          	jal	ra,ffffffffc02030b4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201072:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201076:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020107a:	078a                	slli	a5,a5,0x2
ffffffffc020107c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020107e:	22e7f763          	bgeu	a5,a4,ffffffffc02012ac <vmm_init+0x562>
    return &pages[PPN(pa) - nbase];
ffffffffc0201082:	414787b3          	sub	a5,a5,s4
ffffffffc0201086:	0009b503          	ld	a0,0(s3)
ffffffffc020108a:	00379713          	slli	a4,a5,0x3
ffffffffc020108e:	97ba                	add	a5,a5,a4
ffffffffc0201090:	078e                	slli	a5,a5,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201092:	4585                	li	a1,1
ffffffffc0201094:	953e                	add	a0,a0,a5
ffffffffc0201096:	01e020ef          	jal	ra,ffffffffc02030b4 <free_pages>
    pgdir[0] = 0;
ffffffffc020109a:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc020109e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02010a2:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02010a4:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02010a8:	00a40c63          	beq	s0,a0,ffffffffc02010c0 <vmm_init+0x376>
    __list_del(listelm->prev, listelm->next);
ffffffffc02010ac:	6118                	ld	a4,0(a0)
ffffffffc02010ae:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02010b0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02010b2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010b4:	e398                	sd	a4,0(a5)
ffffffffc02010b6:	23f000ef          	jal	ra,ffffffffc0201af4 <kfree>
    return listelm->next;
ffffffffc02010ba:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02010bc:	fea418e3          	bne	s0,a0,ffffffffc02010ac <vmm_init+0x362>
    kfree(mm); //kfree mm
ffffffffc02010c0:	8522                	mv	a0,s0
ffffffffc02010c2:	233000ef          	jal	ra,ffffffffc0201af4 <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc02010c6:	00014797          	auipc	a5,0x14
ffffffffc02010ca:	4807b123          	sd	zero,1154(a5) # ffffffffc0215548 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02010ce:	026020ef          	jal	ra,ffffffffc02030f4 <nr_free_pages>
ffffffffc02010d2:	20a49563          	bne	s1,a0,ffffffffc02012dc <vmm_init+0x592>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02010d6:	00005517          	auipc	a0,0x5
ffffffffc02010da:	87a50513          	addi	a0,a0,-1926 # ffffffffc0205950 <commands+0x9d0>
ffffffffc02010de:	feffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02010e2:	7442                	ld	s0,48(sp)
ffffffffc02010e4:	70e2                	ld	ra,56(sp)
ffffffffc02010e6:	74a2                	ld	s1,40(sp)
ffffffffc02010e8:	7902                	ld	s2,32(sp)
ffffffffc02010ea:	69e2                	ld	s3,24(sp)
ffffffffc02010ec:	6a42                	ld	s4,16(sp)
ffffffffc02010ee:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010f0:	00005517          	auipc	a0,0x5
ffffffffc02010f4:	88050513          	addi	a0,a0,-1920 # ffffffffc0205970 <commands+0x9f0>
}
ffffffffc02010f8:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010fa:	fd3fe06f          	j	ffffffffc02000cc <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02010fe:	26e010ef          	jal	ra,ffffffffc020236c <swap_init_mm>
ffffffffc0201102:	b58d                	j	ffffffffc0200f64 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	64468693          	addi	a3,a3,1604 # ffffffffc0205748 <commands+0x7c8>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	59c60613          	addi	a2,a2,1436 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201114:	0d800593          	li	a1,216
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	5a850513          	addi	a0,a0,1448 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201120:	8a8ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	6ac68693          	addi	a3,a3,1708 # ffffffffc02057d0 <commands+0x850>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	57c60613          	addi	a2,a2,1404 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201134:	0e800593          	li	a1,232
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	58850513          	addi	a0,a0,1416 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201140:	888ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	6bc68693          	addi	a3,a3,1724 # ffffffffc0205800 <commands+0x880>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	55c60613          	addi	a2,a2,1372 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201154:	0e900593          	li	a1,233
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	56850513          	addi	a0,a0,1384 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201160:	868ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	5cc68693          	addi	a3,a3,1484 # ffffffffc0205730 <commands+0x7b0>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	53c60613          	addi	a2,a2,1340 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201174:	0d600593          	li	a1,214
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	54850513          	addi	a0,a0,1352 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201180:	848ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma4 == NULL);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	62c68693          	addi	a3,a3,1580 # ffffffffc02057b0 <commands+0x830>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	51c60613          	addi	a2,a2,1308 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201194:	0e400593          	li	a1,228
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	52850513          	addi	a0,a0,1320 # ffffffffc02056c0 <commands+0x740>
ffffffffc02011a0:	828ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma5 == NULL);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	61c68693          	addi	a3,a3,1564 # ffffffffc02057c0 <commands+0x840>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	4fc60613          	addi	a2,a2,1276 # ffffffffc02056a8 <commands+0x728>
ffffffffc02011b4:	0e600593          	li	a1,230
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	50850513          	addi	a0,a0,1288 # ffffffffc02056c0 <commands+0x740>
ffffffffc02011c0:	808ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1 != NULL);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	5bc68693          	addi	a3,a3,1468 # ffffffffc0205780 <commands+0x800>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	4dc60613          	addi	a2,a2,1244 # ffffffffc02056a8 <commands+0x728>
ffffffffc02011d4:	0de00593          	li	a1,222
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	4e850513          	addi	a0,a0,1256 # ffffffffc02056c0 <commands+0x740>
ffffffffc02011e0:	fe9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2 != NULL);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	5ac68693          	addi	a3,a3,1452 # ffffffffc0205790 <commands+0x810>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	4bc60613          	addi	a2,a2,1212 # ffffffffc02056a8 <commands+0x728>
ffffffffc02011f4:	0e000593          	li	a1,224
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	4c850513          	addi	a0,a0,1224 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201200:	fc9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma3 == NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	59c68693          	addi	a3,a3,1436 # ffffffffc02057a0 <commands+0x820>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	49c60613          	addi	a2,a2,1180 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201214:	0e200593          	li	a1,226
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	4a850513          	addi	a0,a0,1192 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201220:	fa9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	77468693          	addi	a3,a3,1908 # ffffffffc0205998 <commands+0xa18>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	47c60613          	addi	a2,a2,1148 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201234:	10100593          	li	a1,257
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	48850513          	addi	a0,a0,1160 # ffffffffc02056c0 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201240:	00014797          	auipc	a5,0x14
ffffffffc0201244:	3007b423          	sd	zero,776(a5) # ffffffffc0215548 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0201248:	f81fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(vma != NULL);
ffffffffc020124c:	00004697          	auipc	a3,0x4
ffffffffc0201250:	73c68693          	addi	a3,a3,1852 # ffffffffc0205988 <commands+0xa08>
ffffffffc0201254:	00004617          	auipc	a2,0x4
ffffffffc0201258:	45460613          	addi	a2,a2,1108 # ffffffffc02056a8 <commands+0x728>
ffffffffc020125c:	10800593          	li	a1,264
ffffffffc0201260:	00004517          	auipc	a0,0x4
ffffffffc0201264:	46050513          	addi	a0,a0,1120 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201268:	f61fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020126c:	00004697          	auipc	a3,0x4
ffffffffc0201270:	63468693          	addi	a3,a3,1588 # ffffffffc02058a0 <commands+0x920>
ffffffffc0201274:	00004617          	auipc	a2,0x4
ffffffffc0201278:	43460613          	addi	a2,a2,1076 # ffffffffc02056a8 <commands+0x728>
ffffffffc020127c:	10d00593          	li	a1,269
ffffffffc0201280:	00004517          	auipc	a0,0x4
ffffffffc0201284:	44050513          	addi	a0,a0,1088 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201288:	f41fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(sum == 0);
ffffffffc020128c:	00004697          	auipc	a3,0x4
ffffffffc0201290:	63468693          	addi	a3,a3,1588 # ffffffffc02058c0 <commands+0x940>
ffffffffc0201294:	00004617          	auipc	a2,0x4
ffffffffc0201298:	41460613          	addi	a2,a2,1044 # ffffffffc02056a8 <commands+0x728>
ffffffffc020129c:	11700593          	li	a1,279
ffffffffc02012a0:	00004517          	auipc	a0,0x4
ffffffffc02012a4:	42050513          	addi	a0,a0,1056 # ffffffffc02056c0 <commands+0x740>
ffffffffc02012a8:	f21fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	62460613          	addi	a2,a2,1572 # ffffffffc02058d0 <commands+0x950>
ffffffffc02012b4:	06200593          	li	a1,98
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	63850513          	addi	a0,a0,1592 # ffffffffc02058f0 <commands+0x970>
ffffffffc02012c0:	f09fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc02012c4:	00004617          	auipc	a2,0x4
ffffffffc02012c8:	63c60613          	addi	a2,a2,1596 # ffffffffc0205900 <commands+0x980>
ffffffffc02012cc:	06900593          	li	a1,105
ffffffffc02012d0:	00004517          	auipc	a0,0x4
ffffffffc02012d4:	62050513          	addi	a0,a0,1568 # ffffffffc02058f0 <commands+0x970>
ffffffffc02012d8:	ef1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02012dc:	00004697          	auipc	a3,0x4
ffffffffc02012e0:	64c68693          	addi	a3,a3,1612 # ffffffffc0205928 <commands+0x9a8>
ffffffffc02012e4:	00004617          	auipc	a2,0x4
ffffffffc02012e8:	3c460613          	addi	a2,a2,964 # ffffffffc02056a8 <commands+0x728>
ffffffffc02012ec:	12400593          	li	a1,292
ffffffffc02012f0:	00004517          	auipc	a0,0x4
ffffffffc02012f4:	3d050513          	addi	a0,a0,976 # ffffffffc02056c0 <commands+0x740>
ffffffffc02012f8:	ed1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02012fc:	00004697          	auipc	a3,0x4
ffffffffc0201300:	59468693          	addi	a3,a3,1428 # ffffffffc0205890 <commands+0x910>
ffffffffc0201304:	00004617          	auipc	a2,0x4
ffffffffc0201308:	3a460613          	addi	a2,a2,932 # ffffffffc02056a8 <commands+0x728>
ffffffffc020130c:	10500593          	li	a1,261
ffffffffc0201310:	00004517          	auipc	a0,0x4
ffffffffc0201314:	3b050513          	addi	a0,a0,944 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201318:	eb1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(mm != NULL);
ffffffffc020131c:	00004697          	auipc	a3,0x4
ffffffffc0201320:	69468693          	addi	a3,a3,1684 # ffffffffc02059b0 <commands+0xa30>
ffffffffc0201324:	00004617          	auipc	a2,0x4
ffffffffc0201328:	38460613          	addi	a2,a2,900 # ffffffffc02056a8 <commands+0x728>
ffffffffc020132c:	0c200593          	li	a1,194
ffffffffc0201330:	00004517          	auipc	a0,0x4
ffffffffc0201334:	39050513          	addi	a0,a0,912 # ffffffffc02056c0 <commands+0x740>
ffffffffc0201338:	e91fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020133c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020133c:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020133e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0201340:	f022                	sd	s0,32(sp)
ffffffffc0201342:	ec26                	sd	s1,24(sp)
ffffffffc0201344:	f406                	sd	ra,40(sp)
ffffffffc0201346:	e84a                	sd	s2,16(sp)
ffffffffc0201348:	8432                	mv	s0,a2
ffffffffc020134a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020134c:	8c1ff0ef          	jal	ra,ffffffffc0200c0c <find_vma>

    pgfault_num++;
ffffffffc0201350:	00014797          	auipc	a5,0x14
ffffffffc0201354:	2007a783          	lw	a5,512(a5) # ffffffffc0215550 <pgfault_num>
ffffffffc0201358:	2785                	addiw	a5,a5,1
ffffffffc020135a:	00014717          	auipc	a4,0x14
ffffffffc020135e:	1ef72b23          	sw	a5,502(a4) # ffffffffc0215550 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201362:	c541                	beqz	a0,ffffffffc02013ea <do_pgfault+0xae>
ffffffffc0201364:	651c                	ld	a5,8(a0)
ffffffffc0201366:	08f46263          	bltu	s0,a5,ffffffffc02013ea <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020136a:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020136c:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020136e:	8b89                	andi	a5,a5,2
ffffffffc0201370:	ebb9                	bnez	a5,ffffffffc02013c6 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201372:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201374:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201376:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201378:	4605                	li	a2,1
ffffffffc020137a:	85a2                	mv	a1,s0
ffffffffc020137c:	5b3010ef          	jal	ra,ffffffffc020312e <get_pte>
ffffffffc0201380:	c551                	beqz	a0,ffffffffc020140c <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201382:	610c                	ld	a1,0(a0)
ffffffffc0201384:	c1b9                	beqz	a1,ffffffffc02013ca <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201386:	00014797          	auipc	a5,0x14
ffffffffc020138a:	1ea7a783          	lw	a5,490(a5) # ffffffffc0215570 <swap_init_ok>
ffffffffc020138e:	c7bd                	beqz	a5,ffffffffc02013fc <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0201390:	85a2                	mv	a1,s0
ffffffffc0201392:	0030                	addi	a2,sp,8
ffffffffc0201394:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201396:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0201398:	100010ef          	jal	ra,ffffffffc0202498 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020139c:	65a2                	ld	a1,8(sp)
ffffffffc020139e:	6c88                	ld	a0,24(s1)
ffffffffc02013a0:	86ca                	mv	a3,s2
ffffffffc02013a2:	8622                	mv	a2,s0
ffffffffc02013a4:	07c020ef          	jal	ra,ffffffffc0203420 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc02013a8:	6622                	ld	a2,8(sp)
ffffffffc02013aa:	4685                	li	a3,1
ffffffffc02013ac:	85a2                	mv	a1,s0
ffffffffc02013ae:	8526                	mv	a0,s1
ffffffffc02013b0:	7c9000ef          	jal	ra,ffffffffc0202378 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02013b4:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02013b6:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc02013b8:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc02013ba:	70a2                	ld	ra,40(sp)
ffffffffc02013bc:	7402                	ld	s0,32(sp)
ffffffffc02013be:	64e2                	ld	s1,24(sp)
ffffffffc02013c0:	6942                	ld	s2,16(sp)
ffffffffc02013c2:	6145                	addi	sp,sp,48
ffffffffc02013c4:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02013c6:	495d                	li	s2,23
ffffffffc02013c8:	b76d                	j	ffffffffc0201372 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02013ca:	6c88                	ld	a0,24(s1)
ffffffffc02013cc:	864a                	mv	a2,s2
ffffffffc02013ce:	85a2                	mv	a1,s0
ffffffffc02013d0:	565020ef          	jal	ra,ffffffffc0204134 <pgdir_alloc_page>
ffffffffc02013d4:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02013d6:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02013d8:	f3ed                	bnez	a5,ffffffffc02013ba <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02013da:	00004517          	auipc	a0,0x4
ffffffffc02013de:	63650513          	addi	a0,a0,1590 # ffffffffc0205a10 <commands+0xa90>
ffffffffc02013e2:	cebfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013e6:	5571                	li	a0,-4
            goto failed;
ffffffffc02013e8:	bfc9                	j	ffffffffc02013ba <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02013ea:	85a2                	mv	a1,s0
ffffffffc02013ec:	00004517          	auipc	a0,0x4
ffffffffc02013f0:	5d450513          	addi	a0,a0,1492 # ffffffffc02059c0 <commands+0xa40>
ffffffffc02013f4:	cd9fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02013f8:	5575                	li	a0,-3
        goto failed;
ffffffffc02013fa:	b7c1                	j	ffffffffc02013ba <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02013fc:	00004517          	auipc	a0,0x4
ffffffffc0201400:	63c50513          	addi	a0,a0,1596 # ffffffffc0205a38 <commands+0xab8>
ffffffffc0201404:	cc9fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201408:	5571                	li	a0,-4
            goto failed;
ffffffffc020140a:	bf45                	j	ffffffffc02013ba <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020140c:	00004517          	auipc	a0,0x4
ffffffffc0201410:	5e450513          	addi	a0,a0,1508 # ffffffffc02059f0 <commands+0xa70>
ffffffffc0201414:	cb9fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201418:	5571                	li	a0,-4
        goto failed;
ffffffffc020141a:	b745                	j	ffffffffc02013ba <do_pgfault+0x7e>

ffffffffc020141c <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020141c:	00010797          	auipc	a5,0x10
ffffffffc0201420:	0e478793          	addi	a5,a5,228 # ffffffffc0211500 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201424:	f51c                	sd	a5,40(a0)
ffffffffc0201426:	e79c                	sd	a5,8(a5)
ffffffffc0201428:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020142a:	4501                	li	a0,0
ffffffffc020142c:	8082                	ret

ffffffffc020142e <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020142e:	4501                	li	a0,0
ffffffffc0201430:	8082                	ret

ffffffffc0201432 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201432:	4501                	li	a0,0
ffffffffc0201434:	8082                	ret

ffffffffc0201436 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201436:	4501                	li	a0,0
ffffffffc0201438:	8082                	ret

ffffffffc020143a <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020143a:	711d                	addi	sp,sp,-96
ffffffffc020143c:	fc4e                	sd	s3,56(sp)
ffffffffc020143e:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201440:	00004517          	auipc	a0,0x4
ffffffffc0201444:	62050513          	addi	a0,a0,1568 # ffffffffc0205a60 <commands+0xae0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201448:	698d                	lui	s3,0x3
ffffffffc020144a:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020144c:	e0ca                	sd	s2,64(sp)
ffffffffc020144e:	ec86                	sd	ra,88(sp)
ffffffffc0201450:	e8a2                	sd	s0,80(sp)
ffffffffc0201452:	e4a6                	sd	s1,72(sp)
ffffffffc0201454:	f456                	sd	s5,40(sp)
ffffffffc0201456:	f05a                	sd	s6,32(sp)
ffffffffc0201458:	ec5e                	sd	s7,24(sp)
ffffffffc020145a:	e862                	sd	s8,16(sp)
ffffffffc020145c:	e466                	sd	s9,8(sp)
ffffffffc020145e:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201460:	c6dfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201464:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0201468:	00014917          	auipc	s2,0x14
ffffffffc020146c:	0e892903          	lw	s2,232(s2) # ffffffffc0215550 <pgfault_num>
ffffffffc0201470:	4791                	li	a5,4
ffffffffc0201472:	14f91e63          	bne	s2,a5,ffffffffc02015ce <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201476:	00004517          	auipc	a0,0x4
ffffffffc020147a:	63a50513          	addi	a0,a0,1594 # ffffffffc0205ab0 <commands+0xb30>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020147e:	6a85                	lui	s5,0x1
ffffffffc0201480:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201482:	c4bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201486:	00014417          	auipc	s0,0x14
ffffffffc020148a:	0ca40413          	addi	s0,s0,202 # ffffffffc0215550 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020148e:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201492:	4004                	lw	s1,0(s0)
ffffffffc0201494:	2481                	sext.w	s1,s1
ffffffffc0201496:	2b249c63          	bne	s1,s2,ffffffffc020174e <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020149a:	00004517          	auipc	a0,0x4
ffffffffc020149e:	63e50513          	addi	a0,a0,1598 # ffffffffc0205ad8 <commands+0xb58>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02014a2:	6b91                	lui	s7,0x4
ffffffffc02014a4:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02014a6:	c27fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02014aa:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02014ae:	00042903          	lw	s2,0(s0)
ffffffffc02014b2:	2901                	sext.w	s2,s2
ffffffffc02014b4:	26991d63          	bne	s2,s1,ffffffffc020172e <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014b8:	00004517          	auipc	a0,0x4
ffffffffc02014bc:	64850513          	addi	a0,a0,1608 # ffffffffc0205b00 <commands+0xb80>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014c0:	6c89                	lui	s9,0x2
ffffffffc02014c2:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014c4:	c09fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014c8:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02014cc:	401c                	lw	a5,0(s0)
ffffffffc02014ce:	2781                	sext.w	a5,a5
ffffffffc02014d0:	23279f63          	bne	a5,s2,ffffffffc020170e <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02014d4:	00004517          	auipc	a0,0x4
ffffffffc02014d8:	65450513          	addi	a0,a0,1620 # ffffffffc0205b28 <commands+0xba8>
ffffffffc02014dc:	bf1fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02014e0:	6795                	lui	a5,0x5
ffffffffc02014e2:	4739                	li	a4,14
ffffffffc02014e4:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02014e8:	4004                	lw	s1,0(s0)
ffffffffc02014ea:	4795                	li	a5,5
ffffffffc02014ec:	2481                	sext.w	s1,s1
ffffffffc02014ee:	20f49063          	bne	s1,a5,ffffffffc02016ee <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014f2:	00004517          	auipc	a0,0x4
ffffffffc02014f6:	60e50513          	addi	a0,a0,1550 # ffffffffc0205b00 <commands+0xb80>
ffffffffc02014fa:	bd3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014fe:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201502:	401c                	lw	a5,0(s0)
ffffffffc0201504:	2781                	sext.w	a5,a5
ffffffffc0201506:	1c979463          	bne	a5,s1,ffffffffc02016ce <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020150a:	00004517          	auipc	a0,0x4
ffffffffc020150e:	5a650513          	addi	a0,a0,1446 # ffffffffc0205ab0 <commands+0xb30>
ffffffffc0201512:	bbbfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201516:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020151a:	401c                	lw	a5,0(s0)
ffffffffc020151c:	4719                	li	a4,6
ffffffffc020151e:	2781                	sext.w	a5,a5
ffffffffc0201520:	18e79763          	bne	a5,a4,ffffffffc02016ae <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201524:	00004517          	auipc	a0,0x4
ffffffffc0201528:	5dc50513          	addi	a0,a0,1500 # ffffffffc0205b00 <commands+0xb80>
ffffffffc020152c:	ba1fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201530:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201534:	401c                	lw	a5,0(s0)
ffffffffc0201536:	471d                	li	a4,7
ffffffffc0201538:	2781                	sext.w	a5,a5
ffffffffc020153a:	14e79a63          	bne	a5,a4,ffffffffc020168e <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020153e:	00004517          	auipc	a0,0x4
ffffffffc0201542:	52250513          	addi	a0,a0,1314 # ffffffffc0205a60 <commands+0xae0>
ffffffffc0201546:	b87fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020154a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020154e:	401c                	lw	a5,0(s0)
ffffffffc0201550:	4721                	li	a4,8
ffffffffc0201552:	2781                	sext.w	a5,a5
ffffffffc0201554:	10e79d63          	bne	a5,a4,ffffffffc020166e <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201558:	00004517          	auipc	a0,0x4
ffffffffc020155c:	58050513          	addi	a0,a0,1408 # ffffffffc0205ad8 <commands+0xb58>
ffffffffc0201560:	b6dfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201564:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201568:	401c                	lw	a5,0(s0)
ffffffffc020156a:	4725                	li	a4,9
ffffffffc020156c:	2781                	sext.w	a5,a5
ffffffffc020156e:	0ee79063          	bne	a5,a4,ffffffffc020164e <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201572:	00004517          	auipc	a0,0x4
ffffffffc0201576:	5b650513          	addi	a0,a0,1462 # ffffffffc0205b28 <commands+0xba8>
ffffffffc020157a:	b53fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020157e:	6795                	lui	a5,0x5
ffffffffc0201580:	4739                	li	a4,14
ffffffffc0201582:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201586:	4004                	lw	s1,0(s0)
ffffffffc0201588:	47a9                	li	a5,10
ffffffffc020158a:	2481                	sext.w	s1,s1
ffffffffc020158c:	0af49163          	bne	s1,a5,ffffffffc020162e <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201590:	00004517          	auipc	a0,0x4
ffffffffc0201594:	52050513          	addi	a0,a0,1312 # ffffffffc0205ab0 <commands+0xb30>
ffffffffc0201598:	b35fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020159c:	6785                	lui	a5,0x1
ffffffffc020159e:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02015a2:	06979663          	bne	a5,s1,ffffffffc020160e <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc02015a6:	401c                	lw	a5,0(s0)
ffffffffc02015a8:	472d                	li	a4,11
ffffffffc02015aa:	2781                	sext.w	a5,a5
ffffffffc02015ac:	04e79163          	bne	a5,a4,ffffffffc02015ee <_fifo_check_swap+0x1b4>
}
ffffffffc02015b0:	60e6                	ld	ra,88(sp)
ffffffffc02015b2:	6446                	ld	s0,80(sp)
ffffffffc02015b4:	64a6                	ld	s1,72(sp)
ffffffffc02015b6:	6906                	ld	s2,64(sp)
ffffffffc02015b8:	79e2                	ld	s3,56(sp)
ffffffffc02015ba:	7a42                	ld	s4,48(sp)
ffffffffc02015bc:	7aa2                	ld	s5,40(sp)
ffffffffc02015be:	7b02                	ld	s6,32(sp)
ffffffffc02015c0:	6be2                	ld	s7,24(sp)
ffffffffc02015c2:	6c42                	ld	s8,16(sp)
ffffffffc02015c4:	6ca2                	ld	s9,8(sp)
ffffffffc02015c6:	6d02                	ld	s10,0(sp)
ffffffffc02015c8:	4501                	li	a0,0
ffffffffc02015ca:	6125                	addi	sp,sp,96
ffffffffc02015cc:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02015ce:	00004697          	auipc	a3,0x4
ffffffffc02015d2:	4ba68693          	addi	a3,a3,1210 # ffffffffc0205a88 <commands+0xb08>
ffffffffc02015d6:	00004617          	auipc	a2,0x4
ffffffffc02015da:	0d260613          	addi	a2,a2,210 # ffffffffc02056a8 <commands+0x728>
ffffffffc02015de:	05100593          	li	a1,81
ffffffffc02015e2:	00004517          	auipc	a0,0x4
ffffffffc02015e6:	4b650513          	addi	a0,a0,1206 # ffffffffc0205a98 <commands+0xb18>
ffffffffc02015ea:	bdffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==11);
ffffffffc02015ee:	00004697          	auipc	a3,0x4
ffffffffc02015f2:	5ea68693          	addi	a3,a3,1514 # ffffffffc0205bd8 <commands+0xc58>
ffffffffc02015f6:	00004617          	auipc	a2,0x4
ffffffffc02015fa:	0b260613          	addi	a2,a2,178 # ffffffffc02056a8 <commands+0x728>
ffffffffc02015fe:	07300593          	li	a1,115
ffffffffc0201602:	00004517          	auipc	a0,0x4
ffffffffc0201606:	49650513          	addi	a0,a0,1174 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020160a:	bbffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020160e:	00004697          	auipc	a3,0x4
ffffffffc0201612:	5a268693          	addi	a3,a3,1442 # ffffffffc0205bb0 <commands+0xc30>
ffffffffc0201616:	00004617          	auipc	a2,0x4
ffffffffc020161a:	09260613          	addi	a2,a2,146 # ffffffffc02056a8 <commands+0x728>
ffffffffc020161e:	07100593          	li	a1,113
ffffffffc0201622:	00004517          	auipc	a0,0x4
ffffffffc0201626:	47650513          	addi	a0,a0,1142 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020162a:	b9ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==10);
ffffffffc020162e:	00004697          	auipc	a3,0x4
ffffffffc0201632:	57268693          	addi	a3,a3,1394 # ffffffffc0205ba0 <commands+0xc20>
ffffffffc0201636:	00004617          	auipc	a2,0x4
ffffffffc020163a:	07260613          	addi	a2,a2,114 # ffffffffc02056a8 <commands+0x728>
ffffffffc020163e:	06f00593          	li	a1,111
ffffffffc0201642:	00004517          	auipc	a0,0x4
ffffffffc0201646:	45650513          	addi	a0,a0,1110 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020164a:	b7ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==9);
ffffffffc020164e:	00004697          	auipc	a3,0x4
ffffffffc0201652:	54268693          	addi	a3,a3,1346 # ffffffffc0205b90 <commands+0xc10>
ffffffffc0201656:	00004617          	auipc	a2,0x4
ffffffffc020165a:	05260613          	addi	a2,a2,82 # ffffffffc02056a8 <commands+0x728>
ffffffffc020165e:	06c00593          	li	a1,108
ffffffffc0201662:	00004517          	auipc	a0,0x4
ffffffffc0201666:	43650513          	addi	a0,a0,1078 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020166a:	b5ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==8);
ffffffffc020166e:	00004697          	auipc	a3,0x4
ffffffffc0201672:	51268693          	addi	a3,a3,1298 # ffffffffc0205b80 <commands+0xc00>
ffffffffc0201676:	00004617          	auipc	a2,0x4
ffffffffc020167a:	03260613          	addi	a2,a2,50 # ffffffffc02056a8 <commands+0x728>
ffffffffc020167e:	06900593          	li	a1,105
ffffffffc0201682:	00004517          	auipc	a0,0x4
ffffffffc0201686:	41650513          	addi	a0,a0,1046 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020168a:	b3ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==7);
ffffffffc020168e:	00004697          	auipc	a3,0x4
ffffffffc0201692:	4e268693          	addi	a3,a3,1250 # ffffffffc0205b70 <commands+0xbf0>
ffffffffc0201696:	00004617          	auipc	a2,0x4
ffffffffc020169a:	01260613          	addi	a2,a2,18 # ffffffffc02056a8 <commands+0x728>
ffffffffc020169e:	06600593          	li	a1,102
ffffffffc02016a2:	00004517          	auipc	a0,0x4
ffffffffc02016a6:	3f650513          	addi	a0,a0,1014 # ffffffffc0205a98 <commands+0xb18>
ffffffffc02016aa:	b1ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==6);
ffffffffc02016ae:	00004697          	auipc	a3,0x4
ffffffffc02016b2:	4b268693          	addi	a3,a3,1202 # ffffffffc0205b60 <commands+0xbe0>
ffffffffc02016b6:	00004617          	auipc	a2,0x4
ffffffffc02016ba:	ff260613          	addi	a2,a2,-14 # ffffffffc02056a8 <commands+0x728>
ffffffffc02016be:	06300593          	li	a1,99
ffffffffc02016c2:	00004517          	auipc	a0,0x4
ffffffffc02016c6:	3d650513          	addi	a0,a0,982 # ffffffffc0205a98 <commands+0xb18>
ffffffffc02016ca:	afffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc02016ce:	00004697          	auipc	a3,0x4
ffffffffc02016d2:	48268693          	addi	a3,a3,1154 # ffffffffc0205b50 <commands+0xbd0>
ffffffffc02016d6:	00004617          	auipc	a2,0x4
ffffffffc02016da:	fd260613          	addi	a2,a2,-46 # ffffffffc02056a8 <commands+0x728>
ffffffffc02016de:	06000593          	li	a1,96
ffffffffc02016e2:	00004517          	auipc	a0,0x4
ffffffffc02016e6:	3b650513          	addi	a0,a0,950 # ffffffffc0205a98 <commands+0xb18>
ffffffffc02016ea:	adffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc02016ee:	00004697          	auipc	a3,0x4
ffffffffc02016f2:	46268693          	addi	a3,a3,1122 # ffffffffc0205b50 <commands+0xbd0>
ffffffffc02016f6:	00004617          	auipc	a2,0x4
ffffffffc02016fa:	fb260613          	addi	a2,a2,-78 # ffffffffc02056a8 <commands+0x728>
ffffffffc02016fe:	05d00593          	li	a1,93
ffffffffc0201702:	00004517          	auipc	a0,0x4
ffffffffc0201706:	39650513          	addi	a0,a0,918 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020170a:	abffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc020170e:	00004697          	auipc	a3,0x4
ffffffffc0201712:	37a68693          	addi	a3,a3,890 # ffffffffc0205a88 <commands+0xb08>
ffffffffc0201716:	00004617          	auipc	a2,0x4
ffffffffc020171a:	f9260613          	addi	a2,a2,-110 # ffffffffc02056a8 <commands+0x728>
ffffffffc020171e:	05a00593          	li	a1,90
ffffffffc0201722:	00004517          	auipc	a0,0x4
ffffffffc0201726:	37650513          	addi	a0,a0,886 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020172a:	a9ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc020172e:	00004697          	auipc	a3,0x4
ffffffffc0201732:	35a68693          	addi	a3,a3,858 # ffffffffc0205a88 <commands+0xb08>
ffffffffc0201736:	00004617          	auipc	a2,0x4
ffffffffc020173a:	f7260613          	addi	a2,a2,-142 # ffffffffc02056a8 <commands+0x728>
ffffffffc020173e:	05700593          	li	a1,87
ffffffffc0201742:	00004517          	auipc	a0,0x4
ffffffffc0201746:	35650513          	addi	a0,a0,854 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020174a:	a7ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc020174e:	00004697          	auipc	a3,0x4
ffffffffc0201752:	33a68693          	addi	a3,a3,826 # ffffffffc0205a88 <commands+0xb08>
ffffffffc0201756:	00004617          	auipc	a2,0x4
ffffffffc020175a:	f5260613          	addi	a2,a2,-174 # ffffffffc02056a8 <commands+0x728>
ffffffffc020175e:	05400593          	li	a1,84
ffffffffc0201762:	00004517          	auipc	a0,0x4
ffffffffc0201766:	33650513          	addi	a0,a0,822 # ffffffffc0205a98 <commands+0xb18>
ffffffffc020176a:	a5ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020176e <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020176e:	751c                	ld	a5,40(a0)
{
ffffffffc0201770:	1141                	addi	sp,sp,-16
ffffffffc0201772:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201774:	cf91                	beqz	a5,ffffffffc0201790 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201776:	ee0d                	bnez	a2,ffffffffc02017b0 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201778:	679c                	ld	a5,8(a5)
}
ffffffffc020177a:	60a2                	ld	ra,8(sp)
ffffffffc020177c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020177e:	6394                	ld	a3,0(a5)
ffffffffc0201780:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201782:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc0201786:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201788:	e314                	sd	a3,0(a4)
ffffffffc020178a:	e19c                	sd	a5,0(a1)
}
ffffffffc020178c:	0141                	addi	sp,sp,16
ffffffffc020178e:	8082                	ret
         assert(head != NULL);
ffffffffc0201790:	00004697          	auipc	a3,0x4
ffffffffc0201794:	45868693          	addi	a3,a3,1112 # ffffffffc0205be8 <commands+0xc68>
ffffffffc0201798:	00004617          	auipc	a2,0x4
ffffffffc020179c:	f1060613          	addi	a2,a2,-240 # ffffffffc02056a8 <commands+0x728>
ffffffffc02017a0:	04100593          	li	a1,65
ffffffffc02017a4:	00004517          	auipc	a0,0x4
ffffffffc02017a8:	2f450513          	addi	a0,a0,756 # ffffffffc0205a98 <commands+0xb18>
ffffffffc02017ac:	a1dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(in_tick==0);
ffffffffc02017b0:	00004697          	auipc	a3,0x4
ffffffffc02017b4:	44868693          	addi	a3,a3,1096 # ffffffffc0205bf8 <commands+0xc78>
ffffffffc02017b8:	00004617          	auipc	a2,0x4
ffffffffc02017bc:	ef060613          	addi	a2,a2,-272 # ffffffffc02056a8 <commands+0x728>
ffffffffc02017c0:	04200593          	li	a1,66
ffffffffc02017c4:	00004517          	auipc	a0,0x4
ffffffffc02017c8:	2d450513          	addi	a0,a0,724 # ffffffffc0205a98 <commands+0xb18>
ffffffffc02017cc:	9fdfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02017d0 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02017d0:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02017d2:	cb91                	beqz	a5,ffffffffc02017e6 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02017d4:	6394                	ld	a3,0(a5)
ffffffffc02017d6:	03060713          	addi	a4,a2,48
    prev->next = next->prev = elm;
ffffffffc02017da:	e398                	sd	a4,0(a5)
ffffffffc02017dc:	e698                	sd	a4,8(a3)
}
ffffffffc02017de:	4501                	li	a0,0
    elm->next = next;
ffffffffc02017e0:	fe1c                	sd	a5,56(a2)
    elm->prev = prev;
ffffffffc02017e2:	fa14                	sd	a3,48(a2)
ffffffffc02017e4:	8082                	ret
{
ffffffffc02017e6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02017e8:	00004697          	auipc	a3,0x4
ffffffffc02017ec:	42068693          	addi	a3,a3,1056 # ffffffffc0205c08 <commands+0xc88>
ffffffffc02017f0:	00004617          	auipc	a2,0x4
ffffffffc02017f4:	eb860613          	addi	a2,a2,-328 # ffffffffc02056a8 <commands+0x728>
ffffffffc02017f8:	03200593          	li	a1,50
ffffffffc02017fc:	00004517          	auipc	a0,0x4
ffffffffc0201800:	29c50513          	addi	a0,a0,668 # ffffffffc0205a98 <commands+0xb18>
{
ffffffffc0201804:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201806:	9c3fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020180a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020180a:	c94d                	beqz	a0,ffffffffc02018bc <slob_free+0xb2>
{
ffffffffc020180c:	1141                	addi	sp,sp,-16
ffffffffc020180e:	e022                	sd	s0,0(sp)
ffffffffc0201810:	e406                	sd	ra,8(sp)
ffffffffc0201812:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201814:	e9c1                	bnez	a1,ffffffffc02018a4 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201816:	100027f3          	csrr	a5,sstatus
ffffffffc020181a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020181c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020181e:	ebd9                	bnez	a5,ffffffffc02018b4 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201820:	00009617          	auipc	a2,0x9
ffffffffc0201824:	83060613          	addi	a2,a2,-2000 # ffffffffc020a050 <slobfree>
ffffffffc0201828:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020182a:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020182c:	679c                	ld	a5,8(a5)
ffffffffc020182e:	02877a63          	bgeu	a4,s0,ffffffffc0201862 <slob_free+0x58>
ffffffffc0201832:	00f46463          	bltu	s0,a5,ffffffffc020183a <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201836:	fef76ae3          	bltu	a4,a5,ffffffffc020182a <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc020183a:	400c                	lw	a1,0(s0)
ffffffffc020183c:	00459693          	slli	a3,a1,0x4
ffffffffc0201840:	96a2                	add	a3,a3,s0
ffffffffc0201842:	02d78a63          	beq	a5,a3,ffffffffc0201876 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201846:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201848:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020184a:	00469793          	slli	a5,a3,0x4
ffffffffc020184e:	97ba                	add	a5,a5,a4
ffffffffc0201850:	02f40e63          	beq	s0,a5,ffffffffc020188c <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201854:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201856:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201858:	e129                	bnez	a0,ffffffffc020189a <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020185a:	60a2                	ld	ra,8(sp)
ffffffffc020185c:	6402                	ld	s0,0(sp)
ffffffffc020185e:	0141                	addi	sp,sp,16
ffffffffc0201860:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201862:	fcf764e3          	bltu	a4,a5,ffffffffc020182a <slob_free+0x20>
ffffffffc0201866:	fcf472e3          	bgeu	s0,a5,ffffffffc020182a <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc020186a:	400c                	lw	a1,0(s0)
ffffffffc020186c:	00459693          	slli	a3,a1,0x4
ffffffffc0201870:	96a2                	add	a3,a3,s0
ffffffffc0201872:	fcd79ae3          	bne	a5,a3,ffffffffc0201846 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201876:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201878:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020187a:	9db5                	addw	a1,a1,a3
ffffffffc020187c:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020187e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201880:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201882:	00469793          	slli	a5,a3,0x4
ffffffffc0201886:	97ba                	add	a5,a5,a4
ffffffffc0201888:	fcf416e3          	bne	s0,a5,ffffffffc0201854 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020188c:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020188e:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201890:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201892:	9ebd                	addw	a3,a3,a5
ffffffffc0201894:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201896:	e70c                	sd	a1,8(a4)
ffffffffc0201898:	d169                	beqz	a0,ffffffffc020185a <slob_free+0x50>
}
ffffffffc020189a:	6402                	ld	s0,0(sp)
ffffffffc020189c:	60a2                	ld	ra,8(sp)
ffffffffc020189e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02018a0:	d1ffe06f          	j	ffffffffc02005be <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02018a4:	25bd                	addiw	a1,a1,15
ffffffffc02018a6:	8191                	srli	a1,a1,0x4
ffffffffc02018a8:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018aa:	100027f3          	csrr	a5,sstatus
ffffffffc02018ae:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018b0:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018b2:	d7bd                	beqz	a5,ffffffffc0201820 <slob_free+0x16>
        intr_disable();
ffffffffc02018b4:	d11fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02018b8:	4505                	li	a0,1
ffffffffc02018ba:	b79d                	j	ffffffffc0201820 <slob_free+0x16>
ffffffffc02018bc:	8082                	ret

ffffffffc02018be <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018be:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018c0:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018c2:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018c6:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018c8:	75a010ef          	jal	ra,ffffffffc0203022 <alloc_pages>
  if(!page)
ffffffffc02018cc:	c129                	beqz	a0,ffffffffc020190e <__slob_get_free_pages.constprop.0+0x50>
    return page - pages + nbase;
ffffffffc02018ce:	00014697          	auipc	a3,0x14
ffffffffc02018d2:	cc26b683          	ld	a3,-830(a3) # ffffffffc0215590 <pages>
ffffffffc02018d6:	8d15                	sub	a0,a0,a3
ffffffffc02018d8:	850d                	srai	a0,a0,0x3
ffffffffc02018da:	00005697          	auipc	a3,0x5
ffffffffc02018de:	48e6b683          	ld	a3,1166(a3) # ffffffffc0206d68 <error_string+0x38>
ffffffffc02018e2:	02d50533          	mul	a0,a0,a3
ffffffffc02018e6:	00005697          	auipc	a3,0x5
ffffffffc02018ea:	48a6b683          	ld	a3,1162(a3) # ffffffffc0206d70 <nbase>
    return KADDR(page2pa(page));
ffffffffc02018ee:	00014717          	auipc	a4,0x14
ffffffffc02018f2:	c9a73703          	ld	a4,-870(a4) # ffffffffc0215588 <npage>
    return page - pages + nbase;
ffffffffc02018f6:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02018f8:	00c51793          	slli	a5,a0,0xc
ffffffffc02018fc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02018fe:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201900:	00e7fa63          	bgeu	a5,a4,ffffffffc0201914 <__slob_get_free_pages.constprop.0+0x56>
ffffffffc0201904:	00014697          	auipc	a3,0x14
ffffffffc0201908:	c9c6b683          	ld	a3,-868(a3) # ffffffffc02155a0 <va_pa_offset>
ffffffffc020190c:	9536                	add	a0,a0,a3
}
ffffffffc020190e:	60a2                	ld	ra,8(sp)
ffffffffc0201910:	0141                	addi	sp,sp,16
ffffffffc0201912:	8082                	ret
ffffffffc0201914:	86aa                	mv	a3,a0
ffffffffc0201916:	00004617          	auipc	a2,0x4
ffffffffc020191a:	fea60613          	addi	a2,a2,-22 # ffffffffc0205900 <commands+0x980>
ffffffffc020191e:	06900593          	li	a1,105
ffffffffc0201922:	00004517          	auipc	a0,0x4
ffffffffc0201926:	fce50513          	addi	a0,a0,-50 # ffffffffc02058f0 <commands+0x970>
ffffffffc020192a:	89ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020192e <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020192e:	1101                	addi	sp,sp,-32
ffffffffc0201930:	ec06                	sd	ra,24(sp)
ffffffffc0201932:	e822                	sd	s0,16(sp)
ffffffffc0201934:	e426                	sd	s1,8(sp)
ffffffffc0201936:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201938:	01050713          	addi	a4,a0,16
ffffffffc020193c:	6785                	lui	a5,0x1
ffffffffc020193e:	0cf77363          	bgeu	a4,a5,ffffffffc0201a04 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201942:	00f50493          	addi	s1,a0,15
ffffffffc0201946:	8091                	srli	s1,s1,0x4
ffffffffc0201948:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020194a:	10002673          	csrr	a2,sstatus
ffffffffc020194e:	8a09                	andi	a2,a2,2
ffffffffc0201950:	e25d                	bnez	a2,ffffffffc02019f6 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201952:	00008917          	auipc	s2,0x8
ffffffffc0201956:	6fe90913          	addi	s2,s2,1790 # ffffffffc020a050 <slobfree>
ffffffffc020195a:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020195e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201960:	4398                	lw	a4,0(a5)
ffffffffc0201962:	08975e63          	bge	a4,s1,ffffffffc02019fe <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201966:	00d78b63          	beq	a5,a3,ffffffffc020197c <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020196a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020196c:	4018                	lw	a4,0(s0)
ffffffffc020196e:	02975a63          	bge	a4,s1,ffffffffc02019a2 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201972:	00093683          	ld	a3,0(s2)
ffffffffc0201976:	87a2                	mv	a5,s0
ffffffffc0201978:	fed799e3          	bne	a5,a3,ffffffffc020196a <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc020197c:	ee31                	bnez	a2,ffffffffc02019d8 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020197e:	4501                	li	a0,0
ffffffffc0201980:	f3fff0ef          	jal	ra,ffffffffc02018be <__slob_get_free_pages.constprop.0>
ffffffffc0201984:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201986:	cd05                	beqz	a0,ffffffffc02019be <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201988:	6585                	lui	a1,0x1
ffffffffc020198a:	e81ff0ef          	jal	ra,ffffffffc020180a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020198e:	10002673          	csrr	a2,sstatus
ffffffffc0201992:	8a09                	andi	a2,a2,2
ffffffffc0201994:	ee05                	bnez	a2,ffffffffc02019cc <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201996:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020199a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020199c:	4018                	lw	a4,0(s0)
ffffffffc020199e:	fc974ae3          	blt	a4,s1,ffffffffc0201972 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc02019a2:	04e48763          	beq	s1,a4,ffffffffc02019f0 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc02019a6:	00449693          	slli	a3,s1,0x4
ffffffffc02019aa:	96a2                	add	a3,a3,s0
ffffffffc02019ac:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02019ae:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02019b0:	9f05                	subw	a4,a4,s1
ffffffffc02019b2:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02019b4:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02019b6:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02019b8:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc02019bc:	e20d                	bnez	a2,ffffffffc02019de <slob_alloc.constprop.0+0xb0>
}
ffffffffc02019be:	60e2                	ld	ra,24(sp)
ffffffffc02019c0:	8522                	mv	a0,s0
ffffffffc02019c2:	6442                	ld	s0,16(sp)
ffffffffc02019c4:	64a2                	ld	s1,8(sp)
ffffffffc02019c6:	6902                	ld	s2,0(sp)
ffffffffc02019c8:	6105                	addi	sp,sp,32
ffffffffc02019ca:	8082                	ret
        intr_disable();
ffffffffc02019cc:	bf9fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
			cur = slobfree;
ffffffffc02019d0:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02019d4:	4605                	li	a2,1
ffffffffc02019d6:	b7d1                	j	ffffffffc020199a <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02019d8:	be7fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02019dc:	b74d                	j	ffffffffc020197e <slob_alloc.constprop.0+0x50>
ffffffffc02019de:	be1fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
}
ffffffffc02019e2:	60e2                	ld	ra,24(sp)
ffffffffc02019e4:	8522                	mv	a0,s0
ffffffffc02019e6:	6442                	ld	s0,16(sp)
ffffffffc02019e8:	64a2                	ld	s1,8(sp)
ffffffffc02019ea:	6902                	ld	s2,0(sp)
ffffffffc02019ec:	6105                	addi	sp,sp,32
ffffffffc02019ee:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02019f0:	6418                	ld	a4,8(s0)
ffffffffc02019f2:	e798                	sd	a4,8(a5)
ffffffffc02019f4:	b7d1                	j	ffffffffc02019b8 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02019f6:	bcffe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02019fa:	4605                	li	a2,1
ffffffffc02019fc:	bf99                	j	ffffffffc0201952 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019fe:	843e                	mv	s0,a5
ffffffffc0201a00:	87b6                	mv	a5,a3
ffffffffc0201a02:	b745                	j	ffffffffc02019a2 <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201a04:	00004697          	auipc	a3,0x4
ffffffffc0201a08:	23c68693          	addi	a3,a3,572 # ffffffffc0205c40 <commands+0xcc0>
ffffffffc0201a0c:	00004617          	auipc	a2,0x4
ffffffffc0201a10:	c9c60613          	addi	a2,a2,-868 # ffffffffc02056a8 <commands+0x728>
ffffffffc0201a14:	06300593          	li	a1,99
ffffffffc0201a18:	00004517          	auipc	a0,0x4
ffffffffc0201a1c:	24850513          	addi	a0,a0,584 # ffffffffc0205c60 <commands+0xce0>
ffffffffc0201a20:	fa8fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201a24 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201a24:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201a26:	00004517          	auipc	a0,0x4
ffffffffc0201a2a:	25250513          	addi	a0,a0,594 # ffffffffc0205c78 <commands+0xcf8>
kmalloc_init(void) {
ffffffffc0201a2e:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201a30:	e9cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201a34:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a36:	00004517          	auipc	a0,0x4
ffffffffc0201a3a:	25a50513          	addi	a0,a0,602 # ffffffffc0205c90 <commands+0xd10>
}
ffffffffc0201a3e:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a40:	e8cfe06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0201a44 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201a44:	1101                	addi	sp,sp,-32
ffffffffc0201a46:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a48:	6905                	lui	s2,0x1
{
ffffffffc0201a4a:	e822                	sd	s0,16(sp)
ffffffffc0201a4c:	ec06                	sd	ra,24(sp)
ffffffffc0201a4e:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a50:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0201a54:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a56:	04a7f963          	bgeu	a5,a0,ffffffffc0201aa8 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201a5a:	4561                	li	a0,24
ffffffffc0201a5c:	ed3ff0ef          	jal	ra,ffffffffc020192e <slob_alloc.constprop.0>
ffffffffc0201a60:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201a62:	c929                	beqz	a0,ffffffffc0201ab4 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201a64:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201a68:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a6a:	00f95763          	bge	s2,a5,ffffffffc0201a78 <kmalloc+0x34>
ffffffffc0201a6e:	6705                	lui	a4,0x1
ffffffffc0201a70:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201a72:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a74:	fef74ee3          	blt	a4,a5,ffffffffc0201a70 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201a78:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201a7a:	e45ff0ef          	jal	ra,ffffffffc02018be <__slob_get_free_pages.constprop.0>
ffffffffc0201a7e:	e488                	sd	a0,8(s1)
ffffffffc0201a80:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201a82:	c525                	beqz	a0,ffffffffc0201aea <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a84:	100027f3          	csrr	a5,sstatus
ffffffffc0201a88:	8b89                	andi	a5,a5,2
ffffffffc0201a8a:	ef8d                	bnez	a5,ffffffffc0201ac4 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201a8c:	00014797          	auipc	a5,0x14
ffffffffc0201a90:	acc78793          	addi	a5,a5,-1332 # ffffffffc0215558 <bigblocks>
ffffffffc0201a94:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201a96:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201a98:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201a9a:	60e2                	ld	ra,24(sp)
ffffffffc0201a9c:	8522                	mv	a0,s0
ffffffffc0201a9e:	6442                	ld	s0,16(sp)
ffffffffc0201aa0:	64a2                	ld	s1,8(sp)
ffffffffc0201aa2:	6902                	ld	s2,0(sp)
ffffffffc0201aa4:	6105                	addi	sp,sp,32
ffffffffc0201aa6:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201aa8:	0541                	addi	a0,a0,16
ffffffffc0201aaa:	e85ff0ef          	jal	ra,ffffffffc020192e <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201aae:	01050413          	addi	s0,a0,16
ffffffffc0201ab2:	f565                	bnez	a0,ffffffffc0201a9a <kmalloc+0x56>
ffffffffc0201ab4:	4401                	li	s0,0
}
ffffffffc0201ab6:	60e2                	ld	ra,24(sp)
ffffffffc0201ab8:	8522                	mv	a0,s0
ffffffffc0201aba:	6442                	ld	s0,16(sp)
ffffffffc0201abc:	64a2                	ld	s1,8(sp)
ffffffffc0201abe:	6902                	ld	s2,0(sp)
ffffffffc0201ac0:	6105                	addi	sp,sp,32
ffffffffc0201ac2:	8082                	ret
        intr_disable();
ffffffffc0201ac4:	b01fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ac8:	00014797          	auipc	a5,0x14
ffffffffc0201acc:	a9078793          	addi	a5,a5,-1392 # ffffffffc0215558 <bigblocks>
ffffffffc0201ad0:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201ad2:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201ad4:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201ad6:	ae9fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
		return bb->pages;
ffffffffc0201ada:	6480                	ld	s0,8(s1)
}
ffffffffc0201adc:	60e2                	ld	ra,24(sp)
ffffffffc0201ade:	64a2                	ld	s1,8(sp)
ffffffffc0201ae0:	8522                	mv	a0,s0
ffffffffc0201ae2:	6442                	ld	s0,16(sp)
ffffffffc0201ae4:	6902                	ld	s2,0(sp)
ffffffffc0201ae6:	6105                	addi	sp,sp,32
ffffffffc0201ae8:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201aea:	45e1                	li	a1,24
ffffffffc0201aec:	8526                	mv	a0,s1
ffffffffc0201aee:	d1dff0ef          	jal	ra,ffffffffc020180a <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201af2:	b765                	j	ffffffffc0201a9a <kmalloc+0x56>

ffffffffc0201af4 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201af4:	c561                	beqz	a0,ffffffffc0201bbc <kfree+0xc8>
{
ffffffffc0201af6:	1101                	addi	sp,sp,-32
ffffffffc0201af8:	e822                	sd	s0,16(sp)
ffffffffc0201afa:	ec06                	sd	ra,24(sp)
ffffffffc0201afc:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201afe:	03451793          	slli	a5,a0,0x34
ffffffffc0201b02:	842a                	mv	s0,a0
ffffffffc0201b04:	e7d1                	bnez	a5,ffffffffc0201b90 <kfree+0x9c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b06:	100027f3          	csrr	a5,sstatus
ffffffffc0201b0a:	8b89                	andi	a5,a5,2
ffffffffc0201b0c:	ebd1                	bnez	a5,ffffffffc0201ba0 <kfree+0xac>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b0e:	00014797          	auipc	a5,0x14
ffffffffc0201b12:	a4a7b783          	ld	a5,-1462(a5) # ffffffffc0215558 <bigblocks>
    return 0;
ffffffffc0201b16:	4601                	li	a2,0
ffffffffc0201b18:	cfa5                	beqz	a5,ffffffffc0201b90 <kfree+0x9c>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201b1a:	00014697          	auipc	a3,0x14
ffffffffc0201b1e:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0215558 <bigblocks>
ffffffffc0201b22:	a021                	j	ffffffffc0201b2a <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b24:	01048693          	addi	a3,s1,16
ffffffffc0201b28:	c3bd                	beqz	a5,ffffffffc0201b8e <kfree+0x9a>
			if (bb->pages == block) {
ffffffffc0201b2a:	6798                	ld	a4,8(a5)
ffffffffc0201b2c:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201b2e:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201b30:	fe871ae3          	bne	a4,s0,ffffffffc0201b24 <kfree+0x30>
				*last = bb->next;
ffffffffc0201b34:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201b36:	e241                	bnez	a2,ffffffffc0201bb6 <kfree+0xc2>
    return pa2page(PADDR(kva));
ffffffffc0201b38:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201b3c:	4098                	lw	a4,0(s1)
ffffffffc0201b3e:	08f46c63          	bltu	s0,a5,ffffffffc0201bd6 <kfree+0xe2>
ffffffffc0201b42:	00014697          	auipc	a3,0x14
ffffffffc0201b46:	a5e6b683          	ld	a3,-1442(a3) # ffffffffc02155a0 <va_pa_offset>
ffffffffc0201b4a:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201b4c:	8031                	srli	s0,s0,0xc
ffffffffc0201b4e:	00014797          	auipc	a5,0x14
ffffffffc0201b52:	a3a7b783          	ld	a5,-1478(a5) # ffffffffc0215588 <npage>
ffffffffc0201b56:	06f47463          	bgeu	s0,a5,ffffffffc0201bbe <kfree+0xca>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b5a:	00005797          	auipc	a5,0x5
ffffffffc0201b5e:	2167b783          	ld	a5,534(a5) # ffffffffc0206d70 <nbase>
ffffffffc0201b62:	8c1d                	sub	s0,s0,a5
ffffffffc0201b64:	00341513          	slli	a0,s0,0x3
ffffffffc0201b68:	942a                	add	s0,s0,a0
ffffffffc0201b6a:	040e                	slli	s0,s0,0x3
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b6c:	00014517          	auipc	a0,0x14
ffffffffc0201b70:	a2453503          	ld	a0,-1500(a0) # ffffffffc0215590 <pages>
ffffffffc0201b74:	4585                	li	a1,1
ffffffffc0201b76:	9522                	add	a0,a0,s0
ffffffffc0201b78:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201b7c:	538010ef          	jal	ra,ffffffffc02030b4 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201b80:	6442                	ld	s0,16(sp)
ffffffffc0201b82:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b84:	8526                	mv	a0,s1
}
ffffffffc0201b86:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b88:	45e1                	li	a1,24
}
ffffffffc0201b8a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b8c:	b9bd                	j	ffffffffc020180a <slob_free>
ffffffffc0201b8e:	e20d                	bnez	a2,ffffffffc0201bb0 <kfree+0xbc>
ffffffffc0201b90:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201b94:	6442                	ld	s0,16(sp)
ffffffffc0201b96:	60e2                	ld	ra,24(sp)
ffffffffc0201b98:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b9a:	4581                	li	a1,0
}
ffffffffc0201b9c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b9e:	b1b5                	j	ffffffffc020180a <slob_free>
        intr_disable();
ffffffffc0201ba0:	a25fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ba4:	00014797          	auipc	a5,0x14
ffffffffc0201ba8:	9b47b783          	ld	a5,-1612(a5) # ffffffffc0215558 <bigblocks>
        return 1;
ffffffffc0201bac:	4605                	li	a2,1
ffffffffc0201bae:	f7b5                	bnez	a5,ffffffffc0201b1a <kfree+0x26>
        intr_enable();
ffffffffc0201bb0:	a0ffe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201bb4:	bff1                	j	ffffffffc0201b90 <kfree+0x9c>
ffffffffc0201bb6:	a09fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201bba:	bfbd                	j	ffffffffc0201b38 <kfree+0x44>
ffffffffc0201bbc:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201bbe:	00004617          	auipc	a2,0x4
ffffffffc0201bc2:	d1260613          	addi	a2,a2,-750 # ffffffffc02058d0 <commands+0x950>
ffffffffc0201bc6:	06200593          	li	a1,98
ffffffffc0201bca:	00004517          	auipc	a0,0x4
ffffffffc0201bce:	d2650513          	addi	a0,a0,-730 # ffffffffc02058f0 <commands+0x970>
ffffffffc0201bd2:	df6fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201bd6:	86a2                	mv	a3,s0
ffffffffc0201bd8:	00004617          	auipc	a2,0x4
ffffffffc0201bdc:	0d860613          	addi	a2,a2,216 # ffffffffc0205cb0 <commands+0xd30>
ffffffffc0201be0:	06e00593          	li	a1,110
ffffffffc0201be4:	00004517          	auipc	a0,0x4
ffffffffc0201be8:	d0c50513          	addi	a0,a0,-756 # ffffffffc02058f0 <commands+0x970>
ffffffffc0201bec:	ddcfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201bf0 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201bf0:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201bf2:	00004617          	auipc	a2,0x4
ffffffffc0201bf6:	cde60613          	addi	a2,a2,-802 # ffffffffc02058d0 <commands+0x950>
ffffffffc0201bfa:	06200593          	li	a1,98
ffffffffc0201bfe:	00004517          	auipc	a0,0x4
ffffffffc0201c02:	cf250513          	addi	a0,a0,-782 # ffffffffc02058f0 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc0201c06:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c08:	dc0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201c0c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201c0c:	7135                	addi	sp,sp,-160
ffffffffc0201c0e:	ed06                	sd	ra,152(sp)
ffffffffc0201c10:	e922                	sd	s0,144(sp)
ffffffffc0201c12:	e526                	sd	s1,136(sp)
ffffffffc0201c14:	e14a                	sd	s2,128(sp)
ffffffffc0201c16:	fcce                	sd	s3,120(sp)
ffffffffc0201c18:	f8d2                	sd	s4,112(sp)
ffffffffc0201c1a:	f4d6                	sd	s5,104(sp)
ffffffffc0201c1c:	f0da                	sd	s6,96(sp)
ffffffffc0201c1e:	ecde                	sd	s7,88(sp)
ffffffffc0201c20:	e8e2                	sd	s8,80(sp)
ffffffffc0201c22:	e4e6                	sd	s9,72(sp)
ffffffffc0201c24:	e0ea                	sd	s10,64(sp)
ffffffffc0201c26:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201c28:	5c4020ef          	jal	ra,ffffffffc02041ec <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201c2c:	00014697          	auipc	a3,0x14
ffffffffc0201c30:	9346b683          	ld	a3,-1740(a3) # ffffffffc0215560 <max_swap_offset>
ffffffffc0201c34:	010007b7          	lui	a5,0x1000
ffffffffc0201c38:	ff968713          	addi	a4,a3,-7
ffffffffc0201c3c:	17e1                	addi	a5,a5,-8
ffffffffc0201c3e:	44e7e363          	bltu	a5,a4,ffffffffc0202084 <swap_init+0x478>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0201c42:	00008797          	auipc	a5,0x8
ffffffffc0201c46:	3be78793          	addi	a5,a5,958 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0201c4a:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0201c4c:	00014b97          	auipc	s7,0x14
ffffffffc0201c50:	91cb8b93          	addi	s7,s7,-1764 # ffffffffc0215568 <sm>
ffffffffc0201c54:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0201c58:	9702                	jalr	a4
ffffffffc0201c5a:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0201c5c:	c10d                	beqz	a0,ffffffffc0201c7e <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201c5e:	60ea                	ld	ra,152(sp)
ffffffffc0201c60:	644a                	ld	s0,144(sp)
ffffffffc0201c62:	64aa                	ld	s1,136(sp)
ffffffffc0201c64:	79e6                	ld	s3,120(sp)
ffffffffc0201c66:	7a46                	ld	s4,112(sp)
ffffffffc0201c68:	7aa6                	ld	s5,104(sp)
ffffffffc0201c6a:	7b06                	ld	s6,96(sp)
ffffffffc0201c6c:	6be6                	ld	s7,88(sp)
ffffffffc0201c6e:	6c46                	ld	s8,80(sp)
ffffffffc0201c70:	6ca6                	ld	s9,72(sp)
ffffffffc0201c72:	6d06                	ld	s10,64(sp)
ffffffffc0201c74:	7de2                	ld	s11,56(sp)
ffffffffc0201c76:	854a                	mv	a0,s2
ffffffffc0201c78:	690a                	ld	s2,128(sp)
ffffffffc0201c7a:	610d                	addi	sp,sp,160
ffffffffc0201c7c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201c7e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c82:	00004517          	auipc	a0,0x4
ffffffffc0201c86:	08650513          	addi	a0,a0,134 # ffffffffc0205d08 <commands+0xd88>
    return listelm->next;
ffffffffc0201c8a:	00010417          	auipc	s0,0x10
ffffffffc0201c8e:	85e40413          	addi	s0,s0,-1954 # ffffffffc02114e8 <free_area>
ffffffffc0201c92:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201c94:	4785                	li	a5,1
ffffffffc0201c96:	00014717          	auipc	a4,0x14
ffffffffc0201c9a:	8cf72d23          	sw	a5,-1830(a4) # ffffffffc0215570 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201c9e:	c2efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201ca2:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0201ca4:	4d01                	li	s10,0
ffffffffc0201ca6:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201ca8:	34878e63          	beq	a5,s0,ffffffffc0202004 <swap_init+0x3f8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201cac:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201cb0:	8b09                	andi	a4,a4,2
ffffffffc0201cb2:	34070b63          	beqz	a4,ffffffffc0202008 <swap_init+0x3fc>
        count ++, total += p->property;
ffffffffc0201cb6:	ff07a703          	lw	a4,-16(a5)
ffffffffc0201cba:	679c                	ld	a5,8(a5)
ffffffffc0201cbc:	2d85                	addiw	s11,s11,1
ffffffffc0201cbe:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201cc2:	fe8795e3          	bne	a5,s0,ffffffffc0201cac <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201cc6:	84ea                	mv	s1,s10
ffffffffc0201cc8:	42c010ef          	jal	ra,ffffffffc02030f4 <nr_free_pages>
ffffffffc0201ccc:	44951463          	bne	a0,s1,ffffffffc0202114 <swap_init+0x508>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201cd0:	866a                	mv	a2,s10
ffffffffc0201cd2:	85ee                	mv	a1,s11
ffffffffc0201cd4:	00004517          	auipc	a0,0x4
ffffffffc0201cd8:	07c50513          	addi	a0,a0,124 # ffffffffc0205d50 <commands+0xdd0>
ffffffffc0201cdc:	bf0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201ce0:	eb7fe0ef          	jal	ra,ffffffffc0200b96 <mm_create>
ffffffffc0201ce4:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201ce6:	48050763          	beqz	a0,ffffffffc0202174 <swap_init+0x568>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201cea:	00014797          	auipc	a5,0x14
ffffffffc0201cee:	85e78793          	addi	a5,a5,-1954 # ffffffffc0215548 <check_mm_struct>
ffffffffc0201cf2:	6398                	ld	a4,0(a5)
ffffffffc0201cf4:	40071063          	bnez	a4,ffffffffc02020f4 <swap_init+0x4e8>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201cf8:	00014717          	auipc	a4,0x14
ffffffffc0201cfc:	88870713          	addi	a4,a4,-1912 # ffffffffc0215580 <boot_pgdir>
ffffffffc0201d00:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0201d04:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0201d06:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201d0a:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201d0e:	44079363          	bnez	a5,ffffffffc0202154 <swap_init+0x548>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201d12:	6599                	lui	a1,0x6
ffffffffc0201d14:	460d                	li	a2,3
ffffffffc0201d16:	6505                	lui	a0,0x1
ffffffffc0201d18:	ec7fe0ef          	jal	ra,ffffffffc0200bde <vma_create>
ffffffffc0201d1c:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201d1e:	54050763          	beqz	a0,ffffffffc020226c <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0201d22:	8556                	mv	a0,s5
ffffffffc0201d24:	f29fe0ef          	jal	ra,ffffffffc0200c4c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201d28:	00004517          	auipc	a0,0x4
ffffffffc0201d2c:	06850513          	addi	a0,a0,104 # ffffffffc0205d90 <commands+0xe10>
ffffffffc0201d30:	b9cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201d34:	018ab503          	ld	a0,24(s5)
ffffffffc0201d38:	4605                	li	a2,1
ffffffffc0201d3a:	6585                	lui	a1,0x1
ffffffffc0201d3c:	3f2010ef          	jal	ra,ffffffffc020312e <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201d40:	4e050663          	beqz	a0,ffffffffc020222c <swap_init+0x620>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d44:	00004517          	auipc	a0,0x4
ffffffffc0201d48:	09c50513          	addi	a0,a0,156 # ffffffffc0205de0 <commands+0xe60>
ffffffffc0201d4c:	0000f497          	auipc	s1,0xf
ffffffffc0201d50:	72c48493          	addi	s1,s1,1836 # ffffffffc0211478 <check_rp>
ffffffffc0201d54:	b78fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d58:	0000f997          	auipc	s3,0xf
ffffffffc0201d5c:	74098993          	addi	s3,s3,1856 # ffffffffc0211498 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d60:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0201d62:	4505                	li	a0,1
ffffffffc0201d64:	2be010ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0201d68:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0201d6c:	2e050c63          	beqz	a0,ffffffffc0202064 <swap_init+0x458>
ffffffffc0201d70:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201d72:	8b89                	andi	a5,a5,2
ffffffffc0201d74:	36079063          	bnez	a5,ffffffffc02020d4 <swap_init+0x4c8>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d78:	0a21                	addi	s4,s4,8
ffffffffc0201d7a:	ff3a14e3          	bne	s4,s3,ffffffffc0201d62 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201d7e:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201d80:	0000fa17          	auipc	s4,0xf
ffffffffc0201d84:	6f8a0a13          	addi	s4,s4,1784 # ffffffffc0211478 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0201d88:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0201d8a:	ec3e                	sd	a5,24(sp)
ffffffffc0201d8c:	641c                	ld	a5,8(s0)
ffffffffc0201d8e:	e400                	sd	s0,8(s0)
ffffffffc0201d90:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201d92:	481c                	lw	a5,16(s0)
ffffffffc0201d94:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0201d96:	0000f797          	auipc	a5,0xf
ffffffffc0201d9a:	7607a123          	sw	zero,1890(a5) # ffffffffc02114f8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201d9e:	000a3503          	ld	a0,0(s4)
ffffffffc0201da2:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201da4:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0201da6:	30e010ef          	jal	ra,ffffffffc02030b4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201daa:	ff3a1ae3          	bne	s4,s3,ffffffffc0201d9e <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201dae:	01042a03          	lw	s4,16(s0)
ffffffffc0201db2:	4791                	li	a5,4
ffffffffc0201db4:	44fa1c63          	bne	s4,a5,ffffffffc020220c <swap_init+0x600>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201db8:	00004517          	auipc	a0,0x4
ffffffffc0201dbc:	0b050513          	addi	a0,a0,176 # ffffffffc0205e68 <commands+0xee8>
ffffffffc0201dc0:	b0cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201dc4:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201dc6:	00013797          	auipc	a5,0x13
ffffffffc0201dca:	7807a523          	sw	zero,1930(a5) # ffffffffc0215550 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201dce:	4629                	li	a2,10
ffffffffc0201dd0:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0201dd4:	00013697          	auipc	a3,0x13
ffffffffc0201dd8:	77c6a683          	lw	a3,1916(a3) # ffffffffc0215550 <pgfault_num>
ffffffffc0201ddc:	4585                	li	a1,1
ffffffffc0201dde:	00013797          	auipc	a5,0x13
ffffffffc0201de2:	77278793          	addi	a5,a5,1906 # ffffffffc0215550 <pgfault_num>
ffffffffc0201de6:	56b69363          	bne	a3,a1,ffffffffc020234c <swap_init+0x740>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201dea:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0201dee:	4398                	lw	a4,0(a5)
ffffffffc0201df0:	2701                	sext.w	a4,a4
ffffffffc0201df2:	3ed71d63          	bne	a4,a3,ffffffffc02021ec <swap_init+0x5e0>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201df6:	6689                	lui	a3,0x2
ffffffffc0201df8:	462d                	li	a2,11
ffffffffc0201dfa:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201dfe:	4398                	lw	a4,0(a5)
ffffffffc0201e00:	4589                	li	a1,2
ffffffffc0201e02:	2701                	sext.w	a4,a4
ffffffffc0201e04:	4cb71463          	bne	a4,a1,ffffffffc02022cc <swap_init+0x6c0>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201e08:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201e0c:	4394                	lw	a3,0(a5)
ffffffffc0201e0e:	2681                	sext.w	a3,a3
ffffffffc0201e10:	4ce69e63          	bne	a3,a4,ffffffffc02022ec <swap_init+0x6e0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201e14:	668d                	lui	a3,0x3
ffffffffc0201e16:	4631                	li	a2,12
ffffffffc0201e18:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201e1c:	4398                	lw	a4,0(a5)
ffffffffc0201e1e:	458d                	li	a1,3
ffffffffc0201e20:	2701                	sext.w	a4,a4
ffffffffc0201e22:	4eb71563          	bne	a4,a1,ffffffffc020230c <swap_init+0x700>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201e26:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201e2a:	4394                	lw	a3,0(a5)
ffffffffc0201e2c:	2681                	sext.w	a3,a3
ffffffffc0201e2e:	4ee69f63          	bne	a3,a4,ffffffffc020232c <swap_init+0x720>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201e32:	6691                	lui	a3,0x4
ffffffffc0201e34:	4635                	li	a2,13
ffffffffc0201e36:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201e3a:	4398                	lw	a4,0(a5)
ffffffffc0201e3c:	2701                	sext.w	a4,a4
ffffffffc0201e3e:	45471763          	bne	a4,s4,ffffffffc020228c <swap_init+0x680>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201e42:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201e46:	439c                	lw	a5,0(a5)
ffffffffc0201e48:	2781                	sext.w	a5,a5
ffffffffc0201e4a:	46e79163          	bne	a5,a4,ffffffffc02022ac <swap_init+0x6a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201e4e:	481c                	lw	a5,16(s0)
ffffffffc0201e50:	2e079263          	bnez	a5,ffffffffc0202134 <swap_init+0x528>
ffffffffc0201e54:	0000f797          	auipc	a5,0xf
ffffffffc0201e58:	64478793          	addi	a5,a5,1604 # ffffffffc0211498 <swap_in_seq_no>
ffffffffc0201e5c:	0000f717          	auipc	a4,0xf
ffffffffc0201e60:	66470713          	addi	a4,a4,1636 # ffffffffc02114c0 <swap_out_seq_no>
ffffffffc0201e64:	0000f617          	auipc	a2,0xf
ffffffffc0201e68:	65c60613          	addi	a2,a2,1628 # ffffffffc02114c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201e6c:	56fd                	li	a3,-1
ffffffffc0201e6e:	c394                	sw	a3,0(a5)
ffffffffc0201e70:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201e72:	0791                	addi	a5,a5,4
ffffffffc0201e74:	0711                	addi	a4,a4,4
ffffffffc0201e76:	fec79ce3          	bne	a5,a2,ffffffffc0201e6e <swap_init+0x262>
ffffffffc0201e7a:	0000f717          	auipc	a4,0xf
ffffffffc0201e7e:	5de70713          	addi	a4,a4,1502 # ffffffffc0211458 <check_ptep>
ffffffffc0201e82:	0000f697          	auipc	a3,0xf
ffffffffc0201e86:	5f668693          	addi	a3,a3,1526 # ffffffffc0211478 <check_rp>
ffffffffc0201e8a:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201e8c:	00013c17          	auipc	s8,0x13
ffffffffc0201e90:	6fcc0c13          	addi	s8,s8,1788 # ffffffffc0215588 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e94:	00013c97          	auipc	s9,0x13
ffffffffc0201e98:	6fcc8c93          	addi	s9,s9,1788 # ffffffffc0215590 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201e9c:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201ea0:	4601                	li	a2,0
ffffffffc0201ea2:	855a                	mv	a0,s6
ffffffffc0201ea4:	e836                	sd	a3,16(sp)
ffffffffc0201ea6:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0201ea8:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201eaa:	284010ef          	jal	ra,ffffffffc020312e <get_pte>
ffffffffc0201eae:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201eb0:	65a2                	ld	a1,8(sp)
ffffffffc0201eb2:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201eb4:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0201eb6:	1e050363          	beqz	a0,ffffffffc020209c <swap_init+0x490>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201eba:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201ebc:	0017f613          	andi	a2,a5,1
ffffffffc0201ec0:	1e060e63          	beqz	a2,ffffffffc02020bc <swap_init+0x4b0>
    if (PPN(pa) >= npage) {
ffffffffc0201ec4:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ec8:	078a                	slli	a5,a5,0x2
ffffffffc0201eca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ecc:	16c7f063          	bgeu	a5,a2,ffffffffc020202c <swap_init+0x420>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ed0:	00005617          	auipc	a2,0x5
ffffffffc0201ed4:	ea060613          	addi	a2,a2,-352 # ffffffffc0206d70 <nbase>
ffffffffc0201ed8:	00063a03          	ld	s4,0(a2)
ffffffffc0201edc:	000cb503          	ld	a0,0(s9)
ffffffffc0201ee0:	0006b303          	ld	t1,0(a3)
ffffffffc0201ee4:	414787b3          	sub	a5,a5,s4
ffffffffc0201ee8:	00379613          	slli	a2,a5,0x3
ffffffffc0201eec:	97b2                	add	a5,a5,a2
ffffffffc0201eee:	078e                	slli	a5,a5,0x3
ffffffffc0201ef0:	97aa                	add	a5,a5,a0
ffffffffc0201ef2:	14f31963          	bne	t1,a5,ffffffffc0202044 <swap_init+0x438>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201ef6:	6785                	lui	a5,0x1
ffffffffc0201ef8:	95be                	add	a1,a1,a5
ffffffffc0201efa:	6795                	lui	a5,0x5
ffffffffc0201efc:	0721                	addi	a4,a4,8
ffffffffc0201efe:	06a1                	addi	a3,a3,8
ffffffffc0201f00:	f8f59ee3          	bne	a1,a5,ffffffffc0201e9c <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201f04:	00004517          	auipc	a0,0x4
ffffffffc0201f08:	03450513          	addi	a0,a0,52 # ffffffffc0205f38 <commands+0xfb8>
ffffffffc0201f0c:	9c0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0201f10:	000bb783          	ld	a5,0(s7)
ffffffffc0201f14:	7f9c                	ld	a5,56(a5)
ffffffffc0201f16:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201f18:	32051a63          	bnez	a0,ffffffffc020224c <swap_init+0x640>

     nr_free = nr_free_store;
ffffffffc0201f1c:	77a2                	ld	a5,40(sp)
ffffffffc0201f1e:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0201f20:	67e2                	ld	a5,24(sp)
ffffffffc0201f22:	e01c                	sd	a5,0(s0)
ffffffffc0201f24:	7782                	ld	a5,32(sp)
ffffffffc0201f26:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201f28:	6088                	ld	a0,0(s1)
ffffffffc0201f2a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201f2c:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0201f2e:	186010ef          	jal	ra,ffffffffc02030b4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201f32:	ff349be3          	bne	s1,s3,ffffffffc0201f28 <swap_init+0x31c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201f36:	8556                	mv	a0,s5
ffffffffc0201f38:	de5fe0ef          	jal	ra,ffffffffc0200d1c <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201f3c:	00013797          	auipc	a5,0x13
ffffffffc0201f40:	64478793          	addi	a5,a5,1604 # ffffffffc0215580 <boot_pgdir>
ffffffffc0201f44:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201f46:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f4a:	6394                	ld	a3,0(a5)
ffffffffc0201f4c:	068a                	slli	a3,a3,0x2
ffffffffc0201f4e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f50:	0ce6fc63          	bgeu	a3,a4,ffffffffc0202028 <swap_init+0x41c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f54:	414687b3          	sub	a5,a3,s4
ffffffffc0201f58:	00379693          	slli	a3,a5,0x3
ffffffffc0201f5c:	96be                	add	a3,a3,a5
ffffffffc0201f5e:	068e                	slli	a3,a3,0x3
    return page - pages + nbase;
ffffffffc0201f60:	00005797          	auipc	a5,0x5
ffffffffc0201f64:	e087b783          	ld	a5,-504(a5) # ffffffffc0206d68 <error_string+0x38>
ffffffffc0201f68:	868d                	srai	a3,a3,0x3
ffffffffc0201f6a:	02f686b3          	mul	a3,a3,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0201f6e:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc0201f72:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201f74:	00c69793          	slli	a5,a3,0xc
ffffffffc0201f78:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f7a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201f7c:	22e7fc63          	bgeu	a5,a4,ffffffffc02021b4 <swap_init+0x5a8>
     free_page(pde2page(pd0[0]));
ffffffffc0201f80:	00013797          	auipc	a5,0x13
ffffffffc0201f84:	6207b783          	ld	a5,1568(a5) # ffffffffc02155a0 <va_pa_offset>
ffffffffc0201f88:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f8a:	629c                	ld	a5,0(a3)
ffffffffc0201f8c:	078a                	slli	a5,a5,0x2
ffffffffc0201f8e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f90:	08e7fc63          	bgeu	a5,a4,ffffffffc0202028 <swap_init+0x41c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f94:	414787b3          	sub	a5,a5,s4
ffffffffc0201f98:	00379713          	slli	a4,a5,0x3
ffffffffc0201f9c:	97ba                	add	a5,a5,a4
ffffffffc0201f9e:	078e                	slli	a5,a5,0x3
ffffffffc0201fa0:	953e                	add	a0,a0,a5
ffffffffc0201fa2:	4585                	li	a1,1
ffffffffc0201fa4:	110010ef          	jal	ra,ffffffffc02030b4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fa8:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201fac:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fb0:	078a                	slli	a5,a5,0x2
ffffffffc0201fb2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fb4:	06e7fa63          	bgeu	a5,a4,ffffffffc0202028 <swap_init+0x41c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fb8:	414787b3          	sub	a5,a5,s4
ffffffffc0201fbc:	000cb503          	ld	a0,0(s9)
ffffffffc0201fc0:	00379a13          	slli	s4,a5,0x3
ffffffffc0201fc4:	97d2                	add	a5,a5,s4
ffffffffc0201fc6:	078e                	slli	a5,a5,0x3
     free_page(pde2page(pd1[0]));
ffffffffc0201fc8:	4585                	li	a1,1
ffffffffc0201fca:	953e                	add	a0,a0,a5
ffffffffc0201fcc:	0e8010ef          	jal	ra,ffffffffc02030b4 <free_pages>
     pgdir[0] = 0;
ffffffffc0201fd0:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201fd4:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201fd8:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201fda:	00878a63          	beq	a5,s0,ffffffffc0201fee <swap_init+0x3e2>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201fde:	ff07a703          	lw	a4,-16(a5)
ffffffffc0201fe2:	679c                	ld	a5,8(a5)
ffffffffc0201fe4:	3dfd                	addiw	s11,s11,-1
ffffffffc0201fe6:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201fea:	fe879ae3          	bne	a5,s0,ffffffffc0201fde <swap_init+0x3d2>
     }
     assert(count==0);
ffffffffc0201fee:	1c0d9f63          	bnez	s11,ffffffffc02021cc <swap_init+0x5c0>
     assert(total==0);
ffffffffc0201ff2:	1a0d1163          	bnez	s10,ffffffffc0202194 <swap_init+0x588>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201ff6:	00004517          	auipc	a0,0x4
ffffffffc0201ffa:	f9250513          	addi	a0,a0,-110 # ffffffffc0205f88 <commands+0x1008>
ffffffffc0201ffe:	8cefe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202002:	b9b1                	j	ffffffffc0201c5e <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202004:	4481                	li	s1,0
ffffffffc0202006:	b1c9                	j	ffffffffc0201cc8 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0202008:	00004697          	auipc	a3,0x4
ffffffffc020200c:	d1868693          	addi	a3,a3,-744 # ffffffffc0205d20 <commands+0xda0>
ffffffffc0202010:	00003617          	auipc	a2,0x3
ffffffffc0202014:	69860613          	addi	a2,a2,1688 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202018:	0bd00593          	li	a1,189
ffffffffc020201c:	00004517          	auipc	a0,0x4
ffffffffc0202020:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202024:	9a4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0202028:	bc9ff0ef          	jal	ra,ffffffffc0201bf0 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc020202c:	00004617          	auipc	a2,0x4
ffffffffc0202030:	8a460613          	addi	a2,a2,-1884 # ffffffffc02058d0 <commands+0x950>
ffffffffc0202034:	06200593          	li	a1,98
ffffffffc0202038:	00004517          	auipc	a0,0x4
ffffffffc020203c:	8b850513          	addi	a0,a0,-1864 # ffffffffc02058f0 <commands+0x970>
ffffffffc0202040:	988fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202044:	00004697          	auipc	a3,0x4
ffffffffc0202048:	ecc68693          	addi	a3,a3,-308 # ffffffffc0205f10 <commands+0xf90>
ffffffffc020204c:	00003617          	auipc	a2,0x3
ffffffffc0202050:	65c60613          	addi	a2,a2,1628 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202054:	0fd00593          	li	a1,253
ffffffffc0202058:	00004517          	auipc	a0,0x4
ffffffffc020205c:	ca050513          	addi	a0,a0,-864 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202060:	968fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202064:	00004697          	auipc	a3,0x4
ffffffffc0202068:	da468693          	addi	a3,a3,-604 # ffffffffc0205e08 <commands+0xe88>
ffffffffc020206c:	00003617          	auipc	a2,0x3
ffffffffc0202070:	63c60613          	addi	a2,a2,1596 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202074:	0dd00593          	li	a1,221
ffffffffc0202078:	00004517          	auipc	a0,0x4
ffffffffc020207c:	c8050513          	addi	a0,a0,-896 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202080:	948fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202084:	00004617          	auipc	a2,0x4
ffffffffc0202088:	c5460613          	addi	a2,a2,-940 # ffffffffc0205cd8 <commands+0xd58>
ffffffffc020208c:	02a00593          	li	a1,42
ffffffffc0202090:	00004517          	auipc	a0,0x4
ffffffffc0202094:	c6850513          	addi	a0,a0,-920 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202098:	930fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020209c:	00004697          	auipc	a3,0x4
ffffffffc02020a0:	e3468693          	addi	a3,a3,-460 # ffffffffc0205ed0 <commands+0xf50>
ffffffffc02020a4:	00003617          	auipc	a2,0x3
ffffffffc02020a8:	60460613          	addi	a2,a2,1540 # ffffffffc02056a8 <commands+0x728>
ffffffffc02020ac:	0fc00593          	li	a1,252
ffffffffc02020b0:	00004517          	auipc	a0,0x4
ffffffffc02020b4:	c4850513          	addi	a0,a0,-952 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc02020b8:	910fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02020bc:	00004617          	auipc	a2,0x4
ffffffffc02020c0:	e2c60613          	addi	a2,a2,-468 # ffffffffc0205ee8 <commands+0xf68>
ffffffffc02020c4:	07400593          	li	a1,116
ffffffffc02020c8:	00004517          	auipc	a0,0x4
ffffffffc02020cc:	82850513          	addi	a0,a0,-2008 # ffffffffc02058f0 <commands+0x970>
ffffffffc02020d0:	8f8fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02020d4:	00004697          	auipc	a3,0x4
ffffffffc02020d8:	d4c68693          	addi	a3,a3,-692 # ffffffffc0205e20 <commands+0xea0>
ffffffffc02020dc:	00003617          	auipc	a2,0x3
ffffffffc02020e0:	5cc60613          	addi	a2,a2,1484 # ffffffffc02056a8 <commands+0x728>
ffffffffc02020e4:	0de00593          	li	a1,222
ffffffffc02020e8:	00004517          	auipc	a0,0x4
ffffffffc02020ec:	c1050513          	addi	a0,a0,-1008 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc02020f0:	8d8fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02020f4:	00004697          	auipc	a3,0x4
ffffffffc02020f8:	c8468693          	addi	a3,a3,-892 # ffffffffc0205d78 <commands+0xdf8>
ffffffffc02020fc:	00003617          	auipc	a2,0x3
ffffffffc0202100:	5ac60613          	addi	a2,a2,1452 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202104:	0c800593          	li	a1,200
ffffffffc0202108:	00004517          	auipc	a0,0x4
ffffffffc020210c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202110:	8b8fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202114:	00004697          	auipc	a3,0x4
ffffffffc0202118:	c1c68693          	addi	a3,a3,-996 # ffffffffc0205d30 <commands+0xdb0>
ffffffffc020211c:	00003617          	auipc	a2,0x3
ffffffffc0202120:	58c60613          	addi	a2,a2,1420 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202124:	0c000593          	li	a1,192
ffffffffc0202128:	00004517          	auipc	a0,0x4
ffffffffc020212c:	bd050513          	addi	a0,a0,-1072 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202130:	898fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert( nr_free == 0);         
ffffffffc0202134:	00004697          	auipc	a3,0x4
ffffffffc0202138:	d8c68693          	addi	a3,a3,-628 # ffffffffc0205ec0 <commands+0xf40>
ffffffffc020213c:	00003617          	auipc	a2,0x3
ffffffffc0202140:	56c60613          	addi	a2,a2,1388 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202144:	0f400593          	li	a1,244
ffffffffc0202148:	00004517          	auipc	a0,0x4
ffffffffc020214c:	bb050513          	addi	a0,a0,-1104 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202150:	878fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202154:	00003697          	auipc	a3,0x3
ffffffffc0202158:	73c68693          	addi	a3,a3,1852 # ffffffffc0205890 <commands+0x910>
ffffffffc020215c:	00003617          	auipc	a2,0x3
ffffffffc0202160:	54c60613          	addi	a2,a2,1356 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202164:	0cd00593          	li	a1,205
ffffffffc0202168:	00004517          	auipc	a0,0x4
ffffffffc020216c:	b9050513          	addi	a0,a0,-1136 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202170:	858fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(mm != NULL);
ffffffffc0202174:	00004697          	auipc	a3,0x4
ffffffffc0202178:	83c68693          	addi	a3,a3,-1988 # ffffffffc02059b0 <commands+0xa30>
ffffffffc020217c:	00003617          	auipc	a2,0x3
ffffffffc0202180:	52c60613          	addi	a2,a2,1324 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202184:	0c500593          	li	a1,197
ffffffffc0202188:	00004517          	auipc	a0,0x4
ffffffffc020218c:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202190:	838fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total==0);
ffffffffc0202194:	00004697          	auipc	a3,0x4
ffffffffc0202198:	de468693          	addi	a3,a3,-540 # ffffffffc0205f78 <commands+0xff8>
ffffffffc020219c:	00003617          	auipc	a2,0x3
ffffffffc02021a0:	50c60613          	addi	a2,a2,1292 # ffffffffc02056a8 <commands+0x728>
ffffffffc02021a4:	11d00593          	li	a1,285
ffffffffc02021a8:	00004517          	auipc	a0,0x4
ffffffffc02021ac:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc02021b0:	818fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc02021b4:	00003617          	auipc	a2,0x3
ffffffffc02021b8:	74c60613          	addi	a2,a2,1868 # ffffffffc0205900 <commands+0x980>
ffffffffc02021bc:	06900593          	li	a1,105
ffffffffc02021c0:	00003517          	auipc	a0,0x3
ffffffffc02021c4:	73050513          	addi	a0,a0,1840 # ffffffffc02058f0 <commands+0x970>
ffffffffc02021c8:	800fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(count==0);
ffffffffc02021cc:	00004697          	auipc	a3,0x4
ffffffffc02021d0:	d9c68693          	addi	a3,a3,-612 # ffffffffc0205f68 <commands+0xfe8>
ffffffffc02021d4:	00003617          	auipc	a2,0x3
ffffffffc02021d8:	4d460613          	addi	a2,a2,1236 # ffffffffc02056a8 <commands+0x728>
ffffffffc02021dc:	11c00593          	li	a1,284
ffffffffc02021e0:	00004517          	auipc	a0,0x4
ffffffffc02021e4:	b1850513          	addi	a0,a0,-1256 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc02021e8:	fe1fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc02021ec:	00004697          	auipc	a3,0x4
ffffffffc02021f0:	ca468693          	addi	a3,a3,-860 # ffffffffc0205e90 <commands+0xf10>
ffffffffc02021f4:	00003617          	auipc	a2,0x3
ffffffffc02021f8:	4b460613          	addi	a2,a2,1204 # ffffffffc02056a8 <commands+0x728>
ffffffffc02021fc:	09600593          	li	a1,150
ffffffffc0202200:	00004517          	auipc	a0,0x4
ffffffffc0202204:	af850513          	addi	a0,a0,-1288 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202208:	fc1fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020220c:	00004697          	auipc	a3,0x4
ffffffffc0202210:	c3468693          	addi	a3,a3,-972 # ffffffffc0205e40 <commands+0xec0>
ffffffffc0202214:	00003617          	auipc	a2,0x3
ffffffffc0202218:	49460613          	addi	a2,a2,1172 # ffffffffc02056a8 <commands+0x728>
ffffffffc020221c:	0eb00593          	li	a1,235
ffffffffc0202220:	00004517          	auipc	a0,0x4
ffffffffc0202224:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202228:	fa1fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020222c:	00004697          	auipc	a3,0x4
ffffffffc0202230:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205dc8 <commands+0xe48>
ffffffffc0202234:	00003617          	auipc	a2,0x3
ffffffffc0202238:	47460613          	addi	a2,a2,1140 # ffffffffc02056a8 <commands+0x728>
ffffffffc020223c:	0d800593          	li	a1,216
ffffffffc0202240:	00004517          	auipc	a0,0x4
ffffffffc0202244:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202248:	f81fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(ret==0);
ffffffffc020224c:	00004697          	auipc	a3,0x4
ffffffffc0202250:	d1468693          	addi	a3,a3,-748 # ffffffffc0205f60 <commands+0xfe0>
ffffffffc0202254:	00003617          	auipc	a2,0x3
ffffffffc0202258:	45460613          	addi	a2,a2,1108 # ffffffffc02056a8 <commands+0x728>
ffffffffc020225c:	10300593          	li	a1,259
ffffffffc0202260:	00004517          	auipc	a0,0x4
ffffffffc0202264:	a9850513          	addi	a0,a0,-1384 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202268:	f61fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(vma != NULL);
ffffffffc020226c:	00003697          	auipc	a3,0x3
ffffffffc0202270:	71c68693          	addi	a3,a3,1820 # ffffffffc0205988 <commands+0xa08>
ffffffffc0202274:	00003617          	auipc	a2,0x3
ffffffffc0202278:	43460613          	addi	a2,a2,1076 # ffffffffc02056a8 <commands+0x728>
ffffffffc020227c:	0d000593          	li	a1,208
ffffffffc0202280:	00004517          	auipc	a0,0x4
ffffffffc0202284:	a7850513          	addi	a0,a0,-1416 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202288:	f41fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc020228c:	00003697          	auipc	a3,0x3
ffffffffc0202290:	7fc68693          	addi	a3,a3,2044 # ffffffffc0205a88 <commands+0xb08>
ffffffffc0202294:	00003617          	auipc	a2,0x3
ffffffffc0202298:	41460613          	addi	a2,a2,1044 # ffffffffc02056a8 <commands+0x728>
ffffffffc020229c:	0a000593          	li	a1,160
ffffffffc02022a0:	00004517          	auipc	a0,0x4
ffffffffc02022a4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc02022a8:	f21fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc02022ac:	00003697          	auipc	a3,0x3
ffffffffc02022b0:	7dc68693          	addi	a3,a3,2012 # ffffffffc0205a88 <commands+0xb08>
ffffffffc02022b4:	00003617          	auipc	a2,0x3
ffffffffc02022b8:	3f460613          	addi	a2,a2,1012 # ffffffffc02056a8 <commands+0x728>
ffffffffc02022bc:	0a200593          	li	a1,162
ffffffffc02022c0:	00004517          	auipc	a0,0x4
ffffffffc02022c4:	a3850513          	addi	a0,a0,-1480 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc02022c8:	f01fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc02022cc:	00004697          	auipc	a3,0x4
ffffffffc02022d0:	bd468693          	addi	a3,a3,-1068 # ffffffffc0205ea0 <commands+0xf20>
ffffffffc02022d4:	00003617          	auipc	a2,0x3
ffffffffc02022d8:	3d460613          	addi	a2,a2,980 # ffffffffc02056a8 <commands+0x728>
ffffffffc02022dc:	09800593          	li	a1,152
ffffffffc02022e0:	00004517          	auipc	a0,0x4
ffffffffc02022e4:	a1850513          	addi	a0,a0,-1512 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc02022e8:	ee1fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc02022ec:	00004697          	auipc	a3,0x4
ffffffffc02022f0:	bb468693          	addi	a3,a3,-1100 # ffffffffc0205ea0 <commands+0xf20>
ffffffffc02022f4:	00003617          	auipc	a2,0x3
ffffffffc02022f8:	3b460613          	addi	a2,a2,948 # ffffffffc02056a8 <commands+0x728>
ffffffffc02022fc:	09a00593          	li	a1,154
ffffffffc0202300:	00004517          	auipc	a0,0x4
ffffffffc0202304:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202308:	ec1fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc020230c:	00004697          	auipc	a3,0x4
ffffffffc0202310:	ba468693          	addi	a3,a3,-1116 # ffffffffc0205eb0 <commands+0xf30>
ffffffffc0202314:	00003617          	auipc	a2,0x3
ffffffffc0202318:	39460613          	addi	a2,a2,916 # ffffffffc02056a8 <commands+0x728>
ffffffffc020231c:	09c00593          	li	a1,156
ffffffffc0202320:	00004517          	auipc	a0,0x4
ffffffffc0202324:	9d850513          	addi	a0,a0,-1576 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202328:	ea1fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc020232c:	00004697          	auipc	a3,0x4
ffffffffc0202330:	b8468693          	addi	a3,a3,-1148 # ffffffffc0205eb0 <commands+0xf30>
ffffffffc0202334:	00003617          	auipc	a2,0x3
ffffffffc0202338:	37460613          	addi	a2,a2,884 # ffffffffc02056a8 <commands+0x728>
ffffffffc020233c:	09e00593          	li	a1,158
ffffffffc0202340:	00004517          	auipc	a0,0x4
ffffffffc0202344:	9b850513          	addi	a0,a0,-1608 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202348:	e81fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc020234c:	00004697          	auipc	a3,0x4
ffffffffc0202350:	b4468693          	addi	a3,a3,-1212 # ffffffffc0205e90 <commands+0xf10>
ffffffffc0202354:	00003617          	auipc	a2,0x3
ffffffffc0202358:	35460613          	addi	a2,a2,852 # ffffffffc02056a8 <commands+0x728>
ffffffffc020235c:	09400593          	li	a1,148
ffffffffc0202360:	00004517          	auipc	a0,0x4
ffffffffc0202364:	99850513          	addi	a0,a0,-1640 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202368:	e61fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020236c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020236c:	00013797          	auipc	a5,0x13
ffffffffc0202370:	1fc7b783          	ld	a5,508(a5) # ffffffffc0215568 <sm>
ffffffffc0202374:	6b9c                	ld	a5,16(a5)
ffffffffc0202376:	8782                	jr	a5

ffffffffc0202378 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202378:	00013797          	auipc	a5,0x13
ffffffffc020237c:	1f07b783          	ld	a5,496(a5) # ffffffffc0215568 <sm>
ffffffffc0202380:	739c                	ld	a5,32(a5)
ffffffffc0202382:	8782                	jr	a5

ffffffffc0202384 <swap_out>:
{
ffffffffc0202384:	711d                	addi	sp,sp,-96
ffffffffc0202386:	ec86                	sd	ra,88(sp)
ffffffffc0202388:	e8a2                	sd	s0,80(sp)
ffffffffc020238a:	e4a6                	sd	s1,72(sp)
ffffffffc020238c:	e0ca                	sd	s2,64(sp)
ffffffffc020238e:	fc4e                	sd	s3,56(sp)
ffffffffc0202390:	f852                	sd	s4,48(sp)
ffffffffc0202392:	f456                	sd	s5,40(sp)
ffffffffc0202394:	f05a                	sd	s6,32(sp)
ffffffffc0202396:	ec5e                	sd	s7,24(sp)
ffffffffc0202398:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc020239a:	cde9                	beqz	a1,ffffffffc0202474 <swap_out+0xf0>
ffffffffc020239c:	8a2e                	mv	s4,a1
ffffffffc020239e:	892a                	mv	s2,a0
ffffffffc02023a0:	8ab2                	mv	s5,a2
ffffffffc02023a2:	4401                	li	s0,0
ffffffffc02023a4:	00013997          	auipc	s3,0x13
ffffffffc02023a8:	1c498993          	addi	s3,s3,452 # ffffffffc0215568 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02023ac:	00004b17          	auipc	s6,0x4
ffffffffc02023b0:	c5cb0b13          	addi	s6,s6,-932 # ffffffffc0206008 <commands+0x1088>
                    cprintf("SWAP: failed to save\n");
ffffffffc02023b4:	00004b97          	auipc	s7,0x4
ffffffffc02023b8:	c3cb8b93          	addi	s7,s7,-964 # ffffffffc0205ff0 <commands+0x1070>
ffffffffc02023bc:	a825                	j	ffffffffc02023f4 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02023be:	67a2                	ld	a5,8(sp)
ffffffffc02023c0:	8626                	mv	a2,s1
ffffffffc02023c2:	85a2                	mv	a1,s0
ffffffffc02023c4:	63b4                	ld	a3,64(a5)
ffffffffc02023c6:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02023c8:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02023ca:	82b1                	srli	a3,a3,0xc
ffffffffc02023cc:	0685                	addi	a3,a3,1
ffffffffc02023ce:	cfffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02023d2:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02023d4:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02023d6:	613c                	ld	a5,64(a0)
ffffffffc02023d8:	83b1                	srli	a5,a5,0xc
ffffffffc02023da:	0785                	addi	a5,a5,1
ffffffffc02023dc:	07a2                	slli	a5,a5,0x8
ffffffffc02023de:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02023e2:	4d3000ef          	jal	ra,ffffffffc02030b4 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02023e6:	01893503          	ld	a0,24(s2)
ffffffffc02023ea:	85a6                	mv	a1,s1
ffffffffc02023ec:	543010ef          	jal	ra,ffffffffc020412e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02023f0:	048a0d63          	beq	s4,s0,ffffffffc020244a <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02023f4:	0009b783          	ld	a5,0(s3)
ffffffffc02023f8:	8656                	mv	a2,s5
ffffffffc02023fa:	002c                	addi	a1,sp,8
ffffffffc02023fc:	7b9c                	ld	a5,48(a5)
ffffffffc02023fe:	854a                	mv	a0,s2
ffffffffc0202400:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202402:	e12d                	bnez	a0,ffffffffc0202464 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202404:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202406:	01893503          	ld	a0,24(s2)
ffffffffc020240a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020240c:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020240e:	85a6                	mv	a1,s1
ffffffffc0202410:	51f000ef          	jal	ra,ffffffffc020312e <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202414:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202416:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202418:	8b85                	andi	a5,a5,1
ffffffffc020241a:	cfb9                	beqz	a5,ffffffffc0202478 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020241c:	65a2                	ld	a1,8(sp)
ffffffffc020241e:	61bc                	ld	a5,64(a1)
ffffffffc0202420:	83b1                	srli	a5,a5,0xc
ffffffffc0202422:	0785                	addi	a5,a5,1
ffffffffc0202424:	00879513          	slli	a0,a5,0x8
ffffffffc0202428:	697010ef          	jal	ra,ffffffffc02042be <swapfs_write>
ffffffffc020242c:	d949                	beqz	a0,ffffffffc02023be <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020242e:	855e                	mv	a0,s7
ffffffffc0202430:	c9dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202434:	0009b783          	ld	a5,0(s3)
ffffffffc0202438:	6622                	ld	a2,8(sp)
ffffffffc020243a:	4681                	li	a3,0
ffffffffc020243c:	739c                	ld	a5,32(a5)
ffffffffc020243e:	85a6                	mv	a1,s1
ffffffffc0202440:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202442:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202444:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202446:	fa8a17e3          	bne	s4,s0,ffffffffc02023f4 <swap_out+0x70>
}
ffffffffc020244a:	60e6                	ld	ra,88(sp)
ffffffffc020244c:	8522                	mv	a0,s0
ffffffffc020244e:	6446                	ld	s0,80(sp)
ffffffffc0202450:	64a6                	ld	s1,72(sp)
ffffffffc0202452:	6906                	ld	s2,64(sp)
ffffffffc0202454:	79e2                	ld	s3,56(sp)
ffffffffc0202456:	7a42                	ld	s4,48(sp)
ffffffffc0202458:	7aa2                	ld	s5,40(sp)
ffffffffc020245a:	7b02                	ld	s6,32(sp)
ffffffffc020245c:	6be2                	ld	s7,24(sp)
ffffffffc020245e:	6c42                	ld	s8,16(sp)
ffffffffc0202460:	6125                	addi	sp,sp,96
ffffffffc0202462:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202464:	85a2                	mv	a1,s0
ffffffffc0202466:	00004517          	auipc	a0,0x4
ffffffffc020246a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0205fa8 <commands+0x1028>
ffffffffc020246e:	c5ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0202472:	bfe1                	j	ffffffffc020244a <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202474:	4401                	li	s0,0
ffffffffc0202476:	bfd1                	j	ffffffffc020244a <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202478:	00004697          	auipc	a3,0x4
ffffffffc020247c:	b6068693          	addi	a3,a3,-1184 # ffffffffc0205fd8 <commands+0x1058>
ffffffffc0202480:	00003617          	auipc	a2,0x3
ffffffffc0202484:	22860613          	addi	a2,a2,552 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202488:	06900593          	li	a1,105
ffffffffc020248c:	00004517          	auipc	a0,0x4
ffffffffc0202490:	86c50513          	addi	a0,a0,-1940 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc0202494:	d35fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202498 <swap_in>:
{
ffffffffc0202498:	7179                	addi	sp,sp,-48
ffffffffc020249a:	e84a                	sd	s2,16(sp)
ffffffffc020249c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020249e:	4505                	li	a0,1
{
ffffffffc02024a0:	ec26                	sd	s1,24(sp)
ffffffffc02024a2:	e44e                	sd	s3,8(sp)
ffffffffc02024a4:	f406                	sd	ra,40(sp)
ffffffffc02024a6:	f022                	sd	s0,32(sp)
ffffffffc02024a8:	84ae                	mv	s1,a1
ffffffffc02024aa:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02024ac:	377000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
     assert(result!=NULL);
ffffffffc02024b0:	c129                	beqz	a0,ffffffffc02024f2 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02024b2:	842a                	mv	s0,a0
ffffffffc02024b4:	01893503          	ld	a0,24(s2)
ffffffffc02024b8:	4601                	li	a2,0
ffffffffc02024ba:	85a6                	mv	a1,s1
ffffffffc02024bc:	473000ef          	jal	ra,ffffffffc020312e <get_pte>
ffffffffc02024c0:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02024c2:	6108                	ld	a0,0(a0)
ffffffffc02024c4:	85a2                	mv	a1,s0
ffffffffc02024c6:	55f010ef          	jal	ra,ffffffffc0204224 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02024ca:	00093583          	ld	a1,0(s2)
ffffffffc02024ce:	8626                	mv	a2,s1
ffffffffc02024d0:	00004517          	auipc	a0,0x4
ffffffffc02024d4:	b8850513          	addi	a0,a0,-1144 # ffffffffc0206058 <commands+0x10d8>
ffffffffc02024d8:	81a1                	srli	a1,a1,0x8
ffffffffc02024da:	bf3fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02024de:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02024e0:	0089b023          	sd	s0,0(s3)
}
ffffffffc02024e4:	7402                	ld	s0,32(sp)
ffffffffc02024e6:	64e2                	ld	s1,24(sp)
ffffffffc02024e8:	6942                	ld	s2,16(sp)
ffffffffc02024ea:	69a2                	ld	s3,8(sp)
ffffffffc02024ec:	4501                	li	a0,0
ffffffffc02024ee:	6145                	addi	sp,sp,48
ffffffffc02024f0:	8082                	ret
     assert(result!=NULL);
ffffffffc02024f2:	00004697          	auipc	a3,0x4
ffffffffc02024f6:	b5668693          	addi	a3,a3,-1194 # ffffffffc0206048 <commands+0x10c8>
ffffffffc02024fa:	00003617          	auipc	a2,0x3
ffffffffc02024fe:	1ae60613          	addi	a2,a2,430 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202502:	07f00593          	li	a1,127
ffffffffc0202506:	00003517          	auipc	a0,0x3
ffffffffc020250a:	7f250513          	addi	a0,a0,2034 # ffffffffc0205cf8 <commands+0xd78>
ffffffffc020250e:	cbbfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202512 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202512:	0000f797          	auipc	a5,0xf
ffffffffc0202516:	fd678793          	addi	a5,a5,-42 # ffffffffc02114e8 <free_area>
ffffffffc020251a:	e79c                	sd	a5,8(a5)
ffffffffc020251c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020251e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202522:	8082                	ret

ffffffffc0202524 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202524:	0000f517          	auipc	a0,0xf
ffffffffc0202528:	fd456503          	lwu	a0,-44(a0) # ffffffffc02114f8 <free_area+0x10>
ffffffffc020252c:	8082                	ret

ffffffffc020252e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020252e:	715d                	addi	sp,sp,-80
ffffffffc0202530:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202532:	0000f417          	auipc	s0,0xf
ffffffffc0202536:	fb640413          	addi	s0,s0,-74 # ffffffffc02114e8 <free_area>
ffffffffc020253a:	641c                	ld	a5,8(s0)
ffffffffc020253c:	e486                	sd	ra,72(sp)
ffffffffc020253e:	fc26                	sd	s1,56(sp)
ffffffffc0202540:	f84a                	sd	s2,48(sp)
ffffffffc0202542:	f44e                	sd	s3,40(sp)
ffffffffc0202544:	f052                	sd	s4,32(sp)
ffffffffc0202546:	ec56                	sd	s5,24(sp)
ffffffffc0202548:	e85a                	sd	s6,16(sp)
ffffffffc020254a:	e45e                	sd	s7,8(sp)
ffffffffc020254c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020254e:	2c878763          	beq	a5,s0,ffffffffc020281c <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0202552:	4481                	li	s1,0
ffffffffc0202554:	4901                	li	s2,0
ffffffffc0202556:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020255a:	8b09                	andi	a4,a4,2
ffffffffc020255c:	2c070463          	beqz	a4,ffffffffc0202824 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0202560:	ff07a703          	lw	a4,-16(a5)
ffffffffc0202564:	679c                	ld	a5,8(a5)
ffffffffc0202566:	2905                	addiw	s2,s2,1
ffffffffc0202568:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020256a:	fe8796e3          	bne	a5,s0,ffffffffc0202556 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020256e:	89a6                	mv	s3,s1
ffffffffc0202570:	385000ef          	jal	ra,ffffffffc02030f4 <nr_free_pages>
ffffffffc0202574:	71351863          	bne	a0,s3,ffffffffc0202c84 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202578:	4505                	li	a0,1
ffffffffc020257a:	2a9000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020257e:	8a2a                	mv	s4,a0
ffffffffc0202580:	44050263          	beqz	a0,ffffffffc02029c4 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202584:	4505                	li	a0,1
ffffffffc0202586:	29d000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020258a:	89aa                	mv	s3,a0
ffffffffc020258c:	70050c63          	beqz	a0,ffffffffc0202ca4 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202590:	4505                	li	a0,1
ffffffffc0202592:	291000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0202596:	8aaa                	mv	s5,a0
ffffffffc0202598:	4a050663          	beqz	a0,ffffffffc0202a44 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020259c:	2b3a0463          	beq	s4,s3,ffffffffc0202844 <default_check+0x316>
ffffffffc02025a0:	2aaa0263          	beq	s4,a0,ffffffffc0202844 <default_check+0x316>
ffffffffc02025a4:	2aa98063          	beq	s3,a0,ffffffffc0202844 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02025a8:	000a2783          	lw	a5,0(s4)
ffffffffc02025ac:	2a079c63          	bnez	a5,ffffffffc0202864 <default_check+0x336>
ffffffffc02025b0:	0009a783          	lw	a5,0(s3)
ffffffffc02025b4:	2a079863          	bnez	a5,ffffffffc0202864 <default_check+0x336>
ffffffffc02025b8:	411c                	lw	a5,0(a0)
ffffffffc02025ba:	2a079563          	bnez	a5,ffffffffc0202864 <default_check+0x336>
    return page - pages + nbase;
ffffffffc02025be:	00013797          	auipc	a5,0x13
ffffffffc02025c2:	fd27b783          	ld	a5,-46(a5) # ffffffffc0215590 <pages>
ffffffffc02025c6:	40fa0733          	sub	a4,s4,a5
ffffffffc02025ca:	870d                	srai	a4,a4,0x3
ffffffffc02025cc:	00004597          	auipc	a1,0x4
ffffffffc02025d0:	79c5b583          	ld	a1,1948(a1) # ffffffffc0206d68 <error_string+0x38>
ffffffffc02025d4:	02b70733          	mul	a4,a4,a1
ffffffffc02025d8:	00004617          	auipc	a2,0x4
ffffffffc02025dc:	79863603          	ld	a2,1944(a2) # ffffffffc0206d70 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02025e0:	00013697          	auipc	a3,0x13
ffffffffc02025e4:	fa86b683          	ld	a3,-88(a3) # ffffffffc0215588 <npage>
ffffffffc02025e8:	06b2                	slli	a3,a3,0xc
ffffffffc02025ea:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02025ec:	0732                	slli	a4,a4,0xc
ffffffffc02025ee:	28d77b63          	bgeu	a4,a3,ffffffffc0202884 <default_check+0x356>
    return page - pages + nbase;
ffffffffc02025f2:	40f98733          	sub	a4,s3,a5
ffffffffc02025f6:	870d                	srai	a4,a4,0x3
ffffffffc02025f8:	02b70733          	mul	a4,a4,a1
ffffffffc02025fc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02025fe:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202600:	4cd77263          	bgeu	a4,a3,ffffffffc0202ac4 <default_check+0x596>
    return page - pages + nbase;
ffffffffc0202604:	40f507b3          	sub	a5,a0,a5
ffffffffc0202608:	878d                	srai	a5,a5,0x3
ffffffffc020260a:	02b787b3          	mul	a5,a5,a1
ffffffffc020260e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202610:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202612:	30d7f963          	bgeu	a5,a3,ffffffffc0202924 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0202616:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202618:	00043c03          	ld	s8,0(s0)
ffffffffc020261c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202620:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202624:	e400                	sd	s0,8(s0)
ffffffffc0202626:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202628:	0000f797          	auipc	a5,0xf
ffffffffc020262c:	ec07a823          	sw	zero,-304(a5) # ffffffffc02114f8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202630:	1f3000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0202634:	2c051863          	bnez	a0,ffffffffc0202904 <default_check+0x3d6>
    free_page(p0);
ffffffffc0202638:	4585                	li	a1,1
ffffffffc020263a:	8552                	mv	a0,s4
ffffffffc020263c:	279000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    free_page(p1);
ffffffffc0202640:	4585                	li	a1,1
ffffffffc0202642:	854e                	mv	a0,s3
ffffffffc0202644:	271000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    free_page(p2);
ffffffffc0202648:	4585                	li	a1,1
ffffffffc020264a:	8556                	mv	a0,s5
ffffffffc020264c:	269000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    assert(nr_free == 3);
ffffffffc0202650:	4818                	lw	a4,16(s0)
ffffffffc0202652:	478d                	li	a5,3
ffffffffc0202654:	28f71863          	bne	a4,a5,ffffffffc02028e4 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202658:	4505                	li	a0,1
ffffffffc020265a:	1c9000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020265e:	89aa                	mv	s3,a0
ffffffffc0202660:	26050263          	beqz	a0,ffffffffc02028c4 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202664:	4505                	li	a0,1
ffffffffc0202666:	1bd000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020266a:	8aaa                	mv	s5,a0
ffffffffc020266c:	3a050c63          	beqz	a0,ffffffffc0202a24 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202670:	4505                	li	a0,1
ffffffffc0202672:	1b1000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0202676:	8a2a                	mv	s4,a0
ffffffffc0202678:	38050663          	beqz	a0,ffffffffc0202a04 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc020267c:	4505                	li	a0,1
ffffffffc020267e:	1a5000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0202682:	36051163          	bnez	a0,ffffffffc02029e4 <default_check+0x4b6>
    free_page(p0);
ffffffffc0202686:	4585                	li	a1,1
ffffffffc0202688:	854e                	mv	a0,s3
ffffffffc020268a:	22b000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020268e:	641c                	ld	a5,8(s0)
ffffffffc0202690:	20878a63          	beq	a5,s0,ffffffffc02028a4 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0202694:	4505                	li	a0,1
ffffffffc0202696:	18d000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020269a:	30a99563          	bne	s3,a0,ffffffffc02029a4 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc020269e:	4505                	li	a0,1
ffffffffc02026a0:	183000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc02026a4:	2e051063          	bnez	a0,ffffffffc0202984 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc02026a8:	481c                	lw	a5,16(s0)
ffffffffc02026aa:	2a079d63          	bnez	a5,ffffffffc0202964 <default_check+0x436>
    free_page(p);
ffffffffc02026ae:	854e                	mv	a0,s3
ffffffffc02026b0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02026b2:	01843023          	sd	s8,0(s0)
ffffffffc02026b6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02026ba:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02026be:	1f7000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    free_page(p1);
ffffffffc02026c2:	4585                	li	a1,1
ffffffffc02026c4:	8556                	mv	a0,s5
ffffffffc02026c6:	1ef000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    free_page(p2);
ffffffffc02026ca:	4585                	li	a1,1
ffffffffc02026cc:	8552                	mv	a0,s4
ffffffffc02026ce:	1e7000ef          	jal	ra,ffffffffc02030b4 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02026d2:	4515                	li	a0,5
ffffffffc02026d4:	14f000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc02026d8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02026da:	26050563          	beqz	a0,ffffffffc0202944 <default_check+0x416>
ffffffffc02026de:	651c                	ld	a5,8(a0)
ffffffffc02026e0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02026e2:	8b85                	andi	a5,a5,1
ffffffffc02026e4:	54079063          	bnez	a5,ffffffffc0202c24 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02026e8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02026ea:	00043b03          	ld	s6,0(s0)
ffffffffc02026ee:	00843a83          	ld	s5,8(s0)
ffffffffc02026f2:	e000                	sd	s0,0(s0)
ffffffffc02026f4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02026f6:	12d000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc02026fa:	50051563          	bnez	a0,ffffffffc0202c04 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02026fe:	09098a13          	addi	s4,s3,144
ffffffffc0202702:	8552                	mv	a0,s4
ffffffffc0202704:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202706:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc020270a:	0000f797          	auipc	a5,0xf
ffffffffc020270e:	de07a723          	sw	zero,-530(a5) # ffffffffc02114f8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202712:	1a3000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202716:	4511                	li	a0,4
ffffffffc0202718:	10b000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020271c:	4c051463          	bnez	a0,ffffffffc0202be4 <default_check+0x6b6>
ffffffffc0202720:	0989b783          	ld	a5,152(s3)
ffffffffc0202724:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202726:	8b85                	andi	a5,a5,1
ffffffffc0202728:	48078e63          	beqz	a5,ffffffffc0202bc4 <default_check+0x696>
ffffffffc020272c:	0a09a703          	lw	a4,160(s3)
ffffffffc0202730:	478d                	li	a5,3
ffffffffc0202732:	48f71963          	bne	a4,a5,ffffffffc0202bc4 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202736:	450d                	li	a0,3
ffffffffc0202738:	0eb000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020273c:	8c2a                	mv	s8,a0
ffffffffc020273e:	46050363          	beqz	a0,ffffffffc0202ba4 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0202742:	4505                	li	a0,1
ffffffffc0202744:	0df000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0202748:	42051e63          	bnez	a0,ffffffffc0202b84 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc020274c:	418a1c63          	bne	s4,s8,ffffffffc0202b64 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202750:	4585                	li	a1,1
ffffffffc0202752:	854e                	mv	a0,s3
ffffffffc0202754:	161000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    free_pages(p1, 3);
ffffffffc0202758:	458d                	li	a1,3
ffffffffc020275a:	8552                	mv	a0,s4
ffffffffc020275c:	159000ef          	jal	ra,ffffffffc02030b4 <free_pages>
ffffffffc0202760:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202764:	04898c13          	addi	s8,s3,72
ffffffffc0202768:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020276a:	8b85                	andi	a5,a5,1
ffffffffc020276c:	3c078c63          	beqz	a5,ffffffffc0202b44 <default_check+0x616>
ffffffffc0202770:	0109a703          	lw	a4,16(s3)
ffffffffc0202774:	4785                	li	a5,1
ffffffffc0202776:	3cf71763          	bne	a4,a5,ffffffffc0202b44 <default_check+0x616>
ffffffffc020277a:	008a3783          	ld	a5,8(s4)
ffffffffc020277e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202780:	8b85                	andi	a5,a5,1
ffffffffc0202782:	3a078163          	beqz	a5,ffffffffc0202b24 <default_check+0x5f6>
ffffffffc0202786:	010a2703          	lw	a4,16(s4)
ffffffffc020278a:	478d                	li	a5,3
ffffffffc020278c:	38f71c63          	bne	a4,a5,ffffffffc0202b24 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202790:	4505                	li	a0,1
ffffffffc0202792:	091000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0202796:	36a99763          	bne	s3,a0,ffffffffc0202b04 <default_check+0x5d6>
    free_page(p0);
ffffffffc020279a:	4585                	li	a1,1
ffffffffc020279c:	119000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02027a0:	4509                	li	a0,2
ffffffffc02027a2:	081000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc02027a6:	32aa1f63          	bne	s4,a0,ffffffffc0202ae4 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc02027aa:	4589                	li	a1,2
ffffffffc02027ac:	109000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    free_page(p2);
ffffffffc02027b0:	4585                	li	a1,1
ffffffffc02027b2:	8562                	mv	a0,s8
ffffffffc02027b4:	101000ef          	jal	ra,ffffffffc02030b4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02027b8:	4515                	li	a0,5
ffffffffc02027ba:	069000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc02027be:	89aa                	mv	s3,a0
ffffffffc02027c0:	48050263          	beqz	a0,ffffffffc0202c44 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc02027c4:	4505                	li	a0,1
ffffffffc02027c6:	05d000ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc02027ca:	2c051d63          	bnez	a0,ffffffffc0202aa4 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc02027ce:	481c                	lw	a5,16(s0)
ffffffffc02027d0:	2a079a63          	bnez	a5,ffffffffc0202a84 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02027d4:	4595                	li	a1,5
ffffffffc02027d6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02027d8:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02027dc:	01643023          	sd	s6,0(s0)
ffffffffc02027e0:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02027e4:	0d1000ef          	jal	ra,ffffffffc02030b4 <free_pages>
    return listelm->next;
ffffffffc02027e8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027ea:	00878963          	beq	a5,s0,ffffffffc02027fc <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02027ee:	ff07a703          	lw	a4,-16(a5)
ffffffffc02027f2:	679c                	ld	a5,8(a5)
ffffffffc02027f4:	397d                	addiw	s2,s2,-1
ffffffffc02027f6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027f8:	fe879be3          	bne	a5,s0,ffffffffc02027ee <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc02027fc:	26091463          	bnez	s2,ffffffffc0202a64 <default_check+0x536>
    assert(total == 0);
ffffffffc0202800:	46049263          	bnez	s1,ffffffffc0202c64 <default_check+0x736>
}
ffffffffc0202804:	60a6                	ld	ra,72(sp)
ffffffffc0202806:	6406                	ld	s0,64(sp)
ffffffffc0202808:	74e2                	ld	s1,56(sp)
ffffffffc020280a:	7942                	ld	s2,48(sp)
ffffffffc020280c:	79a2                	ld	s3,40(sp)
ffffffffc020280e:	7a02                	ld	s4,32(sp)
ffffffffc0202810:	6ae2                	ld	s5,24(sp)
ffffffffc0202812:	6b42                	ld	s6,16(sp)
ffffffffc0202814:	6ba2                	ld	s7,8(sp)
ffffffffc0202816:	6c02                	ld	s8,0(sp)
ffffffffc0202818:	6161                	addi	sp,sp,80
ffffffffc020281a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020281c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020281e:	4481                	li	s1,0
ffffffffc0202820:	4901                	li	s2,0
ffffffffc0202822:	b3b9                	j	ffffffffc0202570 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202824:	00003697          	auipc	a3,0x3
ffffffffc0202828:	4fc68693          	addi	a3,a3,1276 # ffffffffc0205d20 <commands+0xda0>
ffffffffc020282c:	00003617          	auipc	a2,0x3
ffffffffc0202830:	e7c60613          	addi	a2,a2,-388 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202834:	0f000593          	li	a1,240
ffffffffc0202838:	00004517          	auipc	a0,0x4
ffffffffc020283c:	86050513          	addi	a0,a0,-1952 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202840:	989fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202844:	00004697          	auipc	a3,0x4
ffffffffc0202848:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0206110 <commands+0x1190>
ffffffffc020284c:	00003617          	auipc	a2,0x3
ffffffffc0202850:	e5c60613          	addi	a2,a2,-420 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202854:	0bd00593          	li	a1,189
ffffffffc0202858:	00004517          	auipc	a0,0x4
ffffffffc020285c:	84050513          	addi	a0,a0,-1984 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202860:	969fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202864:	00004697          	auipc	a3,0x4
ffffffffc0202868:	8d468693          	addi	a3,a3,-1836 # ffffffffc0206138 <commands+0x11b8>
ffffffffc020286c:	00003617          	auipc	a2,0x3
ffffffffc0202870:	e3c60613          	addi	a2,a2,-452 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202874:	0be00593          	li	a1,190
ffffffffc0202878:	00004517          	auipc	a0,0x4
ffffffffc020287c:	82050513          	addi	a0,a0,-2016 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202880:	949fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202884:	00004697          	auipc	a3,0x4
ffffffffc0202888:	8f468693          	addi	a3,a3,-1804 # ffffffffc0206178 <commands+0x11f8>
ffffffffc020288c:	00003617          	auipc	a2,0x3
ffffffffc0202890:	e1c60613          	addi	a2,a2,-484 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202894:	0c000593          	li	a1,192
ffffffffc0202898:	00004517          	auipc	a0,0x4
ffffffffc020289c:	80050513          	addi	a0,a0,-2048 # ffffffffc0206098 <commands+0x1118>
ffffffffc02028a0:	929fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02028a4:	00004697          	auipc	a3,0x4
ffffffffc02028a8:	95c68693          	addi	a3,a3,-1700 # ffffffffc0206200 <commands+0x1280>
ffffffffc02028ac:	00003617          	auipc	a2,0x3
ffffffffc02028b0:	dfc60613          	addi	a2,a2,-516 # ffffffffc02056a8 <commands+0x728>
ffffffffc02028b4:	0d900593          	li	a1,217
ffffffffc02028b8:	00003517          	auipc	a0,0x3
ffffffffc02028bc:	7e050513          	addi	a0,a0,2016 # ffffffffc0206098 <commands+0x1118>
ffffffffc02028c0:	909fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02028c4:	00003697          	auipc	a3,0x3
ffffffffc02028c8:	7ec68693          	addi	a3,a3,2028 # ffffffffc02060b0 <commands+0x1130>
ffffffffc02028cc:	00003617          	auipc	a2,0x3
ffffffffc02028d0:	ddc60613          	addi	a2,a2,-548 # ffffffffc02056a8 <commands+0x728>
ffffffffc02028d4:	0d200593          	li	a1,210
ffffffffc02028d8:	00003517          	auipc	a0,0x3
ffffffffc02028dc:	7c050513          	addi	a0,a0,1984 # ffffffffc0206098 <commands+0x1118>
ffffffffc02028e0:	8e9fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 3);
ffffffffc02028e4:	00004697          	auipc	a3,0x4
ffffffffc02028e8:	90c68693          	addi	a3,a3,-1780 # ffffffffc02061f0 <commands+0x1270>
ffffffffc02028ec:	00003617          	auipc	a2,0x3
ffffffffc02028f0:	dbc60613          	addi	a2,a2,-580 # ffffffffc02056a8 <commands+0x728>
ffffffffc02028f4:	0d000593          	li	a1,208
ffffffffc02028f8:	00003517          	auipc	a0,0x3
ffffffffc02028fc:	7a050513          	addi	a0,a0,1952 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202900:	8c9fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202904:	00004697          	auipc	a3,0x4
ffffffffc0202908:	8d468693          	addi	a3,a3,-1836 # ffffffffc02061d8 <commands+0x1258>
ffffffffc020290c:	00003617          	auipc	a2,0x3
ffffffffc0202910:	d9c60613          	addi	a2,a2,-612 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202914:	0cb00593          	li	a1,203
ffffffffc0202918:	00003517          	auipc	a0,0x3
ffffffffc020291c:	78050513          	addi	a0,a0,1920 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202920:	8a9fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202924:	00004697          	auipc	a3,0x4
ffffffffc0202928:	89468693          	addi	a3,a3,-1900 # ffffffffc02061b8 <commands+0x1238>
ffffffffc020292c:	00003617          	auipc	a2,0x3
ffffffffc0202930:	d7c60613          	addi	a2,a2,-644 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202934:	0c200593          	li	a1,194
ffffffffc0202938:	00003517          	auipc	a0,0x3
ffffffffc020293c:	76050513          	addi	a0,a0,1888 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202940:	889fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != NULL);
ffffffffc0202944:	00004697          	auipc	a3,0x4
ffffffffc0202948:	8f468693          	addi	a3,a3,-1804 # ffffffffc0206238 <commands+0x12b8>
ffffffffc020294c:	00003617          	auipc	a2,0x3
ffffffffc0202950:	d5c60613          	addi	a2,a2,-676 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202954:	0f800593          	li	a1,248
ffffffffc0202958:	00003517          	auipc	a0,0x3
ffffffffc020295c:	74050513          	addi	a0,a0,1856 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202960:	869fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0202964:	00003697          	auipc	a3,0x3
ffffffffc0202968:	55c68693          	addi	a3,a3,1372 # ffffffffc0205ec0 <commands+0xf40>
ffffffffc020296c:	00003617          	auipc	a2,0x3
ffffffffc0202970:	d3c60613          	addi	a2,a2,-708 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202974:	0df00593          	li	a1,223
ffffffffc0202978:	00003517          	auipc	a0,0x3
ffffffffc020297c:	72050513          	addi	a0,a0,1824 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202980:	849fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202984:	00004697          	auipc	a3,0x4
ffffffffc0202988:	85468693          	addi	a3,a3,-1964 # ffffffffc02061d8 <commands+0x1258>
ffffffffc020298c:	00003617          	auipc	a2,0x3
ffffffffc0202990:	d1c60613          	addi	a2,a2,-740 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202994:	0dd00593          	li	a1,221
ffffffffc0202998:	00003517          	auipc	a0,0x3
ffffffffc020299c:	70050513          	addi	a0,a0,1792 # ffffffffc0206098 <commands+0x1118>
ffffffffc02029a0:	829fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02029a4:	00004697          	auipc	a3,0x4
ffffffffc02029a8:	87468693          	addi	a3,a3,-1932 # ffffffffc0206218 <commands+0x1298>
ffffffffc02029ac:	00003617          	auipc	a2,0x3
ffffffffc02029b0:	cfc60613          	addi	a2,a2,-772 # ffffffffc02056a8 <commands+0x728>
ffffffffc02029b4:	0dc00593          	li	a1,220
ffffffffc02029b8:	00003517          	auipc	a0,0x3
ffffffffc02029bc:	6e050513          	addi	a0,a0,1760 # ffffffffc0206098 <commands+0x1118>
ffffffffc02029c0:	809fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02029c4:	00003697          	auipc	a3,0x3
ffffffffc02029c8:	6ec68693          	addi	a3,a3,1772 # ffffffffc02060b0 <commands+0x1130>
ffffffffc02029cc:	00003617          	auipc	a2,0x3
ffffffffc02029d0:	cdc60613          	addi	a2,a2,-804 # ffffffffc02056a8 <commands+0x728>
ffffffffc02029d4:	0b900593          	li	a1,185
ffffffffc02029d8:	00003517          	auipc	a0,0x3
ffffffffc02029dc:	6c050513          	addi	a0,a0,1728 # ffffffffc0206098 <commands+0x1118>
ffffffffc02029e0:	fe8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02029e4:	00003697          	auipc	a3,0x3
ffffffffc02029e8:	7f468693          	addi	a3,a3,2036 # ffffffffc02061d8 <commands+0x1258>
ffffffffc02029ec:	00003617          	auipc	a2,0x3
ffffffffc02029f0:	cbc60613          	addi	a2,a2,-836 # ffffffffc02056a8 <commands+0x728>
ffffffffc02029f4:	0d600593          	li	a1,214
ffffffffc02029f8:	00003517          	auipc	a0,0x3
ffffffffc02029fc:	6a050513          	addi	a0,a0,1696 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202a00:	fc8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202a04:	00003697          	auipc	a3,0x3
ffffffffc0202a08:	6ec68693          	addi	a3,a3,1772 # ffffffffc02060f0 <commands+0x1170>
ffffffffc0202a0c:	00003617          	auipc	a2,0x3
ffffffffc0202a10:	c9c60613          	addi	a2,a2,-868 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202a14:	0d400593          	li	a1,212
ffffffffc0202a18:	00003517          	auipc	a0,0x3
ffffffffc0202a1c:	68050513          	addi	a0,a0,1664 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202a20:	fa8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202a24:	00003697          	auipc	a3,0x3
ffffffffc0202a28:	6ac68693          	addi	a3,a3,1708 # ffffffffc02060d0 <commands+0x1150>
ffffffffc0202a2c:	00003617          	auipc	a2,0x3
ffffffffc0202a30:	c7c60613          	addi	a2,a2,-900 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202a34:	0d300593          	li	a1,211
ffffffffc0202a38:	00003517          	auipc	a0,0x3
ffffffffc0202a3c:	66050513          	addi	a0,a0,1632 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202a40:	f88fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202a44:	00003697          	auipc	a3,0x3
ffffffffc0202a48:	6ac68693          	addi	a3,a3,1708 # ffffffffc02060f0 <commands+0x1170>
ffffffffc0202a4c:	00003617          	auipc	a2,0x3
ffffffffc0202a50:	c5c60613          	addi	a2,a2,-932 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202a54:	0bb00593          	li	a1,187
ffffffffc0202a58:	00003517          	auipc	a0,0x3
ffffffffc0202a5c:	64050513          	addi	a0,a0,1600 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202a60:	f68fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(count == 0);
ffffffffc0202a64:	00004697          	auipc	a3,0x4
ffffffffc0202a68:	92468693          	addi	a3,a3,-1756 # ffffffffc0206388 <commands+0x1408>
ffffffffc0202a6c:	00003617          	auipc	a2,0x3
ffffffffc0202a70:	c3c60613          	addi	a2,a2,-964 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202a74:	12500593          	li	a1,293
ffffffffc0202a78:	00003517          	auipc	a0,0x3
ffffffffc0202a7c:	62050513          	addi	a0,a0,1568 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202a80:	f48fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0202a84:	00003697          	auipc	a3,0x3
ffffffffc0202a88:	43c68693          	addi	a3,a3,1084 # ffffffffc0205ec0 <commands+0xf40>
ffffffffc0202a8c:	00003617          	auipc	a2,0x3
ffffffffc0202a90:	c1c60613          	addi	a2,a2,-996 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202a94:	11a00593          	li	a1,282
ffffffffc0202a98:	00003517          	auipc	a0,0x3
ffffffffc0202a9c:	60050513          	addi	a0,a0,1536 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202aa0:	f28fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202aa4:	00003697          	auipc	a3,0x3
ffffffffc0202aa8:	73468693          	addi	a3,a3,1844 # ffffffffc02061d8 <commands+0x1258>
ffffffffc0202aac:	00003617          	auipc	a2,0x3
ffffffffc0202ab0:	bfc60613          	addi	a2,a2,-1028 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202ab4:	11800593          	li	a1,280
ffffffffc0202ab8:	00003517          	auipc	a0,0x3
ffffffffc0202abc:	5e050513          	addi	a0,a0,1504 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202ac0:	f08fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202ac4:	00003697          	auipc	a3,0x3
ffffffffc0202ac8:	6d468693          	addi	a3,a3,1748 # ffffffffc0206198 <commands+0x1218>
ffffffffc0202acc:	00003617          	auipc	a2,0x3
ffffffffc0202ad0:	bdc60613          	addi	a2,a2,-1060 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202ad4:	0c100593          	li	a1,193
ffffffffc0202ad8:	00003517          	auipc	a0,0x3
ffffffffc0202adc:	5c050513          	addi	a0,a0,1472 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202ae0:	ee8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202ae4:	00004697          	auipc	a3,0x4
ffffffffc0202ae8:	86468693          	addi	a3,a3,-1948 # ffffffffc0206348 <commands+0x13c8>
ffffffffc0202aec:	00003617          	auipc	a2,0x3
ffffffffc0202af0:	bbc60613          	addi	a2,a2,-1092 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202af4:	11200593          	li	a1,274
ffffffffc0202af8:	00003517          	auipc	a0,0x3
ffffffffc0202afc:	5a050513          	addi	a0,a0,1440 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202b00:	ec8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202b04:	00004697          	auipc	a3,0x4
ffffffffc0202b08:	82468693          	addi	a3,a3,-2012 # ffffffffc0206328 <commands+0x13a8>
ffffffffc0202b0c:	00003617          	auipc	a2,0x3
ffffffffc0202b10:	b9c60613          	addi	a2,a2,-1124 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202b14:	11000593          	li	a1,272
ffffffffc0202b18:	00003517          	auipc	a0,0x3
ffffffffc0202b1c:	58050513          	addi	a0,a0,1408 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202b20:	ea8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202b24:	00003697          	auipc	a3,0x3
ffffffffc0202b28:	7dc68693          	addi	a3,a3,2012 # ffffffffc0206300 <commands+0x1380>
ffffffffc0202b2c:	00003617          	auipc	a2,0x3
ffffffffc0202b30:	b7c60613          	addi	a2,a2,-1156 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202b34:	10e00593          	li	a1,270
ffffffffc0202b38:	00003517          	auipc	a0,0x3
ffffffffc0202b3c:	56050513          	addi	a0,a0,1376 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202b40:	e88fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202b44:	00003697          	auipc	a3,0x3
ffffffffc0202b48:	79468693          	addi	a3,a3,1940 # ffffffffc02062d8 <commands+0x1358>
ffffffffc0202b4c:	00003617          	auipc	a2,0x3
ffffffffc0202b50:	b5c60613          	addi	a2,a2,-1188 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202b54:	10d00593          	li	a1,269
ffffffffc0202b58:	00003517          	auipc	a0,0x3
ffffffffc0202b5c:	54050513          	addi	a0,a0,1344 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202b60:	e68fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202b64:	00003697          	auipc	a3,0x3
ffffffffc0202b68:	76468693          	addi	a3,a3,1892 # ffffffffc02062c8 <commands+0x1348>
ffffffffc0202b6c:	00003617          	auipc	a2,0x3
ffffffffc0202b70:	b3c60613          	addi	a2,a2,-1220 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202b74:	10800593          	li	a1,264
ffffffffc0202b78:	00003517          	auipc	a0,0x3
ffffffffc0202b7c:	52050513          	addi	a0,a0,1312 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202b80:	e48fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202b84:	00003697          	auipc	a3,0x3
ffffffffc0202b88:	65468693          	addi	a3,a3,1620 # ffffffffc02061d8 <commands+0x1258>
ffffffffc0202b8c:	00003617          	auipc	a2,0x3
ffffffffc0202b90:	b1c60613          	addi	a2,a2,-1252 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202b94:	10700593          	li	a1,263
ffffffffc0202b98:	00003517          	auipc	a0,0x3
ffffffffc0202b9c:	50050513          	addi	a0,a0,1280 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202ba0:	e28fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202ba4:	00003697          	auipc	a3,0x3
ffffffffc0202ba8:	70468693          	addi	a3,a3,1796 # ffffffffc02062a8 <commands+0x1328>
ffffffffc0202bac:	00003617          	auipc	a2,0x3
ffffffffc0202bb0:	afc60613          	addi	a2,a2,-1284 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202bb4:	10600593          	li	a1,262
ffffffffc0202bb8:	00003517          	auipc	a0,0x3
ffffffffc0202bbc:	4e050513          	addi	a0,a0,1248 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202bc0:	e08fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202bc4:	00003697          	auipc	a3,0x3
ffffffffc0202bc8:	6b468693          	addi	a3,a3,1716 # ffffffffc0206278 <commands+0x12f8>
ffffffffc0202bcc:	00003617          	auipc	a2,0x3
ffffffffc0202bd0:	adc60613          	addi	a2,a2,-1316 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202bd4:	10500593          	li	a1,261
ffffffffc0202bd8:	00003517          	auipc	a0,0x3
ffffffffc0202bdc:	4c050513          	addi	a0,a0,1216 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202be0:	de8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202be4:	00003697          	auipc	a3,0x3
ffffffffc0202be8:	67c68693          	addi	a3,a3,1660 # ffffffffc0206260 <commands+0x12e0>
ffffffffc0202bec:	00003617          	auipc	a2,0x3
ffffffffc0202bf0:	abc60613          	addi	a2,a2,-1348 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202bf4:	10400593          	li	a1,260
ffffffffc0202bf8:	00003517          	auipc	a0,0x3
ffffffffc0202bfc:	4a050513          	addi	a0,a0,1184 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202c00:	dc8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202c04:	00003697          	auipc	a3,0x3
ffffffffc0202c08:	5d468693          	addi	a3,a3,1492 # ffffffffc02061d8 <commands+0x1258>
ffffffffc0202c0c:	00003617          	auipc	a2,0x3
ffffffffc0202c10:	a9c60613          	addi	a2,a2,-1380 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202c14:	0fe00593          	li	a1,254
ffffffffc0202c18:	00003517          	auipc	a0,0x3
ffffffffc0202c1c:	48050513          	addi	a0,a0,1152 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202c20:	da8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202c24:	00003697          	auipc	a3,0x3
ffffffffc0202c28:	62468693          	addi	a3,a3,1572 # ffffffffc0206248 <commands+0x12c8>
ffffffffc0202c2c:	00003617          	auipc	a2,0x3
ffffffffc0202c30:	a7c60613          	addi	a2,a2,-1412 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202c34:	0f900593          	li	a1,249
ffffffffc0202c38:	00003517          	auipc	a0,0x3
ffffffffc0202c3c:	46050513          	addi	a0,a0,1120 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202c40:	d88fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202c44:	00003697          	auipc	a3,0x3
ffffffffc0202c48:	72468693          	addi	a3,a3,1828 # ffffffffc0206368 <commands+0x13e8>
ffffffffc0202c4c:	00003617          	auipc	a2,0x3
ffffffffc0202c50:	a5c60613          	addi	a2,a2,-1444 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202c54:	11700593          	li	a1,279
ffffffffc0202c58:	00003517          	auipc	a0,0x3
ffffffffc0202c5c:	44050513          	addi	a0,a0,1088 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202c60:	d68fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == 0);
ffffffffc0202c64:	00003697          	auipc	a3,0x3
ffffffffc0202c68:	73468693          	addi	a3,a3,1844 # ffffffffc0206398 <commands+0x1418>
ffffffffc0202c6c:	00003617          	auipc	a2,0x3
ffffffffc0202c70:	a3c60613          	addi	a2,a2,-1476 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202c74:	12600593          	li	a1,294
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	42050513          	addi	a0,a0,1056 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202c80:	d48fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202c84:	00003697          	auipc	a3,0x3
ffffffffc0202c88:	0ac68693          	addi	a3,a3,172 # ffffffffc0205d30 <commands+0xdb0>
ffffffffc0202c8c:	00003617          	auipc	a2,0x3
ffffffffc0202c90:	a1c60613          	addi	a2,a2,-1508 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202c94:	0f300593          	li	a1,243
ffffffffc0202c98:	00003517          	auipc	a0,0x3
ffffffffc0202c9c:	40050513          	addi	a0,a0,1024 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202ca0:	d28fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202ca4:	00003697          	auipc	a3,0x3
ffffffffc0202ca8:	42c68693          	addi	a3,a3,1068 # ffffffffc02060d0 <commands+0x1150>
ffffffffc0202cac:	00003617          	auipc	a2,0x3
ffffffffc0202cb0:	9fc60613          	addi	a2,a2,-1540 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202cb4:	0ba00593          	li	a1,186
ffffffffc0202cb8:	00003517          	auipc	a0,0x3
ffffffffc0202cbc:	3e050513          	addi	a0,a0,992 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202cc0:	d08fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202cc4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202cc4:	1141                	addi	sp,sp,-16
ffffffffc0202cc6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202cc8:	14058a63          	beqz	a1,ffffffffc0202e1c <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202ccc:	00359693          	slli	a3,a1,0x3
ffffffffc0202cd0:	96ae                	add	a3,a3,a1
ffffffffc0202cd2:	068e                	slli	a3,a3,0x3
ffffffffc0202cd4:	96aa                	add	a3,a3,a0
ffffffffc0202cd6:	87aa                	mv	a5,a0
ffffffffc0202cd8:	02d50263          	beq	a0,a3,ffffffffc0202cfc <default_free_pages+0x38>
ffffffffc0202cdc:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202cde:	8b05                	andi	a4,a4,1
ffffffffc0202ce0:	10071e63          	bnez	a4,ffffffffc0202dfc <default_free_pages+0x138>
ffffffffc0202ce4:	6798                	ld	a4,8(a5)
ffffffffc0202ce6:	8b09                	andi	a4,a4,2
ffffffffc0202ce8:	10071a63          	bnez	a4,ffffffffc0202dfc <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202cec:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0202cf0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202cf4:	04878793          	addi	a5,a5,72
ffffffffc0202cf8:	fed792e3          	bne	a5,a3,ffffffffc0202cdc <default_free_pages+0x18>
    base->property = n;
ffffffffc0202cfc:	2581                	sext.w	a1,a1
ffffffffc0202cfe:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202d00:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202d04:	4789                	li	a5,2
ffffffffc0202d06:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202d0a:	0000e697          	auipc	a3,0xe
ffffffffc0202d0e:	7de68693          	addi	a3,a3,2014 # ffffffffc02114e8 <free_area>
ffffffffc0202d12:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202d14:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202d16:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202d1a:	9db9                	addw	a1,a1,a4
ffffffffc0202d1c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202d1e:	0ad78863          	beq	a5,a3,ffffffffc0202dce <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202d22:	fe078713          	addi	a4,a5,-32
ffffffffc0202d26:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202d2a:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202d2c:	00e56a63          	bltu	a0,a4,ffffffffc0202d40 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0202d30:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202d32:	06d70263          	beq	a4,a3,ffffffffc0202d96 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0202d36:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202d38:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202d3c:	fee57ae3          	bgeu	a0,a4,ffffffffc0202d30 <default_free_pages+0x6c>
ffffffffc0202d40:	c199                	beqz	a1,ffffffffc0202d46 <default_free_pages+0x82>
ffffffffc0202d42:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202d46:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202d48:	e390                	sd	a2,0(a5)
ffffffffc0202d4a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202d4c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202d4e:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc0202d50:	02d70063          	beq	a4,a3,ffffffffc0202d70 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0202d54:	ff072803          	lw	a6,-16(a4)
        p = le2page(le, page_link);
ffffffffc0202d58:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0202d5c:	02081613          	slli	a2,a6,0x20
ffffffffc0202d60:	9201                	srli	a2,a2,0x20
ffffffffc0202d62:	00361793          	slli	a5,a2,0x3
ffffffffc0202d66:	97b2                	add	a5,a5,a2
ffffffffc0202d68:	078e                	slli	a5,a5,0x3
ffffffffc0202d6a:	97ae                	add	a5,a5,a1
ffffffffc0202d6c:	02f50f63          	beq	a0,a5,ffffffffc0202daa <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0202d70:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0202d72:	00d70f63          	beq	a4,a3,ffffffffc0202d90 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0202d76:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0202d78:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0202d7c:	02059613          	slli	a2,a1,0x20
ffffffffc0202d80:	9201                	srli	a2,a2,0x20
ffffffffc0202d82:	00361793          	slli	a5,a2,0x3
ffffffffc0202d86:	97b2                	add	a5,a5,a2
ffffffffc0202d88:	078e                	slli	a5,a5,0x3
ffffffffc0202d8a:	97aa                	add	a5,a5,a0
ffffffffc0202d8c:	04f68863          	beq	a3,a5,ffffffffc0202ddc <default_free_pages+0x118>
}
ffffffffc0202d90:	60a2                	ld	ra,8(sp)
ffffffffc0202d92:	0141                	addi	sp,sp,16
ffffffffc0202d94:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202d96:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202d98:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0202d9a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202d9c:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202d9e:	02d70563          	beq	a4,a3,ffffffffc0202dc8 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0202da2:	8832                	mv	a6,a2
ffffffffc0202da4:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202da6:	87ba                	mv	a5,a4
ffffffffc0202da8:	bf41                	j	ffffffffc0202d38 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0202daa:	491c                	lw	a5,16(a0)
ffffffffc0202dac:	0107883b          	addw	a6,a5,a6
ffffffffc0202db0:	ff072823          	sw	a6,-16(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202db4:	57f5                	li	a5,-3
ffffffffc0202db6:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202dba:	7110                	ld	a2,32(a0)
ffffffffc0202dbc:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc0202dbe:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0202dc0:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0202dc2:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0202dc4:	e390                	sd	a2,0(a5)
ffffffffc0202dc6:	b775                	j	ffffffffc0202d72 <default_free_pages+0xae>
ffffffffc0202dc8:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202dca:	873e                	mv	a4,a5
ffffffffc0202dcc:	b761                	j	ffffffffc0202d54 <default_free_pages+0x90>
}
ffffffffc0202dce:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202dd0:	e390                	sd	a2,0(a5)
ffffffffc0202dd2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202dd4:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202dd6:	f11c                	sd	a5,32(a0)
ffffffffc0202dd8:	0141                	addi	sp,sp,16
ffffffffc0202dda:	8082                	ret
            base->property += p->property;
ffffffffc0202ddc:	ff072783          	lw	a5,-16(a4)
ffffffffc0202de0:	fe870693          	addi	a3,a4,-24
ffffffffc0202de4:	9dbd                	addw	a1,a1,a5
ffffffffc0202de6:	c90c                	sw	a1,16(a0)
ffffffffc0202de8:	57f5                	li	a5,-3
ffffffffc0202dea:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202dee:	6314                	ld	a3,0(a4)
ffffffffc0202df0:	671c                	ld	a5,8(a4)
}
ffffffffc0202df2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202df4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0202df6:	e394                	sd	a3,0(a5)
ffffffffc0202df8:	0141                	addi	sp,sp,16
ffffffffc0202dfa:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202dfc:	00003697          	auipc	a3,0x3
ffffffffc0202e00:	5b468693          	addi	a3,a3,1460 # ffffffffc02063b0 <commands+0x1430>
ffffffffc0202e04:	00003617          	auipc	a2,0x3
ffffffffc0202e08:	8a460613          	addi	a2,a2,-1884 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202e0c:	08300593          	li	a1,131
ffffffffc0202e10:	00003517          	auipc	a0,0x3
ffffffffc0202e14:	28850513          	addi	a0,a0,648 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202e18:	bb0fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0202e1c:	00003697          	auipc	a3,0x3
ffffffffc0202e20:	58c68693          	addi	a3,a3,1420 # ffffffffc02063a8 <commands+0x1428>
ffffffffc0202e24:	00003617          	auipc	a2,0x3
ffffffffc0202e28:	88460613          	addi	a2,a2,-1916 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202e2c:	08000593          	li	a1,128
ffffffffc0202e30:	00003517          	auipc	a0,0x3
ffffffffc0202e34:	26850513          	addi	a0,a0,616 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202e38:	b90fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202e3c <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202e3c:	c959                	beqz	a0,ffffffffc0202ed2 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202e3e:	0000e597          	auipc	a1,0xe
ffffffffc0202e42:	6aa58593          	addi	a1,a1,1706 # ffffffffc02114e8 <free_area>
ffffffffc0202e46:	0105a803          	lw	a6,16(a1)
ffffffffc0202e4a:	862a                	mv	a2,a0
ffffffffc0202e4c:	02081793          	slli	a5,a6,0x20
ffffffffc0202e50:	9381                	srli	a5,a5,0x20
ffffffffc0202e52:	00a7ee63          	bltu	a5,a0,ffffffffc0202e6e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202e56:	87ae                	mv	a5,a1
ffffffffc0202e58:	a801                	j	ffffffffc0202e68 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202e5a:	ff07a703          	lw	a4,-16(a5)
ffffffffc0202e5e:	02071693          	slli	a3,a4,0x20
ffffffffc0202e62:	9281                	srli	a3,a3,0x20
ffffffffc0202e64:	00c6f763          	bgeu	a3,a2,ffffffffc0202e72 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202e68:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202e6a:	feb798e3          	bne	a5,a1,ffffffffc0202e5a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202e6e:	4501                	li	a0,0
}
ffffffffc0202e70:	8082                	ret
    return listelm->prev;
ffffffffc0202e72:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202e76:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202e7a:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc0202e7e:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0202e82:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202e86:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202e8a:	02d67b63          	bgeu	a2,a3,ffffffffc0202ec0 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0202e8e:	00361693          	slli	a3,a2,0x3
ffffffffc0202e92:	96b2                	add	a3,a3,a2
ffffffffc0202e94:	068e                	slli	a3,a3,0x3
ffffffffc0202e96:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0202e98:	41c7073b          	subw	a4,a4,t3
ffffffffc0202e9c:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202e9e:	00868613          	addi	a2,a3,8
ffffffffc0202ea2:	4709                	li	a4,2
ffffffffc0202ea4:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202ea8:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202eac:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0202eb0:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202eb4:	e310                	sd	a2,0(a4)
ffffffffc0202eb6:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202eba:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202ebc:	0316b023          	sd	a7,32(a3)
ffffffffc0202ec0:	41c8083b          	subw	a6,a6,t3
ffffffffc0202ec4:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202ec8:	5775                	li	a4,-3
ffffffffc0202eca:	17a1                	addi	a5,a5,-24
ffffffffc0202ecc:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202ed0:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202ed2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202ed4:	00003697          	auipc	a3,0x3
ffffffffc0202ed8:	4d468693          	addi	a3,a3,1236 # ffffffffc02063a8 <commands+0x1428>
ffffffffc0202edc:	00002617          	auipc	a2,0x2
ffffffffc0202ee0:	7cc60613          	addi	a2,a2,1996 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202ee4:	06200593          	li	a1,98
ffffffffc0202ee8:	00003517          	auipc	a0,0x3
ffffffffc0202eec:	1b050513          	addi	a0,a0,432 # ffffffffc0206098 <commands+0x1118>
default_alloc_pages(size_t n) {
ffffffffc0202ef0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202ef2:	ad6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202ef6 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202ef6:	1141                	addi	sp,sp,-16
ffffffffc0202ef8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202efa:	c9e1                	beqz	a1,ffffffffc0202fca <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202efc:	00359693          	slli	a3,a1,0x3
ffffffffc0202f00:	96ae                	add	a3,a3,a1
ffffffffc0202f02:	068e                	slli	a3,a3,0x3
ffffffffc0202f04:	96aa                	add	a3,a3,a0
ffffffffc0202f06:	87aa                	mv	a5,a0
ffffffffc0202f08:	00d50f63          	beq	a0,a3,ffffffffc0202f26 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202f0c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202f0e:	8b05                	andi	a4,a4,1
ffffffffc0202f10:	cf49                	beqz	a4,ffffffffc0202faa <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202f12:	0007a823          	sw	zero,16(a5)
ffffffffc0202f16:	0007b423          	sd	zero,8(a5)
ffffffffc0202f1a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202f1e:	04878793          	addi	a5,a5,72
ffffffffc0202f22:	fed795e3          	bne	a5,a3,ffffffffc0202f0c <default_init_memmap+0x16>
    base->property = n;
ffffffffc0202f26:	2581                	sext.w	a1,a1
ffffffffc0202f28:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202f2a:	4789                	li	a5,2
ffffffffc0202f2c:	00850713          	addi	a4,a0,8
ffffffffc0202f30:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202f34:	0000e697          	auipc	a3,0xe
ffffffffc0202f38:	5b468693          	addi	a3,a3,1460 # ffffffffc02114e8 <free_area>
ffffffffc0202f3c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202f3e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202f40:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202f44:	9db9                	addw	a1,a1,a4
ffffffffc0202f46:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202f48:	04d78a63          	beq	a5,a3,ffffffffc0202f9c <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0202f4c:	fe078713          	addi	a4,a5,-32
ffffffffc0202f50:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202f54:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202f56:	00e56a63          	bltu	a0,a4,ffffffffc0202f6a <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0202f5a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202f5c:	02d70263          	beq	a4,a3,ffffffffc0202f80 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0202f60:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202f62:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202f66:	fee57ae3          	bgeu	a0,a4,ffffffffc0202f5a <default_init_memmap+0x64>
ffffffffc0202f6a:	c199                	beqz	a1,ffffffffc0202f70 <default_init_memmap+0x7a>
ffffffffc0202f6c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202f70:	6398                	ld	a4,0(a5)
}
ffffffffc0202f72:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202f74:	e390                	sd	a2,0(a5)
ffffffffc0202f76:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202f78:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202f7a:	f118                	sd	a4,32(a0)
ffffffffc0202f7c:	0141                	addi	sp,sp,16
ffffffffc0202f7e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202f80:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202f82:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0202f84:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202f86:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202f88:	00d70663          	beq	a4,a3,ffffffffc0202f94 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0202f8c:	8832                	mv	a6,a2
ffffffffc0202f8e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202f90:	87ba                	mv	a5,a4
ffffffffc0202f92:	bfc1                	j	ffffffffc0202f62 <default_init_memmap+0x6c>
}
ffffffffc0202f94:	60a2                	ld	ra,8(sp)
ffffffffc0202f96:	e290                	sd	a2,0(a3)
ffffffffc0202f98:	0141                	addi	sp,sp,16
ffffffffc0202f9a:	8082                	ret
ffffffffc0202f9c:	60a2                	ld	ra,8(sp)
ffffffffc0202f9e:	e390                	sd	a2,0(a5)
ffffffffc0202fa0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202fa2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202fa4:	f11c                	sd	a5,32(a0)
ffffffffc0202fa6:	0141                	addi	sp,sp,16
ffffffffc0202fa8:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202faa:	00003697          	auipc	a3,0x3
ffffffffc0202fae:	42e68693          	addi	a3,a3,1070 # ffffffffc02063d8 <commands+0x1458>
ffffffffc0202fb2:	00002617          	auipc	a2,0x2
ffffffffc0202fb6:	6f660613          	addi	a2,a2,1782 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202fba:	04900593          	li	a1,73
ffffffffc0202fbe:	00003517          	auipc	a0,0x3
ffffffffc0202fc2:	0da50513          	addi	a0,a0,218 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202fc6:	a02fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0202fca:	00003697          	auipc	a3,0x3
ffffffffc0202fce:	3de68693          	addi	a3,a3,990 # ffffffffc02063a8 <commands+0x1428>
ffffffffc0202fd2:	00002617          	auipc	a2,0x2
ffffffffc0202fd6:	6d660613          	addi	a2,a2,1750 # ffffffffc02056a8 <commands+0x728>
ffffffffc0202fda:	04600593          	li	a1,70
ffffffffc0202fde:	00003517          	auipc	a0,0x3
ffffffffc0202fe2:	0ba50513          	addi	a0,a0,186 # ffffffffc0206098 <commands+0x1118>
ffffffffc0202fe6:	9e2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202fea <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202fea:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202fec:	00003617          	auipc	a2,0x3
ffffffffc0202ff0:	8e460613          	addi	a2,a2,-1820 # ffffffffc02058d0 <commands+0x950>
ffffffffc0202ff4:	06200593          	li	a1,98
ffffffffc0202ff8:	00003517          	auipc	a0,0x3
ffffffffc0202ffc:	8f850513          	addi	a0,a0,-1800 # ffffffffc02058f0 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc0203000:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203002:	9c6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203006 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0203006:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0203008:	00003617          	auipc	a2,0x3
ffffffffc020300c:	ee060613          	addi	a2,a2,-288 # ffffffffc0205ee8 <commands+0xf68>
ffffffffc0203010:	07400593          	li	a1,116
ffffffffc0203014:	00003517          	auipc	a0,0x3
ffffffffc0203018:	8dc50513          	addi	a0,a0,-1828 # ffffffffc02058f0 <commands+0x970>
pte2page(pte_t pte) {
ffffffffc020301c:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc020301e:	9aafd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203022 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203022:	7139                	addi	sp,sp,-64
ffffffffc0203024:	f426                	sd	s1,40(sp)
ffffffffc0203026:	f04a                	sd	s2,32(sp)
ffffffffc0203028:	ec4e                	sd	s3,24(sp)
ffffffffc020302a:	e852                	sd	s4,16(sp)
ffffffffc020302c:	e456                	sd	s5,8(sp)
ffffffffc020302e:	e05a                	sd	s6,0(sp)
ffffffffc0203030:	fc06                	sd	ra,56(sp)
ffffffffc0203032:	f822                	sd	s0,48(sp)
ffffffffc0203034:	84aa                	mv	s1,a0
ffffffffc0203036:	00012917          	auipc	s2,0x12
ffffffffc020303a:	56290913          	addi	s2,s2,1378 # ffffffffc0215598 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020303e:	4a05                	li	s4,1
ffffffffc0203040:	00012a97          	auipc	s5,0x12
ffffffffc0203044:	530a8a93          	addi	s5,s5,1328 # ffffffffc0215570 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0203048:	0005099b          	sext.w	s3,a0
ffffffffc020304c:	00012b17          	auipc	s6,0x12
ffffffffc0203050:	4fcb0b13          	addi	s6,s6,1276 # ffffffffc0215548 <check_mm_struct>
ffffffffc0203054:	a01d                	j	ffffffffc020307a <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0203056:	00093783          	ld	a5,0(s2)
ffffffffc020305a:	6f9c                	ld	a5,24(a5)
ffffffffc020305c:	9782                	jalr	a5
ffffffffc020305e:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0203060:	4601                	li	a2,0
ffffffffc0203062:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203064:	ec0d                	bnez	s0,ffffffffc020309e <alloc_pages+0x7c>
ffffffffc0203066:	029a6c63          	bltu	s4,s1,ffffffffc020309e <alloc_pages+0x7c>
ffffffffc020306a:	000aa783          	lw	a5,0(s5)
ffffffffc020306e:	2781                	sext.w	a5,a5
ffffffffc0203070:	c79d                	beqz	a5,ffffffffc020309e <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203072:	000b3503          	ld	a0,0(s6)
ffffffffc0203076:	b0eff0ef          	jal	ra,ffffffffc0202384 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020307a:	100027f3          	csrr	a5,sstatus
ffffffffc020307e:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0203080:	8526                	mv	a0,s1
ffffffffc0203082:	dbf1                	beqz	a5,ffffffffc0203056 <alloc_pages+0x34>
        intr_disable();
ffffffffc0203084:	d40fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203088:	00093783          	ld	a5,0(s2)
ffffffffc020308c:	8526                	mv	a0,s1
ffffffffc020308e:	6f9c                	ld	a5,24(a5)
ffffffffc0203090:	9782                	jalr	a5
ffffffffc0203092:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203094:	d2afd0ef          	jal	ra,ffffffffc02005be <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203098:	4601                	li	a2,0
ffffffffc020309a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020309c:	d469                	beqz	s0,ffffffffc0203066 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020309e:	70e2                	ld	ra,56(sp)
ffffffffc02030a0:	8522                	mv	a0,s0
ffffffffc02030a2:	7442                	ld	s0,48(sp)
ffffffffc02030a4:	74a2                	ld	s1,40(sp)
ffffffffc02030a6:	7902                	ld	s2,32(sp)
ffffffffc02030a8:	69e2                	ld	s3,24(sp)
ffffffffc02030aa:	6a42                	ld	s4,16(sp)
ffffffffc02030ac:	6aa2                	ld	s5,8(sp)
ffffffffc02030ae:	6b02                	ld	s6,0(sp)
ffffffffc02030b0:	6121                	addi	sp,sp,64
ffffffffc02030b2:	8082                	ret

ffffffffc02030b4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030b4:	100027f3          	csrr	a5,sstatus
ffffffffc02030b8:	8b89                	andi	a5,a5,2
ffffffffc02030ba:	e799                	bnez	a5,ffffffffc02030c8 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02030bc:	00012797          	auipc	a5,0x12
ffffffffc02030c0:	4dc7b783          	ld	a5,1244(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc02030c4:	739c                	ld	a5,32(a5)
ffffffffc02030c6:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02030c8:	1101                	addi	sp,sp,-32
ffffffffc02030ca:	ec06                	sd	ra,24(sp)
ffffffffc02030cc:	e822                	sd	s0,16(sp)
ffffffffc02030ce:	e426                	sd	s1,8(sp)
ffffffffc02030d0:	842a                	mv	s0,a0
ffffffffc02030d2:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02030d4:	cf0fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02030d8:	00012797          	auipc	a5,0x12
ffffffffc02030dc:	4c07b783          	ld	a5,1216(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc02030e0:	739c                	ld	a5,32(a5)
ffffffffc02030e2:	85a6                	mv	a1,s1
ffffffffc02030e4:	8522                	mv	a0,s0
ffffffffc02030e6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02030e8:	6442                	ld	s0,16(sp)
ffffffffc02030ea:	60e2                	ld	ra,24(sp)
ffffffffc02030ec:	64a2                	ld	s1,8(sp)
ffffffffc02030ee:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02030f0:	ccefd06f          	j	ffffffffc02005be <intr_enable>

ffffffffc02030f4 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030f4:	100027f3          	csrr	a5,sstatus
ffffffffc02030f8:	8b89                	andi	a5,a5,2
ffffffffc02030fa:	e799                	bnez	a5,ffffffffc0203108 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02030fc:	00012797          	auipc	a5,0x12
ffffffffc0203100:	49c7b783          	ld	a5,1180(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0203104:	779c                	ld	a5,40(a5)
ffffffffc0203106:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0203108:	1141                	addi	sp,sp,-16
ffffffffc020310a:	e406                	sd	ra,8(sp)
ffffffffc020310c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020310e:	cb6fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203112:	00012797          	auipc	a5,0x12
ffffffffc0203116:	4867b783          	ld	a5,1158(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc020311a:	779c                	ld	a5,40(a5)
ffffffffc020311c:	9782                	jalr	a5
ffffffffc020311e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203120:	c9efd0ef          	jal	ra,ffffffffc02005be <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0203124:	60a2                	ld	ra,8(sp)
ffffffffc0203126:	8522                	mv	a0,s0
ffffffffc0203128:	6402                	ld	s0,0(sp)
ffffffffc020312a:	0141                	addi	sp,sp,16
ffffffffc020312c:	8082                	ret

ffffffffc020312e <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020312e:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0203132:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203136:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203138:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020313a:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020313c:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203140:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203142:	f84a                	sd	s2,48(sp)
ffffffffc0203144:	f44e                	sd	s3,40(sp)
ffffffffc0203146:	f052                	sd	s4,32(sp)
ffffffffc0203148:	e486                	sd	ra,72(sp)
ffffffffc020314a:	e0a2                	sd	s0,64(sp)
ffffffffc020314c:	ec56                	sd	s5,24(sp)
ffffffffc020314e:	e85a                	sd	s6,16(sp)
ffffffffc0203150:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203152:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203156:	892e                	mv	s2,a1
ffffffffc0203158:	8a32                	mv	s4,a2
ffffffffc020315a:	00012997          	auipc	s3,0x12
ffffffffc020315e:	42e98993          	addi	s3,s3,1070 # ffffffffc0215588 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203162:	efb5                	bnez	a5,ffffffffc02031de <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203164:	14060c63          	beqz	a2,ffffffffc02032bc <get_pte+0x18e>
ffffffffc0203168:	4505                	li	a0,1
ffffffffc020316a:	eb9ff0ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020316e:	842a                	mv	s0,a0
ffffffffc0203170:	14050663          	beqz	a0,ffffffffc02032bc <get_pte+0x18e>
    return page - pages + nbase;
ffffffffc0203174:	00012b97          	auipc	s7,0x12
ffffffffc0203178:	41cb8b93          	addi	s7,s7,1052 # ffffffffc0215590 <pages>
ffffffffc020317c:	000bb503          	ld	a0,0(s7)
ffffffffc0203180:	00004b17          	auipc	s6,0x4
ffffffffc0203184:	be8b3b03          	ld	s6,-1048(s6) # ffffffffc0206d68 <error_string+0x38>
ffffffffc0203188:	00080ab7          	lui	s5,0x80
ffffffffc020318c:	40a40533          	sub	a0,s0,a0
ffffffffc0203190:	850d                	srai	a0,a0,0x3
ffffffffc0203192:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203196:	00012997          	auipc	s3,0x12
ffffffffc020319a:	3f298993          	addi	s3,s3,1010 # ffffffffc0215588 <npage>
    page->ref = val;
ffffffffc020319e:	4785                	li	a5,1
ffffffffc02031a0:	0009b703          	ld	a4,0(s3)
ffffffffc02031a4:	c01c                	sw	a5,0(s0)
    return page - pages + nbase;
ffffffffc02031a6:	9556                	add	a0,a0,s5
ffffffffc02031a8:	00c51793          	slli	a5,a0,0xc
ffffffffc02031ac:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02031ae:	0532                	slli	a0,a0,0xc
ffffffffc02031b0:	14e7fd63          	bgeu	a5,a4,ffffffffc020330a <get_pte+0x1dc>
ffffffffc02031b4:	00012797          	auipc	a5,0x12
ffffffffc02031b8:	3ec7b783          	ld	a5,1004(a5) # ffffffffc02155a0 <va_pa_offset>
ffffffffc02031bc:	6605                	lui	a2,0x1
ffffffffc02031be:	4581                	li	a1,0
ffffffffc02031c0:	953e                	add	a0,a0,a5
ffffffffc02031c2:	6e0010ef          	jal	ra,ffffffffc02048a2 <memset>
    return page - pages + nbase;
ffffffffc02031c6:	000bb683          	ld	a3,0(s7)
ffffffffc02031ca:	40d406b3          	sub	a3,s0,a3
ffffffffc02031ce:	868d                	srai	a3,a3,0x3
ffffffffc02031d0:	036686b3          	mul	a3,a3,s6
ffffffffc02031d4:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02031d6:	06aa                	slli	a3,a3,0xa
ffffffffc02031d8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02031dc:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02031de:	77fd                	lui	a5,0xfffff
ffffffffc02031e0:	068a                	slli	a3,a3,0x2
ffffffffc02031e2:	0009b703          	ld	a4,0(s3)
ffffffffc02031e6:	8efd                	and	a3,a3,a5
ffffffffc02031e8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02031ec:	0ce7fa63          	bgeu	a5,a4,ffffffffc02032c0 <get_pte+0x192>
ffffffffc02031f0:	00012a97          	auipc	s5,0x12
ffffffffc02031f4:	3b0a8a93          	addi	s5,s5,944 # ffffffffc02155a0 <va_pa_offset>
ffffffffc02031f8:	000ab403          	ld	s0,0(s5)
ffffffffc02031fc:	01595793          	srli	a5,s2,0x15
ffffffffc0203200:	1ff7f793          	andi	a5,a5,511
ffffffffc0203204:	96a2                	add	a3,a3,s0
ffffffffc0203206:	00379413          	slli	s0,a5,0x3
ffffffffc020320a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020320c:	6014                	ld	a3,0(s0)
ffffffffc020320e:	0016f793          	andi	a5,a3,1
ffffffffc0203212:	ebad                	bnez	a5,ffffffffc0203284 <get_pte+0x156>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203214:	0a0a0463          	beqz	s4,ffffffffc02032bc <get_pte+0x18e>
ffffffffc0203218:	4505                	li	a0,1
ffffffffc020321a:	e09ff0ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020321e:	84aa                	mv	s1,a0
ffffffffc0203220:	cd51                	beqz	a0,ffffffffc02032bc <get_pte+0x18e>
    return page - pages + nbase;
ffffffffc0203222:	00012b97          	auipc	s7,0x12
ffffffffc0203226:	36eb8b93          	addi	s7,s7,878 # ffffffffc0215590 <pages>
ffffffffc020322a:	000bb503          	ld	a0,0(s7)
ffffffffc020322e:	00004b17          	auipc	s6,0x4
ffffffffc0203232:	b3ab3b03          	ld	s6,-1222(s6) # ffffffffc0206d68 <error_string+0x38>
ffffffffc0203236:	00080a37          	lui	s4,0x80
ffffffffc020323a:	40a48533          	sub	a0,s1,a0
ffffffffc020323e:	850d                	srai	a0,a0,0x3
ffffffffc0203240:	03650533          	mul	a0,a0,s6
    page->ref = val;
ffffffffc0203244:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203246:	0009b703          	ld	a4,0(s3)
ffffffffc020324a:	c09c                	sw	a5,0(s1)
    return page - pages + nbase;
ffffffffc020324c:	9552                	add	a0,a0,s4
ffffffffc020324e:	00c51793          	slli	a5,a0,0xc
ffffffffc0203252:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203254:	0532                	slli	a0,a0,0xc
ffffffffc0203256:	08e7fd63          	bgeu	a5,a4,ffffffffc02032f0 <get_pte+0x1c2>
ffffffffc020325a:	000ab783          	ld	a5,0(s5)
ffffffffc020325e:	6605                	lui	a2,0x1
ffffffffc0203260:	4581                	li	a1,0
ffffffffc0203262:	953e                	add	a0,a0,a5
ffffffffc0203264:	63e010ef          	jal	ra,ffffffffc02048a2 <memset>
    return page - pages + nbase;
ffffffffc0203268:	000bb683          	ld	a3,0(s7)
ffffffffc020326c:	40d486b3          	sub	a3,s1,a3
ffffffffc0203270:	868d                	srai	a3,a3,0x3
ffffffffc0203272:	036686b3          	mul	a3,a3,s6
ffffffffc0203276:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203278:	06aa                	slli	a3,a3,0xa
ffffffffc020327a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020327e:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203280:	0009b703          	ld	a4,0(s3)
ffffffffc0203284:	068a                	slli	a3,a3,0x2
ffffffffc0203286:	757d                	lui	a0,0xfffff
ffffffffc0203288:	8ee9                	and	a3,a3,a0
ffffffffc020328a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020328e:	04e7f563          	bgeu	a5,a4,ffffffffc02032d8 <get_pte+0x1aa>
ffffffffc0203292:	000ab503          	ld	a0,0(s5)
ffffffffc0203296:	00c95913          	srli	s2,s2,0xc
ffffffffc020329a:	1ff97913          	andi	s2,s2,511
ffffffffc020329e:	96aa                	add	a3,a3,a0
ffffffffc02032a0:	00391513          	slli	a0,s2,0x3
ffffffffc02032a4:	9536                	add	a0,a0,a3
}
ffffffffc02032a6:	60a6                	ld	ra,72(sp)
ffffffffc02032a8:	6406                	ld	s0,64(sp)
ffffffffc02032aa:	74e2                	ld	s1,56(sp)
ffffffffc02032ac:	7942                	ld	s2,48(sp)
ffffffffc02032ae:	79a2                	ld	s3,40(sp)
ffffffffc02032b0:	7a02                	ld	s4,32(sp)
ffffffffc02032b2:	6ae2                	ld	s5,24(sp)
ffffffffc02032b4:	6b42                	ld	s6,16(sp)
ffffffffc02032b6:	6ba2                	ld	s7,8(sp)
ffffffffc02032b8:	6161                	addi	sp,sp,80
ffffffffc02032ba:	8082                	ret
            return NULL;
ffffffffc02032bc:	4501                	li	a0,0
ffffffffc02032be:	b7e5                	j	ffffffffc02032a6 <get_pte+0x178>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02032c0:	00002617          	auipc	a2,0x2
ffffffffc02032c4:	64060613          	addi	a2,a2,1600 # ffffffffc0205900 <commands+0x980>
ffffffffc02032c8:	0e400593          	li	a1,228
ffffffffc02032cc:	00003517          	auipc	a0,0x3
ffffffffc02032d0:	16c50513          	addi	a0,a0,364 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc02032d4:	ef5fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02032d8:	00002617          	auipc	a2,0x2
ffffffffc02032dc:	62860613          	addi	a2,a2,1576 # ffffffffc0205900 <commands+0x980>
ffffffffc02032e0:	0ef00593          	li	a1,239
ffffffffc02032e4:	00003517          	auipc	a0,0x3
ffffffffc02032e8:	15450513          	addi	a0,a0,340 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc02032ec:	eddfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02032f0:	86aa                	mv	a3,a0
ffffffffc02032f2:	00002617          	auipc	a2,0x2
ffffffffc02032f6:	60e60613          	addi	a2,a2,1550 # ffffffffc0205900 <commands+0x980>
ffffffffc02032fa:	0ec00593          	li	a1,236
ffffffffc02032fe:	00003517          	auipc	a0,0x3
ffffffffc0203302:	13a50513          	addi	a0,a0,314 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203306:	ec3fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020330a:	86aa                	mv	a3,a0
ffffffffc020330c:	00002617          	auipc	a2,0x2
ffffffffc0203310:	5f460613          	addi	a2,a2,1524 # ffffffffc0205900 <commands+0x980>
ffffffffc0203314:	0e100593          	li	a1,225
ffffffffc0203318:	00003517          	auipc	a0,0x3
ffffffffc020331c:	12050513          	addi	a0,a0,288 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203320:	ea9fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203324 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203324:	1141                	addi	sp,sp,-16
ffffffffc0203326:	e022                	sd	s0,0(sp)
ffffffffc0203328:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020332a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020332c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020332e:	e01ff0ef          	jal	ra,ffffffffc020312e <get_pte>
    if (ptep_store != NULL) {
ffffffffc0203332:	c011                	beqz	s0,ffffffffc0203336 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203334:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203336:	c511                	beqz	a0,ffffffffc0203342 <get_page+0x1e>
ffffffffc0203338:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020333a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020333c:	0017f713          	andi	a4,a5,1
ffffffffc0203340:	e709                	bnez	a4,ffffffffc020334a <get_page+0x26>
}
ffffffffc0203342:	60a2                	ld	ra,8(sp)
ffffffffc0203344:	6402                	ld	s0,0(sp)
ffffffffc0203346:	0141                	addi	sp,sp,16
ffffffffc0203348:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020334a:	078a                	slli	a5,a5,0x2
ffffffffc020334c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020334e:	00012717          	auipc	a4,0x12
ffffffffc0203352:	23a73703          	ld	a4,570(a4) # ffffffffc0215588 <npage>
ffffffffc0203356:	02e7f263          	bgeu	a5,a4,ffffffffc020337a <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc020335a:	fff80537          	lui	a0,0xfff80
ffffffffc020335e:	97aa                	add	a5,a5,a0
ffffffffc0203360:	60a2                	ld	ra,8(sp)
ffffffffc0203362:	6402                	ld	s0,0(sp)
ffffffffc0203364:	00379513          	slli	a0,a5,0x3
ffffffffc0203368:	97aa                	add	a5,a5,a0
ffffffffc020336a:	078e                	slli	a5,a5,0x3
ffffffffc020336c:	00012517          	auipc	a0,0x12
ffffffffc0203370:	22453503          	ld	a0,548(a0) # ffffffffc0215590 <pages>
ffffffffc0203374:	953e                	add	a0,a0,a5
ffffffffc0203376:	0141                	addi	sp,sp,16
ffffffffc0203378:	8082                	ret
ffffffffc020337a:	c71ff0ef          	jal	ra,ffffffffc0202fea <pa2page.part.0>

ffffffffc020337e <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020337e:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203380:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203382:	ec26                	sd	s1,24(sp)
ffffffffc0203384:	f406                	sd	ra,40(sp)
ffffffffc0203386:	f022                	sd	s0,32(sp)
ffffffffc0203388:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020338a:	da5ff0ef          	jal	ra,ffffffffc020312e <get_pte>
    if (ptep != NULL) {
ffffffffc020338e:	c511                	beqz	a0,ffffffffc020339a <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203390:	611c                	ld	a5,0(a0)
ffffffffc0203392:	842a                	mv	s0,a0
ffffffffc0203394:	0017f713          	andi	a4,a5,1
ffffffffc0203398:	e711                	bnez	a4,ffffffffc02033a4 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc020339a:	70a2                	ld	ra,40(sp)
ffffffffc020339c:	7402                	ld	s0,32(sp)
ffffffffc020339e:	64e2                	ld	s1,24(sp)
ffffffffc02033a0:	6145                	addi	sp,sp,48
ffffffffc02033a2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02033a4:	078a                	slli	a5,a5,0x2
ffffffffc02033a6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033a8:	00012717          	auipc	a4,0x12
ffffffffc02033ac:	1e073703          	ld	a4,480(a4) # ffffffffc0215588 <npage>
ffffffffc02033b0:	06e7f663          	bgeu	a5,a4,ffffffffc020341c <page_remove+0x9e>
    return &pages[PPN(pa) - nbase];
ffffffffc02033b4:	fff80737          	lui	a4,0xfff80
ffffffffc02033b8:	97ba                	add	a5,a5,a4
ffffffffc02033ba:	00379513          	slli	a0,a5,0x3
ffffffffc02033be:	97aa                	add	a5,a5,a0
ffffffffc02033c0:	078e                	slli	a5,a5,0x3
ffffffffc02033c2:	00012517          	auipc	a0,0x12
ffffffffc02033c6:	1ce53503          	ld	a0,462(a0) # ffffffffc0215590 <pages>
ffffffffc02033ca:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02033cc:	411c                	lw	a5,0(a0)
ffffffffc02033ce:	fff7871b          	addiw	a4,a5,-1
ffffffffc02033d2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02033d4:	cb11                	beqz	a4,ffffffffc02033e8 <page_remove+0x6a>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02033d6:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02033da:	12048073          	sfence.vma	s1
}
ffffffffc02033de:	70a2                	ld	ra,40(sp)
ffffffffc02033e0:	7402                	ld	s0,32(sp)
ffffffffc02033e2:	64e2                	ld	s1,24(sp)
ffffffffc02033e4:	6145                	addi	sp,sp,48
ffffffffc02033e6:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033e8:	100027f3          	csrr	a5,sstatus
ffffffffc02033ec:	8b89                	andi	a5,a5,2
ffffffffc02033ee:	eb89                	bnez	a5,ffffffffc0203400 <page_remove+0x82>
        pmm_manager->free_pages(base, n);
ffffffffc02033f0:	00012797          	auipc	a5,0x12
ffffffffc02033f4:	1a87b783          	ld	a5,424(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc02033f8:	739c                	ld	a5,32(a5)
ffffffffc02033fa:	4585                	li	a1,1
ffffffffc02033fc:	9782                	jalr	a5
    if (flag) {
ffffffffc02033fe:	bfe1                	j	ffffffffc02033d6 <page_remove+0x58>
        intr_disable();
ffffffffc0203400:	e42a                	sd	a0,8(sp)
ffffffffc0203402:	9c2fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203406:	00012797          	auipc	a5,0x12
ffffffffc020340a:	1927b783          	ld	a5,402(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc020340e:	739c                	ld	a5,32(a5)
ffffffffc0203410:	6522                	ld	a0,8(sp)
ffffffffc0203412:	4585                	li	a1,1
ffffffffc0203414:	9782                	jalr	a5
        intr_enable();
ffffffffc0203416:	9a8fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020341a:	bf75                	j	ffffffffc02033d6 <page_remove+0x58>
ffffffffc020341c:	bcfff0ef          	jal	ra,ffffffffc0202fea <pa2page.part.0>

ffffffffc0203420 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203420:	7139                	addi	sp,sp,-64
ffffffffc0203422:	ec4e                	sd	s3,24(sp)
ffffffffc0203424:	89b2                	mv	s3,a2
ffffffffc0203426:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203428:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020342a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020342c:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020342e:	f426                	sd	s1,40(sp)
ffffffffc0203430:	fc06                	sd	ra,56(sp)
ffffffffc0203432:	f04a                	sd	s2,32(sp)
ffffffffc0203434:	e852                	sd	s4,16(sp)
ffffffffc0203436:	e456                	sd	s5,8(sp)
ffffffffc0203438:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020343a:	cf5ff0ef          	jal	ra,ffffffffc020312e <get_pte>
    if (ptep == NULL) {
ffffffffc020343e:	c17d                	beqz	a0,ffffffffc0203524 <page_insert+0x104>
    page->ref += 1;
ffffffffc0203440:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203442:	611c                	ld	a5,0(a0)
ffffffffc0203444:	8a2a                	mv	s4,a0
ffffffffc0203446:	0016871b          	addiw	a4,a3,1
ffffffffc020344a:	c018                	sw	a4,0(s0)
ffffffffc020344c:	0017f713          	andi	a4,a5,1
ffffffffc0203450:	e339                	bnez	a4,ffffffffc0203496 <page_insert+0x76>
    return page - pages + nbase;
ffffffffc0203452:	00012797          	auipc	a5,0x12
ffffffffc0203456:	13e7b783          	ld	a5,318(a5) # ffffffffc0215590 <pages>
ffffffffc020345a:	40f407b3          	sub	a5,s0,a5
ffffffffc020345e:	878d                	srai	a5,a5,0x3
ffffffffc0203460:	00004417          	auipc	s0,0x4
ffffffffc0203464:	90843403          	ld	s0,-1784(s0) # ffffffffc0206d68 <error_string+0x38>
ffffffffc0203468:	028787b3          	mul	a5,a5,s0
ffffffffc020346c:	00080437          	lui	s0,0x80
ffffffffc0203470:	97a2                	add	a5,a5,s0
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203472:	07aa                	slli	a5,a5,0xa
ffffffffc0203474:	8cdd                	or	s1,s1,a5
ffffffffc0203476:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020347a:	009a3023          	sd	s1,0(s4) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020347e:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0203482:	4501                	li	a0,0
}
ffffffffc0203484:	70e2                	ld	ra,56(sp)
ffffffffc0203486:	7442                	ld	s0,48(sp)
ffffffffc0203488:	74a2                	ld	s1,40(sp)
ffffffffc020348a:	7902                	ld	s2,32(sp)
ffffffffc020348c:	69e2                	ld	s3,24(sp)
ffffffffc020348e:	6a42                	ld	s4,16(sp)
ffffffffc0203490:	6aa2                	ld	s5,8(sp)
ffffffffc0203492:	6121                	addi	sp,sp,64
ffffffffc0203494:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203496:	00279713          	slli	a4,a5,0x2
ffffffffc020349a:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020349c:	00012797          	auipc	a5,0x12
ffffffffc02034a0:	0ec7b783          	ld	a5,236(a5) # ffffffffc0215588 <npage>
ffffffffc02034a4:	08f77263          	bgeu	a4,a5,ffffffffc0203528 <page_insert+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc02034a8:	fff807b7          	lui	a5,0xfff80
ffffffffc02034ac:	973e                	add	a4,a4,a5
ffffffffc02034ae:	00012a97          	auipc	s5,0x12
ffffffffc02034b2:	0e2a8a93          	addi	s5,s5,226 # ffffffffc0215590 <pages>
ffffffffc02034b6:	000ab783          	ld	a5,0(s5)
ffffffffc02034ba:	00371913          	slli	s2,a4,0x3
ffffffffc02034be:	993a                	add	s2,s2,a4
ffffffffc02034c0:	090e                	slli	s2,s2,0x3
ffffffffc02034c2:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc02034c4:	01240c63          	beq	s0,s2,ffffffffc02034dc <page_insert+0xbc>
    page->ref -= 1;
ffffffffc02034c8:	00092703          	lw	a4,0(s2)
ffffffffc02034cc:	fff7069b          	addiw	a3,a4,-1
ffffffffc02034d0:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc02034d4:	c691                	beqz	a3,ffffffffc02034e0 <page_insert+0xc0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02034d6:	12098073          	sfence.vma	s3
}
ffffffffc02034da:	b741                	j	ffffffffc020345a <page_insert+0x3a>
ffffffffc02034dc:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02034de:	bfb5                	j	ffffffffc020345a <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034e0:	100027f3          	csrr	a5,sstatus
ffffffffc02034e4:	8b89                	andi	a5,a5,2
ffffffffc02034e6:	ef91                	bnez	a5,ffffffffc0203502 <page_insert+0xe2>
        pmm_manager->free_pages(base, n);
ffffffffc02034e8:	00012797          	auipc	a5,0x12
ffffffffc02034ec:	0b07b783          	ld	a5,176(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc02034f0:	739c                	ld	a5,32(a5)
ffffffffc02034f2:	4585                	li	a1,1
ffffffffc02034f4:	854a                	mv	a0,s2
ffffffffc02034f6:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02034f8:	000ab783          	ld	a5,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02034fc:	12098073          	sfence.vma	s3
ffffffffc0203500:	bfa9                	j	ffffffffc020345a <page_insert+0x3a>
        intr_disable();
ffffffffc0203502:	8c2fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203506:	00012797          	auipc	a5,0x12
ffffffffc020350a:	0927b783          	ld	a5,146(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc020350e:	739c                	ld	a5,32(a5)
ffffffffc0203510:	4585                	li	a1,1
ffffffffc0203512:	854a                	mv	a0,s2
ffffffffc0203514:	9782                	jalr	a5
        intr_enable();
ffffffffc0203516:	8a8fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020351a:	000ab783          	ld	a5,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020351e:	12098073          	sfence.vma	s3
ffffffffc0203522:	bf25                	j	ffffffffc020345a <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203524:	5571                	li	a0,-4
ffffffffc0203526:	bfb9                	j	ffffffffc0203484 <page_insert+0x64>
ffffffffc0203528:	ac3ff0ef          	jal	ra,ffffffffc0202fea <pa2page.part.0>

ffffffffc020352c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020352c:	00003797          	auipc	a5,0x3
ffffffffc0203530:	ed478793          	addi	a5,a5,-300 # ffffffffc0206400 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203534:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203536:	7159                	addi	sp,sp,-112
ffffffffc0203538:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020353a:	00003517          	auipc	a0,0x3
ffffffffc020353e:	f0e50513          	addi	a0,a0,-242 # ffffffffc0206448 <default_pmm_manager+0x48>
    pmm_manager = &default_pmm_manager;
ffffffffc0203542:	00012b97          	auipc	s7,0x12
ffffffffc0203546:	056b8b93          	addi	s7,s7,86 # ffffffffc0215598 <pmm_manager>
void pmm_init(void) {
ffffffffc020354a:	f486                	sd	ra,104(sp)
ffffffffc020354c:	eca6                	sd	s1,88(sp)
ffffffffc020354e:	e4ce                	sd	s3,72(sp)
ffffffffc0203550:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203552:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203556:	f0a2                	sd	s0,96(sp)
ffffffffc0203558:	e8ca                	sd	s2,80(sp)
ffffffffc020355a:	e0d2                	sd	s4,64(sp)
ffffffffc020355c:	fc56                	sd	s5,56(sp)
ffffffffc020355e:	f062                	sd	s8,32(sp)
ffffffffc0203560:	ec66                	sd	s9,24(sp)
ffffffffc0203562:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203564:	b69fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0203568:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020356c:	00012997          	auipc	s3,0x12
ffffffffc0203570:	03498993          	addi	s3,s3,52 # ffffffffc02155a0 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203574:	00012497          	auipc	s1,0x12
ffffffffc0203578:	01448493          	addi	s1,s1,20 # ffffffffc0215588 <npage>
    pmm_manager->init();
ffffffffc020357c:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020357e:	00012b17          	auipc	s6,0x12
ffffffffc0203582:	012b0b13          	addi	s6,s6,18 # ffffffffc0215590 <pages>
    pmm_manager->init();
ffffffffc0203586:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203588:	57f5                	li	a5,-3
ffffffffc020358a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020358c:	00003517          	auipc	a0,0x3
ffffffffc0203590:	ed450513          	addi	a0,a0,-300 # ffffffffc0206460 <default_pmm_manager+0x60>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203594:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0203598:	b35fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020359c:	46c5                	li	a3,17
ffffffffc020359e:	06ee                	slli	a3,a3,0x1b
ffffffffc02035a0:	40100613          	li	a2,1025
ffffffffc02035a4:	16fd                	addi	a3,a3,-1
ffffffffc02035a6:	07e005b7          	lui	a1,0x7e00
ffffffffc02035aa:	0656                	slli	a2,a2,0x15
ffffffffc02035ac:	00003517          	auipc	a0,0x3
ffffffffc02035b0:	ecc50513          	addi	a0,a0,-308 # ffffffffc0206478 <default_pmm_manager+0x78>
ffffffffc02035b4:	b19fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02035b8:	777d                	lui	a4,0xfffff
ffffffffc02035ba:	00013797          	auipc	a5,0x13
ffffffffc02035be:	00978793          	addi	a5,a5,9 # ffffffffc02165c3 <end+0xfff>
ffffffffc02035c2:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02035c4:	00088737          	lui	a4,0x88
ffffffffc02035c8:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02035ca:	00fb3023          	sd	a5,0(s6)
ffffffffc02035ce:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02035d0:	4701                	li	a4,0
ffffffffc02035d2:	4585                	li	a1,1
ffffffffc02035d4:	fff80837          	lui	a6,0xfff80
ffffffffc02035d8:	a019                	j	ffffffffc02035de <pmm_init+0xb2>
        SetPageReserved(pages + i);
ffffffffc02035da:	000b3783          	ld	a5,0(s6)
ffffffffc02035de:	97b6                	add	a5,a5,a3
ffffffffc02035e0:	07a1                	addi	a5,a5,8
ffffffffc02035e2:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02035e6:	609c                	ld	a5,0(s1)
ffffffffc02035e8:	0705                	addi	a4,a4,1
ffffffffc02035ea:	04868693          	addi	a3,a3,72
ffffffffc02035ee:	01078633          	add	a2,a5,a6
ffffffffc02035f2:	fec764e3          	bltu	a4,a2,ffffffffc02035da <pmm_init+0xae>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02035f6:	000b3503          	ld	a0,0(s6)
ffffffffc02035fa:	00379693          	slli	a3,a5,0x3
ffffffffc02035fe:	96be                	add	a3,a3,a5
ffffffffc0203600:	fdc00737          	lui	a4,0xfdc00
ffffffffc0203604:	972a                	add	a4,a4,a0
ffffffffc0203606:	068e                	slli	a3,a3,0x3
ffffffffc0203608:	96ba                	add	a3,a3,a4
ffffffffc020360a:	c0200737          	lui	a4,0xc0200
ffffffffc020360e:	66e6e163          	bltu	a3,a4,ffffffffc0203c70 <pmm_init+0x744>
ffffffffc0203612:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203616:	4645                	li	a2,17
ffffffffc0203618:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020361a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020361c:	4ec6ee63          	bltu	a3,a2,ffffffffc0203b18 <pmm_init+0x5ec>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203620:	00003517          	auipc	a0,0x3
ffffffffc0203624:	e8050513          	addi	a0,a0,-384 # ffffffffc02064a0 <default_pmm_manager+0xa0>
ffffffffc0203628:	aa5fc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020362c:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203630:	00012917          	auipc	s2,0x12
ffffffffc0203634:	f5090913          	addi	s2,s2,-176 # ffffffffc0215580 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203638:	7b9c                	ld	a5,48(a5)
ffffffffc020363a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020363c:	00003517          	auipc	a0,0x3
ffffffffc0203640:	e7c50513          	addi	a0,a0,-388 # ffffffffc02064b8 <default_pmm_manager+0xb8>
ffffffffc0203644:	a89fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203648:	00006697          	auipc	a3,0x6
ffffffffc020364c:	9b868693          	addi	a3,a3,-1608 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0203650:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203654:	c02007b7          	lui	a5,0xc0200
ffffffffc0203658:	62f6e863          	bltu	a3,a5,ffffffffc0203c88 <pmm_init+0x75c>
ffffffffc020365c:	0009b783          	ld	a5,0(s3)
ffffffffc0203660:	8e9d                	sub	a3,a3,a5
ffffffffc0203662:	00012797          	auipc	a5,0x12
ffffffffc0203666:	f0d7bb23          	sd	a3,-234(a5) # ffffffffc0215578 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020366a:	100027f3          	csrr	a5,sstatus
ffffffffc020366e:	8b89                	andi	a5,a5,2
ffffffffc0203670:	4c079e63          	bnez	a5,ffffffffc0203b4c <pmm_init+0x620>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203674:	000bb783          	ld	a5,0(s7)
ffffffffc0203678:	779c                	ld	a5,40(a5)
ffffffffc020367a:	9782                	jalr	a5
ffffffffc020367c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020367e:	6098                	ld	a4,0(s1)
ffffffffc0203680:	c80007b7          	lui	a5,0xc8000
ffffffffc0203684:	83b1                	srli	a5,a5,0xc
ffffffffc0203686:	62e7ed63          	bltu	a5,a4,ffffffffc0203cc0 <pmm_init+0x794>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020368a:	00093503          	ld	a0,0(s2)
ffffffffc020368e:	60050963          	beqz	a0,ffffffffc0203ca0 <pmm_init+0x774>
ffffffffc0203692:	03451793          	slli	a5,a0,0x34
ffffffffc0203696:	60079563          	bnez	a5,ffffffffc0203ca0 <pmm_init+0x774>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020369a:	4601                	li	a2,0
ffffffffc020369c:	4581                	li	a1,0
ffffffffc020369e:	c87ff0ef          	jal	ra,ffffffffc0203324 <get_page>
ffffffffc02036a2:	68051163          	bnez	a0,ffffffffc0203d24 <pmm_init+0x7f8>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02036a6:	4505                	li	a0,1
ffffffffc02036a8:	97bff0ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc02036ac:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02036ae:	00093503          	ld	a0,0(s2)
ffffffffc02036b2:	4681                	li	a3,0
ffffffffc02036b4:	4601                	li	a2,0
ffffffffc02036b6:	85d2                	mv	a1,s4
ffffffffc02036b8:	d69ff0ef          	jal	ra,ffffffffc0203420 <page_insert>
ffffffffc02036bc:	64051463          	bnez	a0,ffffffffc0203d04 <pmm_init+0x7d8>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02036c0:	00093503          	ld	a0,0(s2)
ffffffffc02036c4:	4601                	li	a2,0
ffffffffc02036c6:	4581                	li	a1,0
ffffffffc02036c8:	a67ff0ef          	jal	ra,ffffffffc020312e <get_pte>
ffffffffc02036cc:	60050c63          	beqz	a0,ffffffffc0203ce4 <pmm_init+0x7b8>
    assert(pte2page(*ptep) == p1);
ffffffffc02036d0:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02036d2:	0017f713          	andi	a4,a5,1
ffffffffc02036d6:	60070563          	beqz	a4,ffffffffc0203ce0 <pmm_init+0x7b4>
    if (PPN(pa) >= npage) {
ffffffffc02036da:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02036dc:	078a                	slli	a5,a5,0x2
ffffffffc02036de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036e0:	58c7f663          	bgeu	a5,a2,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc02036e4:	fff80737          	lui	a4,0xfff80
ffffffffc02036e8:	97ba                	add	a5,a5,a4
ffffffffc02036ea:	000b3683          	ld	a3,0(s6)
ffffffffc02036ee:	00379713          	slli	a4,a5,0x3
ffffffffc02036f2:	97ba                	add	a5,a5,a4
ffffffffc02036f4:	078e                	slli	a5,a5,0x3
ffffffffc02036f6:	97b6                	add	a5,a5,a3
ffffffffc02036f8:	14fa1fe3          	bne	s4,a5,ffffffffc0204056 <pmm_init+0xb2a>
    assert(page_ref(p1) == 1);
ffffffffc02036fc:	000a2703          	lw	a4,0(s4)
ffffffffc0203700:	4785                	li	a5,1
ffffffffc0203702:	18f716e3          	bne	a4,a5,ffffffffc020408e <pmm_init+0xb62>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203706:	00093503          	ld	a0,0(s2)
ffffffffc020370a:	77fd                	lui	a5,0xfffff
ffffffffc020370c:	6114                	ld	a3,0(a0)
ffffffffc020370e:	068a                	slli	a3,a3,0x2
ffffffffc0203710:	8efd                	and	a3,a3,a5
ffffffffc0203712:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203716:	16c770e3          	bgeu	a4,a2,ffffffffc0204076 <pmm_init+0xb4a>
ffffffffc020371a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020371e:	96e2                	add	a3,a3,s8
ffffffffc0203720:	0006ba83          	ld	s5,0(a3)
ffffffffc0203724:	0a8a                	slli	s5,s5,0x2
ffffffffc0203726:	00fafab3          	and	s5,s5,a5
ffffffffc020372a:	00cad793          	srli	a5,s5,0xc
ffffffffc020372e:	66c7fb63          	bgeu	a5,a2,ffffffffc0203da4 <pmm_init+0x878>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203732:	4601                	li	a2,0
ffffffffc0203734:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203736:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203738:	9f7ff0ef          	jal	ra,ffffffffc020312e <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020373c:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020373e:	65551363          	bne	a0,s5,ffffffffc0203d84 <pmm_init+0x858>

    p2 = alloc_page();
ffffffffc0203742:	4505                	li	a0,1
ffffffffc0203744:	8dfff0ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc0203748:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020374a:	00093503          	ld	a0,0(s2)
ffffffffc020374e:	46d1                	li	a3,20
ffffffffc0203750:	6605                	lui	a2,0x1
ffffffffc0203752:	85d6                	mv	a1,s5
ffffffffc0203754:	ccdff0ef          	jal	ra,ffffffffc0203420 <page_insert>
ffffffffc0203758:	5e051663          	bnez	a0,ffffffffc0203d44 <pmm_init+0x818>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020375c:	00093503          	ld	a0,0(s2)
ffffffffc0203760:	4601                	li	a2,0
ffffffffc0203762:	6585                	lui	a1,0x1
ffffffffc0203764:	9cbff0ef          	jal	ra,ffffffffc020312e <get_pte>
ffffffffc0203768:	140503e3          	beqz	a0,ffffffffc02040ae <pmm_init+0xb82>
    assert(*ptep & PTE_U);
ffffffffc020376c:	611c                	ld	a5,0(a0)
ffffffffc020376e:	0107f713          	andi	a4,a5,16
ffffffffc0203772:	74070663          	beqz	a4,ffffffffc0203ebe <pmm_init+0x992>
    assert(*ptep & PTE_W);
ffffffffc0203776:	8b91                	andi	a5,a5,4
ffffffffc0203778:	70078363          	beqz	a5,ffffffffc0203e7e <pmm_init+0x952>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020377c:	00093503          	ld	a0,0(s2)
ffffffffc0203780:	611c                	ld	a5,0(a0)
ffffffffc0203782:	8bc1                	andi	a5,a5,16
ffffffffc0203784:	6c078d63          	beqz	a5,ffffffffc0203e5e <pmm_init+0x932>
    assert(page_ref(p2) == 1);
ffffffffc0203788:	000aa703          	lw	a4,0(s5)
ffffffffc020378c:	4785                	li	a5,1
ffffffffc020378e:	5cf71b63          	bne	a4,a5,ffffffffc0203d64 <pmm_init+0x838>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203792:	4681                	li	a3,0
ffffffffc0203794:	6605                	lui	a2,0x1
ffffffffc0203796:	85d2                	mv	a1,s4
ffffffffc0203798:	c89ff0ef          	jal	ra,ffffffffc0203420 <page_insert>
ffffffffc020379c:	68051163          	bnez	a0,ffffffffc0203e1e <pmm_init+0x8f2>
    assert(page_ref(p1) == 2);
ffffffffc02037a0:	000a2703          	lw	a4,0(s4)
ffffffffc02037a4:	4789                	li	a5,2
ffffffffc02037a6:	64f71c63          	bne	a4,a5,ffffffffc0203dfe <pmm_init+0x8d2>
    assert(page_ref(p2) == 0);
ffffffffc02037aa:	000aa783          	lw	a5,0(s5)
ffffffffc02037ae:	62079863          	bnez	a5,ffffffffc0203dde <pmm_init+0x8b2>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02037b2:	00093503          	ld	a0,0(s2)
ffffffffc02037b6:	4601                	li	a2,0
ffffffffc02037b8:	6585                	lui	a1,0x1
ffffffffc02037ba:	975ff0ef          	jal	ra,ffffffffc020312e <get_pte>
ffffffffc02037be:	60050063          	beqz	a0,ffffffffc0203dbe <pmm_init+0x892>
    assert(pte2page(*ptep) == p1);
ffffffffc02037c2:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02037c4:	00177793          	andi	a5,a4,1
ffffffffc02037c8:	50078c63          	beqz	a5,ffffffffc0203ce0 <pmm_init+0x7b4>
    if (PPN(pa) >= npage) {
ffffffffc02037cc:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02037ce:	00271793          	slli	a5,a4,0x2
ffffffffc02037d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037d4:	48d7fc63          	bgeu	a5,a3,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc02037d8:	fff806b7          	lui	a3,0xfff80
ffffffffc02037dc:	97b6                	add	a5,a5,a3
ffffffffc02037de:	000b3603          	ld	a2,0(s6)
ffffffffc02037e2:	00379693          	slli	a3,a5,0x3
ffffffffc02037e6:	97b6                	add	a5,a5,a3
ffffffffc02037e8:	078e                	slli	a5,a5,0x3
ffffffffc02037ea:	97b2                	add	a5,a5,a2
ffffffffc02037ec:	72fa1963          	bne	s4,a5,ffffffffc0203f1e <pmm_init+0x9f2>
    assert((*ptep & PTE_U) == 0);
ffffffffc02037f0:	8b41                	andi	a4,a4,16
ffffffffc02037f2:	70071663          	bnez	a4,ffffffffc0203efe <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02037f6:	00093503          	ld	a0,0(s2)
ffffffffc02037fa:	4581                	li	a1,0
ffffffffc02037fc:	b83ff0ef          	jal	ra,ffffffffc020337e <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203800:	000a2703          	lw	a4,0(s4)
ffffffffc0203804:	4785                	li	a5,1
ffffffffc0203806:	6cf71c63          	bne	a4,a5,ffffffffc0203ede <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020380a:	000aa783          	lw	a5,0(s5)
ffffffffc020380e:	7a079463          	bnez	a5,ffffffffc0203fb6 <pmm_init+0xa8a>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203812:	00093503          	ld	a0,0(s2)
ffffffffc0203816:	6585                	lui	a1,0x1
ffffffffc0203818:	b67ff0ef          	jal	ra,ffffffffc020337e <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020381c:	000a2783          	lw	a5,0(s4)
ffffffffc0203820:	76079b63          	bnez	a5,ffffffffc0203f96 <pmm_init+0xa6a>
    assert(page_ref(p2) == 0);
ffffffffc0203824:	000aa783          	lw	a5,0(s5)
ffffffffc0203828:	74079763          	bnez	a5,ffffffffc0203f76 <pmm_init+0xa4a>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020382c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203830:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203832:	000a3783          	ld	a5,0(s4)
ffffffffc0203836:	078a                	slli	a5,a5,0x2
ffffffffc0203838:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020383a:	42c7f963          	bgeu	a5,a2,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc020383e:	fff80737          	lui	a4,0xfff80
ffffffffc0203842:	973e                	add	a4,a4,a5
ffffffffc0203844:	00371793          	slli	a5,a4,0x3
ffffffffc0203848:	000b3503          	ld	a0,0(s6)
ffffffffc020384c:	97ba                	add	a5,a5,a4
ffffffffc020384e:	078e                	slli	a5,a5,0x3
    return page->ref;
ffffffffc0203850:	00f50733          	add	a4,a0,a5
ffffffffc0203854:	4314                	lw	a3,0(a4)
ffffffffc0203856:	4705                	li	a4,1
ffffffffc0203858:	6ee69f63          	bne	a3,a4,ffffffffc0203f56 <pmm_init+0xa2a>
    return page - pages + nbase;
ffffffffc020385c:	4037d693          	srai	a3,a5,0x3
ffffffffc0203860:	00003c97          	auipc	s9,0x3
ffffffffc0203864:	508cbc83          	ld	s9,1288(s9) # ffffffffc0206d68 <error_string+0x38>
ffffffffc0203868:	039686b3          	mul	a3,a3,s9
ffffffffc020386c:	000805b7          	lui	a1,0x80
ffffffffc0203870:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0203872:	00c69713          	slli	a4,a3,0xc
ffffffffc0203876:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203878:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020387a:	6cc77263          	bgeu	a4,a2,ffffffffc0203f3e <pmm_init+0xa12>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020387e:	0009b703          	ld	a4,0(s3)
ffffffffc0203882:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0203884:	629c                	ld	a5,0(a3)
ffffffffc0203886:	078a                	slli	a5,a5,0x2
ffffffffc0203888:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020388a:	3ec7f163          	bgeu	a5,a2,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc020388e:	8f8d                	sub	a5,a5,a1
ffffffffc0203890:	00379713          	slli	a4,a5,0x3
ffffffffc0203894:	97ba                	add	a5,a5,a4
ffffffffc0203896:	078e                	slli	a5,a5,0x3
ffffffffc0203898:	953e                	add	a0,a0,a5
ffffffffc020389a:	100027f3          	csrr	a5,sstatus
ffffffffc020389e:	8b89                	andi	a5,a5,2
ffffffffc02038a0:	30079063          	bnez	a5,ffffffffc0203ba0 <pmm_init+0x674>
        pmm_manager->free_pages(base, n);
ffffffffc02038a4:	000bb783          	ld	a5,0(s7)
ffffffffc02038a8:	4585                	li	a1,1
ffffffffc02038aa:	739c                	ld	a5,32(a5)
ffffffffc02038ac:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02038ae:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02038b2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02038b4:	078a                	slli	a5,a5,0x2
ffffffffc02038b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038b8:	3ae7fa63          	bgeu	a5,a4,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc02038bc:	fff80737          	lui	a4,0xfff80
ffffffffc02038c0:	97ba                	add	a5,a5,a4
ffffffffc02038c2:	000b3503          	ld	a0,0(s6)
ffffffffc02038c6:	00379713          	slli	a4,a5,0x3
ffffffffc02038ca:	97ba                	add	a5,a5,a4
ffffffffc02038cc:	078e                	slli	a5,a5,0x3
ffffffffc02038ce:	953e                	add	a0,a0,a5
ffffffffc02038d0:	100027f3          	csrr	a5,sstatus
ffffffffc02038d4:	8b89                	andi	a5,a5,2
ffffffffc02038d6:	2a079963          	bnez	a5,ffffffffc0203b88 <pmm_init+0x65c>
ffffffffc02038da:	000bb783          	ld	a5,0(s7)
ffffffffc02038de:	4585                	li	a1,1
ffffffffc02038e0:	739c                	ld	a5,32(a5)
ffffffffc02038e2:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02038e4:	00093783          	ld	a5,0(s2)
ffffffffc02038e8:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fde9a3c>
  asm volatile("sfence.vma");
ffffffffc02038ec:	12000073          	sfence.vma
ffffffffc02038f0:	100027f3          	csrr	a5,sstatus
ffffffffc02038f4:	8b89                	andi	a5,a5,2
ffffffffc02038f6:	26079f63          	bnez	a5,ffffffffc0203b74 <pmm_init+0x648>
        ret = pmm_manager->nr_free_pages();
ffffffffc02038fa:	000bb783          	ld	a5,0(s7)
ffffffffc02038fe:	779c                	ld	a5,40(a5)
ffffffffc0203900:	9782                	jalr	a5
ffffffffc0203902:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203904:	73441963          	bne	s0,s4,ffffffffc0204036 <pmm_init+0xb0a>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203908:	00003517          	auipc	a0,0x3
ffffffffc020390c:	e9850513          	addi	a0,a0,-360 # ffffffffc02067a0 <default_pmm_manager+0x3a0>
ffffffffc0203910:	fbcfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0203914:	100027f3          	csrr	a5,sstatus
ffffffffc0203918:	8b89                	andi	a5,a5,2
ffffffffc020391a:	24079363          	bnez	a5,ffffffffc0203b60 <pmm_init+0x634>
        ret = pmm_manager->nr_free_pages();
ffffffffc020391e:	000bb783          	ld	a5,0(s7)
ffffffffc0203922:	779c                	ld	a5,40(a5)
ffffffffc0203924:	9782                	jalr	a5
ffffffffc0203926:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203928:	6098                	ld	a4,0(s1)
ffffffffc020392a:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020392e:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203930:	00c71793          	slli	a5,a4,0xc
ffffffffc0203934:	6a05                	lui	s4,0x1
ffffffffc0203936:	02f47c63          	bgeu	s0,a5,ffffffffc020396e <pmm_init+0x442>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020393a:	00c45793          	srli	a5,s0,0xc
ffffffffc020393e:	00093503          	ld	a0,0(s2)
ffffffffc0203942:	30e7f863          	bgeu	a5,a4,ffffffffc0203c52 <pmm_init+0x726>
ffffffffc0203946:	0009b583          	ld	a1,0(s3)
ffffffffc020394a:	4601                	li	a2,0
ffffffffc020394c:	95a2                	add	a1,a1,s0
ffffffffc020394e:	fe0ff0ef          	jal	ra,ffffffffc020312e <get_pte>
ffffffffc0203952:	2e050063          	beqz	a0,ffffffffc0203c32 <pmm_init+0x706>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203956:	611c                	ld	a5,0(a0)
ffffffffc0203958:	078a                	slli	a5,a5,0x2
ffffffffc020395a:	0157f7b3          	and	a5,a5,s5
ffffffffc020395e:	2a879a63          	bne	a5,s0,ffffffffc0203c12 <pmm_init+0x6e6>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203962:	6098                	ld	a4,0(s1)
ffffffffc0203964:	9452                	add	s0,s0,s4
ffffffffc0203966:	00c71793          	slli	a5,a4,0xc
ffffffffc020396a:	fcf468e3          	bltu	s0,a5,ffffffffc020393a <pmm_init+0x40e>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc020396e:	00093783          	ld	a5,0(s2)
ffffffffc0203972:	639c                	ld	a5,0(a5)
ffffffffc0203974:	6a079163          	bnez	a5,ffffffffc0204016 <pmm_init+0xaea>

    struct Page *p;
    p = alloc_page();
ffffffffc0203978:	4505                	li	a0,1
ffffffffc020397a:	ea8ff0ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020397e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203980:	00093503          	ld	a0,0(s2)
ffffffffc0203984:	4699                	li	a3,6
ffffffffc0203986:	10000613          	li	a2,256
ffffffffc020398a:	85d6                	mv	a1,s5
ffffffffc020398c:	a95ff0ef          	jal	ra,ffffffffc0203420 <page_insert>
ffffffffc0203990:	66051363          	bnez	a0,ffffffffc0203ff6 <pmm_init+0xaca>
    assert(page_ref(p) == 1);
ffffffffc0203994:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9a3c>
ffffffffc0203998:	4785                	li	a5,1
ffffffffc020399a:	62f71e63          	bne	a4,a5,ffffffffc0203fd6 <pmm_init+0xaaa>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020399e:	00093503          	ld	a0,0(s2)
ffffffffc02039a2:	6405                	lui	s0,0x1
ffffffffc02039a4:	4699                	li	a3,6
ffffffffc02039a6:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02039aa:	85d6                	mv	a1,s5
ffffffffc02039ac:	a75ff0ef          	jal	ra,ffffffffc0203420 <page_insert>
ffffffffc02039b0:	48051763          	bnez	a0,ffffffffc0203e3e <pmm_init+0x912>
    assert(page_ref(p) == 2);
ffffffffc02039b4:	000aa703          	lw	a4,0(s5)
ffffffffc02039b8:	4789                	li	a5,2
ffffffffc02039ba:	74f71a63          	bne	a4,a5,ffffffffc020410e <pmm_init+0xbe2>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02039be:	00003597          	auipc	a1,0x3
ffffffffc02039c2:	f1a58593          	addi	a1,a1,-230 # ffffffffc02068d8 <default_pmm_manager+0x4d8>
ffffffffc02039c6:	10000513          	li	a0,256
ffffffffc02039ca:	693000ef          	jal	ra,ffffffffc020485c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02039ce:	10040593          	addi	a1,s0,256
ffffffffc02039d2:	10000513          	li	a0,256
ffffffffc02039d6:	699000ef          	jal	ra,ffffffffc020486e <strcmp>
ffffffffc02039da:	70051a63          	bnez	a0,ffffffffc02040ee <pmm_init+0xbc2>
    return page - pages + nbase;
ffffffffc02039de:	000b3683          	ld	a3,0(s6)
ffffffffc02039e2:	00080d37          	lui	s10,0x80
    return KADDR(page2pa(page));
ffffffffc02039e6:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02039e8:	40da86b3          	sub	a3,s5,a3
ffffffffc02039ec:	868d                	srai	a3,a3,0x3
ffffffffc02039ee:	039686b3          	mul	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc02039f2:	609c                	ld	a5,0(s1)
ffffffffc02039f4:	8031                	srli	s0,s0,0xc
    return page - pages + nbase;
ffffffffc02039f6:	96ea                	add	a3,a3,s10
    return KADDR(page2pa(page));
ffffffffc02039f8:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02039fc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02039fe:	54f77063          	bgeu	a4,a5,ffffffffc0203f3e <pmm_init+0xa12>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203a02:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203a06:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203a0a:	96be                	add	a3,a3,a5
ffffffffc0203a0c:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6ab3c>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203a10:	617000ef          	jal	ra,ffffffffc0204826 <strlen>
ffffffffc0203a14:	6a051d63          	bnez	a0,ffffffffc02040ce <pmm_init+0xba2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203a18:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203a1c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a1e:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203a22:	078a                	slli	a5,a5,0x2
ffffffffc0203a24:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a26:	24e7f363          	bgeu	a5,a4,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a2a:	41a787b3          	sub	a5,a5,s10
ffffffffc0203a2e:	00379693          	slli	a3,a5,0x3
    return page - pages + nbase;
ffffffffc0203a32:	96be                	add	a3,a3,a5
ffffffffc0203a34:	03968cb3          	mul	s9,a3,s9
ffffffffc0203a38:	01ac86b3          	add	a3,s9,s10
    return KADDR(page2pa(page));
ffffffffc0203a3c:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a3e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203a40:	4ee47f63          	bgeu	s0,a4,ffffffffc0203f3e <pmm_init+0xa12>
ffffffffc0203a44:	0009b403          	ld	s0,0(s3)
ffffffffc0203a48:	9436                	add	s0,s0,a3
ffffffffc0203a4a:	100027f3          	csrr	a5,sstatus
ffffffffc0203a4e:	8b89                	andi	a5,a5,2
ffffffffc0203a50:	1a079663          	bnez	a5,ffffffffc0203bfc <pmm_init+0x6d0>
        pmm_manager->free_pages(base, n);
ffffffffc0203a54:	000bb783          	ld	a5,0(s7)
ffffffffc0203a58:	4585                	li	a1,1
ffffffffc0203a5a:	8556                	mv	a0,s5
ffffffffc0203a5c:	739c                	ld	a5,32(a5)
ffffffffc0203a5e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a60:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203a62:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a64:	078a                	slli	a5,a5,0x2
ffffffffc0203a66:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a68:	20e7f263          	bgeu	a5,a4,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a6c:	fff80737          	lui	a4,0xfff80
ffffffffc0203a70:	97ba                	add	a5,a5,a4
ffffffffc0203a72:	000b3503          	ld	a0,0(s6)
ffffffffc0203a76:	00379713          	slli	a4,a5,0x3
ffffffffc0203a7a:	97ba                	add	a5,a5,a4
ffffffffc0203a7c:	078e                	slli	a5,a5,0x3
ffffffffc0203a7e:	953e                	add	a0,a0,a5
ffffffffc0203a80:	100027f3          	csrr	a5,sstatus
ffffffffc0203a84:	8b89                	andi	a5,a5,2
ffffffffc0203a86:	14079f63          	bnez	a5,ffffffffc0203be4 <pmm_init+0x6b8>
ffffffffc0203a8a:	000bb783          	ld	a5,0(s7)
ffffffffc0203a8e:	4585                	li	a1,1
ffffffffc0203a90:	739c                	ld	a5,32(a5)
ffffffffc0203a92:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a94:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203a98:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a9a:	078a                	slli	a5,a5,0x2
ffffffffc0203a9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a9e:	1ce7f763          	bgeu	a5,a4,ffffffffc0203c6c <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc0203aa2:	fff80737          	lui	a4,0xfff80
ffffffffc0203aa6:	97ba                	add	a5,a5,a4
ffffffffc0203aa8:	000b3503          	ld	a0,0(s6)
ffffffffc0203aac:	00379713          	slli	a4,a5,0x3
ffffffffc0203ab0:	97ba                	add	a5,a5,a4
ffffffffc0203ab2:	078e                	slli	a5,a5,0x3
ffffffffc0203ab4:	953e                	add	a0,a0,a5
ffffffffc0203ab6:	100027f3          	csrr	a5,sstatus
ffffffffc0203aba:	8b89                	andi	a5,a5,2
ffffffffc0203abc:	10079863          	bnez	a5,ffffffffc0203bcc <pmm_init+0x6a0>
ffffffffc0203ac0:	000bb783          	ld	a5,0(s7)
ffffffffc0203ac4:	4585                	li	a1,1
ffffffffc0203ac6:	739c                	ld	a5,32(a5)
ffffffffc0203ac8:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203aca:	00093783          	ld	a5,0(s2)
ffffffffc0203ace:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0203ad2:	12000073          	sfence.vma
ffffffffc0203ad6:	100027f3          	csrr	a5,sstatus
ffffffffc0203ada:	8b89                	andi	a5,a5,2
ffffffffc0203adc:	0c079e63          	bnez	a5,ffffffffc0203bb8 <pmm_init+0x68c>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203ae0:	000bb783          	ld	a5,0(s7)
ffffffffc0203ae4:	779c                	ld	a5,40(a5)
ffffffffc0203ae6:	9782                	jalr	a5
ffffffffc0203ae8:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203aea:	3a8c1a63          	bne	s8,s0,ffffffffc0203e9e <pmm_init+0x972>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203aee:	00003517          	auipc	a0,0x3
ffffffffc0203af2:	e6250513          	addi	a0,a0,-414 # ffffffffc0206950 <default_pmm_manager+0x550>
ffffffffc0203af6:	dd6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203afa:	7406                	ld	s0,96(sp)
ffffffffc0203afc:	70a6                	ld	ra,104(sp)
ffffffffc0203afe:	64e6                	ld	s1,88(sp)
ffffffffc0203b00:	6946                	ld	s2,80(sp)
ffffffffc0203b02:	69a6                	ld	s3,72(sp)
ffffffffc0203b04:	6a06                	ld	s4,64(sp)
ffffffffc0203b06:	7ae2                	ld	s5,56(sp)
ffffffffc0203b08:	7b42                	ld	s6,48(sp)
ffffffffc0203b0a:	7ba2                	ld	s7,40(sp)
ffffffffc0203b0c:	7c02                	ld	s8,32(sp)
ffffffffc0203b0e:	6ce2                	ld	s9,24(sp)
ffffffffc0203b10:	6d42                	ld	s10,16(sp)
ffffffffc0203b12:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0203b14:	f11fd06f          	j	ffffffffc0201a24 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203b18:	6705                	lui	a4,0x1
ffffffffc0203b1a:	177d                	addi	a4,a4,-1
ffffffffc0203b1c:	96ba                	add	a3,a3,a4
ffffffffc0203b1e:	777d                	lui	a4,0xfffff
ffffffffc0203b20:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0203b22:	00c75693          	srli	a3,a4,0xc
ffffffffc0203b26:	14f6f363          	bgeu	a3,a5,ffffffffc0203c6c <pmm_init+0x740>
    pmm_manager->init_memmap(base, n);
ffffffffc0203b2a:	000bb583          	ld	a1,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0203b2e:	9836                	add	a6,a6,a3
ffffffffc0203b30:	00381793          	slli	a5,a6,0x3
ffffffffc0203b34:	6994                	ld	a3,16(a1)
ffffffffc0203b36:	97c2                	add	a5,a5,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203b38:	40e60733          	sub	a4,a2,a4
ffffffffc0203b3c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0203b3e:	00c75593          	srli	a1,a4,0xc
ffffffffc0203b42:	953e                	add	a0,a0,a5
ffffffffc0203b44:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203b46:	0009b583          	ld	a1,0(s3)
}
ffffffffc0203b4a:	bcd9                	j	ffffffffc0203620 <pmm_init+0xf4>
        intr_disable();
ffffffffc0203b4c:	a79fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203b50:	000bb783          	ld	a5,0(s7)
ffffffffc0203b54:	779c                	ld	a5,40(a5)
ffffffffc0203b56:	9782                	jalr	a5
ffffffffc0203b58:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203b5a:	a65fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203b5e:	b605                	j	ffffffffc020367e <pmm_init+0x152>
        intr_disable();
ffffffffc0203b60:	a65fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203b64:	000bb783          	ld	a5,0(s7)
ffffffffc0203b68:	779c                	ld	a5,40(a5)
ffffffffc0203b6a:	9782                	jalr	a5
ffffffffc0203b6c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203b6e:	a51fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203b72:	bb5d                	j	ffffffffc0203928 <pmm_init+0x3fc>
        intr_disable();
ffffffffc0203b74:	a51fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203b78:	000bb783          	ld	a5,0(s7)
ffffffffc0203b7c:	779c                	ld	a5,40(a5)
ffffffffc0203b7e:	9782                	jalr	a5
ffffffffc0203b80:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203b82:	a3dfc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203b86:	bbbd                	j	ffffffffc0203904 <pmm_init+0x3d8>
ffffffffc0203b88:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203b8a:	a3bfc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203b8e:	000bb783          	ld	a5,0(s7)
ffffffffc0203b92:	6522                	ld	a0,8(sp)
ffffffffc0203b94:	4585                	li	a1,1
ffffffffc0203b96:	739c                	ld	a5,32(a5)
ffffffffc0203b98:	9782                	jalr	a5
        intr_enable();
ffffffffc0203b9a:	a25fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203b9e:	b399                	j	ffffffffc02038e4 <pmm_init+0x3b8>
ffffffffc0203ba0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203ba2:	a23fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203ba6:	000bb783          	ld	a5,0(s7)
ffffffffc0203baa:	6522                	ld	a0,8(sp)
ffffffffc0203bac:	4585                	li	a1,1
ffffffffc0203bae:	739c                	ld	a5,32(a5)
ffffffffc0203bb0:	9782                	jalr	a5
        intr_enable();
ffffffffc0203bb2:	a0dfc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203bb6:	b9e5                	j	ffffffffc02038ae <pmm_init+0x382>
        intr_disable();
ffffffffc0203bb8:	a0dfc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203bbc:	000bb783          	ld	a5,0(s7)
ffffffffc0203bc0:	779c                	ld	a5,40(a5)
ffffffffc0203bc2:	9782                	jalr	a5
ffffffffc0203bc4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203bc6:	9f9fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203bca:	b705                	j	ffffffffc0203aea <pmm_init+0x5be>
ffffffffc0203bcc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203bce:	9f7fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203bd2:	000bb783          	ld	a5,0(s7)
ffffffffc0203bd6:	6522                	ld	a0,8(sp)
ffffffffc0203bd8:	4585                	li	a1,1
ffffffffc0203bda:	739c                	ld	a5,32(a5)
ffffffffc0203bdc:	9782                	jalr	a5
        intr_enable();
ffffffffc0203bde:	9e1fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203be2:	b5e5                	j	ffffffffc0203aca <pmm_init+0x59e>
ffffffffc0203be4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203be6:	9dffc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203bea:	000bb783          	ld	a5,0(s7)
ffffffffc0203bee:	6522                	ld	a0,8(sp)
ffffffffc0203bf0:	4585                	li	a1,1
ffffffffc0203bf2:	739c                	ld	a5,32(a5)
ffffffffc0203bf4:	9782                	jalr	a5
        intr_enable();
ffffffffc0203bf6:	9c9fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203bfa:	bd69                	j	ffffffffc0203a94 <pmm_init+0x568>
        intr_disable();
ffffffffc0203bfc:	9c9fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203c00:	000bb783          	ld	a5,0(s7)
ffffffffc0203c04:	4585                	li	a1,1
ffffffffc0203c06:	8556                	mv	a0,s5
ffffffffc0203c08:	739c                	ld	a5,32(a5)
ffffffffc0203c0a:	9782                	jalr	a5
        intr_enable();
ffffffffc0203c0c:	9b3fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203c10:	bd81                	j	ffffffffc0203a60 <pmm_init+0x534>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203c12:	00003697          	auipc	a3,0x3
ffffffffc0203c16:	bee68693          	addi	a3,a3,-1042 # ffffffffc0206800 <default_pmm_manager+0x400>
ffffffffc0203c1a:	00002617          	auipc	a2,0x2
ffffffffc0203c1e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203c22:	19e00593          	li	a1,414
ffffffffc0203c26:	00003517          	auipc	a0,0x3
ffffffffc0203c2a:	81250513          	addi	a0,a0,-2030 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203c2e:	d9afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203c32:	00003697          	auipc	a3,0x3
ffffffffc0203c36:	b8e68693          	addi	a3,a3,-1138 # ffffffffc02067c0 <default_pmm_manager+0x3c0>
ffffffffc0203c3a:	00002617          	auipc	a2,0x2
ffffffffc0203c3e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203c42:	19d00593          	li	a1,413
ffffffffc0203c46:	00002517          	auipc	a0,0x2
ffffffffc0203c4a:	7f250513          	addi	a0,a0,2034 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203c4e:	d7afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203c52:	86a2                	mv	a3,s0
ffffffffc0203c54:	00002617          	auipc	a2,0x2
ffffffffc0203c58:	cac60613          	addi	a2,a2,-852 # ffffffffc0205900 <commands+0x980>
ffffffffc0203c5c:	19d00593          	li	a1,413
ffffffffc0203c60:	00002517          	auipc	a0,0x2
ffffffffc0203c64:	7d850513          	addi	a0,a0,2008 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203c68:	d60fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203c6c:	b7eff0ef          	jal	ra,ffffffffc0202fea <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203c70:	00002617          	auipc	a2,0x2
ffffffffc0203c74:	04060613          	addi	a2,a2,64 # ffffffffc0205cb0 <commands+0xd30>
ffffffffc0203c78:	07f00593          	li	a1,127
ffffffffc0203c7c:	00002517          	auipc	a0,0x2
ffffffffc0203c80:	7bc50513          	addi	a0,a0,1980 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203c84:	d44fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203c88:	00002617          	auipc	a2,0x2
ffffffffc0203c8c:	02860613          	addi	a2,a2,40 # ffffffffc0205cb0 <commands+0xd30>
ffffffffc0203c90:	0c300593          	li	a1,195
ffffffffc0203c94:	00002517          	auipc	a0,0x2
ffffffffc0203c98:	7a450513          	addi	a0,a0,1956 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203c9c:	d2cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203ca0:	00003697          	auipc	a3,0x3
ffffffffc0203ca4:	85868693          	addi	a3,a3,-1960 # ffffffffc02064f8 <default_pmm_manager+0xf8>
ffffffffc0203ca8:	00002617          	auipc	a2,0x2
ffffffffc0203cac:	a0060613          	addi	a2,a2,-1536 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203cb0:	16100593          	li	a1,353
ffffffffc0203cb4:	00002517          	auipc	a0,0x2
ffffffffc0203cb8:	78450513          	addi	a0,a0,1924 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203cbc:	d0cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203cc0:	00003697          	auipc	a3,0x3
ffffffffc0203cc4:	81868693          	addi	a3,a3,-2024 # ffffffffc02064d8 <default_pmm_manager+0xd8>
ffffffffc0203cc8:	00002617          	auipc	a2,0x2
ffffffffc0203ccc:	9e060613          	addi	a2,a2,-1568 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203cd0:	16000593          	li	a1,352
ffffffffc0203cd4:	00002517          	auipc	a0,0x2
ffffffffc0203cd8:	76450513          	addi	a0,a0,1892 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203cdc:	cecfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203ce0:	b26ff0ef          	jal	ra,ffffffffc0203006 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203ce4:	00003697          	auipc	a3,0x3
ffffffffc0203ce8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0206588 <default_pmm_manager+0x188>
ffffffffc0203cec:	00002617          	auipc	a2,0x2
ffffffffc0203cf0:	9bc60613          	addi	a2,a2,-1604 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203cf4:	16900593          	li	a1,361
ffffffffc0203cf8:	00002517          	auipc	a0,0x2
ffffffffc0203cfc:	74050513          	addi	a0,a0,1856 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203d00:	cc8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203d04:	00003697          	auipc	a3,0x3
ffffffffc0203d08:	85468693          	addi	a3,a3,-1964 # ffffffffc0206558 <default_pmm_manager+0x158>
ffffffffc0203d0c:	00002617          	auipc	a2,0x2
ffffffffc0203d10:	99c60613          	addi	a2,a2,-1636 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203d14:	16600593          	li	a1,358
ffffffffc0203d18:	00002517          	auipc	a0,0x2
ffffffffc0203d1c:	72050513          	addi	a0,a0,1824 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203d20:	ca8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203d24:	00003697          	auipc	a3,0x3
ffffffffc0203d28:	80c68693          	addi	a3,a3,-2036 # ffffffffc0206530 <default_pmm_manager+0x130>
ffffffffc0203d2c:	00002617          	auipc	a2,0x2
ffffffffc0203d30:	97c60613          	addi	a2,a2,-1668 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203d34:	16200593          	li	a1,354
ffffffffc0203d38:	00002517          	auipc	a0,0x2
ffffffffc0203d3c:	70050513          	addi	a0,a0,1792 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203d40:	c88fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203d44:	00003697          	auipc	a3,0x3
ffffffffc0203d48:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0206610 <default_pmm_manager+0x210>
ffffffffc0203d4c:	00002617          	auipc	a2,0x2
ffffffffc0203d50:	95c60613          	addi	a2,a2,-1700 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203d54:	17200593          	li	a1,370
ffffffffc0203d58:	00002517          	auipc	a0,0x2
ffffffffc0203d5c:	6e050513          	addi	a0,a0,1760 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203d60:	c68fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203d64:	00003697          	auipc	a3,0x3
ffffffffc0203d68:	94c68693          	addi	a3,a3,-1716 # ffffffffc02066b0 <default_pmm_manager+0x2b0>
ffffffffc0203d6c:	00002617          	auipc	a2,0x2
ffffffffc0203d70:	93c60613          	addi	a2,a2,-1732 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203d74:	17700593          	li	a1,375
ffffffffc0203d78:	00002517          	auipc	a0,0x2
ffffffffc0203d7c:	6c050513          	addi	a0,a0,1728 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203d80:	c48fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203d84:	00003697          	auipc	a3,0x3
ffffffffc0203d88:	86468693          	addi	a3,a3,-1948 # ffffffffc02065e8 <default_pmm_manager+0x1e8>
ffffffffc0203d8c:	00002617          	auipc	a2,0x2
ffffffffc0203d90:	91c60613          	addi	a2,a2,-1764 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203d94:	16f00593          	li	a1,367
ffffffffc0203d98:	00002517          	auipc	a0,0x2
ffffffffc0203d9c:	6a050513          	addi	a0,a0,1696 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203da0:	c28fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203da4:	86d6                	mv	a3,s5
ffffffffc0203da6:	00002617          	auipc	a2,0x2
ffffffffc0203daa:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0205900 <commands+0x980>
ffffffffc0203dae:	16e00593          	li	a1,366
ffffffffc0203db2:	00002517          	auipc	a0,0x2
ffffffffc0203db6:	68650513          	addi	a0,a0,1670 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203dba:	c0efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203dbe:	00003697          	auipc	a3,0x3
ffffffffc0203dc2:	88a68693          	addi	a3,a3,-1910 # ffffffffc0206648 <default_pmm_manager+0x248>
ffffffffc0203dc6:	00002617          	auipc	a2,0x2
ffffffffc0203dca:	8e260613          	addi	a2,a2,-1822 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203dce:	17c00593          	li	a1,380
ffffffffc0203dd2:	00002517          	auipc	a0,0x2
ffffffffc0203dd6:	66650513          	addi	a0,a0,1638 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203dda:	beefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203dde:	00003697          	auipc	a3,0x3
ffffffffc0203de2:	93268693          	addi	a3,a3,-1742 # ffffffffc0206710 <default_pmm_manager+0x310>
ffffffffc0203de6:	00002617          	auipc	a2,0x2
ffffffffc0203dea:	8c260613          	addi	a2,a2,-1854 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203dee:	17b00593          	li	a1,379
ffffffffc0203df2:	00002517          	auipc	a0,0x2
ffffffffc0203df6:	64650513          	addi	a0,a0,1606 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203dfa:	bcefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203dfe:	00003697          	auipc	a3,0x3
ffffffffc0203e02:	8fa68693          	addi	a3,a3,-1798 # ffffffffc02066f8 <default_pmm_manager+0x2f8>
ffffffffc0203e06:	00002617          	auipc	a2,0x2
ffffffffc0203e0a:	8a260613          	addi	a2,a2,-1886 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203e0e:	17a00593          	li	a1,378
ffffffffc0203e12:	00002517          	auipc	a0,0x2
ffffffffc0203e16:	62650513          	addi	a0,a0,1574 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203e1a:	baefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203e1e:	00003697          	auipc	a3,0x3
ffffffffc0203e22:	8aa68693          	addi	a3,a3,-1878 # ffffffffc02066c8 <default_pmm_manager+0x2c8>
ffffffffc0203e26:	00002617          	auipc	a2,0x2
ffffffffc0203e2a:	88260613          	addi	a2,a2,-1918 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203e2e:	17900593          	li	a1,377
ffffffffc0203e32:	00002517          	auipc	a0,0x2
ffffffffc0203e36:	60650513          	addi	a0,a0,1542 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203e3a:	b8efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203e3e:	00003697          	auipc	a3,0x3
ffffffffc0203e42:	a4268693          	addi	a3,a3,-1470 # ffffffffc0206880 <default_pmm_manager+0x480>
ffffffffc0203e46:	00002617          	auipc	a2,0x2
ffffffffc0203e4a:	86260613          	addi	a2,a2,-1950 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203e4e:	1a700593          	li	a1,423
ffffffffc0203e52:	00002517          	auipc	a0,0x2
ffffffffc0203e56:	5e650513          	addi	a0,a0,1510 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203e5a:	b6efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203e5e:	00003697          	auipc	a3,0x3
ffffffffc0203e62:	83a68693          	addi	a3,a3,-1990 # ffffffffc0206698 <default_pmm_manager+0x298>
ffffffffc0203e66:	00002617          	auipc	a2,0x2
ffffffffc0203e6a:	84260613          	addi	a2,a2,-1982 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203e6e:	17600593          	li	a1,374
ffffffffc0203e72:	00002517          	auipc	a0,0x2
ffffffffc0203e76:	5c650513          	addi	a0,a0,1478 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203e7a:	b4efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203e7e:	00003697          	auipc	a3,0x3
ffffffffc0203e82:	80a68693          	addi	a3,a3,-2038 # ffffffffc0206688 <default_pmm_manager+0x288>
ffffffffc0203e86:	00002617          	auipc	a2,0x2
ffffffffc0203e8a:	82260613          	addi	a2,a2,-2014 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203e8e:	17500593          	li	a1,373
ffffffffc0203e92:	00002517          	auipc	a0,0x2
ffffffffc0203e96:	5a650513          	addi	a0,a0,1446 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203e9a:	b2efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203e9e:	00003697          	auipc	a3,0x3
ffffffffc0203ea2:	8e268693          	addi	a3,a3,-1822 # ffffffffc0206780 <default_pmm_manager+0x380>
ffffffffc0203ea6:	00002617          	auipc	a2,0x2
ffffffffc0203eaa:	80260613          	addi	a2,a2,-2046 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203eae:	1b800593          	li	a1,440
ffffffffc0203eb2:	00002517          	auipc	a0,0x2
ffffffffc0203eb6:	58650513          	addi	a0,a0,1414 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203eba:	b0efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203ebe:	00002697          	auipc	a3,0x2
ffffffffc0203ec2:	7ba68693          	addi	a3,a3,1978 # ffffffffc0206678 <default_pmm_manager+0x278>
ffffffffc0203ec6:	00001617          	auipc	a2,0x1
ffffffffc0203eca:	7e260613          	addi	a2,a2,2018 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203ece:	17400593          	li	a1,372
ffffffffc0203ed2:	00002517          	auipc	a0,0x2
ffffffffc0203ed6:	56650513          	addi	a0,a0,1382 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203eda:	aeefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203ede:	00002697          	auipc	a3,0x2
ffffffffc0203ee2:	6f268693          	addi	a3,a3,1778 # ffffffffc02065d0 <default_pmm_manager+0x1d0>
ffffffffc0203ee6:	00001617          	auipc	a2,0x1
ffffffffc0203eea:	7c260613          	addi	a2,a2,1986 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203eee:	18100593          	li	a1,385
ffffffffc0203ef2:	00002517          	auipc	a0,0x2
ffffffffc0203ef6:	54650513          	addi	a0,a0,1350 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203efa:	acefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203efe:	00003697          	auipc	a3,0x3
ffffffffc0203f02:	82a68693          	addi	a3,a3,-2006 # ffffffffc0206728 <default_pmm_manager+0x328>
ffffffffc0203f06:	00001617          	auipc	a2,0x1
ffffffffc0203f0a:	7a260613          	addi	a2,a2,1954 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203f0e:	17e00593          	li	a1,382
ffffffffc0203f12:	00002517          	auipc	a0,0x2
ffffffffc0203f16:	52650513          	addi	a0,a0,1318 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203f1a:	aaefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203f1e:	00002697          	auipc	a3,0x2
ffffffffc0203f22:	69a68693          	addi	a3,a3,1690 # ffffffffc02065b8 <default_pmm_manager+0x1b8>
ffffffffc0203f26:	00001617          	auipc	a2,0x1
ffffffffc0203f2a:	78260613          	addi	a2,a2,1922 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203f2e:	17d00593          	li	a1,381
ffffffffc0203f32:	00002517          	auipc	a0,0x2
ffffffffc0203f36:	50650513          	addi	a0,a0,1286 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203f3a:	a8efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203f3e:	00002617          	auipc	a2,0x2
ffffffffc0203f42:	9c260613          	addi	a2,a2,-1598 # ffffffffc0205900 <commands+0x980>
ffffffffc0203f46:	06900593          	li	a1,105
ffffffffc0203f4a:	00002517          	auipc	a0,0x2
ffffffffc0203f4e:	9a650513          	addi	a0,a0,-1626 # ffffffffc02058f0 <commands+0x970>
ffffffffc0203f52:	a76fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203f56:	00003697          	auipc	a3,0x3
ffffffffc0203f5a:	80268693          	addi	a3,a3,-2046 # ffffffffc0206758 <default_pmm_manager+0x358>
ffffffffc0203f5e:	00001617          	auipc	a2,0x1
ffffffffc0203f62:	74a60613          	addi	a2,a2,1866 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203f66:	18800593          	li	a1,392
ffffffffc0203f6a:	00002517          	auipc	a0,0x2
ffffffffc0203f6e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203f72:	a56fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203f76:	00002697          	auipc	a3,0x2
ffffffffc0203f7a:	79a68693          	addi	a3,a3,1946 # ffffffffc0206710 <default_pmm_manager+0x310>
ffffffffc0203f7e:	00001617          	auipc	a2,0x1
ffffffffc0203f82:	72a60613          	addi	a2,a2,1834 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203f86:	18600593          	li	a1,390
ffffffffc0203f8a:	00002517          	auipc	a0,0x2
ffffffffc0203f8e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203f92:	a36fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203f96:	00002697          	auipc	a3,0x2
ffffffffc0203f9a:	7aa68693          	addi	a3,a3,1962 # ffffffffc0206740 <default_pmm_manager+0x340>
ffffffffc0203f9e:	00001617          	auipc	a2,0x1
ffffffffc0203fa2:	70a60613          	addi	a2,a2,1802 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203fa6:	18500593          	li	a1,389
ffffffffc0203faa:	00002517          	auipc	a0,0x2
ffffffffc0203fae:	48e50513          	addi	a0,a0,1166 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203fb2:	a16fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203fb6:	00002697          	auipc	a3,0x2
ffffffffc0203fba:	75a68693          	addi	a3,a3,1882 # ffffffffc0206710 <default_pmm_manager+0x310>
ffffffffc0203fbe:	00001617          	auipc	a2,0x1
ffffffffc0203fc2:	6ea60613          	addi	a2,a2,1770 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203fc6:	18200593          	li	a1,386
ffffffffc0203fca:	00002517          	auipc	a0,0x2
ffffffffc0203fce:	46e50513          	addi	a0,a0,1134 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203fd2:	9f6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203fd6:	00003697          	auipc	a3,0x3
ffffffffc0203fda:	89268693          	addi	a3,a3,-1902 # ffffffffc0206868 <default_pmm_manager+0x468>
ffffffffc0203fde:	00001617          	auipc	a2,0x1
ffffffffc0203fe2:	6ca60613          	addi	a2,a2,1738 # ffffffffc02056a8 <commands+0x728>
ffffffffc0203fe6:	1a600593          	li	a1,422
ffffffffc0203fea:	00002517          	auipc	a0,0x2
ffffffffc0203fee:	44e50513          	addi	a0,a0,1102 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0203ff2:	9d6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203ff6:	00003697          	auipc	a3,0x3
ffffffffc0203ffa:	83a68693          	addi	a3,a3,-1990 # ffffffffc0206830 <default_pmm_manager+0x430>
ffffffffc0203ffe:	00001617          	auipc	a2,0x1
ffffffffc0204002:	6aa60613          	addi	a2,a2,1706 # ffffffffc02056a8 <commands+0x728>
ffffffffc0204006:	1a500593          	li	a1,421
ffffffffc020400a:	00002517          	auipc	a0,0x2
ffffffffc020400e:	42e50513          	addi	a0,a0,1070 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0204012:	9b6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0204016:	00003697          	auipc	a3,0x3
ffffffffc020401a:	80268693          	addi	a3,a3,-2046 # ffffffffc0206818 <default_pmm_manager+0x418>
ffffffffc020401e:	00001617          	auipc	a2,0x1
ffffffffc0204022:	68a60613          	addi	a2,a2,1674 # ffffffffc02056a8 <commands+0x728>
ffffffffc0204026:	1a100593          	li	a1,417
ffffffffc020402a:	00002517          	auipc	a0,0x2
ffffffffc020402e:	40e50513          	addi	a0,a0,1038 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0204032:	996fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204036:	00002697          	auipc	a3,0x2
ffffffffc020403a:	74a68693          	addi	a3,a3,1866 # ffffffffc0206780 <default_pmm_manager+0x380>
ffffffffc020403e:	00001617          	auipc	a2,0x1
ffffffffc0204042:	66a60613          	addi	a2,a2,1642 # ffffffffc02056a8 <commands+0x728>
ffffffffc0204046:	19000593          	li	a1,400
ffffffffc020404a:	00002517          	auipc	a0,0x2
ffffffffc020404e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0204052:	976fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0204056:	00002697          	auipc	a3,0x2
ffffffffc020405a:	56268693          	addi	a3,a3,1378 # ffffffffc02065b8 <default_pmm_manager+0x1b8>
ffffffffc020405e:	00001617          	auipc	a2,0x1
ffffffffc0204062:	64a60613          	addi	a2,a2,1610 # ffffffffc02056a8 <commands+0x728>
ffffffffc0204066:	16a00593          	li	a1,362
ffffffffc020406a:	00002517          	auipc	a0,0x2
ffffffffc020406e:	3ce50513          	addi	a0,a0,974 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc0204072:	956fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204076:	00002617          	auipc	a2,0x2
ffffffffc020407a:	88a60613          	addi	a2,a2,-1910 # ffffffffc0205900 <commands+0x980>
ffffffffc020407e:	16d00593          	li	a1,365
ffffffffc0204082:	00002517          	auipc	a0,0x2
ffffffffc0204086:	3b650513          	addi	a0,a0,950 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc020408a:	93efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020408e:	00002697          	auipc	a3,0x2
ffffffffc0204092:	54268693          	addi	a3,a3,1346 # ffffffffc02065d0 <default_pmm_manager+0x1d0>
ffffffffc0204096:	00001617          	auipc	a2,0x1
ffffffffc020409a:	61260613          	addi	a2,a2,1554 # ffffffffc02056a8 <commands+0x728>
ffffffffc020409e:	16b00593          	li	a1,363
ffffffffc02040a2:	00002517          	auipc	a0,0x2
ffffffffc02040a6:	39650513          	addi	a0,a0,918 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc02040aa:	91efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02040ae:	00002697          	auipc	a3,0x2
ffffffffc02040b2:	59a68693          	addi	a3,a3,1434 # ffffffffc0206648 <default_pmm_manager+0x248>
ffffffffc02040b6:	00001617          	auipc	a2,0x1
ffffffffc02040ba:	5f260613          	addi	a2,a2,1522 # ffffffffc02056a8 <commands+0x728>
ffffffffc02040be:	17300593          	li	a1,371
ffffffffc02040c2:	00002517          	auipc	a0,0x2
ffffffffc02040c6:	37650513          	addi	a0,a0,886 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc02040ca:	8fefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02040ce:	00003697          	auipc	a3,0x3
ffffffffc02040d2:	85a68693          	addi	a3,a3,-1958 # ffffffffc0206928 <default_pmm_manager+0x528>
ffffffffc02040d6:	00001617          	auipc	a2,0x1
ffffffffc02040da:	5d260613          	addi	a2,a2,1490 # ffffffffc02056a8 <commands+0x728>
ffffffffc02040de:	1af00593          	li	a1,431
ffffffffc02040e2:	00002517          	auipc	a0,0x2
ffffffffc02040e6:	35650513          	addi	a0,a0,854 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc02040ea:	8defc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02040ee:	00003697          	auipc	a3,0x3
ffffffffc02040f2:	80268693          	addi	a3,a3,-2046 # ffffffffc02068f0 <default_pmm_manager+0x4f0>
ffffffffc02040f6:	00001617          	auipc	a2,0x1
ffffffffc02040fa:	5b260613          	addi	a2,a2,1458 # ffffffffc02056a8 <commands+0x728>
ffffffffc02040fe:	1ac00593          	li	a1,428
ffffffffc0204102:	00002517          	auipc	a0,0x2
ffffffffc0204106:	33650513          	addi	a0,a0,822 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc020410a:	8befc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020410e:	00002697          	auipc	a3,0x2
ffffffffc0204112:	7b268693          	addi	a3,a3,1970 # ffffffffc02068c0 <default_pmm_manager+0x4c0>
ffffffffc0204116:	00001617          	auipc	a2,0x1
ffffffffc020411a:	59260613          	addi	a2,a2,1426 # ffffffffc02056a8 <commands+0x728>
ffffffffc020411e:	1a800593          	li	a1,424
ffffffffc0204122:	00002517          	auipc	a0,0x2
ffffffffc0204126:	31650513          	addi	a0,a0,790 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc020412a:	89efc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020412e <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020412e:	12058073          	sfence.vma	a1
}
ffffffffc0204132:	8082                	ret

ffffffffc0204134 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204134:	7179                	addi	sp,sp,-48
ffffffffc0204136:	e84a                	sd	s2,16(sp)
ffffffffc0204138:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020413a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020413c:	f022                	sd	s0,32(sp)
ffffffffc020413e:	ec26                	sd	s1,24(sp)
ffffffffc0204140:	e44e                	sd	s3,8(sp)
ffffffffc0204142:	f406                	sd	ra,40(sp)
ffffffffc0204144:	84ae                	mv	s1,a1
ffffffffc0204146:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204148:	edbfe0ef          	jal	ra,ffffffffc0203022 <alloc_pages>
ffffffffc020414c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020414e:	cd09                	beqz	a0,ffffffffc0204168 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204150:	85aa                	mv	a1,a0
ffffffffc0204152:	86ce                	mv	a3,s3
ffffffffc0204154:	8626                	mv	a2,s1
ffffffffc0204156:	854a                	mv	a0,s2
ffffffffc0204158:	ac8ff0ef          	jal	ra,ffffffffc0203420 <page_insert>
ffffffffc020415c:	ed21                	bnez	a0,ffffffffc02041b4 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020415e:	00011797          	auipc	a5,0x11
ffffffffc0204162:	4127a783          	lw	a5,1042(a5) # ffffffffc0215570 <swap_init_ok>
ffffffffc0204166:	eb89                	bnez	a5,ffffffffc0204178 <pgdir_alloc_page+0x44>
}
ffffffffc0204168:	70a2                	ld	ra,40(sp)
ffffffffc020416a:	8522                	mv	a0,s0
ffffffffc020416c:	7402                	ld	s0,32(sp)
ffffffffc020416e:	64e2                	ld	s1,24(sp)
ffffffffc0204170:	6942                	ld	s2,16(sp)
ffffffffc0204172:	69a2                	ld	s3,8(sp)
ffffffffc0204174:	6145                	addi	sp,sp,48
ffffffffc0204176:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204178:	4681                	li	a3,0
ffffffffc020417a:	8622                	mv	a2,s0
ffffffffc020417c:	85a6                	mv	a1,s1
ffffffffc020417e:	00011517          	auipc	a0,0x11
ffffffffc0204182:	3ca53503          	ld	a0,970(a0) # ffffffffc0215548 <check_mm_struct>
ffffffffc0204186:	9f2fe0ef          	jal	ra,ffffffffc0202378 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc020418a:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc020418c:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020418e:	4785                	li	a5,1
ffffffffc0204190:	fcf70ce3          	beq	a4,a5,ffffffffc0204168 <pgdir_alloc_page+0x34>
ffffffffc0204194:	00002697          	auipc	a3,0x2
ffffffffc0204198:	7dc68693          	addi	a3,a3,2012 # ffffffffc0206970 <default_pmm_manager+0x570>
ffffffffc020419c:	00001617          	auipc	a2,0x1
ffffffffc02041a0:	50c60613          	addi	a2,a2,1292 # ffffffffc02056a8 <commands+0x728>
ffffffffc02041a4:	14800593          	li	a1,328
ffffffffc02041a8:	00002517          	auipc	a0,0x2
ffffffffc02041ac:	29050513          	addi	a0,a0,656 # ffffffffc0206438 <default_pmm_manager+0x38>
ffffffffc02041b0:	818fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02041b4:	100027f3          	csrr	a5,sstatus
ffffffffc02041b8:	8b89                	andi	a5,a5,2
ffffffffc02041ba:	eb99                	bnez	a5,ffffffffc02041d0 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc02041bc:	00011797          	auipc	a5,0x11
ffffffffc02041c0:	3dc7b783          	ld	a5,988(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc02041c4:	739c                	ld	a5,32(a5)
ffffffffc02041c6:	8522                	mv	a0,s0
ffffffffc02041c8:	4585                	li	a1,1
ffffffffc02041ca:	9782                	jalr	a5
            return NULL;
ffffffffc02041cc:	4401                	li	s0,0
ffffffffc02041ce:	bf69                	j	ffffffffc0204168 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc02041d0:	bf4fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02041d4:	00011797          	auipc	a5,0x11
ffffffffc02041d8:	3c47b783          	ld	a5,964(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc02041dc:	739c                	ld	a5,32(a5)
ffffffffc02041de:	8522                	mv	a0,s0
ffffffffc02041e0:	4585                	li	a1,1
ffffffffc02041e2:	9782                	jalr	a5
            return NULL;
ffffffffc02041e4:	4401                	li	s0,0
        intr_enable();
ffffffffc02041e6:	bd8fc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02041ea:	bfbd                	j	ffffffffc0204168 <pgdir_alloc_page+0x34>

ffffffffc02041ec <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02041ec:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02041ee:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02041f0:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02041f2:	ab2fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_valid>
ffffffffc02041f6:	cd01                	beqz	a0,ffffffffc020420e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02041f8:	4505                	li	a0,1
ffffffffc02041fa:	ab0fc0ef          	jal	ra,ffffffffc02004aa <ide_device_size>
}
ffffffffc02041fe:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204200:	810d                	srli	a0,a0,0x3
ffffffffc0204202:	00011797          	auipc	a5,0x11
ffffffffc0204206:	34a7bf23          	sd	a0,862(a5) # ffffffffc0215560 <max_swap_offset>
}
ffffffffc020420a:	0141                	addi	sp,sp,16
ffffffffc020420c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020420e:	00002617          	auipc	a2,0x2
ffffffffc0204212:	77a60613          	addi	a2,a2,1914 # ffffffffc0206988 <default_pmm_manager+0x588>
ffffffffc0204216:	45b5                	li	a1,13
ffffffffc0204218:	00002517          	auipc	a0,0x2
ffffffffc020421c:	79050513          	addi	a0,a0,1936 # ffffffffc02069a8 <default_pmm_manager+0x5a8>
ffffffffc0204220:	fa9fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204224 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204224:	1141                	addi	sp,sp,-16
ffffffffc0204226:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204228:	00855793          	srli	a5,a0,0x8
ffffffffc020422c:	c3a5                	beqz	a5,ffffffffc020428c <swapfs_read+0x68>
ffffffffc020422e:	00011717          	auipc	a4,0x11
ffffffffc0204232:	33273703          	ld	a4,818(a4) # ffffffffc0215560 <max_swap_offset>
ffffffffc0204236:	04e7fb63          	bgeu	a5,a4,ffffffffc020428c <swapfs_read+0x68>
    return page - pages + nbase;
ffffffffc020423a:	00011617          	auipc	a2,0x11
ffffffffc020423e:	35663603          	ld	a2,854(a2) # ffffffffc0215590 <pages>
ffffffffc0204242:	8d91                	sub	a1,a1,a2
ffffffffc0204244:	4035d613          	srai	a2,a1,0x3
ffffffffc0204248:	00003597          	auipc	a1,0x3
ffffffffc020424c:	b205b583          	ld	a1,-1248(a1) # ffffffffc0206d68 <error_string+0x38>
ffffffffc0204250:	02b60633          	mul	a2,a2,a1
ffffffffc0204254:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204258:	00003797          	auipc	a5,0x3
ffffffffc020425c:	b187b783          	ld	a5,-1256(a5) # ffffffffc0206d70 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204260:	00011717          	auipc	a4,0x11
ffffffffc0204264:	32873703          	ld	a4,808(a4) # ffffffffc0215588 <npage>
    return page - pages + nbase;
ffffffffc0204268:	963e                	add	a2,a2,a5
    return KADDR(page2pa(page));
ffffffffc020426a:	00c61793          	slli	a5,a2,0xc
ffffffffc020426e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204270:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204272:	02e7f963          	bgeu	a5,a4,ffffffffc02042a4 <swapfs_read+0x80>
}
ffffffffc0204276:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204278:	00011797          	auipc	a5,0x11
ffffffffc020427c:	3287b783          	ld	a5,808(a5) # ffffffffc02155a0 <va_pa_offset>
ffffffffc0204280:	46a1                	li	a3,8
ffffffffc0204282:	963e                	add	a2,a2,a5
ffffffffc0204284:	4505                	li	a0,1
}
ffffffffc0204286:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204288:	a28fc06f          	j	ffffffffc02004b0 <ide_read_secs>
ffffffffc020428c:	86aa                	mv	a3,a0
ffffffffc020428e:	00002617          	auipc	a2,0x2
ffffffffc0204292:	73260613          	addi	a2,a2,1842 # ffffffffc02069c0 <default_pmm_manager+0x5c0>
ffffffffc0204296:	45d1                	li	a1,20
ffffffffc0204298:	00002517          	auipc	a0,0x2
ffffffffc020429c:	71050513          	addi	a0,a0,1808 # ffffffffc02069a8 <default_pmm_manager+0x5a8>
ffffffffc02042a0:	f29fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02042a4:	86b2                	mv	a3,a2
ffffffffc02042a6:	06900593          	li	a1,105
ffffffffc02042aa:	00001617          	auipc	a2,0x1
ffffffffc02042ae:	65660613          	addi	a2,a2,1622 # ffffffffc0205900 <commands+0x980>
ffffffffc02042b2:	00001517          	auipc	a0,0x1
ffffffffc02042b6:	63e50513          	addi	a0,a0,1598 # ffffffffc02058f0 <commands+0x970>
ffffffffc02042ba:	f0ffb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02042be <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02042be:	1141                	addi	sp,sp,-16
ffffffffc02042c0:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02042c2:	00855793          	srli	a5,a0,0x8
ffffffffc02042c6:	c3a5                	beqz	a5,ffffffffc0204326 <swapfs_write+0x68>
ffffffffc02042c8:	00011717          	auipc	a4,0x11
ffffffffc02042cc:	29873703          	ld	a4,664(a4) # ffffffffc0215560 <max_swap_offset>
ffffffffc02042d0:	04e7fb63          	bgeu	a5,a4,ffffffffc0204326 <swapfs_write+0x68>
    return page - pages + nbase;
ffffffffc02042d4:	00011617          	auipc	a2,0x11
ffffffffc02042d8:	2bc63603          	ld	a2,700(a2) # ffffffffc0215590 <pages>
ffffffffc02042dc:	8d91                	sub	a1,a1,a2
ffffffffc02042de:	4035d613          	srai	a2,a1,0x3
ffffffffc02042e2:	00003597          	auipc	a1,0x3
ffffffffc02042e6:	a865b583          	ld	a1,-1402(a1) # ffffffffc0206d68 <error_string+0x38>
ffffffffc02042ea:	02b60633          	mul	a2,a2,a1
ffffffffc02042ee:	0037959b          	slliw	a1,a5,0x3
ffffffffc02042f2:	00003797          	auipc	a5,0x3
ffffffffc02042f6:	a7e7b783          	ld	a5,-1410(a5) # ffffffffc0206d70 <nbase>
    return KADDR(page2pa(page));
ffffffffc02042fa:	00011717          	auipc	a4,0x11
ffffffffc02042fe:	28e73703          	ld	a4,654(a4) # ffffffffc0215588 <npage>
    return page - pages + nbase;
ffffffffc0204302:	963e                	add	a2,a2,a5
    return KADDR(page2pa(page));
ffffffffc0204304:	00c61793          	slli	a5,a2,0xc
ffffffffc0204308:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020430a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020430c:	02e7f963          	bgeu	a5,a4,ffffffffc020433e <swapfs_write+0x80>
}
ffffffffc0204310:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204312:	00011797          	auipc	a5,0x11
ffffffffc0204316:	28e7b783          	ld	a5,654(a5) # ffffffffc02155a0 <va_pa_offset>
ffffffffc020431a:	46a1                	li	a3,8
ffffffffc020431c:	963e                	add	a2,a2,a5
ffffffffc020431e:	4505                	li	a0,1
}
ffffffffc0204320:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204322:	9b2fc06f          	j	ffffffffc02004d4 <ide_write_secs>
ffffffffc0204326:	86aa                	mv	a3,a0
ffffffffc0204328:	00002617          	auipc	a2,0x2
ffffffffc020432c:	69860613          	addi	a2,a2,1688 # ffffffffc02069c0 <default_pmm_manager+0x5c0>
ffffffffc0204330:	45e5                	li	a1,25
ffffffffc0204332:	00002517          	auipc	a0,0x2
ffffffffc0204336:	67650513          	addi	a0,a0,1654 # ffffffffc02069a8 <default_pmm_manager+0x5a8>
ffffffffc020433a:	e8ffb0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020433e:	86b2                	mv	a3,a2
ffffffffc0204340:	06900593          	li	a1,105
ffffffffc0204344:	00001617          	auipc	a2,0x1
ffffffffc0204348:	5bc60613          	addi	a2,a2,1468 # ffffffffc0205900 <commands+0x980>
ffffffffc020434c:	00001517          	auipc	a0,0x1
ffffffffc0204350:	5a450513          	addi	a0,a0,1444 # ffffffffc02058f0 <commands+0x970>
ffffffffc0204354:	e75fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204358 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204358:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020435c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204360:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204362:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204364:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204368:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020436c:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204370:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204374:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204378:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020437c:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204380:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204384:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204388:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020438c:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204390:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204394:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204396:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204398:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc020439c:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02043a0:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02043a4:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02043a8:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02043ac:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02043b0:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02043b4:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02043b8:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02043bc:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02043c0:	8082                	ret

ffffffffc02043c2 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02043c2:	7179                	addi	sp,sp,-48
ffffffffc02043c4:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02043c6:	00011497          	auipc	s1,0x11
ffffffffc02043ca:	14a48493          	addi	s1,s1,330 # ffffffffc0215510 <name.0>
init_main(void *arg) {
ffffffffc02043ce:	f022                	sd	s0,32(sp)
ffffffffc02043d0:	e84a                	sd	s2,16(sp)
ffffffffc02043d2:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043d4:	00011917          	auipc	s2,0x11
ffffffffc02043d8:	1d493903          	ld	s2,468(s2) # ffffffffc02155a8 <current>
    memset(name, 0, sizeof(name));
ffffffffc02043dc:	4641                	li	a2,16
ffffffffc02043de:	4581                	li	a1,0
ffffffffc02043e0:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc02043e2:	f406                	sd	ra,40(sp)
ffffffffc02043e4:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043e6:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc02043ea:	4b8000ef          	jal	ra,ffffffffc02048a2 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02043ee:	0b490593          	addi	a1,s2,180
ffffffffc02043f2:	463d                	li	a2,15
ffffffffc02043f4:	8526                	mv	a0,s1
ffffffffc02043f6:	4be000ef          	jal	ra,ffffffffc02048b4 <memcpy>
ffffffffc02043fa:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043fc:	85ce                	mv	a1,s3
ffffffffc02043fe:	00002517          	auipc	a0,0x2
ffffffffc0204402:	5e250513          	addi	a0,a0,1506 # ffffffffc02069e0 <default_pmm_manager+0x5e0>
ffffffffc0204406:	cc7fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020440a:	85a2                	mv	a1,s0
ffffffffc020440c:	00002517          	auipc	a0,0x2
ffffffffc0204410:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206a08 <default_pmm_manager+0x608>
ffffffffc0204414:	cb9fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204418:	00002517          	auipc	a0,0x2
ffffffffc020441c:	60050513          	addi	a0,a0,1536 # ffffffffc0206a18 <default_pmm_manager+0x618>
ffffffffc0204420:	cadfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc0204424:	70a2                	ld	ra,40(sp)
ffffffffc0204426:	7402                	ld	s0,32(sp)
ffffffffc0204428:	64e2                	ld	s1,24(sp)
ffffffffc020442a:	6942                	ld	s2,16(sp)
ffffffffc020442c:	69a2                	ld	s3,8(sp)
ffffffffc020442e:	4501                	li	a0,0
ffffffffc0204430:	6145                	addi	sp,sp,48
ffffffffc0204432:	8082                	ret

ffffffffc0204434 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204434:	7179                	addi	sp,sp,-48
ffffffffc0204436:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204438:	00011917          	auipc	s2,0x11
ffffffffc020443c:	17090913          	addi	s2,s2,368 # ffffffffc02155a8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204440:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204442:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204446:	f406                	sd	ra,40(sp)
ffffffffc0204448:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc020444a:	02a48963          	beq	s1,a0,ffffffffc020447c <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020444e:	100027f3          	csrr	a5,sstatus
ffffffffc0204452:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204454:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204456:	e3a1                	bnez	a5,ffffffffc0204496 <proc_run+0x62>
        lcr3(proc->cr3);//修改页表基址的地址
ffffffffc0204458:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020445a:	80000737          	lui	a4,0x80000
        current = proc;
ffffffffc020445e:	00a93023          	sd	a0,0(s2)
ffffffffc0204462:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204466:	8fd9                	or	a5,a5,a4
ffffffffc0204468:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(proc->context));// 切换上下文状态
ffffffffc020446c:	03050593          	addi	a1,a0,48
ffffffffc0204470:	03048513          	addi	a0,s1,48
ffffffffc0204474:	ee5ff0ef          	jal	ra,ffffffffc0204358 <switch_to>
    if (flag) {
ffffffffc0204478:	00099863          	bnez	s3,ffffffffc0204488 <proc_run+0x54>
}
ffffffffc020447c:	70a2                	ld	ra,40(sp)
ffffffffc020447e:	7482                	ld	s1,32(sp)
ffffffffc0204480:	6962                	ld	s2,24(sp)
ffffffffc0204482:	69c2                	ld	s3,16(sp)
ffffffffc0204484:	6145                	addi	sp,sp,48
ffffffffc0204486:	8082                	ret
ffffffffc0204488:	70a2                	ld	ra,40(sp)
ffffffffc020448a:	7482                	ld	s1,32(sp)
ffffffffc020448c:	6962                	ld	s2,24(sp)
ffffffffc020448e:	69c2                	ld	s3,16(sp)
ffffffffc0204490:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204492:	92cfc06f          	j	ffffffffc02005be <intr_enable>
ffffffffc0204496:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204498:	92cfc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc020449c:	6522                	ld	a0,8(sp)
ffffffffc020449e:	4985                	li	s3,1
ffffffffc02044a0:	bf65                	j	ffffffffc0204458 <proc_run+0x24>

ffffffffc02044a2 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02044a2:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02044a4:	12000613          	li	a2,288
ffffffffc02044a8:	4581                	li	a1,0
ffffffffc02044aa:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02044ac:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02044ae:	3f4000ef          	jal	ra,ffffffffc02048a2 <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02044b2:	100027f3          	csrr	a5,sstatus
}
ffffffffc02044b6:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02044b8:	00011517          	auipc	a0,0x11
ffffffffc02044bc:	10852503          	lw	a0,264(a0) # ffffffffc02155c0 <nr_process>
ffffffffc02044c0:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc02044c2:	00f52533          	slt	a0,a0,a5
}
ffffffffc02044c6:	156d                	addi	a0,a0,-5
ffffffffc02044c8:	6155                	addi	sp,sp,304
ffffffffc02044ca:	8082                	ret

ffffffffc02044cc <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc02044cc:	7139                	addi	sp,sp,-64
ffffffffc02044ce:	f426                	sd	s1,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02044d0:	00011797          	auipc	a5,0x11
ffffffffc02044d4:	05078793          	addi	a5,a5,80 # ffffffffc0215520 <proc_list>
ffffffffc02044d8:	fc06                	sd	ra,56(sp)
ffffffffc02044da:	f822                	sd	s0,48(sp)
ffffffffc02044dc:	f04a                	sd	s2,32(sp)
ffffffffc02044de:	ec4e                	sd	s3,24(sp)
ffffffffc02044e0:	e852                	sd	s4,16(sp)
ffffffffc02044e2:	e456                	sd	s5,8(sp)
ffffffffc02044e4:	0000d497          	auipc	s1,0xd
ffffffffc02044e8:	02c48493          	addi	s1,s1,44 # ffffffffc0211510 <hash_list>
ffffffffc02044ec:	e79c                	sd	a5,8(a5)
ffffffffc02044ee:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02044f0:	00011717          	auipc	a4,0x11
ffffffffc02044f4:	02070713          	addi	a4,a4,32 # ffffffffc0215510 <name.0>
ffffffffc02044f8:	87a6                	mv	a5,s1
ffffffffc02044fa:	e79c                	sd	a5,8(a5)
ffffffffc02044fc:	e39c                	sd	a5,0(a5)
ffffffffc02044fe:	07c1                	addi	a5,a5,16
ffffffffc0204500:	fef71de3          	bne	a4,a5,ffffffffc02044fa <proc_init+0x2e>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204504:	0e800513          	li	a0,232
ffffffffc0204508:	d3cfd0ef          	jal	ra,ffffffffc0201a44 <kmalloc>
ffffffffc020450c:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc020450e:	1e050863          	beqz	a0,ffffffffc02046fe <proc_init+0x232>
    proc->state = PROC_UNINIT;
ffffffffc0204512:	59fd                	li	s3,-1
ffffffffc0204514:	1982                	slli	s3,s3,0x20
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204516:	07000613          	li	a2,112
ffffffffc020451a:	4581                	li	a1,0
    proc->state = PROC_UNINIT;
ffffffffc020451c:	01353023          	sd	s3,0(a0)
    proc->runs = 0;
ffffffffc0204520:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204524:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204528:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL;
ffffffffc020452c:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204530:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204534:	03050513          	addi	a0,a0,48
ffffffffc0204538:	36a000ef          	jal	ra,ffffffffc02048a2 <memset>
    proc->cr3 = boot_cr3;
ffffffffc020453c:	00011a97          	auipc	s5,0x11
ffffffffc0204540:	03ca8a93          	addi	s5,s5,60 # ffffffffc0215578 <boot_cr3>
ffffffffc0204544:	000ab783          	ld	a5,0(s5)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204548:	4641                	li	a2,16
ffffffffc020454a:	4581                	li	a1,0
    proc->cr3 = boot_cr3;
ffffffffc020454c:	f45c                	sd	a5,168(s0)
    proc->tf = NULL;
ffffffffc020454e:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204552:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204556:	0b440513          	addi	a0,s0,180
ffffffffc020455a:	348000ef          	jal	ra,ffffffffc02048a2 <memset>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020455e:	00011917          	auipc	s2,0x11
ffffffffc0204562:	05290913          	addi	s2,s2,82 # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204566:	07000513          	li	a0,112
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020456a:	00893023          	sd	s0,0(s2)
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020456e:	cd6fd0ef          	jal	ra,ffffffffc0201a44 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204572:	07000613          	li	a2,112
ffffffffc0204576:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204578:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020457a:	328000ef          	jal	ra,ffffffffc02048a2 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020457e:	00093503          	ld	a0,0(s2)
ffffffffc0204582:	85a2                	mv	a1,s0
ffffffffc0204584:	07000613          	li	a2,112
ffffffffc0204588:	03050513          	addi	a0,a0,48
ffffffffc020458c:	340000ef          	jal	ra,ffffffffc02048cc <memcmp>
ffffffffc0204590:	8a2a                	mv	s4,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204592:	453d                	li	a0,15
ffffffffc0204594:	cb0fd0ef          	jal	ra,ffffffffc0201a44 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204598:	463d                	li	a2,15
ffffffffc020459a:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020459c:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020459e:	304000ef          	jal	ra,ffffffffc02048a2 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02045a2:	00093503          	ld	a0,0(s2)
ffffffffc02045a6:	463d                	li	a2,15
ffffffffc02045a8:	85a2                	mv	a1,s0
ffffffffc02045aa:	0b450513          	addi	a0,a0,180
ffffffffc02045ae:	31e000ef          	jal	ra,ffffffffc02048cc <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02045b2:	00093783          	ld	a5,0(s2)
ffffffffc02045b6:	000ab703          	ld	a4,0(s5)
ffffffffc02045ba:	77d4                	ld	a3,168(a5)
ffffffffc02045bc:	0ee68663          	beq	a3,a4,ffffffffc02046a8 <proc_init+0x1dc>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;//idleproc是第0个内核线程
    idleproc->state = PROC_RUNNABLE;//使得它从“出生”转到了“准备工作”，就差uCore调度它执行了
ffffffffc02045c0:	4709                	li	a4,2
ffffffffc02045c2:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;//uCore启动时设置的内核栈直接分配给idleproc使用
ffffffffc02045c4:	00003717          	auipc	a4,0x3
ffffffffc02045c8:	a3c70713          	addi	a4,a4,-1476 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02045cc:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;//uCore启动时设置的内核栈直接分配给idleproc使用
ffffffffc02045d0:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;//如果当前idleproc在执行，则只要此标志为1，马上就调用schedule函数要求调度器切换其他进程执行。
ffffffffc02045d2:	4705                	li	a4,1
ffffffffc02045d4:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02045d6:	4641                	li	a2,16
ffffffffc02045d8:	4581                	li	a1,0
ffffffffc02045da:	8522                	mv	a0,s0
ffffffffc02045dc:	2c6000ef          	jal	ra,ffffffffc02048a2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02045e0:	463d                	li	a2,15
ffffffffc02045e2:	00002597          	auipc	a1,0x2
ffffffffc02045e6:	49e58593          	addi	a1,a1,1182 # ffffffffc0206a80 <default_pmm_manager+0x680>
ffffffffc02045ea:	8522                	mv	a0,s0
ffffffffc02045ec:	2c8000ef          	jal	ra,ffffffffc02048b4 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc02045f0:	00011717          	auipc	a4,0x11
ffffffffc02045f4:	fd070713          	addi	a4,a4,-48 # ffffffffc02155c0 <nr_process>
ffffffffc02045f8:	431c                	lw	a5,0(a4)

    current = idleproc;//当前进程是idleproc，0号进程
ffffffffc02045fa:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02045fe:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204600:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204602:	00002597          	auipc	a1,0x2
ffffffffc0204606:	48658593          	addi	a1,a1,1158 # ffffffffc0206a88 <default_pmm_manager+0x688>
ffffffffc020460a:	00000517          	auipc	a0,0x0
ffffffffc020460e:	db850513          	addi	a0,a0,-584 # ffffffffc02043c2 <init_main>
    nr_process ++;
ffffffffc0204612:	c31c                	sw	a5,0(a4)
    current = idleproc;//当前进程是idleproc，0号进程
ffffffffc0204614:	00011797          	auipc	a5,0x11
ffffffffc0204618:	f8d7ba23          	sd	a3,-108(a5) # ffffffffc02155a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020461c:	e87ff0ef          	jal	ra,ffffffffc02044a2 <kernel_thread>
ffffffffc0204620:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0204622:	0ea05e63          	blez	a0,ffffffffc020471e <proc_init+0x252>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204626:	6789                	lui	a5,0x2
ffffffffc0204628:	fff5071b          	addiw	a4,a0,-1
ffffffffc020462c:	17f9                	addi	a5,a5,-2
ffffffffc020462e:	2501                	sext.w	a0,a0
ffffffffc0204630:	02e7e363          	bltu	a5,a4,ffffffffc0204656 <proc_init+0x18a>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204634:	45a9                	li	a1,10
ffffffffc0204636:	6a8000ef          	jal	ra,ffffffffc0204cde <hash32>
ffffffffc020463a:	02051793          	slli	a5,a0,0x20
ffffffffc020463e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204642:	96a6                	add	a3,a3,s1
ffffffffc0204644:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204646:	a029                	j	ffffffffc0204650 <proc_init+0x184>
            if (proc->pid == pid) {
ffffffffc0204648:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc020464c:	0a870663          	beq	a4,s0,ffffffffc02046f8 <proc_init+0x22c>
    return listelm->next;
ffffffffc0204650:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204652:	fef69be3          	bne	a3,a5,ffffffffc0204648 <proc_init+0x17c>
    return NULL;
ffffffffc0204656:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204658:	0b478493          	addi	s1,a5,180
ffffffffc020465c:	4641                	li	a2,16
ffffffffc020465e:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204660:	00011417          	auipc	s0,0x11
ffffffffc0204664:	f5840413          	addi	s0,s0,-168 # ffffffffc02155b8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204668:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020466a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020466c:	236000ef          	jal	ra,ffffffffc02048a2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204670:	463d                	li	a2,15
ffffffffc0204672:	00002597          	auipc	a1,0x2
ffffffffc0204676:	44658593          	addi	a1,a1,1094 # ffffffffc0206ab8 <default_pmm_manager+0x6b8>
ffffffffc020467a:	8526                	mv	a0,s1
ffffffffc020467c:	238000ef          	jal	ra,ffffffffc02048b4 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204680:	00093783          	ld	a5,0(s2)
ffffffffc0204684:	cbe9                	beqz	a5,ffffffffc0204756 <proc_init+0x28a>
ffffffffc0204686:	43dc                	lw	a5,4(a5)
ffffffffc0204688:	e7f9                	bnez	a5,ffffffffc0204756 <proc_init+0x28a>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020468a:	601c                	ld	a5,0(s0)
ffffffffc020468c:	c7cd                	beqz	a5,ffffffffc0204736 <proc_init+0x26a>
ffffffffc020468e:	43d8                	lw	a4,4(a5)
ffffffffc0204690:	4785                	li	a5,1
ffffffffc0204692:	0af71263          	bne	a4,a5,ffffffffc0204736 <proc_init+0x26a>
}
ffffffffc0204696:	70e2                	ld	ra,56(sp)
ffffffffc0204698:	7442                	ld	s0,48(sp)
ffffffffc020469a:	74a2                	ld	s1,40(sp)
ffffffffc020469c:	7902                	ld	s2,32(sp)
ffffffffc020469e:	69e2                	ld	s3,24(sp)
ffffffffc02046a0:	6a42                	ld	s4,16(sp)
ffffffffc02046a2:	6aa2                	ld	s5,8(sp)
ffffffffc02046a4:	6121                	addi	sp,sp,64
ffffffffc02046a6:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02046a8:	73d8                	ld	a4,160(a5)
ffffffffc02046aa:	f0071be3          	bnez	a4,ffffffffc02045c0 <proc_init+0xf4>
ffffffffc02046ae:	f00a19e3          	bnez	s4,ffffffffc02045c0 <proc_init+0xf4>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02046b2:	6398                	ld	a4,0(a5)
ffffffffc02046b4:	f13716e3          	bne	a4,s3,ffffffffc02045c0 <proc_init+0xf4>
ffffffffc02046b8:	4798                	lw	a4,8(a5)
ffffffffc02046ba:	f00713e3          	bnez	a4,ffffffffc02045c0 <proc_init+0xf4>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02046be:	6b98                	ld	a4,16(a5)
ffffffffc02046c0:	f00710e3          	bnez	a4,ffffffffc02045c0 <proc_init+0xf4>
ffffffffc02046c4:	4f98                	lw	a4,24(a5)
ffffffffc02046c6:	2701                	sext.w	a4,a4
ffffffffc02046c8:	ee071ce3          	bnez	a4,ffffffffc02045c0 <proc_init+0xf4>
ffffffffc02046cc:	7398                	ld	a4,32(a5)
ffffffffc02046ce:	ee0719e3          	bnez	a4,ffffffffc02045c0 <proc_init+0xf4>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02046d2:	7798                	ld	a4,40(a5)
ffffffffc02046d4:	ee0716e3          	bnez	a4,ffffffffc02045c0 <proc_init+0xf4>
ffffffffc02046d8:	0b07a703          	lw	a4,176(a5)
ffffffffc02046dc:	8d59                	or	a0,a0,a4
ffffffffc02046de:	0005071b          	sext.w	a4,a0
ffffffffc02046e2:	ec071fe3          	bnez	a4,ffffffffc02045c0 <proc_init+0xf4>
        cprintf("alloc_proc() correct!\n");
ffffffffc02046e6:	00002517          	auipc	a0,0x2
ffffffffc02046ea:	38250513          	addi	a0,a0,898 # ffffffffc0206a68 <default_pmm_manager+0x668>
ffffffffc02046ee:	9dffb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    idleproc->pid = 0;//idleproc是第0个内核线程
ffffffffc02046f2:	00093783          	ld	a5,0(s2)
ffffffffc02046f6:	b5e9                	j	ffffffffc02045c0 <proc_init+0xf4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02046f8:	f2878793          	addi	a5,a5,-216
ffffffffc02046fc:	bfb1                	j	ffffffffc0204658 <proc_init+0x18c>
        panic("cannot alloc idleproc.\n");
ffffffffc02046fe:	00002617          	auipc	a2,0x2
ffffffffc0204702:	41260613          	addi	a2,a2,1042 # ffffffffc0206b10 <default_pmm_manager+0x710>
ffffffffc0204706:	17d00593          	li	a1,381
ffffffffc020470a:	00002517          	auipc	a0,0x2
ffffffffc020470e:	34650513          	addi	a0,a0,838 # ffffffffc0206a50 <default_pmm_manager+0x650>
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204712:	00011797          	auipc	a5,0x11
ffffffffc0204716:	e807bf23          	sd	zero,-354(a5) # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
ffffffffc020471a:	aaffb0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("create init_main failed.\n");
ffffffffc020471e:	00002617          	auipc	a2,0x2
ffffffffc0204722:	37a60613          	addi	a2,a2,890 # ffffffffc0206a98 <default_pmm_manager+0x698>
ffffffffc0204726:	19d00593          	li	a1,413
ffffffffc020472a:	00002517          	auipc	a0,0x2
ffffffffc020472e:	32650513          	addi	a0,a0,806 # ffffffffc0206a50 <default_pmm_manager+0x650>
ffffffffc0204732:	a97fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204736:	00002697          	auipc	a3,0x2
ffffffffc020473a:	3b268693          	addi	a3,a3,946 # ffffffffc0206ae8 <default_pmm_manager+0x6e8>
ffffffffc020473e:	00001617          	auipc	a2,0x1
ffffffffc0204742:	f6a60613          	addi	a2,a2,-150 # ffffffffc02056a8 <commands+0x728>
ffffffffc0204746:	1a400593          	li	a1,420
ffffffffc020474a:	00002517          	auipc	a0,0x2
ffffffffc020474e:	30650513          	addi	a0,a0,774 # ffffffffc0206a50 <default_pmm_manager+0x650>
ffffffffc0204752:	a77fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204756:	00002697          	auipc	a3,0x2
ffffffffc020475a:	36a68693          	addi	a3,a3,874 # ffffffffc0206ac0 <default_pmm_manager+0x6c0>
ffffffffc020475e:	00001617          	auipc	a2,0x1
ffffffffc0204762:	f4a60613          	addi	a2,a2,-182 # ffffffffc02056a8 <commands+0x728>
ffffffffc0204766:	1a300593          	li	a1,419
ffffffffc020476a:	00002517          	auipc	a0,0x2
ffffffffc020476e:	2e650513          	addi	a0,a0,742 # ffffffffc0206a50 <default_pmm_manager+0x650>
ffffffffc0204772:	a57fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204776 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204776:	1141                	addi	sp,sp,-16
ffffffffc0204778:	e022                	sd	s0,0(sp)
ffffffffc020477a:	e406                	sd	ra,8(sp)
ffffffffc020477c:	00011417          	auipc	s0,0x11
ffffffffc0204780:	e2c40413          	addi	s0,s0,-468 # ffffffffc02155a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204784:	6018                	ld	a4,0(s0)
ffffffffc0204786:	4f1c                	lw	a5,24(a4)
ffffffffc0204788:	2781                	sext.w	a5,a5
ffffffffc020478a:	dff5                	beqz	a5,ffffffffc0204786 <cpu_idle+0x10>
            schedule();
ffffffffc020478c:	006000ef          	jal	ra,ffffffffc0204792 <schedule>
ffffffffc0204790:	bfd5                	j	ffffffffc0204784 <cpu_idle+0xe>

ffffffffc0204792 <schedule>:
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
ffffffffc0204792:	1141                	addi	sp,sp,-16
ffffffffc0204794:	e406                	sd	ra,8(sp)
ffffffffc0204796:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204798:	100027f3          	csrr	a5,sstatus
ffffffffc020479c:	8b89                	andi	a5,a5,2
ffffffffc020479e:	4401                	li	s0,0
ffffffffc02047a0:	efbd                	bnez	a5,ffffffffc020481e <schedule+0x8c>
    bool intr_flag;//中断标志变量
    list_entry_t *le, *last;//工作指针：当前节点、下一节点
    struct proc_struct *next = NULL;//找到的要切换的进程
    local_intr_save(intr_flag);//中断禁止
    {
        current->need_resched = 0;
ffffffffc02047a2:	00011897          	auipc	a7,0x11
ffffffffc02047a6:	e068b883          	ld	a7,-506(a7) # ffffffffc02155a8 <current>
ffffffffc02047aa:	0008ac23          	sw	zero,24(a7)
        //检查是否是idle，如果是idle就从头开始找，否则从现在开始找
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02047ae:	00011517          	auipc	a0,0x11
ffffffffc02047b2:	e0253503          	ld	a0,-510(a0) # ffffffffc02155b0 <idleproc>
ffffffffc02047b6:	04a88e63          	beq	a7,a0,ffffffffc0204812 <schedule+0x80>
ffffffffc02047ba:	0c888693          	addi	a3,a7,200
ffffffffc02047be:	00011617          	auipc	a2,0x11
ffffffffc02047c2:	d6260613          	addi	a2,a2,-670 # ffffffffc0215520 <proc_list>
        le = last;
ffffffffc02047c6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;//找到的要切换的进程
ffffffffc02047c8:	4581                	li	a1,0
        do {//遍历proc_list，直到找到可以调度的进程
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047ca:	4809                	li	a6,2
ffffffffc02047cc:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02047ce:	00c78863          	beq	a5,a2,ffffffffc02047de <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047d2:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02047d6:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047da:	03070163          	beq	a4,a6,ffffffffc02047fc <schedule+0x6a>
                    break;//找到一个可以调度的进程，结束循环
                }
            }
        } while (le != last);
ffffffffc02047de:	fef697e3          	bne	a3,a5,ffffffffc02047cc <schedule+0x3a>

        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02047e2:	ed89                	bnez	a1,ffffffffc02047fc <schedule+0x6a>
            next = idleproc;//未找到可以调度的进程，回到idle
        }

        next->runs ++;//该进程运行次数加一
ffffffffc02047e4:	451c                	lw	a5,8(a0)
ffffffffc02047e6:	2785                	addiw	a5,a5,1
ffffffffc02047e8:	c51c                	sw	a5,8(a0)

        if (next != current) {
ffffffffc02047ea:	00a88463          	beq	a7,a0,ffffffffc02047f2 <schedule+0x60>
            proc_run(next);//调用proc_run函数运行新进程
ffffffffc02047ee:	c47ff0ef          	jal	ra,ffffffffc0204434 <proc_run>
    if (flag) {
ffffffffc02047f2:	e819                	bnez	s0,ffffffffc0204808 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);//中断允许
}
ffffffffc02047f4:	60a2                	ld	ra,8(sp)
ffffffffc02047f6:	6402                	ld	s0,0(sp)
ffffffffc02047f8:	0141                	addi	sp,sp,16
ffffffffc02047fa:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02047fc:	4198                	lw	a4,0(a1)
ffffffffc02047fe:	4789                	li	a5,2
ffffffffc0204800:	fef712e3          	bne	a4,a5,ffffffffc02047e4 <schedule+0x52>
ffffffffc0204804:	852e                	mv	a0,a1
ffffffffc0204806:	bff9                	j	ffffffffc02047e4 <schedule+0x52>
}
ffffffffc0204808:	6402                	ld	s0,0(sp)
ffffffffc020480a:	60a2                	ld	ra,8(sp)
ffffffffc020480c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020480e:	db1fb06f          	j	ffffffffc02005be <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204812:	00011617          	auipc	a2,0x11
ffffffffc0204816:	d0e60613          	addi	a2,a2,-754 # ffffffffc0215520 <proc_list>
ffffffffc020481a:	86b2                	mv	a3,a2
ffffffffc020481c:	b76d                	j	ffffffffc02047c6 <schedule+0x34>
        intr_disable();
ffffffffc020481e:	da7fb0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc0204822:	4405                	li	s0,1
ffffffffc0204824:	bfbd                	j	ffffffffc02047a2 <schedule+0x10>

ffffffffc0204826 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204826:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020482a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020482c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020482e:	cb81                	beqz	a5,ffffffffc020483e <strlen+0x18>
        cnt ++;
ffffffffc0204830:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204832:	00a707b3          	add	a5,a4,a0
ffffffffc0204836:	0007c783          	lbu	a5,0(a5)
ffffffffc020483a:	fbfd                	bnez	a5,ffffffffc0204830 <strlen+0xa>
ffffffffc020483c:	8082                	ret
    }
    return cnt;
}
ffffffffc020483e:	8082                	ret

ffffffffc0204840 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204840:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204842:	e589                	bnez	a1,ffffffffc020484c <strnlen+0xc>
ffffffffc0204844:	a811                	j	ffffffffc0204858 <strnlen+0x18>
        cnt ++;
ffffffffc0204846:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204848:	00f58863          	beq	a1,a5,ffffffffc0204858 <strnlen+0x18>
ffffffffc020484c:	00f50733          	add	a4,a0,a5
ffffffffc0204850:	00074703          	lbu	a4,0(a4)
ffffffffc0204854:	fb6d                	bnez	a4,ffffffffc0204846 <strnlen+0x6>
ffffffffc0204856:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204858:	852e                	mv	a0,a1
ffffffffc020485a:	8082                	ret

ffffffffc020485c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020485c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020485e:	0005c703          	lbu	a4,0(a1)
ffffffffc0204862:	0785                	addi	a5,a5,1
ffffffffc0204864:	0585                	addi	a1,a1,1
ffffffffc0204866:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020486a:	fb75                	bnez	a4,ffffffffc020485e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020486c:	8082                	ret

ffffffffc020486e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020486e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204872:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204876:	cb89                	beqz	a5,ffffffffc0204888 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204878:	0505                	addi	a0,a0,1
ffffffffc020487a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020487c:	fee789e3          	beq	a5,a4,ffffffffc020486e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204880:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204884:	9d19                	subw	a0,a0,a4
ffffffffc0204886:	8082                	ret
ffffffffc0204888:	4501                	li	a0,0
ffffffffc020488a:	bfed                	j	ffffffffc0204884 <strcmp+0x16>

ffffffffc020488c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020488c:	00054783          	lbu	a5,0(a0)
ffffffffc0204890:	c799                	beqz	a5,ffffffffc020489e <strchr+0x12>
        if (*s == c) {
ffffffffc0204892:	00f58763          	beq	a1,a5,ffffffffc02048a0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204896:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020489a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020489c:	fbfd                	bnez	a5,ffffffffc0204892 <strchr+0x6>
    }
    return NULL;
ffffffffc020489e:	4501                	li	a0,0
}
ffffffffc02048a0:	8082                	ret

ffffffffc02048a2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02048a2:	ca01                	beqz	a2,ffffffffc02048b2 <memset+0x10>
ffffffffc02048a4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02048a6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02048a8:	0785                	addi	a5,a5,1
ffffffffc02048aa:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02048ae:	fec79de3          	bne	a5,a2,ffffffffc02048a8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02048b2:	8082                	ret

ffffffffc02048b4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02048b4:	ca19                	beqz	a2,ffffffffc02048ca <memcpy+0x16>
ffffffffc02048b6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02048b8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02048ba:	0005c703          	lbu	a4,0(a1)
ffffffffc02048be:	0585                	addi	a1,a1,1
ffffffffc02048c0:	0785                	addi	a5,a5,1
ffffffffc02048c2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02048c6:	fec59ae3          	bne	a1,a2,ffffffffc02048ba <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02048ca:	8082                	ret

ffffffffc02048cc <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc02048cc:	c205                	beqz	a2,ffffffffc02048ec <memcmp+0x20>
ffffffffc02048ce:	962e                	add	a2,a2,a1
ffffffffc02048d0:	a019                	j	ffffffffc02048d6 <memcmp+0xa>
ffffffffc02048d2:	00c58d63          	beq	a1,a2,ffffffffc02048ec <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc02048d6:	00054783          	lbu	a5,0(a0)
ffffffffc02048da:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc02048de:	0505                	addi	a0,a0,1
ffffffffc02048e0:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc02048e2:	fee788e3          	beq	a5,a4,ffffffffc02048d2 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02048e6:	40e7853b          	subw	a0,a5,a4
ffffffffc02048ea:	8082                	ret
    }
    return 0;
ffffffffc02048ec:	4501                	li	a0,0
}
ffffffffc02048ee:	8082                	ret

ffffffffc02048f0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02048f0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02048f4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02048f6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02048fa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02048fc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204900:	f022                	sd	s0,32(sp)
ffffffffc0204902:	ec26                	sd	s1,24(sp)
ffffffffc0204904:	e84a                	sd	s2,16(sp)
ffffffffc0204906:	f406                	sd	ra,40(sp)
ffffffffc0204908:	e44e                	sd	s3,8(sp)
ffffffffc020490a:	84aa                	mv	s1,a0
ffffffffc020490c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020490e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204912:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204914:	03067e63          	bgeu	a2,a6,ffffffffc0204950 <printnum+0x60>
ffffffffc0204918:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020491a:	00805763          	blez	s0,ffffffffc0204928 <printnum+0x38>
ffffffffc020491e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204920:	85ca                	mv	a1,s2
ffffffffc0204922:	854e                	mv	a0,s3
ffffffffc0204924:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204926:	fc65                	bnez	s0,ffffffffc020491e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204928:	1a02                	slli	s4,s4,0x20
ffffffffc020492a:	00002797          	auipc	a5,0x2
ffffffffc020492e:	1fe78793          	addi	a5,a5,510 # ffffffffc0206b28 <default_pmm_manager+0x728>
ffffffffc0204932:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204936:	9a3e                	add	s4,s4,a5
}
ffffffffc0204938:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020493a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020493e:	70a2                	ld	ra,40(sp)
ffffffffc0204940:	69a2                	ld	s3,8(sp)
ffffffffc0204942:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204944:	85ca                	mv	a1,s2
ffffffffc0204946:	87a6                	mv	a5,s1
}
ffffffffc0204948:	6942                	ld	s2,16(sp)
ffffffffc020494a:	64e2                	ld	s1,24(sp)
ffffffffc020494c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020494e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204950:	03065633          	divu	a2,a2,a6
ffffffffc0204954:	8722                	mv	a4,s0
ffffffffc0204956:	f9bff0ef          	jal	ra,ffffffffc02048f0 <printnum>
ffffffffc020495a:	b7f9                	j	ffffffffc0204928 <printnum+0x38>

ffffffffc020495c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020495c:	7119                	addi	sp,sp,-128
ffffffffc020495e:	f4a6                	sd	s1,104(sp)
ffffffffc0204960:	f0ca                	sd	s2,96(sp)
ffffffffc0204962:	ecce                	sd	s3,88(sp)
ffffffffc0204964:	e8d2                	sd	s4,80(sp)
ffffffffc0204966:	e4d6                	sd	s5,72(sp)
ffffffffc0204968:	e0da                	sd	s6,64(sp)
ffffffffc020496a:	fc5e                	sd	s7,56(sp)
ffffffffc020496c:	f06a                	sd	s10,32(sp)
ffffffffc020496e:	fc86                	sd	ra,120(sp)
ffffffffc0204970:	f8a2                	sd	s0,112(sp)
ffffffffc0204972:	f862                	sd	s8,48(sp)
ffffffffc0204974:	f466                	sd	s9,40(sp)
ffffffffc0204976:	ec6e                	sd	s11,24(sp)
ffffffffc0204978:	892a                	mv	s2,a0
ffffffffc020497a:	84ae                	mv	s1,a1
ffffffffc020497c:	8d32                	mv	s10,a2
ffffffffc020497e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204980:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204984:	5b7d                	li	s6,-1
ffffffffc0204986:	00002a97          	auipc	s5,0x2
ffffffffc020498a:	1cea8a93          	addi	s5,s5,462 # ffffffffc0206b54 <default_pmm_manager+0x754>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020498e:	00002b97          	auipc	s7,0x2
ffffffffc0204992:	3a2b8b93          	addi	s7,s7,930 # ffffffffc0206d30 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204996:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc020499a:	001d0413          	addi	s0,s10,1
ffffffffc020499e:	01350a63          	beq	a0,s3,ffffffffc02049b2 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02049a2:	c121                	beqz	a0,ffffffffc02049e2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02049a4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02049a6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02049a8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02049aa:	fff44503          	lbu	a0,-1(s0)
ffffffffc02049ae:	ff351ae3          	bne	a0,s3,ffffffffc02049a2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049b2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02049b6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02049ba:	4c81                	li	s9,0
ffffffffc02049bc:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02049be:	5c7d                	li	s8,-1
ffffffffc02049c0:	5dfd                	li	s11,-1
ffffffffc02049c2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02049c6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049c8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02049cc:	0ff5f593          	zext.b	a1,a1
ffffffffc02049d0:	00140d13          	addi	s10,s0,1
ffffffffc02049d4:	04b56263          	bltu	a0,a1,ffffffffc0204a18 <vprintfmt+0xbc>
ffffffffc02049d8:	058a                	slli	a1,a1,0x2
ffffffffc02049da:	95d6                	add	a1,a1,s5
ffffffffc02049dc:	4194                	lw	a3,0(a1)
ffffffffc02049de:	96d6                	add	a3,a3,s5
ffffffffc02049e0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02049e2:	70e6                	ld	ra,120(sp)
ffffffffc02049e4:	7446                	ld	s0,112(sp)
ffffffffc02049e6:	74a6                	ld	s1,104(sp)
ffffffffc02049e8:	7906                	ld	s2,96(sp)
ffffffffc02049ea:	69e6                	ld	s3,88(sp)
ffffffffc02049ec:	6a46                	ld	s4,80(sp)
ffffffffc02049ee:	6aa6                	ld	s5,72(sp)
ffffffffc02049f0:	6b06                	ld	s6,64(sp)
ffffffffc02049f2:	7be2                	ld	s7,56(sp)
ffffffffc02049f4:	7c42                	ld	s8,48(sp)
ffffffffc02049f6:	7ca2                	ld	s9,40(sp)
ffffffffc02049f8:	7d02                	ld	s10,32(sp)
ffffffffc02049fa:	6de2                	ld	s11,24(sp)
ffffffffc02049fc:	6109                	addi	sp,sp,128
ffffffffc02049fe:	8082                	ret
            padc = '0';
ffffffffc0204a00:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204a02:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a06:	846a                	mv	s0,s10
ffffffffc0204a08:	00140d13          	addi	s10,s0,1
ffffffffc0204a0c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204a10:	0ff5f593          	zext.b	a1,a1
ffffffffc0204a14:	fcb572e3          	bgeu	a0,a1,ffffffffc02049d8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204a18:	85a6                	mv	a1,s1
ffffffffc0204a1a:	02500513          	li	a0,37
ffffffffc0204a1e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204a20:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204a24:	8d22                	mv	s10,s0
ffffffffc0204a26:	f73788e3          	beq	a5,s3,ffffffffc0204996 <vprintfmt+0x3a>
ffffffffc0204a2a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204a2e:	1d7d                	addi	s10,s10,-1
ffffffffc0204a30:	ff379de3          	bne	a5,s3,ffffffffc0204a2a <vprintfmt+0xce>
ffffffffc0204a34:	b78d                	j	ffffffffc0204996 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204a36:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204a3a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a3e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204a40:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204a44:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204a48:	02d86463          	bltu	a6,a3,ffffffffc0204a70 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204a4c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204a50:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204a54:	0186873b          	addw	a4,a3,s8
ffffffffc0204a58:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204a5c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204a5e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204a62:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204a64:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204a68:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204a6c:	fed870e3          	bgeu	a6,a3,ffffffffc0204a4c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204a70:	f40ddce3          	bgez	s11,ffffffffc02049c8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204a74:	8de2                	mv	s11,s8
ffffffffc0204a76:	5c7d                	li	s8,-1
ffffffffc0204a78:	bf81                	j	ffffffffc02049c8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204a7a:	fffdc693          	not	a3,s11
ffffffffc0204a7e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204a80:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a84:	00144603          	lbu	a2,1(s0)
ffffffffc0204a88:	2d81                	sext.w	s11,s11
ffffffffc0204a8a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204a8c:	bf35                	j	ffffffffc02049c8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204a8e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a92:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204a96:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a98:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204a9a:	bfd9                	j	ffffffffc0204a70 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204a9c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204a9e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204aa2:	01174463          	blt	a4,a7,ffffffffc0204aaa <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204aa6:	1a088e63          	beqz	a7,ffffffffc0204c62 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204aaa:	000a3603          	ld	a2,0(s4)
ffffffffc0204aae:	46c1                	li	a3,16
ffffffffc0204ab0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204ab2:	2781                	sext.w	a5,a5
ffffffffc0204ab4:	876e                	mv	a4,s11
ffffffffc0204ab6:	85a6                	mv	a1,s1
ffffffffc0204ab8:	854a                	mv	a0,s2
ffffffffc0204aba:	e37ff0ef          	jal	ra,ffffffffc02048f0 <printnum>
            break;
ffffffffc0204abe:	bde1                	j	ffffffffc0204996 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204ac0:	000a2503          	lw	a0,0(s4)
ffffffffc0204ac4:	85a6                	mv	a1,s1
ffffffffc0204ac6:	0a21                	addi	s4,s4,8
ffffffffc0204ac8:	9902                	jalr	s2
            break;
ffffffffc0204aca:	b5f1                	j	ffffffffc0204996 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204acc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204ace:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204ad2:	01174463          	blt	a4,a7,ffffffffc0204ada <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204ad6:	18088163          	beqz	a7,ffffffffc0204c58 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204ada:	000a3603          	ld	a2,0(s4)
ffffffffc0204ade:	46a9                	li	a3,10
ffffffffc0204ae0:	8a2e                	mv	s4,a1
ffffffffc0204ae2:	bfc1                	j	ffffffffc0204ab2 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ae4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204ae8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204aea:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204aec:	bdf1                	j	ffffffffc02049c8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204aee:	85a6                	mv	a1,s1
ffffffffc0204af0:	02500513          	li	a0,37
ffffffffc0204af4:	9902                	jalr	s2
            break;
ffffffffc0204af6:	b545                	j	ffffffffc0204996 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204af8:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204afc:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204afe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204b00:	b5e1                	j	ffffffffc02049c8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204b02:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204b04:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204b08:	01174463          	blt	a4,a7,ffffffffc0204b10 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204b0c:	14088163          	beqz	a7,ffffffffc0204c4e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204b10:	000a3603          	ld	a2,0(s4)
ffffffffc0204b14:	46a1                	li	a3,8
ffffffffc0204b16:	8a2e                	mv	s4,a1
ffffffffc0204b18:	bf69                	j	ffffffffc0204ab2 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204b1a:	03000513          	li	a0,48
ffffffffc0204b1e:	85a6                	mv	a1,s1
ffffffffc0204b20:	e03e                	sd	a5,0(sp)
ffffffffc0204b22:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204b24:	85a6                	mv	a1,s1
ffffffffc0204b26:	07800513          	li	a0,120
ffffffffc0204b2a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204b2c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204b2e:	6782                	ld	a5,0(sp)
ffffffffc0204b30:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204b32:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204b36:	bfb5                	j	ffffffffc0204ab2 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204b38:	000a3403          	ld	s0,0(s4)
ffffffffc0204b3c:	008a0713          	addi	a4,s4,8
ffffffffc0204b40:	e03a                	sd	a4,0(sp)
ffffffffc0204b42:	14040263          	beqz	s0,ffffffffc0204c86 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204b46:	0fb05763          	blez	s11,ffffffffc0204c34 <vprintfmt+0x2d8>
ffffffffc0204b4a:	02d00693          	li	a3,45
ffffffffc0204b4e:	0cd79163          	bne	a5,a3,ffffffffc0204c10 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b52:	00044783          	lbu	a5,0(s0)
ffffffffc0204b56:	0007851b          	sext.w	a0,a5
ffffffffc0204b5a:	cf85                	beqz	a5,ffffffffc0204b92 <vprintfmt+0x236>
ffffffffc0204b5c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b60:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b64:	000c4563          	bltz	s8,ffffffffc0204b6e <vprintfmt+0x212>
ffffffffc0204b68:	3c7d                	addiw	s8,s8,-1
ffffffffc0204b6a:	036c0263          	beq	s8,s6,ffffffffc0204b8e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204b6e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b70:	0e0c8e63          	beqz	s9,ffffffffc0204c6c <vprintfmt+0x310>
ffffffffc0204b74:	3781                	addiw	a5,a5,-32
ffffffffc0204b76:	0ef47b63          	bgeu	s0,a5,ffffffffc0204c6c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204b7a:	03f00513          	li	a0,63
ffffffffc0204b7e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b80:	000a4783          	lbu	a5,0(s4)
ffffffffc0204b84:	3dfd                	addiw	s11,s11,-1
ffffffffc0204b86:	0a05                	addi	s4,s4,1
ffffffffc0204b88:	0007851b          	sext.w	a0,a5
ffffffffc0204b8c:	ffe1                	bnez	a5,ffffffffc0204b64 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204b8e:	01b05963          	blez	s11,ffffffffc0204ba0 <vprintfmt+0x244>
ffffffffc0204b92:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204b94:	85a6                	mv	a1,s1
ffffffffc0204b96:	02000513          	li	a0,32
ffffffffc0204b9a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204b9c:	fe0d9be3          	bnez	s11,ffffffffc0204b92 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204ba0:	6a02                	ld	s4,0(sp)
ffffffffc0204ba2:	bbd5                	j	ffffffffc0204996 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204ba4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204ba6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204baa:	01174463          	blt	a4,a7,ffffffffc0204bb2 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204bae:	08088d63          	beqz	a7,ffffffffc0204c48 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204bb2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204bb6:	0a044d63          	bltz	s0,ffffffffc0204c70 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204bba:	8622                	mv	a2,s0
ffffffffc0204bbc:	8a66                	mv	s4,s9
ffffffffc0204bbe:	46a9                	li	a3,10
ffffffffc0204bc0:	bdcd                	j	ffffffffc0204ab2 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204bc2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bc6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204bc8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204bca:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204bce:	8fb5                	xor	a5,a5,a3
ffffffffc0204bd0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bd4:	02d74163          	blt	a4,a3,ffffffffc0204bf6 <vprintfmt+0x29a>
ffffffffc0204bd8:	00369793          	slli	a5,a3,0x3
ffffffffc0204bdc:	97de                	add	a5,a5,s7
ffffffffc0204bde:	639c                	ld	a5,0(a5)
ffffffffc0204be0:	cb99                	beqz	a5,ffffffffc0204bf6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204be2:	86be                	mv	a3,a5
ffffffffc0204be4:	00000617          	auipc	a2,0x0
ffffffffc0204be8:	13c60613          	addi	a2,a2,316 # ffffffffc0204d20 <etext+0x2c>
ffffffffc0204bec:	85a6                	mv	a1,s1
ffffffffc0204bee:	854a                	mv	a0,s2
ffffffffc0204bf0:	0ce000ef          	jal	ra,ffffffffc0204cbe <printfmt>
ffffffffc0204bf4:	b34d                	j	ffffffffc0204996 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204bf6:	00002617          	auipc	a2,0x2
ffffffffc0204bfa:	f5260613          	addi	a2,a2,-174 # ffffffffc0206b48 <default_pmm_manager+0x748>
ffffffffc0204bfe:	85a6                	mv	a1,s1
ffffffffc0204c00:	854a                	mv	a0,s2
ffffffffc0204c02:	0bc000ef          	jal	ra,ffffffffc0204cbe <printfmt>
ffffffffc0204c06:	bb41                	j	ffffffffc0204996 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204c08:	00002417          	auipc	s0,0x2
ffffffffc0204c0c:	f3840413          	addi	s0,s0,-200 # ffffffffc0206b40 <default_pmm_manager+0x740>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204c10:	85e2                	mv	a1,s8
ffffffffc0204c12:	8522                	mv	a0,s0
ffffffffc0204c14:	e43e                	sd	a5,8(sp)
ffffffffc0204c16:	c2bff0ef          	jal	ra,ffffffffc0204840 <strnlen>
ffffffffc0204c1a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204c1e:	01b05b63          	blez	s11,ffffffffc0204c34 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204c22:	67a2                	ld	a5,8(sp)
ffffffffc0204c24:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204c28:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204c2a:	85a6                	mv	a1,s1
ffffffffc0204c2c:	8552                	mv	a0,s4
ffffffffc0204c2e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204c30:	fe0d9ce3          	bnez	s11,ffffffffc0204c28 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c34:	00044783          	lbu	a5,0(s0)
ffffffffc0204c38:	00140a13          	addi	s4,s0,1
ffffffffc0204c3c:	0007851b          	sext.w	a0,a5
ffffffffc0204c40:	d3a5                	beqz	a5,ffffffffc0204ba0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204c42:	05e00413          	li	s0,94
ffffffffc0204c46:	bf39                	j	ffffffffc0204b64 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204c48:	000a2403          	lw	s0,0(s4)
ffffffffc0204c4c:	b7ad                	j	ffffffffc0204bb6 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204c4e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204c52:	46a1                	li	a3,8
ffffffffc0204c54:	8a2e                	mv	s4,a1
ffffffffc0204c56:	bdb1                	j	ffffffffc0204ab2 <vprintfmt+0x156>
ffffffffc0204c58:	000a6603          	lwu	a2,0(s4)
ffffffffc0204c5c:	46a9                	li	a3,10
ffffffffc0204c5e:	8a2e                	mv	s4,a1
ffffffffc0204c60:	bd89                	j	ffffffffc0204ab2 <vprintfmt+0x156>
ffffffffc0204c62:	000a6603          	lwu	a2,0(s4)
ffffffffc0204c66:	46c1                	li	a3,16
ffffffffc0204c68:	8a2e                	mv	s4,a1
ffffffffc0204c6a:	b5a1                	j	ffffffffc0204ab2 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204c6c:	9902                	jalr	s2
ffffffffc0204c6e:	bf09                	j	ffffffffc0204b80 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204c70:	85a6                	mv	a1,s1
ffffffffc0204c72:	02d00513          	li	a0,45
ffffffffc0204c76:	e03e                	sd	a5,0(sp)
ffffffffc0204c78:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204c7a:	6782                	ld	a5,0(sp)
ffffffffc0204c7c:	8a66                	mv	s4,s9
ffffffffc0204c7e:	40800633          	neg	a2,s0
ffffffffc0204c82:	46a9                	li	a3,10
ffffffffc0204c84:	b53d                	j	ffffffffc0204ab2 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204c86:	03b05163          	blez	s11,ffffffffc0204ca8 <vprintfmt+0x34c>
ffffffffc0204c8a:	02d00693          	li	a3,45
ffffffffc0204c8e:	f6d79de3          	bne	a5,a3,ffffffffc0204c08 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204c92:	00002417          	auipc	s0,0x2
ffffffffc0204c96:	eae40413          	addi	s0,s0,-338 # ffffffffc0206b40 <default_pmm_manager+0x740>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c9a:	02800793          	li	a5,40
ffffffffc0204c9e:	02800513          	li	a0,40
ffffffffc0204ca2:	00140a13          	addi	s4,s0,1
ffffffffc0204ca6:	bd6d                	j	ffffffffc0204b60 <vprintfmt+0x204>
ffffffffc0204ca8:	00002a17          	auipc	s4,0x2
ffffffffc0204cac:	e99a0a13          	addi	s4,s4,-359 # ffffffffc0206b41 <default_pmm_manager+0x741>
ffffffffc0204cb0:	02800513          	li	a0,40
ffffffffc0204cb4:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204cb8:	05e00413          	li	s0,94
ffffffffc0204cbc:	b565                	j	ffffffffc0204b64 <vprintfmt+0x208>

ffffffffc0204cbe <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204cbe:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204cc0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204cc4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204cc6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204cc8:	ec06                	sd	ra,24(sp)
ffffffffc0204cca:	f83a                	sd	a4,48(sp)
ffffffffc0204ccc:	fc3e                	sd	a5,56(sp)
ffffffffc0204cce:	e0c2                	sd	a6,64(sp)
ffffffffc0204cd0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204cd2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204cd4:	c89ff0ef          	jal	ra,ffffffffc020495c <vprintfmt>
}
ffffffffc0204cd8:	60e2                	ld	ra,24(sp)
ffffffffc0204cda:	6161                	addi	sp,sp,80
ffffffffc0204cdc:	8082                	ret

ffffffffc0204cde <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204cde:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204ce2:	2785                	addiw	a5,a5,1
ffffffffc0204ce4:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204ce8:	02000793          	li	a5,32
ffffffffc0204cec:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204cee:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204cf2:	8082                	ret
