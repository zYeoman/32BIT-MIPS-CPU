module CPU(
    input clk, rst_n,
    input [7:0] switch,
    input rx, 
    output tx, 
    output [7:0] led, 
    output [6:0] digi_out1, 
    output [6:0] digi_out2, 
    output [6:0] digi_out3, 
    output [6:0] digi_out4
);
    wire rst;
    assign rst = ~rst_n;

    wire IF_flush,
        IF2ID_flush,
        ID2EX_flush,
        EX2MEM_flush,
        MEM2WB_flush;
    wire [31:0] IFPC_In,
        IFPC_Out,
        IF2ID_PCIn,
        IF2ID_PCOut,
        ID2EX_PC_In,
        ID2EX_PC_Out,
        EX2MEM_PC_In,
        EX2MEM_PC_Out,
        MEM2WB_PC_In,
        MEM2WB_PC_Out;

    // IF阶段
    // 非常不完善！！！还有中断什么的还没写都
    always @(*) begin
        case (PCSrc)                //谁的PCSrc？
            3'h0: PC <= IF2ID_PCIn; //IF2ID_PCIn = PC+4
            3'h1: PC <= ALUOut[0] ? ConBA : PC4;    //这里有ALUOut么？
            3'h2: PC <= {PC[31:28], JT, 2'b0};      //还没取出指令来呢
            3'h3: PC <= DataBusA; // jr jalr $Ra
            3'h4: PC <= 32'h8000_0004; // ILLOP
            3'h5: PC <= 32'h8000_0008; // XADR
            default: PC <= 32'h8000_0008;
        endcase
    end

    IF RegIF(
        .clk(clk), 
        .rst(rst), 
        .flush(IF_flush), 
        .PC_In(IFPC_In), 
        .PC_Out(IFPC_Out)
    );

    wire [31:0] IF2ID_InstructionIn,
        IF2ID_InstructionOut;

    //IF阶段, flush信号？
    //指令读取
    InstructionMem insmem(
        .addr(IFPC_Out),
        .instruction(InstructionIn)
    );

    //下一条指令
    assign IF2ID_PCIn = IFPC_Out + 32'h4;

    IF2ID RegIF2ID(
        .clk(clk), 
        .rst(rst), 
        .flush(IF2ID_flush), 

        .PCIn(IF2ID_PCIn), 
        .InstructionIn(IF2ID_InstructionIn), 
        .PCOut(IF2ID_PCOut), 
        .InstructionOut(IF2ID_InstructionOut)
    );

    //ID阶段 中断没有，flush 没有

    wire ID2EX_AluSrc1_In, 
        ID2EX_AluSrc2_In, 
        ID2EX_RegWrite_In, 
        ID2EX_Branch_In, 
        ID2EX_MemWrite_In, 
        ID2EX_MemRead_In, 
        ID2EX_Sign_In;
    wire [31:0] ID2EX_DataBusA_In, 
        ID2EX_DataBusB_In, 
        ID2EX_Imm_In;
    wire [4:0] ID2EX_Rd_In, 
        ID2EX_Rt_In, 
        ID2EX_Shamt_In; 
    wire [5:0] ID2EX_ALUFun_In; 
    wire [3:0] ID2EX_PCSrc_In;
    wire [1:0] ID2EX_RegDst_In, 
        ID2EX_MemtoReg_In;
    wire ID2EX_AluSrc1_Out, 
        ID2EX_AluSrc2_Out, 
        ID2EX_RegWrite_Out, 
        ID2EX_Branch_Out, 
        ID2EX_MemWrite_Out, 
        ID2EX_MemRead_Out, 
        ID2EX_Sign_Out;
    wire [31:0] ID2EX_DataBusA_Out, 
        ID2EX_DataBusB_Out, 
        ID2EX_Imm_Out,
        DataBusC;
    wire [4:0] ID2EX_Rd_Out, 
        ID2EX_Rt_Out,
        ID2EX_Shamt_Out;
    wire [5:0] ID2EX_ALUFun_Out; 
    wire [3:0] ID2EX_PCSrc_Out; 
    wire [1:0] ID2EX_RegDst_Out, 
        ID2EX_MemtoReg_Out;


    wire IRQ;               //input
    wire ExtOp,LuOp,Sign;   //output
    wire [4:0] Rs;
    wire [4:0] Rd;
    wire [4:0] Rt;
    wire Imm16;
    wire [31:0] ConBA;

    assign ID2EX_PC_In = IFPC_Out;
    assign ID2EX_Shamt_In = IF2ID_InstructionOut[10:6];
    assign Rd = IF2ID_InstructionOut[15:11];
    assign Rt = IF2ID_InstructionOut[20:16];
    assign Rs = IF2ID_InstructionOut[25:21];

    assign DataBusC = ExtOp ? {{16{Imm16[15]}}, Imm16} : {16'b0, Imm16};
    assign ID2EX_Imm_In = LuOp ? {Imm16, 16'b0} : DataBusC;
    assign ConBA = {DataBusC[29:0],2'b0} + IF2ID_PCOut;

    assign ID2EX_Rd_In = Rd;
    assign ID2EX_Rt_In = Rt;

    Control control(
        .irq(IRQ), .PC31(IF2ID_PCOut[31]), 
        .OpCode(IF2ID_InstructionOut[31:26]), 
        .Funct(IF2ID_InstructionOut[5:0]), 
        .PCSrc(ID2EX_PCSrc_In), 
        // .nextPC(nextPC), 
        .RegDst(ID2EX_RegDst_In), .MemtoReg(ID2EX_MemtoReg_In), 
        ///.ALUOp(ALUOp), 
        .ALUFun(ID2EX_ALUFun_In), 
        .RegWrite(ID2EX_RegWrite_In), .ALUSrc1(ID2EX_AluSrc1_In), .ALUSrc2(ID2EX_AluSrc2_In), .Branch(ID2EX_Branch_In),
        .MemWrite(ID2EX_MemWrite_In), .MemRead(ID2EX_MemRead_In), .ExtOp(ExtOp), .LuOp(LuOp), .Sign(Sign)
    );

    wire [31:0] wdata;


    always @ (*) begin
        case (MEM2WB_MemtoReg_Out)
            2'h0: wdata = MEM2WB_ALUOut_Out;
            2'h1: wdata = MEM2WB_rdata_Out;
            2'h2: wdata = IFPCOut;      //中断时，未完成！！！！！
            default : wdata = 32'b0;
    end

    Register register(
        .clk(clk), .rst(rst),
        .RegWrite(MEM2WB_RegWrite_Out), 
        .r1(Rs), .r2(Rt), .w(MEM2WB_AddrC_Out), 
        .wdata(wdata), 
        .rdata1(ID2EX_DataBusA_In), .rdata2(ID2EX_DataBusB_In)
    );

    ID2EX RegID2EX(
        .clk(clk), 
        .rst(rst), 
        .flush(ID2EX_flush), 

        .PC_In(ID2EX_PC_In), 
        .DataBusA_In(ID2EX_DataBusA_In), 
        .DataBusB_In(ID2EX_DataBusB_In), 
        .Imm_In(ID2EX_Imm_In), 
        .Rd_In(ID2EX_Rd_In), 
        .Rt_In(ID2EX_Rt_In), 
        .Shamt_In(ID2EX_Shamt_In),

        .AluSrc1_In(ID2EX_AluSrc1_In), 
        .AluSrc2_In(ID2EX_AluSrc2_In), 
        .RegWrite_In(ID2EX_RegWrite_In), 
        .Branch_In(ID2EX_Branch_In), 
        .MemWrite_In(ID2EX_MemWrite_In), 
        .MemRead_In(ID2EX_MemRead_In), 
        .ALUFun_In(ID2EX_ALUFun_In), 
        .PCSrc_In(ID2EX_PCSrc_In), 
        .RegDst_In(ID2EX_RegDst_In), 
        .MemtoReg_In(ID2EX_MemtoReg_In), 

        .Shamt_Out(ID2EX_Shamt_Out),
        .AluSrc1_Out(ID2EX_AluSrc1_Out), 
        .AluSrc2_Out(ID2EX_AluSrc2_Out), 
        .RegWrite_Out(ID2EX_RegWrite_Out), 
        .ranch_Out(ID2EX_ranch_Out), 
        .MemWrite_Out(ID2EX_MemWrite_Out), 
        .MemRead_Out(ID2EX_MemRead_Out), 
        .PC_Out(ID2EX_PC_Out), 
        .DataBusA_Out(ID2EX_DataBusA_Out), 
        .DataBusB_Out(ID2EX_DataBusB_Out), 
        .Imm_Out(ID2EX_Imm_Out), 
        .Rd_Out(ID2EX_Rd_Out), 
        .Rt_Out(ID2EX_Rt_Out), 
        .ALUFun_Out(ID2EX_ALUFun_Out), 
        .PCSrc_Out(ID2EX_PCSrc_Out), 
        .RegDst_Out(ID2EX_RegDst_Out), 
        .MemtoReg_Out(ID2EX_MemtoReg_Out) 
    );

    //EX阶段

    wire EX2MEM_RegWrite_In, 
        EX2MEM_MemWrite_In, 
        EX2MEM_MemRead_In;
    wire [31:0] EX2MEM_ALUOut_In, 
        EX2MEM_DataBusB_In;
    wire [4:0] EX2MEM_AddrC_In;
    wire [1:0] EX2MEM_MemtoReg_In;
    wire EX2MEM_RegWrite_Out, 
        EX2MEM_MemWrite_Out, 
        EX2MEM_MemRead_Out;
    wire [31:0] EX2MEM_ALUOut_Out,
        EX2MEM_DataBusB_Out;
    wire [4:0] EX2MEM_AddrC_Out;
    wire [1:0] EX2MEM_MemtoReg_Out; 

    wire [31:0] ALU1;
    wire [31:0] ALU2;

    //直接传递下去

    assign EX2MEM_RegWrite_In = ID2EX_RegWrite_Out;
    assign EX2MEM_MemWrite_In = ID2EX_MemWrite_Out;
    assign EX2MEM_MemRead_In = ID2EX_MemRead_Out;
    assign EX2MEM_PC_In = ID2EX_PC_Out;
    assign EX2MEM_MemtoReg_In = ID2EX_MemtoReg_In;
    assign EX2MEM_DataBusB_In = ID2EX_DataBusB_Out;


    assign ALU1 = ID2EX_AluSrc1_Out ? {27'b0,ID2EX_Shamt_Out[4:0]} : DataBusA;
    assign ALU2 = ID2EX_AluSrc2_Out ? Imm : DataBusB;

    ALU alu(
        .in1(ALU1), .in2(ALU2), 
        .ALUFun(ID2EX_ALUFun_Out), .sign(Sign), 
        .out(EX2MEM_ALUOut_In)
    );


    assign EX2MEM_AddrC_In = (ID2EX_RegDst_Out==2'h0) ? Rd : 
        (ID2EX_RegDst_Out==2'h1) ? Rt : 
        (ID2EX_RegDst_Out==2'h2) ? 5'd31 : // Ra
        (ID2EX_RegDst_Out==2'h3) ? 5'd26 : // Xp
        5'b0; // zero won't be write

    EX2MEM RegEX2MEM(
        .clk(clk), 
        .rst(rst), 
        .flush(EX2MEM_flush), 

        .RegWrite_In(EX2MEM_RegWrite_In), 
        .MemWrite_In(EX2MEM_MemWrite_In), 
        .MemRead_In(EX2MEM_MemRead_In), 
        .PC_In(EX2MEM_PC_In), //可能没用
        .DataBusB_In(EX2MEM_DataBusB_In), 
        .MemtoReg_In(EX2MEM_MemtoReg_In), 

        .ALUOut_In(EX2MEM_ALUOut_In), 
        .AddrC_In(EX2MEM_AddrC_In), 

        .RegWrite_Out(EX2MEM_RegWrite_Out), 
        .MemWrite_Out(EX2MEM_MemWrite_Out), 
        .MemRead_Out(EX2MEM_MemRead_Out), 
        .PC_Out(EX2MEM_PC_Out), //可能没用
        .DataBusB_Out(EX2MEM_DataBusB_Out), 
        .ALUOut_Out(EX2MEM_ALUOut_Out), 
        .AddrC_Out(EX2MEM_AddrC_Out), 
        .MemtoReg_Out(EX2MEM_MemtoReg_Out)
    );

    wire MEM2WB_RegWrite_In; 
    wire [31:0] MEM2WB_ALUOut_In, 
        MEM2WB_rdata_In;
    wire [4:0] MEM2WB_AddrC_In; 
    wire [1:0] MEM2WB_MemtoReg_In; 
    wire MEM2WB_RegWrite_Out; 
    wire [31:0] MEM2WB_ALUOut_Out, 
        MEM2WB_rdata_Out; 
    wire [4:0] MEM2WB_AddrC_Out; 
    wire [1:0] MEM2WB_MemtoReg_Out; 

    //MEM阶段
    DataMem datamem(
        .clk(clk), .rst(rst), 
        .MemWrite(EX2MEM_MemWrite_Out), .MemRead(EX2MEM_MemRead_Out), 
        .tx(tx), .rx(rx), 
        .addr(EX2MEM_ALUOut_Out), .wdata(EX2MEM_DataBusB_Out), 
        .switch(switch), 
        .rdata(MEM2WB_rdata_In), 
        .led(led), 
        .digi(digi), 
        .irq(IRQ)
    );




    MEM2WB RegMEM2WB(
        .clk(clk), 
        .rst(rst), 
        .flush(MEM2WB_flush), 
        .RegWrite_In(MEM2WB_RegWrite_In), 
        .PC_In(MEM2WB_PC_In), //可能没用
        .ALUOut_In(MEM2WB_ALUOut_In), 
        .rdata_In(MEM2WB_rdata_In), 
        .AddrC_In(MEM2WB_AddrC_In), 
        .MemtoReg_In(MEM2WB_MemtoReg_In), 
        .RegWrite_Out(MEM2WB_RegWrite_Out), 
        .PC_Out(MEM2WB_PC_Out), //可能没用
        .ALUOut_Out(MEM2WB_ALUOut_Out), 
        .rdata_Out(MEM2WB_rdata_Out), 
        .AddrC_Out(MEM2WB_AddrC_Out), 
        .MemtoReg_Out(MEM2WB_MemtoReg_Out)
    );




    //译码显示

    digitube_scan digitube(
        .digi_in(digi), 
        .digi_out1(digi_out1), 
        .digi_out2(digi_out2), 
        .digi_out3(digi_out3), 
        .digi_out4(digi_out4)
    );

endmodule
