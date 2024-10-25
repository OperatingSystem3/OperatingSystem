#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub.h>
#include <stdio.h>

/*第一层：伙伴系统*/
#define MAX_ORDER (14) 
static struct Page *buddy_start = NULL;   // 伙伴系统起始页的指针
extern free_area_t free_area[MAX_ORDER + 1];     // 定义一个数组，用于存放各个块大小的空闲块链表
unsigned int max_order;                   // 实际最大块的大小
unsigned int total_nr_free;               // 伙伴系统中剩余的空闲页   
/*IS_POWER_OF_2:判断一个数是不是2的次幂*/
static int IS_POWER_OF_2(size_t n) {
    if (n & (n - 1)) 
        return 0;
    else 
        return 1;
}

/*getOrderOf2:计算一个数是2的多少次幂*/
static unsigned int getOrderOf2(size_t n) {
    unsigned int order = 0;
    while (n >> 1) {
        n >>= 1;
        order++;
    }
    return order;
}

/*ROUNDDOWN2:向下取最接近的2的次幂*/
static size_t ROUNDDOWN2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res>>1; 
    }
    else {
        return n;
    }
}

/*ROUNDUP2:向上取最接近的2的次幂*/
static size_t ROUNDUP2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res; 
    }
    else {
        return n;
    }
}

                        
/*buddy_init：初始化空闲链表*/
static void
 buddy_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&(free_area[i].free_list)); // 初始化空闲链表
        free_area[i].nr_free = 0;
    }
    max_order=0;
    total_nr_free=0;
}

/*buddy_init_memmap:初始化伙伴堆*/
static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    size_t pnum;
    unsigned int order;
    pnum = ROUNDDOWN2(n);        // 将页数向下取整为2的幂
    order = getOrderOf2(pnum);   // 求出页数对应的2的幂
    buddy_start=base;
    max_order = order;
    total_nr_free = pnum;
    cprintf("------------------------------maxorder %d\n",max_order);

    struct Page *p = base;     // 初始化pages数组中范围内的每个Page
    for (; p != base + pnum; p ++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property =0;   
        set_page_ref(p, 0);
    }

    list_add(&(free_area[max_order].free_list), &(base->page_link)); // 将第一页base插入对应的链表中
    SetPageProperty(base);                
    base->property = max_order;           // 将第一页base的property设为最大块的2幂

    return;
}  

/*buddy_alloc_pages：分配指定大小的物理块*/
static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > total_nr_free) {
        return NULL;
    }
    //找到向上取的最接近的order
    struct Page *page = NULL;
    size_t pnum = ROUNDUP2(n);
    int order = getOrderOf2(pnum);

    //cprintf("-------------------------allocorder:%d \n",order);

    //找最接近的2次幂的空闲页
    for(int o=order;o<=max_order;o++)  
    {
        if (!list_empty(&(free_area[o].free_list))) {
            page = le2page(list_next(&(free_area[o].free_list)), page_link);
            if(o!=order)
            {
                for (int i = o - 1; i >= order; --i) {
                    //分裂操作：分裂出左右两块，右侧设为空闲块，左侧可能继续分裂
                    unsigned long idx = page-buddy_start;
                    idx += 1 << i;
                    struct Page *new_page = buddy_start+idx;
                    // 修改分裂出的右侧页的信息：order变化；成为了空闲页首；加入空闲链表
                    new_page->property = i;
                    SetPageProperty(new_page);
                    list_add(&(free_area[i].free_list), &(new_page->page_link)); 
                }
            }
            //修改相关信息：order可能变了(有分裂的情况)；不再是空闲页首页；从空闲链表中删除
            page->property=order;
            list_del(list_next(&(free_area[o].free_list)));
            ClearPageProperty(page);
            total_nr_free -= pnum;
            return page;
        }

    }    
    return NULL;
}

/*getBuddyPage:获取以page页为头页的块的伙伴块*/
static struct Page*
getBuddyPage(struct Page *page) {
    unsigned int order = page->property;
    unsigned int buddy_ppn = page2ppn(buddy_start) + ((1 << order) ^ (page2ppn(page) - page2ppn(buddy_start))); 
    if (buddy_ppn > page2ppn(page)) {
        return page + (buddy_ppn - page2ppn(page));
    }
    else {
        return page - (page2ppn(page) - buddy_ppn);
    }
}

