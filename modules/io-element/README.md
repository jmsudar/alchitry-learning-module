# io-element

[Alchitry Tutorial](https://alchitry.com/tutorials/io-element/)
[Local Backup](/reference/Io%20Element.pdf)

## Purpose

Understand the Alchitry IO board.

## Success

You will know the project is successful if you are able to simulate or light a single LED on the board when flipping a dip switch.

As configured in this example, the 8th switch on switch bank 3 turns on the 8th light on LED bank 3.

## The Work

We use a different template board for this project, the IO base template. This gives us a ton of standard inputs and outputs as well as a `.alp` file for interacting with the board.

The behavior takes place on the last line of the `always` block, `io_led[0][0] = io_dip[0][0] & io_dip[0][0]`.

```hdl
module alchitry_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led[8],          // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx,          // USB->Serial output
    output io_led[3][8],    // LEDs on IO Shield
    output io_segment[8],   // 7-segment LEDs on IO Shield
    output io_select[4],    // Digit select on IO Shield
    input io_button[5],     // 5 buttons on IO Shield
    input io_dip[3][8]      // DIP switches on IO Shield
) {
    
    sig rst                 // reset signal
    
    .clk(clk) {
        // The reset conditioner is used to synchronize the reset signal to the FPGA
        // clock. This ensures the entire FPGA comes out of reset at the same time.
        reset_conditioner reset_cond
    }
    
    always {
        reset_cond.in = ~rst_n  // input raw inverted reset signal
        rst = reset_cond.out    // conditioned reset
        
        led = 8h00              // turn LEDs off
        
        usb_tx = usb_rx         // loop serial port
        
        io_led = 3x{{8h00}}
        io_segment = 8hff
        io_select = 4hf
        
        io_led[0][0] = io_dip[0][0] & io_dip[0][0]
    }
}
```