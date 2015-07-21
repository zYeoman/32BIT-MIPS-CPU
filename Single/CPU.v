module CPU (
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
    reg [31:0] PC;
    wire [31:0] Instruction, 
        PC4, 
        ConBA;
    wire IRQ;               //Interrupt
    wire [25:0] JT;         //j Addr
    wire [15:0] Imm16;
    wire [4:0] Shammt,
        Rd,
        Rt,
        Rs;
    wire [2:0] PCSrc;
    wire [1:0] RegDst,
        MemtoReg, 
        nextPC;             //no use
    wire [3:0] ALUOp;
    wire RegWrite, 
        ALUSrc1, 
        ALUSrc2, 
        Branch, 
        MemWrite, 
        MemRead, 
        ExtOp, 
        LuOp, 
        Sign;
    wire [5:0] ALUFun;      
    wire [4:0] AddrC;       //Write Dst Addr
    reg [31:0] wdata;       //Write data from memory
    wire [31:0] rdata,      //read data from memory
        DataBusA,
        DataBusB;
    wire [31:0] ALU1,       //DataBusA or Shamt
        ALU2,               //DataBudB or Imm
        Imm,                //ExtImm/ZeroImm or luiImm
        DataBusC;           //ExtImm or ZeroImm
    wire [31:0] ALUOut;     //
    wire [11:0] digi;       //display

    assign rst = ~rst_n;
    assign PC4 = PC + 32'h4;
    assign JT = Instruction[25:0];
    assign Imm16 = Instruction[15:0];
    assign Shammt = Instruction[10:6];
    assign Rd = Instruction[15:11];
    assign Rt = Instruction[20:16];
    assign Rs = Instruction[25:21];

    always @ (posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'h8000_0000;
        else
            case (PCSrc)
                3'h0: PC <= PC4;
                3'h1: PC <= ALUOut[0] ? ConBA : PC4;
                3'h2: PC <= {PC[31:28], JT, 2'b0};
                3'h3: PC <= DataBusA; // jr jalr $Ra
                3'h4: PC <= 32'h8000_0004; // ILLOP
                3'h5: PC <= 32'h8000_0008; // XADR
                default: PC <= 32'h8000_0008;
            endcase
    end

    InstructionMem insmem(
        .addr(PC),
        .instruction(Instruction)
    );

    Control control(
        .irq(IRQ), .PC31(PC[31]), 
        .OpCode(Instruction[31:26]), 
        .Funct(Instruction[5:0]), 
        .PCSrc(PCSrc), 
        .nextPC(nextPC), 
        .RegDst(RegDst), .MemtoReg(MemtoReg), 
        ///.ALUOp(ALUOp), 
        .ALUFun(ALUFun), 
        .RegWrite(RegWrite), .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .Branch(Branch),
        .MemWrite(MemWrite), .MemRead(MemRead), .ExtOp(ExtOp), .LuOp(LuOp), .Sign(Sign)
    );

    assign AddrC = (RegDst==2'h0) ? Rd : 
        (RegDst==2'h1) ? Rt : 
        (RegDst==2'h2) ? 5'd31 : // Ra
        (RegDst==2'h3) ? 5'd26 : // Xp
        5'b0; // zero won't be write

    always @ (*) begin
        case (MemtoReg)
            2'h0: wdata = ALUOut;
            2'h1: wdata = rdata;
            // 2'h2: case (nextPC)
            //         2'h0: wdata = PC4;
            //         2'h1: wdata = ALUOut[0] ? ConBA : PC4;
            //         2'h2: wdata = {PC[31:28], JT, 2'b0};
            //         2'h3: wdata = DataBusA;
            //         default : wdata = 32'b0;
            //    endcase
            2'h2: wdata = PC;
            default : wdata = 32'b0;
        endcase
    end

    Register register(
        .clk(clk), .rst(rst),
        .RegWrite(RegWrite), 
        .r1(Rs), .r2(Rt), .w(AddrC), 
        .wdata(wdata), 
        .rdata1(DataBusA), .rdata2(DataBusB)
    );

    // ALUControl alucon(
    //     .ALUOp(ALUOp), .Funct(Instruction[5:0]), 
    //     .ALUFun(ALUFun), .Sign(Sign)
    // );

    assign DataBusC = ExtOp ? {{16{Imm16[15]}}, Imm16} : {16'b0, Imm16};
    assign Imm = LuOp ? {Imm16, 16'b0} : DataBusC;
    assign ConBA = {DataBusC[29:0],2'b0} + PC4;

    assign ALU1 = ALUSrc1 ? {27'b0,Shammt[4:0]} : DataBusA;
    assign ALU2 = ALUSrc2 ? Imm : DataBusB;

    ALU alu(
        .in1(ALU1), .in2(ALU2), 
        .ALUFun(ALUFun), .sign(Sign), 
        .out(ALUOut)
    );

    DataMem datamem(
        .clk(clk), .rst(rst), 
        .MemWrite(MemWrite), .MemRead(MemRead), 
        .tx(tx), .rx(rx), 
        .addr(ALUOut), .wdata(DataBusB), 
        .switch(switch), 
        .rdata(rdata), 
        .led(led), 
        .digi(digi), 
        .irq(IRQ)
    );

    digitube_scan digitube(
        .digi_in(digi), 
        .digi_out1(digi_out1), 
        .digi_out2(digi_out2), 
        .digi_out3(digi_out3), 
        .digi_out4(digi_out4)
    );
endmodule