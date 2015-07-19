module UART_TX(clk,TX,DATA,EN,STATUS,END,rst);

    input clk;              //ϵͳʱ��
    input rst;
    input [7:0]DATA;        //��������
    input EN;               //ʹ���ź�
    output reg TX;          //��������
    output reg STATUS;      //TX״̬����ʱ����
    output reg END;         //TX������ϣ���һ���ߵ�ƽ����
    //����TXʱ���������ʷ�����

    wire clk_9600;         //����ʱ��

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
        END<=0;
        TX_num<=4'h0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            STATUS<=1;
            TX_DATA<=8'h00;
        end
        else if (EN) begin   //��⵽EN�ź�
            TX_DATA<=DATA;
            STATUS<=0;
        end
        else if (TX_num==4'hA) begin
            STATUS<=1;
        end
    end

    always @(posedge clk or posedge rst) begin//��������
        if (rst) begin
            // reset
            TX<=1'b1;
            TX_num<=0;
            END<=1'b0;
        end
        else if (clk_9600&&(~STATUS)) begin
            TX_num<=TX_num+4'h1;
            case(TX_num)
                4'h0: TX<=1'b0;         //��ʼλ
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
            END<=1'b1;
        end
        else END<=0;
    end
endmodule

module UART_RX(clk,RX,DATA,STATUS,rst);
    input clk;              //ϵͳʱ��
    input RX;               //��������
    input rst;
    output reg [7:0]DATA;   //8λ���ݴ洢
    output reg STATUS;      //RX״̬���յ�һ���ֽں�ͷ���һ���ߵ�ƽ����

    wire clk_9600;          //�м������
    reg start;              //����RXʱ���������ʷ�����
    reg [7:0]temp_DATA;
    reg [3:0]RX_num;        //�����ֽ���

    BaudGen RXbg(.clk(clk),
        .clk_9600(clk_9600),
        .start(start),
        .rst(rst));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            start<=1'b0;
        end
        else if (~RX) begin
            start<=1'b1;    //���������ʷ�����//��ʼ����
        end
        else if (RX_num==4'hA)begin
            start<=1'b0;    //�رղ����ʷ�����
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
    // clk should be 27MHz
    // start, rst, �ߵ�ƽ��Ч
    // ����9600Hz���� 
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
        // Counter, period is 1/9600s
        if(rst) begin
            state<=0;
        end
        else if(state==2812 || !start) begin//2812
            state<=0;
        end
        else begin
            state<=state+16'd1;        
        end
    end

    always @(posedge clk or posedge rst) begin
        // generate 50%-duty 9600Hz clock, half the counter
        if (rst) begin
            clk_9600<=0;
        end
        else if (state==1406) begin//1406
            clk_9600<=1;
        end
        else begin
            clk_9600<=0;
        end
    end
endmodule
