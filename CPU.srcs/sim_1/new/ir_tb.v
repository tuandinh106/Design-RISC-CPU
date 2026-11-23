`timescale 1ns / 1ps

module tb_instruction_reg;

    // 1. Khai bao cac tin hieu ket noi voi UUT
    reg [31:0] data_in;
    reg clk;
    reg rst;
    reg ld_ir;
    
    wire [2:0] opcode;
    wire [31:0] operand;

    // 2. Gọi Module Instruction Register (UUT)
    instruction_reg uut (
        .data_in(data_in),
        .clk(clk),
        .rst(rst),
        .ld_ir(ld_ir),
        .opcode(opcode),
        .operand(operand)
    );

    // 3. Tao xung nhip Clock (Chu ky 10ns - Tuan tu)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. Kich ban kiem thu toan dien
    initial begin
        // Monitor hien thi ket qua o console
        $monitor("Time = %0t | rst = %b | ld_ir = %b | data_in = %h | opcode = %b (bin) | operand = %h", 
                 $time, rst, ld_ir, data_in, opcode, operand);

        // Khoi tao gia tri ban dau
        rst = 0;
        ld_ir = 0;
        data_in = 32'h0000_0000;
        #13; // Lech pha voi sườn len clock de tranh hien tuong chay dua (race condition)

        // ====================================================================
        // TRƯỜNG HỢP 1: Kiem tra Reset dong bo (Synchronous Reset)
        // ====================================================================
        rst = 1;
        data_in = 32'hE000_001F; // Gia lap co du lieu tren bus
        #10; // Chờ 1 chu kỳ clock -> Kỳ vọng: opcode = 0, operand = 0
        rst = 0;
        #10;

        // ====================================================================
        // TRƯỜNG HỢP 2: Nap ma lenh hop le (Load Instruction)
        // ====================================================================
        // Gia lap lenh ADD (Opcode = 3'b001) voi dia chi o nho 5 (5'b00101)
        // Ma may 32-bit: 3'b001 + 24 bit trong + 5'b00101 = 32'h2000_0005
        data_in = 32'h2000_0005;
        ld_ir = 1; // Cho phep nap
        #10; // Ky vong sau sườn lên: opcode = 3'b001, operand = 32'h0000_0005
        
        // Gia lap lenh JMP (Opcode = 3'b101) voi dia chi o nho 21 (5'b10101)
        // Ma may 32-bit: 3'b101 + 24 bit trong + 5'b10101 = 32'hA000_0015
        data_in = 32'hA000_0015;
        #10; // Ky vong sau sườn lên: opcode = 3'b101, operand = 32'h0000_0015


        // ====================================================================
        // TRƯỜNG HỢP 3: Kiem tra trang thai Giu (Hold / ld_ir = 0)
        // ====================================================================
        ld_ir = 0; // Khoa chot thanh ghi IR
        data_in = 32'hFFFF_FFFF; // Thay doi du lieu lung tung tren bus
        #20; // Chờ qua 2 chu kỳ clock
        // Ky vong: opcode van phai giu nguyen la 3'b101 va operand la 32'h0000_0015


        // ====================================================================
        // TRƯỜNG HỢP 4: Kiem tra do uu tien giua Reset va Load
        // ====================================================================
        data_in = 32'h4000_000A; // Lenh bat ky
        ld_ir = 1;               // Bat cho phep nap
        rst = 1;                 // Nhung dong thoi bat reset
        #10; 
        // Vi rst dung dau nhanh if, mạch bat buoc phai xoa sach: opcode = 0, operand = 0
        
        // Dua ve trang thai an toan va ket thuc
        rst = 0;
        ld_ir = 0;
        #10;
        
        $display(">> Module Instruction Register Verification Completed!");
        $finish;
    end

endmodule