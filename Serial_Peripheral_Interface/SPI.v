module spi #(parameter N = 4, parameter cpol = 0, parameter cpha = 0)
(
    input clk, // clk of the system
    input start,
    input [11:0] din,
    input [N-1 : 0] which_slave_enabled,
    output reg [N-1 : 0] cs, // enable of the master to send data to the slave in active low
    output reg mosi,
    output reg done,
    output reg [11:0] bits_sent,   // Register to track bits sent
    output sclk // clk of the master
);

    // Generate the clock of the master to be 100MHz
    integer count = 0;
    reg sclkt;

    generate
        if (cpol) begin
            initial sclkt = 1;
        end else begin
            initial sclkt = 0;
        end
    endgenerate

    always @(posedge clk) begin
        if (count < 5)
            count <= count + 1;
        else begin
            count  <= 0;
            sclkt  <= ~sclkt;
        end
    end

    /////////////////////////////////////
    localparam idle = 0, start_tx = 1, send = 2, end_tx = 3; 
    reg [1:0] state = idle;
    reg [11:0] temp;
    integer bitcount = 0;

    generate
        if (!cpha) begin
            always @(posedge sclkt) begin
                case(state)
                    idle: begin
                        mosi <= 1'b0;
                        temp <= 12'h000;
                        cs <= {N{1'b1}};
                        done <= 1'b0; // no data transmitted
                        bits_sent <= 12'h000; // Initialize bits_sent
                        if (start)
                            state <= start_tx;
                        else
                            state <= idle;
                    end

                    start_tx: begin
                        case (which_slave_enabled)
                            4'b0001: begin
                                mosi <= 1'b1;
                                cs <= 4'b1110;
                            end
                            4'b0010: begin
                                mosi <= 1'b1;
                                cs <= 4'b1101;
                            end
                            4'b0100: begin
                                mosi <= 1'b1;
                                cs <= 4'b1011;
                            end
                            4'b1000: begin
                                mosi <= 1'b1;
                                cs <= 4'b0111;
                            end
                        endcase
                        temp <= din;
                        bits_sent <= din; // Set bits_sent to the input data
                        state <= send;
                    end

                    send: begin
                        if (bitcount <= 11) begin
                            bitcount <= bitcount + 1;
                            mosi <= temp[bitcount];
                            bits_sent[bitcount] <= mosi;
                            state <= send;
                        end else begin
                            bitcount <= 0;
                            state <= end_tx;
                            mosi <= 1'b0;
                        end
                    end

                    end_tx: begin
                        cs <= {N{1'b1}};
                        done <= 1'b1;                    
                        state <= idle;
                    end

                    default: state <= idle;
                endcase
            end
        end else begin
            always @(negedge sclkt) begin
                case(state)
                                idle: begin
                                    mosi <= 1'b0;
                                    temp <= 12'h000;
                                    cs <= {N{1'b1}};
                                    done <= 1'b0; // no data transmitted
                                    bits_sent <= 12'h000; // Initialize bits_sent
                                    if (start)
                                        state <= start_tx;
                                    else
                                        state <= idle;
                                end
            
                                start_tx: begin
                                    case (which_slave_enabled)
                                        4'b0001: begin
                                            mosi <= 1'b1;
                                            cs <= 4'b1110;
                                        end
                                        4'b0010: begin
                                            mosi <= 1'b1;
                                            cs <= 4'b1101;
                                        end
                                        4'b0100: begin
                                            mosi <= 1'b1;
                                            cs <= 4'b1011;
                                        end
                                        4'b1000: begin
                                            mosi <= 1'b1;
                                            cs <= 4'b0111;
                                        end
                                    endcase
                                    temp <= din;
                                    bits_sent <= din; // Set bits_sent to the input data
                                    state <= send;
                                end
            
                                send: begin
                                    if (bitcount <= 11) begin
                                        bitcount <= bitcount + 1;
                                        mosi <= temp[bitcount];
                                        bits_sent[bitcount] <= mosi;
                                        state <= send;
                                    end else begin
                                        bitcount <= 0;
                                        state <= end_tx;
                                        mosi <= 1'b0;
                                    end
                                end
            
                                end_tx: begin
                                    cs <= {N{1'b1}};
                                    done <= 1'b1;                    
                                    state <= idle;
                                end
            
                                default: state <= idle;
                            endcase
            end
        end
    endgenerate
    assign sclk = sclkt;
endmodule
