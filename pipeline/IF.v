/*
Filename : IF.v
Compiler : Quartus II
Description : PC to PC register
INPUT : clk, rst, EN : all active high
        PCIn : 32bits Register
OUTPUT : PCIn : 32bits Register
Author : Yeoman Zhuang
Release : *
*/

module IF(
    input clk, rst, flush,
    input [31:0] PC_In,
    output reg [31:0] PC_Out
);
    always @(posedge clk or posedge rst) begin
        if (rst|flush) begin
            // reset
            PC_Out <= 0;
        end else 
            PC_Out <= PC_In; 
    end
endmodule
