#ifndef PONG_H
#define PONG_H

#include <inttypes.h>

#include "ball.h"
#include "paddle.h"
#include "table.h"

#define TABLE_HEIGHT 25
#define TABLE_WIDTH 100
#define PADDLE_OFFSET 2
#define PADDLE_LENGTH 5

typedef struct {
    table table;
    ball ball;
    paddle rightPaddle, leftPaddle;
    uint8_t rightScore, leftScore;
} game;


void update(game* game, int8_t rightPaddleDy, int8_t leftPaddleDy);
void updatePosition(game* game, int8_t rightPaddleDy, int8_t leftPaddleDy);
void updateScore(game* game);
uint8_t pointScoredAgainst(ball ball, paddle paddle);
uint8_t collisionWithPaddle(ball ball, paddle paddle);
uint8_t collisionWithTable(ball ball, table table);
game start();
uint8_t byteAbs(int8_t value);

#endif
