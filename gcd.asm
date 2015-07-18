# a = $t1,b = $t2,return $t3


init:
    #lui $s0,0x4000
    addi $t0,$zero,-4096
    sw $zero,8($s0) #TCOM = 0
    sw $t0,0($s0)   #TH=0xFFFFF000
    addi $t0,$zero,-1
    sw $t0,4($s0)   #TL=0xFFFFFFFF
    addi $t0,$zero,1
    addi $s1,$zero,0#$s1=0
    sll $t7,$t0,4   #$t7=0x10
    sw $zero,32($s0)#UART_CON=0

get1:
    lw $t0,32($s0)
    andi $t0,$t0,8
    beq $t0,$zero,get1
    lw $t1,28($s0)
    andi $t1,$t1,255#0xFF
get2:
    lw $t0,32($s0)
    andi $t0,$t0,8
    beq $t0,$zero,get2
    lw $t2,28($s0)
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
    addi $t0,$zero,3
    sw $t0,8($s0)
    sw $t1,24($s0)
TX:
    lw $t0,32($s0)
    andi $t0,$t0,4
    beq $t0,$zero,TX
    

INTERUPT:
    lw $t0,8($s0)
    addi $t8,$zero,-7
    and $t0,$t0,$t8
    sw $t0,8($s0)
    sll $t7,$t7,1
    addi $s1,$s1,1
    addi $t0,$zero,4
    beq $t7,$t0,reset
    jr $ra
reset:
    addi $s1,$zero,0
    addi $t0,$zero,1
    sll $t7,$t0,4
    jr $ra