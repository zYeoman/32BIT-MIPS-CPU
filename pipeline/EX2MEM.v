/*
Filename : EX2MEM.v
Compiler : Quartus II
Description : EX to MEM register
INPUT : clk, rst, EN, all active high
        RegWrite_In, MemWrite_In, MemRead_In, 
        [31:0] PC_In, ALUOut_In, 
        [4:0] AddrC_In, 
        [3:0] PCSrc_In, 
        [1:0] MemtoReg_In, 
OUTPUT : RegWrite_Out, MemWrite_Out, MemRead_Out, 
        [31:0] PC_Out, ALUOut_Out, 
        [4:0] AddrC_Out, 
        [3:0] PCSrc_Out, 
        [1:0] MemtoReg_Out, 
Author : Yeoman Zhuang
Release : *
*/

module EX2MEM(
    input clk, rst, flush, 
    input RegWrite_In, MemWrite_In, MemRead_In, 
<<<<<<< HEAD:pipeline/EX2MEM.v
    input [31:0] PC_In, ConBA_In, ALUOut_In, 
    // !!! AddrC i.e. EX2MEM_Rd
=======
    input [31:0] PC_In, ALUOut_In, 
>>>>>>> origin/master:pipline/EX2MEM.v
    input [4:0] AddrC_In, 
    input [3:0] PCSrc_In, 
    input [1:0] MemtoReg_In, 
    output reg RegWrite_Out, MemWrite_Out, MemRead_Out, 
    output reg [31:0] PC_Out, ALUOut_Out, 
    output reg [4:0] AddrC_Out, 
    output reg [3:0] PCSrc_Out, 
    output reg [1:0] MemtoReg_Out, 
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            RegWrite_Out <= 0;
            MemWrite_Out <= 0;
            MemRead_Out <= 0;
            PC_Out <= 0;
            ALUOut_Out <= 0;
            AddrC_Out <= 0;
            PCSrc_Out <= 0;
            MemtoReg_Out <= 0;
        end else 
            RegWrite_Out <= RegWrite_In;
            MemWrite_Out <= MemWrite_In;
            MemRead_Out <= MemRead_In;
            PC_Out <= PC_In;
            ALUOut_Out <= ALUOut_In;
            AddrC_Out <= AddrC_In;
            PCSrc_Out <= PCSrc_In;
            MemtoReg_Out <= MemtoReg_In;
<<<<<<< HEAD:pipeline/EX2MEM.v
=======
        end else begin
            RegWrite_Out <= RegWrite_Out;
            MemWrite_Out <= MemWrite_Out;
            MemRead_Out <= MemRead_Out;
            PC_Out <= PC_Out;
            ALUOut_Out <= ALUOut_Out;
            AddrC_Out <= AddrC_Out;
            PCSrc_Out <= PCSrc_Out;
            MemtoReg_Out <= MemtoReg_Out;
            
        end
>>>>>>> origin/master:pipline/EX2MEM.v
    end

endmodule
