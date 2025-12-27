module ffd #(
    parameter reset_val = 1'b0
)(
    input clk, rst_b,
    input en, d,
    output reg q
);
    always @(posedge clk or negedge rst_b)
    begin
        if(!rst_b)
            q <= reset_val;
        else if(en)
            q <= d;
    end
endmodule