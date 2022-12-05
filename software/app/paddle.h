#ifndef PADDLE_H
#define PADDLE_H

#include <inttypes.h>

#include "ball.h"

typedef struct {
    int16_t x, y;
} paddle;

void movePaddle(paddle* paddle, int16_t dy);
void bounceOffPaddle(ball* ball);

#endif