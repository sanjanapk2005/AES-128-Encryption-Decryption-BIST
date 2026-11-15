`timescale 1ns/1ps

module aes_roundtrip_testbench;

    reg clk;
    reg reset;

    reg enc_start;
    reg dec_start;

    reg [127:0] plaintext_in;
    reg [127:0] key;

    wire [127:0] ciphertext;
    wire [127:0] decrypted_plaintext;

    wire enc_done;
    wire dec_done;

    integer test_number;

    // Existing AES encryption module
    aes_top encryptor (
        .clk(clk),
        .reset(reset),
        .start(enc_start),
        .plaintext(plaintext_in),
        .key(key),
        .ciphertext(ciphertext),
        .done(enc_done)
    );

    // AES decryption module
    aes_decrypt decryptor (
        .clk(clk),
        .reset(reset),
        .start(dec_start),
        .ciphertext(ciphertext),
        .key(key),
        .plaintext(decrypted_plaintext),
        .done(dec_done)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    task run_test;
        input [127:0] test_plaintext;
        input [127:0] test_key;

        begin
            // Apply test inputs
            @(negedge clk);
            plaintext_in = test_plaintext;
            key = test_key;

            // Start encryption
            enc_start = 1'b1;
            @(negedge clk);
            enc_start = 1'b0;

            // Wait for encryption to finish
            wait (enc_done == 1'b1);
            #1;

            $display("----------------------------------------");
            $display("Test number : %0d", test_number);
            $display("Original plaintext: %032h", test_plaintext);
            $display("Secret key : %032h", test_key);
            $display("Ciphertext : %032h", ciphertext);

            // Start decryption
            @(negedge clk);
            dec_start = 1'b1;
            @(negedge clk);
            dec_start = 1'b0;

            // Wait for decryption to finish
            wait (dec_done == 1'b1);
            #1;

            $display("Decrypted plaintext: %032h",
                     decrypted_plaintext);

            if (decrypted_plaintext === test_plaintext)
                $display("RESULT: PASS");
            else
                $display("RESULT: FAIL");

            $display("----------------------------------------");

            @(negedge clk);
            test_number = test_number + 1;
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;

        enc_start = 1'b0;
        dec_start = 1'b0;

        plaintext_in = 128'b0;
        key = 128'b0;

        test_number = 1;

        // Reset both modules
        repeat (3) @(negedge clk);
        reset = 1'b0;

        // Test 1: All-zero plaintext and key
        run_test(
            128'h00000000000000000000000000000000,
            128'h00000000000000000000000000000000
        );

        // Test 2: All-one plaintext and key
        run_test(
            128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
            128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        );

        // Test 3: Different plaintext and key
        run_test(
            128'h00112233445566778899AABBCCDDEEFF,
            128'h00000000000000000000000000000000
        );

        $display("ALL ROUND-TRIP TESTS COMPLETED");
        $finish;
    end

    // Timeout protection
    initial begin
        #10000;
        $display("ERROR: Testbench timeout");
        $finish;
    end

endmodule
