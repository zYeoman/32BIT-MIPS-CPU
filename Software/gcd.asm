# a = $t1,b = $t2，result = $t1
# $s0=外设地址指针
# $s1=数码管译码位置选择
# $s2=数码管位置
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
    #译码数码管显示结束
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
    ori $t5,2
    sw $t5,8($s0)
    jr $k0
