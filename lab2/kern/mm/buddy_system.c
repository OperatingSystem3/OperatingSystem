#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system.h>
#include <stdio.h>
#include <defs.h>

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// 源代码中宏定义 https://github.com/wuwenbin/buddy2/blob/master/buddy2.c
#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

static unsigned fixsize(unsigned size) {
  size |= size >> 1;
  size |= size >> 2;
  size |= size >> 4;
  size |= size >> 8;
  size |= size >> 16;
  return size+1;
}


struct buddy2
{
    unsigned size;
    unsigned longest;// longest代表该节点所表示的初始空闲空间块数
};
struct buddy2 root[40000]; //存放二叉树的数组，用于内存分配
int total_size=0; //记录总的空闲块数


static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

// 初始化二叉树
void buddy2_new( int size ) {
    // size是buddy system的总空闲空间；node_size是对应节点所表示的空闲空间的块数
    unsigned node_size; 
    int i;
    if (size < 1 || !IS_POWER_OF_2(size))
        return;

    root[0].size = size;
    node_size = size * 2;   // 总结点数是size*2

    // 初始化每个节点管理的空闲空间块数
    for (i = 0; i < 2 * size - 1; ++i) {
        if (IS_POWER_OF_2(i+1)) // 下一层
            node_size /= 2;
        root[i].longest = node_size;   
    }
    return;
}


static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) { // 初始化每一页
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = 0; 
    nr_free += n; // 空闲块总数

    if (list_empty(&free_list)) { 
        list_add(&free_list, &(base->page_link));
    } 
    else { // freelist不为空，找到合适的位置插入
        list_entry_t* le = &free_list; // 从头开始遍历
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link); 
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
    if(IS_POWER_OF_2(n)) { // 如果是2的幂次方，那么就可以用来初始化树
        buddy2_new(n);
    }
    else{ // 将大于 n 的最小 2 的幂次方减小为不超过 n 的最大 2 的幂次方
        buddy2_new(fixsize(n)>>1);
    }
    total_size=n;
}

static int buddy2_alloc(struct buddy2* self, int size) {
    unsigned index = 0;  
    unsigned node_size;  // 记录当前层的大小
    unsigned offset = 0;

    // 检查空指针
    if (self == NULL)
        return -1;

    // 检查最大的可用块是否小于请求的大小
    if (self[0].longest < size)  // 假设根节点在索引 0
        return -1;

    // 从根节点开始搜索合适的节点
    for (node_size = self->size; node_size > size; node_size /= 2) {
        unsigned left_index = LEFT_LEAF(index);
        unsigned right_index = RIGHT_LEAF(index);

        if (self[left_index].longest >= size) {
            if (self[right_index].longest >= size) {
                // 选择两个中内存块较小的
                index = (self[left_index].longest <= self[right_index].longest) ? left_index : right_index;
            } else {
                index = left_index;  // 只有左子节点适合
            }
        } else {
            index = right_index;  // 只有右子节点适合
        }
    }

    // 标记找到的块为已使用
    self[index].longest = 0;

    // 计算分配块的偏移量
    offset = (index + 1) * node_size - self->size;  

    // 更新父节点的 longest 值
    while (index) {
        index = PARENT(index);
        self[index].longest = MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
    }

    return offset;  // 返回分配内存块的偏移量
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    if (n <= 0)// 把n调整到合适大小
        n = 1;
    else if (!IS_POWER_OF_2(n)) // 不为2的幂时，向上取
        n = fixsize(n);
    // 找到合适的空闲块
    unsigned long offset = buddy2_alloc(root, n);

    list_entry_t *le = &free_list;
    struct Page *base = le2page(list_next(le), page_link);
    struct Page *page = base+offset; // 找到空闲块的第一页
    cprintf("alloc page offset %ld\n",offset);

    nr_free -= n; // 总的空闲块数减少
    page->property = n; // 记录空闲块的大小

    return page;
}

static void
buddy2_free(struct buddy2* self, int offset){
    unsigned node_size, index;
    unsigned left_longest, right_longest;

    // 实际的双链表信息复原后，还要对“二叉树”里面的节点信息进行更新
    node_size = 1;
    index = offset + self->size - 1;   //从原始的分配节点的最底节点开始改变longest
    self[index].longest = node_size;   //这里是node_size，也就是从1那层开始改变
    while (index) {//向上合并，修改父节点的记录值
        index = PARENT(index);
        node_size *= 2;
        left_longest = self[LEFT_LEAF(index)].longest;
        right_longest = self[RIGHT_LEAF(index)].longest;
        
        if (left_longest + right_longest == node_size) 
            self[index].longest = node_size;
        else
            self[index].longest = MAX(left_longest, right_longest);
    }
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n>0);
    n = base->property; // 从property中拿到空闲块的大小

    struct buddy2* self=root;
    list_entry_t *le=&free_list;
    struct Page *base_page = le2page(list_next(le), page_link); 
    unsigned int offset= base - base_page; // 释放块的偏移量
    cprintf("free page offset %d\n),",offset);
    assert(self&&offset >= 0&&offset < self->size); // 是否合法
    
    struct Page *p = base;
    for (; p != base + n; p ++) { // 释放每一页
        assert(!PageReserved(p));
        set_page_ref(p, 0);
    }
    base->property = 0; // 当前页不再管辖任何空闲块
    nr_free += n;

    buddy2_free(self, offset); // 释放空闲块
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void) {
    struct Page *p0, *p1,*p2;
    p0 = p1 = NULL;
    p2=NULL;
    struct Page *p3, *p4,*p5;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    free_page(p0);
    free_page(p1);
    free_page(p2);
    
    p0=alloc_pages(70);
    p1=alloc_pages(35);
    //注意，一个结构体指针是20个字节，有3个int,3*4，还有一个双向链表,两个指针是8。加载一起是20。
    cprintf("p0 %p\n",p0);
    cprintf("p1 %p\n",p1);
    cprintf("p1-p0 equal %p ?=128\n",p1-p0);//应该差128
    
    p2=alloc_pages(257);
    cprintf("p2 %p\n",p2);
    cprintf("p2-p1 equal %p ?=128+256\n",p2-p1);//应该差384
    
    p3=alloc_pages(63);
    cprintf("p3 %p\n",p3);
    cprintf("p3-p1 equal %p ?=64\n",p3-p1);//应该差64
    
    free_pages(p0,70);    
    cprintf("free p0!\n");
    free_pages(p1,35);
    cprintf("free p1!\n");
    free_pages(p3,63);    
    cprintf("free p3!\n");
    
    p4=alloc_pages(255);
    cprintf("p4 %p\n",p4);
    cprintf("p2-p4 equal %p ?=512\n",p2-p4);//应该差512
    
    p5=alloc_pages(255);
    cprintf("p5 %p\n",p5);
    cprintf("p5-p4 equal %p ?=256\n",p5-p4);//应该差256
        free_pages(p2,257);    
    cprintf("free p2!\n");
        free_pages(p4,255);    
    cprintf("free p4!\n"); 
            free_pages(p5,255);    
    cprintf("free p5!\n");   
    cprintf("CHECK DONE!\n") ;

}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};