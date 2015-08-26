module Control_tb ();
    reg irq, PC31;
    reg [5:0] OpCode, Funct;
    wire [2:0] PCSrc;
    wire [1:0] RegDst, MemtoReg;
    wire [5:0] ALUFun;
    wire RegWrite, ALUSrc1, ALUSrc2, Branch,
        MemWrite, MemRead, ExtOp, LuOp, Sign, Jump;

    Control con(
        .irq(irq), .PC31(PC31),
        .OpCode(OpCode), .Funct(Funct), .PCSrc(PCSrc), 
        .RegDst(RegDst), .MemtoReg(MemtoReg), .RegWrite(RegWrite), 
        .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .Branch(Branch), 
        .MemWrite(MemWrite), .MemRead(MemRead), .ExtOp(ExtOp), 
        .LuOp(LuOp), .Sign(Sign), .ALUFun(ALUFun), .Jump(Jump)
    );

    initial begin 
        irq = 1;
        PC31 = 0;
        OpCode = 6'h23;
        Funct = 6'h3f;
    #5  irq = 0;
        OpCode = 6'h3f;
        Funct = 6'h3f;
    #5  OpCode = 6'h23;
    #5  OpCode = 6'h2b;
    #5  OpCode = 6'hf;
    #5  OpCode = 6'h0;
        Funct = 6'h20;
    #5  Funct = 6'h21;
    #5  Funct = 6'h22;
    #5  Funct = 6'h23;
    #5  OpCode = 6'h8;
    #5  OpCode = 6'h9;
    #5  OpCode = 6'h0;
        Funct = 6'h24;
    #5  Funct = 6'h25;
    #5  Funct = 6'h26;
    #5  Funct = 6'h27;
    #5  OpCode = 6'hc;
    #5  OpCode = 6'hd;
    #5  OpCode = 6'h0;
        Funct = 6'h0;
    #5  Funct = 6'h2;
    #5  Funct = 6'h3;
    #5  Funct = 6'h2a;
    #5  Funct = 6'h2b;
    #5  OpCode = 6'ha;
    #5  OpCode = 6'hb;
    #5  OpCode = 6'h4;
    #5  OpCode = 6'h5;
    #5  OpCode = 6'h6;
    #5  OpCode = 6'h7;
    #5  OpCode = 6'h1;
    #5  OpCode = 6'h2;
    #5  OpCode = 6'h3;
    #5  OpCode = 6'h0;
        Funct = 6'h8;
    #5  Funct = 6'h9;
end

endmodule