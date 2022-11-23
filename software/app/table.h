#ifndef TABLE_H
#define TABLE_H

#include <inttypes.h>

#include "ball.h"

typedef struct {
    uint8_t height, width;
} table;

void bounceOffTable(ball* ball);

#endif