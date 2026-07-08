/*
 * SPI.h
 *
 *  Created on: 2026. 5. 3.
 *      Author: kccistc
 */

#ifndef SRC_HAL_SPI_SPI_H_
#define SRC_HAL_SPI_SPI_H_

#include <stdint.h>
#include "xil_io.h"

typedef struct {
    volatile uint32_t CONTROL;
    volatile uint32_t TX_DATA;
    volatile uint32_t STATUS;
    volatile uint32_t RX_DATA;
} SPI_Typedef_t;


#define SPI0_BASE_ADDR 0x44A10000
#define SPI0 ((SPI_Typedef_t*)SPI0_BASE_ADDR)

void SPI_Init();
uint8_t SPI_Transfer(uint8_t data);

#endif
