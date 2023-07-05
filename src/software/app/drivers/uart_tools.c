#include <stdlib.h>
#include <string.h>

#include "xuartlite_l.h"

#include "uart_tools.h"

typedef enum
{
    done,
    started,
} uart_state_t;

typedef struct
{
    volatile uart_state_t tx_state;
    volatile uart_state_t rx_state;

    XUartLite *_xuart;

    u8 tx_accumulator[BUF_SIZE];
    u8 tx_buffer[BUF_SIZE];
    u32 tx_len;

    u8 rx_buffer[BUF_SIZE];
    u32 rx_len;
} uart_driver_t;

static uart_driver_t uart_device[UART_COUNT];

static void rx_start(u8 device_id)
{
    uart_driver_t *dev = &uart_device[device_id];
    dev->rx_buffer[0] = '\0';
    dev->rx_buffer[sizeof(dev->rx_buffer) - 1] = '\0';
    dev->rx_len = 0;
    dev->rx_state = started;
}

static void rx_done(void *ref, u32 len)
{
    uart_driver_t *dev = (uart_driver_t *)ref;
    // if device is fast enough, rx buffer may contain more that 1 char
    while (!XUartLite_IsReceiveEmpty(dev->_xuart->RegBaseAddress))
    {
        u8 c = XUartLite_RecvByte(dev->_xuart->RegBaseAddress);

        // quietly drop char if rx not in progress
        if (dev->rx_state == started)
        {
            if (c == '\n' || c == '\r')
            {
                // stop receiving on EOL
                dev->rx_buffer[dev->rx_len] = '\0';
                dev->rx_state = done;
            }
            else
            {
                // quietly drop char if buffer is full (reserve space for '\0')
                if (dev->rx_len < sizeof(dev->rx_buffer) - 1)
                    dev->rx_buffer[dev->rx_len++] = c;
            }
        }
    }
}

static void tx_start(u8 device_id)
{
    uart_driver_t *dev = &uart_device[device_id];
    // start tx only if there is data in accumulator
    if (dev->tx_len > 0)
    {
        dev->tx_state = started;
        memcpy(dev->tx_buffer, dev->tx_accumulator, dev->tx_len);
        XUartLite_Send(dev->_xuart, dev->tx_buffer, dev->tx_len);
        dev->tx_len = 0;
    }
}

static void tx_done(void *ref, u32 len)
{
    ((uart_driver_t *)ref)->tx_state = done;
}

static void tx_flush_device(u8 device_id)
{
    while (uart_device[device_id].tx_state != done)
        ;
    tx_start(device_id);
    while (uart_device[device_id].tx_state != done)
        ;
}

void tx_flush()
{
    tx_flush_device(UART_PC_ID);
    // do not flush MDM UART - never ends if no programmer is connected
}

u32 handle_uart(u8 device_id, char *buf, u32 buf_size)
{
    uart_driver_t *dev = &uart_device[device_id];

    if (dev->tx_state == done)
        tx_start(device_id);

    if (dev->rx_state == done)
    {
        memcpy(buf, dev->rx_buffer, dev->rx_len);
        buf[dev->rx_len] = '\0';

        // restart rx after rx_buffer was copied out
        u32 rx_len_rv = dev->rx_len;
        rx_start(device_id);
        return rx_len_rv;
    }
    else
        return 0;
}

void uart_write(u8 device_id, const char *str)
{
    uart_driver_t *dev = &uart_device[device_id];
    u32 remain = BUF_SIZE - dev->tx_len;
    u32 len = strlen(str);
    if (remain < len)
    {
        // MDM UART works only when programmer is connected,
        // so it is normal if MDM buffer is full otherwise
//        if (device_id != UART_MDM_ID)
//        {
//            warning(ERR_UART, "TX buffer overrun");
//        }
        return;
    }

    memcpy(&(dev->tx_accumulator[dev->tx_len]), str, len);
    dev->tx_len += len;
}

static void add_to_tx_accum(u8 device_id, char c)
{
    uart_driver_t *dev = &uart_device[device_id];
    // quietly drop char if buffer is full
    if (dev->tx_len < BUF_SIZE)
        dev->tx_accumulator[dev->tx_len++] = c;

    if (dev->tx_state != started)
        tx_start(device_id);
}

