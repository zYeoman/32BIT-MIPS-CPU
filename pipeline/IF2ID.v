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
    input clk, rst, flush, 
    input [31:0]PCIn, InstructionIn, 
    output reg [31:0] PCOut, InstructionOut
);
    
    parameter initial = 32'h0000_0000;
    
    always @(posedge clk or posedge rst) begin
        if (rst|flush) begin
            // reset
            PCOut<=initial;
            InstructionOut<=initial;
        end else 
            PCOut<=PCIn;
            InstructionOut<=InstructionIn;
    end

endmodule
