#include "SPI.h"

#define CLK_DIV_VAL 50

void SPI_Init() {
    SPI0->CONTROL = CLK_DIV_VAL;
}

uint8_t SPI_Transfer(uint8_t data) {
    SPI0->TX_DATA = data;
    SPI0->CONTROL = CLK_DIV_VAL | (1 << 10);
    while ((SPI0->STATUS & 0x01) == 0);

    SPI0->CONTROL = CLK_DIV_VAL;
    while ((SPI0->STATUS & 0x01) != 0);

    return (uint8_t)(SPI0->RX_DATA);
}
