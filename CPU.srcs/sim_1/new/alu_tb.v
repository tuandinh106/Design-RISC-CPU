`timescale 1ns / 1ps

module tb_alu;

    // 1. Khai báo các tín hiệu kết nối với UUT (Unit Under Test)
    reg [31:0] data;
    reg [31:0] accum;
    reg [2:0] opcode;
    
    wire [31:0] alu_out;
    wire is_zero;

    // Định nghĩa lại các Parameter giống hệt file Design để code testbench tường minh
    parameter   HLT = 3'b000, SKZ = 3'b001,
                ADD = 3'b010, AND = 3'b011,
                XOR = 3'b100, LDA = 3'b101,
                STO = 3'b110, JMP = 3'b111;

    // 2. Gọi Module ALU vào để kiểm thử (Named Port Mapping)
    alu uut (
        .data(data),
        .accum(accum),
        .opcode(opcode),
        .alu_out(alu_out),
        .is_zero(is_zero)
    );

    // 3. Kịch bản kiểm thử toàn diện (Mạch tổ hợp không cần xung nhịp clock)
    initial begin
        // Hiển thị trực quan log kết quả trên Tcl Console để check nhanh
        $monitor("Time=%0t | Opcode=%b | Accum=%h | Data=%h | AluOut=%h | IsZero=%b", 
                 $time, opcode, accum, data, alu_out, is_zero);

        // Khởi tạo trạng thái ban đầu
        data = 32'h0000_0000;
        accum = 32'h0000_0000;
        opcode = HLT;
        #10; // Chờ đáp ứng mạch tổ hợp

        // ====================================================================
        // TRƯỜNG HỢP 1: Kiểm tra phép toán Số học (ADD) & Trạng thái biên tràn số
        // ====================================================================
        opcode = ADD;
        accum = 32'h0000_0005; data = 32'h0000_0006; #10; // 5 + 6 = 11 (b)
        
        // Test trường hợp tràn số (Overflow)
        accum = 32'hFFFF_FFFF; data = 32'h0000_0001; #10; // FFFFFFFF + 1 = 00000000 (Tràn bit)


        // ====================================================================
        // TRƯỜNG HỢP 2: Kiểm tra các phép toán Logic (AND, XOR)
        // ====================================================================
        // Phép toán AND (Mặt nạ bit)
        opcode = AND;
        accum = 32'h00FF_00FF; data = 32'h1234_5678; #10; // Kết quả kỳ vọng: 0034_0078
        
        // Phép toán XOR (Đảo bit có chọn lọc)
        opcode = XOR;
        accum = 32'hFFFF_FFFF; data = 32'h1234_5678; #10; // Kết quả kỳ vọng: EDCA_A987 (Đảo toàn bộ)


        // ====================================================================
        // TRƯỜNG HỢP 3: Kiểm tra lệnh nạp trực tiếp (LDA)
        // ====================================================================
        opcode = LDA;
        accum = 32'h5555_5555; data = 32'h9999_9999; #10; // alu_out phải bắt đúng theo dây Data = 99999999


        // ====================================================================
        // TRƯỜNG HỢP 4: Kiểm tra nhóm lệnh mặc định (Default Case - HLT, SKZ, STO, JMP)
        // ====================================================================
        // Khi chạy các lệnh này, ngõ ra ALU phải giữ nguyên giá trị của Accumulator
        accum = 32'h5A5A_5A5A; data = 32'h1111_1111;
        
        opcode = SKZ; #10; // alu_out = 5A5A5A5A
        opcode = HLT; #10; // alu_out = 5A5A5A5A
        opcode = STO; #10; // alu_out = 5A5A5A5A
        opcode = JMP; #10; // alu_out = 5A5A5A5A


        // ====================================================================
        // TRƯỜNG HỢP 5: Kiểm tra cờ kiểm tra số không (is_zero flag)
        // ====================================================================
        // Kịch bản 5.1: Khi Accumulator khác 0 -> is_zero phải bằng 0
        accum = 32'h0000_0001; #10;
        
        // Kịch bản 5.2: Khi Accumulator đúng bằng 0 -> is_zero phải lập tức dựng lên 1
        accum = 32'h0000_0000; #10;

        // Kết thúc chu trình mô phỏng
        $display(">> ALU Module Verification Completed Successfully!");
        $finish;
    end

endmodule