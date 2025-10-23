module Q(
    input clk,rst_b,
    input a0,
    input [1:0]sel,
    input [7:0]in,
    output[7:0]out,
    output q_1 

);
    wire[7:0]mux_wire;
    wire mux_q;
    //                  same      shfit_right  shift_left    load
    mux_2s#(.w(1))m_1(.d0(q_1   ),.d1(out[0]),.d2(1'b0  ),.d3(1'b0 ),.sel(sel),.o(mux_q      ));
    mux_2s#(.w(1)) m0(.d0(out[0]),.d1(out[1]),.d2(1'b0  ),.d3(in[0]),.sel(sel),.o(mux_wire[0]));
    mux_2s#(.w(1)) m1(.d0(out[1]),.d1(out[2]),.d2(out[0]),.d3(in[1]),.sel(sel),.o(mux_wire[1]));
    mux_2s#(.w(1)) m2(.d0(out[2]),.d1(out[3]),.d2(out[1]),.d3(in[2]),.sel(sel),.o(mux_wire[2]));
    mux_2s#(.w(1)) m3(.d0(out[3]),.d1(out[4]),.d2(out[2]),.d3(in[3]),.sel(sel),.o(mux_wire[3]));
    mux_2s#(.w(1)) m4(.d0(out[4]),.d1(out[5]),.d2(out[3]),.d3(in[4]),.sel(sel),.o(mux_wire[4]));
    mux_2s#(.w(1)) m5(.d0(out[5]),.d1(out[6]),.d2(out[4]),.d3(in[5]),.sel(sel),.o(mux_wire[5]));
    mux_2s#(.w(1)) m6(.d0(out[6]),.d1(out[7]),.d2(out[5]),.d3(in[6]),.sel(sel),.o(mux_wire[6]));
    mux_2s#(.w(1)) m7(.d0(out[7]),.d1(a0    ),.d2(out[6]),.d3(in[7]),.sel(sel),.o(mux_wire[7]));

    ffd f_1(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_q      ),.q(q_1   ));
    ffd  f0(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[0]),.q(out[0]));
    ffd  f1(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[1]),.q(out[1]));
    ffd  f2(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[2]),.q(out[2]));
    ffd  f3(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[3]),.q(out[3]));
    ffd  f4(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[4]),.q(out[4]));
    ffd  f5(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[5]),.q(out[5]));
    ffd  f6(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[6]),.q(out[6]));
    ffd  f7(.clk(clk),.rst_b(rst_b),.en(1'b1),.d(mux_wire[7]),.q(out[7]));
    
endmodule