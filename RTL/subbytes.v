`timescale 1ns/1ps
module subbytes(
    input [127:0] in_state,
    output [127:0] out_state
);

wire [7:0] s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15;

aes_sbox sb0 (.in(in_state[127:120]), .out(s0));
aes_sbox sb1 (.in(in_state[119:112]), .out(s1));
aes_sbox sb2 (.in(in_state[111:104]), .out(s2));
aes_sbox sb3 (.in(in_state[103:96]), .out(s3));
aes_sbox sb4 (.in(in_state[95:88]), .out(s4));
aes_sbox sb5 (.in(in_state[87:80]), .out(s5));
aes_sbox sb6 (.in(in_state[79:72]), .out(s6));
aes_sbox sb7 (.in(in_state[71:64]), .out(s7));
aes_sbox sb8 (.in(in_state[63:56]), .out(s8));
aes_sbox sb9 (.in(in_state[55:48]), .out(s9));
aes_sbox sb10 (.in(in_state[47:40]), .out(s10));
aes_sbox sb11 (.in(in_state[39:32]), .out(s11));
aes_sbox sb12 (.in(in_state[31:24]), .out(s12));
aes_sbox sb13 (.in(in_state[23:16]), .out(s13));
aes_sbox sb14 (.in(in_state[15:8]), .out(s14));
aes_sbox sb15 (.in(in_state[7:0]), .out(s15));

assign out_state = {
    s0,s1,s2,s3,
    s4,s5,s6,s7,
    s8,s9,s10,s11,
    s12,s13,s14,s15
};

endmodule
