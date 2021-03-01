// 函数原型 proto.h

#include "const.h"
#include "type.h"

PUBLIC void out_byte(u16 port, u8 value);
PUBLIC u8 in_byte(u16 port);
PUBLIC void disp_str(char* info);
PUBLIC void disp_int(int num);
PUBLIC void disp_color_str(char* str, int num);
