`timescale 1ns/1ns

module UART(clk_50M,rst,RX,TX);

input clk_50M;
input rst;
input RX;
output TX;

wire [7:0]dataR;
wire [7:0]dataT;
wire statusRX;
wire statusTX;
wire start_RX;
wire rst_r;
wire RXclk;
wire TXclk;

assign dataT=dataR[7]?~dataR:dataR;

assign rst_r=~rst;

UART_TX tx(.clk(clk_50M),
    .TX(TX),
    .DATA(dataT),
    .EN(statusRX),
    .STATUS(statusTX),
    .rst(rst_r));

UART_RX rx(.clk(clk_50M),
    .RX(RX),
    .DATA(dataR),
    .STATUS(statusRX),
    .rst(rst_r)
    );

endmodule

module UART_TX(clk,TX,DATA,EN,STATUS,rst);

input clk;              //系统时钟
input rst;
input [7:0]DATA;        //发送数据
input EN;               //使能信号
output reg TX;          //发送数据
output reg STATUS;      //TX状态，高时空闲
//发送TX时启动波特率发生器

wire clk_9600;         //发送时钟

BaudGen TXbg(.clk(clk),
    .clk_9600(clk_9600),
    .start(~STATUS),
    .rst(rst));

reg [3:0]TX_num;
reg [7:0]TX_DATA;

initial
begin
    TX<=1'b1;
    STATUS<=1;
    TX_num<=4'h0;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // reset
        STATUS<=1;
        TX_DATA<=8'h00;
    end
    else if (EN) begin   //检测到EN信号
        TX_DATA<=DATA;
        STATUS<=0;
    end
    else if (TX_num==4'hA) begin
        STATUS<=1;
    end
end

always @(posedge clk or posedge rst) begin//发送数据
    if (rst) begin
        // reset
        TX<=1'b1;
        TX_num<=0;
    end
    else if (clk_9600&&(~STATUS)) begin
        TX_num<=TX_num+4'h1;
        case(TX_num)
            4'h0: TX<=1'b0;         //起始位
            4'h1: TX<=TX_DATA[0];
            4'h2: TX<=TX_DATA[1];
            4'h3: TX<=TX_DATA[2];
            4'h4: TX<=TX_DATA[3];
            4'h5: TX<=TX_DATA[4];
            4'h6: TX<=TX_DATA[5];
            4'h7: TX<=TX_DATA[6];
            4'h8: TX<=TX_DATA[7];
            4'h9: TX<=1'b1;
            default: ;
        endcase
    end
    else if (TX_num==4'hA) begin
        TX_num<=4'h0;
        TX<=1'b1;
    end
end

endmodule

module UART_RX(clk,RX,DATA,STATUS,rst);

input clk;              //系统时钟
input RX;               //接受数据
input rst;
output reg [7:0]DATA;   //8位数据存储
output reg STATUS;      //RX状态，收到一个字节后就发生一个高电平脉冲

BaudGen RXbg(.clk(clk),
    .clk_9600(clk_9600),
    .start(start),
    .rst(rst));

wire clk_9600;          //中间采样点
reg start;              //接受RX时启动波特率发生器
reg [7:0]temp_DATA;
reg [3:0]RX_num;        //接受字节数

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // reset
        start<=1'b0;
    end
    else if (~RX) begin
        start<=1'b1;    //开启波特率发生器//开始接受
    end
    else if (RX_num==4'hA)begin
        start<=1'b0;    //关闭波特率发生器
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // reset
        STATUS<=0;
        DATA<=8'h00;
        temp_DATA<=8'h00;
        RX_num<=4'h0;
    end
    else if (clk_9600&&start) begin
		RX_num<=RX_num+4'h1;
        case(RX_num)
            4'h1: temp_DATA[0] <= RX;
            4'h2: temp_DATA[1] <= RX;
            4'h3: temp_DATA[2] <= RX;
            4'h4: temp_DATA[3] <= RX;
            4'h5: temp_DATA[4] <= RX;
            4'h6: temp_DATA[5] <= RX;
            4'h7: temp_DATA[6] <= RX;
            4'h8: temp_DATA[7] <= RX;
            default: ;
        endcase
    end
    else if(RX_num==4'hA)begin
		RX_num<=0;
        STATUS<=1;
        DATA<=temp_DATA;
	end
    else STATUS<=0;
end

endmodule

module BaudGen(clk,clk_9600,start,rst);
// start, rst, 高电平有效
// 产生9600Hz脉冲 
input rst;
input start;
input clk;
output reg clk_9600;
reg [15:0]state;

initial
begin
    clk_9600 <= 0;
    state <= 0;
end

always@(posedge clk or posedge rst) begin
    //divide,generate 9600Hz pulse
    if(rst) begin
        state<=0;
    end
    else if(state==5208 || !start) begin
        state<=0;
    end
    else begin
        state<=state+16'd1;        
    end
end

always @(posedge clk or posedge rst) begin
    //
    if (rst) begin
        clk_9600<=0;
    end
    else if (state==2604) begin
        clk_9600<=1;
    end
    else begin
        clk_9600<=0;
    end
end

endmodule
