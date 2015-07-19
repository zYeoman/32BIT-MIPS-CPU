module InstructionMem (
    input [31:0] addr,
    output reg [31:0] instruction
);
    parameter ROM_SIZE = 128;
    parameter ROM_BIT  = 7;  // 2^7 = 128
    //reg [31:0] ROM[31:0];

    always @ (*)
        case (addr[ROM_BIT+1:2])
            7'd0: instruction = 32'h08000003;
            7'd1: instruction = 32'h0800001c;
            7'd2: instruction = 32'h03400008;
            7'd3: instruction = 32'h20080014;
            7'd4: instruction = 32'h01000008;
            7'd5: instruction = 32'h3c084000;
            7'd6: instruction = 32'h3c099000;
            7'd7: instruction = 32'h00094f03;
            7'd8: instruction = 32'had090000;
            7'd9: instruction = 32'had090004;
            7'd10: instruction = 32'h20090003;
            7'd11: instruction = 32'had090008;
            7'd12: instruction = 32'h8d090010;
            7'd13: instruction = 32'h3130000f;
            7'd14: instruction = 32'h00098902;
            7'd15: instruction = 32'h12110008;
            7'd16: instruction = 32'h0211402a;
            7'd17: instruction = 32'h15000002;
            7'd18: instruction = 32'h02118022;
            7'd19: instruction = 32'h0800000f;
            7'd20: instruction = 32'h02308822;
            7'd21: instruction = 32'h0800000f;
            7'd22: instruction = 32'h02201820;
            7'd23: instruction = 32'h08000019;
            7'd24: instruction = 32'h02001820;
            7'd25: instruction = 32'h3c084000;
            7'd26: instruction = 32'had03000c;
            7'd27: instruction = 32'h08000003;
            7'd28: instruction = 32'h03400008;
            default: instruction =32'h8000_0000;
        endcase
endmodule
