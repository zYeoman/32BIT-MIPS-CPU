% 编译器与汇编代码
% 庄永文 2013011208
% 2015.7
<!-- UsingPandoc: pandoc Compiler.md -\-latex-engine=xelatex -o Compiler.pdf -\-template=pm-template1.latex -\-listings -H listings-setup.tex -->

## 编译器(庄永文)

### 实验目的

设计一个简单的编译程序，能够将简单的汇编代码编译为机器码。

### 设计方案

首先从纯文本文件(`.*`)中读入所有行，然后对每行进行处理。主要处理流程是将每行去掉标号(`:`前的部分)，去掉注释(`#`后的部分)，然后再取出每一行开头语结尾的空格，最后得到的不是空行的话就进行分词处理，将每一行汇编语句根据` ,()`分解成几个部分，包括开头的命令部分和后边的寄存器部分，然后判断命令类型进行处理。下面将依次展示整个程序工作的流程。

### 关键代码

* `main`函数部分:
    - 在`main`函数部分主要进行的是对命令行输入的命令进行解析，并进行相应的操作。
    - 命令行命令包括:帮助`-h,--help`，版本号`-v,--version`，设置输出格式`-f,--format`，以及输入输出文件名。
    - 具体代码如下：

    ``` {.cpp .numberLines}
    // main: just deal with the argv
    int main(int argc, char const *argv[]){
        short life;
        //life is short, why I use cpp?
        if (argc==1){
            showHelp(argv);
        }
        else if(argc==2){
            string options = argv[1];
            if (options=="-h"||options=="--help"){
                showHelp(argv);
            }
            else if(options=="-v"||options=="--version"){
                cout<<"Copyright (C) Yeoman Zhuang. All rights reserved."<<endl;
                cout<<"MIPS Compiler: from MIPS to HEX"<<endl;
                cout<<"Version: "<<VERSION<<endl;
            }
        }
        else{
            string options = argv[1];
            string fmt = "%08X %08X";
            int source, output;
            if(options=="-f"||options=="--format"){
                fmt = argv[2];
                source = 3;
                output = 4;
            }
            else{
                source = 1;
                output = 2;
            }
            ifstream sourceFile(argv[source]);
            ofstream outputFile(argv[output]);
            if (!sourceFile){
                cerr<<"Error: Can not open source file "<<argv[1]<<endl;
                return 1;
            }
            else if (!outputFile){
                cerr<<"Error: Can not create output file "<<argv[2]<<endl;
                return 1;
            }
            else{
                vector < string > content;
                int line = 0;
                for (string tmp; getline(sourceFile, tmp);){
                    content.push_back(tmp);
                }
                for (unsigned int i = 0; i < content.size(); i++){
                    if (!trans(outputFile, content, i, line, fmt))line++;
                }
            }
        }
        return 0;
    }
    ```

