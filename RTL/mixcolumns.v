`timescale 1ns/1ps
module mixcolumns(
    input [127:0] in_state,
    output [127:0] out_state
);

function [7:0] xtime;
    input [7:0] b;
    begin
        xtime = (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
    end
endfunction

function [31:0] mix_col;
    input [31:0] col;
    reg [7:0] b0,b1,b2,b3;
    begin
        b0 = col[31:24];
        b1 = col[23:16];
        b2 = col[15:8];
        b3 = col[7:0];

        mix_col[31:24] = xtime(b0) ^ (xtime(b1)^b1) ^ b2 ^ b3;
        mix_col[23:16] = b0 ^ xtime(b1) ^ (xtime(b2)^b2) ^ b3;
        mix_col[15:8] = b0 ^ b1 ^ xtime(b2) ^ (xtime(b3)^b3);
        mix_col[7:0] = (xtime(b0)^b0) ^ b1 ^ b2 ^ xtime(b3);
    end
endfunction

assign out_state = {
    mix_col(in_state[127:96]),
    mix_col(in_state[95:64]),
    mix_col(in_state[63:32]),
    mix_col(in_state[31:0])
};

endmodule
