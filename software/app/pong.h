#ifndef PONG_H
#define PONG_H

#include <inttypes.h>

#include "ball.h"
#include "paddle.h"
#include "table.h"

#define TABLE_HEIGHT 960
#define TABLE_WIDTH 1280
#define PADDLE_OFFSET 20
#define PADDLE_LENGTH 160
#define PADDLE_WIDTH 20
#define BALL_WIDTH 30

typedef struct {
  table table;
  ball ball;
  paddle rightPaddle, leftPaddle;
  uint8_t rightScore, leftScore;
} game;

void update(game *game, int16_t rightPaddleDy, int16_t leftPaddleDy);
void updatePosition(game *game, int16_t rightPaddleDy, int16_t leftPaddleDy);
void showScore(game game);
uint16_t pointScoredAgainst(ball ball, paddle paddle);
uint16_t collisionWithPaddle(ball ball, paddle paddle);
uint16_t collisionWithTable(ball ball, table table);
uint8_t invertThreeBits(uint8_t input);
uint8_t oneHotEncoder(uint8_t input);
game start();
uint16_t byteAbs(int16_t value);

#endif
