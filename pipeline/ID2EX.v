/*
Filename : ID2EX.v
Compiler : Quartus II
Description : ID to EX register
INPUT : clk, rst, EN, all acitve high
        AluSrc1_In, AluSrc2_In, RegWrite_In, Branch_In, MemWrite_In, MemRead_In, 
        [31:0] PC_In, DataBusA_In, DataBusB_In, Imm_In,
        [4:0] Rd_In, Rt_In, Shamt_In
        [5:0] ALUFun_In, 
        [3:0] PCSrc_In, 
        [1:0] RegDst_In, MemtoReg_In, 
OUTPUT : AluSrc1_Out, AluSrc2_Out, RegWrite_Out, Branch_Out, MemWrite_Out, MemRead_Out, 
        [31:0] PC_Out, DataBusA_Out, DataBusB_Out, Imm_Out,
        [4:0] Rd_Out, Rt_Out, Shamt_Out
        [5:0] ALUFun_Out, 
        [3:0] PCSrc_Out, 
        [1:0] RegDst_Out, MemtoReg_Out, 
Author : Yeoman Zhuang
Release : *
*/

module ID2EX(
    input clk, rst, flush, 
    input AluSrc1_In, AluSrc2_In, RegWrite_In, Branch_In, Jump_In, MemWrite_In, MemRead_In, Sign_In,
    input [31:0] PC_In, DataBusA_In, DataBusB_In, Imm_In,
    input [4:0] Rd_In, Rt_In, Rs_In, Shamt_In, 
    input [5:0] ALUFun_In, 
    input [2:0] PCSrc_In, 
    input [1:0] RegDst_In, MemtoReg_In, 
    output reg AluSrc1_Out, AluSrc2_Out, RegWrite_Out, Branch_Out, Jump_Out, MemWrite_Out, MemRead_Out, Sign_Out,
    output reg [31:0] PC_Out, DataBusA_Out, DataBusB_Out, Imm_Out,
    output reg [4:0] Rd_Out, Rt_Out, Rs_Out, Shamt_Out, 
    output reg [5:0] ALUFun_Out, 
    output reg [2:0] PCSrc_Out, 
    output reg [1:0] RegDst_Out, MemtoReg_Out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            AluSrc1_Out <= 0;
            AluSrc2_Out <= 0;
            RegWrite_Out <= 0;
            Branch_Out <= 0;
            Jump_Out <= 0;
            MemWrite_Out <= 0;
            MemRead_Out <= 0;
            Sign_Out <= 0;
            PC_Out <= 0;
            DataBusA_Out <= 0;
            DataBusB_Out <= 0;
            Imm_Out <= 0;
            Rd_Out <= 0;
            Rt_Out <= 0;
            Rs_Out <= 0;
            ALUFun_Out <= 0;
            PCSrc_Out <= 0;
            RegDst_Out <= 0;
            MemtoReg_Out <= 0;
            Shamt_Out <= 0;
        end else if (flush) begin
            // reset
            AluSrc1_Out <= 0;
            AluSrc2_Out <= 0;
            RegWrite_Out <= 0;
            Branch_Out <= 0;
            Jump_Out <= 0;
            MemWrite_Out <= 0;
            MemRead_Out <= 0;
            Sign_Out <= 0;
            PC_Out <= {PC_Out[31], {31{1'b0}}};
            DataBusA_Out <= 0;
            DataBusB_Out <= 0;
            Imm_Out <= 0;
            Rd_Out <= 0;
            Rt_Out <= 0;
            Rs_Out <= 0;
            ALUFun_Out <= 0;
            PCSrc_Out <= 0;
            RegDst_Out <= 0;
            MemtoReg_Out <= 0;
            Shamt_Out <= 0;
        end else begin
            AluSrc1_Out <= AluSrc1_In;
            AluSrc2_Out <= AluSrc2_In;
            RegWrite_Out <= RegWrite_In;
            Branch_Out <= Branch_In;
            Jump_Out <= Jump_In;
            MemWrite_Out <= MemWrite_In;
            MemRead_Out <= MemRead_In;
            Sign_Out <= Sign_In;
            PC_Out <= PC_In;
            DataBusA_Out <= DataBusA_In;
            DataBusB_Out <= DataBusB_In;
            Imm_Out <= Imm_In;
            Rd_Out <= Rd_In;
            Rt_Out <= Rt_In;
            Rs_Out <= Rs_In;
            ALUFun_Out <= ALUFun_In;
            PCSrc_Out <= PCSrc_In;
            RegDst_Out <= RegDst_In;
            MemtoReg_Out <= MemtoReg_In;
            Shamt_Out <= Shamt_In;
        end
    end
endmodule
