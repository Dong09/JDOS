# IDT(中断描述符)

> 中断门 FAULT

> 陷阱门 TRAP

> 任务门 ABORT

> 中断 ： 1.指令中断  2.外部中断(不可屏蔽中断NMI & 可屏蔽中断INTR)  

> 可屏蔽中断 -----> 中断控制器8259A 

> 对 主20h 从A0h 写入ICW1 

> 对 主21h 从A1h 写入ICW2

> 对 主21h 从A1h 写入ICW3

> 对 主21h 从A1h 写入ICW4

>> + mov al,11111110b  <u>仅开启定时器中断</u>    out 021h,al  主8259，OCW1  
>> + mov al，11111111B  屏蔽从8259所有中断     out 0A1h,al  从8259，OCW1

>    <u>EOI</u>   ：当每一次中断处理结束，需要发送一个 EOI 给8259A

> 发送一个 EOI 给8259A   ：mov al,20h        out 20h,al      

## 建立IDT

> idt段---idtptr---中断函数---加载idtr

> 为 idt 单独创个段，与GDT类似

> \[section .idt] .020h:      Gate    SelectorCode32, ClockHandler,   0,  DA_386IGate  
> _ClockHandler:  
> ClockHandler    equ _ClockHandler - $$

> 加载IDTR      lidt \[IdtPtr]

## 时钟中断

> 时钟中断：是一个周期性的信号，完全是硬件行为，该信号触发CPU去执行一个中断服务程序

> 时钟中断会在EOI后周期性的中断、完成、中断、完成

> _ClockHandler:  
> ClockHandler    equ _ClockHandler - $$  
>    inc byte \[gs:((80\*0+70)*2)]  
>    mov     al, 20h                    ; OCW2  
>    out 20h,    al                     ;<u>发送EOI</u> end of interrupt 表示中断任务处理完成  
>    iretd  

> 