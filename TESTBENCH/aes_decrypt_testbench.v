`timescale 1ns/1ps

module aes_decrypt_testbench;

    reg clk;
    reg reset;
    reg start;

    reg [127:0] ciphertext;
    reg [127:0] key;

    wire [127:0] plaintext;
    wire done;

    // Instantiate AES decryption module
    aes_decrypt dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .ciphertext(ciphertext),
        .key(key),
        .plaintext(plaintext),
        .done(done)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        ciphertext = 128'b0;
        key = 128'b0;

        // Apply reset
        #20;
        reset = 1'b0;

        // Standard AES-128 test vector
        ciphertext = 128'h69C4E0D86A7B0430D8CDB78070B4C55A;
        key = 128'h000102030405060708090A0B0C0D0E0F;

        // Start decryption
        #10;
        start = 1'b1;

        #10;
        start = 1'b0;

        // Wait for decryption to finish
        wait (done == 1'b1);

        #1;
        $display("----------------------------------------");
        $display("AES-128 DECRYPTION TEST");
        $display("Ciphertext = %032h", ciphertext);
        $display("Secret Key = %032h", key);
        $display("Decrypted Plaintext = %032h", plaintext);
        $display("Expected Plaintext = 00112233445566778899AABBCCDDEEFF");

        if (plaintext == 128'h00112233445566778899AABBCCDDEEFF)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");

        $display("----------------------------------------");

        #20;
        $finish;
    end

    // Prevent an indefinite simulation if decryption never completes
    initial begin
        #2000;
        $display("ERROR: Simulation timeout - decryption did not complete.");
        $finish;
    end

endmodule

