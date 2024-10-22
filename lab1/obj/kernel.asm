
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
    8020001a:	1141                	addi	sp,sp,-16
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
    80200020:	e406                	sd	ra,8(sp)
    80200022:	1f9000ef          	jal	ra,80200a1a <memset>
    80200026:	154000ef          	jal	ra,8020017a <cons_init>
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a0658593          	addi	a1,a1,-1530 # 80200a30 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a1e50513          	addi	a0,a0,-1506 # 80200a50 <etext+0x24>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>
    80200042:	148000ef          	jal	ra,8020018a <idt_init>
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>
    8020004a:	13a000ef          	jal	ra,80200184 <intr_enable>
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    80200058:	124000ef          	jal	ra,8020017c <cons_putc>
    8020005c:	401c                	lw	a5,0(s0)
    8020005e:	60a2                	ld	ra,8(sp)
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
    8020006a:	711d                	addi	sp,sp,-96
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    80200090:	e41a                	sd	t1,8(sp)
    80200092:	c202                	sw	zero,4(sp)
    80200094:	59a000ef          	jal	ra,8020062e <vprintfmt>
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
    802000a0:	1141                	addi	sp,sp,-16
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9b650513          	addi	a0,a0,-1610 # 80200a58 <etext+0x2c>
    802000aa:	e406                	sd	ra,8(sp)
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9c050513          	addi	a0,a0,-1600 # 80200a78 <etext+0x4c>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	96858593          	addi	a1,a1,-1688 # 80200a2c <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9cc50513          	addi	a0,a0,-1588 # 80200a98 <etext+0x6c>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9d850513          	addi	a0,a0,-1576 # 80200ab8 <etext+0x8c>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9e450513          	addi	a0,a0,-1564 # 80200ad8 <etext+0xac>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    80200114:	43f7d593          	srai	a1,a5,0x3f
    80200118:	60a2                	ld	ra,8(sp)
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9d650513          	addi	a0,a0,-1578 # 80200af8 <etext+0xcc>
    8020012a:	0141                	addi	sp,sp,16
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    8020013a:	c0102573          	rdtime	a0
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	085000ef          	jal	ra,802009ca <sbi_set_timer>
    8020014a:	00001517          	auipc	a0,0x1
    8020014e:	9de50513          	addi	a0,a0,-1570 # 80200b28 <etext+0xfc>
    80200152:	00004797          	auipc	a5,0x4
    80200156:	ea07bf23          	sd	zero,-322(a5) # 80204010 <ticks>
    8020015a:	f11ff0ef          	jal	ra,8020006a <cprintf>
    8020015e:	30200073          	mret
    80200162:	9002                	ebreak
    80200164:	60a2                	ld	ra,8(sp)
    80200166:	0141                	addi	sp,sp,16
    80200168:	8082                	ret

000000008020016a <clock_set_next_event>:
    8020016a:	c0102573          	rdtime	a0
    8020016e:	67e1                	lui	a5,0x18
    80200170:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200174:	953e                	add	a0,a0,a5
    80200176:	0550006f          	j	802009ca <sbi_set_timer>

000000008020017a <cons_init>:
    8020017a:	8082                	ret

000000008020017c <cons_putc>:
    8020017c:	0ff57513          	zext.b	a0,a0
    80200180:	0310006f          	j	802009b0 <sbi_console_putchar>

0000000080200184 <intr_enable>:
    80200184:	100167f3          	csrrsi	a5,sstatus,2
    80200188:	8082                	ret

000000008020018a <idt_init>:
    8020018a:	14005073          	csrwi	sscratch,0
    8020018e:	00000797          	auipc	a5,0x0
    80200192:	37e78793          	addi	a5,a5,894 # 8020050c <__alltraps>
    80200196:	10579073          	csrw	stvec,a5
    8020019a:	8082                	ret

