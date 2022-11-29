#include "pong.h"

void update(game* game, int16_t rightPaddleDy, int16_t leftPaddleDy) {
    updateScore(game);
    updatePosition(game, rightPaddleDy, leftPaddleDy);
}

void updatePosition(game* game, int16_t rightPaddleDy, int16_t leftPaddleDy) {
    if (pointScoredAgainst(game->ball, game->rightPaddle) || pointScoredAgainst(game->ball, game->leftPaddle))
        resetBall(&game->ball);

    if (collisionWithPaddle(game->ball, game->rightPaddle) || collisionWithPaddle(game->ball, game->leftPaddle))
        bounceOffPaddle(&game->ball);
    if (collisionWithTable(game->ball, game->table))
        bounceOffTable(&game->ball);

    movePaddle(&game->rightPaddle, rightPaddleDy);
    movePaddle(&game->leftPaddle, leftPaddleDy);
    getPaddleInside(&game->rightPaddle, game->table);
    getPaddleInside(&game->leftPaddle, game->table);
    moveBall(&game->ball);
}

void updateScore(game* game) {
    if (pointScoredAgainst(game->ball, game->rightPaddle))
        game->leftScore += 1;
    else if (pointScoredAgainst(game->ball, game->leftPaddle))
        game->rightScore += 1;
}

uint16_t pointScoredAgainst(ball ball, paddle paddle) {
    return byteAbs(ball.x) > byteAbs(paddle.x);
}

void getPaddleInside(paddle* paddle, table table) {
    if (paddle->y + PADDLE_LENGTH/2 > table.height/2)
        paddle->y = table.height/2 - PADDLE_LENGTH/2;
    if (paddle->y - PADDLE_LENGTH/2 < -table.height/2)
        paddle->y = -table.height/2 + PADDLE_LENGTH/2;
}

uint16_t collisionWithPaddle(ball ball, paddle paddle) {
    return (
        byteAbs(ball.x - paddle.x) == PADDLE_WIDTH/2 + BALL_WIDTH/2
        && byteAbs(ball.y - paddle.y) < PADDLE_LENGTH/2 + BALL_WIDTH/2
    );
}

uint16_t collisionWithTable(ball ball, table table) {
    return byteAbs(ball.y) == table.height/2 - BALL_WIDTH/2;
}

game start() {
    table table = { .height=TABLE_HEIGHT, .width=TABLE_WIDTH };
    ball ball = { .x=0, .y=0, .dx=1, .dy=0 };
    paddle rightPaddle = { .x=(TABLE_WIDTH/2 - PADDLE_OFFSET), .y=0 };
    paddle leftPaddle = { .x=(-TABLE_WIDTH/2 + PADDLE_OFFSET), .y=0 };
    uint16_t rightScore, leftScore;
    rightScore = leftScore = 0;

    game pong = {
        .table=table,
        .ball=ball,
        .rightPaddle=rightPaddle, .leftPaddle=leftPaddle,
        .rightScore=rightScore, .leftScore=leftScore
    };
    return pong;
}

uint16_t byteAbs(int16_t value) {
    return value > 0 ? value : -value;
}
