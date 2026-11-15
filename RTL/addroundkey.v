`timescale 1ns/1ps
module addroundkey(
    input [127:0] state,
    input [127:0] round_key,
    output [127:0] out
);

assign out = state ^ round_key;

endmodule
