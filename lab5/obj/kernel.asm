
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	4fe50513          	addi	a0,a0,1278 # ffffffffc02a7530 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	a5260613          	addi	a2,a2,-1454 # ffffffffc02b2a8c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	02e060ef          	jal	ra,ffffffffc0206078 <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	45658593          	addi	a1,a1,1110 # ffffffffc02064a8 <etext+0x2>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	46e50513          	addi	a0,a0,1134 # ffffffffc02064c8 <etext+0x22>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	605030ef          	jal	ra,ffffffffc0203e6e <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	168010ef          	jal	ra,ffffffffc02011de <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	3e5050ef          	jal	ra,ffffffffc0205c5e <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	7f3010ef          	jal	ra,ffffffffc0202074 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	569050ef          	jal	ra,ffffffffc0205df6 <cpu_idle>

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
ffffffffc020009a:	536000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
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
ffffffffc02000c0:	04e060ef          	jal	ra,ffffffffc020610e <vprintfmt>
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
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f6:	018060ef          	jal	ra,ffffffffc020610e <vprintfmt>
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
ffffffffc0200102:	a1f9                	j	ffffffffc02005d0 <cons_putc>

ffffffffc0200104 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	e822                	sd	s0,16(sp)
ffffffffc0200108:	ec06                	sd	ra,24(sp)
ffffffffc020010a:	e426                	sd	s1,8(sp)
ffffffffc020010c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020010e:	00054503          	lbu	a0,0(a0)
ffffffffc0200112:	c51d                	beqz	a0,ffffffffc0200140 <cputs+0x3c>
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	4485                	li	s1,1
ffffffffc0200118:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011a:	4b6000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	4a0000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	64a2                	ld	s1,8(sp)
ffffffffc020013c:	6105                	addi	sp,sp,32
ffffffffc020013e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200140:	4405                	li	s0,1
ffffffffc0200142:	b7f5                	j	ffffffffc020012e <cputs+0x2a>

ffffffffc0200144 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
ffffffffc0200146:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200148:	4bc000ef          	jal	ra,ffffffffc0200604 <cons_getc>
ffffffffc020014c:	dd75                	beqz	a0,ffffffffc0200148 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020014e:	60a2                	ld	ra,8(sp)
ffffffffc0200150:	0141                	addi	sp,sp,16
ffffffffc0200152:	8082                	ret

ffffffffc0200154 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200154:	715d                	addi	sp,sp,-80
ffffffffc0200156:	e486                	sd	ra,72(sp)
ffffffffc0200158:	e0a6                	sd	s1,64(sp)
ffffffffc020015a:	fc4a                	sd	s2,56(sp)
ffffffffc020015c:	f84e                	sd	s3,48(sp)
ffffffffc020015e:	f452                	sd	s4,40(sp)
ffffffffc0200160:	f056                	sd	s5,32(sp)
ffffffffc0200162:	ec5a                	sd	s6,24(sp)
ffffffffc0200164:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200166:	c901                	beqz	a0,ffffffffc0200176 <readline+0x22>
ffffffffc0200168:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020016a:	00006517          	auipc	a0,0x6
ffffffffc020016e:	36650513          	addi	a0,a0,870 # ffffffffc02064d0 <etext+0x2a>
ffffffffc0200172:	f5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200176:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200178:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020017c:	4aa9                	li	s5,10
ffffffffc020017e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200180:	000a7b97          	auipc	s7,0xa7
ffffffffc0200184:	3b0b8b93          	addi	s7,s7,944 # ffffffffc02a7530 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200188:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020018c:	fb9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc0200190:	00054a63          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	00a95a63          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc0200198:	029a5263          	bge	s4,s1,ffffffffc02001bc <readline+0x68>
        c = getchar();
ffffffffc020019c:	fa9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001a0:	fe055ae3          	bgez	a0,ffffffffc0200194 <readline+0x40>
            return NULL;
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	a091                	j	ffffffffc02001ea <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	03351463          	bne	a0,s3,ffffffffc02001d0 <readline+0x7c>
ffffffffc02001ac:	e8a9                	bnez	s1,ffffffffc02001fe <readline+0xaa>
        c = getchar();
ffffffffc02001ae:	f97ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001b2:	fe0549e3          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b6:	fea959e3          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc02001ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001bc:	e42a                	sd	a0,8(sp)
ffffffffc02001be:	f45ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	6522                	ld	a0,8(sp)
ffffffffc02001c4:	009b87b3          	add	a5,s7,s1
ffffffffc02001c8:	2485                	addiw	s1,s1,1
ffffffffc02001ca:	00a78023          	sb	a0,0(a5)
ffffffffc02001ce:	bf7d                	j	ffffffffc020018c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d0:	01550463          	beq	a0,s5,ffffffffc02001d8 <readline+0x84>
ffffffffc02001d4:	fb651ce3          	bne	a0,s6,ffffffffc020018c <readline+0x38>
            cputchar(c);
ffffffffc02001d8:	f2bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc02001dc:	000a7517          	auipc	a0,0xa7
ffffffffc02001e0:	35450513          	addi	a0,a0,852 # ffffffffc02a7530 <buf>
ffffffffc02001e4:	94aa                	add	s1,s1,a0
ffffffffc02001e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001ea:	60a6                	ld	ra,72(sp)
ffffffffc02001ec:	6486                	ld	s1,64(sp)
ffffffffc02001ee:	7962                	ld	s2,56(sp)
ffffffffc02001f0:	79c2                	ld	s3,48(sp)
ffffffffc02001f2:	7a22                	ld	s4,40(sp)
ffffffffc02001f4:	7a82                	ld	s5,32(sp)
ffffffffc02001f6:	6b62                	ld	s6,24(sp)
ffffffffc02001f8:	6bc2                	ld	s7,16(sp)
ffffffffc02001fa:	6161                	addi	sp,sp,80
ffffffffc02001fc:	8082                	ret
            cputchar(c);
ffffffffc02001fe:	4521                	li	a0,8
ffffffffc0200200:	f03ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc0200204:	34fd                	addiw	s1,s1,-1
ffffffffc0200206:	b759                	j	ffffffffc020018c <readline+0x38>

ffffffffc0200208 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200208:	000b2317          	auipc	t1,0xb2
ffffffffc020020c:	7f030313          	addi	t1,t1,2032 # ffffffffc02b29f8 <is_panic>
ffffffffc0200210:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200214:	715d                	addi	sp,sp,-80
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	e822                	sd	s0,16(sp)
ffffffffc020021a:	f436                	sd	a3,40(sp)
ffffffffc020021c:	f83a                	sd	a4,48(sp)
ffffffffc020021e:	fc3e                	sd	a5,56(sp)
ffffffffc0200220:	e0c2                	sd	a6,64(sp)
ffffffffc0200222:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200224:	020e1a63          	bnez	t3,ffffffffc0200258 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200228:	4785                	li	a5,1
ffffffffc020022a:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020022e:	8432                	mv	s0,a2
ffffffffc0200230:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200232:	862e                	mv	a2,a1
ffffffffc0200234:	85aa                	mv	a1,a0
ffffffffc0200236:	00006517          	auipc	a0,0x6
ffffffffc020023a:	2a250513          	addi	a0,a0,674 # ffffffffc02064d8 <etext+0x32>
    va_start(ap, fmt);
ffffffffc020023e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	e8dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200244:	65a2                	ld	a1,8(sp)
ffffffffc0200246:	8522                	mv	a0,s0
ffffffffc0200248:	e65ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020024c:	00008517          	auipc	a0,0x8
ffffffffc0200250:	ddc50513          	addi	a0,a0,-548 # ffffffffc0208028 <default_pmm_manager+0x420>
ffffffffc0200254:	e79ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	4581                	li	a1,0
ffffffffc020025c:	4601                	li	a2,0
ffffffffc020025e:	48a1                	li	a7,8
ffffffffc0200260:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200264:	3e4000ef          	jal	ra,ffffffffc0200648 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	174000ef          	jal	ra,ffffffffc02003de <kmonitor>
    while (1) {
ffffffffc020026e:	bfed                	j	ffffffffc0200268 <__panic+0x60>

ffffffffc0200270 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200270:	715d                	addi	sp,sp,-80
ffffffffc0200272:	832e                	mv	t1,a1
ffffffffc0200274:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200276:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200278:	8432                	mv	s0,a2
ffffffffc020027a:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020027c:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc020027e:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200280:	00006517          	auipc	a0,0x6
ffffffffc0200284:	27850513          	addi	a0,a0,632 # ffffffffc02064f8 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	f436                	sd	a3,40(sp)
ffffffffc020028c:	f83a                	sd	a4,48(sp)
ffffffffc020028e:	e0c2                	sd	a6,64(sp)
ffffffffc0200290:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200292:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200294:	e39ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200298:	65a2                	ld	a1,8(sp)
ffffffffc020029a:	8522                	mv	a0,s0
ffffffffc020029c:	e11ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc02002a0:	00008517          	auipc	a0,0x8
ffffffffc02002a4:	d8850513          	addi	a0,a0,-632 # ffffffffc0208028 <default_pmm_manager+0x420>
ffffffffc02002a8:	e25ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);
}
ffffffffc02002ac:	60e2                	ld	ra,24(sp)
ffffffffc02002ae:	6442                	ld	s0,16(sp)
ffffffffc02002b0:	6161                	addi	sp,sp,80
ffffffffc02002b2:	8082                	ret

ffffffffc02002b4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002b4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	26250513          	addi	a0,a0,610 # ffffffffc0206518 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	26c50513          	addi	a0,a0,620 # ffffffffc0206538 <etext+0x92>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	1ce58593          	addi	a1,a1,462 # ffffffffc02064a6 <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	27850513          	addi	a0,a0,632 # ffffffffc0206558 <etext+0xb2>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	24458593          	addi	a1,a1,580 # ffffffffc02a7530 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	28450513          	addi	a0,a0,644 # ffffffffc0206578 <etext+0xd2>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	78c58593          	addi	a1,a1,1932 # ffffffffc02b2a8c <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	29050513          	addi	a0,a0,656 # ffffffffc0206598 <etext+0xf2>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	b7758593          	addi	a1,a1,-1161 # ffffffffc02b2e8b <end+0x3ff>
ffffffffc020031c:	00000797          	auipc	a5,0x0
ffffffffc0200320:	d1678793          	addi	a5,a5,-746 # ffffffffc0200032 <kern_init>
ffffffffc0200324:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200328:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020032c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020032e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200332:	95be                	add	a1,a1,a5
ffffffffc0200334:	85a9                	srai	a1,a1,0xa
ffffffffc0200336:	00006517          	auipc	a0,0x6
ffffffffc020033a:	28250513          	addi	a0,a0,642 # ffffffffc02065b8 <etext+0x112>
}
ffffffffc020033e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200340:	b371                	j	ffffffffc02000cc <cprintf>

ffffffffc0200342 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200344:	00006617          	auipc	a2,0x6
ffffffffc0200348:	2a460613          	addi	a2,a2,676 # ffffffffc02065e8 <etext+0x142>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	2b050513          	addi	a0,a0,688 # ffffffffc0206600 <etext+0x15a>
void print_stackframe(void) {
ffffffffc0200358:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020035a:	eafff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020035e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020035e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200360:	00006617          	auipc	a2,0x6
ffffffffc0200364:	2b860613          	addi	a2,a2,696 # ffffffffc0206618 <etext+0x172>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	2d058593          	addi	a1,a1,720 # ffffffffc0206638 <etext+0x192>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	2d050513          	addi	a0,a0,720 # ffffffffc0206640 <etext+0x19a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	2d260613          	addi	a2,a2,722 # ffffffffc0206650 <etext+0x1aa>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	2f258593          	addi	a1,a1,754 # ffffffffc0206678 <etext+0x1d2>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	2b250513          	addi	a0,a0,690 # ffffffffc0206640 <etext+0x19a>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	2ee60613          	addi	a2,a2,750 # ffffffffc0206688 <etext+0x1e2>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	30658593          	addi	a1,a1,774 # ffffffffc02066a8 <etext+0x202>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	29650513          	addi	a0,a0,662 # ffffffffc0206640 <etext+0x19a>
ffffffffc02003b2:	d1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc02003b6:	60a2                	ld	ra,8(sp)
ffffffffc02003b8:	4501                	li	a0,0
ffffffffc02003ba:	0141                	addi	sp,sp,16
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003be:	1141                	addi	sp,sp,-16
ffffffffc02003c0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c2:	ef3ff0ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>
    return 0;
}
ffffffffc02003c6:	60a2                	ld	ra,8(sp)
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	0141                	addi	sp,sp,16
ffffffffc02003cc:	8082                	ret

ffffffffc02003ce <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003ce:	1141                	addi	sp,sp,-16
ffffffffc02003d0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d2:	f71ff0ef          	jal	ra,ffffffffc0200342 <print_stackframe>
    return 0;
}
ffffffffc02003d6:	60a2                	ld	ra,8(sp)
ffffffffc02003d8:	4501                	li	a0,0
ffffffffc02003da:	0141                	addi	sp,sp,16
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003de:	7115                	addi	sp,sp,-224
ffffffffc02003e0:	ed5e                	sd	s7,152(sp)
ffffffffc02003e2:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e4:	00006517          	auipc	a0,0x6
ffffffffc02003e8:	2d450513          	addi	a0,a0,724 # ffffffffc02066b8 <etext+0x212>
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	ed86                	sd	ra,216(sp)
ffffffffc02003ee:	e9a2                	sd	s0,208(sp)
ffffffffc02003f0:	e5a6                	sd	s1,200(sp)
ffffffffc02003f2:	e1ca                	sd	s2,192(sp)
ffffffffc02003f4:	fd4e                	sd	s3,184(sp)
ffffffffc02003f6:	f952                	sd	s4,176(sp)
ffffffffc02003f8:	f556                	sd	s5,168(sp)
ffffffffc02003fa:	f15a                	sd	s6,160(sp)
ffffffffc02003fc:	e962                	sd	s8,144(sp)
ffffffffc02003fe:	e566                	sd	s9,136(sp)
ffffffffc0200400:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200402:	ccbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200406:	00006517          	auipc	a0,0x6
ffffffffc020040a:	2da50513          	addi	a0,a0,730 # ffffffffc02066e0 <etext+0x23a>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	334c0c13          	addi	s8,s8,820 # ffffffffc0206750 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	2e490913          	addi	s2,s2,740 # ffffffffc0206708 <etext+0x262>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	2e448493          	addi	s1,s1,740 # ffffffffc0206710 <etext+0x26a>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	2e2b0b13          	addi	s6,s6,738 # ffffffffc0206718 <etext+0x272>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	1faa0a13          	addi	s4,s4,506 # ffffffffc0206638 <etext+0x192>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200446:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200448:	854a                	mv	a0,s2
ffffffffc020044a:	d0bff0ef          	jal	ra,ffffffffc0200154 <readline>
ffffffffc020044e:	842a                	mv	s0,a0
ffffffffc0200450:	dd65                	beqz	a0,ffffffffc0200448 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200452:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200456:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	e1bd                	bnez	a1,ffffffffc02004be <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020045a:	fe0c87e3          	beqz	s9,ffffffffc0200448 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020045e:	6582                	ld	a1,0(sp)
ffffffffc0200460:	00006d17          	auipc	s10,0x6
ffffffffc0200464:	2f0d0d13          	addi	s10,s10,752 # ffffffffc0206750 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	3d7050ef          	jal	ra,ffffffffc0206044 <strcmp>
ffffffffc0200472:	c919                	beqz	a0,ffffffffc0200488 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200474:	2405                	addiw	s0,s0,1
ffffffffc0200476:	0b540063          	beq	s0,s5,ffffffffc0200516 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047a:	000d3503          	ld	a0,0(s10)
ffffffffc020047e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200480:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	3c3050ef          	jal	ra,ffffffffc0206044 <strcmp>
ffffffffc0200486:	f57d                	bnez	a0,ffffffffc0200474 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200488:	00141793          	slli	a5,s0,0x1
ffffffffc020048c:	97a2                	add	a5,a5,s0
ffffffffc020048e:	078e                	slli	a5,a5,0x3
ffffffffc0200490:	97e2                	add	a5,a5,s8
ffffffffc0200492:	6b9c                	ld	a5,16(a5)
ffffffffc0200494:	865e                	mv	a2,s7
ffffffffc0200496:	002c                	addi	a1,sp,8
ffffffffc0200498:	fffc851b          	addiw	a0,s9,-1
ffffffffc020049c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020049e:	fa0555e3          	bgez	a0,ffffffffc0200448 <kmonitor+0x6a>
}
ffffffffc02004a2:	60ee                	ld	ra,216(sp)
ffffffffc02004a4:	644e                	ld	s0,208(sp)
ffffffffc02004a6:	64ae                	ld	s1,200(sp)
ffffffffc02004a8:	690e                	ld	s2,192(sp)
ffffffffc02004aa:	79ea                	ld	s3,184(sp)
ffffffffc02004ac:	7a4a                	ld	s4,176(sp)
ffffffffc02004ae:	7aaa                	ld	s5,168(sp)
ffffffffc02004b0:	7b0a                	ld	s6,160(sp)
ffffffffc02004b2:	6bea                	ld	s7,152(sp)
ffffffffc02004b4:	6c4a                	ld	s8,144(sp)
ffffffffc02004b6:	6caa                	ld	s9,136(sp)
ffffffffc02004b8:	6d0a                	ld	s10,128(sp)
ffffffffc02004ba:	612d                	addi	sp,sp,224
ffffffffc02004bc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004be:	8526                	mv	a0,s1
ffffffffc02004c0:	3a3050ef          	jal	ra,ffffffffc0206062 <strchr>
ffffffffc02004c4:	c901                	beqz	a0,ffffffffc02004d4 <kmonitor+0xf6>
ffffffffc02004c6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004ca:	00040023          	sb	zero,0(s0)
ffffffffc02004ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d0:	d5c9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004d2:	b7f5                	j	ffffffffc02004be <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004d4:	00044783          	lbu	a5,0(s0)
ffffffffc02004d8:	d3c9                	beqz	a5,ffffffffc020045a <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004da:	033c8963          	beq	s9,s3,ffffffffc020050c <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004de:	003c9793          	slli	a5,s9,0x3
ffffffffc02004e2:	0118                	addi	a4,sp,128
ffffffffc02004e4:	97ba                	add	a5,a5,a4
ffffffffc02004e6:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004ea:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004ee:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f0:	e591                	bnez	a1,ffffffffc02004fc <kmonitor+0x11e>
ffffffffc02004f2:	b7b5                	j	ffffffffc020045e <kmonitor+0x80>
ffffffffc02004f4:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004f8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	d1a5                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004fc:	8526                	mv	a0,s1
ffffffffc02004fe:	365050ef          	jal	ra,ffffffffc0206062 <strchr>
ffffffffc0200502:	d96d                	beqz	a0,ffffffffc02004f4 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	d9a9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc020050a:	bf55                	j	ffffffffc02004be <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020050c:	45c1                	li	a1,16
ffffffffc020050e:	855a                	mv	a0,s6
ffffffffc0200510:	bbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200514:	b7e9                	j	ffffffffc02004de <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200516:	6582                	ld	a1,0(sp)
ffffffffc0200518:	00006517          	auipc	a0,0x6
ffffffffc020051c:	22050513          	addi	a0,a0,544 # ffffffffc0206738 <etext+0x292>
ffffffffc0200520:	badff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc0200524:	b715                	j	ffffffffc0200448 <kmonitor+0x6a>

ffffffffc0200526 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200528:	00253513          	sltiu	a0,a0,2
ffffffffc020052c:	8082                	ret

ffffffffc020052e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020052e:	03800513          	li	a0,56
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200534:	000a7797          	auipc	a5,0xa7
ffffffffc0200538:	3fc78793          	addi	a5,a5,1020 # ffffffffc02a7930 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020053c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200544:	95be                	add	a1,a1,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	33f050ef          	jal	ra,ffffffffc020608a <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200558:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020055c:	000a7517          	auipc	a0,0xa7
ffffffffc0200560:	3d450513          	addi	a0,a0,980 # ffffffffc02a7930 <ide>
                   size_t nsecs) {
ffffffffc0200564:	1141                	addi	sp,sp,-16
ffffffffc0200566:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	31b050ef          	jal	ra,ffffffffc020608a <memcpy>
    return 0;
}
ffffffffc0200574:	60a2                	ld	ra,8(sp)
ffffffffc0200576:	4501                	li	a0,0
ffffffffc0200578:	0141                	addi	sp,sp,16
ffffffffc020057a:	8082                	ret

ffffffffc020057c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020057c:	67e1                	lui	a5,0x18
ffffffffc020057e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd558>
ffffffffc0200582:	000b2717          	auipc	a4,0xb2
ffffffffc0200586:	48f73323          	sd	a5,1158(a4) # ffffffffc02b2a08 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020058a:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020058e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200590:	953e                	add	a0,a0,a5
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4881                	li	a7,0
ffffffffc0200596:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020059a:	02000793          	li	a5,32
ffffffffc020059e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005a2:	00006517          	auipc	a0,0x6
ffffffffc02005a6:	1f650513          	addi	a0,a0,502 # ffffffffc0206798 <commands+0x48>
    ticks = 0;
ffffffffc02005aa:	000b2797          	auipc	a5,0xb2
ffffffffc02005ae:	4407bb23          	sd	zero,1110(a5) # ffffffffc02b2a00 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b2:	be29                	j	ffffffffc02000cc <cprintf>

ffffffffc02005b4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005b4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005b8:	000b2797          	auipc	a5,0xb2
ffffffffc02005bc:	4507b783          	ld	a5,1104(a5) # ffffffffc02b2a08 <timebase>
ffffffffc02005c0:	953e                	add	a0,a0,a5
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4881                	li	a7,0
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	8082                	ret

ffffffffc02005ce <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005d0:	100027f3          	csrr	a5,sstatus
ffffffffc02005d4:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005d6:	0ff57513          	zext.b	a0,a0
ffffffffc02005da:	e799                	bnez	a5,ffffffffc02005e8 <cons_putc+0x18>
ffffffffc02005dc:	4581                	li	a1,0
ffffffffc02005de:	4601                	li	a2,0
ffffffffc02005e0:	4885                	li	a7,1
ffffffffc02005e2:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005e6:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005e8:	1101                	addi	sp,sp,-32
ffffffffc02005ea:	ec06                	sd	ra,24(sp)
ffffffffc02005ec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ee:	05a000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02005f2:	6522                	ld	a0,8(sp)
ffffffffc02005f4:	4581                	li	a1,0
ffffffffc02005f6:	4601                	li	a2,0
ffffffffc02005f8:	4885                	li	a7,1
ffffffffc02005fa:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005fe:	60e2                	ld	ra,24(sp)
ffffffffc0200600:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200602:	a081                	j	ffffffffc0200642 <intr_enable>

ffffffffc0200604 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200604:	100027f3          	csrr	a5,sstatus
ffffffffc0200608:	8b89                	andi	a5,a5,2
ffffffffc020060a:	eb89                	bnez	a5,ffffffffc020061c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020060c:	4501                	li	a0,0
ffffffffc020060e:	4581                	li	a1,0
ffffffffc0200610:	4601                	li	a2,0
ffffffffc0200612:	4889                	li	a7,2
ffffffffc0200614:	00000073          	ecall
ffffffffc0200618:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020061a:	8082                	ret
int cons_getc(void) {
ffffffffc020061c:	1101                	addi	sp,sp,-32
ffffffffc020061e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200620:	028000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200624:	4501                	li	a0,0
ffffffffc0200626:	4581                	li	a1,0
ffffffffc0200628:	4601                	li	a2,0
ffffffffc020062a:	4889                	li	a7,2
ffffffffc020062c:	00000073          	ecall
ffffffffc0200630:	2501                	sext.w	a0,a0
ffffffffc0200632:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200634:	00e000ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0200638:	60e2                	ld	ra,24(sp)
ffffffffc020063a:	6522                	ld	a0,8(sp)
ffffffffc020063c:	6105                	addi	sp,sp,32
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200640:	8082                	ret

ffffffffc0200642 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200642:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200648:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	14850513          	addi	a0,a0,328 # ffffffffc02067b8 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	15050513          	addi	a0,a0,336 # ffffffffc02067d0 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	15a50513          	addi	a0,a0,346 # ffffffffc02067e8 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	16450513          	addi	a0,a0,356 # ffffffffc0206800 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	16e50513          	addi	a0,a0,366 # ffffffffc0206818 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	17850513          	addi	a0,a0,376 # ffffffffc0206830 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	18250513          	addi	a0,a0,386 # ffffffffc0206848 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	18c50513          	addi	a0,a0,396 # ffffffffc0206860 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	19650513          	addi	a0,a0,406 # ffffffffc0206878 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	1a050513          	addi	a0,a0,416 # ffffffffc0206890 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	1aa50513          	addi	a0,a0,426 # ffffffffc02068a8 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	1b450513          	addi	a0,a0,436 # ffffffffc02068c0 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	1be50513          	addi	a0,a0,446 # ffffffffc02068d8 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	1c850513          	addi	a0,a0,456 # ffffffffc02068f0 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	1d250513          	addi	a0,a0,466 # ffffffffc0206908 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	1dc50513          	addi	a0,a0,476 # ffffffffc0206920 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	1e650513          	addi	a0,a0,486 # ffffffffc0206938 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	1f050513          	addi	a0,a0,496 # ffffffffc0206950 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	1fa50513          	addi	a0,a0,506 # ffffffffc0206968 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	20450513          	addi	a0,a0,516 # ffffffffc0206980 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	20e50513          	addi	a0,a0,526 # ffffffffc0206998 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	21850513          	addi	a0,a0,536 # ffffffffc02069b0 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	22250513          	addi	a0,a0,546 # ffffffffc02069c8 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	22c50513          	addi	a0,a0,556 # ffffffffc02069e0 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	23650513          	addi	a0,a0,566 # ffffffffc02069f8 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	24050513          	addi	a0,a0,576 # ffffffffc0206a10 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	24a50513          	addi	a0,a0,586 # ffffffffc0206a28 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	25450513          	addi	a0,a0,596 # ffffffffc0206a40 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	25e50513          	addi	a0,a0,606 # ffffffffc0206a58 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	26850513          	addi	a0,a0,616 # ffffffffc0206a70 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	27250513          	addi	a0,a0,626 # ffffffffc0206a88 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	27850513          	addi	a0,a0,632 # ffffffffc0206aa0 <commands+0x350>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	89bff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200836 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	1141                	addi	sp,sp,-16
ffffffffc0200838:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	00006517          	auipc	a0,0x6
ffffffffc0200842:	27a50513          	addi	a0,a0,634 # ffffffffc0206ab8 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	885ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084c:	8522                	mv	a0,s0
ffffffffc020084e:	e1bff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200852:	10043583          	ld	a1,256(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	27a50513          	addi	a0,a0,634 # ffffffffc0206ad0 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	28250513          	addi	a0,a0,642 # ffffffffc0206ae8 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	28a50513          	addi	a0,a0,650 # ffffffffc0206b00 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	28650513          	addi	a0,a0,646 # ffffffffc0206b10 <commands+0x3c0>
}
ffffffffc0200892:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	839ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200898 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200898:	1101                	addi	sp,sp,-32
ffffffffc020089a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	000b2497          	auipc	s1,0xb2
ffffffffc02008a0:	17448493          	addi	s1,s1,372 # ffffffffc02b2a10 <check_mm_struct>
ffffffffc02008a4:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a6:	e822                	sd	s0,16(sp)
ffffffffc02008a8:	ec06                	sd	ra,24(sp)
ffffffffc02008aa:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008ac:	cbad                	beqz	a5,ffffffffc020091e <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ae:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b2:	11053583          	ld	a1,272(a0)
ffffffffc02008b6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	c7b1                	beqz	a5,ffffffffc020090a <pgfault_handler+0x72>
ffffffffc02008c0:	11843703          	ld	a4,280(s0)
ffffffffc02008c4:	47bd                	li	a5,15
ffffffffc02008c6:	05700693          	li	a3,87
ffffffffc02008ca:	00f70463          	beq	a4,a5,ffffffffc02008d2 <pgfault_handler+0x3a>
ffffffffc02008ce:	05200693          	li	a3,82
ffffffffc02008d2:	00006517          	auipc	a0,0x6
ffffffffc02008d6:	25650513          	addi	a0,a0,598 # ffffffffc0206b28 <commands+0x3d8>
ffffffffc02008da:	ff2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008de:	6088                	ld	a0,0(s1)
ffffffffc02008e0:	cd1d                	beqz	a0,ffffffffc020091e <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e2:	000b2717          	auipc	a4,0xb2
ffffffffc02008e6:	18e73703          	ld	a4,398(a4) # ffffffffc02b2a70 <current>
ffffffffc02008ea:	000b2797          	auipc	a5,0xb2
ffffffffc02008ee:	18e7b783          	ld	a5,398(a5) # ffffffffc02b2a78 <idleproc>
ffffffffc02008f2:	04f71663          	bne	a4,a5,ffffffffc020093e <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f6:	11043603          	ld	a2,272(s0)
ffffffffc02008fa:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fe:	6442                	ld	s0,16(sp)
ffffffffc0200900:	60e2                	ld	ra,24(sp)
ffffffffc0200902:	64a2                	ld	s1,8(sp)
ffffffffc0200904:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	6190006f          	j	ffffffffc020171e <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020090a:	11843703          	ld	a4,280(s0)
ffffffffc020090e:	47bd                	li	a5,15
ffffffffc0200910:	05500613          	li	a2,85
ffffffffc0200914:	05700693          	li	a3,87
ffffffffc0200918:	faf71be3          	bne	a4,a5,ffffffffc02008ce <pgfault_handler+0x36>
ffffffffc020091c:	bf5d                	j	ffffffffc02008d2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091e:	000b2797          	auipc	a5,0xb2
ffffffffc0200922:	1527b783          	ld	a5,338(a5) # ffffffffc02b2a70 <current>
ffffffffc0200926:	cf85                	beqz	a5,ffffffffc020095e <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200928:	11043603          	ld	a2,272(s0)
ffffffffc020092c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200930:	6442                	ld	s0,16(sp)
ffffffffc0200932:	60e2                	ld	ra,24(sp)
ffffffffc0200934:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200936:	7788                	ld	a0,40(a5)
}
ffffffffc0200938:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	5e50006f          	j	ffffffffc020171e <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	20a68693          	addi	a3,a3,522 # ffffffffc0206b48 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	21a60613          	addi	a2,a2,538 # ffffffffc0206b60 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	22650513          	addi	a0,a0,550 # ffffffffc0206b78 <commands+0x428>
ffffffffc020095a:	8afff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020095e:	8522                	mv	a0,s0
ffffffffc0200960:	ed7ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200964:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200968:	11043583          	ld	a1,272(s0)
ffffffffc020096c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200970:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200974:	e399                	bnez	a5,ffffffffc020097a <pgfault_handler+0xe2>
ffffffffc0200976:	05500613          	li	a2,85
ffffffffc020097a:	11843703          	ld	a4,280(s0)
ffffffffc020097e:	47bd                	li	a5,15
ffffffffc0200980:	02f70663          	beq	a4,a5,ffffffffc02009ac <pgfault_handler+0x114>
ffffffffc0200984:	05200693          	li	a3,82
ffffffffc0200988:	00006517          	auipc	a0,0x6
ffffffffc020098c:	1a050513          	addi	a0,a0,416 # ffffffffc0206b28 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	1fc60613          	addi	a2,a2,508 # ffffffffc0206b90 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	1d850513          	addi	a0,a0,472 # ffffffffc0206b78 <commands+0x428>
ffffffffc02009a8:	861ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009ac:	05700693          	li	a3,87
ffffffffc02009b0:	bfe1                	j	ffffffffc0200988 <pgfault_handler+0xf0>

ffffffffc02009b2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b2:	11853783          	ld	a5,280(a0)
ffffffffc02009b6:	472d                	li	a4,11
ffffffffc02009b8:	0786                	slli	a5,a5,0x1
ffffffffc02009ba:	8385                	srli	a5,a5,0x1
ffffffffc02009bc:	08f76363          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x90>
ffffffffc02009c0:	00006717          	auipc	a4,0x6
ffffffffc02009c4:	28870713          	addi	a4,a4,648 # ffffffffc0206c48 <commands+0x4f8>
ffffffffc02009c8:	078a                	slli	a5,a5,0x2
ffffffffc02009ca:	97ba                	add	a5,a5,a4
ffffffffc02009cc:	439c                	lw	a5,0(a5)
ffffffffc02009ce:	97ba                	add	a5,a5,a4
ffffffffc02009d0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	23650513          	addi	a0,a0,566 # ffffffffc0206c08 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	20a50513          	addi	a0,a0,522 # ffffffffc0206be8 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	1be50513          	addi	a0,a0,446 # ffffffffc0206ba8 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	1d250513          	addi	a0,a0,466 # ffffffffc0206bc8 <commands+0x478>
ffffffffc02009fe:	eceff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a02:	1141                	addi	sp,sp,-16
ffffffffc0200a04:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a06:	bafff0ef          	jal	ra,ffffffffc02005b4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0a:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0e:	ff668693          	addi	a3,a3,-10 # ffffffffc02b2a00 <ticks>
ffffffffc0200a12:	629c                	ld	a5,0(a3)
ffffffffc0200a14:	06400713          	li	a4,100
ffffffffc0200a18:	0785                	addi	a5,a5,1
ffffffffc0200a1a:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1e:	e29c                	sd	a5,0(a3)
ffffffffc0200a20:	eb01                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x7e>
ffffffffc0200a22:	000b2797          	auipc	a5,0xb2
ffffffffc0200a26:	04e7b783          	ld	a5,78(a5) # ffffffffc02b2a70 <current>
ffffffffc0200a2a:	c399                	beqz	a5,ffffffffc0200a30 <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2c:	4705                	li	a4,1
ffffffffc0200a2e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a36:	00006517          	auipc	a0,0x6
ffffffffc0200a3a:	1f250513          	addi	a0,a0,498 # ffffffffc0206c28 <commands+0x4d8>
ffffffffc0200a3e:	e8eff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a42:	bbd5                	j	ffffffffc0200836 <print_trapframe>

ffffffffc0200a44 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a44:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a48:	1101                	addi	sp,sp,-32
ffffffffc0200a4a:	e822                	sd	s0,16(sp)
ffffffffc0200a4c:	ec06                	sd	ra,24(sp)
ffffffffc0200a4e:	e426                	sd	s1,8(sp)
ffffffffc0200a50:	473d                	li	a4,15
ffffffffc0200a52:	842a                	mv	s0,a0
ffffffffc0200a54:	18f76563          	bltu	a4,a5,ffffffffc0200bde <exception_handler+0x19a>
ffffffffc0200a58:	00006717          	auipc	a4,0x6
ffffffffc0200a5c:	3b870713          	addi	a4,a4,952 # ffffffffc0206e10 <commands+0x6c0>
ffffffffc0200a60:	078a                	slli	a5,a5,0x2
ffffffffc0200a62:	97ba                	add	a5,a5,a4
ffffffffc0200a64:	439c                	lw	a5,0(a5)
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6a:	00006517          	auipc	a0,0x6
ffffffffc0200a6e:	2fe50513          	addi	a0,a0,766 # ffffffffc0206d68 <commands+0x618>
ffffffffc0200a72:	e5aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a76:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7a:	60e2                	ld	ra,24(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7e:	0791                	addi	a5,a5,4
ffffffffc0200a80:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a84:	6442                	ld	s0,16(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a88:	4f40506f          	j	ffffffffc0205f7c <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	2fc50513          	addi	a0,a0,764 # ffffffffc0206d88 <commands+0x638>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	30850513          	addi	a0,a0,776 # ffffffffc0206da8 <commands+0x658>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	31e50513          	addi	a0,a0,798 # ffffffffc0206dc8 <commands+0x678>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	32c50513          	addi	a0,a0,812 # ffffffffc0206de0 <commands+0x690>
ffffffffc0200abc:	e10ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac0:	8522                	mv	a0,s0
ffffffffc0200ac2:	dd7ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ac6:	84aa                	mv	s1,a0
ffffffffc0200ac8:	12051d63          	bnez	a0,ffffffffc0200c02 <exception_handler+0x1be>
}
ffffffffc0200acc:	60e2                	ld	ra,24(sp)
ffffffffc0200ace:	6442                	ld	s0,16(sp)
ffffffffc0200ad0:	64a2                	ld	s1,8(sp)
ffffffffc0200ad2:	6105                	addi	sp,sp,32
ffffffffc0200ad4:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad6:	00006517          	auipc	a0,0x6
ffffffffc0200ada:	32250513          	addi	a0,a0,802 # ffffffffc0206df8 <commands+0x6a8>
ffffffffc0200ade:	deeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae2:	8522                	mv	a0,s0
ffffffffc0200ae4:	db5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ae8:	84aa                	mv	s1,a0
ffffffffc0200aea:	d16d                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aec:	8522                	mv	a0,s0
ffffffffc0200aee:	d49ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af2:	86a6                	mv	a3,s1
ffffffffc0200af4:	00006617          	auipc	a2,0x6
ffffffffc0200af8:	22460613          	addi	a2,a2,548 # ffffffffc0206d18 <commands+0x5c8>
ffffffffc0200afc:	0f800593          	li	a1,248
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	07850513          	addi	a0,a0,120 # ffffffffc0206b78 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	16c50513          	addi	a0,a0,364 # ffffffffc0206c78 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	18250513          	addi	a0,a0,386 # ffffffffc0206c98 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	19850513          	addi	a0,a0,408 # ffffffffc0206cb8 <commands+0x568>
ffffffffc0200b28:	b7b5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	1a650513          	addi	a0,a0,422 # ffffffffc0206cd0 <commands+0x580>
ffffffffc0200b32:	d9aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b36:	6458                	ld	a4,136(s0)
ffffffffc0200b38:	47a9                	li	a5,10
ffffffffc0200b3a:	f8f719e3          	bne	a4,a5,ffffffffc0200acc <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3e:	10843783          	ld	a5,264(s0)
ffffffffc0200b42:	0791                	addi	a5,a5,4
ffffffffc0200b44:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b48:	434050ef          	jal	ra,ffffffffc0205f7c <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4c:	000b2797          	auipc	a5,0xb2
ffffffffc0200b50:	f247b783          	ld	a5,-220(a5) # ffffffffc02b2a70 <current>
ffffffffc0200b54:	6b9c                	ld	a5,16(a5)
ffffffffc0200b56:	8522                	mv	a0,s0
}
ffffffffc0200b58:	6442                	ld	s0,16(sp)
ffffffffc0200b5a:	60e2                	ld	ra,24(sp)
ffffffffc0200b5c:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5e:	6589                	lui	a1,0x2
ffffffffc0200b60:	95be                	add	a1,a1,a5
}
ffffffffc0200b62:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	ac19                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b66:	00006517          	auipc	a0,0x6
ffffffffc0200b6a:	17a50513          	addi	a0,a0,378 # ffffffffc0206ce0 <commands+0x590>
ffffffffc0200b6e:	b71d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	19050513          	addi	a0,a0,400 # ffffffffc0206d00 <commands+0x5b0>
ffffffffc0200b78:	d54ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7c:	8522                	mv	a0,s0
ffffffffc0200b7e:	d1bff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200b82:	84aa                	mv	s1,a0
ffffffffc0200b84:	d521                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b86:	8522                	mv	a0,s0
ffffffffc0200b88:	cafff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8c:	86a6                	mv	a3,s1
ffffffffc0200b8e:	00006617          	auipc	a2,0x6
ffffffffc0200b92:	18a60613          	addi	a2,a2,394 # ffffffffc0206d18 <commands+0x5c8>
ffffffffc0200b96:	0cd00593          	li	a1,205
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	fde50513          	addi	a0,a0,-34 # ffffffffc0206b78 <commands+0x428>
ffffffffc0200ba2:	e66ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	1aa50513          	addi	a0,a0,426 # ffffffffc0206d50 <commands+0x600>
ffffffffc0200bae:	d1eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	ce5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200bb8:	84aa                	mv	s1,a0
ffffffffc0200bba:	f00509e3          	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	c77ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc4:	86a6                	mv	a3,s1
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	15260613          	addi	a2,a2,338 # ffffffffc0206d18 <commands+0x5c8>
ffffffffc0200bce:	0d700593          	li	a1,215
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	fa650513          	addi	a0,a0,-90 # ffffffffc0206b78 <commands+0x428>
ffffffffc0200bda:	e2eff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
}
ffffffffc0200be0:	6442                	ld	s0,16(sp)
ffffffffc0200be2:	60e2                	ld	ra,24(sp)
ffffffffc0200be4:	64a2                	ld	s1,8(sp)
ffffffffc0200be6:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be8:	b1b9                	j	ffffffffc0200836 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bea:	00006617          	auipc	a2,0x6
ffffffffc0200bee:	14e60613          	addi	a2,a2,334 # ffffffffc0206d38 <commands+0x5e8>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	f8250513          	addi	a0,a0,-126 # ffffffffc0206b78 <commands+0x428>
ffffffffc0200bfe:	e0aff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200c02:	8522                	mv	a0,s0
ffffffffc0200c04:	c33ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c08:	86a6                	mv	a3,s1
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	10e60613          	addi	a2,a2,270 # ffffffffc0206d18 <commands+0x5c8>
ffffffffc0200c12:	0f100593          	li	a1,241
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	f6250513          	addi	a0,a0,-158 # ffffffffc0206b78 <commands+0x428>
ffffffffc0200c1e:	deaff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200c22 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c22:	1101                	addi	sp,sp,-32
ffffffffc0200c24:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c26:	000b2417          	auipc	s0,0xb2
ffffffffc0200c2a:	e4a40413          	addi	s0,s0,-438 # ffffffffc02b2a70 <current>
ffffffffc0200c2e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c30:	ec06                	sd	ra,24(sp)
ffffffffc0200c32:	e426                	sd	s1,8(sp)
ffffffffc0200c34:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c36:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c3a:	cf1d                	beqz	a4,ffffffffc0200c78 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c40:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c44:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c46:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c4a:	0206c463          	bltz	a3,ffffffffc0200c72 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4e:	df7ff0ef          	jal	ra,ffffffffc0200a44 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c52:	601c                	ld	a5,0(s0)
ffffffffc0200c54:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c58:	e499                	bnez	s1,ffffffffc0200c66 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c5a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5e:	8b05                	andi	a4,a4,1
ffffffffc0200c60:	e329                	bnez	a4,ffffffffc0200ca2 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c62:	6f9c                	ld	a5,24(a5)
ffffffffc0200c64:	eb85                	bnez	a5,ffffffffc0200c94 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
ffffffffc0200c68:	6442                	ld	s0,16(sp)
ffffffffc0200c6a:	64a2                	ld	s1,8(sp)
ffffffffc0200c6c:	6902                	ld	s2,0(sp)
ffffffffc0200c6e:	6105                	addi	sp,sp,32
ffffffffc0200c70:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c72:	d41ff0ef          	jal	ra,ffffffffc02009b2 <interrupt_handler>
ffffffffc0200c76:	bff1                	j	ffffffffc0200c52 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0006c863          	bltz	a3,ffffffffc0200c88 <trap+0x66>
}
ffffffffc0200c7c:	6442                	ld	s0,16(sp)
ffffffffc0200c7e:	60e2                	ld	ra,24(sp)
ffffffffc0200c80:	64a2                	ld	s1,8(sp)
ffffffffc0200c82:	6902                	ld	s2,0(sp)
ffffffffc0200c84:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c86:	bb7d                	j	ffffffffc0200a44 <exception_handler>
}
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	60e2                	ld	ra,24(sp)
ffffffffc0200c8c:	64a2                	ld	s1,8(sp)
ffffffffc0200c8e:	6902                	ld	s2,0(sp)
ffffffffc0200c90:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c92:	b305                	j	ffffffffc02009b2 <interrupt_handler>
}
ffffffffc0200c94:	6442                	ld	s0,16(sp)
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9e:	1f20506f          	j	ffffffffc0205e90 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca2:	555d                	li	a0,-9
ffffffffc0200ca4:	5a0040ef          	jal	ra,ffffffffc0205244 <do_exit>
            if (current->need_resched) {
ffffffffc0200ca8:	601c                	ld	a5,0(s0)
ffffffffc0200caa:	bf65                	j	ffffffffc0200c62 <trap+0x40>

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f0bff0ef          	jal	ra,ffffffffc0200c22 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cf8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e22:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e24:	00006697          	auipc	a3,0x6
ffffffffc0200e28:	02c68693          	addi	a3,a3,44 # ffffffffc0206e50 <commands+0x700>
ffffffffc0200e2c:	00006617          	auipc	a2,0x6
ffffffffc0200e30:	d3460613          	addi	a2,a2,-716 # ffffffffc0206b60 <commands+0x410>
ffffffffc0200e34:	06d00593          	li	a1,109
ffffffffc0200e38:	00006517          	auipc	a0,0x6
ffffffffc0200e3c:	03850513          	addi	a0,a0,56 # ffffffffc0206e70 <commands+0x720>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e40:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e42:	bc6ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e46 <mm_create>:
mm_create(void) {
ffffffffc0200e46:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e48:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e4c:	e022                	sd	s0,0(sp)
ffffffffc0200e4e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e50:	062010ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0200e54:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e56:	c505                	beqz	a0,ffffffffc0200e7e <mm_create+0x38>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e58:	e408                	sd	a0,8(s0)
ffffffffc0200e5a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e5c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e60:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200e64:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e68:	000b2797          	auipc	a5,0xb2
ffffffffc0200e6c:	bd07a783          	lw	a5,-1072(a5) # ffffffffc02b2a38 <swap_init_ok>
ffffffffc0200e70:	ef81                	bnez	a5,ffffffffc0200e88 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0200e72:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200e76:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200e7a:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200e7e:	60a2                	ld	ra,8(sp)
ffffffffc0200e80:	8522                	mv	a0,s0
ffffffffc0200e82:	6402                	ld	s0,0(sp)
ffffffffc0200e84:	0141                	addi	sp,sp,16
ffffffffc0200e86:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e88:	133010ef          	jal	ra,ffffffffc02027ba <swap_init_mm>
ffffffffc0200e8c:	b7ed                	j	ffffffffc0200e76 <mm_create+0x30>

ffffffffc0200e8e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e8e:	1101                	addi	sp,sp,-32
ffffffffc0200e90:	e04a                	sd	s2,0(sp)
ffffffffc0200e92:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e94:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e98:	e822                	sd	s0,16(sp)
ffffffffc0200e9a:	e426                	sd	s1,8(sp)
ffffffffc0200e9c:	ec06                	sd	ra,24(sp)
ffffffffc0200e9e:	84ae                	mv	s1,a1
ffffffffc0200ea0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ea2:	010010ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
    if (vma != NULL) {
ffffffffc0200ea6:	c509                	beqz	a0,ffffffffc0200eb0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200ea8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200eac:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200eae:	cd00                	sw	s0,24(a0)
}
ffffffffc0200eb0:	60e2                	ld	ra,24(sp)
ffffffffc0200eb2:	6442                	ld	s0,16(sp)
ffffffffc0200eb4:	64a2                	ld	s1,8(sp)
ffffffffc0200eb6:	6902                	ld	s2,0(sp)
ffffffffc0200eb8:	6105                	addi	sp,sp,32
ffffffffc0200eba:	8082                	ret

ffffffffc0200ebc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200ebc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200ebe:	c505                	beqz	a0,ffffffffc0200ee6 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200ec0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ec2:	c501                	beqz	a0,ffffffffc0200eca <find_vma+0xe>
ffffffffc0200ec4:	651c                	ld	a5,8(a0)
ffffffffc0200ec6:	02f5f263          	bgeu	a1,a5,ffffffffc0200eea <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200eca:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200ecc:	00f68d63          	beq	a3,a5,ffffffffc0200ee6 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200ed0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ed4:	00e5e663          	bltu	a1,a4,ffffffffc0200ee0 <find_vma+0x24>
ffffffffc0200ed8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200edc:	00e5ec63          	bltu	a1,a4,ffffffffc0200ef4 <find_vma+0x38>
ffffffffc0200ee0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200ee2:	fef697e3          	bne	a3,a5,ffffffffc0200ed0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200ee6:	4501                	li	a0,0
}
ffffffffc0200ee8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200eea:	691c                	ld	a5,16(a0)
ffffffffc0200eec:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200eca <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200ef0:	ea88                	sd	a0,16(a3)
ffffffffc0200ef2:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200ef4:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200ef8:	ea88                	sd	a0,16(a3)
ffffffffc0200efa:	8082                	ret

ffffffffc0200efc <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200efc:	6590                	ld	a2,8(a1)
ffffffffc0200efe:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f02:	1141                	addi	sp,sp,-16
ffffffffc0200f04:	e406                	sd	ra,8(sp)
ffffffffc0200f06:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f08:	01066763          	bltu	a2,a6,ffffffffc0200f16 <insert_vma_struct+0x1a>
ffffffffc0200f0c:	a085                	j	ffffffffc0200f6c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f0e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f12:	04e66863          	bltu	a2,a4,ffffffffc0200f62 <insert_vma_struct+0x66>
ffffffffc0200f16:	86be                	mv	a3,a5
ffffffffc0200f18:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200f1a:	fef51ae3          	bne	a0,a5,ffffffffc0200f0e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f1e:	02a68463          	beq	a3,a0,ffffffffc0200f46 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f22:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f26:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200f2a:	08e8f163          	bgeu	a7,a4,ffffffffc0200fac <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f2e:	04e66f63          	bltu	a2,a4,ffffffffc0200f8c <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200f32:	00f50a63          	beq	a0,a5,ffffffffc0200f46 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f36:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f3a:	05076963          	bltu	a4,a6,ffffffffc0200f8c <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f3e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f42:	02c77363          	bgeu	a4,a2,ffffffffc0200f68 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f46:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f48:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f4a:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f4e:	e390                	sd	a2,0(a5)
ffffffffc0200f50:	e690                	sd	a2,8(a3)
}
ffffffffc0200f52:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f54:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f56:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200f58:	0017079b          	addiw	a5,a4,1
ffffffffc0200f5c:	d11c                	sw	a5,32(a0)
}
ffffffffc0200f5e:	0141                	addi	sp,sp,16
ffffffffc0200f60:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f62:	fca690e3          	bne	a3,a0,ffffffffc0200f22 <insert_vma_struct+0x26>
ffffffffc0200f66:	bfd1                	j	ffffffffc0200f3a <insert_vma_struct+0x3e>
ffffffffc0200f68:	ebbff0ef          	jal	ra,ffffffffc0200e22 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f6c:	00006697          	auipc	a3,0x6
ffffffffc0200f70:	f1468693          	addi	a3,a3,-236 # ffffffffc0206e80 <commands+0x730>
ffffffffc0200f74:	00006617          	auipc	a2,0x6
ffffffffc0200f78:	bec60613          	addi	a2,a2,-1044 # ffffffffc0206b60 <commands+0x410>
ffffffffc0200f7c:	07400593          	li	a1,116
ffffffffc0200f80:	00006517          	auipc	a0,0x6
ffffffffc0200f84:	ef050513          	addi	a0,a0,-272 # ffffffffc0206e70 <commands+0x720>
ffffffffc0200f88:	a80ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f8c:	00006697          	auipc	a3,0x6
ffffffffc0200f90:	f3468693          	addi	a3,a3,-204 # ffffffffc0206ec0 <commands+0x770>
ffffffffc0200f94:	00006617          	auipc	a2,0x6
ffffffffc0200f98:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0206b60 <commands+0x410>
ffffffffc0200f9c:	06c00593          	li	a1,108
ffffffffc0200fa0:	00006517          	auipc	a0,0x6
ffffffffc0200fa4:	ed050513          	addi	a0,a0,-304 # ffffffffc0206e70 <commands+0x720>
ffffffffc0200fa8:	a60ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fac:	00006697          	auipc	a3,0x6
ffffffffc0200fb0:	ef468693          	addi	a3,a3,-268 # ffffffffc0206ea0 <commands+0x750>
ffffffffc0200fb4:	00006617          	auipc	a2,0x6
ffffffffc0200fb8:	bac60613          	addi	a2,a2,-1108 # ffffffffc0206b60 <commands+0x410>
ffffffffc0200fbc:	06b00593          	li	a1,107
ffffffffc0200fc0:	00006517          	auipc	a0,0x6
ffffffffc0200fc4:	eb050513          	addi	a0,a0,-336 # ffffffffc0206e70 <commands+0x720>
ffffffffc0200fc8:	a40ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200fcc <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0200fcc:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0200fce:	1141                	addi	sp,sp,-16
ffffffffc0200fd0:	e406                	sd	ra,8(sp)
ffffffffc0200fd2:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0200fd4:	e78d                	bnez	a5,ffffffffc0200ffe <mm_destroy+0x32>
ffffffffc0200fd6:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200fd8:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200fda:	00a40c63          	beq	s0,a0,ffffffffc0200ff2 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fde:	6118                	ld	a4,0(a0)
ffffffffc0200fe0:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200fe2:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200fe4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fe6:	e398                	sd	a4,0(a5)
ffffffffc0200fe8:	77b000ef          	jal	ra,ffffffffc0201f62 <kfree>
    return listelm->next;
ffffffffc0200fec:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fee:	fea418e3          	bne	s0,a0,ffffffffc0200fde <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0200ff2:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200ff4:	6402                	ld	s0,0(sp)
ffffffffc0200ff6:	60a2                	ld	ra,8(sp)
ffffffffc0200ff8:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200ffa:	7690006f          	j	ffffffffc0201f62 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0200ffe:	00006697          	auipc	a3,0x6
ffffffffc0201002:	ee268693          	addi	a3,a3,-286 # ffffffffc0206ee0 <commands+0x790>
ffffffffc0201006:	00006617          	auipc	a2,0x6
ffffffffc020100a:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0206b60 <commands+0x410>
ffffffffc020100e:	09400593          	li	a1,148
ffffffffc0201012:	00006517          	auipc	a0,0x6
ffffffffc0201016:	e5e50513          	addi	a0,a0,-418 # ffffffffc0206e70 <commands+0x720>
ffffffffc020101a:	9eeff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020101e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc020101e:	7139                	addi	sp,sp,-64
ffffffffc0201020:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201022:	6405                	lui	s0,0x1
ffffffffc0201024:	147d                	addi	s0,s0,-1
ffffffffc0201026:	77fd                	lui	a5,0xfffff
ffffffffc0201028:	9622                	add	a2,a2,s0
ffffffffc020102a:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc020102c:	f426                	sd	s1,40(sp)
ffffffffc020102e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201030:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0201034:	f04a                	sd	s2,32(sp)
ffffffffc0201036:	ec4e                	sd	s3,24(sp)
ffffffffc0201038:	e852                	sd	s4,16(sp)
ffffffffc020103a:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc020103c:	002005b7          	lui	a1,0x200
ffffffffc0201040:	00f67433          	and	s0,a2,a5
ffffffffc0201044:	06b4e363          	bltu	s1,a1,ffffffffc02010aa <mm_map+0x8c>
ffffffffc0201048:	0684f163          	bgeu	s1,s0,ffffffffc02010aa <mm_map+0x8c>
ffffffffc020104c:	4785                	li	a5,1
ffffffffc020104e:	07fe                	slli	a5,a5,0x1f
ffffffffc0201050:	0487ed63          	bltu	a5,s0,ffffffffc02010aa <mm_map+0x8c>
ffffffffc0201054:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201056:	cd21                	beqz	a0,ffffffffc02010ae <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201058:	85a6                	mv	a1,s1
ffffffffc020105a:	8ab6                	mv	s5,a3
ffffffffc020105c:	8a3a                	mv	s4,a4
ffffffffc020105e:	e5fff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc0201062:	c501                	beqz	a0,ffffffffc020106a <mm_map+0x4c>
ffffffffc0201064:	651c                	ld	a5,8(a0)
ffffffffc0201066:	0487e263          	bltu	a5,s0,ffffffffc02010aa <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020106a:	03000513          	li	a0,48
ffffffffc020106e:	645000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0201072:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0201074:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0201076:	02090163          	beqz	s2,ffffffffc0201098 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020107a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020107c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0201080:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0201084:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0201088:	85ca                	mv	a1,s2
ffffffffc020108a:	e73ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020108e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0201090:	000a0463          	beqz	s4,ffffffffc0201098 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0201094:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0201098:	70e2                	ld	ra,56(sp)
ffffffffc020109a:	7442                	ld	s0,48(sp)
ffffffffc020109c:	74a2                	ld	s1,40(sp)
ffffffffc020109e:	7902                	ld	s2,32(sp)
ffffffffc02010a0:	69e2                	ld	s3,24(sp)
ffffffffc02010a2:	6a42                	ld	s4,16(sp)
ffffffffc02010a4:	6aa2                	ld	s5,8(sp)
ffffffffc02010a6:	6121                	addi	sp,sp,64
ffffffffc02010a8:	8082                	ret
        return -E_INVAL;
ffffffffc02010aa:	5575                	li	a0,-3
ffffffffc02010ac:	b7f5                	j	ffffffffc0201098 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02010ae:	00006697          	auipc	a3,0x6
ffffffffc02010b2:	e4a68693          	addi	a3,a3,-438 # ffffffffc0206ef8 <commands+0x7a8>
ffffffffc02010b6:	00006617          	auipc	a2,0x6
ffffffffc02010ba:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0206b60 <commands+0x410>
ffffffffc02010be:	0a700593          	li	a1,167
ffffffffc02010c2:	00006517          	auipc	a0,0x6
ffffffffc02010c6:	dae50513          	addi	a0,a0,-594 # ffffffffc0206e70 <commands+0x720>
ffffffffc02010ca:	93eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02010ce <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02010ce:	7139                	addi	sp,sp,-64
ffffffffc02010d0:	fc06                	sd	ra,56(sp)
ffffffffc02010d2:	f822                	sd	s0,48(sp)
ffffffffc02010d4:	f426                	sd	s1,40(sp)
ffffffffc02010d6:	f04a                	sd	s2,32(sp)
ffffffffc02010d8:	ec4e                	sd	s3,24(sp)
ffffffffc02010da:	e852                	sd	s4,16(sp)
ffffffffc02010dc:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02010de:	c52d                	beqz	a0,ffffffffc0201148 <dup_mmap+0x7a>
ffffffffc02010e0:	892a                	mv	s2,a0
ffffffffc02010e2:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02010e4:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02010e6:	e595                	bnez	a1,ffffffffc0201112 <dup_mmap+0x44>
ffffffffc02010e8:	a085                	j	ffffffffc0201148 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02010ea:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02010ec:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ec0>
        vma->vm_end = vm_end;
ffffffffc02010f0:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02010f4:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02010f8:	e05ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02010fc:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8be8>
ffffffffc0201100:	fe843603          	ld	a2,-24(s0)
ffffffffc0201104:	6c8c                	ld	a1,24(s1)
ffffffffc0201106:	01893503          	ld	a0,24(s2)
ffffffffc020110a:	4701                	li	a4,0
ffffffffc020110c:	245020ef          	jal	ra,ffffffffc0203b50 <copy_range>
ffffffffc0201110:	e105                	bnez	a0,ffffffffc0201130 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0201112:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0201114:	02848863          	beq	s1,s0,ffffffffc0201144 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201118:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020111c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0201120:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201124:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201128:	58b000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc020112c:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020112e:	fd55                	bnez	a0,ffffffffc02010ea <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0201130:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0201132:	70e2                	ld	ra,56(sp)
ffffffffc0201134:	7442                	ld	s0,48(sp)
ffffffffc0201136:	74a2                	ld	s1,40(sp)
ffffffffc0201138:	7902                	ld	s2,32(sp)
ffffffffc020113a:	69e2                	ld	s3,24(sp)
ffffffffc020113c:	6a42                	ld	s4,16(sp)
ffffffffc020113e:	6aa2                	ld	s5,8(sp)
ffffffffc0201140:	6121                	addi	sp,sp,64
ffffffffc0201142:	8082                	ret
    return 0;
ffffffffc0201144:	4501                	li	a0,0
ffffffffc0201146:	b7f5                	j	ffffffffc0201132 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0201148:	00006697          	auipc	a3,0x6
ffffffffc020114c:	dc068693          	addi	a3,a3,-576 # ffffffffc0206f08 <commands+0x7b8>
ffffffffc0201150:	00006617          	auipc	a2,0x6
ffffffffc0201154:	a1060613          	addi	a2,a2,-1520 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201158:	0c000593          	li	a1,192
ffffffffc020115c:	00006517          	auipc	a0,0x6
ffffffffc0201160:	d1450513          	addi	a0,a0,-748 # ffffffffc0206e70 <commands+0x720>
ffffffffc0201164:	8a4ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201168 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0201168:	1101                	addi	sp,sp,-32
ffffffffc020116a:	ec06                	sd	ra,24(sp)
ffffffffc020116c:	e822                	sd	s0,16(sp)
ffffffffc020116e:	e426                	sd	s1,8(sp)
ffffffffc0201170:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201172:	c531                	beqz	a0,ffffffffc02011be <exit_mmap+0x56>
ffffffffc0201174:	591c                	lw	a5,48(a0)
ffffffffc0201176:	84aa                	mv	s1,a0
ffffffffc0201178:	e3b9                	bnez	a5,ffffffffc02011be <exit_mmap+0x56>
    return listelm->next;
ffffffffc020117a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020117c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0201180:	02850663          	beq	a0,s0,ffffffffc02011ac <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201184:	ff043603          	ld	a2,-16(s0)
ffffffffc0201188:	fe843583          	ld	a1,-24(s0)
ffffffffc020118c:	854a                	mv	a0,s2
ffffffffc020118e:	5ea020ef          	jal	ra,ffffffffc0203778 <unmap_range>
ffffffffc0201192:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0201194:	fe8498e3          	bne	s1,s0,ffffffffc0201184 <exit_mmap+0x1c>
ffffffffc0201198:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020119a:	00848c63          	beq	s1,s0,ffffffffc02011b2 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020119e:	ff043603          	ld	a2,-16(s0)
ffffffffc02011a2:	fe843583          	ld	a1,-24(s0)
ffffffffc02011a6:	854a                	mv	a0,s2
ffffffffc02011a8:	716020ef          	jal	ra,ffffffffc02038be <exit_range>
ffffffffc02011ac:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011ae:	fe8498e3          	bne	s1,s0,ffffffffc020119e <exit_mmap+0x36>
    }
}
ffffffffc02011b2:	60e2                	ld	ra,24(sp)
ffffffffc02011b4:	6442                	ld	s0,16(sp)
ffffffffc02011b6:	64a2                	ld	s1,8(sp)
ffffffffc02011b8:	6902                	ld	s2,0(sp)
ffffffffc02011ba:	6105                	addi	sp,sp,32
ffffffffc02011bc:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011be:	00006697          	auipc	a3,0x6
ffffffffc02011c2:	d6a68693          	addi	a3,a3,-662 # ffffffffc0206f28 <commands+0x7d8>
ffffffffc02011c6:	00006617          	auipc	a2,0x6
ffffffffc02011ca:	99a60613          	addi	a2,a2,-1638 # ffffffffc0206b60 <commands+0x410>
ffffffffc02011ce:	0d600593          	li	a1,214
ffffffffc02011d2:	00006517          	auipc	a0,0x6
ffffffffc02011d6:	c9e50513          	addi	a0,a0,-866 # ffffffffc0206e70 <commands+0x720>
ffffffffc02011da:	82eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02011de <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02011de:	7139                	addi	sp,sp,-64
ffffffffc02011e0:	f822                	sd	s0,48(sp)
ffffffffc02011e2:	f426                	sd	s1,40(sp)
ffffffffc02011e4:	fc06                	sd	ra,56(sp)
ffffffffc02011e6:	f04a                	sd	s2,32(sp)
ffffffffc02011e8:	ec4e                	sd	s3,24(sp)
ffffffffc02011ea:	e852                	sd	s4,16(sp)
ffffffffc02011ec:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02011ee:	c59ff0ef          	jal	ra,ffffffffc0200e46 <mm_create>
    assert(mm != NULL);
ffffffffc02011f2:	84aa                	mv	s1,a0
ffffffffc02011f4:	03200413          	li	s0,50
ffffffffc02011f8:	e919                	bnez	a0,ffffffffc020120e <vmm_init+0x30>
ffffffffc02011fa:	a991                	j	ffffffffc020164e <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02011fc:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02011fe:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201200:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0201204:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201206:	8526                	mv	a0,s1
ffffffffc0201208:	cf5ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020120c:	c80d                	beqz	s0,ffffffffc020123e <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020120e:	03000513          	li	a0,48
ffffffffc0201212:	4a1000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0201216:	85aa                	mv	a1,a0
ffffffffc0201218:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020121c:	f165                	bnez	a0,ffffffffc02011fc <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc020121e:	00006697          	auipc	a3,0x6
ffffffffc0201222:	f9a68693          	addi	a3,a3,-102 # ffffffffc02071b8 <commands+0xa68>
ffffffffc0201226:	00006617          	auipc	a2,0x6
ffffffffc020122a:	93a60613          	addi	a2,a2,-1734 # ffffffffc0206b60 <commands+0x410>
ffffffffc020122e:	11300593          	li	a1,275
ffffffffc0201232:	00006517          	auipc	a0,0x6
ffffffffc0201236:	c3e50513          	addi	a0,a0,-962 # ffffffffc0206e70 <commands+0x720>
ffffffffc020123a:	fcffe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020123e:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201242:	1f900913          	li	s2,505
ffffffffc0201246:	a819                	j	ffffffffc020125c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201248:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020124a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020124c:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201250:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201252:	8526                	mv	a0,s1
ffffffffc0201254:	ca9ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201258:	03240a63          	beq	s0,s2,ffffffffc020128c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020125c:	03000513          	li	a0,48
ffffffffc0201260:	453000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0201264:	85aa                	mv	a1,a0
ffffffffc0201266:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020126a:	fd79                	bnez	a0,ffffffffc0201248 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020126c:	00006697          	auipc	a3,0x6
ffffffffc0201270:	f4c68693          	addi	a3,a3,-180 # ffffffffc02071b8 <commands+0xa68>
ffffffffc0201274:	00006617          	auipc	a2,0x6
ffffffffc0201278:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0206b60 <commands+0x410>
ffffffffc020127c:	11900593          	li	a1,281
ffffffffc0201280:	00006517          	auipc	a0,0x6
ffffffffc0201284:	bf050513          	addi	a0,a0,-1040 # ffffffffc0206e70 <commands+0x720>
ffffffffc0201288:	f81fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020128c:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc020128e:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0201290:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201294:	2cf48d63          	beq	s1,a5,ffffffffc020156e <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201298:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c55c>
ffffffffc020129c:	ffe70613          	addi	a2,a4,-2
ffffffffc02012a0:	24d61763          	bne	a2,a3,ffffffffc02014ee <vmm_init+0x310>
ffffffffc02012a4:	ff07b683          	ld	a3,-16(a5)
ffffffffc02012a8:	24e69363          	bne	a3,a4,ffffffffc02014ee <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc02012ac:	0715                	addi	a4,a4,5
ffffffffc02012ae:	679c                	ld	a5,8(a5)
ffffffffc02012b0:	feb712e3          	bne	a4,a1,ffffffffc0201294 <vmm_init+0xb6>
ffffffffc02012b4:	4a1d                	li	s4,7
ffffffffc02012b6:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012b8:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012bc:	85a2                	mv	a1,s0
ffffffffc02012be:	8526                	mv	a0,s1
ffffffffc02012c0:	bfdff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02012c4:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02012c6:	30050463          	beqz	a0,ffffffffc02015ce <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02012ca:	00140593          	addi	a1,s0,1
ffffffffc02012ce:	8526                	mv	a0,s1
ffffffffc02012d0:	bedff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02012d4:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02012d6:	2c050c63          	beqz	a0,ffffffffc02015ae <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02012da:	85d2                	mv	a1,s4
ffffffffc02012dc:	8526                	mv	a0,s1
ffffffffc02012de:	bdfff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma3 == NULL);
ffffffffc02012e2:	2a051663          	bnez	a0,ffffffffc020158e <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02012e6:	00340593          	addi	a1,s0,3
ffffffffc02012ea:	8526                	mv	a0,s1
ffffffffc02012ec:	bd1ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma4 == NULL);
ffffffffc02012f0:	30051f63          	bnez	a0,ffffffffc020160e <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02012f4:	00440593          	addi	a1,s0,4
ffffffffc02012f8:	8526                	mv	a0,s1
ffffffffc02012fa:	bc3ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma5 == NULL);
ffffffffc02012fe:	2e051863          	bnez	a0,ffffffffc02015ee <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201302:	00893783          	ld	a5,8(s2)
ffffffffc0201306:	20879463          	bne	a5,s0,ffffffffc020150e <vmm_init+0x330>
ffffffffc020130a:	01093783          	ld	a5,16(s2)
ffffffffc020130e:	20fa1063          	bne	s4,a5,ffffffffc020150e <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201312:	0089b783          	ld	a5,8(s3)
ffffffffc0201316:	20879c63          	bne	a5,s0,ffffffffc020152e <vmm_init+0x350>
ffffffffc020131a:	0109b783          	ld	a5,16(s3)
ffffffffc020131e:	20fa1863          	bne	s4,a5,ffffffffc020152e <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201322:	0415                	addi	s0,s0,5
ffffffffc0201324:	0a15                	addi	s4,s4,5
ffffffffc0201326:	f9541be3          	bne	s0,s5,ffffffffc02012bc <vmm_init+0xde>
ffffffffc020132a:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020132c:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020132e:	85a2                	mv	a1,s0
ffffffffc0201330:	8526                	mv	a0,s1
ffffffffc0201332:	b8bff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc0201336:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc020133a:	c90d                	beqz	a0,ffffffffc020136c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020133c:	6914                	ld	a3,16(a0)
ffffffffc020133e:	6510                	ld	a2,8(a0)
ffffffffc0201340:	00006517          	auipc	a0,0x6
ffffffffc0201344:	d0850513          	addi	a0,a0,-760 # ffffffffc0207048 <commands+0x8f8>
ffffffffc0201348:	d85fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020134c:	00006697          	auipc	a3,0x6
ffffffffc0201350:	d2468693          	addi	a3,a3,-732 # ffffffffc0207070 <commands+0x920>
ffffffffc0201354:	00006617          	auipc	a2,0x6
ffffffffc0201358:	80c60613          	addi	a2,a2,-2036 # ffffffffc0206b60 <commands+0x410>
ffffffffc020135c:	13b00593          	li	a1,315
ffffffffc0201360:	00006517          	auipc	a0,0x6
ffffffffc0201364:	b1050513          	addi	a0,a0,-1264 # ffffffffc0206e70 <commands+0x720>
ffffffffc0201368:	ea1fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc020136c:	147d                	addi	s0,s0,-1
ffffffffc020136e:	fd2410e3          	bne	s0,s2,ffffffffc020132e <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0201372:	8526                	mv	a0,s1
ffffffffc0201374:	c59ff0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	d1050513          	addi	a0,a0,-752 # ffffffffc0207088 <commands+0x938>
ffffffffc0201380:	d4dfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201384:	194020ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc0201388:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc020138a:	abdff0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc020138e:	000b1797          	auipc	a5,0xb1
ffffffffc0201392:	68a7b123          	sd	a0,1666(a5) # ffffffffc02b2a10 <check_mm_struct>
ffffffffc0201396:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0201398:	28050b63          	beqz	a0,ffffffffc020162e <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020139c:	000b1497          	auipc	s1,0xb1
ffffffffc02013a0:	6ac4b483          	ld	s1,1708(s1) # ffffffffc02b2a48 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02013a4:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013a6:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02013a8:	2e079f63          	bnez	a5,ffffffffc02016a6 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013ac:	03000513          	li	a0,48
ffffffffc02013b0:	303000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc02013b4:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02013b6:	18050c63          	beqz	a0,ffffffffc020154e <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc02013ba:	002007b7          	lui	a5,0x200
ffffffffc02013be:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02013c2:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02013c4:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02013c6:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013ca:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02013cc:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013d0:	b2dff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02013d4:	10000593          	li	a1,256
ffffffffc02013d8:	8522                	mv	a0,s0
ffffffffc02013da:	ae3ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02013de:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02013e2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02013e6:	2ea99063          	bne	s3,a0,ffffffffc02016c6 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02013ea:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4eb8>
    for (i = 0; i < 100; i ++) {
ffffffffc02013ee:	0785                	addi	a5,a5,1
ffffffffc02013f0:	fee79de3          	bne	a5,a4,ffffffffc02013ea <vmm_init+0x20c>
        sum += i;
ffffffffc02013f4:	6705                	lui	a4,0x1
ffffffffc02013f6:	10000793          	li	a5,256
ffffffffc02013fa:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8882>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02013fe:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201402:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0201406:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0201408:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020140a:	fec79ce3          	bne	a5,a2,ffffffffc0201402 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc020140e:	2e071863          	bnez	a4,ffffffffc02016fe <vmm_init+0x520>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0201412:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201414:	000b1a97          	auipc	s5,0xb1
ffffffffc0201418:	63ca8a93          	addi	s5,s5,1596 # ffffffffc02b2a50 <npage>
ffffffffc020141c:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201420:	078a                	slli	a5,a5,0x2
ffffffffc0201422:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201424:	2cc7f163          	bgeu	a5,a2,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201428:	00007a17          	auipc	s4,0x7
ffffffffc020142c:	740a3a03          	ld	s4,1856(s4) # ffffffffc0208b68 <nbase>
ffffffffc0201430:	414787b3          	sub	a5,a5,s4
ffffffffc0201434:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201436:	8799                	srai	a5,a5,0x6
ffffffffc0201438:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc020143a:	00c79713          	slli	a4,a5,0xc
ffffffffc020143e:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201440:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201444:	24c77563          	bgeu	a4,a2,ffffffffc020168e <vmm_init+0x4b0>
ffffffffc0201448:	000b1997          	auipc	s3,0xb1
ffffffffc020144c:	6209b983          	ld	s3,1568(s3) # ffffffffc02b2a68 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201450:	4581                	li	a1,0
ffffffffc0201452:	8526                	mv	a0,s1
ffffffffc0201454:	99b6                	add	s3,s3,a3
ffffffffc0201456:	087020ef          	jal	ra,ffffffffc0203cdc <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020145a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020145e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201462:	078a                	slli	a5,a5,0x2
ffffffffc0201464:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201466:	28e7f063          	bgeu	a5,a4,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020146a:	000b1997          	auipc	s3,0xb1
ffffffffc020146e:	5ee98993          	addi	s3,s3,1518 # ffffffffc02b2a58 <pages>
ffffffffc0201472:	0009b503          	ld	a0,0(s3)
ffffffffc0201476:	414787b3          	sub	a5,a5,s4
ffffffffc020147a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020147c:	953e                	add	a0,a0,a5
ffffffffc020147e:	4585                	li	a1,1
ffffffffc0201480:	058020ef          	jal	ra,ffffffffc02034d8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201484:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201486:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020148a:	078a                	slli	a5,a5,0x2
ffffffffc020148c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020148e:	24e7fc63          	bgeu	a5,a4,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201492:	0009b503          	ld	a0,0(s3)
ffffffffc0201496:	414787b3          	sub	a5,a5,s4
ffffffffc020149a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020149c:	4585                	li	a1,1
ffffffffc020149e:	953e                	add	a0,a0,a5
ffffffffc02014a0:	038020ef          	jal	ra,ffffffffc02034d8 <free_pages>
    pgdir[0] = 0;
ffffffffc02014a4:	0004b023          	sd	zero,0(s1)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02014a8:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02014ac:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02014ae:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02014b2:	b1bff0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02014b6:	000b1797          	auipc	a5,0xb1
ffffffffc02014ba:	5407bd23          	sd	zero,1370(a5) # ffffffffc02b2a10 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014be:	05a020ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc02014c2:	1aa91663          	bne	s2,a0,ffffffffc020166e <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02014c6:	00006517          	auipc	a0,0x6
ffffffffc02014ca:	cba50513          	addi	a0,a0,-838 # ffffffffc0207180 <commands+0xa30>
ffffffffc02014ce:	bfffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02014d2:	7442                	ld	s0,48(sp)
ffffffffc02014d4:	70e2                	ld	ra,56(sp)
ffffffffc02014d6:	74a2                	ld	s1,40(sp)
ffffffffc02014d8:	7902                	ld	s2,32(sp)
ffffffffc02014da:	69e2                	ld	s3,24(sp)
ffffffffc02014dc:	6a42                	ld	s4,16(sp)
ffffffffc02014de:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014e0:	00006517          	auipc	a0,0x6
ffffffffc02014e4:	cc050513          	addi	a0,a0,-832 # ffffffffc02071a0 <commands+0xa50>
}
ffffffffc02014e8:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014ea:	be3fe06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02014ee:	00006697          	auipc	a3,0x6
ffffffffc02014f2:	a7268693          	addi	a3,a3,-1422 # ffffffffc0206f60 <commands+0x810>
ffffffffc02014f6:	00005617          	auipc	a2,0x5
ffffffffc02014fa:	66a60613          	addi	a2,a2,1642 # ffffffffc0206b60 <commands+0x410>
ffffffffc02014fe:	12200593          	li	a1,290
ffffffffc0201502:	00006517          	auipc	a0,0x6
ffffffffc0201506:	96e50513          	addi	a0,a0,-1682 # ffffffffc0206e70 <commands+0x720>
ffffffffc020150a:	cfffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020150e:	00006697          	auipc	a3,0x6
ffffffffc0201512:	ada68693          	addi	a3,a3,-1318 # ffffffffc0206fe8 <commands+0x898>
ffffffffc0201516:	00005617          	auipc	a2,0x5
ffffffffc020151a:	64a60613          	addi	a2,a2,1610 # ffffffffc0206b60 <commands+0x410>
ffffffffc020151e:	13200593          	li	a1,306
ffffffffc0201522:	00006517          	auipc	a0,0x6
ffffffffc0201526:	94e50513          	addi	a0,a0,-1714 # ffffffffc0206e70 <commands+0x720>
ffffffffc020152a:	cdffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020152e:	00006697          	auipc	a3,0x6
ffffffffc0201532:	aea68693          	addi	a3,a3,-1302 # ffffffffc0207018 <commands+0x8c8>
ffffffffc0201536:	00005617          	auipc	a2,0x5
ffffffffc020153a:	62a60613          	addi	a2,a2,1578 # ffffffffc0206b60 <commands+0x410>
ffffffffc020153e:	13300593          	li	a1,307
ffffffffc0201542:	00006517          	auipc	a0,0x6
ffffffffc0201546:	92e50513          	addi	a0,a0,-1746 # ffffffffc0206e70 <commands+0x720>
ffffffffc020154a:	cbffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc020154e:	00006697          	auipc	a3,0x6
ffffffffc0201552:	c6a68693          	addi	a3,a3,-918 # ffffffffc02071b8 <commands+0xa68>
ffffffffc0201556:	00005617          	auipc	a2,0x5
ffffffffc020155a:	60a60613          	addi	a2,a2,1546 # ffffffffc0206b60 <commands+0x410>
ffffffffc020155e:	15200593          	li	a1,338
ffffffffc0201562:	00006517          	auipc	a0,0x6
ffffffffc0201566:	90e50513          	addi	a0,a0,-1778 # ffffffffc0206e70 <commands+0x720>
ffffffffc020156a:	c9ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020156e:	00006697          	auipc	a3,0x6
ffffffffc0201572:	9da68693          	addi	a3,a3,-1574 # ffffffffc0206f48 <commands+0x7f8>
ffffffffc0201576:	00005617          	auipc	a2,0x5
ffffffffc020157a:	5ea60613          	addi	a2,a2,1514 # ffffffffc0206b60 <commands+0x410>
ffffffffc020157e:	12000593          	li	a1,288
ffffffffc0201582:	00006517          	auipc	a0,0x6
ffffffffc0201586:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0206e70 <commands+0x720>
ffffffffc020158a:	c7ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc020158e:	00006697          	auipc	a3,0x6
ffffffffc0201592:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0206fb8 <commands+0x868>
ffffffffc0201596:	00005617          	auipc	a2,0x5
ffffffffc020159a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0206b60 <commands+0x410>
ffffffffc020159e:	12c00593          	li	a1,300
ffffffffc02015a2:	00006517          	auipc	a0,0x6
ffffffffc02015a6:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0206e70 <commands+0x720>
ffffffffc02015aa:	c5ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc02015ae:	00006697          	auipc	a3,0x6
ffffffffc02015b2:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0206fa8 <commands+0x858>
ffffffffc02015b6:	00005617          	auipc	a2,0x5
ffffffffc02015ba:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206b60 <commands+0x410>
ffffffffc02015be:	12a00593          	li	a1,298
ffffffffc02015c2:	00006517          	auipc	a0,0x6
ffffffffc02015c6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0206e70 <commands+0x720>
ffffffffc02015ca:	c3ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02015ce:	00006697          	auipc	a3,0x6
ffffffffc02015d2:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0206f98 <commands+0x848>
ffffffffc02015d6:	00005617          	auipc	a2,0x5
ffffffffc02015da:	58a60613          	addi	a2,a2,1418 # ffffffffc0206b60 <commands+0x410>
ffffffffc02015de:	12800593          	li	a1,296
ffffffffc02015e2:	00006517          	auipc	a0,0x6
ffffffffc02015e6:	88e50513          	addi	a0,a0,-1906 # ffffffffc0206e70 <commands+0x720>
ffffffffc02015ea:	c1ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc02015ee:	00006697          	auipc	a3,0x6
ffffffffc02015f2:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0206fd8 <commands+0x888>
ffffffffc02015f6:	00005617          	auipc	a2,0x5
ffffffffc02015fa:	56a60613          	addi	a2,a2,1386 # ffffffffc0206b60 <commands+0x410>
ffffffffc02015fe:	13000593          	li	a1,304
ffffffffc0201602:	00006517          	auipc	a0,0x6
ffffffffc0201606:	86e50513          	addi	a0,a0,-1938 # ffffffffc0206e70 <commands+0x720>
ffffffffc020160a:	bfffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc020160e:	00006697          	auipc	a3,0x6
ffffffffc0201612:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0206fc8 <commands+0x878>
ffffffffc0201616:	00005617          	auipc	a2,0x5
ffffffffc020161a:	54a60613          	addi	a2,a2,1354 # ffffffffc0206b60 <commands+0x410>
ffffffffc020161e:	12e00593          	li	a1,302
ffffffffc0201622:	00006517          	auipc	a0,0x6
ffffffffc0201626:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206e70 <commands+0x720>
ffffffffc020162a:	bdffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020162e:	00006697          	auipc	a3,0x6
ffffffffc0201632:	a7a68693          	addi	a3,a3,-1414 # ffffffffc02070a8 <commands+0x958>
ffffffffc0201636:	00005617          	auipc	a2,0x5
ffffffffc020163a:	52a60613          	addi	a2,a2,1322 # ffffffffc0206b60 <commands+0x410>
ffffffffc020163e:	14b00593          	li	a1,331
ffffffffc0201642:	00006517          	auipc	a0,0x6
ffffffffc0201646:	82e50513          	addi	a0,a0,-2002 # ffffffffc0206e70 <commands+0x720>
ffffffffc020164a:	bbffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc020164e:	00006697          	auipc	a3,0x6
ffffffffc0201652:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0206ef8 <commands+0x7a8>
ffffffffc0201656:	00005617          	auipc	a2,0x5
ffffffffc020165a:	50a60613          	addi	a2,a2,1290 # ffffffffc0206b60 <commands+0x410>
ffffffffc020165e:	10c00593          	li	a1,268
ffffffffc0201662:	00006517          	auipc	a0,0x6
ffffffffc0201666:	80e50513          	addi	a0,a0,-2034 # ffffffffc0206e70 <commands+0x720>
ffffffffc020166a:	b9ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020166e:	00006697          	auipc	a3,0x6
ffffffffc0201672:	aea68693          	addi	a3,a3,-1302 # ffffffffc0207158 <commands+0xa08>
ffffffffc0201676:	00005617          	auipc	a2,0x5
ffffffffc020167a:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206b60 <commands+0x410>
ffffffffc020167e:	17000593          	li	a1,368
ffffffffc0201682:	00005517          	auipc	a0,0x5
ffffffffc0201686:	7ee50513          	addi	a0,a0,2030 # ffffffffc0206e70 <commands+0x720>
ffffffffc020168a:	b7ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020168e:	00006617          	auipc	a2,0x6
ffffffffc0201692:	aa260613          	addi	a2,a2,-1374 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0201696:	06900593          	li	a1,105
ffffffffc020169a:	00006517          	auipc	a0,0x6
ffffffffc020169e:	a8650513          	addi	a0,a0,-1402 # ffffffffc0207120 <commands+0x9d0>
ffffffffc02016a2:	b67fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02016a6:	00006697          	auipc	a3,0x6
ffffffffc02016aa:	a1a68693          	addi	a3,a3,-1510 # ffffffffc02070c0 <commands+0x970>
ffffffffc02016ae:	00005617          	auipc	a2,0x5
ffffffffc02016b2:	4b260613          	addi	a2,a2,1202 # ffffffffc0206b60 <commands+0x410>
ffffffffc02016b6:	14f00593          	li	a1,335
ffffffffc02016ba:	00005517          	auipc	a0,0x5
ffffffffc02016be:	7b650513          	addi	a0,a0,1974 # ffffffffc0206e70 <commands+0x720>
ffffffffc02016c2:	b47fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016c6:	00006697          	auipc	a3,0x6
ffffffffc02016ca:	a0a68693          	addi	a3,a3,-1526 # ffffffffc02070d0 <commands+0x980>
ffffffffc02016ce:	00005617          	auipc	a2,0x5
ffffffffc02016d2:	49260613          	addi	a2,a2,1170 # ffffffffc0206b60 <commands+0x410>
ffffffffc02016d6:	15700593          	li	a1,343
ffffffffc02016da:	00005517          	auipc	a0,0x5
ffffffffc02016de:	79650513          	addi	a0,a0,1942 # ffffffffc0206e70 <commands+0x720>
ffffffffc02016e2:	b27fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016e6:	00006617          	auipc	a2,0x6
ffffffffc02016ea:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0207100 <commands+0x9b0>
ffffffffc02016ee:	06200593          	li	a1,98
ffffffffc02016f2:	00006517          	auipc	a0,0x6
ffffffffc02016f6:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0207120 <commands+0x9d0>
ffffffffc02016fa:	b0ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc02016fe:	00006697          	auipc	a3,0x6
ffffffffc0201702:	9f268693          	addi	a3,a3,-1550 # ffffffffc02070f0 <commands+0x9a0>
ffffffffc0201706:	00005617          	auipc	a2,0x5
ffffffffc020170a:	45a60613          	addi	a2,a2,1114 # ffffffffc0206b60 <commands+0x410>
ffffffffc020170e:	16300593          	li	a1,355
ffffffffc0201712:	00005517          	auipc	a0,0x5
ffffffffc0201716:	75e50513          	addi	a0,a0,1886 # ffffffffc0206e70 <commands+0x720>
ffffffffc020171a:	aeffe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020171e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020171e:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201720:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201722:	f022                	sd	s0,32(sp)
ffffffffc0201724:	ec26                	sd	s1,24(sp)
ffffffffc0201726:	f406                	sd	ra,40(sp)
ffffffffc0201728:	e84a                	sd	s2,16(sp)
ffffffffc020172a:	8432                	mv	s0,a2
ffffffffc020172c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020172e:	f8eff0ef          	jal	ra,ffffffffc0200ebc <find_vma>

    pgfault_num++;
ffffffffc0201732:	000b1797          	auipc	a5,0xb1
ffffffffc0201736:	2e67a783          	lw	a5,742(a5) # ffffffffc02b2a18 <pgfault_num>
ffffffffc020173a:	2785                	addiw	a5,a5,1
ffffffffc020173c:	000b1717          	auipc	a4,0xb1
ffffffffc0201740:	2cf72e23          	sw	a5,732(a4) # ffffffffc02b2a18 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201744:	c541                	beqz	a0,ffffffffc02017cc <do_pgfault+0xae>
ffffffffc0201746:	651c                	ld	a5,8(a0)
ffffffffc0201748:	08f46263          	bltu	s0,a5,ffffffffc02017cc <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020174c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020174e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201750:	8b89                	andi	a5,a5,2
ffffffffc0201752:	ebb9                	bnez	a5,ffffffffc02017a8 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201754:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201756:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201758:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020175a:	4605                	li	a2,1
ffffffffc020175c:	85a2                	mv	a1,s0
ffffffffc020175e:	5f5010ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0201762:	c551                	beqz	a0,ffffffffc02017ee <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201764:	610c                	ld	a1,0(a0)
ffffffffc0201766:	c1b9                	beqz	a1,ffffffffc02017ac <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201768:	000b1797          	auipc	a5,0xb1
ffffffffc020176c:	2d07a783          	lw	a5,720(a5) # ffffffffc02b2a38 <swap_init_ok>
ffffffffc0201770:	c7bd                	beqz	a5,ffffffffc02017de <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0201772:	85a2                	mv	a1,s0
ffffffffc0201774:	0030                	addi	a2,sp,8
ffffffffc0201776:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201778:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc020177a:	16c010ef          	jal	ra,ffffffffc02028e6 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020177e:	65a2                	ld	a1,8(sp)
ffffffffc0201780:	6c88                	ld	a0,24(s1)
ffffffffc0201782:	86ca                	mv	a3,s2
ffffffffc0201784:	8622                	mv	a2,s0
ffffffffc0201786:	5f2020ef          	jal	ra,ffffffffc0203d78 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc020178a:	6622                	ld	a2,8(sp)
ffffffffc020178c:	4685                	li	a3,1
ffffffffc020178e:	85a2                	mv	a1,s0
ffffffffc0201790:	8526                	mv	a0,s1
ffffffffc0201792:	034010ef          	jal	ra,ffffffffc02027c6 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0201796:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0201798:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc020179a:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc020179c:	70a2                	ld	ra,40(sp)
ffffffffc020179e:	7402                	ld	s0,32(sp)
ffffffffc02017a0:	64e2                	ld	s1,24(sp)
ffffffffc02017a2:	6942                	ld	s2,16(sp)
ffffffffc02017a4:	6145                	addi	sp,sp,48
ffffffffc02017a6:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02017a8:	495d                	li	s2,23
ffffffffc02017aa:	b76d                	j	ffffffffc0201754 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017ac:	6c88                	ld	a0,24(s1)
ffffffffc02017ae:	864a                	mv	a2,s2
ffffffffc02017b0:	85a2                	mv	a1,s0
ffffffffc02017b2:	25c030ef          	jal	ra,ffffffffc0204a0e <pgdir_alloc_page>
ffffffffc02017b6:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02017b8:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017ba:	f3ed                	bnez	a5,ffffffffc020179c <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02017bc:	00006517          	auipc	a0,0x6
ffffffffc02017c0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0207218 <commands+0xac8>
ffffffffc02017c4:	909fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017c8:	5571                	li	a0,-4
            goto failed;
ffffffffc02017ca:	bfc9                	j	ffffffffc020179c <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02017cc:	85a2                	mv	a1,s0
ffffffffc02017ce:	00006517          	auipc	a0,0x6
ffffffffc02017d2:	9fa50513          	addi	a0,a0,-1542 # ffffffffc02071c8 <commands+0xa78>
ffffffffc02017d6:	8f7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02017da:	5575                	li	a0,-3
        goto failed;
ffffffffc02017dc:	b7c1                	j	ffffffffc020179c <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02017de:	00006517          	auipc	a0,0x6
ffffffffc02017e2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0207240 <commands+0xaf0>
ffffffffc02017e6:	8e7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017ea:	5571                	li	a0,-4
            goto failed;
ffffffffc02017ec:	bf45                	j	ffffffffc020179c <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02017ee:	00006517          	auipc	a0,0x6
ffffffffc02017f2:	a0a50513          	addi	a0,a0,-1526 # ffffffffc02071f8 <commands+0xaa8>
ffffffffc02017f6:	8d7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017fa:	5571                	li	a0,-4
        goto failed;
ffffffffc02017fc:	b745                	j	ffffffffc020179c <do_pgfault+0x7e>

ffffffffc02017fe <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc02017fe:	7179                	addi	sp,sp,-48
ffffffffc0201800:	f022                	sd	s0,32(sp)
ffffffffc0201802:	f406                	sd	ra,40(sp)
ffffffffc0201804:	ec26                	sd	s1,24(sp)
ffffffffc0201806:	e84a                	sd	s2,16(sp)
ffffffffc0201808:	e44e                	sd	s3,8(sp)
ffffffffc020180a:	e052                	sd	s4,0(sp)
ffffffffc020180c:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc020180e:	c135                	beqz	a0,ffffffffc0201872 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201810:	002007b7          	lui	a5,0x200
ffffffffc0201814:	04f5e663          	bltu	a1,a5,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201818:	00c584b3          	add	s1,a1,a2
ffffffffc020181c:	0495f263          	bgeu	a1,s1,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201820:	4785                	li	a5,1
ffffffffc0201822:	07fe                	slli	a5,a5,0x1f
ffffffffc0201824:	0297ee63          	bltu	a5,s1,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201828:	892a                	mv	s2,a0
ffffffffc020182a:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020182c:	6a05                	lui	s4,0x1
ffffffffc020182e:	a821                	j	ffffffffc0201846 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201830:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201834:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201836:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201838:	c685                	beqz	a3,ffffffffc0201860 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020183a:	c399                	beqz	a5,ffffffffc0201840 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020183c:	02e46263          	bltu	s0,a4,ffffffffc0201860 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201840:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0201842:	04947663          	bgeu	s0,s1,ffffffffc020188e <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0201846:	85a2                	mv	a1,s0
ffffffffc0201848:	854a                	mv	a0,s2
ffffffffc020184a:	e72ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc020184e:	c909                	beqz	a0,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201850:	6518                	ld	a4,8(a0)
ffffffffc0201852:	00e46763          	bltu	s0,a4,ffffffffc0201860 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201856:	4d1c                	lw	a5,24(a0)
ffffffffc0201858:	fc099ce3          	bnez	s3,ffffffffc0201830 <user_mem_check+0x32>
ffffffffc020185c:	8b85                	andi	a5,a5,1
ffffffffc020185e:	f3ed                	bnez	a5,ffffffffc0201840 <user_mem_check+0x42>
            return 0;
ffffffffc0201860:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0201862:	70a2                	ld	ra,40(sp)
ffffffffc0201864:	7402                	ld	s0,32(sp)
ffffffffc0201866:	64e2                	ld	s1,24(sp)
ffffffffc0201868:	6942                	ld	s2,16(sp)
ffffffffc020186a:	69a2                	ld	s3,8(sp)
ffffffffc020186c:	6a02                	ld	s4,0(sp)
ffffffffc020186e:	6145                	addi	sp,sp,48
ffffffffc0201870:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201872:	c02007b7          	lui	a5,0xc0200
ffffffffc0201876:	4501                	li	a0,0
ffffffffc0201878:	fef5e5e3          	bltu	a1,a5,ffffffffc0201862 <user_mem_check+0x64>
ffffffffc020187c:	962e                	add	a2,a2,a1
ffffffffc020187e:	fec5f2e3          	bgeu	a1,a2,ffffffffc0201862 <user_mem_check+0x64>
ffffffffc0201882:	c8000537          	lui	a0,0xc8000
ffffffffc0201886:	0505                	addi	a0,a0,1
ffffffffc0201888:	00a63533          	sltu	a0,a2,a0
ffffffffc020188c:	bfd9                	j	ffffffffc0201862 <user_mem_check+0x64>
        return 1;
ffffffffc020188e:	4505                	li	a0,1
ffffffffc0201890:	bfc9                	j	ffffffffc0201862 <user_mem_check+0x64>

ffffffffc0201892 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0201892:	000ad797          	auipc	a5,0xad
ffffffffc0201896:	09e78793          	addi	a5,a5,158 # ffffffffc02ae930 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020189a:	f51c                	sd	a5,40(a0)
ffffffffc020189c:	e79c                	sd	a5,8(a5)
ffffffffc020189e:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02018a0:	4501                	li	a0,0
ffffffffc02018a2:	8082                	ret

ffffffffc02018a4 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02018a4:	4501                	li	a0,0
ffffffffc02018a6:	8082                	ret

ffffffffc02018a8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02018a8:	4501                	li	a0,0
ffffffffc02018aa:	8082                	ret

ffffffffc02018ac <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02018ac:	4501                	li	a0,0
ffffffffc02018ae:	8082                	ret

ffffffffc02018b0 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02018b0:	711d                	addi	sp,sp,-96
ffffffffc02018b2:	fc4e                	sd	s3,56(sp)
ffffffffc02018b4:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02018b6:	00006517          	auipc	a0,0x6
ffffffffc02018ba:	9b250513          	addi	a0,a0,-1614 # ffffffffc0207268 <commands+0xb18>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02018be:	698d                	lui	s3,0x3
ffffffffc02018c0:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02018c2:	e0ca                	sd	s2,64(sp)
ffffffffc02018c4:	ec86                	sd	ra,88(sp)
ffffffffc02018c6:	e8a2                	sd	s0,80(sp)
ffffffffc02018c8:	e4a6                	sd	s1,72(sp)
ffffffffc02018ca:	f456                	sd	s5,40(sp)
ffffffffc02018cc:	f05a                	sd	s6,32(sp)
ffffffffc02018ce:	ec5e                	sd	s7,24(sp)
ffffffffc02018d0:	e862                	sd	s8,16(sp)
ffffffffc02018d2:	e466                	sd	s9,8(sp)
ffffffffc02018d4:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02018d6:	ff6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02018da:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bd8>
    assert(pgfault_num==4);
ffffffffc02018de:	000b1917          	auipc	s2,0xb1
ffffffffc02018e2:	13a92903          	lw	s2,314(s2) # ffffffffc02b2a18 <pgfault_num>
ffffffffc02018e6:	4791                	li	a5,4
ffffffffc02018e8:	14f91e63          	bne	s2,a5,ffffffffc0201a44 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02018ec:	00006517          	auipc	a0,0x6
ffffffffc02018f0:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02072b8 <commands+0xb68>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02018f4:	6a85                	lui	s5,0x1
ffffffffc02018f6:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02018f8:	fd4fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02018fc:	000b1417          	auipc	s0,0xb1
ffffffffc0201900:	11c40413          	addi	s0,s0,284 # ffffffffc02b2a18 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201904:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
    assert(pgfault_num==4);
ffffffffc0201908:	4004                	lw	s1,0(s0)
ffffffffc020190a:	2481                	sext.w	s1,s1
ffffffffc020190c:	2b249c63          	bne	s1,s2,ffffffffc0201bc4 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201910:	00006517          	auipc	a0,0x6
ffffffffc0201914:	9d050513          	addi	a0,a0,-1584 # ffffffffc02072e0 <commands+0xb90>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201918:	6b91                	lui	s7,0x4
ffffffffc020191a:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020191c:	fb0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201920:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bd8>
    assert(pgfault_num==4);
ffffffffc0201924:	00042903          	lw	s2,0(s0)
ffffffffc0201928:	2901                	sext.w	s2,s2
ffffffffc020192a:	26991d63          	bne	s2,s1,ffffffffc0201ba4 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020192e:	00006517          	auipc	a0,0x6
ffffffffc0201932:	9da50513          	addi	a0,a0,-1574 # ffffffffc0207308 <commands+0xbb8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201936:	6c89                	lui	s9,0x2
ffffffffc0201938:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020193a:	f92fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020193e:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bd8>
    assert(pgfault_num==4);
ffffffffc0201942:	401c                	lw	a5,0(s0)
ffffffffc0201944:	2781                	sext.w	a5,a5
ffffffffc0201946:	23279f63          	bne	a5,s2,ffffffffc0201b84 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020194a:	00006517          	auipc	a0,0x6
ffffffffc020194e:	9e650513          	addi	a0,a0,-1562 # ffffffffc0207330 <commands+0xbe0>
ffffffffc0201952:	f7afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201956:	6795                	lui	a5,0x5
ffffffffc0201958:	4739                	li	a4,14
ffffffffc020195a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bd8>
    assert(pgfault_num==5);
ffffffffc020195e:	4004                	lw	s1,0(s0)
ffffffffc0201960:	4795                	li	a5,5
ffffffffc0201962:	2481                	sext.w	s1,s1
ffffffffc0201964:	20f49063          	bne	s1,a5,ffffffffc0201b64 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201968:	00006517          	auipc	a0,0x6
ffffffffc020196c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0207308 <commands+0xbb8>
ffffffffc0201970:	f5cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201974:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201978:	401c                	lw	a5,0(s0)
ffffffffc020197a:	2781                	sext.w	a5,a5
ffffffffc020197c:	1c979463          	bne	a5,s1,ffffffffc0201b44 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201980:	00006517          	auipc	a0,0x6
ffffffffc0201984:	93850513          	addi	a0,a0,-1736 # ffffffffc02072b8 <commands+0xb68>
ffffffffc0201988:	f44fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020198c:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201990:	401c                	lw	a5,0(s0)
ffffffffc0201992:	4719                	li	a4,6
ffffffffc0201994:	2781                	sext.w	a5,a5
ffffffffc0201996:	18e79763          	bne	a5,a4,ffffffffc0201b24 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020199a:	00006517          	auipc	a0,0x6
ffffffffc020199e:	96e50513          	addi	a0,a0,-1682 # ffffffffc0207308 <commands+0xbb8>
ffffffffc02019a2:	f2afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02019a6:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc02019aa:	401c                	lw	a5,0(s0)
ffffffffc02019ac:	471d                	li	a4,7
ffffffffc02019ae:	2781                	sext.w	a5,a5
ffffffffc02019b0:	14e79a63          	bne	a5,a4,ffffffffc0201b04 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02019b4:	00006517          	auipc	a0,0x6
ffffffffc02019b8:	8b450513          	addi	a0,a0,-1868 # ffffffffc0207268 <commands+0xb18>
ffffffffc02019bc:	f10fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02019c0:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02019c4:	401c                	lw	a5,0(s0)
ffffffffc02019c6:	4721                	li	a4,8
ffffffffc02019c8:	2781                	sext.w	a5,a5
ffffffffc02019ca:	10e79d63          	bne	a5,a4,ffffffffc0201ae4 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02019ce:	00006517          	auipc	a0,0x6
ffffffffc02019d2:	91250513          	addi	a0,a0,-1774 # ffffffffc02072e0 <commands+0xb90>
ffffffffc02019d6:	ef6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02019da:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02019de:	401c                	lw	a5,0(s0)
ffffffffc02019e0:	4725                	li	a4,9
ffffffffc02019e2:	2781                	sext.w	a5,a5
ffffffffc02019e4:	0ee79063          	bne	a5,a4,ffffffffc0201ac4 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02019e8:	00006517          	auipc	a0,0x6
ffffffffc02019ec:	94850513          	addi	a0,a0,-1720 # ffffffffc0207330 <commands+0xbe0>
ffffffffc02019f0:	edcfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02019f4:	6795                	lui	a5,0x5
ffffffffc02019f6:	4739                	li	a4,14
ffffffffc02019f8:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bd8>
    assert(pgfault_num==10);
ffffffffc02019fc:	4004                	lw	s1,0(s0)
ffffffffc02019fe:	47a9                	li	a5,10
ffffffffc0201a00:	2481                	sext.w	s1,s1
ffffffffc0201a02:	0af49163          	bne	s1,a5,ffffffffc0201aa4 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201a06:	00006517          	auipc	a0,0x6
ffffffffc0201a0a:	8b250513          	addi	a0,a0,-1870 # ffffffffc02072b8 <commands+0xb68>
ffffffffc0201a0e:	ebefe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201a12:	6785                	lui	a5,0x1
ffffffffc0201a14:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc0201a18:	06979663          	bne	a5,s1,ffffffffc0201a84 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201a1c:	401c                	lw	a5,0(s0)
ffffffffc0201a1e:	472d                	li	a4,11
ffffffffc0201a20:	2781                	sext.w	a5,a5
ffffffffc0201a22:	04e79163          	bne	a5,a4,ffffffffc0201a64 <_fifo_check_swap+0x1b4>
}
ffffffffc0201a26:	60e6                	ld	ra,88(sp)
ffffffffc0201a28:	6446                	ld	s0,80(sp)
ffffffffc0201a2a:	64a6                	ld	s1,72(sp)
ffffffffc0201a2c:	6906                	ld	s2,64(sp)
ffffffffc0201a2e:	79e2                	ld	s3,56(sp)
ffffffffc0201a30:	7a42                	ld	s4,48(sp)
ffffffffc0201a32:	7aa2                	ld	s5,40(sp)
ffffffffc0201a34:	7b02                	ld	s6,32(sp)
ffffffffc0201a36:	6be2                	ld	s7,24(sp)
ffffffffc0201a38:	6c42                	ld	s8,16(sp)
ffffffffc0201a3a:	6ca2                	ld	s9,8(sp)
ffffffffc0201a3c:	6d02                	ld	s10,0(sp)
ffffffffc0201a3e:	4501                	li	a0,0
ffffffffc0201a40:	6125                	addi	sp,sp,96
ffffffffc0201a42:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201a44:	00006697          	auipc	a3,0x6
ffffffffc0201a48:	84c68693          	addi	a3,a3,-1972 # ffffffffc0207290 <commands+0xb40>
ffffffffc0201a4c:	00005617          	auipc	a2,0x5
ffffffffc0201a50:	11460613          	addi	a2,a2,276 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201a54:	05100593          	li	a1,81
ffffffffc0201a58:	00006517          	auipc	a0,0x6
ffffffffc0201a5c:	84850513          	addi	a0,a0,-1976 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201a60:	fa8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0201a64:	00006697          	auipc	a3,0x6
ffffffffc0201a68:	97c68693          	addi	a3,a3,-1668 # ffffffffc02073e0 <commands+0xc90>
ffffffffc0201a6c:	00005617          	auipc	a2,0x5
ffffffffc0201a70:	0f460613          	addi	a2,a2,244 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201a74:	07300593          	li	a1,115
ffffffffc0201a78:	00006517          	auipc	a0,0x6
ffffffffc0201a7c:	82850513          	addi	a0,a0,-2008 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201a80:	f88fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201a84:	00006697          	auipc	a3,0x6
ffffffffc0201a88:	93468693          	addi	a3,a3,-1740 # ffffffffc02073b8 <commands+0xc68>
ffffffffc0201a8c:	00005617          	auipc	a2,0x5
ffffffffc0201a90:	0d460613          	addi	a2,a2,212 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201a94:	07100593          	li	a1,113
ffffffffc0201a98:	00006517          	auipc	a0,0x6
ffffffffc0201a9c:	80850513          	addi	a0,a0,-2040 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201aa0:	f68fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0201aa4:	00006697          	auipc	a3,0x6
ffffffffc0201aa8:	90468693          	addi	a3,a3,-1788 # ffffffffc02073a8 <commands+0xc58>
ffffffffc0201aac:	00005617          	auipc	a2,0x5
ffffffffc0201ab0:	0b460613          	addi	a2,a2,180 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201ab4:	06f00593          	li	a1,111
ffffffffc0201ab8:	00005517          	auipc	a0,0x5
ffffffffc0201abc:	7e850513          	addi	a0,a0,2024 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201ac0:	f48fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc0201ac4:	00006697          	auipc	a3,0x6
ffffffffc0201ac8:	8d468693          	addi	a3,a3,-1836 # ffffffffc0207398 <commands+0xc48>
ffffffffc0201acc:	00005617          	auipc	a2,0x5
ffffffffc0201ad0:	09460613          	addi	a2,a2,148 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201ad4:	06c00593          	li	a1,108
ffffffffc0201ad8:	00005517          	auipc	a0,0x5
ffffffffc0201adc:	7c850513          	addi	a0,a0,1992 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201ae0:	f28fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc0201ae4:	00006697          	auipc	a3,0x6
ffffffffc0201ae8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0207388 <commands+0xc38>
ffffffffc0201aec:	00005617          	auipc	a2,0x5
ffffffffc0201af0:	07460613          	addi	a2,a2,116 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201af4:	06900593          	li	a1,105
ffffffffc0201af8:	00005517          	auipc	a0,0x5
ffffffffc0201afc:	7a850513          	addi	a0,a0,1960 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201b00:	f08fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc0201b04:	00006697          	auipc	a3,0x6
ffffffffc0201b08:	87468693          	addi	a3,a3,-1932 # ffffffffc0207378 <commands+0xc28>
ffffffffc0201b0c:	00005617          	auipc	a2,0x5
ffffffffc0201b10:	05460613          	addi	a2,a2,84 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201b14:	06600593          	li	a1,102
ffffffffc0201b18:	00005517          	auipc	a0,0x5
ffffffffc0201b1c:	78850513          	addi	a0,a0,1928 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201b20:	ee8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0201b24:	00006697          	auipc	a3,0x6
ffffffffc0201b28:	84468693          	addi	a3,a3,-1980 # ffffffffc0207368 <commands+0xc18>
ffffffffc0201b2c:	00005617          	auipc	a2,0x5
ffffffffc0201b30:	03460613          	addi	a2,a2,52 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201b34:	06300593          	li	a1,99
ffffffffc0201b38:	00005517          	auipc	a0,0x5
ffffffffc0201b3c:	76850513          	addi	a0,a0,1896 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201b40:	ec8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201b44:	00006697          	auipc	a3,0x6
ffffffffc0201b48:	81468693          	addi	a3,a3,-2028 # ffffffffc0207358 <commands+0xc08>
ffffffffc0201b4c:	00005617          	auipc	a2,0x5
ffffffffc0201b50:	01460613          	addi	a2,a2,20 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201b54:	06000593          	li	a1,96
ffffffffc0201b58:	00005517          	auipc	a0,0x5
ffffffffc0201b5c:	74850513          	addi	a0,a0,1864 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201b60:	ea8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201b64:	00005697          	auipc	a3,0x5
ffffffffc0201b68:	7f468693          	addi	a3,a3,2036 # ffffffffc0207358 <commands+0xc08>
ffffffffc0201b6c:	00005617          	auipc	a2,0x5
ffffffffc0201b70:	ff460613          	addi	a2,a2,-12 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201b74:	05d00593          	li	a1,93
ffffffffc0201b78:	00005517          	auipc	a0,0x5
ffffffffc0201b7c:	72850513          	addi	a0,a0,1832 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201b80:	e88fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201b84:	00005697          	auipc	a3,0x5
ffffffffc0201b88:	70c68693          	addi	a3,a3,1804 # ffffffffc0207290 <commands+0xb40>
ffffffffc0201b8c:	00005617          	auipc	a2,0x5
ffffffffc0201b90:	fd460613          	addi	a2,a2,-44 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201b94:	05a00593          	li	a1,90
ffffffffc0201b98:	00005517          	auipc	a0,0x5
ffffffffc0201b9c:	70850513          	addi	a0,a0,1800 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201ba0:	e68fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201ba4:	00005697          	auipc	a3,0x5
ffffffffc0201ba8:	6ec68693          	addi	a3,a3,1772 # ffffffffc0207290 <commands+0xb40>
ffffffffc0201bac:	00005617          	auipc	a2,0x5
ffffffffc0201bb0:	fb460613          	addi	a2,a2,-76 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201bb4:	05700593          	li	a1,87
ffffffffc0201bb8:	00005517          	auipc	a0,0x5
ffffffffc0201bbc:	6e850513          	addi	a0,a0,1768 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201bc0:	e48fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201bc4:	00005697          	auipc	a3,0x5
ffffffffc0201bc8:	6cc68693          	addi	a3,a3,1740 # ffffffffc0207290 <commands+0xb40>
ffffffffc0201bcc:	00005617          	auipc	a2,0x5
ffffffffc0201bd0:	f9460613          	addi	a2,a2,-108 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201bd4:	05400593          	li	a1,84
ffffffffc0201bd8:	00005517          	auipc	a0,0x5
ffffffffc0201bdc:	6c850513          	addi	a0,a0,1736 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201be0:	e28fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201be4 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201be4:	751c                	ld	a5,40(a0)
{
ffffffffc0201be6:	1141                	addi	sp,sp,-16
ffffffffc0201be8:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201bea:	cf91                	beqz	a5,ffffffffc0201c06 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201bec:	ee0d                	bnez	a2,ffffffffc0201c26 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201bee:	679c                	ld	a5,8(a5)
}
ffffffffc0201bf0:	60a2                	ld	ra,8(sp)
ffffffffc0201bf2:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201bf4:	6394                	ld	a3,0(a5)
ffffffffc0201bf6:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201bf8:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201bfc:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201bfe:	e314                	sd	a3,0(a4)
ffffffffc0201c00:	e19c                	sd	a5,0(a1)
}
ffffffffc0201c02:	0141                	addi	sp,sp,16
ffffffffc0201c04:	8082                	ret
         assert(head != NULL);
ffffffffc0201c06:	00005697          	auipc	a3,0x5
ffffffffc0201c0a:	7ea68693          	addi	a3,a3,2026 # ffffffffc02073f0 <commands+0xca0>
ffffffffc0201c0e:	00005617          	auipc	a2,0x5
ffffffffc0201c12:	f5260613          	addi	a2,a2,-174 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201c16:	04100593          	li	a1,65
ffffffffc0201c1a:	00005517          	auipc	a0,0x5
ffffffffc0201c1e:	68650513          	addi	a0,a0,1670 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201c22:	de6fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc0201c26:	00005697          	auipc	a3,0x5
ffffffffc0201c2a:	7da68693          	addi	a3,a3,2010 # ffffffffc0207400 <commands+0xcb0>
ffffffffc0201c2e:	00005617          	auipc	a2,0x5
ffffffffc0201c32:	f3260613          	addi	a2,a2,-206 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201c36:	04200593          	li	a1,66
ffffffffc0201c3a:	00005517          	auipc	a0,0x5
ffffffffc0201c3e:	66650513          	addi	a0,a0,1638 # ffffffffc02072a0 <commands+0xb50>
ffffffffc0201c42:	dc6fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201c46 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201c46:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201c48:	cb91                	beqz	a5,ffffffffc0201c5c <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201c4a:	6394                	ld	a3,0(a5)
ffffffffc0201c4c:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0201c50:	e398                	sd	a4,0(a5)
ffffffffc0201c52:	e698                	sd	a4,8(a3)
}
ffffffffc0201c54:	4501                	li	a0,0
    elm->next = next;
ffffffffc0201c56:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0201c58:	f614                	sd	a3,40(a2)
ffffffffc0201c5a:	8082                	ret
{
ffffffffc0201c5c:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201c5e:	00005697          	auipc	a3,0x5
ffffffffc0201c62:	7b268693          	addi	a3,a3,1970 # ffffffffc0207410 <commands+0xcc0>
ffffffffc0201c66:	00005617          	auipc	a2,0x5
ffffffffc0201c6a:	efa60613          	addi	a2,a2,-262 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201c6e:	03200593          	li	a1,50
ffffffffc0201c72:	00005517          	auipc	a0,0x5
ffffffffc0201c76:	62e50513          	addi	a0,a0,1582 # ffffffffc02072a0 <commands+0xb50>
{
ffffffffc0201c7a:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201c7c:	d8cfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201c80 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201c80:	c94d                	beqz	a0,ffffffffc0201d32 <slob_free+0xb2>
{
ffffffffc0201c82:	1141                	addi	sp,sp,-16
ffffffffc0201c84:	e022                	sd	s0,0(sp)
ffffffffc0201c86:	e406                	sd	ra,8(sp)
ffffffffc0201c88:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201c8a:	e9c1                	bnez	a1,ffffffffc0201d1a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c8c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c90:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c92:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c94:	ebd9                	bnez	a5,ffffffffc0201d2a <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c96:	000a6617          	auipc	a2,0xa6
ffffffffc0201c9a:	88a60613          	addi	a2,a2,-1910 # ffffffffc02a7520 <slobfree>
ffffffffc0201c9e:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ca0:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ca2:	679c                	ld	a5,8(a5)
ffffffffc0201ca4:	02877a63          	bgeu	a4,s0,ffffffffc0201cd8 <slob_free+0x58>
ffffffffc0201ca8:	00f46463          	bltu	s0,a5,ffffffffc0201cb0 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201cac:	fef76ae3          	bltu	a4,a5,ffffffffc0201ca0 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201cb0:	400c                	lw	a1,0(s0)
ffffffffc0201cb2:	00459693          	slli	a3,a1,0x4
ffffffffc0201cb6:	96a2                	add	a3,a3,s0
ffffffffc0201cb8:	02d78a63          	beq	a5,a3,ffffffffc0201cec <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201cbc:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201cbe:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201cc0:	00469793          	slli	a5,a3,0x4
ffffffffc0201cc4:	97ba                	add	a5,a5,a4
ffffffffc0201cc6:	02f40e63          	beq	s0,a5,ffffffffc0201d02 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201cca:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201ccc:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201cce:	e129                	bnez	a0,ffffffffc0201d10 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201cd0:	60a2                	ld	ra,8(sp)
ffffffffc0201cd2:	6402                	ld	s0,0(sp)
ffffffffc0201cd4:	0141                	addi	sp,sp,16
ffffffffc0201cd6:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201cd8:	fcf764e3          	bltu	a4,a5,ffffffffc0201ca0 <slob_free+0x20>
ffffffffc0201cdc:	fcf472e3          	bgeu	s0,a5,ffffffffc0201ca0 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201ce0:	400c                	lw	a1,0(s0)
ffffffffc0201ce2:	00459693          	slli	a3,a1,0x4
ffffffffc0201ce6:	96a2                	add	a3,a3,s0
ffffffffc0201ce8:	fcd79ae3          	bne	a5,a3,ffffffffc0201cbc <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201cec:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201cee:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201cf0:	9db5                	addw	a1,a1,a3
ffffffffc0201cf2:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201cf4:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201cf6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201cf8:	00469793          	slli	a5,a3,0x4
ffffffffc0201cfc:	97ba                	add	a5,a5,a4
ffffffffc0201cfe:	fcf416e3          	bne	s0,a5,ffffffffc0201cca <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201d02:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201d04:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201d06:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201d08:	9ebd                	addw	a3,a3,a5
ffffffffc0201d0a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201d0c:	e70c                	sd	a1,8(a4)
ffffffffc0201d0e:	d169                	beqz	a0,ffffffffc0201cd0 <slob_free+0x50>
}
ffffffffc0201d10:	6402                	ld	s0,0(sp)
ffffffffc0201d12:	60a2                	ld	ra,8(sp)
ffffffffc0201d14:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201d16:	92dfe06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201d1a:	25bd                	addiw	a1,a1,15
ffffffffc0201d1c:	8191                	srli	a1,a1,0x4
ffffffffc0201d1e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d20:	100027f3          	csrr	a5,sstatus
ffffffffc0201d24:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201d26:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d28:	d7bd                	beqz	a5,ffffffffc0201c96 <slob_free+0x16>
        intr_disable();
ffffffffc0201d2a:	91ffe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0201d2e:	4505                	li	a0,1
ffffffffc0201d30:	b79d                	j	ffffffffc0201c96 <slob_free+0x16>
ffffffffc0201d32:	8082                	ret

ffffffffc0201d34 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201d34:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201d36:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201d38:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201d3c:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201d3e:	708010ef          	jal	ra,ffffffffc0203446 <alloc_pages>
  if(!page)
ffffffffc0201d42:	c91d                	beqz	a0,ffffffffc0201d78 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201d44:	000b1697          	auipc	a3,0xb1
ffffffffc0201d48:	d146b683          	ld	a3,-748(a3) # ffffffffc02b2a58 <pages>
ffffffffc0201d4c:	8d15                	sub	a0,a0,a3
ffffffffc0201d4e:	8519                	srai	a0,a0,0x6
ffffffffc0201d50:	00007697          	auipc	a3,0x7
ffffffffc0201d54:	e186b683          	ld	a3,-488(a3) # ffffffffc0208b68 <nbase>
ffffffffc0201d58:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201d5a:	00c51793          	slli	a5,a0,0xc
ffffffffc0201d5e:	83b1                	srli	a5,a5,0xc
ffffffffc0201d60:	000b1717          	auipc	a4,0xb1
ffffffffc0201d64:	cf073703          	ld	a4,-784(a4) # ffffffffc02b2a50 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d68:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201d6a:	00e7fa63          	bgeu	a5,a4,ffffffffc0201d7e <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201d6e:	000b1697          	auipc	a3,0xb1
ffffffffc0201d72:	cfa6b683          	ld	a3,-774(a3) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0201d76:	9536                	add	a0,a0,a3
}
ffffffffc0201d78:	60a2                	ld	ra,8(sp)
ffffffffc0201d7a:	0141                	addi	sp,sp,16
ffffffffc0201d7c:	8082                	ret
ffffffffc0201d7e:	86aa                	mv	a3,a0
ffffffffc0201d80:	00005617          	auipc	a2,0x5
ffffffffc0201d84:	3b060613          	addi	a2,a2,944 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0201d88:	06900593          	li	a1,105
ffffffffc0201d8c:	00005517          	auipc	a0,0x5
ffffffffc0201d90:	39450513          	addi	a0,a0,916 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0201d94:	c74fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201d98 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201d98:	1101                	addi	sp,sp,-32
ffffffffc0201d9a:	ec06                	sd	ra,24(sp)
ffffffffc0201d9c:	e822                	sd	s0,16(sp)
ffffffffc0201d9e:	e426                	sd	s1,8(sp)
ffffffffc0201da0:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201da2:	01050713          	addi	a4,a0,16
ffffffffc0201da6:	6785                	lui	a5,0x1
ffffffffc0201da8:	0cf77363          	bgeu	a4,a5,ffffffffc0201e6e <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201dac:	00f50493          	addi	s1,a0,15
ffffffffc0201db0:	8091                	srli	s1,s1,0x4
ffffffffc0201db2:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db4:	10002673          	csrr	a2,sstatus
ffffffffc0201db8:	8a09                	andi	a2,a2,2
ffffffffc0201dba:	e25d                	bnez	a2,ffffffffc0201e60 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201dbc:	000a5917          	auipc	s2,0xa5
ffffffffc0201dc0:	76490913          	addi	s2,s2,1892 # ffffffffc02a7520 <slobfree>
ffffffffc0201dc4:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201dc8:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201dca:	4398                	lw	a4,0(a5)
ffffffffc0201dcc:	08975e63          	bge	a4,s1,ffffffffc0201e68 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201dd0:	00f68b63          	beq	a3,a5,ffffffffc0201de6 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201dd4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201dd6:	4018                	lw	a4,0(s0)
ffffffffc0201dd8:	02975a63          	bge	a4,s1,ffffffffc0201e0c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201ddc:	00093683          	ld	a3,0(s2)
ffffffffc0201de0:	87a2                	mv	a5,s0
ffffffffc0201de2:	fef699e3          	bne	a3,a5,ffffffffc0201dd4 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201de6:	ee31                	bnez	a2,ffffffffc0201e42 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201de8:	4501                	li	a0,0
ffffffffc0201dea:	f4bff0ef          	jal	ra,ffffffffc0201d34 <__slob_get_free_pages.constprop.0>
ffffffffc0201dee:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201df0:	cd05                	beqz	a0,ffffffffc0201e28 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201df2:	6585                	lui	a1,0x1
ffffffffc0201df4:	e8dff0ef          	jal	ra,ffffffffc0201c80 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201df8:	10002673          	csrr	a2,sstatus
ffffffffc0201dfc:	8a09                	andi	a2,a2,2
ffffffffc0201dfe:	ee05                	bnez	a2,ffffffffc0201e36 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201e00:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201e04:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e06:	4018                	lw	a4,0(s0)
ffffffffc0201e08:	fc974ae3          	blt	a4,s1,ffffffffc0201ddc <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201e0c:	04e48763          	beq	s1,a4,ffffffffc0201e5a <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201e10:	00449693          	slli	a3,s1,0x4
ffffffffc0201e14:	96a2                	add	a3,a3,s0
ffffffffc0201e16:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201e18:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201e1a:	9f05                	subw	a4,a4,s1
ffffffffc0201e1c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201e1e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201e20:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201e22:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201e26:	e20d                	bnez	a2,ffffffffc0201e48 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201e28:	60e2                	ld	ra,24(sp)
ffffffffc0201e2a:	8522                	mv	a0,s0
ffffffffc0201e2c:	6442                	ld	s0,16(sp)
ffffffffc0201e2e:	64a2                	ld	s1,8(sp)
ffffffffc0201e30:	6902                	ld	s2,0(sp)
ffffffffc0201e32:	6105                	addi	sp,sp,32
ffffffffc0201e34:	8082                	ret
        intr_disable();
ffffffffc0201e36:	813fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc0201e3a:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201e3e:	4605                	li	a2,1
ffffffffc0201e40:	b7d1                	j	ffffffffc0201e04 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201e42:	801fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201e46:	b74d                	j	ffffffffc0201de8 <slob_alloc.constprop.0+0x50>
ffffffffc0201e48:	ffafe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0201e4c:	60e2                	ld	ra,24(sp)
ffffffffc0201e4e:	8522                	mv	a0,s0
ffffffffc0201e50:	6442                	ld	s0,16(sp)
ffffffffc0201e52:	64a2                	ld	s1,8(sp)
ffffffffc0201e54:	6902                	ld	s2,0(sp)
ffffffffc0201e56:	6105                	addi	sp,sp,32
ffffffffc0201e58:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201e5a:	6418                	ld	a4,8(s0)
ffffffffc0201e5c:	e798                	sd	a4,8(a5)
ffffffffc0201e5e:	b7d1                	j	ffffffffc0201e22 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201e60:	fe8fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0201e64:	4605                	li	a2,1
ffffffffc0201e66:	bf99                	j	ffffffffc0201dbc <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e68:	843e                	mv	s0,a5
ffffffffc0201e6a:	87b6                	mv	a5,a3
ffffffffc0201e6c:	b745                	j	ffffffffc0201e0c <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201e6e:	00005697          	auipc	a3,0x5
ffffffffc0201e72:	5da68693          	addi	a3,a3,1498 # ffffffffc0207448 <commands+0xcf8>
ffffffffc0201e76:	00005617          	auipc	a2,0x5
ffffffffc0201e7a:	cea60613          	addi	a2,a2,-790 # ffffffffc0206b60 <commands+0x410>
ffffffffc0201e7e:	06400593          	li	a1,100
ffffffffc0201e82:	00005517          	auipc	a0,0x5
ffffffffc0201e86:	5e650513          	addi	a0,a0,1510 # ffffffffc0207468 <commands+0xd18>
ffffffffc0201e8a:	b7efe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201e8e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201e8e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201e90:	00005517          	auipc	a0,0x5
ffffffffc0201e94:	5f050513          	addi	a0,a0,1520 # ffffffffc0207480 <commands+0xd30>
kmalloc_init(void) {
ffffffffc0201e98:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201e9a:	a32fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201e9e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ea0:	00005517          	auipc	a0,0x5
ffffffffc0201ea4:	5f850513          	addi	a0,a0,1528 # ffffffffc0207498 <commands+0xd48>
}
ffffffffc0201ea8:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201eaa:	a22fe06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0201eae <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201eae:	4501                	li	a0,0
ffffffffc0201eb0:	8082                	ret

ffffffffc0201eb2 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201eb2:	1101                	addi	sp,sp,-32
ffffffffc0201eb4:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201eb6:	6905                	lui	s2,0x1
{
ffffffffc0201eb8:	e822                	sd	s0,16(sp)
ffffffffc0201eba:	ec06                	sd	ra,24(sp)
ffffffffc0201ebc:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ebe:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8be9>
{
ffffffffc0201ec2:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ec4:	04a7f963          	bgeu	a5,a0,ffffffffc0201f16 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201ec8:	4561                	li	a0,24
ffffffffc0201eca:	ecfff0ef          	jal	ra,ffffffffc0201d98 <slob_alloc.constprop.0>
ffffffffc0201ece:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201ed0:	c929                	beqz	a0,ffffffffc0201f22 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201ed2:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201ed6:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201ed8:	00f95763          	bge	s2,a5,ffffffffc0201ee6 <kmalloc+0x34>
ffffffffc0201edc:	6705                	lui	a4,0x1
ffffffffc0201ede:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201ee0:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201ee2:	fef74ee3          	blt	a4,a5,ffffffffc0201ede <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201ee6:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201ee8:	e4dff0ef          	jal	ra,ffffffffc0201d34 <__slob_get_free_pages.constprop.0>
ffffffffc0201eec:	e488                	sd	a0,8(s1)
ffffffffc0201eee:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201ef0:	c525                	beqz	a0,ffffffffc0201f58 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ef2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ef6:	8b89                	andi	a5,a5,2
ffffffffc0201ef8:	ef8d                	bnez	a5,ffffffffc0201f32 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201efa:	000b1797          	auipc	a5,0xb1
ffffffffc0201efe:	b2678793          	addi	a5,a5,-1242 # ffffffffc02b2a20 <bigblocks>
ffffffffc0201f02:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201f04:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201f06:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201f08:	60e2                	ld	ra,24(sp)
ffffffffc0201f0a:	8522                	mv	a0,s0
ffffffffc0201f0c:	6442                	ld	s0,16(sp)
ffffffffc0201f0e:	64a2                	ld	s1,8(sp)
ffffffffc0201f10:	6902                	ld	s2,0(sp)
ffffffffc0201f12:	6105                	addi	sp,sp,32
ffffffffc0201f14:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201f16:	0541                	addi	a0,a0,16
ffffffffc0201f18:	e81ff0ef          	jal	ra,ffffffffc0201d98 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201f1c:	01050413          	addi	s0,a0,16
ffffffffc0201f20:	f565                	bnez	a0,ffffffffc0201f08 <kmalloc+0x56>
ffffffffc0201f22:	4401                	li	s0,0
}
ffffffffc0201f24:	60e2                	ld	ra,24(sp)
ffffffffc0201f26:	8522                	mv	a0,s0
ffffffffc0201f28:	6442                	ld	s0,16(sp)
ffffffffc0201f2a:	64a2                	ld	s1,8(sp)
ffffffffc0201f2c:	6902                	ld	s2,0(sp)
ffffffffc0201f2e:	6105                	addi	sp,sp,32
ffffffffc0201f30:	8082                	ret
        intr_disable();
ffffffffc0201f32:	f16fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201f36:	000b1797          	auipc	a5,0xb1
ffffffffc0201f3a:	aea78793          	addi	a5,a5,-1302 # ffffffffc02b2a20 <bigblocks>
ffffffffc0201f3e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201f40:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201f42:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201f44:	efefe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc0201f48:	6480                	ld	s0,8(s1)
}
ffffffffc0201f4a:	60e2                	ld	ra,24(sp)
ffffffffc0201f4c:	64a2                	ld	s1,8(sp)
ffffffffc0201f4e:	8522                	mv	a0,s0
ffffffffc0201f50:	6442                	ld	s0,16(sp)
ffffffffc0201f52:	6902                	ld	s2,0(sp)
ffffffffc0201f54:	6105                	addi	sp,sp,32
ffffffffc0201f56:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f58:	45e1                	li	a1,24
ffffffffc0201f5a:	8526                	mv	a0,s1
ffffffffc0201f5c:	d25ff0ef          	jal	ra,ffffffffc0201c80 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201f60:	b765                	j	ffffffffc0201f08 <kmalloc+0x56>

ffffffffc0201f62 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201f62:	c169                	beqz	a0,ffffffffc0202024 <kfree+0xc2>
{
ffffffffc0201f64:	1101                	addi	sp,sp,-32
ffffffffc0201f66:	e822                	sd	s0,16(sp)
ffffffffc0201f68:	ec06                	sd	ra,24(sp)
ffffffffc0201f6a:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201f6c:	03451793          	slli	a5,a0,0x34
ffffffffc0201f70:	842a                	mv	s0,a0
ffffffffc0201f72:	e3d9                	bnez	a5,ffffffffc0201ff8 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f74:	100027f3          	csrr	a5,sstatus
ffffffffc0201f78:	8b89                	andi	a5,a5,2
ffffffffc0201f7a:	e7d9                	bnez	a5,ffffffffc0202008 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f7c:	000b1797          	auipc	a5,0xb1
ffffffffc0201f80:	aa47b783          	ld	a5,-1372(a5) # ffffffffc02b2a20 <bigblocks>
    return 0;
ffffffffc0201f84:	4601                	li	a2,0
ffffffffc0201f86:	cbad                	beqz	a5,ffffffffc0201ff8 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201f88:	000b1697          	auipc	a3,0xb1
ffffffffc0201f8c:	a9868693          	addi	a3,a3,-1384 # ffffffffc02b2a20 <bigblocks>
ffffffffc0201f90:	a021                	j	ffffffffc0201f98 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f92:	01048693          	addi	a3,s1,16
ffffffffc0201f96:	c3a5                	beqz	a5,ffffffffc0201ff6 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201f98:	6798                	ld	a4,8(a5)
ffffffffc0201f9a:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201f9c:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201f9e:	fe871ae3          	bne	a4,s0,ffffffffc0201f92 <kfree+0x30>
				*last = bb->next;
ffffffffc0201fa2:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201fa4:	ee2d                	bnez	a2,ffffffffc020201e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201fa6:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201faa:	4098                	lw	a4,0(s1)
ffffffffc0201fac:	08f46963          	bltu	s0,a5,ffffffffc020203e <kfree+0xdc>
ffffffffc0201fb0:	000b1697          	auipc	a3,0xb1
ffffffffc0201fb4:	ab86b683          	ld	a3,-1352(a3) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0201fb8:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201fba:	8031                	srli	s0,s0,0xc
ffffffffc0201fbc:	000b1797          	auipc	a5,0xb1
ffffffffc0201fc0:	a947b783          	ld	a5,-1388(a5) # ffffffffc02b2a50 <npage>
ffffffffc0201fc4:	06f47163          	bgeu	s0,a5,ffffffffc0202026 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc8:	00007517          	auipc	a0,0x7
ffffffffc0201fcc:	ba053503          	ld	a0,-1120(a0) # ffffffffc0208b68 <nbase>
ffffffffc0201fd0:	8c09                	sub	s0,s0,a0
ffffffffc0201fd2:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201fd4:	000b1517          	auipc	a0,0xb1
ffffffffc0201fd8:	a8453503          	ld	a0,-1404(a0) # ffffffffc02b2a58 <pages>
ffffffffc0201fdc:	4585                	li	a1,1
ffffffffc0201fde:	9522                	add	a0,a0,s0
ffffffffc0201fe0:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201fe4:	4f4010ef          	jal	ra,ffffffffc02034d8 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201fe8:	6442                	ld	s0,16(sp)
ffffffffc0201fea:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201fec:	8526                	mv	a0,s1
}
ffffffffc0201fee:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ff0:	45e1                	li	a1,24
}
ffffffffc0201ff2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ff4:	b171                	j	ffffffffc0201c80 <slob_free>
ffffffffc0201ff6:	e20d                	bnez	a2,ffffffffc0202018 <kfree+0xb6>
ffffffffc0201ff8:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201ffc:	6442                	ld	s0,16(sp)
ffffffffc0201ffe:	60e2                	ld	ra,24(sp)
ffffffffc0202000:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202002:	4581                	li	a1,0
}
ffffffffc0202004:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202006:	b9ad                	j	ffffffffc0201c80 <slob_free>
        intr_disable();
ffffffffc0202008:	e40fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020200c:	000b1797          	auipc	a5,0xb1
ffffffffc0202010:	a147b783          	ld	a5,-1516(a5) # ffffffffc02b2a20 <bigblocks>
        return 1;
ffffffffc0202014:	4605                	li	a2,1
ffffffffc0202016:	fbad                	bnez	a5,ffffffffc0201f88 <kfree+0x26>
        intr_enable();
ffffffffc0202018:	e2afe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020201c:	bff1                	j	ffffffffc0201ff8 <kfree+0x96>
ffffffffc020201e:	e24fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0202022:	b751                	j	ffffffffc0201fa6 <kfree+0x44>
ffffffffc0202024:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202026:	00005617          	auipc	a2,0x5
ffffffffc020202a:	0da60613          	addi	a2,a2,218 # ffffffffc0207100 <commands+0x9b0>
ffffffffc020202e:	06200593          	li	a1,98
ffffffffc0202032:	00005517          	auipc	a0,0x5
ffffffffc0202036:	0ee50513          	addi	a0,a0,238 # ffffffffc0207120 <commands+0x9d0>
ffffffffc020203a:	9cefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020203e:	86a2                	mv	a3,s0
ffffffffc0202040:	00005617          	auipc	a2,0x5
ffffffffc0202044:	47860613          	addi	a2,a2,1144 # ffffffffc02074b8 <commands+0xd68>
ffffffffc0202048:	06e00593          	li	a1,110
ffffffffc020204c:	00005517          	auipc	a0,0x5
ffffffffc0202050:	0d450513          	addi	a0,a0,212 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0202054:	9b4fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202058 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202058:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020205a:	00005617          	auipc	a2,0x5
ffffffffc020205e:	0a660613          	addi	a2,a2,166 # ffffffffc0207100 <commands+0x9b0>
ffffffffc0202062:	06200593          	li	a1,98
ffffffffc0202066:	00005517          	auipc	a0,0x5
ffffffffc020206a:	0ba50513          	addi	a0,a0,186 # ffffffffc0207120 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc020206e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202070:	998fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202074 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202074:	7135                	addi	sp,sp,-160
ffffffffc0202076:	ed06                	sd	ra,152(sp)
ffffffffc0202078:	e922                	sd	s0,144(sp)
ffffffffc020207a:	e526                	sd	s1,136(sp)
ffffffffc020207c:	e14a                	sd	s2,128(sp)
ffffffffc020207e:	fcce                	sd	s3,120(sp)
ffffffffc0202080:	f8d2                	sd	s4,112(sp)
ffffffffc0202082:	f4d6                	sd	s5,104(sp)
ffffffffc0202084:	f0da                	sd	s6,96(sp)
ffffffffc0202086:	ecde                	sd	s7,88(sp)
ffffffffc0202088:	e8e2                	sd	s8,80(sp)
ffffffffc020208a:	e4e6                	sd	s9,72(sp)
ffffffffc020208c:	e0ea                	sd	s10,64(sp)
ffffffffc020208e:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202090:	239020ef          	jal	ra,ffffffffc0204ac8 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202094:	000b1697          	auipc	a3,0xb1
ffffffffc0202098:	9946b683          	ld	a3,-1644(a3) # ffffffffc02b2a28 <max_swap_offset>
ffffffffc020209c:	010007b7          	lui	a5,0x1000
ffffffffc02020a0:	ff968713          	addi	a4,a3,-7
ffffffffc02020a4:	17e1                	addi	a5,a5,-8
ffffffffc02020a6:	42e7e663          	bltu	a5,a4,ffffffffc02024d2 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02020aa:	000a5797          	auipc	a5,0xa5
ffffffffc02020ae:	42678793          	addi	a5,a5,1062 # ffffffffc02a74d0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02020b2:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02020b4:	000b1b97          	auipc	s7,0xb1
ffffffffc02020b8:	97cb8b93          	addi	s7,s7,-1668 # ffffffffc02b2a30 <sm>
ffffffffc02020bc:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02020c0:	9702                	jalr	a4
ffffffffc02020c2:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02020c4:	c10d                	beqz	a0,ffffffffc02020e6 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02020c6:	60ea                	ld	ra,152(sp)
ffffffffc02020c8:	644a                	ld	s0,144(sp)
ffffffffc02020ca:	64aa                	ld	s1,136(sp)
ffffffffc02020cc:	79e6                	ld	s3,120(sp)
ffffffffc02020ce:	7a46                	ld	s4,112(sp)
ffffffffc02020d0:	7aa6                	ld	s5,104(sp)
ffffffffc02020d2:	7b06                	ld	s6,96(sp)
ffffffffc02020d4:	6be6                	ld	s7,88(sp)
ffffffffc02020d6:	6c46                	ld	s8,80(sp)
ffffffffc02020d8:	6ca6                	ld	s9,72(sp)
ffffffffc02020da:	6d06                	ld	s10,64(sp)
ffffffffc02020dc:	7de2                	ld	s11,56(sp)
ffffffffc02020de:	854a                	mv	a0,s2
ffffffffc02020e0:	690a                	ld	s2,128(sp)
ffffffffc02020e2:	610d                	addi	sp,sp,160
ffffffffc02020e4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02020e6:	000bb783          	ld	a5,0(s7)
ffffffffc02020ea:	00005517          	auipc	a0,0x5
ffffffffc02020ee:	42650513          	addi	a0,a0,1062 # ffffffffc0207510 <commands+0xdc0>
    return listelm->next;
ffffffffc02020f2:	000ad417          	auipc	s0,0xad
ffffffffc02020f6:	8de40413          	addi	s0,s0,-1826 # ffffffffc02ae9d0 <free_area>
ffffffffc02020fa:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02020fc:	4785                	li	a5,1
ffffffffc02020fe:	000b1717          	auipc	a4,0xb1
ffffffffc0202102:	92f72d23          	sw	a5,-1734(a4) # ffffffffc02b2a38 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202106:	fc7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020210a:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020210c:	4d01                	li	s10,0
ffffffffc020210e:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202110:	34878163          	beq	a5,s0,ffffffffc0202452 <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202114:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202118:	8b09                	andi	a4,a4,2
ffffffffc020211a:	32070e63          	beqz	a4,ffffffffc0202456 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc020211e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202122:	679c                	ld	a5,8(a5)
ffffffffc0202124:	2d85                	addiw	s11,s11,1
ffffffffc0202126:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc020212a:	fe8795e3          	bne	a5,s0,ffffffffc0202114 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020212e:	84ea                	mv	s1,s10
ffffffffc0202130:	3e8010ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc0202134:	42951763          	bne	a0,s1,ffffffffc0202562 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202138:	866a                	mv	a2,s10
ffffffffc020213a:	85ee                	mv	a1,s11
ffffffffc020213c:	00005517          	auipc	a0,0x5
ffffffffc0202140:	41c50513          	addi	a0,a0,1052 # ffffffffc0207558 <commands+0xe08>
ffffffffc0202144:	f89fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202148:	cfffe0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc020214c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020214e:	46050a63          	beqz	a0,ffffffffc02025c2 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202152:	000b1797          	auipc	a5,0xb1
ffffffffc0202156:	8be78793          	addi	a5,a5,-1858 # ffffffffc02b2a10 <check_mm_struct>
ffffffffc020215a:	6398                	ld	a4,0(a5)
ffffffffc020215c:	3e071363          	bnez	a4,ffffffffc0202542 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202160:	000b1717          	auipc	a4,0xb1
ffffffffc0202164:	8e870713          	addi	a4,a4,-1816 # ffffffffc02b2a48 <boot_pgdir>
ffffffffc0202168:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc020216c:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc020216e:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202172:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202176:	42079663          	bnez	a5,ffffffffc02025a2 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020217a:	6599                	lui	a1,0x6
ffffffffc020217c:	460d                	li	a2,3
ffffffffc020217e:	6505                	lui	a0,0x1
ffffffffc0202180:	d0ffe0ef          	jal	ra,ffffffffc0200e8e <vma_create>
ffffffffc0202184:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202186:	52050a63          	beqz	a0,ffffffffc02026ba <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc020218a:	8556                	mv	a0,s5
ffffffffc020218c:	d71fe0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202190:	00005517          	auipc	a0,0x5
ffffffffc0202194:	40850513          	addi	a0,a0,1032 # ffffffffc0207598 <commands+0xe48>
ffffffffc0202198:	f35fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020219c:	018ab503          	ld	a0,24(s5)
ffffffffc02021a0:	4605                	li	a2,1
ffffffffc02021a2:	6585                	lui	a1,0x1
ffffffffc02021a4:	3ae010ef          	jal	ra,ffffffffc0203552 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02021a8:	4c050963          	beqz	a0,ffffffffc020267a <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02021ac:	00005517          	auipc	a0,0x5
ffffffffc02021b0:	43c50513          	addi	a0,a0,1084 # ffffffffc02075e8 <commands+0xe98>
ffffffffc02021b4:	000ac497          	auipc	s1,0xac
ffffffffc02021b8:	7ac48493          	addi	s1,s1,1964 # ffffffffc02ae960 <check_rp>
ffffffffc02021bc:	f11fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02021c0:	000ac997          	auipc	s3,0xac
ffffffffc02021c4:	7c098993          	addi	s3,s3,1984 # ffffffffc02ae980 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02021c8:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02021ca:	4505                	li	a0,1
ffffffffc02021cc:	27a010ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02021d0:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
          assert(check_rp[i] != NULL );
ffffffffc02021d4:	2c050f63          	beqz	a0,ffffffffc02024b2 <swap_init+0x43e>
ffffffffc02021d8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02021da:	8b89                	andi	a5,a5,2
ffffffffc02021dc:	34079363          	bnez	a5,ffffffffc0202522 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02021e0:	0a21                	addi	s4,s4,8
ffffffffc02021e2:	ff3a14e3          	bne	s4,s3,ffffffffc02021ca <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02021e6:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02021e8:	000aca17          	auipc	s4,0xac
ffffffffc02021ec:	778a0a13          	addi	s4,s4,1912 # ffffffffc02ae960 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02021f0:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02021f2:	ec3e                	sd	a5,24(sp)
ffffffffc02021f4:	641c                	ld	a5,8(s0)
ffffffffc02021f6:	e400                	sd	s0,8(s0)
ffffffffc02021f8:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02021fa:	481c                	lw	a5,16(s0)
ffffffffc02021fc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02021fe:	000ac797          	auipc	a5,0xac
ffffffffc0202202:	7e07a123          	sw	zero,2018(a5) # ffffffffc02ae9e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202206:	000a3503          	ld	a0,0(s4)
ffffffffc020220a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020220c:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc020220e:	2ca010ef          	jal	ra,ffffffffc02034d8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202212:	ff3a1ae3          	bne	s4,s3,ffffffffc0202206 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202216:	01042a03          	lw	s4,16(s0)
ffffffffc020221a:	4791                	li	a5,4
ffffffffc020221c:	42fa1f63          	bne	s4,a5,ffffffffc020265a <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202220:	00005517          	auipc	a0,0x5
ffffffffc0202224:	45050513          	addi	a0,a0,1104 # ffffffffc0207670 <commands+0xf20>
ffffffffc0202228:	ea5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020222c:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020222e:	000b0797          	auipc	a5,0xb0
ffffffffc0202232:	7e07a523          	sw	zero,2026(a5) # ffffffffc02b2a18 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202236:	4629                	li	a2,10
ffffffffc0202238:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
     assert(pgfault_num==1);
ffffffffc020223c:	000b0697          	auipc	a3,0xb0
ffffffffc0202240:	7dc6a683          	lw	a3,2012(a3) # ffffffffc02b2a18 <pgfault_num>
ffffffffc0202244:	4585                	li	a1,1
ffffffffc0202246:	000b0797          	auipc	a5,0xb0
ffffffffc020224a:	7d278793          	addi	a5,a5,2002 # ffffffffc02b2a18 <pgfault_num>
ffffffffc020224e:	54b69663          	bne	a3,a1,ffffffffc020279a <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202252:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202256:	4398                	lw	a4,0(a5)
ffffffffc0202258:	2701                	sext.w	a4,a4
ffffffffc020225a:	3ed71063          	bne	a4,a3,ffffffffc020263a <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020225e:	6689                	lui	a3,0x2
ffffffffc0202260:	462d                	li	a2,11
ffffffffc0202262:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bd8>
     assert(pgfault_num==2);
ffffffffc0202266:	4398                	lw	a4,0(a5)
ffffffffc0202268:	4589                	li	a1,2
ffffffffc020226a:	2701                	sext.w	a4,a4
ffffffffc020226c:	4ab71763          	bne	a4,a1,ffffffffc020271a <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202270:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202274:	4394                	lw	a3,0(a5)
ffffffffc0202276:	2681                	sext.w	a3,a3
ffffffffc0202278:	4ce69163          	bne	a3,a4,ffffffffc020273a <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020227c:	668d                	lui	a3,0x3
ffffffffc020227e:	4631                	li	a2,12
ffffffffc0202280:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bd8>
     assert(pgfault_num==3);
ffffffffc0202284:	4398                	lw	a4,0(a5)
ffffffffc0202286:	458d                	li	a1,3
ffffffffc0202288:	2701                	sext.w	a4,a4
ffffffffc020228a:	4cb71863          	bne	a4,a1,ffffffffc020275a <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020228e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202292:	4394                	lw	a3,0(a5)
ffffffffc0202294:	2681                	sext.w	a3,a3
ffffffffc0202296:	4ee69263          	bne	a3,a4,ffffffffc020277a <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020229a:	6691                	lui	a3,0x4
ffffffffc020229c:	4635                	li	a2,13
ffffffffc020229e:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bd8>
     assert(pgfault_num==4);
ffffffffc02022a2:	4398                	lw	a4,0(a5)
ffffffffc02022a4:	2701                	sext.w	a4,a4
ffffffffc02022a6:	43471a63          	bne	a4,s4,ffffffffc02026da <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02022aa:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02022ae:	439c                	lw	a5,0(a5)
ffffffffc02022b0:	2781                	sext.w	a5,a5
ffffffffc02022b2:	44e79463          	bne	a5,a4,ffffffffc02026fa <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02022b6:	481c                	lw	a5,16(s0)
ffffffffc02022b8:	2c079563          	bnez	a5,ffffffffc0202582 <swap_init+0x50e>
ffffffffc02022bc:	000ac797          	auipc	a5,0xac
ffffffffc02022c0:	6c478793          	addi	a5,a5,1732 # ffffffffc02ae980 <swap_in_seq_no>
ffffffffc02022c4:	000ac717          	auipc	a4,0xac
ffffffffc02022c8:	6e470713          	addi	a4,a4,1764 # ffffffffc02ae9a8 <swap_out_seq_no>
ffffffffc02022cc:	000ac617          	auipc	a2,0xac
ffffffffc02022d0:	6dc60613          	addi	a2,a2,1756 # ffffffffc02ae9a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02022d4:	56fd                	li	a3,-1
ffffffffc02022d6:	c394                	sw	a3,0(a5)
ffffffffc02022d8:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02022da:	0791                	addi	a5,a5,4
ffffffffc02022dc:	0711                	addi	a4,a4,4
ffffffffc02022de:	fec79ce3          	bne	a5,a2,ffffffffc02022d6 <swap_init+0x262>
ffffffffc02022e2:	000ac717          	auipc	a4,0xac
ffffffffc02022e6:	65e70713          	addi	a4,a4,1630 # ffffffffc02ae940 <check_ptep>
ffffffffc02022ea:	000ac697          	auipc	a3,0xac
ffffffffc02022ee:	67668693          	addi	a3,a3,1654 # ffffffffc02ae960 <check_rp>
ffffffffc02022f2:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc02022f4:	000b0c17          	auipc	s8,0xb0
ffffffffc02022f8:	75cc0c13          	addi	s8,s8,1884 # ffffffffc02b2a50 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02022fc:	000b0c97          	auipc	s9,0xb0
ffffffffc0202300:	75cc8c93          	addi	s9,s9,1884 # ffffffffc02b2a58 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202304:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202308:	4601                	li	a2,0
ffffffffc020230a:	855a                	mv	a0,s6
ffffffffc020230c:	e836                	sd	a3,16(sp)
ffffffffc020230e:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202310:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202312:	240010ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0202316:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202318:	65a2                	ld	a1,8(sp)
ffffffffc020231a:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020231c:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc020231e:	1c050663          	beqz	a0,ffffffffc02024ea <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202322:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202324:	0017f613          	andi	a2,a5,1
ffffffffc0202328:	1e060163          	beqz	a2,ffffffffc020250a <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc020232c:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202330:	078a                	slli	a5,a5,0x2
ffffffffc0202332:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202334:	14c7f363          	bgeu	a5,a2,ffffffffc020247a <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0202338:	00007617          	auipc	a2,0x7
ffffffffc020233c:	83060613          	addi	a2,a2,-2000 # ffffffffc0208b68 <nbase>
ffffffffc0202340:	00063a03          	ld	s4,0(a2)
ffffffffc0202344:	000cb603          	ld	a2,0(s9)
ffffffffc0202348:	6288                	ld	a0,0(a3)
ffffffffc020234a:	414787b3          	sub	a5,a5,s4
ffffffffc020234e:	079a                	slli	a5,a5,0x6
ffffffffc0202350:	97b2                	add	a5,a5,a2
ffffffffc0202352:	14f51063          	bne	a0,a5,ffffffffc0202492 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202356:	6785                	lui	a5,0x1
ffffffffc0202358:	95be                	add	a1,a1,a5
ffffffffc020235a:	6795                	lui	a5,0x5
ffffffffc020235c:	0721                	addi	a4,a4,8
ffffffffc020235e:	06a1                	addi	a3,a3,8
ffffffffc0202360:	faf592e3          	bne	a1,a5,ffffffffc0202304 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202364:	00005517          	auipc	a0,0x5
ffffffffc0202368:	3dc50513          	addi	a0,a0,988 # ffffffffc0207740 <commands+0xff0>
ffffffffc020236c:	d61fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0202370:	000bb783          	ld	a5,0(s7)
ffffffffc0202374:	7f9c                	ld	a5,56(a5)
ffffffffc0202376:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202378:	32051163          	bnez	a0,ffffffffc020269a <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc020237c:	77a2                	ld	a5,40(sp)
ffffffffc020237e:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202380:	67e2                	ld	a5,24(sp)
ffffffffc0202382:	e01c                	sd	a5,0(s0)
ffffffffc0202384:	7782                	ld	a5,32(sp)
ffffffffc0202386:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202388:	6088                	ld	a0,0(s1)
ffffffffc020238a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020238c:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc020238e:	14a010ef          	jal	ra,ffffffffc02034d8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202392:	ff349be3          	bne	s1,s3,ffffffffc0202388 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0202396:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc020239a:	8556                	mv	a0,s5
ffffffffc020239c:	c31fe0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02023a0:	000b0797          	auipc	a5,0xb0
ffffffffc02023a4:	6a878793          	addi	a5,a5,1704 # ffffffffc02b2a48 <boot_pgdir>
ffffffffc02023a8:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02023aa:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc02023ae:	000b0697          	auipc	a3,0xb0
ffffffffc02023b2:	6606b123          	sd	zero,1634(a3) # ffffffffc02b2a10 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc02023b6:	639c                	ld	a5,0(a5)
ffffffffc02023b8:	078a                	slli	a5,a5,0x2
ffffffffc02023ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023bc:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202476 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02023c0:	414786b3          	sub	a3,a5,s4
ffffffffc02023c4:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02023c6:	8699                	srai	a3,a3,0x6
ffffffffc02023c8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02023ca:	00c69793          	slli	a5,a3,0xc
ffffffffc02023ce:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02023d0:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc02023d4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023d6:	22e7f663          	bgeu	a5,a4,ffffffffc0202602 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc02023da:	000b0797          	auipc	a5,0xb0
ffffffffc02023de:	68e7b783          	ld	a5,1678(a5) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc02023e2:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e4:	629c                	ld	a5,0(a3)
ffffffffc02023e6:	078a                	slli	a5,a5,0x2
ffffffffc02023e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023ea:	08e7f663          	bgeu	a5,a4,ffffffffc0202476 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ee:	414787b3          	sub	a5,a5,s4
ffffffffc02023f2:	079a                	slli	a5,a5,0x6
ffffffffc02023f4:	953e                	add	a0,a0,a5
ffffffffc02023f6:	4585                	li	a1,1
ffffffffc02023f8:	0e0010ef          	jal	ra,ffffffffc02034d8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02023fc:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202400:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202404:	078a                	slli	a5,a5,0x2
ffffffffc0202406:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202408:	06e7f763          	bgeu	a5,a4,ffffffffc0202476 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020240c:	000cb503          	ld	a0,0(s9)
ffffffffc0202410:	414787b3          	sub	a5,a5,s4
ffffffffc0202414:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202416:	4585                	li	a1,1
ffffffffc0202418:	953e                	add	a0,a0,a5
ffffffffc020241a:	0be010ef          	jal	ra,ffffffffc02034d8 <free_pages>
     pgdir[0] = 0;
ffffffffc020241e:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202422:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202426:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202428:	00878a63          	beq	a5,s0,ffffffffc020243c <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020242c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202430:	679c                	ld	a5,8(a5)
ffffffffc0202432:	3dfd                	addiw	s11,s11,-1
ffffffffc0202434:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202438:	fe879ae3          	bne	a5,s0,ffffffffc020242c <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc020243c:	1c0d9f63          	bnez	s11,ffffffffc020261a <swap_init+0x5a6>
     assert(total==0);
ffffffffc0202440:	1a0d1163          	bnez	s10,ffffffffc02025e2 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202444:	00005517          	auipc	a0,0x5
ffffffffc0202448:	34c50513          	addi	a0,a0,844 # ffffffffc0207790 <commands+0x1040>
ffffffffc020244c:	c81fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202450:	b99d                	j	ffffffffc02020c6 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202452:	4481                	li	s1,0
ffffffffc0202454:	b9f1                	j	ffffffffc0202130 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0202456:	00005697          	auipc	a3,0x5
ffffffffc020245a:	0d268693          	addi	a3,a3,210 # ffffffffc0207528 <commands+0xdd8>
ffffffffc020245e:	00004617          	auipc	a2,0x4
ffffffffc0202462:	70260613          	addi	a2,a2,1794 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202466:	0bc00593          	li	a1,188
ffffffffc020246a:	00005517          	auipc	a0,0x5
ffffffffc020246e:	09650513          	addi	a0,a0,150 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202472:	d97fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202476:	be3ff0ef          	jal	ra,ffffffffc0202058 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc020247a:	00005617          	auipc	a2,0x5
ffffffffc020247e:	c8660613          	addi	a2,a2,-890 # ffffffffc0207100 <commands+0x9b0>
ffffffffc0202482:	06200593          	li	a1,98
ffffffffc0202486:	00005517          	auipc	a0,0x5
ffffffffc020248a:	c9a50513          	addi	a0,a0,-870 # ffffffffc0207120 <commands+0x9d0>
ffffffffc020248e:	d7bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202492:	00005697          	auipc	a3,0x5
ffffffffc0202496:	28668693          	addi	a3,a3,646 # ffffffffc0207718 <commands+0xfc8>
ffffffffc020249a:	00004617          	auipc	a2,0x4
ffffffffc020249e:	6c660613          	addi	a2,a2,1734 # ffffffffc0206b60 <commands+0x410>
ffffffffc02024a2:	0fc00593          	li	a1,252
ffffffffc02024a6:	00005517          	auipc	a0,0x5
ffffffffc02024aa:	05a50513          	addi	a0,a0,90 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02024ae:	d5bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02024b2:	00005697          	auipc	a3,0x5
ffffffffc02024b6:	15e68693          	addi	a3,a3,350 # ffffffffc0207610 <commands+0xec0>
ffffffffc02024ba:	00004617          	auipc	a2,0x4
ffffffffc02024be:	6a660613          	addi	a2,a2,1702 # ffffffffc0206b60 <commands+0x410>
ffffffffc02024c2:	0dc00593          	li	a1,220
ffffffffc02024c6:	00005517          	auipc	a0,0x5
ffffffffc02024ca:	03a50513          	addi	a0,a0,58 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02024ce:	d3bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02024d2:	00005617          	auipc	a2,0x5
ffffffffc02024d6:	00e60613          	addi	a2,a2,14 # ffffffffc02074e0 <commands+0xd90>
ffffffffc02024da:	02800593          	li	a1,40
ffffffffc02024de:	00005517          	auipc	a0,0x5
ffffffffc02024e2:	02250513          	addi	a0,a0,34 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02024e6:	d23fd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02024ea:	00005697          	auipc	a3,0x5
ffffffffc02024ee:	1ee68693          	addi	a3,a3,494 # ffffffffc02076d8 <commands+0xf88>
ffffffffc02024f2:	00004617          	auipc	a2,0x4
ffffffffc02024f6:	66e60613          	addi	a2,a2,1646 # ffffffffc0206b60 <commands+0x410>
ffffffffc02024fa:	0fb00593          	li	a1,251
ffffffffc02024fe:	00005517          	auipc	a0,0x5
ffffffffc0202502:	00250513          	addi	a0,a0,2 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202506:	d03fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020250a:	00005617          	auipc	a2,0x5
ffffffffc020250e:	1e660613          	addi	a2,a2,486 # ffffffffc02076f0 <commands+0xfa0>
ffffffffc0202512:	07400593          	li	a1,116
ffffffffc0202516:	00005517          	auipc	a0,0x5
ffffffffc020251a:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0207120 <commands+0x9d0>
ffffffffc020251e:	cebfd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202522:	00005697          	auipc	a3,0x5
ffffffffc0202526:	10668693          	addi	a3,a3,262 # ffffffffc0207628 <commands+0xed8>
ffffffffc020252a:	00004617          	auipc	a2,0x4
ffffffffc020252e:	63660613          	addi	a2,a2,1590 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202532:	0dd00593          	li	a1,221
ffffffffc0202536:	00005517          	auipc	a0,0x5
ffffffffc020253a:	fca50513          	addi	a0,a0,-54 # ffffffffc0207500 <commands+0xdb0>
ffffffffc020253e:	ccbfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202542:	00005697          	auipc	a3,0x5
ffffffffc0202546:	03e68693          	addi	a3,a3,62 # ffffffffc0207580 <commands+0xe30>
ffffffffc020254a:	00004617          	auipc	a2,0x4
ffffffffc020254e:	61660613          	addi	a2,a2,1558 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202552:	0c700593          	li	a1,199
ffffffffc0202556:	00005517          	auipc	a0,0x5
ffffffffc020255a:	faa50513          	addi	a0,a0,-86 # ffffffffc0207500 <commands+0xdb0>
ffffffffc020255e:	cabfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202562:	00005697          	auipc	a3,0x5
ffffffffc0202566:	fd668693          	addi	a3,a3,-42 # ffffffffc0207538 <commands+0xde8>
ffffffffc020256a:	00004617          	auipc	a2,0x4
ffffffffc020256e:	5f660613          	addi	a2,a2,1526 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202572:	0bf00593          	li	a1,191
ffffffffc0202576:	00005517          	auipc	a0,0x5
ffffffffc020257a:	f8a50513          	addi	a0,a0,-118 # ffffffffc0207500 <commands+0xdb0>
ffffffffc020257e:	c8bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0202582:	00005697          	auipc	a3,0x5
ffffffffc0202586:	14668693          	addi	a3,a3,326 # ffffffffc02076c8 <commands+0xf78>
ffffffffc020258a:	00004617          	auipc	a2,0x4
ffffffffc020258e:	5d660613          	addi	a2,a2,1494 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202592:	0f300593          	li	a1,243
ffffffffc0202596:	00005517          	auipc	a0,0x5
ffffffffc020259a:	f6a50513          	addi	a0,a0,-150 # ffffffffc0207500 <commands+0xdb0>
ffffffffc020259e:	c6bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02025a2:	00005697          	auipc	a3,0x5
ffffffffc02025a6:	b1e68693          	addi	a3,a3,-1250 # ffffffffc02070c0 <commands+0x970>
ffffffffc02025aa:	00004617          	auipc	a2,0x4
ffffffffc02025ae:	5b660613          	addi	a2,a2,1462 # ffffffffc0206b60 <commands+0x410>
ffffffffc02025b2:	0cc00593          	li	a1,204
ffffffffc02025b6:	00005517          	auipc	a0,0x5
ffffffffc02025ba:	f4a50513          	addi	a0,a0,-182 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02025be:	c4bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc02025c2:	00005697          	auipc	a3,0x5
ffffffffc02025c6:	93668693          	addi	a3,a3,-1738 # ffffffffc0206ef8 <commands+0x7a8>
ffffffffc02025ca:	00004617          	auipc	a2,0x4
ffffffffc02025ce:	59660613          	addi	a2,a2,1430 # ffffffffc0206b60 <commands+0x410>
ffffffffc02025d2:	0c400593          	li	a1,196
ffffffffc02025d6:	00005517          	auipc	a0,0x5
ffffffffc02025da:	f2a50513          	addi	a0,a0,-214 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02025de:	c2bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc02025e2:	00005697          	auipc	a3,0x5
ffffffffc02025e6:	19e68693          	addi	a3,a3,414 # ffffffffc0207780 <commands+0x1030>
ffffffffc02025ea:	00004617          	auipc	a2,0x4
ffffffffc02025ee:	57660613          	addi	a2,a2,1398 # ffffffffc0206b60 <commands+0x410>
ffffffffc02025f2:	11e00593          	li	a1,286
ffffffffc02025f6:	00005517          	auipc	a0,0x5
ffffffffc02025fa:	f0a50513          	addi	a0,a0,-246 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02025fe:	c0bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202602:	00005617          	auipc	a2,0x5
ffffffffc0202606:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0207130 <commands+0x9e0>
ffffffffc020260a:	06900593          	li	a1,105
ffffffffc020260e:	00005517          	auipc	a0,0x5
ffffffffc0202612:	b1250513          	addi	a0,a0,-1262 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0202616:	bf3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc020261a:	00005697          	auipc	a3,0x5
ffffffffc020261e:	15668693          	addi	a3,a3,342 # ffffffffc0207770 <commands+0x1020>
ffffffffc0202622:	00004617          	auipc	a2,0x4
ffffffffc0202626:	53e60613          	addi	a2,a2,1342 # ffffffffc0206b60 <commands+0x410>
ffffffffc020262a:	11d00593          	li	a1,285
ffffffffc020262e:	00005517          	auipc	a0,0x5
ffffffffc0202632:	ed250513          	addi	a0,a0,-302 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202636:	bd3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc020263a:	00005697          	auipc	a3,0x5
ffffffffc020263e:	05e68693          	addi	a3,a3,94 # ffffffffc0207698 <commands+0xf48>
ffffffffc0202642:	00004617          	auipc	a2,0x4
ffffffffc0202646:	51e60613          	addi	a2,a2,1310 # ffffffffc0206b60 <commands+0x410>
ffffffffc020264a:	09500593          	li	a1,149
ffffffffc020264e:	00005517          	auipc	a0,0x5
ffffffffc0202652:	eb250513          	addi	a0,a0,-334 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202656:	bb3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020265a:	00005697          	auipc	a3,0x5
ffffffffc020265e:	fee68693          	addi	a3,a3,-18 # ffffffffc0207648 <commands+0xef8>
ffffffffc0202662:	00004617          	auipc	a2,0x4
ffffffffc0202666:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206b60 <commands+0x410>
ffffffffc020266a:	0ea00593          	li	a1,234
ffffffffc020266e:	00005517          	auipc	a0,0x5
ffffffffc0202672:	e9250513          	addi	a0,a0,-366 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202676:	b93fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020267a:	00005697          	auipc	a3,0x5
ffffffffc020267e:	f5668693          	addi	a3,a3,-170 # ffffffffc02075d0 <commands+0xe80>
ffffffffc0202682:	00004617          	auipc	a2,0x4
ffffffffc0202686:	4de60613          	addi	a2,a2,1246 # ffffffffc0206b60 <commands+0x410>
ffffffffc020268a:	0d700593          	li	a1,215
ffffffffc020268e:	00005517          	auipc	a0,0x5
ffffffffc0202692:	e7250513          	addi	a0,a0,-398 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202696:	b73fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc020269a:	00005697          	auipc	a3,0x5
ffffffffc020269e:	0ce68693          	addi	a3,a3,206 # ffffffffc0207768 <commands+0x1018>
ffffffffc02026a2:	00004617          	auipc	a2,0x4
ffffffffc02026a6:	4be60613          	addi	a2,a2,1214 # ffffffffc0206b60 <commands+0x410>
ffffffffc02026aa:	10200593          	li	a1,258
ffffffffc02026ae:	00005517          	auipc	a0,0x5
ffffffffc02026b2:	e5250513          	addi	a0,a0,-430 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02026b6:	b53fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc02026ba:	00005697          	auipc	a3,0x5
ffffffffc02026be:	afe68693          	addi	a3,a3,-1282 # ffffffffc02071b8 <commands+0xa68>
ffffffffc02026c2:	00004617          	auipc	a2,0x4
ffffffffc02026c6:	49e60613          	addi	a2,a2,1182 # ffffffffc0206b60 <commands+0x410>
ffffffffc02026ca:	0cf00593          	li	a1,207
ffffffffc02026ce:	00005517          	auipc	a0,0x5
ffffffffc02026d2:	e3250513          	addi	a0,a0,-462 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02026d6:	b33fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc02026da:	00005697          	auipc	a3,0x5
ffffffffc02026de:	bb668693          	addi	a3,a3,-1098 # ffffffffc0207290 <commands+0xb40>
ffffffffc02026e2:	00004617          	auipc	a2,0x4
ffffffffc02026e6:	47e60613          	addi	a2,a2,1150 # ffffffffc0206b60 <commands+0x410>
ffffffffc02026ea:	09f00593          	li	a1,159
ffffffffc02026ee:	00005517          	auipc	a0,0x5
ffffffffc02026f2:	e1250513          	addi	a0,a0,-494 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02026f6:	b13fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc02026fa:	00005697          	auipc	a3,0x5
ffffffffc02026fe:	b9668693          	addi	a3,a3,-1130 # ffffffffc0207290 <commands+0xb40>
ffffffffc0202702:	00004617          	auipc	a2,0x4
ffffffffc0202706:	45e60613          	addi	a2,a2,1118 # ffffffffc0206b60 <commands+0x410>
ffffffffc020270a:	0a100593          	li	a1,161
ffffffffc020270e:	00005517          	auipc	a0,0x5
ffffffffc0202712:	df250513          	addi	a0,a0,-526 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202716:	af3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc020271a:	00005697          	auipc	a3,0x5
ffffffffc020271e:	f8e68693          	addi	a3,a3,-114 # ffffffffc02076a8 <commands+0xf58>
ffffffffc0202722:	00004617          	auipc	a2,0x4
ffffffffc0202726:	43e60613          	addi	a2,a2,1086 # ffffffffc0206b60 <commands+0x410>
ffffffffc020272a:	09700593          	li	a1,151
ffffffffc020272e:	00005517          	auipc	a0,0x5
ffffffffc0202732:	dd250513          	addi	a0,a0,-558 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202736:	ad3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc020273a:	00005697          	auipc	a3,0x5
ffffffffc020273e:	f6e68693          	addi	a3,a3,-146 # ffffffffc02076a8 <commands+0xf58>
ffffffffc0202742:	00004617          	auipc	a2,0x4
ffffffffc0202746:	41e60613          	addi	a2,a2,1054 # ffffffffc0206b60 <commands+0x410>
ffffffffc020274a:	09900593          	li	a1,153
ffffffffc020274e:	00005517          	auipc	a0,0x5
ffffffffc0202752:	db250513          	addi	a0,a0,-590 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202756:	ab3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc020275a:	00005697          	auipc	a3,0x5
ffffffffc020275e:	f5e68693          	addi	a3,a3,-162 # ffffffffc02076b8 <commands+0xf68>
ffffffffc0202762:	00004617          	auipc	a2,0x4
ffffffffc0202766:	3fe60613          	addi	a2,a2,1022 # ffffffffc0206b60 <commands+0x410>
ffffffffc020276a:	09b00593          	li	a1,155
ffffffffc020276e:	00005517          	auipc	a0,0x5
ffffffffc0202772:	d9250513          	addi	a0,a0,-622 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202776:	a93fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc020277a:	00005697          	auipc	a3,0x5
ffffffffc020277e:	f3e68693          	addi	a3,a3,-194 # ffffffffc02076b8 <commands+0xf68>
ffffffffc0202782:	00004617          	auipc	a2,0x4
ffffffffc0202786:	3de60613          	addi	a2,a2,990 # ffffffffc0206b60 <commands+0x410>
ffffffffc020278a:	09d00593          	li	a1,157
ffffffffc020278e:	00005517          	auipc	a0,0x5
ffffffffc0202792:	d7250513          	addi	a0,a0,-654 # ffffffffc0207500 <commands+0xdb0>
ffffffffc0202796:	a73fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc020279a:	00005697          	auipc	a3,0x5
ffffffffc020279e:	efe68693          	addi	a3,a3,-258 # ffffffffc0207698 <commands+0xf48>
ffffffffc02027a2:	00004617          	auipc	a2,0x4
ffffffffc02027a6:	3be60613          	addi	a2,a2,958 # ffffffffc0206b60 <commands+0x410>
ffffffffc02027aa:	09300593          	li	a1,147
ffffffffc02027ae:	00005517          	auipc	a0,0x5
ffffffffc02027b2:	d5250513          	addi	a0,a0,-686 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02027b6:	a53fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02027ba <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02027ba:	000b0797          	auipc	a5,0xb0
ffffffffc02027be:	2767b783          	ld	a5,630(a5) # ffffffffc02b2a30 <sm>
ffffffffc02027c2:	6b9c                	ld	a5,16(a5)
ffffffffc02027c4:	8782                	jr	a5

ffffffffc02027c6 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02027c6:	000b0797          	auipc	a5,0xb0
ffffffffc02027ca:	26a7b783          	ld	a5,618(a5) # ffffffffc02b2a30 <sm>
ffffffffc02027ce:	739c                	ld	a5,32(a5)
ffffffffc02027d0:	8782                	jr	a5

ffffffffc02027d2 <swap_out>:
{
ffffffffc02027d2:	711d                	addi	sp,sp,-96
ffffffffc02027d4:	ec86                	sd	ra,88(sp)
ffffffffc02027d6:	e8a2                	sd	s0,80(sp)
ffffffffc02027d8:	e4a6                	sd	s1,72(sp)
ffffffffc02027da:	e0ca                	sd	s2,64(sp)
ffffffffc02027dc:	fc4e                	sd	s3,56(sp)
ffffffffc02027de:	f852                	sd	s4,48(sp)
ffffffffc02027e0:	f456                	sd	s5,40(sp)
ffffffffc02027e2:	f05a                	sd	s6,32(sp)
ffffffffc02027e4:	ec5e                	sd	s7,24(sp)
ffffffffc02027e6:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02027e8:	cde9                	beqz	a1,ffffffffc02028c2 <swap_out+0xf0>
ffffffffc02027ea:	8a2e                	mv	s4,a1
ffffffffc02027ec:	892a                	mv	s2,a0
ffffffffc02027ee:	8ab2                	mv	s5,a2
ffffffffc02027f0:	4401                	li	s0,0
ffffffffc02027f2:	000b0997          	auipc	s3,0xb0
ffffffffc02027f6:	23e98993          	addi	s3,s3,574 # ffffffffc02b2a30 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02027fa:	00005b17          	auipc	s6,0x5
ffffffffc02027fe:	016b0b13          	addi	s6,s6,22 # ffffffffc0207810 <commands+0x10c0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202802:	00005b97          	auipc	s7,0x5
ffffffffc0202806:	ff6b8b93          	addi	s7,s7,-10 # ffffffffc02077f8 <commands+0x10a8>
ffffffffc020280a:	a825                	j	ffffffffc0202842 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020280c:	67a2                	ld	a5,8(sp)
ffffffffc020280e:	8626                	mv	a2,s1
ffffffffc0202810:	85a2                	mv	a1,s0
ffffffffc0202812:	7f94                	ld	a3,56(a5)
ffffffffc0202814:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202816:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202818:	82b1                	srli	a3,a3,0xc
ffffffffc020281a:	0685                	addi	a3,a3,1
ffffffffc020281c:	8b1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202820:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202822:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202824:	7d1c                	ld	a5,56(a0)
ffffffffc0202826:	83b1                	srli	a5,a5,0xc
ffffffffc0202828:	0785                	addi	a5,a5,1
ffffffffc020282a:	07a2                	slli	a5,a5,0x8
ffffffffc020282c:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202830:	4a9000ef          	jal	ra,ffffffffc02034d8 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202834:	01893503          	ld	a0,24(s2)
ffffffffc0202838:	85a6                	mv	a1,s1
ffffffffc020283a:	1ce020ef          	jal	ra,ffffffffc0204a08 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020283e:	048a0d63          	beq	s4,s0,ffffffffc0202898 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202842:	0009b783          	ld	a5,0(s3)
ffffffffc0202846:	8656                	mv	a2,s5
ffffffffc0202848:	002c                	addi	a1,sp,8
ffffffffc020284a:	7b9c                	ld	a5,48(a5)
ffffffffc020284c:	854a                	mv	a0,s2
ffffffffc020284e:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202850:	e12d                	bnez	a0,ffffffffc02028b2 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202852:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202854:	01893503          	ld	a0,24(s2)
ffffffffc0202858:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020285a:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020285c:	85a6                	mv	a1,s1
ffffffffc020285e:	4f5000ef          	jal	ra,ffffffffc0203552 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202862:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202864:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202866:	8b85                	andi	a5,a5,1
ffffffffc0202868:	cfb9                	beqz	a5,ffffffffc02028c6 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020286a:	65a2                	ld	a1,8(sp)
ffffffffc020286c:	7d9c                	ld	a5,56(a1)
ffffffffc020286e:	83b1                	srli	a5,a5,0xc
ffffffffc0202870:	0785                	addi	a5,a5,1
ffffffffc0202872:	00879513          	slli	a0,a5,0x8
ffffffffc0202876:	318020ef          	jal	ra,ffffffffc0204b8e <swapfs_write>
ffffffffc020287a:	d949                	beqz	a0,ffffffffc020280c <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020287c:	855e                	mv	a0,s7
ffffffffc020287e:	84ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202882:	0009b783          	ld	a5,0(s3)
ffffffffc0202886:	6622                	ld	a2,8(sp)
ffffffffc0202888:	4681                	li	a3,0
ffffffffc020288a:	739c                	ld	a5,32(a5)
ffffffffc020288c:	85a6                	mv	a1,s1
ffffffffc020288e:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202890:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202892:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202894:	fa8a17e3          	bne	s4,s0,ffffffffc0202842 <swap_out+0x70>
}
ffffffffc0202898:	60e6                	ld	ra,88(sp)
ffffffffc020289a:	8522                	mv	a0,s0
ffffffffc020289c:	6446                	ld	s0,80(sp)
ffffffffc020289e:	64a6                	ld	s1,72(sp)
ffffffffc02028a0:	6906                	ld	s2,64(sp)
ffffffffc02028a2:	79e2                	ld	s3,56(sp)
ffffffffc02028a4:	7a42                	ld	s4,48(sp)
ffffffffc02028a6:	7aa2                	ld	s5,40(sp)
ffffffffc02028a8:	7b02                	ld	s6,32(sp)
ffffffffc02028aa:	6be2                	ld	s7,24(sp)
ffffffffc02028ac:	6c42                	ld	s8,16(sp)
ffffffffc02028ae:	6125                	addi	sp,sp,96
ffffffffc02028b0:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02028b2:	85a2                	mv	a1,s0
ffffffffc02028b4:	00005517          	auipc	a0,0x5
ffffffffc02028b8:	efc50513          	addi	a0,a0,-260 # ffffffffc02077b0 <commands+0x1060>
ffffffffc02028bc:	811fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc02028c0:	bfe1                	j	ffffffffc0202898 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02028c2:	4401                	li	s0,0
ffffffffc02028c4:	bfd1                	j	ffffffffc0202898 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02028c6:	00005697          	auipc	a3,0x5
ffffffffc02028ca:	f1a68693          	addi	a3,a3,-230 # ffffffffc02077e0 <commands+0x1090>
ffffffffc02028ce:	00004617          	auipc	a2,0x4
ffffffffc02028d2:	29260613          	addi	a2,a2,658 # ffffffffc0206b60 <commands+0x410>
ffffffffc02028d6:	06800593          	li	a1,104
ffffffffc02028da:	00005517          	auipc	a0,0x5
ffffffffc02028de:	c2650513          	addi	a0,a0,-986 # ffffffffc0207500 <commands+0xdb0>
ffffffffc02028e2:	927fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02028e6 <swap_in>:
{
ffffffffc02028e6:	7179                	addi	sp,sp,-48
ffffffffc02028e8:	e84a                	sd	s2,16(sp)
ffffffffc02028ea:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02028ec:	4505                	li	a0,1
{
ffffffffc02028ee:	ec26                	sd	s1,24(sp)
ffffffffc02028f0:	e44e                	sd	s3,8(sp)
ffffffffc02028f2:	f406                	sd	ra,40(sp)
ffffffffc02028f4:	f022                	sd	s0,32(sp)
ffffffffc02028f6:	84ae                	mv	s1,a1
ffffffffc02028f8:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02028fa:	34d000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
     assert(result!=NULL);
ffffffffc02028fe:	c129                	beqz	a0,ffffffffc0202940 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202900:	842a                	mv	s0,a0
ffffffffc0202902:	01893503          	ld	a0,24(s2)
ffffffffc0202906:	4601                	li	a2,0
ffffffffc0202908:	85a6                	mv	a1,s1
ffffffffc020290a:	449000ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc020290e:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202910:	6108                	ld	a0,0(a0)
ffffffffc0202912:	85a2                	mv	a1,s0
ffffffffc0202914:	1ec020ef          	jal	ra,ffffffffc0204b00 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202918:	00093583          	ld	a1,0(s2)
ffffffffc020291c:	8626                	mv	a2,s1
ffffffffc020291e:	00005517          	auipc	a0,0x5
ffffffffc0202922:	f4250513          	addi	a0,a0,-190 # ffffffffc0207860 <commands+0x1110>
ffffffffc0202926:	81a1                	srli	a1,a1,0x8
ffffffffc0202928:	fa4fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020292c:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020292e:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202932:	7402                	ld	s0,32(sp)
ffffffffc0202934:	64e2                	ld	s1,24(sp)
ffffffffc0202936:	6942                	ld	s2,16(sp)
ffffffffc0202938:	69a2                	ld	s3,8(sp)
ffffffffc020293a:	4501                	li	a0,0
ffffffffc020293c:	6145                	addi	sp,sp,48
ffffffffc020293e:	8082                	ret
     assert(result!=NULL);
ffffffffc0202940:	00005697          	auipc	a3,0x5
ffffffffc0202944:	f1068693          	addi	a3,a3,-240 # ffffffffc0207850 <commands+0x1100>
ffffffffc0202948:	00004617          	auipc	a2,0x4
ffffffffc020294c:	21860613          	addi	a2,a2,536 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202950:	07e00593          	li	a1,126
ffffffffc0202954:	00005517          	auipc	a0,0x5
ffffffffc0202958:	bac50513          	addi	a0,a0,-1108 # ffffffffc0207500 <commands+0xdb0>
ffffffffc020295c:	8adfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202960 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202960:	000ac797          	auipc	a5,0xac
ffffffffc0202964:	07078793          	addi	a5,a5,112 # ffffffffc02ae9d0 <free_area>
ffffffffc0202968:	e79c                	sd	a5,8(a5)
ffffffffc020296a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020296c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202970:	8082                	ret

ffffffffc0202972 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202972:	000ac517          	auipc	a0,0xac
ffffffffc0202976:	06e56503          	lwu	a0,110(a0) # ffffffffc02ae9e0 <free_area+0x10>
ffffffffc020297a:	8082                	ret

ffffffffc020297c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020297c:	715d                	addi	sp,sp,-80
ffffffffc020297e:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202980:	000ac417          	auipc	s0,0xac
ffffffffc0202984:	05040413          	addi	s0,s0,80 # ffffffffc02ae9d0 <free_area>
ffffffffc0202988:	641c                	ld	a5,8(s0)
ffffffffc020298a:	e486                	sd	ra,72(sp)
ffffffffc020298c:	fc26                	sd	s1,56(sp)
ffffffffc020298e:	f84a                	sd	s2,48(sp)
ffffffffc0202990:	f44e                	sd	s3,40(sp)
ffffffffc0202992:	f052                	sd	s4,32(sp)
ffffffffc0202994:	ec56                	sd	s5,24(sp)
ffffffffc0202996:	e85a                	sd	s6,16(sp)
ffffffffc0202998:	e45e                	sd	s7,8(sp)
ffffffffc020299a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020299c:	2a878d63          	beq	a5,s0,ffffffffc0202c56 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02029a0:	4481                	li	s1,0
ffffffffc02029a2:	4901                	li	s2,0
ffffffffc02029a4:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02029a8:	8b09                	andi	a4,a4,2
ffffffffc02029aa:	2a070a63          	beqz	a4,ffffffffc0202c5e <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc02029ae:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029b2:	679c                	ld	a5,8(a5)
ffffffffc02029b4:	2905                	addiw	s2,s2,1
ffffffffc02029b6:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02029b8:	fe8796e3          	bne	a5,s0,ffffffffc02029a4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02029bc:	89a6                	mv	s3,s1
ffffffffc02029be:	35b000ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc02029c2:	6f351e63          	bne	a0,s3,ffffffffc02030be <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02029c6:	4505                	li	a0,1
ffffffffc02029c8:	27f000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02029cc:	8aaa                	mv	s5,a0
ffffffffc02029ce:	42050863          	beqz	a0,ffffffffc0202dfe <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02029d2:	4505                	li	a0,1
ffffffffc02029d4:	273000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02029d8:	89aa                	mv	s3,a0
ffffffffc02029da:	70050263          	beqz	a0,ffffffffc02030de <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029de:	4505                	li	a0,1
ffffffffc02029e0:	267000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02029e4:	8a2a                	mv	s4,a0
ffffffffc02029e6:	48050c63          	beqz	a0,ffffffffc0202e7e <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02029ea:	293a8a63          	beq	s5,s3,ffffffffc0202c7e <default_check+0x302>
ffffffffc02029ee:	28aa8863          	beq	s5,a0,ffffffffc0202c7e <default_check+0x302>
ffffffffc02029f2:	28a98663          	beq	s3,a0,ffffffffc0202c7e <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02029f6:	000aa783          	lw	a5,0(s5)
ffffffffc02029fa:	2a079263          	bnez	a5,ffffffffc0202c9e <default_check+0x322>
ffffffffc02029fe:	0009a783          	lw	a5,0(s3)
ffffffffc0202a02:	28079e63          	bnez	a5,ffffffffc0202c9e <default_check+0x322>
ffffffffc0202a06:	411c                	lw	a5,0(a0)
ffffffffc0202a08:	28079b63          	bnez	a5,ffffffffc0202c9e <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202a0c:	000b0797          	auipc	a5,0xb0
ffffffffc0202a10:	04c7b783          	ld	a5,76(a5) # ffffffffc02b2a58 <pages>
ffffffffc0202a14:	40fa8733          	sub	a4,s5,a5
ffffffffc0202a18:	00006617          	auipc	a2,0x6
ffffffffc0202a1c:	15063603          	ld	a2,336(a2) # ffffffffc0208b68 <nbase>
ffffffffc0202a20:	8719                	srai	a4,a4,0x6
ffffffffc0202a22:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202a24:	000b0697          	auipc	a3,0xb0
ffffffffc0202a28:	02c6b683          	ld	a3,44(a3) # ffffffffc02b2a50 <npage>
ffffffffc0202a2c:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a2e:	0732                	slli	a4,a4,0xc
ffffffffc0202a30:	28d77763          	bgeu	a4,a3,ffffffffc0202cbe <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202a34:	40f98733          	sub	a4,s3,a5
ffffffffc0202a38:	8719                	srai	a4,a4,0x6
ffffffffc0202a3a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a3c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202a3e:	4cd77063          	bgeu	a4,a3,ffffffffc0202efe <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202a42:	40f507b3          	sub	a5,a0,a5
ffffffffc0202a46:	8799                	srai	a5,a5,0x6
ffffffffc0202a48:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a4a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202a4c:	30d7f963          	bgeu	a5,a3,ffffffffc0202d5e <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0202a50:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202a52:	00043c03          	ld	s8,0(s0)
ffffffffc0202a56:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202a5a:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202a5e:	e400                	sd	s0,8(s0)
ffffffffc0202a60:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202a62:	000ac797          	auipc	a5,0xac
ffffffffc0202a66:	f607af23          	sw	zero,-130(a5) # ffffffffc02ae9e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202a6a:	1dd000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202a6e:	2c051863          	bnez	a0,ffffffffc0202d3e <default_check+0x3c2>
    free_page(p0);
ffffffffc0202a72:	4585                	li	a1,1
ffffffffc0202a74:	8556                	mv	a0,s5
ffffffffc0202a76:	263000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p1);
ffffffffc0202a7a:	4585                	li	a1,1
ffffffffc0202a7c:	854e                	mv	a0,s3
ffffffffc0202a7e:	25b000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p2);
ffffffffc0202a82:	4585                	li	a1,1
ffffffffc0202a84:	8552                	mv	a0,s4
ffffffffc0202a86:	253000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert(nr_free == 3);
ffffffffc0202a8a:	4818                	lw	a4,16(s0)
ffffffffc0202a8c:	478d                	li	a5,3
ffffffffc0202a8e:	28f71863          	bne	a4,a5,ffffffffc0202d1e <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202a92:	4505                	li	a0,1
ffffffffc0202a94:	1b3000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202a98:	89aa                	mv	s3,a0
ffffffffc0202a9a:	26050263          	beqz	a0,ffffffffc0202cfe <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202a9e:	4505                	li	a0,1
ffffffffc0202aa0:	1a7000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202aa4:	8aaa                	mv	s5,a0
ffffffffc0202aa6:	3a050c63          	beqz	a0,ffffffffc0202e5e <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202aaa:	4505                	li	a0,1
ffffffffc0202aac:	19b000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202ab0:	8a2a                	mv	s4,a0
ffffffffc0202ab2:	38050663          	beqz	a0,ffffffffc0202e3e <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202ab6:	4505                	li	a0,1
ffffffffc0202ab8:	18f000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202abc:	36051163          	bnez	a0,ffffffffc0202e1e <default_check+0x4a2>
    free_page(p0);
ffffffffc0202ac0:	4585                	li	a1,1
ffffffffc0202ac2:	854e                	mv	a0,s3
ffffffffc0202ac4:	215000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202ac8:	641c                	ld	a5,8(s0)
ffffffffc0202aca:	20878a63          	beq	a5,s0,ffffffffc0202cde <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202ace:	4505                	li	a0,1
ffffffffc0202ad0:	177000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202ad4:	30a99563          	bne	s3,a0,ffffffffc0202dde <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202ad8:	4505                	li	a0,1
ffffffffc0202ada:	16d000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202ade:	2e051063          	bnez	a0,ffffffffc0202dbe <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202ae2:	481c                	lw	a5,16(s0)
ffffffffc0202ae4:	2a079d63          	bnez	a5,ffffffffc0202d9e <default_check+0x422>
    free_page(p);
ffffffffc0202ae8:	854e                	mv	a0,s3
ffffffffc0202aea:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202aec:	01843023          	sd	s8,0(s0)
ffffffffc0202af0:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202af4:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202af8:	1e1000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p1);
ffffffffc0202afc:	4585                	li	a1,1
ffffffffc0202afe:	8556                	mv	a0,s5
ffffffffc0202b00:	1d9000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p2);
ffffffffc0202b04:	4585                	li	a1,1
ffffffffc0202b06:	8552                	mv	a0,s4
ffffffffc0202b08:	1d1000ef          	jal	ra,ffffffffc02034d8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202b0c:	4515                	li	a0,5
ffffffffc0202b0e:	139000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b12:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202b14:	26050563          	beqz	a0,ffffffffc0202d7e <default_check+0x402>
ffffffffc0202b18:	651c                	ld	a5,8(a0)
ffffffffc0202b1a:	8385                	srli	a5,a5,0x1
ffffffffc0202b1c:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202b1e:	54079063          	bnez	a5,ffffffffc020305e <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202b22:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202b24:	00043b03          	ld	s6,0(s0)
ffffffffc0202b28:	00843a83          	ld	s5,8(s0)
ffffffffc0202b2c:	e000                	sd	s0,0(s0)
ffffffffc0202b2e:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202b30:	117000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b34:	50051563          	bnez	a0,ffffffffc020303e <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202b38:	08098a13          	addi	s4,s3,128
ffffffffc0202b3c:	8552                	mv	a0,s4
ffffffffc0202b3e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202b40:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202b44:	000ac797          	auipc	a5,0xac
ffffffffc0202b48:	e807ae23          	sw	zero,-356(a5) # ffffffffc02ae9e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202b4c:	18d000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202b50:	4511                	li	a0,4
ffffffffc0202b52:	0f5000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b56:	4c051463          	bnez	a0,ffffffffc020301e <default_check+0x6a2>
ffffffffc0202b5a:	0889b783          	ld	a5,136(s3)
ffffffffc0202b5e:	8385                	srli	a5,a5,0x1
ffffffffc0202b60:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202b62:	48078e63          	beqz	a5,ffffffffc0202ffe <default_check+0x682>
ffffffffc0202b66:	0909a703          	lw	a4,144(s3)
ffffffffc0202b6a:	478d                	li	a5,3
ffffffffc0202b6c:	48f71963          	bne	a4,a5,ffffffffc0202ffe <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202b70:	450d                	li	a0,3
ffffffffc0202b72:	0d5000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b76:	8c2a                	mv	s8,a0
ffffffffc0202b78:	46050363          	beqz	a0,ffffffffc0202fde <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202b7c:	4505                	li	a0,1
ffffffffc0202b7e:	0c9000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b82:	42051e63          	bnez	a0,ffffffffc0202fbe <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202b86:	418a1c63          	bne	s4,s8,ffffffffc0202f9e <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202b8a:	4585                	li	a1,1
ffffffffc0202b8c:	854e                	mv	a0,s3
ffffffffc0202b8e:	14b000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_pages(p1, 3);
ffffffffc0202b92:	458d                	li	a1,3
ffffffffc0202b94:	8552                	mv	a0,s4
ffffffffc0202b96:	143000ef          	jal	ra,ffffffffc02034d8 <free_pages>
ffffffffc0202b9a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202b9e:	04098c13          	addi	s8,s3,64
ffffffffc0202ba2:	8385                	srli	a5,a5,0x1
ffffffffc0202ba4:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202ba6:	3c078c63          	beqz	a5,ffffffffc0202f7e <default_check+0x602>
ffffffffc0202baa:	0109a703          	lw	a4,16(s3)
ffffffffc0202bae:	4785                	li	a5,1
ffffffffc0202bb0:	3cf71763          	bne	a4,a5,ffffffffc0202f7e <default_check+0x602>
ffffffffc0202bb4:	008a3783          	ld	a5,8(s4)
ffffffffc0202bb8:	8385                	srli	a5,a5,0x1
ffffffffc0202bba:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202bbc:	3a078163          	beqz	a5,ffffffffc0202f5e <default_check+0x5e2>
ffffffffc0202bc0:	010a2703          	lw	a4,16(s4)
ffffffffc0202bc4:	478d                	li	a5,3
ffffffffc0202bc6:	38f71c63          	bne	a4,a5,ffffffffc0202f5e <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202bca:	4505                	li	a0,1
ffffffffc0202bcc:	07b000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202bd0:	36a99763          	bne	s3,a0,ffffffffc0202f3e <default_check+0x5c2>
    free_page(p0);
ffffffffc0202bd4:	4585                	li	a1,1
ffffffffc0202bd6:	103000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202bda:	4509                	li	a0,2
ffffffffc0202bdc:	06b000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202be0:	32aa1f63          	bne	s4,a0,ffffffffc0202f1e <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202be4:	4589                	li	a1,2
ffffffffc0202be6:	0f3000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p2);
ffffffffc0202bea:	4585                	li	a1,1
ffffffffc0202bec:	8562                	mv	a0,s8
ffffffffc0202bee:	0eb000ef          	jal	ra,ffffffffc02034d8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202bf2:	4515                	li	a0,5
ffffffffc0202bf4:	053000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202bf8:	89aa                	mv	s3,a0
ffffffffc0202bfa:	48050263          	beqz	a0,ffffffffc020307e <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202bfe:	4505                	li	a0,1
ffffffffc0202c00:	047000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202c04:	2c051d63          	bnez	a0,ffffffffc0202ede <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202c08:	481c                	lw	a5,16(s0)
ffffffffc0202c0a:	2a079a63          	bnez	a5,ffffffffc0202ebe <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202c0e:	4595                	li	a1,5
ffffffffc0202c10:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202c12:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202c16:	01643023          	sd	s6,0(s0)
ffffffffc0202c1a:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202c1e:	0bb000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    return listelm->next;
ffffffffc0202c22:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c24:	00878963          	beq	a5,s0,ffffffffc0202c36 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202c28:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c2c:	679c                	ld	a5,8(a5)
ffffffffc0202c2e:	397d                	addiw	s2,s2,-1
ffffffffc0202c30:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c32:	fe879be3          	bne	a5,s0,ffffffffc0202c28 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202c36:	26091463          	bnez	s2,ffffffffc0202e9e <default_check+0x522>
    assert(total == 0);
ffffffffc0202c3a:	46049263          	bnez	s1,ffffffffc020309e <default_check+0x722>
}
ffffffffc0202c3e:	60a6                	ld	ra,72(sp)
ffffffffc0202c40:	6406                	ld	s0,64(sp)
ffffffffc0202c42:	74e2                	ld	s1,56(sp)
ffffffffc0202c44:	7942                	ld	s2,48(sp)
ffffffffc0202c46:	79a2                	ld	s3,40(sp)
ffffffffc0202c48:	7a02                	ld	s4,32(sp)
ffffffffc0202c4a:	6ae2                	ld	s5,24(sp)
ffffffffc0202c4c:	6b42                	ld	s6,16(sp)
ffffffffc0202c4e:	6ba2                	ld	s7,8(sp)
ffffffffc0202c50:	6c02                	ld	s8,0(sp)
ffffffffc0202c52:	6161                	addi	sp,sp,80
ffffffffc0202c54:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c56:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202c58:	4481                	li	s1,0
ffffffffc0202c5a:	4901                	li	s2,0
ffffffffc0202c5c:	b38d                	j	ffffffffc02029be <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202c5e:	00005697          	auipc	a3,0x5
ffffffffc0202c62:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0207528 <commands+0xdd8>
ffffffffc0202c66:	00004617          	auipc	a2,0x4
ffffffffc0202c6a:	efa60613          	addi	a2,a2,-262 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202c6e:	0f000593          	li	a1,240
ffffffffc0202c72:	00005517          	auipc	a0,0x5
ffffffffc0202c76:	c2e50513          	addi	a0,a0,-978 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202c7a:	d8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202c7e:	00005697          	auipc	a3,0x5
ffffffffc0202c82:	c9a68693          	addi	a3,a3,-870 # ffffffffc0207918 <commands+0x11c8>
ffffffffc0202c86:	00004617          	auipc	a2,0x4
ffffffffc0202c8a:	eda60613          	addi	a2,a2,-294 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202c8e:	0bd00593          	li	a1,189
ffffffffc0202c92:	00005517          	auipc	a0,0x5
ffffffffc0202c96:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202c9a:	d6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202c9e:	00005697          	auipc	a3,0x5
ffffffffc0202ca2:	ca268693          	addi	a3,a3,-862 # ffffffffc0207940 <commands+0x11f0>
ffffffffc0202ca6:	00004617          	auipc	a2,0x4
ffffffffc0202caa:	eba60613          	addi	a2,a2,-326 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202cae:	0be00593          	li	a1,190
ffffffffc0202cb2:	00005517          	auipc	a0,0x5
ffffffffc0202cb6:	bee50513          	addi	a0,a0,-1042 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202cba:	d4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202cbe:	00005697          	auipc	a3,0x5
ffffffffc0202cc2:	cc268693          	addi	a3,a3,-830 # ffffffffc0207980 <commands+0x1230>
ffffffffc0202cc6:	00004617          	auipc	a2,0x4
ffffffffc0202cca:	e9a60613          	addi	a2,a2,-358 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202cce:	0c000593          	li	a1,192
ffffffffc0202cd2:	00005517          	auipc	a0,0x5
ffffffffc0202cd6:	bce50513          	addi	a0,a0,-1074 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202cda:	d2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202cde:	00005697          	auipc	a3,0x5
ffffffffc0202ce2:	d2a68693          	addi	a3,a3,-726 # ffffffffc0207a08 <commands+0x12b8>
ffffffffc0202ce6:	00004617          	auipc	a2,0x4
ffffffffc0202cea:	e7a60613          	addi	a2,a2,-390 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202cee:	0d900593          	li	a1,217
ffffffffc0202cf2:	00005517          	auipc	a0,0x5
ffffffffc0202cf6:	bae50513          	addi	a0,a0,-1106 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202cfa:	d0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202cfe:	00005697          	auipc	a3,0x5
ffffffffc0202d02:	bba68693          	addi	a3,a3,-1094 # ffffffffc02078b8 <commands+0x1168>
ffffffffc0202d06:	00004617          	auipc	a2,0x4
ffffffffc0202d0a:	e5a60613          	addi	a2,a2,-422 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202d0e:	0d200593          	li	a1,210
ffffffffc0202d12:	00005517          	auipc	a0,0x5
ffffffffc0202d16:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202d1a:	ceefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0202d1e:	00005697          	auipc	a3,0x5
ffffffffc0202d22:	cda68693          	addi	a3,a3,-806 # ffffffffc02079f8 <commands+0x12a8>
ffffffffc0202d26:	00004617          	auipc	a2,0x4
ffffffffc0202d2a:	e3a60613          	addi	a2,a2,-454 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202d2e:	0d000593          	li	a1,208
ffffffffc0202d32:	00005517          	auipc	a0,0x5
ffffffffc0202d36:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202d3a:	ccefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202d3e:	00005697          	auipc	a3,0x5
ffffffffc0202d42:	ca268693          	addi	a3,a3,-862 # ffffffffc02079e0 <commands+0x1290>
ffffffffc0202d46:	00004617          	auipc	a2,0x4
ffffffffc0202d4a:	e1a60613          	addi	a2,a2,-486 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202d4e:	0cb00593          	li	a1,203
ffffffffc0202d52:	00005517          	auipc	a0,0x5
ffffffffc0202d56:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202d5a:	caefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202d5e:	00005697          	auipc	a3,0x5
ffffffffc0202d62:	c6268693          	addi	a3,a3,-926 # ffffffffc02079c0 <commands+0x1270>
ffffffffc0202d66:	00004617          	auipc	a2,0x4
ffffffffc0202d6a:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202d6e:	0c200593          	li	a1,194
ffffffffc0202d72:	00005517          	auipc	a0,0x5
ffffffffc0202d76:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202d7a:	c8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc0202d7e:	00005697          	auipc	a3,0x5
ffffffffc0202d82:	cc268693          	addi	a3,a3,-830 # ffffffffc0207a40 <commands+0x12f0>
ffffffffc0202d86:	00004617          	auipc	a2,0x4
ffffffffc0202d8a:	dda60613          	addi	a2,a2,-550 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202d8e:	0f800593          	li	a1,248
ffffffffc0202d92:	00005517          	auipc	a0,0x5
ffffffffc0202d96:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202d9a:	c6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202d9e:	00005697          	auipc	a3,0x5
ffffffffc0202da2:	92a68693          	addi	a3,a3,-1750 # ffffffffc02076c8 <commands+0xf78>
ffffffffc0202da6:	00004617          	auipc	a2,0x4
ffffffffc0202daa:	dba60613          	addi	a2,a2,-582 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202dae:	0df00593          	li	a1,223
ffffffffc0202db2:	00005517          	auipc	a0,0x5
ffffffffc0202db6:	aee50513          	addi	a0,a0,-1298 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202dba:	c4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202dbe:	00005697          	auipc	a3,0x5
ffffffffc0202dc2:	c2268693          	addi	a3,a3,-990 # ffffffffc02079e0 <commands+0x1290>
ffffffffc0202dc6:	00004617          	auipc	a2,0x4
ffffffffc0202dca:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202dce:	0dd00593          	li	a1,221
ffffffffc0202dd2:	00005517          	auipc	a0,0x5
ffffffffc0202dd6:	ace50513          	addi	a0,a0,-1330 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202dda:	c2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202dde:	00005697          	auipc	a3,0x5
ffffffffc0202de2:	c4268693          	addi	a3,a3,-958 # ffffffffc0207a20 <commands+0x12d0>
ffffffffc0202de6:	00004617          	auipc	a2,0x4
ffffffffc0202dea:	d7a60613          	addi	a2,a2,-646 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202dee:	0dc00593          	li	a1,220
ffffffffc0202df2:	00005517          	auipc	a0,0x5
ffffffffc0202df6:	aae50513          	addi	a0,a0,-1362 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202dfa:	c0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202dfe:	00005697          	auipc	a3,0x5
ffffffffc0202e02:	aba68693          	addi	a3,a3,-1350 # ffffffffc02078b8 <commands+0x1168>
ffffffffc0202e06:	00004617          	auipc	a2,0x4
ffffffffc0202e0a:	d5a60613          	addi	a2,a2,-678 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202e0e:	0b900593          	li	a1,185
ffffffffc0202e12:	00005517          	auipc	a0,0x5
ffffffffc0202e16:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202e1a:	beefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202e1e:	00005697          	auipc	a3,0x5
ffffffffc0202e22:	bc268693          	addi	a3,a3,-1086 # ffffffffc02079e0 <commands+0x1290>
ffffffffc0202e26:	00004617          	auipc	a2,0x4
ffffffffc0202e2a:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202e2e:	0d600593          	li	a1,214
ffffffffc0202e32:	00005517          	auipc	a0,0x5
ffffffffc0202e36:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202e3a:	bcefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e3e:	00005697          	auipc	a3,0x5
ffffffffc0202e42:	aba68693          	addi	a3,a3,-1350 # ffffffffc02078f8 <commands+0x11a8>
ffffffffc0202e46:	00004617          	auipc	a2,0x4
ffffffffc0202e4a:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202e4e:	0d400593          	li	a1,212
ffffffffc0202e52:	00005517          	auipc	a0,0x5
ffffffffc0202e56:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202e5a:	baefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202e5e:	00005697          	auipc	a3,0x5
ffffffffc0202e62:	a7a68693          	addi	a3,a3,-1414 # ffffffffc02078d8 <commands+0x1188>
ffffffffc0202e66:	00004617          	auipc	a2,0x4
ffffffffc0202e6a:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202e6e:	0d300593          	li	a1,211
ffffffffc0202e72:	00005517          	auipc	a0,0x5
ffffffffc0202e76:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202e7a:	b8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e7e:	00005697          	auipc	a3,0x5
ffffffffc0202e82:	a7a68693          	addi	a3,a3,-1414 # ffffffffc02078f8 <commands+0x11a8>
ffffffffc0202e86:	00004617          	auipc	a2,0x4
ffffffffc0202e8a:	cda60613          	addi	a2,a2,-806 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202e8e:	0bb00593          	li	a1,187
ffffffffc0202e92:	00005517          	auipc	a0,0x5
ffffffffc0202e96:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202e9a:	b6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0202e9e:	00005697          	auipc	a3,0x5
ffffffffc0202ea2:	cf268693          	addi	a3,a3,-782 # ffffffffc0207b90 <commands+0x1440>
ffffffffc0202ea6:	00004617          	auipc	a2,0x4
ffffffffc0202eaa:	cba60613          	addi	a2,a2,-838 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202eae:	12500593          	li	a1,293
ffffffffc0202eb2:	00005517          	auipc	a0,0x5
ffffffffc0202eb6:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202eba:	b4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202ebe:	00005697          	auipc	a3,0x5
ffffffffc0202ec2:	80a68693          	addi	a3,a3,-2038 # ffffffffc02076c8 <commands+0xf78>
ffffffffc0202ec6:	00004617          	auipc	a2,0x4
ffffffffc0202eca:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202ece:	11a00593          	li	a1,282
ffffffffc0202ed2:	00005517          	auipc	a0,0x5
ffffffffc0202ed6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202eda:	b2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ede:	00005697          	auipc	a3,0x5
ffffffffc0202ee2:	b0268693          	addi	a3,a3,-1278 # ffffffffc02079e0 <commands+0x1290>
ffffffffc0202ee6:	00004617          	auipc	a2,0x4
ffffffffc0202eea:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202eee:	11800593          	li	a1,280
ffffffffc0202ef2:	00005517          	auipc	a0,0x5
ffffffffc0202ef6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202efa:	b0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202efe:	00005697          	auipc	a3,0x5
ffffffffc0202f02:	aa268693          	addi	a3,a3,-1374 # ffffffffc02079a0 <commands+0x1250>
ffffffffc0202f06:	00004617          	auipc	a2,0x4
ffffffffc0202f0a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202f0e:	0c100593          	li	a1,193
ffffffffc0202f12:	00005517          	auipc	a0,0x5
ffffffffc0202f16:	98e50513          	addi	a0,a0,-1650 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202f1a:	aeefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202f1e:	00005697          	auipc	a3,0x5
ffffffffc0202f22:	c3268693          	addi	a3,a3,-974 # ffffffffc0207b50 <commands+0x1400>
ffffffffc0202f26:	00004617          	auipc	a2,0x4
ffffffffc0202f2a:	c3a60613          	addi	a2,a2,-966 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202f2e:	11200593          	li	a1,274
ffffffffc0202f32:	00005517          	auipc	a0,0x5
ffffffffc0202f36:	96e50513          	addi	a0,a0,-1682 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202f3a:	acefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202f3e:	00005697          	auipc	a3,0x5
ffffffffc0202f42:	bf268693          	addi	a3,a3,-1038 # ffffffffc0207b30 <commands+0x13e0>
ffffffffc0202f46:	00004617          	auipc	a2,0x4
ffffffffc0202f4a:	c1a60613          	addi	a2,a2,-998 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202f4e:	11000593          	li	a1,272
ffffffffc0202f52:	00005517          	auipc	a0,0x5
ffffffffc0202f56:	94e50513          	addi	a0,a0,-1714 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202f5a:	aaefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202f5e:	00005697          	auipc	a3,0x5
ffffffffc0202f62:	baa68693          	addi	a3,a3,-1110 # ffffffffc0207b08 <commands+0x13b8>
ffffffffc0202f66:	00004617          	auipc	a2,0x4
ffffffffc0202f6a:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202f6e:	10e00593          	li	a1,270
ffffffffc0202f72:	00005517          	auipc	a0,0x5
ffffffffc0202f76:	92e50513          	addi	a0,a0,-1746 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202f7a:	a8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202f7e:	00005697          	auipc	a3,0x5
ffffffffc0202f82:	b6268693          	addi	a3,a3,-1182 # ffffffffc0207ae0 <commands+0x1390>
ffffffffc0202f86:	00004617          	auipc	a2,0x4
ffffffffc0202f8a:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202f8e:	10d00593          	li	a1,269
ffffffffc0202f92:	00005517          	auipc	a0,0x5
ffffffffc0202f96:	90e50513          	addi	a0,a0,-1778 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202f9a:	a6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202f9e:	00005697          	auipc	a3,0x5
ffffffffc0202fa2:	b3268693          	addi	a3,a3,-1230 # ffffffffc0207ad0 <commands+0x1380>
ffffffffc0202fa6:	00004617          	auipc	a2,0x4
ffffffffc0202faa:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202fae:	10800593          	li	a1,264
ffffffffc0202fb2:	00005517          	auipc	a0,0x5
ffffffffc0202fb6:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202fba:	a4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202fbe:	00005697          	auipc	a3,0x5
ffffffffc0202fc2:	a2268693          	addi	a3,a3,-1502 # ffffffffc02079e0 <commands+0x1290>
ffffffffc0202fc6:	00004617          	auipc	a2,0x4
ffffffffc0202fca:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202fce:	10700593          	li	a1,263
ffffffffc0202fd2:	00005517          	auipc	a0,0x5
ffffffffc0202fd6:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202fda:	a2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202fde:	00005697          	auipc	a3,0x5
ffffffffc0202fe2:	ad268693          	addi	a3,a3,-1326 # ffffffffc0207ab0 <commands+0x1360>
ffffffffc0202fe6:	00004617          	auipc	a2,0x4
ffffffffc0202fea:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0206b60 <commands+0x410>
ffffffffc0202fee:	10600593          	li	a1,262
ffffffffc0202ff2:	00005517          	auipc	a0,0x5
ffffffffc0202ff6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0202ffa:	a0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202ffe:	00005697          	auipc	a3,0x5
ffffffffc0203002:	a8268693          	addi	a3,a3,-1406 # ffffffffc0207a80 <commands+0x1330>
ffffffffc0203006:	00004617          	auipc	a2,0x4
ffffffffc020300a:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0206b60 <commands+0x410>
ffffffffc020300e:	10500593          	li	a1,261
ffffffffc0203012:	00005517          	auipc	a0,0x5
ffffffffc0203016:	88e50513          	addi	a0,a0,-1906 # ffffffffc02078a0 <commands+0x1150>
ffffffffc020301a:	9eefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020301e:	00005697          	auipc	a3,0x5
ffffffffc0203022:	a4a68693          	addi	a3,a3,-1462 # ffffffffc0207a68 <commands+0x1318>
ffffffffc0203026:	00004617          	auipc	a2,0x4
ffffffffc020302a:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0206b60 <commands+0x410>
ffffffffc020302e:	10400593          	li	a1,260
ffffffffc0203032:	00005517          	auipc	a0,0x5
ffffffffc0203036:	86e50513          	addi	a0,a0,-1938 # ffffffffc02078a0 <commands+0x1150>
ffffffffc020303a:	9cefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020303e:	00005697          	auipc	a3,0x5
ffffffffc0203042:	9a268693          	addi	a3,a3,-1630 # ffffffffc02079e0 <commands+0x1290>
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0206b60 <commands+0x410>
ffffffffc020304e:	0fe00593          	li	a1,254
ffffffffc0203052:	00005517          	auipc	a0,0x5
ffffffffc0203056:	84e50513          	addi	a0,a0,-1970 # ffffffffc02078a0 <commands+0x1150>
ffffffffc020305a:	9aefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc020305e:	00005697          	auipc	a3,0x5
ffffffffc0203062:	9f268693          	addi	a3,a3,-1550 # ffffffffc0207a50 <commands+0x1300>
ffffffffc0203066:	00004617          	auipc	a2,0x4
ffffffffc020306a:	afa60613          	addi	a2,a2,-1286 # ffffffffc0206b60 <commands+0x410>
ffffffffc020306e:	0f900593          	li	a1,249
ffffffffc0203072:	00005517          	auipc	a0,0x5
ffffffffc0203076:	82e50513          	addi	a0,a0,-2002 # ffffffffc02078a0 <commands+0x1150>
ffffffffc020307a:	98efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020307e:	00005697          	auipc	a3,0x5
ffffffffc0203082:	af268693          	addi	a3,a3,-1294 # ffffffffc0207b70 <commands+0x1420>
ffffffffc0203086:	00004617          	auipc	a2,0x4
ffffffffc020308a:	ada60613          	addi	a2,a2,-1318 # ffffffffc0206b60 <commands+0x410>
ffffffffc020308e:	11700593          	li	a1,279
ffffffffc0203092:	00005517          	auipc	a0,0x5
ffffffffc0203096:	80e50513          	addi	a0,a0,-2034 # ffffffffc02078a0 <commands+0x1150>
ffffffffc020309a:	96efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc020309e:	00005697          	auipc	a3,0x5
ffffffffc02030a2:	b0268693          	addi	a3,a3,-1278 # ffffffffc0207ba0 <commands+0x1450>
ffffffffc02030a6:	00004617          	auipc	a2,0x4
ffffffffc02030aa:	aba60613          	addi	a2,a2,-1350 # ffffffffc0206b60 <commands+0x410>
ffffffffc02030ae:	12600593          	li	a1,294
ffffffffc02030b2:	00004517          	auipc	a0,0x4
ffffffffc02030b6:	7ee50513          	addi	a0,a0,2030 # ffffffffc02078a0 <commands+0x1150>
ffffffffc02030ba:	94efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc02030be:	00004697          	auipc	a3,0x4
ffffffffc02030c2:	47a68693          	addi	a3,a3,1146 # ffffffffc0207538 <commands+0xde8>
ffffffffc02030c6:	00004617          	auipc	a2,0x4
ffffffffc02030ca:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0206b60 <commands+0x410>
ffffffffc02030ce:	0f300593          	li	a1,243
ffffffffc02030d2:	00004517          	auipc	a0,0x4
ffffffffc02030d6:	7ce50513          	addi	a0,a0,1998 # ffffffffc02078a0 <commands+0x1150>
ffffffffc02030da:	92efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02030de:	00004697          	auipc	a3,0x4
ffffffffc02030e2:	7fa68693          	addi	a3,a3,2042 # ffffffffc02078d8 <commands+0x1188>
ffffffffc02030e6:	00004617          	auipc	a2,0x4
ffffffffc02030ea:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0206b60 <commands+0x410>
ffffffffc02030ee:	0ba00593          	li	a1,186
ffffffffc02030f2:	00004517          	auipc	a0,0x4
ffffffffc02030f6:	7ae50513          	addi	a0,a0,1966 # ffffffffc02078a0 <commands+0x1150>
ffffffffc02030fa:	90efd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02030fe <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02030fe:	1141                	addi	sp,sp,-16
ffffffffc0203100:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203102:	14058463          	beqz	a1,ffffffffc020324a <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0203106:	00659693          	slli	a3,a1,0x6
ffffffffc020310a:	96aa                	add	a3,a3,a0
ffffffffc020310c:	87aa                	mv	a5,a0
ffffffffc020310e:	02d50263          	beq	a0,a3,ffffffffc0203132 <default_free_pages+0x34>
ffffffffc0203112:	6798                	ld	a4,8(a5)
ffffffffc0203114:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203116:	10071a63          	bnez	a4,ffffffffc020322a <default_free_pages+0x12c>
ffffffffc020311a:	6798                	ld	a4,8(a5)
ffffffffc020311c:	8b09                	andi	a4,a4,2
ffffffffc020311e:	10071663          	bnez	a4,ffffffffc020322a <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203122:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203126:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020312a:	04078793          	addi	a5,a5,64
ffffffffc020312e:	fed792e3          	bne	a5,a3,ffffffffc0203112 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203132:	2581                	sext.w	a1,a1
ffffffffc0203134:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203136:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020313a:	4789                	li	a5,2
ffffffffc020313c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203140:	000ac697          	auipc	a3,0xac
ffffffffc0203144:	89068693          	addi	a3,a3,-1904 # ffffffffc02ae9d0 <free_area>
ffffffffc0203148:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020314a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020314c:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203150:	9db9                	addw	a1,a1,a4
ffffffffc0203152:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203154:	0ad78463          	beq	a5,a3,ffffffffc02031fc <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0203158:	fe878713          	addi	a4,a5,-24
ffffffffc020315c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203160:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203162:	00e56a63          	bltu	a0,a4,ffffffffc0203176 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0203166:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203168:	04d70c63          	beq	a4,a3,ffffffffc02031c0 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020316c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020316e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203172:	fee57ae3          	bgeu	a0,a4,ffffffffc0203166 <default_free_pages+0x68>
ffffffffc0203176:	c199                	beqz	a1,ffffffffc020317c <default_free_pages+0x7e>
ffffffffc0203178:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020317c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020317e:	e390                	sd	a2,0(a5)
ffffffffc0203180:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203182:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203184:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0203186:	00d70d63          	beq	a4,a3,ffffffffc02031a0 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020318a:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020318e:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0203192:	02059813          	slli	a6,a1,0x20
ffffffffc0203196:	01a85793          	srli	a5,a6,0x1a
ffffffffc020319a:	97b2                	add	a5,a5,a2
ffffffffc020319c:	02f50c63          	beq	a0,a5,ffffffffc02031d4 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02031a0:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02031a2:	00d78c63          	beq	a5,a3,ffffffffc02031ba <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02031a6:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02031a8:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02031ac:	02061593          	slli	a1,a2,0x20
ffffffffc02031b0:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02031b4:	972a                	add	a4,a4,a0
ffffffffc02031b6:	04e68a63          	beq	a3,a4,ffffffffc020320a <default_free_pages+0x10c>
}
ffffffffc02031ba:	60a2                	ld	ra,8(sp)
ffffffffc02031bc:	0141                	addi	sp,sp,16
ffffffffc02031be:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02031c0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02031c2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02031c4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02031c6:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02031c8:	02d70763          	beq	a4,a3,ffffffffc02031f6 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02031cc:	8832                	mv	a6,a2
ffffffffc02031ce:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02031d0:	87ba                	mv	a5,a4
ffffffffc02031d2:	bf71                	j	ffffffffc020316e <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02031d4:	491c                	lw	a5,16(a0)
ffffffffc02031d6:	9dbd                	addw	a1,a1,a5
ffffffffc02031d8:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02031dc:	57f5                	li	a5,-3
ffffffffc02031de:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02031e2:	01853803          	ld	a6,24(a0)
ffffffffc02031e6:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02031e8:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02031ea:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02031ee:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02031f0:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc02031f4:	b77d                	j	ffffffffc02031a2 <default_free_pages+0xa4>
ffffffffc02031f6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02031f8:	873e                	mv	a4,a5
ffffffffc02031fa:	bf41                	j	ffffffffc020318a <default_free_pages+0x8c>
}
ffffffffc02031fc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02031fe:	e390                	sd	a2,0(a5)
ffffffffc0203200:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203202:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203204:	ed1c                	sd	a5,24(a0)
ffffffffc0203206:	0141                	addi	sp,sp,16
ffffffffc0203208:	8082                	ret
            base->property += p->property;
ffffffffc020320a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020320e:	ff078693          	addi	a3,a5,-16
ffffffffc0203212:	9e39                	addw	a2,a2,a4
ffffffffc0203214:	c910                	sw	a2,16(a0)
ffffffffc0203216:	5775                	li	a4,-3
ffffffffc0203218:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020321c:	6398                	ld	a4,0(a5)
ffffffffc020321e:	679c                	ld	a5,8(a5)
}
ffffffffc0203220:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203222:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203224:	e398                	sd	a4,0(a5)
ffffffffc0203226:	0141                	addi	sp,sp,16
ffffffffc0203228:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020322a:	00005697          	auipc	a3,0x5
ffffffffc020322e:	98e68693          	addi	a3,a3,-1650 # ffffffffc0207bb8 <commands+0x1468>
ffffffffc0203232:	00004617          	auipc	a2,0x4
ffffffffc0203236:	92e60613          	addi	a2,a2,-1746 # ffffffffc0206b60 <commands+0x410>
ffffffffc020323a:	08300593          	li	a1,131
ffffffffc020323e:	00004517          	auipc	a0,0x4
ffffffffc0203242:	66250513          	addi	a0,a0,1634 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0203246:	fc3fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc020324a:	00005697          	auipc	a3,0x5
ffffffffc020324e:	96668693          	addi	a3,a3,-1690 # ffffffffc0207bb0 <commands+0x1460>
ffffffffc0203252:	00004617          	auipc	a2,0x4
ffffffffc0203256:	90e60613          	addi	a2,a2,-1778 # ffffffffc0206b60 <commands+0x410>
ffffffffc020325a:	08000593          	li	a1,128
ffffffffc020325e:	00004517          	auipc	a0,0x4
ffffffffc0203262:	64250513          	addi	a0,a0,1602 # ffffffffc02078a0 <commands+0x1150>
ffffffffc0203266:	fa3fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020326a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020326a:	c941                	beqz	a0,ffffffffc02032fa <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020326c:	000ab597          	auipc	a1,0xab
ffffffffc0203270:	76458593          	addi	a1,a1,1892 # ffffffffc02ae9d0 <free_area>
ffffffffc0203274:	0105a803          	lw	a6,16(a1)
ffffffffc0203278:	872a                	mv	a4,a0
ffffffffc020327a:	02081793          	slli	a5,a6,0x20
ffffffffc020327e:	9381                	srli	a5,a5,0x20
ffffffffc0203280:	00a7ee63          	bltu	a5,a0,ffffffffc020329c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203284:	87ae                	mv	a5,a1
ffffffffc0203286:	a801                	j	ffffffffc0203296 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203288:	ff87a683          	lw	a3,-8(a5)
ffffffffc020328c:	02069613          	slli	a2,a3,0x20
ffffffffc0203290:	9201                	srli	a2,a2,0x20
ffffffffc0203292:	00e67763          	bgeu	a2,a4,ffffffffc02032a0 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203296:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203298:	feb798e3          	bne	a5,a1,ffffffffc0203288 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020329c:	4501                	li	a0,0
}
ffffffffc020329e:	8082                	ret
    return listelm->prev;
ffffffffc02032a0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02032a4:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02032a8:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02032ac:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc02032b0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02032b4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02032b8:	02c77863          	bgeu	a4,a2,ffffffffc02032e8 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02032bc:	071a                	slli	a4,a4,0x6
ffffffffc02032be:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02032c0:	41c686bb          	subw	a3,a3,t3
ffffffffc02032c4:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02032c6:	00870613          	addi	a2,a4,8
ffffffffc02032ca:	4689                	li	a3,2
ffffffffc02032cc:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02032d0:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02032d4:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02032d8:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02032dc:	e290                	sd	a2,0(a3)
ffffffffc02032de:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02032e2:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02032e4:	01173c23          	sd	a7,24(a4)
ffffffffc02032e8:	41c8083b          	subw	a6,a6,t3
ffffffffc02032ec:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02032f0:	5775                	li	a4,-3
ffffffffc02032f2:	17c1                	addi	a5,a5,-16
ffffffffc02032f4:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02032f8:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02032fa:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02032fc:	00005697          	auipc	a3,0x5
ffffffffc0203300:	8b468693          	addi	a3,a3,-1868 # ffffffffc0207bb0 <commands+0x1460>
ffffffffc0203304:	00004617          	auipc	a2,0x4
ffffffffc0203308:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206b60 <commands+0x410>
ffffffffc020330c:	06200593          	li	a1,98
ffffffffc0203310:	00004517          	auipc	a0,0x4
ffffffffc0203314:	59050513          	addi	a0,a0,1424 # ffffffffc02078a0 <commands+0x1150>
default_alloc_pages(size_t n) {
ffffffffc0203318:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020331a:	eeffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020331e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020331e:	1141                	addi	sp,sp,-16
ffffffffc0203320:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203322:	c5f1                	beqz	a1,ffffffffc02033ee <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203324:	00659693          	slli	a3,a1,0x6
ffffffffc0203328:	96aa                	add	a3,a3,a0
ffffffffc020332a:	87aa                	mv	a5,a0
ffffffffc020332c:	00d50f63          	beq	a0,a3,ffffffffc020334a <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203330:	6798                	ld	a4,8(a5)
ffffffffc0203332:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0203334:	cf49                	beqz	a4,ffffffffc02033ce <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203336:	0007a823          	sw	zero,16(a5)
ffffffffc020333a:	0007b423          	sd	zero,8(a5)
ffffffffc020333e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203342:	04078793          	addi	a5,a5,64
ffffffffc0203346:	fed795e3          	bne	a5,a3,ffffffffc0203330 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020334a:	2581                	sext.w	a1,a1
ffffffffc020334c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020334e:	4789                	li	a5,2
ffffffffc0203350:	00850713          	addi	a4,a0,8
ffffffffc0203354:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203358:	000ab697          	auipc	a3,0xab
ffffffffc020335c:	67868693          	addi	a3,a3,1656 # ffffffffc02ae9d0 <free_area>
ffffffffc0203360:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203362:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203364:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203368:	9db9                	addw	a1,a1,a4
ffffffffc020336a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020336c:	04d78a63          	beq	a5,a3,ffffffffc02033c0 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0203370:	fe878713          	addi	a4,a5,-24
ffffffffc0203374:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203378:	4581                	li	a1,0
            if (base < page) {
ffffffffc020337a:	00e56a63          	bltu	a0,a4,ffffffffc020338e <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020337e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203380:	02d70263          	beq	a4,a3,ffffffffc02033a4 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0203384:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203386:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020338a:	fee57ae3          	bgeu	a0,a4,ffffffffc020337e <default_init_memmap+0x60>
ffffffffc020338e:	c199                	beqz	a1,ffffffffc0203394 <default_init_memmap+0x76>
ffffffffc0203390:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203394:	6398                	ld	a4,0(a5)
}
ffffffffc0203396:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203398:	e390                	sd	a2,0(a5)
ffffffffc020339a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020339c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020339e:	ed18                	sd	a4,24(a0)
ffffffffc02033a0:	0141                	addi	sp,sp,16
ffffffffc02033a2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02033a4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02033a6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02033a8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02033aa:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02033ac:	00d70663          	beq	a4,a3,ffffffffc02033b8 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02033b0:	8832                	mv	a6,a2
ffffffffc02033b2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02033b4:	87ba                	mv	a5,a4
ffffffffc02033b6:	bfc1                	j	ffffffffc0203386 <default_init_memmap+0x68>
}
ffffffffc02033b8:	60a2                	ld	ra,8(sp)
ffffffffc02033ba:	e290                	sd	a2,0(a3)
ffffffffc02033bc:	0141                	addi	sp,sp,16
ffffffffc02033be:	8082                	ret
ffffffffc02033c0:	60a2                	ld	ra,8(sp)
ffffffffc02033c2:	e390                	sd	a2,0(a5)
ffffffffc02033c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02033c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02033c8:	ed1c                	sd	a5,24(a0)
ffffffffc02033ca:	0141                	addi	sp,sp,16
ffffffffc02033cc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02033ce:	00005697          	auipc	a3,0x5
ffffffffc02033d2:	81268693          	addi	a3,a3,-2030 # ffffffffc0207be0 <commands+0x1490>
ffffffffc02033d6:	00003617          	auipc	a2,0x3
ffffffffc02033da:	78a60613          	addi	a2,a2,1930 # ffffffffc0206b60 <commands+0x410>
ffffffffc02033de:	04900593          	li	a1,73
ffffffffc02033e2:	00004517          	auipc	a0,0x4
ffffffffc02033e6:	4be50513          	addi	a0,a0,1214 # ffffffffc02078a0 <commands+0x1150>
ffffffffc02033ea:	e1ffc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02033ee:	00004697          	auipc	a3,0x4
ffffffffc02033f2:	7c268693          	addi	a3,a3,1986 # ffffffffc0207bb0 <commands+0x1460>
ffffffffc02033f6:	00003617          	auipc	a2,0x3
ffffffffc02033fa:	76a60613          	addi	a2,a2,1898 # ffffffffc0206b60 <commands+0x410>
ffffffffc02033fe:	04600593          	li	a1,70
ffffffffc0203402:	00004517          	auipc	a0,0x4
ffffffffc0203406:	49e50513          	addi	a0,a0,1182 # ffffffffc02078a0 <commands+0x1150>
ffffffffc020340a:	dfffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020340e <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020340e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203410:	00004617          	auipc	a2,0x4
ffffffffc0203414:	cf060613          	addi	a2,a2,-784 # ffffffffc0207100 <commands+0x9b0>
ffffffffc0203418:	06200593          	li	a1,98
ffffffffc020341c:	00004517          	auipc	a0,0x4
ffffffffc0203420:	d0450513          	addi	a0,a0,-764 # ffffffffc0207120 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc0203424:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203426:	de3fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020342a <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc020342a:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc020342c:	00004617          	auipc	a2,0x4
ffffffffc0203430:	2c460613          	addi	a2,a2,708 # ffffffffc02076f0 <commands+0xfa0>
ffffffffc0203434:	07400593          	li	a1,116
ffffffffc0203438:	00004517          	auipc	a0,0x4
ffffffffc020343c:	ce850513          	addi	a0,a0,-792 # ffffffffc0207120 <commands+0x9d0>
pte2page(pte_t pte) {
ffffffffc0203440:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0203442:	dc7fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203446 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203446:	7139                	addi	sp,sp,-64
ffffffffc0203448:	f426                	sd	s1,40(sp)
ffffffffc020344a:	f04a                	sd	s2,32(sp)
ffffffffc020344c:	ec4e                	sd	s3,24(sp)
ffffffffc020344e:	e852                	sd	s4,16(sp)
ffffffffc0203450:	e456                	sd	s5,8(sp)
ffffffffc0203452:	e05a                	sd	s6,0(sp)
ffffffffc0203454:	fc06                	sd	ra,56(sp)
ffffffffc0203456:	f822                	sd	s0,48(sp)
ffffffffc0203458:	84aa                	mv	s1,a0
ffffffffc020345a:	000af917          	auipc	s2,0xaf
ffffffffc020345e:	60690913          	addi	s2,s2,1542 # ffffffffc02b2a60 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203462:	4a05                	li	s4,1
ffffffffc0203464:	000afa97          	auipc	s5,0xaf
ffffffffc0203468:	5d4a8a93          	addi	s5,s5,1492 # ffffffffc02b2a38 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc020346c:	0005099b          	sext.w	s3,a0
ffffffffc0203470:	000afb17          	auipc	s6,0xaf
ffffffffc0203474:	5a0b0b13          	addi	s6,s6,1440 # ffffffffc02b2a10 <check_mm_struct>
ffffffffc0203478:	a01d                	j	ffffffffc020349e <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc020347a:	00093783          	ld	a5,0(s2)
ffffffffc020347e:	6f9c                	ld	a5,24(a5)
ffffffffc0203480:	9782                	jalr	a5
ffffffffc0203482:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0203484:	4601                	li	a2,0
ffffffffc0203486:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203488:	ec0d                	bnez	s0,ffffffffc02034c2 <alloc_pages+0x7c>
ffffffffc020348a:	029a6c63          	bltu	s4,s1,ffffffffc02034c2 <alloc_pages+0x7c>
ffffffffc020348e:	000aa783          	lw	a5,0(s5)
ffffffffc0203492:	2781                	sext.w	a5,a5
ffffffffc0203494:	c79d                	beqz	a5,ffffffffc02034c2 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203496:	000b3503          	ld	a0,0(s6)
ffffffffc020349a:	b38ff0ef          	jal	ra,ffffffffc02027d2 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020349e:	100027f3          	csrr	a5,sstatus
ffffffffc02034a2:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc02034a4:	8526                	mv	a0,s1
ffffffffc02034a6:	dbf1                	beqz	a5,ffffffffc020347a <alloc_pages+0x34>
        intr_disable();
ffffffffc02034a8:	9a0fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02034ac:	00093783          	ld	a5,0(s2)
ffffffffc02034b0:	8526                	mv	a0,s1
ffffffffc02034b2:	6f9c                	ld	a5,24(a5)
ffffffffc02034b4:	9782                	jalr	a5
ffffffffc02034b6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02034b8:	98afd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc02034bc:	4601                	li	a2,0
ffffffffc02034be:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02034c0:	d469                	beqz	s0,ffffffffc020348a <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02034c2:	70e2                	ld	ra,56(sp)
ffffffffc02034c4:	8522                	mv	a0,s0
ffffffffc02034c6:	7442                	ld	s0,48(sp)
ffffffffc02034c8:	74a2                	ld	s1,40(sp)
ffffffffc02034ca:	7902                	ld	s2,32(sp)
ffffffffc02034cc:	69e2                	ld	s3,24(sp)
ffffffffc02034ce:	6a42                	ld	s4,16(sp)
ffffffffc02034d0:	6aa2                	ld	s5,8(sp)
ffffffffc02034d2:	6b02                	ld	s6,0(sp)
ffffffffc02034d4:	6121                	addi	sp,sp,64
ffffffffc02034d6:	8082                	ret

ffffffffc02034d8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034d8:	100027f3          	csrr	a5,sstatus
ffffffffc02034dc:	8b89                	andi	a5,a5,2
ffffffffc02034de:	e799                	bnez	a5,ffffffffc02034ec <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02034e0:	000af797          	auipc	a5,0xaf
ffffffffc02034e4:	5807b783          	ld	a5,1408(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc02034e8:	739c                	ld	a5,32(a5)
ffffffffc02034ea:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02034ec:	1101                	addi	sp,sp,-32
ffffffffc02034ee:	ec06                	sd	ra,24(sp)
ffffffffc02034f0:	e822                	sd	s0,16(sp)
ffffffffc02034f2:	e426                	sd	s1,8(sp)
ffffffffc02034f4:	842a                	mv	s0,a0
ffffffffc02034f6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02034f8:	950fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02034fc:	000af797          	auipc	a5,0xaf
ffffffffc0203500:	5647b783          	ld	a5,1380(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0203504:	739c                	ld	a5,32(a5)
ffffffffc0203506:	85a6                	mv	a1,s1
ffffffffc0203508:	8522                	mv	a0,s0
ffffffffc020350a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020350c:	6442                	ld	s0,16(sp)
ffffffffc020350e:	60e2                	ld	ra,24(sp)
ffffffffc0203510:	64a2                	ld	s1,8(sp)
ffffffffc0203512:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203514:	92efd06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc0203518 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203518:	100027f3          	csrr	a5,sstatus
ffffffffc020351c:	8b89                	andi	a5,a5,2
ffffffffc020351e:	e799                	bnez	a5,ffffffffc020352c <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0203520:	000af797          	auipc	a5,0xaf
ffffffffc0203524:	5407b783          	ld	a5,1344(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0203528:	779c                	ld	a5,40(a5)
ffffffffc020352a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020352c:	1141                	addi	sp,sp,-16
ffffffffc020352e:	e406                	sd	ra,8(sp)
ffffffffc0203530:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0203532:	916fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203536:	000af797          	auipc	a5,0xaf
ffffffffc020353a:	52a7b783          	ld	a5,1322(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc020353e:	779c                	ld	a5,40(a5)
ffffffffc0203540:	9782                	jalr	a5
ffffffffc0203542:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203544:	8fefd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0203548:	60a2                	ld	ra,8(sp)
ffffffffc020354a:	8522                	mv	a0,s0
ffffffffc020354c:	6402                	ld	s0,0(sp)
ffffffffc020354e:	0141                	addi	sp,sp,16
ffffffffc0203550:	8082                	ret

ffffffffc0203552 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203552:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0203556:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020355a:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020355c:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020355e:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203560:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203564:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203566:	f04a                	sd	s2,32(sp)
ffffffffc0203568:	ec4e                	sd	s3,24(sp)
ffffffffc020356a:	e852                	sd	s4,16(sp)
ffffffffc020356c:	fc06                	sd	ra,56(sp)
ffffffffc020356e:	f822                	sd	s0,48(sp)
ffffffffc0203570:	e456                	sd	s5,8(sp)
ffffffffc0203572:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203574:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203578:	892e                	mv	s2,a1
ffffffffc020357a:	89b2                	mv	s3,a2
ffffffffc020357c:	000afa17          	auipc	s4,0xaf
ffffffffc0203580:	4d4a0a13          	addi	s4,s4,1236 # ffffffffc02b2a50 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203584:	e7b5                	bnez	a5,ffffffffc02035f0 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203586:	12060b63          	beqz	a2,ffffffffc02036bc <get_pte+0x16a>
ffffffffc020358a:	4505                	li	a0,1
ffffffffc020358c:	ebbff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0203590:	842a                	mv	s0,a0
ffffffffc0203592:	12050563          	beqz	a0,ffffffffc02036bc <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203596:	000afb17          	auipc	s6,0xaf
ffffffffc020359a:	4c2b0b13          	addi	s6,s6,1218 # ffffffffc02b2a58 <pages>
ffffffffc020359e:	000b3503          	ld	a0,0(s6)
ffffffffc02035a2:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02035a6:	000afa17          	auipc	s4,0xaf
ffffffffc02035aa:	4aaa0a13          	addi	s4,s4,1194 # ffffffffc02b2a50 <npage>
ffffffffc02035ae:	40a40533          	sub	a0,s0,a0
ffffffffc02035b2:	8519                	srai	a0,a0,0x6
ffffffffc02035b4:	9556                	add	a0,a0,s5
ffffffffc02035b6:	000a3703          	ld	a4,0(s4)
ffffffffc02035ba:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02035be:	4685                	li	a3,1
ffffffffc02035c0:	c014                	sw	a3,0(s0)
ffffffffc02035c2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02035c4:	0532                	slli	a0,a0,0xc
ffffffffc02035c6:	14e7f263          	bgeu	a5,a4,ffffffffc020370a <get_pte+0x1b8>
ffffffffc02035ca:	000af797          	auipc	a5,0xaf
ffffffffc02035ce:	49e7b783          	ld	a5,1182(a5) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc02035d2:	6605                	lui	a2,0x1
ffffffffc02035d4:	4581                	li	a1,0
ffffffffc02035d6:	953e                	add	a0,a0,a5
ffffffffc02035d8:	2a1020ef          	jal	ra,ffffffffc0206078 <memset>
    return page - pages + nbase;
ffffffffc02035dc:	000b3683          	ld	a3,0(s6)
ffffffffc02035e0:	40d406b3          	sub	a3,s0,a3
ffffffffc02035e4:	8699                	srai	a3,a3,0x6
ffffffffc02035e6:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02035e8:	06aa                	slli	a3,a3,0xa
ffffffffc02035ea:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02035ee:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02035f0:	77fd                	lui	a5,0xfffff
ffffffffc02035f2:	068a                	slli	a3,a3,0x2
ffffffffc02035f4:	000a3703          	ld	a4,0(s4)
ffffffffc02035f8:	8efd                	and	a3,a3,a5
ffffffffc02035fa:	00c6d793          	srli	a5,a3,0xc
ffffffffc02035fe:	0ce7f163          	bgeu	a5,a4,ffffffffc02036c0 <get_pte+0x16e>
ffffffffc0203602:	000afa97          	auipc	s5,0xaf
ffffffffc0203606:	466a8a93          	addi	s5,s5,1126 # ffffffffc02b2a68 <va_pa_offset>
ffffffffc020360a:	000ab403          	ld	s0,0(s5)
ffffffffc020360e:	01595793          	srli	a5,s2,0x15
ffffffffc0203612:	1ff7f793          	andi	a5,a5,511
ffffffffc0203616:	96a2                	add	a3,a3,s0
ffffffffc0203618:	00379413          	slli	s0,a5,0x3
ffffffffc020361c:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020361e:	6014                	ld	a3,0(s0)
ffffffffc0203620:	0016f793          	andi	a5,a3,1
ffffffffc0203624:	e3ad                	bnez	a5,ffffffffc0203686 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203626:	08098b63          	beqz	s3,ffffffffc02036bc <get_pte+0x16a>
ffffffffc020362a:	4505                	li	a0,1
ffffffffc020362c:	e1bff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0203630:	84aa                	mv	s1,a0
ffffffffc0203632:	c549                	beqz	a0,ffffffffc02036bc <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203634:	000afb17          	auipc	s6,0xaf
ffffffffc0203638:	424b0b13          	addi	s6,s6,1060 # ffffffffc02b2a58 <pages>
ffffffffc020363c:	000b3503          	ld	a0,0(s6)
ffffffffc0203640:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203644:	000a3703          	ld	a4,0(s4)
ffffffffc0203648:	40a48533          	sub	a0,s1,a0
ffffffffc020364c:	8519                	srai	a0,a0,0x6
ffffffffc020364e:	954e                	add	a0,a0,s3
ffffffffc0203650:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203654:	4685                	li	a3,1
ffffffffc0203656:	c094                	sw	a3,0(s1)
ffffffffc0203658:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020365a:	0532                	slli	a0,a0,0xc
ffffffffc020365c:	08e7fa63          	bgeu	a5,a4,ffffffffc02036f0 <get_pte+0x19e>
ffffffffc0203660:	000ab783          	ld	a5,0(s5)
ffffffffc0203664:	6605                	lui	a2,0x1
ffffffffc0203666:	4581                	li	a1,0
ffffffffc0203668:	953e                	add	a0,a0,a5
ffffffffc020366a:	20f020ef          	jal	ra,ffffffffc0206078 <memset>
    return page - pages + nbase;
ffffffffc020366e:	000b3683          	ld	a3,0(s6)
ffffffffc0203672:	40d486b3          	sub	a3,s1,a3
ffffffffc0203676:	8699                	srai	a3,a3,0x6
ffffffffc0203678:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020367a:	06aa                	slli	a3,a3,0xa
ffffffffc020367c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203680:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203682:	000a3703          	ld	a4,0(s4)
ffffffffc0203686:	068a                	slli	a3,a3,0x2
ffffffffc0203688:	757d                	lui	a0,0xfffff
ffffffffc020368a:	8ee9                	and	a3,a3,a0
ffffffffc020368c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203690:	04e7f463          	bgeu	a5,a4,ffffffffc02036d8 <get_pte+0x186>
ffffffffc0203694:	000ab503          	ld	a0,0(s5)
ffffffffc0203698:	00c95913          	srli	s2,s2,0xc
ffffffffc020369c:	1ff97913          	andi	s2,s2,511
ffffffffc02036a0:	96aa                	add	a3,a3,a0
ffffffffc02036a2:	00391513          	slli	a0,s2,0x3
ffffffffc02036a6:	9536                	add	a0,a0,a3
}
ffffffffc02036a8:	70e2                	ld	ra,56(sp)
ffffffffc02036aa:	7442                	ld	s0,48(sp)
ffffffffc02036ac:	74a2                	ld	s1,40(sp)
ffffffffc02036ae:	7902                	ld	s2,32(sp)
ffffffffc02036b0:	69e2                	ld	s3,24(sp)
ffffffffc02036b2:	6a42                	ld	s4,16(sp)
ffffffffc02036b4:	6aa2                	ld	s5,8(sp)
ffffffffc02036b6:	6b02                	ld	s6,0(sp)
ffffffffc02036b8:	6121                	addi	sp,sp,64
ffffffffc02036ba:	8082                	ret
            return NULL;
ffffffffc02036bc:	4501                	li	a0,0
ffffffffc02036be:	b7ed                	j	ffffffffc02036a8 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02036c0:	00004617          	auipc	a2,0x4
ffffffffc02036c4:	a7060613          	addi	a2,a2,-1424 # ffffffffc0207130 <commands+0x9e0>
ffffffffc02036c8:	0e300593          	li	a1,227
ffffffffc02036cc:	00004517          	auipc	a0,0x4
ffffffffc02036d0:	57450513          	addi	a0,a0,1396 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02036d4:	b35fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02036d8:	00004617          	auipc	a2,0x4
ffffffffc02036dc:	a5860613          	addi	a2,a2,-1448 # ffffffffc0207130 <commands+0x9e0>
ffffffffc02036e0:	0ee00593          	li	a1,238
ffffffffc02036e4:	00004517          	auipc	a0,0x4
ffffffffc02036e8:	55c50513          	addi	a0,a0,1372 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02036ec:	b1dfc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02036f0:	86aa                	mv	a3,a0
ffffffffc02036f2:	00004617          	auipc	a2,0x4
ffffffffc02036f6:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0207130 <commands+0x9e0>
ffffffffc02036fa:	0eb00593          	li	a1,235
ffffffffc02036fe:	00004517          	auipc	a0,0x4
ffffffffc0203702:	54250513          	addi	a0,a0,1346 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203706:	b03fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020370a:	86aa                	mv	a3,a0
ffffffffc020370c:	00004617          	auipc	a2,0x4
ffffffffc0203710:	a2460613          	addi	a2,a2,-1500 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0203714:	0df00593          	li	a1,223
ffffffffc0203718:	00004517          	auipc	a0,0x4
ffffffffc020371c:	52850513          	addi	a0,a0,1320 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203720:	ae9fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203724 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203724:	1141                	addi	sp,sp,-16
ffffffffc0203726:	e022                	sd	s0,0(sp)
ffffffffc0203728:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020372a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020372c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020372e:	e25ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0203732:	c011                	beqz	s0,ffffffffc0203736 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203734:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203736:	c511                	beqz	a0,ffffffffc0203742 <get_page+0x1e>
ffffffffc0203738:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020373a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020373c:	0017f713          	andi	a4,a5,1
ffffffffc0203740:	e709                	bnez	a4,ffffffffc020374a <get_page+0x26>
}
ffffffffc0203742:	60a2                	ld	ra,8(sp)
ffffffffc0203744:	6402                	ld	s0,0(sp)
ffffffffc0203746:	0141                	addi	sp,sp,16
ffffffffc0203748:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020374a:	078a                	slli	a5,a5,0x2
ffffffffc020374c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374e:	000af717          	auipc	a4,0xaf
ffffffffc0203752:	30273703          	ld	a4,770(a4) # ffffffffc02b2a50 <npage>
ffffffffc0203756:	00e7ff63          	bgeu	a5,a4,ffffffffc0203774 <get_page+0x50>
ffffffffc020375a:	60a2                	ld	ra,8(sp)
ffffffffc020375c:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020375e:	fff80537          	lui	a0,0xfff80
ffffffffc0203762:	97aa                	add	a5,a5,a0
ffffffffc0203764:	079a                	slli	a5,a5,0x6
ffffffffc0203766:	000af517          	auipc	a0,0xaf
ffffffffc020376a:	2f253503          	ld	a0,754(a0) # ffffffffc02b2a58 <pages>
ffffffffc020376e:	953e                	add	a0,a0,a5
ffffffffc0203770:	0141                	addi	sp,sp,16
ffffffffc0203772:	8082                	ret
ffffffffc0203774:	c9bff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc0203778 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203778:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020377a:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020377e:	f486                	sd	ra,104(sp)
ffffffffc0203780:	f0a2                	sd	s0,96(sp)
ffffffffc0203782:	eca6                	sd	s1,88(sp)
ffffffffc0203784:	e8ca                	sd	s2,80(sp)
ffffffffc0203786:	e4ce                	sd	s3,72(sp)
ffffffffc0203788:	e0d2                	sd	s4,64(sp)
ffffffffc020378a:	fc56                	sd	s5,56(sp)
ffffffffc020378c:	f85a                	sd	s6,48(sp)
ffffffffc020378e:	f45e                	sd	s7,40(sp)
ffffffffc0203790:	f062                	sd	s8,32(sp)
ffffffffc0203792:	ec66                	sd	s9,24(sp)
ffffffffc0203794:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203796:	17d2                	slli	a5,a5,0x34
ffffffffc0203798:	e3ed                	bnez	a5,ffffffffc020387a <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020379a:	002007b7          	lui	a5,0x200
ffffffffc020379e:	842e                	mv	s0,a1
ffffffffc02037a0:	0ef5ed63          	bltu	a1,a5,ffffffffc020389a <unmap_range+0x122>
ffffffffc02037a4:	8932                	mv	s2,a2
ffffffffc02037a6:	0ec5fa63          	bgeu	a1,a2,ffffffffc020389a <unmap_range+0x122>
ffffffffc02037aa:	4785                	li	a5,1
ffffffffc02037ac:	07fe                	slli	a5,a5,0x1f
ffffffffc02037ae:	0ec7e663          	bltu	a5,a2,ffffffffc020389a <unmap_range+0x122>
ffffffffc02037b2:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02037b4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02037b6:	000afc97          	auipc	s9,0xaf
ffffffffc02037ba:	29ac8c93          	addi	s9,s9,666 # ffffffffc02b2a50 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02037be:	000afc17          	auipc	s8,0xaf
ffffffffc02037c2:	29ac0c13          	addi	s8,s8,666 # ffffffffc02b2a58 <pages>
ffffffffc02037c6:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02037ca:	000afd17          	auipc	s10,0xaf
ffffffffc02037ce:	296d0d13          	addi	s10,s10,662 # ffffffffc02b2a60 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02037d2:	00200b37          	lui	s6,0x200
ffffffffc02037d6:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02037da:	4601                	li	a2,0
ffffffffc02037dc:	85a2                	mv	a1,s0
ffffffffc02037de:	854e                	mv	a0,s3
ffffffffc02037e0:	d73ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc02037e4:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02037e6:	cd29                	beqz	a0,ffffffffc0203840 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02037e8:	611c                	ld	a5,0(a0)
ffffffffc02037ea:	e395                	bnez	a5,ffffffffc020380e <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02037ec:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02037ee:	ff2466e3          	bltu	s0,s2,ffffffffc02037da <unmap_range+0x62>
}
ffffffffc02037f2:	70a6                	ld	ra,104(sp)
ffffffffc02037f4:	7406                	ld	s0,96(sp)
ffffffffc02037f6:	64e6                	ld	s1,88(sp)
ffffffffc02037f8:	6946                	ld	s2,80(sp)
ffffffffc02037fa:	69a6                	ld	s3,72(sp)
ffffffffc02037fc:	6a06                	ld	s4,64(sp)
ffffffffc02037fe:	7ae2                	ld	s5,56(sp)
ffffffffc0203800:	7b42                	ld	s6,48(sp)
ffffffffc0203802:	7ba2                	ld	s7,40(sp)
ffffffffc0203804:	7c02                	ld	s8,32(sp)
ffffffffc0203806:	6ce2                	ld	s9,24(sp)
ffffffffc0203808:	6d42                	ld	s10,16(sp)
ffffffffc020380a:	6165                	addi	sp,sp,112
ffffffffc020380c:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020380e:	0017f713          	andi	a4,a5,1
ffffffffc0203812:	df69                	beqz	a4,ffffffffc02037ec <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0203814:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203818:	078a                	slli	a5,a5,0x2
ffffffffc020381a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020381c:	08e7ff63          	bgeu	a5,a4,ffffffffc02038ba <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0203820:	000c3503          	ld	a0,0(s8)
ffffffffc0203824:	97de                	add	a5,a5,s7
ffffffffc0203826:	079a                	slli	a5,a5,0x6
ffffffffc0203828:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020382a:	411c                	lw	a5,0(a0)
ffffffffc020382c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203830:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203832:	cf11                	beqz	a4,ffffffffc020384e <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203834:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203838:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020383c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020383e:	bf45                	j	ffffffffc02037ee <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203840:	945a                	add	s0,s0,s6
ffffffffc0203842:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203846:	d455                	beqz	s0,ffffffffc02037f2 <unmap_range+0x7a>
ffffffffc0203848:	f92469e3          	bltu	s0,s2,ffffffffc02037da <unmap_range+0x62>
ffffffffc020384c:	b75d                	j	ffffffffc02037f2 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020384e:	100027f3          	csrr	a5,sstatus
ffffffffc0203852:	8b89                	andi	a5,a5,2
ffffffffc0203854:	e799                	bnez	a5,ffffffffc0203862 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0203856:	000d3783          	ld	a5,0(s10)
ffffffffc020385a:	4585                	li	a1,1
ffffffffc020385c:	739c                	ld	a5,32(a5)
ffffffffc020385e:	9782                	jalr	a5
    if (flag) {
ffffffffc0203860:	bfd1                	j	ffffffffc0203834 <unmap_range+0xbc>
ffffffffc0203862:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203864:	de5fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203868:	000d3783          	ld	a5,0(s10)
ffffffffc020386c:	6522                	ld	a0,8(sp)
ffffffffc020386e:	4585                	li	a1,1
ffffffffc0203870:	739c                	ld	a5,32(a5)
ffffffffc0203872:	9782                	jalr	a5
        intr_enable();
ffffffffc0203874:	dcffc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203878:	bf75                	j	ffffffffc0203834 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020387a:	00004697          	auipc	a3,0x4
ffffffffc020387e:	3d668693          	addi	a3,a3,982 # ffffffffc0207c50 <default_pmm_manager+0x48>
ffffffffc0203882:	00003617          	auipc	a2,0x3
ffffffffc0203886:	2de60613          	addi	a2,a2,734 # ffffffffc0206b60 <commands+0x410>
ffffffffc020388a:	10f00593          	li	a1,271
ffffffffc020388e:	00004517          	auipc	a0,0x4
ffffffffc0203892:	3b250513          	addi	a0,a0,946 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203896:	973fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020389a:	00004697          	auipc	a3,0x4
ffffffffc020389e:	3e668693          	addi	a3,a3,998 # ffffffffc0207c80 <default_pmm_manager+0x78>
ffffffffc02038a2:	00003617          	auipc	a2,0x3
ffffffffc02038a6:	2be60613          	addi	a2,a2,702 # ffffffffc0206b60 <commands+0x410>
ffffffffc02038aa:	11000593          	li	a1,272
ffffffffc02038ae:	00004517          	auipc	a0,0x4
ffffffffc02038b2:	39250513          	addi	a0,a0,914 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02038b6:	953fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02038ba:	b55ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc02038be <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02038be:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038c0:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02038c4:	fc86                	sd	ra,120(sp)
ffffffffc02038c6:	f8a2                	sd	s0,112(sp)
ffffffffc02038c8:	f4a6                	sd	s1,104(sp)
ffffffffc02038ca:	f0ca                	sd	s2,96(sp)
ffffffffc02038cc:	ecce                	sd	s3,88(sp)
ffffffffc02038ce:	e8d2                	sd	s4,80(sp)
ffffffffc02038d0:	e4d6                	sd	s5,72(sp)
ffffffffc02038d2:	e0da                	sd	s6,64(sp)
ffffffffc02038d4:	fc5e                	sd	s7,56(sp)
ffffffffc02038d6:	f862                	sd	s8,48(sp)
ffffffffc02038d8:	f466                	sd	s9,40(sp)
ffffffffc02038da:	f06a                	sd	s10,32(sp)
ffffffffc02038dc:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038de:	17d2                	slli	a5,a5,0x34
ffffffffc02038e0:	20079a63          	bnez	a5,ffffffffc0203af4 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02038e4:	002007b7          	lui	a5,0x200
ffffffffc02038e8:	24f5e463          	bltu	a1,a5,ffffffffc0203b30 <exit_range+0x272>
ffffffffc02038ec:	8ab2                	mv	s5,a2
ffffffffc02038ee:	24c5f163          	bgeu	a1,a2,ffffffffc0203b30 <exit_range+0x272>
ffffffffc02038f2:	4785                	li	a5,1
ffffffffc02038f4:	07fe                	slli	a5,a5,0x1f
ffffffffc02038f6:	22c7ed63          	bltu	a5,a2,ffffffffc0203b30 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02038fa:	c00009b7          	lui	s3,0xc0000
ffffffffc02038fe:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203902:	ffe00937          	lui	s2,0xffe00
ffffffffc0203906:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020390a:	5cfd                	li	s9,-1
ffffffffc020390c:	8c2a                	mv	s8,a0
ffffffffc020390e:	0125f933          	and	s2,a1,s2
ffffffffc0203912:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0203914:	000afd17          	auipc	s10,0xaf
ffffffffc0203918:	13cd0d13          	addi	s10,s10,316 # ffffffffc02b2a50 <npage>
    return KADDR(page2pa(page));
ffffffffc020391c:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203920:	000af717          	auipc	a4,0xaf
ffffffffc0203924:	13870713          	addi	a4,a4,312 # ffffffffc02b2a58 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0203928:	000afd97          	auipc	s11,0xaf
ffffffffc020392c:	138d8d93          	addi	s11,s11,312 # ffffffffc02b2a60 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203930:	c0000437          	lui	s0,0xc0000
ffffffffc0203934:	944e                	add	s0,s0,s3
ffffffffc0203936:	8079                	srli	s0,s0,0x1e
ffffffffc0203938:	1ff47413          	andi	s0,s0,511
ffffffffc020393c:	040e                	slli	s0,s0,0x3
ffffffffc020393e:	9462                	add	s0,s0,s8
ffffffffc0203940:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4eb8>
        if (pde1&PTE_V){
ffffffffc0203944:	001a7793          	andi	a5,s4,1
ffffffffc0203948:	eb99                	bnez	a5,ffffffffc020395e <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020394a:	12098463          	beqz	s3,ffffffffc0203a72 <exit_range+0x1b4>
ffffffffc020394e:	400007b7          	lui	a5,0x40000
ffffffffc0203952:	97ce                	add	a5,a5,s3
ffffffffc0203954:	894e                	mv	s2,s3
ffffffffc0203956:	1159fe63          	bgeu	s3,s5,ffffffffc0203a72 <exit_range+0x1b4>
ffffffffc020395a:	89be                	mv	s3,a5
ffffffffc020395c:	bfd1                	j	ffffffffc0203930 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc020395e:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203962:	0a0a                	slli	s4,s4,0x2
ffffffffc0203964:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203968:	1cfa7263          	bgeu	s4,a5,ffffffffc0203b2c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020396c:	fff80637          	lui	a2,0xfff80
ffffffffc0203970:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0203972:	000806b7          	lui	a3,0x80
ffffffffc0203976:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0203978:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020397c:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020397e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203980:	18f5fa63          	bgeu	a1,a5,ffffffffc0203b14 <exit_range+0x256>
ffffffffc0203984:	000af817          	auipc	a6,0xaf
ffffffffc0203988:	0e480813          	addi	a6,a6,228 # ffffffffc02b2a68 <va_pa_offset>
ffffffffc020398c:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0203990:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203992:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203996:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0203998:	00080337          	lui	t1,0x80
ffffffffc020399c:	6885                	lui	a7,0x1
ffffffffc020399e:	a819                	j	ffffffffc02039b4 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02039a0:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02039a2:	002007b7          	lui	a5,0x200
ffffffffc02039a6:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02039a8:	08090c63          	beqz	s2,ffffffffc0203a40 <exit_range+0x182>
ffffffffc02039ac:	09397a63          	bgeu	s2,s3,ffffffffc0203a40 <exit_range+0x182>
ffffffffc02039b0:	0f597063          	bgeu	s2,s5,ffffffffc0203a90 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02039b4:	01595493          	srli	s1,s2,0x15
ffffffffc02039b8:	1ff4f493          	andi	s1,s1,511
ffffffffc02039bc:	048e                	slli	s1,s1,0x3
ffffffffc02039be:	94da                	add	s1,s1,s6
ffffffffc02039c0:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc02039c2:	0017f693          	andi	a3,a5,1
ffffffffc02039c6:	dee9                	beqz	a3,ffffffffc02039a0 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc02039c8:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02039cc:	078a                	slli	a5,a5,0x2
ffffffffc02039ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039d0:	14b7fe63          	bgeu	a5,a1,ffffffffc0203b2c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02039d4:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02039d6:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02039da:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02039de:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02039e2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02039e4:	12bef863          	bgeu	t4,a1,ffffffffc0203b14 <exit_range+0x256>
ffffffffc02039e8:	00083783          	ld	a5,0(a6)
ffffffffc02039ec:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02039ee:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc02039f2:	629c                	ld	a5,0(a3)
ffffffffc02039f4:	8b85                	andi	a5,a5,1
ffffffffc02039f6:	f7d5                	bnez	a5,ffffffffc02039a2 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02039f8:	06a1                	addi	a3,a3,8
ffffffffc02039fa:	fed59ce3          	bne	a1,a3,ffffffffc02039f2 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02039fe:	631c                	ld	a5,0(a4)
ffffffffc0203a00:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a02:	100027f3          	csrr	a5,sstatus
ffffffffc0203a06:	8b89                	andi	a5,a5,2
ffffffffc0203a08:	e7d9                	bnez	a5,ffffffffc0203a96 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0203a0a:	000db783          	ld	a5,0(s11)
ffffffffc0203a0e:	4585                	li	a1,1
ffffffffc0203a10:	e032                	sd	a2,0(sp)
ffffffffc0203a12:	739c                	ld	a5,32(a5)
ffffffffc0203a14:	9782                	jalr	a5
    if (flag) {
ffffffffc0203a16:	6602                	ld	a2,0(sp)
ffffffffc0203a18:	000af817          	auipc	a6,0xaf
ffffffffc0203a1c:	05080813          	addi	a6,a6,80 # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0203a20:	fff80e37          	lui	t3,0xfff80
ffffffffc0203a24:	00080337          	lui	t1,0x80
ffffffffc0203a28:	6885                	lui	a7,0x1
ffffffffc0203a2a:	000af717          	auipc	a4,0xaf
ffffffffc0203a2e:	02e70713          	addi	a4,a4,46 # ffffffffc02b2a58 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203a32:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0203a36:	002007b7          	lui	a5,0x200
ffffffffc0203a3a:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203a3c:	f60918e3          	bnez	s2,ffffffffc02039ac <exit_range+0xee>
            if (free_pd0) {
ffffffffc0203a40:	f00b85e3          	beqz	s7,ffffffffc020394a <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0203a44:	000d3783          	ld	a5,0(s10)
ffffffffc0203a48:	0efa7263          	bgeu	s4,a5,ffffffffc0203b2c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a4c:	6308                	ld	a0,0(a4)
ffffffffc0203a4e:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a50:	100027f3          	csrr	a5,sstatus
ffffffffc0203a54:	8b89                	andi	a5,a5,2
ffffffffc0203a56:	efad                	bnez	a5,ffffffffc0203ad0 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0203a58:	000db783          	ld	a5,0(s11)
ffffffffc0203a5c:	4585                	li	a1,1
ffffffffc0203a5e:	739c                	ld	a5,32(a5)
ffffffffc0203a60:	9782                	jalr	a5
ffffffffc0203a62:	000af717          	auipc	a4,0xaf
ffffffffc0203a66:	ff670713          	addi	a4,a4,-10 # ffffffffc02b2a58 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203a6a:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0203a6e:	ee0990e3          	bnez	s3,ffffffffc020394e <exit_range+0x90>
}
ffffffffc0203a72:	70e6                	ld	ra,120(sp)
ffffffffc0203a74:	7446                	ld	s0,112(sp)
ffffffffc0203a76:	74a6                	ld	s1,104(sp)
ffffffffc0203a78:	7906                	ld	s2,96(sp)
ffffffffc0203a7a:	69e6                	ld	s3,88(sp)
ffffffffc0203a7c:	6a46                	ld	s4,80(sp)
ffffffffc0203a7e:	6aa6                	ld	s5,72(sp)
ffffffffc0203a80:	6b06                	ld	s6,64(sp)
ffffffffc0203a82:	7be2                	ld	s7,56(sp)
ffffffffc0203a84:	7c42                	ld	s8,48(sp)
ffffffffc0203a86:	7ca2                	ld	s9,40(sp)
ffffffffc0203a88:	7d02                	ld	s10,32(sp)
ffffffffc0203a8a:	6de2                	ld	s11,24(sp)
ffffffffc0203a8c:	6109                	addi	sp,sp,128
ffffffffc0203a8e:	8082                	ret
            if (free_pd0) {
ffffffffc0203a90:	ea0b8fe3          	beqz	s7,ffffffffc020394e <exit_range+0x90>
ffffffffc0203a94:	bf45                	j	ffffffffc0203a44 <exit_range+0x186>
ffffffffc0203a96:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0203a98:	e42a                	sd	a0,8(sp)
ffffffffc0203a9a:	baffc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203a9e:	000db783          	ld	a5,0(s11)
ffffffffc0203aa2:	6522                	ld	a0,8(sp)
ffffffffc0203aa4:	4585                	li	a1,1
ffffffffc0203aa6:	739c                	ld	a5,32(a5)
ffffffffc0203aa8:	9782                	jalr	a5
        intr_enable();
ffffffffc0203aaa:	b99fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203aae:	6602                	ld	a2,0(sp)
ffffffffc0203ab0:	000af717          	auipc	a4,0xaf
ffffffffc0203ab4:	fa870713          	addi	a4,a4,-88 # ffffffffc02b2a58 <pages>
ffffffffc0203ab8:	6885                	lui	a7,0x1
ffffffffc0203aba:	00080337          	lui	t1,0x80
ffffffffc0203abe:	fff80e37          	lui	t3,0xfff80
ffffffffc0203ac2:	000af817          	auipc	a6,0xaf
ffffffffc0203ac6:	fa680813          	addi	a6,a6,-90 # ffffffffc02b2a68 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203aca:	0004b023          	sd	zero,0(s1)
ffffffffc0203ace:	b7a5                	j	ffffffffc0203a36 <exit_range+0x178>
ffffffffc0203ad0:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0203ad2:	b77fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203ad6:	000db783          	ld	a5,0(s11)
ffffffffc0203ada:	6502                	ld	a0,0(sp)
ffffffffc0203adc:	4585                	li	a1,1
ffffffffc0203ade:	739c                	ld	a5,32(a5)
ffffffffc0203ae0:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ae2:	b61fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203ae6:	000af717          	auipc	a4,0xaf
ffffffffc0203aea:	f7270713          	addi	a4,a4,-142 # ffffffffc02b2a58 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203aee:	00043023          	sd	zero,0(s0)
ffffffffc0203af2:	bfb5                	j	ffffffffc0203a6e <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203af4:	00004697          	auipc	a3,0x4
ffffffffc0203af8:	15c68693          	addi	a3,a3,348 # ffffffffc0207c50 <default_pmm_manager+0x48>
ffffffffc0203afc:	00003617          	auipc	a2,0x3
ffffffffc0203b00:	06460613          	addi	a2,a2,100 # ffffffffc0206b60 <commands+0x410>
ffffffffc0203b04:	12000593          	li	a1,288
ffffffffc0203b08:	00004517          	auipc	a0,0x4
ffffffffc0203b0c:	13850513          	addi	a0,a0,312 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203b10:	ef8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203b14:	00003617          	auipc	a2,0x3
ffffffffc0203b18:	61c60613          	addi	a2,a2,1564 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0203b1c:	06900593          	li	a1,105
ffffffffc0203b20:	00003517          	auipc	a0,0x3
ffffffffc0203b24:	60050513          	addi	a0,a0,1536 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0203b28:	ee0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203b2c:	8e3ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0203b30:	00004697          	auipc	a3,0x4
ffffffffc0203b34:	15068693          	addi	a3,a3,336 # ffffffffc0207c80 <default_pmm_manager+0x78>
ffffffffc0203b38:	00003617          	auipc	a2,0x3
ffffffffc0203b3c:	02860613          	addi	a2,a2,40 # ffffffffc0206b60 <commands+0x410>
ffffffffc0203b40:	12100593          	li	a1,289
ffffffffc0203b44:	00004517          	auipc	a0,0x4
ffffffffc0203b48:	0fc50513          	addi	a0,a0,252 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203b4c:	ebcfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203b50 <copy_range>:
               bool share) {
ffffffffc0203b50:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203b52:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0203b56:	ec86                	sd	ra,88(sp)
ffffffffc0203b58:	e8a2                	sd	s0,80(sp)
ffffffffc0203b5a:	e4a6                	sd	s1,72(sp)
ffffffffc0203b5c:	e0ca                	sd	s2,64(sp)
ffffffffc0203b5e:	fc4e                	sd	s3,56(sp)
ffffffffc0203b60:	f852                	sd	s4,48(sp)
ffffffffc0203b62:	f456                	sd	s5,40(sp)
ffffffffc0203b64:	f05a                	sd	s6,32(sp)
ffffffffc0203b66:	ec5e                	sd	s7,24(sp)
ffffffffc0203b68:	e862                	sd	s8,16(sp)
ffffffffc0203b6a:	e466                	sd	s9,8(sp)
ffffffffc0203b6c:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203b6e:	17d2                	slli	a5,a5,0x34
ffffffffc0203b70:	14079663          	bnez	a5,ffffffffc0203cbc <copy_range+0x16c>
    assert(USER_ACCESS(start, end));
ffffffffc0203b74:	002007b7          	lui	a5,0x200
ffffffffc0203b78:	84b2                	mv	s1,a2
ffffffffc0203b7a:	10f66563          	bltu	a2,a5,ffffffffc0203c84 <copy_range+0x134>
ffffffffc0203b7e:	8936                	mv	s2,a3
ffffffffc0203b80:	10d67263          	bgeu	a2,a3,ffffffffc0203c84 <copy_range+0x134>
ffffffffc0203b84:	4785                	li	a5,1
ffffffffc0203b86:	07fe                	slli	a5,a5,0x1f
ffffffffc0203b88:	0ed7ee63          	bltu	a5,a3,ffffffffc0203c84 <copy_range+0x134>
ffffffffc0203b8c:	8aaa                	mv	s5,a0
ffffffffc0203b8e:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc0203b90:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203b92:	000afc17          	auipc	s8,0xaf
ffffffffc0203b96:	ebec0c13          	addi	s8,s8,-322 # ffffffffc02b2a50 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b9a:	000afb97          	auipc	s7,0xaf
ffffffffc0203b9e:	ebeb8b93          	addi	s7,s7,-322 # ffffffffc02b2a58 <pages>
ffffffffc0203ba2:	fff80b37          	lui	s6,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203ba6:	00200d37          	lui	s10,0x200
ffffffffc0203baa:	ffe00cb7          	lui	s9,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203bae:	4601                	li	a2,0
ffffffffc0203bb0:	85a6                	mv	a1,s1
ffffffffc0203bb2:	854e                	mv	a0,s3
ffffffffc0203bb4:	99fff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0203bb8:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc0203bba:	c141                	beqz	a0,ffffffffc0203c3a <copy_range+0xea>
        if (*ptep & PTE_V) {
ffffffffc0203bbc:	611c                	ld	a5,0(a0)
ffffffffc0203bbe:	8b85                	andi	a5,a5,1
ffffffffc0203bc0:	e39d                	bnez	a5,ffffffffc0203be6 <copy_range+0x96>
        start += PGSIZE;
ffffffffc0203bc2:	94d2                	add	s1,s1,s4
    } while (start != 0 && start < end);
ffffffffc0203bc4:	ff24e5e3          	bltu	s1,s2,ffffffffc0203bae <copy_range+0x5e>
    return 0;
ffffffffc0203bc8:	4501                	li	a0,0
}
ffffffffc0203bca:	60e6                	ld	ra,88(sp)
ffffffffc0203bcc:	6446                	ld	s0,80(sp)
ffffffffc0203bce:	64a6                	ld	s1,72(sp)
ffffffffc0203bd0:	6906                	ld	s2,64(sp)
ffffffffc0203bd2:	79e2                	ld	s3,56(sp)
ffffffffc0203bd4:	7a42                	ld	s4,48(sp)
ffffffffc0203bd6:	7aa2                	ld	s5,40(sp)
ffffffffc0203bd8:	7b02                	ld	s6,32(sp)
ffffffffc0203bda:	6be2                	ld	s7,24(sp)
ffffffffc0203bdc:	6c42                	ld	s8,16(sp)
ffffffffc0203bde:	6ca2                	ld	s9,8(sp)
ffffffffc0203be0:	6d02                	ld	s10,0(sp)
ffffffffc0203be2:	6125                	addi	sp,sp,96
ffffffffc0203be4:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203be6:	4605                	li	a2,1
ffffffffc0203be8:	85a6                	mv	a1,s1
ffffffffc0203bea:	8556                	mv	a0,s5
ffffffffc0203bec:	967ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0203bf0:	cd21                	beqz	a0,ffffffffc0203c48 <copy_range+0xf8>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203bf2:	601c                	ld	a5,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc0203bf4:	0017f713          	andi	a4,a5,1
ffffffffc0203bf8:	c755                	beqz	a4,ffffffffc0203ca4 <copy_range+0x154>
    if (PPN(pa) >= npage) {
ffffffffc0203bfa:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203bfe:	078a                	slli	a5,a5,0x2
ffffffffc0203c00:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c02:	06e7f563          	bgeu	a5,a4,ffffffffc0203c6c <copy_range+0x11c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c06:	000bb403          	ld	s0,0(s7)
ffffffffc0203c0a:	97da                	add	a5,a5,s6
ffffffffc0203c0c:	079a                	slli	a5,a5,0x6
ffffffffc0203c0e:	943e                	add	s0,s0,a5
            struct Page *npage = alloc_page();
ffffffffc0203c10:	4505                	li	a0,1
ffffffffc0203c12:	835ff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
            assert(page != NULL);
ffffffffc0203c16:	c81d                	beqz	s0,ffffffffc0203c4c <copy_range+0xfc>
            assert(npage != NULL);
ffffffffc0203c18:	f54d                	bnez	a0,ffffffffc0203bc2 <copy_range+0x72>
ffffffffc0203c1a:	00004697          	auipc	a3,0x4
ffffffffc0203c1e:	08e68693          	addi	a3,a3,142 # ffffffffc0207ca8 <default_pmm_manager+0xa0>
ffffffffc0203c22:	00003617          	auipc	a2,0x3
ffffffffc0203c26:	f3e60613          	addi	a2,a2,-194 # ffffffffc0206b60 <commands+0x410>
ffffffffc0203c2a:	17300593          	li	a1,371
ffffffffc0203c2e:	00004517          	auipc	a0,0x4
ffffffffc0203c32:	01250513          	addi	a0,a0,18 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203c36:	dd2fc0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203c3a:	94ea                	add	s1,s1,s10
ffffffffc0203c3c:	0194f4b3          	and	s1,s1,s9
    } while (start != 0 && start < end);
ffffffffc0203c40:	d4c1                	beqz	s1,ffffffffc0203bc8 <copy_range+0x78>
ffffffffc0203c42:	f724e6e3          	bltu	s1,s2,ffffffffc0203bae <copy_range+0x5e>
ffffffffc0203c46:	b749                	j	ffffffffc0203bc8 <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc0203c48:	5571                	li	a0,-4
ffffffffc0203c4a:	b741                	j	ffffffffc0203bca <copy_range+0x7a>
            assert(page != NULL);
ffffffffc0203c4c:	00004697          	auipc	a3,0x4
ffffffffc0203c50:	04c68693          	addi	a3,a3,76 # ffffffffc0207c98 <default_pmm_manager+0x90>
ffffffffc0203c54:	00003617          	auipc	a2,0x3
ffffffffc0203c58:	f0c60613          	addi	a2,a2,-244 # ffffffffc0206b60 <commands+0x410>
ffffffffc0203c5c:	17200593          	li	a1,370
ffffffffc0203c60:	00004517          	auipc	a0,0x4
ffffffffc0203c64:	fe050513          	addi	a0,a0,-32 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203c68:	da0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203c6c:	00003617          	auipc	a2,0x3
ffffffffc0203c70:	49460613          	addi	a2,a2,1172 # ffffffffc0207100 <commands+0x9b0>
ffffffffc0203c74:	06200593          	li	a1,98
ffffffffc0203c78:	00003517          	auipc	a0,0x3
ffffffffc0203c7c:	4a850513          	addi	a0,a0,1192 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0203c80:	d88fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203c84:	00004697          	auipc	a3,0x4
ffffffffc0203c88:	ffc68693          	addi	a3,a3,-4 # ffffffffc0207c80 <default_pmm_manager+0x78>
ffffffffc0203c8c:	00003617          	auipc	a2,0x3
ffffffffc0203c90:	ed460613          	addi	a2,a2,-300 # ffffffffc0206b60 <commands+0x410>
ffffffffc0203c94:	15e00593          	li	a1,350
ffffffffc0203c98:	00004517          	auipc	a0,0x4
ffffffffc0203c9c:	fa850513          	addi	a0,a0,-88 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203ca0:	d68fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203ca4:	00004617          	auipc	a2,0x4
ffffffffc0203ca8:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02076f0 <commands+0xfa0>
ffffffffc0203cac:	07400593          	li	a1,116
ffffffffc0203cb0:	00003517          	auipc	a0,0x3
ffffffffc0203cb4:	47050513          	addi	a0,a0,1136 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0203cb8:	d50fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203cbc:	00004697          	auipc	a3,0x4
ffffffffc0203cc0:	f9468693          	addi	a3,a3,-108 # ffffffffc0207c50 <default_pmm_manager+0x48>
ffffffffc0203cc4:	00003617          	auipc	a2,0x3
ffffffffc0203cc8:	e9c60613          	addi	a2,a2,-356 # ffffffffc0206b60 <commands+0x410>
ffffffffc0203ccc:	15d00593          	li	a1,349
ffffffffc0203cd0:	00004517          	auipc	a0,0x4
ffffffffc0203cd4:	f7050513          	addi	a0,a0,-144 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0203cd8:	d30fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203cdc <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203cdc:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203cde:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203ce0:	ec26                	sd	s1,24(sp)
ffffffffc0203ce2:	f406                	sd	ra,40(sp)
ffffffffc0203ce4:	f022                	sd	s0,32(sp)
ffffffffc0203ce6:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203ce8:	86bff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    if (ptep != NULL) {
ffffffffc0203cec:	c511                	beqz	a0,ffffffffc0203cf8 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203cee:	611c                	ld	a5,0(a0)
ffffffffc0203cf0:	842a                	mv	s0,a0
ffffffffc0203cf2:	0017f713          	andi	a4,a5,1
ffffffffc0203cf6:	e711                	bnez	a4,ffffffffc0203d02 <page_remove+0x26>
}
ffffffffc0203cf8:	70a2                	ld	ra,40(sp)
ffffffffc0203cfa:	7402                	ld	s0,32(sp)
ffffffffc0203cfc:	64e2                	ld	s1,24(sp)
ffffffffc0203cfe:	6145                	addi	sp,sp,48
ffffffffc0203d00:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d02:	078a                	slli	a5,a5,0x2
ffffffffc0203d04:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d06:	000af717          	auipc	a4,0xaf
ffffffffc0203d0a:	d4a73703          	ld	a4,-694(a4) # ffffffffc02b2a50 <npage>
ffffffffc0203d0e:	06e7f363          	bgeu	a5,a4,ffffffffc0203d74 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d12:	fff80537          	lui	a0,0xfff80
ffffffffc0203d16:	97aa                	add	a5,a5,a0
ffffffffc0203d18:	079a                	slli	a5,a5,0x6
ffffffffc0203d1a:	000af517          	auipc	a0,0xaf
ffffffffc0203d1e:	d3e53503          	ld	a0,-706(a0) # ffffffffc02b2a58 <pages>
ffffffffc0203d22:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203d24:	411c                	lw	a5,0(a0)
ffffffffc0203d26:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203d2a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203d2c:	cb11                	beqz	a4,ffffffffc0203d40 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203d2e:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d32:	12048073          	sfence.vma	s1
}
ffffffffc0203d36:	70a2                	ld	ra,40(sp)
ffffffffc0203d38:	7402                	ld	s0,32(sp)
ffffffffc0203d3a:	64e2                	ld	s1,24(sp)
ffffffffc0203d3c:	6145                	addi	sp,sp,48
ffffffffc0203d3e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d40:	100027f3          	csrr	a5,sstatus
ffffffffc0203d44:	8b89                	andi	a5,a5,2
ffffffffc0203d46:	eb89                	bnez	a5,ffffffffc0203d58 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203d48:	000af797          	auipc	a5,0xaf
ffffffffc0203d4c:	d187b783          	ld	a5,-744(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0203d50:	739c                	ld	a5,32(a5)
ffffffffc0203d52:	4585                	li	a1,1
ffffffffc0203d54:	9782                	jalr	a5
    if (flag) {
ffffffffc0203d56:	bfe1                	j	ffffffffc0203d2e <page_remove+0x52>
        intr_disable();
ffffffffc0203d58:	e42a                	sd	a0,8(sp)
ffffffffc0203d5a:	8effc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203d5e:	000af797          	auipc	a5,0xaf
ffffffffc0203d62:	d027b783          	ld	a5,-766(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0203d66:	739c                	ld	a5,32(a5)
ffffffffc0203d68:	6522                	ld	a0,8(sp)
ffffffffc0203d6a:	4585                	li	a1,1
ffffffffc0203d6c:	9782                	jalr	a5
        intr_enable();
ffffffffc0203d6e:	8d5fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203d72:	bf75                	j	ffffffffc0203d2e <page_remove+0x52>
ffffffffc0203d74:	e9aff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc0203d78 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d78:	7139                	addi	sp,sp,-64
ffffffffc0203d7a:	e852                	sd	s4,16(sp)
ffffffffc0203d7c:	8a32                	mv	s4,a2
ffffffffc0203d7e:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d80:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d82:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d84:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d86:	f426                	sd	s1,40(sp)
ffffffffc0203d88:	fc06                	sd	ra,56(sp)
ffffffffc0203d8a:	f04a                	sd	s2,32(sp)
ffffffffc0203d8c:	ec4e                	sd	s3,24(sp)
ffffffffc0203d8e:	e456                	sd	s5,8(sp)
ffffffffc0203d90:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d92:	fc0ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    if (ptep == NULL) {
ffffffffc0203d96:	c961                	beqz	a0,ffffffffc0203e66 <page_insert+0xee>
    page->ref += 1;
ffffffffc0203d98:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203d9a:	611c                	ld	a5,0(a0)
ffffffffc0203d9c:	89aa                	mv	s3,a0
ffffffffc0203d9e:	0016871b          	addiw	a4,a3,1
ffffffffc0203da2:	c018                	sw	a4,0(s0)
ffffffffc0203da4:	0017f713          	andi	a4,a5,1
ffffffffc0203da8:	ef05                	bnez	a4,ffffffffc0203de0 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0203daa:	000af717          	auipc	a4,0xaf
ffffffffc0203dae:	cae73703          	ld	a4,-850(a4) # ffffffffc02b2a58 <pages>
ffffffffc0203db2:	8c19                	sub	s0,s0,a4
ffffffffc0203db4:	000807b7          	lui	a5,0x80
ffffffffc0203db8:	8419                	srai	s0,s0,0x6
ffffffffc0203dba:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203dbc:	042a                	slli	s0,s0,0xa
ffffffffc0203dbe:	8cc1                	or	s1,s1,s0
ffffffffc0203dc0:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203dc4:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4eb8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dc8:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203dcc:	4501                	li	a0,0
}
ffffffffc0203dce:	70e2                	ld	ra,56(sp)
ffffffffc0203dd0:	7442                	ld	s0,48(sp)
ffffffffc0203dd2:	74a2                	ld	s1,40(sp)
ffffffffc0203dd4:	7902                	ld	s2,32(sp)
ffffffffc0203dd6:	69e2                	ld	s3,24(sp)
ffffffffc0203dd8:	6a42                	ld	s4,16(sp)
ffffffffc0203dda:	6aa2                	ld	s5,8(sp)
ffffffffc0203ddc:	6121                	addi	sp,sp,64
ffffffffc0203dde:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203de0:	078a                	slli	a5,a5,0x2
ffffffffc0203de2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203de4:	000af717          	auipc	a4,0xaf
ffffffffc0203de8:	c6c73703          	ld	a4,-916(a4) # ffffffffc02b2a50 <npage>
ffffffffc0203dec:	06e7ff63          	bgeu	a5,a4,ffffffffc0203e6a <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203df0:	000afa97          	auipc	s5,0xaf
ffffffffc0203df4:	c68a8a93          	addi	s5,s5,-920 # ffffffffc02b2a58 <pages>
ffffffffc0203df8:	000ab703          	ld	a4,0(s5)
ffffffffc0203dfc:	fff80937          	lui	s2,0xfff80
ffffffffc0203e00:	993e                	add	s2,s2,a5
ffffffffc0203e02:	091a                	slli	s2,s2,0x6
ffffffffc0203e04:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0203e06:	01240c63          	beq	s0,s2,ffffffffc0203e1e <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203e0a:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd574>
ffffffffc0203e0e:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203e12:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203e16:	c691                	beqz	a3,ffffffffc0203e22 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e18:	120a0073          	sfence.vma	s4
}
ffffffffc0203e1c:	bf59                	j	ffffffffc0203db2 <page_insert+0x3a>
ffffffffc0203e1e:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203e20:	bf49                	j	ffffffffc0203db2 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203e22:	100027f3          	csrr	a5,sstatus
ffffffffc0203e26:	8b89                	andi	a5,a5,2
ffffffffc0203e28:	ef91                	bnez	a5,ffffffffc0203e44 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203e2a:	000af797          	auipc	a5,0xaf
ffffffffc0203e2e:	c367b783          	ld	a5,-970(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0203e32:	739c                	ld	a5,32(a5)
ffffffffc0203e34:	4585                	li	a1,1
ffffffffc0203e36:	854a                	mv	a0,s2
ffffffffc0203e38:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203e3a:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e3e:	120a0073          	sfence.vma	s4
ffffffffc0203e42:	bf85                	j	ffffffffc0203db2 <page_insert+0x3a>
        intr_disable();
ffffffffc0203e44:	805fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203e48:	000af797          	auipc	a5,0xaf
ffffffffc0203e4c:	c187b783          	ld	a5,-1000(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0203e50:	739c                	ld	a5,32(a5)
ffffffffc0203e52:	4585                	li	a1,1
ffffffffc0203e54:	854a                	mv	a0,s2
ffffffffc0203e56:	9782                	jalr	a5
        intr_enable();
ffffffffc0203e58:	feafc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203e5c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e60:	120a0073          	sfence.vma	s4
ffffffffc0203e64:	b7b9                	j	ffffffffc0203db2 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203e66:	5571                	li	a0,-4
ffffffffc0203e68:	b79d                	j	ffffffffc0203dce <page_insert+0x56>
ffffffffc0203e6a:	da4ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc0203e6e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203e6e:	00004797          	auipc	a5,0x4
ffffffffc0203e72:	d9a78793          	addi	a5,a5,-614 # ffffffffc0207c08 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e76:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203e78:	711d                	addi	sp,sp,-96
ffffffffc0203e7a:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e7c:	00004517          	auipc	a0,0x4
ffffffffc0203e80:	e3c50513          	addi	a0,a0,-452 # ffffffffc0207cb8 <default_pmm_manager+0xb0>
    pmm_manager = &default_pmm_manager;
ffffffffc0203e84:	000afb97          	auipc	s7,0xaf
ffffffffc0203e88:	bdcb8b93          	addi	s7,s7,-1060 # ffffffffc02b2a60 <pmm_manager>
void pmm_init(void) {
ffffffffc0203e8c:	ec86                	sd	ra,88(sp)
ffffffffc0203e8e:	e4a6                	sd	s1,72(sp)
ffffffffc0203e90:	fc4e                	sd	s3,56(sp)
ffffffffc0203e92:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203e94:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203e98:	e8a2                	sd	s0,80(sp)
ffffffffc0203e9a:	e0ca                	sd	s2,64(sp)
ffffffffc0203e9c:	f852                	sd	s4,48(sp)
ffffffffc0203e9e:	f456                	sd	s5,40(sp)
ffffffffc0203ea0:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203ea2:	a2afc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0203ea6:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203eaa:	000af997          	auipc	s3,0xaf
ffffffffc0203eae:	bbe98993          	addi	s3,s3,-1090 # ffffffffc02b2a68 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203eb2:	000af497          	auipc	s1,0xaf
ffffffffc0203eb6:	b9e48493          	addi	s1,s1,-1122 # ffffffffc02b2a50 <npage>
    pmm_manager->init();
ffffffffc0203eba:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203ebc:	000afb17          	auipc	s6,0xaf
ffffffffc0203ec0:	b9cb0b13          	addi	s6,s6,-1124 # ffffffffc02b2a58 <pages>
    pmm_manager->init();
ffffffffc0203ec4:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203ec6:	57f5                	li	a5,-3
ffffffffc0203ec8:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203eca:	00004517          	auipc	a0,0x4
ffffffffc0203ece:	e0650513          	addi	a0,a0,-506 # ffffffffc0207cd0 <default_pmm_manager+0xc8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203ed2:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0203ed6:	9f6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203eda:	46c5                	li	a3,17
ffffffffc0203edc:	06ee                	slli	a3,a3,0x1b
ffffffffc0203ede:	40100613          	li	a2,1025
ffffffffc0203ee2:	07e005b7          	lui	a1,0x7e00
ffffffffc0203ee6:	16fd                	addi	a3,a3,-1
ffffffffc0203ee8:	0656                	slli	a2,a2,0x15
ffffffffc0203eea:	00004517          	auipc	a0,0x4
ffffffffc0203eee:	dfe50513          	addi	a0,a0,-514 # ffffffffc0207ce8 <default_pmm_manager+0xe0>
ffffffffc0203ef2:	9dafc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203ef6:	777d                	lui	a4,0xfffff
ffffffffc0203ef8:	000b0797          	auipc	a5,0xb0
ffffffffc0203efc:	b9378793          	addi	a5,a5,-1133 # ffffffffc02b3a8b <end+0xfff>
ffffffffc0203f00:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203f02:	00088737          	lui	a4,0x88
ffffffffc0203f06:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203f08:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203f0c:	4701                	li	a4,0
ffffffffc0203f0e:	4585                	li	a1,1
ffffffffc0203f10:	fff80837          	lui	a6,0xfff80
ffffffffc0203f14:	a019                	j	ffffffffc0203f1a <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0203f16:	000b3783          	ld	a5,0(s6)
ffffffffc0203f1a:	00671693          	slli	a3,a4,0x6
ffffffffc0203f1e:	97b6                	add	a5,a5,a3
ffffffffc0203f20:	07a1                	addi	a5,a5,8
ffffffffc0203f22:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203f26:	6090                	ld	a2,0(s1)
ffffffffc0203f28:	0705                	addi	a4,a4,1
ffffffffc0203f2a:	010607b3          	add	a5,a2,a6
ffffffffc0203f2e:	fef764e3          	bltu	a4,a5,ffffffffc0203f16 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203f32:	000b3503          	ld	a0,0(s6)
ffffffffc0203f36:	079a                	slli	a5,a5,0x6
ffffffffc0203f38:	c0200737          	lui	a4,0xc0200
ffffffffc0203f3c:	00f506b3          	add	a3,a0,a5
ffffffffc0203f40:	60e6e563          	bltu	a3,a4,ffffffffc020454a <pmm_init+0x6dc>
ffffffffc0203f44:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203f48:	4745                	li	a4,17
ffffffffc0203f4a:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203f4c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203f4e:	4ae6e563          	bltu	a3,a4,ffffffffc02043f8 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203f52:	00004517          	auipc	a0,0x4
ffffffffc0203f56:	dbe50513          	addi	a0,a0,-578 # ffffffffc0207d10 <default_pmm_manager+0x108>
ffffffffc0203f5a:	972fc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203f5e:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f62:	000af917          	auipc	s2,0xaf
ffffffffc0203f66:	ae690913          	addi	s2,s2,-1306 # ffffffffc02b2a48 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203f6a:	7b9c                	ld	a5,48(a5)
ffffffffc0203f6c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203f6e:	00004517          	auipc	a0,0x4
ffffffffc0203f72:	dba50513          	addi	a0,a0,-582 # ffffffffc0207d28 <default_pmm_manager+0x120>
ffffffffc0203f76:	956fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f7a:	00007697          	auipc	a3,0x7
ffffffffc0203f7e:	08668693          	addi	a3,a3,134 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203f82:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203f86:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f8a:	5cf6ec63          	bltu	a3,a5,ffffffffc0204562 <pmm_init+0x6f4>
ffffffffc0203f8e:	0009b783          	ld	a5,0(s3)
ffffffffc0203f92:	8e9d                	sub	a3,a3,a5
ffffffffc0203f94:	000af797          	auipc	a5,0xaf
ffffffffc0203f98:	aad7b623          	sd	a3,-1364(a5) # ffffffffc02b2a40 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203f9c:	100027f3          	csrr	a5,sstatus
ffffffffc0203fa0:	8b89                	andi	a5,a5,2
ffffffffc0203fa2:	48079263          	bnez	a5,ffffffffc0204426 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203fa6:	000bb783          	ld	a5,0(s7)
ffffffffc0203faa:	779c                	ld	a5,40(a5)
ffffffffc0203fac:	9782                	jalr	a5
ffffffffc0203fae:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203fb0:	6098                	ld	a4,0(s1)
ffffffffc0203fb2:	c80007b7          	lui	a5,0xc8000
ffffffffc0203fb6:	83b1                	srli	a5,a5,0xc
ffffffffc0203fb8:	5ee7e163          	bltu	a5,a4,ffffffffc020459a <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203fbc:	00093503          	ld	a0,0(s2)
ffffffffc0203fc0:	5a050d63          	beqz	a0,ffffffffc020457a <pmm_init+0x70c>
ffffffffc0203fc4:	03451793          	slli	a5,a0,0x34
ffffffffc0203fc8:	5a079963          	bnez	a5,ffffffffc020457a <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203fcc:	4601                	li	a2,0
ffffffffc0203fce:	4581                	li	a1,0
ffffffffc0203fd0:	f54ff0ef          	jal	ra,ffffffffc0203724 <get_page>
ffffffffc0203fd4:	62051563          	bnez	a0,ffffffffc02045fe <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203fd8:	4505                	li	a0,1
ffffffffc0203fda:	c6cff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0203fde:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203fe0:	00093503          	ld	a0,0(s2)
ffffffffc0203fe4:	4681                	li	a3,0
ffffffffc0203fe6:	4601                	li	a2,0
ffffffffc0203fe8:	85d2                	mv	a1,s4
ffffffffc0203fea:	d8fff0ef          	jal	ra,ffffffffc0203d78 <page_insert>
ffffffffc0203fee:	5e051863          	bnez	a0,ffffffffc02045de <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203ff2:	00093503          	ld	a0,0(s2)
ffffffffc0203ff6:	4601                	li	a2,0
ffffffffc0203ff8:	4581                	li	a1,0
ffffffffc0203ffa:	d58ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0203ffe:	5c050063          	beqz	a0,ffffffffc02045be <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0204002:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0204004:	0017f713          	andi	a4,a5,1
ffffffffc0204008:	5a070963          	beqz	a4,ffffffffc02045ba <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020400c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020400e:	078a                	slli	a5,a5,0x2
ffffffffc0204010:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204012:	52e7fa63          	bgeu	a5,a4,ffffffffc0204546 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204016:	000b3683          	ld	a3,0(s6)
ffffffffc020401a:	fff80637          	lui	a2,0xfff80
ffffffffc020401e:	97b2                	add	a5,a5,a2
ffffffffc0204020:	079a                	slli	a5,a5,0x6
ffffffffc0204022:	97b6                	add	a5,a5,a3
ffffffffc0204024:	10fa16e3          	bne	s4,a5,ffffffffc0204930 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0204028:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc020402c:	4785                	li	a5,1
ffffffffc020402e:	12f69de3          	bne	a3,a5,ffffffffc0204968 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204032:	00093503          	ld	a0,0(s2)
ffffffffc0204036:	77fd                	lui	a5,0xfffff
ffffffffc0204038:	6114                	ld	a3,0(a0)
ffffffffc020403a:	068a                	slli	a3,a3,0x2
ffffffffc020403c:	8efd                	and	a3,a3,a5
ffffffffc020403e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0204042:	10e677e3          	bgeu	a2,a4,ffffffffc0204950 <pmm_init+0xae2>
ffffffffc0204046:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020404a:	96e2                	add	a3,a3,s8
ffffffffc020404c:	0006ba83          	ld	s5,0(a3)
ffffffffc0204050:	0a8a                	slli	s5,s5,0x2
ffffffffc0204052:	00fafab3          	and	s5,s5,a5
ffffffffc0204056:	00cad793          	srli	a5,s5,0xc
ffffffffc020405a:	62e7f263          	bgeu	a5,a4,ffffffffc020467e <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020405e:	4601                	li	a2,0
ffffffffc0204060:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204062:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204064:	ceeff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204068:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020406a:	5f551a63          	bne	a0,s5,ffffffffc020465e <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc020406e:	4505                	li	a0,1
ffffffffc0204070:	bd6ff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0204074:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204076:	00093503          	ld	a0,0(s2)
ffffffffc020407a:	46d1                	li	a3,20
ffffffffc020407c:	6605                	lui	a2,0x1
ffffffffc020407e:	85d6                	mv	a1,s5
ffffffffc0204080:	cf9ff0ef          	jal	ra,ffffffffc0203d78 <page_insert>
ffffffffc0204084:	58051d63          	bnez	a0,ffffffffc020461e <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204088:	00093503          	ld	a0,0(s2)
ffffffffc020408c:	4601                	li	a2,0
ffffffffc020408e:	6585                	lui	a1,0x1
ffffffffc0204090:	cc2ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0204094:	0e050ae3          	beqz	a0,ffffffffc0204988 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0204098:	611c                	ld	a5,0(a0)
ffffffffc020409a:	0107f713          	andi	a4,a5,16
ffffffffc020409e:	6e070d63          	beqz	a4,ffffffffc0204798 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02040a2:	8b91                	andi	a5,a5,4
ffffffffc02040a4:	6a078a63          	beqz	a5,ffffffffc0204758 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02040a8:	00093503          	ld	a0,0(s2)
ffffffffc02040ac:	611c                	ld	a5,0(a0)
ffffffffc02040ae:	8bc1                	andi	a5,a5,16
ffffffffc02040b0:	68078463          	beqz	a5,ffffffffc0204738 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02040b4:	000aa703          	lw	a4,0(s5)
ffffffffc02040b8:	4785                	li	a5,1
ffffffffc02040ba:	58f71263          	bne	a4,a5,ffffffffc020463e <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02040be:	4681                	li	a3,0
ffffffffc02040c0:	6605                	lui	a2,0x1
ffffffffc02040c2:	85d2                	mv	a1,s4
ffffffffc02040c4:	cb5ff0ef          	jal	ra,ffffffffc0203d78 <page_insert>
ffffffffc02040c8:	62051863          	bnez	a0,ffffffffc02046f8 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02040cc:	000a2703          	lw	a4,0(s4)
ffffffffc02040d0:	4789                	li	a5,2
ffffffffc02040d2:	60f71363          	bne	a4,a5,ffffffffc02046d8 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02040d6:	000aa783          	lw	a5,0(s5)
ffffffffc02040da:	5c079f63          	bnez	a5,ffffffffc02046b8 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02040de:	00093503          	ld	a0,0(s2)
ffffffffc02040e2:	4601                	li	a2,0
ffffffffc02040e4:	6585                	lui	a1,0x1
ffffffffc02040e6:	c6cff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc02040ea:	5a050763          	beqz	a0,ffffffffc0204698 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02040ee:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02040f0:	00177793          	andi	a5,a4,1
ffffffffc02040f4:	4c078363          	beqz	a5,ffffffffc02045ba <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02040f8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02040fa:	00271793          	slli	a5,a4,0x2
ffffffffc02040fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204100:	44d7f363          	bgeu	a5,a3,ffffffffc0204546 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204104:	000b3683          	ld	a3,0(s6)
ffffffffc0204108:	fff80637          	lui	a2,0xfff80
ffffffffc020410c:	97b2                	add	a5,a5,a2
ffffffffc020410e:	079a                	slli	a5,a5,0x6
ffffffffc0204110:	97b6                	add	a5,a5,a3
ffffffffc0204112:	6efa1363          	bne	s4,a5,ffffffffc02047f8 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0204116:	8b41                	andi	a4,a4,16
ffffffffc0204118:	6c071063          	bnez	a4,ffffffffc02047d8 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020411c:	00093503          	ld	a0,0(s2)
ffffffffc0204120:	4581                	li	a1,0
ffffffffc0204122:	bbbff0ef          	jal	ra,ffffffffc0203cdc <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0204126:	000a2703          	lw	a4,0(s4)
ffffffffc020412a:	4785                	li	a5,1
ffffffffc020412c:	68f71663          	bne	a4,a5,ffffffffc02047b8 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0204130:	000aa783          	lw	a5,0(s5)
ffffffffc0204134:	74079e63          	bnez	a5,ffffffffc0204890 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0204138:	00093503          	ld	a0,0(s2)
ffffffffc020413c:	6585                	lui	a1,0x1
ffffffffc020413e:	b9fff0ef          	jal	ra,ffffffffc0203cdc <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0204142:	000a2783          	lw	a5,0(s4)
ffffffffc0204146:	72079563          	bnez	a5,ffffffffc0204870 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc020414a:	000aa783          	lw	a5,0(s5)
ffffffffc020414e:	70079163          	bnez	a5,ffffffffc0204850 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0204152:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204156:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204158:	000a3683          	ld	a3,0(s4)
ffffffffc020415c:	068a                	slli	a3,a3,0x2
ffffffffc020415e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204160:	3ee6f363          	bgeu	a3,a4,ffffffffc0204546 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204164:	fff807b7          	lui	a5,0xfff80
ffffffffc0204168:	000b3503          	ld	a0,0(s6)
ffffffffc020416c:	96be                	add	a3,a3,a5
ffffffffc020416e:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0204170:	00d507b3          	add	a5,a0,a3
ffffffffc0204174:	4390                	lw	a2,0(a5)
ffffffffc0204176:	4785                	li	a5,1
ffffffffc0204178:	6af61c63          	bne	a2,a5,ffffffffc0204830 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc020417c:	8699                	srai	a3,a3,0x6
ffffffffc020417e:	000805b7          	lui	a1,0x80
ffffffffc0204182:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0204184:	00c69613          	slli	a2,a3,0xc
ffffffffc0204188:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020418a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020418c:	68e67663          	bgeu	a2,a4,ffffffffc0204818 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0204190:	0009b603          	ld	a2,0(s3)
ffffffffc0204194:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0204196:	629c                	ld	a5,0(a3)
ffffffffc0204198:	078a                	slli	a5,a5,0x2
ffffffffc020419a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020419c:	3ae7f563          	bgeu	a5,a4,ffffffffc0204546 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02041a0:	8f8d                	sub	a5,a5,a1
ffffffffc02041a2:	079a                	slli	a5,a5,0x6
ffffffffc02041a4:	953e                	add	a0,a0,a5
ffffffffc02041a6:	100027f3          	csrr	a5,sstatus
ffffffffc02041aa:	8b89                	andi	a5,a5,2
ffffffffc02041ac:	2c079763          	bnez	a5,ffffffffc020447a <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02041b0:	000bb783          	ld	a5,0(s7)
ffffffffc02041b4:	4585                	li	a1,1
ffffffffc02041b6:	739c                	ld	a5,32(a5)
ffffffffc02041b8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02041ba:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02041be:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02041c0:	078a                	slli	a5,a5,0x2
ffffffffc02041c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041c4:	38e7f163          	bgeu	a5,a4,ffffffffc0204546 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02041c8:	000b3503          	ld	a0,0(s6)
ffffffffc02041cc:	fff80737          	lui	a4,0xfff80
ffffffffc02041d0:	97ba                	add	a5,a5,a4
ffffffffc02041d2:	079a                	slli	a5,a5,0x6
ffffffffc02041d4:	953e                	add	a0,a0,a5
ffffffffc02041d6:	100027f3          	csrr	a5,sstatus
ffffffffc02041da:	8b89                	andi	a5,a5,2
ffffffffc02041dc:	28079363          	bnez	a5,ffffffffc0204462 <pmm_init+0x5f4>
ffffffffc02041e0:	000bb783          	ld	a5,0(s7)
ffffffffc02041e4:	4585                	li	a1,1
ffffffffc02041e6:	739c                	ld	a5,32(a5)
ffffffffc02041e8:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02041ea:	00093783          	ld	a5,0(s2)
ffffffffc02041ee:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd574>
  asm volatile("sfence.vma");
ffffffffc02041f2:	12000073          	sfence.vma
ffffffffc02041f6:	100027f3          	csrr	a5,sstatus
ffffffffc02041fa:	8b89                	andi	a5,a5,2
ffffffffc02041fc:	24079963          	bnez	a5,ffffffffc020444e <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204200:	000bb783          	ld	a5,0(s7)
ffffffffc0204204:	779c                	ld	a5,40(a5)
ffffffffc0204206:	9782                	jalr	a5
ffffffffc0204208:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020420a:	71441363          	bne	s0,s4,ffffffffc0204910 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020420e:	00004517          	auipc	a0,0x4
ffffffffc0204212:	e0250513          	addi	a0,a0,-510 # ffffffffc0208010 <default_pmm_manager+0x408>
ffffffffc0204216:	eb7fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020421a:	100027f3          	csrr	a5,sstatus
ffffffffc020421e:	8b89                	andi	a5,a5,2
ffffffffc0204220:	20079d63          	bnez	a5,ffffffffc020443a <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204224:	000bb783          	ld	a5,0(s7)
ffffffffc0204228:	779c                	ld	a5,40(a5)
ffffffffc020422a:	9782                	jalr	a5
ffffffffc020422c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020422e:	6098                	ld	a4,0(s1)
ffffffffc0204230:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204234:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204236:	00c71793          	slli	a5,a4,0xc
ffffffffc020423a:	6a05                	lui	s4,0x1
ffffffffc020423c:	02f47c63          	bgeu	s0,a5,ffffffffc0204274 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204240:	00c45793          	srli	a5,s0,0xc
ffffffffc0204244:	00093503          	ld	a0,0(s2)
ffffffffc0204248:	2ee7f263          	bgeu	a5,a4,ffffffffc020452c <pmm_init+0x6be>
ffffffffc020424c:	0009b583          	ld	a1,0(s3)
ffffffffc0204250:	4601                	li	a2,0
ffffffffc0204252:	95a2                	add	a1,a1,s0
ffffffffc0204254:	afeff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0204258:	2a050a63          	beqz	a0,ffffffffc020450c <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020425c:	611c                	ld	a5,0(a0)
ffffffffc020425e:	078a                	slli	a5,a5,0x2
ffffffffc0204260:	0157f7b3          	and	a5,a5,s5
ffffffffc0204264:	28879463          	bne	a5,s0,ffffffffc02044ec <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204268:	6098                	ld	a4,0(s1)
ffffffffc020426a:	9452                	add	s0,s0,s4
ffffffffc020426c:	00c71793          	slli	a5,a4,0xc
ffffffffc0204270:	fcf468e3          	bltu	s0,a5,ffffffffc0204240 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0204274:	00093783          	ld	a5,0(s2)
ffffffffc0204278:	639c                	ld	a5,0(a5)
ffffffffc020427a:	66079b63          	bnez	a5,ffffffffc02048f0 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc020427e:	4505                	li	a0,1
ffffffffc0204280:	9c6ff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0204284:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0204286:	00093503          	ld	a0,0(s2)
ffffffffc020428a:	4699                	li	a3,6
ffffffffc020428c:	10000613          	li	a2,256
ffffffffc0204290:	85d6                	mv	a1,s5
ffffffffc0204292:	ae7ff0ef          	jal	ra,ffffffffc0203d78 <page_insert>
ffffffffc0204296:	62051d63          	bnez	a0,ffffffffc02048d0 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc020429a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c574>
ffffffffc020429e:	4785                	li	a5,1
ffffffffc02042a0:	60f71863          	bne	a4,a5,ffffffffc02048b0 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02042a4:	00093503          	ld	a0,0(s2)
ffffffffc02042a8:	6405                	lui	s0,0x1
ffffffffc02042aa:	4699                	li	a3,6
ffffffffc02042ac:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ad8>
ffffffffc02042b0:	85d6                	mv	a1,s5
ffffffffc02042b2:	ac7ff0ef          	jal	ra,ffffffffc0203d78 <page_insert>
ffffffffc02042b6:	46051163          	bnez	a0,ffffffffc0204718 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02042ba:	000aa703          	lw	a4,0(s5)
ffffffffc02042be:	4789                	li	a5,2
ffffffffc02042c0:	72f71463          	bne	a4,a5,ffffffffc02049e8 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02042c4:	00004597          	auipc	a1,0x4
ffffffffc02042c8:	e8458593          	addi	a1,a1,-380 # ffffffffc0208148 <default_pmm_manager+0x540>
ffffffffc02042cc:	10000513          	li	a0,256
ffffffffc02042d0:	563010ef          	jal	ra,ffffffffc0206032 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02042d4:	10040593          	addi	a1,s0,256
ffffffffc02042d8:	10000513          	li	a0,256
ffffffffc02042dc:	569010ef          	jal	ra,ffffffffc0206044 <strcmp>
ffffffffc02042e0:	6e051463          	bnez	a0,ffffffffc02049c8 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02042e4:	000b3683          	ld	a3,0(s6)
ffffffffc02042e8:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02042ec:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02042ee:	40da86b3          	sub	a3,s5,a3
ffffffffc02042f2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02042f4:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02042f6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02042f8:	8031                	srli	s0,s0,0xc
ffffffffc02042fa:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02042fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204300:	50f77c63          	bgeu	a4,a5,ffffffffc0204818 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204304:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204308:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020430c:	96be                	add	a3,a3,a5
ffffffffc020430e:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204312:	4eb010ef          	jal	ra,ffffffffc0205ffc <strlen>
ffffffffc0204316:	68051963          	bnez	a0,ffffffffc02049a8 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020431a:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020431e:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204320:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc0204324:	068a                	slli	a3,a3,0x2
ffffffffc0204326:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204328:	20f6ff63          	bgeu	a3,a5,ffffffffc0204546 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc020432c:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020432e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204330:	4ef47463          	bgeu	s0,a5,ffffffffc0204818 <pmm_init+0x9aa>
ffffffffc0204334:	0009b403          	ld	s0,0(s3)
ffffffffc0204338:	9436                	add	s0,s0,a3
ffffffffc020433a:	100027f3          	csrr	a5,sstatus
ffffffffc020433e:	8b89                	andi	a5,a5,2
ffffffffc0204340:	18079b63          	bnez	a5,ffffffffc02044d6 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0204344:	000bb783          	ld	a5,0(s7)
ffffffffc0204348:	4585                	li	a1,1
ffffffffc020434a:	8556                	mv	a0,s5
ffffffffc020434c:	739c                	ld	a5,32(a5)
ffffffffc020434e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204350:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204352:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204354:	078a                	slli	a5,a5,0x2
ffffffffc0204356:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204358:	1ee7f763          	bgeu	a5,a4,ffffffffc0204546 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020435c:	000b3503          	ld	a0,0(s6)
ffffffffc0204360:	fff80737          	lui	a4,0xfff80
ffffffffc0204364:	97ba                	add	a5,a5,a4
ffffffffc0204366:	079a                	slli	a5,a5,0x6
ffffffffc0204368:	953e                	add	a0,a0,a5
ffffffffc020436a:	100027f3          	csrr	a5,sstatus
ffffffffc020436e:	8b89                	andi	a5,a5,2
ffffffffc0204370:	14079763          	bnez	a5,ffffffffc02044be <pmm_init+0x650>
ffffffffc0204374:	000bb783          	ld	a5,0(s7)
ffffffffc0204378:	4585                	li	a1,1
ffffffffc020437a:	739c                	ld	a5,32(a5)
ffffffffc020437c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020437e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204382:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204384:	078a                	slli	a5,a5,0x2
ffffffffc0204386:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204388:	1ae7ff63          	bgeu	a5,a4,ffffffffc0204546 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020438c:	000b3503          	ld	a0,0(s6)
ffffffffc0204390:	fff80737          	lui	a4,0xfff80
ffffffffc0204394:	97ba                	add	a5,a5,a4
ffffffffc0204396:	079a                	slli	a5,a5,0x6
ffffffffc0204398:	953e                	add	a0,a0,a5
ffffffffc020439a:	100027f3          	csrr	a5,sstatus
ffffffffc020439e:	8b89                	andi	a5,a5,2
ffffffffc02043a0:	10079363          	bnez	a5,ffffffffc02044a6 <pmm_init+0x638>
ffffffffc02043a4:	000bb783          	ld	a5,0(s7)
ffffffffc02043a8:	4585                	li	a1,1
ffffffffc02043aa:	739c                	ld	a5,32(a5)
ffffffffc02043ac:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02043ae:	00093783          	ld	a5,0(s2)
ffffffffc02043b2:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02043b6:	12000073          	sfence.vma
ffffffffc02043ba:	100027f3          	csrr	a5,sstatus
ffffffffc02043be:	8b89                	andi	a5,a5,2
ffffffffc02043c0:	0c079963          	bnez	a5,ffffffffc0204492 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc02043c4:	000bb783          	ld	a5,0(s7)
ffffffffc02043c8:	779c                	ld	a5,40(a5)
ffffffffc02043ca:	9782                	jalr	a5
ffffffffc02043cc:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02043ce:	3a8c1563          	bne	s8,s0,ffffffffc0204778 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02043d2:	00004517          	auipc	a0,0x4
ffffffffc02043d6:	dee50513          	addi	a0,a0,-530 # ffffffffc02081c0 <default_pmm_manager+0x5b8>
ffffffffc02043da:	cf3fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02043de:	6446                	ld	s0,80(sp)
ffffffffc02043e0:	60e6                	ld	ra,88(sp)
ffffffffc02043e2:	64a6                	ld	s1,72(sp)
ffffffffc02043e4:	6906                	ld	s2,64(sp)
ffffffffc02043e6:	79e2                	ld	s3,56(sp)
ffffffffc02043e8:	7a42                	ld	s4,48(sp)
ffffffffc02043ea:	7aa2                	ld	s5,40(sp)
ffffffffc02043ec:	7b02                	ld	s6,32(sp)
ffffffffc02043ee:	6be2                	ld	s7,24(sp)
ffffffffc02043f0:	6c42                	ld	s8,16(sp)
ffffffffc02043f2:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02043f4:	a9bfd06f          	j	ffffffffc0201e8e <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02043f8:	6785                	lui	a5,0x1
ffffffffc02043fa:	17fd                	addi	a5,a5,-1
ffffffffc02043fc:	96be                	add	a3,a3,a5
ffffffffc02043fe:	77fd                	lui	a5,0xfffff
ffffffffc0204400:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0204402:	00c7d693          	srli	a3,a5,0xc
ffffffffc0204406:	14c6f063          	bgeu	a3,a2,ffffffffc0204546 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc020440a:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020440e:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0204410:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0204414:	6a10                	ld	a2,16(a2)
ffffffffc0204416:	069a                	slli	a3,a3,0x6
ffffffffc0204418:	00c7d593          	srli	a1,a5,0xc
ffffffffc020441c:	9536                	add	a0,a0,a3
ffffffffc020441e:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0204420:	0009b583          	ld	a1,0(s3)
}
ffffffffc0204424:	b63d                	j	ffffffffc0203f52 <pmm_init+0xe4>
        intr_disable();
ffffffffc0204426:	a22fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020442a:	000bb783          	ld	a5,0(s7)
ffffffffc020442e:	779c                	ld	a5,40(a5)
ffffffffc0204430:	9782                	jalr	a5
ffffffffc0204432:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0204434:	a0efc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204438:	bea5                	j	ffffffffc0203fb0 <pmm_init+0x142>
        intr_disable();
ffffffffc020443a:	a0efc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020443e:	000bb783          	ld	a5,0(s7)
ffffffffc0204442:	779c                	ld	a5,40(a5)
ffffffffc0204444:	9782                	jalr	a5
ffffffffc0204446:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0204448:	9fafc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020444c:	b3cd                	j	ffffffffc020422e <pmm_init+0x3c0>
        intr_disable();
ffffffffc020444e:	9fafc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204452:	000bb783          	ld	a5,0(s7)
ffffffffc0204456:	779c                	ld	a5,40(a5)
ffffffffc0204458:	9782                	jalr	a5
ffffffffc020445a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020445c:	9e6fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204460:	b36d                	j	ffffffffc020420a <pmm_init+0x39c>
ffffffffc0204462:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204464:	9e4fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204468:	000bb783          	ld	a5,0(s7)
ffffffffc020446c:	6522                	ld	a0,8(sp)
ffffffffc020446e:	4585                	li	a1,1
ffffffffc0204470:	739c                	ld	a5,32(a5)
ffffffffc0204472:	9782                	jalr	a5
        intr_enable();
ffffffffc0204474:	9cefc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204478:	bb8d                	j	ffffffffc02041ea <pmm_init+0x37c>
ffffffffc020447a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020447c:	9ccfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204480:	000bb783          	ld	a5,0(s7)
ffffffffc0204484:	6522                	ld	a0,8(sp)
ffffffffc0204486:	4585                	li	a1,1
ffffffffc0204488:	739c                	ld	a5,32(a5)
ffffffffc020448a:	9782                	jalr	a5
        intr_enable();
ffffffffc020448c:	9b6fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204490:	b32d                	j	ffffffffc02041ba <pmm_init+0x34c>
        intr_disable();
ffffffffc0204492:	9b6fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204496:	000bb783          	ld	a5,0(s7)
ffffffffc020449a:	779c                	ld	a5,40(a5)
ffffffffc020449c:	9782                	jalr	a5
ffffffffc020449e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02044a0:	9a2fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02044a4:	b72d                	j	ffffffffc02043ce <pmm_init+0x560>
ffffffffc02044a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02044a8:	9a0fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02044ac:	000bb783          	ld	a5,0(s7)
ffffffffc02044b0:	6522                	ld	a0,8(sp)
ffffffffc02044b2:	4585                	li	a1,1
ffffffffc02044b4:	739c                	ld	a5,32(a5)
ffffffffc02044b6:	9782                	jalr	a5
        intr_enable();
ffffffffc02044b8:	98afc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02044bc:	bdcd                	j	ffffffffc02043ae <pmm_init+0x540>
ffffffffc02044be:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02044c0:	988fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02044c4:	000bb783          	ld	a5,0(s7)
ffffffffc02044c8:	6522                	ld	a0,8(sp)
ffffffffc02044ca:	4585                	li	a1,1
ffffffffc02044cc:	739c                	ld	a5,32(a5)
ffffffffc02044ce:	9782                	jalr	a5
        intr_enable();
ffffffffc02044d0:	972fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02044d4:	b56d                	j	ffffffffc020437e <pmm_init+0x510>
        intr_disable();
ffffffffc02044d6:	972fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02044da:	000bb783          	ld	a5,0(s7)
ffffffffc02044de:	4585                	li	a1,1
ffffffffc02044e0:	8556                	mv	a0,s5
ffffffffc02044e2:	739c                	ld	a5,32(a5)
ffffffffc02044e4:	9782                	jalr	a5
        intr_enable();
ffffffffc02044e6:	95cfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02044ea:	b59d                	j	ffffffffc0204350 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02044ec:	00004697          	auipc	a3,0x4
ffffffffc02044f0:	b8468693          	addi	a3,a3,-1148 # ffffffffc0208070 <default_pmm_manager+0x468>
ffffffffc02044f4:	00002617          	auipc	a2,0x2
ffffffffc02044f8:	66c60613          	addi	a2,a2,1644 # ffffffffc0206b60 <commands+0x410>
ffffffffc02044fc:	22500593          	li	a1,549
ffffffffc0204500:	00003517          	auipc	a0,0x3
ffffffffc0204504:	74050513          	addi	a0,a0,1856 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204508:	d01fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020450c:	00004697          	auipc	a3,0x4
ffffffffc0204510:	b2468693          	addi	a3,a3,-1244 # ffffffffc0208030 <default_pmm_manager+0x428>
ffffffffc0204514:	00002617          	auipc	a2,0x2
ffffffffc0204518:	64c60613          	addi	a2,a2,1612 # ffffffffc0206b60 <commands+0x410>
ffffffffc020451c:	22400593          	li	a1,548
ffffffffc0204520:	00003517          	auipc	a0,0x3
ffffffffc0204524:	72050513          	addi	a0,a0,1824 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204528:	ce1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020452c:	86a2                	mv	a3,s0
ffffffffc020452e:	00003617          	auipc	a2,0x3
ffffffffc0204532:	c0260613          	addi	a2,a2,-1022 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0204536:	22400593          	li	a1,548
ffffffffc020453a:	00003517          	auipc	a0,0x3
ffffffffc020453e:	70650513          	addi	a0,a0,1798 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204542:	cc7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204546:	ec9fe0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020454a:	00003617          	auipc	a2,0x3
ffffffffc020454e:	f6e60613          	addi	a2,a2,-146 # ffffffffc02074b8 <commands+0xd68>
ffffffffc0204552:	07f00593          	li	a1,127
ffffffffc0204556:	00003517          	auipc	a0,0x3
ffffffffc020455a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020455e:	cabfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0204562:	00003617          	auipc	a2,0x3
ffffffffc0204566:	f5660613          	addi	a2,a2,-170 # ffffffffc02074b8 <commands+0xd68>
ffffffffc020456a:	0c100593          	li	a1,193
ffffffffc020456e:	00003517          	auipc	a0,0x3
ffffffffc0204572:	6d250513          	addi	a0,a0,1746 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204576:	c93fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020457a:	00003697          	auipc	a3,0x3
ffffffffc020457e:	7ee68693          	addi	a3,a3,2030 # ffffffffc0207d68 <default_pmm_manager+0x160>
ffffffffc0204582:	00002617          	auipc	a2,0x2
ffffffffc0204586:	5de60613          	addi	a2,a2,1502 # ffffffffc0206b60 <commands+0x410>
ffffffffc020458a:	1e800593          	li	a1,488
ffffffffc020458e:	00003517          	auipc	a0,0x3
ffffffffc0204592:	6b250513          	addi	a0,a0,1714 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204596:	c73fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020459a:	00003697          	auipc	a3,0x3
ffffffffc020459e:	7ae68693          	addi	a3,a3,1966 # ffffffffc0207d48 <default_pmm_manager+0x140>
ffffffffc02045a2:	00002617          	auipc	a2,0x2
ffffffffc02045a6:	5be60613          	addi	a2,a2,1470 # ffffffffc0206b60 <commands+0x410>
ffffffffc02045aa:	1e700593          	li	a1,487
ffffffffc02045ae:	00003517          	auipc	a0,0x3
ffffffffc02045b2:	69250513          	addi	a0,a0,1682 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02045b6:	c53fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02045ba:	e71fe0ef          	jal	ra,ffffffffc020342a <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02045be:	00004697          	auipc	a3,0x4
ffffffffc02045c2:	83a68693          	addi	a3,a3,-1990 # ffffffffc0207df8 <default_pmm_manager+0x1f0>
ffffffffc02045c6:	00002617          	auipc	a2,0x2
ffffffffc02045ca:	59a60613          	addi	a2,a2,1434 # ffffffffc0206b60 <commands+0x410>
ffffffffc02045ce:	1f000593          	li	a1,496
ffffffffc02045d2:	00003517          	auipc	a0,0x3
ffffffffc02045d6:	66e50513          	addi	a0,a0,1646 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02045da:	c2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02045de:	00003697          	auipc	a3,0x3
ffffffffc02045e2:	7ea68693          	addi	a3,a3,2026 # ffffffffc0207dc8 <default_pmm_manager+0x1c0>
ffffffffc02045e6:	00002617          	auipc	a2,0x2
ffffffffc02045ea:	57a60613          	addi	a2,a2,1402 # ffffffffc0206b60 <commands+0x410>
ffffffffc02045ee:	1ed00593          	li	a1,493
ffffffffc02045f2:	00003517          	auipc	a0,0x3
ffffffffc02045f6:	64e50513          	addi	a0,a0,1614 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02045fa:	c0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02045fe:	00003697          	auipc	a3,0x3
ffffffffc0204602:	7a268693          	addi	a3,a3,1954 # ffffffffc0207da0 <default_pmm_manager+0x198>
ffffffffc0204606:	00002617          	auipc	a2,0x2
ffffffffc020460a:	55a60613          	addi	a2,a2,1370 # ffffffffc0206b60 <commands+0x410>
ffffffffc020460e:	1e900593          	li	a1,489
ffffffffc0204612:	00003517          	auipc	a0,0x3
ffffffffc0204616:	62e50513          	addi	a0,a0,1582 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020461a:	beffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020461e:	00004697          	auipc	a3,0x4
ffffffffc0204622:	86268693          	addi	a3,a3,-1950 # ffffffffc0207e80 <default_pmm_manager+0x278>
ffffffffc0204626:	00002617          	auipc	a2,0x2
ffffffffc020462a:	53a60613          	addi	a2,a2,1338 # ffffffffc0206b60 <commands+0x410>
ffffffffc020462e:	1f900593          	li	a1,505
ffffffffc0204632:	00003517          	auipc	a0,0x3
ffffffffc0204636:	60e50513          	addi	a0,a0,1550 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020463a:	bcffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020463e:	00004697          	auipc	a3,0x4
ffffffffc0204642:	8e268693          	addi	a3,a3,-1822 # ffffffffc0207f20 <default_pmm_manager+0x318>
ffffffffc0204646:	00002617          	auipc	a2,0x2
ffffffffc020464a:	51a60613          	addi	a2,a2,1306 # ffffffffc0206b60 <commands+0x410>
ffffffffc020464e:	1fe00593          	li	a1,510
ffffffffc0204652:	00003517          	auipc	a0,0x3
ffffffffc0204656:	5ee50513          	addi	a0,a0,1518 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020465a:	baffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020465e:	00003697          	auipc	a3,0x3
ffffffffc0204662:	7fa68693          	addi	a3,a3,2042 # ffffffffc0207e58 <default_pmm_manager+0x250>
ffffffffc0204666:	00002617          	auipc	a2,0x2
ffffffffc020466a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0206b60 <commands+0x410>
ffffffffc020466e:	1f600593          	li	a1,502
ffffffffc0204672:	00003517          	auipc	a0,0x3
ffffffffc0204676:	5ce50513          	addi	a0,a0,1486 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020467a:	b8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020467e:	86d6                	mv	a3,s5
ffffffffc0204680:	00003617          	auipc	a2,0x3
ffffffffc0204684:	ab060613          	addi	a2,a2,-1360 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0204688:	1f500593          	li	a1,501
ffffffffc020468c:	00003517          	auipc	a0,0x3
ffffffffc0204690:	5b450513          	addi	a0,a0,1460 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204694:	b75fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204698:	00004697          	auipc	a3,0x4
ffffffffc020469c:	82068693          	addi	a3,a3,-2016 # ffffffffc0207eb8 <default_pmm_manager+0x2b0>
ffffffffc02046a0:	00002617          	auipc	a2,0x2
ffffffffc02046a4:	4c060613          	addi	a2,a2,1216 # ffffffffc0206b60 <commands+0x410>
ffffffffc02046a8:	20300593          	li	a1,515
ffffffffc02046ac:	00003517          	auipc	a0,0x3
ffffffffc02046b0:	59450513          	addi	a0,a0,1428 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02046b4:	b55fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02046b8:	00004697          	auipc	a3,0x4
ffffffffc02046bc:	8c868693          	addi	a3,a3,-1848 # ffffffffc0207f80 <default_pmm_manager+0x378>
ffffffffc02046c0:	00002617          	auipc	a2,0x2
ffffffffc02046c4:	4a060613          	addi	a2,a2,1184 # ffffffffc0206b60 <commands+0x410>
ffffffffc02046c8:	20200593          	li	a1,514
ffffffffc02046cc:	00003517          	auipc	a0,0x3
ffffffffc02046d0:	57450513          	addi	a0,a0,1396 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02046d4:	b35fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02046d8:	00004697          	auipc	a3,0x4
ffffffffc02046dc:	89068693          	addi	a3,a3,-1904 # ffffffffc0207f68 <default_pmm_manager+0x360>
ffffffffc02046e0:	00002617          	auipc	a2,0x2
ffffffffc02046e4:	48060613          	addi	a2,a2,1152 # ffffffffc0206b60 <commands+0x410>
ffffffffc02046e8:	20100593          	li	a1,513
ffffffffc02046ec:	00003517          	auipc	a0,0x3
ffffffffc02046f0:	55450513          	addi	a0,a0,1364 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02046f4:	b15fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02046f8:	00004697          	auipc	a3,0x4
ffffffffc02046fc:	84068693          	addi	a3,a3,-1984 # ffffffffc0207f38 <default_pmm_manager+0x330>
ffffffffc0204700:	00002617          	auipc	a2,0x2
ffffffffc0204704:	46060613          	addi	a2,a2,1120 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204708:	20000593          	li	a1,512
ffffffffc020470c:	00003517          	auipc	a0,0x3
ffffffffc0204710:	53450513          	addi	a0,a0,1332 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204714:	af5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0204718:	00004697          	auipc	a3,0x4
ffffffffc020471c:	9d868693          	addi	a3,a3,-1576 # ffffffffc02080f0 <default_pmm_manager+0x4e8>
ffffffffc0204720:	00002617          	auipc	a2,0x2
ffffffffc0204724:	44060613          	addi	a2,a2,1088 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204728:	22f00593          	li	a1,559
ffffffffc020472c:	00003517          	auipc	a0,0x3
ffffffffc0204730:	51450513          	addi	a0,a0,1300 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204734:	ad5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0204738:	00003697          	auipc	a3,0x3
ffffffffc020473c:	7d068693          	addi	a3,a3,2000 # ffffffffc0207f08 <default_pmm_manager+0x300>
ffffffffc0204740:	00002617          	auipc	a2,0x2
ffffffffc0204744:	42060613          	addi	a2,a2,1056 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204748:	1fd00593          	li	a1,509
ffffffffc020474c:	00003517          	auipc	a0,0x3
ffffffffc0204750:	4f450513          	addi	a0,a0,1268 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204754:	ab5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0204758:	00003697          	auipc	a3,0x3
ffffffffc020475c:	7a068693          	addi	a3,a3,1952 # ffffffffc0207ef8 <default_pmm_manager+0x2f0>
ffffffffc0204760:	00002617          	auipc	a2,0x2
ffffffffc0204764:	40060613          	addi	a2,a2,1024 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204768:	1fc00593          	li	a1,508
ffffffffc020476c:	00003517          	auipc	a0,0x3
ffffffffc0204770:	4d450513          	addi	a0,a0,1236 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204774:	a95fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204778:	00004697          	auipc	a3,0x4
ffffffffc020477c:	87868693          	addi	a3,a3,-1928 # ffffffffc0207ff0 <default_pmm_manager+0x3e8>
ffffffffc0204780:	00002617          	auipc	a2,0x2
ffffffffc0204784:	3e060613          	addi	a2,a2,992 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204788:	24000593          	li	a1,576
ffffffffc020478c:	00003517          	auipc	a0,0x3
ffffffffc0204790:	4b450513          	addi	a0,a0,1204 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204794:	a75fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0204798:	00003697          	auipc	a3,0x3
ffffffffc020479c:	75068693          	addi	a3,a3,1872 # ffffffffc0207ee8 <default_pmm_manager+0x2e0>
ffffffffc02047a0:	00002617          	auipc	a2,0x2
ffffffffc02047a4:	3c060613          	addi	a2,a2,960 # ffffffffc0206b60 <commands+0x410>
ffffffffc02047a8:	1fb00593          	li	a1,507
ffffffffc02047ac:	00003517          	auipc	a0,0x3
ffffffffc02047b0:	49450513          	addi	a0,a0,1172 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02047b4:	a55fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02047b8:	00003697          	auipc	a3,0x3
ffffffffc02047bc:	68868693          	addi	a3,a3,1672 # ffffffffc0207e40 <default_pmm_manager+0x238>
ffffffffc02047c0:	00002617          	auipc	a2,0x2
ffffffffc02047c4:	3a060613          	addi	a2,a2,928 # ffffffffc0206b60 <commands+0x410>
ffffffffc02047c8:	20800593          	li	a1,520
ffffffffc02047cc:	00003517          	auipc	a0,0x3
ffffffffc02047d0:	47450513          	addi	a0,a0,1140 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02047d4:	a35fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02047d8:	00003697          	auipc	a3,0x3
ffffffffc02047dc:	7c068693          	addi	a3,a3,1984 # ffffffffc0207f98 <default_pmm_manager+0x390>
ffffffffc02047e0:	00002617          	auipc	a2,0x2
ffffffffc02047e4:	38060613          	addi	a2,a2,896 # ffffffffc0206b60 <commands+0x410>
ffffffffc02047e8:	20500593          	li	a1,517
ffffffffc02047ec:	00003517          	auipc	a0,0x3
ffffffffc02047f0:	45450513          	addi	a0,a0,1108 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02047f4:	a15fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02047f8:	00003697          	auipc	a3,0x3
ffffffffc02047fc:	63068693          	addi	a3,a3,1584 # ffffffffc0207e28 <default_pmm_manager+0x220>
ffffffffc0204800:	00002617          	auipc	a2,0x2
ffffffffc0204804:	36060613          	addi	a2,a2,864 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204808:	20400593          	li	a1,516
ffffffffc020480c:	00003517          	auipc	a0,0x3
ffffffffc0204810:	43450513          	addi	a0,a0,1076 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204814:	9f5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204818:	00003617          	auipc	a2,0x3
ffffffffc020481c:	91860613          	addi	a2,a2,-1768 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0204820:	06900593          	li	a1,105
ffffffffc0204824:	00003517          	auipc	a0,0x3
ffffffffc0204828:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0207120 <commands+0x9d0>
ffffffffc020482c:	9ddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0204830:	00003697          	auipc	a3,0x3
ffffffffc0204834:	79868693          	addi	a3,a3,1944 # ffffffffc0207fc8 <default_pmm_manager+0x3c0>
ffffffffc0204838:	00002617          	auipc	a2,0x2
ffffffffc020483c:	32860613          	addi	a2,a2,808 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204840:	20f00593          	li	a1,527
ffffffffc0204844:	00003517          	auipc	a0,0x3
ffffffffc0204848:	3fc50513          	addi	a0,a0,1020 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020484c:	9bdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204850:	00003697          	auipc	a3,0x3
ffffffffc0204854:	73068693          	addi	a3,a3,1840 # ffffffffc0207f80 <default_pmm_manager+0x378>
ffffffffc0204858:	00002617          	auipc	a2,0x2
ffffffffc020485c:	30860613          	addi	a2,a2,776 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204860:	20d00593          	li	a1,525
ffffffffc0204864:	00003517          	auipc	a0,0x3
ffffffffc0204868:	3dc50513          	addi	a0,a0,988 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020486c:	99dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0204870:	00003697          	auipc	a3,0x3
ffffffffc0204874:	74068693          	addi	a3,a3,1856 # ffffffffc0207fb0 <default_pmm_manager+0x3a8>
ffffffffc0204878:	00002617          	auipc	a2,0x2
ffffffffc020487c:	2e860613          	addi	a2,a2,744 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204880:	20c00593          	li	a1,524
ffffffffc0204884:	00003517          	auipc	a0,0x3
ffffffffc0204888:	3bc50513          	addi	a0,a0,956 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020488c:	97dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204890:	00003697          	auipc	a3,0x3
ffffffffc0204894:	6f068693          	addi	a3,a3,1776 # ffffffffc0207f80 <default_pmm_manager+0x378>
ffffffffc0204898:	00002617          	auipc	a2,0x2
ffffffffc020489c:	2c860613          	addi	a2,a2,712 # ffffffffc0206b60 <commands+0x410>
ffffffffc02048a0:	20900593          	li	a1,521
ffffffffc02048a4:	00003517          	auipc	a0,0x3
ffffffffc02048a8:	39c50513          	addi	a0,a0,924 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02048ac:	95dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02048b0:	00004697          	auipc	a3,0x4
ffffffffc02048b4:	82868693          	addi	a3,a3,-2008 # ffffffffc02080d8 <default_pmm_manager+0x4d0>
ffffffffc02048b8:	00002617          	auipc	a2,0x2
ffffffffc02048bc:	2a860613          	addi	a2,a2,680 # ffffffffc0206b60 <commands+0x410>
ffffffffc02048c0:	22e00593          	li	a1,558
ffffffffc02048c4:	00003517          	auipc	a0,0x3
ffffffffc02048c8:	37c50513          	addi	a0,a0,892 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02048cc:	93dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02048d0:	00003697          	auipc	a3,0x3
ffffffffc02048d4:	7d068693          	addi	a3,a3,2000 # ffffffffc02080a0 <default_pmm_manager+0x498>
ffffffffc02048d8:	00002617          	auipc	a2,0x2
ffffffffc02048dc:	28860613          	addi	a2,a2,648 # ffffffffc0206b60 <commands+0x410>
ffffffffc02048e0:	22d00593          	li	a1,557
ffffffffc02048e4:	00003517          	auipc	a0,0x3
ffffffffc02048e8:	35c50513          	addi	a0,a0,860 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02048ec:	91dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02048f0:	00003697          	auipc	a3,0x3
ffffffffc02048f4:	79868693          	addi	a3,a3,1944 # ffffffffc0208088 <default_pmm_manager+0x480>
ffffffffc02048f8:	00002617          	auipc	a2,0x2
ffffffffc02048fc:	26860613          	addi	a2,a2,616 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204900:	22900593          	li	a1,553
ffffffffc0204904:	00003517          	auipc	a0,0x3
ffffffffc0204908:	33c50513          	addi	a0,a0,828 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020490c:	8fdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204910:	00003697          	auipc	a3,0x3
ffffffffc0204914:	6e068693          	addi	a3,a3,1760 # ffffffffc0207ff0 <default_pmm_manager+0x3e8>
ffffffffc0204918:	00002617          	auipc	a2,0x2
ffffffffc020491c:	24860613          	addi	a2,a2,584 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204920:	21700593          	li	a1,535
ffffffffc0204924:	00003517          	auipc	a0,0x3
ffffffffc0204928:	31c50513          	addi	a0,a0,796 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020492c:	8ddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0204930:	00003697          	auipc	a3,0x3
ffffffffc0204934:	4f868693          	addi	a3,a3,1272 # ffffffffc0207e28 <default_pmm_manager+0x220>
ffffffffc0204938:	00002617          	auipc	a2,0x2
ffffffffc020493c:	22860613          	addi	a2,a2,552 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204940:	1f100593          	li	a1,497
ffffffffc0204944:	00003517          	auipc	a0,0x3
ffffffffc0204948:	2fc50513          	addi	a0,a0,764 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc020494c:	8bdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204950:	00002617          	auipc	a2,0x2
ffffffffc0204954:	7e060613          	addi	a2,a2,2016 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0204958:	1f400593          	li	a1,500
ffffffffc020495c:	00003517          	auipc	a0,0x3
ffffffffc0204960:	2e450513          	addi	a0,a0,740 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204964:	8a5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0204968:	00003697          	auipc	a3,0x3
ffffffffc020496c:	4d868693          	addi	a3,a3,1240 # ffffffffc0207e40 <default_pmm_manager+0x238>
ffffffffc0204970:	00002617          	auipc	a2,0x2
ffffffffc0204974:	1f060613          	addi	a2,a2,496 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204978:	1f200593          	li	a1,498
ffffffffc020497c:	00003517          	auipc	a0,0x3
ffffffffc0204980:	2c450513          	addi	a0,a0,708 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204984:	885fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204988:	00003697          	auipc	a3,0x3
ffffffffc020498c:	53068693          	addi	a3,a3,1328 # ffffffffc0207eb8 <default_pmm_manager+0x2b0>
ffffffffc0204990:	00002617          	auipc	a2,0x2
ffffffffc0204994:	1d060613          	addi	a2,a2,464 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204998:	1fa00593          	li	a1,506
ffffffffc020499c:	00003517          	auipc	a0,0x3
ffffffffc02049a0:	2a450513          	addi	a0,a0,676 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02049a4:	865fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02049a8:	00003697          	auipc	a3,0x3
ffffffffc02049ac:	7f068693          	addi	a3,a3,2032 # ffffffffc0208198 <default_pmm_manager+0x590>
ffffffffc02049b0:	00002617          	auipc	a2,0x2
ffffffffc02049b4:	1b060613          	addi	a2,a2,432 # ffffffffc0206b60 <commands+0x410>
ffffffffc02049b8:	23700593          	li	a1,567
ffffffffc02049bc:	00003517          	auipc	a0,0x3
ffffffffc02049c0:	28450513          	addi	a0,a0,644 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02049c4:	845fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02049c8:	00003697          	auipc	a3,0x3
ffffffffc02049cc:	79868693          	addi	a3,a3,1944 # ffffffffc0208160 <default_pmm_manager+0x558>
ffffffffc02049d0:	00002617          	auipc	a2,0x2
ffffffffc02049d4:	19060613          	addi	a2,a2,400 # ffffffffc0206b60 <commands+0x410>
ffffffffc02049d8:	23400593          	li	a1,564
ffffffffc02049dc:	00003517          	auipc	a0,0x3
ffffffffc02049e0:	26450513          	addi	a0,a0,612 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc02049e4:	825fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02049e8:	00003697          	auipc	a3,0x3
ffffffffc02049ec:	74868693          	addi	a3,a3,1864 # ffffffffc0208130 <default_pmm_manager+0x528>
ffffffffc02049f0:	00002617          	auipc	a2,0x2
ffffffffc02049f4:	17060613          	addi	a2,a2,368 # ffffffffc0206b60 <commands+0x410>
ffffffffc02049f8:	23000593          	li	a1,560
ffffffffc02049fc:	00003517          	auipc	a0,0x3
ffffffffc0204a00:	24450513          	addi	a0,a0,580 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204a04:	805fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204a08 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204a08:	12058073          	sfence.vma	a1
}
ffffffffc0204a0c:	8082                	ret

ffffffffc0204a0e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a0e:	7179                	addi	sp,sp,-48
ffffffffc0204a10:	e84a                	sd	s2,16(sp)
ffffffffc0204a12:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204a14:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a16:	f022                	sd	s0,32(sp)
ffffffffc0204a18:	ec26                	sd	s1,24(sp)
ffffffffc0204a1a:	e44e                	sd	s3,8(sp)
ffffffffc0204a1c:	f406                	sd	ra,40(sp)
ffffffffc0204a1e:	84ae                	mv	s1,a1
ffffffffc0204a20:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204a22:	a25fe0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0204a26:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204a28:	cd05                	beqz	a0,ffffffffc0204a60 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204a2a:	85aa                	mv	a1,a0
ffffffffc0204a2c:	86ce                	mv	a3,s3
ffffffffc0204a2e:	8626                	mv	a2,s1
ffffffffc0204a30:	854a                	mv	a0,s2
ffffffffc0204a32:	b46ff0ef          	jal	ra,ffffffffc0203d78 <page_insert>
ffffffffc0204a36:	ed0d                	bnez	a0,ffffffffc0204a70 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0204a38:	000ae797          	auipc	a5,0xae
ffffffffc0204a3c:	0007a783          	lw	a5,0(a5) # ffffffffc02b2a38 <swap_init_ok>
ffffffffc0204a40:	c385                	beqz	a5,ffffffffc0204a60 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0204a42:	000ae517          	auipc	a0,0xae
ffffffffc0204a46:	fce53503          	ld	a0,-50(a0) # ffffffffc02b2a10 <check_mm_struct>
ffffffffc0204a4a:	c919                	beqz	a0,ffffffffc0204a60 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204a4c:	4681                	li	a3,0
ffffffffc0204a4e:	8622                	mv	a2,s0
ffffffffc0204a50:	85a6                	mv	a1,s1
ffffffffc0204a52:	d75fd0ef          	jal	ra,ffffffffc02027c6 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204a56:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204a58:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204a5a:	4785                	li	a5,1
ffffffffc0204a5c:	04f71663          	bne	a4,a5,ffffffffc0204aa8 <pgdir_alloc_page+0x9a>
}
ffffffffc0204a60:	70a2                	ld	ra,40(sp)
ffffffffc0204a62:	8522                	mv	a0,s0
ffffffffc0204a64:	7402                	ld	s0,32(sp)
ffffffffc0204a66:	64e2                	ld	s1,24(sp)
ffffffffc0204a68:	6942                	ld	s2,16(sp)
ffffffffc0204a6a:	69a2                	ld	s3,8(sp)
ffffffffc0204a6c:	6145                	addi	sp,sp,48
ffffffffc0204a6e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a70:	100027f3          	csrr	a5,sstatus
ffffffffc0204a74:	8b89                	andi	a5,a5,2
ffffffffc0204a76:	eb99                	bnez	a5,ffffffffc0204a8c <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0204a78:	000ae797          	auipc	a5,0xae
ffffffffc0204a7c:	fe87b783          	ld	a5,-24(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0204a80:	739c                	ld	a5,32(a5)
ffffffffc0204a82:	8522                	mv	a0,s0
ffffffffc0204a84:	4585                	li	a1,1
ffffffffc0204a86:	9782                	jalr	a5
            return NULL;
ffffffffc0204a88:	4401                	li	s0,0
ffffffffc0204a8a:	bfd9                	j	ffffffffc0204a60 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0204a8c:	bbdfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204a90:	000ae797          	auipc	a5,0xae
ffffffffc0204a94:	fd07b783          	ld	a5,-48(a5) # ffffffffc02b2a60 <pmm_manager>
ffffffffc0204a98:	739c                	ld	a5,32(a5)
ffffffffc0204a9a:	8522                	mv	a0,s0
ffffffffc0204a9c:	4585                	li	a1,1
ffffffffc0204a9e:	9782                	jalr	a5
            return NULL;
ffffffffc0204aa0:	4401                	li	s0,0
        intr_enable();
ffffffffc0204aa2:	ba1fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204aa6:	bf6d                	j	ffffffffc0204a60 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0204aa8:	00003697          	auipc	a3,0x3
ffffffffc0204aac:	73868693          	addi	a3,a3,1848 # ffffffffc02081e0 <default_pmm_manager+0x5d8>
ffffffffc0204ab0:	00002617          	auipc	a2,0x2
ffffffffc0204ab4:	0b060613          	addi	a2,a2,176 # ffffffffc0206b60 <commands+0x410>
ffffffffc0204ab8:	1c800593          	li	a1,456
ffffffffc0204abc:	00003517          	auipc	a0,0x3
ffffffffc0204ac0:	18450513          	addi	a0,a0,388 # ffffffffc0207c40 <default_pmm_manager+0x38>
ffffffffc0204ac4:	f44fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ac8 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204ac8:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204aca:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204acc:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ace:	a5bfb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204ad2:	cd01                	beqz	a0,ffffffffc0204aea <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ad4:	4505                	li	a0,1
ffffffffc0204ad6:	a59fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204ada:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204adc:	810d                	srli	a0,a0,0x3
ffffffffc0204ade:	000ae797          	auipc	a5,0xae
ffffffffc0204ae2:	f4a7b523          	sd	a0,-182(a5) # ffffffffc02b2a28 <max_swap_offset>
}
ffffffffc0204ae6:	0141                	addi	sp,sp,16
ffffffffc0204ae8:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204aea:	00003617          	auipc	a2,0x3
ffffffffc0204aee:	70e60613          	addi	a2,a2,1806 # ffffffffc02081f8 <default_pmm_manager+0x5f0>
ffffffffc0204af2:	45b5                	li	a1,13
ffffffffc0204af4:	00003517          	auipc	a0,0x3
ffffffffc0204af8:	72450513          	addi	a0,a0,1828 # ffffffffc0208218 <default_pmm_manager+0x610>
ffffffffc0204afc:	f0cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b00 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b00:	1141                	addi	sp,sp,-16
ffffffffc0204b02:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b04:	00855793          	srli	a5,a0,0x8
ffffffffc0204b08:	cbb1                	beqz	a5,ffffffffc0204b5c <swapfs_read+0x5c>
ffffffffc0204b0a:	000ae717          	auipc	a4,0xae
ffffffffc0204b0e:	f1e73703          	ld	a4,-226(a4) # ffffffffc02b2a28 <max_swap_offset>
ffffffffc0204b12:	04e7f563          	bgeu	a5,a4,ffffffffc0204b5c <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204b16:	000ae617          	auipc	a2,0xae
ffffffffc0204b1a:	f4263603          	ld	a2,-190(a2) # ffffffffc02b2a58 <pages>
ffffffffc0204b1e:	8d91                	sub	a1,a1,a2
ffffffffc0204b20:	4065d613          	srai	a2,a1,0x6
ffffffffc0204b24:	00004717          	auipc	a4,0x4
ffffffffc0204b28:	04473703          	ld	a4,68(a4) # ffffffffc0208b68 <nbase>
ffffffffc0204b2c:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204b2e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b32:	8331                	srli	a4,a4,0xc
ffffffffc0204b34:	000ae697          	auipc	a3,0xae
ffffffffc0204b38:	f1c6b683          	ld	a3,-228(a3) # ffffffffc02b2a50 <npage>
ffffffffc0204b3c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b40:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b42:	02d77963          	bgeu	a4,a3,ffffffffc0204b74 <swapfs_read+0x74>
}
ffffffffc0204b46:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b48:	000ae797          	auipc	a5,0xae
ffffffffc0204b4c:	f207b783          	ld	a5,-224(a5) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0204b50:	46a1                	li	a3,8
ffffffffc0204b52:	963e                	add	a2,a2,a5
ffffffffc0204b54:	4505                	li	a0,1
}
ffffffffc0204b56:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b58:	9ddfb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204b5c:	86aa                	mv	a3,a0
ffffffffc0204b5e:	00003617          	auipc	a2,0x3
ffffffffc0204b62:	6d260613          	addi	a2,a2,1746 # ffffffffc0208230 <default_pmm_manager+0x628>
ffffffffc0204b66:	45d1                	li	a1,20
ffffffffc0204b68:	00003517          	auipc	a0,0x3
ffffffffc0204b6c:	6b050513          	addi	a0,a0,1712 # ffffffffc0208218 <default_pmm_manager+0x610>
ffffffffc0204b70:	e98fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204b74:	86b2                	mv	a3,a2
ffffffffc0204b76:	06900593          	li	a1,105
ffffffffc0204b7a:	00002617          	auipc	a2,0x2
ffffffffc0204b7e:	5b660613          	addi	a2,a2,1462 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0204b82:	00002517          	auipc	a0,0x2
ffffffffc0204b86:	59e50513          	addi	a0,a0,1438 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0204b8a:	e7efb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b8e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204b8e:	1141                	addi	sp,sp,-16
ffffffffc0204b90:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b92:	00855793          	srli	a5,a0,0x8
ffffffffc0204b96:	cbb1                	beqz	a5,ffffffffc0204bea <swapfs_write+0x5c>
ffffffffc0204b98:	000ae717          	auipc	a4,0xae
ffffffffc0204b9c:	e9073703          	ld	a4,-368(a4) # ffffffffc02b2a28 <max_swap_offset>
ffffffffc0204ba0:	04e7f563          	bgeu	a5,a4,ffffffffc0204bea <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204ba4:	000ae617          	auipc	a2,0xae
ffffffffc0204ba8:	eb463603          	ld	a2,-332(a2) # ffffffffc02b2a58 <pages>
ffffffffc0204bac:	8d91                	sub	a1,a1,a2
ffffffffc0204bae:	4065d613          	srai	a2,a1,0x6
ffffffffc0204bb2:	00004717          	auipc	a4,0x4
ffffffffc0204bb6:	fb673703          	ld	a4,-74(a4) # ffffffffc0208b68 <nbase>
ffffffffc0204bba:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204bbc:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bc0:	8331                	srli	a4,a4,0xc
ffffffffc0204bc2:	000ae697          	auipc	a3,0xae
ffffffffc0204bc6:	e8e6b683          	ld	a3,-370(a3) # ffffffffc02b2a50 <npage>
ffffffffc0204bca:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bce:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bd0:	02d77963          	bgeu	a4,a3,ffffffffc0204c02 <swapfs_write+0x74>
}
ffffffffc0204bd4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bd6:	000ae797          	auipc	a5,0xae
ffffffffc0204bda:	e927b783          	ld	a5,-366(a5) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0204bde:	46a1                	li	a3,8
ffffffffc0204be0:	963e                	add	a2,a2,a5
ffffffffc0204be2:	4505                	li	a0,1
}
ffffffffc0204be4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204be6:	973fb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204bea:	86aa                	mv	a3,a0
ffffffffc0204bec:	00003617          	auipc	a2,0x3
ffffffffc0204bf0:	64460613          	addi	a2,a2,1604 # ffffffffc0208230 <default_pmm_manager+0x628>
ffffffffc0204bf4:	45e5                	li	a1,25
ffffffffc0204bf6:	00003517          	auipc	a0,0x3
ffffffffc0204bfa:	62250513          	addi	a0,a0,1570 # ffffffffc0208218 <default_pmm_manager+0x610>
ffffffffc0204bfe:	e0afb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204c02:	86b2                	mv	a3,a2
ffffffffc0204c04:	06900593          	li	a1,105
ffffffffc0204c08:	00002617          	auipc	a2,0x2
ffffffffc0204c0c:	52860613          	addi	a2,a2,1320 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0204c10:	00002517          	auipc	a0,0x2
ffffffffc0204c14:	51050513          	addi	a0,a0,1296 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0204c18:	df0fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c1c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c1c:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c1e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c20:	624000ef          	jal	ra,ffffffffc0205244 <do_exit>

ffffffffc0204c24 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204c24:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204c28:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204c2c:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204c2e:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204c30:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204c34:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204c38:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204c3c:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204c40:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204c44:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204c48:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204c4c:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204c50:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204c54:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204c58:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204c5c:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204c60:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204c62:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204c64:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204c68:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204c6c:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204c70:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204c74:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204c78:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204c7c:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204c80:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204c84:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204c88:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204c8c:	8082                	ret

ffffffffc0204c8e <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204c8e:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c90:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204c94:	e022                	sd	s0,0(sp)
ffffffffc0204c96:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c98:	a1afd0ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0204c9c:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204c9e:	cd21                	beqz	a0,ffffffffc0204cf6 <alloc_proc+0x68>
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        // 初始化进程的状态为 PROC_UNINIT，表示该进程尚未初始化完成
        proc->state = PROC_UNINIT;
ffffffffc0204ca0:	57fd                	li	a5,-1
ffffffffc0204ca2:	1782                	slli	a5,a5,0x20
ffffffffc0204ca4:	e11c                	sd	a5,0(a0)
        // 初始化进程的父进程为 NULL，表示没有父进程（通常是 init 进程）
        proc->parent = NULL;
        // 进程的内存管理结构体 (mm_struct) 初始化为 NULL，表示没有内存管理信息
        proc->mm = NULL;
        // 将进程的上下文 (context) 清零，为了保证没有遗留的状态
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204ca6:	07000613          	li	a2,112
ffffffffc0204caa:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204cac:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204cb0:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204cb4:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204cb8:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204cbc:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204cc0:	03050513          	addi	a0,a0,48
ffffffffc0204cc4:	3b4010ef          	jal	ra,ffffffffc0206078 <memset>
        // 初始化进程的陷阱帧 (trapframe) 为 NULL，表示该进程还没有陷入中断或系统调用
        proc->tf = NULL;
        // 设置进程的 CR3 寄存器为 boot_cr3，通常是系统启动时的页目录表基地址
        proc->cr3 = boot_cr3;
ffffffffc0204cc8:	000ae797          	auipc	a5,0xae
ffffffffc0204ccc:	d787b783          	ld	a5,-648(a5) # ffffffffc02b2a40 <boot_cr3>
        proc->tf = NULL;
ffffffffc0204cd0:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204cd4:	f45c                	sd	a5,168(s0)
        // 初始化进程的标志位为 0，表示没有特殊的进程标志
        proc->flags = 0;
ffffffffc0204cd6:	0a042823          	sw	zero,176(s0)
        // 清空进程名称的字符串，确保没有随机的字符，长度为 PROC_NAME_LEN + 1
        memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204cda:	4641                	li	a2,16
ffffffffc0204cdc:	4581                	li	a1,0
ffffffffc0204cde:	0b440513          	addi	a0,s0,180
ffffffffc0204ce2:	396010ef          	jal	ra,ffffffffc0206078 <memset>
        //lab5新增
        proc->wait_state = 0;
ffffffffc0204ce6:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL; // Child Pointer 表示当前进程的子进程
ffffffffc0204cea:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL; // Older Sibling Pointer 表示当前进程的上一个兄弟进程
ffffffffc0204cee:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL; // Younger Sibling Pointer 表示当前进程的下一个兄弟进程
ffffffffc0204cf2:	0e043c23          	sd	zero,248(s0)
    }
    return proc;
}
ffffffffc0204cf6:	60a2                	ld	ra,8(sp)
ffffffffc0204cf8:	8522                	mv	a0,s0
ffffffffc0204cfa:	6402                	ld	s0,0(sp)
ffffffffc0204cfc:	0141                	addi	sp,sp,16
ffffffffc0204cfe:	8082                	ret

ffffffffc0204d00 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d00:	000ae797          	auipc	a5,0xae
ffffffffc0204d04:	d707b783          	ld	a5,-656(a5) # ffffffffc02b2a70 <current>
ffffffffc0204d08:	73c8                	ld	a0,160(a5)
ffffffffc0204d0a:	86cfc06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204d0e <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc0204d0e:	000ae797          	auipc	a5,0xae
ffffffffc0204d12:	d627b783          	ld	a5,-670(a5) # ffffffffc02b2a70 <current>
ffffffffc0204d16:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204d18:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0204d1a:	00003617          	auipc	a2,0x3
ffffffffc0204d1e:	53660613          	addi	a2,a2,1334 # ffffffffc0208250 <default_pmm_manager+0x648>
ffffffffc0204d22:	00003517          	auipc	a0,0x3
ffffffffc0204d26:	53650513          	addi	a0,a0,1334 # ffffffffc0208258 <default_pmm_manager+0x650>
user_main(void *arg) {
ffffffffc0204d2a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204d2c:	ba0fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204d30:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204d34:	41878793          	addi	a5,a5,1048 # b148 <_binary_obj___user_exit_out_size>
ffffffffc0204d38:	e43e                	sd	a5,8(sp)
ffffffffc0204d3a:	00003517          	auipc	a0,0x3
ffffffffc0204d3e:	51650513          	addi	a0,a0,1302 # ffffffffc0208250 <default_pmm_manager+0x648>
ffffffffc0204d42:	00030797          	auipc	a5,0x30
ffffffffc0204d46:	61e78793          	addi	a5,a5,1566 # ffffffffc0235360 <_binary_obj___user_exit_out_start>
ffffffffc0204d4a:	f03e                	sd	a5,32(sp)
ffffffffc0204d4c:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d4e:	e802                	sd	zero,16(sp)
ffffffffc0204d50:	2ac010ef          	jal	ra,ffffffffc0205ffc <strlen>
ffffffffc0204d54:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d56:	4511                	li	a0,4
ffffffffc0204d58:	55a2                	lw	a1,40(sp)
ffffffffc0204d5a:	4662                	lw	a2,24(sp)
ffffffffc0204d5c:	5682                	lw	a3,32(sp)
ffffffffc0204d5e:	4722                	lw	a4,8(sp)
ffffffffc0204d60:	48a9                	li	a7,10
ffffffffc0204d62:	9002                	ebreak
ffffffffc0204d64:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204d66:	65c2                	ld	a1,16(sp)
ffffffffc0204d68:	00003517          	auipc	a0,0x3
ffffffffc0204d6c:	51850513          	addi	a0,a0,1304 # ffffffffc0208280 <default_pmm_manager+0x678>
ffffffffc0204d70:	b5cfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204d74:	00003617          	auipc	a2,0x3
ffffffffc0204d78:	51c60613          	addi	a2,a2,1308 # ffffffffc0208290 <default_pmm_manager+0x688>
ffffffffc0204d7c:	35500593          	li	a1,853
ffffffffc0204d80:	00003517          	auipc	a0,0x3
ffffffffc0204d84:	53050513          	addi	a0,a0,1328 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0204d88:	c80fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d8c <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204d8c:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204d8e:	1141                	addi	sp,sp,-16
ffffffffc0204d90:	e406                	sd	ra,8(sp)
ffffffffc0204d92:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d96:	02f6ee63          	bltu	a3,a5,ffffffffc0204dd2 <put_pgdir+0x46>
ffffffffc0204d9a:	000ae517          	auipc	a0,0xae
ffffffffc0204d9e:	cce53503          	ld	a0,-818(a0) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0204da2:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204da4:	82b1                	srli	a3,a3,0xc
ffffffffc0204da6:	000ae797          	auipc	a5,0xae
ffffffffc0204daa:	caa7b783          	ld	a5,-854(a5) # ffffffffc02b2a50 <npage>
ffffffffc0204dae:	02f6fe63          	bgeu	a3,a5,ffffffffc0204dea <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204db2:	00004517          	auipc	a0,0x4
ffffffffc0204db6:	db653503          	ld	a0,-586(a0) # ffffffffc0208b68 <nbase>
}
ffffffffc0204dba:	60a2                	ld	ra,8(sp)
ffffffffc0204dbc:	8e89                	sub	a3,a3,a0
ffffffffc0204dbe:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204dc0:	000ae517          	auipc	a0,0xae
ffffffffc0204dc4:	c9853503          	ld	a0,-872(a0) # ffffffffc02b2a58 <pages>
ffffffffc0204dc8:	4585                	li	a1,1
ffffffffc0204dca:	9536                	add	a0,a0,a3
}
ffffffffc0204dcc:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204dce:	f0afe06f          	j	ffffffffc02034d8 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204dd2:	00002617          	auipc	a2,0x2
ffffffffc0204dd6:	6e660613          	addi	a2,a2,1766 # ffffffffc02074b8 <commands+0xd68>
ffffffffc0204dda:	06e00593          	li	a1,110
ffffffffc0204dde:	00002517          	auipc	a0,0x2
ffffffffc0204de2:	34250513          	addi	a0,a0,834 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0204de6:	c22fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204dea:	00002617          	auipc	a2,0x2
ffffffffc0204dee:	31660613          	addi	a2,a2,790 # ffffffffc0207100 <commands+0x9b0>
ffffffffc0204df2:	06200593          	li	a1,98
ffffffffc0204df6:	00002517          	auipc	a0,0x2
ffffffffc0204dfa:	32a50513          	addi	a0,a0,810 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0204dfe:	c0afb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204e02 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204e02:	7179                	addi	sp,sp,-48
ffffffffc0204e04:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204e06:	000ae917          	auipc	s2,0xae
ffffffffc0204e0a:	c6a90913          	addi	s2,s2,-918 # ffffffffc02b2a70 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204e0e:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204e10:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204e14:	f406                	sd	ra,40(sp)
ffffffffc0204e16:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204e18:	02a48863          	beq	s1,a0,ffffffffc0204e48 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204e1c:	100027f3          	csrr	a5,sstatus
ffffffffc0204e20:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204e22:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204e24:	ef9d                	bnez	a5,ffffffffc0204e62 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204e26:	755c                	ld	a5,168(a0)
ffffffffc0204e28:	577d                	li	a4,-1
ffffffffc0204e2a:	177e                	slli	a4,a4,0x3f
ffffffffc0204e2c:	83b1                	srli	a5,a5,0xc
        current = proc;
ffffffffc0204e2e:	00a93023          	sd	a0,0(s2)
ffffffffc0204e32:	8fd9                	or	a5,a5,a4
ffffffffc0204e34:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(proc->context));// 切换上下文状态
ffffffffc0204e38:	03050593          	addi	a1,a0,48
ffffffffc0204e3c:	03048513          	addi	a0,s1,48
ffffffffc0204e40:	de5ff0ef          	jal	ra,ffffffffc0204c24 <switch_to>
    if (flag) {
ffffffffc0204e44:	00099863          	bnez	s3,ffffffffc0204e54 <proc_run+0x52>
}
ffffffffc0204e48:	70a2                	ld	ra,40(sp)
ffffffffc0204e4a:	7482                	ld	s1,32(sp)
ffffffffc0204e4c:	6962                	ld	s2,24(sp)
ffffffffc0204e4e:	69c2                	ld	s3,16(sp)
ffffffffc0204e50:	6145                	addi	sp,sp,48
ffffffffc0204e52:	8082                	ret
ffffffffc0204e54:	70a2                	ld	ra,40(sp)
ffffffffc0204e56:	7482                	ld	s1,32(sp)
ffffffffc0204e58:	6962                	ld	s2,24(sp)
ffffffffc0204e5a:	69c2                	ld	s3,16(sp)
ffffffffc0204e5c:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204e5e:	fe4fb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc0204e62:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204e64:	fe4fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0204e68:	6522                	ld	a0,8(sp)
ffffffffc0204e6a:	4985                	li	s3,1
ffffffffc0204e6c:	bf6d                	j	ffffffffc0204e26 <proc_run+0x24>

ffffffffc0204e6e <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204e6e:	715d                	addi	sp,sp,-80
ffffffffc0204e70:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204e72:	000ae917          	auipc	s2,0xae
ffffffffc0204e76:	c1690913          	addi	s2,s2,-1002 # ffffffffc02b2a88 <nr_process>
ffffffffc0204e7a:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204e7e:	e486                	sd	ra,72(sp)
ffffffffc0204e80:	e0a2                	sd	s0,64(sp)
ffffffffc0204e82:	fc26                	sd	s1,56(sp)
ffffffffc0204e84:	f44e                	sd	s3,40(sp)
ffffffffc0204e86:	f052                	sd	s4,32(sp)
ffffffffc0204e88:	ec56                	sd	s5,24(sp)
ffffffffc0204e8a:	e85a                	sd	s6,16(sp)
ffffffffc0204e8c:	e45e                	sd	s7,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204e8e:	6785                	lui	a5,0x1
ffffffffc0204e90:	2ef75963          	bge	a4,a5,ffffffffc0205182 <do_fork+0x314>
    proc = alloc_proc();                // 分配并初始化一个新的进程结构体
ffffffffc0204e94:	8a2a                	mv	s4,a0
ffffffffc0204e96:	89ae                	mv	s3,a1
ffffffffc0204e98:	8432                	mv	s0,a2
    proc->parent = current;             // 设置新进程的父进程为当前进程
ffffffffc0204e9a:	000aea97          	auipc	s5,0xae
ffffffffc0204e9e:	bd6a8a93          	addi	s5,s5,-1066 # ffffffffc02b2a70 <current>
    proc = alloc_proc();                // 分配并初始化一个新的进程结构体
ffffffffc0204ea2:	dedff0ef          	jal	ra,ffffffffc0204c8e <alloc_proc>
    proc->parent = current;             // 设置新进程的父进程为当前进程
ffffffffc0204ea6:	000ab783          	ld	a5,0(s5)
    proc = alloc_proc();                // 分配并初始化一个新的进程结构体
ffffffffc0204eaa:	84aa                	mv	s1,a0
    assert(current->wait_state == 0);
ffffffffc0204eac:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8aec>
    proc->parent = current;             // 设置新进程的父进程为当前进程
ffffffffc0204eb0:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204eb2:	2e071963          	bnez	a4,ffffffffc02051a4 <do_fork+0x336>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204eb6:	4509                	li	a0,2
ffffffffc0204eb8:	d8efe0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
    if (page != NULL) {
ffffffffc0204ebc:	cd0d                	beqz	a0,ffffffffc0204ef6 <do_fork+0x88>
    return page - pages + nbase;
ffffffffc0204ebe:	000ae697          	auipc	a3,0xae
ffffffffc0204ec2:	b9a6b683          	ld	a3,-1126(a3) # ffffffffc02b2a58 <pages>
ffffffffc0204ec6:	40d506b3          	sub	a3,a0,a3
ffffffffc0204eca:	8699                	srai	a3,a3,0x6
ffffffffc0204ecc:	00004517          	auipc	a0,0x4
ffffffffc0204ed0:	c9c53503          	ld	a0,-868(a0) # ffffffffc0208b68 <nbase>
ffffffffc0204ed4:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204ed6:	00c69793          	slli	a5,a3,0xc
ffffffffc0204eda:	83b1                	srli	a5,a5,0xc
ffffffffc0204edc:	000ae717          	auipc	a4,0xae
ffffffffc0204ee0:	b7473703          	ld	a4,-1164(a4) # ffffffffc02b2a50 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ee4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ee6:	2ae7f363          	bgeu	a5,a4,ffffffffc020518c <do_fork+0x31e>
ffffffffc0204eea:	000ae797          	auipc	a5,0xae
ffffffffc0204eee:	b7e7b783          	ld	a5,-1154(a5) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0204ef2:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204ef4:	e894                	sd	a3,16(s1)
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204ef6:	000ab783          	ld	a5,0(s5)
ffffffffc0204efa:	0287bb03          	ld	s6,40(a5)
    if (oldmm == NULL) {
ffffffffc0204efe:	020b0963          	beqz	s6,ffffffffc0204f30 <do_fork+0xc2>
    if (clone_flags & CLONE_VM) {
ffffffffc0204f02:	100a7a13          	andi	s4,s4,256
ffffffffc0204f06:	1a0a0f63          	beqz	s4,ffffffffc02050c4 <do_fork+0x256>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204f0a:	030b2783          	lw	a5,48(s6)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f0e:	018b3683          	ld	a3,24(s6)
ffffffffc0204f12:	c0200737          	lui	a4,0xc0200
ffffffffc0204f16:	2785                	addiw	a5,a5,1
ffffffffc0204f18:	02fb2823          	sw	a5,48(s6)
    proc->mm = mm;
ffffffffc0204f1c:	0364b423          	sd	s6,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f20:	2ae6e263          	bltu	a3,a4,ffffffffc02051c4 <do_fork+0x356>
ffffffffc0204f24:	000ae797          	auipc	a5,0xae
ffffffffc0204f28:	b447b783          	ld	a5,-1212(a5) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0204f2c:	8e9d                	sub	a3,a3,a5
ffffffffc0204f2e:	f4d4                	sd	a3,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204f30:	6898                	ld	a4,16(s1)
ffffffffc0204f32:	6789                	lui	a5,0x2
ffffffffc0204f34:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cf8>
ffffffffc0204f38:	973e                	add	a4,a4,a5
    *(proc->tf) = *tf;
ffffffffc0204f3a:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204f3c:	f0d8                	sd	a4,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204f3e:	87ba                	mv	a5,a4
ffffffffc0204f40:	12040893          	addi	a7,s0,288
ffffffffc0204f44:	00063803          	ld	a6,0(a2)
ffffffffc0204f48:	6608                	ld	a0,8(a2)
ffffffffc0204f4a:	6a0c                	ld	a1,16(a2)
ffffffffc0204f4c:	6e14                	ld	a3,24(a2)
ffffffffc0204f4e:	0107b023          	sd	a6,0(a5)
ffffffffc0204f52:	e788                	sd	a0,8(a5)
ffffffffc0204f54:	eb8c                	sd	a1,16(a5)
ffffffffc0204f56:	ef94                	sd	a3,24(a5)
ffffffffc0204f58:	02060613          	addi	a2,a2,32
ffffffffc0204f5c:	02078793          	addi	a5,a5,32
ffffffffc0204f60:	ff1612e3          	bne	a2,a7,ffffffffc0204f44 <do_fork+0xd6>
    proc->tf->gpr.a0 = 0;
ffffffffc0204f64:	04073823          	sd	zero,80(a4) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204f68:	12098b63          	beqz	s3,ffffffffc020509e <do_fork+0x230>
ffffffffc0204f6c:	01373823          	sd	s3,16(a4)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204f70:	00000797          	auipc	a5,0x0
ffffffffc0204f74:	d9078793          	addi	a5,a5,-624 # ffffffffc0204d00 <forkret>
ffffffffc0204f78:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204f7a:	fc98                	sd	a4,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f7c:	100027f3          	csrr	a5,sstatus
ffffffffc0204f80:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f82:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f84:	12079c63          	bnez	a5,ffffffffc02050bc <do_fork+0x24e>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204f88:	000a2817          	auipc	a6,0xa2
ffffffffc0204f8c:	5a080813          	addi	a6,a6,1440 # ffffffffc02a7528 <last_pid.1>
ffffffffc0204f90:	00082783          	lw	a5,0(a6)
ffffffffc0204f94:	6709                	lui	a4,0x2
ffffffffc0204f96:	0017851b          	addiw	a0,a5,1
ffffffffc0204f9a:	00a82023          	sw	a0,0(a6)
ffffffffc0204f9e:	08e55963          	bge	a0,a4,ffffffffc0205030 <do_fork+0x1c2>
    if (last_pid >= next_safe) {
ffffffffc0204fa2:	000a2317          	auipc	t1,0xa2
ffffffffc0204fa6:	58a30313          	addi	t1,t1,1418 # ffffffffc02a752c <next_safe.0>
ffffffffc0204faa:	00032783          	lw	a5,0(t1)
ffffffffc0204fae:	000ae417          	auipc	s0,0xae
ffffffffc0204fb2:	a3a40413          	addi	s0,s0,-1478 # ffffffffc02b29e8 <proc_list>
ffffffffc0204fb6:	08f55563          	bge	a0,a5,ffffffffc0205040 <do_fork+0x1d2>
        proc->pid = pid;               // 设置新进程的进程ID 
ffffffffc0204fba:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204fbc:	45a9                	li	a1,10
ffffffffc0204fbe:	2501                	sext.w	a0,a0
ffffffffc0204fc0:	4d0010ef          	jal	ra,ffffffffc0206490 <hash32>
ffffffffc0204fc4:	02051793          	slli	a5,a0,0x20
ffffffffc0204fc8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204fcc:	000aa797          	auipc	a5,0xaa
ffffffffc0204fd0:	a1c78793          	addi	a5,a5,-1508 # ffffffffc02ae9e8 <hash_list>
ffffffffc0204fd4:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204fd6:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204fd8:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204fda:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204fde:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204fe0:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204fe2:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204fe4:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204fe6:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204fea:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204fec:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204fee:	e21c                	sd	a5,0(a2)
ffffffffc0204ff0:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204ff2:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0204ff4:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0204ff6:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204ffa:	10e4b023          	sd	a4,256(s1)
ffffffffc0204ffe:	c311                	beqz	a4,ffffffffc0205002 <do_fork+0x194>
        proc->optr->yptr = proc;
ffffffffc0205000:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc0205002:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0205006:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0205008:	2785                	addiw	a5,a5,1
ffffffffc020500a:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc020500e:	14099d63          	bnez	s3,ffffffffc0205168 <do_fork+0x2fa>
    wakeup_proc(proc);              // 调用wakeup_proc使新子进程RUNNABLE
ffffffffc0205012:	8526                	mv	a0,s1
ffffffffc0205014:	5fd000ef          	jal	ra,ffffffffc0205e10 <wakeup_proc>
    ret = proc->pid;                  // 返回新进程的进程ID
ffffffffc0205018:	40c8                	lw	a0,4(s1)
}
ffffffffc020501a:	60a6                	ld	ra,72(sp)
ffffffffc020501c:	6406                	ld	s0,64(sp)
ffffffffc020501e:	74e2                	ld	s1,56(sp)
ffffffffc0205020:	7942                	ld	s2,48(sp)
ffffffffc0205022:	79a2                	ld	s3,40(sp)
ffffffffc0205024:	7a02                	ld	s4,32(sp)
ffffffffc0205026:	6ae2                	ld	s5,24(sp)
ffffffffc0205028:	6b42                	ld	s6,16(sp)
ffffffffc020502a:	6ba2                	ld	s7,8(sp)
ffffffffc020502c:	6161                	addi	sp,sp,80
ffffffffc020502e:	8082                	ret
        last_pid = 1;
ffffffffc0205030:	4785                	li	a5,1
ffffffffc0205032:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205036:	4505                	li	a0,1
ffffffffc0205038:	000a2317          	auipc	t1,0xa2
ffffffffc020503c:	4f430313          	addi	t1,t1,1268 # ffffffffc02a752c <next_safe.0>
    return listelm->next;
ffffffffc0205040:	000ae417          	auipc	s0,0xae
ffffffffc0205044:	9a840413          	addi	s0,s0,-1624 # ffffffffc02b29e8 <proc_list>
ffffffffc0205048:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020504c:	6789                	lui	a5,0x2
ffffffffc020504e:	00f32023          	sw	a5,0(t1)
ffffffffc0205052:	86aa                	mv	a3,a0
ffffffffc0205054:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0205056:	6e89                	lui	t4,0x2
ffffffffc0205058:	128e0063          	beq	t3,s0,ffffffffc0205178 <do_fork+0x30a>
ffffffffc020505c:	88ae                	mv	a7,a1
ffffffffc020505e:	87f2                	mv	a5,t3
ffffffffc0205060:	6609                	lui	a2,0x2
ffffffffc0205062:	a811                	j	ffffffffc0205076 <do_fork+0x208>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205064:	00e6d663          	bge	a3,a4,ffffffffc0205070 <do_fork+0x202>
ffffffffc0205068:	00c75463          	bge	a4,a2,ffffffffc0205070 <do_fork+0x202>
ffffffffc020506c:	863a                	mv	a2,a4
ffffffffc020506e:	4885                	li	a7,1
ffffffffc0205070:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205072:	00878d63          	beq	a5,s0,ffffffffc020508c <do_fork+0x21e>
            if (proc->pid == last_pid) {
ffffffffc0205076:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c9c>
ffffffffc020507a:	fee695e3          	bne	a3,a4,ffffffffc0205064 <do_fork+0x1f6>
                if (++ last_pid >= next_safe) {
ffffffffc020507e:	2685                	addiw	a3,a3,1
ffffffffc0205080:	0ec6d763          	bge	a3,a2,ffffffffc020516e <do_fork+0x300>
ffffffffc0205084:	679c                	ld	a5,8(a5)
ffffffffc0205086:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205088:	fe8797e3          	bne	a5,s0,ffffffffc0205076 <do_fork+0x208>
ffffffffc020508c:	c581                	beqz	a1,ffffffffc0205094 <do_fork+0x226>
ffffffffc020508e:	00d82023          	sw	a3,0(a6)
ffffffffc0205092:	8536                	mv	a0,a3
ffffffffc0205094:	f20883e3          	beqz	a7,ffffffffc0204fba <do_fork+0x14c>
ffffffffc0205098:	00c32023          	sw	a2,0(t1)
ffffffffc020509c:	bf39                	j	ffffffffc0204fba <do_fork+0x14c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020509e:	89ba                	mv	s3,a4
ffffffffc02050a0:	01373823          	sd	s3,16(a4) # 2010 <_binary_obj___user_faultread_out_size-0x7bc8>
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050a4:	00000797          	auipc	a5,0x0
ffffffffc02050a8:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d00 <forkret>
ffffffffc02050ac:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050ae:	fc98                	sd	a4,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050b0:	100027f3          	csrr	a5,sstatus
ffffffffc02050b4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050b6:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050b8:	ec0788e3          	beqz	a5,ffffffffc0204f88 <do_fork+0x11a>
        intr_disable();
ffffffffc02050bc:	d8cfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02050c0:	4985                	li	s3,1
ffffffffc02050c2:	b5d9                	j	ffffffffc0204f88 <do_fork+0x11a>
    if ((mm = mm_create()) == NULL) {
ffffffffc02050c4:	d83fb0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc02050c8:	8aaa                	mv	s5,a0
ffffffffc02050ca:	e60503e3          	beqz	a0,ffffffffc0204f30 <do_fork+0xc2>
    if ((page = alloc_page()) == NULL) {
ffffffffc02050ce:	4505                	li	a0,1
ffffffffc02050d0:	b76fe0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02050d4:	c551                	beqz	a0,ffffffffc0205160 <do_fork+0x2f2>
    return page - pages + nbase;
ffffffffc02050d6:	000ae697          	auipc	a3,0xae
ffffffffc02050da:	9826b683          	ld	a3,-1662(a3) # ffffffffc02b2a58 <pages>
ffffffffc02050de:	40d506b3          	sub	a3,a0,a3
ffffffffc02050e2:	8699                	srai	a3,a3,0x6
ffffffffc02050e4:	00004a17          	auipc	s4,0x4
ffffffffc02050e8:	a84a3a03          	ld	s4,-1404(s4) # ffffffffc0208b68 <nbase>
ffffffffc02050ec:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02050ee:	00c69793          	slli	a5,a3,0xc
ffffffffc02050f2:	83b1                	srli	a5,a5,0xc
ffffffffc02050f4:	000ae717          	auipc	a4,0xae
ffffffffc02050f8:	95c73703          	ld	a4,-1700(a4) # ffffffffc02b2a50 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02050fc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050fe:	08e7f763          	bgeu	a5,a4,ffffffffc020518c <do_fork+0x31e>
ffffffffc0205102:	000aea17          	auipc	s4,0xae
ffffffffc0205106:	966a3a03          	ld	s4,-1690(s4) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc020510a:	9a36                	add	s4,s4,a3
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020510c:	6605                	lui	a2,0x1
ffffffffc020510e:	000ae597          	auipc	a1,0xae
ffffffffc0205112:	93a5b583          	ld	a1,-1734(a1) # ffffffffc02b2a48 <boot_pgdir>
ffffffffc0205116:	8552                	mv	a0,s4
ffffffffc0205118:	773000ef          	jal	ra,ffffffffc020608a <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020511c:	038b0b93          	addi	s7,s6,56
    mm->pgdir = pgdir;
ffffffffc0205120:	014abc23          	sd	s4,24(s5)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205124:	4785                	li	a5,1
ffffffffc0205126:	40fbb7af          	amoor.d	a5,a5,(s7)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020512a:	8b85                	andi	a5,a5,1
ffffffffc020512c:	4a05                	li	s4,1
ffffffffc020512e:	c799                	beqz	a5,ffffffffc020513c <do_fork+0x2ce>
        schedule();
ffffffffc0205130:	561000ef          	jal	ra,ffffffffc0205e90 <schedule>
ffffffffc0205134:	414bb7af          	amoor.d	a5,s4,(s7)
    while (!try_lock(lock)) {
ffffffffc0205138:	8b85                	andi	a5,a5,1
ffffffffc020513a:	fbfd                	bnez	a5,ffffffffc0205130 <do_fork+0x2c2>
        ret = dup_mmap(mm, oldmm);
ffffffffc020513c:	85da                	mv	a1,s6
ffffffffc020513e:	8556                	mv	a0,s5
ffffffffc0205140:	f8ffb0ef          	jal	ra,ffffffffc02010ce <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205144:	57f9                	li	a5,-2
ffffffffc0205146:	60fbb7af          	amoand.d	a5,a5,(s7)
ffffffffc020514a:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020514c:	cbc1                	beqz	a5,ffffffffc02051dc <do_fork+0x36e>
good_mm:
ffffffffc020514e:	8b56                	mv	s6,s5
    if (ret != 0) {
ffffffffc0205150:	da050de3          	beqz	a0,ffffffffc0204f0a <do_fork+0x9c>
    exit_mmap(mm);
ffffffffc0205154:	8556                	mv	a0,s5
ffffffffc0205156:	812fc0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
    put_pgdir(mm);
ffffffffc020515a:	8556                	mv	a0,s5
ffffffffc020515c:	c31ff0ef          	jal	ra,ffffffffc0204d8c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205160:	8556                	mv	a0,s5
ffffffffc0205162:	e6bfb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
ffffffffc0205166:	b3e9                	j	ffffffffc0204f30 <do_fork+0xc2>
        intr_enable();
ffffffffc0205168:	cdafb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020516c:	b55d                	j	ffffffffc0205012 <do_fork+0x1a4>
                    if (last_pid >= MAX_PID) {
ffffffffc020516e:	01d6c363          	blt	a3,t4,ffffffffc0205174 <do_fork+0x306>
                        last_pid = 1;
ffffffffc0205172:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205174:	4585                	li	a1,1
ffffffffc0205176:	b5cd                	j	ffffffffc0205058 <do_fork+0x1ea>
ffffffffc0205178:	c599                	beqz	a1,ffffffffc0205186 <do_fork+0x318>
ffffffffc020517a:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020517e:	8536                	mv	a0,a3
ffffffffc0205180:	bd2d                	j	ffffffffc0204fba <do_fork+0x14c>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205182:	556d                	li	a0,-5
    return ret;
ffffffffc0205184:	bd59                	j	ffffffffc020501a <do_fork+0x1ac>
    return last_pid;
ffffffffc0205186:	00082503          	lw	a0,0(a6)
ffffffffc020518a:	bd05                	j	ffffffffc0204fba <do_fork+0x14c>
ffffffffc020518c:	00002617          	auipc	a2,0x2
ffffffffc0205190:	fa460613          	addi	a2,a2,-92 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0205194:	06900593          	li	a1,105
ffffffffc0205198:	00002517          	auipc	a0,0x2
ffffffffc020519c:	f8850513          	addi	a0,a0,-120 # ffffffffc0207120 <commands+0x9d0>
ffffffffc02051a0:	868fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(current->wait_state == 0);
ffffffffc02051a4:	00003697          	auipc	a3,0x3
ffffffffc02051a8:	12468693          	addi	a3,a3,292 # ffffffffc02082c8 <default_pmm_manager+0x6c0>
ffffffffc02051ac:	00002617          	auipc	a2,0x2
ffffffffc02051b0:	9b460613          	addi	a2,a2,-1612 # ffffffffc0206b60 <commands+0x410>
ffffffffc02051b4:	1bf00593          	li	a1,447
ffffffffc02051b8:	00003517          	auipc	a0,0x3
ffffffffc02051bc:	0f850513          	addi	a0,a0,248 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc02051c0:	848fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02051c4:	00002617          	auipc	a2,0x2
ffffffffc02051c8:	2f460613          	addi	a2,a2,756 # ffffffffc02074b8 <commands+0xd68>
ffffffffc02051cc:	17300593          	li	a1,371
ffffffffc02051d0:	00003517          	auipc	a0,0x3
ffffffffc02051d4:	0e050513          	addi	a0,a0,224 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc02051d8:	830fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc02051dc:	00003617          	auipc	a2,0x3
ffffffffc02051e0:	10c60613          	addi	a2,a2,268 # ffffffffc02082e8 <default_pmm_manager+0x6e0>
ffffffffc02051e4:	03100593          	li	a1,49
ffffffffc02051e8:	00003517          	auipc	a0,0x3
ffffffffc02051ec:	11050513          	addi	a0,a0,272 # ffffffffc02082f8 <default_pmm_manager+0x6f0>
ffffffffc02051f0:	818fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02051f4 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02051f4:	7129                	addi	sp,sp,-320
ffffffffc02051f6:	fa22                	sd	s0,304(sp)
ffffffffc02051f8:	f626                	sd	s1,296(sp)
ffffffffc02051fa:	f24a                	sd	s2,288(sp)
ffffffffc02051fc:	84ae                	mv	s1,a1
ffffffffc02051fe:	892a                	mv	s2,a0
ffffffffc0205200:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205202:	4581                	li	a1,0
ffffffffc0205204:	12000613          	li	a2,288
ffffffffc0205208:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020520a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020520c:	66d000ef          	jal	ra,ffffffffc0206078 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205210:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205212:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205214:	100027f3          	csrr	a5,sstatus
ffffffffc0205218:	edd7f793          	andi	a5,a5,-291
ffffffffc020521c:	1207e793          	ori	a5,a5,288
ffffffffc0205220:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205222:	860a                	mv	a2,sp
ffffffffc0205224:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205228:	00000797          	auipc	a5,0x0
ffffffffc020522c:	9f478793          	addi	a5,a5,-1548 # ffffffffc0204c1c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205230:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205232:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205234:	c3bff0ef          	jal	ra,ffffffffc0204e6e <do_fork>
}
ffffffffc0205238:	70f2                	ld	ra,312(sp)
ffffffffc020523a:	7452                	ld	s0,304(sp)
ffffffffc020523c:	74b2                	ld	s1,296(sp)
ffffffffc020523e:	7912                	ld	s2,288(sp)
ffffffffc0205240:	6131                	addi	sp,sp,320
ffffffffc0205242:	8082                	ret

ffffffffc0205244 <do_exit>:
do_exit(int error_code) {
ffffffffc0205244:	7179                	addi	sp,sp,-48
ffffffffc0205246:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205248:	000ae417          	auipc	s0,0xae
ffffffffc020524c:	82840413          	addi	s0,s0,-2008 # ffffffffc02b2a70 <current>
ffffffffc0205250:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205252:	f406                	sd	ra,40(sp)
ffffffffc0205254:	ec26                	sd	s1,24(sp)
ffffffffc0205256:	e84a                	sd	s2,16(sp)
ffffffffc0205258:	e44e                	sd	s3,8(sp)
ffffffffc020525a:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020525c:	000ae717          	auipc	a4,0xae
ffffffffc0205260:	81c73703          	ld	a4,-2020(a4) # ffffffffc02b2a78 <idleproc>
ffffffffc0205264:	0ce78c63          	beq	a5,a4,ffffffffc020533c <do_exit+0xf8>
    if (current == initproc) {
ffffffffc0205268:	000ae497          	auipc	s1,0xae
ffffffffc020526c:	81848493          	addi	s1,s1,-2024 # ffffffffc02b2a80 <initproc>
ffffffffc0205270:	6098                	ld	a4,0(s1)
ffffffffc0205272:	0ee78b63          	beq	a5,a4,ffffffffc0205368 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0205276:	0287b983          	ld	s3,40(a5)
ffffffffc020527a:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc020527c:	02098663          	beqz	s3,ffffffffc02052a8 <do_exit+0x64>
ffffffffc0205280:	000ad797          	auipc	a5,0xad
ffffffffc0205284:	7c07b783          	ld	a5,1984(a5) # ffffffffc02b2a40 <boot_cr3>
ffffffffc0205288:	577d                	li	a4,-1
ffffffffc020528a:	177e                	slli	a4,a4,0x3f
ffffffffc020528c:	83b1                	srli	a5,a5,0xc
ffffffffc020528e:	8fd9                	or	a5,a5,a4
ffffffffc0205290:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205294:	0309a783          	lw	a5,48(s3)
ffffffffc0205298:	fff7871b          	addiw	a4,a5,-1
ffffffffc020529c:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02052a0:	cb55                	beqz	a4,ffffffffc0205354 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02052a2:	601c                	ld	a5,0(s0)
ffffffffc02052a4:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02052a8:	601c                	ld	a5,0(s0)
ffffffffc02052aa:	470d                	li	a4,3
ffffffffc02052ac:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02052ae:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052b2:	100027f3          	csrr	a5,sstatus
ffffffffc02052b6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052b8:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052ba:	e3f9                	bnez	a5,ffffffffc0205380 <do_exit+0x13c>
        proc = current->parent;
ffffffffc02052bc:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052be:	800007b7          	lui	a5,0x80000
ffffffffc02052c2:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02052c4:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052c6:	0ec52703          	lw	a4,236(a0)
ffffffffc02052ca:	0af70f63          	beq	a4,a5,ffffffffc0205388 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02052ce:	6018                	ld	a4,0(s0)
ffffffffc02052d0:	7b7c                	ld	a5,240(a4)
ffffffffc02052d2:	c3a1                	beqz	a5,ffffffffc0205312 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052d4:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052d8:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052da:	0985                	addi	s3,s3,1
ffffffffc02052dc:	a021                	j	ffffffffc02052e4 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02052de:	6018                	ld	a4,0(s0)
ffffffffc02052e0:	7b7c                	ld	a5,240(a4)
ffffffffc02052e2:	cb85                	beqz	a5,ffffffffc0205312 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02052e4:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fb8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052e8:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02052ea:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052ec:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02052ee:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052f2:	10e7b023          	sd	a4,256(a5)
ffffffffc02052f6:	c311                	beqz	a4,ffffffffc02052fa <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02052f8:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052fa:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02052fc:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02052fe:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205300:	fd271fe3          	bne	a4,s2,ffffffffc02052de <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205304:	0ec52783          	lw	a5,236(a0)
ffffffffc0205308:	fd379be3          	bne	a5,s3,ffffffffc02052de <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020530c:	305000ef          	jal	ra,ffffffffc0205e10 <wakeup_proc>
ffffffffc0205310:	b7f9                	j	ffffffffc02052de <do_exit+0x9a>
    if (flag) {
ffffffffc0205312:	020a1263          	bnez	s4,ffffffffc0205336 <do_exit+0xf2>
    schedule();
ffffffffc0205316:	37b000ef          	jal	ra,ffffffffc0205e90 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020531a:	601c                	ld	a5,0(s0)
ffffffffc020531c:	00003617          	auipc	a2,0x3
ffffffffc0205320:	01460613          	addi	a2,a2,20 # ffffffffc0208330 <default_pmm_manager+0x728>
ffffffffc0205324:	20c00593          	li	a1,524
ffffffffc0205328:	43d4                	lw	a3,4(a5)
ffffffffc020532a:	00003517          	auipc	a0,0x3
ffffffffc020532e:	f8650513          	addi	a0,a0,-122 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205332:	ed7fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc0205336:	b0cfb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020533a:	bff1                	j	ffffffffc0205316 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020533c:	00003617          	auipc	a2,0x3
ffffffffc0205340:	fd460613          	addi	a2,a2,-44 # ffffffffc0208310 <default_pmm_manager+0x708>
ffffffffc0205344:	1e000593          	li	a1,480
ffffffffc0205348:	00003517          	auipc	a0,0x3
ffffffffc020534c:	f6850513          	addi	a0,a0,-152 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205350:	eb9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc0205354:	854e                	mv	a0,s3
ffffffffc0205356:	e13fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
            put_pgdir(mm);
ffffffffc020535a:	854e                	mv	a0,s3
ffffffffc020535c:	a31ff0ef          	jal	ra,ffffffffc0204d8c <put_pgdir>
            mm_destroy(mm);
ffffffffc0205360:	854e                	mv	a0,s3
ffffffffc0205362:	c6bfb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
ffffffffc0205366:	bf35                	j	ffffffffc02052a2 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0205368:	00003617          	auipc	a2,0x3
ffffffffc020536c:	fb860613          	addi	a2,a2,-72 # ffffffffc0208320 <default_pmm_manager+0x718>
ffffffffc0205370:	1e300593          	li	a1,483
ffffffffc0205374:	00003517          	auipc	a0,0x3
ffffffffc0205378:	f3c50513          	addi	a0,a0,-196 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc020537c:	e8dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc0205380:	ac8fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205384:	4a05                	li	s4,1
ffffffffc0205386:	bf1d                	j	ffffffffc02052bc <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0205388:	289000ef          	jal	ra,ffffffffc0205e10 <wakeup_proc>
ffffffffc020538c:	b789                	j	ffffffffc02052ce <do_exit+0x8a>

ffffffffc020538e <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc020538e:	715d                	addi	sp,sp,-80
ffffffffc0205390:	f84a                	sd	s2,48(sp)
ffffffffc0205392:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205394:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205398:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc020539a:	fc26                	sd	s1,56(sp)
ffffffffc020539c:	f052                	sd	s4,32(sp)
ffffffffc020539e:	ec56                	sd	s5,24(sp)
ffffffffc02053a0:	e85a                	sd	s6,16(sp)
ffffffffc02053a2:	e45e                	sd	s7,8(sp)
ffffffffc02053a4:	e486                	sd	ra,72(sp)
ffffffffc02053a6:	e0a2                	sd	s0,64(sp)
ffffffffc02053a8:	84aa                	mv	s1,a0
ffffffffc02053aa:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02053ac:	000adb97          	auipc	s7,0xad
ffffffffc02053b0:	6c4b8b93          	addi	s7,s7,1732 # ffffffffc02b2a70 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02053b4:	00050b1b          	sext.w	s6,a0
ffffffffc02053b8:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02053bc:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02053be:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02053c0:	ccbd                	beqz	s1,ffffffffc020543e <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02053c2:	0359e863          	bltu	s3,s5,ffffffffc02053f2 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02053c6:	45a9                	li	a1,10
ffffffffc02053c8:	855a                	mv	a0,s6
ffffffffc02053ca:	0c6010ef          	jal	ra,ffffffffc0206490 <hash32>
ffffffffc02053ce:	02051793          	slli	a5,a0,0x20
ffffffffc02053d2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02053d6:	000a9797          	auipc	a5,0xa9
ffffffffc02053da:	61278793          	addi	a5,a5,1554 # ffffffffc02ae9e8 <hash_list>
ffffffffc02053de:	953e                	add	a0,a0,a5
ffffffffc02053e0:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02053e2:	a029                	j	ffffffffc02053ec <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02053e4:	f2c42783          	lw	a5,-212(s0)
ffffffffc02053e8:	02978163          	beq	a5,s1,ffffffffc020540a <do_wait.part.0+0x7c>
ffffffffc02053ec:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02053ee:	fe851be3          	bne	a0,s0,ffffffffc02053e4 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02053f2:	5579                	li	a0,-2
}
ffffffffc02053f4:	60a6                	ld	ra,72(sp)
ffffffffc02053f6:	6406                	ld	s0,64(sp)
ffffffffc02053f8:	74e2                	ld	s1,56(sp)
ffffffffc02053fa:	7942                	ld	s2,48(sp)
ffffffffc02053fc:	79a2                	ld	s3,40(sp)
ffffffffc02053fe:	7a02                	ld	s4,32(sp)
ffffffffc0205400:	6ae2                	ld	s5,24(sp)
ffffffffc0205402:	6b42                	ld	s6,16(sp)
ffffffffc0205404:	6ba2                	ld	s7,8(sp)
ffffffffc0205406:	6161                	addi	sp,sp,80
ffffffffc0205408:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc020540a:	000bb683          	ld	a3,0(s7)
ffffffffc020540e:	f4843783          	ld	a5,-184(s0)
ffffffffc0205412:	fed790e3          	bne	a5,a3,ffffffffc02053f2 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205416:	f2842703          	lw	a4,-216(s0)
ffffffffc020541a:	478d                	li	a5,3
ffffffffc020541c:	0ef70b63          	beq	a4,a5,ffffffffc0205512 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205420:	4785                	li	a5,1
ffffffffc0205422:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205424:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0205428:	269000ef          	jal	ra,ffffffffc0205e90 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020542c:	000bb783          	ld	a5,0(s7)
ffffffffc0205430:	0b07a783          	lw	a5,176(a5)
ffffffffc0205434:	8b85                	andi	a5,a5,1
ffffffffc0205436:	d7c9                	beqz	a5,ffffffffc02053c0 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0205438:	555d                	li	a0,-9
ffffffffc020543a:	e0bff0ef          	jal	ra,ffffffffc0205244 <do_exit>
        proc = current->cptr;
ffffffffc020543e:	000bb683          	ld	a3,0(s7)
ffffffffc0205442:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205444:	d45d                	beqz	s0,ffffffffc02053f2 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205446:	470d                	li	a4,3
ffffffffc0205448:	a021                	j	ffffffffc0205450 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020544a:	10043403          	ld	s0,256(s0)
ffffffffc020544e:	d869                	beqz	s0,ffffffffc0205420 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205450:	401c                	lw	a5,0(s0)
ffffffffc0205452:	fee79ce3          	bne	a5,a4,ffffffffc020544a <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205456:	000ad797          	auipc	a5,0xad
ffffffffc020545a:	6227b783          	ld	a5,1570(a5) # ffffffffc02b2a78 <idleproc>
ffffffffc020545e:	0c878963          	beq	a5,s0,ffffffffc0205530 <do_wait.part.0+0x1a2>
ffffffffc0205462:	000ad797          	auipc	a5,0xad
ffffffffc0205466:	61e7b783          	ld	a5,1566(a5) # ffffffffc02b2a80 <initproc>
ffffffffc020546a:	0cf40363          	beq	s0,a5,ffffffffc0205530 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc020546e:	000a0663          	beqz	s4,ffffffffc020547a <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205472:	0e842783          	lw	a5,232(s0)
ffffffffc0205476:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020547a:	100027f3          	csrr	a5,sstatus
ffffffffc020547e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205480:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205482:	e7c1                	bnez	a5,ffffffffc020550a <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205484:	6c70                	ld	a2,216(s0)
ffffffffc0205486:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205488:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020548c:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020548e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205490:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205492:	6470                	ld	a2,200(s0)
ffffffffc0205494:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205496:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205498:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc020549a:	c319                	beqz	a4,ffffffffc02054a0 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc020549c:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc020549e:	7c7c                	ld	a5,248(s0)
ffffffffc02054a0:	c3b5                	beqz	a5,ffffffffc0205504 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02054a2:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02054a6:	000ad717          	auipc	a4,0xad
ffffffffc02054aa:	5e270713          	addi	a4,a4,1506 # ffffffffc02b2a88 <nr_process>
ffffffffc02054ae:	431c                	lw	a5,0(a4)
ffffffffc02054b0:	37fd                	addiw	a5,a5,-1
ffffffffc02054b2:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02054b4:	e5a9                	bnez	a1,ffffffffc02054fe <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02054b6:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02054b8:	c02007b7          	lui	a5,0xc0200
ffffffffc02054bc:	04f6ee63          	bltu	a3,a5,ffffffffc0205518 <do_wait.part.0+0x18a>
ffffffffc02054c0:	000ad797          	auipc	a5,0xad
ffffffffc02054c4:	5a87b783          	ld	a5,1448(a5) # ffffffffc02b2a68 <va_pa_offset>
ffffffffc02054c8:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02054ca:	82b1                	srli	a3,a3,0xc
ffffffffc02054cc:	000ad797          	auipc	a5,0xad
ffffffffc02054d0:	5847b783          	ld	a5,1412(a5) # ffffffffc02b2a50 <npage>
ffffffffc02054d4:	06f6fa63          	bgeu	a3,a5,ffffffffc0205548 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02054d8:	00003517          	auipc	a0,0x3
ffffffffc02054dc:	69053503          	ld	a0,1680(a0) # ffffffffc0208b68 <nbase>
ffffffffc02054e0:	8e89                	sub	a3,a3,a0
ffffffffc02054e2:	069a                	slli	a3,a3,0x6
ffffffffc02054e4:	000ad517          	auipc	a0,0xad
ffffffffc02054e8:	57453503          	ld	a0,1396(a0) # ffffffffc02b2a58 <pages>
ffffffffc02054ec:	9536                	add	a0,a0,a3
ffffffffc02054ee:	4589                	li	a1,2
ffffffffc02054f0:	fe9fd0ef          	jal	ra,ffffffffc02034d8 <free_pages>
    kfree(proc);
ffffffffc02054f4:	8522                	mv	a0,s0
ffffffffc02054f6:	a6dfc0ef          	jal	ra,ffffffffc0201f62 <kfree>
    return 0;
ffffffffc02054fa:	4501                	li	a0,0
ffffffffc02054fc:	bde5                	j	ffffffffc02053f4 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02054fe:	944fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205502:	bf55                	j	ffffffffc02054b6 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc0205504:	701c                	ld	a5,32(s0)
ffffffffc0205506:	fbf8                	sd	a4,240(a5)
ffffffffc0205508:	bf79                	j	ffffffffc02054a6 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc020550a:	93efb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020550e:	4585                	li	a1,1
ffffffffc0205510:	bf95                	j	ffffffffc0205484 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205512:	f2840413          	addi	s0,s0,-216
ffffffffc0205516:	b781                	j	ffffffffc0205456 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205518:	00002617          	auipc	a2,0x2
ffffffffc020551c:	fa060613          	addi	a2,a2,-96 # ffffffffc02074b8 <commands+0xd68>
ffffffffc0205520:	06e00593          	li	a1,110
ffffffffc0205524:	00002517          	auipc	a0,0x2
ffffffffc0205528:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0207120 <commands+0x9d0>
ffffffffc020552c:	cddfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205530:	00003617          	auipc	a2,0x3
ffffffffc0205534:	e2060613          	addi	a2,a2,-480 # ffffffffc0208350 <default_pmm_manager+0x748>
ffffffffc0205538:	30300593          	li	a1,771
ffffffffc020553c:	00003517          	auipc	a0,0x3
ffffffffc0205540:	d7450513          	addi	a0,a0,-652 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205544:	cc5fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205548:	00002617          	auipc	a2,0x2
ffffffffc020554c:	bb860613          	addi	a2,a2,-1096 # ffffffffc0207100 <commands+0x9b0>
ffffffffc0205550:	06200593          	li	a1,98
ffffffffc0205554:	00002517          	auipc	a0,0x2
ffffffffc0205558:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0207120 <commands+0x9d0>
ffffffffc020555c:	cadfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205560 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205560:	1141                	addi	sp,sp,-16
ffffffffc0205562:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205564:	fb5fd0ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205568:	947fc0ef          	jal	ra,ffffffffc0201eae <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020556c:	4601                	li	a2,0
ffffffffc020556e:	4581                	li	a1,0
ffffffffc0205570:	fffff517          	auipc	a0,0xfffff
ffffffffc0205574:	79e50513          	addi	a0,a0,1950 # ffffffffc0204d0e <user_main>
ffffffffc0205578:	c7dff0ef          	jal	ra,ffffffffc02051f4 <kernel_thread>
    if (pid <= 0) {
ffffffffc020557c:	00a04563          	bgtz	a0,ffffffffc0205586 <init_main+0x26>
ffffffffc0205580:	a071                	j	ffffffffc020560c <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205582:	10f000ef          	jal	ra,ffffffffc0205e90 <schedule>
    if (code_store != NULL) {
ffffffffc0205586:	4581                	li	a1,0
ffffffffc0205588:	4501                	li	a0,0
ffffffffc020558a:	e05ff0ef          	jal	ra,ffffffffc020538e <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc020558e:	d975                	beqz	a0,ffffffffc0205582 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205590:	00003517          	auipc	a0,0x3
ffffffffc0205594:	e0050513          	addi	a0,a0,-512 # ffffffffc0208390 <default_pmm_manager+0x788>
ffffffffc0205598:	b35fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020559c:	000ad797          	auipc	a5,0xad
ffffffffc02055a0:	4e47b783          	ld	a5,1252(a5) # ffffffffc02b2a80 <initproc>
ffffffffc02055a4:	7bf8                	ld	a4,240(a5)
ffffffffc02055a6:	e339                	bnez	a4,ffffffffc02055ec <init_main+0x8c>
ffffffffc02055a8:	7ff8                	ld	a4,248(a5)
ffffffffc02055aa:	e329                	bnez	a4,ffffffffc02055ec <init_main+0x8c>
ffffffffc02055ac:	1007b703          	ld	a4,256(a5)
ffffffffc02055b0:	ef15                	bnez	a4,ffffffffc02055ec <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02055b2:	000ad697          	auipc	a3,0xad
ffffffffc02055b6:	4d66a683          	lw	a3,1238(a3) # ffffffffc02b2a88 <nr_process>
ffffffffc02055ba:	4709                	li	a4,2
ffffffffc02055bc:	0ae69463          	bne	a3,a4,ffffffffc0205664 <init_main+0x104>
    return listelm->next;
ffffffffc02055c0:	000ad697          	auipc	a3,0xad
ffffffffc02055c4:	42868693          	addi	a3,a3,1064 # ffffffffc02b29e8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02055c8:	6698                	ld	a4,8(a3)
ffffffffc02055ca:	0c878793          	addi	a5,a5,200
ffffffffc02055ce:	06f71b63          	bne	a4,a5,ffffffffc0205644 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02055d2:	629c                	ld	a5,0(a3)
ffffffffc02055d4:	04f71863          	bne	a4,a5,ffffffffc0205624 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02055d8:	00003517          	auipc	a0,0x3
ffffffffc02055dc:	ea050513          	addi	a0,a0,-352 # ffffffffc0208478 <default_pmm_manager+0x870>
ffffffffc02055e0:	aedfa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc02055e4:	60a2                	ld	ra,8(sp)
ffffffffc02055e6:	4501                	li	a0,0
ffffffffc02055e8:	0141                	addi	sp,sp,16
ffffffffc02055ea:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02055ec:	00003697          	auipc	a3,0x3
ffffffffc02055f0:	dcc68693          	addi	a3,a3,-564 # ffffffffc02083b8 <default_pmm_manager+0x7b0>
ffffffffc02055f4:	00001617          	auipc	a2,0x1
ffffffffc02055f8:	56c60613          	addi	a2,a2,1388 # ffffffffc0206b60 <commands+0x410>
ffffffffc02055fc:	36800593          	li	a1,872
ffffffffc0205600:	00003517          	auipc	a0,0x3
ffffffffc0205604:	cb050513          	addi	a0,a0,-848 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205608:	c01fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc020560c:	00003617          	auipc	a2,0x3
ffffffffc0205610:	d6460613          	addi	a2,a2,-668 # ffffffffc0208370 <default_pmm_manager+0x768>
ffffffffc0205614:	36000593          	li	a1,864
ffffffffc0205618:	00003517          	auipc	a0,0x3
ffffffffc020561c:	c9850513          	addi	a0,a0,-872 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205620:	be9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205624:	00003697          	auipc	a3,0x3
ffffffffc0205628:	e2468693          	addi	a3,a3,-476 # ffffffffc0208448 <default_pmm_manager+0x840>
ffffffffc020562c:	00001617          	auipc	a2,0x1
ffffffffc0205630:	53460613          	addi	a2,a2,1332 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205634:	36b00593          	li	a1,875
ffffffffc0205638:	00003517          	auipc	a0,0x3
ffffffffc020563c:	c7850513          	addi	a0,a0,-904 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205640:	bc9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205644:	00003697          	auipc	a3,0x3
ffffffffc0205648:	dd468693          	addi	a3,a3,-556 # ffffffffc0208418 <default_pmm_manager+0x810>
ffffffffc020564c:	00001617          	auipc	a2,0x1
ffffffffc0205650:	51460613          	addi	a2,a2,1300 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205654:	36a00593          	li	a1,874
ffffffffc0205658:	00003517          	auipc	a0,0x3
ffffffffc020565c:	c5850513          	addi	a0,a0,-936 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205660:	ba9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc0205664:	00003697          	auipc	a3,0x3
ffffffffc0205668:	da468693          	addi	a3,a3,-604 # ffffffffc0208408 <default_pmm_manager+0x800>
ffffffffc020566c:	00001617          	auipc	a2,0x1
ffffffffc0205670:	4f460613          	addi	a2,a2,1268 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205674:	36900593          	li	a1,873
ffffffffc0205678:	00003517          	auipc	a0,0x3
ffffffffc020567c:	c3850513          	addi	a0,a0,-968 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205680:	b89fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205684 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205684:	7171                	addi	sp,sp,-176
ffffffffc0205686:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205688:	000add97          	auipc	s11,0xad
ffffffffc020568c:	3e8d8d93          	addi	s11,s11,1000 # ffffffffc02b2a70 <current>
ffffffffc0205690:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205694:	e54e                	sd	s3,136(sp)
ffffffffc0205696:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205698:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020569c:	e94a                	sd	s2,144(sp)
ffffffffc020569e:	f4de                	sd	s7,104(sp)
ffffffffc02056a0:	892a                	mv	s2,a0
ffffffffc02056a2:	8bb2                	mv	s7,a2
ffffffffc02056a4:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02056a6:	862e                	mv	a2,a1
ffffffffc02056a8:	4681                	li	a3,0
ffffffffc02056aa:	85aa                	mv	a1,a0
ffffffffc02056ac:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02056ae:	f506                	sd	ra,168(sp)
ffffffffc02056b0:	f122                	sd	s0,160(sp)
ffffffffc02056b2:	e152                	sd	s4,128(sp)
ffffffffc02056b4:	fcd6                	sd	s5,120(sp)
ffffffffc02056b6:	f8da                	sd	s6,112(sp)
ffffffffc02056b8:	f0e2                	sd	s8,96(sp)
ffffffffc02056ba:	ece6                	sd	s9,88(sp)
ffffffffc02056bc:	e8ea                	sd	s10,80(sp)
ffffffffc02056be:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02056c0:	93efc0ef          	jal	ra,ffffffffc02017fe <user_mem_check>
ffffffffc02056c4:	40050863          	beqz	a0,ffffffffc0205ad4 <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02056c8:	4641                	li	a2,16
ffffffffc02056ca:	4581                	li	a1,0
ffffffffc02056cc:	1808                	addi	a0,sp,48
ffffffffc02056ce:	1ab000ef          	jal	ra,ffffffffc0206078 <memset>
    memcpy(local_name, name, len);
ffffffffc02056d2:	47bd                	li	a5,15
ffffffffc02056d4:	8626                	mv	a2,s1
ffffffffc02056d6:	1e97e063          	bltu	a5,s1,ffffffffc02058b6 <do_execve+0x232>
ffffffffc02056da:	85ca                	mv	a1,s2
ffffffffc02056dc:	1808                	addi	a0,sp,48
ffffffffc02056de:	1ad000ef          	jal	ra,ffffffffc020608a <memcpy>
    if (mm != NULL) {
ffffffffc02056e2:	1e098163          	beqz	s3,ffffffffc02058c4 <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc02056e6:	00002517          	auipc	a0,0x2
ffffffffc02056ea:	81250513          	addi	a0,a0,-2030 # ffffffffc0206ef8 <commands+0x7a8>
ffffffffc02056ee:	a17fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc02056f2:	000ad797          	auipc	a5,0xad
ffffffffc02056f6:	34e7b783          	ld	a5,846(a5) # ffffffffc02b2a40 <boot_cr3>
ffffffffc02056fa:	577d                	li	a4,-1
ffffffffc02056fc:	177e                	slli	a4,a4,0x3f
ffffffffc02056fe:	83b1                	srli	a5,a5,0xc
ffffffffc0205700:	8fd9                	or	a5,a5,a4
ffffffffc0205702:	18079073          	csrw	satp,a5
ffffffffc0205706:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7ba8>
ffffffffc020570a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020570e:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205712:	2c070263          	beqz	a4,ffffffffc02059d6 <do_execve+0x352>
        current->mm = NULL;
ffffffffc0205716:	000db783          	ld	a5,0(s11)
ffffffffc020571a:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020571e:	f28fb0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc0205722:	84aa                	mv	s1,a0
ffffffffc0205724:	1c050b63          	beqz	a0,ffffffffc02058fa <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205728:	4505                	li	a0,1
ffffffffc020572a:	d1dfd0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc020572e:	3a050763          	beqz	a0,ffffffffc0205adc <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205732:	000adc97          	auipc	s9,0xad
ffffffffc0205736:	326c8c93          	addi	s9,s9,806 # ffffffffc02b2a58 <pages>
ffffffffc020573a:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc020573e:	000adc17          	auipc	s8,0xad
ffffffffc0205742:	312c0c13          	addi	s8,s8,786 # ffffffffc02b2a50 <npage>
    return page - pages + nbase;
ffffffffc0205746:	00003717          	auipc	a4,0x3
ffffffffc020574a:	42273703          	ld	a4,1058(a4) # ffffffffc0208b68 <nbase>
ffffffffc020574e:	40d506b3          	sub	a3,a0,a3
ffffffffc0205752:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205754:	5afd                	li	s5,-1
ffffffffc0205756:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc020575a:	96ba                	add	a3,a3,a4
ffffffffc020575c:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc020575e:	00cad713          	srli	a4,s5,0xc
ffffffffc0205762:	ec3a                	sd	a4,24(sp)
ffffffffc0205764:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205766:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205768:	36f77e63          	bgeu	a4,a5,ffffffffc0205ae4 <do_execve+0x460>
ffffffffc020576c:	000adb17          	auipc	s6,0xad
ffffffffc0205770:	2fcb0b13          	addi	s6,s6,764 # ffffffffc02b2a68 <va_pa_offset>
ffffffffc0205774:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205778:	6605                	lui	a2,0x1
ffffffffc020577a:	000ad597          	auipc	a1,0xad
ffffffffc020577e:	2ce5b583          	ld	a1,718(a1) # ffffffffc02b2a48 <boot_pgdir>
ffffffffc0205782:	9936                	add	s2,s2,a3
ffffffffc0205784:	854a                	mv	a0,s2
ffffffffc0205786:	105000ef          	jal	ra,ffffffffc020608a <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020578a:	7782                	ld	a5,32(sp)
ffffffffc020578c:	4398                	lw	a4,0(a5)
ffffffffc020578e:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205792:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205796:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9437>
ffffffffc020579a:	14f71663          	bne	a4,a5,ffffffffc02058e6 <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020579e:	7682                	ld	a3,32(sp)
ffffffffc02057a0:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02057a4:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02057a8:	00371793          	slli	a5,a4,0x3
ffffffffc02057ac:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02057ae:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02057b0:	078e                	slli	a5,a5,0x3
ffffffffc02057b2:	97ce                	add	a5,a5,s3
ffffffffc02057b4:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02057b6:	00f9fc63          	bgeu	s3,a5,ffffffffc02057ce <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02057ba:	0009a783          	lw	a5,0(s3)
ffffffffc02057be:	4705                	li	a4,1
ffffffffc02057c0:	12e78f63          	beq	a5,a4,ffffffffc02058fe <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc02057c4:	77a2                	ld	a5,40(sp)
ffffffffc02057c6:	03898993          	addi	s3,s3,56
ffffffffc02057ca:	fef9e8e3          	bltu	s3,a5,ffffffffc02057ba <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02057ce:	4701                	li	a4,0
ffffffffc02057d0:	46ad                	li	a3,11
ffffffffc02057d2:	00100637          	lui	a2,0x100
ffffffffc02057d6:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02057da:	8526                	mv	a0,s1
ffffffffc02057dc:	843fb0ef          	jal	ra,ffffffffc020101e <mm_map>
ffffffffc02057e0:	892a                	mv	s2,a0
ffffffffc02057e2:	1e051063          	bnez	a0,ffffffffc02059c2 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02057e6:	6c88                	ld	a0,24(s1)
ffffffffc02057e8:	467d                	li	a2,31
ffffffffc02057ea:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02057ee:	a20ff0ef          	jal	ra,ffffffffc0204a0e <pgdir_alloc_page>
ffffffffc02057f2:	38050163          	beqz	a0,ffffffffc0205b74 <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02057f6:	6c88                	ld	a0,24(s1)
ffffffffc02057f8:	467d                	li	a2,31
ffffffffc02057fa:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02057fe:	a10ff0ef          	jal	ra,ffffffffc0204a0e <pgdir_alloc_page>
ffffffffc0205802:	34050963          	beqz	a0,ffffffffc0205b54 <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205806:	6c88                	ld	a0,24(s1)
ffffffffc0205808:	467d                	li	a2,31
ffffffffc020580a:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc020580e:	a00ff0ef          	jal	ra,ffffffffc0204a0e <pgdir_alloc_page>
ffffffffc0205812:	32050163          	beqz	a0,ffffffffc0205b34 <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205816:	6c88                	ld	a0,24(s1)
ffffffffc0205818:	467d                	li	a2,31
ffffffffc020581a:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc020581e:	9f0ff0ef          	jal	ra,ffffffffc0204a0e <pgdir_alloc_page>
ffffffffc0205822:	2e050963          	beqz	a0,ffffffffc0205b14 <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc0205826:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205828:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020582c:	6c94                	ld	a3,24(s1)
ffffffffc020582e:	2785                	addiw	a5,a5,1
ffffffffc0205830:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205832:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205834:	c02007b7          	lui	a5,0xc0200
ffffffffc0205838:	2cf6e263          	bltu	a3,a5,ffffffffc0205afc <do_execve+0x478>
ffffffffc020583c:	000b3783          	ld	a5,0(s6)
ffffffffc0205840:	577d                	li	a4,-1
ffffffffc0205842:	177e                	slli	a4,a4,0x3f
ffffffffc0205844:	8e9d                	sub	a3,a3,a5
ffffffffc0205846:	00c6d793          	srli	a5,a3,0xc
ffffffffc020584a:	f654                	sd	a3,168(a2)
ffffffffc020584c:	8fd9                	or	a5,a5,a4
ffffffffc020584e:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205852:	7244                	ld	s1,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205854:	4581                	li	a1,0
ffffffffc0205856:	12000613          	li	a2,288
ffffffffc020585a:	8526                	mv	a0,s1
ffffffffc020585c:	01d000ef          	jal	ra,ffffffffc0206078 <memset>
    tf->epc = elf-> e_entry;
ffffffffc0205860:	7782                	ld	a5,32(sp)
ffffffffc0205862:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205864:	4785                	li	a5,1
ffffffffc0205866:	07fe                	slli	a5,a5,0x1f
ffffffffc0205868:	e89c                	sd	a5,16(s1)
    tf->epc = elf-> e_entry;
ffffffffc020586a:	10e4b423          	sd	a4,264(s1)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE);
ffffffffc020586e:	100027f3          	csrr	a5,sstatus
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205872:	000db403          	ld	s0,0(s11)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE);
ffffffffc0205876:	edf7f793          	andi	a5,a5,-289
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020587a:	4641                	li	a2,16
ffffffffc020587c:	0b440413          	addi	s0,s0,180
ffffffffc0205880:	4581                	li	a1,0
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE);
ffffffffc0205882:	10f4b023          	sd	a5,256(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205886:	8522                	mv	a0,s0
ffffffffc0205888:	7f0000ef          	jal	ra,ffffffffc0206078 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020588c:	463d                	li	a2,15
ffffffffc020588e:	180c                	addi	a1,sp,48
ffffffffc0205890:	8522                	mv	a0,s0
ffffffffc0205892:	7f8000ef          	jal	ra,ffffffffc020608a <memcpy>
}
ffffffffc0205896:	70aa                	ld	ra,168(sp)
ffffffffc0205898:	740a                	ld	s0,160(sp)
ffffffffc020589a:	64ea                	ld	s1,152(sp)
ffffffffc020589c:	69aa                	ld	s3,136(sp)
ffffffffc020589e:	6a0a                	ld	s4,128(sp)
ffffffffc02058a0:	7ae6                	ld	s5,120(sp)
ffffffffc02058a2:	7b46                	ld	s6,112(sp)
ffffffffc02058a4:	7ba6                	ld	s7,104(sp)
ffffffffc02058a6:	7c06                	ld	s8,96(sp)
ffffffffc02058a8:	6ce6                	ld	s9,88(sp)
ffffffffc02058aa:	6d46                	ld	s10,80(sp)
ffffffffc02058ac:	6da6                	ld	s11,72(sp)
ffffffffc02058ae:	854a                	mv	a0,s2
ffffffffc02058b0:	694a                	ld	s2,144(sp)
ffffffffc02058b2:	614d                	addi	sp,sp,176
ffffffffc02058b4:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc02058b6:	463d                	li	a2,15
ffffffffc02058b8:	85ca                	mv	a1,s2
ffffffffc02058ba:	1808                	addi	a0,sp,48
ffffffffc02058bc:	7ce000ef          	jal	ra,ffffffffc020608a <memcpy>
    if (mm != NULL) {
ffffffffc02058c0:	e20993e3          	bnez	s3,ffffffffc02056e6 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc02058c4:	000db783          	ld	a5,0(s11)
ffffffffc02058c8:	779c                	ld	a5,40(a5)
ffffffffc02058ca:	e4078ae3          	beqz	a5,ffffffffc020571e <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058ce:	00003617          	auipc	a2,0x3
ffffffffc02058d2:	bca60613          	addi	a2,a2,-1078 # ffffffffc0208498 <default_pmm_manager+0x890>
ffffffffc02058d6:	21600593          	li	a1,534
ffffffffc02058da:	00003517          	auipc	a0,0x3
ffffffffc02058de:	9d650513          	addi	a0,a0,-1578 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc02058e2:	927fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc02058e6:	8526                	mv	a0,s1
ffffffffc02058e8:	ca4ff0ef          	jal	ra,ffffffffc0204d8c <put_pgdir>
    mm_destroy(mm);
ffffffffc02058ec:	8526                	mv	a0,s1
ffffffffc02058ee:	edefb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058f2:	5961                	li	s2,-8
    do_exit(ret);
ffffffffc02058f4:	854a                	mv	a0,s2
ffffffffc02058f6:	94fff0ef          	jal	ra,ffffffffc0205244 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02058fa:	5971                	li	s2,-4
ffffffffc02058fc:	bfe5                	j	ffffffffc02058f4 <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02058fe:	0289b603          	ld	a2,40(s3)
ffffffffc0205902:	0209b783          	ld	a5,32(s3)
ffffffffc0205906:	1cf66d63          	bltu	a2,a5,ffffffffc0205ae0 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc020590a:	0049a783          	lw	a5,4(s3)
ffffffffc020590e:	0017f693          	andi	a3,a5,1
ffffffffc0205912:	c291                	beqz	a3,ffffffffc0205916 <do_execve+0x292>
ffffffffc0205914:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205916:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020591a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020591c:	e779                	bnez	a4,ffffffffc02059ea <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc020591e:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205920:	c781                	beqz	a5,ffffffffc0205928 <do_execve+0x2a4>
ffffffffc0205922:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205926:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205928:	0026f793          	andi	a5,a3,2
ffffffffc020592c:	e3f1                	bnez	a5,ffffffffc02059f0 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc020592e:	0046f793          	andi	a5,a3,4
ffffffffc0205932:	c399                	beqz	a5,ffffffffc0205938 <do_execve+0x2b4>
ffffffffc0205934:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205938:	0109b583          	ld	a1,16(s3)
ffffffffc020593c:	4701                	li	a4,0
ffffffffc020593e:	8526                	mv	a0,s1
ffffffffc0205940:	edefb0ef          	jal	ra,ffffffffc020101e <mm_map>
ffffffffc0205944:	892a                	mv	s2,a0
ffffffffc0205946:	ed35                	bnez	a0,ffffffffc02059c2 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205948:	0109bb83          	ld	s7,16(s3)
ffffffffc020594c:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc020594e:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205952:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205956:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc020595a:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc020595c:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc020595e:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205960:	054be963          	bltu	s7,s4,ffffffffc02059b2 <do_execve+0x32e>
ffffffffc0205964:	aa95                	j	ffffffffc0205ad8 <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205966:	6785                	lui	a5,0x1
ffffffffc0205968:	415b8533          	sub	a0,s7,s5
ffffffffc020596c:	9abe                	add	s5,s5,a5
ffffffffc020596e:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205972:	015a7463          	bgeu	s4,s5,ffffffffc020597a <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205976:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc020597a:	000cb683          	ld	a3,0(s9)
ffffffffc020597e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205980:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205984:	40d406b3          	sub	a3,s0,a3
ffffffffc0205988:	8699                	srai	a3,a3,0x6
ffffffffc020598a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020598c:	67e2                	ld	a5,24(sp)
ffffffffc020598e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205992:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205994:	14b87863          	bgeu	a6,a1,ffffffffc0205ae4 <do_execve+0x460>
ffffffffc0205998:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc020599c:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc020599e:	9bb2                	add	s7,s7,a2
ffffffffc02059a0:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc02059a2:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc02059a4:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc02059a6:	6e4000ef          	jal	ra,ffffffffc020608a <memcpy>
            start += size, from += size;
ffffffffc02059aa:	6622                	ld	a2,8(sp)
ffffffffc02059ac:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc02059ae:	054bf363          	bgeu	s7,s4,ffffffffc02059f4 <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02059b2:	6c88                	ld	a0,24(s1)
ffffffffc02059b4:	866a                	mv	a2,s10
ffffffffc02059b6:	85d6                	mv	a1,s5
ffffffffc02059b8:	856ff0ef          	jal	ra,ffffffffc0204a0e <pgdir_alloc_page>
ffffffffc02059bc:	842a                	mv	s0,a0
ffffffffc02059be:	f545                	bnez	a0,ffffffffc0205966 <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc02059c0:	5971                	li	s2,-4
    exit_mmap(mm);
ffffffffc02059c2:	8526                	mv	a0,s1
ffffffffc02059c4:	fa4fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
    put_pgdir(mm);
ffffffffc02059c8:	8526                	mv	a0,s1
ffffffffc02059ca:	bc2ff0ef          	jal	ra,ffffffffc0204d8c <put_pgdir>
    mm_destroy(mm);
ffffffffc02059ce:	8526                	mv	a0,s1
ffffffffc02059d0:	dfcfb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    return ret;
ffffffffc02059d4:	b705                	j	ffffffffc02058f4 <do_execve+0x270>
            exit_mmap(mm);
ffffffffc02059d6:	854e                	mv	a0,s3
ffffffffc02059d8:	f90fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
            put_pgdir(mm);
ffffffffc02059dc:	854e                	mv	a0,s3
ffffffffc02059de:	baeff0ef          	jal	ra,ffffffffc0204d8c <put_pgdir>
            mm_destroy(mm);
ffffffffc02059e2:	854e                	mv	a0,s3
ffffffffc02059e4:	de8fb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
ffffffffc02059e8:	b33d                	j	ffffffffc0205716 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059ea:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059ee:	fb95                	bnez	a5,ffffffffc0205922 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02059f0:	4d5d                	li	s10,23
ffffffffc02059f2:	bf35                	j	ffffffffc020592e <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc02059f4:	0109b683          	ld	a3,16(s3)
ffffffffc02059f8:	0289b903          	ld	s2,40(s3)
ffffffffc02059fc:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc02059fe:	075bfd63          	bgeu	s7,s5,ffffffffc0205a78 <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205a02:	dd7901e3          	beq	s2,s7,ffffffffc02057c4 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205a06:	6785                	lui	a5,0x1
ffffffffc0205a08:	00fb8533          	add	a0,s7,a5
ffffffffc0205a0c:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205a10:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205a14:	0b597d63          	bgeu	s2,s5,ffffffffc0205ace <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205a18:	000cb683          	ld	a3,0(s9)
ffffffffc0205a1c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a1e:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205a22:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a26:	8699                	srai	a3,a3,0x6
ffffffffc0205a28:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205a2a:	67e2                	ld	a5,24(sp)
ffffffffc0205a2c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a30:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a32:	0ac5f963          	bgeu	a1,a2,ffffffffc0205ae4 <do_execve+0x460>
ffffffffc0205a36:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205a3a:	8652                	mv	a2,s4
ffffffffc0205a3c:	4581                	li	a1,0
ffffffffc0205a3e:	96c2                	add	a3,a3,a6
ffffffffc0205a40:	9536                	add	a0,a0,a3
ffffffffc0205a42:	636000ef          	jal	ra,ffffffffc0206078 <memset>
            start += size;
ffffffffc0205a46:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205a4a:	03597463          	bgeu	s2,s5,ffffffffc0205a72 <do_execve+0x3ee>
ffffffffc0205a4e:	d6e90be3          	beq	s2,a4,ffffffffc02057c4 <do_execve+0x140>
ffffffffc0205a52:	00003697          	auipc	a3,0x3
ffffffffc0205a56:	a6e68693          	addi	a3,a3,-1426 # ffffffffc02084c0 <default_pmm_manager+0x8b8>
ffffffffc0205a5a:	00001617          	auipc	a2,0x1
ffffffffc0205a5e:	10660613          	addi	a2,a2,262 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205a62:	26b00593          	li	a1,619
ffffffffc0205a66:	00003517          	auipc	a0,0x3
ffffffffc0205a6a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205a6e:	f9afa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205a72:	ff5710e3          	bne	a4,s5,ffffffffc0205a52 <do_execve+0x3ce>
ffffffffc0205a76:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205a78:	d52bf6e3          	bgeu	s7,s2,ffffffffc02057c4 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a7c:	6c88                	ld	a0,24(s1)
ffffffffc0205a7e:	866a                	mv	a2,s10
ffffffffc0205a80:	85d6                	mv	a1,s5
ffffffffc0205a82:	f8dfe0ef          	jal	ra,ffffffffc0204a0e <pgdir_alloc_page>
ffffffffc0205a86:	842a                	mv	s0,a0
ffffffffc0205a88:	dd05                	beqz	a0,ffffffffc02059c0 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a8a:	6785                	lui	a5,0x1
ffffffffc0205a8c:	415b8533          	sub	a0,s7,s5
ffffffffc0205a90:	9abe                	add	s5,s5,a5
ffffffffc0205a92:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205a96:	01597463          	bgeu	s2,s5,ffffffffc0205a9e <do_execve+0x41a>
                size -= la - end;
ffffffffc0205a9a:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205a9e:	000cb683          	ld	a3,0(s9)
ffffffffc0205aa2:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205aa4:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205aa8:	40d406b3          	sub	a3,s0,a3
ffffffffc0205aac:	8699                	srai	a3,a3,0x6
ffffffffc0205aae:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205ab0:	67e2                	ld	a5,24(sp)
ffffffffc0205ab2:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ab6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ab8:	02b87663          	bgeu	a6,a1,ffffffffc0205ae4 <do_execve+0x460>
ffffffffc0205abc:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ac0:	4581                	li	a1,0
            start += size;
ffffffffc0205ac2:	9bb2                	add	s7,s7,a2
ffffffffc0205ac4:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ac6:	9536                	add	a0,a0,a3
ffffffffc0205ac8:	5b0000ef          	jal	ra,ffffffffc0206078 <memset>
ffffffffc0205acc:	b775                	j	ffffffffc0205a78 <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205ace:	417a8a33          	sub	s4,s5,s7
ffffffffc0205ad2:	b799                	j	ffffffffc0205a18 <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205ad4:	5975                	li	s2,-3
ffffffffc0205ad6:	b3c1                	j	ffffffffc0205896 <do_execve+0x212>
        while (start < end) {
ffffffffc0205ad8:	86de                	mv	a3,s7
ffffffffc0205ada:	bf39                	j	ffffffffc02059f8 <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205adc:	5971                	li	s2,-4
ffffffffc0205ade:	bdc5                	j	ffffffffc02059ce <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205ae0:	5961                	li	s2,-8
ffffffffc0205ae2:	b5c5                	j	ffffffffc02059c2 <do_execve+0x33e>
ffffffffc0205ae4:	00001617          	auipc	a2,0x1
ffffffffc0205ae8:	64c60613          	addi	a2,a2,1612 # ffffffffc0207130 <commands+0x9e0>
ffffffffc0205aec:	06900593          	li	a1,105
ffffffffc0205af0:	00001517          	auipc	a0,0x1
ffffffffc0205af4:	63050513          	addi	a0,a0,1584 # ffffffffc0207120 <commands+0x9d0>
ffffffffc0205af8:	f10fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205afc:	00002617          	auipc	a2,0x2
ffffffffc0205b00:	9bc60613          	addi	a2,a2,-1604 # ffffffffc02074b8 <commands+0xd68>
ffffffffc0205b04:	28600593          	li	a1,646
ffffffffc0205b08:	00002517          	auipc	a0,0x2
ffffffffc0205b0c:	7a850513          	addi	a0,a0,1960 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205b10:	ef8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b14:	00003697          	auipc	a3,0x3
ffffffffc0205b18:	ac468693          	addi	a3,a3,-1340 # ffffffffc02085d8 <default_pmm_manager+0x9d0>
ffffffffc0205b1c:	00001617          	auipc	a2,0x1
ffffffffc0205b20:	04460613          	addi	a2,a2,68 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205b24:	28100593          	li	a1,641
ffffffffc0205b28:	00002517          	auipc	a0,0x2
ffffffffc0205b2c:	78850513          	addi	a0,a0,1928 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205b30:	ed8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b34:	00003697          	auipc	a3,0x3
ffffffffc0205b38:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0208590 <default_pmm_manager+0x988>
ffffffffc0205b3c:	00001617          	auipc	a2,0x1
ffffffffc0205b40:	02460613          	addi	a2,a2,36 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205b44:	28000593          	li	a1,640
ffffffffc0205b48:	00002517          	auipc	a0,0x2
ffffffffc0205b4c:	76850513          	addi	a0,a0,1896 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205b50:	eb8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b54:	00003697          	auipc	a3,0x3
ffffffffc0205b58:	9f468693          	addi	a3,a3,-1548 # ffffffffc0208548 <default_pmm_manager+0x940>
ffffffffc0205b5c:	00001617          	auipc	a2,0x1
ffffffffc0205b60:	00460613          	addi	a2,a2,4 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205b64:	27f00593          	li	a1,639
ffffffffc0205b68:	00002517          	auipc	a0,0x2
ffffffffc0205b6c:	74850513          	addi	a0,a0,1864 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205b70:	e98fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205b74:	00003697          	auipc	a3,0x3
ffffffffc0205b78:	98c68693          	addi	a3,a3,-1652 # ffffffffc0208500 <default_pmm_manager+0x8f8>
ffffffffc0205b7c:	00001617          	auipc	a2,0x1
ffffffffc0205b80:	fe460613          	addi	a2,a2,-28 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205b84:	27e00593          	li	a1,638
ffffffffc0205b88:	00002517          	auipc	a0,0x2
ffffffffc0205b8c:	72850513          	addi	a0,a0,1832 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205b90:	e78fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205b94 <do_yield>:
    current->need_resched = 1;
ffffffffc0205b94:	000ad797          	auipc	a5,0xad
ffffffffc0205b98:	edc7b783          	ld	a5,-292(a5) # ffffffffc02b2a70 <current>
ffffffffc0205b9c:	4705                	li	a4,1
ffffffffc0205b9e:	ef98                	sd	a4,24(a5)
}
ffffffffc0205ba0:	4501                	li	a0,0
ffffffffc0205ba2:	8082                	ret

ffffffffc0205ba4 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205ba4:	1101                	addi	sp,sp,-32
ffffffffc0205ba6:	e822                	sd	s0,16(sp)
ffffffffc0205ba8:	e426                	sd	s1,8(sp)
ffffffffc0205baa:	ec06                	sd	ra,24(sp)
ffffffffc0205bac:	842e                	mv	s0,a1
ffffffffc0205bae:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205bb0:	c999                	beqz	a1,ffffffffc0205bc6 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205bb2:	000ad797          	auipc	a5,0xad
ffffffffc0205bb6:	ebe7b783          	ld	a5,-322(a5) # ffffffffc02b2a70 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205bba:	7788                	ld	a0,40(a5)
ffffffffc0205bbc:	4685                	li	a3,1
ffffffffc0205bbe:	4611                	li	a2,4
ffffffffc0205bc0:	c3ffb0ef          	jal	ra,ffffffffc02017fe <user_mem_check>
ffffffffc0205bc4:	c909                	beqz	a0,ffffffffc0205bd6 <do_wait+0x32>
ffffffffc0205bc6:	85a2                	mv	a1,s0
}
ffffffffc0205bc8:	6442                	ld	s0,16(sp)
ffffffffc0205bca:	60e2                	ld	ra,24(sp)
ffffffffc0205bcc:	8526                	mv	a0,s1
ffffffffc0205bce:	64a2                	ld	s1,8(sp)
ffffffffc0205bd0:	6105                	addi	sp,sp,32
ffffffffc0205bd2:	fbcff06f          	j	ffffffffc020538e <do_wait.part.0>
ffffffffc0205bd6:	60e2                	ld	ra,24(sp)
ffffffffc0205bd8:	6442                	ld	s0,16(sp)
ffffffffc0205bda:	64a2                	ld	s1,8(sp)
ffffffffc0205bdc:	5575                	li	a0,-3
ffffffffc0205bde:	6105                	addi	sp,sp,32
ffffffffc0205be0:	8082                	ret

ffffffffc0205be2 <do_kill>:
do_kill(int pid) {
ffffffffc0205be2:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205be4:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205be6:	e406                	sd	ra,8(sp)
ffffffffc0205be8:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205bea:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205bee:	17f9                	addi	a5,a5,-2
ffffffffc0205bf0:	02e7e963          	bltu	a5,a4,ffffffffc0205c22 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205bf4:	842a                	mv	s0,a0
ffffffffc0205bf6:	45a9                	li	a1,10
ffffffffc0205bf8:	2501                	sext.w	a0,a0
ffffffffc0205bfa:	097000ef          	jal	ra,ffffffffc0206490 <hash32>
ffffffffc0205bfe:	02051793          	slli	a5,a0,0x20
ffffffffc0205c02:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205c06:	000a9797          	auipc	a5,0xa9
ffffffffc0205c0a:	de278793          	addi	a5,a5,-542 # ffffffffc02ae9e8 <hash_list>
ffffffffc0205c0e:	953e                	add	a0,a0,a5
ffffffffc0205c10:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205c12:	a029                	j	ffffffffc0205c1c <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205c14:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205c18:	00870b63          	beq	a4,s0,ffffffffc0205c2e <do_kill+0x4c>
ffffffffc0205c1c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205c1e:	fef51be3          	bne	a0,a5,ffffffffc0205c14 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205c22:	5475                	li	s0,-3
}
ffffffffc0205c24:	60a2                	ld	ra,8(sp)
ffffffffc0205c26:	8522                	mv	a0,s0
ffffffffc0205c28:	6402                	ld	s0,0(sp)
ffffffffc0205c2a:	0141                	addi	sp,sp,16
ffffffffc0205c2c:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205c2e:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205c32:	00177693          	andi	a3,a4,1
ffffffffc0205c36:	e295                	bnez	a3,ffffffffc0205c5a <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205c38:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205c3a:	00176713          	ori	a4,a4,1
ffffffffc0205c3e:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205c42:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205c44:	fe06d0e3          	bgez	a3,ffffffffc0205c24 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205c48:	f2878513          	addi	a0,a5,-216
ffffffffc0205c4c:	1c4000ef          	jal	ra,ffffffffc0205e10 <wakeup_proc>
}
ffffffffc0205c50:	60a2                	ld	ra,8(sp)
ffffffffc0205c52:	8522                	mv	a0,s0
ffffffffc0205c54:	6402                	ld	s0,0(sp)
ffffffffc0205c56:	0141                	addi	sp,sp,16
ffffffffc0205c58:	8082                	ret
        return -E_KILLED;
ffffffffc0205c5a:	545d                	li	s0,-9
ffffffffc0205c5c:	b7e1                	j	ffffffffc0205c24 <do_kill+0x42>

ffffffffc0205c5e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205c5e:	1101                	addi	sp,sp,-32
ffffffffc0205c60:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205c62:	000ad797          	auipc	a5,0xad
ffffffffc0205c66:	d8678793          	addi	a5,a5,-634 # ffffffffc02b29e8 <proc_list>
ffffffffc0205c6a:	ec06                	sd	ra,24(sp)
ffffffffc0205c6c:	e822                	sd	s0,16(sp)
ffffffffc0205c6e:	e04a                	sd	s2,0(sp)
ffffffffc0205c70:	000a9497          	auipc	s1,0xa9
ffffffffc0205c74:	d7848493          	addi	s1,s1,-648 # ffffffffc02ae9e8 <hash_list>
ffffffffc0205c78:	e79c                	sd	a5,8(a5)
ffffffffc0205c7a:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205c7c:	000ad717          	auipc	a4,0xad
ffffffffc0205c80:	d6c70713          	addi	a4,a4,-660 # ffffffffc02b29e8 <proc_list>
ffffffffc0205c84:	87a6                	mv	a5,s1
ffffffffc0205c86:	e79c                	sd	a5,8(a5)
ffffffffc0205c88:	e39c                	sd	a5,0(a5)
ffffffffc0205c8a:	07c1                	addi	a5,a5,16
ffffffffc0205c8c:	fef71de3          	bne	a4,a5,ffffffffc0205c86 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205c90:	ffffe0ef          	jal	ra,ffffffffc0204c8e <alloc_proc>
ffffffffc0205c94:	000ad917          	auipc	s2,0xad
ffffffffc0205c98:	de490913          	addi	s2,s2,-540 # ffffffffc02b2a78 <idleproc>
ffffffffc0205c9c:	00a93023          	sd	a0,0(s2)
ffffffffc0205ca0:	0e050f63          	beqz	a0,ffffffffc0205d9e <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205ca4:	4789                	li	a5,2
ffffffffc0205ca6:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205ca8:	00003797          	auipc	a5,0x3
ffffffffc0205cac:	35878793          	addi	a5,a5,856 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205cb0:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205cb4:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205cb6:	4785                	li	a5,1
ffffffffc0205cb8:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205cba:	4641                	li	a2,16
ffffffffc0205cbc:	4581                	li	a1,0
ffffffffc0205cbe:	8522                	mv	a0,s0
ffffffffc0205cc0:	3b8000ef          	jal	ra,ffffffffc0206078 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205cc4:	463d                	li	a2,15
ffffffffc0205cc6:	00003597          	auipc	a1,0x3
ffffffffc0205cca:	97258593          	addi	a1,a1,-1678 # ffffffffc0208638 <default_pmm_manager+0xa30>
ffffffffc0205cce:	8522                	mv	a0,s0
ffffffffc0205cd0:	3ba000ef          	jal	ra,ffffffffc020608a <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205cd4:	000ad717          	auipc	a4,0xad
ffffffffc0205cd8:	db470713          	addi	a4,a4,-588 # ffffffffc02b2a88 <nr_process>
ffffffffc0205cdc:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205cde:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ce2:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205ce4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ce6:	4581                	li	a1,0
ffffffffc0205ce8:	00000517          	auipc	a0,0x0
ffffffffc0205cec:	87850513          	addi	a0,a0,-1928 # ffffffffc0205560 <init_main>
    nr_process ++;
ffffffffc0205cf0:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205cf2:	000ad797          	auipc	a5,0xad
ffffffffc0205cf6:	d6d7bf23          	sd	a3,-642(a5) # ffffffffc02b2a70 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205cfa:	cfaff0ef          	jal	ra,ffffffffc02051f4 <kernel_thread>
ffffffffc0205cfe:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205d00:	08a05363          	blez	a0,ffffffffc0205d86 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d04:	6789                	lui	a5,0x2
ffffffffc0205d06:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d0a:	17f9                	addi	a5,a5,-2
ffffffffc0205d0c:	2501                	sext.w	a0,a0
ffffffffc0205d0e:	02e7e363          	bltu	a5,a4,ffffffffc0205d34 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d12:	45a9                	li	a1,10
ffffffffc0205d14:	77c000ef          	jal	ra,ffffffffc0206490 <hash32>
ffffffffc0205d18:	02051793          	slli	a5,a0,0x20
ffffffffc0205d1c:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205d20:	96a6                	add	a3,a3,s1
ffffffffc0205d22:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205d24:	a029                	j	ffffffffc0205d2e <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205d26:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7cac>
ffffffffc0205d2a:	04870b63          	beq	a4,s0,ffffffffc0205d80 <proc_init+0x122>
    return listelm->next;
ffffffffc0205d2e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d30:	fef69be3          	bne	a3,a5,ffffffffc0205d26 <proc_init+0xc8>
    return NULL;
ffffffffc0205d34:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d36:	0b478493          	addi	s1,a5,180
ffffffffc0205d3a:	4641                	li	a2,16
ffffffffc0205d3c:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205d3e:	000ad417          	auipc	s0,0xad
ffffffffc0205d42:	d4240413          	addi	s0,s0,-702 # ffffffffc02b2a80 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d46:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205d48:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d4a:	32e000ef          	jal	ra,ffffffffc0206078 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205d4e:	463d                	li	a2,15
ffffffffc0205d50:	00003597          	auipc	a1,0x3
ffffffffc0205d54:	91058593          	addi	a1,a1,-1776 # ffffffffc0208660 <default_pmm_manager+0xa58>
ffffffffc0205d58:	8526                	mv	a0,s1
ffffffffc0205d5a:	330000ef          	jal	ra,ffffffffc020608a <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205d5e:	00093783          	ld	a5,0(s2)
ffffffffc0205d62:	cbb5                	beqz	a5,ffffffffc0205dd6 <proc_init+0x178>
ffffffffc0205d64:	43dc                	lw	a5,4(a5)
ffffffffc0205d66:	eba5                	bnez	a5,ffffffffc0205dd6 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205d68:	601c                	ld	a5,0(s0)
ffffffffc0205d6a:	c7b1                	beqz	a5,ffffffffc0205db6 <proc_init+0x158>
ffffffffc0205d6c:	43d8                	lw	a4,4(a5)
ffffffffc0205d6e:	4785                	li	a5,1
ffffffffc0205d70:	04f71363          	bne	a4,a5,ffffffffc0205db6 <proc_init+0x158>
}
ffffffffc0205d74:	60e2                	ld	ra,24(sp)
ffffffffc0205d76:	6442                	ld	s0,16(sp)
ffffffffc0205d78:	64a2                	ld	s1,8(sp)
ffffffffc0205d7a:	6902                	ld	s2,0(sp)
ffffffffc0205d7c:	6105                	addi	sp,sp,32
ffffffffc0205d7e:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205d80:	f2878793          	addi	a5,a5,-216
ffffffffc0205d84:	bf4d                	j	ffffffffc0205d36 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205d86:	00003617          	auipc	a2,0x3
ffffffffc0205d8a:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0208640 <default_pmm_manager+0xa38>
ffffffffc0205d8e:	38b00593          	li	a1,907
ffffffffc0205d92:	00002517          	auipc	a0,0x2
ffffffffc0205d96:	51e50513          	addi	a0,a0,1310 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205d9a:	c6efa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205d9e:	00003617          	auipc	a2,0x3
ffffffffc0205da2:	88260613          	addi	a2,a2,-1918 # ffffffffc0208620 <default_pmm_manager+0xa18>
ffffffffc0205da6:	37d00593          	li	a1,893
ffffffffc0205daa:	00002517          	auipc	a0,0x2
ffffffffc0205dae:	50650513          	addi	a0,a0,1286 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205db2:	c56fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205db6:	00003697          	auipc	a3,0x3
ffffffffc0205dba:	8da68693          	addi	a3,a3,-1830 # ffffffffc0208690 <default_pmm_manager+0xa88>
ffffffffc0205dbe:	00001617          	auipc	a2,0x1
ffffffffc0205dc2:	da260613          	addi	a2,a2,-606 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205dc6:	39200593          	li	a1,914
ffffffffc0205dca:	00002517          	auipc	a0,0x2
ffffffffc0205dce:	4e650513          	addi	a0,a0,1254 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205dd2:	c36fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205dd6:	00003697          	auipc	a3,0x3
ffffffffc0205dda:	89268693          	addi	a3,a3,-1902 # ffffffffc0208668 <default_pmm_manager+0xa60>
ffffffffc0205dde:	00001617          	auipc	a2,0x1
ffffffffc0205de2:	d8260613          	addi	a2,a2,-638 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205de6:	39100593          	li	a1,913
ffffffffc0205dea:	00002517          	auipc	a0,0x2
ffffffffc0205dee:	4c650513          	addi	a0,a0,1222 # ffffffffc02082b0 <default_pmm_manager+0x6a8>
ffffffffc0205df2:	c16fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205df6 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205df6:	1141                	addi	sp,sp,-16
ffffffffc0205df8:	e022                	sd	s0,0(sp)
ffffffffc0205dfa:	e406                	sd	ra,8(sp)
ffffffffc0205dfc:	000ad417          	auipc	s0,0xad
ffffffffc0205e00:	c7440413          	addi	s0,s0,-908 # ffffffffc02b2a70 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205e04:	6018                	ld	a4,0(s0)
ffffffffc0205e06:	6f1c                	ld	a5,24(a4)
ffffffffc0205e08:	dffd                	beqz	a5,ffffffffc0205e06 <cpu_idle+0x10>
            schedule();
ffffffffc0205e0a:	086000ef          	jal	ra,ffffffffc0205e90 <schedule>
ffffffffc0205e0e:	bfdd                	j	ffffffffc0205e04 <cpu_idle+0xe>

ffffffffc0205e10 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e10:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205e12:	1101                	addi	sp,sp,-32
ffffffffc0205e14:	ec06                	sd	ra,24(sp)
ffffffffc0205e16:	e822                	sd	s0,16(sp)
ffffffffc0205e18:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e1a:	478d                	li	a5,3
ffffffffc0205e1c:	04f70b63          	beq	a4,a5,ffffffffc0205e72 <wakeup_proc+0x62>
ffffffffc0205e20:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e22:	100027f3          	csrr	a5,sstatus
ffffffffc0205e26:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205e28:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e2a:	ef9d                	bnez	a5,ffffffffc0205e68 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205e2c:	4789                	li	a5,2
ffffffffc0205e2e:	02f70163          	beq	a4,a5,ffffffffc0205e50 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205e32:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205e34:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205e38:	e491                	bnez	s1,ffffffffc0205e44 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205e3a:	60e2                	ld	ra,24(sp)
ffffffffc0205e3c:	6442                	ld	s0,16(sp)
ffffffffc0205e3e:	64a2                	ld	s1,8(sp)
ffffffffc0205e40:	6105                	addi	sp,sp,32
ffffffffc0205e42:	8082                	ret
ffffffffc0205e44:	6442                	ld	s0,16(sp)
ffffffffc0205e46:	60e2                	ld	ra,24(sp)
ffffffffc0205e48:	64a2                	ld	s1,8(sp)
ffffffffc0205e4a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205e4c:	ff6fa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205e50:	00003617          	auipc	a2,0x3
ffffffffc0205e54:	8a060613          	addi	a2,a2,-1888 # ffffffffc02086f0 <default_pmm_manager+0xae8>
ffffffffc0205e58:	45c9                	li	a1,18
ffffffffc0205e5a:	00003517          	auipc	a0,0x3
ffffffffc0205e5e:	87e50513          	addi	a0,a0,-1922 # ffffffffc02086d8 <default_pmm_manager+0xad0>
ffffffffc0205e62:	c0efa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205e66:	bfc9                	j	ffffffffc0205e38 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205e68:	fe0fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205e6c:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205e6e:	4485                	li	s1,1
ffffffffc0205e70:	bf75                	j	ffffffffc0205e2c <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e72:	00003697          	auipc	a3,0x3
ffffffffc0205e76:	84668693          	addi	a3,a3,-1978 # ffffffffc02086b8 <default_pmm_manager+0xab0>
ffffffffc0205e7a:	00001617          	auipc	a2,0x1
ffffffffc0205e7e:	ce660613          	addi	a2,a2,-794 # ffffffffc0206b60 <commands+0x410>
ffffffffc0205e82:	45a5                	li	a1,9
ffffffffc0205e84:	00003517          	auipc	a0,0x3
ffffffffc0205e88:	85450513          	addi	a0,a0,-1964 # ffffffffc02086d8 <default_pmm_manager+0xad0>
ffffffffc0205e8c:	b7cfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205e90 <schedule>:

void
schedule(void) {
ffffffffc0205e90:	1141                	addi	sp,sp,-16
ffffffffc0205e92:	e406                	sd	ra,8(sp)
ffffffffc0205e94:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e96:	100027f3          	csrr	a5,sstatus
ffffffffc0205e9a:	8b89                	andi	a5,a5,2
ffffffffc0205e9c:	4401                	li	s0,0
ffffffffc0205e9e:	efbd                	bnez	a5,ffffffffc0205f1c <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205ea0:	000ad897          	auipc	a7,0xad
ffffffffc0205ea4:	bd08b883          	ld	a7,-1072(a7) # ffffffffc02b2a70 <current>
ffffffffc0205ea8:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205eac:	000ad517          	auipc	a0,0xad
ffffffffc0205eb0:	bcc53503          	ld	a0,-1076(a0) # ffffffffc02b2a78 <idleproc>
ffffffffc0205eb4:	04a88e63          	beq	a7,a0,ffffffffc0205f10 <schedule+0x80>
ffffffffc0205eb8:	0c888693          	addi	a3,a7,200
ffffffffc0205ebc:	000ad617          	auipc	a2,0xad
ffffffffc0205ec0:	b2c60613          	addi	a2,a2,-1236 # ffffffffc02b29e8 <proc_list>
        le = last;
ffffffffc0205ec4:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205ec6:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ec8:	4809                	li	a6,2
ffffffffc0205eca:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205ecc:	00c78863          	beq	a5,a2,ffffffffc0205edc <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ed0:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205ed4:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ed8:	03070163          	beq	a4,a6,ffffffffc0205efa <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205edc:	fef697e3          	bne	a3,a5,ffffffffc0205eca <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205ee0:	ed89                	bnez	a1,ffffffffc0205efa <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205ee2:	451c                	lw	a5,8(a0)
ffffffffc0205ee4:	2785                	addiw	a5,a5,1
ffffffffc0205ee6:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205ee8:	00a88463          	beq	a7,a0,ffffffffc0205ef0 <schedule+0x60>
            proc_run(next);
ffffffffc0205eec:	f17fe0ef          	jal	ra,ffffffffc0204e02 <proc_run>
    if (flag) {
ffffffffc0205ef0:	e819                	bnez	s0,ffffffffc0205f06 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205ef2:	60a2                	ld	ra,8(sp)
ffffffffc0205ef4:	6402                	ld	s0,0(sp)
ffffffffc0205ef6:	0141                	addi	sp,sp,16
ffffffffc0205ef8:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205efa:	4198                	lw	a4,0(a1)
ffffffffc0205efc:	4789                	li	a5,2
ffffffffc0205efe:	fef712e3          	bne	a4,a5,ffffffffc0205ee2 <schedule+0x52>
ffffffffc0205f02:	852e                	mv	a0,a1
ffffffffc0205f04:	bff9                	j	ffffffffc0205ee2 <schedule+0x52>
}
ffffffffc0205f06:	6402                	ld	s0,0(sp)
ffffffffc0205f08:	60a2                	ld	ra,8(sp)
ffffffffc0205f0a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205f0c:	f36fa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f10:	000ad617          	auipc	a2,0xad
ffffffffc0205f14:	ad860613          	addi	a2,a2,-1320 # ffffffffc02b29e8 <proc_list>
ffffffffc0205f18:	86b2                	mv	a3,a2
ffffffffc0205f1a:	b76d                	j	ffffffffc0205ec4 <schedule+0x34>
        intr_disable();
ffffffffc0205f1c:	f2cfa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205f20:	4405                	li	s0,1
ffffffffc0205f22:	bfbd                	j	ffffffffc0205ea0 <schedule+0x10>

ffffffffc0205f24 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205f24:	000ad797          	auipc	a5,0xad
ffffffffc0205f28:	b4c7b783          	ld	a5,-1204(a5) # ffffffffc02b2a70 <current>
}
ffffffffc0205f2c:	43c8                	lw	a0,4(a5)
ffffffffc0205f2e:	8082                	ret

ffffffffc0205f30 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205f30:	4501                	li	a0,0
ffffffffc0205f32:	8082                	ret

ffffffffc0205f34 <sys_putc>:
    cputchar(c);
ffffffffc0205f34:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205f36:	1141                	addi	sp,sp,-16
ffffffffc0205f38:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205f3a:	9c8fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0205f3e:	60a2                	ld	ra,8(sp)
ffffffffc0205f40:	4501                	li	a0,0
ffffffffc0205f42:	0141                	addi	sp,sp,16
ffffffffc0205f44:	8082                	ret

ffffffffc0205f46 <sys_kill>:
    return do_kill(pid);
ffffffffc0205f46:	4108                	lw	a0,0(a0)
ffffffffc0205f48:	c9bff06f          	j	ffffffffc0205be2 <do_kill>

ffffffffc0205f4c <sys_yield>:
    return do_yield();
ffffffffc0205f4c:	c49ff06f          	j	ffffffffc0205b94 <do_yield>

ffffffffc0205f50 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205f50:	6d14                	ld	a3,24(a0)
ffffffffc0205f52:	6910                	ld	a2,16(a0)
ffffffffc0205f54:	650c                	ld	a1,8(a0)
ffffffffc0205f56:	6108                	ld	a0,0(a0)
ffffffffc0205f58:	f2cff06f          	j	ffffffffc0205684 <do_execve>

ffffffffc0205f5c <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205f5c:	650c                	ld	a1,8(a0)
ffffffffc0205f5e:	4108                	lw	a0,0(a0)
ffffffffc0205f60:	c45ff06f          	j	ffffffffc0205ba4 <do_wait>

ffffffffc0205f64 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205f64:	000ad797          	auipc	a5,0xad
ffffffffc0205f68:	b0c7b783          	ld	a5,-1268(a5) # ffffffffc02b2a70 <current>
ffffffffc0205f6c:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205f6e:	4501                	li	a0,0
ffffffffc0205f70:	6a0c                	ld	a1,16(a2)
ffffffffc0205f72:	efdfe06f          	j	ffffffffc0204e6e <do_fork>

ffffffffc0205f76 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205f76:	4108                	lw	a0,0(a0)
ffffffffc0205f78:	accff06f          	j	ffffffffc0205244 <do_exit>

ffffffffc0205f7c <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205f7c:	715d                	addi	sp,sp,-80
ffffffffc0205f7e:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205f80:	000ad497          	auipc	s1,0xad
ffffffffc0205f84:	af048493          	addi	s1,s1,-1296 # ffffffffc02b2a70 <current>
ffffffffc0205f88:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205f8a:	e0a2                	sd	s0,64(sp)
ffffffffc0205f8c:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205f8e:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205f90:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f92:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205f94:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f98:	0327ee63          	bltu	a5,s2,ffffffffc0205fd4 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205f9c:	00391713          	slli	a4,s2,0x3
ffffffffc0205fa0:	00002797          	auipc	a5,0x2
ffffffffc0205fa4:	7b878793          	addi	a5,a5,1976 # ffffffffc0208758 <syscalls>
ffffffffc0205fa8:	97ba                	add	a5,a5,a4
ffffffffc0205faa:	639c                	ld	a5,0(a5)
ffffffffc0205fac:	c785                	beqz	a5,ffffffffc0205fd4 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205fae:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205fb0:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205fb2:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205fb4:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205fb6:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205fb8:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205fba:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205fbc:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205fbe:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205fc0:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205fc2:	0028                	addi	a0,sp,8
ffffffffc0205fc4:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205fc6:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205fc8:	e828                	sd	a0,80(s0)
}
ffffffffc0205fca:	6406                	ld	s0,64(sp)
ffffffffc0205fcc:	74e2                	ld	s1,56(sp)
ffffffffc0205fce:	7942                	ld	s2,48(sp)
ffffffffc0205fd0:	6161                	addi	sp,sp,80
ffffffffc0205fd2:	8082                	ret
    print_trapframe(tf);
ffffffffc0205fd4:	8522                	mv	a0,s0
ffffffffc0205fd6:	861fa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205fda:	609c                	ld	a5,0(s1)
ffffffffc0205fdc:	86ca                	mv	a3,s2
ffffffffc0205fde:	00002617          	auipc	a2,0x2
ffffffffc0205fe2:	73260613          	addi	a2,a2,1842 # ffffffffc0208710 <default_pmm_manager+0xb08>
ffffffffc0205fe6:	43d8                	lw	a4,4(a5)
ffffffffc0205fe8:	06200593          	li	a1,98
ffffffffc0205fec:	0b478793          	addi	a5,a5,180
ffffffffc0205ff0:	00002517          	auipc	a0,0x2
ffffffffc0205ff4:	75050513          	addi	a0,a0,1872 # ffffffffc0208740 <default_pmm_manager+0xb38>
ffffffffc0205ff8:	a10fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205ffc <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205ffc:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206000:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206002:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206004:	cb81                	beqz	a5,ffffffffc0206014 <strlen+0x18>
        cnt ++;
ffffffffc0206006:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206008:	00a707b3          	add	a5,a4,a0
ffffffffc020600c:	0007c783          	lbu	a5,0(a5)
ffffffffc0206010:	fbfd                	bnez	a5,ffffffffc0206006 <strlen+0xa>
ffffffffc0206012:	8082                	ret
    }
    return cnt;
}
ffffffffc0206014:	8082                	ret

ffffffffc0206016 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206016:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206018:	e589                	bnez	a1,ffffffffc0206022 <strnlen+0xc>
ffffffffc020601a:	a811                	j	ffffffffc020602e <strnlen+0x18>
        cnt ++;
ffffffffc020601c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020601e:	00f58863          	beq	a1,a5,ffffffffc020602e <strnlen+0x18>
ffffffffc0206022:	00f50733          	add	a4,a0,a5
ffffffffc0206026:	00074703          	lbu	a4,0(a4)
ffffffffc020602a:	fb6d                	bnez	a4,ffffffffc020601c <strnlen+0x6>
ffffffffc020602c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020602e:	852e                	mv	a0,a1
ffffffffc0206030:	8082                	ret

ffffffffc0206032 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206032:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206034:	0005c703          	lbu	a4,0(a1)
ffffffffc0206038:	0785                	addi	a5,a5,1
ffffffffc020603a:	0585                	addi	a1,a1,1
ffffffffc020603c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206040:	fb75                	bnez	a4,ffffffffc0206034 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206042:	8082                	ret

ffffffffc0206044 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206044:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206048:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020604c:	cb89                	beqz	a5,ffffffffc020605e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020604e:	0505                	addi	a0,a0,1
ffffffffc0206050:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206052:	fee789e3          	beq	a5,a4,ffffffffc0206044 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206056:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020605a:	9d19                	subw	a0,a0,a4
ffffffffc020605c:	8082                	ret
ffffffffc020605e:	4501                	li	a0,0
ffffffffc0206060:	bfed                	j	ffffffffc020605a <strcmp+0x16>

ffffffffc0206062 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206062:	00054783          	lbu	a5,0(a0)
ffffffffc0206066:	c799                	beqz	a5,ffffffffc0206074 <strchr+0x12>
        if (*s == c) {
ffffffffc0206068:	00f58763          	beq	a1,a5,ffffffffc0206076 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020606c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206070:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206072:	fbfd                	bnez	a5,ffffffffc0206068 <strchr+0x6>
    }
    return NULL;
ffffffffc0206074:	4501                	li	a0,0
}
ffffffffc0206076:	8082                	ret

ffffffffc0206078 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206078:	ca01                	beqz	a2,ffffffffc0206088 <memset+0x10>
ffffffffc020607a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020607c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020607e:	0785                	addi	a5,a5,1
ffffffffc0206080:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206084:	fec79de3          	bne	a5,a2,ffffffffc020607e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206088:	8082                	ret

ffffffffc020608a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020608a:	ca19                	beqz	a2,ffffffffc02060a0 <memcpy+0x16>
ffffffffc020608c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020608e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206090:	0005c703          	lbu	a4,0(a1)
ffffffffc0206094:	0585                	addi	a1,a1,1
ffffffffc0206096:	0785                	addi	a5,a5,1
ffffffffc0206098:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020609c:	fec59ae3          	bne	a1,a2,ffffffffc0206090 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02060a0:	8082                	ret

ffffffffc02060a2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02060a2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060a6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02060a8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060ac:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02060ae:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060b2:	f022                	sd	s0,32(sp)
ffffffffc02060b4:	ec26                	sd	s1,24(sp)
ffffffffc02060b6:	e84a                	sd	s2,16(sp)
ffffffffc02060b8:	f406                	sd	ra,40(sp)
ffffffffc02060ba:	e44e                	sd	s3,8(sp)
ffffffffc02060bc:	84aa                	mv	s1,a0
ffffffffc02060be:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02060c0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02060c4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02060c6:	03067e63          	bgeu	a2,a6,ffffffffc0206102 <printnum+0x60>
ffffffffc02060ca:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02060cc:	00805763          	blez	s0,ffffffffc02060da <printnum+0x38>
ffffffffc02060d0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02060d2:	85ca                	mv	a1,s2
ffffffffc02060d4:	854e                	mv	a0,s3
ffffffffc02060d6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02060d8:	fc65                	bnez	s0,ffffffffc02060d0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060da:	1a02                	slli	s4,s4,0x20
ffffffffc02060dc:	00002797          	auipc	a5,0x2
ffffffffc02060e0:	77c78793          	addi	a5,a5,1916 # ffffffffc0208858 <syscalls+0x100>
ffffffffc02060e4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02060e8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02060ea:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060ec:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02060f0:	70a2                	ld	ra,40(sp)
ffffffffc02060f2:	69a2                	ld	s3,8(sp)
ffffffffc02060f4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060f6:	85ca                	mv	a1,s2
ffffffffc02060f8:	87a6                	mv	a5,s1
}
ffffffffc02060fa:	6942                	ld	s2,16(sp)
ffffffffc02060fc:	64e2                	ld	s1,24(sp)
ffffffffc02060fe:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206100:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206102:	03065633          	divu	a2,a2,a6
ffffffffc0206106:	8722                	mv	a4,s0
ffffffffc0206108:	f9bff0ef          	jal	ra,ffffffffc02060a2 <printnum>
ffffffffc020610c:	b7f9                	j	ffffffffc02060da <printnum+0x38>

ffffffffc020610e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020610e:	7119                	addi	sp,sp,-128
ffffffffc0206110:	f4a6                	sd	s1,104(sp)
ffffffffc0206112:	f0ca                	sd	s2,96(sp)
ffffffffc0206114:	ecce                	sd	s3,88(sp)
ffffffffc0206116:	e8d2                	sd	s4,80(sp)
ffffffffc0206118:	e4d6                	sd	s5,72(sp)
ffffffffc020611a:	e0da                	sd	s6,64(sp)
ffffffffc020611c:	fc5e                	sd	s7,56(sp)
ffffffffc020611e:	f06a                	sd	s10,32(sp)
ffffffffc0206120:	fc86                	sd	ra,120(sp)
ffffffffc0206122:	f8a2                	sd	s0,112(sp)
ffffffffc0206124:	f862                	sd	s8,48(sp)
ffffffffc0206126:	f466                	sd	s9,40(sp)
ffffffffc0206128:	ec6e                	sd	s11,24(sp)
ffffffffc020612a:	892a                	mv	s2,a0
ffffffffc020612c:	84ae                	mv	s1,a1
ffffffffc020612e:	8d32                	mv	s10,a2
ffffffffc0206130:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206132:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206136:	5b7d                	li	s6,-1
ffffffffc0206138:	00002a97          	auipc	s5,0x2
ffffffffc020613c:	74ca8a93          	addi	s5,s5,1868 # ffffffffc0208884 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206140:	00003b97          	auipc	s7,0x3
ffffffffc0206144:	960b8b93          	addi	s7,s7,-1696 # ffffffffc0208aa0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206148:	000d4503          	lbu	a0,0(s10) # 200000 <_binary_obj___user_exit_out_size+0x1f4eb8>
ffffffffc020614c:	001d0413          	addi	s0,s10,1
ffffffffc0206150:	01350a63          	beq	a0,s3,ffffffffc0206164 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206154:	c121                	beqz	a0,ffffffffc0206194 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206156:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206158:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020615a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020615c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206160:	ff351ae3          	bne	a0,s3,ffffffffc0206154 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206164:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206168:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020616c:	4c81                	li	s9,0
ffffffffc020616e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0206170:	5c7d                	li	s8,-1
ffffffffc0206172:	5dfd                	li	s11,-1
ffffffffc0206174:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206178:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020617a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020617e:	0ff5f593          	zext.b	a1,a1
ffffffffc0206182:	00140d13          	addi	s10,s0,1
ffffffffc0206186:	04b56263          	bltu	a0,a1,ffffffffc02061ca <vprintfmt+0xbc>
ffffffffc020618a:	058a                	slli	a1,a1,0x2
ffffffffc020618c:	95d6                	add	a1,a1,s5
ffffffffc020618e:	4194                	lw	a3,0(a1)
ffffffffc0206190:	96d6                	add	a3,a3,s5
ffffffffc0206192:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206194:	70e6                	ld	ra,120(sp)
ffffffffc0206196:	7446                	ld	s0,112(sp)
ffffffffc0206198:	74a6                	ld	s1,104(sp)
ffffffffc020619a:	7906                	ld	s2,96(sp)
ffffffffc020619c:	69e6                	ld	s3,88(sp)
ffffffffc020619e:	6a46                	ld	s4,80(sp)
ffffffffc02061a0:	6aa6                	ld	s5,72(sp)
ffffffffc02061a2:	6b06                	ld	s6,64(sp)
ffffffffc02061a4:	7be2                	ld	s7,56(sp)
ffffffffc02061a6:	7c42                	ld	s8,48(sp)
ffffffffc02061a8:	7ca2                	ld	s9,40(sp)
ffffffffc02061aa:	7d02                	ld	s10,32(sp)
ffffffffc02061ac:	6de2                	ld	s11,24(sp)
ffffffffc02061ae:	6109                	addi	sp,sp,128
ffffffffc02061b0:	8082                	ret
            padc = '0';
ffffffffc02061b2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02061b4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061b8:	846a                	mv	s0,s10
ffffffffc02061ba:	00140d13          	addi	s10,s0,1
ffffffffc02061be:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02061c2:	0ff5f593          	zext.b	a1,a1
ffffffffc02061c6:	fcb572e3          	bgeu	a0,a1,ffffffffc020618a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02061ca:	85a6                	mv	a1,s1
ffffffffc02061cc:	02500513          	li	a0,37
ffffffffc02061d0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02061d2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02061d6:	8d22                	mv	s10,s0
ffffffffc02061d8:	f73788e3          	beq	a5,s3,ffffffffc0206148 <vprintfmt+0x3a>
ffffffffc02061dc:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02061e0:	1d7d                	addi	s10,s10,-1
ffffffffc02061e2:	ff379de3          	bne	a5,s3,ffffffffc02061dc <vprintfmt+0xce>
ffffffffc02061e6:	b78d                	j	ffffffffc0206148 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02061e8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02061ec:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061f0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02061f2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02061f6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02061fa:	02d86463          	bltu	a6,a3,ffffffffc0206222 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02061fe:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206202:	002c169b          	slliw	a3,s8,0x2
ffffffffc0206206:	0186873b          	addw	a4,a3,s8
ffffffffc020620a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020620e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206210:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206214:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206216:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020621a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020621e:	fed870e3          	bgeu	a6,a3,ffffffffc02061fe <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206222:	f40ddce3          	bgez	s11,ffffffffc020617a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0206226:	8de2                	mv	s11,s8
ffffffffc0206228:	5c7d                	li	s8,-1
ffffffffc020622a:	bf81                	j	ffffffffc020617a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020622c:	fffdc693          	not	a3,s11
ffffffffc0206230:	96fd                	srai	a3,a3,0x3f
ffffffffc0206232:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206236:	00144603          	lbu	a2,1(s0)
ffffffffc020623a:	2d81                	sext.w	s11,s11
ffffffffc020623c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020623e:	bf35                	j	ffffffffc020617a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206240:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206244:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206248:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020624a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020624c:	bfd9                	j	ffffffffc0206222 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020624e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206250:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206254:	01174463          	blt	a4,a7,ffffffffc020625c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206258:	1a088e63          	beqz	a7,ffffffffc0206414 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020625c:	000a3603          	ld	a2,0(s4)
ffffffffc0206260:	46c1                	li	a3,16
ffffffffc0206262:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206264:	2781                	sext.w	a5,a5
ffffffffc0206266:	876e                	mv	a4,s11
ffffffffc0206268:	85a6                	mv	a1,s1
ffffffffc020626a:	854a                	mv	a0,s2
ffffffffc020626c:	e37ff0ef          	jal	ra,ffffffffc02060a2 <printnum>
            break;
ffffffffc0206270:	bde1                	j	ffffffffc0206148 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0206272:	000a2503          	lw	a0,0(s4)
ffffffffc0206276:	85a6                	mv	a1,s1
ffffffffc0206278:	0a21                	addi	s4,s4,8
ffffffffc020627a:	9902                	jalr	s2
            break;
ffffffffc020627c:	b5f1                	j	ffffffffc0206148 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020627e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206280:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206284:	01174463          	blt	a4,a7,ffffffffc020628c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206288:	18088163          	beqz	a7,ffffffffc020640a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020628c:	000a3603          	ld	a2,0(s4)
ffffffffc0206290:	46a9                	li	a3,10
ffffffffc0206292:	8a2e                	mv	s4,a1
ffffffffc0206294:	bfc1                	j	ffffffffc0206264 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206296:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020629a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020629c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020629e:	bdf1                	j	ffffffffc020617a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02062a0:	85a6                	mv	a1,s1
ffffffffc02062a2:	02500513          	li	a0,37
ffffffffc02062a6:	9902                	jalr	s2
            break;
ffffffffc02062a8:	b545                	j	ffffffffc0206148 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062aa:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02062ae:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062b0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062b2:	b5e1                	j	ffffffffc020617a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02062b4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02062b6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02062ba:	01174463          	blt	a4,a7,ffffffffc02062c2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02062be:	14088163          	beqz	a7,ffffffffc0206400 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02062c2:	000a3603          	ld	a2,0(s4)
ffffffffc02062c6:	46a1                	li	a3,8
ffffffffc02062c8:	8a2e                	mv	s4,a1
ffffffffc02062ca:	bf69                	j	ffffffffc0206264 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02062cc:	03000513          	li	a0,48
ffffffffc02062d0:	85a6                	mv	a1,s1
ffffffffc02062d2:	e03e                	sd	a5,0(sp)
ffffffffc02062d4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02062d6:	85a6                	mv	a1,s1
ffffffffc02062d8:	07800513          	li	a0,120
ffffffffc02062dc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02062de:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02062e0:	6782                	ld	a5,0(sp)
ffffffffc02062e2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02062e4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02062e8:	bfb5                	j	ffffffffc0206264 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02062ea:	000a3403          	ld	s0,0(s4)
ffffffffc02062ee:	008a0713          	addi	a4,s4,8
ffffffffc02062f2:	e03a                	sd	a4,0(sp)
ffffffffc02062f4:	14040263          	beqz	s0,ffffffffc0206438 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02062f8:	0fb05763          	blez	s11,ffffffffc02063e6 <vprintfmt+0x2d8>
ffffffffc02062fc:	02d00693          	li	a3,45
ffffffffc0206300:	0cd79163          	bne	a5,a3,ffffffffc02063c2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206304:	00044783          	lbu	a5,0(s0)
ffffffffc0206308:	0007851b          	sext.w	a0,a5
ffffffffc020630c:	cf85                	beqz	a5,ffffffffc0206344 <vprintfmt+0x236>
ffffffffc020630e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206312:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206316:	000c4563          	bltz	s8,ffffffffc0206320 <vprintfmt+0x212>
ffffffffc020631a:	3c7d                	addiw	s8,s8,-1
ffffffffc020631c:	036c0263          	beq	s8,s6,ffffffffc0206340 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206320:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206322:	0e0c8e63          	beqz	s9,ffffffffc020641e <vprintfmt+0x310>
ffffffffc0206326:	3781                	addiw	a5,a5,-32
ffffffffc0206328:	0ef47b63          	bgeu	s0,a5,ffffffffc020641e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020632c:	03f00513          	li	a0,63
ffffffffc0206330:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206332:	000a4783          	lbu	a5,0(s4)
ffffffffc0206336:	3dfd                	addiw	s11,s11,-1
ffffffffc0206338:	0a05                	addi	s4,s4,1
ffffffffc020633a:	0007851b          	sext.w	a0,a5
ffffffffc020633e:	ffe1                	bnez	a5,ffffffffc0206316 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206340:	01b05963          	blez	s11,ffffffffc0206352 <vprintfmt+0x244>
ffffffffc0206344:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206346:	85a6                	mv	a1,s1
ffffffffc0206348:	02000513          	li	a0,32
ffffffffc020634c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020634e:	fe0d9be3          	bnez	s11,ffffffffc0206344 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206352:	6a02                	ld	s4,0(sp)
ffffffffc0206354:	bbd5                	j	ffffffffc0206148 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206356:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206358:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020635c:	01174463          	blt	a4,a7,ffffffffc0206364 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206360:	08088d63          	beqz	a7,ffffffffc02063fa <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206364:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206368:	0a044d63          	bltz	s0,ffffffffc0206422 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020636c:	8622                	mv	a2,s0
ffffffffc020636e:	8a66                	mv	s4,s9
ffffffffc0206370:	46a9                	li	a3,10
ffffffffc0206372:	bdcd                	j	ffffffffc0206264 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0206374:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206378:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020637a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020637c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206380:	8fb5                	xor	a5,a5,a3
ffffffffc0206382:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206386:	02d74163          	blt	a4,a3,ffffffffc02063a8 <vprintfmt+0x29a>
ffffffffc020638a:	00369793          	slli	a5,a3,0x3
ffffffffc020638e:	97de                	add	a5,a5,s7
ffffffffc0206390:	639c                	ld	a5,0(a5)
ffffffffc0206392:	cb99                	beqz	a5,ffffffffc02063a8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206394:	86be                	mv	a3,a5
ffffffffc0206396:	00000617          	auipc	a2,0x0
ffffffffc020639a:	13a60613          	addi	a2,a2,314 # ffffffffc02064d0 <etext+0x2a>
ffffffffc020639e:	85a6                	mv	a1,s1
ffffffffc02063a0:	854a                	mv	a0,s2
ffffffffc02063a2:	0ce000ef          	jal	ra,ffffffffc0206470 <printfmt>
ffffffffc02063a6:	b34d                	j	ffffffffc0206148 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02063a8:	00002617          	auipc	a2,0x2
ffffffffc02063ac:	4d060613          	addi	a2,a2,1232 # ffffffffc0208878 <syscalls+0x120>
ffffffffc02063b0:	85a6                	mv	a1,s1
ffffffffc02063b2:	854a                	mv	a0,s2
ffffffffc02063b4:	0bc000ef          	jal	ra,ffffffffc0206470 <printfmt>
ffffffffc02063b8:	bb41                	j	ffffffffc0206148 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02063ba:	00002417          	auipc	s0,0x2
ffffffffc02063be:	4b640413          	addi	s0,s0,1206 # ffffffffc0208870 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063c2:	85e2                	mv	a1,s8
ffffffffc02063c4:	8522                	mv	a0,s0
ffffffffc02063c6:	e43e                	sd	a5,8(sp)
ffffffffc02063c8:	c4fff0ef          	jal	ra,ffffffffc0206016 <strnlen>
ffffffffc02063cc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02063d0:	01b05b63          	blez	s11,ffffffffc02063e6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02063d4:	67a2                	ld	a5,8(sp)
ffffffffc02063d6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063da:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02063dc:	85a6                	mv	a1,s1
ffffffffc02063de:	8552                	mv	a0,s4
ffffffffc02063e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063e2:	fe0d9ce3          	bnez	s11,ffffffffc02063da <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063e6:	00044783          	lbu	a5,0(s0)
ffffffffc02063ea:	00140a13          	addi	s4,s0,1
ffffffffc02063ee:	0007851b          	sext.w	a0,a5
ffffffffc02063f2:	d3a5                	beqz	a5,ffffffffc0206352 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063f4:	05e00413          	li	s0,94
ffffffffc02063f8:	bf39                	j	ffffffffc0206316 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02063fa:	000a2403          	lw	s0,0(s4)
ffffffffc02063fe:	b7ad                	j	ffffffffc0206368 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206400:	000a6603          	lwu	a2,0(s4)
ffffffffc0206404:	46a1                	li	a3,8
ffffffffc0206406:	8a2e                	mv	s4,a1
ffffffffc0206408:	bdb1                	j	ffffffffc0206264 <vprintfmt+0x156>
ffffffffc020640a:	000a6603          	lwu	a2,0(s4)
ffffffffc020640e:	46a9                	li	a3,10
ffffffffc0206410:	8a2e                	mv	s4,a1
ffffffffc0206412:	bd89                	j	ffffffffc0206264 <vprintfmt+0x156>
ffffffffc0206414:	000a6603          	lwu	a2,0(s4)
ffffffffc0206418:	46c1                	li	a3,16
ffffffffc020641a:	8a2e                	mv	s4,a1
ffffffffc020641c:	b5a1                	j	ffffffffc0206264 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020641e:	9902                	jalr	s2
ffffffffc0206420:	bf09                	j	ffffffffc0206332 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206422:	85a6                	mv	a1,s1
ffffffffc0206424:	02d00513          	li	a0,45
ffffffffc0206428:	e03e                	sd	a5,0(sp)
ffffffffc020642a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020642c:	6782                	ld	a5,0(sp)
ffffffffc020642e:	8a66                	mv	s4,s9
ffffffffc0206430:	40800633          	neg	a2,s0
ffffffffc0206434:	46a9                	li	a3,10
ffffffffc0206436:	b53d                	j	ffffffffc0206264 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0206438:	03b05163          	blez	s11,ffffffffc020645a <vprintfmt+0x34c>
ffffffffc020643c:	02d00693          	li	a3,45
ffffffffc0206440:	f6d79de3          	bne	a5,a3,ffffffffc02063ba <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206444:	00002417          	auipc	s0,0x2
ffffffffc0206448:	42c40413          	addi	s0,s0,1068 # ffffffffc0208870 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020644c:	02800793          	li	a5,40
ffffffffc0206450:	02800513          	li	a0,40
ffffffffc0206454:	00140a13          	addi	s4,s0,1
ffffffffc0206458:	bd6d                	j	ffffffffc0206312 <vprintfmt+0x204>
ffffffffc020645a:	00002a17          	auipc	s4,0x2
ffffffffc020645e:	417a0a13          	addi	s4,s4,1047 # ffffffffc0208871 <syscalls+0x119>
ffffffffc0206462:	02800513          	li	a0,40
ffffffffc0206466:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020646a:	05e00413          	li	s0,94
ffffffffc020646e:	b565                	j	ffffffffc0206316 <vprintfmt+0x208>

ffffffffc0206470 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206470:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206472:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206476:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206478:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020647a:	ec06                	sd	ra,24(sp)
ffffffffc020647c:	f83a                	sd	a4,48(sp)
ffffffffc020647e:	fc3e                	sd	a5,56(sp)
ffffffffc0206480:	e0c2                	sd	a6,64(sp)
ffffffffc0206482:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206484:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206486:	c89ff0ef          	jal	ra,ffffffffc020610e <vprintfmt>
}
ffffffffc020648a:	60e2                	ld	ra,24(sp)
ffffffffc020648c:	6161                	addi	sp,sp,80
ffffffffc020648e:	8082                	ret

ffffffffc0206490 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206490:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206494:	2785                	addiw	a5,a5,1
ffffffffc0206496:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc020649a:	02000793          	li	a5,32
ffffffffc020649e:	9f8d                	subw	a5,a5,a1
}
ffffffffc02064a0:	00f5553b          	srlw	a0,a0,a5
ffffffffc02064a4:	8082                	ret
