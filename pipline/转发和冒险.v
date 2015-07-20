module Forward(EXMEMWr,MEMWBWr,EXMEMADDR,MEMWBADDR,IDEXRs,IDEXRt,DataBusA,DataBusB,ALUout,ReadData,DataA,DataB);
  input EXMEMWr;
  input MEMWBWr;
  input[4:0] EXMEMADDR;
  input[4:0] MEMWBADDR;
  input[4:0] IDEXRs;
  input[4:0] IDEXRt; 
  input [31:0] DataBusA,DataBusB,ALUout,ReadData;
  output reg[31:0] DataA;
  output reg[31:0] DataB;
  
  always @(*)
  begin
    if((EXMEMWr)&(|EXMEMRd)&(EXMEMRd==IDEXRs))                    //EXMEMWr第三个寄存器的写回寄存器堆使能 Rd是Rd寄存器地址 Rs是Rs地址	
      DataA<=ALUout;                                              //DataA输出到ALU第一个端口的数据 ALUout是第三个寄存器中ALU输出                                          
    else
      if((MEMWBWr)&(|MEMWBRd)&(MEMWBRd==IDEXRs))                 //MEMWBWr第四个寄存器的写回寄存器堆使能 
        DataA<=ReadData;                                           //ReadData是第四个寄存器中存储器输出的数据

      else
        DataA<=DataBusA;                                          //DataBusA寄存器堆输出的第一个数据
      end
  always @(*)
  begin
  if((EXMEMWr)&(|EXMEMRd)&(EXMEMRd==IDEXRt))
      DataB<=ALUout;                                              //DataB输出到ALU第二个端口的数据
    else
      if((MEMWBWr)&(|MEMWBRd)&(MEMWBRd==IDEXRt))
        DataB<=ReadData;
      else
        DataB<=DataBusB;
  end
endmodule
	
	
module Hazard(Branch2,Jump,IDEXRead,IDEXRt,IFIDRs,IFIDRt,IFID_flush,IDEX_flush,PC_write,IFID_write);
 input IDEXRead,Branch2,Jump;
 input[4:0] IDEXRt,IFIDRs,IFIDRt;
 output reg IFID_flush,IDEX_flush,PC_write,IFID_write,;
 always @(*)
 begin
   if(IDEXRead&((IDEXRt==IFIDRs)|(IDEXRt==IFIDRt)))              //IDEXRead是第二个寄存器的存储器读使能，IDEXRt是Rt寄存器的地址，Rs是rs地址
     IFID_flush<=0;                                              //IFID_flush是第一个寄存器的清除使能
	 IDEX_flush<=1;                                          //IDEX_flush是第二个寄存器的清除使能
	 PC_write<=0;                                        //程序计数器的写使能	
	 IFID_write<=0;                                 //第一个寄存器的写使能                          
   else if(Jump)
     IFID_flush<=1;                                   
	 IDEX_flush<=0;
	 PC_write<=1;
	 IFID_write<=1;
	 else if(Branch2)
	  IFID_flush<=1;
	 IDEX_flush<=1;
	 PC_write<=1;
	 IFID_write<=1;
	 else
	  IFID_flush<=0;
	 IDEX_flush<=0;
	 PC_write<=1;
	 IFID_write<=1;
   end
 endmodule