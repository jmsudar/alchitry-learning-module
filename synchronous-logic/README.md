# led-blink

[Alchitry Tutorial](https://alchitry.com/tutorials/synchronous-logic/)
[Local Backup](/reference/Synchronous%20Logic.pdf)

## Purpose

Understand D-flip flops and fundamentals of synchronous logic

## Success

You will know the project is successful if you are able to simulate or blink an LED on your FPGA or in the simulator.

This project does not work properly in the simulator without some changes detailed in the instructions. At a glance, you can tell these specific changes with the `$is_sim()` assessment.

## The Work

For this project, you create a new module called blinker.

```hdl
module blinker (
    input clk,   // clock
    input rst,   // reset
    output blink // output to LED
) {
    
    dff counter[$is_sim() ? 9 : 25](.clk(clk), .rst(rst))
    
    always {
        blink = counter.q[$is_sim() ? 8 : 24]
        counter.d = counter.q + 1
    }
}
```

And then you include this in your `alchitry_top.luc` file on lines 17

```hdl
blinker my_blinker
```

and use it on line 25

```hdl
led = 8x{my_blinker.blink} // blink LEDs
```