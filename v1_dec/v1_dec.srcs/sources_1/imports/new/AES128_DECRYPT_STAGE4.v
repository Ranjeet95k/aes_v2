`timescale 1ns / 1ps

module AES128_DECRYPT_STAGE4(
    input clk,
    input [127:0] IN_DATA,
    input [127:0] IN_KEY,
    output reg [127:0] OUT_DATA
);

// ================= KEY PIPELINE =================

wire [127:0] dummy = 128'd0;

wire [127:0] R0_w,R1_w,R2_w,R3_w,R4_w,R5_w,R6_w,R7_w,R8_w,R9_w;
wire [127:0] K0_w,K1_w,K2_w,K3_w,K4_w,K5_w,K6_w,K7_w,K8_w,K9_w;

reg [127:0] R0_q,R1_q,R2_q,R3_q,R4_q,R5_q,R6_q,R7_q,R8_q,R9_q;
reg [127:0] K0_q,K1_q,K2_q,K3_q,K4_q,K5_q,K6_q,K7_q,K8_q,K9_q;
reg [127:0] cipher_q;

wire [127:0] perm_key, perm_key1;

SUB_BYTES s1(.clk(clk), .IN_DATA(IN_KEY), .SB_DATA(perm_key));
KEY_MODIFY_PART k1(.clk(clk), .IN_KEY(perm_key), .KEY_OUT(perm_key1));

assign R0_w = dummy ^ perm_key1;
assign K0_w = perm_key1;

// Forward rounds (key generation)
ROUND_ITERATION R1_gen(.clk(clk), .ROUND_KEY(4'd0), .IN_DATA(R0_q), .IN_KEY(K0_q), .OUT_KEY(K1_w), .OUT_DATA(R1_w));
ROUND_ITERATION R2_gen(.clk(clk), .ROUND_KEY(4'd1), .IN_DATA(R1_q), .IN_KEY(K1_q), .OUT_KEY(K2_w), .OUT_DATA(R2_w));
ROUND_ITERATION R3_gen(.clk(clk), .ROUND_KEY(4'd2), .IN_DATA(R2_q), .IN_KEY(K2_q), .OUT_KEY(K3_w), .OUT_DATA(R3_w));
ROUND_ITERATION R4_gen(.clk(clk), .ROUND_KEY(4'd3), .IN_DATA(R3_q), .IN_KEY(K3_q), .OUT_KEY(K4_w), .OUT_DATA(R4_w));
ROUND_ITERATION R5_gen(.clk(clk), .ROUND_KEY(4'd4), .IN_DATA(R4_q), .IN_KEY(K4_q), .OUT_KEY(K5_w), .OUT_DATA(R5_w));
ROUND_ITERATION R6_gen(.clk(clk), .ROUND_KEY(4'd5), .IN_DATA(R5_q), .IN_KEY(K5_q), .OUT_KEY(K6_w), .OUT_DATA(R6_w));
ROUND_ITERATION R7_gen(.clk(clk), .ROUND_KEY(4'd6), .IN_DATA(R6_q), .IN_KEY(K6_q), .OUT_KEY(K7_w), .OUT_DATA(R7_w));
ROUND_ITERATION R8_gen(.clk(clk), .ROUND_KEY(4'd7), .IN_DATA(R7_q), .IN_KEY(K7_q), .OUT_KEY(K8_w), .OUT_DATA(R8_w));
ROUND_ITERATION R9_gen(.clk(clk), .ROUND_KEY(4'd8), .IN_DATA(R8_q), .IN_KEY(K8_q), .OUT_KEY(K9_w), .OUT_DATA(R9_w));

// ================= DECRYPT =================

wire [127:0] R9_d_w,R8_d_w,R7_d_w,R6_d_w,R5_d_w,R4_d_w,R3_d_w,R2_d_w,R1_d_w,R0_d_w;
reg [127:0] R9_d_q,R8_d_q,R7_d_q,R6_d_q,R5_d_q,R4_d_q,R3_d_q,R2_d_q,R1_d_q,R0_d_q;

// Last round
INV_LAST_ROUND INV_R10(
    .clk(clk),
    .ROUND_KEY(4'd9),
    .IN_DATA(cipher_q),
    .IN_KEY(K9_q),
    .OUT_DATA(R9_d_w)
);

// Inverse rounds
INV_ROUND_ITERATION_updated INV_R9(.clk(clk), .ROUND_KEY(4'd8), .IN_DATA(R9_d_q), .IN_KEY(K8_q), .OUT_DATA(R8_d_w));
INV_ROUND_ITERATION_updated INV_R8(.clk(clk), .ROUND_KEY(4'd7), .IN_DATA(R8_d_q), .IN_KEY(K7_q), .OUT_DATA(R7_d_w));
INV_ROUND_ITERATION_updated INV_R7(.clk(clk), .ROUND_KEY(4'd6), .IN_DATA(R7_d_q), .IN_KEY(K6_q), .OUT_DATA(R6_d_w));
INV_ROUND_ITERATION_updated INV_R6(.clk(clk), .ROUND_KEY(4'd5), .IN_DATA(R6_d_q), .IN_KEY(K5_q), .OUT_DATA(R5_d_w));
INV_ROUND_ITERATION_updated INV_R5(.clk(clk), .ROUND_KEY(4'd4), .IN_DATA(R5_d_q), .IN_KEY(K4_q), .OUT_DATA(R4_d_w));
INV_ROUND_ITERATION_updated INV_R4(.clk(clk), .ROUND_KEY(4'd3), .IN_DATA(R4_d_q), .IN_KEY(K3_q), .OUT_DATA(R3_d_w));
INV_ROUND_ITERATION_updated INV_R3(.clk(clk), .ROUND_KEY(4'd2), .IN_DATA(R3_d_q), .IN_KEY(K2_q), .OUT_DATA(R2_d_w));
INV_ROUND_ITERATION_updated INV_R2(.clk(clk), .ROUND_KEY(4'd1), .IN_DATA(R2_d_q), .IN_KEY(K1_q), .OUT_DATA(R1_d_w));
INV_ROUND_ITERATION_updated INV_R1(.clk(clk), .ROUND_KEY(4'd0), .IN_DATA(R1_d_q), .IN_KEY(K0_q), .OUT_DATA(R0_d_w));

// Register every inter-round boundary to break the long AES critical path.
always @(posedge clk) begin
    cipher_q <= IN_DATA;

    R0_q <= R0_w;
    K0_q <= K0_w;
    R1_q <= R1_w;
    K1_q <= K1_w;
    R2_q <= R2_w;
    K2_q <= K2_w;
    R3_q <= R3_w;
    K3_q <= K3_w;
    R4_q <= R4_w;
    K4_q <= K4_w;
    R5_q <= R5_w;
    K5_q <= K5_w;
    R6_q <= R6_w;
    K6_q <= K6_w;
    R7_q <= R7_w;
    K7_q <= K7_w;
    R8_q <= R8_w;
    K8_q <= K8_w;
    R9_q <= R9_w;
    K9_q <= K9_w;

    R9_d_q <= R9_d_w;
    R8_d_q <= R8_d_w;
    R7_d_q <= R7_d_w;
    R6_d_q <= R6_d_w;
    R5_d_q <= R5_d_w;
    R4_d_q <= R4_d_w;
    R3_d_q <= R3_d_w;
    R2_d_q <= R2_d_w;
    R1_d_q <= R1_d_w;
    R0_d_q <= R0_d_w;

    OUT_DATA <= R0_d_q ^ K0_q;
end

endmodule
