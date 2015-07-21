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

    wire IF_EN,
        IF2ID_EN,
        ID2EX_EN,
        EX2MEM_EN,
        MEM2WB_EN;
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



    IF RegIF(
        .clk(clk), 
        .rst(rst), 
        .EN(IF_EN), 
        .PC_In(IFPC_In), 
        .PC_Out(IFPC_Out)
    );

    wire [31:0] IF2ID_InstructionIn,
        IF2ID_InstructionOut;

    //IF阶段, EN信号？
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
        .EN(IF2ID_EN), 

        .PCIn(IF2ID_PCIn), 
        .InstructionIn(IF2ID_InstructionIn), 
        .PCOut(IF2ID_PCOut), 
        .InstructionOut(IF2ID_InstructionOut)
    );

    wire ID2EX_AluSrc1_In, 
        ID2EX_AluSrc2_In, 
        ID2EX_RegWrite_In, 
        ID2EX_Branch_In, 
        ID2EX_MemWrite_In, 
        ID2EX_MemRead_In, 
        ID2EX_Sign_In;
    wire [31:0] ID2EX_DataBusA_In, 
        ID2EX_DataBusB_In, 
        ID2EX_Imm_In, 
    wire [4:0] ID2EX_Rd_In, ID2EX_Rt_In, 
    wire [5:0] ID2EX_ALUFun_In, 
    wire [3:0] ID2EX_PCSrc_In, 
    wire [1:0] ID2EX_RegDst_In, ID2EX_MemtoReg_In, 
    wire ID2EX_AluSrc1_Out, 
        ID2EX_AluSrc2_Out, 
        ID2EX_RegWrite_Out, 
        ID2EX_Branch_Out, 
        ID2EX_MemWrite_Out, 
        ID2EX_MemRead_Out, 
        ID2EX_Sign_Out,
    wire [31:0] ID2EX_DataBusA_Out, 
        ID2EX_DataBusB_Out, 
        ID2EX_Imm_Out,
    wire [4:0] ID2EX_Rd_Out, 
        ID2EX_Rt_Out, 
    wire [5:0] ID2EX_ALUFun_Out, 
    wire [3:0] ID2EX_PCSrc_Out, 
    wire [1:0] ID2EX_RegDst_Out, 
        ID2EX_MemtoReg_Out, 


    wire IRQ;               //input
    wire ExtOp,LuOp,Sign;   //output

    assign ID2EX_PC_In = IFPC_Out;
    assign ID2EX_Rd_In = IF2ID_InstructionOut[15:11];
    assign ID2EX_Rt_In = IF2ID_InstructionOut[20:16];


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
            2'h0: wdata = ALUOut;
            2'h1: wdata = MEM2WB_rdata_Out;
            2'h2: wdata = IF2ID_PCOut;
            default : wdata = 32'b0;
    end

    Register register(
        .clk(clk), .rst(rst),
        .RegWrite(RegWrite), 
        .r1(Rs), .r2(Rt), .w(MEM2WB_AddrC_Out), 
        .wdata(wdata), 
        .rdata1(DataBusA), .rdata2(DataBusB)
    );

    ID2EX RegID2EX(
        .clk(clk), 
        .rst(rst), 
        .EN(ID2EX_EN), 

        .PC_In(ID2EX_PC_In), 
        .DataBusA_In(ID2EX_DataBusA_In), 
        .DataBusB_In(ID2EX_DataBusB_In), 
        .Imm_In(ID2EX_Imm_In), 
        .Rd_In(ID2EX_Rd_In), 
        .Rt_In(ID2EX_Rt_In), 

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

    wire EX2MEM_RegWrite_In, 
        EX2MEM_MemWrite_In, 
        EX2MEM_MemRead_In;
    wire [31:0] EX2MEM_ALUOut_In;
    wire [4:0] EX2MEM_AddrC_In;
    wire [3:0] EX2MEM_PCSrc_In; 
    wire [1:0] EX2MEM_MemtoReg_In;
    wire EX2MEM_RegWrite_Out, 
        EX2MEM_MemWrite_Out, 
        EX2MEM_MemRead_Out;
    wire [31:0] EX2MEM_ALUOut_Out;
    wire [4:0] EX2MEM_AddrC_Out;
    wire [3:0] EX2MEM_PCSrc_Out; 
    wire [1:0] EX2MEM_MemtoReg_Out; 

    EX2MEM RegEX2MEM(
        .clk(clk), 
        .rst(rst), 
        .EN(EX2MEM_EN), 

        .RegWrite_In(EX2MEM_RegWrite_In), 
        .MemWrite_In(EX2MEM_MemWrite_In), 
        .MemRead_In(EX2MEM_MemRead_In), 
        .PC_In(EX2MEM_PC_In), 
        .ALUOut_In(EX2MEM_ALUOut_In), 
        .AddrC_In(EX2MEM_AddrC_In), 
        .PCSrc_In(EX2MEM_PCSrc_In), 
        .MemtoReg_In(EX2MEM_MemtoReg_In), 

        .RegWrite_Out(EX2MEM_RegWrite_Out), 
        .MemWrite_Out(EX2MEM_MemWrite_Out), 
        .MemRead_Out(EX2MEM_MemRead_Out), 
        .PC_Out(EX2MEM_PC_Out), 
        .ALUOut_Out(EX2MEM_ALUOut_Out), 
        .AddrC_Out(EX2MEM_AddrC_Out), 
        .PCSrc_Out(EX2MEM_PCSrc_Out), 
        .MemtoReg_Out(EX2MEM_MemtoReg_Out)
    );

    wire MEM2WB_RegWrite_In, 
    wire [31:0] MEM2WB_ALUOut_In, 
        MEM2WB_rdata_In, 
    wire [4:0] MEM2WB_AddrC_In, 
    wire [1:0] MEM2WB_MemtoReg_In, 
    wire MEM2WB_RegWrite_Out, 
    wire [31:0] MEM2WB_ALUOut_Out, 
        MEM2WB_rdata_Out, 
    wire [4:0] MEM2WB_AddrC_Out, 
    wire [1:0] MEM2WB_MemtoReg_Out, 

    MEM2WB RegMEM2WB(
        .clk(clk), 
        .rst(rst), 
        .EN(MEM2WB_EN), 
        .RegWrite_In(MEM2WB_RegWrite_In), 
        .PC_In(MEM2WB_PC_In), 
        .ALUOut_In(MEM2WB_ALUOut_In), 
        .rdata_In(MEM2WB_rdata_In), 
        .AddrC_In(MEM2WB_AddrC_In), 
        .MemtoReg_In(MEM2WB_MemtoReg_In), 
        .RegWrite_Out(MEM2WB_RegWrite_Out), 
        .PC_Out(MEM2WB_PC_Out), 
        .ALUOut_Out(MEM2WB_ALUOut_Out), 
        .rdata_Out(MEM2WB_rdata_Out), 
        .AddrC_Out(MEM2WB_AddrC_Out), 
        .MemtoReg_Out(MEM2WB_MemtoReg_Out)
    );

endmodule
