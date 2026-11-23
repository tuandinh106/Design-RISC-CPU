`timescale 1ns / 1ps

module AddressMux #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] pc_addr,
    input [WIDTH-1:0] ir_addr,
    input sel,
    output [WIDTH-1:0] add_out
);

    assign add_out = sel ? pc_addr : ir_addr;
endmodule
