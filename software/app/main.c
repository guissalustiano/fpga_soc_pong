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

#define X_OFFSET TABLE_WIDTH/2
#define Y_OFFSET TABLE_HEIGHT/2

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
    int16_t rightPaddleDx, leftPaddleDx = 0;
    int16_t up, down, left, right = 0;

    while (1) {

        if (elapsed(&lastEvent, (CLOCK_FREQUENCY * UPDATE_PERIOD_IN_SECONDS))) {
            up = button_up_output_read();
            down = button_down_output_read();
            left = button_left_output_read();
            right = button_right_output_read();

            if (up) rightPaddleDx = 1;
            else if (down) rightPaddleDx = -1;
            else rightPaddleDx = 0;

            if (right) leftPaddleDx = 1;
            else if (left) leftPaddleDx = -1;
            else leftPaddleDx = 0;

            // control = getch();
            // if (control == 119) rightPaddleDx = 1; // w
            // else if (control == 115) rightPaddleDx = -1; // s
            // else rightPaddleDx = 0;

            update(&pong, rightPaddleDx, leftPaddleDx);
        }
    }
	return 0;
}

void draw(game pong) {
    drawer_cursor_right_py_write(pong.rightPaddle.y + Y_OFFSET);
    drawer_cursor_left_py_write(pong.leftPaddle.y + Y_OFFSET);

    drawer_ball_px_write(pong.ball.x + X_OFFSET);
    drawer_ball_py_write(pong.ball.y + Y_OFFSET);
}
