/*
    This file was generated automatically by Alchitry Labs 2.0.36-BETA.
    Do not edit this file directly. Instead edit the original Lucid source.
    This is a temporary file and any changes made to it will be destroyed.
*/

module greeter (
        input wire clk,
        input wire rst,
        input wire new_rx,
        input wire [7:0] rx_data,
        output reg new_tx,
        output reg [7:0] tx_data,
        input wire tx_busy
    );
    localparam NUM_LETTERS = 4'he;
    localparam E_States_IDLE = 1'h0;
    localparam E_States_GREET = 1'h1;
    logic [0:0] D_state_d, D_state_q = 0;
    logic [3:0] D_count_d, D_count_q = 0;
    logic [3:0] M_rom_address;
    logic [7:0] M_rom_letter;
    
    hello_world_rom rom (
        .address(M_rom_address),
        .letter(M_rom_letter)
    );
    
    
    always @* begin
        D_count_d = D_count_q;
        D_state_d = D_state_q;
        
        M_rom_address = D_count_q;
        tx_data = M_rom_letter;
        new_tx = 1'h0;
        
        case (D_state_q)
            1'h0: begin
                D_count_d = 1'h0;
                if (new_rx && rx_data == 8'h68) begin
                    D_state_d = 1'h1;
                end
            end
            1'h1: begin
                if (!tx_busy) begin
                    D_count_d = (($bits(D_count_q) > $bits(1'h1) ? $bits(D_count_q) : $bits(1'h1)) + 1)'(D_count_q + 1'h1);
                    new_tx = 1'h1;
                    if (D_count_q == 5'hd) begin
                        D_state_d = 1'h0;
                    end
                end
            end
        endcase
    end
    
    
    always @(posedge (clk)) begin
        if ((rst) == 1'b1) begin
            D_state_q <= 0;
        end else begin
            D_state_q <= D_state_d;
        end
    end
    always @(posedge (clk)) begin
        D_count_q <= D_count_d;
        
    end
endmodule