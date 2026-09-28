`timescale 1ns/1ps

module alu_tb;

reg  [7:0] a;
reg  [7:0] b;
reg  [2:0] opcode;
wire [7:0] result;
wire zero;
wire carry;
wire overflow;
wire negative;

alu uut (
    .a        (a),
    .b        (b),
    .opcode   (opcode),
    .result   (result),
    .zero     (zero),
    .carry    (carry),
    .overflow (overflow),
    .negative (negative)
);

localparam ADD = 3'b000;
localparam SUB = 3'b001;
localparam AND_OP = 3'b010;
localparam OR_OP  = 3'b011;
localparam XOR_OP = 3'b100;
localparam NOT_OP = 3'b101;
localparam SHL = 3'b110;
localparam SHR = 3'b111;

initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);

    // Plain ADD, no flags expected: 10 + 20 = 30
    a = 8'd10; b = 8'd20; opcode = ADD;
    #10;

    // ADD that triggers CARRY: 200 + 100 = 300, doesn't fit in 8 bits
    a = 8'd200; b = 8'd100; opcode = ADD;
    #10;

    // ADD that triggers OVERFLOW: 100 + 50, both "positive" signed, wraps negative
    a = 8'd100; b = 8'd50; opcode = ADD;
    #10;

    // SUB that triggers ZERO: 7 - 7 = 0
    a = 8'd7; b = 8'd7; opcode = SUB;
    #10;

    // SUB that triggers NEGATIVE: 5 - 10 (result's top bit becomes 1)
    a = 8'd5; b = 8'd10; opcode = SUB;
    #10;

    // AND
    a = 8'b11001100; b = 8'b10101010; opcode = AND_OP;
    #10;

    // OR
    a = 8'b11001100; b = 8'b10101010; opcode = OR_OP;
    #10;

    // XOR
    a = 8'b11001100; b = 8'b10101010; opcode = XOR_OP;
    #10;

    // NOT (only uses a)
    a = 8'b00001111; b = 8'b00000000; opcode = NOT_OP;
    #10;

    // Shift left
    a = 8'b00000001; b = 8'b00000000; opcode = SHL;
    #10;

    // Shift right
    a = 8'b10000000; b = 8'b00000000; opcode = SHR;
    #10;

    #20 $finish;
end

endmodule