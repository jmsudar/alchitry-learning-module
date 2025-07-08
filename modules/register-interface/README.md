# register-interface

[Alchitry Tutorial](https://alchitry.com/tutorials/register-interface/)
[Local Backup](/reference/Register%20Interface.pdf)

## Purpose

Learn to use the register interface component.

## Success

You are successful in this project if you're able to control the LED banks with serial input.

## The Work

Start from a new base project.

Add the `Register Interface`, `UART Rx`, and `UART Tx` components fromt he component library.

To control the LEDs, you first have to add the block below to the restart block:

```hdl
.rst(rst) {
    dff led_reg[8]
    #CLK_FREQ(100_000_000) {
        register_interface reg
        #BAUD(1_000_000) {
            uart_rx rx
            uart_tx tx
        }
    }
}
```

Then you will connect your interfaces and put in an if block allowing for this interaction within the `always` block:

```hdl
always {
    reset_cond.in = ~rst_n  // input raw inverted reset signal
    rst = reset_cond.out    // conditioned reset
    
    led = led_reg.q
    
    usb_tx = tx.tx
    rx.rx = usb_rx
    
    reg.rx_data = rx.data
    reg.new_rx_data = rx.new_data
    tx.data = reg.tx_data
    tx.new_data = reg.new_tx_data
    reg.tx_busy = tx.busy
    tx.block = 0 // never block
    reg.reg_in = <Register.response>(.data(32bx), .drdy(0))
    
    if (reg.reg_out.new_cmd) {
        if (reg.reg_out.write) { // write
            if (reg.reg_out.address == 0) { // address matches
                led_reg.d = reg.reg_out.data[7:0] // update the value
            }
        } else { // read
            if (reg.reg_out.address == 0) { // address matches
                reg.reg_in.drdy = 1 // data ready
                reg.reg_in.data = led_reg.q // return the value
            }
        }
    }
}
```