module instr_mem (
    input  wire [7:0] addr,
    output wire [7:0] instr
);

reg [7:0] mem [0:255];
integer i;   // <-- moved here, outside the initial block

initial begin
    for (i = 0; i < 256; i = i + 1)
        mem[i] = 8'h00;

    mem[0] = 8'h93;  // STORE R0 -> [R3]
    mem[1] = 8'h87;  // LOAD  R1 <- [R3]
    mem[2] = 8'hC0;  // HALT
end

assign instr = mem[addr];

endmodule