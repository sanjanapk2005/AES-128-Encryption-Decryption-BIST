`timescale 1ns/1ps

module aes_decrypt (
    input clk,
    input reset,
    input start,
    input [127:0] ciphertext,
    input [127:0] key,

    output reg [127:0] plaintext,
    output reg done
);

    reg [127:0] state;
    reg [3:0] round;
    reg [1:0] phase;

    localparam IDLE = 2'd0;
    localparam INITIAL_KEY = 2'd1;
    localparam MAIN_ROUNDS = 2'd2;
    localparam FINAL_ROUND = 2'd3;

    wire [127:0] round_key;
    wire [127:0] shifted_state;
    wire [127:0] sub_state;
    wire [127:0] key_state;
    wire [127:0] mixed_state;

    // AES-128 round-key generation
    key_expansion ke (
        .key(key),
        .round(round),
        .round_key(round_key)
    );

    // Inverse ShiftRows
    inv_shiftrows isr (
        .in_state(state),
        .out_state(shifted_state)
    );

    // Inverse SubBytes
    inv_subbytes isb (
        .in_state(shifted_state),
        .out_state(sub_state)
    );

    // AddRoundKey: port name corrected to match addroundkey.v
    addroundkey ark (
        .state(sub_state),
        .round_key(round_key),
        .out(key_state)
    );

    // Inverse MixColumns
    inv_mixcolumns imc (
        .in_state(key_state),
        .out_state(mixed_state)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 128'b0;
            round <= 4'd0;
            plaintext <= 128'b0;
            done <= 1'b0;
            phase <= IDLE;
        end
        else begin
            done <= 1'b0;

            case (phase)

                IDLE: begin
                    if (start) begin
                        state <= ciphertext;
                        round <= 4'd10;
                        phase <= INITIAL_KEY;
                    end
                end

                // Initial AddRoundKey using round key 10
                INITIAL_KEY: begin
                    state <= state ^ round_key;
                    round <= 4'd9;
                    phase <= MAIN_ROUNDS;
                end

                // Inverse rounds 9 through 1
                MAIN_ROUNDS: begin
                    state <= mixed_state;

                    if (round == 4'd1) begin
                        round <= 4'd0;
                        phase <= FINAL_ROUND;
                    end
                    else begin
                        round <= round - 1'b1;
                    end
                end

                // Final round: no InvMixColumns
                FINAL_ROUND: begin
                    plaintext <= key_state;
                    done <= 1'b1;
                    phase <= IDLE;
                end

                default: begin
                    phase <= IDLE;
                end

            endcase
        end
    end

endmodule

