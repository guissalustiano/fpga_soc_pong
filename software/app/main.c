// This file is Copyright (c) 2020 Florent Kermarrec <florent@enjoy-digital.fr>
// License: BSD

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <irq.h>
#include <libbase/uart.h>
#include <libbase/console.h>
#include <generated/csr.h>

#include "pong.h"
#include "time.h"

#define CLOCK_FREQUENCY 100e6
#define UPDATE_PERIOD_IN_SECONDS 1/60

int main(void)
{
#ifdef CONFIG_CPU_HAS_INTERRUPT
	irq_setmask(0);
	irq_setie(1);
#endif
	uart_init();
	game pong = start();
    time_init();

    int lastEvent = 0;
    uint8_t control = 0;
    int8_t rightPaddleDx = 0;

    while (1) {

        if (elapsed(&lastEvent, (CLOCK_FREQUENCY * UPDATE_PERIOD_IN_SECONDS))) {


            // control = getch();
            // if (control == 119) rightPaddleDx = 1; // w
            // else if (control == 115) rightPaddleDx = -1; // s
            // else rightPaddleDx = 0;

            update(&pong, rightPaddleDx, 0);
        }
    }
	return 0;
}
