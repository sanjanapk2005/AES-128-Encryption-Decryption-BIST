`timescale 1ns/1ps

module aes_bist_faultable (
    input clk,
    input reset,
    input bist_start,
    input inject_fault,
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
    wire [127:0] misr_data;
    wire aes_done;

    localparam [127:0] GOLDEN_SIGNATURE =
        128'h00E76DB577F60F0D194EC4F9A5455803;

    localparam IDLE = 0,
               START_AES = 1,
               WAIT_AES = 2,
               CAPTURE = 3,
               NEXT_TEST = 4,
               FINISH = 5;

    // Fault injection before the MISR
    assign misr_data = inject_fault
                     ? (aes_ciphertext ^ 128'h1)
                     : aes_ciphertext;

    // LFSR test-pattern generator
    lfsr128 lfsr_inst (
        .clk(clk),
        .reset(reset),
        .enable(lfsr_enable),
        .pattern(lfsr_pattern)
    );

    // AES-128 encryption core
    aes_top aes_inst (
        .clk(clk),
        .reset(reset),
        .start(aes_start),
        .plaintext(lfsr_pattern),
        .key(key),
        .ciphertext(aes_ciphertext),
        .done(aes_done)
    );

    // MISR response compactor
    misr128 misr_inst (
        .clk(clk),
        .reset(reset),
        .enable(misr_enable),
        .data_in(misr_data),
        .signature(signature)
    );

    // BIST controller
    always @(posedge clk or posedge reset) begin

        if (reset) begin
            bist_state <= IDLE;
            pattern_count <= 0;

            aes_start <= 0;
            lfsr_enable <= 0;
            misr_enable <= 0;

            bist_done <= 0;
            bist_pass <= 0;
            bist_fail <= 0;
        end
        else begin

            aes_start <= 0;
            lfsr_enable <= 0;
            misr_enable <= 0;

            case (bist_state)

                IDLE: begin
                    bist_done <= 0;
                    bist_pass <= 0;
                    bist_fail <= 0;

                    if (bist_start) begin
                        pattern_count <= 0;
                        bist_state <= START_AES;
                    end
                end

                START_AES: begin
                    aes_start <= 1;
                    bist_state <= WAIT_AES;
                end

                WAIT_AES: begin
                    if (aes_done)
                        bist_state <= CAPTURE;
                end

                CAPTURE: begin
                    misr_enable <= 1;
                    bist_state <= NEXT_TEST;
                end

                NEXT_TEST: begin
                    if (pattern_count == 4'd7) begin
                        bist_state <= FINISH;
                    end
                    else begin
                        pattern_count <= pattern_count + 1'b1;
                        lfsr_enable <= 1;
                        bist_state <= START_AES;
                    end
                end

                FINISH: begin
                    bist_done <= 1;

                    if (signature == GOLDEN_SIGNATURE) begin
                        bist_pass <= 1;
                        bist_fail <= 0;

                        $display("AES BIST PASS");
                        $display("MISR SIGNATURE = %032h",
                                 signature);
                    end
                    else begin
                        bist_pass <= 0;
                        bist_fail <= 1;

                        $display("AES BIST FAIL");
                        $display("EXPECTED = %032h",
                                 GOLDEN_SIGNATURE);
                        $display("ACTUAL = %032h",
                                 signature);
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