static void nonblocking_outbyte(void *ref, char c)
{
    add_to_tx_accum(UART_PC_ID, c);
//    if ((COMM_LSTCOM_MODE == comm_mode) && ('\n' == c))
//    {
//        // Add CR character to MDM output line termination.
//        // Otherwise XSDK does not output lines properly.
//        add_to_tx_accum(UART_MDM_ID, '\r');
//    }
//    add_to_tx_accum(UART_MDM_ID, c);
}

void uart_init(XUartLite *xuart, u8 device_id)
{
    if (device_id >= UART_COUNT) return;
    uart_driver_t *dev = &uart_device[device_id];

    XUartLite_Initialize(xuart, device_id);
    XUartLite_SetSendHandler(xuart, (XUartLite_Handler)tx_done, dev);
    XUartLite_SetRecvHandler(xuart, (XUartLite_Handler)rx_done, dev);
    XUartLite_ResetFifos(xuart);
    XUartLite_EnableInterrupt(xuart);

    dev->_xuart = xuart;
    dev->tx_state = done;
    dev->rx_state = started;

    init_printf(NULL, nonblocking_outbyte);
}

u32 tiny_sscanf(char *str, char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    u8 base;
    u32 matched = 0;
    while (*str && *format)
    {
        if (*format == '%')
        {
            format++;
            switch (*format)
            {
            case 'c':
                *(va_arg(ap, char *)) = *str;
                str++;
                matched++;
                break;
            case 'd':
                if (*str == '0' && *(str + 1) == 'x')
                    base = 16;
                else if (*str == 'b')
                {
                    base = 2;
                    str++;
                }
                else
                    base = 10;
                char *str_before = str;
                *(va_arg(ap, u32 *)) = strtol(str, &str, base);
                if (str_before == str)
                    return matched;
                else
                    matched++;
                break;
            default:
                return 0;
            }
            format++;
        }
        else
        {
            if (*str != *format)
                return 0;
            str++;
            format++;
        }
    }

    va_end(ap);
    return matched;
}

void test_tiny_sscanf()
{
    debug("tiny_sscanf() unit tests:");
    debug(" 1: %d", tiny_sscanf("asd", "asd") == 0);
    debug(" 2: %d", tiny_sscanf("qwe", "asd") == 0);
    debug(" 3: %d", tiny_sscanf("a", "asd") == 0);
    debug(" 4: %d", tiny_sscanf("asdfgh", "asd") == 0);

    u32 d, d1, d2, r;
    r = tiny_sscanf("123456", "%d", &d);
    debug(" 5: %d", r == 1 && d == 123456);
    r = tiny_sscanf("-123456", "%d", &d);
    debug(" 6: %d", r == 1 && d == -123456);

    debug(" 7: %d", tiny_sscanf("asd", "%d") == 0);
    debug(" 8: %d", tiny_sscanf("123456", "%A") == 0);

    r = tiny_sscanf("0x123", "%d", &d);
    debug(" 9: %d", r == 1 && d == 0x123);

    r = tiny_sscanf("b11110001", "%d", &d);
    debug("10: %d", r == 1 && d == 0xf1);

    char c;
    r = tiny_sscanf("dlpc_L", "dlpc_%c", &c);
    debug("11: %d", r == 1 && c == 'L');

    r = tiny_sscanf("dlpc_L 10 0x123 b00010001", "dlpc_%c %d %d %d", &c, &d, &d1, &d2);
    debug("12: %d", r == 4 && c == 'L' && d == 10 && d1 == 0x123 && d2 == 0x11);

    debug("13: %d", tiny_sscanf("123456tail123", "%d", &d) == 1);
    debug("14: %d", tiny_sscanf("123456tail123", "%dtail%d", &d, &d) == 2);
    debug("15: %d", tiny_sscanf("123456tail123", "%d%d", &d) == 1);

    debug("16: %d", tiny_sscanf("pref123456", "%d", &d) == 0);
}