000000008020019c <print_regs>:
    8020019c:	610c                	ld	a1,0(a0)
    8020019e:	1141                	addi	sp,sp,-16
    802001a0:	e022                	sd	s0,0(sp)
    802001a2:	842a                	mv	s0,a0
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	9a450513          	addi	a0,a0,-1628 # 80200b48 <etext+0x11c>
    802001ac:	e406                	sd	ra,8(sp)
    802001ae:	ebdff0ef          	jal	ra,8020006a <cprintf>
    802001b2:	640c                	ld	a1,8(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	9ac50513          	addi	a0,a0,-1620 # 80200b60 <etext+0x134>
    802001bc:	eafff0ef          	jal	ra,8020006a <cprintf>
    802001c0:	680c                	ld	a1,16(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	9b650513          	addi	a0,a0,-1610 # 80200b78 <etext+0x14c>
    802001ca:	ea1ff0ef          	jal	ra,8020006a <cprintf>
    802001ce:	6c0c                	ld	a1,24(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	9c050513          	addi	a0,a0,-1600 # 80200b90 <etext+0x164>
    802001d8:	e93ff0ef          	jal	ra,8020006a <cprintf>
    802001dc:	700c                	ld	a1,32(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	9ca50513          	addi	a0,a0,-1590 # 80200ba8 <etext+0x17c>
    802001e6:	e85ff0ef          	jal	ra,8020006a <cprintf>
    802001ea:	740c                	ld	a1,40(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	9d450513          	addi	a0,a0,-1580 # 80200bc0 <etext+0x194>
    802001f4:	e77ff0ef          	jal	ra,8020006a <cprintf>
    802001f8:	780c                	ld	a1,48(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	9de50513          	addi	a0,a0,-1570 # 80200bd8 <etext+0x1ac>
    80200202:	e69ff0ef          	jal	ra,8020006a <cprintf>
    80200206:	7c0c                	ld	a1,56(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	9e850513          	addi	a0,a0,-1560 # 80200bf0 <etext+0x1c4>
    80200210:	e5bff0ef          	jal	ra,8020006a <cprintf>
    80200214:	602c                	ld	a1,64(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	9f250513          	addi	a0,a0,-1550 # 80200c08 <etext+0x1dc>
    8020021e:	e4dff0ef          	jal	ra,8020006a <cprintf>
    80200222:	642c                	ld	a1,72(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	9fc50513          	addi	a0,a0,-1540 # 80200c20 <etext+0x1f4>
    8020022c:	e3fff0ef          	jal	ra,8020006a <cprintf>
    80200230:	682c                	ld	a1,80(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	a0650513          	addi	a0,a0,-1530 # 80200c38 <etext+0x20c>
    8020023a:	e31ff0ef          	jal	ra,8020006a <cprintf>
    8020023e:	6c2c                	ld	a1,88(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	a1050513          	addi	a0,a0,-1520 # 80200c50 <etext+0x224>
    80200248:	e23ff0ef          	jal	ra,8020006a <cprintf>
    8020024c:	702c                	ld	a1,96(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	a1a50513          	addi	a0,a0,-1510 # 80200c68 <etext+0x23c>
    80200256:	e15ff0ef          	jal	ra,8020006a <cprintf>
    8020025a:	742c                	ld	a1,104(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	a2450513          	addi	a0,a0,-1500 # 80200c80 <etext+0x254>
    80200264:	e07ff0ef          	jal	ra,8020006a <cprintf>
    80200268:	782c                	ld	a1,112(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	a2e50513          	addi	a0,a0,-1490 # 80200c98 <etext+0x26c>
    80200272:	df9ff0ef          	jal	ra,8020006a <cprintf>
    80200276:	7c2c                	ld	a1,120(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	a3850513          	addi	a0,a0,-1480 # 80200cb0 <etext+0x284>
    80200280:	debff0ef          	jal	ra,8020006a <cprintf>
    80200284:	604c                	ld	a1,128(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	a4250513          	addi	a0,a0,-1470 # 80200cc8 <etext+0x29c>
    8020028e:	dddff0ef          	jal	ra,8020006a <cprintf>
    80200292:	644c                	ld	a1,136(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	a4c50513          	addi	a0,a0,-1460 # 80200ce0 <etext+0x2b4>
    8020029c:	dcfff0ef          	jal	ra,8020006a <cprintf>
    802002a0:	684c                	ld	a1,144(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	a5650513          	addi	a0,a0,-1450 # 80200cf8 <etext+0x2cc>
    802002aa:	dc1ff0ef          	jal	ra,8020006a <cprintf>
    802002ae:	6c4c                	ld	a1,152(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	a6050513          	addi	a0,a0,-1440 # 80200d10 <etext+0x2e4>
    802002b8:	db3ff0ef          	jal	ra,8020006a <cprintf>
    802002bc:	704c                	ld	a1,160(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	a6a50513          	addi	a0,a0,-1430 # 80200d28 <etext+0x2fc>
    802002c6:	da5ff0ef          	jal	ra,8020006a <cprintf>
    802002ca:	744c                	ld	a1,168(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	a7450513          	addi	a0,a0,-1420 # 80200d40 <etext+0x314>
    802002d4:	d97ff0ef          	jal	ra,8020006a <cprintf>
    802002d8:	784c                	ld	a1,176(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	a7e50513          	addi	a0,a0,-1410 # 80200d58 <etext+0x32c>
    802002e2:	d89ff0ef          	jal	ra,8020006a <cprintf>
    802002e6:	7c4c                	ld	a1,184(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	a8850513          	addi	a0,a0,-1400 # 80200d70 <etext+0x344>
    802002f0:	d7bff0ef          	jal	ra,8020006a <cprintf>
    802002f4:	606c                	ld	a1,192(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	a9250513          	addi	a0,a0,-1390 # 80200d88 <etext+0x35c>
    802002fe:	d6dff0ef          	jal	ra,8020006a <cprintf>
    80200302:	646c                	ld	a1,200(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	a9c50513          	addi	a0,a0,-1380 # 80200da0 <etext+0x374>
    8020030c:	d5fff0ef          	jal	ra,8020006a <cprintf>
    80200310:	686c                	ld	a1,208(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	aa650513          	addi	a0,a0,-1370 # 80200db8 <etext+0x38c>
    8020031a:	d51ff0ef          	jal	ra,8020006a <cprintf>
    8020031e:	6c6c                	ld	a1,216(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	ab050513          	addi	a0,a0,-1360 # 80200dd0 <etext+0x3a4>
    80200328:	d43ff0ef          	jal	ra,8020006a <cprintf>
    8020032c:	706c                	ld	a1,224(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	aba50513          	addi	a0,a0,-1350 # 80200de8 <etext+0x3bc>
    80200336:	d35ff0ef          	jal	ra,8020006a <cprintf>
    8020033a:	746c                	ld	a1,232(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	ac450513          	addi	a0,a0,-1340 # 80200e00 <etext+0x3d4>
    80200344:	d27ff0ef          	jal	ra,8020006a <cprintf>
    80200348:	786c                	ld	a1,240(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	ace50513          	addi	a0,a0,-1330 # 80200e18 <etext+0x3ec>
    80200352:	d19ff0ef          	jal	ra,8020006a <cprintf>
    80200356:	7c6c                	ld	a1,248(s0)
    80200358:	6402                	ld	s0,0(sp)
    8020035a:	60a2                	ld	ra,8(sp)
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	ad450513          	addi	a0,a0,-1324 # 80200e30 <etext+0x404>
    80200364:	0141                	addi	sp,sp,16
    80200366:	b311                	j	8020006a <cprintf>

0000000080200368 <print_trapframe>:
    80200368:	1141                	addi	sp,sp,-16
    8020036a:	e022                	sd	s0,0(sp)
    8020036c:	85aa                	mv	a1,a0
    8020036e:	842a                	mv	s0,a0
    80200370:	00001517          	auipc	a0,0x1
    80200374:	ad850513          	addi	a0,a0,-1320 # 80200e48 <etext+0x41c>
    80200378:	e406                	sd	ra,8(sp)
    8020037a:	cf1ff0ef          	jal	ra,8020006a <cprintf>
    8020037e:	8522                	mv	a0,s0
    80200380:	e1dff0ef          	jal	ra,8020019c <print_regs>
    80200384:	10043583          	ld	a1,256(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	ad850513          	addi	a0,a0,-1320 # 80200e60 <etext+0x434>
    80200390:	cdbff0ef          	jal	ra,8020006a <cprintf>
    80200394:	10843583          	ld	a1,264(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	ae050513          	addi	a0,a0,-1312 # 80200e78 <etext+0x44c>
    802003a0:	ccbff0ef          	jal	ra,8020006a <cprintf>
    802003a4:	11043583          	ld	a1,272(s0)
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	ae850513          	addi	a0,a0,-1304 # 80200e90 <etext+0x464>
    802003b0:	cbbff0ef          	jal	ra,8020006a <cprintf>
    802003b4:	11843583          	ld	a1,280(s0)
    802003b8:	6402                	ld	s0,0(sp)
    802003ba:	60a2                	ld	ra,8(sp)
    802003bc:	00001517          	auipc	a0,0x1
    802003c0:	aec50513          	addi	a0,a0,-1300 # 80200ea8 <etext+0x47c>
    802003c4:	0141                	addi	sp,sp,16
    802003c6:	b155                	j	8020006a <cprintf>

00000000802003c8 <interrupt_handler>:
    802003c8:	11853783          	ld	a5,280(a0)
    802003cc:	472d                	li	a4,11
    802003ce:	0786                	slli	a5,a5,0x1
    802003d0:	8385                	srli	a5,a5,0x1
    802003d2:	08f76163          	bltu	a4,a5,80200454 <interrupt_handler+0x8c>
    802003d6:	00001717          	auipc	a4,0x1
    802003da:	b9a70713          	addi	a4,a4,-1126 # 80200f70 <etext+0x544>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	b3850513          	addi	a0,a0,-1224 # 80200f20 <etext+0x4f4>
    802003f0:	b9ad                	j	8020006a <cprintf>
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	b0e50513          	addi	a0,a0,-1266 # 80200f00 <etext+0x4d4>
    802003fa:	b985                	j	8020006a <cprintf>
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	ac450513          	addi	a0,a0,-1340 # 80200ec0 <etext+0x494>
    80200404:	b19d                	j	8020006a <cprintf>
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	ada50513          	addi	a0,a0,-1318 # 80200ee0 <etext+0x4b4>
    8020040e:	b9b1                	j	8020006a <cprintf>
    80200410:	1141                	addi	sp,sp,-16
    80200412:	e022                	sd	s0,0(sp)
    80200414:	e406                	sd	ra,8(sp)
    80200416:	d55ff0ef          	jal	ra,8020016a <clock_set_next_event>
    8020041a:	00004697          	auipc	a3,0x4
    8020041e:	bf668693          	addi	a3,a3,-1034 # 80204010 <ticks>
    80200422:	629c                	ld	a5,0(a3)
    80200424:	06400713          	li	a4,100
    80200428:	00004417          	auipc	s0,0x4
    8020042c:	bf040413          	addi	s0,s0,-1040 # 80204018 <num>
    80200430:	0785                	addi	a5,a5,1
    80200432:	02e7f733          	remu	a4,a5,a4
    80200436:	e29c                	sd	a5,0(a3)
    80200438:	cf19                	beqz	a4,80200456 <interrupt_handler+0x8e>
    8020043a:	6018                	ld	a4,0(s0)
    8020043c:	47a9                	li	a5,10
    8020043e:	02f70863          	beq	a4,a5,8020046e <interrupt_handler+0xa6>
    80200442:	60a2                	ld	ra,8(sp)
    80200444:	6402                	ld	s0,0(sp)
    80200446:	0141                	addi	sp,sp,16
    80200448:	8082                	ret
    8020044a:	00001517          	auipc	a0,0x1
    8020044e:	b0650513          	addi	a0,a0,-1274 # 80200f50 <etext+0x524>
    80200452:	b921                	j	8020006a <cprintf>
    80200454:	bf11                	j	80200368 <print_trapframe>
    80200456:	06400593          	li	a1,100
    8020045a:	00001517          	auipc	a0,0x1
    8020045e:	ae650513          	addi	a0,a0,-1306 # 80200f40 <etext+0x514>
    80200462:	c09ff0ef          	jal	ra,8020006a <cprintf>
    80200466:	601c                	ld	a5,0(s0)
    80200468:	0785                	addi	a5,a5,1
    8020046a:	e01c                	sd	a5,0(s0)
    8020046c:	b7f9                	j	8020043a <interrupt_handler+0x72>
    8020046e:	6402                	ld	s0,0(sp)
    80200470:	60a2                	ld	ra,8(sp)
    80200472:	0141                	addi	sp,sp,16
    80200474:	ab85                	j	802009e4 <sbi_shutdown>

0000000080200476 <exception_handler>:
    80200476:	11853783          	ld	a5,280(a0)
    8020047a:	1141                	addi	sp,sp,-16
    8020047c:	e022                	sd	s0,0(sp)
    8020047e:	e406                	sd	ra,8(sp)
    80200480:	470d                	li	a4,3
    80200482:	842a                	mv	s0,a0
    80200484:	04e78663          	beq	a5,a4,802004d0 <exception_handler+0x5a>
    80200488:	02f76c63          	bltu	a4,a5,802004c0 <exception_handler+0x4a>
    8020048c:	4709                	li	a4,2
    8020048e:	02e79563          	bne	a5,a4,802004b8 <exception_handler+0x42>
    80200492:	00001517          	auipc	a0,0x1
    80200496:	b0e50513          	addi	a0,a0,-1266 # 80200fa0 <etext+0x574>
    8020049a:	bd1ff0ef          	jal	ra,8020006a <cprintf>
    8020049e:	10843583          	ld	a1,264(s0)
    802004a2:	00001517          	auipc	a0,0x1
    802004a6:	b2650513          	addi	a0,a0,-1242 # 80200fc8 <etext+0x59c>
    802004aa:	bc1ff0ef          	jal	ra,8020006a <cprintf>
    802004ae:	10843783          	ld	a5,264(s0)
    802004b2:	0791                	addi	a5,a5,4
    802004b4:	10f43423          	sd	a5,264(s0)
    802004b8:	60a2                	ld	ra,8(sp)
    802004ba:	6402                	ld	s0,0(sp)
    802004bc:	0141                	addi	sp,sp,16
    802004be:	8082                	ret
    802004c0:	17f1                	addi	a5,a5,-4
    802004c2:	471d                	li	a4,7
    802004c4:	fef77ae3          	bgeu	a4,a5,802004b8 <exception_handler+0x42>
    802004c8:	6402                	ld	s0,0(sp)
    802004ca:	60a2                	ld	ra,8(sp)
    802004cc:	0141                	addi	sp,sp,16
    802004ce:	bd69                	j	80200368 <print_trapframe>
    802004d0:	00001517          	auipc	a0,0x1
    802004d4:	b2050513          	addi	a0,a0,-1248 # 80200ff0 <etext+0x5c4>
    802004d8:	b93ff0ef          	jal	ra,8020006a <cprintf>
    802004dc:	10843583          	ld	a1,264(s0)
    802004e0:	00001517          	auipc	a0,0x1
    802004e4:	b3050513          	addi	a0,a0,-1232 # 80201010 <etext+0x5e4>
    802004e8:	b83ff0ef          	jal	ra,8020006a <cprintf>
    802004ec:	10843783          	ld	a5,264(s0)
    802004f0:	60a2                	ld	ra,8(sp)
    802004f2:	0789                	addi	a5,a5,2
    802004f4:	10f43423          	sd	a5,264(s0)
    802004f8:	6402                	ld	s0,0(sp)
    802004fa:	0141                	addi	sp,sp,16
    802004fc:	8082                	ret

00000000802004fe <trap>:
    802004fe:	11853783          	ld	a5,280(a0)
    80200502:	0007c363          	bltz	a5,80200508 <trap+0xa>
    80200506:	bf85                	j	80200476 <exception_handler>
    80200508:	b5c1                	j	802003c8 <interrupt_handler>
	...

000000008020050c <__alltraps>:
    8020050c:	14011073          	csrw	sscratch,sp
    80200510:	712d                	addi	sp,sp,-288
    80200512:	e002                	sd	zero,0(sp)
    80200514:	e406                	sd	ra,8(sp)
    80200516:	ec0e                	sd	gp,24(sp)
    80200518:	f012                	sd	tp,32(sp)
    8020051a:	f416                	sd	t0,40(sp)
    8020051c:	f81a                	sd	t1,48(sp)
    8020051e:	fc1e                	sd	t2,56(sp)
    80200520:	e0a2                	sd	s0,64(sp)
    80200522:	e4a6                	sd	s1,72(sp)
    80200524:	e8aa                	sd	a0,80(sp)
    80200526:	ecae                	sd	a1,88(sp)
    80200528:	f0b2                	sd	a2,96(sp)
    8020052a:	f4b6                	sd	a3,104(sp)
    8020052c:	f8ba                	sd	a4,112(sp)
    8020052e:	fcbe                	sd	a5,120(sp)
    80200530:	e142                	sd	a6,128(sp)
    80200532:	e546                	sd	a7,136(sp)
    80200534:	e94a                	sd	s2,144(sp)
    80200536:	ed4e                	sd	s3,152(sp)
    80200538:	f152                	sd	s4,160(sp)
    8020053a:	f556                	sd	s5,168(sp)
    8020053c:	f95a                	sd	s6,176(sp)
    8020053e:	fd5e                	sd	s7,184(sp)
    80200540:	e1e2                	sd	s8,192(sp)
    80200542:	e5e6                	sd	s9,200(sp)
    80200544:	e9ea                	sd	s10,208(sp)
    80200546:	edee                	sd	s11,216(sp)
    80200548:	f1f2                	sd	t3,224(sp)
    8020054a:	f5f6                	sd	t4,232(sp)
    8020054c:	f9fa                	sd	t5,240(sp)
    8020054e:	fdfe                	sd	t6,248(sp)
    80200550:	14001473          	csrrw	s0,sscratch,zero
    80200554:	100024f3          	csrr	s1,sstatus
    80200558:	14102973          	csrr	s2,sepc
    8020055c:	143029f3          	csrr	s3,stval
    80200560:	14202a73          	csrr	s4,scause
    80200564:	e822                	sd	s0,16(sp)
    80200566:	e226                	sd	s1,256(sp)
    80200568:	e64a                	sd	s2,264(sp)
    8020056a:	ea4e                	sd	s3,272(sp)
    8020056c:	ee52                	sd	s4,280(sp)
    8020056e:	850a                	mv	a0,sp
    80200570:	f8fff0ef          	jal	ra,802004fe <trap>

0000000080200574 <__trapret>:
    80200574:	6492                	ld	s1,256(sp)
    80200576:	6932                	ld	s2,264(sp)
    80200578:	10049073          	csrw	sstatus,s1
    8020057c:	14191073          	csrw	sepc,s2
    80200580:	60a2                	ld	ra,8(sp)
    80200582:	61e2                	ld	gp,24(sp)
    80200584:	7202                	ld	tp,32(sp)
    80200586:	72a2                	ld	t0,40(sp)
    80200588:	7342                	ld	t1,48(sp)
    8020058a:	73e2                	ld	t2,56(sp)
    8020058c:	6406                	ld	s0,64(sp)
    8020058e:	64a6                	ld	s1,72(sp)
    80200590:	6546                	ld	a0,80(sp)
    80200592:	65e6                	ld	a1,88(sp)
    80200594:	7606                	ld	a2,96(sp)
    80200596:	76a6                	ld	a3,104(sp)
    80200598:	7746                	ld	a4,112(sp)
    8020059a:	77e6                	ld	a5,120(sp)
    8020059c:	680a                	ld	a6,128(sp)
    8020059e:	68aa                	ld	a7,136(sp)
    802005a0:	694a                	ld	s2,144(sp)
    802005a2:	69ea                	ld	s3,152(sp)
    802005a4:	7a0a                	ld	s4,160(sp)
    802005a6:	7aaa                	ld	s5,168(sp)
    802005a8:	7b4a                	ld	s6,176(sp)
    802005aa:	7bea                	ld	s7,184(sp)
    802005ac:	6c0e                	ld	s8,192(sp)
    802005ae:	6cae                	ld	s9,200(sp)
    802005b0:	6d4e                	ld	s10,208(sp)
    802005b2:	6dee                	ld	s11,216(sp)
    802005b4:	7e0e                	ld	t3,224(sp)
    802005b6:	7eae                	ld	t4,232(sp)
    802005b8:	7f4e                	ld	t5,240(sp)
    802005ba:	7fee                	ld	t6,248(sp)
    802005bc:	6142                	ld	sp,16(sp)
    802005be:	10200073          	sret

00000000802005c2 <printnum>:
    802005c2:	02069813          	slli	a6,a3,0x20
    802005c6:	7179                	addi	sp,sp,-48
    802005c8:	02085813          	srli	a6,a6,0x20
    802005cc:	e052                	sd	s4,0(sp)
    802005ce:	03067a33          	remu	s4,a2,a6
    802005d2:	f022                	sd	s0,32(sp)
    802005d4:	ec26                	sd	s1,24(sp)
    802005d6:	e84a                	sd	s2,16(sp)
    802005d8:	f406                	sd	ra,40(sp)
    802005da:	e44e                	sd	s3,8(sp)
    802005dc:	84aa                	mv	s1,a0
    802005de:	892e                	mv	s2,a1
    802005e0:	fff7041b          	addiw	s0,a4,-1
    802005e4:	2a01                	sext.w	s4,s4
    802005e6:	03067e63          	bgeu	a2,a6,80200622 <printnum+0x60>
    802005ea:	89be                	mv	s3,a5
    802005ec:	00805763          	blez	s0,802005fa <printnum+0x38>
    802005f0:	347d                	addiw	s0,s0,-1
    802005f2:	85ca                	mv	a1,s2
    802005f4:	854e                	mv	a0,s3
    802005f6:	9482                	jalr	s1
    802005f8:	fc65                	bnez	s0,802005f0 <printnum+0x2e>
    802005fa:	1a02                	slli	s4,s4,0x20
    802005fc:	00001797          	auipc	a5,0x1
    80200600:	a3478793          	addi	a5,a5,-1484 # 80201030 <etext+0x604>
    80200604:	020a5a13          	srli	s4,s4,0x20
    80200608:	9a3e                	add	s4,s4,a5
    8020060a:	7402                	ld	s0,32(sp)
    8020060c:	000a4503          	lbu	a0,0(s4)
    80200610:	70a2                	ld	ra,40(sp)
    80200612:	69a2                	ld	s3,8(sp)
    80200614:	6a02                	ld	s4,0(sp)
    80200616:	85ca                	mv	a1,s2
    80200618:	87a6                	mv	a5,s1
    8020061a:	6942                	ld	s2,16(sp)
    8020061c:	64e2                	ld	s1,24(sp)
    8020061e:	6145                	addi	sp,sp,48
    80200620:	8782                	jr	a5
    80200622:	03065633          	divu	a2,a2,a6
    80200626:	8722                	mv	a4,s0
    80200628:	f9bff0ef          	jal	ra,802005c2 <printnum>
    8020062c:	b7f9                	j	802005fa <printnum+0x38>

000000008020062e <vprintfmt>:
    8020062e:	7119                	addi	sp,sp,-128
    80200630:	f4a6                	sd	s1,104(sp)
    80200632:	f0ca                	sd	s2,96(sp)
    80200634:	ecce                	sd	s3,88(sp)
    80200636:	e8d2                	sd	s4,80(sp)
    80200638:	e4d6                	sd	s5,72(sp)
    8020063a:	e0da                	sd	s6,64(sp)
    8020063c:	fc5e                	sd	s7,56(sp)
    8020063e:	f06a                	sd	s10,32(sp)
    80200640:	fc86                	sd	ra,120(sp)
    80200642:	f8a2                	sd	s0,112(sp)
    80200644:	f862                	sd	s8,48(sp)
    80200646:	f466                	sd	s9,40(sp)
    80200648:	ec6e                	sd	s11,24(sp)
    8020064a:	892a                	mv	s2,a0
    8020064c:	84ae                	mv	s1,a1
    8020064e:	8d32                	mv	s10,a2
    80200650:	8a36                	mv	s4,a3
    80200652:	02500993          	li	s3,37
    80200656:	5b7d                	li	s6,-1
    80200658:	00001a97          	auipc	s5,0x1
    8020065c:	a0ca8a93          	addi	s5,s5,-1524 # 80201064 <etext+0x638>
    80200660:	00001b97          	auipc	s7,0x1
    80200664:	be0b8b93          	addi	s7,s7,-1056 # 80201240 <error_string>
    80200668:	000d4503          	lbu	a0,0(s10)
    8020066c:	001d0413          	addi	s0,s10,1
    80200670:	01350a63          	beq	a0,s3,80200684 <vprintfmt+0x56>
    80200674:	c121                	beqz	a0,802006b4 <vprintfmt+0x86>
    80200676:	85a6                	mv	a1,s1
    80200678:	0405                	addi	s0,s0,1
    8020067a:	9902                	jalr	s2
    8020067c:	fff44503          	lbu	a0,-1(s0)
    80200680:	ff351ae3          	bne	a0,s3,80200674 <vprintfmt+0x46>
    80200684:	00044603          	lbu	a2,0(s0)
    80200688:	02000793          	li	a5,32
    8020068c:	4c81                	li	s9,0
    8020068e:	4881                	li	a7,0
    80200690:	5c7d                	li	s8,-1
    80200692:	5dfd                	li	s11,-1
    80200694:	05500513          	li	a0,85
    80200698:	4825                	li	a6,9
    8020069a:	fdd6059b          	addiw	a1,a2,-35
    8020069e:	0ff5f593          	zext.b	a1,a1
    802006a2:	00140d13          	addi	s10,s0,1
    802006a6:	04b56263          	bltu	a0,a1,802006ea <vprintfmt+0xbc>
    802006aa:	058a                	slli	a1,a1,0x2
    802006ac:	95d6                	add	a1,a1,s5
    802006ae:	4194                	lw	a3,0(a1)
    802006b0:	96d6                	add	a3,a3,s5
    802006b2:	8682                	jr	a3
    802006b4:	70e6                	ld	ra,120(sp)
    802006b6:	7446                	ld	s0,112(sp)
    802006b8:	74a6                	ld	s1,104(sp)
    802006ba:	7906                	ld	s2,96(sp)
    802006bc:	69e6                	ld	s3,88(sp)
    802006be:	6a46                	ld	s4,80(sp)
    802006c0:	6aa6                	ld	s5,72(sp)
    802006c2:	6b06                	ld	s6,64(sp)
    802006c4:	7be2                	ld	s7,56(sp)
    802006c6:	7c42                	ld	s8,48(sp)
    802006c8:	7ca2                	ld	s9,40(sp)
    802006ca:	7d02                	ld	s10,32(sp)
    802006cc:	6de2                	ld	s11,24(sp)
    802006ce:	6109                	addi	sp,sp,128
    802006d0:	8082                	ret
    802006d2:	87b2                	mv	a5,a2
    802006d4:	00144603          	lbu	a2,1(s0)
    802006d8:	846a                	mv	s0,s10
    802006da:	00140d13          	addi	s10,s0,1
    802006de:	fdd6059b          	addiw	a1,a2,-35
    802006e2:	0ff5f593          	zext.b	a1,a1
    802006e6:	fcb572e3          	bgeu	a0,a1,802006aa <vprintfmt+0x7c>
    802006ea:	85a6                	mv	a1,s1
    802006ec:	02500513          	li	a0,37
    802006f0:	9902                	jalr	s2
    802006f2:	fff44783          	lbu	a5,-1(s0)
    802006f6:	8d22                	mv	s10,s0
    802006f8:	f73788e3          	beq	a5,s3,80200668 <vprintfmt+0x3a>
    802006fc:	ffed4783          	lbu	a5,-2(s10)
    80200700:	1d7d                	addi	s10,s10,-1
    80200702:	ff379de3          	bne	a5,s3,802006fc <vprintfmt+0xce>
    80200706:	b78d                	j	80200668 <vprintfmt+0x3a>
    80200708:	fd060c1b          	addiw	s8,a2,-48
    8020070c:	00144603          	lbu	a2,1(s0)
    80200710:	846a                	mv	s0,s10
    80200712:	fd06069b          	addiw	a3,a2,-48
    80200716:	0006059b          	sext.w	a1,a2
    8020071a:	02d86463          	bltu	a6,a3,80200742 <vprintfmt+0x114>
    8020071e:	00144603          	lbu	a2,1(s0)
    80200722:	002c169b          	slliw	a3,s8,0x2
    80200726:	0186873b          	addw	a4,a3,s8
    8020072a:	0017171b          	slliw	a4,a4,0x1
    8020072e:	9f2d                	addw	a4,a4,a1
    80200730:	fd06069b          	addiw	a3,a2,-48
    80200734:	0405                	addi	s0,s0,1
    80200736:	fd070c1b          	addiw	s8,a4,-48
    8020073a:	0006059b          	sext.w	a1,a2
    8020073e:	fed870e3          	bgeu	a6,a3,8020071e <vprintfmt+0xf0>
    80200742:	f40ddce3          	bgez	s11,8020069a <vprintfmt+0x6c>
    80200746:	8de2                	mv	s11,s8
    80200748:	5c7d                	li	s8,-1
    8020074a:	bf81                	j	8020069a <vprintfmt+0x6c>
    8020074c:	fffdc693          	not	a3,s11
    80200750:	96fd                	srai	a3,a3,0x3f
    80200752:	00ddfdb3          	and	s11,s11,a3
    80200756:	00144603          	lbu	a2,1(s0)
    8020075a:	2d81                	sext.w	s11,s11
    8020075c:	846a                	mv	s0,s10
    8020075e:	bf35                	j	8020069a <vprintfmt+0x6c>
    80200760:	000a2c03          	lw	s8,0(s4)
    80200764:	00144603          	lbu	a2,1(s0)
    80200768:	0a21                	addi	s4,s4,8
    8020076a:	846a                	mv	s0,s10
    8020076c:	bfd9                	j	80200742 <vprintfmt+0x114>
    8020076e:	4705                	li	a4,1
    80200770:	008a0593          	addi	a1,s4,8
    80200774:	01174463          	blt	a4,a7,8020077c <vprintfmt+0x14e>
    80200778:	1a088e63          	beqz	a7,80200934 <vprintfmt+0x306>
    8020077c:	000a3603          	ld	a2,0(s4)
    80200780:	46c1                	li	a3,16
    80200782:	8a2e                	mv	s4,a1
    80200784:	2781                	sext.w	a5,a5
    80200786:	876e                	mv	a4,s11
    80200788:	85a6                	mv	a1,s1
    8020078a:	854a                	mv	a0,s2
    8020078c:	e37ff0ef          	jal	ra,802005c2 <printnum>
    80200790:	bde1                	j	80200668 <vprintfmt+0x3a>
    80200792:	000a2503          	lw	a0,0(s4)
    80200796:	85a6                	mv	a1,s1
    80200798:	0a21                	addi	s4,s4,8
    8020079a:	9902                	jalr	s2
    8020079c:	b5f1                	j	80200668 <vprintfmt+0x3a>
    8020079e:	4705                	li	a4,1
    802007a0:	008a0593          	addi	a1,s4,8
    802007a4:	01174463          	blt	a4,a7,802007ac <vprintfmt+0x17e>
    802007a8:	18088163          	beqz	a7,8020092a <vprintfmt+0x2fc>
    802007ac:	000a3603          	ld	a2,0(s4)
    802007b0:	46a9                	li	a3,10
    802007b2:	8a2e                	mv	s4,a1
    802007b4:	bfc1                	j	80200784 <vprintfmt+0x156>
    802007b6:	00144603          	lbu	a2,1(s0)
    802007ba:	4c85                	li	s9,1
    802007bc:	846a                	mv	s0,s10
    802007be:	bdf1                	j	8020069a <vprintfmt+0x6c>
    802007c0:	85a6                	mv	a1,s1
    802007c2:	02500513          	li	a0,37
    802007c6:	9902                	jalr	s2
    802007c8:	b545                	j	80200668 <vprintfmt+0x3a>
    802007ca:	00144603          	lbu	a2,1(s0)
    802007ce:	2885                	addiw	a7,a7,1
    802007d0:	846a                	mv	s0,s10
    802007d2:	b5e1                	j	8020069a <vprintfmt+0x6c>
    802007d4:	4705                	li	a4,1
    802007d6:	008a0593          	addi	a1,s4,8
    802007da:	01174463          	blt	a4,a7,802007e2 <vprintfmt+0x1b4>
    802007de:	14088163          	beqz	a7,80200920 <vprintfmt+0x2f2>
    802007e2:	000a3603          	ld	a2,0(s4)
    802007e6:	46a1                	li	a3,8
    802007e8:	8a2e                	mv	s4,a1
    802007ea:	bf69                	j	80200784 <vprintfmt+0x156>
    802007ec:	03000513          	li	a0,48
    802007f0:	85a6                	mv	a1,s1
    802007f2:	e03e                	sd	a5,0(sp)
    802007f4:	9902                	jalr	s2
    802007f6:	85a6                	mv	a1,s1
    802007f8:	07800513          	li	a0,120
    802007fc:	9902                	jalr	s2
    802007fe:	0a21                	addi	s4,s4,8
    80200800:	6782                	ld	a5,0(sp)
    80200802:	46c1                	li	a3,16
    80200804:	ff8a3603          	ld	a2,-8(s4)
    80200808:	bfb5                	j	80200784 <vprintfmt+0x156>
    8020080a:	000a3403          	ld	s0,0(s4)
    8020080e:	008a0713          	addi	a4,s4,8
    80200812:	e03a                	sd	a4,0(sp)
    80200814:	14040263          	beqz	s0,80200958 <vprintfmt+0x32a>
    80200818:	0fb05763          	blez	s11,80200906 <vprintfmt+0x2d8>
    8020081c:	02d00693          	li	a3,45
    80200820:	0cd79163          	bne	a5,a3,802008e2 <vprintfmt+0x2b4>
    80200824:	00044783          	lbu	a5,0(s0)
    80200828:	0007851b          	sext.w	a0,a5
    8020082c:	cf85                	beqz	a5,80200864 <vprintfmt+0x236>
    8020082e:	00140a13          	addi	s4,s0,1
    80200832:	05e00413          	li	s0,94
    80200836:	000c4563          	bltz	s8,80200840 <vprintfmt+0x212>
    8020083a:	3c7d                	addiw	s8,s8,-1
    8020083c:	036c0263          	beq	s8,s6,80200860 <vprintfmt+0x232>
    80200840:	85a6                	mv	a1,s1
    80200842:	0e0c8e63          	beqz	s9,8020093e <vprintfmt+0x310>
    80200846:	3781                	addiw	a5,a5,-32
    80200848:	0ef47b63          	bgeu	s0,a5,8020093e <vprintfmt+0x310>
    8020084c:	03f00513          	li	a0,63
    80200850:	9902                	jalr	s2
    80200852:	000a4783          	lbu	a5,0(s4)
    80200856:	3dfd                	addiw	s11,s11,-1
    80200858:	0a05                	addi	s4,s4,1
    8020085a:	0007851b          	sext.w	a0,a5
    8020085e:	ffe1                	bnez	a5,80200836 <vprintfmt+0x208>
    80200860:	01b05963          	blez	s11,80200872 <vprintfmt+0x244>
    80200864:	3dfd                	addiw	s11,s11,-1
    80200866:	85a6                	mv	a1,s1
    80200868:	02000513          	li	a0,32
    8020086c:	9902                	jalr	s2
    8020086e:	fe0d9be3          	bnez	s11,80200864 <vprintfmt+0x236>
    80200872:	6a02                	ld	s4,0(sp)
    80200874:	bbd5                	j	80200668 <vprintfmt+0x3a>
    80200876:	4705                	li	a4,1
    80200878:	008a0c93          	addi	s9,s4,8
    8020087c:	01174463          	blt	a4,a7,80200884 <vprintfmt+0x256>
    80200880:	08088d63          	beqz	a7,8020091a <vprintfmt+0x2ec>
    80200884:	000a3403          	ld	s0,0(s4)
    80200888:	0a044d63          	bltz	s0,80200942 <vprintfmt+0x314>
    8020088c:	8622                	mv	a2,s0
    8020088e:	8a66                	mv	s4,s9
    80200890:	46a9                	li	a3,10
    80200892:	bdcd                	j	80200784 <vprintfmt+0x156>
    80200894:	000a2783          	lw	a5,0(s4)
    80200898:	4719                	li	a4,6
    8020089a:	0a21                	addi	s4,s4,8
    8020089c:	41f7d69b          	sraiw	a3,a5,0x1f
    802008a0:	8fb5                	xor	a5,a5,a3
    802008a2:	40d786bb          	subw	a3,a5,a3
    802008a6:	02d74163          	blt	a4,a3,802008c8 <vprintfmt+0x29a>
    802008aa:	00369793          	slli	a5,a3,0x3
    802008ae:	97de                	add	a5,a5,s7
    802008b0:	639c                	ld	a5,0(a5)
    802008b2:	cb99                	beqz	a5,802008c8 <vprintfmt+0x29a>
    802008b4:	86be                	mv	a3,a5
    802008b6:	00000617          	auipc	a2,0x0
    802008ba:	7aa60613          	addi	a2,a2,1962 # 80201060 <etext+0x634>
    802008be:	85a6                	mv	a1,s1
    802008c0:	854a                	mv	a0,s2
    802008c2:	0ce000ef          	jal	ra,80200990 <printfmt>
    802008c6:	b34d                	j	80200668 <vprintfmt+0x3a>
    802008c8:	00000617          	auipc	a2,0x0
    802008cc:	78860613          	addi	a2,a2,1928 # 80201050 <etext+0x624>
    802008d0:	85a6                	mv	a1,s1
    802008d2:	854a                	mv	a0,s2
    802008d4:	0bc000ef          	jal	ra,80200990 <printfmt>
    802008d8:	bb41                	j	80200668 <vprintfmt+0x3a>
    802008da:	00000417          	auipc	s0,0x0
    802008de:	76e40413          	addi	s0,s0,1902 # 80201048 <etext+0x61c>
    802008e2:	85e2                	mv	a1,s8
    802008e4:	8522                	mv	a0,s0
    802008e6:	e43e                	sd	a5,8(sp)
    802008e8:	116000ef          	jal	ra,802009fe <strnlen>
    802008ec:	40ad8dbb          	subw	s11,s11,a0
    802008f0:	01b05b63          	blez	s11,80200906 <vprintfmt+0x2d8>
    802008f4:	67a2                	ld	a5,8(sp)
    802008f6:	00078a1b          	sext.w	s4,a5
    802008fa:	3dfd                	addiw	s11,s11,-1
    802008fc:	85a6                	mv	a1,s1
    802008fe:	8552                	mv	a0,s4
    80200900:	9902                	jalr	s2
    80200902:	fe0d9ce3          	bnez	s11,802008fa <vprintfmt+0x2cc>
    80200906:	00044783          	lbu	a5,0(s0)
    8020090a:	00140a13          	addi	s4,s0,1
    8020090e:	0007851b          	sext.w	a0,a5
    80200912:	d3a5                	beqz	a5,80200872 <vprintfmt+0x244>
    80200914:	05e00413          	li	s0,94
    80200918:	bf39                	j	80200836 <vprintfmt+0x208>
    8020091a:	000a2403          	lw	s0,0(s4)
    8020091e:	b7ad                	j	80200888 <vprintfmt+0x25a>
    80200920:	000a6603          	lwu	a2,0(s4)
    80200924:	46a1                	li	a3,8
    80200926:	8a2e                	mv	s4,a1
    80200928:	bdb1                	j	80200784 <vprintfmt+0x156>
    8020092a:	000a6603          	lwu	a2,0(s4)
    8020092e:	46a9                	li	a3,10
    80200930:	8a2e                	mv	s4,a1
    80200932:	bd89                	j	80200784 <vprintfmt+0x156>
    80200934:	000a6603          	lwu	a2,0(s4)
    80200938:	46c1                	li	a3,16
    8020093a:	8a2e                	mv	s4,a1
    8020093c:	b5a1                	j	80200784 <vprintfmt+0x156>
    8020093e:	9902                	jalr	s2
    80200940:	bf09                	j	80200852 <vprintfmt+0x224>
    80200942:	85a6                	mv	a1,s1
    80200944:	02d00513          	li	a0,45
    80200948:	e03e                	sd	a5,0(sp)
    8020094a:	9902                	jalr	s2
    8020094c:	6782                	ld	a5,0(sp)
    8020094e:	8a66                	mv	s4,s9
    80200950:	40800633          	neg	a2,s0
    80200954:	46a9                	li	a3,10
    80200956:	b53d                	j	80200784 <vprintfmt+0x156>
    80200958:	03b05163          	blez	s11,8020097a <vprintfmt+0x34c>
    8020095c:	02d00693          	li	a3,45
    80200960:	f6d79de3          	bne	a5,a3,802008da <vprintfmt+0x2ac>
    80200964:	00000417          	auipc	s0,0x0
    80200968:	6e440413          	addi	s0,s0,1764 # 80201048 <etext+0x61c>
    8020096c:	02800793          	li	a5,40
    80200970:	02800513          	li	a0,40
    80200974:	00140a13          	addi	s4,s0,1
    80200978:	bd6d                	j	80200832 <vprintfmt+0x204>
    8020097a:	00000a17          	auipc	s4,0x0
    8020097e:	6cfa0a13          	addi	s4,s4,1743 # 80201049 <etext+0x61d>
    80200982:	02800513          	li	a0,40
    80200986:	02800793          	li	a5,40
    8020098a:	05e00413          	li	s0,94
    8020098e:	b565                	j	80200836 <vprintfmt+0x208>

0000000080200990 <printfmt>:
    80200990:	715d                	addi	sp,sp,-80
    80200992:	02810313          	addi	t1,sp,40
    80200996:	f436                	sd	a3,40(sp)
    80200998:	869a                	mv	a3,t1
    8020099a:	ec06                	sd	ra,24(sp)
    8020099c:	f83a                	sd	a4,48(sp)
    8020099e:	fc3e                	sd	a5,56(sp)
    802009a0:	e0c2                	sd	a6,64(sp)
    802009a2:	e4c6                	sd	a7,72(sp)
    802009a4:	e41a                	sd	t1,8(sp)
    802009a6:	c89ff0ef          	jal	ra,8020062e <vprintfmt>
    802009aa:	60e2                	ld	ra,24(sp)
    802009ac:	6161                	addi	sp,sp,80
    802009ae:	8082                	ret

00000000802009b0 <sbi_console_putchar>:
    802009b0:	4781                	li	a5,0
    802009b2:	00003717          	auipc	a4,0x3
    802009b6:	64e73703          	ld	a4,1614(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009ba:	88ba                	mv	a7,a4
    802009bc:	852a                	mv	a0,a0
    802009be:	85be                	mv	a1,a5
    802009c0:	863e                	mv	a2,a5
    802009c2:	00000073          	ecall
    802009c6:	87aa                	mv	a5,a0
    802009c8:	8082                	ret

00000000802009ca <sbi_set_timer>:
    802009ca:	4781                	li	a5,0
    802009cc:	00003717          	auipc	a4,0x3
    802009d0:	65473703          	ld	a4,1620(a4) # 80204020 <SBI_SET_TIMER>
    802009d4:	88ba                	mv	a7,a4
    802009d6:	852a                	mv	a0,a0
    802009d8:	85be                	mv	a1,a5
    802009da:	863e                	mv	a2,a5
    802009dc:	00000073          	ecall
    802009e0:	87aa                	mv	a5,a0
    802009e2:	8082                	ret

00000000802009e4 <sbi_shutdown>:
    802009e4:	4781                	li	a5,0
    802009e6:	00003717          	auipc	a4,0x3
    802009ea:	62273703          	ld	a4,1570(a4) # 80204008 <SBI_SHUTDOWN>
    802009ee:	88ba                	mv	a7,a4
    802009f0:	853e                	mv	a0,a5
    802009f2:	85be                	mv	a1,a5
    802009f4:	863e                	mv	a2,a5
    802009f6:	00000073          	ecall
    802009fa:	87aa                	mv	a5,a0
    802009fc:	8082                	ret

00000000802009fe <strnlen>:
    802009fe:	4781                	li	a5,0
    80200a00:	e589                	bnez	a1,80200a0a <strnlen+0xc>
    80200a02:	a811                	j	80200a16 <strnlen+0x18>
    80200a04:	0785                	addi	a5,a5,1
    80200a06:	00f58863          	beq	a1,a5,80200a16 <strnlen+0x18>
    80200a0a:	00f50733          	add	a4,a0,a5
    80200a0e:	00074703          	lbu	a4,0(a4)
    80200a12:	fb6d                	bnez	a4,80200a04 <strnlen+0x6>
    80200a14:	85be                	mv	a1,a5
    80200a16:	852e                	mv	a0,a1
    80200a18:	8082                	ret

0000000080200a1a <memset>:
    80200a1a:	ca01                	beqz	a2,80200a2a <memset+0x10>
    80200a1c:	962a                	add	a2,a2,a0
    80200a1e:	87aa                	mv	a5,a0
    80200a20:	0785                	addi	a5,a5,1
    80200a22:	feb78fa3          	sb	a1,-1(a5)
    80200a26:	fec79de3          	bne	a5,a2,80200a20 <memset+0x6>
    80200a2a:	8082                	ret
