module instruction_reg (
    input [31:0] data_in,    
    input clk, rst, ld_ir,
    output reg [2:0] opcode,
    output reg [31:0] operand
);
    always @(posedge clk) begin
        if (rst) begin
            opcode <= 3'b0; operand <= 32'b0;
        end else if (ld_ir) begin
            opcode <= data_in[31:29]; 
            operand <= {27'b0, data_in[4:0]}; 
        end
    end
endmodule
