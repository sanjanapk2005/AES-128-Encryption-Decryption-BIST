`timescale 1ns/1ps

module aes_crypto_processor (
    input clk,
    input reset,

    // Operating mode: 0 = normal operation, 1 = BIST
    input bist_mode,

    // Encryption/decryption control
    input encrypt_start,
    input decrypt_start,

    // Encryption/decryption data
    input [127:0] plaintext_in,
    input [127:0] ciphertext_in,
    input [127:0] key,

    // Fault injection for simulation
    input inject_fault,

    // Outputs
    output [127:0] ciphertext_out,
    output [127:0] plaintext_out,

    output encrypt_done,
    output decrypt_done,

    output bist_done,
    output bist_pass,
    output bist_fail,
    output [127:0] bist_signature
);

    // -------------------------------------------------
    // AES ENCRYPTION CORE
    // -------------------------------------------------

    wire [127:0] encrypted_data;
    wire aes_encrypt_done;

    aes_top encryption_core (
        .clk(clk),
        .reset(reset),
        .start(encrypt_start),
        .plaintext(plaintext_in),
        .key(key),
        .ciphertext(encrypted_data),
        .done(aes_encrypt_done)
    );

    assign ciphertext_out = encrypted_data;
    assign encrypt_done = aes_encrypt_done;


    // -------------------------------------------------
    // AES DECRYPTION CORE
    // -------------------------------------------------

    wire [127:0] decrypted_data;
    wire aes_decrypt_done;

    aes_decrypt decryption_core (
        .clk(clk),
        .reset(reset),
        .start(decrypt_start),
        .ciphertext(ciphertext_in),
        .key(key),
        .plaintext(decrypted_data),
        .done(aes_decrypt_done)
    );

    assign plaintext_out = decrypted_data;
    assign decrypt_done = aes_decrypt_done;


    // -------------------------------------------------
    // BUILT-IN SELF-TEST
    // -------------------------------------------------

    wire [127:0] internal_signature;
    wire internal_bist_done;
    wire internal_bist_pass;
    wire internal_bist_fail;

    generate
        if (1) begin : BIST_IMPLEMENTATION

            aes_bist_faultable bist_core (
                .clk(clk),
                .reset(reset),
                .bist_start(bist_mode),
                .inject_fault(inject_fault),
                .key(key),
                .bist_done(internal_bist_done),
                .bist_pass(internal_bist_pass),
                .bist_fail(internal_bist_fail),
                .signature(internal_signature)
            );

        end
    endgenerate

    assign bist_signature = internal_signature;
    assign bist_done = internal_bist_done;
    assign bist_pass = internal_bist_pass;
    assign bist_fail = internal_bist_fail;

endmodule

