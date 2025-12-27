module SEU_Controller(
  input  [5:0]  opcode,
  output [1:0]  selector
);

  // sel[1] = (!x5 & !x4 & !x3 & !x2 & !x1 & !x0) | (!x5 & !x4 & x3 & !x2) | (!x5 & x4 & !x3 & x2 & x1) | ( x5 & !x4 & x3 & !x2 & x1)
  // sel[0] = (!x5 & x4)
  // A = opcode[0], B = opcode[1], C = opcode[2], D = opcode[3], E = opcode[4], F = opcode[5]

  assign selector[1] = 
          (~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0])   | // 0
          (~opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0])   | // 7
          (~opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] & (~opcode[1] | ~opcode[0])) | // 8, 9, 10
          (~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0])   | // 19
          ( opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] &  opcode[1])                | // 42, 43
          ( opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] & ~opcode[1] & ~opcode[0]);    // 44


  assign selector[0] = 
          (~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0])   | // 0
          (~opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0])   | // 7
          (~opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] & (~opcode[1] | ~opcode[0])) | // 8, 9, 10
          (~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0])   | // 19
          ( opcode[5] & ~opcode[4] &  opcode[3] & ~opcode[2] &  opcode[1])                | // 42, 43
          (~opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2])                             | // 20-23
          (~opcode[5] &  opcode[4] &  opcode[3] & ~opcode[2])                             | // 24-27
          (~opcode[5] &  opcode[4] &  opcode[3] &  opcode[2] & ~opcode[1] & ~opcode[0]);    // 28                

endmodule