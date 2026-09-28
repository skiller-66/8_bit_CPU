module data_mem (
    input  wire       clk,
    input  wire       we,      // write enable: 1 = store a value this cycle
    input  wire [7:0] addr,    // which memory location to read AND/OR write
    input  wire [7:0] wdata,   // value to write in, when we=1
    output wire [7:0] rdata    // value currently stored at addr (always visible)
);

// Same idea as instr_mem's array -- 256 separate 8-bit storage slots.
// The difference: this one can be WRITTEN to as well as read, which is
// exactly what STORE and LOAD instructions need (instr_mem never gets
// written to at all, since it holds the fixed program, not changing data).
reg [7:0] mem [0:255];

integer i;
initial begin
    // Start all of data memory at a clean, defined 0 -- same reasoning
    // as instr_mem's fix: avoids 'x' (unknown) values in unused locations.
    for (i = 0; i < 256; i = i + 1)
        mem[i] = 8'h00;
end

// WRITING needs a clock, because it's an action that should only happen
// on a specific, controlled instant (this is exactly why 'we' exists --
// same enable-signal idea as your very first register in Phase 2).
always @(posedge clk) begin
    if (we)
        mem[addr] <= wdata;
end

// READING needs no clock at all -- same as instr_mem and the register
// file's read ports: instantly show whatever is currently stored at
// whatever address is being asked for, live, no delay.
assign rdata = mem[addr];

endmodule