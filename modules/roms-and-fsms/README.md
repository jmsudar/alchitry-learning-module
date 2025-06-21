# roms-and-fsms

[Alchitry Tutorial](https://alchitry.com/tutorials/roms-and-fsms/)
[Local Backup](/reference/ROMs%20and%20FSMs.pdf)

## Purpose

Understand how serial input and output work with more complex return targets.

This, in my opinion, is one of the most important lessons in this learning module. Serial input and output is core to electronics and computers. The difference in how electronics process serial data vs. how computers abstract it is striking and important to learn.

## Success

You are successful in this project if your board's serial interface receives input and replies with `Hello, World!`.

## The Work

This uses the base project and two elements from the component library: `UART Rx` and `UART Tx`, like the previous one.

We will also add two modules. The first is ROM:

```hdl
module hello_world_rom (
    input address[4], // ROM address
    output letter[8]  // ROM output
) {
    
    const TEXT = "\r\n!dlroW ,olleH" // text is reversed to make 'H' address [0]
    
    always {
        letter = TEXT[address] // address indexes 8 bit blocks of TEXT
    }
}
```

And the second is interactive and consumes this ROM.

```hdl
module greeter (
    input clk,         // clock
    input rst,         // reset
    input new_rx,      // new RX flag
    input rx_data[8],  // RX data
    output new_tx,     // new TX flag
    output tx_data[8], // TX data
    input tx_busy      // TX is busy flag
) {
    const NUM_LETTERS = 14
    
    enum States {IDLE, GREET}
    
    .clk(clk) {
        .rst(rst) {
            dff state[$width(States)]
        }
        dff count[$clog2(NUM_LETTERS)] // min bits to store NUM_LETTERS - 1
    }
    
    hello_world_rom rom
    
    always {
        rom.address = count.q
        tx_data = rom.letter
        
        new_tx = 0 // default to 0
        
        case (state.q) {
            States.IDLE:
                count.d = 0
                if (new_rx && rx_data == "h")
                    state.d = States.GREET
            
            States.GREET:
                if (!tx_busy) {
                    count.d = count.q + 1
                    new_tx = 1
                    if (count.q == NUM_LETTERS - 1)
                        state.d = States.IDLE
                }
        }
    }
}
```

Then finally you use all of this by wiring up the components and adding your greeter (note that the `#BAUD` declaration is using syntactic sugar to shorten the declarations compared to the previous module).

```hdl
.rst(rst) {
    #BAUD(1_000_000), #CLK_FREQ(100_000_000) {
        uart_rx rx
        uart_tx tx
    }
    
    greeter greeter
}    
```

And you include your behavior 