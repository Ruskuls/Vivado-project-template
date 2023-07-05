#ifndef IO_TOOLS_H_
#define IO_TOOLS_H_
#include "xiomodule.h"

void iomodule_init(XIOModule *xio, u8 device_id);

u32 millis();
void delay_ms(u32 ms);
void timeout_ms(u32 ms, void (*callback)());
void timeout_disarm();

void set_pin(u8 port, u8 pin, u8 value);
u8 read_pin(u8 port, u8 pin);

void iobus_write(u8 channel, u32 value);
u32 iobus_read(u32 offset);


#endif /* IO_TOOLS_H_ */

