module Forward(
    input EX2MEM_RegWrite, 
    input MEM2WB_RegWrite, 
    input [4:0] EX2MEM_Rd,     // !!! AddrC i.e. EX2MEM_Rd
            MEM2WB_Rd,     // !!! AddrC i.e. MEM2WB_Rd
            ID2EX_Rs, 
            IF2ID_Rs, 
            ID2EX_Rt, 
            IF2ID_Rt, 
            ID2EX_Rd, 
    output reg[1:0] ForwardA,
        ForwardB, 
    output reg ForwardC, 
        ForwardD
);
    // ForwardX: 2->ALUOut, 1->wdata, 0->DataBusA
    //           2->last, 1->last last, 0->normal
    always @(*) begin
        if((EX2MEM_RegWrite)&&(EX2MEM_Rd!=5'h0)&&(EX2MEM_Rd==ID2EX_Rs))
            ForwardA <= 2'h2;
        else if( (MEM2WB_RegWrite) & (|MEM2WB_Rd) & (MEM2WB_Rd==ID2EX_Rs) & ~(EX2MEM_Rd==ID2EX_Rs&&EX2MEM_RegWrite))
            ForwardA <= 2'h1;
        else
            ForwardA <= 2'h0;
    end

    always @(*) begin
        if((EX2MEM_RegWrite)&(|EX2MEM_Rd)&(EX2MEM_Rd==ID2EX_Rt))
            ForwardB <= 2'h2;
        else if((MEM2WB_RegWrite) & (|MEM2WB_Rd) & (MEM2WB_Rd==ID2EX_Rt) & ~(EX2MEM_Rd==ID2EX_Rt&&EX2MEM_RegWrite)  )
            ForwardB <= 2'h1;
        else
            ForwardB <= 2'h0;
    end

    always @ (*)
        if(MEM2WB_RegWrite & (|MEM2WB_Rd) & (MEM2WB_Rd == IF2ID_Rs)) // Rd ie AddrC to be written
            ForwardC = 1'b1;
        else
            ForwardC = 1'b0;

    always @ (*)
        if(MEM2WB_RegWrite & (|MEM2WB_Rd) & (MEM2WB_Rd == IF2ID_Rt)) // Rd ie AddrC to be written
            ForwardD = 1'b1;
        else
            ForwardD = 1'b0;
endmodule

// no IF2ID_Rs & IF2ID_Rt
// directly connect from `instruction` outside this module
//为产生气泡，对寄存器进行清除，产生气泡可以延后时钟周期方便转发
//jump为第二阶段，branch为第三阶段，清除寄存器延后时钟周期
module Hazard(
    input ID2EX_MemRead, 
        Branch, 
        Jump, 
    input[4:0] ID2EX_Rt, 
        IF2ID_Rs, 
        IF2ID_Rt, 
    output reg PCWrite, 
        IF2ID_flush, 
        IF2ID_write,
        ID2EX_flush
);
    //
    always @(*) begin
        if(ID2EX_MemRead&((ID2EX_Rt==IF2ID_Rs)|(ID2EX_Rt==IF2ID_Rt))) begin
            PCWrite = 1'b0;
            IF2ID_flush = 1'b0;
            IF2ID_write = 1'b0;
            ID2EX_flush = 1'b1;
        end else if(Jump) begin
            PCWrite = 1'b1;
            IF2ID_flush = 1'b1;
            IF2ID_write = 1'b0;
            ID2EX_flush = 1'b0;
        end else if(Branch) begin 
            PCWrite = 1'b1;
            IF2ID_flush = 1'b1;
            IF2ID_write = 1'b0;
            ID2EX_flush = 1'b1;
        end else begin
            PCWrite = 1'b1;
            IF2ID_flush = 1'b0;
            IF2ID_write = 1'b1;
            ID2EX_flush = 1'b0;
        end
    end
 endmodule
