`timescale 1ns/1ps

module lfsr_testbench;

reg clk;
reg reset;
reg enable;

wire [127:0] pattern;

lfsr128 dut (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .pattern(pattern)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    reset = 1;
    enable = 0;

    #20;

    reset = 0;
    enable = 1;

    #100;

    enable = 0;

    #20;

    $finish;

end

endmodule

