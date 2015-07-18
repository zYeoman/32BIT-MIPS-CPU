/*
Filename : gcd.c
Description : C gcd
Release : 7/18/2015
*/
sfr TH 0x40000000
sfr TL 0x40000004
sfr TCON 0x40000008

sfr UART_CON 0x40000020
sfr UART_TXD 0x40000018
sfr UART_RXD 0x4000001C
sfr BCD 0x40000014

int $t1,$t2;
int $t7;//数码管译码位置选择
int DATA[16];//数码管译码

void main(){
    TCON = 0x00000000;
    TH = 0x0000FFFF;
    TL = 0xFFFFFFFF;
    $t7 = 0x00010000;
    UART_CON = 0x00000000;//?可以么？
    while(1){
        while(UART_CON^3==0)$t1=UART_RXD&0x000000FF;
        while(UART_CON^3==0)$t1=UART_RXD&0x000000FF;
        while($t1!=$t2){
            if($t1>$t2)
                $t1-=$t2;
            else
                $t2-=$t1;
        }
        TCON = 0x00000003;
        UART_TXD = $t1;
        while(UART_CON^2==0);
    }
}

void time() interrupt 1 //Timer
{
    TCON &= 0xfffffff9;//关闭定时器中断
    //翻译
    BCD=DATA[$t1&0x0000000F]+$t7;
    $t7 = $t7<<1;
    if($t7==0)$t7=0x00010000;
}
