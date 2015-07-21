module Pipeline_tb ();
    reg clk, rst_n, rx;
    reg [7:0] switch;
    wire tx;
    wire [7:0] led;
    wire [6:0] digi[3:0];
    CPU cpu(
        .clk(clk), .rst_n(rst_n),
        .switch(switch),
        .led(led),
        .rx(rx), .tx(tx), 
        .digi_out1(digi[0]), 
        .digi_out2(digi[1]), 
        .digi_out3(digi[2]), 
        .digi_out4(digi[3])
    );

    initial begin
        clk = 1'b1;
        rst_n = 1'b1;
        rx = 1'b1;
        switch = 8'h69;
    #1  rst_n = 1'b0;
    #1  rst_n = 1'b1;
    #1  rx = 1'b0;  // start
    #104166 rx = 1'b0;
    #104166 rx = 1'b1;
    #104166 rx = 1'b0;
    #104166 rx = 1'b1;
    #104166 rx = 1'b0;
    #104166 rx = 1'b0;
    #104166 rx = 1'b0;
    #104166 rx = 1'b0;
    #104166 rx = 1'b1;// end
    #104166 rx = 1'b0;// start
    #104166 rx = 1'b1;
    #104166 rx = 1'b0;
    #104166 rx = 1'b1;
    #104166 rx = 1'b0;
    #104166 rx = 1'b0;
    #104166 rx = 1'b0;
    #104166 rx = 1'b0;
    #104166 rx = 1'b0;
    #104166 rx = 1'b1;// end
    end

    initial
        forever #18.5 clk <= ~clk;
endmodule