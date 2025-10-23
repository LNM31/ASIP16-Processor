`timescale 1ns/1ps
`include "ALU.v"
module ALU_tb;
    reg clk,rst_b,start;
    reg[1:0]s;
    reg [7:0]inbus;
    wire[7:0]outbus;
    wire finish;
    wire overflow;

    ALU alu(
        .clk(clk),
        .rst_b(rst_b),
        .start(start),
        .s(s),
        .inbus(inbus),
        .outbus(outbus),
        .finish(finish),
        .overflow(overflow)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        clk=0;
        rst_b=1;
        start=0;
        inbus=0;
        s=0;
    end

    integer i;
    initial begin
        for(i=0;i<1000;i=i+1)
        begin
            #50; clk=~clk;
        end
        #50;
    end

    initial begin // adunare
        #10; rst_b=0; 
        #20; rst_b=1; 
        #20; s=2'b00; 
        #40; start=1; 
        #50; inbus=8'b00111001; //140 inbus=8'b00111001;//M 57
        #30; start=0; 
        #60; inbus=8'b01000011;  //230 inbus=8'b01010110; //Q 67
    end

    initial begin // scadere
        #800;
        #10; rst_b=0; 
        #20; rst_b=1; 
        #20; s=2'b01; 
        #40; start=1; 
        #50; inbus=8'b00111001; //140 inbus=8'b00111001;//M 57
        #30; start=0; 
        #60; inbus=8'b01000011;  //230 inbus=8'b01010110; //Q 67
    end

    initial begin // adunare cu overflow
        #1500;
        #10; rst_b=0;
        #20; rst_b=1;
        #20; s=2'b00;
        #40; start=1;
        #50; inbus=8'b01111111; //M=127 test overflow adunare 127 + 126 = -3 in c2
        #30; start=0;
        #60; inbus=8'b01111110; //Q=126 test overflow adunare 127 + 126 = -3 in c2
    end

    initial begin // scadere cu overflow
        #2300;
        #10; rst_b=0;
        #20; rst_b=1;
        #20; s=2'b01;
        #40; start=1;
        #50; inbus=8'b00000001; //M=1 test overflow scadere -128 - 1 = 127 in c2
        #30; start=0;
        #60; inbus=8'b10000000; //Q=-128 test overflow scadere -128 -1 = 127 in c2
    end

    initial begin // inmultire
        #3100;
        #10; rst_b=0;
        #20; rst_b=1;
        #20; s=2'b10;
        #40; start=1;
        #50; inbus=8'b10100011;//M -93 inmultire
        #30; start=0;
        #60; inbus=8'b10001101;//Q -115 inmultire
        //00101001     11000111
    end

    initial begin // inmultire
        #6500;
        #10; rst_b=0;
        #20; rst_b=1;
        #20; s=2'b10;
        #40; start=1;
        #50; inbus=8'b01011001;//M 89 inmultire 
        #30; start=0;
        #60; inbus=8'b10011111;//Q -97 inmultire 
        //11011110    01000111
    end

    initial begin // inmultire
        #9800;
        #10; rst_b=0;
        #20; rst_b=1;
        #20; s=2'b10;
        #40; start=1;
        #50; inbus=8'b10100001;//M -119 inmultire  
        #30; start=0;
        #60; inbus=8'b10001001;//Q -95 inmultire 
        //00101100     00101001
    end

    initial begin // impartire
        #13300;
        #10; rst_b=0;
        #20; rst_b=1;
        #20; s=2'b11;
        #40; start=1;
        #50; inbus=8'b00001101;//M 13 impartire  
        #30; start=0;
        #60; inbus=8'b11011001;//Q 217 impartire 
        //9     16
    end

    initial begin // impartire
        #17200;
        #10; rst_b=0;
        #20; rst_b=1;
        #20; s=2'b11;
        #40; start=1;
        #50; inbus=8'b00001100;//M 12 impartire 
        #30; start=0;
        #60; inbus=8'b11110111;//Q 247 impartire 
        //7     20
    end


endmodule