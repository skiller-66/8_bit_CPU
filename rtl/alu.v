module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] opcode,
    output reg  [7:0] result,
    output wire zero,
    output reg  carry,
    output reg  overflow,
    output wire negative
);

localparam ADD = 3'b000;
localparam SUB = 3'b001;
localparam AND_OP = 3'b010;
localparam OR_OP  = 3'b011;
localparam XOR_OP = 3'b100;
localparam NOT_OP = 3'b101;
localparam SHL = 3'b110;
localparam SHR = 3'b111;

wire [8:0] add_ext = {1'b0, a} + {1'b0, b};
wire [8:0] sub_ext = {1'b0, a} - {1'b0, b};

always @(*) begin
    carry    = 0;
    overflow = 0;

    case (opcode)
        ADD: begin
            result   = add_ext[7:0];
            carry    = add_ext[8];
            overflow = (a[7] == b[7]) && (result[7] != a[7]);
        end
        SUB: begin
            result   = sub_ext[7:0];
            carry    = sub_ext[8];
            overflow = (a[7] != b[7]) && (result[7] != a[7]);
        end
        AND_OP: result = a & b;
        OR_OP:  result = a | b;
        XOR_OP: result = a ^ b;
        NOT_OP: result = ~a;
        SHL:    result = a << 1;
        SHR:    result = a >> 1;
        default: result = 8'b0;
    endcase
end

assign zero     = (result == 8'b0);
assign negative = result[7];

endmodule