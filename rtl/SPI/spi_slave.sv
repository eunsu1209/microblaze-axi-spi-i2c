`timescale 1ns / 1ps

module spi_slave (
    input logic clk,
    input logic reset,
    input logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic done,
    output logic busy,

    input  logic sclk,
    input  logic mosi,
    output logic miso,
    input  logic cs_n
);

    // [동기화 로직]
    logic [2:0] sclk_sync;
    logic [2:0] cs_n_sync;
    logic [1:0] mosi_sync;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_sync <= 3'b000;
            cs_n_sync <= 3'b111;
            mosi_sync <= 2'b00;
        end else begin
            sclk_sync <= {sclk_sync[1:0], sclk};
            cs_n_sync <= {cs_n_sync[1:0], cs_n};
            mosi_sync <= {mosi_sync[0], mosi};
        end
    end

    wire sclk_rise = (sclk_sync[2:1] == 2'b01);
    wire sclk_fall = (sclk_sync[2:1] == 2'b10);
    wire cs_n_fall = (cs_n_sync[2:1] == 2'b10);
    wire cs_n_rise = (cs_n_sync[2:1] == 2'b01);
    wire cs_n_active = ~cs_n_sync[1];
    wire mosi_in = mosi_sync[1];

    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [2:0] bit_cnt;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_shift_reg <= 8'd0;
            tx_shift_reg <= 8'd0;
            bit_cnt      <= 3'd7;
            rx_data      <= 8'd0;
            done         <= 1'b0;
            busy         <= 1'b0;
        end else begin
            done <= 1'b0;

            if (cs_n_fall) begin
                tx_shift_reg <= tx_data;
                bit_cnt      <= 3'd7;
                busy         <= 1'b1;
            end else if (cs_n_active) begin
                if (sclk_rise) begin
                    rx_shift_reg <= {rx_shift_reg[6:0], mosi_in};
                end

                if (sclk_fall) begin
                    if (bit_cnt == 3'd0) begin
                        done <= 1'b1;
                        rx_data <= rx_shift_reg;
                    end
                    bit_cnt <= bit_cnt - 3'd1;
                end
            end else if (cs_n_rise) begin
                busy <= 1'b0;
                done <= 1'b1;
                rx_data <= rx_shift_reg;
            end
        end
    end

    assign miso = cs_n_active ? tx_shift_reg[bit_cnt] : 1'bz;

endmodule
