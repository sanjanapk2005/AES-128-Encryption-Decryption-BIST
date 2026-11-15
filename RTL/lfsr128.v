`timescale 1ns/1ps
module lfsr128 (
    input clk,
    input reset,
    input enable,
    output reg [127:0] pattern
);

wire feedback;

assign feedback = pattern[127] ^
                  pattern[126] ^
                  pattern[125] ^
                  pattern[120];

always @(posedge clk or posedge reset) begin
    if (reset)
        pattern <= 128'h1;
    else if (enable)
        pattern <= {pattern[126:0], feedback};
end

endmodule
