`timescale 1ns / 1ps

module controller_tb ();
    // 1. Khai báo các chân tín hiệu kết nối
    reg clk;
    reg rst;
    reg [2:0] opcode;
    reg is_zero;
    
    wire sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e;

    // Định nghĩa Parameter cho Tập lệnh giống file Design
    parameter HLT = 3'b000, SKZ = 3'b001, ADD = 3'b010, AND = 3'b011,
              XOR = 3'b100, LDA = 3'b101, STO = 3'b110, JMP = 3'b111;

    // Biến phụ trợ dùng để hiển thị tên lệnh dạng CHỮ trên Tcl Console
    reg [23:0] op_name; 

    // 2. Gọi module Controller (UUT)
    controller uut (
        .clk(clk), .rst(rst), .opcode(opcode), .is_zero(is_zero),
        .sel(sel), .rd(rd), .ld_ir(ld_ir), .halt(halt),
        .inc_pc(inc_pc), .ld_ac(ld_ac), .ld_pc(ld_pc), .wr(wr), .data_e(data_e)
    );

    // Tạo xung nhịp Clock tuần hoàn (Chu kỳ 10ns)
    always #5 clk = ~clk; 

    // Mạch tổ hợp tự động dịch mã Opcode sang chữ viết tắt
    always @(*) begin
        case (opcode)
            HLT: op_name = "HLT";
            SKZ: op_name = "SKZ";
            ADD: op_name = "ADD";
            AND: op_name = "AND";
            XOR: op_name = "XOR";
            LDA: op_name = "LDA";
            STO: op_name = "STO";
            JMP: op_name = "JMP";
            default: op_name = "UNK";
        endcase
    end

    // 3. Kịch bản kiểm thử chi tiết qua từng chu kỳ trạng thái (8 nhịp clock mỗi lệnh)
    initial begin
        // Khởi tạo các tín hiệu gốc
        clk = 0;
        rst = 1;
        opcode = HLT;
        is_zero = 0;
        
        // Trễ 13ns để lệch pha với cạnh lên xung Clock, tránh lỗi chạy đua (Race Condition)
        #13; 
        rst = 0; // Nhả mạch Reset

        $display("\n==========================================================================");
        $display("     BAT DAU QUY TRINH KIEM THU TOAN DIEN KHOI CONTROLLER UNIT");
        $display("==========================================================================\n");

        // --- Case 1: Lệnh ADD (Cộng tích lũy) ---
        $display("[TIME: %0t] >>> TEST CASE 1: Thực thi lệnh ADD (Opcode 010) ---", $time);
        opcode = ADD; #5;
        repeat (8) @(posedge clk); 
        
        // --- Case 2: Lệnh AND (Mặt nạ Bit) ---
        $display("\n[TIME: %0t] >>> TEST CASE 2: Thực thi lệnh AND (Opcode 011) ---", $time);
        opcode = AND; #5;
        repeat (8) @(posedge clk); 

        // --- Case 3: Lệnh XOR (Đảo bit logic) [MỚI BỔ SUNG] ---
        $display("\n[TIME: %0t] >>> TEST CASE 3: Thực thi lệnh XOR (Opcode 100) ---", $time);
        opcode = XOR; #5;
        repeat (8) @(posedge clk); 

        // --- Case 4: Lệnh LDA (Nạp Accumulator) [MỚI BỔ SUNG] ---
        $display("\n[TIME: %0t] >>> TEST CASE 4: Thực thi lệnh LDA (Opcode 101) ---", $time);
        opcode = LDA; #5;
        repeat (8) @(posedge clk); 

        // --- Case 5: Lệnh STO (Ghi RAM) ---
        $display("\n[TIME: %0t] >>> TEST CASE 5: Thực thi lệnh STO (Opcode 110) ---", $time);
        opcode = STO; #5;
        repeat (8) @(posedge clk);

        // --- Case 6: Lệnh JMP (Nhảy không điều kiện) ---
        $display("\n[TIME: %0t] >>> TEST CASE 6: Thực thi lệnh JMP (Opcode 111) ---", $time);
        opcode = JMP; #5;
        repeat (8) @(posedge clk);

        // --- Case 7: Lệnh SKZ với cờ Zero = 0 (Không thỏa điều kiện nhảy) ---
        $display("\n[TIME: %0t] >>> TEST CASE 7: Thực thi lệnh SKZ khi ACCUMULATOR KHÁC 0 (Zero = 0) ---", $time);
        opcode = SKZ; is_zero = 0; #5;       
        repeat (8) @(posedge clk);

        // --- Case 8: Lệnh SKZ với cờ Zero = 1 (Thỏa điều kiện nhảy, kích hoạt inc_pc liên tục) ---
        $display("\n[TIME: %0t] >>> TEST CASE 8: Thực thi lệnh SKZ khi ACCUMULATOR BẰNG 0 (Zero = 1) ---", $time);
        opcode = SKZ; is_zero = 1; #5;       
        repeat (8) @(posedge clk);

        // --- Case 9: Lệnh HLT (Dừng CPU) --- 
        $display("\n[TIME: %0t] >>> TEST CASE 9: Thực thi lệnh HLT -> Kích hoạt chân HALT hệ thống ---", $time);
        opcode = HLT; #5;
        repeat (8) @(posedge clk);

        $display("\n==========================================================================");
        $display(" >> KẾT THÚC MÔ PHỎNG CONTROLLER!");
        $display("==========================================================================\n");
        $finish;
    end

    // 4. Mạch giám sát (Monitor) in ra đầy đủ 9 tín hiệu điều khiển dạng bảng matrix cực đẹp
    initial begin
        // In dòng tiêu đề cột trước để dễ đối chiếu
        $display("Time\t\tCmd\t| [Sel Read LdIR Halt IncPC LdAC LdPC Wr DataE]");
        $display("--------------------------------------------------------------------------");
        
        // Mẹo nhỏ: Bạn có thể thêm biến uut.state vào monitor bên dưới nếu muốn in cả tên trạng thái FSM hiện tại.
        $monitor("%0t ns\t%s\t|   %b    %b    %b    %b     %b     %b    %b    %b    %b", 
                 $time, op_name, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
    end

endmodule