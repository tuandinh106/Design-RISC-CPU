`timescale 1ns / 1ps

module risc_cpu_tb();
    // 1. Khai báo các tín hiệu điều khiển gốc cấp vào CPU
    reg clk;
    reg rst;  
    wire halt; // Chân ngõ ra duy nhất thực tế của CPU

    // 2. GỌI MODULE TOP (CHỈ NỐI CHÍNH XÁC CÁC CỔNG THỰC TẾ)
    risc_cpu uut (
        .clk(clk), 
        .rst(rst),
        .halt(halt)
    );

    // 3. KỸ THUẬT CÂU DÂY NGẦM (HIERARCHICAL PROBES)
    // Giúp Testbench trỏ thẳng vào lòng CPU lấy dữ liệu xem sóng mà không cần khai báo cổng ở file Top
    wire [2:0] opcode  = uut.opcode;
    wire is_zero       = uut.is_zero;
    wire sel           = uut.sel;
    wire rd            = uut.rd;
    wire ld_ir         = uut.ld_ir;
    wire inc_pc        = uut.inc_pc;
    wire ld_ac         = uut.ld_ac;
    wire ld_pc         = uut.ld_pc;
    wire wr            = uut.wr;
    wire data_e        = uut.data_e;
    
    wire [31:0] data_bus = uut.data_bus;
    wire [31:0] addr_bus = uut.addr_bus;
    wire [31:0] pc_addr  = uut.pc_addr;
    wire [31:0] ir_addr  = uut.ir_addr;
    wire [31:0] alu_out  = uut.alu_out;
    wire [31:0] ac_out   = uut.ac_out;   
    
    // 4. Tạo xung nhịp Clock hệ thống (Chu kỳ 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 5. Kịch bản nạp RAM và kích hoạt CPU
    integer i;
    initial begin        
        // Xóa sạch bộ nhớ RAM về 0 trước khi chạy
        for (i = 0; i < 1024; i = i + 1) begin
            uut.mem_unit.mem_array[i] = 32'b0;
        end
        
        // Nạp file chứa chương trình mã máy dạng Hex vào RAM
        $readmemh("program.mem", uut.mem_unit.mem_array);
        
        // Kích hoạt Reset hệ thống (Giữ trong 1 chu kỳ rưỡi clk để mạch chốt ổn định)
        rst = 1;
        #15; 
        rst = 0;
        
        // Ép hệ thống chờ cho đến khi Controller chạy hết chương trình và dựng chân HALT lên 1
        wait(halt == 1'b1); 
        #50; // Chờ thêm 5 chu kỳ máy để đồ thị đi ngang đẹp mắt trước khi tắt
        
        $display(">> MO PHONG RICS CPU THANH CONG!");
        $finish;        
    end

    // 6. Theo dõi vết xử lý lệnh ra cửa sổ Console dạng bảng cực chất
    initial begin
        $monitor("Time=%0t ns | PC=%h | IR_Addr=%h | Opcode=%b | AC=%h | BusData=%h", 
                 $time, pc_addr, ir_addr, opcode, ac_out, data_bus);
    end
endmodule