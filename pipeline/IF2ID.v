/*
Filename : IF2ID.v
Compiler : Quartus II
Description : IF to ID register
INPUT : clk, rst, EN : all active high
        PCIn, InstructionIn : 32bits Register
OUTPUT : PCIn, InstructionOut : 32bits Register
Author : Yeoman Zhuang
Release : *
*/

module IF2ID(
    input clk, rst, flush, EN, 
    input [31:0]PCIn, InstructionIn, 
    output reg [31:0] PCOut, InstructionOut
);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            PCOut<=32'h8000_0000;
            InstructionOut<=0;
        end else if(flush) begin
            PCOut <= {PCOut[31], {31{1'b0}}};
            InstructionOut<=32'h0;
        end else if(EN) begin
            PCOut<=PCIn;
            InstructionOut<=InstructionIn;
        end else begin
            PCOut<=PCOut;
            InstructionOut<=InstructionOut;
        end
    end

endmodule
