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

firstLine:
    j init
    j INTERUPT
Error:
    j Error 

init:
    addi $t0,$zero,20
    jr $t0
    lui $s0,0x4000
    addi $t3,$zero,-4096
    sw $zero,8($s0) #TCON = 0
    sw $t3,0($s0)   #TH=0xFFFFF000
    addi $t4,$zero,-1
    addi $t0,$zero,1
    addi $s1,$zero,0#$s1=0
    sll $s2,$t0,4   #$s2=0x10
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

get1:
    lw $t6,32($s0)
    andi $t6,$t6,8
    beq $t6,$zero,get1
    lw $t1,28($s0)

get2:
    lw $t6,32($s0)
    andi $t6,$t6,8
    beq $t6,$zero,get2
    lw $t2,28($s0)

filter:
    andi $t1,$t1,255#0xFF
    andi $t2,$t2,255#0xFF

main:
    beq $t1,$t2,end
    slt $t6,$t1,$t2
    beq $t6,$zero,high
    j low
high:
    sub $t1,$t1,$t2
    j main
low:
    sub $t2,$t2,$t1
    j main
end:
    addi $t5,$zero,3
    sw $t1,24($s0)
    sw $t5,8($s0)
TX:
    lw $t6,32($s0)
    andi $t6,$t6,4
    beq $t6,$zero,TX
    
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
    and $t0,$t1,0xF
    sll $t0,$t0,2
    add $s4,$t0,$s3
    j endbcd
bcd2:
    and $t0,$t1,0xF0
    srl $t0,$t0,2
    add $s4,$t0,$s3
    j endbcd
bcd3:
    and $t0,$t2,0xF
    sll $t0,$t0,2
    add $s4,$t0,$s3
    j endbcd
bcd4:
    and $t0,$t2,0xF0
    srl $t0,$t0,2
    add $s4,$t0,$s3
    j endbcd
    #数码管译码结束
endbcd:
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
    addi $t0,$zero,1
    sll $s2,$t0,4
exit:
    lw $t5,8($s0)
    ori $t5,$t5,2
    sw $t5,8($s0)
    jr $k0
