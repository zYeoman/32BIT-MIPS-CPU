module ALU_tb ();
    reg [31:0] I1, I2;
    wire [31:0] O;
    reg [5:0] ALUFun;
    reg Sign;
    ALU alu(
        .in1(I1), .in2(I2), .out(O), .ALUFun(ALUFun),
        .sign(Sign)
    );

    initial begin
        I1 = 32'ha8a8aa55; // 2829625941 = -1465341355
        I2 = 32'h95556aa5; // 2505403045 = -1789564249
        Sign = 1'b0;
        ALUFun = 6'b110101; // lt
    #5  Sign = 1'b1;
    #5  I1 = 32'h95556aa5;
        I2 = 32'ha8a8aa55;
    #5  Sign = 1'b0;
    #5  ALUFun = 6'b110011; // eq
        I1 = 32'ha8a8aa55;
    #5  ALUFun = 6'b100011; // sra
        I1 = 32'd8;
        I2 = 32'hf101_0101;
    #5  I1 = 32'd12;
    #5  I1 = 32'd14;
    #5  I1 = 32'd15;
    #5  I1 = 32'hffff_ffff;
        I2 = 32'h0000_0001;
        ALUFun = 6'b000000;
        Sign = 1'b0;
    #5  I1 = 32'h7fff_ffff;
        I2 = 32'h0000_0001;
        Sign = 1'b1;
    end
endmodule