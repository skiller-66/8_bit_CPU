`timescale 1ns/1ps

// Self-checking testbench for cpu_top -- Phase 0 close-out of v1.
// Program in instr_mem:
//   mem[0] = 0x93  STORE R0 -> [R3]
//   mem[1] = 0x87  LOAD  R1 <- [R3]
//   mem[2] = 0xC0  HALT
// Assumes registers reset to 0 and data_mem starts zeroed (both true in v1 RTL).
module cpu_top_tb;

    localparam integer MAX_CYCLES = 2000;

    // ---- Expectations ----
    localparam integer N_REG_EXP    = 1;      // register-file writes
    localparam integer N_MEM_EXP    = 1;      // data-memory writes
    localparam integer N_INSTR_EXP  = 2;      // instructions retired before HALT
    localparam [7:0]   EXP_FINAL_PC = 8'h02;  // PC parks on HALT

    reg [1:0] exp_waddr [0:7];
    reg [7:0] exp_wdata [0:7];
    reg [7:0] exp_maddr [0:7];
    reg [7:0] exp_mdata [0:7];
    reg [7:0] exp_ipc   [0:7];
    reg [7:0] exp_iword [0:7];

    initial begin
        exp_waddr[0] = 2'd1;  exp_wdata[0] = 8'h00;                 // LOAD  R1 <- [R3]
        exp_maddr[0] = 8'h00; exp_mdata[0] = 8'h00;                 // STORE R0 -> [R3]
        exp_ipc[0]   = 8'h00; exp_iword[0] = 8'h93;                 // retire #0: STORE
        exp_ipc[1]   = 8'h01; exp_iword[1] = 8'h87;                 // retire #1: LOAD
    end

    // ---- DUT ----
    reg clk   = 1'b0;
    reg reset = 1'b1;                         // active-high

    wire       halted_out;
    wire [7:0] pc_out, instr_word_out, alu_result_out;
    wire       alu_zero_out, alu_carry_out, alu_overflow_out, alu_negative_out;
    wire [1:0] reg_waddr_out;
    wire [7:0] reg_wdata_out;
    wire       reg_we_out;
    wire [7:0] dmem_addr_out, dmem_wdata_out, dmem_rdata_out;
    wire       dmem_we_out, pc_en_out, pc_load_out;

    cpu_top dut (
        .clk(clk), .reset(reset),
        .halted_out(halted_out), .pc_out(pc_out), .instr_word_out(instr_word_out),
        .alu_result_out(alu_result_out), .alu_zero_out(alu_zero_out),
        .alu_carry_out(alu_carry_out), .alu_overflow_out(alu_overflow_out),
        .alu_negative_out(alu_negative_out),
        .reg_waddr_out(reg_waddr_out), .reg_wdata_out(reg_wdata_out), .reg_we_out(reg_we_out),
        .dmem_addr_out(dmem_addr_out), .dmem_wdata_out(dmem_wdata_out),
        .dmem_rdata_out(dmem_rdata_out), .dmem_we_out(dmem_we_out),
        .pc_en_out(pc_en_out), .pc_load_out(pc_load_out)
    );

    always #5 clk = ~clk;                     // 100 MHz

    integer reg_idx = 0, mem_idx = 0, ins_idx = 0, errors = 0, cycles = 0;
    reg     was_halted = 1'b0;
    reg [7:0] pc_at_halt;

    // Sampled at posedge: sees the values being used on this edge.
    always @(posedge clk) begin
        if (!reset) begin
            // register-file writes
            if (reg_we_out) begin
                $display("[%0t] REG  write r%0d <= 0x%02h (pc=0x%02h)",
                         $time, reg_waddr_out, reg_wdata_out, pc_out);
                if (reg_idx < N_REG_EXP &&
                    (reg_waddr_out !== exp_waddr[reg_idx] || reg_wdata_out !== exp_wdata[reg_idx])) begin
                    errors = errors + 1;
                    $display("   MISMATCH reg write #%0d: expected r%0d <= 0x%02h",
                             reg_idx, exp_waddr[reg_idx], exp_wdata[reg_idx]);
                end
                reg_idx = reg_idx + 1;
            end
            // data-memory writes
            if (dmem_we_out) begin
                $display("[%0t] DMEM write [0x%02h] <= 0x%02h", $time, dmem_addr_out, dmem_wdata_out);
                if (mem_idx < N_MEM_EXP &&
                    (dmem_addr_out !== exp_maddr[mem_idx] || dmem_wdata_out !== exp_mdata[mem_idx])) begin
                    errors = errors + 1;
                    $display("   MISMATCH mem write #%0d: expected [0x%02h] <= 0x%02h",
                             mem_idx, exp_maddr[mem_idx], exp_mdata[mem_idx]);
                end
                mem_idx = mem_idx + 1;
            end
            // instruction retire (pc_en is high at the end of EXECUTE, non-HALT)
            if (pc_en_out) begin
                $display("[%0t] RETIRE pc=0x%02h instr=0x%02h", $time, pc_out, instr_word_out);
                if (ins_idx < N_INSTR_EXP &&
                    (pc_out !== exp_ipc[ins_idx] || instr_word_out !== exp_iword[ins_idx])) begin
                    errors = errors + 1;
                    $display("   MISMATCH retire #%0d: expected pc=0x%02h instr=0x%02h",
                             ins_idx, exp_ipc[ins_idx], exp_iword[ins_idx]);
                end
                ins_idx = ins_idx + 1;
            end
            // HALT must be sticky and PC must stay parked
            if (halted_out === 1'b1) begin
                if (!was_halted) begin was_halted = 1'b1; pc_at_halt = pc_out; end
                else if (pc_out !== pc_at_halt) begin
                    errors = errors + 1;
                    $display("   MISMATCH: PC moved after HALT");
                end
            end else if (was_halted) begin
                errors = errors + 1;
                $display("   MISMATCH: halted dropped back to 0");
            end
        end
    end

    initial begin
        repeat (4) @(posedge clk);
        #1 reset = 1'b0;

        while (halted_out !== 1'b1 && cycles < MAX_CYCLES) begin
            @(posedge clk);
            cycles = cycles + 1;
        end
        repeat (4) @(posedge clk);            // let the sticky-halt checks run

        $display("----------------------------------------");
        $display("cycles=%0d reg writes=%0d mem writes=%0d retired=%0d final pc=0x%02h",
                 cycles, reg_idx, mem_idx, ins_idx, pc_out);

        if (halted_out !== 1'b1)
            $display("FAIL: timeout, CPU never halted");
        else if (errors != 0 || reg_idx != N_REG_EXP || mem_idx != N_MEM_EXP || ins_idx != N_INSTR_EXP)
            $display("FAIL: %0d mismatches (reg %0d/%0d, mem %0d/%0d, retired %0d/%0d)",
                     errors, reg_idx, N_REG_EXP, mem_idx, N_MEM_EXP, ins_idx, N_INSTR_EXP);
        else if (pc_out !== EXP_FINAL_PC)
            $display("FAIL: final pc 0x%02h, expected 0x%02h", pc_out, EXP_FINAL_PC);
        else
            $display("PASS");
        $finish;
    end

endmodule