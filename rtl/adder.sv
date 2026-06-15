//------------------------------------------------------------------------------
// 4-bit Adder Module
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Nelson Alves
// Date  : October 2023
//------------------------------------------------------------------------------

module adder #(
    parameter DATA_WIDTH = 4
)(
    input  logic                  clk,   // Clock input
    input  logic                  reset, // Active-high reset input
    input  logic [DATA_WIDTH-1:0] x,     // Input x
    input  logic [DATA_WIDTH-1:0] y,     // Input y
    input  logic                  cin,   // Carry-in input
    output logic [DATA_WIDTH-1:0] sum,   // Registered sum output
    output logic                  cout   // Registered carry-out output
);
    // Internal carry wires
    logic [DATA_WIDTH:0] carry;

    // Internal combinational sum and cout wires
    logic [DATA_WIDTH-1:0] sum_comb;
    logic                  cout_comb;

    // Assign carry-in to the first carry bit
    assign carry[0] = cin;

    // Generate block to instantiate full adders
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i++) begin : adder_gen
            full_adder fa(
                .x(x[i]),
                .y(y[i]),
                .cin(carry[i]),
                .s(sum_comb[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    // Assign the final carry-out combinational signal
    assign cout_comb = carry[DATA_WIDTH];

    // Registered output logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sum  <= '0;
            cout <= 1'b0;
        end else begin
            sum  <= sum_comb;
            cout <= cout_comb;
        end
    end
endmodule


