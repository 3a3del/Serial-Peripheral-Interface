`timescale 1ns / 1ps

module spi_tb;

    reg clk;
    reg start;
    reg [11:0] din;
    reg [3:0] which_slave_enabled;
    wire [3:0] cs;
    wire mosi;
    wire done;
    wire sclk;
    wire [11:0] bits_sent;

    // Instantiate the SPI module
    spi #( .N(4), .cpol(0), .cpha(0) ) dut (
        .clk(clk),
        .start(start),
        .din(din),
        .which_slave_enabled(which_slave_enabled),
        .cs(cs),
        .mosi(mosi),
        .done(done),
        .bits_sent(bits_sent),
        .sclk(sclk)
    );
integer i =0;
    // Clock generation
    initial begin
        clk = 0;
        start = 0;
        din = 12'h000; // Example data to be transmitted
        which_slave_enabled = 4'b0000;
    end

always #5 clk <= ~clk;

    // Stimulus
    initial begin
        for(i=0 ; i<=10 ; i=i+1) begin
        #10 start = 1;
        din = $random ; // Example data to be transmitted
            case (i % 4) 
            0: which_slave_enabled = 4'b0001;
            1: which_slave_enabled = 4'b0010;
            2: which_slave_enabled = 4'b0100;
            3: which_slave_enabled = 4'b1000;
            endcase
        wait(done);
         display;
         start = 0;
         end
        $stop;
    end

    task display;
        $display("Time: %0t, Start: %b, DIN: %h, CS: %b, MOSI: %b, Done: %b, SCLK: %b, Which Slave: %b ",
                 $time, start, din, cs, mosi, done, sclk,which_slave_enabled);
    endtask

endmodule

