
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc0200024:	c020a137          	lui	sp,0xc020a

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
ffffffffc0200032:	0000b517          	auipc	a0,0xb
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020b060 <buf>
ffffffffc020003a:	00016617          	auipc	a2,0x16
ffffffffc020003e:	59260613          	addi	a2,a2,1426 # ffffffffc02165cc <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	6e9040ef          	jal	ra,ffffffffc0204f32 <memset>

    cons_init();                // init the console
ffffffffc020004e:	4a6000ef          	jal	ra,ffffffffc02004f4 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	f2e58593          	addi	a1,a1,-210 # ffffffffc0204f80 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	f4650513          	addi	a0,a0,-186 # ffffffffc0204fa0 <etext+0x20>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	162000ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	709010ef          	jal	ra,ffffffffc0201f72 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	55a000ef          	jal	ra,ffffffffc02005c8 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	2a5030ef          	jal	ra,ffffffffc0203b1a <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	6d0040ef          	jal	ra,ffffffffc020474a <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4e8000ef          	jal	ra,ffffffffc0200566 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	3cd020ef          	jal	ra,ffffffffc0202c4e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	41c000ef          	jal	ra,ffffffffc02004a2 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	532000ef          	jal	ra,ffffffffc02005bc <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	10b040ef          	jal	ra,ffffffffc0204998 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00005517          	auipc	a0,0x5
ffffffffc02000ac:	f0050513          	addi	a0,a0,-256 # ffffffffc0204fa8 <etext+0x28>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	0000bb97          	auipc	s7,0xb
ffffffffc02000c2:	fa2b8b93          	addi	s7,s7,-94 # ffffffffc020b060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	0ee000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	0de000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	0cc000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	0000b517          	auipc	a0,0xb
ffffffffc020011e:	f4650513          	addi	a0,a0,-186 # ffffffffc020b060 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	3a8000ef          	jal	ra,ffffffffc02004f6 <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	1c1040ef          	jal	ra,ffffffffc0204b34 <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	18b040ef          	jal	ra,ffffffffc0204b34 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a681                	j	ffffffffc02004f6 <cons_putc>

ffffffffc02001b8 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001b8:	1141                	addi	sp,sp,-16
ffffffffc02001ba:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001bc:	36e000ef          	jal	ra,ffffffffc020052a <cons_getc>
ffffffffc02001c0:	dd75                	beqz	a0,ffffffffc02001bc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001c2:	60a2                	ld	ra,8(sp)
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001ca:	00005517          	auipc	a0,0x5
ffffffffc02001ce:	de650513          	addi	a0,a0,-538 # ffffffffc0204fb0 <etext+0x30>
void print_kerninfo(void) {
ffffffffc02001d2:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001d4:	fadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001d8:	00000597          	auipc	a1,0x0
ffffffffc02001dc:	e5a58593          	addi	a1,a1,-422 # ffffffffc0200032 <kern_init>
ffffffffc02001e0:	00005517          	auipc	a0,0x5
ffffffffc02001e4:	df050513          	addi	a0,a0,-528 # ffffffffc0204fd0 <etext+0x50>
ffffffffc02001e8:	f99ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001ec:	00005597          	auipc	a1,0x5
ffffffffc02001f0:	d9458593          	addi	a1,a1,-620 # ffffffffc0204f80 <etext>
ffffffffc02001f4:	00005517          	auipc	a0,0x5
ffffffffc02001f8:	dfc50513          	addi	a0,a0,-516 # ffffffffc0204ff0 <etext+0x70>
ffffffffc02001fc:	f85ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200200:	0000b597          	auipc	a1,0xb
ffffffffc0200204:	e6058593          	addi	a1,a1,-416 # ffffffffc020b060 <buf>
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	e0850513          	addi	a0,a0,-504 # ffffffffc0205010 <etext+0x90>
ffffffffc0200210:	f71ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200214:	00016597          	auipc	a1,0x16
ffffffffc0200218:	3b858593          	addi	a1,a1,952 # ffffffffc02165cc <end>
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	e1450513          	addi	a0,a0,-492 # ffffffffc0205030 <etext+0xb0>
ffffffffc0200224:	f5dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200228:	00016597          	auipc	a1,0x16
ffffffffc020022c:	7a358593          	addi	a1,a1,1955 # ffffffffc02169cb <end+0x3ff>
ffffffffc0200230:	00000797          	auipc	a5,0x0
ffffffffc0200234:	e0278793          	addi	a5,a5,-510 # ffffffffc0200032 <kern_init>
ffffffffc0200238:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200240:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200242:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200246:	95be                	add	a1,a1,a5
ffffffffc0200248:	85a9                	srai	a1,a1,0xa
ffffffffc020024a:	00005517          	auipc	a0,0x5
ffffffffc020024e:	e0650513          	addi	a0,a0,-506 # ffffffffc0205050 <etext+0xd0>
}
ffffffffc0200252:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200254:	b735                	j	ffffffffc0200180 <cprintf>

ffffffffc0200256 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200258:	00005617          	auipc	a2,0x5
ffffffffc020025c:	e2860613          	addi	a2,a2,-472 # ffffffffc0205080 <etext+0x100>
ffffffffc0200260:	04d00593          	li	a1,77
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	e3450513          	addi	a0,a0,-460 # ffffffffc0205098 <etext+0x118>
void print_stackframe(void) {
ffffffffc020026c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020026e:	1d8000ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200272 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200274:	00005617          	auipc	a2,0x5
ffffffffc0200278:	e3c60613          	addi	a2,a2,-452 # ffffffffc02050b0 <etext+0x130>
ffffffffc020027c:	00005597          	auipc	a1,0x5
ffffffffc0200280:	e5458593          	addi	a1,a1,-428 # ffffffffc02050d0 <etext+0x150>
ffffffffc0200284:	00005517          	auipc	a0,0x5
ffffffffc0200288:	e5450513          	addi	a0,a0,-428 # ffffffffc02050d8 <etext+0x158>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020028c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020028e:	ef3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200292:	00005617          	auipc	a2,0x5
ffffffffc0200296:	e5660613          	addi	a2,a2,-426 # ffffffffc02050e8 <etext+0x168>
ffffffffc020029a:	00005597          	auipc	a1,0x5
ffffffffc020029e:	e7658593          	addi	a1,a1,-394 # ffffffffc0205110 <etext+0x190>
ffffffffc02002a2:	00005517          	auipc	a0,0x5
ffffffffc02002a6:	e3650513          	addi	a0,a0,-458 # ffffffffc02050d8 <etext+0x158>
ffffffffc02002aa:	ed7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ae:	00005617          	auipc	a2,0x5
ffffffffc02002b2:	e7260613          	addi	a2,a2,-398 # ffffffffc0205120 <etext+0x1a0>
ffffffffc02002b6:	00005597          	auipc	a1,0x5
ffffffffc02002ba:	e8a58593          	addi	a1,a1,-374 # ffffffffc0205140 <etext+0x1c0>
ffffffffc02002be:	00005517          	auipc	a0,0x5
ffffffffc02002c2:	e1a50513          	addi	a0,a0,-486 # ffffffffc02050d8 <etext+0x158>
ffffffffc02002c6:	ebbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc02002ca:	60a2                	ld	ra,8(sp)
ffffffffc02002cc:	4501                	li	a0,0
ffffffffc02002ce:	0141                	addi	sp,sp,16
ffffffffc02002d0:	8082                	ret

ffffffffc02002d2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d2:	1141                	addi	sp,sp,-16
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002d6:	ef3ff0ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002e6:	f71ff0ef          	jal	ra,ffffffffc0200256 <print_stackframe>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002f2:	7115                	addi	sp,sp,-224
ffffffffc02002f4:	ed5e                	sd	s7,152(sp)
ffffffffc02002f6:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f8:	00005517          	auipc	a0,0x5
ffffffffc02002fc:	e5850513          	addi	a0,a0,-424 # ffffffffc0205150 <etext+0x1d0>
kmonitor(struct trapframe *tf) {
ffffffffc0200300:	ed86                	sd	ra,216(sp)
ffffffffc0200302:	e9a2                	sd	s0,208(sp)
ffffffffc0200304:	e5a6                	sd	s1,200(sp)
ffffffffc0200306:	e1ca                	sd	s2,192(sp)
ffffffffc0200308:	fd4e                	sd	s3,184(sp)
ffffffffc020030a:	f952                	sd	s4,176(sp)
ffffffffc020030c:	f556                	sd	s5,168(sp)
ffffffffc020030e:	f15a                	sd	s6,160(sp)
ffffffffc0200310:	e962                	sd	s8,144(sp)
ffffffffc0200312:	e566                	sd	s9,136(sp)
ffffffffc0200314:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200316:	e6bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	e5e50513          	addi	a0,a0,-418 # ffffffffc0205178 <etext+0x1f8>
ffffffffc0200322:	e5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200326:	000b8563          	beqz	s7,ffffffffc0200330 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020032a:	855e                	mv	a0,s7
ffffffffc020032c:	4f4000ef          	jal	ra,ffffffffc0200820 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	4581                	li	a1,0
ffffffffc0200334:	4601                	li	a2,0
ffffffffc0200336:	48a1                	li	a7,8
ffffffffc0200338:	00000073          	ecall
ffffffffc020033c:	00005c17          	auipc	s8,0x5
ffffffffc0200340:	eacc0c13          	addi	s8,s8,-340 # ffffffffc02051e8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200344:	00005917          	auipc	s2,0x5
ffffffffc0200348:	e5c90913          	addi	s2,s2,-420 # ffffffffc02051a0 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	00005497          	auipc	s1,0x5
ffffffffc0200350:	e5c48493          	addi	s1,s1,-420 # ffffffffc02051a8 <etext+0x228>
        if (argc == MAXARGS - 1) {
ffffffffc0200354:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200356:	00005b17          	auipc	s6,0x5
ffffffffc020035a:	e5ab0b13          	addi	s6,s6,-422 # ffffffffc02051b0 <etext+0x230>
        argv[argc ++] = buf;
ffffffffc020035e:	00005a17          	auipc	s4,0x5
ffffffffc0200362:	d72a0a13          	addi	s4,s4,-654 # ffffffffc02050d0 <etext+0x150>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200366:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200368:	854a                	mv	a0,s2
ffffffffc020036a:	d29ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc020036e:	842a                	mv	s0,a0
ffffffffc0200370:	dd65                	beqz	a0,ffffffffc0200368 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200372:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200376:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200378:	e1bd                	bnez	a1,ffffffffc02003de <kmonitor+0xec>
    if (argc == 0) {
ffffffffc020037a:	fe0c87e3          	beqz	s9,ffffffffc0200368 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037e:	6582                	ld	a1,0(sp)
ffffffffc0200380:	00005d17          	auipc	s10,0x5
ffffffffc0200384:	e68d0d13          	addi	s10,s10,-408 # ffffffffc02051e8 <commands>
        argv[argc ++] = buf;
ffffffffc0200388:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038a:	4401                	li	s0,0
ffffffffc020038c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038e:	371040ef          	jal	ra,ffffffffc0204efe <strcmp>
ffffffffc0200392:	c919                	beqz	a0,ffffffffc02003a8 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200394:	2405                	addiw	s0,s0,1
ffffffffc0200396:	0b540063          	beq	s0,s5,ffffffffc0200436 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039a:	000d3503          	ld	a0,0(s10)
ffffffffc020039e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a2:	35d040ef          	jal	ra,ffffffffc0204efe <strcmp>
ffffffffc02003a6:	f57d                	bnez	a0,ffffffffc0200394 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003a8:	00141793          	slli	a5,s0,0x1
ffffffffc02003ac:	97a2                	add	a5,a5,s0
ffffffffc02003ae:	078e                	slli	a5,a5,0x3
ffffffffc02003b0:	97e2                	add	a5,a5,s8
ffffffffc02003b2:	6b9c                	ld	a5,16(a5)
ffffffffc02003b4:	865e                	mv	a2,s7
ffffffffc02003b6:	002c                	addi	a1,sp,8
ffffffffc02003b8:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003bc:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003be:	fa0555e3          	bgez	a0,ffffffffc0200368 <kmonitor+0x76>
}
ffffffffc02003c2:	60ee                	ld	ra,216(sp)
ffffffffc02003c4:	644e                	ld	s0,208(sp)
ffffffffc02003c6:	64ae                	ld	s1,200(sp)
ffffffffc02003c8:	690e                	ld	s2,192(sp)
ffffffffc02003ca:	79ea                	ld	s3,184(sp)
ffffffffc02003cc:	7a4a                	ld	s4,176(sp)
ffffffffc02003ce:	7aaa                	ld	s5,168(sp)
ffffffffc02003d0:	7b0a                	ld	s6,160(sp)
ffffffffc02003d2:	6bea                	ld	s7,152(sp)
ffffffffc02003d4:	6c4a                	ld	s8,144(sp)
ffffffffc02003d6:	6caa                	ld	s9,136(sp)
ffffffffc02003d8:	6d0a                	ld	s10,128(sp)
ffffffffc02003da:	612d                	addi	sp,sp,224
ffffffffc02003dc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	33d040ef          	jal	ra,ffffffffc0204f1c <strchr>
ffffffffc02003e4:	c901                	beqz	a0,ffffffffc02003f4 <kmonitor+0x102>
ffffffffc02003e6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ea:	00040023          	sb	zero,0(s0)
ffffffffc02003ee:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f0:	d5c9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc02003f2:	b7f5                	j	ffffffffc02003de <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc02003f4:	00044783          	lbu	a5,0(s0)
ffffffffc02003f8:	d3c9                	beqz	a5,ffffffffc020037a <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc02003fa:	033c8963          	beq	s9,s3,ffffffffc020042c <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc02003fe:	003c9793          	slli	a5,s9,0x3
ffffffffc0200402:	0118                	addi	a4,sp,128
ffffffffc0200404:	97ba                	add	a5,a5,a4
ffffffffc0200406:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020040a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020040e:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200410:	e591                	bnez	a1,ffffffffc020041c <kmonitor+0x12a>
ffffffffc0200412:	b7b5                	j	ffffffffc020037e <kmonitor+0x8c>
ffffffffc0200414:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200418:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041a:	d1a5                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020041c:	8526                	mv	a0,s1
ffffffffc020041e:	2ff040ef          	jal	ra,ffffffffc0204f1c <strchr>
ffffffffc0200422:	d96d                	beqz	a0,ffffffffc0200414 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	00044583          	lbu	a1,0(s0)
ffffffffc0200428:	d9a9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020042a:	bf55                	j	ffffffffc02003de <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020042c:	45c1                	li	a1,16
ffffffffc020042e:	855a                	mv	a0,s6
ffffffffc0200430:	d51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200434:	b7e9                	j	ffffffffc02003fe <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200436:	6582                	ld	a1,0(sp)
ffffffffc0200438:	00005517          	auipc	a0,0x5
ffffffffc020043c:	d9850513          	addi	a0,a0,-616 # ffffffffc02051d0 <etext+0x250>
ffffffffc0200440:	d41ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200444:	b715                	j	ffffffffc0200368 <kmonitor+0x76>

ffffffffc0200446 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200446:	00016317          	auipc	t1,0x16
ffffffffc020044a:	0f230313          	addi	t1,t1,242 # ffffffffc0216538 <is_panic>
ffffffffc020044e:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	e822                	sd	s0,16(sp)
ffffffffc0200458:	f436                	sd	a3,40(sp)
ffffffffc020045a:	f83a                	sd	a4,48(sp)
ffffffffc020045c:	fc3e                	sd	a5,56(sp)
ffffffffc020045e:	e0c2                	sd	a6,64(sp)
ffffffffc0200460:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200462:	020e1a63          	bnez	t3,ffffffffc0200496 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200466:	4785                	li	a5,1
ffffffffc0200468:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020046c:	8432                	mv	s0,a2
ffffffffc020046e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200470:	862e                	mv	a2,a1
ffffffffc0200472:	85aa                	mv	a1,a0
ffffffffc0200474:	00005517          	auipc	a0,0x5
ffffffffc0200478:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205230 <commands+0x48>
    va_start(ap, fmt);
ffffffffc020047c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047e:	d03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cdbff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc020048a:	00006517          	auipc	a0,0x6
ffffffffc020048e:	d1650513          	addi	a0,a0,-746 # ffffffffc02061a0 <default_pmm_manager+0x4d0>
ffffffffc0200492:	cefff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200496:	12c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020049a:	4501                	li	a0,0
ffffffffc020049c:	e57ff0ef          	jal	ra,ffffffffc02002f2 <kmonitor>
    while (1) {
ffffffffc02004a0:	bfed                	j	ffffffffc020049a <__panic+0x54>

ffffffffc02004a2 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004a2:	67e1                	lui	a5,0x18
ffffffffc02004a4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a8:	00016717          	auipc	a4,0x16
ffffffffc02004ac:	0af73023          	sd	a5,160(a4) # ffffffffc0216548 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004b0:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004b4:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004b6:	953e                	add	a0,a0,a5
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4881                	li	a7,0
ffffffffc02004bc:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004c0:	02000793          	li	a5,32
ffffffffc02004c4:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004c8:	00005517          	auipc	a0,0x5
ffffffffc02004cc:	d8850513          	addi	a0,a0,-632 # ffffffffc0205250 <commands+0x68>
    ticks = 0;
ffffffffc02004d0:	00016797          	auipc	a5,0x16
ffffffffc02004d4:	0607b823          	sd	zero,112(a5) # ffffffffc0216540 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d8:	b165                	j	ffffffffc0200180 <cprintf>

ffffffffc02004da <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004da:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004de:	00016797          	auipc	a5,0x16
ffffffffc02004e2:	06a7b783          	ld	a5,106(a5) # ffffffffc0216548 <timebase>
ffffffffc02004e6:	953e                	add	a0,a0,a5
ffffffffc02004e8:	4581                	li	a1,0
ffffffffc02004ea:	4601                	li	a2,0
ffffffffc02004ec:	4881                	li	a7,0
ffffffffc02004ee:	00000073          	ecall
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004f4:	8082                	ret

ffffffffc02004f6 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004f6:	100027f3          	csrr	a5,sstatus
ffffffffc02004fa:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02004fc:	0ff57513          	zext.b	a0,a0
ffffffffc0200500:	e799                	bnez	a5,ffffffffc020050e <cons_putc+0x18>
ffffffffc0200502:	4581                	li	a1,0
ffffffffc0200504:	4601                	li	a2,0
ffffffffc0200506:	4885                	li	a7,1
ffffffffc0200508:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020050c:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020050e:	1101                	addi	sp,sp,-32
ffffffffc0200510:	ec06                	sd	ra,24(sp)
ffffffffc0200512:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200514:	0ae000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0200518:	6522                	ld	a0,8(sp)
ffffffffc020051a:	4581                	li	a1,0
ffffffffc020051c:	4601                	li	a2,0
ffffffffc020051e:	4885                	li	a7,1
ffffffffc0200520:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200524:	60e2                	ld	ra,24(sp)
ffffffffc0200526:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200528:	a851                	j	ffffffffc02005bc <intr_enable>

ffffffffc020052a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020052a:	100027f3          	csrr	a5,sstatus
ffffffffc020052e:	8b89                	andi	a5,a5,2
ffffffffc0200530:	eb89                	bnez	a5,ffffffffc0200542 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200532:	4501                	li	a0,0
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4889                	li	a7,2
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200540:	8082                	ret
int cons_getc(void) {
ffffffffc0200542:	1101                	addi	sp,sp,-32
ffffffffc0200544:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200546:	07c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc020054a:	4501                	li	a0,0
ffffffffc020054c:	4581                	li	a1,0
ffffffffc020054e:	4601                	li	a2,0
ffffffffc0200550:	4889                	li	a7,2
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	2501                	sext.w	a0,a0
ffffffffc0200558:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020055a:	062000ef          	jal	ra,ffffffffc02005bc <intr_enable>
}
ffffffffc020055e:	60e2                	ld	ra,24(sp)
ffffffffc0200560:	6522                	ld	a0,8(sp)
ffffffffc0200562:	6105                	addi	sp,sp,32
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200566:	8082                	ret

ffffffffc0200568 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200568:	00253513          	sltiu	a0,a0,2
ffffffffc020056c:	8082                	ret

ffffffffc020056e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020056e:	03800513          	li	a0,56
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200574:	0000b797          	auipc	a5,0xb
ffffffffc0200578:	eec78793          	addi	a5,a5,-276 # ffffffffc020b460 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020057c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200580:	1141                	addi	sp,sp,-16
ffffffffc0200582:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200584:	95be                	add	a1,a1,a5
ffffffffc0200586:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020058a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020058c:	1b9040ef          	jal	ra,ffffffffc0204f44 <memcpy>
    return 0;
}
ffffffffc0200590:	60a2                	ld	ra,8(sp)
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	0141                	addi	sp,sp,16
ffffffffc0200596:	8082                	ret

ffffffffc0200598 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200598:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020059c:	0000b517          	auipc	a0,0xb
ffffffffc02005a0:	ec450513          	addi	a0,a0,-316 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02005a4:	1141                	addi	sp,sp,-16
ffffffffc02005a6:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a8:	953e                	add	a0,a0,a5
ffffffffc02005aa:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02005ae:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005b0:	195040ef          	jal	ra,ffffffffc0204f44 <memcpy>
    return 0;
}
ffffffffc02005b4:	60a2                	ld	ra,8(sp)
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	0141                	addi	sp,sp,16
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005bc:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005c0:	8082                	ret

ffffffffc02005c2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005c2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005c6:	8082                	ret

ffffffffc02005c8 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
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
ffffffffc02005fe:	c7650513          	addi	a0,a0,-906 # ffffffffc0205270 <commands+0x88>
ffffffffc0200602:	b7fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00016517          	auipc	a0,0x16
ffffffffc020060a:	f9a53503          	ld	a0,-102(a0) # ffffffffc02165a0 <check_mm_struct>
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
ffffffffc020061e:	2ef0306f          	j	ffffffffc020410c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00005617          	auipc	a2,0x5
ffffffffc0200626:	c6e60613          	addi	a2,a2,-914 # ffffffffc0205290 <commands+0xa8>
ffffffffc020062a:	06200593          	li	a1,98
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	c7a50513          	addi	a0,a0,-902 # ffffffffc02052a8 <commands+0xc0>
ffffffffc0200636:	e11ff0ef          	jal	ra,ffffffffc0200446 <__panic>

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
ffffffffc0200660:	c6450513          	addi	a0,a0,-924 # ffffffffc02052c0 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	b1bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	c6c50513          	addi	a0,a0,-916 # ffffffffc02052d8 <commands+0xf0>
ffffffffc0200674:	b0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00005517          	auipc	a0,0x5
ffffffffc020067e:	c7650513          	addi	a0,a0,-906 # ffffffffc02052f0 <commands+0x108>
ffffffffc0200682:	affff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00005517          	auipc	a0,0x5
ffffffffc020068c:	c8050513          	addi	a0,a0,-896 # ffffffffc0205308 <commands+0x120>
ffffffffc0200690:	af1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00005517          	auipc	a0,0x5
ffffffffc020069a:	c8a50513          	addi	a0,a0,-886 # ffffffffc0205320 <commands+0x138>
ffffffffc020069e:	ae3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00005517          	auipc	a0,0x5
ffffffffc02006a8:	c9450513          	addi	a0,a0,-876 # ffffffffc0205338 <commands+0x150>
ffffffffc02006ac:	ad5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00005517          	auipc	a0,0x5
ffffffffc02006b6:	c9e50513          	addi	a0,a0,-866 # ffffffffc0205350 <commands+0x168>
ffffffffc02006ba:	ac7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00005517          	auipc	a0,0x5
ffffffffc02006c4:	ca850513          	addi	a0,a0,-856 # ffffffffc0205368 <commands+0x180>
ffffffffc02006c8:	ab9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00005517          	auipc	a0,0x5
ffffffffc02006d2:	cb250513          	addi	a0,a0,-846 # ffffffffc0205380 <commands+0x198>
ffffffffc02006d6:	aabff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00005517          	auipc	a0,0x5
ffffffffc02006e0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0205398 <commands+0x1b0>
ffffffffc02006e4:	a9dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00005517          	auipc	a0,0x5
ffffffffc02006ee:	cc650513          	addi	a0,a0,-826 # ffffffffc02053b0 <commands+0x1c8>
ffffffffc02006f2:	a8fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	cd050513          	addi	a0,a0,-816 # ffffffffc02053c8 <commands+0x1e0>
ffffffffc0200700:	a81ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00005517          	auipc	a0,0x5
ffffffffc020070a:	cda50513          	addi	a0,a0,-806 # ffffffffc02053e0 <commands+0x1f8>
ffffffffc020070e:	a73ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00005517          	auipc	a0,0x5
ffffffffc0200718:	ce450513          	addi	a0,a0,-796 # ffffffffc02053f8 <commands+0x210>
ffffffffc020071c:	a65ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00005517          	auipc	a0,0x5
ffffffffc0200726:	cee50513          	addi	a0,a0,-786 # ffffffffc0205410 <commands+0x228>
ffffffffc020072a:	a57ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	cf850513          	addi	a0,a0,-776 # ffffffffc0205428 <commands+0x240>
ffffffffc0200738:	a49ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00005517          	auipc	a0,0x5
ffffffffc0200742:	d0250513          	addi	a0,a0,-766 # ffffffffc0205440 <commands+0x258>
ffffffffc0200746:	a3bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00005517          	auipc	a0,0x5
ffffffffc0200750:	d0c50513          	addi	a0,a0,-756 # ffffffffc0205458 <commands+0x270>
ffffffffc0200754:	a2dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00005517          	auipc	a0,0x5
ffffffffc020075e:	d1650513          	addi	a0,a0,-746 # ffffffffc0205470 <commands+0x288>
ffffffffc0200762:	a1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00005517          	auipc	a0,0x5
ffffffffc020076c:	d2050513          	addi	a0,a0,-736 # ffffffffc0205488 <commands+0x2a0>
ffffffffc0200770:	a11ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	d2a50513          	addi	a0,a0,-726 # ffffffffc02054a0 <commands+0x2b8>
ffffffffc020077e:	a03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00005517          	auipc	a0,0x5
ffffffffc0200788:	d3450513          	addi	a0,a0,-716 # ffffffffc02054b8 <commands+0x2d0>
ffffffffc020078c:	9f5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00005517          	auipc	a0,0x5
ffffffffc0200796:	d3e50513          	addi	a0,a0,-706 # ffffffffc02054d0 <commands+0x2e8>
ffffffffc020079a:	9e7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00005517          	auipc	a0,0x5
ffffffffc02007a4:	d4850513          	addi	a0,a0,-696 # ffffffffc02054e8 <commands+0x300>
ffffffffc02007a8:	9d9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00005517          	auipc	a0,0x5
ffffffffc02007b2:	d5250513          	addi	a0,a0,-686 # ffffffffc0205500 <commands+0x318>
ffffffffc02007b6:	9cbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	d5c50513          	addi	a0,a0,-676 # ffffffffc0205518 <commands+0x330>
ffffffffc02007c4:	9bdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00005517          	auipc	a0,0x5
ffffffffc02007ce:	d6650513          	addi	a0,a0,-666 # ffffffffc0205530 <commands+0x348>
ffffffffc02007d2:	9afff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00005517          	auipc	a0,0x5
ffffffffc02007dc:	d7050513          	addi	a0,a0,-656 # ffffffffc0205548 <commands+0x360>
ffffffffc02007e0:	9a1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00005517          	auipc	a0,0x5
ffffffffc02007ea:	d7a50513          	addi	a0,a0,-646 # ffffffffc0205560 <commands+0x378>
ffffffffc02007ee:	993ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00005517          	auipc	a0,0x5
ffffffffc02007f8:	d8450513          	addi	a0,a0,-636 # ffffffffc0205578 <commands+0x390>
ffffffffc02007fc:	985ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00005517          	auipc	a0,0x5
ffffffffc0200806:	d8e50513          	addi	a0,a0,-626 # ffffffffc0205590 <commands+0x3a8>
ffffffffc020080a:	977ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00005517          	auipc	a0,0x5
ffffffffc0200818:	d9450513          	addi	a0,a0,-620 # ffffffffc02055a8 <commands+0x3c0>
}
ffffffffc020081c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	b28d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200820 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200820:	1141                	addi	sp,sp,-16
ffffffffc0200822:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200828:	00005517          	auipc	a0,0x5
ffffffffc020082c:	d9850513          	addi	a0,a0,-616 # ffffffffc02055c0 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200832:	94fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200836:	8522                	mv	a0,s0
ffffffffc0200838:	e1dff0ef          	jal	ra,ffffffffc0200654 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083c:	10043583          	ld	a1,256(s0)
ffffffffc0200840:	00005517          	auipc	a0,0x5
ffffffffc0200844:	d9850513          	addi	a0,a0,-616 # ffffffffc02055d8 <commands+0x3f0>
ffffffffc0200848:	939ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084c:	10843583          	ld	a1,264(s0)
ffffffffc0200850:	00005517          	auipc	a0,0x5
ffffffffc0200854:	da050513          	addi	a0,a0,-608 # ffffffffc02055f0 <commands+0x408>
ffffffffc0200858:	929ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085c:	11043583          	ld	a1,272(s0)
ffffffffc0200860:	00005517          	auipc	a0,0x5
ffffffffc0200864:	da850513          	addi	a0,a0,-600 # ffffffffc0205608 <commands+0x420>
ffffffffc0200868:	919ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200870:	6402                	ld	s0,0(sp)
ffffffffc0200872:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200874:	00005517          	auipc	a0,0x5
ffffffffc0200878:	dac50513          	addi	a0,a0,-596 # ffffffffc0205620 <commands+0x438>
}
ffffffffc020087c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087e:	903ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200882 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200882:	11853783          	ld	a5,280(a0)
ffffffffc0200886:	472d                	li	a4,11
ffffffffc0200888:	0786                	slli	a5,a5,0x1
ffffffffc020088a:	8385                	srli	a5,a5,0x1
ffffffffc020088c:	06f76c63          	bltu	a4,a5,ffffffffc0200904 <interrupt_handler+0x82>
ffffffffc0200890:	00005717          	auipc	a4,0x5
ffffffffc0200894:	e5870713          	addi	a4,a4,-424 # ffffffffc02056e8 <commands+0x500>
ffffffffc0200898:	078a                	slli	a5,a5,0x2
ffffffffc020089a:	97ba                	add	a5,a5,a4
ffffffffc020089c:	439c                	lw	a5,0(a5)
ffffffffc020089e:	97ba                	add	a5,a5,a4
ffffffffc02008a0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008a2:	00005517          	auipc	a0,0x5
ffffffffc02008a6:	df650513          	addi	a0,a0,-522 # ffffffffc0205698 <commands+0x4b0>
ffffffffc02008aa:	8d7ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ae:	00005517          	auipc	a0,0x5
ffffffffc02008b2:	dca50513          	addi	a0,a0,-566 # ffffffffc0205678 <commands+0x490>
ffffffffc02008b6:	8cbff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008ba:	00005517          	auipc	a0,0x5
ffffffffc02008be:	d7e50513          	addi	a0,a0,-642 # ffffffffc0205638 <commands+0x450>
ffffffffc02008c2:	8bfff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c6:	00005517          	auipc	a0,0x5
ffffffffc02008ca:	d9250513          	addi	a0,a0,-622 # ffffffffc0205658 <commands+0x470>
ffffffffc02008ce:	8b3ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d2:	1141                	addi	sp,sp,-16
ffffffffc02008d4:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d6:	c05ff0ef          	jal	ra,ffffffffc02004da <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008da:	00016697          	auipc	a3,0x16
ffffffffc02008de:	c6668693          	addi	a3,a3,-922 # ffffffffc0216540 <ticks>
ffffffffc02008e2:	629c                	ld	a5,0(a3)
ffffffffc02008e4:	06400713          	li	a4,100
ffffffffc02008e8:	0785                	addi	a5,a5,1
ffffffffc02008ea:	02e7f733          	remu	a4,a5,a4
ffffffffc02008ee:	e29c                	sd	a5,0(a3)
ffffffffc02008f0:	cb19                	beqz	a4,ffffffffc0200906 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008f2:	60a2                	ld	ra,8(sp)
ffffffffc02008f4:	0141                	addi	sp,sp,16
ffffffffc02008f6:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008f8:	00005517          	auipc	a0,0x5
ffffffffc02008fc:	dd050513          	addi	a0,a0,-560 # ffffffffc02056c8 <commands+0x4e0>
ffffffffc0200900:	881ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200904:	bf31                	j	ffffffffc0200820 <print_trapframe>
}
ffffffffc0200906:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200908:	06400593          	li	a1,100
ffffffffc020090c:	00005517          	auipc	a0,0x5
ffffffffc0200910:	dac50513          	addi	a0,a0,-596 # ffffffffc02056b8 <commands+0x4d0>
}
ffffffffc0200914:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200916:	86bff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020091a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091a:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020091e:	1101                	addi	sp,sp,-32
ffffffffc0200920:	e822                	sd	s0,16(sp)
ffffffffc0200922:	ec06                	sd	ra,24(sp)
ffffffffc0200924:	e426                	sd	s1,8(sp)
ffffffffc0200926:	473d                	li	a4,15
ffffffffc0200928:	842a                	mv	s0,a0
ffffffffc020092a:	14f76a63          	bltu	a4,a5,ffffffffc0200a7e <exception_handler+0x164>
ffffffffc020092e:	00005717          	auipc	a4,0x5
ffffffffc0200932:	fa270713          	addi	a4,a4,-94 # ffffffffc02058d0 <commands+0x6e8>
ffffffffc0200936:	078a                	slli	a5,a5,0x2
ffffffffc0200938:	97ba                	add	a5,a5,a4
ffffffffc020093a:	439c                	lw	a5,0(a5)
ffffffffc020093c:	97ba                	add	a5,a5,a4
ffffffffc020093e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200940:	00005517          	auipc	a0,0x5
ffffffffc0200944:	f7850513          	addi	a0,a0,-136 # ffffffffc02058b8 <commands+0x6d0>
ffffffffc0200948:	839ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094c:	8522                	mv	a0,s0
ffffffffc020094e:	c7dff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200952:	84aa                	mv	s1,a0
ffffffffc0200954:	12051b63          	bnez	a0,ffffffffc0200a8a <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200958:	60e2                	ld	ra,24(sp)
ffffffffc020095a:	6442                	ld	s0,16(sp)
ffffffffc020095c:	64a2                	ld	s1,8(sp)
ffffffffc020095e:	6105                	addi	sp,sp,32
ffffffffc0200960:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	db650513          	addi	a0,a0,-586 # ffffffffc0205718 <commands+0x530>
}
ffffffffc020096a:	6442                	ld	s0,16(sp)
ffffffffc020096c:	60e2                	ld	ra,24(sp)
ffffffffc020096e:	64a2                	ld	s1,8(sp)
ffffffffc0200970:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200972:	80fff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc0200976:	00005517          	auipc	a0,0x5
ffffffffc020097a:	dc250513          	addi	a0,a0,-574 # ffffffffc0205738 <commands+0x550>
ffffffffc020097e:	b7f5                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	dd850513          	addi	a0,a0,-552 # ffffffffc0205758 <commands+0x570>
ffffffffc0200988:	b7cd                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098a:	00005517          	auipc	a0,0x5
ffffffffc020098e:	de650513          	addi	a0,a0,-538 # ffffffffc0205770 <commands+0x588>
ffffffffc0200992:	bfe1                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200994:	00005517          	auipc	a0,0x5
ffffffffc0200998:	dec50513          	addi	a0,a0,-532 # ffffffffc0205780 <commands+0x598>
ffffffffc020099c:	b7f9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020099e:	00005517          	auipc	a0,0x5
ffffffffc02009a2:	e0250513          	addi	a0,a0,-510 # ffffffffc02057a0 <commands+0x5b8>
ffffffffc02009a6:	fdaff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009aa:	8522                	mv	a0,s0
ffffffffc02009ac:	c1fff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009b0:	84aa                	mv	s1,a0
ffffffffc02009b2:	d15d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	e6bff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00005617          	auipc	a2,0x5
ffffffffc02009c0:	dfc60613          	addi	a2,a2,-516 # ffffffffc02057b8 <commands+0x5d0>
ffffffffc02009c4:	0b300593          	li	a1,179
ffffffffc02009c8:	00005517          	auipc	a0,0x5
ffffffffc02009cc:	8e050513          	addi	a0,a0,-1824 # ffffffffc02052a8 <commands+0xc0>
ffffffffc02009d0:	a77ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d4:	00005517          	auipc	a0,0x5
ffffffffc02009d8:	e0450513          	addi	a0,a0,-508 # ffffffffc02057d8 <commands+0x5f0>
ffffffffc02009dc:	b779                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	e1250513          	addi	a0,a0,-494 # ffffffffc02057f0 <commands+0x608>
ffffffffc02009e6:	f9aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ea:	8522                	mv	a0,s0
ffffffffc02009ec:	bdfff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009f0:	84aa                	mv	s1,a0
ffffffffc02009f2:	d13d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	e2bff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00005617          	auipc	a2,0x5
ffffffffc0200a00:	dbc60613          	addi	a2,a2,-580 # ffffffffc02057b8 <commands+0x5d0>
ffffffffc0200a04:	0bd00593          	li	a1,189
ffffffffc0200a08:	00005517          	auipc	a0,0x5
ffffffffc0200a0c:	8a050513          	addi	a0,a0,-1888 # ffffffffc02052a8 <commands+0xc0>
ffffffffc0200a10:	a37ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a14:	00005517          	auipc	a0,0x5
ffffffffc0200a18:	df450513          	addi	a0,a0,-524 # ffffffffc0205808 <commands+0x620>
ffffffffc0200a1c:	b7b9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	e0a50513          	addi	a0,a0,-502 # ffffffffc0205828 <commands+0x640>
ffffffffc0200a26:	b791                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a28:	00005517          	auipc	a0,0x5
ffffffffc0200a2c:	e2050513          	addi	a0,a0,-480 # ffffffffc0205848 <commands+0x660>
ffffffffc0200a30:	bf2d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a32:	00005517          	auipc	a0,0x5
ffffffffc0200a36:	e3650513          	addi	a0,a0,-458 # ffffffffc0205868 <commands+0x680>
ffffffffc0200a3a:	bf05                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3c:	00005517          	auipc	a0,0x5
ffffffffc0200a40:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205888 <commands+0x6a0>
ffffffffc0200a44:	b71d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a46:	00005517          	auipc	a0,0x5
ffffffffc0200a4a:	e5a50513          	addi	a0,a0,-422 # ffffffffc02058a0 <commands+0x6b8>
ffffffffc0200a4e:	f32ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a52:	8522                	mv	a0,s0
ffffffffc0200a54:	b77ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a58:	84aa                	mv	s1,a0
ffffffffc0200a5a:	ee050fe3          	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a5e:	8522                	mv	a0,s0
ffffffffc0200a60:	dc1ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a64:	86a6                	mv	a3,s1
ffffffffc0200a66:	00005617          	auipc	a2,0x5
ffffffffc0200a6a:	d5260613          	addi	a2,a2,-686 # ffffffffc02057b8 <commands+0x5d0>
ffffffffc0200a6e:	0d300593          	li	a1,211
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	83650513          	addi	a0,a0,-1994 # ffffffffc02052a8 <commands+0xc0>
ffffffffc0200a7a:	9cdff0ef          	jal	ra,ffffffffc0200446 <__panic>
            print_trapframe(tf);
ffffffffc0200a7e:	8522                	mv	a0,s0
}
ffffffffc0200a80:	6442                	ld	s0,16(sp)
ffffffffc0200a82:	60e2                	ld	ra,24(sp)
ffffffffc0200a84:	64a2                	ld	s1,8(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a88:	bb61                	j	ffffffffc0200820 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8a:	8522                	mv	a0,s0
ffffffffc0200a8c:	d95ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a90:	86a6                	mv	a3,s1
ffffffffc0200a92:	00005617          	auipc	a2,0x5
ffffffffc0200a96:	d2660613          	addi	a2,a2,-730 # ffffffffc02057b8 <commands+0x5d0>
ffffffffc0200a9a:	0da00593          	li	a1,218
ffffffffc0200a9e:	00005517          	auipc	a0,0x5
ffffffffc0200aa2:	80a50513          	addi	a0,a0,-2038 # ffffffffc02052a8 <commands+0xc0>
ffffffffc0200aa6:	9a1ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200aaa <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aaa:	11853783          	ld	a5,280(a0)
ffffffffc0200aae:	0007c363          	bltz	a5,ffffffffc0200ab4 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab2:	b5a5                	j	ffffffffc020091a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ab4:	b3f9                	j	ffffffffc0200882 <interrupt_handler>
	...

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
ffffffffc0200b1a:	f91ff0ef          	jal	ra,ffffffffc0200aaa <trap>

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

ffffffffc0200b72 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b72:	00012797          	auipc	a5,0x12
ffffffffc0200b76:	8ee78793          	addi	a5,a5,-1810 # ffffffffc0212460 <free_area>
ffffffffc0200b7a:	e79c                	sd	a5,8(a5)
ffffffffc0200b7c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b7e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b82:	8082                	ret

ffffffffc0200b84 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b84:	00012517          	auipc	a0,0x12
ffffffffc0200b88:	8ec56503          	lwu	a0,-1812(a0) # ffffffffc0212470 <free_area+0x10>
ffffffffc0200b8c:	8082                	ret

ffffffffc0200b8e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b8e:	715d                	addi	sp,sp,-80
ffffffffc0200b90:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b92:	00012417          	auipc	s0,0x12
ffffffffc0200b96:	8ce40413          	addi	s0,s0,-1842 # ffffffffc0212460 <free_area>
ffffffffc0200b9a:	641c                	ld	a5,8(s0)
ffffffffc0200b9c:	e486                	sd	ra,72(sp)
ffffffffc0200b9e:	fc26                	sd	s1,56(sp)
ffffffffc0200ba0:	f84a                	sd	s2,48(sp)
ffffffffc0200ba2:	f44e                	sd	s3,40(sp)
ffffffffc0200ba4:	f052                	sd	s4,32(sp)
ffffffffc0200ba6:	ec56                	sd	s5,24(sp)
ffffffffc0200ba8:	e85a                	sd	s6,16(sp)
ffffffffc0200baa:	e45e                	sd	s7,8(sp)
ffffffffc0200bac:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bae:	2c878763          	beq	a5,s0,ffffffffc0200e7c <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200bb2:	4481                	li	s1,0
ffffffffc0200bb4:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bb6:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bba:	8b09                	andi	a4,a4,2
ffffffffc0200bbc:	2c070463          	beqz	a4,ffffffffc0200e84 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200bc0:	ff07a703          	lw	a4,-16(a5)
ffffffffc0200bc4:	679c                	ld	a5,8(a5)
ffffffffc0200bc6:	2905                	addiw	s2,s2,1
ffffffffc0200bc8:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bca:	fe8796e3          	bne	a5,s0,ffffffffc0200bb6 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200bce:	89a6                	mv	s3,s1
ffffffffc0200bd0:	76b000ef          	jal	ra,ffffffffc0201b3a <nr_free_pages>
ffffffffc0200bd4:	71351863          	bne	a0,s3,ffffffffc02012e4 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bd8:	4505                	li	a0,1
ffffffffc0200bda:	68f000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200bde:	8a2a                	mv	s4,a0
ffffffffc0200be0:	44050263          	beqz	a0,ffffffffc0201024 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200be4:	4505                	li	a0,1
ffffffffc0200be6:	683000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200bea:	89aa                	mv	s3,a0
ffffffffc0200bec:	70050c63          	beqz	a0,ffffffffc0201304 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bf0:	4505                	li	a0,1
ffffffffc0200bf2:	677000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200bf6:	8aaa                	mv	s5,a0
ffffffffc0200bf8:	4a050663          	beqz	a0,ffffffffc02010a4 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bfc:	2b3a0463          	beq	s4,s3,ffffffffc0200ea4 <default_check+0x316>
ffffffffc0200c00:	2aaa0263          	beq	s4,a0,ffffffffc0200ea4 <default_check+0x316>
ffffffffc0200c04:	2aa98063          	beq	s3,a0,ffffffffc0200ea4 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c08:	000a2783          	lw	a5,0(s4)
ffffffffc0200c0c:	2a079c63          	bnez	a5,ffffffffc0200ec4 <default_check+0x336>
ffffffffc0200c10:	0009a783          	lw	a5,0(s3)
ffffffffc0200c14:	2a079863          	bnez	a5,ffffffffc0200ec4 <default_check+0x336>
ffffffffc0200c18:	411c                	lw	a5,0(a0)
ffffffffc0200c1a:	2a079563          	bnez	a5,ffffffffc0200ec4 <default_check+0x336>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c1e:	00016797          	auipc	a5,0x16
ffffffffc0200c22:	9527b783          	ld	a5,-1710(a5) # ffffffffc0216570 <pages>
ffffffffc0200c26:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c2a:	870d                	srai	a4,a4,0x3
ffffffffc0200c2c:	00006597          	auipc	a1,0x6
ffffffffc0200c30:	3dc5b583          	ld	a1,988(a1) # ffffffffc0207008 <error_string+0x38>
ffffffffc0200c34:	02b70733          	mul	a4,a4,a1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	3d863603          	ld	a2,984(a2) # ffffffffc0207010 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c40:	00016697          	auipc	a3,0x16
ffffffffc0200c44:	9286b683          	ld	a3,-1752(a3) # ffffffffc0216568 <npage>
ffffffffc0200c48:	06b2                	slli	a3,a3,0xc
ffffffffc0200c4a:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c4c:	0732                	slli	a4,a4,0xc
ffffffffc0200c4e:	28d77b63          	bgeu	a4,a3,ffffffffc0200ee4 <default_check+0x356>
    return page - pages + nbase;
ffffffffc0200c52:	40f98733          	sub	a4,s3,a5
ffffffffc0200c56:	870d                	srai	a4,a4,0x3
ffffffffc0200c58:	02b70733          	mul	a4,a4,a1
ffffffffc0200c5c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c5e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c60:	4cd77263          	bgeu	a4,a3,ffffffffc0201124 <default_check+0x596>
    return page - pages + nbase;
ffffffffc0200c64:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c68:	878d                	srai	a5,a5,0x3
ffffffffc0200c6a:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c6e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c70:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c72:	30d7f963          	bgeu	a5,a3,ffffffffc0200f84 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200c76:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c78:	00043c03          	ld	s8,0(s0)
ffffffffc0200c7c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c80:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c84:	e400                	sd	s0,8(s0)
ffffffffc0200c86:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200c88:	00011797          	auipc	a5,0x11
ffffffffc0200c8c:	7e07a423          	sw	zero,2024(a5) # ffffffffc0212470 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c90:	5d9000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200c94:	2c051863          	bnez	a0,ffffffffc0200f64 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200c98:	4585                	li	a1,1
ffffffffc0200c9a:	8552                	mv	a0,s4
ffffffffc0200c9c:	65f000ef          	jal	ra,ffffffffc0201afa <free_pages>
    free_page(p1);
ffffffffc0200ca0:	4585                	li	a1,1
ffffffffc0200ca2:	854e                	mv	a0,s3
ffffffffc0200ca4:	657000ef          	jal	ra,ffffffffc0201afa <free_pages>
    free_page(p2);
ffffffffc0200ca8:	4585                	li	a1,1
ffffffffc0200caa:	8556                	mv	a0,s5
ffffffffc0200cac:	64f000ef          	jal	ra,ffffffffc0201afa <free_pages>
    assert(nr_free == 3);
ffffffffc0200cb0:	4818                	lw	a4,16(s0)
ffffffffc0200cb2:	478d                	li	a5,3
ffffffffc0200cb4:	28f71863          	bne	a4,a5,ffffffffc0200f44 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cb8:	4505                	li	a0,1
ffffffffc0200cba:	5af000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200cbe:	89aa                	mv	s3,a0
ffffffffc0200cc0:	26050263          	beqz	a0,ffffffffc0200f24 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cc4:	4505                	li	a0,1
ffffffffc0200cc6:	5a3000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200cca:	8aaa                	mv	s5,a0
ffffffffc0200ccc:	3a050c63          	beqz	a0,ffffffffc0201084 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	597000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200cd6:	8a2a                	mv	s4,a0
ffffffffc0200cd8:	38050663          	beqz	a0,ffffffffc0201064 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200cdc:	4505                	li	a0,1
ffffffffc0200cde:	58b000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200ce2:	36051163          	bnez	a0,ffffffffc0201044 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200ce6:	4585                	li	a1,1
ffffffffc0200ce8:	854e                	mv	a0,s3
ffffffffc0200cea:	611000ef          	jal	ra,ffffffffc0201afa <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200cee:	641c                	ld	a5,8(s0)
ffffffffc0200cf0:	20878a63          	beq	a5,s0,ffffffffc0200f04 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200cf4:	4505                	li	a0,1
ffffffffc0200cf6:	573000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200cfa:	30a99563          	bne	s3,a0,ffffffffc0201004 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200cfe:	4505                	li	a0,1
ffffffffc0200d00:	569000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200d04:	2e051063          	bnez	a0,ffffffffc0200fe4 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200d08:	481c                	lw	a5,16(s0)
ffffffffc0200d0a:	2a079d63          	bnez	a5,ffffffffc0200fc4 <default_check+0x436>
    free_page(p);
ffffffffc0200d0e:	854e                	mv	a0,s3
ffffffffc0200d10:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d12:	01843023          	sd	s8,0(s0)
ffffffffc0200d16:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200d1a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200d1e:	5dd000ef          	jal	ra,ffffffffc0201afa <free_pages>
    free_page(p1);
ffffffffc0200d22:	4585                	li	a1,1
ffffffffc0200d24:	8556                	mv	a0,s5
ffffffffc0200d26:	5d5000ef          	jal	ra,ffffffffc0201afa <free_pages>
    free_page(p2);
ffffffffc0200d2a:	4585                	li	a1,1
ffffffffc0200d2c:	8552                	mv	a0,s4
ffffffffc0200d2e:	5cd000ef          	jal	ra,ffffffffc0201afa <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d32:	4515                	li	a0,5
ffffffffc0200d34:	535000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200d38:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d3a:	26050563          	beqz	a0,ffffffffc0200fa4 <default_check+0x416>
ffffffffc0200d3e:	651c                	ld	a5,8(a0)
ffffffffc0200d40:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d42:	8b85                	andi	a5,a5,1
ffffffffc0200d44:	54079063          	bnez	a5,ffffffffc0201284 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d48:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d4a:	00043b03          	ld	s6,0(s0)
ffffffffc0200d4e:	00843a83          	ld	s5,8(s0)
ffffffffc0200d52:	e000                	sd	s0,0(s0)
ffffffffc0200d54:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200d56:	513000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200d5a:	50051563          	bnez	a0,ffffffffc0201264 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d5e:	09098a13          	addi	s4,s3,144
ffffffffc0200d62:	8552                	mv	a0,s4
ffffffffc0200d64:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d66:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200d6a:	00011797          	auipc	a5,0x11
ffffffffc0200d6e:	7007a323          	sw	zero,1798(a5) # ffffffffc0212470 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d72:	589000ef          	jal	ra,ffffffffc0201afa <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d76:	4511                	li	a0,4
ffffffffc0200d78:	4f1000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200d7c:	4c051463          	bnez	a0,ffffffffc0201244 <default_check+0x6b6>
ffffffffc0200d80:	0989b783          	ld	a5,152(s3)
ffffffffc0200d84:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d86:	8b85                	andi	a5,a5,1
ffffffffc0200d88:	48078e63          	beqz	a5,ffffffffc0201224 <default_check+0x696>
ffffffffc0200d8c:	0a09a703          	lw	a4,160(s3)
ffffffffc0200d90:	478d                	li	a5,3
ffffffffc0200d92:	48f71963          	bne	a4,a5,ffffffffc0201224 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d96:	450d                	li	a0,3
ffffffffc0200d98:	4d1000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200d9c:	8c2a                	mv	s8,a0
ffffffffc0200d9e:	46050363          	beqz	a0,ffffffffc0201204 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200da2:	4505                	li	a0,1
ffffffffc0200da4:	4c5000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200da8:	42051e63          	bnez	a0,ffffffffc02011e4 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200dac:	418a1c63          	bne	s4,s8,ffffffffc02011c4 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200db0:	4585                	li	a1,1
ffffffffc0200db2:	854e                	mv	a0,s3
ffffffffc0200db4:	547000ef          	jal	ra,ffffffffc0201afa <free_pages>
    free_pages(p1, 3);
ffffffffc0200db8:	458d                	li	a1,3
ffffffffc0200dba:	8552                	mv	a0,s4
ffffffffc0200dbc:	53f000ef          	jal	ra,ffffffffc0201afa <free_pages>
ffffffffc0200dc0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200dc4:	04898c13          	addi	s8,s3,72
ffffffffc0200dc8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dca:	8b85                	andi	a5,a5,1
ffffffffc0200dcc:	3c078c63          	beqz	a5,ffffffffc02011a4 <default_check+0x616>
ffffffffc0200dd0:	0109a703          	lw	a4,16(s3)
ffffffffc0200dd4:	4785                	li	a5,1
ffffffffc0200dd6:	3cf71763          	bne	a4,a5,ffffffffc02011a4 <default_check+0x616>
ffffffffc0200dda:	008a3783          	ld	a5,8(s4)
ffffffffc0200dde:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200de0:	8b85                	andi	a5,a5,1
ffffffffc0200de2:	3a078163          	beqz	a5,ffffffffc0201184 <default_check+0x5f6>
ffffffffc0200de6:	010a2703          	lw	a4,16(s4)
ffffffffc0200dea:	478d                	li	a5,3
ffffffffc0200dec:	38f71c63          	bne	a4,a5,ffffffffc0201184 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200df0:	4505                	li	a0,1
ffffffffc0200df2:	477000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200df6:	36a99763          	bne	s3,a0,ffffffffc0201164 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200dfa:	4585                	li	a1,1
ffffffffc0200dfc:	4ff000ef          	jal	ra,ffffffffc0201afa <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e00:	4509                	li	a0,2
ffffffffc0200e02:	467000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200e06:	32aa1f63          	bne	s4,a0,ffffffffc0201144 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200e0a:	4589                	li	a1,2
ffffffffc0200e0c:	4ef000ef          	jal	ra,ffffffffc0201afa <free_pages>
    free_page(p2);
ffffffffc0200e10:	4585                	li	a1,1
ffffffffc0200e12:	8562                	mv	a0,s8
ffffffffc0200e14:	4e7000ef          	jal	ra,ffffffffc0201afa <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e18:	4515                	li	a0,5
ffffffffc0200e1a:	44f000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200e1e:	89aa                	mv	s3,a0
ffffffffc0200e20:	48050263          	beqz	a0,ffffffffc02012a4 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200e24:	4505                	li	a0,1
ffffffffc0200e26:	443000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0200e2a:	2c051d63          	bnez	a0,ffffffffc0201104 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200e2e:	481c                	lw	a5,16(s0)
ffffffffc0200e30:	2a079a63          	bnez	a5,ffffffffc02010e4 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e34:	4595                	li	a1,5
ffffffffc0200e36:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e38:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200e3c:	01643023          	sd	s6,0(s0)
ffffffffc0200e40:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200e44:	4b7000ef          	jal	ra,ffffffffc0201afa <free_pages>
    return listelm->next;
ffffffffc0200e48:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e4a:	00878963          	beq	a5,s0,ffffffffc0200e5c <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e4e:	ff07a703          	lw	a4,-16(a5)
ffffffffc0200e52:	679c                	ld	a5,8(a5)
ffffffffc0200e54:	397d                	addiw	s2,s2,-1
ffffffffc0200e56:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e58:	fe879be3          	bne	a5,s0,ffffffffc0200e4e <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200e5c:	26091463          	bnez	s2,ffffffffc02010c4 <default_check+0x536>
    assert(total == 0);
ffffffffc0200e60:	46049263          	bnez	s1,ffffffffc02012c4 <default_check+0x736>
}
ffffffffc0200e64:	60a6                	ld	ra,72(sp)
ffffffffc0200e66:	6406                	ld	s0,64(sp)
ffffffffc0200e68:	74e2                	ld	s1,56(sp)
ffffffffc0200e6a:	7942                	ld	s2,48(sp)
ffffffffc0200e6c:	79a2                	ld	s3,40(sp)
ffffffffc0200e6e:	7a02                	ld	s4,32(sp)
ffffffffc0200e70:	6ae2                	ld	s5,24(sp)
ffffffffc0200e72:	6b42                	ld	s6,16(sp)
ffffffffc0200e74:	6ba2                	ld	s7,8(sp)
ffffffffc0200e76:	6c02                	ld	s8,0(sp)
ffffffffc0200e78:	6161                	addi	sp,sp,80
ffffffffc0200e7a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e7e:	4481                	li	s1,0
ffffffffc0200e80:	4901                	li	s2,0
ffffffffc0200e82:	b3b9                	j	ffffffffc0200bd0 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e84:	00005697          	auipc	a3,0x5
ffffffffc0200e88:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0205910 <commands+0x728>
ffffffffc0200e8c:	00005617          	auipc	a2,0x5
ffffffffc0200e90:	a9460613          	addi	a2,a2,-1388 # ffffffffc0205920 <commands+0x738>
ffffffffc0200e94:	0f000593          	li	a1,240
ffffffffc0200e98:	00005517          	auipc	a0,0x5
ffffffffc0200e9c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0205938 <commands+0x750>
ffffffffc0200ea0:	da6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ea4:	00005697          	auipc	a3,0x5
ffffffffc0200ea8:	b2c68693          	addi	a3,a3,-1236 # ffffffffc02059d0 <commands+0x7e8>
ffffffffc0200eac:	00005617          	auipc	a2,0x5
ffffffffc0200eb0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0205920 <commands+0x738>
ffffffffc0200eb4:	0bd00593          	li	a1,189
ffffffffc0200eb8:	00005517          	auipc	a0,0x5
ffffffffc0200ebc:	a8050513          	addi	a0,a0,-1408 # ffffffffc0205938 <commands+0x750>
ffffffffc0200ec0:	d86ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ec4:	00005697          	auipc	a3,0x5
ffffffffc0200ec8:	b3468693          	addi	a3,a3,-1228 # ffffffffc02059f8 <commands+0x810>
ffffffffc0200ecc:	00005617          	auipc	a2,0x5
ffffffffc0200ed0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0205920 <commands+0x738>
ffffffffc0200ed4:	0be00593          	li	a1,190
ffffffffc0200ed8:	00005517          	auipc	a0,0x5
ffffffffc0200edc:	a6050513          	addi	a0,a0,-1440 # ffffffffc0205938 <commands+0x750>
ffffffffc0200ee0:	d66ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ee4:	00005697          	auipc	a3,0x5
ffffffffc0200ee8:	b5468693          	addi	a3,a3,-1196 # ffffffffc0205a38 <commands+0x850>
ffffffffc0200eec:	00005617          	auipc	a2,0x5
ffffffffc0200ef0:	a3460613          	addi	a2,a2,-1484 # ffffffffc0205920 <commands+0x738>
ffffffffc0200ef4:	0c000593          	li	a1,192
ffffffffc0200ef8:	00005517          	auipc	a0,0x5
ffffffffc0200efc:	a4050513          	addi	a0,a0,-1472 # ffffffffc0205938 <commands+0x750>
ffffffffc0200f00:	d46ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f04:	00005697          	auipc	a3,0x5
ffffffffc0200f08:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0200f0c:	00005617          	auipc	a2,0x5
ffffffffc0200f10:	a1460613          	addi	a2,a2,-1516 # ffffffffc0205920 <commands+0x738>
ffffffffc0200f14:	0d900593          	li	a1,217
ffffffffc0200f18:	00005517          	auipc	a0,0x5
ffffffffc0200f1c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0205938 <commands+0x750>
ffffffffc0200f20:	d26ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f24:	00005697          	auipc	a3,0x5
ffffffffc0200f28:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0205970 <commands+0x788>
ffffffffc0200f2c:	00005617          	auipc	a2,0x5
ffffffffc0200f30:	9f460613          	addi	a2,a2,-1548 # ffffffffc0205920 <commands+0x738>
ffffffffc0200f34:	0d200593          	li	a1,210
ffffffffc0200f38:	00005517          	auipc	a0,0x5
ffffffffc0200f3c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0205938 <commands+0x750>
ffffffffc0200f40:	d06ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 3);
ffffffffc0200f44:	00005697          	auipc	a3,0x5
ffffffffc0200f48:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0205ab0 <commands+0x8c8>
ffffffffc0200f4c:	00005617          	auipc	a2,0x5
ffffffffc0200f50:	9d460613          	addi	a2,a2,-1580 # ffffffffc0205920 <commands+0x738>
ffffffffc0200f54:	0d000593          	li	a1,208
ffffffffc0200f58:	00005517          	auipc	a0,0x5
ffffffffc0200f5c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0205938 <commands+0x750>
ffffffffc0200f60:	ce6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f64:	00005697          	auipc	a3,0x5
ffffffffc0200f68:	b3468693          	addi	a3,a3,-1228 # ffffffffc0205a98 <commands+0x8b0>
ffffffffc0200f6c:	00005617          	auipc	a2,0x5
ffffffffc0200f70:	9b460613          	addi	a2,a2,-1612 # ffffffffc0205920 <commands+0x738>
ffffffffc0200f74:	0cb00593          	li	a1,203
ffffffffc0200f78:	00005517          	auipc	a0,0x5
ffffffffc0200f7c:	9c050513          	addi	a0,a0,-1600 # ffffffffc0205938 <commands+0x750>
ffffffffc0200f80:	cc6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f84:	00005697          	auipc	a3,0x5
ffffffffc0200f88:	af468693          	addi	a3,a3,-1292 # ffffffffc0205a78 <commands+0x890>
ffffffffc0200f8c:	00005617          	auipc	a2,0x5
ffffffffc0200f90:	99460613          	addi	a2,a2,-1644 # ffffffffc0205920 <commands+0x738>
ffffffffc0200f94:	0c200593          	li	a1,194
ffffffffc0200f98:	00005517          	auipc	a0,0x5
ffffffffc0200f9c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0205938 <commands+0x750>
ffffffffc0200fa0:	ca6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc0200fa4:	00005697          	auipc	a3,0x5
ffffffffc0200fa8:	b6468693          	addi	a3,a3,-1180 # ffffffffc0205b08 <commands+0x920>
ffffffffc0200fac:	00005617          	auipc	a2,0x5
ffffffffc0200fb0:	97460613          	addi	a2,a2,-1676 # ffffffffc0205920 <commands+0x738>
ffffffffc0200fb4:	0f800593          	li	a1,248
ffffffffc0200fb8:	00005517          	auipc	a0,0x5
ffffffffc0200fbc:	98050513          	addi	a0,a0,-1664 # ffffffffc0205938 <commands+0x750>
ffffffffc0200fc0:	c86ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc0200fc4:	00005697          	auipc	a3,0x5
ffffffffc0200fc8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0205af8 <commands+0x910>
ffffffffc0200fcc:	00005617          	auipc	a2,0x5
ffffffffc0200fd0:	95460613          	addi	a2,a2,-1708 # ffffffffc0205920 <commands+0x738>
ffffffffc0200fd4:	0df00593          	li	a1,223
ffffffffc0200fd8:	00005517          	auipc	a0,0x5
ffffffffc0200fdc:	96050513          	addi	a0,a0,-1696 # ffffffffc0205938 <commands+0x750>
ffffffffc0200fe0:	c66ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	00005697          	auipc	a3,0x5
ffffffffc0200fe8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0205a98 <commands+0x8b0>
ffffffffc0200fec:	00005617          	auipc	a2,0x5
ffffffffc0200ff0:	93460613          	addi	a2,a2,-1740 # ffffffffc0205920 <commands+0x738>
ffffffffc0200ff4:	0dd00593          	li	a1,221
ffffffffc0200ff8:	00005517          	auipc	a0,0x5
ffffffffc0200ffc:	94050513          	addi	a0,a0,-1728 # ffffffffc0205938 <commands+0x750>
ffffffffc0201000:	c46ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201004:	00005697          	auipc	a3,0x5
ffffffffc0201008:	ad468693          	addi	a3,a3,-1324 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020100c:	00005617          	auipc	a2,0x5
ffffffffc0201010:	91460613          	addi	a2,a2,-1772 # ffffffffc0205920 <commands+0x738>
ffffffffc0201014:	0dc00593          	li	a1,220
ffffffffc0201018:	00005517          	auipc	a0,0x5
ffffffffc020101c:	92050513          	addi	a0,a0,-1760 # ffffffffc0205938 <commands+0x750>
ffffffffc0201020:	c26ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201024:	00005697          	auipc	a3,0x5
ffffffffc0201028:	94c68693          	addi	a3,a3,-1716 # ffffffffc0205970 <commands+0x788>
ffffffffc020102c:	00005617          	auipc	a2,0x5
ffffffffc0201030:	8f460613          	addi	a2,a2,-1804 # ffffffffc0205920 <commands+0x738>
ffffffffc0201034:	0b900593          	li	a1,185
ffffffffc0201038:	00005517          	auipc	a0,0x5
ffffffffc020103c:	90050513          	addi	a0,a0,-1792 # ffffffffc0205938 <commands+0x750>
ffffffffc0201040:	c06ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201044:	00005697          	auipc	a3,0x5
ffffffffc0201048:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205a98 <commands+0x8b0>
ffffffffc020104c:	00005617          	auipc	a2,0x5
ffffffffc0201050:	8d460613          	addi	a2,a2,-1836 # ffffffffc0205920 <commands+0x738>
ffffffffc0201054:	0d600593          	li	a1,214
ffffffffc0201058:	00005517          	auipc	a0,0x5
ffffffffc020105c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205938 <commands+0x750>
ffffffffc0201060:	be6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201064:	00005697          	auipc	a3,0x5
ffffffffc0201068:	94c68693          	addi	a3,a3,-1716 # ffffffffc02059b0 <commands+0x7c8>
ffffffffc020106c:	00005617          	auipc	a2,0x5
ffffffffc0201070:	8b460613          	addi	a2,a2,-1868 # ffffffffc0205920 <commands+0x738>
ffffffffc0201074:	0d400593          	li	a1,212
ffffffffc0201078:	00005517          	auipc	a0,0x5
ffffffffc020107c:	8c050513          	addi	a0,a0,-1856 # ffffffffc0205938 <commands+0x750>
ffffffffc0201080:	bc6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201084:	00005697          	auipc	a3,0x5
ffffffffc0201088:	90c68693          	addi	a3,a3,-1780 # ffffffffc0205990 <commands+0x7a8>
ffffffffc020108c:	00005617          	auipc	a2,0x5
ffffffffc0201090:	89460613          	addi	a2,a2,-1900 # ffffffffc0205920 <commands+0x738>
ffffffffc0201094:	0d300593          	li	a1,211
ffffffffc0201098:	00005517          	auipc	a0,0x5
ffffffffc020109c:	8a050513          	addi	a0,a0,-1888 # ffffffffc0205938 <commands+0x750>
ffffffffc02010a0:	ba6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010a4:	00005697          	auipc	a3,0x5
ffffffffc02010a8:	90c68693          	addi	a3,a3,-1780 # ffffffffc02059b0 <commands+0x7c8>
ffffffffc02010ac:	00005617          	auipc	a2,0x5
ffffffffc02010b0:	87460613          	addi	a2,a2,-1932 # ffffffffc0205920 <commands+0x738>
ffffffffc02010b4:	0bb00593          	li	a1,187
ffffffffc02010b8:	00005517          	auipc	a0,0x5
ffffffffc02010bc:	88050513          	addi	a0,a0,-1920 # ffffffffc0205938 <commands+0x750>
ffffffffc02010c0:	b86ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(count == 0);
ffffffffc02010c4:	00005697          	auipc	a3,0x5
ffffffffc02010c8:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205c58 <commands+0xa70>
ffffffffc02010cc:	00005617          	auipc	a2,0x5
ffffffffc02010d0:	85460613          	addi	a2,a2,-1964 # ffffffffc0205920 <commands+0x738>
ffffffffc02010d4:	12500593          	li	a1,293
ffffffffc02010d8:	00005517          	auipc	a0,0x5
ffffffffc02010dc:	86050513          	addi	a0,a0,-1952 # ffffffffc0205938 <commands+0x750>
ffffffffc02010e0:	b66ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc02010e4:	00005697          	auipc	a3,0x5
ffffffffc02010e8:	a1468693          	addi	a3,a3,-1516 # ffffffffc0205af8 <commands+0x910>
ffffffffc02010ec:	00005617          	auipc	a2,0x5
ffffffffc02010f0:	83460613          	addi	a2,a2,-1996 # ffffffffc0205920 <commands+0x738>
ffffffffc02010f4:	11a00593          	li	a1,282
ffffffffc02010f8:	00005517          	auipc	a0,0x5
ffffffffc02010fc:	84050513          	addi	a0,a0,-1984 # ffffffffc0205938 <commands+0x750>
ffffffffc0201100:	b46ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201104:	00005697          	auipc	a3,0x5
ffffffffc0201108:	99468693          	addi	a3,a3,-1644 # ffffffffc0205a98 <commands+0x8b0>
ffffffffc020110c:	00005617          	auipc	a2,0x5
ffffffffc0201110:	81460613          	addi	a2,a2,-2028 # ffffffffc0205920 <commands+0x738>
ffffffffc0201114:	11800593          	li	a1,280
ffffffffc0201118:	00005517          	auipc	a0,0x5
ffffffffc020111c:	82050513          	addi	a0,a0,-2016 # ffffffffc0205938 <commands+0x750>
ffffffffc0201120:	b26ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201124:	00005697          	auipc	a3,0x5
ffffffffc0201128:	93468693          	addi	a3,a3,-1740 # ffffffffc0205a58 <commands+0x870>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	7f460613          	addi	a2,a2,2036 # ffffffffc0205920 <commands+0x738>
ffffffffc0201134:	0c100593          	li	a1,193
ffffffffc0201138:	00005517          	auipc	a0,0x5
ffffffffc020113c:	80050513          	addi	a0,a0,-2048 # ffffffffc0205938 <commands+0x750>
ffffffffc0201140:	b06ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201144:	00005697          	auipc	a3,0x5
ffffffffc0201148:	ad468693          	addi	a3,a3,-1324 # ffffffffc0205c18 <commands+0xa30>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	7d460613          	addi	a2,a2,2004 # ffffffffc0205920 <commands+0x738>
ffffffffc0201154:	11200593          	li	a1,274
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	7e050513          	addi	a0,a0,2016 # ffffffffc0205938 <commands+0x750>
ffffffffc0201160:	ae6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201164:	00005697          	auipc	a3,0x5
ffffffffc0201168:	a9468693          	addi	a3,a3,-1388 # ffffffffc0205bf8 <commands+0xa10>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	7b460613          	addi	a2,a2,1972 # ffffffffc0205920 <commands+0x738>
ffffffffc0201174:	11000593          	li	a1,272
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	7c050513          	addi	a0,a0,1984 # ffffffffc0205938 <commands+0x750>
ffffffffc0201180:	ac6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201184:	00005697          	auipc	a3,0x5
ffffffffc0201188:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0205bd0 <commands+0x9e8>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	79460613          	addi	a2,a2,1940 # ffffffffc0205920 <commands+0x738>
ffffffffc0201194:	10e00593          	li	a1,270
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	7a050513          	addi	a0,a0,1952 # ffffffffc0205938 <commands+0x750>
ffffffffc02011a0:	aa6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011a4:	00005697          	auipc	a3,0x5
ffffffffc02011a8:	a0468693          	addi	a3,a3,-1532 # ffffffffc0205ba8 <commands+0x9c0>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	77460613          	addi	a2,a2,1908 # ffffffffc0205920 <commands+0x738>
ffffffffc02011b4:	10d00593          	li	a1,269
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	78050513          	addi	a0,a0,1920 # ffffffffc0205938 <commands+0x750>
ffffffffc02011c0:	a86ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011c4:	00005697          	auipc	a3,0x5
ffffffffc02011c8:	9d468693          	addi	a3,a3,-1580 # ffffffffc0205b98 <commands+0x9b0>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	75460613          	addi	a2,a2,1876 # ffffffffc0205920 <commands+0x738>
ffffffffc02011d4:	10800593          	li	a1,264
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	76050513          	addi	a0,a0,1888 # ffffffffc0205938 <commands+0x750>
ffffffffc02011e0:	a66ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011e4:	00005697          	auipc	a3,0x5
ffffffffc02011e8:	8b468693          	addi	a3,a3,-1868 # ffffffffc0205a98 <commands+0x8b0>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	73460613          	addi	a2,a2,1844 # ffffffffc0205920 <commands+0x738>
ffffffffc02011f4:	10700593          	li	a1,263
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	74050513          	addi	a0,a0,1856 # ffffffffc0205938 <commands+0x750>
ffffffffc0201200:	a46ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201204:	00005697          	auipc	a3,0x5
ffffffffc0201208:	97468693          	addi	a3,a3,-1676 # ffffffffc0205b78 <commands+0x990>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	71460613          	addi	a2,a2,1812 # ffffffffc0205920 <commands+0x738>
ffffffffc0201214:	10600593          	li	a1,262
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	72050513          	addi	a0,a0,1824 # ffffffffc0205938 <commands+0x750>
ffffffffc0201220:	a26ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201224:	00005697          	auipc	a3,0x5
ffffffffc0201228:	92468693          	addi	a3,a3,-1756 # ffffffffc0205b48 <commands+0x960>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	6f460613          	addi	a2,a2,1780 # ffffffffc0205920 <commands+0x738>
ffffffffc0201234:	10500593          	li	a1,261
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	70050513          	addi	a0,a0,1792 # ffffffffc0205938 <commands+0x750>
ffffffffc0201240:	a06ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201244:	00005697          	auipc	a3,0x5
ffffffffc0201248:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0205b30 <commands+0x948>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	6d460613          	addi	a2,a2,1748 # ffffffffc0205920 <commands+0x738>
ffffffffc0201254:	10400593          	li	a1,260
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	6e050513          	addi	a0,a0,1760 # ffffffffc0205938 <commands+0x750>
ffffffffc0201260:	9e6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201264:	00005697          	auipc	a3,0x5
ffffffffc0201268:	83468693          	addi	a3,a3,-1996 # ffffffffc0205a98 <commands+0x8b0>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	6b460613          	addi	a2,a2,1716 # ffffffffc0205920 <commands+0x738>
ffffffffc0201274:	0fe00593          	li	a1,254
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	6c050513          	addi	a0,a0,1728 # ffffffffc0205938 <commands+0x750>
ffffffffc0201280:	9c6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201284:	00005697          	auipc	a3,0x5
ffffffffc0201288:	89468693          	addi	a3,a3,-1900 # ffffffffc0205b18 <commands+0x930>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	69460613          	addi	a2,a2,1684 # ffffffffc0205920 <commands+0x738>
ffffffffc0201294:	0f900593          	li	a1,249
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	6a050513          	addi	a0,a0,1696 # ffffffffc0205938 <commands+0x750>
ffffffffc02012a0:	9a6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012a4:	00005697          	auipc	a3,0x5
ffffffffc02012a8:	99468693          	addi	a3,a3,-1644 # ffffffffc0205c38 <commands+0xa50>
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	67460613          	addi	a2,a2,1652 # ffffffffc0205920 <commands+0x738>
ffffffffc02012b4:	11700593          	li	a1,279
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	68050513          	addi	a0,a0,1664 # ffffffffc0205938 <commands+0x750>
ffffffffc02012c0:	986ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == 0);
ffffffffc02012c4:	00005697          	auipc	a3,0x5
ffffffffc02012c8:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205c68 <commands+0xa80>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	65460613          	addi	a2,a2,1620 # ffffffffc0205920 <commands+0x738>
ffffffffc02012d4:	12600593          	li	a1,294
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	66050513          	addi	a0,a0,1632 # ffffffffc0205938 <commands+0x750>
ffffffffc02012e0:	966ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012e4:	00004697          	auipc	a3,0x4
ffffffffc02012e8:	66c68693          	addi	a3,a3,1644 # ffffffffc0205950 <commands+0x768>
ffffffffc02012ec:	00004617          	auipc	a2,0x4
ffffffffc02012f0:	63460613          	addi	a2,a2,1588 # ffffffffc0205920 <commands+0x738>
ffffffffc02012f4:	0f300593          	li	a1,243
ffffffffc02012f8:	00004517          	auipc	a0,0x4
ffffffffc02012fc:	64050513          	addi	a0,a0,1600 # ffffffffc0205938 <commands+0x750>
ffffffffc0201300:	946ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201304:	00004697          	auipc	a3,0x4
ffffffffc0201308:	68c68693          	addi	a3,a3,1676 # ffffffffc0205990 <commands+0x7a8>
ffffffffc020130c:	00004617          	auipc	a2,0x4
ffffffffc0201310:	61460613          	addi	a2,a2,1556 # ffffffffc0205920 <commands+0x738>
ffffffffc0201314:	0ba00593          	li	a1,186
ffffffffc0201318:	00004517          	auipc	a0,0x4
ffffffffc020131c:	62050513          	addi	a0,a0,1568 # ffffffffc0205938 <commands+0x750>
ffffffffc0201320:	926ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201324 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201324:	1141                	addi	sp,sp,-16
ffffffffc0201326:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201328:	14058a63          	beqz	a1,ffffffffc020147c <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020132c:	00359693          	slli	a3,a1,0x3
ffffffffc0201330:	96ae                	add	a3,a3,a1
ffffffffc0201332:	068e                	slli	a3,a3,0x3
ffffffffc0201334:	96aa                	add	a3,a3,a0
ffffffffc0201336:	87aa                	mv	a5,a0
ffffffffc0201338:	02d50263          	beq	a0,a3,ffffffffc020135c <default_free_pages+0x38>
ffffffffc020133c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020133e:	8b05                	andi	a4,a4,1
ffffffffc0201340:	10071e63          	bnez	a4,ffffffffc020145c <default_free_pages+0x138>
ffffffffc0201344:	6798                	ld	a4,8(a5)
ffffffffc0201346:	8b09                	andi	a4,a4,2
ffffffffc0201348:	10071a63          	bnez	a4,ffffffffc020145c <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020134c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201350:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201354:	04878793          	addi	a5,a5,72
ffffffffc0201358:	fed792e3          	bne	a5,a3,ffffffffc020133c <default_free_pages+0x18>
    base->property = n;
ffffffffc020135c:	2581                	sext.w	a1,a1
ffffffffc020135e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201360:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201364:	4789                	li	a5,2
ffffffffc0201366:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020136a:	00011697          	auipc	a3,0x11
ffffffffc020136e:	0f668693          	addi	a3,a3,246 # ffffffffc0212460 <free_area>
ffffffffc0201372:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201374:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201376:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020137a:	9db9                	addw	a1,a1,a4
ffffffffc020137c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020137e:	0ad78863          	beq	a5,a3,ffffffffc020142e <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201382:	fe078713          	addi	a4,a5,-32
ffffffffc0201386:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020138a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020138c:	00e56a63          	bltu	a0,a4,ffffffffc02013a0 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0201390:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201392:	06d70263          	beq	a4,a3,ffffffffc02013f6 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201396:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201398:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020139c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201390 <default_free_pages+0x6c>
ffffffffc02013a0:	c199                	beqz	a1,ffffffffc02013a6 <default_free_pages+0x82>
ffffffffc02013a2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013a6:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013a8:	e390                	sd	a2,0(a5)
ffffffffc02013aa:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02013ac:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013ae:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02013b0:	02d70063          	beq	a4,a3,ffffffffc02013d0 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02013b4:	ff072803          	lw	a6,-16(a4)
        p = le2page(le, page_link);
ffffffffc02013b8:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02013bc:	02081613          	slli	a2,a6,0x20
ffffffffc02013c0:	9201                	srli	a2,a2,0x20
ffffffffc02013c2:	00361793          	slli	a5,a2,0x3
ffffffffc02013c6:	97b2                	add	a5,a5,a2
ffffffffc02013c8:	078e                	slli	a5,a5,0x3
ffffffffc02013ca:	97ae                	add	a5,a5,a1
ffffffffc02013cc:	02f50f63          	beq	a0,a5,ffffffffc020140a <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02013d0:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02013d2:	00d70f63          	beq	a4,a3,ffffffffc02013f0 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02013d6:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02013d8:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02013dc:	02059613          	slli	a2,a1,0x20
ffffffffc02013e0:	9201                	srli	a2,a2,0x20
ffffffffc02013e2:	00361793          	slli	a5,a2,0x3
ffffffffc02013e6:	97b2                	add	a5,a5,a2
ffffffffc02013e8:	078e                	slli	a5,a5,0x3
ffffffffc02013ea:	97aa                	add	a5,a5,a0
ffffffffc02013ec:	04f68863          	beq	a3,a5,ffffffffc020143c <default_free_pages+0x118>
}
ffffffffc02013f0:	60a2                	ld	ra,8(sp)
ffffffffc02013f2:	0141                	addi	sp,sp,16
ffffffffc02013f4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02013f6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013f8:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02013fa:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013fc:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013fe:	02d70563          	beq	a4,a3,ffffffffc0201428 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201402:	8832                	mv	a6,a2
ffffffffc0201404:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201406:	87ba                	mv	a5,a4
ffffffffc0201408:	bf41                	j	ffffffffc0201398 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020140a:	491c                	lw	a5,16(a0)
ffffffffc020140c:	0107883b          	addw	a6,a5,a6
ffffffffc0201410:	ff072823          	sw	a6,-16(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201414:	57f5                	li	a5,-3
ffffffffc0201416:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020141a:	7110                	ld	a2,32(a0)
ffffffffc020141c:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020141e:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201420:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201422:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201424:	e390                	sd	a2,0(a5)
ffffffffc0201426:	b775                	j	ffffffffc02013d2 <default_free_pages+0xae>
ffffffffc0201428:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020142a:	873e                	mv	a4,a5
ffffffffc020142c:	b761                	j	ffffffffc02013b4 <default_free_pages+0x90>
}
ffffffffc020142e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201430:	e390                	sd	a2,0(a5)
ffffffffc0201432:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201434:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201436:	f11c                	sd	a5,32(a0)
ffffffffc0201438:	0141                	addi	sp,sp,16
ffffffffc020143a:	8082                	ret
            base->property += p->property;
ffffffffc020143c:	ff072783          	lw	a5,-16(a4)
ffffffffc0201440:	fe870693          	addi	a3,a4,-24
ffffffffc0201444:	9dbd                	addw	a1,a1,a5
ffffffffc0201446:	c90c                	sw	a1,16(a0)
ffffffffc0201448:	57f5                	li	a5,-3
ffffffffc020144a:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020144e:	6314                	ld	a3,0(a4)
ffffffffc0201450:	671c                	ld	a5,8(a4)
}
ffffffffc0201452:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201454:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201456:	e394                	sd	a3,0(a5)
ffffffffc0201458:	0141                	addi	sp,sp,16
ffffffffc020145a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020145c:	00005697          	auipc	a3,0x5
ffffffffc0201460:	82468693          	addi	a3,a3,-2012 # ffffffffc0205c80 <commands+0xa98>
ffffffffc0201464:	00004617          	auipc	a2,0x4
ffffffffc0201468:	4bc60613          	addi	a2,a2,1212 # ffffffffc0205920 <commands+0x738>
ffffffffc020146c:	08300593          	li	a1,131
ffffffffc0201470:	00004517          	auipc	a0,0x4
ffffffffc0201474:	4c850513          	addi	a0,a0,1224 # ffffffffc0205938 <commands+0x750>
ffffffffc0201478:	fcffe0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc020147c:	00004697          	auipc	a3,0x4
ffffffffc0201480:	7fc68693          	addi	a3,a3,2044 # ffffffffc0205c78 <commands+0xa90>
ffffffffc0201484:	00004617          	auipc	a2,0x4
ffffffffc0201488:	49c60613          	addi	a2,a2,1180 # ffffffffc0205920 <commands+0x738>
ffffffffc020148c:	08000593          	li	a1,128
ffffffffc0201490:	00004517          	auipc	a0,0x4
ffffffffc0201494:	4a850513          	addi	a0,a0,1192 # ffffffffc0205938 <commands+0x750>
ffffffffc0201498:	faffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020149c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020149c:	c959                	beqz	a0,ffffffffc0201532 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020149e:	00011597          	auipc	a1,0x11
ffffffffc02014a2:	fc258593          	addi	a1,a1,-62 # ffffffffc0212460 <free_area>
ffffffffc02014a6:	0105a803          	lw	a6,16(a1)
ffffffffc02014aa:	862a                	mv	a2,a0
ffffffffc02014ac:	02081793          	slli	a5,a6,0x20
ffffffffc02014b0:	9381                	srli	a5,a5,0x20
ffffffffc02014b2:	00a7ee63          	bltu	a5,a0,ffffffffc02014ce <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014b6:	87ae                	mv	a5,a1
ffffffffc02014b8:	a801                	j	ffffffffc02014c8 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014ba:	ff07a703          	lw	a4,-16(a5)
ffffffffc02014be:	02071693          	slli	a3,a4,0x20
ffffffffc02014c2:	9281                	srli	a3,a3,0x20
ffffffffc02014c4:	00c6f763          	bgeu	a3,a2,ffffffffc02014d2 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014c8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014ca:	feb798e3          	bne	a5,a1,ffffffffc02014ba <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014ce:	4501                	li	a0,0
}
ffffffffc02014d0:	8082                	ret
    return listelm->prev;
ffffffffc02014d2:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014d6:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02014da:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02014de:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02014e2:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014e6:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014ea:	02d67b63          	bgeu	a2,a3,ffffffffc0201520 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02014ee:	00361693          	slli	a3,a2,0x3
ffffffffc02014f2:	96b2                	add	a3,a3,a2
ffffffffc02014f4:	068e                	slli	a3,a3,0x3
ffffffffc02014f6:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02014f8:	41c7073b          	subw	a4,a4,t3
ffffffffc02014fc:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014fe:	00868613          	addi	a2,a3,8
ffffffffc0201502:	4709                	li	a4,2
ffffffffc0201504:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201508:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020150c:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0201510:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201514:	e310                	sd	a2,0(a4)
ffffffffc0201516:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020151a:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020151c:	0316b023          	sd	a7,32(a3)
ffffffffc0201520:	41c8083b          	subw	a6,a6,t3
ffffffffc0201524:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201528:	5775                	li	a4,-3
ffffffffc020152a:	17a1                	addi	a5,a5,-24
ffffffffc020152c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201530:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201532:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201534:	00004697          	auipc	a3,0x4
ffffffffc0201538:	74468693          	addi	a3,a3,1860 # ffffffffc0205c78 <commands+0xa90>
ffffffffc020153c:	00004617          	auipc	a2,0x4
ffffffffc0201540:	3e460613          	addi	a2,a2,996 # ffffffffc0205920 <commands+0x738>
ffffffffc0201544:	06200593          	li	a1,98
ffffffffc0201548:	00004517          	auipc	a0,0x4
ffffffffc020154c:	3f050513          	addi	a0,a0,1008 # ffffffffc0205938 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc0201550:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201552:	ef5fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201556 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201556:	1141                	addi	sp,sp,-16
ffffffffc0201558:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020155a:	c9e1                	beqz	a1,ffffffffc020162a <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020155c:	00359693          	slli	a3,a1,0x3
ffffffffc0201560:	96ae                	add	a3,a3,a1
ffffffffc0201562:	068e                	slli	a3,a3,0x3
ffffffffc0201564:	96aa                	add	a3,a3,a0
ffffffffc0201566:	87aa                	mv	a5,a0
ffffffffc0201568:	00d50f63          	beq	a0,a3,ffffffffc0201586 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020156c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020156e:	8b05                	andi	a4,a4,1
ffffffffc0201570:	cf49                	beqz	a4,ffffffffc020160a <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201572:	0007a823          	sw	zero,16(a5)
ffffffffc0201576:	0007b423          	sd	zero,8(a5)
ffffffffc020157a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020157e:	04878793          	addi	a5,a5,72
ffffffffc0201582:	fed795e3          	bne	a5,a3,ffffffffc020156c <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201586:	2581                	sext.w	a1,a1
ffffffffc0201588:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020158a:	4789                	li	a5,2
ffffffffc020158c:	00850713          	addi	a4,a0,8
ffffffffc0201590:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201594:	00011697          	auipc	a3,0x11
ffffffffc0201598:	ecc68693          	addi	a3,a3,-308 # ffffffffc0212460 <free_area>
ffffffffc020159c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020159e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02015a0:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02015a4:	9db9                	addw	a1,a1,a4
ffffffffc02015a6:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015a8:	04d78a63          	beq	a5,a3,ffffffffc02015fc <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02015ac:	fe078713          	addi	a4,a5,-32
ffffffffc02015b0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015b4:	4581                	li	a1,0
            if (base < page) {
ffffffffc02015b6:	00e56a63          	bltu	a0,a4,ffffffffc02015ca <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02015ba:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015bc:	02d70263          	beq	a4,a3,ffffffffc02015e0 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02015c0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015c2:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02015c6:	fee57ae3          	bgeu	a0,a4,ffffffffc02015ba <default_init_memmap+0x64>
ffffffffc02015ca:	c199                	beqz	a1,ffffffffc02015d0 <default_init_memmap+0x7a>
ffffffffc02015cc:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015d0:	6398                	ld	a4,0(a5)
}
ffffffffc02015d2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015d4:	e390                	sd	a2,0(a5)
ffffffffc02015d6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015d8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015da:	f118                	sd	a4,32(a0)
ffffffffc02015dc:	0141                	addi	sp,sp,16
ffffffffc02015de:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015e0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015e2:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02015e4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015e6:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015e8:	00d70663          	beq	a4,a3,ffffffffc02015f4 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02015ec:	8832                	mv	a6,a2
ffffffffc02015ee:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02015f0:	87ba                	mv	a5,a4
ffffffffc02015f2:	bfc1                	j	ffffffffc02015c2 <default_init_memmap+0x6c>
}
ffffffffc02015f4:	60a2                	ld	ra,8(sp)
ffffffffc02015f6:	e290                	sd	a2,0(a3)
ffffffffc02015f8:	0141                	addi	sp,sp,16
ffffffffc02015fa:	8082                	ret
ffffffffc02015fc:	60a2                	ld	ra,8(sp)
ffffffffc02015fe:	e390                	sd	a2,0(a5)
ffffffffc0201600:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201602:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201604:	f11c                	sd	a5,32(a0)
ffffffffc0201606:	0141                	addi	sp,sp,16
ffffffffc0201608:	8082                	ret
        assert(PageReserved(p));
ffffffffc020160a:	00004697          	auipc	a3,0x4
ffffffffc020160e:	69e68693          	addi	a3,a3,1694 # ffffffffc0205ca8 <commands+0xac0>
ffffffffc0201612:	00004617          	auipc	a2,0x4
ffffffffc0201616:	30e60613          	addi	a2,a2,782 # ffffffffc0205920 <commands+0x738>
ffffffffc020161a:	04900593          	li	a1,73
ffffffffc020161e:	00004517          	auipc	a0,0x4
ffffffffc0201622:	31a50513          	addi	a0,a0,794 # ffffffffc0205938 <commands+0x750>
ffffffffc0201626:	e21fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc020162a:	00004697          	auipc	a3,0x4
ffffffffc020162e:	64e68693          	addi	a3,a3,1614 # ffffffffc0205c78 <commands+0xa90>
ffffffffc0201632:	00004617          	auipc	a2,0x4
ffffffffc0201636:	2ee60613          	addi	a2,a2,750 # ffffffffc0205920 <commands+0x738>
ffffffffc020163a:	04600593          	li	a1,70
ffffffffc020163e:	00004517          	auipc	a0,0x4
ffffffffc0201642:	2fa50513          	addi	a0,a0,762 # ffffffffc0205938 <commands+0x750>
ffffffffc0201646:	e01fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020164a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020164a:	c94d                	beqz	a0,ffffffffc02016fc <slob_free+0xb2>
{
ffffffffc020164c:	1141                	addi	sp,sp,-16
ffffffffc020164e:	e022                	sd	s0,0(sp)
ffffffffc0201650:	e406                	sd	ra,8(sp)
ffffffffc0201652:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201654:	e9c1                	bnez	a1,ffffffffc02016e4 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201656:	100027f3          	csrr	a5,sstatus
ffffffffc020165a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020165c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020165e:	ebd9                	bnez	a5,ffffffffc02016f4 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201660:	0000a617          	auipc	a2,0xa
ffffffffc0201664:	9f060613          	addi	a2,a2,-1552 # ffffffffc020b050 <slobfree>
ffffffffc0201668:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020166a:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020166c:	679c                	ld	a5,8(a5)
ffffffffc020166e:	02877a63          	bgeu	a4,s0,ffffffffc02016a2 <slob_free+0x58>
ffffffffc0201672:	00f46463          	bltu	s0,a5,ffffffffc020167a <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201676:	fef76ae3          	bltu	a4,a5,ffffffffc020166a <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc020167a:	400c                	lw	a1,0(s0)
ffffffffc020167c:	00459693          	slli	a3,a1,0x4
ffffffffc0201680:	96a2                	add	a3,a3,s0
ffffffffc0201682:	02d78a63          	beq	a5,a3,ffffffffc02016b6 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201686:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201688:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020168a:	00469793          	slli	a5,a3,0x4
ffffffffc020168e:	97ba                	add	a5,a5,a4
ffffffffc0201690:	02f40e63          	beq	s0,a5,ffffffffc02016cc <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201694:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201696:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201698:	e129                	bnez	a0,ffffffffc02016da <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020169a:	60a2                	ld	ra,8(sp)
ffffffffc020169c:	6402                	ld	s0,0(sp)
ffffffffc020169e:	0141                	addi	sp,sp,16
ffffffffc02016a0:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016a2:	fcf764e3          	bltu	a4,a5,ffffffffc020166a <slob_free+0x20>
ffffffffc02016a6:	fcf472e3          	bgeu	s0,a5,ffffffffc020166a <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc02016aa:	400c                	lw	a1,0(s0)
ffffffffc02016ac:	00459693          	slli	a3,a1,0x4
ffffffffc02016b0:	96a2                	add	a3,a3,s0
ffffffffc02016b2:	fcd79ae3          	bne	a5,a3,ffffffffc0201686 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc02016b6:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02016b8:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02016ba:	9db5                	addw	a1,a1,a3
ffffffffc02016bc:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc02016be:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02016c0:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02016c2:	00469793          	slli	a5,a3,0x4
ffffffffc02016c6:	97ba                	add	a5,a5,a4
ffffffffc02016c8:	fcf416e3          	bne	s0,a5,ffffffffc0201694 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02016cc:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02016ce:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc02016d0:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02016d2:	9ebd                	addw	a3,a3,a5
ffffffffc02016d4:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02016d6:	e70c                	sd	a1,8(a4)
ffffffffc02016d8:	d169                	beqz	a0,ffffffffc020169a <slob_free+0x50>
}
ffffffffc02016da:	6402                	ld	s0,0(sp)
ffffffffc02016dc:	60a2                	ld	ra,8(sp)
ffffffffc02016de:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02016e0:	eddfe06f          	j	ffffffffc02005bc <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02016e4:	25bd                	addiw	a1,a1,15
ffffffffc02016e6:	8191                	srli	a1,a1,0x4
ffffffffc02016e8:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016ea:	100027f3          	csrr	a5,sstatus
ffffffffc02016ee:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02016f0:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f2:	d7bd                	beqz	a5,ffffffffc0201660 <slob_free+0x16>
        intr_disable();
ffffffffc02016f4:	ecffe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc02016f8:	4505                	li	a0,1
ffffffffc02016fa:	b79d                	j	ffffffffc0201660 <slob_free+0x16>
ffffffffc02016fc:	8082                	ret

ffffffffc02016fe <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02016fe:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201700:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201702:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201706:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201708:	360000ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
  if(!page)
ffffffffc020170c:	c129                	beqz	a0,ffffffffc020174e <__slob_get_free_pages.constprop.0+0x50>
    return page - pages + nbase;
ffffffffc020170e:	00015697          	auipc	a3,0x15
ffffffffc0201712:	e626b683          	ld	a3,-414(a3) # ffffffffc0216570 <pages>
ffffffffc0201716:	8d15                	sub	a0,a0,a3
ffffffffc0201718:	850d                	srai	a0,a0,0x3
ffffffffc020171a:	00006697          	auipc	a3,0x6
ffffffffc020171e:	8ee6b683          	ld	a3,-1810(a3) # ffffffffc0207008 <error_string+0x38>
ffffffffc0201722:	02d50533          	mul	a0,a0,a3
ffffffffc0201726:	00006697          	auipc	a3,0x6
ffffffffc020172a:	8ea6b683          	ld	a3,-1814(a3) # ffffffffc0207010 <nbase>
    return KADDR(page2pa(page));
ffffffffc020172e:	00015717          	auipc	a4,0x15
ffffffffc0201732:	e3a73703          	ld	a4,-454(a4) # ffffffffc0216568 <npage>
    return page - pages + nbase;
ffffffffc0201736:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201738:	00c51793          	slli	a5,a0,0xc
ffffffffc020173c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020173e:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201740:	00e7fa63          	bgeu	a5,a4,ffffffffc0201754 <__slob_get_free_pages.constprop.0+0x56>
ffffffffc0201744:	00015697          	auipc	a3,0x15
ffffffffc0201748:	e3c6b683          	ld	a3,-452(a3) # ffffffffc0216580 <va_pa_offset>
ffffffffc020174c:	9536                	add	a0,a0,a3
}
ffffffffc020174e:	60a2                	ld	ra,8(sp)
ffffffffc0201750:	0141                	addi	sp,sp,16
ffffffffc0201752:	8082                	ret
ffffffffc0201754:	86aa                	mv	a3,a0
ffffffffc0201756:	00004617          	auipc	a2,0x4
ffffffffc020175a:	5b260613          	addi	a2,a2,1458 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc020175e:	06900593          	li	a1,105
ffffffffc0201762:	00004517          	auipc	a0,0x4
ffffffffc0201766:	5ce50513          	addi	a0,a0,1486 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc020176a:	cddfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020176e <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020176e:	1101                	addi	sp,sp,-32
ffffffffc0201770:	ec06                	sd	ra,24(sp)
ffffffffc0201772:	e822                	sd	s0,16(sp)
ffffffffc0201774:	e426                	sd	s1,8(sp)
ffffffffc0201776:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201778:	01050713          	addi	a4,a0,16
ffffffffc020177c:	6785                	lui	a5,0x1
ffffffffc020177e:	0cf77363          	bgeu	a4,a5,ffffffffc0201844 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201782:	00f50493          	addi	s1,a0,15
ffffffffc0201786:	8091                	srli	s1,s1,0x4
ffffffffc0201788:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020178a:	10002673          	csrr	a2,sstatus
ffffffffc020178e:	8a09                	andi	a2,a2,2
ffffffffc0201790:	e25d                	bnez	a2,ffffffffc0201836 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201792:	0000a917          	auipc	s2,0xa
ffffffffc0201796:	8be90913          	addi	s2,s2,-1858 # ffffffffc020b050 <slobfree>
ffffffffc020179a:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020179e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02017a0:	4398                	lw	a4,0(a5)
ffffffffc02017a2:	08975e63          	bge	a4,s1,ffffffffc020183e <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02017a6:	00d78b63          	beq	a5,a3,ffffffffc02017bc <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02017aa:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02017ac:	4018                	lw	a4,0(s0)
ffffffffc02017ae:	02975a63          	bge	a4,s1,ffffffffc02017e2 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc02017b2:	00093683          	ld	a3,0(s2)
ffffffffc02017b6:	87a2                	mv	a5,s0
ffffffffc02017b8:	fed799e3          	bne	a5,a3,ffffffffc02017aa <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc02017bc:	ee31                	bnez	a2,ffffffffc0201818 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02017be:	4501                	li	a0,0
ffffffffc02017c0:	f3fff0ef          	jal	ra,ffffffffc02016fe <__slob_get_free_pages.constprop.0>
ffffffffc02017c4:	842a                	mv	s0,a0
			if (!cur)
ffffffffc02017c6:	cd05                	beqz	a0,ffffffffc02017fe <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc02017c8:	6585                	lui	a1,0x1
ffffffffc02017ca:	e81ff0ef          	jal	ra,ffffffffc020164a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017ce:	10002673          	csrr	a2,sstatus
ffffffffc02017d2:	8a09                	andi	a2,a2,2
ffffffffc02017d4:	ee05                	bnez	a2,ffffffffc020180c <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc02017d6:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02017da:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02017dc:	4018                	lw	a4,0(s0)
ffffffffc02017de:	fc974ae3          	blt	a4,s1,ffffffffc02017b2 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc02017e2:	04e48763          	beq	s1,a4,ffffffffc0201830 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc02017e6:	00449693          	slli	a3,s1,0x4
ffffffffc02017ea:	96a2                	add	a3,a3,s0
ffffffffc02017ec:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02017ee:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02017f0:	9f05                	subw	a4,a4,s1
ffffffffc02017f2:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02017f4:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02017f6:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02017f8:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc02017fc:	e20d                	bnez	a2,ffffffffc020181e <slob_alloc.constprop.0+0xb0>
}
ffffffffc02017fe:	60e2                	ld	ra,24(sp)
ffffffffc0201800:	8522                	mv	a0,s0
ffffffffc0201802:	6442                	ld	s0,16(sp)
ffffffffc0201804:	64a2                	ld	s1,8(sp)
ffffffffc0201806:	6902                	ld	s2,0(sp)
ffffffffc0201808:	6105                	addi	sp,sp,32
ffffffffc020180a:	8082                	ret
        intr_disable();
ffffffffc020180c:	db7fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
			cur = slobfree;
ffffffffc0201810:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201814:	4605                	li	a2,1
ffffffffc0201816:	b7d1                	j	ffffffffc02017da <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201818:	da5fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020181c:	b74d                	j	ffffffffc02017be <slob_alloc.constprop.0+0x50>
ffffffffc020181e:	d9ffe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
}
ffffffffc0201822:	60e2                	ld	ra,24(sp)
ffffffffc0201824:	8522                	mv	a0,s0
ffffffffc0201826:	6442                	ld	s0,16(sp)
ffffffffc0201828:	64a2                	ld	s1,8(sp)
ffffffffc020182a:	6902                	ld	s2,0(sp)
ffffffffc020182c:	6105                	addi	sp,sp,32
ffffffffc020182e:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201830:	6418                	ld	a4,8(s0)
ffffffffc0201832:	e798                	sd	a4,8(a5)
ffffffffc0201834:	b7d1                	j	ffffffffc02017f8 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201836:	d8dfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc020183a:	4605                	li	a2,1
ffffffffc020183c:	bf99                	j	ffffffffc0201792 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020183e:	843e                	mv	s0,a5
ffffffffc0201840:	87b6                	mv	a5,a3
ffffffffc0201842:	b745                	j	ffffffffc02017e2 <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201844:	00004697          	auipc	a3,0x4
ffffffffc0201848:	4fc68693          	addi	a3,a3,1276 # ffffffffc0205d40 <default_pmm_manager+0x70>
ffffffffc020184c:	00004617          	auipc	a2,0x4
ffffffffc0201850:	0d460613          	addi	a2,a2,212 # ffffffffc0205920 <commands+0x738>
ffffffffc0201854:	06300593          	li	a1,99
ffffffffc0201858:	00004517          	auipc	a0,0x4
ffffffffc020185c:	50850513          	addi	a0,a0,1288 # ffffffffc0205d60 <default_pmm_manager+0x90>
ffffffffc0201860:	be7fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201864 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201864:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201866:	00004517          	auipc	a0,0x4
ffffffffc020186a:	51250513          	addi	a0,a0,1298 # ffffffffc0205d78 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc020186e:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201870:	911fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201874:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201876:	00004517          	auipc	a0,0x4
ffffffffc020187a:	51a50513          	addi	a0,a0,1306 # ffffffffc0205d90 <default_pmm_manager+0xc0>
}
ffffffffc020187e:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201880:	901fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201884 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201884:	1101                	addi	sp,sp,-32
ffffffffc0201886:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201888:	6905                	lui	s2,0x1
{
ffffffffc020188a:	e822                	sd	s0,16(sp)
ffffffffc020188c:	ec06                	sd	ra,24(sp)
ffffffffc020188e:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201890:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0201894:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201896:	04a7f963          	bgeu	a5,a0,ffffffffc02018e8 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc020189a:	4561                	li	a0,24
ffffffffc020189c:	ed3ff0ef          	jal	ra,ffffffffc020176e <slob_alloc.constprop.0>
ffffffffc02018a0:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02018a2:	c929                	beqz	a0,ffffffffc02018f4 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02018a4:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02018a8:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02018aa:	00f95763          	bge	s2,a5,ffffffffc02018b8 <kmalloc+0x34>
ffffffffc02018ae:	6705                	lui	a4,0x1
ffffffffc02018b0:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02018b2:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02018b4:	fef74ee3          	blt	a4,a5,ffffffffc02018b0 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02018b8:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02018ba:	e45ff0ef          	jal	ra,ffffffffc02016fe <__slob_get_free_pages.constprop.0>
ffffffffc02018be:	e488                	sd	a0,8(s1)
ffffffffc02018c0:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02018c2:	c525                	beqz	a0,ffffffffc020192a <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018c4:	100027f3          	csrr	a5,sstatus
ffffffffc02018c8:	8b89                	andi	a5,a5,2
ffffffffc02018ca:	ef8d                	bnez	a5,ffffffffc0201904 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc02018cc:	00015797          	auipc	a5,0x15
ffffffffc02018d0:	c8478793          	addi	a5,a5,-892 # ffffffffc0216550 <bigblocks>
ffffffffc02018d4:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02018d6:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02018d8:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02018da:	60e2                	ld	ra,24(sp)
ffffffffc02018dc:	8522                	mv	a0,s0
ffffffffc02018de:	6442                	ld	s0,16(sp)
ffffffffc02018e0:	64a2                	ld	s1,8(sp)
ffffffffc02018e2:	6902                	ld	s2,0(sp)
ffffffffc02018e4:	6105                	addi	sp,sp,32
ffffffffc02018e6:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02018e8:	0541                	addi	a0,a0,16
ffffffffc02018ea:	e85ff0ef          	jal	ra,ffffffffc020176e <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc02018ee:	01050413          	addi	s0,a0,16
ffffffffc02018f2:	f565                	bnez	a0,ffffffffc02018da <kmalloc+0x56>
ffffffffc02018f4:	4401                	li	s0,0
}
ffffffffc02018f6:	60e2                	ld	ra,24(sp)
ffffffffc02018f8:	8522                	mv	a0,s0
ffffffffc02018fa:	6442                	ld	s0,16(sp)
ffffffffc02018fc:	64a2                	ld	s1,8(sp)
ffffffffc02018fe:	6902                	ld	s2,0(sp)
ffffffffc0201900:	6105                	addi	sp,sp,32
ffffffffc0201902:	8082                	ret
        intr_disable();
ffffffffc0201904:	cbffe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201908:	00015797          	auipc	a5,0x15
ffffffffc020190c:	c4878793          	addi	a5,a5,-952 # ffffffffc0216550 <bigblocks>
ffffffffc0201910:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201912:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201914:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201916:	ca7fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
		return bb->pages;
ffffffffc020191a:	6480                	ld	s0,8(s1)
}
ffffffffc020191c:	60e2                	ld	ra,24(sp)
ffffffffc020191e:	64a2                	ld	s1,8(sp)
ffffffffc0201920:	8522                	mv	a0,s0
ffffffffc0201922:	6442                	ld	s0,16(sp)
ffffffffc0201924:	6902                	ld	s2,0(sp)
ffffffffc0201926:	6105                	addi	sp,sp,32
ffffffffc0201928:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020192a:	45e1                	li	a1,24
ffffffffc020192c:	8526                	mv	a0,s1
ffffffffc020192e:	d1dff0ef          	jal	ra,ffffffffc020164a <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201932:	b765                	j	ffffffffc02018da <kmalloc+0x56>

ffffffffc0201934 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201934:	c561                	beqz	a0,ffffffffc02019fc <kfree+0xc8>
{
ffffffffc0201936:	1101                	addi	sp,sp,-32
ffffffffc0201938:	e822                	sd	s0,16(sp)
ffffffffc020193a:	ec06                	sd	ra,24(sp)
ffffffffc020193c:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc020193e:	03451793          	slli	a5,a0,0x34
ffffffffc0201942:	842a                	mv	s0,a0
ffffffffc0201944:	e7d1                	bnez	a5,ffffffffc02019d0 <kfree+0x9c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201946:	100027f3          	csrr	a5,sstatus
ffffffffc020194a:	8b89                	andi	a5,a5,2
ffffffffc020194c:	ebd1                	bnez	a5,ffffffffc02019e0 <kfree+0xac>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020194e:	00015797          	auipc	a5,0x15
ffffffffc0201952:	c027b783          	ld	a5,-1022(a5) # ffffffffc0216550 <bigblocks>
    return 0;
ffffffffc0201956:	4601                	li	a2,0
ffffffffc0201958:	cfa5                	beqz	a5,ffffffffc02019d0 <kfree+0x9c>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc020195a:	00015697          	auipc	a3,0x15
ffffffffc020195e:	bf668693          	addi	a3,a3,-1034 # ffffffffc0216550 <bigblocks>
ffffffffc0201962:	a021                	j	ffffffffc020196a <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201964:	01048693          	addi	a3,s1,16
ffffffffc0201968:	c3bd                	beqz	a5,ffffffffc02019ce <kfree+0x9a>
			if (bb->pages == block) {
ffffffffc020196a:	6798                	ld	a4,8(a5)
ffffffffc020196c:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc020196e:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201970:	fe871ae3          	bne	a4,s0,ffffffffc0201964 <kfree+0x30>
				*last = bb->next;
ffffffffc0201974:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201976:	e241                	bnez	a2,ffffffffc02019f6 <kfree+0xc2>
    return pa2page(PADDR(kva));
ffffffffc0201978:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020197c:	4098                	lw	a4,0(s1)
ffffffffc020197e:	08f46c63          	bltu	s0,a5,ffffffffc0201a16 <kfree+0xe2>
ffffffffc0201982:	00015697          	auipc	a3,0x15
ffffffffc0201986:	bfe6b683          	ld	a3,-1026(a3) # ffffffffc0216580 <va_pa_offset>
ffffffffc020198a:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc020198c:	8031                	srli	s0,s0,0xc
ffffffffc020198e:	00015797          	auipc	a5,0x15
ffffffffc0201992:	bda7b783          	ld	a5,-1062(a5) # ffffffffc0216568 <npage>
ffffffffc0201996:	06f47463          	bgeu	s0,a5,ffffffffc02019fe <kfree+0xca>
    return &pages[PPN(pa) - nbase];
ffffffffc020199a:	00005797          	auipc	a5,0x5
ffffffffc020199e:	6767b783          	ld	a5,1654(a5) # ffffffffc0207010 <nbase>
ffffffffc02019a2:	8c1d                	sub	s0,s0,a5
ffffffffc02019a4:	00341513          	slli	a0,s0,0x3
ffffffffc02019a8:	942a                	add	s0,s0,a0
ffffffffc02019aa:	040e                	slli	s0,s0,0x3
  free_pages(kva2page(kva), 1 << order);
ffffffffc02019ac:	00015517          	auipc	a0,0x15
ffffffffc02019b0:	bc453503          	ld	a0,-1084(a0) # ffffffffc0216570 <pages>
ffffffffc02019b4:	4585                	li	a1,1
ffffffffc02019b6:	9522                	add	a0,a0,s0
ffffffffc02019b8:	00e595bb          	sllw	a1,a1,a4
ffffffffc02019bc:	13e000ef          	jal	ra,ffffffffc0201afa <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02019c0:	6442                	ld	s0,16(sp)
ffffffffc02019c2:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02019c4:	8526                	mv	a0,s1
}
ffffffffc02019c6:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02019c8:	45e1                	li	a1,24
}
ffffffffc02019ca:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02019cc:	b9bd                	j	ffffffffc020164a <slob_free>
ffffffffc02019ce:	e20d                	bnez	a2,ffffffffc02019f0 <kfree+0xbc>
ffffffffc02019d0:	ff040513          	addi	a0,s0,-16
}
ffffffffc02019d4:	6442                	ld	s0,16(sp)
ffffffffc02019d6:	60e2                	ld	ra,24(sp)
ffffffffc02019d8:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02019da:	4581                	li	a1,0
}
ffffffffc02019dc:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02019de:	b1b5                	j	ffffffffc020164a <slob_free>
        intr_disable();
ffffffffc02019e0:	be3fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02019e4:	00015797          	auipc	a5,0x15
ffffffffc02019e8:	b6c7b783          	ld	a5,-1172(a5) # ffffffffc0216550 <bigblocks>
        return 1;
ffffffffc02019ec:	4605                	li	a2,1
ffffffffc02019ee:	f7b5                	bnez	a5,ffffffffc020195a <kfree+0x26>
        intr_enable();
ffffffffc02019f0:	bcdfe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02019f4:	bff1                	j	ffffffffc02019d0 <kfree+0x9c>
ffffffffc02019f6:	bc7fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02019fa:	bfbd                	j	ffffffffc0201978 <kfree+0x44>
ffffffffc02019fc:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02019fe:	00004617          	auipc	a2,0x4
ffffffffc0201a02:	3da60613          	addi	a2,a2,986 # ffffffffc0205dd8 <default_pmm_manager+0x108>
ffffffffc0201a06:	06200593          	li	a1,98
ffffffffc0201a0a:	00004517          	auipc	a0,0x4
ffffffffc0201a0e:	32650513          	addi	a0,a0,806 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc0201a12:	a35fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201a16:	86a2                	mv	a3,s0
ffffffffc0201a18:	00004617          	auipc	a2,0x4
ffffffffc0201a1c:	39860613          	addi	a2,a2,920 # ffffffffc0205db0 <default_pmm_manager+0xe0>
ffffffffc0201a20:	06e00593          	li	a1,110
ffffffffc0201a24:	00004517          	auipc	a0,0x4
ffffffffc0201a28:	30c50513          	addi	a0,a0,780 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc0201a2c:	a1bfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a30 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201a30:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201a32:	00004617          	auipc	a2,0x4
ffffffffc0201a36:	3a660613          	addi	a2,a2,934 # ffffffffc0205dd8 <default_pmm_manager+0x108>
ffffffffc0201a3a:	06200593          	li	a1,98
ffffffffc0201a3e:	00004517          	auipc	a0,0x4
ffffffffc0201a42:	2f250513          	addi	a0,a0,754 # ffffffffc0205d30 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201a46:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201a48:	9fffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a4c <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201a4c:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201a4e:	00004617          	auipc	a2,0x4
ffffffffc0201a52:	3aa60613          	addi	a2,a2,938 # ffffffffc0205df8 <default_pmm_manager+0x128>
ffffffffc0201a56:	07400593          	li	a1,116
ffffffffc0201a5a:	00004517          	auipc	a0,0x4
ffffffffc0201a5e:	2d650513          	addi	a0,a0,726 # ffffffffc0205d30 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201a62:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201a64:	9e3fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a68 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201a68:	7139                	addi	sp,sp,-64
ffffffffc0201a6a:	f426                	sd	s1,40(sp)
ffffffffc0201a6c:	f04a                	sd	s2,32(sp)
ffffffffc0201a6e:	ec4e                	sd	s3,24(sp)
ffffffffc0201a70:	e852                	sd	s4,16(sp)
ffffffffc0201a72:	e456                	sd	s5,8(sp)
ffffffffc0201a74:	e05a                	sd	s6,0(sp)
ffffffffc0201a76:	fc06                	sd	ra,56(sp)
ffffffffc0201a78:	f822                	sd	s0,48(sp)
ffffffffc0201a7a:	84aa                	mv	s1,a0
ffffffffc0201a7c:	00015917          	auipc	s2,0x15
ffffffffc0201a80:	afc90913          	addi	s2,s2,-1284 # ffffffffc0216578 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201a84:	4a05                	li	s4,1
ffffffffc0201a86:	00015a97          	auipc	s5,0x15
ffffffffc0201a8a:	b12a8a93          	addi	s5,s5,-1262 # ffffffffc0216598 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a8e:	0005099b          	sext.w	s3,a0
ffffffffc0201a92:	00015b17          	auipc	s6,0x15
ffffffffc0201a96:	b0eb0b13          	addi	s6,s6,-1266 # ffffffffc02165a0 <check_mm_struct>
ffffffffc0201a9a:	a01d                	j	ffffffffc0201ac0 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201a9c:	00093783          	ld	a5,0(s2)
ffffffffc0201aa0:	6f9c                	ld	a5,24(a5)
ffffffffc0201aa2:	9782                	jalr	a5
ffffffffc0201aa4:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201aa6:	4601                	li	a2,0
ffffffffc0201aa8:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201aaa:	ec0d                	bnez	s0,ffffffffc0201ae4 <alloc_pages+0x7c>
ffffffffc0201aac:	029a6c63          	bltu	s4,s1,ffffffffc0201ae4 <alloc_pages+0x7c>
ffffffffc0201ab0:	000aa783          	lw	a5,0(s5)
ffffffffc0201ab4:	2781                	sext.w	a5,a5
ffffffffc0201ab6:	c79d                	beqz	a5,ffffffffc0201ae4 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ab8:	000b3503          	ld	a0,0(s6)
ffffffffc0201abc:	10b010ef          	jal	ra,ffffffffc02033c6 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ac0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ac4:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201ac6:	8526                	mv	a0,s1
ffffffffc0201ac8:	dbf1                	beqz	a5,ffffffffc0201a9c <alloc_pages+0x34>
        intr_disable();
ffffffffc0201aca:	af9fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201ace:	00093783          	ld	a5,0(s2)
ffffffffc0201ad2:	8526                	mv	a0,s1
ffffffffc0201ad4:	6f9c                	ld	a5,24(a5)
ffffffffc0201ad6:	9782                	jalr	a5
ffffffffc0201ad8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201ada:	ae3fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ade:	4601                	li	a2,0
ffffffffc0201ae0:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ae2:	d469                	beqz	s0,ffffffffc0201aac <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ae4:	70e2                	ld	ra,56(sp)
ffffffffc0201ae6:	8522                	mv	a0,s0
ffffffffc0201ae8:	7442                	ld	s0,48(sp)
ffffffffc0201aea:	74a2                	ld	s1,40(sp)
ffffffffc0201aec:	7902                	ld	s2,32(sp)
ffffffffc0201aee:	69e2                	ld	s3,24(sp)
ffffffffc0201af0:	6a42                	ld	s4,16(sp)
ffffffffc0201af2:	6aa2                	ld	s5,8(sp)
ffffffffc0201af4:	6b02                	ld	s6,0(sp)
ffffffffc0201af6:	6121                	addi	sp,sp,64
ffffffffc0201af8:	8082                	ret

ffffffffc0201afa <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201afa:	100027f3          	csrr	a5,sstatus
ffffffffc0201afe:	8b89                	andi	a5,a5,2
ffffffffc0201b00:	e799                	bnez	a5,ffffffffc0201b0e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201b02:	00015797          	auipc	a5,0x15
ffffffffc0201b06:	a767b783          	ld	a5,-1418(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201b0a:	739c                	ld	a5,32(a5)
ffffffffc0201b0c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201b0e:	1101                	addi	sp,sp,-32
ffffffffc0201b10:	ec06                	sd	ra,24(sp)
ffffffffc0201b12:	e822                	sd	s0,16(sp)
ffffffffc0201b14:	e426                	sd	s1,8(sp)
ffffffffc0201b16:	842a                	mv	s0,a0
ffffffffc0201b18:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201b1a:	aa9fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201b1e:	00015797          	auipc	a5,0x15
ffffffffc0201b22:	a5a7b783          	ld	a5,-1446(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201b26:	739c                	ld	a5,32(a5)
ffffffffc0201b28:	85a6                	mv	a1,s1
ffffffffc0201b2a:	8522                	mv	a0,s0
ffffffffc0201b2c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201b2e:	6442                	ld	s0,16(sp)
ffffffffc0201b30:	60e2                	ld	ra,24(sp)
ffffffffc0201b32:	64a2                	ld	s1,8(sp)
ffffffffc0201b34:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201b36:	a87fe06f          	j	ffffffffc02005bc <intr_enable>

ffffffffc0201b3a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b3a:	100027f3          	csrr	a5,sstatus
ffffffffc0201b3e:	8b89                	andi	a5,a5,2
ffffffffc0201b40:	e799                	bnez	a5,ffffffffc0201b4e <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201b42:	00015797          	auipc	a5,0x15
ffffffffc0201b46:	a367b783          	ld	a5,-1482(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201b4a:	779c                	ld	a5,40(a5)
ffffffffc0201b4c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201b4e:	1141                	addi	sp,sp,-16
ffffffffc0201b50:	e406                	sd	ra,8(sp)
ffffffffc0201b52:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201b54:	a6ffe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201b58:	00015797          	auipc	a5,0x15
ffffffffc0201b5c:	a207b783          	ld	a5,-1504(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201b60:	779c                	ld	a5,40(a5)
ffffffffc0201b62:	9782                	jalr	a5
ffffffffc0201b64:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201b66:	a57fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201b6a:	60a2                	ld	ra,8(sp)
ffffffffc0201b6c:	8522                	mv	a0,s0
ffffffffc0201b6e:	6402                	ld	s0,0(sp)
ffffffffc0201b70:	0141                	addi	sp,sp,16
ffffffffc0201b72:	8082                	ret

ffffffffc0201b74 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b74:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201b78:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b7c:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b7e:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b80:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b82:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b86:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b88:	f84a                	sd	s2,48(sp)
ffffffffc0201b8a:	f44e                	sd	s3,40(sp)
ffffffffc0201b8c:	f052                	sd	s4,32(sp)
ffffffffc0201b8e:	e486                	sd	ra,72(sp)
ffffffffc0201b90:	e0a2                	sd	s0,64(sp)
ffffffffc0201b92:	ec56                	sd	s5,24(sp)
ffffffffc0201b94:	e85a                	sd	s6,16(sp)
ffffffffc0201b96:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b98:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b9c:	892e                	mv	s2,a1
ffffffffc0201b9e:	8a32                	mv	s4,a2
ffffffffc0201ba0:	00015997          	auipc	s3,0x15
ffffffffc0201ba4:	9c898993          	addi	s3,s3,-1592 # ffffffffc0216568 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201ba8:	efb5                	bnez	a5,ffffffffc0201c24 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201baa:	14060c63          	beqz	a2,ffffffffc0201d02 <get_pte+0x18e>
ffffffffc0201bae:	4505                	li	a0,1
ffffffffc0201bb0:	eb9ff0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0201bb4:	842a                	mv	s0,a0
ffffffffc0201bb6:	14050663          	beqz	a0,ffffffffc0201d02 <get_pte+0x18e>
    return page - pages + nbase;
ffffffffc0201bba:	00015b97          	auipc	s7,0x15
ffffffffc0201bbe:	9b6b8b93          	addi	s7,s7,-1610 # ffffffffc0216570 <pages>
ffffffffc0201bc2:	000bb503          	ld	a0,0(s7)
ffffffffc0201bc6:	00005b17          	auipc	s6,0x5
ffffffffc0201bca:	442b3b03          	ld	s6,1090(s6) # ffffffffc0207008 <error_string+0x38>
ffffffffc0201bce:	00080ab7          	lui	s5,0x80
ffffffffc0201bd2:	40a40533          	sub	a0,s0,a0
ffffffffc0201bd6:	850d                	srai	a0,a0,0x3
ffffffffc0201bd8:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201bdc:	00015997          	auipc	s3,0x15
ffffffffc0201be0:	98c98993          	addi	s3,s3,-1652 # ffffffffc0216568 <npage>
    page->ref = val;
ffffffffc0201be4:	4785                	li	a5,1
ffffffffc0201be6:	0009b703          	ld	a4,0(s3)
ffffffffc0201bea:	c01c                	sw	a5,0(s0)
    return page - pages + nbase;
ffffffffc0201bec:	9556                	add	a0,a0,s5
ffffffffc0201bee:	00c51793          	slli	a5,a0,0xc
ffffffffc0201bf2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bf4:	0532                	slli	a0,a0,0xc
ffffffffc0201bf6:	14e7fd63          	bgeu	a5,a4,ffffffffc0201d50 <get_pte+0x1dc>
ffffffffc0201bfa:	00015797          	auipc	a5,0x15
ffffffffc0201bfe:	9867b783          	ld	a5,-1658(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc0201c02:	6605                	lui	a2,0x1
ffffffffc0201c04:	4581                	li	a1,0
ffffffffc0201c06:	953e                	add	a0,a0,a5
ffffffffc0201c08:	32a030ef          	jal	ra,ffffffffc0204f32 <memset>
    return page - pages + nbase;
ffffffffc0201c0c:	000bb683          	ld	a3,0(s7)
ffffffffc0201c10:	40d406b3          	sub	a3,s0,a3
ffffffffc0201c14:	868d                	srai	a3,a3,0x3
ffffffffc0201c16:	036686b3          	mul	a3,a3,s6
ffffffffc0201c1a:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201c1c:	06aa                	slli	a3,a3,0xa
ffffffffc0201c1e:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201c22:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201c24:	77fd                	lui	a5,0xfffff
ffffffffc0201c26:	068a                	slli	a3,a3,0x2
ffffffffc0201c28:	0009b703          	ld	a4,0(s3)
ffffffffc0201c2c:	8efd                	and	a3,a3,a5
ffffffffc0201c2e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201c32:	0ce7fa63          	bgeu	a5,a4,ffffffffc0201d06 <get_pte+0x192>
ffffffffc0201c36:	00015a97          	auipc	s5,0x15
ffffffffc0201c3a:	94aa8a93          	addi	s5,s5,-1718 # ffffffffc0216580 <va_pa_offset>
ffffffffc0201c3e:	000ab403          	ld	s0,0(s5)
ffffffffc0201c42:	01595793          	srli	a5,s2,0x15
ffffffffc0201c46:	1ff7f793          	andi	a5,a5,511
ffffffffc0201c4a:	96a2                	add	a3,a3,s0
ffffffffc0201c4c:	00379413          	slli	s0,a5,0x3
ffffffffc0201c50:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201c52:	6014                	ld	a3,0(s0)
ffffffffc0201c54:	0016f793          	andi	a5,a3,1
ffffffffc0201c58:	ebad                	bnez	a5,ffffffffc0201cca <get_pte+0x156>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201c5a:	0a0a0463          	beqz	s4,ffffffffc0201d02 <get_pte+0x18e>
ffffffffc0201c5e:	4505                	li	a0,1
ffffffffc0201c60:	e09ff0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0201c64:	84aa                	mv	s1,a0
ffffffffc0201c66:	cd51                	beqz	a0,ffffffffc0201d02 <get_pte+0x18e>
    return page - pages + nbase;
ffffffffc0201c68:	00015b97          	auipc	s7,0x15
ffffffffc0201c6c:	908b8b93          	addi	s7,s7,-1784 # ffffffffc0216570 <pages>
ffffffffc0201c70:	000bb503          	ld	a0,0(s7)
ffffffffc0201c74:	00005b17          	auipc	s6,0x5
ffffffffc0201c78:	394b3b03          	ld	s6,916(s6) # ffffffffc0207008 <error_string+0x38>
ffffffffc0201c7c:	00080a37          	lui	s4,0x80
ffffffffc0201c80:	40a48533          	sub	a0,s1,a0
ffffffffc0201c84:	850d                	srai	a0,a0,0x3
ffffffffc0201c86:	03650533          	mul	a0,a0,s6
    page->ref = val;
ffffffffc0201c8a:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201c8c:	0009b703          	ld	a4,0(s3)
ffffffffc0201c90:	c09c                	sw	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201c92:	9552                	add	a0,a0,s4
ffffffffc0201c94:	00c51793          	slli	a5,a0,0xc
ffffffffc0201c98:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c9a:	0532                	slli	a0,a0,0xc
ffffffffc0201c9c:	08e7fd63          	bgeu	a5,a4,ffffffffc0201d36 <get_pte+0x1c2>
ffffffffc0201ca0:	000ab783          	ld	a5,0(s5)
ffffffffc0201ca4:	6605                	lui	a2,0x1
ffffffffc0201ca6:	4581                	li	a1,0
ffffffffc0201ca8:	953e                	add	a0,a0,a5
ffffffffc0201caa:	288030ef          	jal	ra,ffffffffc0204f32 <memset>
    return page - pages + nbase;
ffffffffc0201cae:	000bb683          	ld	a3,0(s7)
ffffffffc0201cb2:	40d486b3          	sub	a3,s1,a3
ffffffffc0201cb6:	868d                	srai	a3,a3,0x3
ffffffffc0201cb8:	036686b3          	mul	a3,a3,s6
ffffffffc0201cbc:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201cbe:	06aa                	slli	a3,a3,0xa
ffffffffc0201cc0:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201cc4:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201cc6:	0009b703          	ld	a4,0(s3)
ffffffffc0201cca:	068a                	slli	a3,a3,0x2
ffffffffc0201ccc:	757d                	lui	a0,0xfffff
ffffffffc0201cce:	8ee9                	and	a3,a3,a0
ffffffffc0201cd0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201cd4:	04e7f563          	bgeu	a5,a4,ffffffffc0201d1e <get_pte+0x1aa>
ffffffffc0201cd8:	000ab503          	ld	a0,0(s5)
ffffffffc0201cdc:	00c95913          	srli	s2,s2,0xc
ffffffffc0201ce0:	1ff97913          	andi	s2,s2,511
ffffffffc0201ce4:	96aa                	add	a3,a3,a0
ffffffffc0201ce6:	00391513          	slli	a0,s2,0x3
ffffffffc0201cea:	9536                	add	a0,a0,a3
}
ffffffffc0201cec:	60a6                	ld	ra,72(sp)
ffffffffc0201cee:	6406                	ld	s0,64(sp)
ffffffffc0201cf0:	74e2                	ld	s1,56(sp)
ffffffffc0201cf2:	7942                	ld	s2,48(sp)
ffffffffc0201cf4:	79a2                	ld	s3,40(sp)
ffffffffc0201cf6:	7a02                	ld	s4,32(sp)
ffffffffc0201cf8:	6ae2                	ld	s5,24(sp)
ffffffffc0201cfa:	6b42                	ld	s6,16(sp)
ffffffffc0201cfc:	6ba2                	ld	s7,8(sp)
ffffffffc0201cfe:	6161                	addi	sp,sp,80
ffffffffc0201d00:	8082                	ret
            return NULL;
ffffffffc0201d02:	4501                	li	a0,0
ffffffffc0201d04:	b7e5                	j	ffffffffc0201cec <get_pte+0x178>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d06:	00004617          	auipc	a2,0x4
ffffffffc0201d0a:	00260613          	addi	a2,a2,2 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc0201d0e:	0e400593          	li	a1,228
ffffffffc0201d12:	00004517          	auipc	a0,0x4
ffffffffc0201d16:	10e50513          	addi	a0,a0,270 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0201d1a:	f2cfe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201d1e:	00004617          	auipc	a2,0x4
ffffffffc0201d22:	fea60613          	addi	a2,a2,-22 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc0201d26:	0ef00593          	li	a1,239
ffffffffc0201d2a:	00004517          	auipc	a0,0x4
ffffffffc0201d2e:	0f650513          	addi	a0,a0,246 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0201d32:	f14fe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d36:	86aa                	mv	a3,a0
ffffffffc0201d38:	00004617          	auipc	a2,0x4
ffffffffc0201d3c:	fd060613          	addi	a2,a2,-48 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc0201d40:	0ec00593          	li	a1,236
ffffffffc0201d44:	00004517          	auipc	a0,0x4
ffffffffc0201d48:	0dc50513          	addi	a0,a0,220 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0201d4c:	efafe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d50:	86aa                	mv	a3,a0
ffffffffc0201d52:	00004617          	auipc	a2,0x4
ffffffffc0201d56:	fb660613          	addi	a2,a2,-74 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc0201d5a:	0e100593          	li	a1,225
ffffffffc0201d5e:	00004517          	auipc	a0,0x4
ffffffffc0201d62:	0c250513          	addi	a0,a0,194 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0201d66:	ee0fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201d6a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201d6a:	1141                	addi	sp,sp,-16
ffffffffc0201d6c:	e022                	sd	s0,0(sp)
ffffffffc0201d6e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d70:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201d72:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d74:	e01ff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201d78:	c011                	beqz	s0,ffffffffc0201d7c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201d7a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201d7c:	c511                	beqz	a0,ffffffffc0201d88 <get_page+0x1e>
ffffffffc0201d7e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201d80:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201d82:	0017f713          	andi	a4,a5,1
ffffffffc0201d86:	e709                	bnez	a4,ffffffffc0201d90 <get_page+0x26>
}
ffffffffc0201d88:	60a2                	ld	ra,8(sp)
ffffffffc0201d8a:	6402                	ld	s0,0(sp)
ffffffffc0201d8c:	0141                	addi	sp,sp,16
ffffffffc0201d8e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d90:	078a                	slli	a5,a5,0x2
ffffffffc0201d92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d94:	00014717          	auipc	a4,0x14
ffffffffc0201d98:	7d473703          	ld	a4,2004(a4) # ffffffffc0216568 <npage>
ffffffffc0201d9c:	02e7f263          	bgeu	a5,a4,ffffffffc0201dc0 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201da0:	fff80537          	lui	a0,0xfff80
ffffffffc0201da4:	97aa                	add	a5,a5,a0
ffffffffc0201da6:	60a2                	ld	ra,8(sp)
ffffffffc0201da8:	6402                	ld	s0,0(sp)
ffffffffc0201daa:	00379513          	slli	a0,a5,0x3
ffffffffc0201dae:	97aa                	add	a5,a5,a0
ffffffffc0201db0:	078e                	slli	a5,a5,0x3
ffffffffc0201db2:	00014517          	auipc	a0,0x14
ffffffffc0201db6:	7be53503          	ld	a0,1982(a0) # ffffffffc0216570 <pages>
ffffffffc0201dba:	953e                	add	a0,a0,a5
ffffffffc0201dbc:	0141                	addi	sp,sp,16
ffffffffc0201dbe:	8082                	ret
ffffffffc0201dc0:	c71ff0ef          	jal	ra,ffffffffc0201a30 <pa2page.part.0>

ffffffffc0201dc4 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201dc4:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201dc6:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201dc8:	ec26                	sd	s1,24(sp)
ffffffffc0201dca:	f406                	sd	ra,40(sp)
ffffffffc0201dcc:	f022                	sd	s0,32(sp)
ffffffffc0201dce:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201dd0:	da5ff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
    if (ptep != NULL) {
ffffffffc0201dd4:	c511                	beqz	a0,ffffffffc0201de0 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201dd6:	611c                	ld	a5,0(a0)
ffffffffc0201dd8:	842a                	mv	s0,a0
ffffffffc0201dda:	0017f713          	andi	a4,a5,1
ffffffffc0201dde:	e711                	bnez	a4,ffffffffc0201dea <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201de0:	70a2                	ld	ra,40(sp)
ffffffffc0201de2:	7402                	ld	s0,32(sp)
ffffffffc0201de4:	64e2                	ld	s1,24(sp)
ffffffffc0201de6:	6145                	addi	sp,sp,48
ffffffffc0201de8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dea:	078a                	slli	a5,a5,0x2
ffffffffc0201dec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dee:	00014717          	auipc	a4,0x14
ffffffffc0201df2:	77a73703          	ld	a4,1914(a4) # ffffffffc0216568 <npage>
ffffffffc0201df6:	06e7f663          	bgeu	a5,a4,ffffffffc0201e62 <page_remove+0x9e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dfa:	fff80737          	lui	a4,0xfff80
ffffffffc0201dfe:	97ba                	add	a5,a5,a4
ffffffffc0201e00:	00379513          	slli	a0,a5,0x3
ffffffffc0201e04:	97aa                	add	a5,a5,a0
ffffffffc0201e06:	078e                	slli	a5,a5,0x3
ffffffffc0201e08:	00014517          	auipc	a0,0x14
ffffffffc0201e0c:	76853503          	ld	a0,1896(a0) # ffffffffc0216570 <pages>
ffffffffc0201e10:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201e12:	411c                	lw	a5,0(a0)
ffffffffc0201e14:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201e18:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201e1a:	cb11                	beqz	a4,ffffffffc0201e2e <page_remove+0x6a>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201e1c:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201e20:	12048073          	sfence.vma	s1
}
ffffffffc0201e24:	70a2                	ld	ra,40(sp)
ffffffffc0201e26:	7402                	ld	s0,32(sp)
ffffffffc0201e28:	64e2                	ld	s1,24(sp)
ffffffffc0201e2a:	6145                	addi	sp,sp,48
ffffffffc0201e2c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e2e:	100027f3          	csrr	a5,sstatus
ffffffffc0201e32:	8b89                	andi	a5,a5,2
ffffffffc0201e34:	eb89                	bnez	a5,ffffffffc0201e46 <page_remove+0x82>
        pmm_manager->free_pages(base, n);
ffffffffc0201e36:	00014797          	auipc	a5,0x14
ffffffffc0201e3a:	7427b783          	ld	a5,1858(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201e3e:	739c                	ld	a5,32(a5)
ffffffffc0201e40:	4585                	li	a1,1
ffffffffc0201e42:	9782                	jalr	a5
    if (flag) {
ffffffffc0201e44:	bfe1                	j	ffffffffc0201e1c <page_remove+0x58>
        intr_disable();
ffffffffc0201e46:	e42a                	sd	a0,8(sp)
ffffffffc0201e48:	f7afe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201e4c:	00014797          	auipc	a5,0x14
ffffffffc0201e50:	72c7b783          	ld	a5,1836(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201e54:	739c                	ld	a5,32(a5)
ffffffffc0201e56:	6522                	ld	a0,8(sp)
ffffffffc0201e58:	4585                	li	a1,1
ffffffffc0201e5a:	9782                	jalr	a5
        intr_enable();
ffffffffc0201e5c:	f60fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201e60:	bf75                	j	ffffffffc0201e1c <page_remove+0x58>
ffffffffc0201e62:	bcfff0ef          	jal	ra,ffffffffc0201a30 <pa2page.part.0>

ffffffffc0201e66 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e66:	7139                	addi	sp,sp,-64
ffffffffc0201e68:	ec4e                	sd	s3,24(sp)
ffffffffc0201e6a:	89b2                	mv	s3,a2
ffffffffc0201e6c:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e6e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e70:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e72:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e74:	f426                	sd	s1,40(sp)
ffffffffc0201e76:	fc06                	sd	ra,56(sp)
ffffffffc0201e78:	f04a                	sd	s2,32(sp)
ffffffffc0201e7a:	e852                	sd	s4,16(sp)
ffffffffc0201e7c:	e456                	sd	s5,8(sp)
ffffffffc0201e7e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e80:	cf5ff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
    if (ptep == NULL) {
ffffffffc0201e84:	c17d                	beqz	a0,ffffffffc0201f6a <page_insert+0x104>
    page->ref += 1;
ffffffffc0201e86:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201e88:	611c                	ld	a5,0(a0)
ffffffffc0201e8a:	8a2a                	mv	s4,a0
ffffffffc0201e8c:	0016871b          	addiw	a4,a3,1
ffffffffc0201e90:	c018                	sw	a4,0(s0)
ffffffffc0201e92:	0017f713          	andi	a4,a5,1
ffffffffc0201e96:	e339                	bnez	a4,ffffffffc0201edc <page_insert+0x76>
    return page - pages + nbase;
ffffffffc0201e98:	00014797          	auipc	a5,0x14
ffffffffc0201e9c:	6d87b783          	ld	a5,1752(a5) # ffffffffc0216570 <pages>
ffffffffc0201ea0:	40f407b3          	sub	a5,s0,a5
ffffffffc0201ea4:	878d                	srai	a5,a5,0x3
ffffffffc0201ea6:	00005417          	auipc	s0,0x5
ffffffffc0201eaa:	16243403          	ld	s0,354(s0) # ffffffffc0207008 <error_string+0x38>
ffffffffc0201eae:	028787b3          	mul	a5,a5,s0
ffffffffc0201eb2:	00080437          	lui	s0,0x80
ffffffffc0201eb6:	97a2                	add	a5,a5,s0
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201eb8:	07aa                	slli	a5,a5,0xa
ffffffffc0201eba:	8cdd                	or	s1,s1,a5
ffffffffc0201ebc:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201ec0:	009a3023          	sd	s1,0(s4) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201ec4:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201ec8:	4501                	li	a0,0
}
ffffffffc0201eca:	70e2                	ld	ra,56(sp)
ffffffffc0201ecc:	7442                	ld	s0,48(sp)
ffffffffc0201ece:	74a2                	ld	s1,40(sp)
ffffffffc0201ed0:	7902                	ld	s2,32(sp)
ffffffffc0201ed2:	69e2                	ld	s3,24(sp)
ffffffffc0201ed4:	6a42                	ld	s4,16(sp)
ffffffffc0201ed6:	6aa2                	ld	s5,8(sp)
ffffffffc0201ed8:	6121                	addi	sp,sp,64
ffffffffc0201eda:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201edc:	00279713          	slli	a4,a5,0x2
ffffffffc0201ee0:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ee2:	00014797          	auipc	a5,0x14
ffffffffc0201ee6:	6867b783          	ld	a5,1670(a5) # ffffffffc0216568 <npage>
ffffffffc0201eea:	08f77263          	bgeu	a4,a5,ffffffffc0201f6e <page_insert+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eee:	fff807b7          	lui	a5,0xfff80
ffffffffc0201ef2:	973e                	add	a4,a4,a5
ffffffffc0201ef4:	00014a97          	auipc	s5,0x14
ffffffffc0201ef8:	67ca8a93          	addi	s5,s5,1660 # ffffffffc0216570 <pages>
ffffffffc0201efc:	000ab783          	ld	a5,0(s5)
ffffffffc0201f00:	00371913          	slli	s2,a4,0x3
ffffffffc0201f04:	993a                	add	s2,s2,a4
ffffffffc0201f06:	090e                	slli	s2,s2,0x3
ffffffffc0201f08:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201f0a:	01240c63          	beq	s0,s2,ffffffffc0201f22 <page_insert+0xbc>
    page->ref -= 1;
ffffffffc0201f0e:	00092703          	lw	a4,0(s2)
ffffffffc0201f12:	fff7069b          	addiw	a3,a4,-1
ffffffffc0201f16:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0201f1a:	c691                	beqz	a3,ffffffffc0201f26 <page_insert+0xc0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f1c:	12098073          	sfence.vma	s3
}
ffffffffc0201f20:	b741                	j	ffffffffc0201ea0 <page_insert+0x3a>
ffffffffc0201f22:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201f24:	bfb5                	j	ffffffffc0201ea0 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f26:	100027f3          	csrr	a5,sstatus
ffffffffc0201f2a:	8b89                	andi	a5,a5,2
ffffffffc0201f2c:	ef91                	bnez	a5,ffffffffc0201f48 <page_insert+0xe2>
        pmm_manager->free_pages(base, n);
ffffffffc0201f2e:	00014797          	auipc	a5,0x14
ffffffffc0201f32:	64a7b783          	ld	a5,1610(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201f36:	739c                	ld	a5,32(a5)
ffffffffc0201f38:	4585                	li	a1,1
ffffffffc0201f3a:	854a                	mv	a0,s2
ffffffffc0201f3c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0201f3e:	000ab783          	ld	a5,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f42:	12098073          	sfence.vma	s3
ffffffffc0201f46:	bfa9                	j	ffffffffc0201ea0 <page_insert+0x3a>
        intr_disable();
ffffffffc0201f48:	e7afe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f4c:	00014797          	auipc	a5,0x14
ffffffffc0201f50:	62c7b783          	ld	a5,1580(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201f54:	739c                	ld	a5,32(a5)
ffffffffc0201f56:	4585                	li	a1,1
ffffffffc0201f58:	854a                	mv	a0,s2
ffffffffc0201f5a:	9782                	jalr	a5
        intr_enable();
ffffffffc0201f5c:	e60fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201f60:	000ab783          	ld	a5,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f64:	12098073          	sfence.vma	s3
ffffffffc0201f68:	bf25                	j	ffffffffc0201ea0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201f6a:	5571                	li	a0,-4
ffffffffc0201f6c:	bfb9                	j	ffffffffc0201eca <page_insert+0x64>
ffffffffc0201f6e:	ac3ff0ef          	jal	ra,ffffffffc0201a30 <pa2page.part.0>

ffffffffc0201f72 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201f72:	00004797          	auipc	a5,0x4
ffffffffc0201f76:	d5e78793          	addi	a5,a5,-674 # ffffffffc0205cd0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201f7a:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201f7c:	7159                	addi	sp,sp,-112
ffffffffc0201f7e:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201f80:	00004517          	auipc	a0,0x4
ffffffffc0201f84:	eb050513          	addi	a0,a0,-336 # ffffffffc0205e30 <default_pmm_manager+0x160>
    pmm_manager = &default_pmm_manager;
ffffffffc0201f88:	00014b97          	auipc	s7,0x14
ffffffffc0201f8c:	5f0b8b93          	addi	s7,s7,1520 # ffffffffc0216578 <pmm_manager>
void pmm_init(void) {
ffffffffc0201f90:	f486                	sd	ra,104(sp)
ffffffffc0201f92:	eca6                	sd	s1,88(sp)
ffffffffc0201f94:	e4ce                	sd	s3,72(sp)
ffffffffc0201f96:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201f98:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201f9c:	f0a2                	sd	s0,96(sp)
ffffffffc0201f9e:	e8ca                	sd	s2,80(sp)
ffffffffc0201fa0:	e0d2                	sd	s4,64(sp)
ffffffffc0201fa2:	fc56                	sd	s5,56(sp)
ffffffffc0201fa4:	f062                	sd	s8,32(sp)
ffffffffc0201fa6:	ec66                	sd	s9,24(sp)
ffffffffc0201fa8:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201faa:	9d6fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc0201fae:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201fb2:	00014997          	auipc	s3,0x14
ffffffffc0201fb6:	5ce98993          	addi	s3,s3,1486 # ffffffffc0216580 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201fba:	00014497          	auipc	s1,0x14
ffffffffc0201fbe:	5ae48493          	addi	s1,s1,1454 # ffffffffc0216568 <npage>
    pmm_manager->init();
ffffffffc0201fc2:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201fc4:	00014b17          	auipc	s6,0x14
ffffffffc0201fc8:	5acb0b13          	addi	s6,s6,1452 # ffffffffc0216570 <pages>
    pmm_manager->init();
ffffffffc0201fcc:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201fce:	57f5                	li	a5,-3
ffffffffc0201fd0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201fd2:	00004517          	auipc	a0,0x4
ffffffffc0201fd6:	e7650513          	addi	a0,a0,-394 # ffffffffc0205e48 <default_pmm_manager+0x178>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201fda:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0201fde:	9a2fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201fe2:	46c5                	li	a3,17
ffffffffc0201fe4:	06ee                	slli	a3,a3,0x1b
ffffffffc0201fe6:	40100613          	li	a2,1025
ffffffffc0201fea:	16fd                	addi	a3,a3,-1
ffffffffc0201fec:	07e005b7          	lui	a1,0x7e00
ffffffffc0201ff0:	0656                	slli	a2,a2,0x15
ffffffffc0201ff2:	00004517          	auipc	a0,0x4
ffffffffc0201ff6:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205e60 <default_pmm_manager+0x190>
ffffffffc0201ffa:	986fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201ffe:	777d                	lui	a4,0xfffff
ffffffffc0202000:	00015797          	auipc	a5,0x15
ffffffffc0202004:	5cb78793          	addi	a5,a5,1483 # ffffffffc02175cb <end+0xfff>
ffffffffc0202008:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020200a:	00088737          	lui	a4,0x88
ffffffffc020200e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202010:	00fb3023          	sd	a5,0(s6)
ffffffffc0202014:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202016:	4701                	li	a4,0
ffffffffc0202018:	4585                	li	a1,1
ffffffffc020201a:	fff80837          	lui	a6,0xfff80
ffffffffc020201e:	a019                	j	ffffffffc0202024 <pmm_init+0xb2>
        SetPageReserved(pages + i);
ffffffffc0202020:	000b3783          	ld	a5,0(s6)
ffffffffc0202024:	97b6                	add	a5,a5,a3
ffffffffc0202026:	07a1                	addi	a5,a5,8
ffffffffc0202028:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020202c:	609c                	ld	a5,0(s1)
ffffffffc020202e:	0705                	addi	a4,a4,1
ffffffffc0202030:	04868693          	addi	a3,a3,72
ffffffffc0202034:	01078633          	add	a2,a5,a6
ffffffffc0202038:	fec764e3          	bltu	a4,a2,ffffffffc0202020 <pmm_init+0xae>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020203c:	000b3503          	ld	a0,0(s6)
ffffffffc0202040:	00379693          	slli	a3,a5,0x3
ffffffffc0202044:	96be                	add	a3,a3,a5
ffffffffc0202046:	fdc00737          	lui	a4,0xfdc00
ffffffffc020204a:	972a                	add	a4,a4,a0
ffffffffc020204c:	068e                	slli	a3,a3,0x3
ffffffffc020204e:	96ba                	add	a3,a3,a4
ffffffffc0202050:	c0200737          	lui	a4,0xc0200
ffffffffc0202054:	66e6e163          	bltu	a3,a4,ffffffffc02026b6 <pmm_init+0x744>
ffffffffc0202058:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020205c:	4645                	li	a2,17
ffffffffc020205e:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202060:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202062:	4ec6ee63          	bltu	a3,a2,ffffffffc020255e <pmm_init+0x5ec>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202066:	00004517          	auipc	a0,0x4
ffffffffc020206a:	e2250513          	addi	a0,a0,-478 # ffffffffc0205e88 <default_pmm_manager+0x1b8>
ffffffffc020206e:	912fe0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202072:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202076:	00014917          	auipc	s2,0x14
ffffffffc020207a:	4ea90913          	addi	s2,s2,1258 # ffffffffc0216560 <boot_pgdir>
    pmm_manager->check();
ffffffffc020207e:	7b9c                	ld	a5,48(a5)
ffffffffc0202080:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202082:	00004517          	auipc	a0,0x4
ffffffffc0202086:	e1e50513          	addi	a0,a0,-482 # ffffffffc0205ea0 <default_pmm_manager+0x1d0>
ffffffffc020208a:	8f6fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020208e:	00008697          	auipc	a3,0x8
ffffffffc0202092:	f7268693          	addi	a3,a3,-142 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202096:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020209a:	c02007b7          	lui	a5,0xc0200
ffffffffc020209e:	62f6e863          	bltu	a3,a5,ffffffffc02026ce <pmm_init+0x75c>
ffffffffc02020a2:	0009b783          	ld	a5,0(s3)
ffffffffc02020a6:	8e9d                	sub	a3,a3,a5
ffffffffc02020a8:	00014797          	auipc	a5,0x14
ffffffffc02020ac:	4ad7b823          	sd	a3,1200(a5) # ffffffffc0216558 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020b0:	100027f3          	csrr	a5,sstatus
ffffffffc02020b4:	8b89                	andi	a5,a5,2
ffffffffc02020b6:	4c079e63          	bnez	a5,ffffffffc0202592 <pmm_init+0x620>
        ret = pmm_manager->nr_free_pages();
ffffffffc02020ba:	000bb783          	ld	a5,0(s7)
ffffffffc02020be:	779c                	ld	a5,40(a5)
ffffffffc02020c0:	9782                	jalr	a5
ffffffffc02020c2:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02020c4:	6098                	ld	a4,0(s1)
ffffffffc02020c6:	c80007b7          	lui	a5,0xc8000
ffffffffc02020ca:	83b1                	srli	a5,a5,0xc
ffffffffc02020cc:	62e7ed63          	bltu	a5,a4,ffffffffc0202706 <pmm_init+0x794>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02020d0:	00093503          	ld	a0,0(s2)
ffffffffc02020d4:	60050963          	beqz	a0,ffffffffc02026e6 <pmm_init+0x774>
ffffffffc02020d8:	03451793          	slli	a5,a0,0x34
ffffffffc02020dc:	60079563          	bnez	a5,ffffffffc02026e6 <pmm_init+0x774>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02020e0:	4601                	li	a2,0
ffffffffc02020e2:	4581                	li	a1,0
ffffffffc02020e4:	c87ff0ef          	jal	ra,ffffffffc0201d6a <get_page>
ffffffffc02020e8:	68051163          	bnez	a0,ffffffffc020276a <pmm_init+0x7f8>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02020ec:	4505                	li	a0,1
ffffffffc02020ee:	97bff0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc02020f2:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02020f4:	00093503          	ld	a0,0(s2)
ffffffffc02020f8:	4681                	li	a3,0
ffffffffc02020fa:	4601                	li	a2,0
ffffffffc02020fc:	85d2                	mv	a1,s4
ffffffffc02020fe:	d69ff0ef          	jal	ra,ffffffffc0201e66 <page_insert>
ffffffffc0202102:	64051463          	bnez	a0,ffffffffc020274a <pmm_init+0x7d8>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202106:	00093503          	ld	a0,0(s2)
ffffffffc020210a:	4601                	li	a2,0
ffffffffc020210c:	4581                	li	a1,0
ffffffffc020210e:	a67ff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
ffffffffc0202112:	60050c63          	beqz	a0,ffffffffc020272a <pmm_init+0x7b8>
    assert(pte2page(*ptep) == p1);
ffffffffc0202116:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202118:	0017f713          	andi	a4,a5,1
ffffffffc020211c:	60070563          	beqz	a4,ffffffffc0202726 <pmm_init+0x7b4>
    if (PPN(pa) >= npage) {
ffffffffc0202120:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202122:	078a                	slli	a5,a5,0x2
ffffffffc0202124:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202126:	58c7f663          	bgeu	a5,a2,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc020212a:	fff80737          	lui	a4,0xfff80
ffffffffc020212e:	97ba                	add	a5,a5,a4
ffffffffc0202130:	000b3683          	ld	a3,0(s6)
ffffffffc0202134:	00379713          	slli	a4,a5,0x3
ffffffffc0202138:	97ba                	add	a5,a5,a4
ffffffffc020213a:	078e                	slli	a5,a5,0x3
ffffffffc020213c:	97b6                	add	a5,a5,a3
ffffffffc020213e:	14fa1fe3          	bne	s4,a5,ffffffffc0202a9c <pmm_init+0xb2a>
    assert(page_ref(p1) == 1);
ffffffffc0202142:	000a2703          	lw	a4,0(s4)
ffffffffc0202146:	4785                	li	a5,1
ffffffffc0202148:	18f716e3          	bne	a4,a5,ffffffffc0202ad4 <pmm_init+0xb62>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020214c:	00093503          	ld	a0,0(s2)
ffffffffc0202150:	77fd                	lui	a5,0xfffff
ffffffffc0202152:	6114                	ld	a3,0(a0)
ffffffffc0202154:	068a                	slli	a3,a3,0x2
ffffffffc0202156:	8efd                	and	a3,a3,a5
ffffffffc0202158:	00c6d713          	srli	a4,a3,0xc
ffffffffc020215c:	16c770e3          	bgeu	a4,a2,ffffffffc0202abc <pmm_init+0xb4a>
ffffffffc0202160:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202164:	96e2                	add	a3,a3,s8
ffffffffc0202166:	0006ba83          	ld	s5,0(a3)
ffffffffc020216a:	0a8a                	slli	s5,s5,0x2
ffffffffc020216c:	00fafab3          	and	s5,s5,a5
ffffffffc0202170:	00cad793          	srli	a5,s5,0xc
ffffffffc0202174:	66c7fb63          	bgeu	a5,a2,ffffffffc02027ea <pmm_init+0x878>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202178:	4601                	li	a2,0
ffffffffc020217a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020217c:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020217e:	9f7ff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202182:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202184:	65551363          	bne	a0,s5,ffffffffc02027ca <pmm_init+0x858>

    p2 = alloc_page();
ffffffffc0202188:	4505                	li	a0,1
ffffffffc020218a:	8dfff0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc020218e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202190:	00093503          	ld	a0,0(s2)
ffffffffc0202194:	46d1                	li	a3,20
ffffffffc0202196:	6605                	lui	a2,0x1
ffffffffc0202198:	85d6                	mv	a1,s5
ffffffffc020219a:	ccdff0ef          	jal	ra,ffffffffc0201e66 <page_insert>
ffffffffc020219e:	5e051663          	bnez	a0,ffffffffc020278a <pmm_init+0x818>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02021a2:	00093503          	ld	a0,0(s2)
ffffffffc02021a6:	4601                	li	a2,0
ffffffffc02021a8:	6585                	lui	a1,0x1
ffffffffc02021aa:	9cbff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
ffffffffc02021ae:	140503e3          	beqz	a0,ffffffffc0202af4 <pmm_init+0xb82>
    assert(*ptep & PTE_U);
ffffffffc02021b2:	611c                	ld	a5,0(a0)
ffffffffc02021b4:	0107f713          	andi	a4,a5,16
ffffffffc02021b8:	74070663          	beqz	a4,ffffffffc0202904 <pmm_init+0x992>
    assert(*ptep & PTE_W);
ffffffffc02021bc:	8b91                	andi	a5,a5,4
ffffffffc02021be:	70078363          	beqz	a5,ffffffffc02028c4 <pmm_init+0x952>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02021c2:	00093503          	ld	a0,0(s2)
ffffffffc02021c6:	611c                	ld	a5,0(a0)
ffffffffc02021c8:	8bc1                	andi	a5,a5,16
ffffffffc02021ca:	6c078d63          	beqz	a5,ffffffffc02028a4 <pmm_init+0x932>
    assert(page_ref(p2) == 1);
ffffffffc02021ce:	000aa703          	lw	a4,0(s5)
ffffffffc02021d2:	4785                	li	a5,1
ffffffffc02021d4:	5cf71b63          	bne	a4,a5,ffffffffc02027aa <pmm_init+0x838>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02021d8:	4681                	li	a3,0
ffffffffc02021da:	6605                	lui	a2,0x1
ffffffffc02021dc:	85d2                	mv	a1,s4
ffffffffc02021de:	c89ff0ef          	jal	ra,ffffffffc0201e66 <page_insert>
ffffffffc02021e2:	68051163          	bnez	a0,ffffffffc0202864 <pmm_init+0x8f2>
    assert(page_ref(p1) == 2);
ffffffffc02021e6:	000a2703          	lw	a4,0(s4)
ffffffffc02021ea:	4789                	li	a5,2
ffffffffc02021ec:	64f71c63          	bne	a4,a5,ffffffffc0202844 <pmm_init+0x8d2>
    assert(page_ref(p2) == 0);
ffffffffc02021f0:	000aa783          	lw	a5,0(s5)
ffffffffc02021f4:	62079863          	bnez	a5,ffffffffc0202824 <pmm_init+0x8b2>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02021f8:	00093503          	ld	a0,0(s2)
ffffffffc02021fc:	4601                	li	a2,0
ffffffffc02021fe:	6585                	lui	a1,0x1
ffffffffc0202200:	975ff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
ffffffffc0202204:	60050063          	beqz	a0,ffffffffc0202804 <pmm_init+0x892>
    assert(pte2page(*ptep) == p1);
ffffffffc0202208:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020220a:	00177793          	andi	a5,a4,1
ffffffffc020220e:	50078c63          	beqz	a5,ffffffffc0202726 <pmm_init+0x7b4>
    if (PPN(pa) >= npage) {
ffffffffc0202212:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202214:	00271793          	slli	a5,a4,0x2
ffffffffc0202218:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020221a:	48d7fc63          	bgeu	a5,a3,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc020221e:	fff806b7          	lui	a3,0xfff80
ffffffffc0202222:	97b6                	add	a5,a5,a3
ffffffffc0202224:	000b3603          	ld	a2,0(s6)
ffffffffc0202228:	00379693          	slli	a3,a5,0x3
ffffffffc020222c:	97b6                	add	a5,a5,a3
ffffffffc020222e:	078e                	slli	a5,a5,0x3
ffffffffc0202230:	97b2                	add	a5,a5,a2
ffffffffc0202232:	72fa1963          	bne	s4,a5,ffffffffc0202964 <pmm_init+0x9f2>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202236:	8b41                	andi	a4,a4,16
ffffffffc0202238:	70071663          	bnez	a4,ffffffffc0202944 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc020223c:	00093503          	ld	a0,0(s2)
ffffffffc0202240:	4581                	li	a1,0
ffffffffc0202242:	b83ff0ef          	jal	ra,ffffffffc0201dc4 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202246:	000a2703          	lw	a4,0(s4)
ffffffffc020224a:	4785                	li	a5,1
ffffffffc020224c:	6cf71c63          	bne	a4,a5,ffffffffc0202924 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0202250:	000aa783          	lw	a5,0(s5)
ffffffffc0202254:	7a079463          	bnez	a5,ffffffffc02029fc <pmm_init+0xa8a>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202258:	00093503          	ld	a0,0(s2)
ffffffffc020225c:	6585                	lui	a1,0x1
ffffffffc020225e:	b67ff0ef          	jal	ra,ffffffffc0201dc4 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202262:	000a2783          	lw	a5,0(s4)
ffffffffc0202266:	76079b63          	bnez	a5,ffffffffc02029dc <pmm_init+0xa6a>
    assert(page_ref(p2) == 0);
ffffffffc020226a:	000aa783          	lw	a5,0(s5)
ffffffffc020226e:	74079763          	bnez	a5,ffffffffc02029bc <pmm_init+0xa4a>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202272:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202276:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202278:	000a3783          	ld	a5,0(s4)
ffffffffc020227c:	078a                	slli	a5,a5,0x2
ffffffffc020227e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202280:	42c7f963          	bgeu	a5,a2,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc0202284:	fff80737          	lui	a4,0xfff80
ffffffffc0202288:	973e                	add	a4,a4,a5
ffffffffc020228a:	00371793          	slli	a5,a4,0x3
ffffffffc020228e:	000b3503          	ld	a0,0(s6)
ffffffffc0202292:	97ba                	add	a5,a5,a4
ffffffffc0202294:	078e                	slli	a5,a5,0x3
    return page->ref;
ffffffffc0202296:	00f50733          	add	a4,a0,a5
ffffffffc020229a:	4314                	lw	a3,0(a4)
ffffffffc020229c:	4705                	li	a4,1
ffffffffc020229e:	6ee69f63          	bne	a3,a4,ffffffffc020299c <pmm_init+0xa2a>
    return page - pages + nbase;
ffffffffc02022a2:	4037d693          	srai	a3,a5,0x3
ffffffffc02022a6:	00005c97          	auipc	s9,0x5
ffffffffc02022aa:	d62cbc83          	ld	s9,-670(s9) # ffffffffc0207008 <error_string+0x38>
ffffffffc02022ae:	039686b3          	mul	a3,a3,s9
ffffffffc02022b2:	000805b7          	lui	a1,0x80
ffffffffc02022b6:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02022b8:	00c69713          	slli	a4,a3,0xc
ffffffffc02022bc:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02022be:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02022c0:	6cc77263          	bgeu	a4,a2,ffffffffc0202984 <pmm_init+0xa12>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02022c4:	0009b703          	ld	a4,0(s3)
ffffffffc02022c8:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02022ca:	629c                	ld	a5,0(a3)
ffffffffc02022cc:	078a                	slli	a5,a5,0x2
ffffffffc02022ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022d0:	3ec7f163          	bgeu	a5,a2,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc02022d4:	8f8d                	sub	a5,a5,a1
ffffffffc02022d6:	00379713          	slli	a4,a5,0x3
ffffffffc02022da:	97ba                	add	a5,a5,a4
ffffffffc02022dc:	078e                	slli	a5,a5,0x3
ffffffffc02022de:	953e                	add	a0,a0,a5
ffffffffc02022e0:	100027f3          	csrr	a5,sstatus
ffffffffc02022e4:	8b89                	andi	a5,a5,2
ffffffffc02022e6:	30079063          	bnez	a5,ffffffffc02025e6 <pmm_init+0x674>
        pmm_manager->free_pages(base, n);
ffffffffc02022ea:	000bb783          	ld	a5,0(s7)
ffffffffc02022ee:	4585                	li	a1,1
ffffffffc02022f0:	739c                	ld	a5,32(a5)
ffffffffc02022f2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02022f4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02022f8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022fa:	078a                	slli	a5,a5,0x2
ffffffffc02022fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022fe:	3ae7fa63          	bgeu	a5,a4,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc0202302:	fff80737          	lui	a4,0xfff80
ffffffffc0202306:	97ba                	add	a5,a5,a4
ffffffffc0202308:	000b3503          	ld	a0,0(s6)
ffffffffc020230c:	00379713          	slli	a4,a5,0x3
ffffffffc0202310:	97ba                	add	a5,a5,a4
ffffffffc0202312:	078e                	slli	a5,a5,0x3
ffffffffc0202314:	953e                	add	a0,a0,a5
ffffffffc0202316:	100027f3          	csrr	a5,sstatus
ffffffffc020231a:	8b89                	andi	a5,a5,2
ffffffffc020231c:	2a079963          	bnez	a5,ffffffffc02025ce <pmm_init+0x65c>
ffffffffc0202320:	000bb783          	ld	a5,0(s7)
ffffffffc0202324:	4585                	li	a1,1
ffffffffc0202326:	739c                	ld	a5,32(a5)
ffffffffc0202328:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020232a:	00093783          	ld	a5,0(s2)
ffffffffc020232e:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fde8a34>
  asm volatile("sfence.vma");
ffffffffc0202332:	12000073          	sfence.vma
ffffffffc0202336:	100027f3          	csrr	a5,sstatus
ffffffffc020233a:	8b89                	andi	a5,a5,2
ffffffffc020233c:	26079f63          	bnez	a5,ffffffffc02025ba <pmm_init+0x648>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202340:	000bb783          	ld	a5,0(s7)
ffffffffc0202344:	779c                	ld	a5,40(a5)
ffffffffc0202346:	9782                	jalr	a5
ffffffffc0202348:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020234a:	73441963          	bne	s0,s4,ffffffffc0202a7c <pmm_init+0xb0a>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020234e:	00004517          	auipc	a0,0x4
ffffffffc0202352:	e3a50513          	addi	a0,a0,-454 # ffffffffc0206188 <default_pmm_manager+0x4b8>
ffffffffc0202356:	e2bfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020235a:	100027f3          	csrr	a5,sstatus
ffffffffc020235e:	8b89                	andi	a5,a5,2
ffffffffc0202360:	24079363          	bnez	a5,ffffffffc02025a6 <pmm_init+0x634>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202364:	000bb783          	ld	a5,0(s7)
ffffffffc0202368:	779c                	ld	a5,40(a5)
ffffffffc020236a:	9782                	jalr	a5
ffffffffc020236c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020236e:	6098                	ld	a4,0(s1)
ffffffffc0202370:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202374:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202376:	00c71793          	slli	a5,a4,0xc
ffffffffc020237a:	6a05                	lui	s4,0x1
ffffffffc020237c:	02f47c63          	bgeu	s0,a5,ffffffffc02023b4 <pmm_init+0x442>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202380:	00c45793          	srli	a5,s0,0xc
ffffffffc0202384:	00093503          	ld	a0,0(s2)
ffffffffc0202388:	30e7f863          	bgeu	a5,a4,ffffffffc0202698 <pmm_init+0x726>
ffffffffc020238c:	0009b583          	ld	a1,0(s3)
ffffffffc0202390:	4601                	li	a2,0
ffffffffc0202392:	95a2                	add	a1,a1,s0
ffffffffc0202394:	fe0ff0ef          	jal	ra,ffffffffc0201b74 <get_pte>
ffffffffc0202398:	2e050063          	beqz	a0,ffffffffc0202678 <pmm_init+0x706>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020239c:	611c                	ld	a5,0(a0)
ffffffffc020239e:	078a                	slli	a5,a5,0x2
ffffffffc02023a0:	0157f7b3          	and	a5,a5,s5
ffffffffc02023a4:	2a879a63          	bne	a5,s0,ffffffffc0202658 <pmm_init+0x6e6>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023a8:	6098                	ld	a4,0(s1)
ffffffffc02023aa:	9452                	add	s0,s0,s4
ffffffffc02023ac:	00c71793          	slli	a5,a4,0xc
ffffffffc02023b0:	fcf468e3          	bltu	s0,a5,ffffffffc0202380 <pmm_init+0x40e>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02023b4:	00093783          	ld	a5,0(s2)
ffffffffc02023b8:	639c                	ld	a5,0(a5)
ffffffffc02023ba:	6a079163          	bnez	a5,ffffffffc0202a5c <pmm_init+0xaea>

    struct Page *p;
    p = alloc_page();
ffffffffc02023be:	4505                	li	a0,1
ffffffffc02023c0:	ea8ff0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc02023c4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02023c6:	00093503          	ld	a0,0(s2)
ffffffffc02023ca:	4699                	li	a3,6
ffffffffc02023cc:	10000613          	li	a2,256
ffffffffc02023d0:	85d6                	mv	a1,s5
ffffffffc02023d2:	a95ff0ef          	jal	ra,ffffffffc0201e66 <page_insert>
ffffffffc02023d6:	66051363          	bnez	a0,ffffffffc0202a3c <pmm_init+0xaca>
    assert(page_ref(p) == 1);
ffffffffc02023da:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde8a34>
ffffffffc02023de:	4785                	li	a5,1
ffffffffc02023e0:	62f71e63          	bne	a4,a5,ffffffffc0202a1c <pmm_init+0xaaa>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023e4:	00093503          	ld	a0,0(s2)
ffffffffc02023e8:	6405                	lui	s0,0x1
ffffffffc02023ea:	4699                	li	a3,6
ffffffffc02023ec:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02023f0:	85d6                	mv	a1,s5
ffffffffc02023f2:	a75ff0ef          	jal	ra,ffffffffc0201e66 <page_insert>
ffffffffc02023f6:	48051763          	bnez	a0,ffffffffc0202884 <pmm_init+0x912>
    assert(page_ref(p) == 2);
ffffffffc02023fa:	000aa703          	lw	a4,0(s5)
ffffffffc02023fe:	4789                	li	a5,2
ffffffffc0202400:	74f71a63          	bne	a4,a5,ffffffffc0202b54 <pmm_init+0xbe2>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202404:	00004597          	auipc	a1,0x4
ffffffffc0202408:	ebc58593          	addi	a1,a1,-324 # ffffffffc02062c0 <default_pmm_manager+0x5f0>
ffffffffc020240c:	10000513          	li	a0,256
ffffffffc0202410:	2dd020ef          	jal	ra,ffffffffc0204eec <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202414:	10040593          	addi	a1,s0,256
ffffffffc0202418:	10000513          	li	a0,256
ffffffffc020241c:	2e3020ef          	jal	ra,ffffffffc0204efe <strcmp>
ffffffffc0202420:	70051a63          	bnez	a0,ffffffffc0202b34 <pmm_init+0xbc2>
    return page - pages + nbase;
ffffffffc0202424:	000b3683          	ld	a3,0(s6)
ffffffffc0202428:	00080d37          	lui	s10,0x80
    return KADDR(page2pa(page));
ffffffffc020242c:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc020242e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202432:	868d                	srai	a3,a3,0x3
ffffffffc0202434:	039686b3          	mul	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0202438:	609c                	ld	a5,0(s1)
ffffffffc020243a:	8031                	srli	s0,s0,0xc
    return page - pages + nbase;
ffffffffc020243c:	96ea                	add	a3,a3,s10
    return KADDR(page2pa(page));
ffffffffc020243e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202442:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202444:	54f77063          	bgeu	a4,a5,ffffffffc0202984 <pmm_init+0xa12>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202448:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020244c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202450:	96be                	add	a3,a3,a5
ffffffffc0202452:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd69b34>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202456:	261020ef          	jal	ra,ffffffffc0204eb6 <strlen>
ffffffffc020245a:	6a051d63          	bnez	a0,ffffffffc0202b14 <pmm_init+0xba2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020245e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202462:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202464:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202468:	078a                	slli	a5,a5,0x2
ffffffffc020246a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020246c:	24e7f363          	bgeu	a5,a4,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc0202470:	41a787b3          	sub	a5,a5,s10
ffffffffc0202474:	00379693          	slli	a3,a5,0x3
    return page - pages + nbase;
ffffffffc0202478:	96be                	add	a3,a3,a5
ffffffffc020247a:	03968cb3          	mul	s9,a3,s9
ffffffffc020247e:	01ac86b3          	add	a3,s9,s10
    return KADDR(page2pa(page));
ffffffffc0202482:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202484:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202486:	4ee47f63          	bgeu	s0,a4,ffffffffc0202984 <pmm_init+0xa12>
ffffffffc020248a:	0009b403          	ld	s0,0(s3)
ffffffffc020248e:	9436                	add	s0,s0,a3
ffffffffc0202490:	100027f3          	csrr	a5,sstatus
ffffffffc0202494:	8b89                	andi	a5,a5,2
ffffffffc0202496:	1a079663          	bnez	a5,ffffffffc0202642 <pmm_init+0x6d0>
        pmm_manager->free_pages(base, n);
ffffffffc020249a:	000bb783          	ld	a5,0(s7)
ffffffffc020249e:	4585                	li	a1,1
ffffffffc02024a0:	8556                	mv	a0,s5
ffffffffc02024a2:	739c                	ld	a5,32(a5)
ffffffffc02024a4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02024a6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02024a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024aa:	078a                	slli	a5,a5,0x2
ffffffffc02024ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024ae:	20e7f263          	bgeu	a5,a4,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc02024b2:	fff80737          	lui	a4,0xfff80
ffffffffc02024b6:	97ba                	add	a5,a5,a4
ffffffffc02024b8:	000b3503          	ld	a0,0(s6)
ffffffffc02024bc:	00379713          	slli	a4,a5,0x3
ffffffffc02024c0:	97ba                	add	a5,a5,a4
ffffffffc02024c2:	078e                	slli	a5,a5,0x3
ffffffffc02024c4:	953e                	add	a0,a0,a5
ffffffffc02024c6:	100027f3          	csrr	a5,sstatus
ffffffffc02024ca:	8b89                	andi	a5,a5,2
ffffffffc02024cc:	14079f63          	bnez	a5,ffffffffc020262a <pmm_init+0x6b8>
ffffffffc02024d0:	000bb783          	ld	a5,0(s7)
ffffffffc02024d4:	4585                	li	a1,1
ffffffffc02024d6:	739c                	ld	a5,32(a5)
ffffffffc02024d8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02024da:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02024de:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024e0:	078a                	slli	a5,a5,0x2
ffffffffc02024e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024e4:	1ce7f763          	bgeu	a5,a4,ffffffffc02026b2 <pmm_init+0x740>
    return &pages[PPN(pa) - nbase];
ffffffffc02024e8:	fff80737          	lui	a4,0xfff80
ffffffffc02024ec:	97ba                	add	a5,a5,a4
ffffffffc02024ee:	000b3503          	ld	a0,0(s6)
ffffffffc02024f2:	00379713          	slli	a4,a5,0x3
ffffffffc02024f6:	97ba                	add	a5,a5,a4
ffffffffc02024f8:	078e                	slli	a5,a5,0x3
ffffffffc02024fa:	953e                	add	a0,a0,a5
ffffffffc02024fc:	100027f3          	csrr	a5,sstatus
ffffffffc0202500:	8b89                	andi	a5,a5,2
ffffffffc0202502:	10079863          	bnez	a5,ffffffffc0202612 <pmm_init+0x6a0>
ffffffffc0202506:	000bb783          	ld	a5,0(s7)
ffffffffc020250a:	4585                	li	a1,1
ffffffffc020250c:	739c                	ld	a5,32(a5)
ffffffffc020250e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202510:	00093783          	ld	a5,0(s2)
ffffffffc0202514:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202518:	12000073          	sfence.vma
ffffffffc020251c:	100027f3          	csrr	a5,sstatus
ffffffffc0202520:	8b89                	andi	a5,a5,2
ffffffffc0202522:	0c079e63          	bnez	a5,ffffffffc02025fe <pmm_init+0x68c>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202526:	000bb783          	ld	a5,0(s7)
ffffffffc020252a:	779c                	ld	a5,40(a5)
ffffffffc020252c:	9782                	jalr	a5
ffffffffc020252e:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202530:	3a8c1a63          	bne	s8,s0,ffffffffc02028e4 <pmm_init+0x972>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202534:	00004517          	auipc	a0,0x4
ffffffffc0202538:	e0450513          	addi	a0,a0,-508 # ffffffffc0206338 <default_pmm_manager+0x668>
ffffffffc020253c:	c45fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202540:	7406                	ld	s0,96(sp)
ffffffffc0202542:	70a6                	ld	ra,104(sp)
ffffffffc0202544:	64e6                	ld	s1,88(sp)
ffffffffc0202546:	6946                	ld	s2,80(sp)
ffffffffc0202548:	69a6                	ld	s3,72(sp)
ffffffffc020254a:	6a06                	ld	s4,64(sp)
ffffffffc020254c:	7ae2                	ld	s5,56(sp)
ffffffffc020254e:	7b42                	ld	s6,48(sp)
ffffffffc0202550:	7ba2                	ld	s7,40(sp)
ffffffffc0202552:	7c02                	ld	s8,32(sp)
ffffffffc0202554:	6ce2                	ld	s9,24(sp)
ffffffffc0202556:	6d42                	ld	s10,16(sp)
ffffffffc0202558:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc020255a:	b0aff06f          	j	ffffffffc0201864 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020255e:	6705                	lui	a4,0x1
ffffffffc0202560:	177d                	addi	a4,a4,-1
ffffffffc0202562:	96ba                	add	a3,a3,a4
ffffffffc0202564:	777d                	lui	a4,0xfffff
ffffffffc0202566:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0202568:	00c75693          	srli	a3,a4,0xc
ffffffffc020256c:	14f6f363          	bgeu	a3,a5,ffffffffc02026b2 <pmm_init+0x740>
    pmm_manager->init_memmap(base, n);
ffffffffc0202570:	000bb583          	ld	a1,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202574:	9836                	add	a6,a6,a3
ffffffffc0202576:	00381793          	slli	a5,a6,0x3
ffffffffc020257a:	6994                	ld	a3,16(a1)
ffffffffc020257c:	97c2                	add	a5,a5,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020257e:	40e60733          	sub	a4,a2,a4
ffffffffc0202582:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202584:	00c75593          	srli	a1,a4,0xc
ffffffffc0202588:	953e                	add	a0,a0,a5
ffffffffc020258a:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020258c:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202590:	bcd9                	j	ffffffffc0202066 <pmm_init+0xf4>
        intr_disable();
ffffffffc0202592:	830fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202596:	000bb783          	ld	a5,0(s7)
ffffffffc020259a:	779c                	ld	a5,40(a5)
ffffffffc020259c:	9782                	jalr	a5
ffffffffc020259e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02025a0:	81cfe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025a4:	b605                	j	ffffffffc02020c4 <pmm_init+0x152>
        intr_disable();
ffffffffc02025a6:	81cfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02025aa:	000bb783          	ld	a5,0(s7)
ffffffffc02025ae:	779c                	ld	a5,40(a5)
ffffffffc02025b0:	9782                	jalr	a5
ffffffffc02025b2:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02025b4:	808fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025b8:	bb5d                	j	ffffffffc020236e <pmm_init+0x3fc>
        intr_disable();
ffffffffc02025ba:	808fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02025be:	000bb783          	ld	a5,0(s7)
ffffffffc02025c2:	779c                	ld	a5,40(a5)
ffffffffc02025c4:	9782                	jalr	a5
ffffffffc02025c6:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02025c8:	ff5fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025cc:	bbbd                	j	ffffffffc020234a <pmm_init+0x3d8>
ffffffffc02025ce:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02025d0:	ff3fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025d4:	000bb783          	ld	a5,0(s7)
ffffffffc02025d8:	6522                	ld	a0,8(sp)
ffffffffc02025da:	4585                	li	a1,1
ffffffffc02025dc:	739c                	ld	a5,32(a5)
ffffffffc02025de:	9782                	jalr	a5
        intr_enable();
ffffffffc02025e0:	fddfd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025e4:	b399                	j	ffffffffc020232a <pmm_init+0x3b8>
ffffffffc02025e6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02025e8:	fdbfd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02025ec:	000bb783          	ld	a5,0(s7)
ffffffffc02025f0:	6522                	ld	a0,8(sp)
ffffffffc02025f2:	4585                	li	a1,1
ffffffffc02025f4:	739c                	ld	a5,32(a5)
ffffffffc02025f6:	9782                	jalr	a5
        intr_enable();
ffffffffc02025f8:	fc5fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025fc:	b9e5                	j	ffffffffc02022f4 <pmm_init+0x382>
        intr_disable();
ffffffffc02025fe:	fc5fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202602:	000bb783          	ld	a5,0(s7)
ffffffffc0202606:	779c                	ld	a5,40(a5)
ffffffffc0202608:	9782                	jalr	a5
ffffffffc020260a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020260c:	fb1fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202610:	b705                	j	ffffffffc0202530 <pmm_init+0x5be>
ffffffffc0202612:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202614:	faffd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202618:	000bb783          	ld	a5,0(s7)
ffffffffc020261c:	6522                	ld	a0,8(sp)
ffffffffc020261e:	4585                	li	a1,1
ffffffffc0202620:	739c                	ld	a5,32(a5)
ffffffffc0202622:	9782                	jalr	a5
        intr_enable();
ffffffffc0202624:	f99fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202628:	b5e5                	j	ffffffffc0202510 <pmm_init+0x59e>
ffffffffc020262a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020262c:	f97fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202630:	000bb783          	ld	a5,0(s7)
ffffffffc0202634:	6522                	ld	a0,8(sp)
ffffffffc0202636:	4585                	li	a1,1
ffffffffc0202638:	739c                	ld	a5,32(a5)
ffffffffc020263a:	9782                	jalr	a5
        intr_enable();
ffffffffc020263c:	f81fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202640:	bd69                	j	ffffffffc02024da <pmm_init+0x568>
        intr_disable();
ffffffffc0202642:	f81fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202646:	000bb783          	ld	a5,0(s7)
ffffffffc020264a:	4585                	li	a1,1
ffffffffc020264c:	8556                	mv	a0,s5
ffffffffc020264e:	739c                	ld	a5,32(a5)
ffffffffc0202650:	9782                	jalr	a5
        intr_enable();
ffffffffc0202652:	f6bfd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202656:	bd81                	j	ffffffffc02024a6 <pmm_init+0x534>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202658:	00004697          	auipc	a3,0x4
ffffffffc020265c:	b9068693          	addi	a3,a3,-1136 # ffffffffc02061e8 <default_pmm_manager+0x518>
ffffffffc0202660:	00003617          	auipc	a2,0x3
ffffffffc0202664:	2c060613          	addi	a2,a2,704 # ffffffffc0205920 <commands+0x738>
ffffffffc0202668:	19e00593          	li	a1,414
ffffffffc020266c:	00003517          	auipc	a0,0x3
ffffffffc0202670:	7b450513          	addi	a0,a0,1972 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202674:	dd3fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202678:	00004697          	auipc	a3,0x4
ffffffffc020267c:	b3068693          	addi	a3,a3,-1232 # ffffffffc02061a8 <default_pmm_manager+0x4d8>
ffffffffc0202680:	00003617          	auipc	a2,0x3
ffffffffc0202684:	2a060613          	addi	a2,a2,672 # ffffffffc0205920 <commands+0x738>
ffffffffc0202688:	19d00593          	li	a1,413
ffffffffc020268c:	00003517          	auipc	a0,0x3
ffffffffc0202690:	79450513          	addi	a0,a0,1940 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202694:	db3fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202698:	86a2                	mv	a3,s0
ffffffffc020269a:	00003617          	auipc	a2,0x3
ffffffffc020269e:	66e60613          	addi	a2,a2,1646 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc02026a2:	19d00593          	li	a1,413
ffffffffc02026a6:	00003517          	auipc	a0,0x3
ffffffffc02026aa:	77a50513          	addi	a0,a0,1914 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02026ae:	d99fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02026b2:	b7eff0ef          	jal	ra,ffffffffc0201a30 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026b6:	00003617          	auipc	a2,0x3
ffffffffc02026ba:	6fa60613          	addi	a2,a2,1786 # ffffffffc0205db0 <default_pmm_manager+0xe0>
ffffffffc02026be:	07f00593          	li	a1,127
ffffffffc02026c2:	00003517          	auipc	a0,0x3
ffffffffc02026c6:	75e50513          	addi	a0,a0,1886 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02026ca:	d7dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02026ce:	00003617          	auipc	a2,0x3
ffffffffc02026d2:	6e260613          	addi	a2,a2,1762 # ffffffffc0205db0 <default_pmm_manager+0xe0>
ffffffffc02026d6:	0c300593          	li	a1,195
ffffffffc02026da:	00003517          	auipc	a0,0x3
ffffffffc02026de:	74650513          	addi	a0,a0,1862 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02026e2:	d65fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026e6:	00003697          	auipc	a3,0x3
ffffffffc02026ea:	7fa68693          	addi	a3,a3,2042 # ffffffffc0205ee0 <default_pmm_manager+0x210>
ffffffffc02026ee:	00003617          	auipc	a2,0x3
ffffffffc02026f2:	23260613          	addi	a2,a2,562 # ffffffffc0205920 <commands+0x738>
ffffffffc02026f6:	16100593          	li	a1,353
ffffffffc02026fa:	00003517          	auipc	a0,0x3
ffffffffc02026fe:	72650513          	addi	a0,a0,1830 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202702:	d45fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202706:	00003697          	auipc	a3,0x3
ffffffffc020270a:	7ba68693          	addi	a3,a3,1978 # ffffffffc0205ec0 <default_pmm_manager+0x1f0>
ffffffffc020270e:	00003617          	auipc	a2,0x3
ffffffffc0202712:	21260613          	addi	a2,a2,530 # ffffffffc0205920 <commands+0x738>
ffffffffc0202716:	16000593          	li	a1,352
ffffffffc020271a:	00003517          	auipc	a0,0x3
ffffffffc020271e:	70650513          	addi	a0,a0,1798 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202722:	d25fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202726:	b26ff0ef          	jal	ra,ffffffffc0201a4c <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020272a:	00004697          	auipc	a3,0x4
ffffffffc020272e:	84668693          	addi	a3,a3,-1978 # ffffffffc0205f70 <default_pmm_manager+0x2a0>
ffffffffc0202732:	00003617          	auipc	a2,0x3
ffffffffc0202736:	1ee60613          	addi	a2,a2,494 # ffffffffc0205920 <commands+0x738>
ffffffffc020273a:	16900593          	li	a1,361
ffffffffc020273e:	00003517          	auipc	a0,0x3
ffffffffc0202742:	6e250513          	addi	a0,a0,1762 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202746:	d01fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020274a:	00003697          	auipc	a3,0x3
ffffffffc020274e:	7f668693          	addi	a3,a3,2038 # ffffffffc0205f40 <default_pmm_manager+0x270>
ffffffffc0202752:	00003617          	auipc	a2,0x3
ffffffffc0202756:	1ce60613          	addi	a2,a2,462 # ffffffffc0205920 <commands+0x738>
ffffffffc020275a:	16600593          	li	a1,358
ffffffffc020275e:	00003517          	auipc	a0,0x3
ffffffffc0202762:	6c250513          	addi	a0,a0,1730 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202766:	ce1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020276a:	00003697          	auipc	a3,0x3
ffffffffc020276e:	7ae68693          	addi	a3,a3,1966 # ffffffffc0205f18 <default_pmm_manager+0x248>
ffffffffc0202772:	00003617          	auipc	a2,0x3
ffffffffc0202776:	1ae60613          	addi	a2,a2,430 # ffffffffc0205920 <commands+0x738>
ffffffffc020277a:	16200593          	li	a1,354
ffffffffc020277e:	00003517          	auipc	a0,0x3
ffffffffc0202782:	6a250513          	addi	a0,a0,1698 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202786:	cc1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020278a:	00004697          	auipc	a3,0x4
ffffffffc020278e:	86e68693          	addi	a3,a3,-1938 # ffffffffc0205ff8 <default_pmm_manager+0x328>
ffffffffc0202792:	00003617          	auipc	a2,0x3
ffffffffc0202796:	18e60613          	addi	a2,a2,398 # ffffffffc0205920 <commands+0x738>
ffffffffc020279a:	17200593          	li	a1,370
ffffffffc020279e:	00003517          	auipc	a0,0x3
ffffffffc02027a2:	68250513          	addi	a0,a0,1666 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02027a6:	ca1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02027aa:	00004697          	auipc	a3,0x4
ffffffffc02027ae:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0206098 <default_pmm_manager+0x3c8>
ffffffffc02027b2:	00003617          	auipc	a2,0x3
ffffffffc02027b6:	16e60613          	addi	a2,a2,366 # ffffffffc0205920 <commands+0x738>
ffffffffc02027ba:	17700593          	li	a1,375
ffffffffc02027be:	00003517          	auipc	a0,0x3
ffffffffc02027c2:	66250513          	addi	a0,a0,1634 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02027c6:	c81fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02027ca:	00004697          	auipc	a3,0x4
ffffffffc02027ce:	80668693          	addi	a3,a3,-2042 # ffffffffc0205fd0 <default_pmm_manager+0x300>
ffffffffc02027d2:	00003617          	auipc	a2,0x3
ffffffffc02027d6:	14e60613          	addi	a2,a2,334 # ffffffffc0205920 <commands+0x738>
ffffffffc02027da:	16f00593          	li	a1,367
ffffffffc02027de:	00003517          	auipc	a0,0x3
ffffffffc02027e2:	64250513          	addi	a0,a0,1602 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02027e6:	c61fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027ea:	86d6                	mv	a3,s5
ffffffffc02027ec:	00003617          	auipc	a2,0x3
ffffffffc02027f0:	51c60613          	addi	a2,a2,1308 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc02027f4:	16e00593          	li	a1,366
ffffffffc02027f8:	00003517          	auipc	a0,0x3
ffffffffc02027fc:	62850513          	addi	a0,a0,1576 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202800:	c47fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202804:	00004697          	auipc	a3,0x4
ffffffffc0202808:	82c68693          	addi	a3,a3,-2004 # ffffffffc0206030 <default_pmm_manager+0x360>
ffffffffc020280c:	00003617          	auipc	a2,0x3
ffffffffc0202810:	11460613          	addi	a2,a2,276 # ffffffffc0205920 <commands+0x738>
ffffffffc0202814:	17c00593          	li	a1,380
ffffffffc0202818:	00003517          	auipc	a0,0x3
ffffffffc020281c:	60850513          	addi	a0,a0,1544 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202820:	c27fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202824:	00004697          	auipc	a3,0x4
ffffffffc0202828:	8d468693          	addi	a3,a3,-1836 # ffffffffc02060f8 <default_pmm_manager+0x428>
ffffffffc020282c:	00003617          	auipc	a2,0x3
ffffffffc0202830:	0f460613          	addi	a2,a2,244 # ffffffffc0205920 <commands+0x738>
ffffffffc0202834:	17b00593          	li	a1,379
ffffffffc0202838:	00003517          	auipc	a0,0x3
ffffffffc020283c:	5e850513          	addi	a0,a0,1512 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202840:	c07fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202844:	00004697          	auipc	a3,0x4
ffffffffc0202848:	89c68693          	addi	a3,a3,-1892 # ffffffffc02060e0 <default_pmm_manager+0x410>
ffffffffc020284c:	00003617          	auipc	a2,0x3
ffffffffc0202850:	0d460613          	addi	a2,a2,212 # ffffffffc0205920 <commands+0x738>
ffffffffc0202854:	17a00593          	li	a1,378
ffffffffc0202858:	00003517          	auipc	a0,0x3
ffffffffc020285c:	5c850513          	addi	a0,a0,1480 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202860:	be7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202864:	00004697          	auipc	a3,0x4
ffffffffc0202868:	84c68693          	addi	a3,a3,-1972 # ffffffffc02060b0 <default_pmm_manager+0x3e0>
ffffffffc020286c:	00003617          	auipc	a2,0x3
ffffffffc0202870:	0b460613          	addi	a2,a2,180 # ffffffffc0205920 <commands+0x738>
ffffffffc0202874:	17900593          	li	a1,377
ffffffffc0202878:	00003517          	auipc	a0,0x3
ffffffffc020287c:	5a850513          	addi	a0,a0,1448 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202880:	bc7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202884:	00004697          	auipc	a3,0x4
ffffffffc0202888:	9e468693          	addi	a3,a3,-1564 # ffffffffc0206268 <default_pmm_manager+0x598>
ffffffffc020288c:	00003617          	auipc	a2,0x3
ffffffffc0202890:	09460613          	addi	a2,a2,148 # ffffffffc0205920 <commands+0x738>
ffffffffc0202894:	1a700593          	li	a1,423
ffffffffc0202898:	00003517          	auipc	a0,0x3
ffffffffc020289c:	58850513          	addi	a0,a0,1416 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02028a0:	ba7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02028a4:	00003697          	auipc	a3,0x3
ffffffffc02028a8:	7dc68693          	addi	a3,a3,2012 # ffffffffc0206080 <default_pmm_manager+0x3b0>
ffffffffc02028ac:	00003617          	auipc	a2,0x3
ffffffffc02028b0:	07460613          	addi	a2,a2,116 # ffffffffc0205920 <commands+0x738>
ffffffffc02028b4:	17600593          	li	a1,374
ffffffffc02028b8:	00003517          	auipc	a0,0x3
ffffffffc02028bc:	56850513          	addi	a0,a0,1384 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02028c0:	b87fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02028c4:	00003697          	auipc	a3,0x3
ffffffffc02028c8:	7ac68693          	addi	a3,a3,1964 # ffffffffc0206070 <default_pmm_manager+0x3a0>
ffffffffc02028cc:	00003617          	auipc	a2,0x3
ffffffffc02028d0:	05460613          	addi	a2,a2,84 # ffffffffc0205920 <commands+0x738>
ffffffffc02028d4:	17500593          	li	a1,373
ffffffffc02028d8:	00003517          	auipc	a0,0x3
ffffffffc02028dc:	54850513          	addi	a0,a0,1352 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02028e0:	b67fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02028e4:	00004697          	auipc	a3,0x4
ffffffffc02028e8:	88468693          	addi	a3,a3,-1916 # ffffffffc0206168 <default_pmm_manager+0x498>
ffffffffc02028ec:	00003617          	auipc	a2,0x3
ffffffffc02028f0:	03460613          	addi	a2,a2,52 # ffffffffc0205920 <commands+0x738>
ffffffffc02028f4:	1b800593          	li	a1,440
ffffffffc02028f8:	00003517          	auipc	a0,0x3
ffffffffc02028fc:	52850513          	addi	a0,a0,1320 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202900:	b47fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202904:	00003697          	auipc	a3,0x3
ffffffffc0202908:	75c68693          	addi	a3,a3,1884 # ffffffffc0206060 <default_pmm_manager+0x390>
ffffffffc020290c:	00003617          	auipc	a2,0x3
ffffffffc0202910:	01460613          	addi	a2,a2,20 # ffffffffc0205920 <commands+0x738>
ffffffffc0202914:	17400593          	li	a1,372
ffffffffc0202918:	00003517          	auipc	a0,0x3
ffffffffc020291c:	50850513          	addi	a0,a0,1288 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202920:	b27fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202924:	00003697          	auipc	a3,0x3
ffffffffc0202928:	69468693          	addi	a3,a3,1684 # ffffffffc0205fb8 <default_pmm_manager+0x2e8>
ffffffffc020292c:	00003617          	auipc	a2,0x3
ffffffffc0202930:	ff460613          	addi	a2,a2,-12 # ffffffffc0205920 <commands+0x738>
ffffffffc0202934:	18100593          	li	a1,385
ffffffffc0202938:	00003517          	auipc	a0,0x3
ffffffffc020293c:	4e850513          	addi	a0,a0,1256 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202940:	b07fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202944:	00003697          	auipc	a3,0x3
ffffffffc0202948:	7cc68693          	addi	a3,a3,1996 # ffffffffc0206110 <default_pmm_manager+0x440>
ffffffffc020294c:	00003617          	auipc	a2,0x3
ffffffffc0202950:	fd460613          	addi	a2,a2,-44 # ffffffffc0205920 <commands+0x738>
ffffffffc0202954:	17e00593          	li	a1,382
ffffffffc0202958:	00003517          	auipc	a0,0x3
ffffffffc020295c:	4c850513          	addi	a0,a0,1224 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202960:	ae7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202964:	00003697          	auipc	a3,0x3
ffffffffc0202968:	63c68693          	addi	a3,a3,1596 # ffffffffc0205fa0 <default_pmm_manager+0x2d0>
ffffffffc020296c:	00003617          	auipc	a2,0x3
ffffffffc0202970:	fb460613          	addi	a2,a2,-76 # ffffffffc0205920 <commands+0x738>
ffffffffc0202974:	17d00593          	li	a1,381
ffffffffc0202978:	00003517          	auipc	a0,0x3
ffffffffc020297c:	4a850513          	addi	a0,a0,1192 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202980:	ac7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202984:	00003617          	auipc	a2,0x3
ffffffffc0202988:	38460613          	addi	a2,a2,900 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc020298c:	06900593          	li	a1,105
ffffffffc0202990:	00003517          	auipc	a0,0x3
ffffffffc0202994:	3a050513          	addi	a0,a0,928 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc0202998:	aaffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020299c:	00003697          	auipc	a3,0x3
ffffffffc02029a0:	7a468693          	addi	a3,a3,1956 # ffffffffc0206140 <default_pmm_manager+0x470>
ffffffffc02029a4:	00003617          	auipc	a2,0x3
ffffffffc02029a8:	f7c60613          	addi	a2,a2,-132 # ffffffffc0205920 <commands+0x738>
ffffffffc02029ac:	18800593          	li	a1,392
ffffffffc02029b0:	00003517          	auipc	a0,0x3
ffffffffc02029b4:	47050513          	addi	a0,a0,1136 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02029b8:	a8ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02029bc:	00003697          	auipc	a3,0x3
ffffffffc02029c0:	73c68693          	addi	a3,a3,1852 # ffffffffc02060f8 <default_pmm_manager+0x428>
ffffffffc02029c4:	00003617          	auipc	a2,0x3
ffffffffc02029c8:	f5c60613          	addi	a2,a2,-164 # ffffffffc0205920 <commands+0x738>
ffffffffc02029cc:	18600593          	li	a1,390
ffffffffc02029d0:	00003517          	auipc	a0,0x3
ffffffffc02029d4:	45050513          	addi	a0,a0,1104 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02029d8:	a6ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02029dc:	00003697          	auipc	a3,0x3
ffffffffc02029e0:	74c68693          	addi	a3,a3,1868 # ffffffffc0206128 <default_pmm_manager+0x458>
ffffffffc02029e4:	00003617          	auipc	a2,0x3
ffffffffc02029e8:	f3c60613          	addi	a2,a2,-196 # ffffffffc0205920 <commands+0x738>
ffffffffc02029ec:	18500593          	li	a1,389
ffffffffc02029f0:	00003517          	auipc	a0,0x3
ffffffffc02029f4:	43050513          	addi	a0,a0,1072 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc02029f8:	a4ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02029fc:	00003697          	auipc	a3,0x3
ffffffffc0202a00:	6fc68693          	addi	a3,a3,1788 # ffffffffc02060f8 <default_pmm_manager+0x428>
ffffffffc0202a04:	00003617          	auipc	a2,0x3
ffffffffc0202a08:	f1c60613          	addi	a2,a2,-228 # ffffffffc0205920 <commands+0x738>
ffffffffc0202a0c:	18200593          	li	a1,386
ffffffffc0202a10:	00003517          	auipc	a0,0x3
ffffffffc0202a14:	41050513          	addi	a0,a0,1040 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202a18:	a2ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202a1c:	00004697          	auipc	a3,0x4
ffffffffc0202a20:	83468693          	addi	a3,a3,-1996 # ffffffffc0206250 <default_pmm_manager+0x580>
ffffffffc0202a24:	00003617          	auipc	a2,0x3
ffffffffc0202a28:	efc60613          	addi	a2,a2,-260 # ffffffffc0205920 <commands+0x738>
ffffffffc0202a2c:	1a600593          	li	a1,422
ffffffffc0202a30:	00003517          	auipc	a0,0x3
ffffffffc0202a34:	3f050513          	addi	a0,a0,1008 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202a38:	a0ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a3c:	00003697          	auipc	a3,0x3
ffffffffc0202a40:	7dc68693          	addi	a3,a3,2012 # ffffffffc0206218 <default_pmm_manager+0x548>
ffffffffc0202a44:	00003617          	auipc	a2,0x3
ffffffffc0202a48:	edc60613          	addi	a2,a2,-292 # ffffffffc0205920 <commands+0x738>
ffffffffc0202a4c:	1a500593          	li	a1,421
ffffffffc0202a50:	00003517          	auipc	a0,0x3
ffffffffc0202a54:	3d050513          	addi	a0,a0,976 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202a58:	9effd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202a5c:	00003697          	auipc	a3,0x3
ffffffffc0202a60:	7a468693          	addi	a3,a3,1956 # ffffffffc0206200 <default_pmm_manager+0x530>
ffffffffc0202a64:	00003617          	auipc	a2,0x3
ffffffffc0202a68:	ebc60613          	addi	a2,a2,-324 # ffffffffc0205920 <commands+0x738>
ffffffffc0202a6c:	1a100593          	li	a1,417
ffffffffc0202a70:	00003517          	auipc	a0,0x3
ffffffffc0202a74:	3b050513          	addi	a0,a0,944 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202a78:	9cffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202a7c:	00003697          	auipc	a3,0x3
ffffffffc0202a80:	6ec68693          	addi	a3,a3,1772 # ffffffffc0206168 <default_pmm_manager+0x498>
ffffffffc0202a84:	00003617          	auipc	a2,0x3
ffffffffc0202a88:	e9c60613          	addi	a2,a2,-356 # ffffffffc0205920 <commands+0x738>
ffffffffc0202a8c:	19000593          	li	a1,400
ffffffffc0202a90:	00003517          	auipc	a0,0x3
ffffffffc0202a94:	39050513          	addi	a0,a0,912 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202a98:	9affd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a9c:	00003697          	auipc	a3,0x3
ffffffffc0202aa0:	50468693          	addi	a3,a3,1284 # ffffffffc0205fa0 <default_pmm_manager+0x2d0>
ffffffffc0202aa4:	00003617          	auipc	a2,0x3
ffffffffc0202aa8:	e7c60613          	addi	a2,a2,-388 # ffffffffc0205920 <commands+0x738>
ffffffffc0202aac:	16a00593          	li	a1,362
ffffffffc0202ab0:	00003517          	auipc	a0,0x3
ffffffffc0202ab4:	37050513          	addi	a0,a0,880 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202ab8:	98ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202abc:	00003617          	auipc	a2,0x3
ffffffffc0202ac0:	24c60613          	addi	a2,a2,588 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc0202ac4:	16d00593          	li	a1,365
ffffffffc0202ac8:	00003517          	auipc	a0,0x3
ffffffffc0202acc:	35850513          	addi	a0,a0,856 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202ad0:	977fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ad4:	00003697          	auipc	a3,0x3
ffffffffc0202ad8:	4e468693          	addi	a3,a3,1252 # ffffffffc0205fb8 <default_pmm_manager+0x2e8>
ffffffffc0202adc:	00003617          	auipc	a2,0x3
ffffffffc0202ae0:	e4460613          	addi	a2,a2,-444 # ffffffffc0205920 <commands+0x738>
ffffffffc0202ae4:	16b00593          	li	a1,363
ffffffffc0202ae8:	00003517          	auipc	a0,0x3
ffffffffc0202aec:	33850513          	addi	a0,a0,824 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202af0:	957fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202af4:	00003697          	auipc	a3,0x3
ffffffffc0202af8:	53c68693          	addi	a3,a3,1340 # ffffffffc0206030 <default_pmm_manager+0x360>
ffffffffc0202afc:	00003617          	auipc	a2,0x3
ffffffffc0202b00:	e2460613          	addi	a2,a2,-476 # ffffffffc0205920 <commands+0x738>
ffffffffc0202b04:	17300593          	li	a1,371
ffffffffc0202b08:	00003517          	auipc	a0,0x3
ffffffffc0202b0c:	31850513          	addi	a0,a0,792 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202b10:	937fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b14:	00003697          	auipc	a3,0x3
ffffffffc0202b18:	7fc68693          	addi	a3,a3,2044 # ffffffffc0206310 <default_pmm_manager+0x640>
ffffffffc0202b1c:	00003617          	auipc	a2,0x3
ffffffffc0202b20:	e0460613          	addi	a2,a2,-508 # ffffffffc0205920 <commands+0x738>
ffffffffc0202b24:	1af00593          	li	a1,431
ffffffffc0202b28:	00003517          	auipc	a0,0x3
ffffffffc0202b2c:	2f850513          	addi	a0,a0,760 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202b30:	917fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202b34:	00003697          	auipc	a3,0x3
ffffffffc0202b38:	7a468693          	addi	a3,a3,1956 # ffffffffc02062d8 <default_pmm_manager+0x608>
ffffffffc0202b3c:	00003617          	auipc	a2,0x3
ffffffffc0202b40:	de460613          	addi	a2,a2,-540 # ffffffffc0205920 <commands+0x738>
ffffffffc0202b44:	1ac00593          	li	a1,428
ffffffffc0202b48:	00003517          	auipc	a0,0x3
ffffffffc0202b4c:	2d850513          	addi	a0,a0,728 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202b50:	8f7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202b54:	00003697          	auipc	a3,0x3
ffffffffc0202b58:	75468693          	addi	a3,a3,1876 # ffffffffc02062a8 <default_pmm_manager+0x5d8>
ffffffffc0202b5c:	00003617          	auipc	a2,0x3
ffffffffc0202b60:	dc460613          	addi	a2,a2,-572 # ffffffffc0205920 <commands+0x738>
ffffffffc0202b64:	1a800593          	li	a1,424
ffffffffc0202b68:	00003517          	auipc	a0,0x3
ffffffffc0202b6c:	2b850513          	addi	a0,a0,696 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202b70:	8d7fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202b74 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202b74:	12058073          	sfence.vma	a1
}
ffffffffc0202b78:	8082                	ret

ffffffffc0202b7a <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202b7a:	7179                	addi	sp,sp,-48
ffffffffc0202b7c:	e84a                	sd	s2,16(sp)
ffffffffc0202b7e:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202b80:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202b82:	f022                	sd	s0,32(sp)
ffffffffc0202b84:	ec26                	sd	s1,24(sp)
ffffffffc0202b86:	e44e                	sd	s3,8(sp)
ffffffffc0202b88:	f406                	sd	ra,40(sp)
ffffffffc0202b8a:	84ae                	mv	s1,a1
ffffffffc0202b8c:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202b8e:	edbfe0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0202b92:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202b94:	cd09                	beqz	a0,ffffffffc0202bae <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202b96:	85aa                	mv	a1,a0
ffffffffc0202b98:	86ce                	mv	a3,s3
ffffffffc0202b9a:	8626                	mv	a2,s1
ffffffffc0202b9c:	854a                	mv	a0,s2
ffffffffc0202b9e:	ac8ff0ef          	jal	ra,ffffffffc0201e66 <page_insert>
ffffffffc0202ba2:	ed21                	bnez	a0,ffffffffc0202bfa <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0202ba4:	00014797          	auipc	a5,0x14
ffffffffc0202ba8:	9f47a783          	lw	a5,-1548(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc0202bac:	eb89                	bnez	a5,ffffffffc0202bbe <pgdir_alloc_page+0x44>
}
ffffffffc0202bae:	70a2                	ld	ra,40(sp)
ffffffffc0202bb0:	8522                	mv	a0,s0
ffffffffc0202bb2:	7402                	ld	s0,32(sp)
ffffffffc0202bb4:	64e2                	ld	s1,24(sp)
ffffffffc0202bb6:	6942                	ld	s2,16(sp)
ffffffffc0202bb8:	69a2                	ld	s3,8(sp)
ffffffffc0202bba:	6145                	addi	sp,sp,48
ffffffffc0202bbc:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202bbe:	4681                	li	a3,0
ffffffffc0202bc0:	8622                	mv	a2,s0
ffffffffc0202bc2:	85a6                	mv	a1,s1
ffffffffc0202bc4:	00014517          	auipc	a0,0x14
ffffffffc0202bc8:	9dc53503          	ld	a0,-1572(a0) # ffffffffc02165a0 <check_mm_struct>
ffffffffc0202bcc:	7ee000ef          	jal	ra,ffffffffc02033ba <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202bd0:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202bd2:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202bd4:	4785                	li	a5,1
ffffffffc0202bd6:	fcf70ce3          	beq	a4,a5,ffffffffc0202bae <pgdir_alloc_page+0x34>
ffffffffc0202bda:	00003697          	auipc	a3,0x3
ffffffffc0202bde:	77e68693          	addi	a3,a3,1918 # ffffffffc0206358 <default_pmm_manager+0x688>
ffffffffc0202be2:	00003617          	auipc	a2,0x3
ffffffffc0202be6:	d3e60613          	addi	a2,a2,-706 # ffffffffc0205920 <commands+0x738>
ffffffffc0202bea:	14800593          	li	a1,328
ffffffffc0202bee:	00003517          	auipc	a0,0x3
ffffffffc0202bf2:	23250513          	addi	a0,a0,562 # ffffffffc0205e20 <default_pmm_manager+0x150>
ffffffffc0202bf6:	851fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202bfa:	100027f3          	csrr	a5,sstatus
ffffffffc0202bfe:	8b89                	andi	a5,a5,2
ffffffffc0202c00:	eb99                	bnez	a5,ffffffffc0202c16 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0202c02:	00014797          	auipc	a5,0x14
ffffffffc0202c06:	9767b783          	ld	a5,-1674(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0202c0a:	739c                	ld	a5,32(a5)
ffffffffc0202c0c:	8522                	mv	a0,s0
ffffffffc0202c0e:	4585                	li	a1,1
ffffffffc0202c10:	9782                	jalr	a5
            return NULL;
ffffffffc0202c12:	4401                	li	s0,0
ffffffffc0202c14:	bf69                	j	ffffffffc0202bae <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0202c16:	9adfd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202c1a:	00014797          	auipc	a5,0x14
ffffffffc0202c1e:	95e7b783          	ld	a5,-1698(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0202c22:	739c                	ld	a5,32(a5)
ffffffffc0202c24:	8522                	mv	a0,s0
ffffffffc0202c26:	4585                	li	a1,1
ffffffffc0202c28:	9782                	jalr	a5
            return NULL;
ffffffffc0202c2a:	4401                	li	s0,0
        intr_enable();
ffffffffc0202c2c:	991fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202c30:	bfbd                	j	ffffffffc0202bae <pgdir_alloc_page+0x34>

ffffffffc0202c32 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202c32:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202c34:	00003617          	auipc	a2,0x3
ffffffffc0202c38:	1a460613          	addi	a2,a2,420 # ffffffffc0205dd8 <default_pmm_manager+0x108>
ffffffffc0202c3c:	06200593          	li	a1,98
ffffffffc0202c40:	00003517          	auipc	a0,0x3
ffffffffc0202c44:	0f050513          	addi	a0,a0,240 # ffffffffc0205d30 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0202c48:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202c4a:	ffcfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202c4e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202c4e:	7135                	addi	sp,sp,-160
ffffffffc0202c50:	ed06                	sd	ra,152(sp)
ffffffffc0202c52:	e922                	sd	s0,144(sp)
ffffffffc0202c54:	e526                	sd	s1,136(sp)
ffffffffc0202c56:	e14a                	sd	s2,128(sp)
ffffffffc0202c58:	fcce                	sd	s3,120(sp)
ffffffffc0202c5a:	f8d2                	sd	s4,112(sp)
ffffffffc0202c5c:	f4d6                	sd	s5,104(sp)
ffffffffc0202c5e:	f0da                	sd	s6,96(sp)
ffffffffc0202c60:	ecde                	sd	s7,88(sp)
ffffffffc0202c62:	e8e2                	sd	s8,80(sp)
ffffffffc0202c64:	e4e6                	sd	s9,72(sp)
ffffffffc0202c66:	e0ea                	sd	s10,64(sp)
ffffffffc0202c68:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202c6a:	582010ef          	jal	ra,ffffffffc02041ec <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202c6e:	00014697          	auipc	a3,0x14
ffffffffc0202c72:	91a6b683          	ld	a3,-1766(a3) # ffffffffc0216588 <max_swap_offset>
ffffffffc0202c76:	010007b7          	lui	a5,0x1000
ffffffffc0202c7a:	ff968713          	addi	a4,a3,-7
ffffffffc0202c7e:	17e1                	addi	a5,a5,-8
ffffffffc0202c80:	44e7e363          	bltu	a5,a4,ffffffffc02030c6 <swap_init+0x478>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202c84:	00008797          	auipc	a5,0x8
ffffffffc0202c88:	38c78793          	addi	a5,a5,908 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202c8c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202c8e:	00014b97          	auipc	s7,0x14
ffffffffc0202c92:	902b8b93          	addi	s7,s7,-1790 # ffffffffc0216590 <sm>
ffffffffc0202c96:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0202c9a:	9702                	jalr	a4
ffffffffc0202c9c:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0202c9e:	c10d                	beqz	a0,ffffffffc0202cc0 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202ca0:	60ea                	ld	ra,152(sp)
ffffffffc0202ca2:	644a                	ld	s0,144(sp)
ffffffffc0202ca4:	64aa                	ld	s1,136(sp)
ffffffffc0202ca6:	79e6                	ld	s3,120(sp)
ffffffffc0202ca8:	7a46                	ld	s4,112(sp)
ffffffffc0202caa:	7aa6                	ld	s5,104(sp)
ffffffffc0202cac:	7b06                	ld	s6,96(sp)
ffffffffc0202cae:	6be6                	ld	s7,88(sp)
ffffffffc0202cb0:	6c46                	ld	s8,80(sp)
ffffffffc0202cb2:	6ca6                	ld	s9,72(sp)
ffffffffc0202cb4:	6d06                	ld	s10,64(sp)
ffffffffc0202cb6:	7de2                	ld	s11,56(sp)
ffffffffc0202cb8:	854a                	mv	a0,s2
ffffffffc0202cba:	690a                	ld	s2,128(sp)
ffffffffc0202cbc:	610d                	addi	sp,sp,160
ffffffffc0202cbe:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202cc0:	000bb783          	ld	a5,0(s7)
ffffffffc0202cc4:	00003517          	auipc	a0,0x3
ffffffffc0202cc8:	6dc50513          	addi	a0,a0,1756 # ffffffffc02063a0 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc0202ccc:	0000f417          	auipc	s0,0xf
ffffffffc0202cd0:	79440413          	addi	s0,s0,1940 # ffffffffc0212460 <free_area>
ffffffffc0202cd4:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202cd6:	4785                	li	a5,1
ffffffffc0202cd8:	00014717          	auipc	a4,0x14
ffffffffc0202cdc:	8cf72023          	sw	a5,-1856(a4) # ffffffffc0216598 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ce0:	ca0fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202ce4:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202ce6:	4d01                	li	s10,0
ffffffffc0202ce8:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cea:	34878e63          	beq	a5,s0,ffffffffc0203046 <swap_init+0x3f8>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202cee:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202cf2:	8b09                	andi	a4,a4,2
ffffffffc0202cf4:	34070b63          	beqz	a4,ffffffffc020304a <swap_init+0x3fc>
        count ++, total += p->property;
ffffffffc0202cf8:	ff07a703          	lw	a4,-16(a5)
ffffffffc0202cfc:	679c                	ld	a5,8(a5)
ffffffffc0202cfe:	2d85                	addiw	s11,s11,1
ffffffffc0202d00:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202d04:	fe8795e3          	bne	a5,s0,ffffffffc0202cee <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202d08:	84ea                	mv	s1,s10
ffffffffc0202d0a:	e31fe0ef          	jal	ra,ffffffffc0201b3a <nr_free_pages>
ffffffffc0202d0e:	44951463          	bne	a0,s1,ffffffffc0203156 <swap_init+0x508>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202d12:	866a                	mv	a2,s10
ffffffffc0202d14:	85ee                	mv	a1,s11
ffffffffc0202d16:	00003517          	auipc	a0,0x3
ffffffffc0202d1a:	6a250513          	addi	a0,a0,1698 # ffffffffc02063b8 <default_pmm_manager+0x6e8>
ffffffffc0202d1e:	c62fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202d22:	445000ef          	jal	ra,ffffffffc0203966 <mm_create>
ffffffffc0202d26:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202d28:	48050763          	beqz	a0,ffffffffc02031b6 <swap_init+0x568>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202d2c:	00014797          	auipc	a5,0x14
ffffffffc0202d30:	87478793          	addi	a5,a5,-1932 # ffffffffc02165a0 <check_mm_struct>
ffffffffc0202d34:	6398                	ld	a4,0(a5)
ffffffffc0202d36:	40071063          	bnez	a4,ffffffffc0203136 <swap_init+0x4e8>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202d3a:	00014717          	auipc	a4,0x14
ffffffffc0202d3e:	82670713          	addi	a4,a4,-2010 # ffffffffc0216560 <boot_pgdir>
ffffffffc0202d42:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0202d46:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0202d48:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202d4c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202d50:	44079363          	bnez	a5,ffffffffc0203196 <swap_init+0x548>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202d54:	6599                	lui	a1,0x6
ffffffffc0202d56:	460d                	li	a2,3
ffffffffc0202d58:	6505                	lui	a0,0x1
ffffffffc0202d5a:	455000ef          	jal	ra,ffffffffc02039ae <vma_create>
ffffffffc0202d5e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202d60:	54050763          	beqz	a0,ffffffffc02032ae <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202d64:	8556                	mv	a0,s5
ffffffffc0202d66:	4b7000ef          	jal	ra,ffffffffc0203a1c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202d6a:	00003517          	auipc	a0,0x3
ffffffffc0202d6e:	6be50513          	addi	a0,a0,1726 # ffffffffc0206428 <default_pmm_manager+0x758>
ffffffffc0202d72:	c0efd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202d76:	018ab503          	ld	a0,24(s5)
ffffffffc0202d7a:	4605                	li	a2,1
ffffffffc0202d7c:	6585                	lui	a1,0x1
ffffffffc0202d7e:	df7fe0ef          	jal	ra,ffffffffc0201b74 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202d82:	4e050663          	beqz	a0,ffffffffc020326e <swap_init+0x620>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202d86:	00003517          	auipc	a0,0x3
ffffffffc0202d8a:	6f250513          	addi	a0,a0,1778 # ffffffffc0206478 <default_pmm_manager+0x7a8>
ffffffffc0202d8e:	0000f497          	auipc	s1,0xf
ffffffffc0202d92:	70a48493          	addi	s1,s1,1802 # ffffffffc0212498 <check_rp>
ffffffffc0202d96:	beafd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d9a:	0000f997          	auipc	s3,0xf
ffffffffc0202d9e:	71e98993          	addi	s3,s3,1822 # ffffffffc02124b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202da2:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0202da4:	4505                	li	a0,1
ffffffffc0202da6:	cc3fe0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
ffffffffc0202daa:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0202dae:	2e050c63          	beqz	a0,ffffffffc02030a6 <swap_init+0x458>
ffffffffc0202db2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202db4:	8b89                	andi	a5,a5,2
ffffffffc0202db6:	36079063          	bnez	a5,ffffffffc0203116 <swap_init+0x4c8>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202dba:	0a21                	addi	s4,s4,8
ffffffffc0202dbc:	ff3a14e3          	bne	s4,s3,ffffffffc0202da4 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202dc0:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202dc2:	0000fa17          	auipc	s4,0xf
ffffffffc0202dc6:	6d6a0a13          	addi	s4,s4,1750 # ffffffffc0212498 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0202dca:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0202dcc:	ec3e                	sd	a5,24(sp)
ffffffffc0202dce:	641c                	ld	a5,8(s0)
ffffffffc0202dd0:	e400                	sd	s0,8(s0)
ffffffffc0202dd2:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202dd4:	481c                	lw	a5,16(s0)
ffffffffc0202dd6:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202dd8:	0000f797          	auipc	a5,0xf
ffffffffc0202ddc:	6807ac23          	sw	zero,1688(a5) # ffffffffc0212470 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202de0:	000a3503          	ld	a0,0(s4)
ffffffffc0202de4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202de6:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0202de8:	d13fe0ef          	jal	ra,ffffffffc0201afa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202dec:	ff3a1ae3          	bne	s4,s3,ffffffffc0202de0 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202df0:	01042a03          	lw	s4,16(s0)
ffffffffc0202df4:	4791                	li	a5,4
ffffffffc0202df6:	44fa1c63          	bne	s4,a5,ffffffffc020324e <swap_init+0x600>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202dfa:	00003517          	auipc	a0,0x3
ffffffffc0202dfe:	70650513          	addi	a0,a0,1798 # ffffffffc0206500 <default_pmm_manager+0x830>
ffffffffc0202e02:	b7efd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202e06:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202e08:	00013797          	auipc	a5,0x13
ffffffffc0202e0c:	7a07a023          	sw	zero,1952(a5) # ffffffffc02165a8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202e10:	4629                	li	a2,10
ffffffffc0202e12:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202e16:	00013697          	auipc	a3,0x13
ffffffffc0202e1a:	7926a683          	lw	a3,1938(a3) # ffffffffc02165a8 <pgfault_num>
ffffffffc0202e1e:	4585                	li	a1,1
ffffffffc0202e20:	00013797          	auipc	a5,0x13
ffffffffc0202e24:	78878793          	addi	a5,a5,1928 # ffffffffc02165a8 <pgfault_num>
ffffffffc0202e28:	56b69363          	bne	a3,a1,ffffffffc020338e <swap_init+0x740>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202e2c:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202e30:	4398                	lw	a4,0(a5)
ffffffffc0202e32:	2701                	sext.w	a4,a4
ffffffffc0202e34:	3ed71d63          	bne	a4,a3,ffffffffc020322e <swap_init+0x5e0>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202e38:	6689                	lui	a3,0x2
ffffffffc0202e3a:	462d                	li	a2,11
ffffffffc0202e3c:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202e40:	4398                	lw	a4,0(a5)
ffffffffc0202e42:	4589                	li	a1,2
ffffffffc0202e44:	2701                	sext.w	a4,a4
ffffffffc0202e46:	4cb71463          	bne	a4,a1,ffffffffc020330e <swap_init+0x6c0>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202e4a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202e4e:	4394                	lw	a3,0(a5)
ffffffffc0202e50:	2681                	sext.w	a3,a3
ffffffffc0202e52:	4ce69e63          	bne	a3,a4,ffffffffc020332e <swap_init+0x6e0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202e56:	668d                	lui	a3,0x3
ffffffffc0202e58:	4631                	li	a2,12
ffffffffc0202e5a:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202e5e:	4398                	lw	a4,0(a5)
ffffffffc0202e60:	458d                	li	a1,3
ffffffffc0202e62:	2701                	sext.w	a4,a4
ffffffffc0202e64:	4eb71563          	bne	a4,a1,ffffffffc020334e <swap_init+0x700>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202e68:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202e6c:	4394                	lw	a3,0(a5)
ffffffffc0202e6e:	2681                	sext.w	a3,a3
ffffffffc0202e70:	4ee69f63          	bne	a3,a4,ffffffffc020336e <swap_init+0x720>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202e74:	6691                	lui	a3,0x4
ffffffffc0202e76:	4635                	li	a2,13
ffffffffc0202e78:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202e7c:	4398                	lw	a4,0(a5)
ffffffffc0202e7e:	2701                	sext.w	a4,a4
ffffffffc0202e80:	45471763          	bne	a4,s4,ffffffffc02032ce <swap_init+0x680>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202e84:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202e88:	439c                	lw	a5,0(a5)
ffffffffc0202e8a:	2781                	sext.w	a5,a5
ffffffffc0202e8c:	46e79163          	bne	a5,a4,ffffffffc02032ee <swap_init+0x6a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202e90:	481c                	lw	a5,16(s0)
ffffffffc0202e92:	2e079263          	bnez	a5,ffffffffc0203176 <swap_init+0x528>
ffffffffc0202e96:	0000f797          	auipc	a5,0xf
ffffffffc0202e9a:	62278793          	addi	a5,a5,1570 # ffffffffc02124b8 <swap_in_seq_no>
ffffffffc0202e9e:	0000f717          	auipc	a4,0xf
ffffffffc0202ea2:	64270713          	addi	a4,a4,1602 # ffffffffc02124e0 <swap_out_seq_no>
ffffffffc0202ea6:	0000f617          	auipc	a2,0xf
ffffffffc0202eaa:	63a60613          	addi	a2,a2,1594 # ffffffffc02124e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202eae:	56fd                	li	a3,-1
ffffffffc0202eb0:	c394                	sw	a3,0(a5)
ffffffffc0202eb2:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202eb4:	0791                	addi	a5,a5,4
ffffffffc0202eb6:	0711                	addi	a4,a4,4
ffffffffc0202eb8:	fec79ce3          	bne	a5,a2,ffffffffc0202eb0 <swap_init+0x262>
ffffffffc0202ebc:	0000f717          	auipc	a4,0xf
ffffffffc0202ec0:	5bc70713          	addi	a4,a4,1468 # ffffffffc0212478 <check_ptep>
ffffffffc0202ec4:	0000f697          	auipc	a3,0xf
ffffffffc0202ec8:	5d468693          	addi	a3,a3,1492 # ffffffffc0212498 <check_rp>
ffffffffc0202ecc:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202ece:	00013c17          	auipc	s8,0x13
ffffffffc0202ed2:	69ac0c13          	addi	s8,s8,1690 # ffffffffc0216568 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ed6:	00013c97          	auipc	s9,0x13
ffffffffc0202eda:	69ac8c93          	addi	s9,s9,1690 # ffffffffc0216570 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202ede:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ee2:	4601                	li	a2,0
ffffffffc0202ee4:	855a                	mv	a0,s6
ffffffffc0202ee6:	e836                	sd	a3,16(sp)
ffffffffc0202ee8:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202eea:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202eec:	c89fe0ef          	jal	ra,ffffffffc0201b74 <get_pte>
ffffffffc0202ef0:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202ef2:	65a2                	ld	a1,8(sp)
ffffffffc0202ef4:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ef6:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0202ef8:	1e050363          	beqz	a0,ffffffffc02030de <swap_init+0x490>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202efc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202efe:	0017f613          	andi	a2,a5,1
ffffffffc0202f02:	1e060e63          	beqz	a2,ffffffffc02030fe <swap_init+0x4b0>
    if (PPN(pa) >= npage) {
ffffffffc0202f06:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202f0a:	078a                	slli	a5,a5,0x2
ffffffffc0202f0c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f0e:	16c7f063          	bgeu	a5,a2,ffffffffc020306e <swap_init+0x420>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f12:	00004617          	auipc	a2,0x4
ffffffffc0202f16:	0fe60613          	addi	a2,a2,254 # ffffffffc0207010 <nbase>
ffffffffc0202f1a:	00063a03          	ld	s4,0(a2)
ffffffffc0202f1e:	000cb503          	ld	a0,0(s9)
ffffffffc0202f22:	0006b303          	ld	t1,0(a3)
ffffffffc0202f26:	414787b3          	sub	a5,a5,s4
ffffffffc0202f2a:	00379613          	slli	a2,a5,0x3
ffffffffc0202f2e:	97b2                	add	a5,a5,a2
ffffffffc0202f30:	078e                	slli	a5,a5,0x3
ffffffffc0202f32:	97aa                	add	a5,a5,a0
ffffffffc0202f34:	14f31963          	bne	t1,a5,ffffffffc0203086 <swap_init+0x438>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202f38:	6785                	lui	a5,0x1
ffffffffc0202f3a:	95be                	add	a1,a1,a5
ffffffffc0202f3c:	6795                	lui	a5,0x5
ffffffffc0202f3e:	0721                	addi	a4,a4,8
ffffffffc0202f40:	06a1                	addi	a3,a3,8
ffffffffc0202f42:	f8f59ee3          	bne	a1,a5,ffffffffc0202ede <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202f46:	00003517          	auipc	a0,0x3
ffffffffc0202f4a:	66250513          	addi	a0,a0,1634 # ffffffffc02065a8 <default_pmm_manager+0x8d8>
ffffffffc0202f4e:	a32fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202f52:	000bb783          	ld	a5,0(s7)
ffffffffc0202f56:	7f9c                	ld	a5,56(a5)
ffffffffc0202f58:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202f5a:	32051a63          	bnez	a0,ffffffffc020328e <swap_init+0x640>

     nr_free = nr_free_store;
ffffffffc0202f5e:	77a2                	ld	a5,40(sp)
ffffffffc0202f60:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202f62:	67e2                	ld	a5,24(sp)
ffffffffc0202f64:	e01c                	sd	a5,0(s0)
ffffffffc0202f66:	7782                	ld	a5,32(sp)
ffffffffc0202f68:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202f6a:	6088                	ld	a0,0(s1)
ffffffffc0202f6c:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202f6e:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0202f70:	b8bfe0ef          	jal	ra,ffffffffc0201afa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202f74:	ff349be3          	bne	s1,s3,ffffffffc0202f6a <swap_init+0x31c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202f78:	8556                	mv	a0,s5
ffffffffc0202f7a:	373000ef          	jal	ra,ffffffffc0203aec <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202f7e:	00013797          	auipc	a5,0x13
ffffffffc0202f82:	5e278793          	addi	a5,a5,1506 # ffffffffc0216560 <boot_pgdir>
ffffffffc0202f86:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202f88:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f8c:	6394                	ld	a3,0(a5)
ffffffffc0202f8e:	068a                	slli	a3,a3,0x2
ffffffffc0202f90:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f92:	0ce6fc63          	bgeu	a3,a4,ffffffffc020306a <swap_init+0x41c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f96:	414687b3          	sub	a5,a3,s4
ffffffffc0202f9a:	00379693          	slli	a3,a5,0x3
ffffffffc0202f9e:	96be                	add	a3,a3,a5
ffffffffc0202fa0:	068e                	slli	a3,a3,0x3
    return page - pages + nbase;
ffffffffc0202fa2:	00004797          	auipc	a5,0x4
ffffffffc0202fa6:	0667b783          	ld	a5,102(a5) # ffffffffc0207008 <error_string+0x38>
ffffffffc0202faa:	868d                	srai	a3,a3,0x3
ffffffffc0202fac:	02f686b3          	mul	a3,a3,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202fb0:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc0202fb4:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202fb6:	00c69793          	slli	a5,a3,0xc
ffffffffc0202fba:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202fbc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202fbe:	22e7fc63          	bgeu	a5,a4,ffffffffc02031f6 <swap_init+0x5a8>
     free_page(pde2page(pd0[0]));
ffffffffc0202fc2:	00013797          	auipc	a5,0x13
ffffffffc0202fc6:	5be7b783          	ld	a5,1470(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc0202fca:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fcc:	629c                	ld	a5,0(a3)
ffffffffc0202fce:	078a                	slli	a5,a5,0x2
ffffffffc0202fd0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fd2:	08e7fc63          	bgeu	a5,a4,ffffffffc020306a <swap_init+0x41c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fd6:	414787b3          	sub	a5,a5,s4
ffffffffc0202fda:	00379713          	slli	a4,a5,0x3
ffffffffc0202fde:	97ba                	add	a5,a5,a4
ffffffffc0202fe0:	078e                	slli	a5,a5,0x3
ffffffffc0202fe2:	953e                	add	a0,a0,a5
ffffffffc0202fe4:	4585                	li	a1,1
ffffffffc0202fe6:	b15fe0ef          	jal	ra,ffffffffc0201afa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fea:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202fee:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ff2:	078a                	slli	a5,a5,0x2
ffffffffc0202ff4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ff6:	06e7fa63          	bgeu	a5,a4,ffffffffc020306a <swap_init+0x41c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ffa:	414787b3          	sub	a5,a5,s4
ffffffffc0202ffe:	000cb503          	ld	a0,0(s9)
ffffffffc0203002:	00379a13          	slli	s4,a5,0x3
ffffffffc0203006:	97d2                	add	a5,a5,s4
ffffffffc0203008:	078e                	slli	a5,a5,0x3
     free_page(pde2page(pd1[0]));
ffffffffc020300a:	4585                	li	a1,1
ffffffffc020300c:	953e                	add	a0,a0,a5
ffffffffc020300e:	aedfe0ef          	jal	ra,ffffffffc0201afa <free_pages>
     pgdir[0] = 0;
ffffffffc0203012:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203016:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020301a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020301c:	00878a63          	beq	a5,s0,ffffffffc0203030 <swap_init+0x3e2>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203020:	ff07a703          	lw	a4,-16(a5)
ffffffffc0203024:	679c                	ld	a5,8(a5)
ffffffffc0203026:	3dfd                	addiw	s11,s11,-1
ffffffffc0203028:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020302c:	fe879ae3          	bne	a5,s0,ffffffffc0203020 <swap_init+0x3d2>
     }
     assert(count==0);
ffffffffc0203030:	1c0d9f63          	bnez	s11,ffffffffc020320e <swap_init+0x5c0>
     assert(total==0);
ffffffffc0203034:	1a0d1163          	bnez	s10,ffffffffc02031d6 <swap_init+0x588>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203038:	00003517          	auipc	a0,0x3
ffffffffc020303c:	5c050513          	addi	a0,a0,1472 # ffffffffc02065f8 <default_pmm_manager+0x928>
ffffffffc0203040:	940fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203044:	b9b1                	j	ffffffffc0202ca0 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203046:	4481                	li	s1,0
ffffffffc0203048:	b1c9                	j	ffffffffc0202d0a <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc020304a:	00003697          	auipc	a3,0x3
ffffffffc020304e:	8c668693          	addi	a3,a3,-1850 # ffffffffc0205910 <commands+0x728>
ffffffffc0203052:	00003617          	auipc	a2,0x3
ffffffffc0203056:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0205920 <commands+0x738>
ffffffffc020305a:	0bd00593          	li	a1,189
ffffffffc020305e:	00003517          	auipc	a0,0x3
ffffffffc0203062:	33250513          	addi	a0,a0,818 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc0203066:	be0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020306a:	bc9ff0ef          	jal	ra,ffffffffc0202c32 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc020306e:	00003617          	auipc	a2,0x3
ffffffffc0203072:	d6a60613          	addi	a2,a2,-662 # ffffffffc0205dd8 <default_pmm_manager+0x108>
ffffffffc0203076:	06200593          	li	a1,98
ffffffffc020307a:	00003517          	auipc	a0,0x3
ffffffffc020307e:	cb650513          	addi	a0,a0,-842 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc0203082:	bc4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203086:	00003697          	auipc	a3,0x3
ffffffffc020308a:	4fa68693          	addi	a3,a3,1274 # ffffffffc0206580 <default_pmm_manager+0x8b0>
ffffffffc020308e:	00003617          	auipc	a2,0x3
ffffffffc0203092:	89260613          	addi	a2,a2,-1902 # ffffffffc0205920 <commands+0x738>
ffffffffc0203096:	0fd00593          	li	a1,253
ffffffffc020309a:	00003517          	auipc	a0,0x3
ffffffffc020309e:	2f650513          	addi	a0,a0,758 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02030a2:	ba4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02030a6:	00003697          	auipc	a3,0x3
ffffffffc02030aa:	3fa68693          	addi	a3,a3,1018 # ffffffffc02064a0 <default_pmm_manager+0x7d0>
ffffffffc02030ae:	00003617          	auipc	a2,0x3
ffffffffc02030b2:	87260613          	addi	a2,a2,-1934 # ffffffffc0205920 <commands+0x738>
ffffffffc02030b6:	0dd00593          	li	a1,221
ffffffffc02030ba:	00003517          	auipc	a0,0x3
ffffffffc02030be:	2d650513          	addi	a0,a0,726 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02030c2:	b84fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02030c6:	00003617          	auipc	a2,0x3
ffffffffc02030ca:	2aa60613          	addi	a2,a2,682 # ffffffffc0206370 <default_pmm_manager+0x6a0>
ffffffffc02030ce:	02a00593          	li	a1,42
ffffffffc02030d2:	00003517          	auipc	a0,0x3
ffffffffc02030d6:	2be50513          	addi	a0,a0,702 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02030da:	b6cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02030de:	00003697          	auipc	a3,0x3
ffffffffc02030e2:	48a68693          	addi	a3,a3,1162 # ffffffffc0206568 <default_pmm_manager+0x898>
ffffffffc02030e6:	00003617          	auipc	a2,0x3
ffffffffc02030ea:	83a60613          	addi	a2,a2,-1990 # ffffffffc0205920 <commands+0x738>
ffffffffc02030ee:	0fc00593          	li	a1,252
ffffffffc02030f2:	00003517          	auipc	a0,0x3
ffffffffc02030f6:	29e50513          	addi	a0,a0,670 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02030fa:	b4cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02030fe:	00003617          	auipc	a2,0x3
ffffffffc0203102:	cfa60613          	addi	a2,a2,-774 # ffffffffc0205df8 <default_pmm_manager+0x128>
ffffffffc0203106:	07400593          	li	a1,116
ffffffffc020310a:	00003517          	auipc	a0,0x3
ffffffffc020310e:	c2650513          	addi	a0,a0,-986 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc0203112:	b34fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203116:	00003697          	auipc	a3,0x3
ffffffffc020311a:	3a268693          	addi	a3,a3,930 # ffffffffc02064b8 <default_pmm_manager+0x7e8>
ffffffffc020311e:	00003617          	auipc	a2,0x3
ffffffffc0203122:	80260613          	addi	a2,a2,-2046 # ffffffffc0205920 <commands+0x738>
ffffffffc0203126:	0de00593          	li	a1,222
ffffffffc020312a:	00003517          	auipc	a0,0x3
ffffffffc020312e:	26650513          	addi	a0,a0,614 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc0203132:	b14fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203136:	00003697          	auipc	a3,0x3
ffffffffc020313a:	2ba68693          	addi	a3,a3,698 # ffffffffc02063f0 <default_pmm_manager+0x720>
ffffffffc020313e:	00002617          	auipc	a2,0x2
ffffffffc0203142:	7e260613          	addi	a2,a2,2018 # ffffffffc0205920 <commands+0x738>
ffffffffc0203146:	0c800593          	li	a1,200
ffffffffc020314a:	00003517          	auipc	a0,0x3
ffffffffc020314e:	24650513          	addi	a0,a0,582 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc0203152:	af4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203156:	00002697          	auipc	a3,0x2
ffffffffc020315a:	7fa68693          	addi	a3,a3,2042 # ffffffffc0205950 <commands+0x768>
ffffffffc020315e:	00002617          	auipc	a2,0x2
ffffffffc0203162:	7c260613          	addi	a2,a2,1986 # ffffffffc0205920 <commands+0x738>
ffffffffc0203166:	0c000593          	li	a1,192
ffffffffc020316a:	00003517          	auipc	a0,0x3
ffffffffc020316e:	22650513          	addi	a0,a0,550 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc0203172:	ad4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert( nr_free == 0);         
ffffffffc0203176:	00003697          	auipc	a3,0x3
ffffffffc020317a:	98268693          	addi	a3,a3,-1662 # ffffffffc0205af8 <commands+0x910>
ffffffffc020317e:	00002617          	auipc	a2,0x2
ffffffffc0203182:	7a260613          	addi	a2,a2,1954 # ffffffffc0205920 <commands+0x738>
ffffffffc0203186:	0f400593          	li	a1,244
ffffffffc020318a:	00003517          	auipc	a0,0x3
ffffffffc020318e:	20650513          	addi	a0,a0,518 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc0203192:	ab4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203196:	00003697          	auipc	a3,0x3
ffffffffc020319a:	27268693          	addi	a3,a3,626 # ffffffffc0206408 <default_pmm_manager+0x738>
ffffffffc020319e:	00002617          	auipc	a2,0x2
ffffffffc02031a2:	78260613          	addi	a2,a2,1922 # ffffffffc0205920 <commands+0x738>
ffffffffc02031a6:	0cd00593          	li	a1,205
ffffffffc02031aa:	00003517          	auipc	a0,0x3
ffffffffc02031ae:	1e650513          	addi	a0,a0,486 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02031b2:	a94fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(mm != NULL);
ffffffffc02031b6:	00003697          	auipc	a3,0x3
ffffffffc02031ba:	22a68693          	addi	a3,a3,554 # ffffffffc02063e0 <default_pmm_manager+0x710>
ffffffffc02031be:	00002617          	auipc	a2,0x2
ffffffffc02031c2:	76260613          	addi	a2,a2,1890 # ffffffffc0205920 <commands+0x738>
ffffffffc02031c6:	0c500593          	li	a1,197
ffffffffc02031ca:	00003517          	auipc	a0,0x3
ffffffffc02031ce:	1c650513          	addi	a0,a0,454 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02031d2:	a74fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total==0);
ffffffffc02031d6:	00003697          	auipc	a3,0x3
ffffffffc02031da:	41268693          	addi	a3,a3,1042 # ffffffffc02065e8 <default_pmm_manager+0x918>
ffffffffc02031de:	00002617          	auipc	a2,0x2
ffffffffc02031e2:	74260613          	addi	a2,a2,1858 # ffffffffc0205920 <commands+0x738>
ffffffffc02031e6:	11d00593          	li	a1,285
ffffffffc02031ea:	00003517          	auipc	a0,0x3
ffffffffc02031ee:	1a650513          	addi	a0,a0,422 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02031f2:	a54fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02031f6:	00003617          	auipc	a2,0x3
ffffffffc02031fa:	b1260613          	addi	a2,a2,-1262 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc02031fe:	06900593          	li	a1,105
ffffffffc0203202:	00003517          	auipc	a0,0x3
ffffffffc0203206:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc020320a:	a3cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(count==0);
ffffffffc020320e:	00003697          	auipc	a3,0x3
ffffffffc0203212:	3ca68693          	addi	a3,a3,970 # ffffffffc02065d8 <default_pmm_manager+0x908>
ffffffffc0203216:	00002617          	auipc	a2,0x2
ffffffffc020321a:	70a60613          	addi	a2,a2,1802 # ffffffffc0205920 <commands+0x738>
ffffffffc020321e:	11c00593          	li	a1,284
ffffffffc0203222:	00003517          	auipc	a0,0x3
ffffffffc0203226:	16e50513          	addi	a0,a0,366 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020322a:	a1cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc020322e:	00003697          	auipc	a3,0x3
ffffffffc0203232:	2fa68693          	addi	a3,a3,762 # ffffffffc0206528 <default_pmm_manager+0x858>
ffffffffc0203236:	00002617          	auipc	a2,0x2
ffffffffc020323a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0205920 <commands+0x738>
ffffffffc020323e:	09600593          	li	a1,150
ffffffffc0203242:	00003517          	auipc	a0,0x3
ffffffffc0203246:	14e50513          	addi	a0,a0,334 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020324a:	9fcfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020324e:	00003697          	auipc	a3,0x3
ffffffffc0203252:	28a68693          	addi	a3,a3,650 # ffffffffc02064d8 <default_pmm_manager+0x808>
ffffffffc0203256:	00002617          	auipc	a2,0x2
ffffffffc020325a:	6ca60613          	addi	a2,a2,1738 # ffffffffc0205920 <commands+0x738>
ffffffffc020325e:	0eb00593          	li	a1,235
ffffffffc0203262:	00003517          	auipc	a0,0x3
ffffffffc0203266:	12e50513          	addi	a0,a0,302 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020326a:	9dcfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020326e:	00003697          	auipc	a3,0x3
ffffffffc0203272:	1f268693          	addi	a3,a3,498 # ffffffffc0206460 <default_pmm_manager+0x790>
ffffffffc0203276:	00002617          	auipc	a2,0x2
ffffffffc020327a:	6aa60613          	addi	a2,a2,1706 # ffffffffc0205920 <commands+0x738>
ffffffffc020327e:	0d800593          	li	a1,216
ffffffffc0203282:	00003517          	auipc	a0,0x3
ffffffffc0203286:	10e50513          	addi	a0,a0,270 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020328a:	9bcfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(ret==0);
ffffffffc020328e:	00003697          	auipc	a3,0x3
ffffffffc0203292:	34268693          	addi	a3,a3,834 # ffffffffc02065d0 <default_pmm_manager+0x900>
ffffffffc0203296:	00002617          	auipc	a2,0x2
ffffffffc020329a:	68a60613          	addi	a2,a2,1674 # ffffffffc0205920 <commands+0x738>
ffffffffc020329e:	10300593          	li	a1,259
ffffffffc02032a2:	00003517          	auipc	a0,0x3
ffffffffc02032a6:	0ee50513          	addi	a0,a0,238 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02032aa:	99cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(vma != NULL);
ffffffffc02032ae:	00003697          	auipc	a3,0x3
ffffffffc02032b2:	16a68693          	addi	a3,a3,362 # ffffffffc0206418 <default_pmm_manager+0x748>
ffffffffc02032b6:	00002617          	auipc	a2,0x2
ffffffffc02032ba:	66a60613          	addi	a2,a2,1642 # ffffffffc0205920 <commands+0x738>
ffffffffc02032be:	0d000593          	li	a1,208
ffffffffc02032c2:	00003517          	auipc	a0,0x3
ffffffffc02032c6:	0ce50513          	addi	a0,a0,206 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02032ca:	97cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc02032ce:	00003697          	auipc	a3,0x3
ffffffffc02032d2:	28a68693          	addi	a3,a3,650 # ffffffffc0206558 <default_pmm_manager+0x888>
ffffffffc02032d6:	00002617          	auipc	a2,0x2
ffffffffc02032da:	64a60613          	addi	a2,a2,1610 # ffffffffc0205920 <commands+0x738>
ffffffffc02032de:	0a000593          	li	a1,160
ffffffffc02032e2:	00003517          	auipc	a0,0x3
ffffffffc02032e6:	0ae50513          	addi	a0,a0,174 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02032ea:	95cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc02032ee:	00003697          	auipc	a3,0x3
ffffffffc02032f2:	26a68693          	addi	a3,a3,618 # ffffffffc0206558 <default_pmm_manager+0x888>
ffffffffc02032f6:	00002617          	auipc	a2,0x2
ffffffffc02032fa:	62a60613          	addi	a2,a2,1578 # ffffffffc0205920 <commands+0x738>
ffffffffc02032fe:	0a200593          	li	a1,162
ffffffffc0203302:	00003517          	auipc	a0,0x3
ffffffffc0203306:	08e50513          	addi	a0,a0,142 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020330a:	93cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc020330e:	00003697          	auipc	a3,0x3
ffffffffc0203312:	22a68693          	addi	a3,a3,554 # ffffffffc0206538 <default_pmm_manager+0x868>
ffffffffc0203316:	00002617          	auipc	a2,0x2
ffffffffc020331a:	60a60613          	addi	a2,a2,1546 # ffffffffc0205920 <commands+0x738>
ffffffffc020331e:	09800593          	li	a1,152
ffffffffc0203322:	00003517          	auipc	a0,0x3
ffffffffc0203326:	06e50513          	addi	a0,a0,110 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020332a:	91cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc020332e:	00003697          	auipc	a3,0x3
ffffffffc0203332:	20a68693          	addi	a3,a3,522 # ffffffffc0206538 <default_pmm_manager+0x868>
ffffffffc0203336:	00002617          	auipc	a2,0x2
ffffffffc020333a:	5ea60613          	addi	a2,a2,1514 # ffffffffc0205920 <commands+0x738>
ffffffffc020333e:	09a00593          	li	a1,154
ffffffffc0203342:	00003517          	auipc	a0,0x3
ffffffffc0203346:	04e50513          	addi	a0,a0,78 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020334a:	8fcfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc020334e:	00003697          	auipc	a3,0x3
ffffffffc0203352:	1fa68693          	addi	a3,a3,506 # ffffffffc0206548 <default_pmm_manager+0x878>
ffffffffc0203356:	00002617          	auipc	a2,0x2
ffffffffc020335a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0205920 <commands+0x738>
ffffffffc020335e:	09c00593          	li	a1,156
ffffffffc0203362:	00003517          	auipc	a0,0x3
ffffffffc0203366:	02e50513          	addi	a0,a0,46 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020336a:	8dcfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc020336e:	00003697          	auipc	a3,0x3
ffffffffc0203372:	1da68693          	addi	a3,a3,474 # ffffffffc0206548 <default_pmm_manager+0x878>
ffffffffc0203376:	00002617          	auipc	a2,0x2
ffffffffc020337a:	5aa60613          	addi	a2,a2,1450 # ffffffffc0205920 <commands+0x738>
ffffffffc020337e:	09e00593          	li	a1,158
ffffffffc0203382:	00003517          	auipc	a0,0x3
ffffffffc0203386:	00e50513          	addi	a0,a0,14 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc020338a:	8bcfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc020338e:	00003697          	auipc	a3,0x3
ffffffffc0203392:	19a68693          	addi	a3,a3,410 # ffffffffc0206528 <default_pmm_manager+0x858>
ffffffffc0203396:	00002617          	auipc	a2,0x2
ffffffffc020339a:	58a60613          	addi	a2,a2,1418 # ffffffffc0205920 <commands+0x738>
ffffffffc020339e:	09400593          	li	a1,148
ffffffffc02033a2:	00003517          	auipc	a0,0x3
ffffffffc02033a6:	fee50513          	addi	a0,a0,-18 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02033aa:	89cfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02033ae <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02033ae:	00013797          	auipc	a5,0x13
ffffffffc02033b2:	1e27b783          	ld	a5,482(a5) # ffffffffc0216590 <sm>
ffffffffc02033b6:	6b9c                	ld	a5,16(a5)
ffffffffc02033b8:	8782                	jr	a5

ffffffffc02033ba <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02033ba:	00013797          	auipc	a5,0x13
ffffffffc02033be:	1d67b783          	ld	a5,470(a5) # ffffffffc0216590 <sm>
ffffffffc02033c2:	739c                	ld	a5,32(a5)
ffffffffc02033c4:	8782                	jr	a5

ffffffffc02033c6 <swap_out>:
{
ffffffffc02033c6:	711d                	addi	sp,sp,-96
ffffffffc02033c8:	ec86                	sd	ra,88(sp)
ffffffffc02033ca:	e8a2                	sd	s0,80(sp)
ffffffffc02033cc:	e4a6                	sd	s1,72(sp)
ffffffffc02033ce:	e0ca                	sd	s2,64(sp)
ffffffffc02033d0:	fc4e                	sd	s3,56(sp)
ffffffffc02033d2:	f852                	sd	s4,48(sp)
ffffffffc02033d4:	f456                	sd	s5,40(sp)
ffffffffc02033d6:	f05a                	sd	s6,32(sp)
ffffffffc02033d8:	ec5e                	sd	s7,24(sp)
ffffffffc02033da:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02033dc:	cde9                	beqz	a1,ffffffffc02034b6 <swap_out+0xf0>
ffffffffc02033de:	8a2e                	mv	s4,a1
ffffffffc02033e0:	892a                	mv	s2,a0
ffffffffc02033e2:	8ab2                	mv	s5,a2
ffffffffc02033e4:	4401                	li	s0,0
ffffffffc02033e6:	00013997          	auipc	s3,0x13
ffffffffc02033ea:	1aa98993          	addi	s3,s3,426 # ffffffffc0216590 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02033ee:	00003b17          	auipc	s6,0x3
ffffffffc02033f2:	28ab0b13          	addi	s6,s6,650 # ffffffffc0206678 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc02033f6:	00003b97          	auipc	s7,0x3
ffffffffc02033fa:	26ab8b93          	addi	s7,s7,618 # ffffffffc0206660 <default_pmm_manager+0x990>
ffffffffc02033fe:	a825                	j	ffffffffc0203436 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203400:	67a2                	ld	a5,8(sp)
ffffffffc0203402:	8626                	mv	a2,s1
ffffffffc0203404:	85a2                	mv	a1,s0
ffffffffc0203406:	63b4                	ld	a3,64(a5)
ffffffffc0203408:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc020340a:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020340c:	82b1                	srli	a3,a3,0xc
ffffffffc020340e:	0685                	addi	a3,a3,1
ffffffffc0203410:	d71fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203414:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203416:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203418:	613c                	ld	a5,64(a0)
ffffffffc020341a:	83b1                	srli	a5,a5,0xc
ffffffffc020341c:	0785                	addi	a5,a5,1
ffffffffc020341e:	07a2                	slli	a5,a5,0x8
ffffffffc0203420:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203424:	ed6fe0ef          	jal	ra,ffffffffc0201afa <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203428:	01893503          	ld	a0,24(s2)
ffffffffc020342c:	85a6                	mv	a1,s1
ffffffffc020342e:	f46ff0ef          	jal	ra,ffffffffc0202b74 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203432:	048a0d63          	beq	s4,s0,ffffffffc020348c <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203436:	0009b783          	ld	a5,0(s3)
ffffffffc020343a:	8656                	mv	a2,s5
ffffffffc020343c:	002c                	addi	a1,sp,8
ffffffffc020343e:	7b9c                	ld	a5,48(a5)
ffffffffc0203440:	854a                	mv	a0,s2
ffffffffc0203442:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203444:	e12d                	bnez	a0,ffffffffc02034a6 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203446:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203448:	01893503          	ld	a0,24(s2)
ffffffffc020344c:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020344e:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203450:	85a6                	mv	a1,s1
ffffffffc0203452:	f22fe0ef          	jal	ra,ffffffffc0201b74 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203456:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203458:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc020345a:	8b85                	andi	a5,a5,1
ffffffffc020345c:	cfb9                	beqz	a5,ffffffffc02034ba <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020345e:	65a2                	ld	a1,8(sp)
ffffffffc0203460:	61bc                	ld	a5,64(a1)
ffffffffc0203462:	83b1                	srli	a5,a5,0xc
ffffffffc0203464:	0785                	addi	a5,a5,1
ffffffffc0203466:	00879513          	slli	a0,a5,0x8
ffffffffc020346a:	655000ef          	jal	ra,ffffffffc02042be <swapfs_write>
ffffffffc020346e:	d949                	beqz	a0,ffffffffc0203400 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203470:	855e                	mv	a0,s7
ffffffffc0203472:	d0ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203476:	0009b783          	ld	a5,0(s3)
ffffffffc020347a:	6622                	ld	a2,8(sp)
ffffffffc020347c:	4681                	li	a3,0
ffffffffc020347e:	739c                	ld	a5,32(a5)
ffffffffc0203480:	85a6                	mv	a1,s1
ffffffffc0203482:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203484:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203486:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203488:	fa8a17e3          	bne	s4,s0,ffffffffc0203436 <swap_out+0x70>
}
ffffffffc020348c:	60e6                	ld	ra,88(sp)
ffffffffc020348e:	8522                	mv	a0,s0
ffffffffc0203490:	6446                	ld	s0,80(sp)
ffffffffc0203492:	64a6                	ld	s1,72(sp)
ffffffffc0203494:	6906                	ld	s2,64(sp)
ffffffffc0203496:	79e2                	ld	s3,56(sp)
ffffffffc0203498:	7a42                	ld	s4,48(sp)
ffffffffc020349a:	7aa2                	ld	s5,40(sp)
ffffffffc020349c:	7b02                	ld	s6,32(sp)
ffffffffc020349e:	6be2                	ld	s7,24(sp)
ffffffffc02034a0:	6c42                	ld	s8,16(sp)
ffffffffc02034a2:	6125                	addi	sp,sp,96
ffffffffc02034a4:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02034a6:	85a2                	mv	a1,s0
ffffffffc02034a8:	00003517          	auipc	a0,0x3
ffffffffc02034ac:	17050513          	addi	a0,a0,368 # ffffffffc0206618 <default_pmm_manager+0x948>
ffffffffc02034b0:	cd1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc02034b4:	bfe1                	j	ffffffffc020348c <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02034b6:	4401                	li	s0,0
ffffffffc02034b8:	bfd1                	j	ffffffffc020348c <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02034ba:	00003697          	auipc	a3,0x3
ffffffffc02034be:	18e68693          	addi	a3,a3,398 # ffffffffc0206648 <default_pmm_manager+0x978>
ffffffffc02034c2:	00002617          	auipc	a2,0x2
ffffffffc02034c6:	45e60613          	addi	a2,a2,1118 # ffffffffc0205920 <commands+0x738>
ffffffffc02034ca:	06900593          	li	a1,105
ffffffffc02034ce:	00003517          	auipc	a0,0x3
ffffffffc02034d2:	ec250513          	addi	a0,a0,-318 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc02034d6:	f71fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02034da <swap_in>:
{
ffffffffc02034da:	7179                	addi	sp,sp,-48
ffffffffc02034dc:	e84a                	sd	s2,16(sp)
ffffffffc02034de:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02034e0:	4505                	li	a0,1
{
ffffffffc02034e2:	ec26                	sd	s1,24(sp)
ffffffffc02034e4:	e44e                	sd	s3,8(sp)
ffffffffc02034e6:	f406                	sd	ra,40(sp)
ffffffffc02034e8:	f022                	sd	s0,32(sp)
ffffffffc02034ea:	84ae                	mv	s1,a1
ffffffffc02034ec:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02034ee:	d7afe0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
     assert(result!=NULL);
ffffffffc02034f2:	c129                	beqz	a0,ffffffffc0203534 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02034f4:	842a                	mv	s0,a0
ffffffffc02034f6:	01893503          	ld	a0,24(s2)
ffffffffc02034fa:	4601                	li	a2,0
ffffffffc02034fc:	85a6                	mv	a1,s1
ffffffffc02034fe:	e76fe0ef          	jal	ra,ffffffffc0201b74 <get_pte>
ffffffffc0203502:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203504:	6108                	ld	a0,0(a0)
ffffffffc0203506:	85a2                	mv	a1,s0
ffffffffc0203508:	51d000ef          	jal	ra,ffffffffc0204224 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc020350c:	00093583          	ld	a1,0(s2)
ffffffffc0203510:	8626                	mv	a2,s1
ffffffffc0203512:	00003517          	auipc	a0,0x3
ffffffffc0203516:	1b650513          	addi	a0,a0,438 # ffffffffc02066c8 <default_pmm_manager+0x9f8>
ffffffffc020351a:	81a1                	srli	a1,a1,0x8
ffffffffc020351c:	c65fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203520:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203522:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203526:	7402                	ld	s0,32(sp)
ffffffffc0203528:	64e2                	ld	s1,24(sp)
ffffffffc020352a:	6942                	ld	s2,16(sp)
ffffffffc020352c:	69a2                	ld	s3,8(sp)
ffffffffc020352e:	4501                	li	a0,0
ffffffffc0203530:	6145                	addi	sp,sp,48
ffffffffc0203532:	8082                	ret
     assert(result!=NULL);
ffffffffc0203534:	00003697          	auipc	a3,0x3
ffffffffc0203538:	18468693          	addi	a3,a3,388 # ffffffffc02066b8 <default_pmm_manager+0x9e8>
ffffffffc020353c:	00002617          	auipc	a2,0x2
ffffffffc0203540:	3e460613          	addi	a2,a2,996 # ffffffffc0205920 <commands+0x738>
ffffffffc0203544:	07f00593          	li	a1,127
ffffffffc0203548:	00003517          	auipc	a0,0x3
ffffffffc020354c:	e4850513          	addi	a0,a0,-440 # ffffffffc0206390 <default_pmm_manager+0x6c0>
ffffffffc0203550:	ef7fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203554 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203554:	0000f797          	auipc	a5,0xf
ffffffffc0203558:	fb478793          	addi	a5,a5,-76 # ffffffffc0212508 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020355c:	f51c                	sd	a5,40(a0)
ffffffffc020355e:	e79c                	sd	a5,8(a5)
ffffffffc0203560:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203562:	4501                	li	a0,0
ffffffffc0203564:	8082                	ret

ffffffffc0203566 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203566:	4501                	li	a0,0
ffffffffc0203568:	8082                	ret

ffffffffc020356a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020356a:	4501                	li	a0,0
ffffffffc020356c:	8082                	ret

ffffffffc020356e <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020356e:	4501                	li	a0,0
ffffffffc0203570:	8082                	ret

ffffffffc0203572 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203572:	711d                	addi	sp,sp,-96
ffffffffc0203574:	fc4e                	sd	s3,56(sp)
ffffffffc0203576:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203578:	00003517          	auipc	a0,0x3
ffffffffc020357c:	19050513          	addi	a0,a0,400 # ffffffffc0206708 <default_pmm_manager+0xa38>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203580:	698d                	lui	s3,0x3
ffffffffc0203582:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203584:	e0ca                	sd	s2,64(sp)
ffffffffc0203586:	ec86                	sd	ra,88(sp)
ffffffffc0203588:	e8a2                	sd	s0,80(sp)
ffffffffc020358a:	e4a6                	sd	s1,72(sp)
ffffffffc020358c:	f456                	sd	s5,40(sp)
ffffffffc020358e:	f05a                	sd	s6,32(sp)
ffffffffc0203590:	ec5e                	sd	s7,24(sp)
ffffffffc0203592:	e862                	sd	s8,16(sp)
ffffffffc0203594:	e466                	sd	s9,8(sp)
ffffffffc0203596:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203598:	be9fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020359c:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02035a0:	00013917          	auipc	s2,0x13
ffffffffc02035a4:	00892903          	lw	s2,8(s2) # ffffffffc02165a8 <pgfault_num>
ffffffffc02035a8:	4791                	li	a5,4
ffffffffc02035aa:	14f91e63          	bne	s2,a5,ffffffffc0203706 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035ae:	00003517          	auipc	a0,0x3
ffffffffc02035b2:	19a50513          	addi	a0,a0,410 # ffffffffc0206748 <default_pmm_manager+0xa78>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035b6:	6a85                	lui	s5,0x1
ffffffffc02035b8:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035ba:	bc7fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02035be:	00013417          	auipc	s0,0x13
ffffffffc02035c2:	fea40413          	addi	s0,s0,-22 # ffffffffc02165a8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035c6:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02035ca:	4004                	lw	s1,0(s0)
ffffffffc02035cc:	2481                	sext.w	s1,s1
ffffffffc02035ce:	2b249c63          	bne	s1,s2,ffffffffc0203886 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02035d2:	00003517          	auipc	a0,0x3
ffffffffc02035d6:	19e50513          	addi	a0,a0,414 # ffffffffc0206770 <default_pmm_manager+0xaa0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035da:	6b91                	lui	s7,0x4
ffffffffc02035dc:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02035de:	ba3fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035e2:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02035e6:	00042903          	lw	s2,0(s0)
ffffffffc02035ea:	2901                	sext.w	s2,s2
ffffffffc02035ec:	26991d63          	bne	s2,s1,ffffffffc0203866 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02035f0:	00003517          	auipc	a0,0x3
ffffffffc02035f4:	1a850513          	addi	a0,a0,424 # ffffffffc0206798 <default_pmm_manager+0xac8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035f8:	6c89                	lui	s9,0x2
ffffffffc02035fa:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02035fc:	b85fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203600:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203604:	401c                	lw	a5,0(s0)
ffffffffc0203606:	2781                	sext.w	a5,a5
ffffffffc0203608:	23279f63          	bne	a5,s2,ffffffffc0203846 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020360c:	00003517          	auipc	a0,0x3
ffffffffc0203610:	1b450513          	addi	a0,a0,436 # ffffffffc02067c0 <default_pmm_manager+0xaf0>
ffffffffc0203614:	b6dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203618:	6795                	lui	a5,0x5
ffffffffc020361a:	4739                	li	a4,14
ffffffffc020361c:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203620:	4004                	lw	s1,0(s0)
ffffffffc0203622:	4795                	li	a5,5
ffffffffc0203624:	2481                	sext.w	s1,s1
ffffffffc0203626:	20f49063          	bne	s1,a5,ffffffffc0203826 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020362a:	00003517          	auipc	a0,0x3
ffffffffc020362e:	16e50513          	addi	a0,a0,366 # ffffffffc0206798 <default_pmm_manager+0xac8>
ffffffffc0203632:	b4ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203636:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020363a:	401c                	lw	a5,0(s0)
ffffffffc020363c:	2781                	sext.w	a5,a5
ffffffffc020363e:	1c979463          	bne	a5,s1,ffffffffc0203806 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203642:	00003517          	auipc	a0,0x3
ffffffffc0203646:	10650513          	addi	a0,a0,262 # ffffffffc0206748 <default_pmm_manager+0xa78>
ffffffffc020364a:	b37fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020364e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203652:	401c                	lw	a5,0(s0)
ffffffffc0203654:	4719                	li	a4,6
ffffffffc0203656:	2781                	sext.w	a5,a5
ffffffffc0203658:	18e79763          	bne	a5,a4,ffffffffc02037e6 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020365c:	00003517          	auipc	a0,0x3
ffffffffc0203660:	13c50513          	addi	a0,a0,316 # ffffffffc0206798 <default_pmm_manager+0xac8>
ffffffffc0203664:	b1dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203668:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc020366c:	401c                	lw	a5,0(s0)
ffffffffc020366e:	471d                	li	a4,7
ffffffffc0203670:	2781                	sext.w	a5,a5
ffffffffc0203672:	14e79a63          	bne	a5,a4,ffffffffc02037c6 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203676:	00003517          	auipc	a0,0x3
ffffffffc020367a:	09250513          	addi	a0,a0,146 # ffffffffc0206708 <default_pmm_manager+0xa38>
ffffffffc020367e:	b03fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203682:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203686:	401c                	lw	a5,0(s0)
ffffffffc0203688:	4721                	li	a4,8
ffffffffc020368a:	2781                	sext.w	a5,a5
ffffffffc020368c:	10e79d63          	bne	a5,a4,ffffffffc02037a6 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203690:	00003517          	auipc	a0,0x3
ffffffffc0203694:	0e050513          	addi	a0,a0,224 # ffffffffc0206770 <default_pmm_manager+0xaa0>
ffffffffc0203698:	ae9fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020369c:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02036a0:	401c                	lw	a5,0(s0)
ffffffffc02036a2:	4725                	li	a4,9
ffffffffc02036a4:	2781                	sext.w	a5,a5
ffffffffc02036a6:	0ee79063          	bne	a5,a4,ffffffffc0203786 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02036aa:	00003517          	auipc	a0,0x3
ffffffffc02036ae:	11650513          	addi	a0,a0,278 # ffffffffc02067c0 <default_pmm_manager+0xaf0>
ffffffffc02036b2:	acffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02036b6:	6795                	lui	a5,0x5
ffffffffc02036b8:	4739                	li	a4,14
ffffffffc02036ba:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02036be:	4004                	lw	s1,0(s0)
ffffffffc02036c0:	47a9                	li	a5,10
ffffffffc02036c2:	2481                	sext.w	s1,s1
ffffffffc02036c4:	0af49163          	bne	s1,a5,ffffffffc0203766 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02036c8:	00003517          	auipc	a0,0x3
ffffffffc02036cc:	08050513          	addi	a0,a0,128 # ffffffffc0206748 <default_pmm_manager+0xa78>
ffffffffc02036d0:	ab1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02036d4:	6785                	lui	a5,0x1
ffffffffc02036d6:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02036da:	06979663          	bne	a5,s1,ffffffffc0203746 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc02036de:	401c                	lw	a5,0(s0)
ffffffffc02036e0:	472d                	li	a4,11
ffffffffc02036e2:	2781                	sext.w	a5,a5
ffffffffc02036e4:	04e79163          	bne	a5,a4,ffffffffc0203726 <_fifo_check_swap+0x1b4>
}
ffffffffc02036e8:	60e6                	ld	ra,88(sp)
ffffffffc02036ea:	6446                	ld	s0,80(sp)
ffffffffc02036ec:	64a6                	ld	s1,72(sp)
ffffffffc02036ee:	6906                	ld	s2,64(sp)
ffffffffc02036f0:	79e2                	ld	s3,56(sp)
ffffffffc02036f2:	7a42                	ld	s4,48(sp)
ffffffffc02036f4:	7aa2                	ld	s5,40(sp)
ffffffffc02036f6:	7b02                	ld	s6,32(sp)
ffffffffc02036f8:	6be2                	ld	s7,24(sp)
ffffffffc02036fa:	6c42                	ld	s8,16(sp)
ffffffffc02036fc:	6ca2                	ld	s9,8(sp)
ffffffffc02036fe:	6d02                	ld	s10,0(sp)
ffffffffc0203700:	4501                	li	a0,0
ffffffffc0203702:	6125                	addi	sp,sp,96
ffffffffc0203704:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203706:	00003697          	auipc	a3,0x3
ffffffffc020370a:	e5268693          	addi	a3,a3,-430 # ffffffffc0206558 <default_pmm_manager+0x888>
ffffffffc020370e:	00002617          	auipc	a2,0x2
ffffffffc0203712:	21260613          	addi	a2,a2,530 # ffffffffc0205920 <commands+0x738>
ffffffffc0203716:	05100593          	li	a1,81
ffffffffc020371a:	00003517          	auipc	a0,0x3
ffffffffc020371e:	01650513          	addi	a0,a0,22 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203722:	d25fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==11);
ffffffffc0203726:	00003697          	auipc	a3,0x3
ffffffffc020372a:	14a68693          	addi	a3,a3,330 # ffffffffc0206870 <default_pmm_manager+0xba0>
ffffffffc020372e:	00002617          	auipc	a2,0x2
ffffffffc0203732:	1f260613          	addi	a2,a2,498 # ffffffffc0205920 <commands+0x738>
ffffffffc0203736:	07300593          	li	a1,115
ffffffffc020373a:	00003517          	auipc	a0,0x3
ffffffffc020373e:	ff650513          	addi	a0,a0,-10 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203742:	d05fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203746:	00003697          	auipc	a3,0x3
ffffffffc020374a:	10268693          	addi	a3,a3,258 # ffffffffc0206848 <default_pmm_manager+0xb78>
ffffffffc020374e:	00002617          	auipc	a2,0x2
ffffffffc0203752:	1d260613          	addi	a2,a2,466 # ffffffffc0205920 <commands+0x738>
ffffffffc0203756:	07100593          	li	a1,113
ffffffffc020375a:	00003517          	auipc	a0,0x3
ffffffffc020375e:	fd650513          	addi	a0,a0,-42 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203762:	ce5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==10);
ffffffffc0203766:	00003697          	auipc	a3,0x3
ffffffffc020376a:	0d268693          	addi	a3,a3,210 # ffffffffc0206838 <default_pmm_manager+0xb68>
ffffffffc020376e:	00002617          	auipc	a2,0x2
ffffffffc0203772:	1b260613          	addi	a2,a2,434 # ffffffffc0205920 <commands+0x738>
ffffffffc0203776:	06f00593          	li	a1,111
ffffffffc020377a:	00003517          	auipc	a0,0x3
ffffffffc020377e:	fb650513          	addi	a0,a0,-74 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203782:	cc5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==9);
ffffffffc0203786:	00003697          	auipc	a3,0x3
ffffffffc020378a:	0a268693          	addi	a3,a3,162 # ffffffffc0206828 <default_pmm_manager+0xb58>
ffffffffc020378e:	00002617          	auipc	a2,0x2
ffffffffc0203792:	19260613          	addi	a2,a2,402 # ffffffffc0205920 <commands+0x738>
ffffffffc0203796:	06c00593          	li	a1,108
ffffffffc020379a:	00003517          	auipc	a0,0x3
ffffffffc020379e:	f9650513          	addi	a0,a0,-106 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc02037a2:	ca5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==8);
ffffffffc02037a6:	00003697          	auipc	a3,0x3
ffffffffc02037aa:	07268693          	addi	a3,a3,114 # ffffffffc0206818 <default_pmm_manager+0xb48>
ffffffffc02037ae:	00002617          	auipc	a2,0x2
ffffffffc02037b2:	17260613          	addi	a2,a2,370 # ffffffffc0205920 <commands+0x738>
ffffffffc02037b6:	06900593          	li	a1,105
ffffffffc02037ba:	00003517          	auipc	a0,0x3
ffffffffc02037be:	f7650513          	addi	a0,a0,-138 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc02037c2:	c85fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==7);
ffffffffc02037c6:	00003697          	auipc	a3,0x3
ffffffffc02037ca:	04268693          	addi	a3,a3,66 # ffffffffc0206808 <default_pmm_manager+0xb38>
ffffffffc02037ce:	00002617          	auipc	a2,0x2
ffffffffc02037d2:	15260613          	addi	a2,a2,338 # ffffffffc0205920 <commands+0x738>
ffffffffc02037d6:	06600593          	li	a1,102
ffffffffc02037da:	00003517          	auipc	a0,0x3
ffffffffc02037de:	f5650513          	addi	a0,a0,-170 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc02037e2:	c65fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==6);
ffffffffc02037e6:	00003697          	auipc	a3,0x3
ffffffffc02037ea:	01268693          	addi	a3,a3,18 # ffffffffc02067f8 <default_pmm_manager+0xb28>
ffffffffc02037ee:	00002617          	auipc	a2,0x2
ffffffffc02037f2:	13260613          	addi	a2,a2,306 # ffffffffc0205920 <commands+0x738>
ffffffffc02037f6:	06300593          	li	a1,99
ffffffffc02037fa:	00003517          	auipc	a0,0x3
ffffffffc02037fe:	f3650513          	addi	a0,a0,-202 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203802:	c45fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc0203806:	00003697          	auipc	a3,0x3
ffffffffc020380a:	fe268693          	addi	a3,a3,-30 # ffffffffc02067e8 <default_pmm_manager+0xb18>
ffffffffc020380e:	00002617          	auipc	a2,0x2
ffffffffc0203812:	11260613          	addi	a2,a2,274 # ffffffffc0205920 <commands+0x738>
ffffffffc0203816:	06000593          	li	a1,96
ffffffffc020381a:	00003517          	auipc	a0,0x3
ffffffffc020381e:	f1650513          	addi	a0,a0,-234 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203822:	c25fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc0203826:	00003697          	auipc	a3,0x3
ffffffffc020382a:	fc268693          	addi	a3,a3,-62 # ffffffffc02067e8 <default_pmm_manager+0xb18>
ffffffffc020382e:	00002617          	auipc	a2,0x2
ffffffffc0203832:	0f260613          	addi	a2,a2,242 # ffffffffc0205920 <commands+0x738>
ffffffffc0203836:	05d00593          	li	a1,93
ffffffffc020383a:	00003517          	auipc	a0,0x3
ffffffffc020383e:	ef650513          	addi	a0,a0,-266 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203842:	c05fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203846:	00003697          	auipc	a3,0x3
ffffffffc020384a:	d1268693          	addi	a3,a3,-750 # ffffffffc0206558 <default_pmm_manager+0x888>
ffffffffc020384e:	00002617          	auipc	a2,0x2
ffffffffc0203852:	0d260613          	addi	a2,a2,210 # ffffffffc0205920 <commands+0x738>
ffffffffc0203856:	05a00593          	li	a1,90
ffffffffc020385a:	00003517          	auipc	a0,0x3
ffffffffc020385e:	ed650513          	addi	a0,a0,-298 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203862:	be5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203866:	00003697          	auipc	a3,0x3
ffffffffc020386a:	cf268693          	addi	a3,a3,-782 # ffffffffc0206558 <default_pmm_manager+0x888>
ffffffffc020386e:	00002617          	auipc	a2,0x2
ffffffffc0203872:	0b260613          	addi	a2,a2,178 # ffffffffc0205920 <commands+0x738>
ffffffffc0203876:	05700593          	li	a1,87
ffffffffc020387a:	00003517          	auipc	a0,0x3
ffffffffc020387e:	eb650513          	addi	a0,a0,-330 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203882:	bc5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203886:	00003697          	auipc	a3,0x3
ffffffffc020388a:	cd268693          	addi	a3,a3,-814 # ffffffffc0206558 <default_pmm_manager+0x888>
ffffffffc020388e:	00002617          	auipc	a2,0x2
ffffffffc0203892:	09260613          	addi	a2,a2,146 # ffffffffc0205920 <commands+0x738>
ffffffffc0203896:	05400593          	li	a1,84
ffffffffc020389a:	00003517          	auipc	a0,0x3
ffffffffc020389e:	e9650513          	addi	a0,a0,-362 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc02038a2:	ba5fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02038a6 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02038a6:	751c                	ld	a5,40(a0)
{
ffffffffc02038a8:	1141                	addi	sp,sp,-16
ffffffffc02038aa:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02038ac:	cf91                	beqz	a5,ffffffffc02038c8 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02038ae:	ee0d                	bnez	a2,ffffffffc02038e8 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02038b0:	679c                	ld	a5,8(a5)
}
ffffffffc02038b2:	60a2                	ld	ra,8(sp)
ffffffffc02038b4:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02038b6:	6394                	ld	a3,0(a5)
ffffffffc02038b8:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02038ba:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc02038be:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02038c0:	e314                	sd	a3,0(a4)
ffffffffc02038c2:	e19c                	sd	a5,0(a1)
}
ffffffffc02038c4:	0141                	addi	sp,sp,16
ffffffffc02038c6:	8082                	ret
         assert(head != NULL);
ffffffffc02038c8:	00003697          	auipc	a3,0x3
ffffffffc02038cc:	fb868693          	addi	a3,a3,-72 # ffffffffc0206880 <default_pmm_manager+0xbb0>
ffffffffc02038d0:	00002617          	auipc	a2,0x2
ffffffffc02038d4:	05060613          	addi	a2,a2,80 # ffffffffc0205920 <commands+0x738>
ffffffffc02038d8:	04100593          	li	a1,65
ffffffffc02038dc:	00003517          	auipc	a0,0x3
ffffffffc02038e0:	e5450513          	addi	a0,a0,-428 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc02038e4:	b63fc0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(in_tick==0);
ffffffffc02038e8:	00003697          	auipc	a3,0x3
ffffffffc02038ec:	fa868693          	addi	a3,a3,-88 # ffffffffc0206890 <default_pmm_manager+0xbc0>
ffffffffc02038f0:	00002617          	auipc	a2,0x2
ffffffffc02038f4:	03060613          	addi	a2,a2,48 # ffffffffc0205920 <commands+0x738>
ffffffffc02038f8:	04200593          	li	a1,66
ffffffffc02038fc:	00003517          	auipc	a0,0x3
ffffffffc0203900:	e3450513          	addi	a0,a0,-460 # ffffffffc0206730 <default_pmm_manager+0xa60>
ffffffffc0203904:	b43fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203908 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203908:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020390a:	cb91                	beqz	a5,ffffffffc020391e <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020390c:	6394                	ld	a3,0(a5)
ffffffffc020390e:	03060713          	addi	a4,a2,48
    prev->next = next->prev = elm;
ffffffffc0203912:	e398                	sd	a4,0(a5)
ffffffffc0203914:	e698                	sd	a4,8(a3)
}
ffffffffc0203916:	4501                	li	a0,0
    elm->next = next;
ffffffffc0203918:	fe1c                	sd	a5,56(a2)
    elm->prev = prev;
ffffffffc020391a:	fa14                	sd	a3,48(a2)
ffffffffc020391c:	8082                	ret
{
ffffffffc020391e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203920:	00003697          	auipc	a3,0x3
ffffffffc0203924:	f8068693          	addi	a3,a3,-128 # ffffffffc02068a0 <default_pmm_manager+0xbd0>
ffffffffc0203928:	00002617          	auipc	a2,0x2
ffffffffc020392c:	ff860613          	addi	a2,a2,-8 # ffffffffc0205920 <commands+0x738>
ffffffffc0203930:	03200593          	li	a1,50
ffffffffc0203934:	00003517          	auipc	a0,0x3
ffffffffc0203938:	dfc50513          	addi	a0,a0,-516 # ffffffffc0206730 <default_pmm_manager+0xa60>
{
ffffffffc020393c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020393e:	b09fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203942 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203942:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203944:	00003697          	auipc	a3,0x3
ffffffffc0203948:	f9468693          	addi	a3,a3,-108 # ffffffffc02068d8 <default_pmm_manager+0xc08>
ffffffffc020394c:	00002617          	auipc	a2,0x2
ffffffffc0203950:	fd460613          	addi	a2,a2,-44 # ffffffffc0205920 <commands+0x738>
ffffffffc0203954:	07e00593          	li	a1,126
ffffffffc0203958:	00003517          	auipc	a0,0x3
ffffffffc020395c:	fa050513          	addi	a0,a0,-96 # ffffffffc02068f8 <default_pmm_manager+0xc28>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203960:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203962:	ae5fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203966 <mm_create>:
mm_create(void) {
ffffffffc0203966:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203968:	03000513          	li	a0,48
mm_create(void) {
ffffffffc020396c:	e022                	sd	s0,0(sp)
ffffffffc020396e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203970:	f15fd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
ffffffffc0203974:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203976:	c105                	beqz	a0,ffffffffc0203996 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0203978:	e408                	sd	a0,8(s0)
ffffffffc020397a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020397c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203980:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203984:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203988:	00013797          	auipc	a5,0x13
ffffffffc020398c:	c107a783          	lw	a5,-1008(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc0203990:	eb81                	bnez	a5,ffffffffc02039a0 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0203992:	02053423          	sd	zero,40(a0)
}
ffffffffc0203996:	60a2                	ld	ra,8(sp)
ffffffffc0203998:	8522                	mv	a0,s0
ffffffffc020399a:	6402                	ld	s0,0(sp)
ffffffffc020399c:	0141                	addi	sp,sp,16
ffffffffc020399e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039a0:	a0fff0ef          	jal	ra,ffffffffc02033ae <swap_init_mm>
}
ffffffffc02039a4:	60a2                	ld	ra,8(sp)
ffffffffc02039a6:	8522                	mv	a0,s0
ffffffffc02039a8:	6402                	ld	s0,0(sp)
ffffffffc02039aa:	0141                	addi	sp,sp,16
ffffffffc02039ac:	8082                	ret

ffffffffc02039ae <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02039ae:	1101                	addi	sp,sp,-32
ffffffffc02039b0:	e04a                	sd	s2,0(sp)
ffffffffc02039b2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039b4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02039b8:	e822                	sd	s0,16(sp)
ffffffffc02039ba:	e426                	sd	s1,8(sp)
ffffffffc02039bc:	ec06                	sd	ra,24(sp)
ffffffffc02039be:	84ae                	mv	s1,a1
ffffffffc02039c0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039c2:	ec3fd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
    if (vma != NULL) {
ffffffffc02039c6:	c509                	beqz	a0,ffffffffc02039d0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02039c8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039cc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039ce:	cd00                	sw	s0,24(a0)
}
ffffffffc02039d0:	60e2                	ld	ra,24(sp)
ffffffffc02039d2:	6442                	ld	s0,16(sp)
ffffffffc02039d4:	64a2                	ld	s1,8(sp)
ffffffffc02039d6:	6902                	ld	s2,0(sp)
ffffffffc02039d8:	6105                	addi	sp,sp,32
ffffffffc02039da:	8082                	ret

ffffffffc02039dc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02039dc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02039de:	c505                	beqz	a0,ffffffffc0203a06 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02039e0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02039e2:	c501                	beqz	a0,ffffffffc02039ea <find_vma+0xe>
ffffffffc02039e4:	651c                	ld	a5,8(a0)
ffffffffc02039e6:	02f5f263          	bgeu	a1,a5,ffffffffc0203a0a <find_vma+0x2e>
    return listelm->next;
ffffffffc02039ea:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02039ec:	00f68d63          	beq	a3,a5,ffffffffc0203a06 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02039f0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02039f4:	00e5e663          	bltu	a1,a4,ffffffffc0203a00 <find_vma+0x24>
ffffffffc02039f8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02039fc:	00e5ec63          	bltu	a1,a4,ffffffffc0203a14 <find_vma+0x38>
ffffffffc0203a00:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203a02:	fef697e3          	bne	a3,a5,ffffffffc02039f0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203a06:	4501                	li	a0,0
}
ffffffffc0203a08:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203a0a:	691c                	ld	a5,16(a0)
ffffffffc0203a0c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02039ea <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203a10:	ea88                	sd	a0,16(a3)
ffffffffc0203a12:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203a14:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203a18:	ea88                	sd	a0,16(a3)
ffffffffc0203a1a:	8082                	ret

ffffffffc0203a1c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203a1c:	6590                	ld	a2,8(a1)
ffffffffc0203a1e:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203a22:	1141                	addi	sp,sp,-16
ffffffffc0203a24:	e406                	sd	ra,8(sp)
ffffffffc0203a26:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203a28:	01066763          	bltu	a2,a6,ffffffffc0203a36 <insert_vma_struct+0x1a>
ffffffffc0203a2c:	a085                	j	ffffffffc0203a8c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203a2e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203a32:	04e66863          	bltu	a2,a4,ffffffffc0203a82 <insert_vma_struct+0x66>
ffffffffc0203a36:	86be                	mv	a3,a5
ffffffffc0203a38:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203a3a:	fef51ae3          	bne	a0,a5,ffffffffc0203a2e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203a3e:	02a68463          	beq	a3,a0,ffffffffc0203a66 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203a42:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203a46:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203a4a:	08e8f163          	bgeu	a7,a4,ffffffffc0203acc <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203a4e:	04e66f63          	bltu	a2,a4,ffffffffc0203aac <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0203a52:	00f50a63          	beq	a0,a5,ffffffffc0203a66 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203a56:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203a5a:	05076963          	bltu	a4,a6,ffffffffc0203aac <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203a5e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203a62:	02c77363          	bgeu	a4,a2,ffffffffc0203a88 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203a66:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203a68:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203a6a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203a6e:	e390                	sd	a2,0(a5)
ffffffffc0203a70:	e690                	sd	a2,8(a3)
}
ffffffffc0203a72:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203a74:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203a76:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0203a78:	0017079b          	addiw	a5,a4,1
ffffffffc0203a7c:	d11c                	sw	a5,32(a0)
}
ffffffffc0203a7e:	0141                	addi	sp,sp,16
ffffffffc0203a80:	8082                	ret
    if (le_prev != list) {
ffffffffc0203a82:	fca690e3          	bne	a3,a0,ffffffffc0203a42 <insert_vma_struct+0x26>
ffffffffc0203a86:	bfd1                	j	ffffffffc0203a5a <insert_vma_struct+0x3e>
ffffffffc0203a88:	ebbff0ef          	jal	ra,ffffffffc0203942 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203a8c:	00003697          	auipc	a3,0x3
ffffffffc0203a90:	e7c68693          	addi	a3,a3,-388 # ffffffffc0206908 <default_pmm_manager+0xc38>
ffffffffc0203a94:	00002617          	auipc	a2,0x2
ffffffffc0203a98:	e8c60613          	addi	a2,a2,-372 # ffffffffc0205920 <commands+0x738>
ffffffffc0203a9c:	08500593          	li	a1,133
ffffffffc0203aa0:	00003517          	auipc	a0,0x3
ffffffffc0203aa4:	e5850513          	addi	a0,a0,-424 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203aa8:	99ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203aac:	00003697          	auipc	a3,0x3
ffffffffc0203ab0:	e9c68693          	addi	a3,a3,-356 # ffffffffc0206948 <default_pmm_manager+0xc78>
ffffffffc0203ab4:	00002617          	auipc	a2,0x2
ffffffffc0203ab8:	e6c60613          	addi	a2,a2,-404 # ffffffffc0205920 <commands+0x738>
ffffffffc0203abc:	07d00593          	li	a1,125
ffffffffc0203ac0:	00003517          	auipc	a0,0x3
ffffffffc0203ac4:	e3850513          	addi	a0,a0,-456 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203ac8:	97ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203acc:	00003697          	auipc	a3,0x3
ffffffffc0203ad0:	e5c68693          	addi	a3,a3,-420 # ffffffffc0206928 <default_pmm_manager+0xc58>
ffffffffc0203ad4:	00002617          	auipc	a2,0x2
ffffffffc0203ad8:	e4c60613          	addi	a2,a2,-436 # ffffffffc0205920 <commands+0x738>
ffffffffc0203adc:	07c00593          	li	a1,124
ffffffffc0203ae0:	00003517          	auipc	a0,0x3
ffffffffc0203ae4:	e1850513          	addi	a0,a0,-488 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203ae8:	95ffc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203aec <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203aec:	1141                	addi	sp,sp,-16
ffffffffc0203aee:	e022                	sd	s0,0(sp)
ffffffffc0203af0:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203af2:	6508                	ld	a0,8(a0)
ffffffffc0203af4:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203af6:	00a40c63          	beq	s0,a0,ffffffffc0203b0e <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203afa:	6118                	ld	a4,0(a0)
ffffffffc0203afc:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203afe:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203b00:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203b02:	e398                	sd	a4,0(a5)
ffffffffc0203b04:	e31fd0ef          	jal	ra,ffffffffc0201934 <kfree>
    return listelm->next;
ffffffffc0203b08:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203b0a:	fea418e3          	bne	s0,a0,ffffffffc0203afa <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203b0e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203b10:	6402                	ld	s0,0(sp)
ffffffffc0203b12:	60a2                	ld	ra,8(sp)
ffffffffc0203b14:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203b16:	e1ffd06f          	j	ffffffffc0201934 <kfree>

ffffffffc0203b1a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203b1a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b1c:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0203b20:	fc06                	sd	ra,56(sp)
ffffffffc0203b22:	f822                	sd	s0,48(sp)
ffffffffc0203b24:	f426                	sd	s1,40(sp)
ffffffffc0203b26:	f04a                	sd	s2,32(sp)
ffffffffc0203b28:	ec4e                	sd	s3,24(sp)
ffffffffc0203b2a:	e852                	sd	s4,16(sp)
ffffffffc0203b2c:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b2e:	d57fd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
    if (mm != NULL) {
ffffffffc0203b32:	5a050d63          	beqz	a0,ffffffffc02040ec <vmm_init+0x5d2>
    elm->prev = elm->next = elm;
ffffffffc0203b36:	e508                	sd	a0,8(a0)
ffffffffc0203b38:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203b3a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203b3e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203b42:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203b46:	00013797          	auipc	a5,0x13
ffffffffc0203b4a:	a527a783          	lw	a5,-1454(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc0203b4e:	84aa                	mv	s1,a0
ffffffffc0203b50:	e7b9                	bnez	a5,ffffffffc0203b9e <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0203b52:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0203b56:	03200413          	li	s0,50
ffffffffc0203b5a:	a811                	j	ffffffffc0203b6e <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc0203b5c:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203b5e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b60:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0203b64:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203b66:	8526                	mv	a0,s1
ffffffffc0203b68:	eb5ff0ef          	jal	ra,ffffffffc0203a1c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203b6c:	cc05                	beqz	s0,ffffffffc0203ba4 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b6e:	03000513          	li	a0,48
ffffffffc0203b72:	d13fd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
ffffffffc0203b76:	85aa                	mv	a1,a0
ffffffffc0203b78:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203b7c:	f165                	bnez	a0,ffffffffc0203b5c <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc0203b7e:	00003697          	auipc	a3,0x3
ffffffffc0203b82:	89a68693          	addi	a3,a3,-1894 # ffffffffc0206418 <default_pmm_manager+0x748>
ffffffffc0203b86:	00002617          	auipc	a2,0x2
ffffffffc0203b8a:	d9a60613          	addi	a2,a2,-614 # ffffffffc0205920 <commands+0x738>
ffffffffc0203b8e:	0c900593          	li	a1,201
ffffffffc0203b92:	00003517          	auipc	a0,0x3
ffffffffc0203b96:	d6650513          	addi	a0,a0,-666 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203b9a:	8adfc0ef          	jal	ra,ffffffffc0200446 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203b9e:	811ff0ef          	jal	ra,ffffffffc02033ae <swap_init_mm>
ffffffffc0203ba2:	bf55                	j	ffffffffc0203b56 <vmm_init+0x3c>
ffffffffc0203ba4:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203ba8:	1f900913          	li	s2,505
ffffffffc0203bac:	a819                	j	ffffffffc0203bc2 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0203bae:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203bb0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203bb2:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203bb6:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203bb8:	8526                	mv	a0,s1
ffffffffc0203bba:	e63ff0ef          	jal	ra,ffffffffc0203a1c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203bbe:	03240a63          	beq	s0,s2,ffffffffc0203bf2 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203bc2:	03000513          	li	a0,48
ffffffffc0203bc6:	cbffd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
ffffffffc0203bca:	85aa                	mv	a1,a0
ffffffffc0203bcc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203bd0:	fd79                	bnez	a0,ffffffffc0203bae <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0203bd2:	00003697          	auipc	a3,0x3
ffffffffc0203bd6:	84668693          	addi	a3,a3,-1978 # ffffffffc0206418 <default_pmm_manager+0x748>
ffffffffc0203bda:	00002617          	auipc	a2,0x2
ffffffffc0203bde:	d4660613          	addi	a2,a2,-698 # ffffffffc0205920 <commands+0x738>
ffffffffc0203be2:	0cf00593          	li	a1,207
ffffffffc0203be6:	00003517          	auipc	a0,0x3
ffffffffc0203bea:	d1250513          	addi	a0,a0,-750 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203bee:	859fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return listelm->next;
ffffffffc0203bf2:	649c                	ld	a5,8(s1)
ffffffffc0203bf4:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203bf6:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203bfa:	32f48d63          	beq	s1,a5,ffffffffc0203f34 <vmm_init+0x41a>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203bfe:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203c02:	ffe70613          	addi	a2,a4,-2
ffffffffc0203c06:	2cd61763          	bne	a2,a3,ffffffffc0203ed4 <vmm_init+0x3ba>
ffffffffc0203c0a:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203c0e:	2ce69363          	bne	a3,a4,ffffffffc0203ed4 <vmm_init+0x3ba>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203c12:	0715                	addi	a4,a4,5
ffffffffc0203c14:	679c                	ld	a5,8(a5)
ffffffffc0203c16:	feb712e3          	bne	a4,a1,ffffffffc0203bfa <vmm_init+0xe0>
ffffffffc0203c1a:	4a1d                	li	s4,7
ffffffffc0203c1c:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203c1e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203c22:	85a2                	mv	a1,s0
ffffffffc0203c24:	8526                	mv	a0,s1
ffffffffc0203c26:	db7ff0ef          	jal	ra,ffffffffc02039dc <find_vma>
ffffffffc0203c2a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203c2c:	36050463          	beqz	a0,ffffffffc0203f94 <vmm_init+0x47a>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203c30:	00140593          	addi	a1,s0,1
ffffffffc0203c34:	8526                	mv	a0,s1
ffffffffc0203c36:	da7ff0ef          	jal	ra,ffffffffc02039dc <find_vma>
ffffffffc0203c3a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203c3c:	36050c63          	beqz	a0,ffffffffc0203fb4 <vmm_init+0x49a>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203c40:	85d2                	mv	a1,s4
ffffffffc0203c42:	8526                	mv	a0,s1
ffffffffc0203c44:	d99ff0ef          	jal	ra,ffffffffc02039dc <find_vma>
        assert(vma3 == NULL);
ffffffffc0203c48:	38051663          	bnez	a0,ffffffffc0203fd4 <vmm_init+0x4ba>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203c4c:	00340593          	addi	a1,s0,3
ffffffffc0203c50:	8526                	mv	a0,s1
ffffffffc0203c52:	d8bff0ef          	jal	ra,ffffffffc02039dc <find_vma>
        assert(vma4 == NULL);
ffffffffc0203c56:	2e051f63          	bnez	a0,ffffffffc0203f54 <vmm_init+0x43a>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203c5a:	00440593          	addi	a1,s0,4
ffffffffc0203c5e:	8526                	mv	a0,s1
ffffffffc0203c60:	d7dff0ef          	jal	ra,ffffffffc02039dc <find_vma>
        assert(vma5 == NULL);
ffffffffc0203c64:	30051863          	bnez	a0,ffffffffc0203f74 <vmm_init+0x45a>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203c68:	00893783          	ld	a5,8(s2)
ffffffffc0203c6c:	28879463          	bne	a5,s0,ffffffffc0203ef4 <vmm_init+0x3da>
ffffffffc0203c70:	01093783          	ld	a5,16(s2)
ffffffffc0203c74:	29479063          	bne	a5,s4,ffffffffc0203ef4 <vmm_init+0x3da>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203c78:	0089b783          	ld	a5,8(s3)
ffffffffc0203c7c:	28879c63          	bne	a5,s0,ffffffffc0203f14 <vmm_init+0x3fa>
ffffffffc0203c80:	0109b783          	ld	a5,16(s3)
ffffffffc0203c84:	29479863          	bne	a5,s4,ffffffffc0203f14 <vmm_init+0x3fa>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203c88:	0415                	addi	s0,s0,5
ffffffffc0203c8a:	0a15                	addi	s4,s4,5
ffffffffc0203c8c:	f9541be3          	bne	s0,s5,ffffffffc0203c22 <vmm_init+0x108>
ffffffffc0203c90:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203c92:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203c94:	85a2                	mv	a1,s0
ffffffffc0203c96:	8526                	mv	a0,s1
ffffffffc0203c98:	d45ff0ef          	jal	ra,ffffffffc02039dc <find_vma>
ffffffffc0203c9c:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203ca0:	c90d                	beqz	a0,ffffffffc0203cd2 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203ca2:	6914                	ld	a3,16(a0)
ffffffffc0203ca4:	6510                	ld	a2,8(a0)
ffffffffc0203ca6:	00003517          	auipc	a0,0x3
ffffffffc0203caa:	dc250513          	addi	a0,a0,-574 # ffffffffc0206a68 <default_pmm_manager+0xd98>
ffffffffc0203cae:	cd2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203cb2:	00003697          	auipc	a3,0x3
ffffffffc0203cb6:	dde68693          	addi	a3,a3,-546 # ffffffffc0206a90 <default_pmm_manager+0xdc0>
ffffffffc0203cba:	00002617          	auipc	a2,0x2
ffffffffc0203cbe:	c6660613          	addi	a2,a2,-922 # ffffffffc0205920 <commands+0x738>
ffffffffc0203cc2:	0f100593          	li	a1,241
ffffffffc0203cc6:	00003517          	auipc	a0,0x3
ffffffffc0203cca:	c3250513          	addi	a0,a0,-974 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203cce:	f78fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203cd2:	147d                	addi	s0,s0,-1
ffffffffc0203cd4:	fd2410e3          	bne	s0,s2,ffffffffc0203c94 <vmm_init+0x17a>
ffffffffc0203cd8:	a801                	j	ffffffffc0203ce8 <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203cda:	6118                	ld	a4,0(a0)
ffffffffc0203cdc:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203cde:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203ce0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203ce2:	e398                	sd	a4,0(a5)
ffffffffc0203ce4:	c51fd0ef          	jal	ra,ffffffffc0201934 <kfree>
    return listelm->next;
ffffffffc0203ce8:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203cea:	fea498e3          	bne	s1,a0,ffffffffc0203cda <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0203cee:	8526                	mv	a0,s1
ffffffffc0203cf0:	c45fd0ef          	jal	ra,ffffffffc0201934 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203cf4:	00003517          	auipc	a0,0x3
ffffffffc0203cf8:	db450513          	addi	a0,a0,-588 # ffffffffc0206aa8 <default_pmm_manager+0xdd8>
ffffffffc0203cfc:	c84fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203d00:	e3bfd0ef          	jal	ra,ffffffffc0201b3a <nr_free_pages>
ffffffffc0203d04:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203d06:	03000513          	li	a0,48
ffffffffc0203d0a:	b7bfd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
ffffffffc0203d0e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203d10:	2e050263          	beqz	a0,ffffffffc0203ff4 <vmm_init+0x4da>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203d14:	00013797          	auipc	a5,0x13
ffffffffc0203d18:	8847a783          	lw	a5,-1916(a5) # ffffffffc0216598 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203d1c:	e508                	sd	a0,8(a0)
ffffffffc0203d1e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203d20:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203d24:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203d28:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203d2c:	1a079163          	bnez	a5,ffffffffc0203ece <vmm_init+0x3b4>
        else mm->sm_priv = NULL;
ffffffffc0203d30:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203d34:	00013917          	auipc	s2,0x13
ffffffffc0203d38:	82c93903          	ld	s2,-2004(s2) # ffffffffc0216560 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203d3c:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203d40:	00013717          	auipc	a4,0x13
ffffffffc0203d44:	86873023          	sd	s0,-1952(a4) # ffffffffc02165a0 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203d48:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203d4c:	38079063          	bnez	a5,ffffffffc02040cc <vmm_init+0x5b2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203d50:	03000513          	li	a0,48
ffffffffc0203d54:	b31fd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
ffffffffc0203d58:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0203d5a:	2c050163          	beqz	a0,ffffffffc020401c <vmm_init+0x502>
        vma->vm_end = vm_end;
ffffffffc0203d5e:	002007b7          	lui	a5,0x200
ffffffffc0203d62:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0203d66:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203d68:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203d6a:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203d6e:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203d70:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203d74:	ca9ff0ef          	jal	ra,ffffffffc0203a1c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203d78:	10000593          	li	a1,256
ffffffffc0203d7c:	8522                	mv	a0,s0
ffffffffc0203d7e:	c5fff0ef          	jal	ra,ffffffffc02039dc <find_vma>
ffffffffc0203d82:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203d86:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203d8a:	2aa99963          	bne	s3,a0,ffffffffc020403c <vmm_init+0x522>
        *(char *)(addr + i) = i;
ffffffffc0203d8e:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203d92:	0785                	addi	a5,a5,1
ffffffffc0203d94:	fee79de3          	bne	a5,a4,ffffffffc0203d8e <vmm_init+0x274>
        sum += i;
ffffffffc0203d98:	6705                	lui	a4,0x1
ffffffffc0203d9a:	10000793          	li	a5,256
ffffffffc0203d9e:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203da2:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203da6:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203daa:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203dac:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203dae:	fec79ce3          	bne	a5,a2,ffffffffc0203da6 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0203db2:	2a071563          	bnez	a4,ffffffffc020405c <vmm_init+0x542>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203db6:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203dba:	00012a97          	auipc	s5,0x12
ffffffffc0203dbe:	7aea8a93          	addi	s5,s5,1966 # ffffffffc0216568 <npage>
ffffffffc0203dc2:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203dc6:	078a                	slli	a5,a5,0x2
ffffffffc0203dc8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203dca:	2ac7f963          	bgeu	a5,a2,ffffffffc020407c <vmm_init+0x562>
    return &pages[PPN(pa) - nbase];
ffffffffc0203dce:	00003a17          	auipc	s4,0x3
ffffffffc0203dd2:	242a3a03          	ld	s4,578(s4) # ffffffffc0207010 <nbase>
ffffffffc0203dd6:	41478733          	sub	a4,a5,s4
ffffffffc0203dda:	00371793          	slli	a5,a4,0x3
ffffffffc0203dde:	97ba                	add	a5,a5,a4
ffffffffc0203de0:	078e                	slli	a5,a5,0x3
    return page - pages + nbase;
ffffffffc0203de2:	00003717          	auipc	a4,0x3
ffffffffc0203de6:	22673703          	ld	a4,550(a4) # ffffffffc0207008 <error_string+0x38>
ffffffffc0203dea:	878d                	srai	a5,a5,0x3
ffffffffc0203dec:	02e787b3          	mul	a5,a5,a4
ffffffffc0203df0:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0203df2:	00c79713          	slli	a4,a5,0xc
ffffffffc0203df6:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203df8:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203dfc:	28c77c63          	bgeu	a4,a2,ffffffffc0204094 <vmm_init+0x57a>
ffffffffc0203e00:	00012997          	auipc	s3,0x12
ffffffffc0203e04:	7809b983          	ld	s3,1920(s3) # ffffffffc0216580 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203e08:	4581                	li	a1,0
ffffffffc0203e0a:	854a                	mv	a0,s2
ffffffffc0203e0c:	99b6                	add	s3,s3,a3
ffffffffc0203e0e:	fb7fd0ef          	jal	ra,ffffffffc0201dc4 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203e12:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0203e16:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203e1a:	078a                	slli	a5,a5,0x2
ffffffffc0203e1c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203e1e:	24e7ff63          	bgeu	a5,a4,ffffffffc020407c <vmm_init+0x562>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e22:	414787b3          	sub	a5,a5,s4
ffffffffc0203e26:	00012997          	auipc	s3,0x12
ffffffffc0203e2a:	74a98993          	addi	s3,s3,1866 # ffffffffc0216570 <pages>
ffffffffc0203e2e:	00379713          	slli	a4,a5,0x3
ffffffffc0203e32:	0009b503          	ld	a0,0(s3)
ffffffffc0203e36:	97ba                	add	a5,a5,a4
ffffffffc0203e38:	078e                	slli	a5,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc0203e3a:	953e                	add	a0,a0,a5
ffffffffc0203e3c:	4585                	li	a1,1
ffffffffc0203e3e:	cbdfd0ef          	jal	ra,ffffffffc0201afa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203e42:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203e46:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203e4a:	078a                	slli	a5,a5,0x2
ffffffffc0203e4c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203e4e:	22e7f763          	bgeu	a5,a4,ffffffffc020407c <vmm_init+0x562>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e52:	414787b3          	sub	a5,a5,s4
ffffffffc0203e56:	0009b503          	ld	a0,0(s3)
ffffffffc0203e5a:	00379713          	slli	a4,a5,0x3
ffffffffc0203e5e:	97ba                	add	a5,a5,a4
ffffffffc0203e60:	078e                	slli	a5,a5,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0203e62:	4585                	li	a1,1
ffffffffc0203e64:	953e                	add	a0,a0,a5
ffffffffc0203e66:	c95fd0ef          	jal	ra,ffffffffc0201afa <free_pages>
    pgdir[0] = 0;
ffffffffc0203e6a:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203e6e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203e72:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203e74:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203e78:	00a40c63          	beq	s0,a0,ffffffffc0203e90 <vmm_init+0x376>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203e7c:	6118                	ld	a4,0(a0)
ffffffffc0203e7e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203e80:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203e82:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203e84:	e398                	sd	a4,0(a5)
ffffffffc0203e86:	aaffd0ef          	jal	ra,ffffffffc0201934 <kfree>
    return listelm->next;
ffffffffc0203e8a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203e8c:	fea418e3          	bne	s0,a0,ffffffffc0203e7c <vmm_init+0x362>
    kfree(mm); //kfree mm
ffffffffc0203e90:	8522                	mv	a0,s0
ffffffffc0203e92:	aa3fd0ef          	jal	ra,ffffffffc0201934 <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc0203e96:	00012797          	auipc	a5,0x12
ffffffffc0203e9a:	7007b523          	sd	zero,1802(a5) # ffffffffc02165a0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203e9e:	c9dfd0ef          	jal	ra,ffffffffc0201b3a <nr_free_pages>
ffffffffc0203ea2:	20a49563          	bne	s1,a0,ffffffffc02040ac <vmm_init+0x592>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203ea6:	00003517          	auipc	a0,0x3
ffffffffc0203eaa:	c7a50513          	addi	a0,a0,-902 # ffffffffc0206b20 <default_pmm_manager+0xe50>
ffffffffc0203eae:	ad2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203eb2:	7442                	ld	s0,48(sp)
ffffffffc0203eb4:	70e2                	ld	ra,56(sp)
ffffffffc0203eb6:	74a2                	ld	s1,40(sp)
ffffffffc0203eb8:	7902                	ld	s2,32(sp)
ffffffffc0203eba:	69e2                	ld	s3,24(sp)
ffffffffc0203ebc:	6a42                	ld	s4,16(sp)
ffffffffc0203ebe:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203ec0:	00003517          	auipc	a0,0x3
ffffffffc0203ec4:	c8050513          	addi	a0,a0,-896 # ffffffffc0206b40 <default_pmm_manager+0xe70>
}
ffffffffc0203ec8:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203eca:	ab6fc06f          	j	ffffffffc0200180 <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203ece:	ce0ff0ef          	jal	ra,ffffffffc02033ae <swap_init_mm>
ffffffffc0203ed2:	b58d                	j	ffffffffc0203d34 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203ed4:	00003697          	auipc	a3,0x3
ffffffffc0203ed8:	aac68693          	addi	a3,a3,-1364 # ffffffffc0206980 <default_pmm_manager+0xcb0>
ffffffffc0203edc:	00002617          	auipc	a2,0x2
ffffffffc0203ee0:	a4460613          	addi	a2,a2,-1468 # ffffffffc0205920 <commands+0x738>
ffffffffc0203ee4:	0d800593          	li	a1,216
ffffffffc0203ee8:	00003517          	auipc	a0,0x3
ffffffffc0203eec:	a1050513          	addi	a0,a0,-1520 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203ef0:	d56fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203ef4:	00003697          	auipc	a3,0x3
ffffffffc0203ef8:	b1468693          	addi	a3,a3,-1260 # ffffffffc0206a08 <default_pmm_manager+0xd38>
ffffffffc0203efc:	00002617          	auipc	a2,0x2
ffffffffc0203f00:	a2460613          	addi	a2,a2,-1500 # ffffffffc0205920 <commands+0x738>
ffffffffc0203f04:	0e800593          	li	a1,232
ffffffffc0203f08:	00003517          	auipc	a0,0x3
ffffffffc0203f0c:	9f050513          	addi	a0,a0,-1552 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203f10:	d36fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203f14:	00003697          	auipc	a3,0x3
ffffffffc0203f18:	b2468693          	addi	a3,a3,-1244 # ffffffffc0206a38 <default_pmm_manager+0xd68>
ffffffffc0203f1c:	00002617          	auipc	a2,0x2
ffffffffc0203f20:	a0460613          	addi	a2,a2,-1532 # ffffffffc0205920 <commands+0x738>
ffffffffc0203f24:	0e900593          	li	a1,233
ffffffffc0203f28:	00003517          	auipc	a0,0x3
ffffffffc0203f2c:	9d050513          	addi	a0,a0,-1584 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203f30:	d16fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203f34:	00003697          	auipc	a3,0x3
ffffffffc0203f38:	a3468693          	addi	a3,a3,-1484 # ffffffffc0206968 <default_pmm_manager+0xc98>
ffffffffc0203f3c:	00002617          	auipc	a2,0x2
ffffffffc0203f40:	9e460613          	addi	a2,a2,-1564 # ffffffffc0205920 <commands+0x738>
ffffffffc0203f44:	0d600593          	li	a1,214
ffffffffc0203f48:	00003517          	auipc	a0,0x3
ffffffffc0203f4c:	9b050513          	addi	a0,a0,-1616 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203f50:	cf6fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc0203f54:	00003697          	auipc	a3,0x3
ffffffffc0203f58:	a9468693          	addi	a3,a3,-1388 # ffffffffc02069e8 <default_pmm_manager+0xd18>
ffffffffc0203f5c:	00002617          	auipc	a2,0x2
ffffffffc0203f60:	9c460613          	addi	a2,a2,-1596 # ffffffffc0205920 <commands+0x738>
ffffffffc0203f64:	0e400593          	li	a1,228
ffffffffc0203f68:	00003517          	auipc	a0,0x3
ffffffffc0203f6c:	99050513          	addi	a0,a0,-1648 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203f70:	cd6fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc0203f74:	00003697          	auipc	a3,0x3
ffffffffc0203f78:	a8468693          	addi	a3,a3,-1404 # ffffffffc02069f8 <default_pmm_manager+0xd28>
ffffffffc0203f7c:	00002617          	auipc	a2,0x2
ffffffffc0203f80:	9a460613          	addi	a2,a2,-1628 # ffffffffc0205920 <commands+0x738>
ffffffffc0203f84:	0e600593          	li	a1,230
ffffffffc0203f88:	00003517          	auipc	a0,0x3
ffffffffc0203f8c:	97050513          	addi	a0,a0,-1680 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203f90:	cb6fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc0203f94:	00003697          	auipc	a3,0x3
ffffffffc0203f98:	a2468693          	addi	a3,a3,-1500 # ffffffffc02069b8 <default_pmm_manager+0xce8>
ffffffffc0203f9c:	00002617          	auipc	a2,0x2
ffffffffc0203fa0:	98460613          	addi	a2,a2,-1660 # ffffffffc0205920 <commands+0x738>
ffffffffc0203fa4:	0de00593          	li	a1,222
ffffffffc0203fa8:	00003517          	auipc	a0,0x3
ffffffffc0203fac:	95050513          	addi	a0,a0,-1712 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203fb0:	c96fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc0203fb4:	00003697          	auipc	a3,0x3
ffffffffc0203fb8:	a1468693          	addi	a3,a3,-1516 # ffffffffc02069c8 <default_pmm_manager+0xcf8>
ffffffffc0203fbc:	00002617          	auipc	a2,0x2
ffffffffc0203fc0:	96460613          	addi	a2,a2,-1692 # ffffffffc0205920 <commands+0x738>
ffffffffc0203fc4:	0e000593          	li	a1,224
ffffffffc0203fc8:	00003517          	auipc	a0,0x3
ffffffffc0203fcc:	93050513          	addi	a0,a0,-1744 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203fd0:	c76fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc0203fd4:	00003697          	auipc	a3,0x3
ffffffffc0203fd8:	a0468693          	addi	a3,a3,-1532 # ffffffffc02069d8 <default_pmm_manager+0xd08>
ffffffffc0203fdc:	00002617          	auipc	a2,0x2
ffffffffc0203fe0:	94460613          	addi	a2,a2,-1724 # ffffffffc0205920 <commands+0x738>
ffffffffc0203fe4:	0e200593          	li	a1,226
ffffffffc0203fe8:	00003517          	auipc	a0,0x3
ffffffffc0203fec:	91050513          	addi	a0,a0,-1776 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0203ff0:	c56fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203ff4:	00003697          	auipc	a3,0x3
ffffffffc0203ff8:	b6468693          	addi	a3,a3,-1180 # ffffffffc0206b58 <default_pmm_manager+0xe88>
ffffffffc0203ffc:	00002617          	auipc	a2,0x2
ffffffffc0204000:	92460613          	addi	a2,a2,-1756 # ffffffffc0205920 <commands+0x738>
ffffffffc0204004:	10100593          	li	a1,257
ffffffffc0204008:	00003517          	auipc	a0,0x3
ffffffffc020400c:	8f050513          	addi	a0,a0,-1808 # ffffffffc02068f8 <default_pmm_manager+0xc28>
    check_mm_struct = mm_create();
ffffffffc0204010:	00012797          	auipc	a5,0x12
ffffffffc0204014:	5807b823          	sd	zero,1424(a5) # ffffffffc02165a0 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0204018:	c2efc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(vma != NULL);
ffffffffc020401c:	00002697          	auipc	a3,0x2
ffffffffc0204020:	3fc68693          	addi	a3,a3,1020 # ffffffffc0206418 <default_pmm_manager+0x748>
ffffffffc0204024:	00002617          	auipc	a2,0x2
ffffffffc0204028:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0205920 <commands+0x738>
ffffffffc020402c:	10800593          	li	a1,264
ffffffffc0204030:	00003517          	auipc	a0,0x3
ffffffffc0204034:	8c850513          	addi	a0,a0,-1848 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0204038:	c0efc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020403c:	00003697          	auipc	a3,0x3
ffffffffc0204040:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0206ac8 <default_pmm_manager+0xdf8>
ffffffffc0204044:	00002617          	auipc	a2,0x2
ffffffffc0204048:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0205920 <commands+0x738>
ffffffffc020404c:	10d00593          	li	a1,269
ffffffffc0204050:	00003517          	auipc	a0,0x3
ffffffffc0204054:	8a850513          	addi	a0,a0,-1880 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0204058:	beefc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(sum == 0);
ffffffffc020405c:	00003697          	auipc	a3,0x3
ffffffffc0204060:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0206ae8 <default_pmm_manager+0xe18>
ffffffffc0204064:	00002617          	auipc	a2,0x2
ffffffffc0204068:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0205920 <commands+0x738>
ffffffffc020406c:	11700593          	li	a1,279
ffffffffc0204070:	00003517          	auipc	a0,0x3
ffffffffc0204074:	88850513          	addi	a0,a0,-1912 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0204078:	bcefc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020407c:	00002617          	auipc	a2,0x2
ffffffffc0204080:	d5c60613          	addi	a2,a2,-676 # ffffffffc0205dd8 <default_pmm_manager+0x108>
ffffffffc0204084:	06200593          	li	a1,98
ffffffffc0204088:	00002517          	auipc	a0,0x2
ffffffffc020408c:	ca850513          	addi	a0,a0,-856 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc0204090:	bb6fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204094:	00002617          	auipc	a2,0x2
ffffffffc0204098:	c7460613          	addi	a2,a2,-908 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc020409c:	06900593          	li	a1,105
ffffffffc02040a0:	00002517          	auipc	a0,0x2
ffffffffc02040a4:	c9050513          	addi	a0,a0,-880 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc02040a8:	b9efc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02040ac:	00003697          	auipc	a3,0x3
ffffffffc02040b0:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0206af8 <default_pmm_manager+0xe28>
ffffffffc02040b4:	00002617          	auipc	a2,0x2
ffffffffc02040b8:	86c60613          	addi	a2,a2,-1940 # ffffffffc0205920 <commands+0x738>
ffffffffc02040bc:	12400593          	li	a1,292
ffffffffc02040c0:	00003517          	auipc	a0,0x3
ffffffffc02040c4:	83850513          	addi	a0,a0,-1992 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc02040c8:	b7efc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02040cc:	00002697          	auipc	a3,0x2
ffffffffc02040d0:	33c68693          	addi	a3,a3,828 # ffffffffc0206408 <default_pmm_manager+0x738>
ffffffffc02040d4:	00002617          	auipc	a2,0x2
ffffffffc02040d8:	84c60613          	addi	a2,a2,-1972 # ffffffffc0205920 <commands+0x738>
ffffffffc02040dc:	10500593          	li	a1,261
ffffffffc02040e0:	00003517          	auipc	a0,0x3
ffffffffc02040e4:	81850513          	addi	a0,a0,-2024 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc02040e8:	b5efc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc02040ec:	00002697          	auipc	a3,0x2
ffffffffc02040f0:	2f468693          	addi	a3,a3,756 # ffffffffc02063e0 <default_pmm_manager+0x710>
ffffffffc02040f4:	00002617          	auipc	a2,0x2
ffffffffc02040f8:	82c60613          	addi	a2,a2,-2004 # ffffffffc0205920 <commands+0x738>
ffffffffc02040fc:	0c200593          	li	a1,194
ffffffffc0204100:	00002517          	auipc	a0,0x2
ffffffffc0204104:	7f850513          	addi	a0,a0,2040 # ffffffffc02068f8 <default_pmm_manager+0xc28>
ffffffffc0204108:	b3efc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020410c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020410c:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020410e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0204110:	f022                	sd	s0,32(sp)
ffffffffc0204112:	ec26                	sd	s1,24(sp)
ffffffffc0204114:	f406                	sd	ra,40(sp)
ffffffffc0204116:	e84a                	sd	s2,16(sp)
ffffffffc0204118:	8432                	mv	s0,a2
ffffffffc020411a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020411c:	8c1ff0ef          	jal	ra,ffffffffc02039dc <find_vma>

    pgfault_num++;
ffffffffc0204120:	00012797          	auipc	a5,0x12
ffffffffc0204124:	4887a783          	lw	a5,1160(a5) # ffffffffc02165a8 <pgfault_num>
ffffffffc0204128:	2785                	addiw	a5,a5,1
ffffffffc020412a:	00012717          	auipc	a4,0x12
ffffffffc020412e:	46f72f23          	sw	a5,1150(a4) # ffffffffc02165a8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204132:	c541                	beqz	a0,ffffffffc02041ba <do_pgfault+0xae>
ffffffffc0204134:	651c                	ld	a5,8(a0)
ffffffffc0204136:	08f46263          	bltu	s0,a5,ffffffffc02041ba <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020413a:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020413c:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020413e:	8b89                	andi	a5,a5,2
ffffffffc0204140:	ebb9                	bnez	a5,ffffffffc0204196 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204142:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204144:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204146:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204148:	4605                	li	a2,1
ffffffffc020414a:	85a2                	mv	a1,s0
ffffffffc020414c:	a29fd0ef          	jal	ra,ffffffffc0201b74 <get_pte>
ffffffffc0204150:	c551                	beqz	a0,ffffffffc02041dc <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204152:	610c                	ld	a1,0(a0)
ffffffffc0204154:	c1b9                	beqz	a1,ffffffffc020419a <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204156:	00012797          	auipc	a5,0x12
ffffffffc020415a:	4427a783          	lw	a5,1090(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc020415e:	c7bd                	beqz	a5,ffffffffc02041cc <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0204160:	85a2                	mv	a1,s0
ffffffffc0204162:	0030                	addi	a2,sp,8
ffffffffc0204164:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204166:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0204168:	b72ff0ef          	jal	ra,ffffffffc02034da <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020416c:	65a2                	ld	a1,8(sp)
ffffffffc020416e:	6c88                	ld	a0,24(s1)
ffffffffc0204170:	86ca                	mv	a3,s2
ffffffffc0204172:	8622                	mv	a2,s0
ffffffffc0204174:	cf3fd0ef          	jal	ra,ffffffffc0201e66 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204178:	6622                	ld	a2,8(sp)
ffffffffc020417a:	4685                	li	a3,1
ffffffffc020417c:	85a2                	mv	a1,s0
ffffffffc020417e:	8526                	mv	a0,s1
ffffffffc0204180:	a3aff0ef          	jal	ra,ffffffffc02033ba <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204184:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0204186:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0204188:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc020418a:	70a2                	ld	ra,40(sp)
ffffffffc020418c:	7402                	ld	s0,32(sp)
ffffffffc020418e:	64e2                	ld	s1,24(sp)
ffffffffc0204190:	6942                	ld	s2,16(sp)
ffffffffc0204192:	6145                	addi	sp,sp,48
ffffffffc0204194:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204196:	495d                	li	s2,23
ffffffffc0204198:	b76d                	j	ffffffffc0204142 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020419a:	6c88                	ld	a0,24(s1)
ffffffffc020419c:	864a                	mv	a2,s2
ffffffffc020419e:	85a2                	mv	a1,s0
ffffffffc02041a0:	9dbfe0ef          	jal	ra,ffffffffc0202b7a <pgdir_alloc_page>
ffffffffc02041a4:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02041a6:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02041a8:	f3ed                	bnez	a5,ffffffffc020418a <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02041aa:	00003517          	auipc	a0,0x3
ffffffffc02041ae:	a1650513          	addi	a0,a0,-1514 # ffffffffc0206bc0 <default_pmm_manager+0xef0>
ffffffffc02041b2:	fcffb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02041b6:	5571                	li	a0,-4
            goto failed;
ffffffffc02041b8:	bfc9                	j	ffffffffc020418a <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02041ba:	85a2                	mv	a1,s0
ffffffffc02041bc:	00003517          	auipc	a0,0x3
ffffffffc02041c0:	9b450513          	addi	a0,a0,-1612 # ffffffffc0206b70 <default_pmm_manager+0xea0>
ffffffffc02041c4:	fbdfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc02041c8:	5575                	li	a0,-3
        goto failed;
ffffffffc02041ca:	b7c1                	j	ffffffffc020418a <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02041cc:	00003517          	auipc	a0,0x3
ffffffffc02041d0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206be8 <default_pmm_manager+0xf18>
ffffffffc02041d4:	fadfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02041d8:	5571                	li	a0,-4
            goto failed;
ffffffffc02041da:	bf45                	j	ffffffffc020418a <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02041dc:	00003517          	auipc	a0,0x3
ffffffffc02041e0:	9c450513          	addi	a0,a0,-1596 # ffffffffc0206ba0 <default_pmm_manager+0xed0>
ffffffffc02041e4:	f9dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02041e8:	5571                	li	a0,-4
        goto failed;
ffffffffc02041ea:	b745                	j	ffffffffc020418a <do_pgfault+0x7e>

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
ffffffffc02041f2:	b76fc0ef          	jal	ra,ffffffffc0200568 <ide_device_valid>
ffffffffc02041f6:	cd01                	beqz	a0,ffffffffc020420e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02041f8:	4505                	li	a0,1
ffffffffc02041fa:	b74fc0ef          	jal	ra,ffffffffc020056e <ide_device_size>
}
ffffffffc02041fe:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204200:	810d                	srli	a0,a0,0x3
ffffffffc0204202:	00012797          	auipc	a5,0x12
ffffffffc0204206:	38a7b323          	sd	a0,902(a5) # ffffffffc0216588 <max_swap_offset>
}
ffffffffc020420a:	0141                	addi	sp,sp,16
ffffffffc020420c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020420e:	00003617          	auipc	a2,0x3
ffffffffc0204212:	a0260613          	addi	a2,a2,-1534 # ffffffffc0206c10 <default_pmm_manager+0xf40>
ffffffffc0204216:	45b5                	li	a1,13
ffffffffc0204218:	00003517          	auipc	a0,0x3
ffffffffc020421c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0206c30 <default_pmm_manager+0xf60>
ffffffffc0204220:	a26fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204224 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204224:	1141                	addi	sp,sp,-16
ffffffffc0204226:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204228:	00855793          	srli	a5,a0,0x8
ffffffffc020422c:	c3a5                	beqz	a5,ffffffffc020428c <swapfs_read+0x68>
ffffffffc020422e:	00012717          	auipc	a4,0x12
ffffffffc0204232:	35a73703          	ld	a4,858(a4) # ffffffffc0216588 <max_swap_offset>
ffffffffc0204236:	04e7fb63          	bgeu	a5,a4,ffffffffc020428c <swapfs_read+0x68>
    return page - pages + nbase;
ffffffffc020423a:	00012617          	auipc	a2,0x12
ffffffffc020423e:	33663603          	ld	a2,822(a2) # ffffffffc0216570 <pages>
ffffffffc0204242:	8d91                	sub	a1,a1,a2
ffffffffc0204244:	4035d613          	srai	a2,a1,0x3
ffffffffc0204248:	00003597          	auipc	a1,0x3
ffffffffc020424c:	dc05b583          	ld	a1,-576(a1) # ffffffffc0207008 <error_string+0x38>
ffffffffc0204250:	02b60633          	mul	a2,a2,a1
ffffffffc0204254:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204258:	00003797          	auipc	a5,0x3
ffffffffc020425c:	db87b783          	ld	a5,-584(a5) # ffffffffc0207010 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204260:	00012717          	auipc	a4,0x12
ffffffffc0204264:	30873703          	ld	a4,776(a4) # ffffffffc0216568 <npage>
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
ffffffffc0204278:	00012797          	auipc	a5,0x12
ffffffffc020427c:	3087b783          	ld	a5,776(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc0204280:	46a1                	li	a3,8
ffffffffc0204282:	963e                	add	a2,a2,a5
ffffffffc0204284:	4505                	li	a0,1
}
ffffffffc0204286:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204288:	aecfc06f          	j	ffffffffc0200574 <ide_read_secs>
ffffffffc020428c:	86aa                	mv	a3,a0
ffffffffc020428e:	00003617          	auipc	a2,0x3
ffffffffc0204292:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0206c48 <default_pmm_manager+0xf78>
ffffffffc0204296:	45d1                	li	a1,20
ffffffffc0204298:	00003517          	auipc	a0,0x3
ffffffffc020429c:	99850513          	addi	a0,a0,-1640 # ffffffffc0206c30 <default_pmm_manager+0xf60>
ffffffffc02042a0:	9a6fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02042a4:	86b2                	mv	a3,a2
ffffffffc02042a6:	06900593          	li	a1,105
ffffffffc02042aa:	00002617          	auipc	a2,0x2
ffffffffc02042ae:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc02042b2:	00002517          	auipc	a0,0x2
ffffffffc02042b6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc02042ba:	98cfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02042be <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02042be:	1141                	addi	sp,sp,-16
ffffffffc02042c0:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02042c2:	00855793          	srli	a5,a0,0x8
ffffffffc02042c6:	c3a5                	beqz	a5,ffffffffc0204326 <swapfs_write+0x68>
ffffffffc02042c8:	00012717          	auipc	a4,0x12
ffffffffc02042cc:	2c073703          	ld	a4,704(a4) # ffffffffc0216588 <max_swap_offset>
ffffffffc02042d0:	04e7fb63          	bgeu	a5,a4,ffffffffc0204326 <swapfs_write+0x68>
    return page - pages + nbase;
ffffffffc02042d4:	00012617          	auipc	a2,0x12
ffffffffc02042d8:	29c63603          	ld	a2,668(a2) # ffffffffc0216570 <pages>
ffffffffc02042dc:	8d91                	sub	a1,a1,a2
ffffffffc02042de:	4035d613          	srai	a2,a1,0x3
ffffffffc02042e2:	00003597          	auipc	a1,0x3
ffffffffc02042e6:	d265b583          	ld	a1,-730(a1) # ffffffffc0207008 <error_string+0x38>
ffffffffc02042ea:	02b60633          	mul	a2,a2,a1
ffffffffc02042ee:	0037959b          	slliw	a1,a5,0x3
ffffffffc02042f2:	00003797          	auipc	a5,0x3
ffffffffc02042f6:	d1e7b783          	ld	a5,-738(a5) # ffffffffc0207010 <nbase>
    return KADDR(page2pa(page));
ffffffffc02042fa:	00012717          	auipc	a4,0x12
ffffffffc02042fe:	26e73703          	ld	a4,622(a4) # ffffffffc0216568 <npage>
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
ffffffffc0204312:	00012797          	auipc	a5,0x12
ffffffffc0204316:	26e7b783          	ld	a5,622(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc020431a:	46a1                	li	a3,8
ffffffffc020431c:	963e                	add	a2,a2,a5
ffffffffc020431e:	4505                	li	a0,1
}
ffffffffc0204320:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204322:	a76fc06f          	j	ffffffffc0200598 <ide_write_secs>
ffffffffc0204326:	86aa                	mv	a3,a0
ffffffffc0204328:	00003617          	auipc	a2,0x3
ffffffffc020432c:	92060613          	addi	a2,a2,-1760 # ffffffffc0206c48 <default_pmm_manager+0xf78>
ffffffffc0204330:	45e5                	li	a1,25
ffffffffc0204332:	00003517          	auipc	a0,0x3
ffffffffc0204336:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0206c30 <default_pmm_manager+0xf60>
ffffffffc020433a:	90cfc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020433e:	86b2                	mv	a3,a2
ffffffffc0204340:	06900593          	li	a1,105
ffffffffc0204344:	00002617          	auipc	a2,0x2
ffffffffc0204348:	9c460613          	addi	a2,a2,-1596 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc020434c:	00002517          	auipc	a0,0x2
ffffffffc0204350:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc0204354:	8f2fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204358 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204358:	8526                	mv	a0,s1
	jalr s0
ffffffffc020435a:	9402                	jalr	s0

	jal do_exit
ffffffffc020435c:	3d2000ef          	jal	ra,ffffffffc020472e <do_exit>

ffffffffc0204360 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204360:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204362:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0204366:	e022                	sd	s0,0(sp)
ffffffffc0204368:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020436a:	d1afd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
ffffffffc020436e:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204370:	c521                	beqz	a0,ffffffffc02043b8 <alloc_proc+0x58>
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    // 初始化进程的状态为 PROC_UNINIT，表示该进程尚未初始化完成
    proc->state = PROC_UNINIT;
ffffffffc0204372:	57fd                	li	a5,-1
ffffffffc0204374:	1782                	slli	a5,a5,0x20
ffffffffc0204376:	e11c                	sd	a5,0(a0)
    // 初始化进程的父进程为 NULL，表示没有父进程（通常是 init 进程）
    proc->parent = NULL;
    // 进程的内存管理结构体 (mm_struct) 初始化为 NULL，表示没有内存管理信息
    proc->mm = NULL;
    // 将进程的上下文 (context) 清零，为了保证没有遗留的状态
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204378:	07000613          	li	a2,112
ffffffffc020437c:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc020437e:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204382:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204386:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL;
ffffffffc020438a:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc020438e:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204392:	03050513          	addi	a0,a0,48
ffffffffc0204396:	39d000ef          	jal	ra,ffffffffc0204f32 <memset>
    // 初始化进程的陷阱帧 (trapframe) 为 NULL，表示该进程还没有陷入中断或系统调用
    proc->tf = NULL;
    // 设置进程的 CR3 寄存器为 boot_cr3，通常是系统启动时的页目录表基地址
    proc->cr3 = boot_cr3;
ffffffffc020439a:	00012797          	auipc	a5,0x12
ffffffffc020439e:	1be7b783          	ld	a5,446(a5) # ffffffffc0216558 <boot_cr3>
    proc->tf = NULL;
ffffffffc02043a2:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3;
ffffffffc02043a6:	f45c                	sd	a5,168(s0)
    // 初始化进程的标志位为 0，表示没有特殊的进程标志
    proc->flags = 0;
ffffffffc02043a8:	0a042823          	sw	zero,176(s0)
    // 清空进程名称的字符串，确保没有随机的字符，长度为 PROC_NAME_LEN + 1
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc02043ac:	4641                	li	a2,16
ffffffffc02043ae:	4581                	li	a1,0
ffffffffc02043b0:	0b440513          	addi	a0,s0,180
ffffffffc02043b4:	37f000ef          	jal	ra,ffffffffc0204f32 <memset>
    }
    return proc;
}
ffffffffc02043b8:	60a2                	ld	ra,8(sp)
ffffffffc02043ba:	8522                	mv	a0,s0
ffffffffc02043bc:	6402                	ld	s0,0(sp)
ffffffffc02043be:	0141                	addi	sp,sp,16
ffffffffc02043c0:	8082                	ret

ffffffffc02043c2 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc02043c2:	00012797          	auipc	a5,0x12
ffffffffc02043c6:	1ee7b783          	ld	a5,494(a5) # ffffffffc02165b0 <current>
ffffffffc02043ca:	73c8                	ld	a0,160(a5)
ffffffffc02043cc:	fa0fc06f          	j	ffffffffc0200b6c <forkrets>

ffffffffc02043d0 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02043d0:	7179                	addi	sp,sp,-48
ffffffffc02043d2:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02043d4:	00012497          	auipc	s1,0x12
ffffffffc02043d8:	14448493          	addi	s1,s1,324 # ffffffffc0216518 <name.2>
init_main(void *arg) {
ffffffffc02043dc:	f022                	sd	s0,32(sp)
ffffffffc02043de:	e84a                	sd	s2,16(sp)
ffffffffc02043e0:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043e2:	00012917          	auipc	s2,0x12
ffffffffc02043e6:	1ce93903          	ld	s2,462(s2) # ffffffffc02165b0 <current>
    memset(name, 0, sizeof(name));
ffffffffc02043ea:	4641                	li	a2,16
ffffffffc02043ec:	4581                	li	a1,0
ffffffffc02043ee:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc02043f0:	f406                	sd	ra,40(sp)
ffffffffc02043f2:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043f4:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc02043f8:	33b000ef          	jal	ra,ffffffffc0204f32 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02043fc:	0b490593          	addi	a1,s2,180
ffffffffc0204400:	463d                	li	a2,15
ffffffffc0204402:	8526                	mv	a0,s1
ffffffffc0204404:	341000ef          	jal	ra,ffffffffc0204f44 <memcpy>
ffffffffc0204408:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020440a:	85ce                	mv	a1,s3
ffffffffc020440c:	00003517          	auipc	a0,0x3
ffffffffc0204410:	85c50513          	addi	a0,a0,-1956 # ffffffffc0206c68 <default_pmm_manager+0xf98>
ffffffffc0204414:	d6dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204418:	85a2                	mv	a1,s0
ffffffffc020441a:	00003517          	auipc	a0,0x3
ffffffffc020441e:	87650513          	addi	a0,a0,-1930 # ffffffffc0206c90 <default_pmm_manager+0xfc0>
ffffffffc0204422:	d5ffb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204426:	00003517          	auipc	a0,0x3
ffffffffc020442a:	87a50513          	addi	a0,a0,-1926 # ffffffffc0206ca0 <default_pmm_manager+0xfd0>
ffffffffc020442e:	d53fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0204432:	70a2                	ld	ra,40(sp)
ffffffffc0204434:	7402                	ld	s0,32(sp)
ffffffffc0204436:	64e2                	ld	s1,24(sp)
ffffffffc0204438:	6942                	ld	s2,16(sp)
ffffffffc020443a:	69a2                	ld	s3,8(sp)
ffffffffc020443c:	4501                	li	a0,0
ffffffffc020443e:	6145                	addi	sp,sp,48
ffffffffc0204440:	8082                	ret

ffffffffc0204442 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204442:	7179                	addi	sp,sp,-48
ffffffffc0204444:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204446:	00012917          	auipc	s2,0x12
ffffffffc020444a:	16a90913          	addi	s2,s2,362 # ffffffffc02165b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc020444e:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204450:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204454:	f406                	sd	ra,40(sp)
ffffffffc0204456:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204458:	02a48963          	beq	s1,a0,ffffffffc020448a <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020445c:	100027f3          	csrr	a5,sstatus
ffffffffc0204460:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204462:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204464:	e3a1                	bnez	a5,ffffffffc02044a4 <proc_run+0x62>
        lcr3(proc->cr3);//修改页表基址的地址
ffffffffc0204466:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204468:	80000737          	lui	a4,0x80000
        current = proc;
ffffffffc020446c:	00a93023          	sd	a0,0(s2)
ffffffffc0204470:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204474:	8fd9                	or	a5,a5,a4
ffffffffc0204476:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(proc->context));// 切换上下文状态
ffffffffc020447a:	03050593          	addi	a1,a0,48
ffffffffc020447e:	03048513          	addi	a0,s1,48
ffffffffc0204482:	532000ef          	jal	ra,ffffffffc02049b4 <switch_to>
    if (flag) {
ffffffffc0204486:	00099863          	bnez	s3,ffffffffc0204496 <proc_run+0x54>
}
ffffffffc020448a:	70a2                	ld	ra,40(sp)
ffffffffc020448c:	7482                	ld	s1,32(sp)
ffffffffc020448e:	6962                	ld	s2,24(sp)
ffffffffc0204490:	69c2                	ld	s3,16(sp)
ffffffffc0204492:	6145                	addi	sp,sp,48
ffffffffc0204494:	8082                	ret
ffffffffc0204496:	70a2                	ld	ra,40(sp)
ffffffffc0204498:	7482                	ld	s1,32(sp)
ffffffffc020449a:	6962                	ld	s2,24(sp)
ffffffffc020449c:	69c2                	ld	s3,16(sp)
ffffffffc020449e:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02044a0:	91cfc06f          	j	ffffffffc02005bc <intr_enable>
ffffffffc02044a4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02044a6:	91cfc0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc02044aa:	6522                	ld	a0,8(sp)
ffffffffc02044ac:	4985                	li	s3,1
ffffffffc02044ae:	bf65                	j	ffffffffc0204466 <proc_run+0x24>

ffffffffc02044b0 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02044b0:	7179                	addi	sp,sp,-48
ffffffffc02044b2:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02044b4:	00012917          	auipc	s2,0x12
ffffffffc02044b8:	11490913          	addi	s2,s2,276 # ffffffffc02165c8 <nr_process>
ffffffffc02044bc:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02044c0:	f406                	sd	ra,40(sp)
ffffffffc02044c2:	f022                	sd	s0,32(sp)
ffffffffc02044c4:	ec26                	sd	s1,24(sp)
ffffffffc02044c6:	e44e                	sd	s3,8(sp)
ffffffffc02044c8:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02044ca:	6785                	lui	a5,0x1
ffffffffc02044cc:	1cf75863          	bge	a4,a5,ffffffffc020469c <do_fork+0x1ec>
ffffffffc02044d0:	84ae                	mv	s1,a1
ffffffffc02044d2:	8a32                	mv	s4,a2
    proc->parent = current;             // 设置新进程的父进程为当前进程
ffffffffc02044d4:	00012997          	auipc	s3,0x12
ffffffffc02044d8:	0dc98993          	addi	s3,s3,220 # ffffffffc02165b0 <current>
    proc = alloc_proc();                // 分配并初始化一个新的进程结构体
ffffffffc02044dc:	e85ff0ef          	jal	ra,ffffffffc0204360 <alloc_proc>
    proc->parent = current;             // 设置新进程的父进程为当前进程
ffffffffc02044e0:	0009b783          	ld	a5,0(s3)
    proc = alloc_proc();                // 分配并初始化一个新的进程结构体
ffffffffc02044e4:	842a                	mv	s0,a0
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02044e6:	4509                	li	a0,2
    proc->parent = current;             // 设置新进程的父进程为当前进程
ffffffffc02044e8:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02044ea:	d7efd0ef          	jal	ra,ffffffffc0201a68 <alloc_pages>
    if (page != NULL) {
ffffffffc02044ee:	c139                	beqz	a0,ffffffffc0204534 <do_fork+0x84>
    return page - pages + nbase;
ffffffffc02044f0:	00012697          	auipc	a3,0x12
ffffffffc02044f4:	0806b683          	ld	a3,128(a3) # ffffffffc0216570 <pages>
ffffffffc02044f8:	40d506b3          	sub	a3,a0,a3
ffffffffc02044fc:	868d                	srai	a3,a3,0x3
ffffffffc02044fe:	00003517          	auipc	a0,0x3
ffffffffc0204502:	b0a53503          	ld	a0,-1270(a0) # ffffffffc0207008 <error_string+0x38>
ffffffffc0204506:	02a686b3          	mul	a3,a3,a0
ffffffffc020450a:	00003797          	auipc	a5,0x3
ffffffffc020450e:	b067b783          	ld	a5,-1274(a5) # ffffffffc0207010 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204512:	00012717          	auipc	a4,0x12
ffffffffc0204516:	05673703          	ld	a4,86(a4) # ffffffffc0216568 <npage>
    return page - pages + nbase;
ffffffffc020451a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020451c:	00c69793          	slli	a5,a3,0xc
ffffffffc0204520:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204522:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204524:	1ae7f163          	bgeu	a5,a4,ffffffffc02046c6 <do_fork+0x216>
ffffffffc0204528:	00012797          	auipc	a5,0x12
ffffffffc020452c:	0587b783          	ld	a5,88(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc0204530:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204532:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204534:	0009b783          	ld	a5,0(s3)
ffffffffc0204538:	779c                	ld	a5,40(a5)
ffffffffc020453a:	16079663          	bnez	a5,ffffffffc02046a6 <do_fork+0x1f6>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020453e:	6818                	ld	a4,16(s0)
ffffffffc0204540:	6789                	lui	a5,0x2
ffffffffc0204542:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0204546:	973e                	add	a4,a4,a5
    *(proc->tf) = *tf;
ffffffffc0204548:	8652                	mv	a2,s4
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020454a:	f058                	sd	a4,160(s0)
    *(proc->tf) = *tf;
ffffffffc020454c:	87ba                	mv	a5,a4
ffffffffc020454e:	120a0593          	addi	a1,s4,288
ffffffffc0204552:	00063883          	ld	a7,0(a2)
ffffffffc0204556:	00863803          	ld	a6,8(a2)
ffffffffc020455a:	6a08                	ld	a0,16(a2)
ffffffffc020455c:	6e14                	ld	a3,24(a2)
ffffffffc020455e:	0117b023          	sd	a7,0(a5)
ffffffffc0204562:	0107b423          	sd	a6,8(a5)
ffffffffc0204566:	eb88                	sd	a0,16(a5)
ffffffffc0204568:	ef94                	sd	a3,24(a5)
ffffffffc020456a:	02060613          	addi	a2,a2,32
ffffffffc020456e:	02078793          	addi	a5,a5,32
ffffffffc0204572:	feb610e3          	bne	a2,a1,ffffffffc0204552 <do_fork+0xa2>
    proc->tf->gpr.a0 = 0;
ffffffffc0204576:	04073823          	sd	zero,80(a4)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020457a:	10048563          	beqz	s1,ffffffffc0204684 <do_fork+0x1d4>
    if (++ last_pid >= MAX_PID) {
ffffffffc020457e:	00007817          	auipc	a6,0x7
ffffffffc0204582:	ada80813          	addi	a6,a6,-1318 # ffffffffc020b058 <last_pid.1>
ffffffffc0204586:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020458a:	eb04                	sd	s1,16(a4)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020458c:	00000697          	auipc	a3,0x0
ffffffffc0204590:	e3668693          	addi	a3,a3,-458 # ffffffffc02043c2 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204594:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204598:	f814                	sd	a3,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020459a:	fc18                	sd	a4,56(s0)
    if (++ last_pid >= MAX_PID) {
ffffffffc020459c:	00a82023          	sw	a0,0(a6)
ffffffffc02045a0:	6789                	lui	a5,0x2
ffffffffc02045a2:	06f55a63          	bge	a0,a5,ffffffffc0204616 <do_fork+0x166>
    if (last_pid >= next_safe) {
ffffffffc02045a6:	00007317          	auipc	t1,0x7
ffffffffc02045aa:	ab630313          	addi	t1,t1,-1354 # ffffffffc020b05c <next_safe.0>
ffffffffc02045ae:	00032783          	lw	a5,0(t1)
ffffffffc02045b2:	00012497          	auipc	s1,0x12
ffffffffc02045b6:	f7648493          	addi	s1,s1,-138 # ffffffffc0216528 <proc_list>
ffffffffc02045ba:	06f55663          	bge	a0,a5,ffffffffc0204626 <do_fork+0x176>
    proc->pid = pid;                    // 设置新进程的进程ID
ffffffffc02045be:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));//将 proc->hash_link 链接到对应的哈希桶。
ffffffffc02045c0:	45a9                	li	a1,10
ffffffffc02045c2:	2501                	sext.w	a0,a0
ffffffffc02045c4:	4ee000ef          	jal	ra,ffffffffc0204ab2 <hash32>
ffffffffc02045c8:	02051793          	slli	a5,a0,0x20
ffffffffc02045cc:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02045d0:	0000e797          	auipc	a5,0xe
ffffffffc02045d4:	f4878793          	addi	a5,a5,-184 # ffffffffc0212518 <hash_list>
ffffffffc02045d8:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02045da:	6510                	ld	a2,8(a0)
ffffffffc02045dc:	0d840793          	addi	a5,s0,216
ffffffffc02045e0:	6498                	ld	a4,8(s1)
    prev->next = next->prev = elm;
ffffffffc02045e2:	e21c                	sd	a5,0(a2)
ffffffffc02045e4:	e51c                	sd	a5,8(a0)
    nr_process++;                       // 增加系统中的进程数量
ffffffffc02045e6:	00092783          	lw	a5,0(s2)
    list_add(&proc_list, &(proc->list_link)); // 将新进程加入进程链表
ffffffffc02045ea:	0c840693          	addi	a3,s0,200
    elm->prev = prev;
ffffffffc02045ee:	ec68                	sd	a0,216(s0)
    elm->next = next;
ffffffffc02045f0:	f070                	sd	a2,224(s0)
    prev->next = next->prev = elm;
ffffffffc02045f2:	e314                	sd	a3,0(a4)
    nr_process++;                       // 增加系统中的进程数量
ffffffffc02045f4:	2785                	addiw	a5,a5,1
    ret = proc->pid;                    // 返回新进程的进程ID
ffffffffc02045f6:	4048                	lw	a0,4(s0)
ffffffffc02045f8:	e494                	sd	a3,8(s1)
    nr_process++;                       // 增加系统中的进程数量
ffffffffc02045fa:	00f92023          	sw	a5,0(s2)
    proc->state = PROC_RUNNABLE;        // 设置新进程的状态为可运行
ffffffffc02045fe:	4789                	li	a5,2
    elm->next = next;
ffffffffc0204600:	e878                	sd	a4,208(s0)
    elm->prev = prev;
ffffffffc0204602:	e464                	sd	s1,200(s0)
ffffffffc0204604:	c01c                	sw	a5,0(s0)
}
ffffffffc0204606:	70a2                	ld	ra,40(sp)
ffffffffc0204608:	7402                	ld	s0,32(sp)
ffffffffc020460a:	64e2                	ld	s1,24(sp)
ffffffffc020460c:	6942                	ld	s2,16(sp)
ffffffffc020460e:	69a2                	ld	s3,8(sp)
ffffffffc0204610:	6a02                	ld	s4,0(sp)
ffffffffc0204612:	6145                	addi	sp,sp,48
ffffffffc0204614:	8082                	ret
        last_pid = 1;
ffffffffc0204616:	4785                	li	a5,1
ffffffffc0204618:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc020461c:	4505                	li	a0,1
ffffffffc020461e:	00007317          	auipc	t1,0x7
ffffffffc0204622:	a3e30313          	addi	t1,t1,-1474 # ffffffffc020b05c <next_safe.0>
    return listelm->next;
ffffffffc0204626:	00012497          	auipc	s1,0x12
ffffffffc020462a:	f0248493          	addi	s1,s1,-254 # ffffffffc0216528 <proc_list>
ffffffffc020462e:	0084be03          	ld	t3,8(s1)
        next_safe = MAX_PID;// 设置右边界为最大值，后面再缩小这个范围到冲突的pid的位置
ffffffffc0204632:	6789                	lui	a5,0x2
ffffffffc0204634:	00f32023          	sw	a5,0(t1)
ffffffffc0204638:	86aa                	mv	a3,a0
ffffffffc020463a:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc020463c:	6e89                	lui	t4,0x2
ffffffffc020463e:	049e0a63          	beq	t3,s1,ffffffffc0204692 <do_fork+0x1e2>
ffffffffc0204642:	88ae                	mv	a7,a1
ffffffffc0204644:	87f2                	mv	a5,t3
ffffffffc0204646:	6609                	lui	a2,0x2
ffffffffc0204648:	a811                	j	ffffffffc020465c <do_fork+0x1ac>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020464a:	00e6d663          	bge	a3,a4,ffffffffc0204656 <do_fork+0x1a6>
ffffffffc020464e:	00c75463          	bge	a4,a2,ffffffffc0204656 <do_fork+0x1a6>
ffffffffc0204652:	863a                	mv	a2,a4
ffffffffc0204654:	4885                	li	a7,1
ffffffffc0204656:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204658:	00978d63          	beq	a5,s1,ffffffffc0204672 <do_fork+0x1c2>
            if (proc->pid == last_pid) {
ffffffffc020465c:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc0204660:	fed715e3          	bne	a4,a3,ffffffffc020464a <do_fork+0x19a>
                if (++ last_pid >= next_safe) {
ffffffffc0204664:	2685                	addiw	a3,a3,1
ffffffffc0204666:	02c6d163          	bge	a3,a2,ffffffffc0204688 <do_fork+0x1d8>
ffffffffc020466a:	679c                	ld	a5,8(a5)
ffffffffc020466c:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020466e:	fe9797e3          	bne	a5,s1,ffffffffc020465c <do_fork+0x1ac>
ffffffffc0204672:	c581                	beqz	a1,ffffffffc020467a <do_fork+0x1ca>
ffffffffc0204674:	00d82023          	sw	a3,0(a6)
ffffffffc0204678:	8536                	mv	a0,a3
ffffffffc020467a:	f40882e3          	beqz	a7,ffffffffc02045be <do_fork+0x10e>
ffffffffc020467e:	00c32023          	sw	a2,0(t1)
ffffffffc0204682:	bf35                	j	ffffffffc02045be <do_fork+0x10e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204684:	84ba                	mv	s1,a4
ffffffffc0204686:	bde5                	j	ffffffffc020457e <do_fork+0xce>
                    if (last_pid >= MAX_PID) {
ffffffffc0204688:	01d6c363          	blt	a3,t4,ffffffffc020468e <do_fork+0x1de>
                        last_pid = 1;
ffffffffc020468c:	4685                	li	a3,1
                    goto repeat;
ffffffffc020468e:	4585                	li	a1,1
ffffffffc0204690:	b77d                	j	ffffffffc020463e <do_fork+0x18e>
ffffffffc0204692:	c599                	beqz	a1,ffffffffc02046a0 <do_fork+0x1f0>
ffffffffc0204694:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0204698:	8536                	mv	a0,a3
ffffffffc020469a:	b715                	j	ffffffffc02045be <do_fork+0x10e>
    int ret = -E_NO_FREE_PROC;
ffffffffc020469c:	556d                	li	a0,-5
    return ret;
ffffffffc020469e:	b7a5                	j	ffffffffc0204606 <do_fork+0x156>
    return last_pid;
ffffffffc02046a0:	00082503          	lw	a0,0(a6)
ffffffffc02046a4:	bf29                	j	ffffffffc02045be <do_fork+0x10e>
    assert(current->mm == NULL);
ffffffffc02046a6:	00002697          	auipc	a3,0x2
ffffffffc02046aa:	61a68693          	addi	a3,a3,1562 # ffffffffc0206cc0 <default_pmm_manager+0xff0>
ffffffffc02046ae:	00001617          	auipc	a2,0x1
ffffffffc02046b2:	27260613          	addi	a2,a2,626 # ffffffffc0205920 <commands+0x738>
ffffffffc02046b6:	11800593          	li	a1,280
ffffffffc02046ba:	00002517          	auipc	a0,0x2
ffffffffc02046be:	61e50513          	addi	a0,a0,1566 # ffffffffc0206cd8 <default_pmm_manager+0x1008>
ffffffffc02046c2:	d85fb0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02046c6:	00001617          	auipc	a2,0x1
ffffffffc02046ca:	64260613          	addi	a2,a2,1602 # ffffffffc0205d08 <default_pmm_manager+0x38>
ffffffffc02046ce:	06900593          	li	a1,105
ffffffffc02046d2:	00001517          	auipc	a0,0x1
ffffffffc02046d6:	65e50513          	addi	a0,a0,1630 # ffffffffc0205d30 <default_pmm_manager+0x60>
ffffffffc02046da:	d6dfb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02046de <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02046de:	7129                	addi	sp,sp,-320
ffffffffc02046e0:	fa22                	sd	s0,304(sp)
ffffffffc02046e2:	f626                	sd	s1,296(sp)
ffffffffc02046e4:	f24a                	sd	s2,288(sp)
ffffffffc02046e6:	84ae                	mv	s1,a1
ffffffffc02046e8:	892a                	mv	s2,a0
ffffffffc02046ea:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046ec:	4581                	li	a1,0
ffffffffc02046ee:	12000613          	li	a2,288
ffffffffc02046f2:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02046f4:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046f6:	03d000ef          	jal	ra,ffffffffc0204f32 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02046fa:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02046fc:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02046fe:	100027f3          	csrr	a5,sstatus
ffffffffc0204702:	edd7f793          	andi	a5,a5,-291
ffffffffc0204706:	1207e793          	ori	a5,a5,288
ffffffffc020470a:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020470c:	860a                	mv	a2,sp
ffffffffc020470e:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204712:	00000797          	auipc	a5,0x0
ffffffffc0204716:	c4678793          	addi	a5,a5,-954 # ffffffffc0204358 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020471a:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020471c:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020471e:	d93ff0ef          	jal	ra,ffffffffc02044b0 <do_fork>
}
ffffffffc0204722:	70f2                	ld	ra,312(sp)
ffffffffc0204724:	7452                	ld	s0,304(sp)
ffffffffc0204726:	74b2                	ld	s1,296(sp)
ffffffffc0204728:	7912                	ld	s2,288(sp)
ffffffffc020472a:	6131                	addi	sp,sp,320
ffffffffc020472c:	8082                	ret

ffffffffc020472e <do_exit>:
do_exit(int error_code) {
ffffffffc020472e:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204730:	00002617          	auipc	a2,0x2
ffffffffc0204734:	5c060613          	addi	a2,a2,1472 # ffffffffc0206cf0 <default_pmm_manager+0x1020>
ffffffffc0204738:	17200593          	li	a1,370
ffffffffc020473c:	00002517          	auipc	a0,0x2
ffffffffc0204740:	59c50513          	addi	a0,a0,1436 # ffffffffc0206cd8 <default_pmm_manager+0x1008>
do_exit(int error_code) {
ffffffffc0204744:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204746:	d01fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020474a <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc020474a:	7179                	addi	sp,sp,-48
ffffffffc020474c:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc020474e:	00012797          	auipc	a5,0x12
ffffffffc0204752:	dda78793          	addi	a5,a5,-550 # ffffffffc0216528 <proc_list>
ffffffffc0204756:	f406                	sd	ra,40(sp)
ffffffffc0204758:	f022                	sd	s0,32(sp)
ffffffffc020475a:	e84a                	sd	s2,16(sp)
ffffffffc020475c:	e44e                	sd	s3,8(sp)
ffffffffc020475e:	0000e497          	auipc	s1,0xe
ffffffffc0204762:	dba48493          	addi	s1,s1,-582 # ffffffffc0212518 <hash_list>
ffffffffc0204766:	e79c                	sd	a5,8(a5)
ffffffffc0204768:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc020476a:	00012717          	auipc	a4,0x12
ffffffffc020476e:	dae70713          	addi	a4,a4,-594 # ffffffffc0216518 <name.2>
ffffffffc0204772:	87a6                	mv	a5,s1
ffffffffc0204774:	e79c                	sd	a5,8(a5)
ffffffffc0204776:	e39c                	sd	a5,0(a5)
ffffffffc0204778:	07c1                	addi	a5,a5,16
ffffffffc020477a:	fef71de3          	bne	a4,a5,ffffffffc0204774 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020477e:	be3ff0ef          	jal	ra,ffffffffc0204360 <alloc_proc>
ffffffffc0204782:	00012917          	auipc	s2,0x12
ffffffffc0204786:	e3690913          	addi	s2,s2,-458 # ffffffffc02165b8 <idleproc>
ffffffffc020478a:	00a93023          	sd	a0,0(s2)
ffffffffc020478e:	18050d63          	beqz	a0,ffffffffc0204928 <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204792:	07000513          	li	a0,112
ffffffffc0204796:	8eefd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020479a:	07000613          	li	a2,112
ffffffffc020479e:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02047a0:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02047a2:	790000ef          	jal	ra,ffffffffc0204f32 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02047a6:	00093503          	ld	a0,0(s2)
ffffffffc02047aa:	85a2                	mv	a1,s0
ffffffffc02047ac:	07000613          	li	a2,112
ffffffffc02047b0:	03050513          	addi	a0,a0,48
ffffffffc02047b4:	7a8000ef          	jal	ra,ffffffffc0204f5c <memcmp>
ffffffffc02047b8:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02047ba:	453d                	li	a0,15
ffffffffc02047bc:	8c8fd0ef          	jal	ra,ffffffffc0201884 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02047c0:	463d                	li	a2,15
ffffffffc02047c2:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02047c4:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02047c6:	76c000ef          	jal	ra,ffffffffc0204f32 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02047ca:	00093503          	ld	a0,0(s2)
ffffffffc02047ce:	463d                	li	a2,15
ffffffffc02047d0:	85a2                	mv	a1,s0
ffffffffc02047d2:	0b450513          	addi	a0,a0,180
ffffffffc02047d6:	786000ef          	jal	ra,ffffffffc0204f5c <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02047da:	00093783          	ld	a5,0(s2)
ffffffffc02047de:	00012717          	auipc	a4,0x12
ffffffffc02047e2:	d7a73703          	ld	a4,-646(a4) # ffffffffc0216558 <boot_cr3>
ffffffffc02047e6:	77d4                	ld	a3,168(a5)
ffffffffc02047e8:	0ee68463          	beq	a3,a4,ffffffffc02048d0 <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;//idleproc是第0个内核线程
    idleproc->state = PROC_RUNNABLE;//使得它从“出生”转到了“准备工作”，就差uCore调度它执行了
ffffffffc02047ec:	4709                	li	a4,2
ffffffffc02047ee:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;//uCore启动时设置的内核栈直接分配给idleproc使用
ffffffffc02047f0:	00004717          	auipc	a4,0x4
ffffffffc02047f4:	81070713          	addi	a4,a4,-2032 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047f8:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;//uCore启动时设置的内核栈直接分配给idleproc使用
ffffffffc02047fc:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;//如果当前idleproc在执行，则只要此标志为1，马上就调用schedule函数要求调度器切换其他进程执行。
ffffffffc02047fe:	4705                	li	a4,1
ffffffffc0204800:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204802:	4641                	li	a2,16
ffffffffc0204804:	4581                	li	a1,0
ffffffffc0204806:	8522                	mv	a0,s0
ffffffffc0204808:	72a000ef          	jal	ra,ffffffffc0204f32 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020480c:	463d                	li	a2,15
ffffffffc020480e:	00002597          	auipc	a1,0x2
ffffffffc0204812:	52a58593          	addi	a1,a1,1322 # ffffffffc0206d38 <default_pmm_manager+0x1068>
ffffffffc0204816:	8522                	mv	a0,s0
ffffffffc0204818:	72c000ef          	jal	ra,ffffffffc0204f44 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc020481c:	00012717          	auipc	a4,0x12
ffffffffc0204820:	dac70713          	addi	a4,a4,-596 # ffffffffc02165c8 <nr_process>
ffffffffc0204824:	431c                	lw	a5,0(a4)

    current = idleproc;//当前进程是idleproc，0号进程
ffffffffc0204826:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020482a:	4601                	li	a2,0
    nr_process ++;
ffffffffc020482c:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020482e:	00002597          	auipc	a1,0x2
ffffffffc0204832:	51258593          	addi	a1,a1,1298 # ffffffffc0206d40 <default_pmm_manager+0x1070>
ffffffffc0204836:	00000517          	auipc	a0,0x0
ffffffffc020483a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc02043d0 <init_main>
    nr_process ++;
ffffffffc020483e:	c31c                	sw	a5,0(a4)
    current = idleproc;//当前进程是idleproc，0号进程
ffffffffc0204840:	00012797          	auipc	a5,0x12
ffffffffc0204844:	d6d7b823          	sd	a3,-656(a5) # ffffffffc02165b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204848:	e97ff0ef          	jal	ra,ffffffffc02046de <kernel_thread>
ffffffffc020484c:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc020484e:	0ea05963          	blez	a0,ffffffffc0204940 <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204852:	6789                	lui	a5,0x2
ffffffffc0204854:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204858:	17f9                	addi	a5,a5,-2
ffffffffc020485a:	2501                	sext.w	a0,a0
ffffffffc020485c:	02e7e363          	bltu	a5,a4,ffffffffc0204882 <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204860:	45a9                	li	a1,10
ffffffffc0204862:	250000ef          	jal	ra,ffffffffc0204ab2 <hash32>
ffffffffc0204866:	02051793          	slli	a5,a0,0x20
ffffffffc020486a:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020486e:	96a6                	add	a3,a3,s1
ffffffffc0204870:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204872:	a029                	j	ffffffffc020487c <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc0204874:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc0204878:	0a870563          	beq	a4,s0,ffffffffc0204922 <proc_init+0x1d8>
    return listelm->next;
ffffffffc020487c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020487e:	fef69be3          	bne	a3,a5,ffffffffc0204874 <proc_init+0x12a>
    return NULL;
ffffffffc0204882:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204884:	0b478493          	addi	s1,a5,180
ffffffffc0204888:	4641                	li	a2,16
ffffffffc020488a:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020488c:	00012417          	auipc	s0,0x12
ffffffffc0204890:	d3440413          	addi	s0,s0,-716 # ffffffffc02165c0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204894:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0204896:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204898:	69a000ef          	jal	ra,ffffffffc0204f32 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020489c:	463d                	li	a2,15
ffffffffc020489e:	00002597          	auipc	a1,0x2
ffffffffc02048a2:	4d258593          	addi	a1,a1,1234 # ffffffffc0206d70 <default_pmm_manager+0x10a0>
ffffffffc02048a6:	8526                	mv	a0,s1
ffffffffc02048a8:	69c000ef          	jal	ra,ffffffffc0204f44 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02048ac:	00093783          	ld	a5,0(s2)
ffffffffc02048b0:	c7e1                	beqz	a5,ffffffffc0204978 <proc_init+0x22e>
ffffffffc02048b2:	43dc                	lw	a5,4(a5)
ffffffffc02048b4:	e3f1                	bnez	a5,ffffffffc0204978 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02048b6:	601c                	ld	a5,0(s0)
ffffffffc02048b8:	c3c5                	beqz	a5,ffffffffc0204958 <proc_init+0x20e>
ffffffffc02048ba:	43d8                	lw	a4,4(a5)
ffffffffc02048bc:	4785                	li	a5,1
ffffffffc02048be:	08f71d63          	bne	a4,a5,ffffffffc0204958 <proc_init+0x20e>
}
ffffffffc02048c2:	70a2                	ld	ra,40(sp)
ffffffffc02048c4:	7402                	ld	s0,32(sp)
ffffffffc02048c6:	64e2                	ld	s1,24(sp)
ffffffffc02048c8:	6942                	ld	s2,16(sp)
ffffffffc02048ca:	69a2                	ld	s3,8(sp)
ffffffffc02048cc:	6145                	addi	sp,sp,48
ffffffffc02048ce:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02048d0:	73d8                	ld	a4,160(a5)
ffffffffc02048d2:	ff09                	bnez	a4,ffffffffc02047ec <proc_init+0xa2>
ffffffffc02048d4:	f0099ce3          	bnez	s3,ffffffffc02047ec <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02048d8:	6394                	ld	a3,0(a5)
ffffffffc02048da:	577d                	li	a4,-1
ffffffffc02048dc:	1702                	slli	a4,a4,0x20
ffffffffc02048de:	f0e697e3          	bne	a3,a4,ffffffffc02047ec <proc_init+0xa2>
ffffffffc02048e2:	4798                	lw	a4,8(a5)
ffffffffc02048e4:	f00714e3          	bnez	a4,ffffffffc02047ec <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02048e8:	6b98                	ld	a4,16(a5)
ffffffffc02048ea:	f00711e3          	bnez	a4,ffffffffc02047ec <proc_init+0xa2>
ffffffffc02048ee:	4f98                	lw	a4,24(a5)
ffffffffc02048f0:	2701                	sext.w	a4,a4
ffffffffc02048f2:	ee071de3          	bnez	a4,ffffffffc02047ec <proc_init+0xa2>
ffffffffc02048f6:	7398                	ld	a4,32(a5)
ffffffffc02048f8:	ee071ae3          	bnez	a4,ffffffffc02047ec <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02048fc:	7798                	ld	a4,40(a5)
ffffffffc02048fe:	ee0717e3          	bnez	a4,ffffffffc02047ec <proc_init+0xa2>
ffffffffc0204902:	0b07a703          	lw	a4,176(a5)
ffffffffc0204906:	8d59                	or	a0,a0,a4
ffffffffc0204908:	0005071b          	sext.w	a4,a0
ffffffffc020490c:	ee0710e3          	bnez	a4,ffffffffc02047ec <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204910:	00002517          	auipc	a0,0x2
ffffffffc0204914:	41050513          	addi	a0,a0,1040 # ffffffffc0206d20 <default_pmm_manager+0x1050>
ffffffffc0204918:	869fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    idleproc->pid = 0;//idleproc是第0个内核线程
ffffffffc020491c:	00093783          	ld	a5,0(s2)
ffffffffc0204920:	b5f1                	j	ffffffffc02047ec <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204922:	f2878793          	addi	a5,a5,-216
ffffffffc0204926:	bfb9                	j	ffffffffc0204884 <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc0204928:	00002617          	auipc	a2,0x2
ffffffffc020492c:	3e060613          	addi	a2,a2,992 # ffffffffc0206d08 <default_pmm_manager+0x1038>
ffffffffc0204930:	18a00593          	li	a1,394
ffffffffc0204934:	00002517          	auipc	a0,0x2
ffffffffc0204938:	3a450513          	addi	a0,a0,932 # ffffffffc0206cd8 <default_pmm_manager+0x1008>
ffffffffc020493c:	b0bfb0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204940:	00002617          	auipc	a2,0x2
ffffffffc0204944:	41060613          	addi	a2,a2,1040 # ffffffffc0206d50 <default_pmm_manager+0x1080>
ffffffffc0204948:	1aa00593          	li	a1,426
ffffffffc020494c:	00002517          	auipc	a0,0x2
ffffffffc0204950:	38c50513          	addi	a0,a0,908 # ffffffffc0206cd8 <default_pmm_manager+0x1008>
ffffffffc0204954:	af3fb0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204958:	00002697          	auipc	a3,0x2
ffffffffc020495c:	44868693          	addi	a3,a3,1096 # ffffffffc0206da0 <default_pmm_manager+0x10d0>
ffffffffc0204960:	00001617          	auipc	a2,0x1
ffffffffc0204964:	fc060613          	addi	a2,a2,-64 # ffffffffc0205920 <commands+0x738>
ffffffffc0204968:	1b100593          	li	a1,433
ffffffffc020496c:	00002517          	auipc	a0,0x2
ffffffffc0204970:	36c50513          	addi	a0,a0,876 # ffffffffc0206cd8 <default_pmm_manager+0x1008>
ffffffffc0204974:	ad3fb0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204978:	00002697          	auipc	a3,0x2
ffffffffc020497c:	40068693          	addi	a3,a3,1024 # ffffffffc0206d78 <default_pmm_manager+0x10a8>
ffffffffc0204980:	00001617          	auipc	a2,0x1
ffffffffc0204984:	fa060613          	addi	a2,a2,-96 # ffffffffc0205920 <commands+0x738>
ffffffffc0204988:	1b000593          	li	a1,432
ffffffffc020498c:	00002517          	auipc	a0,0x2
ffffffffc0204990:	34c50513          	addi	a0,a0,844 # ffffffffc0206cd8 <default_pmm_manager+0x1008>
ffffffffc0204994:	ab3fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204998 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204998:	1141                	addi	sp,sp,-16
ffffffffc020499a:	e022                	sd	s0,0(sp)
ffffffffc020499c:	e406                	sd	ra,8(sp)
ffffffffc020499e:	00012417          	auipc	s0,0x12
ffffffffc02049a2:	c1240413          	addi	s0,s0,-1006 # ffffffffc02165b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02049a6:	6018                	ld	a4,0(s0)
ffffffffc02049a8:	4f1c                	lw	a5,24(a4)
ffffffffc02049aa:	2781                	sext.w	a5,a5
ffffffffc02049ac:	dff5                	beqz	a5,ffffffffc02049a8 <cpu_idle+0x10>
            schedule();
ffffffffc02049ae:	070000ef          	jal	ra,ffffffffc0204a1e <schedule>
ffffffffc02049b2:	bfd5                	j	ffffffffc02049a6 <cpu_idle+0xe>

ffffffffc02049b4 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02049b4:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02049b8:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02049bc:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02049be:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02049c0:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02049c4:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02049c8:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02049cc:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02049d0:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02049d4:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02049d8:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02049dc:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02049e0:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02049e4:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02049e8:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02049ec:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02049f0:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02049f2:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02049f4:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02049f8:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02049fc:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204a00:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204a04:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204a08:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204a0c:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204a10:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204a14:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204a18:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204a1c:	8082                	ret

ffffffffc0204a1e <schedule>:
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
ffffffffc0204a1e:	1141                	addi	sp,sp,-16
ffffffffc0204a20:	e406                	sd	ra,8(sp)
ffffffffc0204a22:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a24:	100027f3          	csrr	a5,sstatus
ffffffffc0204a28:	8b89                	andi	a5,a5,2
ffffffffc0204a2a:	4401                	li	s0,0
ffffffffc0204a2c:	efbd                	bnez	a5,ffffffffc0204aaa <schedule+0x8c>
    bool intr_flag;//中断标志变量
    list_entry_t *le, *last;//工作指针：当前节点、下一节点
    struct proc_struct *next = NULL;//找到的要切换的进程
    local_intr_save(intr_flag);//中断禁止
    {
        current->need_resched = 0;
ffffffffc0204a2e:	00012897          	auipc	a7,0x12
ffffffffc0204a32:	b828b883          	ld	a7,-1150(a7) # ffffffffc02165b0 <current>
ffffffffc0204a36:	0008ac23          	sw	zero,24(a7)
        //检查是否是idle，如果是idle就从头开始找，否则从现在开始找
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204a3a:	00012517          	auipc	a0,0x12
ffffffffc0204a3e:	b7e53503          	ld	a0,-1154(a0) # ffffffffc02165b8 <idleproc>
ffffffffc0204a42:	04a88e63          	beq	a7,a0,ffffffffc0204a9e <schedule+0x80>
ffffffffc0204a46:	0c888693          	addi	a3,a7,200
ffffffffc0204a4a:	00012617          	auipc	a2,0x12
ffffffffc0204a4e:	ade60613          	addi	a2,a2,-1314 # ffffffffc0216528 <proc_list>
        le = last;
ffffffffc0204a52:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;//找到的要切换的进程
ffffffffc0204a54:	4581                	li	a1,0
        do {//遍历proc_list，直到找到可以调度的进程
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a56:	4809                	li	a6,2
ffffffffc0204a58:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204a5a:	00c78863          	beq	a5,a2,ffffffffc0204a6a <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a5e:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204a62:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a66:	03070163          	beq	a4,a6,ffffffffc0204a88 <schedule+0x6a>
                    break;//找到一个可以调度的进程，结束循环
                }
            }
        } while (le != last);
ffffffffc0204a6a:	fef697e3          	bne	a3,a5,ffffffffc0204a58 <schedule+0x3a>

        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204a6e:	ed89                	bnez	a1,ffffffffc0204a88 <schedule+0x6a>
            next = idleproc;//未找到可以调度的进程，回到idle
        }

        next->runs ++;//该进程运行次数加一
ffffffffc0204a70:	451c                	lw	a5,8(a0)
ffffffffc0204a72:	2785                	addiw	a5,a5,1
ffffffffc0204a74:	c51c                	sw	a5,8(a0)

        if (next != current) {
ffffffffc0204a76:	00a88463          	beq	a7,a0,ffffffffc0204a7e <schedule+0x60>
            proc_run(next);//调用proc_run函数运行新进程
ffffffffc0204a7a:	9c9ff0ef          	jal	ra,ffffffffc0204442 <proc_run>
    if (flag) {
ffffffffc0204a7e:	e819                	bnez	s0,ffffffffc0204a94 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);//中断允许
}
ffffffffc0204a80:	60a2                	ld	ra,8(sp)
ffffffffc0204a82:	6402                	ld	s0,0(sp)
ffffffffc0204a84:	0141                	addi	sp,sp,16
ffffffffc0204a86:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204a88:	4198                	lw	a4,0(a1)
ffffffffc0204a8a:	4789                	li	a5,2
ffffffffc0204a8c:	fef712e3          	bne	a4,a5,ffffffffc0204a70 <schedule+0x52>
ffffffffc0204a90:	852e                	mv	a0,a1
ffffffffc0204a92:	bff9                	j	ffffffffc0204a70 <schedule+0x52>
}
ffffffffc0204a94:	6402                	ld	s0,0(sp)
ffffffffc0204a96:	60a2                	ld	ra,8(sp)
ffffffffc0204a98:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204a9a:	b23fb06f          	j	ffffffffc02005bc <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204a9e:	00012617          	auipc	a2,0x12
ffffffffc0204aa2:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0216528 <proc_list>
ffffffffc0204aa6:	86b2                	mv	a3,a2
ffffffffc0204aa8:	b76d                	j	ffffffffc0204a52 <schedule+0x34>
        intr_disable();
ffffffffc0204aaa:	b19fb0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0204aae:	4405                	li	s0,1
ffffffffc0204ab0:	bfbd                	j	ffffffffc0204a2e <schedule+0x10>

ffffffffc0204ab2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204ab2:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204ab6:	2785                	addiw	a5,a5,1
ffffffffc0204ab8:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204abc:	02000793          	li	a5,32
ffffffffc0204ac0:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204ac2:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204ac6:	8082                	ret

ffffffffc0204ac8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204ac8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204acc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204ace:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204ad2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204ad4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204ad8:	f022                	sd	s0,32(sp)
ffffffffc0204ada:	ec26                	sd	s1,24(sp)
ffffffffc0204adc:	e84a                	sd	s2,16(sp)
ffffffffc0204ade:	f406                	sd	ra,40(sp)
ffffffffc0204ae0:	e44e                	sd	s3,8(sp)
ffffffffc0204ae2:	84aa                	mv	s1,a0
ffffffffc0204ae4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204ae6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204aea:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204aec:	03067e63          	bgeu	a2,a6,ffffffffc0204b28 <printnum+0x60>
ffffffffc0204af0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204af2:	00805763          	blez	s0,ffffffffc0204b00 <printnum+0x38>
ffffffffc0204af6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204af8:	85ca                	mv	a1,s2
ffffffffc0204afa:	854e                	mv	a0,s3
ffffffffc0204afc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204afe:	fc65                	bnez	s0,ffffffffc0204af6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b00:	1a02                	slli	s4,s4,0x20
ffffffffc0204b02:	00002797          	auipc	a5,0x2
ffffffffc0204b06:	2c678793          	addi	a5,a5,710 # ffffffffc0206dc8 <default_pmm_manager+0x10f8>
ffffffffc0204b0a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204b0e:	9a3e                	add	s4,s4,a5
}
ffffffffc0204b10:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b12:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204b16:	70a2                	ld	ra,40(sp)
ffffffffc0204b18:	69a2                	ld	s3,8(sp)
ffffffffc0204b1a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b1c:	85ca                	mv	a1,s2
ffffffffc0204b1e:	87a6                	mv	a5,s1
}
ffffffffc0204b20:	6942                	ld	s2,16(sp)
ffffffffc0204b22:	64e2                	ld	s1,24(sp)
ffffffffc0204b24:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b26:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204b28:	03065633          	divu	a2,a2,a6
ffffffffc0204b2c:	8722                	mv	a4,s0
ffffffffc0204b2e:	f9bff0ef          	jal	ra,ffffffffc0204ac8 <printnum>
ffffffffc0204b32:	b7f9                	j	ffffffffc0204b00 <printnum+0x38>

ffffffffc0204b34 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204b34:	7119                	addi	sp,sp,-128
ffffffffc0204b36:	f4a6                	sd	s1,104(sp)
ffffffffc0204b38:	f0ca                	sd	s2,96(sp)
ffffffffc0204b3a:	ecce                	sd	s3,88(sp)
ffffffffc0204b3c:	e8d2                	sd	s4,80(sp)
ffffffffc0204b3e:	e4d6                	sd	s5,72(sp)
ffffffffc0204b40:	e0da                	sd	s6,64(sp)
ffffffffc0204b42:	fc5e                	sd	s7,56(sp)
ffffffffc0204b44:	f06a                	sd	s10,32(sp)
ffffffffc0204b46:	fc86                	sd	ra,120(sp)
ffffffffc0204b48:	f8a2                	sd	s0,112(sp)
ffffffffc0204b4a:	f862                	sd	s8,48(sp)
ffffffffc0204b4c:	f466                	sd	s9,40(sp)
ffffffffc0204b4e:	ec6e                	sd	s11,24(sp)
ffffffffc0204b50:	892a                	mv	s2,a0
ffffffffc0204b52:	84ae                	mv	s1,a1
ffffffffc0204b54:	8d32                	mv	s10,a2
ffffffffc0204b56:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b58:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b5c:	5b7d                	li	s6,-1
ffffffffc0204b5e:	00002a97          	auipc	s5,0x2
ffffffffc0204b62:	296a8a93          	addi	s5,s5,662 # ffffffffc0206df4 <default_pmm_manager+0x1124>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b66:	00002b97          	auipc	s7,0x2
ffffffffc0204b6a:	46ab8b93          	addi	s7,s7,1130 # ffffffffc0206fd0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b6e:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204b72:	001d0413          	addi	s0,s10,1
ffffffffc0204b76:	01350a63          	beq	a0,s3,ffffffffc0204b8a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204b7a:	c121                	beqz	a0,ffffffffc0204bba <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204b7c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b7e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b80:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b82:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b86:	ff351ae3          	bne	a0,s3,ffffffffc0204b7a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b8a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204b8e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b92:	4c81                	li	s9,0
ffffffffc0204b94:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204b96:	5c7d                	li	s8,-1
ffffffffc0204b98:	5dfd                	li	s11,-1
ffffffffc0204b9a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204b9e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ba0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204ba4:	0ff5f593          	zext.b	a1,a1
ffffffffc0204ba8:	00140d13          	addi	s10,s0,1
ffffffffc0204bac:	04b56263          	bltu	a0,a1,ffffffffc0204bf0 <vprintfmt+0xbc>
ffffffffc0204bb0:	058a                	slli	a1,a1,0x2
ffffffffc0204bb2:	95d6                	add	a1,a1,s5
ffffffffc0204bb4:	4194                	lw	a3,0(a1)
ffffffffc0204bb6:	96d6                	add	a3,a3,s5
ffffffffc0204bb8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204bba:	70e6                	ld	ra,120(sp)
ffffffffc0204bbc:	7446                	ld	s0,112(sp)
ffffffffc0204bbe:	74a6                	ld	s1,104(sp)
ffffffffc0204bc0:	7906                	ld	s2,96(sp)
ffffffffc0204bc2:	69e6                	ld	s3,88(sp)
ffffffffc0204bc4:	6a46                	ld	s4,80(sp)
ffffffffc0204bc6:	6aa6                	ld	s5,72(sp)
ffffffffc0204bc8:	6b06                	ld	s6,64(sp)
ffffffffc0204bca:	7be2                	ld	s7,56(sp)
ffffffffc0204bcc:	7c42                	ld	s8,48(sp)
ffffffffc0204bce:	7ca2                	ld	s9,40(sp)
ffffffffc0204bd0:	7d02                	ld	s10,32(sp)
ffffffffc0204bd2:	6de2                	ld	s11,24(sp)
ffffffffc0204bd4:	6109                	addi	sp,sp,128
ffffffffc0204bd6:	8082                	ret
            padc = '0';
ffffffffc0204bd8:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204bda:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bde:	846a                	mv	s0,s10
ffffffffc0204be0:	00140d13          	addi	s10,s0,1
ffffffffc0204be4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204be8:	0ff5f593          	zext.b	a1,a1
ffffffffc0204bec:	fcb572e3          	bgeu	a0,a1,ffffffffc0204bb0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204bf0:	85a6                	mv	a1,s1
ffffffffc0204bf2:	02500513          	li	a0,37
ffffffffc0204bf6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204bf8:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204bfc:	8d22                	mv	s10,s0
ffffffffc0204bfe:	f73788e3          	beq	a5,s3,ffffffffc0204b6e <vprintfmt+0x3a>
ffffffffc0204c02:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204c06:	1d7d                	addi	s10,s10,-1
ffffffffc0204c08:	ff379de3          	bne	a5,s3,ffffffffc0204c02 <vprintfmt+0xce>
ffffffffc0204c0c:	b78d                	j	ffffffffc0204b6e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204c0e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204c12:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c16:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204c18:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204c1c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c20:	02d86463          	bltu	a6,a3,ffffffffc0204c48 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204c24:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204c28:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204c2c:	0186873b          	addw	a4,a3,s8
ffffffffc0204c30:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204c34:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204c36:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204c3a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204c3c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204c40:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c44:	fed870e3          	bgeu	a6,a3,ffffffffc0204c24 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204c48:	f40ddce3          	bgez	s11,ffffffffc0204ba0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204c4c:	8de2                	mv	s11,s8
ffffffffc0204c4e:	5c7d                	li	s8,-1
ffffffffc0204c50:	bf81                	j	ffffffffc0204ba0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204c52:	fffdc693          	not	a3,s11
ffffffffc0204c56:	96fd                	srai	a3,a3,0x3f
ffffffffc0204c58:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c5c:	00144603          	lbu	a2,1(s0)
ffffffffc0204c60:	2d81                	sext.w	s11,s11
ffffffffc0204c62:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c64:	bf35                	j	ffffffffc0204ba0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204c66:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c6a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204c6e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c70:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204c72:	bfd9                	j	ffffffffc0204c48 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204c74:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c76:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c7a:	01174463          	blt	a4,a7,ffffffffc0204c82 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204c7e:	1a088e63          	beqz	a7,ffffffffc0204e3a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204c82:	000a3603          	ld	a2,0(s4)
ffffffffc0204c86:	46c1                	li	a3,16
ffffffffc0204c88:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c8a:	2781                	sext.w	a5,a5
ffffffffc0204c8c:	876e                	mv	a4,s11
ffffffffc0204c8e:	85a6                	mv	a1,s1
ffffffffc0204c90:	854a                	mv	a0,s2
ffffffffc0204c92:	e37ff0ef          	jal	ra,ffffffffc0204ac8 <printnum>
            break;
ffffffffc0204c96:	bde1                	j	ffffffffc0204b6e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204c98:	000a2503          	lw	a0,0(s4)
ffffffffc0204c9c:	85a6                	mv	a1,s1
ffffffffc0204c9e:	0a21                	addi	s4,s4,8
ffffffffc0204ca0:	9902                	jalr	s2
            break;
ffffffffc0204ca2:	b5f1                	j	ffffffffc0204b6e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204ca4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204ca6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204caa:	01174463          	blt	a4,a7,ffffffffc0204cb2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204cae:	18088163          	beqz	a7,ffffffffc0204e30 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204cb2:	000a3603          	ld	a2,0(s4)
ffffffffc0204cb6:	46a9                	li	a3,10
ffffffffc0204cb8:	8a2e                	mv	s4,a1
ffffffffc0204cba:	bfc1                	j	ffffffffc0204c8a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cbc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204cc0:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cc2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204cc4:	bdf1                	j	ffffffffc0204ba0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204cc6:	85a6                	mv	a1,s1
ffffffffc0204cc8:	02500513          	li	a0,37
ffffffffc0204ccc:	9902                	jalr	s2
            break;
ffffffffc0204cce:	b545                	j	ffffffffc0204b6e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cd0:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204cd4:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cd6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204cd8:	b5e1                	j	ffffffffc0204ba0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204cda:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204cdc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204ce0:	01174463          	blt	a4,a7,ffffffffc0204ce8 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204ce4:	14088163          	beqz	a7,ffffffffc0204e26 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204ce8:	000a3603          	ld	a2,0(s4)
ffffffffc0204cec:	46a1                	li	a3,8
ffffffffc0204cee:	8a2e                	mv	s4,a1
ffffffffc0204cf0:	bf69                	j	ffffffffc0204c8a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204cf2:	03000513          	li	a0,48
ffffffffc0204cf6:	85a6                	mv	a1,s1
ffffffffc0204cf8:	e03e                	sd	a5,0(sp)
ffffffffc0204cfa:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204cfc:	85a6                	mv	a1,s1
ffffffffc0204cfe:	07800513          	li	a0,120
ffffffffc0204d02:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204d04:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204d06:	6782                	ld	a5,0(sp)
ffffffffc0204d08:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204d0a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204d0e:	bfb5                	j	ffffffffc0204c8a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d10:	000a3403          	ld	s0,0(s4)
ffffffffc0204d14:	008a0713          	addi	a4,s4,8
ffffffffc0204d18:	e03a                	sd	a4,0(sp)
ffffffffc0204d1a:	14040263          	beqz	s0,ffffffffc0204e5e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204d1e:	0fb05763          	blez	s11,ffffffffc0204e0c <vprintfmt+0x2d8>
ffffffffc0204d22:	02d00693          	li	a3,45
ffffffffc0204d26:	0cd79163          	bne	a5,a3,ffffffffc0204de8 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d2a:	00044783          	lbu	a5,0(s0)
ffffffffc0204d2e:	0007851b          	sext.w	a0,a5
ffffffffc0204d32:	cf85                	beqz	a5,ffffffffc0204d6a <vprintfmt+0x236>
ffffffffc0204d34:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d38:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d3c:	000c4563          	bltz	s8,ffffffffc0204d46 <vprintfmt+0x212>
ffffffffc0204d40:	3c7d                	addiw	s8,s8,-1
ffffffffc0204d42:	036c0263          	beq	s8,s6,ffffffffc0204d66 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204d46:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d48:	0e0c8e63          	beqz	s9,ffffffffc0204e44 <vprintfmt+0x310>
ffffffffc0204d4c:	3781                	addiw	a5,a5,-32
ffffffffc0204d4e:	0ef47b63          	bgeu	s0,a5,ffffffffc0204e44 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204d52:	03f00513          	li	a0,63
ffffffffc0204d56:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d58:	000a4783          	lbu	a5,0(s4)
ffffffffc0204d5c:	3dfd                	addiw	s11,s11,-1
ffffffffc0204d5e:	0a05                	addi	s4,s4,1
ffffffffc0204d60:	0007851b          	sext.w	a0,a5
ffffffffc0204d64:	ffe1                	bnez	a5,ffffffffc0204d3c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204d66:	01b05963          	blez	s11,ffffffffc0204d78 <vprintfmt+0x244>
ffffffffc0204d6a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d6c:	85a6                	mv	a1,s1
ffffffffc0204d6e:	02000513          	li	a0,32
ffffffffc0204d72:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d74:	fe0d9be3          	bnez	s11,ffffffffc0204d6a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d78:	6a02                	ld	s4,0(sp)
ffffffffc0204d7a:	bbd5                	j	ffffffffc0204b6e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d7c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204d7e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204d82:	01174463          	blt	a4,a7,ffffffffc0204d8a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204d86:	08088d63          	beqz	a7,ffffffffc0204e20 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204d8a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204d8e:	0a044d63          	bltz	s0,ffffffffc0204e48 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204d92:	8622                	mv	a2,s0
ffffffffc0204d94:	8a66                	mv	s4,s9
ffffffffc0204d96:	46a9                	li	a3,10
ffffffffc0204d98:	bdcd                	j	ffffffffc0204c8a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204d9a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d9e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204da0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204da2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204da6:	8fb5                	xor	a5,a5,a3
ffffffffc0204da8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204dac:	02d74163          	blt	a4,a3,ffffffffc0204dce <vprintfmt+0x29a>
ffffffffc0204db0:	00369793          	slli	a5,a3,0x3
ffffffffc0204db4:	97de                	add	a5,a5,s7
ffffffffc0204db6:	639c                	ld	a5,0(a5)
ffffffffc0204db8:	cb99                	beqz	a5,ffffffffc0204dce <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204dba:	86be                	mv	a3,a5
ffffffffc0204dbc:	00000617          	auipc	a2,0x0
ffffffffc0204dc0:	1ec60613          	addi	a2,a2,492 # ffffffffc0204fa8 <etext+0x28>
ffffffffc0204dc4:	85a6                	mv	a1,s1
ffffffffc0204dc6:	854a                	mv	a0,s2
ffffffffc0204dc8:	0ce000ef          	jal	ra,ffffffffc0204e96 <printfmt>
ffffffffc0204dcc:	b34d                	j	ffffffffc0204b6e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204dce:	00002617          	auipc	a2,0x2
ffffffffc0204dd2:	01a60613          	addi	a2,a2,26 # ffffffffc0206de8 <default_pmm_manager+0x1118>
ffffffffc0204dd6:	85a6                	mv	a1,s1
ffffffffc0204dd8:	854a                	mv	a0,s2
ffffffffc0204dda:	0bc000ef          	jal	ra,ffffffffc0204e96 <printfmt>
ffffffffc0204dde:	bb41                	j	ffffffffc0204b6e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204de0:	00002417          	auipc	s0,0x2
ffffffffc0204de4:	00040413          	mv	s0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204de8:	85e2                	mv	a1,s8
ffffffffc0204dea:	8522                	mv	a0,s0
ffffffffc0204dec:	e43e                	sd	a5,8(sp)
ffffffffc0204dee:	0e2000ef          	jal	ra,ffffffffc0204ed0 <strnlen>
ffffffffc0204df2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204df6:	01b05b63          	blez	s11,ffffffffc0204e0c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204dfa:	67a2                	ld	a5,8(sp)
ffffffffc0204dfc:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e00:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204e02:	85a6                	mv	a1,s1
ffffffffc0204e04:	8552                	mv	a0,s4
ffffffffc0204e06:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e08:	fe0d9ce3          	bnez	s11,ffffffffc0204e00 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e0c:	00044783          	lbu	a5,0(s0) # ffffffffc0206de0 <default_pmm_manager+0x1110>
ffffffffc0204e10:	00140a13          	addi	s4,s0,1
ffffffffc0204e14:	0007851b          	sext.w	a0,a5
ffffffffc0204e18:	d3a5                	beqz	a5,ffffffffc0204d78 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e1a:	05e00413          	li	s0,94
ffffffffc0204e1e:	bf39                	j	ffffffffc0204d3c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204e20:	000a2403          	lw	s0,0(s4)
ffffffffc0204e24:	b7ad                	j	ffffffffc0204d8e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204e26:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e2a:	46a1                	li	a3,8
ffffffffc0204e2c:	8a2e                	mv	s4,a1
ffffffffc0204e2e:	bdb1                	j	ffffffffc0204c8a <vprintfmt+0x156>
ffffffffc0204e30:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e34:	46a9                	li	a3,10
ffffffffc0204e36:	8a2e                	mv	s4,a1
ffffffffc0204e38:	bd89                	j	ffffffffc0204c8a <vprintfmt+0x156>
ffffffffc0204e3a:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e3e:	46c1                	li	a3,16
ffffffffc0204e40:	8a2e                	mv	s4,a1
ffffffffc0204e42:	b5a1                	j	ffffffffc0204c8a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204e44:	9902                	jalr	s2
ffffffffc0204e46:	bf09                	j	ffffffffc0204d58 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204e48:	85a6                	mv	a1,s1
ffffffffc0204e4a:	02d00513          	li	a0,45
ffffffffc0204e4e:	e03e                	sd	a5,0(sp)
ffffffffc0204e50:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204e52:	6782                	ld	a5,0(sp)
ffffffffc0204e54:	8a66                	mv	s4,s9
ffffffffc0204e56:	40800633          	neg	a2,s0
ffffffffc0204e5a:	46a9                	li	a3,10
ffffffffc0204e5c:	b53d                	j	ffffffffc0204c8a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204e5e:	03b05163          	blez	s11,ffffffffc0204e80 <vprintfmt+0x34c>
ffffffffc0204e62:	02d00693          	li	a3,45
ffffffffc0204e66:	f6d79de3          	bne	a5,a3,ffffffffc0204de0 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204e6a:	00002417          	auipc	s0,0x2
ffffffffc0204e6e:	f7640413          	addi	s0,s0,-138 # ffffffffc0206de0 <default_pmm_manager+0x1110>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e72:	02800793          	li	a5,40
ffffffffc0204e76:	02800513          	li	a0,40
ffffffffc0204e7a:	00140a13          	addi	s4,s0,1
ffffffffc0204e7e:	bd6d                	j	ffffffffc0204d38 <vprintfmt+0x204>
ffffffffc0204e80:	00002a17          	auipc	s4,0x2
ffffffffc0204e84:	f61a0a13          	addi	s4,s4,-159 # ffffffffc0206de1 <default_pmm_manager+0x1111>
ffffffffc0204e88:	02800513          	li	a0,40
ffffffffc0204e8c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e90:	05e00413          	li	s0,94
ffffffffc0204e94:	b565                	j	ffffffffc0204d3c <vprintfmt+0x208>

ffffffffc0204e96 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e96:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e98:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e9c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e9e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204ea0:	ec06                	sd	ra,24(sp)
ffffffffc0204ea2:	f83a                	sd	a4,48(sp)
ffffffffc0204ea4:	fc3e                	sd	a5,56(sp)
ffffffffc0204ea6:	e0c2                	sd	a6,64(sp)
ffffffffc0204ea8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204eaa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204eac:	c89ff0ef          	jal	ra,ffffffffc0204b34 <vprintfmt>
}
ffffffffc0204eb0:	60e2                	ld	ra,24(sp)
ffffffffc0204eb2:	6161                	addi	sp,sp,80
ffffffffc0204eb4:	8082                	ret

ffffffffc0204eb6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204eb6:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204eba:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204ebc:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204ebe:	cb81                	beqz	a5,ffffffffc0204ece <strlen+0x18>
        cnt ++;
ffffffffc0204ec0:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204ec2:	00a707b3          	add	a5,a4,a0
ffffffffc0204ec6:	0007c783          	lbu	a5,0(a5)
ffffffffc0204eca:	fbfd                	bnez	a5,ffffffffc0204ec0 <strlen+0xa>
ffffffffc0204ecc:	8082                	ret
    }
    return cnt;
}
ffffffffc0204ece:	8082                	ret

ffffffffc0204ed0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204ed0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204ed2:	e589                	bnez	a1,ffffffffc0204edc <strnlen+0xc>
ffffffffc0204ed4:	a811                	j	ffffffffc0204ee8 <strnlen+0x18>
        cnt ++;
ffffffffc0204ed6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204ed8:	00f58863          	beq	a1,a5,ffffffffc0204ee8 <strnlen+0x18>
ffffffffc0204edc:	00f50733          	add	a4,a0,a5
ffffffffc0204ee0:	00074703          	lbu	a4,0(a4)
ffffffffc0204ee4:	fb6d                	bnez	a4,ffffffffc0204ed6 <strnlen+0x6>
ffffffffc0204ee6:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204ee8:	852e                	mv	a0,a1
ffffffffc0204eea:	8082                	ret

ffffffffc0204eec <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204eec:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204eee:	0005c703          	lbu	a4,0(a1)
ffffffffc0204ef2:	0785                	addi	a5,a5,1
ffffffffc0204ef4:	0585                	addi	a1,a1,1
ffffffffc0204ef6:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204efa:	fb75                	bnez	a4,ffffffffc0204eee <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204efc:	8082                	ret

ffffffffc0204efe <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204efe:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204f02:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204f06:	cb89                	beqz	a5,ffffffffc0204f18 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204f08:	0505                	addi	a0,a0,1
ffffffffc0204f0a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204f0c:	fee789e3          	beq	a5,a4,ffffffffc0204efe <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204f10:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204f14:	9d19                	subw	a0,a0,a4
ffffffffc0204f16:	8082                	ret
ffffffffc0204f18:	4501                	li	a0,0
ffffffffc0204f1a:	bfed                	j	ffffffffc0204f14 <strcmp+0x16>

ffffffffc0204f1c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204f1c:	00054783          	lbu	a5,0(a0)
ffffffffc0204f20:	c799                	beqz	a5,ffffffffc0204f2e <strchr+0x12>
        if (*s == c) {
ffffffffc0204f22:	00f58763          	beq	a1,a5,ffffffffc0204f30 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204f26:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204f2a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204f2c:	fbfd                	bnez	a5,ffffffffc0204f22 <strchr+0x6>
    }
    return NULL;
ffffffffc0204f2e:	4501                	li	a0,0
}
ffffffffc0204f30:	8082                	ret

ffffffffc0204f32 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204f32:	ca01                	beqz	a2,ffffffffc0204f42 <memset+0x10>
ffffffffc0204f34:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204f36:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204f38:	0785                	addi	a5,a5,1
ffffffffc0204f3a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204f3e:	fec79de3          	bne	a5,a2,ffffffffc0204f38 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204f42:	8082                	ret

ffffffffc0204f44 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204f44:	ca19                	beqz	a2,ffffffffc0204f5a <memcpy+0x16>
ffffffffc0204f46:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204f48:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204f4a:	0005c703          	lbu	a4,0(a1)
ffffffffc0204f4e:	0585                	addi	a1,a1,1
ffffffffc0204f50:	0785                	addi	a5,a5,1
ffffffffc0204f52:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204f56:	fec59ae3          	bne	a1,a2,ffffffffc0204f4a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204f5a:	8082                	ret

ffffffffc0204f5c <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204f5c:	c205                	beqz	a2,ffffffffc0204f7c <memcmp+0x20>
ffffffffc0204f5e:	962e                	add	a2,a2,a1
ffffffffc0204f60:	a019                	j	ffffffffc0204f66 <memcmp+0xa>
ffffffffc0204f62:	00c58d63          	beq	a1,a2,ffffffffc0204f7c <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0204f66:	00054783          	lbu	a5,0(a0)
ffffffffc0204f6a:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204f6e:	0505                	addi	a0,a0,1
ffffffffc0204f70:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0204f72:	fee788e3          	beq	a5,a4,ffffffffc0204f62 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204f76:	40e7853b          	subw	a0,a5,a4
ffffffffc0204f7a:	8082                	ret
    }
    return 0;
ffffffffc0204f7c:	4501                	li	a0,0
}
ffffffffc0204f7e:	8082                	ret
