`timescale 1ns/1ps

// Self-checking testbench for cpu_top (v1 close-out).
// - Runs the program already loaded in instr_mem until the CPU halts.
// - Logs every register-file and data-memory write.
// - Compares register writes, in order, against the expected list below.
//   Fill in exp_waddr/exp_wdata and N_EXP from your test program.
module cpu_top_tb;

    localparam integer MAX_CYCLES = 2000;   // timeout guard
    localparam integer N_EXP      = 0;      // number of expected register writes (fill in)

    reg clk   = 1'b0;
    reg reset = 1'b1;                       // assumes active-high reset

    wire       halted_out;
    wire [7:0] pc_out;
    wire [7:0] instr_word_out;
    wire [7:0] alu_result_out;
    wire       alu_zero_out, alu_carry_out, alu_overflow_out, alu_negative_out;
    wire [1:0] reg_waddr_out;
    wire [7:0] reg_wdata_out;
    wire       reg_we_out;
    wire [7:0] dmem_addr_out, dmem_wdata_out, dmem_rdata_out;
    wire       dmem_we_out;
    wire       pc_en_out, pc_load_out;

    cpu_top dut (
        .clk              (clk),
        .reset            (reset),
        .halted_out       (halted_out),
        .pc_out           (pc_out),
        .instr_word_out   (instr_word_out),
        .alu_result_out   (alu_result_out),
        .alu_zero_out     (alu_zero_out),
        .alu_carry_out    (alu_carry_out),
        .alu_overflow_out (alu_overflow_out),
        .alu_negative_out (alu_negative_out),
        .reg_waddr_out    (reg_waddr_out),
        .reg_wdata_out    (reg_wdata_out),
        .reg_we_out       (reg_we_out),
        .dmem_addr_out    (dmem_addr_out),
        .dmem_wdata_out   (dmem_wdata_out),
        .dmem_rdata_out   (dmem_rdata_out),
        .dmem_we_out      (dmem_we_out),
        .pc_en_out        (pc_en_out),
        .pc_load_out      (pc_load_out)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // ---- Expected register writes (in order) ----
    reg [1:0] exp_waddr [0:63];
    reg [7:0] exp_wdata [0:63];

    initial begin
        // Example (replace with your program's real results):
        // exp_waddr[0] = 2'd0; exp_wdata[0] = 8'h05;
        // exp_waddr[1] = 2'd1; exp_wdata[1] = 8'h03;
    end

    integer wr_idx  = 0;
    integer errors  = 0;
    integer cycles  = 0;

    // Sampled at posedge: sees the values being written on this edge.
    always @(posedge clk) begin
        if (!reset && reg_we_out) begin
            $display("[%0t] REG  write r%0d <= 0x%02h  (pc=0x%02h)",
                     $time, reg_waddr_out, reg_wdata_out, pc_out);
            if (wr_idx < N_EXP) begin
                if (reg_waddr_out !== exp_waddr[wr_idx] ||
                    reg_wdata_out !== exp_wdata[wr_idx]) begin
                    errors = errors + 1;
                    $display("   MISMATCH #%0d: expected r%0d <= 0x%02h",
                             wr_idx, exp_waddr[wr_idx], exp_wdata[wr_idx]);
                end
            end
            wr_idx = wr_idx + 1;
        end
        if (!reset && dmem_we_out)
            $display("[%0t] DMEM write [0x%02h] <= 0x%02h", $time, dmem_addr_out, dmem_wdata_out);
    end

    initial begin
        repeat (4) @(posedge clk);
        #1 reset = 1'b0;

        while (halted_out !== 1'b1 && cycles < MAX_CYCLES) begin
            @(posedge clk);
            cycles = cycles + 1;
        end
        repeat (2) @(posedge clk);

        $display("----------------------------------------");
        $display("cycles=%0d  reg writes seen=%0d  final pc=0x%02h", cycles, wr_idx, pc_out);

        if (halted_out !== 1'b1) begin
            $display("FAIL: timeout, CPU never halted");
        end else if (errors != 0 || wr_idx < N_EXP) begin
            $display("FAIL: %0d mismatches, %0d of %0d expected writes seen", errors, wr_idx, N_EXP);
        end else if (N_EXP == 0) begin
            $display("DONE: CPU halted, but no expected values set (nothing was checked)");
        end else begin
            $display("PASS");
        end
        $finish;
    end

endmodule
