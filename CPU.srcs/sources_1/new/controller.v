module controller (
    input clk,
    input rst,
    input [2:0] opcode,
    input is_zero,
    output reg sel,
    output reg rd,
    output reg ld_ir,
    output reg halt,
    output reg inc_pc,
    output reg ld_ac,
    output reg ld_pc,
    output reg wr,
    output reg data_e
);

    parameter INST_ADDR  = 8'b00000001;
    parameter INST_FETCH = 8'b00000010;
    parameter INST_LOAD  = 8'b00000100;
    parameter IDLE       = 8'b00001000;
    parameter OP_ADDR    = 8'b00010000;
    parameter OP_FETCH   = 8'b00100000;
    parameter ALU_OP     = 8'b01000000;
    parameter STORE      = 8'b10000000;

    reg [7:0] current_state, next_state;

    parameter HLT = 3'b000;
    parameter SKZ = 3'b001;
    parameter ADD = 3'b010;
    parameter AND = 3'b011;
    parameter XOR = 3'b100;
    parameter LDA = 3'b101;
    parameter STO = 3'b110;
    parameter JMP = 3'b111;

    wire is_alu_op = (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA);


    always @(posedge clk) begin
        if (rst)
            current_state <= INST_ADDR;
        else if (halt)
            current_state <= current_state;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            INST_ADDR:  next_state = INST_FETCH;
            INST_FETCH: next_state = INST_LOAD;
            INST_LOAD:  next_state = IDLE;
            IDLE:       next_state = OP_ADDR;
            OP_ADDR:    next_state = OP_FETCH;
            OP_FETCH:   next_state = ALU_OP;
            ALU_OP:     next_state = STORE;
            STORE:      next_state = INST_ADDR;
            default:    next_state = INST_ADDR;
        endcase
    end

    always @(*) begin   
        {sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e} = 9'b0;

        case (current_state)
            INST_ADDR: begin
                sel = 1;
            end
            INST_FETCH: begin
                sel = 1;
                rd = 1;
            end
            INST_LOAD: begin
                sel = 1;
                rd = 1;
                ld_ir = 1;
            end
            IDLE: begin
                sel = 1;
                rd = 1;
                ld_ir = 1;
            end
            OP_ADDR: begin
                sel = 0;
                halt = (opcode == HLT);
                if (opcode == HLT)
                    inc_pc = 0;
                else
                    inc_pc = 1;
            end
            OP_FETCH: begin
                sel = 0;
                rd = is_alu_op;
            end
            ALU_OP: begin
                sel = 0;
                rd = is_alu_op;
                inc_pc = (opcode == SKZ && is_zero);
                ld_pc = (opcode == JMP);
                data_e = (opcode == STO);
            end
            STORE: begin
                sel = 0;
                rd = is_alu_op;
                ld_ac = is_alu_op;
                ld_pc = (opcode == JMP);
                wr = (opcode == STO);
                data_e = (opcode == STO);
            end
        endcase
    end

endmodule