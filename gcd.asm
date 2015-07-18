# a = $t1,b = $t2,return $t3


init:
    addi $t1,$zero,24
    addi $t2,$zero,60
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
