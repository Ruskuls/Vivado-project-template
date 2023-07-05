#include "io_tools.h"

// in order to simplify user API - locally store pointer to iomodule controller
XIOModule *_xio;

volatile static u32 ms;
volatile static void (*timeout_callback)();
volatile static u32 timeout_counter;

// interrupt fired every 1ms (fixed in hardware)
static void millis_counter(void *_)
{
    ms++;
    if (timeout_callback)
    {
        if (--timeout_counter == 0)
        {
            timeout_callback();
            timeout_disarm();
        }
    }
}

void iomodule_init(XIOModule *xio, u8 device_id)
{
    XIOModule_Initialize(xio, device_id);
    XIOModule_Start(xio);

    // connect Fixed Interval Timer
    XIOModule_Connect(xio, XIN_IOMODULE_FIT_1_INTERRUPT_INTR,
        (XInterruptHandler)millis_counter, NULL);
    XIOModule_Enable(xio, XIN_IOMODULE_FIT_1_INTERRUPT_INTR);

    _xio = xio;
}

u32 millis()
{
    return ms;
}

void delay_ms(u32 ms)
{
    u32 started_at = millis();
    while (millis() - started_at < ms)
        ;
}

void timeout_ms(u32 ms, void (*callback)())
{
    timeout_callback = callback;
    timeout_counter = ms;
}

void timeout_disarm()
{
    timeout_callback = NULL;
    timeout_counter = 0;
}

void set_pin(u8 port, u8 pin, u8 value)
{
    if (port != 1)
    {
//        error(ERR_MCS_IO, "as of now, only GPO1 is in use");
        return;
    }
    XIOModule_DiscreteWrite(_xio, port,
        (_xio->GpoValue[port - 1] & ~(1 << pin)) | (value << pin));
}

u8 read_pin(u8 port, u8 pin)
{
    if (port != 1)
    {
//        error(ERR_MCS_IO, "as of now, only GPI1 is in use");
        return 0;
    }
    return (XIOModule_DiscreteRead(_xio, port) & (1 << pin)) >> pin;
}

void iobus_write(u8 channel, u32 value)
{
	XIOModule_DiscreteWrite(_xio, channel, value);
}

u32 iobus_read(u32 offset)
{
//    return XIOModule_IoReadWord(_xio, offset);
	return XIOModule_DiscreteRead(_xio, offset);
}

