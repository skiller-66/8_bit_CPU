module pc (
    input  wire       clk,
    input  wire       reset,
    input  wire       en,        // NEW: 1 = allowed to change this cycle, 0 = hold still
    input  wire       load,      // 1 = jump: load a new address (only matters if en=1)
    input  wire [7:0] load_val,  // the jump target, when load=1
    output reg  [7:0] count      // current instruction address
);

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 8'b0;
    else if (!en)
        count <= count;         // HOLD: feed itself back, exact same trick as Phase 2's register
    else if (load)
        count <= load_val;      // JMP/JZ: jump to this address
    else
        count <= count + 1;     // normal case: move to next instruction
end

endmodule