* `trans`函数
    - 输入包括输出流引用，内容链表，当前行数，当前的有效行数，以及输出格式。其中输出格式`fmt`是可选的，默认值是`%08X %08X`（即`PC`和`Instruction`都是`8`位`16`进制数）
    - 输出表明此行是否有效，为`0`则此行有效。
    - 在此函数中进行的是把每一行的汇编代码转换成32位操作数，目前并不支持一行内有多行语句。注意到在`c++`中，`int`的大小就是32位，这样可以直接将操作数存入一个`int`类型的数`Instruction`内。在这个函数中的主要操作是对一行汇编代码进行预处理以后判断是否有错误，并翻译成32位操作数，与32位的PC值共同按照`fmt`的输出格式返回。
    - 具体代码如下：

    ```{.cpp .numberLines}
    // trans asm string to number string
    // output: ofstream, content: the asm data, index: now , line: valid line, fmt: output format
    int trans(ofstream &output, vector<string>&content, int index, int line, string fmt = (string)"%08X %08X"){
        vector<string> ret;
        if (content[index]==""){
            return 1;
        }//Discard ""
        else{
            string thisLine = content[index];
            //进行预处理
            // process thisLine
            comment(thisLine);  //移除注释
            cut(thisLine);      //移除标号
            trim(thisLine);     //移除空白

            if (thisLine == ""){//无视空行
                return 2;       
            }
            int instruct;
            int opt;
            split(thisLine, (string)" ,()", ret);   //分解
            opt = str2int(ret[0]);                  //判断操作数是否正确
            int opn = (unsigned int)opt < 29 ? 4 : 2;
            opn = (opt == 11 ? 3 : opn);
            opn = (opt == 32 ? 1 : opn);
            if (ret.size() != opn){
                cerr << "Error Instruction: Line " << index + 1 << " incorrect num of register" << endl;
                cerr << thisLine << "  " << ret.size() << endl;
                exit(2);
            }
            int tmp = 0;
            unsigned int lineNum = 0;
            //开始翻译
            try{
                switch (opt){
                //add sub and slt
                case 0:
                case 1:
                case 2:
                case 5:instruct = 0x20 + opt * 2 + (str2int(ret[1]) << 11) + (str2int(ret[2]) << 21) + (str2int(ret[3]) << 16);
                    break;
                //lw sw
                case 3:instruct = (0x23 << 26) + (str2int(ret[1]) << 16) + (str2int(ret[3]) << 21) + (str2int(ret[2]));
                    break;
                case 4:instruct = (0x2B << 26) + (str2int(ret[1]) << 16) + (str2int(ret[3]) << 21) + (str2int(ret[2]));
                    break;
                //addi
                case 6:instruct = (8 << 26) + (str2int(ret[1]) << 16) + (str2int(ret[2]) << 21) + ((str2int(ret[3]))&0x0000FFFF);
                    break;
                //sll
                case 7:instruct = (str2int(ret[1]) << 11) + (str2int(ret[2]) << 16) + (str2int(ret[3]) << 6);
                    break;
                //...case : Instruction = ...//详情见代码文件，此处为节省篇幅略去一部分。此处根据命令的编号生成Instruction。
                default:
                    cerr << "Error Instruction: Line " << index + 1 << "No such Instruction \"" << ret[0] << "\"" << endl;
                    exit(0);
                    break;
                }
            }//抛出异常
            catch (string s){
                cerr << "Error Register: Line" << index + 1 << "No such Register \"" << s << "\"" << endl;
                cerr << thisLine << endl;
                exit(1);
            }
            char opcode[100];
            if(fmt.find("%d") == fmt.npos) line = line * 4;
            sprintf(opcode,fmt.c_str(),line,instruct);
            output << opcode << endl;
        }
        return 0;
    }
    ```

* 其他的函数，具体代码见[Compiler文件](./Software/Compiler.cpp)。
    - `trim(&str)`          移除开头结尾处空格。修改源字符串
    - `cut(&str)`           移除标号。修改源字符串
    - `comment(&str)`       移除注释。修改源字符串
    - `str2int(&str)`       将汇编命令转换成数字，支持类似`add`等命令以及`$zero`等寄存器以及十六进制、十进制、二进制的字符串数字。
    - `find()`              查找标号所在有效行数
    - `split()`             分解每一行

### 文件清单

* `Compiler.cpp`  代码文件
* `Compiler.exe`  程序文件

### 测试结果以及分析

测试命令为 `Compiler -f "7'd%d: instruction = 32'h%08X;" gcd.asm gcd.hex`。最后结果与使用`MARS`结果是一致的。

### 调试情况以及思想体会

调试过程就是对着MARS产生的操作数对照，主要思路是对的，各种BUG基本上都是Instruction计算出现的问题。基本上还是很简单的。
在写这个编译器的时候，其实一开始写的是帮助和版本号的内容。后来是一步一步地增加命令的支持和`DEBUG`，这样可以保证不会出很大的`BUG`，只是零零碎碎的修补和增添特性就可以了。写这个编译器也算是锻炼了写命令行程序的能力，同时对C++的抛出异常等等有了更深的认识，能够有基本的错误提示了，也是很有成就感的。
在写编译器的时候也相当于复习了一遍`MIPS`指令集，受益匪浅。
编译器是比较简单的，但是到了最后验收的时候功能依然没有达到完美，首先`MIPS`指令集的支持就不是很完全，很多指令支持其实是因为写汇编代码时需要用到才有的，还有输出格式的问题也是因为在写汇编语言的时候需要这样子的代码才有了这样子的功能的。总之，就是一个用户导向的应用。

