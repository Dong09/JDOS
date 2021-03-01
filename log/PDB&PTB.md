# PDB&PTB&分页

## PDB(PageDirBase 页目录表) & PTB(PageTableBase)

> 页目录表有1024个表项，每个表项为4字节  

> 页目录表每个表项对应1个一个第二级页表，共1024个第二级页表

> 每个第二级页表有1024个表项，每个表项4字节

> 第二级页表为 4\*1024\*1024 = 4MB ,第一级页表为 4*1024 = 4KB

> cr3寄存器 又叫 PDBR 指向页目录表

-------
## 分页机制(4G内存)

> 需要定义 PDB、PTB 的开始地址 PTB = PDB + 4K

> 需要分别定义段描述符 和 段选择子

> <u>SetupPaging函数</u>：
>> + 先初始化页目录表:以PDB为段地址，4096(4\*1024)为步长，1024为循环次数 初始化PDB  
>> + 再初始化所有页表：以PTB为段地址，4096(4\*1024)为步长，1024\*1024=1M为循环次数 初始化PTB  
>> + *其中，stosd 指令 ===>  mov  dword ptr es:\[edi],eax    add edi,4  

## 分页机制(未知内存)

### 计算内存

> 固定写法：

> memchkbuf 缓冲区 存放对内存的描述

> dwMCRNumber  对ARDS结构体的计数器

> mov eax,0e820h

> mov ecx,20

> mov edx,0534D4150h

----

> int 15h  <u>得到内存描述的中断</u>

> DispMemSize函数：【pmtest7.asm】

### 分配PDB&PTB 

> 计算 PDB 的个数   mov eax,\[dwMemSize]  mov ebx,400000h    div bx       

> 看余数判断 是否增加一张页表

> PTB = PDB个数 * 1024

> 