# a = $t1,b = $t2,return $t3
    addi $t1,100
    addi $t2,48
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


#unsigned int gcd(unsigned int a, unsigned int b){
#   if(b == 0)return a;
#   else return gcd(b, a - b)
#}