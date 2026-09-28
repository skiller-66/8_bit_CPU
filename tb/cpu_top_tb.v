`timescale 1ns/1ps

module cpu_top_tb;

reg clk;
reg reset;

cpu_top uut (
    .clk   (clk),
    .reset (reset)
);

always #5 clk = ~clk;

reg [7:0] seed [0:3];

initial begin
    seed[0] = 8'd77;  // R0 -- the value we'll store into memory
    seed[1] = 8'd0;   // R1 -- starts empty, LOAD should fill this with 77
    seed[2] = 8'd0;   // R2 -- unused this program
    seed[3] = 8'd80;  // R3 -- the memory address pointer, used by both STORE and LOAD
    clk   = 0;
    reset = 1;

    $dumpfile("cpu_top_tb.vcd");
    $dumpvars(0, cpu_top_tb);

    #10 reset = 0;

    force uut.u_regfile.regs[0].r.bit[0].u_dff.q = seed[0][0];
    force uut.u_regfile.regs[0].r.bit[1].u_dff.q = seed[0][1];
    force uut.u_regfile.regs[0].r.bit[2].u_dff.q = seed[0][2];
    force uut.u_regfile.regs[0].r.bit[3].u_dff.q = seed[0][3];
    force uut.u_regfile.regs[0].r.bit[4].u_dff.q = seed[0][4];
    force uut.u_regfile.regs[0].r.bit[5].u_dff.q = seed[0][5];
    force uut.u_regfile.regs[0].r.bit[6].u_dff.q = seed[0][6];
    force uut.u_regfile.regs[0].r.bit[7].u_dff.q = seed[0][7];

    force uut.u_regfile.regs[1].r.bit[0].u_dff.q = seed[1][0];
    force uut.u_regfile.regs[1].r.bit[1].u_dff.q = seed[1][1];
    force uut.u_regfile.regs[1].r.bit[2].u_dff.q = seed[1][2];
    force uut.u_regfile.regs[1].r.bit[3].u_dff.q = seed[1][3];
    force uut.u_regfile.regs[1].r.bit[4].u_dff.q = seed[1][4];
    force uut.u_regfile.regs[1].r.bit[5].u_dff.q = seed[1][5];
    force uut.u_regfile.regs[1].r.bit[6].u_dff.q = seed[1][6];
    force uut.u_regfile.regs[1].r.bit[7].u_dff.q = seed[1][7];

    force uut.u_regfile.regs[2].r.bit[0].u_dff.q = seed[2][0];
    force uut.u_regfile.regs[2].r.bit[1].u_dff.q = seed[2][1];
    force uut.u_regfile.regs[2].r.bit[2].u_dff.q = seed[2][2];
    force uut.u_regfile.regs[2].r.bit[3].u_dff.q = seed[2][3];
    force uut.u_regfile.regs[2].r.bit[4].u_dff.q = seed[2][4];
    force uut.u_regfile.regs[2].r.bit[5].u_dff.q = seed[2][5];
    force uut.u_regfile.regs[2].r.bit[6].u_dff.q = seed[2][6];
    force uut.u_regfile.regs[2].r.bit[7].u_dff.q = seed[2][7];

    force uut.u_regfile.regs[3].r.bit[0].u_dff.q = seed[3][0];
    force uut.u_regfile.regs[3].r.bit[1].u_dff.q = seed[3][1];
    force uut.u_regfile.regs[3].r.bit[2].u_dff.q = seed[3][2];
    force uut.u_regfile.regs[3].r.bit[3].u_dff.q = seed[3][3];
    force uut.u_regfile.regs[3].r.bit[4].u_dff.q = seed[3][4];
    force uut.u_regfile.regs[3].r.bit[5].u_dff.q = seed[3][5];
    force uut.u_regfile.regs[3].r.bit[6].u_dff.q = seed[3][6];
    force uut.u_regfile.regs[3].r.bit[7].u_dff.q = seed[3][7];

    #1;

    release uut.u_regfile.regs[0].r.bit[0].u_dff.q;
    release uut.u_regfile.regs[0].r.bit[1].u_dff.q;
    release uut.u_regfile.regs[0].r.bit[2].u_dff.q;
    release uut.u_regfile.regs[0].r.bit[3].u_dff.q;
    release uut.u_regfile.regs[0].r.bit[4].u_dff.q;
    release uut.u_regfile.regs[0].r.bit[5].u_dff.q;
    release uut.u_regfile.regs[0].r.bit[6].u_dff.q;
    release uut.u_regfile.regs[0].r.bit[7].u_dff.q;

    release uut.u_regfile.regs[1].r.bit[0].u_dff.q;
    release uut.u_regfile.regs[1].r.bit[1].u_dff.q;
    release uut.u_regfile.regs[1].r.bit[2].u_dff.q;
    release uut.u_regfile.regs[1].r.bit[3].u_dff.q;
    release uut.u_regfile.regs[1].r.bit[4].u_dff.q;
    release uut.u_regfile.regs[1].r.bit[5].u_dff.q;
    release uut.u_regfile.regs[1].r.bit[6].u_dff.q;
    release uut.u_regfile.regs[1].r.bit[7].u_dff.q;

    release uut.u_regfile.regs[2].r.bit[0].u_dff.q;
    release uut.u_regfile.regs[2].r.bit[1].u_dff.q;
    release uut.u_regfile.regs[2].r.bit[2].u_dff.q;
    release uut.u_regfile.regs[2].r.bit[3].u_dff.q;
    release uut.u_regfile.regs[2].r.bit[4].u_dff.q;
    release uut.u_regfile.regs[2].r.bit[5].u_dff.q;
    release uut.u_regfile.regs[2].r.bit[6].u_dff.q;
    release uut.u_regfile.regs[2].r.bit[7].u_dff.q;

    release uut.u_regfile.regs[3].r.bit[0].u_dff.q;
    release uut.u_regfile.regs[3].r.bit[1].u_dff.q;
    release uut.u_regfile.regs[3].r.bit[2].u_dff.q;
    release uut.u_regfile.regs[3].r.bit[3].u_dff.q;
    release uut.u_regfile.regs[3].r.bit[4].u_dff.q;
    release uut.u_regfile.regs[3].r.bit[5].u_dff.q;
    release uut.u_regfile.regs[3].r.bit[6].u_dff.q;
    release uut.u_regfile.regs[3].r.bit[7].u_dff.q;

    #400;

    $finish;
end

endmodule