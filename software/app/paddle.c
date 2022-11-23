#include "paddle.h"

void movePaddle(paddle* paddle, int8_t dy) {
    paddle->y += dy;
}

void bounceOffPaddle(ball* ball) {
    ball->dx *= -1;
}
