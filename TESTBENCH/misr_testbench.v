`timescale 1ns/1ps

module misr_testbench;

reg clk;
reg reset;
reg enable;
reg [127:0] data_in;

wire [127:0] signature;

misr128 dut (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .data_in(data_in),
    .signature(signature)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    reset = 1;
    enable = 0;
    data_in = 128'd0;

    #20;

    reset = 0;
    enable = 1;

    // Test pattern 1
    data_in = 128'h00112233445566778899AABBCCDDEEFF;

    #10;

    // Test pattern 2
    data_in = 128'h000102030405060708090A0B0C0D0E0F;

    #10;

    // Test pattern 3
    data_in = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    #10;

    enable = 0;

    #20;

    $display("------------------------------------");
    $display("MISR TEST COMPLETE");
    $display("FINAL SIGNATURE = %h", signature);
    $display("------------------------------------");

    $finish;

end

endmodule
