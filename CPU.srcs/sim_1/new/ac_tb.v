`timescale 1ns / 1ps

module tb_accum_reg;

    // 1. Khai báo các tín hiệu kết nối với UUT
    reg [31:0] data_in;
    reg clk;
    reg rst;
    reg ld_ac;
    reg data_e;

    wire [31:0] accum_out;
    wire [31:0] data_out;

    // 2. Gọi Module Accumulator Register (UUT)
    accum_reg uut (
        .data_in(data_in),
        .clk(clk),
        .rst(rst),
        .ld_ac(ld_ac),
        .data_e(data_e),
        .accum_out(accum_out),
        .data_out(data_out)
    );

    // 3. Tạo xung nhịp Clock (Chu kỳ 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. Kịch bản kiểm thử toàn diện
    initial begin
        // Cấu hình monitor xuất kết quả nhanh ra Tcl Console
        $monitor("Time=%0t | rst=%b | ld_ac=%b | data_e=%b | data_in=%h | accum_out=%h | data_out=%h", 
                 $time, rst, ld_ac, data_e, data_in, accum_out, data_out);

        // Khởi tạo trạng thái ban đầu
        rst = 0;
        ld_ac = 0;
        data_e = 0;
        data_in = 32'h0000_0000;
        #7; // Lệch pha sườn lên clk để tránh hiện tượng chạy đua (Race condition)

        // ====================================================================
        // TRƯỜNG HỢP 1: Kiểm tra Reset đồng bộ (Synchronous Reset)
        // ====================================================================
        rst = 1;
        data_in = 32'hAAAA_BBBB; // Cấp dữ liệu mồi
        #10; // Chờ 1 chu kỳ clock -> Kỳ vọng sau cạnh lên clk: accum_out = 0
        rst = 0;
        #10;

        // ====================================================================
        // TRƯỜNG HỢP 2: Nạp dữ liệu thành công (Load Operation)
        // ====================================================================
        data_in = 32'hCAFE_BABE; // Kết quả giả định từ ALU tính xong
        ld_ac = 1;               // Cho phép nạp vào AC
        #10; // Kỳ vọng sau sườn lên clk: accum_out = CAFEBABE
        
        // ====================================================================
        // TRƯỜNG HỢP 3: Kiểm tra tính năng Đóng/Mở cổng Tri-state (data_e)
        // ====================================================================
        // Kịch bản 3.1: Khi data_e = 0 (Trạng thái cô lập Bus)
        data_e = 0; 
        #5; // Kỳ vọng: accum_out vẫn giữ giá trị, nhưng dây data_out phải chuyển thành ZZZZZZZZ
        
        // Kịch bản 3.2: Khi data_e = 1 (Trạng thái đẩy dữ liệu ra Bus)
        data_e = 1; 
        #5; // Kỳ vọng: lập tức dây data_out phải hiển thị đúng giá trị CAFEBABE (mạch tổ hợp)

        // ====================================================================
        // TRƯỜNG HỢP 4: Kiểm tra trạng thái Giữ giá trị ổn định (Hold State)
        // ====================================================================
        ld_ac = 0;               // Khóa chốt thanh ghi AC lại
        data_in = 32'h1111_2222; // Thay đổi dữ liệu ngõ vào liên tục
        #20; // Chờ qua 2 chu kỳ clock
        // Kỳ vọng: accum_out và data_out vẫn kiên định giữ nguyên giá trị cũ CAFEBABE

        // ====================================================================
        // TRƯỜNG HỢP 5: Kiểm tra độ ưu tiên tối cao của Reset so với Load
        // ====================================================================
        data_in = 32'hFFFF_FFFF;
        ld_ac = 1;               // Kích lệnh nạp dữ liệu mới
        rst = 1;                 // Nhưng đồng thời kích cả Reset
        #10; 
        // Kỳ vọng: Do lệnh if(rst) đứng đầu mạch cứng, AC bắt buộc phải sập về 0 chứ không được nạp FFFFFFFF.

        // Đưa hệ thống về vùng an toàn và tắt mô phỏng
        rst = 0;
        ld_ac = 0;
        data_e = 0;
        #10;
        
        $display(">> Module Accumulator Register Verification Completed successfully!");
        $finish;
    end

endmodule