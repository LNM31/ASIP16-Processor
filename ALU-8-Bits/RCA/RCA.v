module fac(
    input x,y,ci,
    output z,co
);
    assign z=x^y^ci;
    assign co=(x&y)|(x&ci)|(y&ci);
endmodule

module RCA(
    input [8:0]x,y,
    input ci,
    output [8:0]z,
    output co,
    output overflow
);
    wire [7:0]w_co;
    genvar i;
    generate
        for(i=0;i<9;i=i+1)
        begin
            if(i==0)
            fac f(
                .x(x[0]),
                .y(y[0]),
                .ci(ci),
                .z(z[0]),
                .co(w_co[0])
            );
            else if(i==8)
            fac f(
                .x(x[8]),
                .y(y[8]),
                .ci(w_co[7]),
                .z(z[8]),
                .co(co)
            );
            else
            fac f(
                .x(x[i]),
                .y(y[i]),
                .ci(w_co[i-1]),
                .z(z[i]),
                .co(w_co[i])
            );
        end
    endgenerate

    assign overflow=w_co[7] ^ w_co[6];
endmodule
