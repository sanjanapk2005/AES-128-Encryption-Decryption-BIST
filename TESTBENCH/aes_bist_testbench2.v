`timescale 1ns/1ps

module aes_bist_testbench2;

    reg clk;
    reg reset;
    reg bist_start;
    reg [127:0] key;

    wire bist_done;
    wire bist_pass;
    wire bist_fail;
    wire [127:0] signature;

    // Instantiate AES-BIST
    aes_bist dut (
        .clk(clk),
        .reset(reset),
        .bist_start(bist_start),
        .key(key),
        .bist_done(bist_done),
        .bist_pass(bist_pass),
        .bist_fail(bist_fail),
        .signature(signature)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        bist_start = 1'b0;

        // Use the same key expected by your BIST setup
        key = 128'h000102030405060708090A0B0C0D0E0F;

        // Apply reset
        #20;
        reset = 1'b0;

        // Start BIST
        #10;
        bist_start = 1'b1;

        #10;
        bist_start = 1'b0;

        // Wait for BIST to finish
        wait (bist_done == 1'b1);
        #1;

        $display("------------------------------------");
        $display("AES-BIST TEST RESULTS");
        $display("MISR Signature = %032h", signature);

        if (bist_pass)
            $display("BIST RESULT: PASS");
        else if (bist_fail)
            $display("BIST RESULT: FAIL");
        else
            $display("BIST RESULT: INVALID");

        $display("------------------------------------");

        #20;
        $finish;
    end

    // Timeout protection
    initial begin
        #5000;
        $display("ERROR: BIST simulation timed out");
        $finish;
    end

endmodule
