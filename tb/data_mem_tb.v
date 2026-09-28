`timescale 1ns/1ps

module data_mem_tb;

reg        clk;
reg        we;
reg  [7:0] addr;
reg  [7:0] wdata;
wire [7:0] rdata;

data_mem uut (
    .clk   (clk),
    .we    (we),
    .addr  (addr),
    .wdata (wdata),
    .rdata (rdata)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("data_mem_tb.vcd");
    $dumpvars(0, data_mem_tb);

    clk = 0;
    we = 0;
    addr = 8'd0;
    wdata = 8'd0;

    // ---- Confirm memory starts clean at 0, not unknown ----
    addr = 8'd50;
    #10;  // expect rdata = 00

    // ---- Write 88 into address 50 ----
    we = 1; addr = 8'd50; wdata = 8'd88;
    #10;
    we = 0;

    // ---- Read it back ----
    addr = 8'd50;
    #10;  // expect rdata = 88

    // ---- Write a DIFFERENT value into a DIFFERENT address ----
    we = 1; addr = 8'd51; wdata = 8'd200;
    #10;
    we = 0;

    // ---- Confirm address 50 is UNCHANGED, and address 51 has the new value ----
    addr = 8'd50;
    #10;  // expect rdata = 88 (still)
    addr = 8'd51;
    #10;  // expect rdata = 200

    #20 $finish;
end

endmodule