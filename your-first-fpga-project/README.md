# your-first-fpga-project

[Alchitry Tutorial](https://alchitry.com/tutorials/your-first-fpga-project/)
[Local Backup](/reference/Your%20First%20FPGA%20Project.pdf)

## Purpose

Understand basic signal concepts by wiring up an LED to the Au's button

## Success

You will know the project is successful if you are able to simulate or enable, live, a single button press that lights an LED on your Alchitry board.

## The Work

Most of this project's code is the Alchitry boilerplate. The work is done on line 21:

```hdl
led = c{7h00, rst}      // connect rst to the first LED
```
