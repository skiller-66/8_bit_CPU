`timescale 1ns/1ps

module instr_mem_tb;

reg  [7:0] addr;
wire [7:0] instr;

instr_mem uut (
    .addr  (addr),
    .instr (instr)
);

initial begin
    $dumpfile("instr_mem_tb.vcd");
    $dumpvars(0, instr_mem_tb);

    // Step through each address one at a time and check what comes out.
    // No clock needed at all -- this module is pure combinational reading,
    // same as the register file's read ports.

    addr = 8'd0;
    #10;  // expect instr = 8'h01  (ADD R0, R1)

    addr = 8'd1;
    #10;  // expect instr = 8'h12  (SUB R0, R2)

    addr = 8'd2;
    #10;  // expect instr = 8'h93  (STORE R0 -> [R3])

    addr = 8'd3;
    #10;  // expect instr = 8'hC0  (HALT)

    // Check an address we never programmed -- should default to 0,
    // proving unused ROM space doesn't contain leftover garbage.
    addr = 8'd10;
    #10;  // expect instr = 8'h00

    #20 $finish;
end

endmodule