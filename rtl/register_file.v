module register_file (
    input  wire       clk,
    input  wire       reset,
    input  wire       we,
    input  wire [1:0] waddr,
    input  wire [7:0] wdata,
    input  wire [1:0] raddr1,
    input  wire [1:0] raddr2,
    output wire [7:0] rdata1,
    output wire [7:0] rdata2
);

wire [7:0] reg_out [0:3];
wire [3:0] en;

genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin : regs
        assign en[i] = we && (waddr == i);

        register #(.WIDTH(8)) r (
            .clk   (clk),
            .reset (reset),
            .en    (en[i]),
            .d     (wdata),
            .q     (reg_out[i])
        );
    end
endgenerate

assign rdata1 = reg_out[raddr1];
assign rdata2 = reg_out[raddr2];

endmodule