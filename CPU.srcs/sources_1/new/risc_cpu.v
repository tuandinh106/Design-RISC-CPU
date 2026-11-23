
module risc_cpu (
    input clk,
    input rst,
    output wire halt,
    output wire [31:0] debug_out
);

    // 1. KHAI BÁO CÁC ĐƯỜNG DÂY NỘI BỘ
    wire [2:0] opcode;
    wire is_zero;
    wire sel, rd, ld_ir, inc_pc, ld_ac, ld_pc, wr, data_e;
    
    wire [31:0] data_bus;  
    wire [31:0] addr_bus, pc_addr, ir_addr, alu_out, ac_out;

    controller control_unit (
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
    
    Program_Counter pc_unit (
        .clk(clk), 
        .rst(rst), 
        .ld_pc(ld_pc),
        .inc_pc(inc_pc), 
        .load_val(ir_addr), 
        .pc(pc_addr)
    );
     
    AddressMux mux_unit (
        .pc_addr(pc_addr),
        .ir_addr(ir_addr),
        .sel(sel),
        .add_out(addr_bus)
    );

    Memory mem_unit (
        .clk(clk), 
        .rd(rd), 
        .wr(wr),
        .addr_mem(addr_bus),
        .data(data_bus) // C?ng inout chung
    );

    instruction_reg ir_unit (
        .data_in(data_bus),
        .clk(clk), 
        .rst(rst), 
        .ld_ir(ld_ir),
        .opcode(opcode),
        .operand(ir_addr)
    );

    accum_reg accum_unit (
        .data_in(alu_out),
        .clk(clk), 
        .rst(rst), 
        .ld_ac(ld_ac),
        .data_e(data_e),
        .accum_out(ac_out),
        .data_out(data_bus)
    );
 
    alu alu_unit (
        .data(data_bus),
        .accum(ac_out),
        .opcode(opcode),
        .alu_out(alu_out),
        .is_zero(is_zero)
    );
endmodule