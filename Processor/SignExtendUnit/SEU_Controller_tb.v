`timescale 1ns/1ps

module SEU_Controller_tb;

  reg [5:0] opcode;
  wire [1:0] selector;
  
  SEU_Controller uut (
    .opcode(opcode),
    .selector(selector)
  );
  
  integer i;
  
  initial begin
    
    for (i = 0; i < 64; i = i + 1) begin
      opcode = i;
      #10;
      $display("opcode=%b => selector=%b", opcode, selector);
    end
    
    $finish;
  end

endmodule
