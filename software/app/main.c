// This file is Copyright (c) 2020 Florent Kermarrec <florent@enjoy-digital.fr>
// License: BSD

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <generated/csr.h>
#include <irq.h>
#include <libbase/console.h>
#include <libbase/uart.h>

#include "pong.h"
#include "time.h"

#define CLOCK_FREQUENCY 100e6
#define UPDATE_PERIOD_IN_SECONDS 1 / 360

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

            update(&pong, rightPaddleDx, leftPaddleDx);
        }
    }
	return 0;
}

void updateScore(game pong) {
    uint8_t invertedRightScore = invertThreeBits(oneHotEncoder(pong.rightScore));
    uint8_t leftScore = oneHotEncoder(pong.leftScore);
    leds_out_write(leftScore + (invertedRightScore >> 8));
}

uint8_t oneHotEncoder(uint8_t input) {
    return 0b1 >> input;
}

uint8_t invertThreeBits(uint8_t input) {
    uint8_t firstBit = input & 0b001;
    uint8_t secondBitValue = input & 0b010);
    uint8_t thirdBit = (input & 0b100) >> 2;

    return (firstBit << 2) + secondBitValue + (thirdBit)
}

void draw(game pong) {
  drawer_cursor_right_py_write(pong.rightPaddle.y + Y_OFFSET);
  drawer_cursor_left_py_write(pong.leftPaddle.y + Y_OFFSET);

  drawer_ball_px_write(pong.ball.x + X_OFFSET);
  drawer_ball_py_write(pong.ball.y + Y_OFFSET);
}

int main(void) {
#ifdef CONFIG_CPU_HAS_INTERRUPT
  irq_setmask(0);
  irq_setie(1);
#endif
  uart_init();
  game pong = start();
  time_init();

  int lastEvent = 0;
  int16_t rightPaddleDy, leftPaddleDy = 0;
  int16_t up, down, left, right = 0;

  while (1) {

    if (elapsed(&lastEvent, (CLOCK_FREQUENCY * UPDATE_PERIOD_IN_SECONDS))) {
      up = button_up_output_read();
      down = button_down_output_read();
      left = button_left_output_read();
      right = button_right_output_read();

      if (right)
        rightPaddleDy = 1;
      else if (up)
        rightPaddleDy = -1;
      else
        rightPaddleDy = 0;

      if (down)
        leftPaddleDy = 1;
      else if (left)
        leftPaddleDy = -1;
      else
        leftPaddleDy = 0;

      // control = getch();
      // if (control == 119) rightPaddleDx = 1; // w
      // else if (control == 115) rightPaddleDx = -1; // s
      // else rightPaddleDx = 0;

      update(&pong, rightPaddleDy, leftPaddleDy);
      draw(pong);
    }
  }
  return 0;
}
