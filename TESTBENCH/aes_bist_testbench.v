`timescale 1ns/1ps

module aes_bist_testbench;

    // -----------------------------------------
    // Testbench signals
    // -----------------------------------------

    reg clk;
    reg reset;
    reg bist_start;

    reg [127:0] key;

    wire bist_done;
    wire bist_pass;
    wire bist_fail;
    wire [127:0] signature;


    // -----------------------------------------
    // DUT: AES BIST
    // -----------------------------------------

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


    // -----------------------------------------
    // Clock generation
    // 10 ns clock period
    // -----------------------------------------

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // -----------------------------------------
    // BIST test
    // -----------------------------------------

    initial begin

        // Initial values
        clk = 1'b0;
        reset = 1'b1;
        bist_start = 1'b0;

        // AES-128 test key
        key = 128'h000102030405060708090A0B0C0D0E0F;


        // -------------------------------------
        // Apply reset
        // -------------------------------------

        #20;

        reset = 1'b0;


        // -------------------------------------
        // Wait after reset
        // -------------------------------------

        #20;


        // -------------------------------------
        // Start BIST
        // -------------------------------------

        bist_start = 1'b1;

        #10;

        bist_start = 1'b0;


        // -------------------------------------
        // Wait until BIST finishes
        // -------------------------------------

        wait (bist_done == 1'b1);

        #10;


        // -------------------------------------
        // Display results
        // -------------------------------------

        $display("");
        $display("==========================================");
        $display(" AES-128 BIST RESULT");
        $display("==========================================");

        $display("KEY = %h", key);

        $display("SIGNATURE = %h", signature);

        $display("BIST_DONE = %b", bist_done);

        $display("BIST_PASS = %b", bist_pass);

        $display("BIST_FAIL = %b", bist_fail);


        // -------------------------------------
        // Check result
        // -------------------------------------

        if (bist_pass == 1'b1 &&
            bist_fail == 1'b0) begin

            $display("");
            $display("**************************************");
            $display(" AES BIST TEST PASSED");
            $display("**************************************");

        end

        else begin

            $display("");
            $display("**************************************");
            $display(" AES BIST TEST FAILED");
            $display("**************************************");

        end


        $display("==========================================");
        $display("");


        // -------------------------------------
        // End simulation
        // -------------------------------------

        #10;

        $finish;

    end

endmodule
