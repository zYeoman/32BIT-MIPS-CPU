module Forward(
    input EX2MEM_RegWrite, 
    input MEM2WB_RegWrite, 
    input [4:0] EX2MEM_Rd,     // !!! AddrC i.e. EX2MEM_Rd
            MEM2WB_Rd,     // !!! AddrC i.e. MEM2WB_Rd
            ID2EX_Rs, 
            ID2EX_Rt, 
            ID2EX_Rd, 
    output reg[1:0] ForwardA,
    output reg[1:0] ForwardB
);
    // ForwardX: 2->ALUOut, 1->rdata, 0->DataBusA
    //           2->last, 1->last last, 0->normal
    always @(*) begin
        if((EX2MEM_RegWrite)&(|EX2MEM_Rd)&(EX2MEM_Rd==ID2EX_Rs))
            ForwardA <= 2'h2;
        else if( (MEM2WB_RegWrite) & (|MEM2WB_Rd) & (MEM2WB_Rd==ID2EX_Rs) & ~(EX2MEM_Rd==ID2EX_Rs&&EX2MEM_RegWrite))
            ForwardA <= 2'h1;
        else
            ForwardA <= 2'h0;
    end

    always @(*) begin
        if((EX2MEM_RegWrite)&(|EX2MEM_Rd)&(EX2MEM_Rd==ID2EX_Rt))
            ForwardB <= 2'h2;
        else if((MEM2WB_RegWrite) & (|MEM2WB_Rd) & (MEM2WB_Rd==ID2EX_Rt) & ~(EX2MEM_Rd==ID2EX_Rt&&EX2MEM_RegWrite))
            ForwardB <= 2'h1;
        else
            ForwardB <= 2'h0;
    end
endmodule

// no IF2ID_Rs & IF2ID_Rt
// directly connect from `instruction` outside this module
module Hazard(
    input ID2EX_MemRead, 
        Branch2, 
        Jump, 
    input[4:0] ID2EX_Rt, 
        IF2ID_Rs, 
        IF2ID_Rt, 
    output reg IFID_flush, 
        IDEX_flush, 
        PC_write, 
        IFID_write
);
    always @(*) begin
        if(ID2EX_MemRead&((ID2EX_Rt==IF2ID_Rs)|(ID2EX_Rt==IF2ID_Rt))) begin              //ID2EX_MemRead是第二个寄存器的存储器读使能，ID2EX_Rt是Rt寄存器的地址，Rs是rs地址
            IFID_flush<=0;                                              //IFID_flush是第一个寄存器的清除使能
            IDEX_flush<=1;                                          //IDEX_flush是第二个寄存器的清除使能
            PC_write<=0;                                        //程序计数器的写使能    
            IFID_write<=0;                                 //第一个寄存器的写使能
        end else if(Jump) begin
            IFID_flush<=1;                                   
            IDEX_flush<=0;
            PC_write<=1;
            IFID_write<=1;
        end else if(Branch2) begin
            IFID_flush<=1;
            IDEX_flush<=1;
            PC_write<=1;
            IFID_write<=1;
        end else begin
            IFID_flush<=0;
            IDEX_flush<=0;
            PC_write<=1;
            IFID_write<=1;
        end
    end
 endmodule
