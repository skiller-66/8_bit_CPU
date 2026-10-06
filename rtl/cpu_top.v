module cpu_top (
    input  wire       clk,
    input  wire       reset,

    // ---- Observable outputs: keep the datapath alive through synthesis ----
    output wire       halted_out,
    output wire [7:0] pc_out,
    output wire [7:0] instr_word_out,

    output wire [7:0] alu_result_out,
    output wire       alu_zero_out,
    output wire       alu_carry_out,
    output wire       alu_overflow_out,
    output wire       alu_negative_out,

    output wire [1:0] reg_waddr_out,
    output wire [7:0] reg_wdata_out,
    output wire       reg_we_out,

    output wire [7:0] dmem_addr_out,
    output wire [7:0] dmem_wdata_out,
    output wire [7:0] dmem_rdata_out,
    output wire       dmem_we_out,

    output wire       pc_en_out,
    output wire       pc_load_out
);

// ---- Wires connecting everything together ----
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

// ---- Drive the top-level outputs ----
assign halted_out       = halted;
assign pc_out           = pc_count;
assign instr_word_out   = instr_word;

assign alu_result_out   = alu_result;
assign alu_zero_out     = alu_zero;
assign alu_carry_out    = alu_carry;
assign alu_overflow_out = alu_overflow;
assign alu_negative_out = alu_negative;

assign reg_waddr_out    = reg_waddr;
assign reg_wdata_out    = reg_wdata;
assign reg_we_out       = reg_we;

assign dmem_addr_out    = dmem_addr;
assign dmem_wdata_out   = dmem_wdata;
assign dmem_rdata_out   = dmem_rdata;
assign dmem_we_out      = dmem_we;

assign pc_en_out        = pc_en;
assign pc_load_out      = pc_load;

endmodule