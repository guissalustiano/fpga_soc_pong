#include "ball.h"

void moveBall(ball* ball) {
    ball->x += ball->dx;
    ball->y += ball->dy;
}

void resetBall(ball* ball) {
    ball->x = ball->y = 0;
}
