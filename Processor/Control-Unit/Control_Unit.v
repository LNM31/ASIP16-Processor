module Control_Unit(
  input         clk, rst_b,
  input  [5:0]  op,         // opcode from IR(Instruction Register)
  input         ra,         // RA - Register Address from IR
  input         start,      // start from user
  input         ack_alu,    // finish from ALU
  output        finish,     
  output [15:0] c           // control signals for proccesor
);
  
  // Implementare OneHot

  wire [25:0] qout;
 
  // 1. HLT
  ffd #(.reset_val(1'b1)) S0 (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    (qout[0] & ~start) | // S0 and start = 0
    qout[3] & (~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0]) // S3 and opcode = 000000

  ), .q(qout[0]));
  
  ffd S1   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[0] & start
  ), .q(qout[1]));
  
  ffd S2   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[1]  | // from S0
    qout[5]  | // from S5
    qout[6]  |
    qout[12] |
    qout[14] |
    qout[16] |
    qout[17] |
    qout[23] |
    qout[25] 
  ), .q(qout[2]));

  ffd S3   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[2]
  ), .q(qout[3]));

  // 2. LDR Reg, #Immediate
  ffd S4   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & 
    (~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & op[0]) // 000001
  ), .q(qout[4]));

  ffd S5   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[4] & ~ra
  ), .q(qout[5]));

  ffd S6   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[4] & ra
  ), .q(qout[6]));

  // 3. LDA Reg, Offset
  ffd S7   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & ~ra &
    (~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0]) // 000010
  ), .q(qout[7]));

  ffd S8   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & ra &
    (~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0]) // 000010
  ), .q(qout[8]));

  ffd S9   (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[7] |
    qout[8]
  ), .q(qout[9]));

  ffd S10  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[9] |
    (qout[10] & ~ack_alu)
  ), .q(qout[10]));

  ffd S11  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[10] & ack_alu
  ), .q(qout[11]));

  ffd S12  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[11]
  ), .q(qout[12]));

  // 6. LDA #Immediate
  ffd S13  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & 
    (~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0]) // 000101
  ), .q(qout[13]));

  ffd S14  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[13]
  ), .q(qout[14]));

  // 4. STR Reg, #Immediate
  ffd S15  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & 
    (~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0]) // 000011
  ), .q(qout[15]));

  ffd S16  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[15] & ~ra
  ), .q(qout[16]));

  ffd S17  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[15] & ra
  ), .q(qout[17 ]));

  // 5. STA Reg, Offset
  ffd S18  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & ~ra &
    (~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0]) // 000100
  ), .q(qout[18 ]));

  ffd S19  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & ra &
    (~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0]) // 000100
  ), .q(qout[19]));

  ffd S20  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[18] |
    qout[19]
  ), .q(qout[20]));

  ffd S21  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[20] |
    (qout[21] & ~ack_alu)
  ), .q(qout[21]));

  ffd S22  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[21] & ack_alu
  ), .q(qout[22]));

  ffd S23  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[22]
  ), .q(qout[23]));

  // 7. STA #Immediate
  ffd S24  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[3] & 
    (~op[5] & ~op[4] & ~op[3] & op[2] & op[1] & ~op[0]) // 000110
  ), .q(qout[24]));

  ffd S25  (.clk(clk), .rst_b(rst_b), .en(1'b1), .d(
    qout[24]
  ), .q(qout[25]));
  
  assign finish = qout[0];
  assign c[0] = qout[1];
  assign c[1] = qout[2];
  assign c[2] = qout[3];
  assign c[3] = qout[4] | qout[13];
  assign c[4] = qout[5];
  assign c[5] = qout[6];
  assign c[6] = qout[7] | qout[18];
  assign c[7] = qout[8] | qout[19];
  assign c[8] = qout[9] | qout[20];
  assign c[9] = qout[11];
  assign c[10] = qout[12] | qout[14];
  assign c[11] = qout[15] | qout[24];
  assign c[12] = qout[16];
  assign c[13] = qout[17];
  assign c[14] = qout[22];
  assign c[15] = qout[23] | qout[25];
  

endmodule