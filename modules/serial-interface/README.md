# serial-interface

[Alchitry Tutorial](https://alchitry.com/tutorials/serial-interface/)
[Local Backup](/reference/Serial%20Interface.pdf)

## Purpose

Understand serial input and output.

## Success

You are successful in this project if your board's serial interface receives input and echoes it back.

## The Work

This uses the base project and two elements from the component library: `UART Rx` and `UART Tx`.

You implement these interfaces in the reset block: 

```hdl
uart_rx rx(#BAUD(1_000_000), #CLK_FREQ(100_000_000))
uart_tx tx(#BAUD(1_000_000), #CLK_FREQ(100_000_000))
```

Then, you set a D-flip flop to store the last character with `dff data[8]`, and set your echo command in the always block:

```hdl
tx.new_data = rx.new_data
tx.data = rx.data
tx.block = 0            // no flow control, do not block

if (rx.new_data) {      // new byte received
    data.d = rx.data    // save it
}

led = data.q            // output the data
```