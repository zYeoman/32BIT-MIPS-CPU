// module div(input clk_div,output reg clk);

// initial clk = 1'b0;

// always @ (posedge clk_div) begin
//     clk <= ~clk;
// end

// endmodule

module CPU(
    input clk_div, rst_n,
    input [7:0] switch,
    input rx, 
    output tx, 
    output [7:0] led, 
    output [6:0] digi_out1, 
    output [6:0] digi_out2, 
    output [6:0] digi_out3, 
    output [6:0] digi_out4
);
    
    wire clk;
    
    //div di(.clk_div(clk_div),.clk(clk));
    assign clk = clk_div;
    
    wire rst;
    assign rst = ~rst_n;

    wire IF_flush,
        IF2ID_flush, 
        IF2ID_EN, 
        ID2EX_flush, 
        PCWrite;
    wire [31:0] IFPC_In;
    wire [31:0] IFPC_Out, //IFPC_In, 
        IF2ID_PCIn,
        IF2ID_PCOut,
        ID2EX_PC_In,
        ID2EX_PC_Out,
        EX2MEM_PC_In,
        EX2MEM_PC_Out,
        MEM2WB_PC_In,
        MEM2WB_PC_Out;

    wire [31:0] IF2ID_InstructionIn,
        IF2ID_InstructionOut;

    wire ID2EX_AluSrc1_In, 
        ID2EX_AluSrc2_In, 
        ID2EX_RegWrite_In, 
        ID2EX_Branch_In, 
        ID2EX_Jump_In, 
        ID2EX_MemWrite_In, 
        ID2EX_MemRead_In, 
        ID2EX_Sign_In;
    wire [31:0] rdata1, 
        rdata2, 
        ID2EX_DataBusA_In, 
        ID2EX_DataBusB_In, 
        ID2EX_Imm_In;
    wire [4:0] ID2EX_Rd_In, 
        ID2EX_Rt_In, 
        ID2EX_Rs_In, 
        ID2EX_Shamt_In; 
    wire [5:0] ID2EX_ALUFun_In; 
    wire [2:0] ID2EX_PCSrc_In;
    wire [1:0] ID2EX_RegDst_In, 
        ID2EX_MemtoReg_In;
    wire ID2EX_AluSrc1_Out, 
        ID2EX_AluSrc2_Out, 
        ID2EX_RegWrite_Out, 
        ID2EX_Branch_Out, 
        ID2EX_Jump_Out, 
        ID2EX_MemWrite_Out, 
        ID2EX_MemRead_Out, 
        ID2EX_Sign_Out;
    wire [31:0] ID2EX_DataBusA_Out, 
        ID2EX_DataBusB_Out, 
        ID2EX_Imm_Out,
        DataBusC;
    wire [4:0] ID2EX_Rd_Out, 
        ID2EX_Rt_Out, 
        ID2EX_Rs_Out,
        ID2EX_Shamt_Out;
    wire [5:0] ID2EX_ALUFun_Out; 
    wire [2:0] ID2EX_PCSrc_Out; // no use ?
    wire [1:0] ID2EX_RegDst_Out, 
        ID2EX_MemtoReg_Out;


    wire IRQ,               //input
        IRQ_;
    reg IRQ__;
    wire ExtOp,LuOp,Sign;   //output
    wire [4:0] Rs;
    wire [4:0] Rd;
    wire [4:0] Rt;
    wire [15:0] Imm16;
    wire [31:0] ConBA;

    reg [31:0] wdata;

    wire Branch;

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

    wire ForwardC, 
        ForwardD;
    wire [1:0] ForwardA, 
        ForwardB;
    reg [31:0] ALU1, 
        ForwardB_Out;
    wire [31:0] ALU2;

    wire MEM2WB_RegWrite_Out; 
    wire [4:0] MEM2WB_AddrC_Out; 
    wire MEM2WB_RegWrite_In; 
    wire [31:0] MEM2WB_ALUOut_In, 
        MEM2WB_rdata_In;
    wire [4:0] MEM2WB_AddrC_In; 
    wire [1:0] MEM2WB_MemtoReg_In;
    wire [31:0] MEM2WB_ALUOut_Out, 
        MEM2WB_rdata_Out; 
    wire [1:0] MEM2WB_MemtoReg_Out; 

    wire [11:0] digi;

    wire Branch_;

    assign Branch_ = ~IRQ_ & Branch;

    IF RegIF(
        .clk(clk), 
        .rst(rst), 
        .flush(IF_flush), 
        .PCSrc(ID2EX_PCSrc_In), 
        .PCWrite(PCWrite), 
        .Branch(Branch_), 
        .ConBA(ConBA), 
        .JT(IF2ID_InstructionOut[25:0]), 
        .DataBusA(ID2EX_DataBusA_In), 
        .PC_In(IF2ID_PCIn), 
        .PC_Out(IFPC_Out)
    );

    //IF阶段, flush信号？
    //指令读取
    InstructionMem insmem(
        .addr(IFPC_Out),
        .instruction(IF2ID_InstructionIn)
    );

    //本条指令
    assign IF2ID_PCIn = IFPC_Out; 

    wire irq_IF2ID_flush;
    wire irq_ID2EX_flush;
    assign irq_ID2EX_flush = ~IRQ_ & ID2EX_flush;
    assign irq_IF2ID_flush = ~IRQ_ & IF2ID_flush;

    IF2ID RegIF2ID(
        .clk(clk), 
        .rst(rst), 
        .flush(irq_IF2ID_flush), 
        .EN(IF2ID_EN), 
        .PCIn(IF2ID_PCIn), 
        .InstructionIn(IF2ID_InstructionIn), 
        .PCOut(IF2ID_PCOut), 
        .InstructionOut(IF2ID_InstructionOut)
    );

    //ID阶段 中断没有，flush 没有

    assign ID2EX_PC_In = IF2ID_PCOut;
    assign ID2EX_Shamt_In = IF2ID_InstructionOut[10:6];
    assign Rd = IF2ID_InstructionOut[15:11];
    assign Rt = IF2ID_InstructionOut[20:16];
    assign Rs = IF2ID_InstructionOut[25:21];
    assign Imm16 = IF2ID_InstructionOut[15:0];
    assign ID2EX_Sign_In = Sign;
    assign DataBusC = ExtOp ? {{16{Imm16[15]}}, Imm16} : {16'b0, Imm16};
    assign ID2EX_Imm_In = LuOp ? {Imm16, 16'b0} : DataBusC;
    
    assign ConBA = {ID2EX_Imm_Out[29:0],2'b0} + ID2EX_PC_In; // calc in EX

    assign ID2EX_Rd_In = IRQ_ ? 5'h0 : IF2ID_InstructionOut[15:11];
    assign ID2EX_Rt_In = IRQ_ ? 5'h0 : IF2ID_InstructionOut[20:16];
    assign ID2EX_Rs_In = IRQ_ ? 5'h0 : IF2ID_InstructionOut[25:21];
    
    always @ (posedge clk)
            IRQ__ = IRQ; //& ~IF2ID_flush
    assign IRQ_ = ~IRQ__ & IRQ;

    Control control(
        .irq(IRQ_), .PC31(IF2ID_PCOut[31]), 
        .OpCode(IF2ID_InstructionOut[31:26]), 
        .Funct(IF2ID_InstructionOut[5:0]), 
        .PCSrc(ID2EX_PCSrc_In), 
        // .nextPC(nextPC), 
        .RegDst(ID2EX_RegDst_In), .MemtoReg(ID2EX_MemtoReg_In), 
        ///.ALUOp(ALUOp), 
        .ALUFun(ID2EX_ALUFun_In), 
        .RegWrite(ID2EX_RegWrite_In), .ALUSrc1(ID2EX_AluSrc1_In), .ALUSrc2(ID2EX_AluSrc2_In), .Branch(ID2EX_Branch_In),
        .Jump(ID2EX_Jump_In), .MemWrite(ID2EX_MemWrite_In), .MemRead(ID2EX_MemRead_In), .ExtOp(ExtOp), .LuOp(LuOp), .Sign(Sign)
    );

    assign Branch = ID2EX_Branch_Out & EX2MEM_ALUOut_In[0]; // Branch & ALUOut[0]

    Hazard hzd(
        .ID2EX_MemRead(ID2EX_MemRead_Out), 
        .Branch(Branch), 
        .Jump(ID2EX_Jump_In), // Control to here
        .ID2EX_Rt(ID2EX_Rt_Out), 
        .IF2ID_Rs(ID2EX_Rs_In), 
        .IF2ID_Rt(ID2EX_Rt_In), 
        .PCWrite(PCWrite), 
        .IF2ID_flush(IF2ID_flush), 
        .IF2ID_write(IF2ID_EN), 
        .ID2EX_flush(ID2EX_flush)
    );

    Register register(
        .clk(clk), .rst(rst),
        .RegWrite(MEM2WB_RegWrite_Out), 
        .PC(IFPC_Out), 
        .r1(Rs), .r2(Rt), .w(MEM2WB_AddrC_Out), 
        .wdata(wdata), 
        .rdata1(rdata1), .rdata2(rdata2)
    );

    assign ID2EX_DataBusA_In = (IRQ_ & ~IF2ID_PCOut[31]) ? 32'b0 : 
        ForwardC ? wdata : 
        rdata1;
    // assign ID2EX_DataBusB_In = (IRQ_ & ~IF2ID_PCOut[31]) ? (IF2ID_flush ? IF2ID_PCIn : ID2EX_PC_In) : 
    //     ForwardD ? wdata : 
    //     rdata2;
    assign ID2EX_DataBusB_In = (IRQ_ & ~IF2ID_PCOut[31]) ? (Branch ? ConBA : ID2EX_PC_In) : 
        ForwardD ? wdata : 
        rdata2;

    ID2EX RegID2EX(
        .clk(clk), 
        .rst(rst), 
        .flush(irq_ID2EX_flush), 

        .PC_In(ID2EX_PC_In), 
        .DataBusA_In(ID2EX_DataBusA_In), 
        .DataBusB_In(ID2EX_DataBusB_In), 
        .Imm_In(ID2EX_Imm_In), 
        .Rd_In(ID2EX_Rd_In), 
        .Rt_In(ID2EX_Rt_In), 
        .Rs_In(ID2EX_Rs_In), 
        .Shamt_In(ID2EX_Shamt_In),
        .Sign_In(ID2EX_Sign_In), 

        .AluSrc1_In(ID2EX_AluSrc1_In), 
        .AluSrc2_In(ID2EX_AluSrc2_In), 
        .RegWrite_In(ID2EX_RegWrite_In), 
        .Branch_In(ID2EX_Branch_In), 
        .Jump_In(ID2EX_Jump_In), 
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
        .Branch_Out(ID2EX_Branch_Out), 
        .Jump_Out(ID2EX_Jump_Out), 
        .MemWrite_Out(ID2EX_MemWrite_Out), 
        .MemRead_Out(ID2EX_MemRead_Out), 
        .Sign_Out(ID2EX_Sign_Out), 
        .PC_Out(ID2EX_PC_Out), 
        .DataBusA_Out(ID2EX_DataBusA_Out), 
        .DataBusB_Out(ID2EX_DataBusB_Out), 
        .Imm_Out(ID2EX_Imm_Out), 
        .Rd_Out(ID2EX_Rd_Out), 
        .Rt_Out(ID2EX_Rt_Out), 
        .Rs_Out(ID2EX_Rs_Out), 
        .ALUFun_Out(ID2EX_ALUFun_Out), 
        .PCSrc_Out(ID2EX_PCSrc_Out), // no use ?
        .RegDst_Out(ID2EX_RegDst_Out), 
        .MemtoReg_Out(ID2EX_MemtoReg_Out) 
    );

    //EX阶段

    //直接传递下去

    assign EX2MEM_RegWrite_In = ID2EX_RegWrite_Out;
    assign EX2MEM_MemWrite_In = ID2EX_MemWrite_Out;
    assign EX2MEM_MemRead_In = ID2EX_MemRead_Out;
    assign EX2MEM_PC_In = ID2EX_PC_Out;
    assign EX2MEM_MemtoReg_In = ID2EX_MemtoReg_Out;
    assign EX2MEM_DataBusB_In = ForwardB_Out;

    always @ (*)
        case (ForwardA)
            2'h0: ALU1 = ID2EX_AluSrc1_Out ? {27'b0,ID2EX_Shamt_Out[4:0]} : ID2EX_DataBusA_Out;
            2'h1: ALU1 = wdata;
            2'h2: ALU1 = EX2MEM_ALUOut_Out;
            //2'h3: ALU1 = MEM2WB_rdata_Out;
            default: ALU1 = 32'h0;
        endcase
    always @ (*)
        case (ForwardB)
            2'h0: ForwardB_Out = ID2EX_DataBusB_Out;
            2'h1: ForwardB_Out = wdata;
            2'h2: ForwardB_Out = EX2MEM_ALUOut_Out;
            //2'h3: ForwardB_Out = MEM2WB_rdata_Out;
            default: ForwardB_Out = 32'h0;
        endcase

    assign ALU2 = ID2EX_AluSrc2_Out ? ID2EX_Imm_Out : ForwardB_Out;

    ALU alu(
        .in1(ALU1), .in2(ALU2), 
        .ALUFun(ID2EX_ALUFun_Out), .sign(ID2EX_Sign_Out), 
        .out(EX2MEM_ALUOut_In)
    );

    Forward fwd(
        .EX2MEM_RegWrite(EX2MEM_RegWrite_Out), 
        .MEM2WB_RegWrite(MEM2WB_RegWrite_Out), 
        .EX2MEM_Rd(EX2MEM_AddrC_Out), 
        .MEM2WB_Rd(MEM2WB_AddrC_Out), 
        .ID2EX_Rs(ID2EX_Rs_Out), 
        .IF2ID_Rs(ID2EX_Rs_In), 
        .ID2EX_Rt(ID2EX_Rt_Out), 
        .IF2ID_Rt(ID2EX_Rt_In), 
        .ID2EX_Rd(ID2EX_Rd_Out), 
        .ForwardA(ForwardA), 
        .ForwardB(ForwardB), 
        .ForwardC(ForwardC), 
        .ForwardD(ForwardD)
    );

    assign EX2MEM_AddrC_In = (ID2EX_RegDst_Out==2'h0) ? ID2EX_Rd_Out : 
        (ID2EX_RegDst_Out==2'h1) ? ID2EX_Rt_Out : 
        (ID2EX_RegDst_Out==2'h2) ? 5'd31 : // Ra
        (ID2EX_RegDst_Out==2'h3) ? 5'd26 : // Xp
        5'b0; // zero won't be write

    EX2MEM RegEX2MEM(
        .clk(clk), 
        .rst(rst), 

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

    always @ (*) begin
        case (MEM2WB_MemtoReg_Out)
            2'h0: wdata = MEM2WB_ALUOut_Out;
            2'h1: wdata = MEM2WB_rdata_Out; // TODO MEM2WB_MemtoReg_Out 1bit is enough
            default : wdata = 32'b0;
        endcase
    end



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

    assign MEM2WB_RegWrite_In = EX2MEM_RegWrite_Out;
    assign MEM2WB_PC_In = EX2MEM_PC_Out;
    assign MEM2WB_ALUOut_In = EX2MEM_ALUOut_Out;
    assign MEM2WB_AddrC_In = EX2MEM_AddrC_Out;
    assign MEM2WB_MemtoReg_In = EX2MEM_MemtoReg_Out;

    MEM2WB RegMEM2WB(
        .clk(clk), 
        .rst(rst), 
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
