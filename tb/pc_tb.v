`timescale 1ns/1ps

module pc_tb;

reg        clk;
reg        reset;
reg        load;
reg  [7:0] load_val;
wire [7:0] count;

pc uut (
    .clk      (clk),
    .reset    (reset),
    .load     (load),
    .load_val (load_val),
    .count    (count)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("pc_tb.vcd");
    $dumpvars(0, pc_tb);

    // ---- Startup: reset should force count to 0 ----
    clk      = 0;
    reset    = 1;
    load     = 0;
    load_val = 8'd0;
    #10 reset = 0;

    // ---- Normal counting: count should tick 0,1,2,3,4,5 on its own ----
    // (load stays 0 the whole time, so it should just keep incrementing)
    #10; // count -> 1
    #10; // count -> 2
    #10; // count -> 3
    #10; // count -> 4
    #10; // count -> 5

    // ---- JUMP: force count to jump to address 100, skipping ahead ----
    load     = 1;
    load_val = 8'd100;
    #10;               // this edge should make count become 100
    load = 0;           // release the jump, go back to normal counting

    // ---- Confirm normal counting resumes FROM the jumped address ----
    #10; // count -> 101
    #10; // count -> 102

    // ---- PRIORITY TEST: assert reset AND load at the same time ----
    // reset must win -- count should snap to 0, NOT jump to load_val
    load     = 1;
    load_val = 8'd200;
    reset    = 1;
    #10;
    reset = 0;
    load  = 0;

    // ---- Confirm normal counting resumes from 0 ----
    #10; // count -> 1
    #10; // count -> 2

    #20 $finish;
end

endmodule