`timescale 1ns/1ps
`include "CU_Extended.v"

module CU_Extended_tb;

  // Clocking and reset
  reg clk;
  reg rst_b;
  localparam integer CLK_PERIOD = 100; // ns

  // Inputs
  reg  [3:0] s;
  reg        start;
  reg        q0, q_1, a_16, cmp_cnt_m4;
  reg  [3:0] cnt;

  // Outputs
  wire [18:0] c;
  wire        finish;

  // DUT
  Control_Unit dut (
    .clk(clk),
    .rst_b(rst_b),
    .s(s),
    .start(start),
    .q0(q0),
    .q_1(q_1),
    .a_16(a_16),
    .cmp_cnt_m4(cmp_cnt_m4),
    .cnt(cnt),
    .c(c),
    .finish(finish)
  );

  // Clock generation
  initial clk = 1'b0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // Utilities
  task automatic do_reset(input integer cycles);
    begin
      rst_b = 1'b0;
      repeat (cycles) @(posedge clk);
      rst_b = 1'b1;
      @(posedge clk);
    end
  endtask

  task automatic drive_inputs(
    input [3:0] s_i,
    input       start_i,
    input       q0_i,
    input       q_1_i,
    input       a_16_i,
    input       cmp_cnt_m4_i,
    input [3:0] cnt_i
  );
    begin
      s          = s_i;
      start      = start_i;
      q0         = q0_i;
      q_1        = q_1_i;
      a_16       = a_16_i;
      cmp_cnt_m4 = cmp_cnt_m4_i;
      cnt        = cnt_i;
    end
  endtask

  // Advance one clock, then wait a delta (#0) so NBAs settle before sampling
  task automatic step; begin @(posedge clk); #0; end endtask
  task automatic stepn(input integer n);
    integer i;
    begin
      for (i = 0; i < n; i = i + 1) step();
    end
  endtask

  // Simple checker (fill expected values when known)
  task automatic check_outputs(
    input [18:0] exp_c,
    input        exp_finish,
    input [8*64:1] name
  );
    begin
      if ((c === exp_c) && (finish === exp_finish))
        $display("[%0t] PASS %-20s c=%b finish=%b", $time, name, c, finish);
      else begin
        $error  ("[%0t] FAIL %-20s", $time, name);
        $display("        exp c=%b got c=%b | exp fin=%b got fin=%b", exp_c, c, exp_finish, finish);
      end
    end
  endtask

  // Wave dumps and live monitor
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, CU_Extended_tb);
    $display("Time  rst s  start q0 q_1 a_16 cmp cnt | c[18:0] finish");
  end

  initial begin
    $monitor("%5t  %b  %4b   %b    %b  %b   %b    %b  %2d | %019b   %b",
             $time, rst_b, s, start, q0, q_1, a_16, cmp_cnt_m4, cnt, c, finish);
  end

  // Main stimulus
  initial begin
    // Defaults
    s = 4'd0; start = 1'b0; q0 = 1'b0; q_1 = 1'b0; a_16 = 1'b0; cmp_cnt_m4 = 1'b0; cnt = 4'd0;

    // Reset
    do_reset(2);

    // Scenario 1: pulse start with s=0000, cnt=0..3
    drive_inputs(4'b0000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'd0); step();
    drive_inputs(4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'd1); step();
    drive_inputs(4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 4'd2); step();
    drive_inputs(4'b0000, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 4'd3); step();

    // Example check (replace X with expected when you know them)
    // check_outputs(19'bX, 1'bX, "scenario1_end");

    // Scenario 2: exercise cmp_cnt_m4 and a_16 paths
    drive_inputs(4'b0010, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 4'd15); step();
    drive_inputs(4'b0010, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 4'd15); stepn(3);

    // Scenario 3: toggle q0/q_1 to hit (q0 ~^ q_1) conditions
    drive_inputs(4'b0101, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 4'd7); step();
    drive_inputs(4'b0101, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 4'd7); step();
    drive_inputs(4'b0101, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'd7); step();

    // Finish
    stepn(5);
    $display("Testbench finished");
    $finish;
  end

endmodule