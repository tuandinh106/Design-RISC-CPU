`timescale 1ns / 1ps

module tb_Program_Counter;

    reg clk_cpu;
    reg rst;
    reg ld_pc;
    reg inc_pc;
    
    // Đã sửa thành 32-bit để khớp với module Program_Counter
    reg [31:0] load_val;
    wire [31:0] pc;

    Program_Counter uut (
        .clk(clk_cpu),       // Sửa .clk_cpu thành .clk
        .rst(rst),
        .ld_pc(ld_pc),
        .inc_pc(inc_pc),
        .load_val(load_val),
        .pc(pc)
    );

    initial begin
        clk_cpu = 0;
        forever #5 clk_cpu = ~clk_cpu;
    end

    initial begin
        // Khởi tạo hiển thị kết quả trên console (tùy chọn nhưng rất hữu ích)
        $monitor("Time = %0t | rst = %b | ld_pc = %b | inc_pc = %b | load_val = %h | pc = %h", 
                 $time, rst, ld_pc, inc_pc, load_val, pc);

        rst = 0;
        ld_pc = 0;
        inc_pc = 0;
        load_val = 32'b0; // Sửa định dạng thành 32-bit
        
        // Truong hop 1 test reset
        rst = 1;
        #10;
        rst = 0;
        #10;

        // Truong hop 2 test inc_pc
        inc_pc = 1;
        #30;
        inc_pc = 0;
        #10;

        // Truong hop 3 test load
        load_val = 32'b10101; // Sửa định dạng thành 32-bit
        ld_pc = 1;
        #10;
        ld_pc = 0;
        #10;

        // Truong hop 4 ktra do uu tien khi rst, ld_pc, inc_pc deu bang 1
        load_val = 32'b11111; // Sửa định dạng thành 32-bit
        rst = 1;
        ld_pc = 1;
        inc_pc = 1;
        #10;
        
        rst = 0;
        #10;
        
        ld_pc = 0;
        #20;

        inc_pc = 0;
        #10;
        
        $finish;
    end

endmodule
