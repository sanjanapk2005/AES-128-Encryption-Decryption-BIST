`timescale 1ns/1ps
module aes_bist (
    input clk,
    input reset,
    input bist_start,
    input [127:0] key,

    output reg bist_done,
    output reg bist_pass,
    output reg bist_fail,
    output [127:0] signature
);

reg aes_start;
reg lfsr_enable;
reg misr_enable;

reg [3:0] pattern_count;
reg [2:0] bist_state;

wire [127:0] lfsr_pattern;
wire [127:0] aes_ciphertext;
wire aes_done;


// Golden signature obtained from fault-free BIST
localparam [127:0] GOLDEN_SIGNATURE =
    128'h00E76DB577F60F0D194EC4F9A5455803;


// BIST states
localparam IDLE = 3'd0;
localparam START_AES = 3'd1;
localparam WAIT_AES = 3'd2;
localparam CAPTURE = 3'd3;
localparam NEXT_TEST = 3'd4;
localparam FINISH = 3'd5;


// LFSR
lfsr128 lfsr_inst (
    .clk(clk),
    .reset(reset),
    .enable(lfsr_enable),
    .pattern(lfsr_pattern)
);


// AES
aes_top aes_inst (
    .clk(clk),
    .reset(reset),
    .start(aes_start),
    .plaintext(lfsr_pattern),
    .key(key),
    .ciphertext(aes_ciphertext),
    .done(aes_done)
);


// MISR
misr128 misr_inst (
    .clk(clk),
    .reset(reset),
    .enable(misr_enable),
    .data_in(aes_ciphertext),
    .signature(signature)
);


// BIST controller
always @(posedge clk or posedge reset) begin

    if (reset) begin

        bist_state <= IDLE;
        pattern_count <= 4'd0;

        aes_start <= 1'b0;
        lfsr_enable <= 1'b0;
        misr_enable <= 1'b0;

        bist_done <= 1'b0;
        bist_pass <= 1'b0;
        bist_fail <= 1'b0;

    end

    else begin

        // Default control signals
        aes_start <= 1'b0;
        lfsr_enable <= 1'b0;
        misr_enable <= 1'b0;

        case (bist_state)

            IDLE: begin

                bist_done <= 1'b0;
                bist_pass <= 1'b0;
                bist_fail <= 1'b0;

                if (bist_start) begin
                    pattern_count <= 4'd0;
                    bist_state <= START_AES;
                end

            end


            START_AES: begin

                aes_start <= 1'b1;
                bist_state <= WAIT_AES;

            end


            WAIT_AES: begin

                if (aes_done) begin
                    bist_state <= CAPTURE;
                end

            end


            CAPTURE: begin

                misr_enable <= 1'b1;
                bist_state <= NEXT_TEST;

            end


            NEXT_TEST: begin

                if (pattern_count == 4'd7) begin
                    bist_state <= FINISH;
                end

                else begin

                    pattern_count <= pattern_count + 1'b1;
                    lfsr_enable <= 1'b1;
                    bist_state <= START_AES;

                end

            end


            FINISH: begin

                bist_done <= 1'b1;

                // Compare actual MISR signature
                // with golden signature
                if (signature == GOLDEN_SIGNATURE) begin
                    bist_pass <= 1'b1;
                    bist_fail <= 1'b0;

                    $display("=================================");
                    $display("AES BIST PASS");
                    $display("MISR SIGNATURE = %h", signature);
                    $display("=================================");

                end

                else begin
                    bist_pass <= 1'b0;
                    bist_fail <= 1'b1;

                    $display("=================================");
                    $display("AES BIST FAIL");
                    $display("EXPECTED = %h", GOLDEN_SIGNATURE);
                    $display("ACTUAL = %h", signature);
                    $display("=================================");

                end

                bist_state <= IDLE;

            end


            default: begin
                bist_state <= IDLE;
            end

        endcase

    end

end

endmodule
