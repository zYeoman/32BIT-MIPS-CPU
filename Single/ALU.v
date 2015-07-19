module ALU (
    input [31:0] in1, in2, 
    input [5:0] ALUFun,
    input sign, 
    output reg [31:0] out
);
    reg zero, overflow; 
    wire negative;
    reg [31:0] out00, out01, out10, out11;
    reg nega;

    assign negative = sign&nega;

    always @ (*) begin
        case (ALUFun[0])
            1'b0: begin
                out00 = in1 + in2;
                zero = (out00 == 1'b0)? 1'b1 : 1'b0;
                overflow = (sign&(in1[31]&in2[31]) ^ (in1[30]&in2[30])) | (~sign&(in1[31]&in2[31]));
                nega = out00[31];
            end
            1'b1: begin
                out00 = in1 + ~in2 + 32'b1;
                zero = (out00 == 1'b0)? 1'b1 : 1'b0;
                overflow = (sign&(in1[31]&in2[31]) ^ (in1[30]&in2[30])) | (~sign&(in1[31]&in2[31]));
                nega = out00[31];
            end
            default : out00 = 32'b0;
        endcase
        case (ALUFun[3:1])
            3'b001: out11 = zero ? 32'b1 : 32'b0;
            3'b000: out11 = zero ? 32'b0 : 32'b1;
            3'b010: out11 = nega ? 32'b1 : 32'b0;
            3'b110: out11 = (nega|zero) ? 32'b1 : 32'b0; // blez
            3'b100: out11 = (~in1[31]) ? 32'b1 : 32'b0; // bgez
            3'b111: out11 = (~in1[31]&~zero) ? 32'b1 : 32'b0; // bgtz
            default : out11 = 32'b0;
        endcase
        case (ALUFun[3:0])
            4'b1000: out01 = in1 & in2;
            4'b1110: out01 = in1 | in2;
            4'b0110: out01 = in1 ^ in2;
            4'b0001: out01 = ~(in1 | in2);
            4'b1010: out01 = in1;
            default : out01 = 32'b0;
        endcase
        case (ALUFun[1:0])
            2'b00: begin                            // sll
                        out10 = in2;
                        if (in1[4]) out10 = out10<<16;
                        if (in1[3]) out10 = out10<<8;
                        if (in1[2]) out10 = out10<<4;
                        if (in1[1]) out10 = out10<<2;
                        if (in1[0]) out10 = out10<<1;
                    end
            2'b01: begin                            // srl
                        out10 = in2;
                        if (in1[4]) out10 = out10>>16;
                        if (in1[3]) out10 = out10>>8;
                        if (in1[2]) out10 = out10>>4;
                        if (in1[1]) out10 = out10>>2;
                        if (in1[0]) out10 = out10>>1;
                    end
            2'b11: begin                            // sra
                        out10 = in2;
                        if (in1[4]) out10 = (out10>>16) | {{16{in2[31]}},{16{1'b0}}};
                        if (in1[3]) out10 = ((out10>>8) | {{8{in2[31]}},{24{1'b0}}});
                        if (in1[2]) out10 = (out10>>4) | {{4{in2[31]}},{28{1'b0}}};
                        if (in1[1]) out10 = (out10>>2) | {{2{in2[31]}},{30{1'b0}}};
                        if (in1[0]) out10 = (out10>>1) | {{1{in2[31]}},{31{1'b0}}};
                    end
            default : out10 = 32'b0;
        endcase
        case(ALUFun[5:4])
            2'b00: out = out00;
            2'b01: out = out01;
            2'b10: out = out10;
            2'b11: out = out11;
            default: out<= 32'b0;
        endcase
    end
endmodule
