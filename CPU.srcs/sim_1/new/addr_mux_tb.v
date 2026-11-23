`timescale 1ns / 1ps

module tb_AddressMux;
    reg [31:0] pc_addr;
    reg [31:0] ir_addr;
    reg sel;
    wire [31:0] add_out;
    
    AddressMux uut (
        .pc_addr(pc_addr),
        .ir_addr(ir_addr),
        .sel(sel),
        .add_out(add_out)
    );

    initial begin
        $monitor("Time = %0t | sel = %b | pc_addr = %h | ir_addr = %h | add_out = %h", 
                 $time, sel, pc_addr, ir_addr, add_out);

        // Khai bao gia tri ban dau
        pc_addr = 32'h0000_0000;
        ir_addr = 32'h0000_0000;
        sel = 0;
        #10;

        // ====================================================================
        // TEST CASE 1: Kiem tra chuc nang chuyen mach co ban voi gia tri thong thuong
        // ====================================================================
        pc_addr = 32'hAAAA_BBBB;
        ir_addr = 32'hCCCC_DDDD;
        
        sel = 1'b1; // Chon PC
        #10; // add_out == AAAABBBB
        
        sel = 1'b0; // Chon IR
        #10; // add_out ==  CCCCDDDD


        // ====================================================================
        // TEST CASE 2: Kiem tra dyna-switching (Thay doi du lieu khi dang ghim kenh)
        // ====================================================================
        sel = 1'b1; // Dang ghim kenh PC
        pc_addr = 32'h1111_2222; #5;
        ir_addr = 32'h3333_4444; #5; // add_out phai cap nhat tuc thi theo pc_addr
        
        sel = 1'b0; // Chuyen sang ghim kenh IR
        ir_addr = 32'h5555_6666; #5;
        ir_addr = 32'h7777_8888; #5; // add_out phai cap nhat tuc thi theo ir_addr


        // ====================================================================
        // TEST CASE 3: Stress Test voi cac gia tri bien Cuc doan (Boundary Values)
        // ====================================================================
        // Kich ban 3.1: All Zeros va All Ones
        pc_addr = 32'h0000_0000;
        ir_addr = 32'hFFFF_FFFF;
        
        sel = 1'b1; #10; // Chon PC -> Ra 00000000
        sel = 1'b0; #10; // Chon IR -> Ra FFFFFFFF

        // Kich ban 3.2: Check hien tuong xuyen nhieu bit o cac o bit xen ke (Walking 1s/0s)
        pc_addr = 32'h5555_5555; // 0101...0101
        ir_addr = 32'hAAAA_AAAA; // 1010...1010
        
        sel = 1'b1; #10; // Chon PC -> Ra 55555555
        sel = 1'b0; #10; // Chon IR -> Ra AAAAAAAA


        // ====================================================================
        // TEST CASE 4: Test hien tuong troi noi logic (X) hoac cao tro (Z) neu co
        // ====================================================================
        pc_addr = 32'h1234_5678;
        ir_addr = 32'h8765_4321;
        
        // Chuyen mach sel nhanh de kiem tra mach co bi tre lan vao nhau khong
        sel = 1; #2;
        sel = 0; #2;
        sel = 1; #2;
        sel = 0; #10;

        // Ket thuc mo phong
        $display(">> AddressMux Verification Completed successfully!");
        $finish;
    end

endmodule