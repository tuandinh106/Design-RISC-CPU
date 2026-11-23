module accum_reg (
    input [31:0] data_in,   
    input clk, rst, ld_ac, data_e, 
    output reg [31:0] accum_out, 
    output [31:0] data_out 
);
    always @(posedge clk) begin
        if (rst) accum_out <= 32'b0;
        else if (ld_ac) accum_out <= data_in;
    end

    assign data_out = (data_e) ? accum_out : 32'bz; 
endmodule
