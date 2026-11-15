`timescale 1ns/1ps

module aes_crypto_processor_testbench;

    reg clk;
    reg reset;
    reg bist_mode;
    reg encrypt_start;
    reg decrypt_start;
    reg inject_fault;

    reg [127:0] plaintext_in;
    reg [127:0] ciphertext_in;
    reg [127:0] key;

    wire [127:0] ciphertext_out;
    wire [127:0] plaintext_out;

    wire encrypt_done;
    wire decrypt_done;

    wire bist_done;
    wire bist_pass;
    wire bist_fail;
    wire [127:0] bist_signature;

    // Integrated crypto-processor
    aes_crypto_processor dut (
        .clk(clk),
        .reset(reset),
        .bist_mode(bist_mode),
        .encrypt_start(encrypt_start),
        .decrypt_start(decrypt_start),
        .plaintext_in(plaintext_in),
        .ciphertext_in(ciphertext_in),
        .key(key),
        .inject_fault(inject_fault),
        .ciphertext_out(ciphertext_out),
        .plaintext_out(plaintext_out),
        .encrypt_done(encrypt_done),
        .decrypt_done(decrypt_done),
        .bist_done(bist_done),
        .bist_pass(bist_pass),
        .bist_fail(bist_fail),
        .bist_signature(bist_signature)
    );

    // 10 ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        reset = 1;
        bist_mode = 0;
        encrypt_start = 0;
        decrypt_start = 0;
        inject_fault = 0;

        plaintext_in = 128'h00112233445566778899AABBCCDDEEFF;
        ciphertext_in = 128'h69C4E0D86A7B0430D8CDB78070B4C55A;
        key = 128'h000102030405060708090A0B0C0D0E0F;

        // Reset all modules
        #20;
        reset = 0;

        // ----------------------------------
        // TEST 1: AES ENCRYPTION
        // ----------------------------------
        $display("==================================");
        $display("TEST 1: AES ENCRYPTION");

        #10;
        encrypt_start = 1;
        #10;
        encrypt_start = 0;

        wait (encrypt_done == 1);
        #1;

        $display("CIPHERTEXT = %032h", ciphertext_out);

        if (ciphertext_out ==
            128'h69C4E0D86A7B0430D8CDB78070B4C55A)
            $display("ENCRYPTION: PASS");
        else
            $display("ENCRYPTION: FAIL");

        // ----------------------------------
        // TEST 2: AES DECRYPTION
        // ----------------------------------
        $display("==================================");
        $display("TEST 2: AES DECRYPTION");

        #10;
        decrypt_start = 1;
        #10;
        decrypt_start = 0;

        wait (decrypt_done == 1);
        #1;

        $display("PLAINTEXT = %032h", plaintext_out);

        if (plaintext_out ==
            128'h00112233445566778899AABBCCDDEEFF)
            $display("DECRYPTION: PASS");
        else
            $display("DECRYPTION: FAIL");

        // ----------------------------------
        // TEST 3: NORMAL BIST
        // ----------------------------------
        $display("==================================");
        $display("TEST 3: NORMAL BIST");

        #10;
        bist_mode = 1;
        #10;
        bist_mode = 0;

        wait (bist_done == 1);
        #1;

        $display("BIST SIGNATURE = %032h", bist_signature);

        if (bist_pass)
            $display("NORMAL BIST: PASS");
        else
            $display("NORMAL BIST: FAIL");

        // ----------------------------------
        // TEST 4: FAULT INJECTION
        // ----------------------------------
        $display("==================================");
        $display("TEST 4: FAULT INJECTION");

        reset = 1;
        #10;
        reset = 0;

        #10;
        inject_fault = 1;
        bist_mode = 1;

        #10;
        bist_mode = 0;

        wait (bist_done == 1);
        #1;

        $display("FAULT-TEST SIGNATURE = %032h",
                 bist_signature);

        if (bist_fail)
            $display("FAULT DETECTED: PASS");
        else
            $display("FAULT DETECTION: FAIL");

        $display("==================================");
        $finish;
    end

    initial begin
        #5000;
        $display("ERROR: SIMULATION TIMEOUT");
        $finish;
    end

endmodule

