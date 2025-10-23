module M(
    input clk,rst_b,
    input en,
    input [7:0]in,
    output[7:0]out 

);
 
    ffd f0(.clk(clk),.rst_b(rst_b),.en(en),.d(in[0]),.q(out[0]));
    ffd f1(.clk(clk),.rst_b(rst_b),.en(en),.d(in[1]),.q(out[1]));
    ffd f2(.clk(clk),.rst_b(rst_b),.en(en),.d(in[2]),.q(out[2]));
    ffd f3(.clk(clk),.rst_b(rst_b),.en(en),.d(in[3]),.q(out[3]));
    ffd f4(.clk(clk),.rst_b(rst_b),.en(en),.d(in[4]),.q(out[4]));
    ffd f5(.clk(clk),.rst_b(rst_b),.en(en),.d(in[5]),.q(out[5]));
    ffd f6(.clk(clk),.rst_b(rst_b),.en(en),.d(in[6]),.q(out[6]));
    ffd f7(.clk(clk),.rst_b(rst_b),.en(en),.d(in[7]),.q(out[7]));
    
endmodule