## 汇编代码(庄永文)

### 实验目的

设计一个计算两个整数的最大公约数的汇编程序，使用设计的编译程序得到机器码，要求通过 `UART` 输入两个 `8bits` 的操作数，通过七段数码管显示十六进制的操作数（ 必须通过定时器中断以扫描的形式进行数码管显示，七段译码采用软件译码，定时中断频率为扫描频率），通过 `8` 个 `LEDs` 显示计算结果并通过 `UART` 输出，自行设计接口逻辑。

### 设计方案

* 求最大公约数：求最大公约数其实是这个汇编代码中最简单的部分，使用更相减损法来计算，也就是每次递归都是用大数与小数的差来替换较小的数，直到两个数相等的时候这两个数就是原来的两个数的最大公约数。具体代码如下：
* 数码管扫描显示：数码管扫描显示需要使用中断，而且每次只能显示一个数字，同时数码管显示数字与七段的通断没有什么规律，只能一个一个判断。我的解决方法是在程序的一开始就把数码管显示的每个数字存入存储器中相应的位置，然后需要显示的时候再到存储器中取出七段译码的数值。这也是中断处理的主要内容，具体代码如下：
* UART接受与发送：这里UART是比较简单的，使用轮询的方式来获得UART的输入。例如：

### 关键代码

因为汇编代码不是很长，因此就在这里直接全部贴在下面了。
[gcd.asm](./gcd.asm)

