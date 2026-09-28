`timescale 1ns/1ps

module register_file_tb;

reg        clk;
reg        reset;
reg        we;
reg  [1:0] waddr;
reg  [7:0] wdata;
reg  [1:0] raddr1;
reg  [1:0] raddr2;
wire [7:0] rdata1;
wire [7:0] rdata2;

register_file uut (
    .clk    (clk),
    .reset  (reset),
    .we     (we),
    .waddr  (waddr),
    .wdata  (wdata),
    .raddr1 (raddr1),
    .raddr2 (raddr2),
    .rdata1 (rdata1),
    .rdata2 (rdata2)
);

// same free-running clock pattern as every testbench so far
always #5 clk = ~clk;

initial begin
    $dumpfile("register_file_tb.vcd");
    $dumpvars(0, register_file_tb);

    // ---- Startup: hold reset, nothing enabled yet ----
    clk    = 0;
    reset  = 1;
    we     = 0;
    waddr  = 0;
    wdata  = 0;
    raddr1 = 0;
    raddr2 = 1;
    #10 reset = 0;

    // ---- Write 10 into register 0 ----
    we = 1; waddr = 0; wdata = 8'd10;
    #10;

    // ---- Write 20 into register 1 ----
    we = 1; waddr = 1; wdata = 8'd20;
    #10;

    // ---- Write 30 into register 2 ----
    we = 1; waddr = 2; wdata = 8'd30;
    #10;

    // ---- Write 40 into register 3 ----
    we = 1; waddr = 3; wdata = 8'd40;
    #10;

    // ---- Stop writing entirely ----
    // From this point, no matter what wdata is, nothing should change,
    // because we = 0 forces every en[i] to 0 (proved in the address
    // decoding discussion).
    we = 0;
    wdata = 8'd99;   // deliberately "dangerous" value that should be ignored
    #10;

    // ---- Read back register 0 and register 1 at the same time ----
    // This proves the TWO READ PORTS work independently and simultaneously.
    raddr1 = 0;  // expect rdata1 = 10
    raddr2 = 1;  // expect rdata2 = 20
    #10;

    // ---- Now read register 2 and register 3 instead ----
    raddr1 = 2;  // expect rdata1 = 30
    raddr2 = 3;  // expect rdata2 = 40
    #10;

    // ---- Try writing into register 1 again, with a NEW value ----
    // Registers 0, 2, 3 must NOT change -- only register 1 should update.
    we = 1; waddr = 1; wdata = 8'd77;
    #10;
    we = 0;

    // ---- Confirm register 1 updated, and register 0 stayed at 10 ----
    raddr1 = 0;  // expect rdata1 = 10 (unchanged)
    raddr2 = 1;  // expect rdata2 = 77 (just updated)
    #10;

    // ---- Reset everything mid-run ----
    // Every register should snap back to 0, regardless of what was stored.
    reset = 1;
    #10;
    reset = 0;

    raddr1 = 1;  // expect rdata1 = 0
    raddr2 = 2;  // expect rdata2 = 0
    #10;

    #20 $finish;
end

endmodule