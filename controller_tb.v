`timescale 1ns / 1ps

module controller_tb ();
    reg clk;
    reg rst;
    reg [2:0] opcode;
    reg is_zero;
    wire sel;
    wire rd;
    wire ld_ir; 
    wire halt;
    wire inc_pc;
    wire ld_ac;
    wire ld_pc;
    wire wr;
    wire data_e;

    controller uut (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .is_zero(is_zero),
        .sel(sel),
        .rd(rd),
        .ld_ir(ld_ir),
        .halt(halt),
        .inc_pc(inc_pc),
        .ld_ac(ld_ac),
        .ld_pc(ld_pc),
        .wr(wr),
        .data_e(data_e)
    );

    always #5 clk = ~clk; // Tao xung clock

    initial begin
        // Khoi tao tin hieu
        clk = 0;
        rst = 1;
        opcode = 3'b000; // NOP
        is_zero = 0;

        #10 rst = 0;

        $display("--- Bat dau kiem tra Controller ---");

        // --- Case 1: Kiem tra lenh ADD (Opcode 010) ---
        opcode = 3'b010;        
        repeat (8) @(posedge clk); 
        
        // --- Case 2: Kiem tra lenh AND (Opcode 011) ---
        opcode = 3'b011;
        repeat (8) @(posedge clk); 

        // --- Case 3: Kiem tra lenh HLT (Opcode 000) --- 
        opcode = 3'b000;
        repeat (8) @(posedge clk);

        // --- Case 4: Kiem tra lenh SKZ voi Zero = 1 (Opcode 001) --- 
        opcode = 3'b001; is_zero = 1;        
        repeat (8) @(posedge clk);

        // --- Case 5: Kiem tra lenh SKZ voi Zero = 0 (Opcode 001) ---
        opcode = 3'b001; is_zero = 0;        
        repeat (8) @(posedge clk);

        // --- Case 6: Kiem tra lenh JMP (Opcode 111) ---
        opcode = 3'b111;        
        repeat (8) @(posedge clk);

        // --- Case 7: Kiem tra lenh STO (Opcode 110) ---
        opcode = 3'b110;        
        repeat (8) @(posedge clk);
        $finish;
    end

    initial begin
        $monitor("Time=%0t | State Loop | Op=%b | Halt=%b | Inc_PC=%b | Ld_AC=%b", 
                 $time, opcode, halt, inc_pc, ld_ac);
    end

endmodule
