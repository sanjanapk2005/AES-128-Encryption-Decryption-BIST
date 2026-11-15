`timescale 1ns/1ps

module inv_subbytes (
    input [127:0] in_state,
    output [127:0] out_state
);

aes_inv_sbox s0 (.in(in_state[127:120]), .out(out_state[127:120]));
aes_inv_sbox s1 (.in(in_state[119:112]), .out(out_state[119:112]));
aes_inv_sbox s2 (.in(in_state[111:104]), .out(out_state[111:104]));
aes_inv_sbox s3 (.in(in_state[103:96]), .out(out_state[103:96]));

aes_inv_sbox s4 (.in(in_state[95:88]), .out(out_state[95:88]));
aes_inv_sbox s5 (.in(in_state[87:80]), .out(out_state[87:80]));
aes_inv_sbox s6 (.in(in_state[79:72]), .out(out_state[79:72]));
aes_inv_sbox s7 (.in(in_state[71:64]), .out(out_state[71:64]));

aes_inv_sbox s8 (.in(in_state[63:56]), .out(out_state[63:56]));
aes_inv_sbox s9 (.in(in_state[55:48]), .out(out_state[55:48]));
aes_inv_sbox s10(.in(in_state[47:40]), .out(out_state[47:40]));
aes_inv_sbox s11(.in(in_state[39:32]), .out(out_state[39:32]));

aes_inv_sbox s12(.in(in_state[31:24]), .out(out_state[31:24]));
aes_inv_sbox s13(.in(in_state[23:16]), .out(out_state[23:16]));
aes_inv_sbox s14(.in(in_state[15:8]), .out(out_state[15:8]));
aes_inv_sbox s15(.in(in_state[7:0]), .out(out_state[7:0]));

endmodule

