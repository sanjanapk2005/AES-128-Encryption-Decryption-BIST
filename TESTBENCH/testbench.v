`timescale 1ns/1ps

module testbench;

reg clk;
reg reset;
reg start;
reg [127:0] plaintext;
reg [127:0] key;
wire [127:0] ciphertext;
wire done;

aes_top uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    start = 0;

    plaintext = 128'h00112233445566778899aabbccddeeff;
    key = 128'h000102030405060708090a0b0c0d0e0f;

    #20;
    reset = 0;

    #10;
    start = 1;

    #10;
    start = 0;

    wait(done);

    $display("Ciphertext = %h", ciphertext);

    if(ciphertext == 128'h69c4e0d86a7b0430d8cdb78070b4c55a)
        $display("AES TEST PASSED");
    else
        $display("AES TEST FAILED");

    #20;
    $finish;
end

endmodule
