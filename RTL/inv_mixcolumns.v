`timescale 1ns/1ps

module inv_mixcolumns (
    input [127:0] in_state,
    output [127:0] out_state
);

function [7:0] multiply;
    input [7:0] a;
    input [7:0] b;
    integer i;
    reg [7:0] temp;
    reg [7:0] result;
    begin
        temp = a;
        result = 8'h00;

        for (i = 0; i < 8; i = i + 1) begin
            if (b[i])
                result = result ^ temp;

            if (temp[7])
                temp = (temp << 1) ^ 8'h1B;
            else
                temp = temp << 1;
        end

        multiply = result;
    end
endfunction

function [31:0] inv_mix_column;
    input [31:0] column;
    reg [7:0] a, b, c, d;
    begin
        a = column[31:24];
        b = column[23:16];
        c = column[15:8];
        d = column[7:0];

        inv_mix_column[31:24] =
            multiply(a, 8'h0E) ^
            multiply(b, 8'h0B) ^
            multiply(c, 8'h0D) ^
            multiply(d, 8'h09);

        inv_mix_column[23:16] =
            multiply(a, 8'h09) ^
            multiply(b, 8'h0E) ^
            multiply(c, 8'h0B) ^
            multiply(d, 8'h0D);

        inv_mix_column[15:8] =
            multiply(a, 8'h0D) ^
            multiply(b, 8'h09) ^
            multiply(c, 8'h0E) ^
            multiply(d, 8'h0B);

        inv_mix_column[7:0] =
            multiply(a, 8'h0B) ^
            multiply(b, 8'h0D) ^
            multiply(c, 8'h09) ^
            multiply(d, 8'h0E);
    end
endfunction

assign out_state[127:96] =
    inv_mix_column(in_state[127:96]);

assign out_state[95:64] =
    inv_mix_column(in_state[95:64]);

assign out_state[63:32] =
    inv_mix_column(in_state[63:32]);

assign out_state[31:0] =
    inv_mix_column(in_state[31:0]);

endmodule

