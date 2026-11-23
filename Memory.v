module Memory (
    input clk,
    input rd,
    input wr,
    input [31:0] addr_mem,
    inout [31:0] data
);

    reg [31:0] mem_array [0:1023]; 
    reg [31:0] data_out;

    assign data = (rd == 1'b1 && wr == 1'b0) ? data_out : {32{1'bz}};

    always @(posedge clk) begin
            if (wr == 1'b1 && rd == 1'b0) begin
                mem_array[addr_mem] <= data;
            end
            else if (rd == 1'b1 && wr == 1'b0) begin
                data_out <= mem_array[addr_mem];
            end
    end
endmodule