/*buddy_free_pages：释放指定大小的物理块*/
static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    unsigned int pnum = 1 << (base->property);
    assert(ROUNDUP2(n) == pnum);
    unsigned int order = base->property;
    struct Page* page=NULL;
    unsigned long idx=base-buddy_start;
    struct Page* buddy_page = NULL;

    for(;order<max_order;order++)
    {
        //cprintf("idx:%d ",idx);
        buddy_page=getBuddyPage(buddy_start+idx);
        unsigned int buddy_idx=buddy_page-buddy_start;
        //调试输出
        //cprintf("oreder:%d  buddy_idx:%d  buddy_page->property:%d PageProperty(buddy_page):%d\n",order,buddy_idx,buddy_page->property,PageProperty(buddy_page));
        if(buddy_page->property!=order||PageProperty(buddy_page)!=1){
            break;
        }
        //如果能合并，伙伴页需做调整：可能不再是空闲页首；从空闲块中删除
        buddy_page->property=0;
        ClearPageProperty(buddy_page);
        list_del(&(buddy_page->page_link));
        (buddy_start+idx)->property=0;
        ClearPageProperty(buddy_start+idx);

        idx&=buddy_idx;  //一对伙伴块的父结点的索引
        page=buddy_start+idx; 
        page->property=order+1;
    }

    //page可能是指向原来的块，也可能是指向伙伴块(谁左谁右不一定)
    //进行更新，将合并块存入空闲链表
    page=buddy_start+idx; 
    page->property=order;
    SetPageProperty(page);
    list_add(&(free_area[order].free_list),&(page->page_link));
    total_nr_free += pnum;

    return;
}

// 获取当前空闲页面数量的函数
static size_t buddy_nr_free_pages(void) {
    return total_nr_free;
}
/*第二层：slub算法*/

/*定义所需的结构体*/

typedef struct kmem_cache_cpu
{
    list_entry_t freelist;
    struct Page *page; 
}kmem_cache_cpu_t;

typedef struct kmem_cache_node
{
    size_t nr_partial;
    size_t nr_full;//记录被分配完的页，用于恢复回到slabs
    list_entry_t page_link_partial;//这里面有一个单链表有一个双链表，单链表用于查找单一page
    list_entry_t page_link_full;
}kmem_cache_node_t;

typedef struct kmem_cache
{
    size_t size;//从伙伴系统分配的连续页的大小
    size_t offset; //每个块的offset即每个小块的大小（这里不考虑对齐）
    int free_blocks;
    kmem_cache_cpu_t *cpu_slab;
    kmem_cache_node_t *node; 
}kmem_cache_t;
/*定义对应的数组*/
kmem_cache_t kmallo_caches[11];
kmem_cache_cpu_t k_cache_cpus[11];
kmem_cache_node_t k_cache_nodes[11];
/*计算所需要的缓存池的大小*/
#define max_order (14)
#define fract_leftover (16)
static int calculate_bufferpool(int x_size)
{   unsigned long slab_size;
    int rem;
    int order;
    for(order=0;order<max_order;order++)
    {
        slab_size=PGSIZE<<order;
        rem=slab_size%x_size;
        if(rem<=slab_size/fract_leftover)/*设置内存碎片阈值*/
        {
            break;
        }
    }
    return PGSIZE<<order;
}

static int calculate_x_size(int size) {
    int x_size;  // 默认值
    if (size <= 8) {
        x_size = 8;
    } else if ((size > 8) && (size <= 16)) {
        x_size = 16;
    } else if ((size > 16) && (size <= 32)) {
        x_size = 32;
    } else if ((size > 32) && (size <= 64)) {
        x_size = 64;
    } else if ((size > 64) && (size <= 96)) {
        x_size = 96;
    } else if ((size > 96) && (size <= 128)) {
        x_size = 128;
    } else if ((size > 128) && (size <= 192)) {
        x_size = 192;
    } else if ((size > 192) && (size <= 256)) {
        x_size = 256;
    } else if ((size > 256) && (size <= 512)) {
        x_size = 512;
    } else if ((size > 512) && (size <= 1024)) {
        x_size = 1024;
    } else if ((size > 1024) && (size <= 2048)) {
        x_size = 2048;
    } else {
        return PGSIZE;
    }
    return x_size;
}

/*一些单链表相关的计算*/
static void init_object_t(list_entry_t *elm)
{
     elm->next=NULL;
}

