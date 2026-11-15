`timescale 1ns/1ps

module aes_bist_fault_injection;

    reg clk;
    reg reset;
    reg bist_start;
    reg inject_fault;
    reg [127:0] key;

    wire bist_done;
    wire bist_pass;
    wire bist_fail;
    wire [127:0] signature;

    // Instantiate the faultable BIST module
    aes_bist_faultable dut (
        .clk(clk),
        .reset(reset),
        .bist_start(bist_start),
        .inject_fault(inject_fault),
        .key(key),
        .bist_done(bist_done),
        .bist_pass(bist_pass),
        .bist_fail(bist_fail),
        .signature(signature)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        bist_start = 0;
        inject_fault = 0;

        key = 128'h000102030405060708090A0B0C0D0E0F;

        // Reset BIST
        #20;
        reset = 0;

        // TEST 1: Normal BIST
        #10;
        $display("----------------------------------");
        $display("TEST 1: NORMAL BIST");

        bist_start = 1;
        #10;
        bist_start = 0;

        wait (bist_done == 1);
        #10;

        $display("SIGNATURE = %032h", signature);

        if (bist_pass)
            $display("NORMAL BIST: PASS");
        else
            $display("NORMAL BIST: FAIL");

        // Reset before the fault test
        reset = 1;
        #10;
        reset = 0;

        // TEST 2: Actual fault injection
        #10;
        $display("----------------------------------");
        $display("TEST 2: FAULT INJECTION");

        inject_fault = 1;
        bist_start = 1;
        #10;
        bist_start = 0;

        wait (bist_done == 1);
        #10;

        $display("FAULT-TEST SIGNATURE = %032h", signature);

        if (bist_fail)
            $display("FAULT DETECTED: BIST FAIL");
        else
            $display("FAULT NOT DETECTED: CHECK SIGNATURE");

        $display("----------------------------------");
        $finish;
    end

    initial begin
        #5000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule

