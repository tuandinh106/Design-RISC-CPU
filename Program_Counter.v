`timescale 1ns / 1ps

module Program_Counter (
    input clk,
    input rst,
    input ld_pc,
    input inc_pc,
    input [31:0] load_val,
    output reg [31:0] pc
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
        end 
        else if (ld_pc) begin
            pc <= load_val;
        end 
        else if (inc_pc) begin
            pc <= pc + 1'b1;
        end
    end

endmodule
