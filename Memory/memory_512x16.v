module memory_512x16 #(
    parameter AW = 9,          // address width (512 = 2^9)
    parameter DW = 16,         // data width
    parameter INIT_FILE = ""   // optional: mem init (hex/binary)
)(
    input              clk,
    input              rst_b,
    input              we,         // write enable (active high)
    input  [AW-1:0]    addr,       // address
    input  [DW-1:0]    din,        // data in
    output reg [DW-1:0] dout       // data out
);

    reg [DW-1:0] mem [0:(1<<AW)-1];

    // Optional initialization
    integer i;
    initial begin
        if (INIT_FILE != "") 
        begin
            $readmemh(INIT_FILE, mem);
        end 
        else 
        begin
            for (i = 0; i < (1<<AW); i = i + 1)
                mem[i] = {DW{1'b0}};
        end
    end

    // Synchronous read & write (read-after-write same cycle gives new data)
    always @(posedge clk or negedge rst_b) 
    begin
        if (!rst_b) 
        begin
            dout <= {DW{1'b0}};
        end 
        else begin
            if (we)
                mem[addr] <= din;
            dout <= mem[addr];
        end
    end
endmodule