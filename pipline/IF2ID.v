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
    input clk, rst, EN, 
    input [31:0]PCIn, InstructionIn, 
    output reg [31:0] PCOut, InstructionOut
);
    
    parameter initial = 32'h0000_0000;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            PCOut<=initial;
            InstructionOut<=initial;
        end else if (EN) begin
            PCOut<=PCIn;
            InstructionOut<=InstructionIn;
        end else begin
            PCOut<=PCOut;
            InstructionOut<=InstructionOut;
        end
    end

endmodule