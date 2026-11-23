`timescale 1ns / 1ps

module risc_cpu_tb();
    reg clk;
    reg rst;  
    wire [2:0] opcode;
    wire is_zero;
    wire sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e;
    wire [31:0] data_bus, addr_bus, pc_addr, ir_addr, alu_out, ac_out;   
    
    risc_cpu uut (
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
        .data_e(data_e),
        .data_bus(data_bus),
        .addr_bus(addr_bus), 
        .pc_addr(pc_addr),
        .ir_addr(ir_addr),
        .alu_out(alu_out),
        .ac_out(ac_out)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer i;
    initial begin        
        for (i = 0; i < 1024; i = i + 1) begin
            uut.mem_unit.mem_array[i] = 32'b0;
        end
        
        $readmemh("program.mem", uut.mem_unit.mem_array);
        
        rst = 1;
        #10;
        rst = 0;
        
        wait(halt == 1'b1); 
        #50;
        $finish;        
    end
endmodule