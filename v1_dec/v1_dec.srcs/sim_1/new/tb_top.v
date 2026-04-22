`timescale 1ns/1ps

module tb_top;

reg clk = 0;
reg rst = 0;
reg rx  = 1;
wire tx;

// Clock (100 MHz)
always #5 clk = ~clk;

// DUT
top_aes_uart DUT (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .tx(tx)
);

// =====================================================
// UART SEND TASK
// =====================================================
task send_byte(input [7:0] data);
    integer i;
    begin
        rx = 1; #160;        // idle

        rx = 0; #160;        // start bit

        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];    // LSB first
            #160;
        end

        rx = 1; #160;        // stop bit
    end
endtask

// =====================================================
// TEST DATA
// =====================================================
integer i;

reg [7:0] cipher [0:15];
reg [7:0] key [0:15];

initial begin

    // Reset
    rst = 1;
    #100;
    rst = 0;

    // ================= CIPHER (YOUR VECTOR) =================
    cipher[0]=8'h31; cipher[1]=8'h96; cipher[2]=8'hde; cipher[3]=8'h4d;
    cipher[4]=8'h67; cipher[5]=8'h2d; cipher[6]=8'h06; cipher[7]=8'ha0;
    cipher[8]=8'hd5; cipher[9]=8'h2d; cipher[10]=8'h94; cipher[11]=8'h7a;
    cipher[12]=8'he3; cipher[13]=8'hee; cipher[14]=8'ha7; cipher[15]=8'h89;

    // ================= KEY =================
    key[0]=8'h00; key[1]=8'h01; key[2]=8'h02; key[3]=8'h03;
    key[4]=8'h04; key[5]=8'h05; key[6]=8'h06; key[7]=8'h07;
    key[8]=8'h08; key[9]=8'h09; key[10]=8'h0a; key[11]=8'h0b;
    key[12]=8'h0c; key[13]=8'h0d; key[14]=8'h0e; key[15]=8'h0f;

    #1000;

    // ================= SEND CIPHER =================
    for (i = 0; i < 16; i = i + 1) begin
        send_byte(cipher[i]);
        #200;
    end

    // ================= SEND KEY =================
    for (i = 0; i < 16; i = i + 1) begin
        send_byte(key[i]);
        #200;
    end

    // ================= WAIT =================
    #1500000;

    // ================= RESULT =================
    $display("\n=========== FINAL RESULT ===========");
    $display("DATA (Cipher) = %h", DUT.data_reg);
    $display("KEY           = %h", DUT.key_reg);
    $display("AES OUTPUT    = %h", DUT.aes_out);

    if (DUT.aes_out == 128'h4142434445464748494a4b4c4d4e4f54)
        $display(" DECRYPTION SUCCESS");
    else
        $display(" DECRYPTION FAILED");

    $display("====================================\n");

    $finish;
end

endmodule