```{.mips .numberLines}
# Filename : gcd.asm
# Description : MIPS code
# Release : 7/22/2015
# Encoding : urf-8

# a = $t1,b = $t2，result = $t1
# $s0=外设地址指针
# $s1=数码管译码位置选择
# $s2=数码管位置
# $s3=数码管译码指针
# $t3=TH
# $t4=TL
# $t5=TCON
# $t6=UART_CON
# $t7=UART_TXD
# $t8=UART_RXD
# $t9=BCD

# 这是前三行，第一行是正式执行，第二行是中断，第三行是异常(进入异常后将会无限循环)
firstLine:
    j init
    j INTERUPT
Error:
    j Error 

# 正常程序开始
init:
    #将之前PC的最高位置零，只有jr,jalr能改最高位
    addi $t0,$zero,20
    jr $t0
    # 外设地址指针
    lui $s0,0x4000
    # 设置计时器TH,TL以及TCON
    addi $t3,$zero,-4096
    sw $zero,8($s0) #TCON = 0
    sw $t3,0($s0)   #TH=0xFFFFF000
    addi $t4,$zero,-1
    addi $s1,$zero,0#$s1=0
    addi $s2,$zero,256   #$s2=0x100
    sw $t4,4($s0)   #TL=0xFFFFFFFF
    sw $zero,32($s0)#UART_CON=0

# 数码管显示数字
    addi $s3,$zero,0
    addi $t0,$zero,0x40
    sw $t0,0($s3)
    addi $t0,$zero,0x79
    sw $t0,4($s3)
    addi $t0,$zero,0x24
    sw $t0,8($s3)
    addi $t0,$zero,0x30
    sw $t0,12($s3)
    addi $t0,$zero,0x19
    sw $t0,16($s3)
    addi $t0,$zero,0x12
    sw $t0,20($s3)
    addi $t0,$zero,0x02
    sw $t0,24($s3)
    addi $t0,$zero,0x78
    sw $t0,28($s3)
    addi $t0,$zero,0x00
    sw $t0,32($s3)
    addi $t0,$zero,0x10
    sw $t0,36($s3)
    addi $t0,$zero,0x08
    sw $t0,40($s3)
    addi $t0,$zero,0x03
    sw $t0,44($s3)
    addi $t0,$zero,0x46
    sw $t0,48($s3)
    addi $t0,$zero,0x21
    sw $t0,52($s3)
    addi $t0,$zero,0x06
    sw $t0,56($s3)
    addi $t0,$zero,0x0E
    sw $t0,60($s3)

# 读取第一个UART数据(8bits)
get1:
    lw $t6,32($s0)
    andi $t6,$t6,8
    beq $t6,$zero,get1
    lw $t1,28($s0)

# 读取第二个UART数据(8bits)
get2:
    lw $t6,32($s0)
    andi $t6,$t6,8
    beq $t6,$zero,get2
    lw $t2,28($s0)

filter:
    addi $t5,$zero,3
    # UART只取8bits数据
    andi $t1,$t1,255#0xFF
    andi $t2,$t2,255#0xFF
    # 存下数据用于数码管显示，以下计算中只改变$t1和$t2
    add $a0,$zero,$t1
    add $a1,$zero,$t2
    # 开TCON中断
    sw $t5,8($s0)


# 开始最大公约数主函数
main:
    beq $t1,$t2,end         # 当两个数相等时停止
    slt $t6,$t1,$t2         # 判断大小，大数等于大数减小数，循环
    beq $t6,$zero,high      # 更相减损法
    j low
high:
    sub $t1,$t1,$t2
    j main
low:
    sub $t2,$t2,$t1
    j main
end:
    sw $t1,24($s0)         # 结束时UART发送 
TX:
    lw $t6,32($s0)         # 读取UART状态
    andi $t6,$t6,4
    beq $t6,$zero,TX       # 未发送完成时循环
result:
    sw $t1,12($s0)         # 发送完毕后又加上LED 显示
    j get1                 # 等待下一次运算


#中断处理部分
INTERUPT:
    lw $t5,8($s0)
    addi $t8,$zero,-7
    and $t5,$t5,$t8 
    sw $t5,8($s0)       #关闭中断
    #在这里译码数码管显示
    
    beq $s1,$zero,bcd1
    addi $s6,$s1,-1
    beq $s6,$zero,bcd2
    addi $s6,$s6,-1
    beq $s6,$zero,bcd3
    addi $s6,$s6,-1
    beq $s6,$zero,bcd4
bcd1:
    andi $t0,$a0,0xF
    sll $t0,$t0,2
    j endbcd
bcd2:
    andi $t0,$a0,0xF0
    srl $t0,$t0,2
    j endbcd
bcd3:
    andi $t0,$a1,0xF
    sll $t0,$t0,2
    j endbcd
bcd4:
    andi $t0,$a1,0xF0
    srl $t0,$t0,2
    j endbcd
    #数码管译码结束
endbcd:
    add $s4,$t0,$s3
    lw $s5,0($s4)
    add $s5,$s5,$s2
    sw $s5,20($s0)
    #将译码结果显示
    addi $s1,$s1,1
    addi $t0,$zero,4
    beq $s1,$t0,reset
    sll $s2,$s2,1
    j exit
reset:
    addi $s1,$zero,0
    addi $s2,$zero,256
exit:
    lw $t5,8($s0)
    ori $t5,$t5,2
    sw $t5,8($s0)
    jr $k0
```

### 仿真结果及分析

直接在MARS中仿真的话，需要修改一下MARS的设置，同时要把UART读取去掉改为直接赋值。最终结果是正确的，在放到单周期和多周期的处理器中运行的话仿真结果和实际验证结果也是正确的。

### 调试情况

因为这个汇编的代码也是比较简单的，因此最终也没有花多久时间来调试，主要调试的部分其实是扫描显示的时候使能位设置错了，应该是第`9~12`位，一开始应该是`256`，结果设置成`16`了。最终还是通过`ModelSim`仿真才发现的问题。

在写汇编代码的时候，一开始只写了求最大公约数的代码，至于中断处理以及UART等等都是没有什么头绪的。后来在和同组的张传奕同学交流以后，彻底搞明白了中断处理的流程，同时先写了一段仿照C51的C代码，再将这一段C代码翻译成汇编，这样子进度就一下子快了起来。其中那段C51_LIKE的代码为[gcd.c](./gcd.c)

### 思想体会
* 分配好任务后要多沟通，不能自己一个人单干；要及时沟通进度和互相之间的接口。
* 写汇编之前可以先写一个C的代码然后人工翻译成汇编，这样更容易写也更容易理解工作的流程。
* 翻译器代码可以先只实现几个功能，采用迭代式开发的方式。