module cpu_top (
    input wire clk,
    input wire reset
);

// ---- Wires connecting everything together ----
// Notice: this module doesn't COMPUTE anything itself. Every wire below
// just carries a signal from one module's output straight into another
// module's input, exactly matching the port names we designed in the
// control unit.

wire [7:0] pc_count;
wire [7:0] instr_word;

wire [1:0] raddr1, raddr2, reg_waddr;
wire [7:0] rdata1, rdata2, reg_wdata;
wire       reg_we;

wire [2:0] alu_opcode;
wire [7:0] alu_result;
wire       alu_zero, alu_carry, alu_overflow, alu_negative;

wire       dmem_we;
wire [7:0] dmem_addr, dmem_wdata, dmem_rdata;

wire       pc_en, pc_load;
wire [7:0] pc_load_val;

wire halted;

// ---- Program Counter ----
pc u_pc (
    .clk      (clk),
    .reset    (reset),
    .en       (pc_en),
    .load     (pc_load),
    .load_val (pc_load_val),
    .count    (pc_count)
);

// ---- Instruction Memory ----
// Always addressed directly by the PC's current value -- this connection
// alone is what makes "fetch" mean anything at all.
instr_mem u_imem (
    .addr  (pc_count),
    .instr (instr_word)
);

// ---- Register File ----
register_file u_regfile (
    .clk    (clk),
    .reset  (reset),
    .we     (reg_we),
    .waddr  (reg_waddr),
    .wdata  (reg_wdata),
    .raddr1 (raddr1),
    .raddr2 (raddr2),
    .rdata1 (rdata1),
    .rdata2 (rdata2)
);

// ---- ALU ----
// Always fed whatever the register file is currently outputting -- the
// control unit decides, via reg_we/dmem_we/pc_en, whether this cycle's
// ALU result actually MATTERS, but the ALU itself just computes,
// unconditionally, every cycle, same as it always has.
alu u_alu (
    .a        (rdata1),
    .b        (rdata2),
    .opcode   (alu_opcode),
    .result   (alu_result),
    .zero     (alu_zero),
    .carry    (alu_carry),
    .overflow (alu_overflow),
    .negative (alu_negative)
);

// ---- Data Memory ----
data_mem u_dmem (
    .clk   (clk),
    .we    (dmem_we),
    .addr  (dmem_addr),
    .wdata (dmem_wdata),
    .rdata (dmem_rdata)
);

// ---- Control Unit ----
// The brain: takes live values from everything above, and decides what
// every OTHER module should do this cycle.
control_unit u_ctrl (
    .clk          (clk),
    .reset        (reset),
    .instr_in     (instr_word),
    .rdata1       (rdata1),
    .rdata2       (rdata2),
    .alu_result   (alu_result),
    .alu_zero     (alu_zero),
    .alu_carry    (alu_carry),
    .alu_overflow (alu_overflow),
    .alu_negative (alu_negative),
    .dmem_rdata   (dmem_rdata),
    .raddr1       (raddr1),
    .raddr2       (raddr2),
    .alu_opcode   (alu_opcode),
    .reg_we       (reg_we),
    .reg_waddr    (reg_waddr),
    .reg_wdata    (reg_wdata),
    .dmem_we      (dmem_we),
    .dmem_addr    (dmem_addr),
    .dmem_wdata   (dmem_wdata),
    .pc_en        (pc_en),
    .pc_load      (pc_load),
    .pc_load_val  (pc_load_val),
    .halted       (halted)
);

endmodule