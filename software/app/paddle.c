#include "paddle.h"

void movePaddle(paddle* paddle, int16_t dy) {
    paddle->y += dy;
}

void bounceOffPaddle(ball* ball) {
    ball->dx *= -1;
}
