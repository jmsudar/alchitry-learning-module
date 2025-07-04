# hello-your-name-here

[Alchitry Tutorial](https://alchitry.com/tutorials/hello-your-name-here/)
[Local Backup](/reference/Hello%20YOUR_NAME_HERE.pdf)

## Purpose

Extend the serial interface lesson from the previous module and learn to use RAM.

## Success

You are successful in this project if your board's serial interface receives input and replies echoes it back to you.

## The Work

To start, make a copy of the previous module, `roms-and-fsms`.

Then, add the `simple_ram` component from the library.

You can then delete `hello_world_rom.luc` as it's not needed, and instead you will make a significant number of changes to `greeter.luc`. I'm not going to go through all of these in detail because I won't do a good job, frankly. Please be sure to read the documentation.

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
    const HELLO_TEXT = $reverse("\r\nHello @!\r\n")
    const PROMPT_TEXT = $reverse("Please type your name: ")
    
    enum States {IDLE, PROMPT, LISTEN, HELLO} // our state machine

    .clk(clk) {
        .rst(rst) {
            dff state[$width(States)]
        }
        // we need our counters to be large enough to store all the indices of our text
        dff hello_count[$clog2($width(HELLO_TEXT, 0))]
        dff prompt_count[$clog2($width(PROMPT_TEXT, 0))]

        dff name_count[5] // 5 allows for 2^5 = 32 letters
        // we need our RAM to have an entry for every value of name_count
        simple_ram ram (#WIDTH(8), #ENTRIES($pow(2,$width(name_count.q))))
    }

    always {
        ram.address = name_count.q // use name_count as the address
        ram.write_data = 8hxx      // don't care
        ram.write_enable = 0       // read by default

        new_tx = 0                 // default to no new data
        tx_data = 8hxx             // don't care

        case (state.q) { // our FSM
            // IDLE: Reset everything and wait for a new byte.
            States.IDLE:
                hello_count.d = 0
                prompt_count.d = 0
                name_count.d = 0
                if (new_rx) // wait for any letter
                    state.d = States.PROMPT

            // PROMPT: Print out name prompt.
            States.PROMPT:
                if (!tx_busy) {
                    prompt_count.d = prompt_count.q + 1   // move to the next letter
                    new_tx = 1                            // send data
                    tx_data = PROMPT_TEXT[prompt_count.q] // send letter from PROMPT_TEXT
                    if (prompt_count.q == $width(PROMPT_TEXT, 0) - 1) // no more letters
                        state.d = States.LISTEN           // change states
                }

            // LISTEN: Listen to the user as they type his/her name.
            States.LISTEN:
                if (new_rx) { // wait for a new byte
                    ram.write_data = rx_data        // write the received letter to RAM
                    ram.write_enable = 1            // signal we want to write
                    name_count.d = name_count.q + 1 // increment the address

                    // We aren't checking tx_busy here that means if someone types super
                    // fast we could drop bytes. In practice this doesn't happen.
                    new_tx = rx_data != "\n" && rx_data != "\r" // only echo non-new line characters
                    tx_data = rx_data // echo text back so you can see what you type

                    // if we run out of space or they pressed enter
                    if (&name_count.q || rx_data == "\n" || rx_data == "\r") {
                        state.d = States.HELLO
                        name_count.d = 0 // reset name_count
                    }
                }

            // HELLO: Prints the hello text with the given name inserted
            States.HELLO:
                if (!tx_busy) { // wait for tx to not be busy
                    if (HELLO_TEXT[hello_count.q] != "@") {  // if we are not at the sentry
                        hello_count.d = hello_count.q + 1    // increment to next letter
                        new_tx = 1                           // new data to send
                        tx_data = HELLO_TEXT[hello_count.q]  // send the letter
                    } else {                                 // we are at the sentry
                        name_count.d = name_count.q + 1      // increment the name_count letter

                        if (ram.read_data != "\n" && ram.read_data != "\r") // if we are not at the end
                            new_tx = 1                                      // send data

                        tx_data = ram.read_data // send the letter from the RAM

                        // if we are at the end of the name or out of letters to send
                        if (ram.read_data == "\n" || ram.read_data == "\r" || &name_count.q) {
                            hello_count.d = hello_count.q + 1  // increment hello_count to pass the sentry
                        }
                    }

                    // if we have sent all of HELLO_TEXT
                    if (hello_count.q == $width(HELLO_TEXT, 0) - 1)
                        state.d = States.IDLE // return to IDLE
                }
        }
    }
}
```

