module control_unit (
    input  wire       clk,
    input  wire       reset,

    input  wire [7:0] instr_in,     // raw byte from instr_mem (addressed by PC externally)

    input  wire [7:0] rdata1,       // register file's read port 1 output (address = rd)
    input  wire [7:0] rdata2,       // register file's read port 2 output (address = rs)

    input  wire [7:0] alu_result,   // ALU's live combinational result
    input  wire       alu_zero,
    input  wire       alu_carry,
    input  wire       alu_overflow,
    input  wire       alu_negative,

    input  wire [7:0] dmem_rdata,   // data memory's live read output

    output wire [1:0] raddr1,       // -> register file read address 1
    output wire [1:0] raddr2,       // -> register file read address 2
    output wire [2:0] alu_opcode,   // -> ALU's opcode input

    output wire        reg_we,      // -> register file write enable
    output wire [1:0]  reg_waddr,   // -> register file write address
    output wire [7:0]  reg_wdata,   // -> register file write data

    output wire        dmem_we,     // -> data memory write enable
    output wire [7:0]  dmem_addr,   // -> data memory address
    output wire [7:0]  dmem_wdata,  // -> data memory write data

    output wire        pc_en,       // -> PC enable (0 = hold, matches Phase 6 upgrade)
    output wire        pc_load,     // -> PC jump control
    output wire [7:0]  pc_load_val, // -> PC jump target

    output wire        halted       // status flag: 1 once HALT has been reached
);

// ---- The 3(+1) states from the diagram ----
localparam S_FETCH   = 2'b00;
localparam S_DECODE  = 2'b01;
localparam S_EXECUTE = 2'b10;
localparam S_HALT    = 2'b11;

reg [1:0] state;

// ---- Instruction Register: reused directly from Phase 2's generic register ----
// Loads a new instruction ONLY during the FETCH state -- otherwise holds
// (feeds itself back), exactly like every enable you've seen before.
wire [7:0] ir_out;
wire ir_load = (state == S_FETCH);
register #(.WIDTH(8)) ir_reg (
    .clk   (clk),
    .reset (reset),
    .en    (ir_load),
    .d     (instr_in),
    .q     (ir_out)
);

// ---- Splitting the instruction into fields, straight from the ISA spec ----
wire       class_bit = ir_out[7];
wire [2:0] opcode    = ir_out[6:4];
wire [1:0] rd        = ir_out[3:2];
wire [1:0] rs        = ir_out[1:0];

// ---- Naming each instruction type, per the ISA table ----
wire is_alu   = (class_bit == 1'b0);
wire is_load  = (class_bit == 1'b1) && (opcode == 3'b000);
wire is_store = (class_bit == 1'b1) && (opcode == 3'b001);
wire is_jmp   = (class_bit == 1'b1) && (opcode == 3'b010);
wire is_jz    = (class_bit == 1'b1) && (opcode == 3'b011);
wire is_halt  = (class_bit == 1'b1) && (opcode == 3'b100);

// ---- Flags Register: reused generic register again, width 4 this time ----
// Captures the ALU's flags ONLY at the moment an ALU instruction executes,
// so a LATER instruction (like JZ) can still check "was the last ALU
// result zero?" even though the ALU itself has no memory of its own.
wire flags_load = (state == S_EXECUTE) && is_alu;
wire [3:0] flags_out;
register #(.WIDTH(4)) flags_reg (
    .clk   (clk),
    .reset (reset),
    .en    (flags_load),
    .d     ({alu_zero, alu_carry, alu_overflow, alu_negative}),
    .q     (flags_out)
);
wire stored_zero = flags_out[3];   // bit 3, matching the concatenation order above

// ---- Register file read addresses: always driven straight from the IR ----
// (Harmless to drive these even outside EXECUTE -- the register file's
// reads are purely combinational, so this just means rdata1/rdata2 are
// "ready and waiting" by the time EXECUTE actually needs them.)
assign raddr1 = rd;
assign raddr2 = rs;

// ---- ALU opcode: direct passthrough from the instruction's own opcode field ----
// (This only matters when is_alu is true and we're in EXECUTE -- otherwise
// the ALU is just quietly computing something nobody uses.)
assign alu_opcode = opcode;

// ---- Register file write-back ----
// Only ALU results and LOADs ever write into a register, and only during EXECUTE.
assign reg_we    = (state == S_EXECUTE) && (is_alu || is_load);
assign reg_waddr = rd;
assign reg_wdata = is_load ? dmem_rdata : alu_result;

// ---- Data memory control ----
// Per the ISA: 'rs' always holds the address pointer for both LOAD and STORE.
assign dmem_we    = (state == S_EXECUTE) && is_store;
assign dmem_addr  = rdata2;   // reg[rs] = the memory address
assign dmem_wdata = rdata1;   // reg[rd] = the value to store (only used by STORE)

// ---- PC control ----
wire jump_taken = is_jmp || (is_jz && stored_zero);
assign pc_en       = (state == S_EXECUTE) && !is_halt;  // move only at end of EXECUTE
assign pc_load     = jump_taken;
assign pc_load_val = rdata1;  // reg[rd] = the jump target, per the ISA

assign halted = (state == S_HALT);

// ---- The state transition itself: this IS the diagram, as code ----
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= S_FETCH;
    else begin
        case (state)
            S_FETCH:   state <= S_DECODE;
            S_DECODE:  state <= S_EXECUTE;
            S_EXECUTE: state <= is_halt ? S_HALT : S_FETCH;
            S_HALT:    state <= S_HALT;   // stays here forever, no exit
            default:   state <= S_FETCH;
        endcase
    end
end

endmodule