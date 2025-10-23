`include"../RCA/RCA.v"
`include"../Control_Unit/Control_Unit_Structural.v"
`include"../Registers/A.v"
`include"../Registers/Q.v"
`include"../Registers/M.v"
`include"../Registers/combinational.v"
`include"../Registers/ffd.v"
`include"../Registers/counter.v"

module ALU (
    input clk,rst_b,start,
    input[1:0]s,
    input [7:0]inbus,
    output [7:0]outbus,
    output overflow,
    output finish
);
    wire [7:0]q_out,m_out;
    wire [8:0]a_out;
    wire [2:0]cnt_out;
    wire q_1out;
    wire [10:0]c;
    wire [8:0]z;
    wire overfl;

    A regA(.clk(clk),.rst_b(rst_b),.q7(q_out[7]),.sel( {c[0]|c[2]|c[3]|c[9], c[0]|c[2]|c[3]|c[6]}),.in({9{c[0]}}&9'd0 | {9{c[2]}}&q_out | {9{c[3]}}&z),.out(a_out));
    Q regQ(.clk(clk),.rst_b(rst_b),.a0(a_out[0]),.sel( {c[1]|c[9]|c[10] , c[1]|c[6]|c[10]} ),.in({8{c[1]}}&inbus |  {q_out[7:1],(~a_out[8])}&{8{c[10]}} ),.out(q_out),.q_1(q_1out));
    M regM(.clk(clk),.rst_b(rst_b),.en(c[0]),.in(inbus),.out(m_out));
    RCA adder(.x({1'b0,m_out} ^ {9{c[4]}}),.y(a_out),.ci(c[4]),.z(z),.co(),.overflow(overfl));
    counter COUNT(.clk(clk),.rst_b(rst_b),.c_up(c[7]),.out(cnt_out));
    Control_Unit CU(.clk(clk),.rst_b(rst_b),.s(s),.start(start),.q0(q_out[0]),.q_1(q_1out),.a_8(a_out[8]),.cnt(cnt_out),.c(c),.finish(finish));
    
    assign outbus={1'b0,{8{c[5]}}}&a_out | {{8{c[8]}}}&q_out;
    assign overflow=overfl & ~s[1] & c[3]; 

endmodule