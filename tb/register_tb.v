`timescale 1ns/1ps

module register_tb;

reg clk;
reg reset;
reg en;
reg [7:0] d;
wire [7:0] q;

register #(.WIDTH(8)) uut (
    .clk   (clk),
    .reset (reset),
    .en    (en),
    .d     (d),
    .q     (q)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("register_tb.vcd");
    $dumpvars(0, register_tb);

    clk = 0;
    reset = 1;
    en = 0;
    d = 8'd0;

    #10 reset = 0;

    // Try loading while en = 0 -> q should NOT change
    d = 8'd12;
    #10;

    // Now enable and load the same value -> q SHOULD become 12
    en = 1;
    #10;

    // Change d again while en stays 1 -> q should follow
    d = 8'd200;
    #10;

    // Disable, then change d again -> q should hold at 200
    en = 0;
    d = 8'd50;
    #10;
    #10;

    // Assert reset mid-run -> q should snap to 0 immediately
    reset = 1;
    #10;
    reset = 0;

    #20 $finish;
end

endmodule