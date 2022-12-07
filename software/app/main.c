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
#define UPDATE_PERIOD_IN_SECONDS 1 / 480
#define LED_BLINK_PERIOD_IN_SECONDS 3

#define X_OFFSET TABLE_WIDTH / 2
#define Y_OFFSET TABLE_HEIGHT / 2

#define SENSOR_MAX_THRESHOLD 30
#define SENSOR_MIN_THRESHOLD 10
#define SENSOR_EXPONENTIAL_DECAY_PERCENTAGE 60

// http://graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious
uint8_t reflectByte(uint8_t v) {
  uint8_t r = v;             // r will be reversed bits of v; first get LSB of v
  int s = sizeof(v) * 8 - 1; // extra shift needed at end

  for (v >>= 1; v; v >>= 1) {
    r <<= 1;
    r |= v & 1;
    s--;
  }
  r <<= s; // shift when v's highest bits are zero

  return r;
}

uint8_t oneHotEncode(uint8_t input) { return 0b1 << input; }

void showScore(game pong) {
  uint8_t rightScore = oneHotEncode(pong.rightScore + 1) - 1;
  uint8_t invertLeftScore = reflectByte(oneHotEncode(pong.leftScore + 1) - 1);
  leds_out_write((uint16_t)invertLeftScore << 8 | rightScore);
}

void draw(game pong) {
  drawer_cursor_right_py_write(pong.rightPaddle.y + Y_OFFSET);
  drawer_cursor_left_py_write(pong.leftPaddle.y + Y_OFFSET);

  drawer_ball_px_write(pong.ball.x + X_OFFSET);
  drawer_ball_py_write(pong.ball.y + Y_OFFSET);
}

int16_t updatePaddlePosition(int16_t paddlePosition,
                             int32_t sensorMeasurement) {
  // printf("sensorMeasurement: %d\n", sensorMeasurement);
  if (sensorMeasurement < SENSOR_MAX_THRESHOLD) {
  // printf("current_position: %d\n", paddlePosition);
    paddlePosition =
        ((int16_t)sensorMeasurement +
         (SENSOR_EXPONENTIAL_DECAY_PERCENTAGE * paddlePosition) / 100);
  // printf("new_position: %d\n", paddlePosition);
  // printf("------------------\n");
  }
  return paddlePosition;
}

int main(void) {
#ifdef CONFIG_CPU_HAS_INTERRUPT
  irq_setmask(0);
  irq_setie(1);
#endif
  uart_init();
  game pong = start();
  time_init();
  servo_left_posicao_write(0);
  servo_right_posicao_write(0);

  printf("####\n"); // header to easy search on usb parser

  int lastEvent = 0;
  int lastPaddleEvent = 0;
  int16_t rightPaddleY, leftPaddleY = 0;
  int16_t up, down, left, right = 0;
  uint8_t gameOn = 1;
  uint32_t leds, left_sensor, right_sensor = 0;

  while (1) {
    if (pong.leftWin || pong.rightWin) {

      if (pong.rightWin) {
        leds_out_write(0x00FF);
        servo_right_posicao_write(1);
      } else if (pong.leftWin) {
        leds_out_write(0xFF00);
        servo_left_posicao_write(1);
      }

      msleep(200);
      leds_out_write(0);
      msleep(200);

    } else if (gameOn) {

      if (elapsed(&lastPaddleEvent, CLOCK_FREQUENCY / 16)) {
        up = button_up_output_read();
        down = button_down_output_read();
        left = button_left_output_read();
        right = button_right_output_read();

        int16_t right_medida = hcsr04_right_medida_read();
        // printf("%d\t", right_medida);
        if (right_medida < SENSOR_MAX_THRESHOLD &&
            right_medida > SENSOR_MIN_THRESHOLD) {
          right_medida = ((right_medida - SENSOR_MIN_THRESHOLD) * TABLE_HEIGHT /
                              (SENSOR_MAX_THRESHOLD - SENSOR_MIN_THRESHOLD) -
                          TABLE_HEIGHT / 2);
          rightPaddleY =
              ((100 - SENSOR_EXPONENTIAL_DECAY_PERCENTAGE) * right_medida +
               SENSOR_EXPONENTIAL_DECAY_PERCENTAGE * rightPaddleY) /
              100;
        }

        int16_t left_medida = hcsr04_left_medida_read();
        // printf("%d\n", left_medida);
        if (left_medida < SENSOR_MAX_THRESHOLD &&
            left_medida > SENSOR_MIN_THRESHOLD) {
          left_medida = ((left_medida - SENSOR_MIN_THRESHOLD) * TABLE_HEIGHT /
                             (SENSOR_MAX_THRESHOLD - SENSOR_MIN_THRESHOLD) -
                         TABLE_HEIGHT / 2);
          leftPaddleY =
              ((100 - SENSOR_EXPONENTIAL_DECAY_PERCENTAGE) * left_medida +
               SENSOR_EXPONENTIAL_DECAY_PERCENTAGE * leftPaddleY) /
              100;
        }
      }

      if (elapsed(&lastEvent, (CLOCK_FREQUENCY * UPDATE_PERIOD_IN_SECONDS))) {
        update(&pong, rightPaddleY, leftPaddleY);
        draw(pong);
        showScore(pong);
      }
    }
  }
  return 0;
}
