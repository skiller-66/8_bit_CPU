`timescale 1ns/1ps

module dff_tb;

reg clk;
reg reset;
reg d;
wire q;

dff uut (
    .clk(clk),
    .reset(reset),
    .d(d),
    .q(q)
);

// Clock generator: toggle every 5ns -> 10ns period
always #5 clk = ~clk;

initial begin
    $dumpfile("dff_tb.vcd");
    $dumpvars(0, dff_tb);

    clk = 0;
    reset = 1;
    d = 0;

    #10 reset = 0;

    #10 d = 1;
    #10 d = 0;
    #10 d = 1;
    #20 d = 0;

    #20 $finish;
end

endmodule