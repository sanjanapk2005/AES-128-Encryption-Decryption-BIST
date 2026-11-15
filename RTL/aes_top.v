`timescale 1ns/1ps

module aes_top(
    input clk,
    input reset,
    input start,
    input [127:0] plaintext,
    input [127:0] key,
    output reg [127:0] ciphertext,
    output reg done
);

reg [127:0] state;
reg [3:0] round;       // 0..10, tracks which round_key to fetch
reg [1:0] fsm_state;   // 0=idle, 1=initial whiten, 2=main rounds, 3=final round

localparam IDLE   = 2'd0;
localparam INIT   = 2'd1;
localparam ROUNDS = 2'd2;
localparam FINAL  = 2'd3;

wire [127:0] round_key;
wire [127:0] subbytes_out;
wire [127:0] shiftrows_out;
wire [127:0] mixcolumns_out;
wire [127:0] ark_main_out;   // AddRoundKey after MixColumns (rounds 1-9)
wire [127:0] ark_final_out;  // AddRoundKey after ShiftRows only (round 10)
wire [127:0] ark_init_out;   // initial AddRoundKey (round 0)

key_expansion ke (
    .key(key),
    .round(round),
    .round_key(round_key)
);

// initial whitening: plaintext ^ round_key(0)
addroundkey ark_init (
    .state(state),
    .round_key(round_key),
    .out(ark_init_out)
);

subbytes sb (
    .in_state(state),
    .out_state(subbytes_out)
);

shiftrows sr (
    .in_state(subbytes_out),
    .out_state(shiftrows_out)
);

mixcolumns mc (
    .in_state(shiftrows_out),
    .out_state(mixcolumns_out)
);

addroundkey ark_main (
    .state(mixcolumns_out),
    .round_key(round_key),
    .out(ark_main_out)
);

addroundkey ark_final (
    .state(shiftrows_out),
    .round_key(round_key),
    .out(ark_final_out)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state      <= 128'd0;
        ciphertext <= 128'd0;
        round      <= 4'd0;
        done       <= 1'b0;
        fsm_state  <= IDLE;
    end
    else begin
        case (fsm_state)
            IDLE: begin
                done <= 1'b0;
                if (start) begin
                    state     <= plaintext;
                    round     <= 4'd0;
                    fsm_state <= INIT;
                end
            end

            // state <= plaintext ^ round_key(0)
            INIT: begin
                state     <= ark_init_out;
                round     <= 4'd1;
                fsm_state <= ROUNDS;
            end

            // rounds 1-9: SubBytes -> ShiftRows -> MixColumns -> AddRoundKey(round)
            ROUNDS: begin
                state <= ark_main_out;
                if (round == 4'd9)
                    fsm_state <= FINAL;
                else
                    round <= round + 1'b1;
                if (round == 4'd9)
                    round <= 4'd10;
            end

            // round 10: SubBytes -> ShiftRows -> AddRoundKey(10)  (no MixColumns)
            FINAL: begin
                ciphertext <= ark_final_out;
                done       <= 1'b1;
                fsm_state  <= IDLE;
            end
        endcase
    end
end

endmodule
