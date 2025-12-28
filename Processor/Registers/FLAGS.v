module FLAGS(
    input clk, rst_b,
    input en,
    input [3:0] in,
    output[3:0] out 
);
 
    ffd  f0(.clk(clk), .rst_b(rst_b), .en(en), .d(in[0] ), .q(out[0] ));
    ffd  f1(.clk(clk), .rst_b(rst_b), .en(en), .d(in[1] ), .q(out[1] ));
    ffd  f2(.clk(clk), .rst_b(rst_b), .en(en), .d(in[2] ), .q(out[2] ));
    ffd  f3(.clk(clk), .rst_b(rst_b), .en(en), .d(in[3] ), .q(out[3] ));
    
endmodule