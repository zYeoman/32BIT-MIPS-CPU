module InstructionMem (
    input [31:0] addr,
    output reg [31:0] instruction
);
    parameter ROM_SIZE = 128;
    parameter ROM_BIT  = 7;  // 2^7 = 128
    //reg [31:0] ROM[31:0];

    always @ (*)
        case (addr[ROM_BIT+1:2])
            7'd0: instruction = 32'h20080005;
            7'd1: instruction = 32'h20090006;
            7'd2: instruction = 32'h200a0007;
            7'd3: instruction = 32'h200b0008;
            7'd4: instruction = 32'h00000000;
            7'd5: instruction = 32'h00000000;
            7'd6: instruction = 32'h00000000;
            7'd7: instruction = 32'h01096020;
            default: instruction =32'h8000_0000;
        endcase
endmodule
