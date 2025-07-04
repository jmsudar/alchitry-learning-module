/*
    This file was generated automatically by Alchitry Labs 2.0.36-BETA.
    Do not edit this file directly. Instead edit the original Lucid source.
    This is a temporary file and any changes made to it will be destroyed.
*/

module alchitry_top (
        input wire clk,
        input wire rst_n,
        output reg [7:0] led,
        input wire usb_rx,
        output reg usb_tx
    );
    logic rst;
    localparam _MP_STAGES_170959040 = 3'h4;
    logic M_reset_cond_in;
    logic M_reset_cond_out;
    
    reset_conditioner #(
        .STAGES(_MP_STAGES_170959040)
    ) reset_cond (
        .clk(clk),
        .in(M_reset_cond_in),
        .out(M_reset_cond_out)
    );
    
    
    localparam _MP_CLK_FREQ_1691670203 = 27'h5f5e100;
    localparam _MP_BAUD_1691670203 = 20'hf4240;
    logic M_rx_rx;
    logic [7:0] M_rx_data;
    logic M_rx_new_data;
    
    uart_rx #(
        .CLK_FREQ(_MP_CLK_FREQ_1691670203),
        .BAUD(_MP_BAUD_1691670203)
    ) rx (
        .clk(clk),
        .rst(rst),
        .rx(M_rx_rx),
        .data(M_rx_data),
        .new_data(M_rx_new_data)
    );
    
    
    localparam _MP_CLK_FREQ_1986845297 = 27'h5f5e100;
    localparam _MP_BAUD_1986845297 = 20'hf4240;
    logic M_tx_tx;
    logic M_tx_block;
    logic M_tx_busy;
    logic [7:0] M_tx_data;
    logic M_tx_new_data;
    
    uart_tx #(
        .CLK_FREQ(_MP_CLK_FREQ_1986845297),
        .BAUD(_MP_BAUD_1986845297)
    ) tx (
        .clk(clk),
        .rst(rst),
        .tx(M_tx_tx),
        .block(M_tx_block),
        .busy(M_tx_busy),
        .data(M_tx_data),
        .new_data(M_tx_new_data)
    );
    
    
    logic M_greeter_new_rx;
    logic [7:0] M_greeter_rx_data;
    logic M_greeter_new_tx;
    logic [7:0] M_greeter_tx_data;
    logic M_greeter_tx_busy;
    
    greeter greeter (
        .clk(clk),
        .rst(rst),
        .new_rx(M_greeter_new_rx),
        .rx_data(M_greeter_rx_data),
        .new_tx(M_greeter_new_tx),
        .tx_data(M_greeter_tx_data),
        .tx_busy(M_greeter_tx_busy)
    );
    
    
    always @* begin
        M_reset_cond_in = ~rst_n;
        rst = M_reset_cond_out;
        led = 8'h0;
        M_rx_rx = usb_rx;
        usb_tx = M_tx_tx;
        M_greeter_new_rx = M_rx_new_data;
        M_greeter_rx_data = M_rx_data;
        M_tx_new_data = M_greeter_new_tx;
        M_tx_data = M_greeter_tx_data;
        M_greeter_tx_busy = M_tx_busy;
        M_tx_block = 1'h0;
    end
    
    
endmodule