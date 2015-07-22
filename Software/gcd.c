/*
Filename : gcd.c
Description : C gcd C51_LIKE style
Release : 7/22/2015
Encoding : utf-8
*/

// 寄存器映射
sfr TH 0x40000000
sfr TL 0x40000004
sfr TCON 0x40000008
sfr leds 0x4000000C
sfr UART_CON 0x40000020
sfr UART_TXD 0x40000018
sfr UART_RXD 0x4000001C
sfr BCD 0x40000014

int $t1,$t2;
int $t7;//数码管译码位置选择
int DATA[16];//数码管译码

void main(){
    TCON = 0x00000000;
    TH = 0xFFFFF000;
    TL = 0xFFFFFFFF;
    $t7 = 0x10;
    UART_CON = 0x00000000;
    while(UART_CON^3==0);
    $t1=UART_RXD&0x000000FF;
    while(UART_CON^3==0);
    $t2=UART_RXD&0x000000FF;
    TCON = 0x00000003;
    while($t1!=$t2){
        if($t1>$t2)
            $t1-=$t2;
        else
            $t2-=$t1;
    }
    UART_TXD = $t1;
    while(UART_CON^2==0);
    leds = $t1;
}

void time() interrupt 1 //Timer
{
    TCON &= 0xFFFFFFF9;//关闭定时器中断
    //翻译
    if($t7==0x100)BCD=DATA[$t1&0x0000000F]+$t7;
    if($t7==0x200)BCD=DATA[$t1&0x000000F0]+$t7;
    if($t7==0x400)BCD=DATA[$t2&0x0000000F]+$t7;
    if($t7==0x800)BCD=DATA[$t2&0x000000F0]+$t7;
    $t7 = $t7<<1;
    if($t7==0x1000)$t7=0x10;
    TCON |= 0x00000002;//打开定时器中断
}
