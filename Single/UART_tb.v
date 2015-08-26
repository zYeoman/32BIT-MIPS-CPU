module recv_tb ();
    reg clk, 
        baud16, 
        tx, 
        rst;
    wire [7:0] data;
    wire status, 
         s;
    initial begin
        clk = 1'b1;
        baud16 = 1'b1;
        tx = 1'b1;
        forever #1 clk = ~clk;
    end
    initial
        forever #324 baud16 = ~baud16;
    initial begin
        #10400 tx=1'b0;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b0;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b0;
        #10416.6 tx=1'b0;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b1;
        #30000 tx=1'b0;
        #10416.6 tx=1'b0;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b0;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b0;
        #10416.6 tx=1'b1;
        #10416.6 tx=1'b0;
        #10416.6 tx=1'b1;
    end
    UART_RX receiver(.clk(clk), .RX(tx), .DATA(data), .STATUS(status), .rst);
endmodule