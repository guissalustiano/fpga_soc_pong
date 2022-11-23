#ifndef BALL_H
#define BALL_H

#include <inttypes.h>

typedef struct {
    int16_t dx, dy;
    int16_t x, y;
} ball;

void moveBall(ball* ball);
void resetBall(ball* ball);

#endif