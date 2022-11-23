#ifndef PONG_H
#define PONG_H

#include <inttypes.h>

#include "ball.h"
#include "paddle.h"
#include "table.h"

#define TABLE_HEIGHT 900
#define TABLE_WIDTH 900
#define PADDLE_OFFSET 10
#define PADDLE_LENGTH 5

typedef struct {
    table table;
    ball ball;
    paddle rightPaddle, leftPaddle;
    uint16_t rightScore, leftScore;
} game;


void update(game* game, int16_t rightPaddleDy, int16_t leftPaddleDy);
void updatePosition(game* game, int16_t rightPaddleDy, int16_t leftPaddleDy);
void updateScore(game* game);
uint16_t pointScoredAgainst(ball ball, paddle paddle);
uint16_t collisionWithPaddle(ball ball, paddle paddle);
uint16_t collisionWithTable(ball ball, table table);
game start();
uint16_t byteAbs(int16_t value);

#endif
