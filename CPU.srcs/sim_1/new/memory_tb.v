`timescale 1ns / 1ps

module tb_Memory;

    // 1. Khai báo các tín hiệu kết nối
    reg clk;
    reg rd;
    reg wr;
    reg [31:0] addr_mem;
    wire [31:0] data;

    // Tín hiệu nội bộ của Testbench để điều khiển đường truyền
    reg [31:0] data_to_write;
    
    assign data = (wr == 1'b1 && rd == 1'b0) ? data_to_write : 32'bz;

    Memory uut (
        .clk(clk),
        .rd(rd),
        .wr(wr),
        .addr_mem(addr_mem),
        .data(data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Khởi tạo các giá trị ban đầu
        rd = 0;
        wr = 0;
        addr_mem = 0;
        data_to_write = 0;
        
        $display("--- Kiem thu Module Memory (1024 words) ---");
        #15; 

        // ==========================================================
        // TRƯỜNG HỢP 1: Ghi vào các địa chỉ khác nhau
        
        addr_mem = 32'd10;
        data_to_write = 32'h1234_5678;
        wr = 1; rd = 0;
        #10; // Chốt dữ liệu tại posedge clk

        // Ghi 0xABCDEF00 vào ô nhớ 1023 (địa chỉ cuối cùng)
        addr_mem = 32'd1023;
        data_to_write = 32'hABCD_EF00;
        wr = 1; rd = 0;
        #10;

        // Dừng lệnh ghi, thả nổi Bus
        wr = 0;
        #10;

        // ==========================================================
        // TRƯỜNG HỢP 2: Đọc dữ liệu ra Bus
        
        addr_mem = 32'd10;
        rd = 1; wr = 0;
        #10; // Ở chu kỳ đầu tiên, RAM lấy dữ liệu từ mảng nạp vào data_out
        #10; // Ở chu kỳ thứ hai, dữ liệu sẽ ổn định trên Bus để quan sát

        // Đọc từ ô nhớ 1023 (Kỳ vọng: ABCDEF00)
        addr_mem = 32'd1023;
        rd = 1; wr = 0;
        #20;

        // ==========================================================
        // TRƯỜNG HỢP 3: Kiểm tra trạng thái nghỉ (Idle)
        
        rd = 0; wr = 0;
        #20; // Kỳ vọng Bus chuyển sang trạng thái Z (màu xanh mảnh)

        $display("--- Ket thuc mo phong Memory ---");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | Addr=%d | WR=%b | RD=%b | DataBus=%h", 
                 $time, addr_mem, wr, rd, data);
    end

endmodule