static void init_kmallo_caches(){
    for(int i=0;i<11;i++)
    {   if(i==0)
    {
     kmallo_caches[i].size=calculate_bufferpool(96);
     kmallo_caches[i].offset=96;
    }
        else if(i==1)
    {
     kmallo_caches[i].size=calculate_bufferpool(192);
     kmallo_caches[i].offset=192;
        }
        else{
     kmallo_caches[i].size=calculate_bufferpool(1<<(i+1));
     kmallo_caches[i].offset=1<<(i+1);
    }
    init_object_t(&(k_cache_cpus[i].freelist));
     k_cache_cpus[i].page=NULL;
     k_cache_nodes[i].nr_full==0;
     k_cache_nodes[i].nr_partial==0;
     list_init(&(k_cache_nodes[i].page_link_partial));
     list_init(&(k_cache_nodes[i].page_link_full));
    kmallo_caches[i].free_blocks=0;
    kmallo_caches[i].cpu_slab=&(k_cache_cpus[i]);
    kmallo_caches[i].node=&(k_cache_nodes[i]);
    }
}

static void
slub_init(void)
{   buddy_init();//初始化所有空闲链表
    init_kmallo_caches();//初始化前三个总框
}

static void slub_init_memap(struct Page *base, size_t n)
{
    buddy_init_memmap(base,n);//初始化分配近乎所有的内存空间
}
/*分割页面*/
static list_entry_t *splitPageToBlocks(void*pageStart,size_t blockSize,size_t numBlocks)
{
    list_entry_t* head = (list_entry_t*)pageStart; // 第一个块
    list_entry_t* current = head;
    for (size_t i = 1; i < numBlocks; i++) {
        list_entry_t* nextBlock = (list_entry_t*)((char*)current + blockSize);
        current->next = nextBlock;
        current = nextBlock;
    }
    current->next = NULL; // 最后一个块的next指向NULL
    return head;
}
static void*slub_alloc_block(size_t size)/*只考虑分配比1页大小小的*/
{
    assert(size>0);
    size_t x_size=calculate_x_size(size);
    cprintf("The block acturally is:%d\n",x_size);
    int i;
    for(i=0;i<11;i++)
    { 
        if(kmallo_caches[i].offset==x_size)
        {
            break;
        }
    }
   /*想要分配 先看cpu里有没有如果没有就需要从伙伴系统求，因为每次partial都会即使补充cpu*/
   size_t n=calculate_bufferpool(x_size)/PGSIZE;/*计算出需要的页*/
   cprintf("The size of bufferpool should be:%d\n",n);
   if(kmallo_caches[i].cpu_slab->freelist.next==NULL){
       struct Page*ALLOC_page=buddy_alloc_pages(n);/*得到对应首页的结构体*/
       /*找到page对应的实际虚拟地址*/
       uint64_t address=DRAM_BASE+(ALLOC_page-pages)*PGSIZE+va_pa_offset;
       void* virtual_address=(void*)address;
       /*链接object到page对应的实际虚拟地址*/
       //计算一个连续页有多少个可用的objects,从而建立链表
       size_t num_objects=(n*PGSIZE)/x_size;
       kmallo_caches[i].cpu_slab->freelist.next=splitPageToBlocks(virtual_address, x_size, num_objects);
       kmallo_caches[i].cpu_slab->page=ALLOC_page;
       kmallo_caches[i].free_blocks=num_objects;
       }
       /*开始实现分配，每次从链表头取一个*/
       cprintf("Address of p1: %p\n", (void*)kmallo_caches[i].cpu_slab->freelist.next);
       list_entry_t*outcome=kmallo_caches[i].cpu_slab->freelist.next;
       kmallo_caches[i].cpu_slab->freelist.next=outcome->next;
       cprintf("Address of p1(after alloc): %p\n", (void*)kmallo_caches[i].cpu_slab->freelist.next);
       kmallo_caches[i].free_blocks-=1;//空闲的少了一个
       cprintf("kmallo_caches[%d].free_blocks=%d\n",i,kmallo_caches[i].free_blocks);
       if(kmallo_caches[i].cpu_slab->freelist.next==NULL)/*刚分配完最后一个*/
       {
            list_add(&(kmallo_caches[i].node->page_link_full),&(kmallo_caches[i].cpu_slab->page->page_link));
            kmallo_caches[i].cpu_slab->page=NULL;
            kmallo_caches[i].node->nr_full+=1;
            cprintf("kmallo_caches[%d].node->nr_full=%d\n",i,kmallo_caches[i].node->nr_full);
         }
       return outcome;
   
}


static void
slub_check(void) {


    cprintf("You are going to check your code!!!\n");

    
}

const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init =slub_init,
    .init_memmap = slub_init_memap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = slub_check,
};