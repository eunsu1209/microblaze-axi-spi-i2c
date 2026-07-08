#include "ap_main.h"
#include "../driver/BTN/BTN.h"
#include "../driver/LED/LED.h"
#include "../HAL/SPI/SPI.h"
#include "interrupt.h"


hBtn_t btn_up;
hLed_t leds[8];
uint8_t up_count = 0;

void ap_init() {

    Button_Init(&btn_up, GPIOA, GPIO_PIN_0);
    for(int i=0; i<8; i++) {
        LED_Init(&leds[i], GPIOB, (1 << i));
    }


    SPI_Init();

    SetUpInterruptSystem();
    TMR_SetPSC(TMR0, 0);
    TMR_SetARR(TMR0, 99999);
    TMR_StartIntr(TMR0);
    TMR_StartTimer(TMR0);
}

void ap_main() {
    ap_init();

    while(1) {

        if (Button_GetState(&btn_up) == ACT_PUSHED) {

            up_count++;

            uint8_t slave_sw = SPI_Transfer(up_count);

            for(int i=0; i<8; i++) {
                if((slave_sw >> i) & 0x01) LED_On(&leds[i]);
                else LED_Off(&leds[i]);
            }
        }
    }
}
