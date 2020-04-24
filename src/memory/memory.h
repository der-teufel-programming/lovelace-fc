#ifndef MEMORY_H
#define MEMORY_H

#include <inttypes.h>
#include <string.h>

uint8_t bank;

uint8_t rom[0xF00] = {
	0xe6, 0x40, 0x26, 0x0e, 0x03, 0x3f, 0xff, 0x0e, 0x00, 0x40, 0x01, 0x0e, 0x02, 0x40, 0x02, 0x0e, 0x00, 0x40, 0x03, 0x0e, 0x04, 0x40, 0x02, 0x0e, 0x40, 0x40, 0x03, 0x0e, 0x07, 0x40, 0x02, 0x0e, 0x20, 0x40, 0x03, 0xe6, 0x02, 0x23, 0x14, 0x40, 0x00, 0x14, 0x02, 0x02, 0x29, 0x03, 0x0f, 0x01, 0x0f, 0x03, 0x34, 0x00, 0x1b, 0x02, 0x90, 0xd5, 0x26, 0xe5, 0x40, 0x2d, 0xe6, 0x02, 0x03
};

uint8_t global_memory[0x3FFF];

void do_controller_cycle();

#endif