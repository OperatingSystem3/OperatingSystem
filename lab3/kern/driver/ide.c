#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];//number of sectors

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }//指定的 IDE 设备编号

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }

////ideno: 假设挂载了多块磁盘，选择哪一块磁盘 这里我们其实只有一块“磁盘”，这个参数就没用到
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {//secno 是起始扇区号，nsecs 是要读取的扇区数量
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);//这里所谓的“硬盘IO”，只是在内存里用memcpy把数据复制来复制去
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}
