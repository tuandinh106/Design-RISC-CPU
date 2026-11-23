module alu (
    input [31:0] data,
    input [31:0] accum,
    input [2:0] opcode,
    output reg [31:0] alu_out,
    output is_zero
);
    parameter   HLT = 3'b000, SKZ = 3'b001,
                ADD = 3'b010, AND = 3'b011,
                XOR = 3'b100, LDA = 3'b101,
                STO = 3'b110, JMP = 3'b111;

    assign is_zero = (accum == 32'b0);
    always @(*) begin
        case (opcode)
            ADD:    alu_out = accum + data;
            AND:    alu_out = accum & data;
            XOR:    alu_out = accum ^ data;
            LDA:    alu_out = data; 
            default: alu_out = accum;   // HLT, SKZ, STO, JMP  Accumulator ko doi
        endcase
    end
endmodule