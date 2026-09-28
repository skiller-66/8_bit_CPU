module register #(
    parameter WIDTH = 8
) (
    input  wire clk,
    input  wire reset,
    input  wire en,
    input  wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] q
);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : bit
        dff u_dff (
            .clk   (clk),
            .reset (reset),
            .d     (en ? d[i] : q[i]),
            .q     (q[i])
        );
    end
endgenerate

endmodule