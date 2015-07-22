module Register (
    input clk, rst,
    input RegWrite, 
    input [4:0] r1, r2, w, // read & write addr
    input [31:0] wdata, // write data
        PC,             // PC for ID stage instruction
    output [31:0] rdata1, rdata2
);
    reg [31:0] Reg[31:1]; // 32 registers
    integer i;
    
    assign rdata1 = (r1==5'b0) ? 32'b0 : Reg[r1]; // $zero always 0
    assign rdata2 = (r2==5'b0) ? 32'b0 : Reg[r2];

    always @ (posedge clk or posedge rst) begin //?posedge clk or posedge rst?
        if (rst)                               // posedge rst
            for(i=1;i<32;i=i+1) Reg[i]<=32'b0;  // clear regs
        else begin 
            if ( RegWrite && ~(w==5'b0) )      // posedge clk
                Reg[w] <= wdata;
        end
    end
endmodule
