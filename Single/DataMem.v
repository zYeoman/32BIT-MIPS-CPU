module DataMem (
    input clk, rst, 
    input MemWrite, MemRead, 
    input rx, tx, 
    input [31:0] addr, wdata, 
    input [7:0] switch, 
    output reg [31:0] rdata, 
    output reg [7:0] led, 
    output reg [11:0] digi, 
    output irq
);
    parameter RAM_SIZE = 256;
    parameter RAM_BIT  = 8;  // 2^8 = 256
    reg [31:0] DATA[RAM_SIZE-1:0];
    reg [31:0] TH, TL;
    reg [2:0] TCON;
    reg [7:0] UART_RXD, UART_TXD;
    reg [1:0] UART_CON;
    reg enable; // UART enable
    wire rx_s, tx_s; // UART status
    wire [7:0] rx_d; // receive data
    integer i;

    assign irq = TCON[2];

    // read
    always @ (*) begin
        if(MemRead) begin
            case (addr)
                32'h4000_0000: rdata <= TH;
                32'h4000_0004: rdata <= TL;
                32'h4000_0008: rdata <= {29'b0, TCON};
                32'h4000_000c: rdata <= {24'b0, led};
                32'h4000_0010: rdata <= {24'b0, switch};
                32'h4000_0014: rdata <= {20'b0, digi};
                32'h4000_0018: rdata <= {24'b0, UART_TXD};
                32'h4000_001c: rdata <= {24'b0, UART_RXD};
                32'h4000_0020: rdata <= {28'b0, UART_CON, 2'b0};
                default: begin 
                    rdata <= ( (addr[RAM_BIT+1:2]<RAM_SIZE) && ~addr[30] ) ? 
                    DATA[ addr[RAM_BIT+1:2] ] : 32'b0;
                end
            endcase
        end else
            rdata <= 32'b0;
    end

    // write
    always @ (posedge clk or posedge rst) begin
        if (rst) begin                                 // posedge rst
            for(i=0;i<256;i=i+1) DATA[i]<=32'b0;
            TH <= 32'b0;
            TL <= 32'b0;
            TCON <= 3'b0; // all disable
        end else if(TCON[0]) begin // TIM enable
            if(TL==32'hffff_ffff) begin
                TL <= TH;
                TCON[2] <= TCON[1] ? 1'b1 : 1'b0;
            end else
                TL <= TL + 1'b1;
        end else if(MemWrite) begin
            case (addr)
                32'h4000_0000: TH <= wdata;
                32'h4000_0004: TL <= wdata;
                32'h4000_0008: TCON <= wdata[2:0];
                32'h4000_000C: led <= wdata[7:0];
                32'h4000_0014: digi <= wdata[11:0];
                default: if ( (addr[RAM_BIT+1:2]<RAM_SIZE) && ~addr[30] )
                    DATA[ addr[RAM_BIT+1:2] ] <= wdata;
            endcase
        end
    end

    // UART control
    UART_RX uartrx(
        .clk(clk), .rst(rst), 
        .RX(rx), 
        .DATA(rx_d),
        .STATUS(rx_s)
    );
    UART_TX rarttx(
        .clk(clk), .rst(rst), 
        .DATA(UART_TXD),
        .EN(enable), 
        .TX(tx), 
        .STATUS(tx_s)
    );
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            UART_CON <= 2'b0;
            UART_TXD <= 8'b0;
            UART_RXD <= 8'b0;
        end else begin
            if(MemWrite)
                case (addr)
                    32'h4000_0018: begin
                            UART_TXD <= wdata[7:0];
                            enable <= 1'b1;
                        end
                    32'h4000_0020: UART_CON <= wdata[3:2];
                    default: ;
                endcase
            if(MemRead)
                case (addr)
                    32'h4000_0018: UART_CON[0] <= 1'b0;
                    32'h4000_001c: UART_CON[1] <= 1'b0;
                    default: ;
                endcase
            if(rx_s) begin
                UART_RXD <= rx_d;
                UART_CON[1] <= 1'b1;
            end
            if(~tx_s) begin
                UART_CON[0] <= 1'b1;
                enable <= 1'b0;
            end
        end
    end
endmodule