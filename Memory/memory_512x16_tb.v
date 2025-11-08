`timescale 1ns/1ps
`include "memory_512x16.v"

module memory_512x16_tb;
    reg clk;
    reg rst_b;
    reg we;
    reg [8:0] addr;
    reg [15:0] din;
    wire [15:0] dout;

    // Instanțierea modulului de memorie
    memory_512x16 #(
        .AW(9),
        .DW(16),
        .INIT_FILE("")  // fără fișier de inițializare pentru test
    ) mem (
        .clk(clk),
        .rst_b(rst_b),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // Generare clock
    initial begin
        clk = 0;
        forever #50 clk = ~clk;  // perioadă 50ns
    end

    // Test scenario
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, memory_512x16_tb);
        
        // Inițializare
        rst_b = 0;
        we = 0;
        addr = 9'd0;
        din = 16'd0;
        
        // Reset
        #50;
        rst_b = 1;
        #50;
        
        // Test 1: Scriere la adresa 0
        $display("Test 1: Scriere 0xABCD la adresa 0");
        we = 1;
        addr = 9'd0;
        din = 16'hABCD;
        #50;
        
        // Test 2: Citire de la adresa 0
        $display("Test 2: Citire de la adresa 0");
        we = 0;
        addr = 9'd0;
        #50;
        $display("Citit: 0x%h (așteptat: 0xABCD)", dout);
        
        // Test 3: Scriere secvențială
        $display("Test 3: Scriere secvențială la 10 adrese");
        we = 1;
        repeat(10) begin
            din = {7'b0, addr};  // valoarea = adresa
            #50;
            addr = addr + 1;
        end
        
        // Test 4: Citire secvențială
        $display("Test 4: Citire secvențială din 10 adrese");
        we = 0;
        addr = 9'd0;
        repeat(10) begin
            #50;
            $display("Adresa %d: citit 0x%h", addr, dout);
            addr = addr + 1;
        end
        
        // Test 5: Scriere la adresa maximă (511)
        $display("Test 5: Scriere 0x1234 la adresa 511");
        we = 1;
        addr = 9'd511;
        din = 16'h1234;
        #50;
        
        // Test 6: Citire de la adresa maximă
        $display("Test 6: Citire de la adresa 511");
        we = 0;
        #50;
        $display("Citit: 0x%h (așteptat: 0x1234)", dout);
        
        // Test 7: Write enable = 0 (nu scrie)
        $display("Test 7: Încercare scriere cu we=0");
        we = 0;
        addr = 9'd100;
        din = 16'hFFFF;
        #50;
        we = 0;
        #50;
        $display("Citit: 0x%h (nu ar trebui să fie 0xFFFF)", dout);
        
        // Test 8: Reset în timpul operării
        $display("Test 8: Reset în timpul operării");
        we = 1;
        addr = 9'd50;
        din = 16'hDEAD;
        #25;
        rst_b = 0;
        #50;
        rst_b = 1;
        we = 0;
        #50;
        $display("Citit după reset: 0x%h (așteptat: 0x0000)", dout);
        
        #100;
        $display("Test finalizat!");
        $finish;
    end

    // Monitor pentru debug
    initial begin
        $monitor("Time=%0t | rst_b=%b we=%b addr=%d din=0x%h dout=0x%h", 
                 $time, rst_b, we, addr, din, dout);
    end

endmodule