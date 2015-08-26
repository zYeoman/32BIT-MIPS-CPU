module Reg_tb ();
    reg clk, rst;
    reg RegWrite; 
    reg [4:0] r1, r2, w; 
    reg [31:0] wdata; 
    wire [31:0] rdata1, rdata2;
    Register Reg(
        .clk(clk), .rst(rst),
        .RegWrite(RegWrite), 
        .r1(r1), .r2(r2), .w(w),
        .wdata(wdata),
        .rdata1(rdata1), .rdata2(rdata2)
    );

    initial begin
        clk = 1'b1;
        rst = 1'b0;
    #10 rst = 1'b1;
    #10 rst = 1'b0;
        w = 5'd26;
        wdata = 32'h0000006c;
        RegWrite = 1'b1;
        r1 = 5'd26;
    #10 w = 5'd0;
        wdata = 32'h1;
    end

    initial
        forever #5 clk <= ~clk;
endmodule