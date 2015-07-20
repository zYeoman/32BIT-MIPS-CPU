/*
Filename : MEM2WB.v
Compiler : Quartus II
Description : MEM to WB register
INPUT : clk, rst, EN, all active high
        [31:0] PC_In, ALUOut_In, rdata_In, 
        [4:0] AddrC_In, 
        [3:0] PCSrc_In, 
        [1:0] MemtoReg_In, 
OUTPUT : RegWrite_Out
        [31:0] PC_Out, ALUOut_Out, rdata_Out, 
        [4:0] AddrC_Out, 
        [3:0] PCSrc_Out, 
        [1:0] MemtoReg_Out, 
Author : Yeoman Zhuang
Release : *
*/

module MEM2WB(
    input clk, rst, EN, 
    input RegWrite_In, 
    input [31:0] PC_In, ALUOut_In, rdata_In, 
    input [4:0] AddrC_In, 
    input [1:0] MemtoReg_In, 
    output reg RegWrite_Out, 
    output reg [31:0] PC_Out, ALUOut_Out, rdata_Out, 
    output reg [4:0] AddrC_Out, 
    output reg [1:0] MemtoReg_Out, 
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            RegWrite_Out <= 0;
            PC_Out <= 0;
            ALUOut_Out <= 0;
            AddrC_Out <= 0;
            MemtoReg_Out <= 0;
            rdata_Out <= 0;
        end
        else if (EN) begin
            RegWrite_Out <= RegWrite_In;
            PC_Out <= PC_In;
            ALUOut_Out <= ALUOut_In;
            AddrC_Out <= AddrC_In;
            MemtoReg_Out <= MemtoReg_In;
            rdata_Out <= rdata_In;
        end
        else begin
            RegWrite_Out <= RegWrite_Out;
            PC_Out <= PC_Out;
            ALUOut_Out <= ALUOut_Out;
            AddrC_Out <= AddrC_Out;
            MemtoReg_Out <= MemtoReg_Out;
            rdata_Out <= rdata_Out;
        end
    end

endmodule