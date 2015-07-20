# 基于MIPS指令集的FPGA——CPU实现

## ALU
## 单周期
## 多周期
TodoList
all 

## 翻译器

TodoList
* 输出filter选项
* 增加更多指令支持
* 优化指令编号

ChangeLog
* 1.1.2：
    - 使用自己写的str2int函数处理输入中的数字字符串，支持十进制二进制和十六进制
    - 修正错误输出时行号差1的错误
* 1.1.1:
    - lui,ori,or 支持
* 1.1.0:
    - split():不会再自动增加最后的空字符串了
    - 增加and,andi,sll,srl,支持
    - beq支持前溯了
* 1.0.0:
    - 基本功能实现，基本无bug
    - 实现了add,sub,lw,sw,slt,addi,beq,j,jr,jal
* 0.9.0:
    - 不能按照标号寻找
    - 基本功能实现，bug尚存

## 汇编代码

* 使用轮询查看UART输入
* 两个输入计算最大公约数
* UART输入两个8Bits操作数在数码管上显示
* 结果显示到LED上
