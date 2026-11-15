`timescale 1ns/1ps
module misr128 (
    input clk,
    input reset,
    input enable,
    input [127:0] data_in,
    output reg [127:0] signature
);

wire feedback;

assign feedback = signature[127] ^
                  data_in[127] ^
                  data_in[126] ^
                  data_in[125] ^
                  data_in[120];

always @(posedge clk or posedge reset) begin
    if (reset)
        signature <= 128'd0;
    else if (enable)
        signature <= {signature[126:0], feedback} ^
                     data_in;
end

endmodule

