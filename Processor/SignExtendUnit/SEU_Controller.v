module SEU_Controller(
  input  [5:0]  opcode,
  output [1:0]  selector
);

  assign selector[1] = 
          (~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0])   | 
          (~opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0])   | 
          (~opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] & (~opcode[1] | ~opcode[0])) | 
          (~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0])   | 
          ( opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] &  opcode[1])                | 
          ( opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] & ~opcode[1] & ~opcode[0]);    


  assign selector[0] = 
          (~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0])   | 
          (~opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0])   | 
          (~opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] & (~opcode[1] | ~opcode[0])) | 
          (~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0])   | 
          ( opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] &  opcode[1])                | 
          (~opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2])                             | 
          (~opcode[5] &  opcode[4] &  opcode[3] & ~opcode[2])                             | 
          (~opcode[5] &  opcode[4] &  opcode[3] &  opcode[2] & ~opcode[1] & ~opcode[0]);    

endmodule