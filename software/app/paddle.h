#ifndef PADDLE_H
#define PADDLE_H

#include <inttypes.h>

#include "ball.h"

typedef struct {
    int8_t x, y;
} paddle;

void movePaddle(paddle* paddle, int8_t dy);
void bounceOffPaddle(ball* ball);

#endif