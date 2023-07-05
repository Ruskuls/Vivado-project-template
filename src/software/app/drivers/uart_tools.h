#ifndef UART_TOOLS_H_
#define UART_TOOLS_H_
#include "xuartlite.h"

#define TINYPRINTF_DEFINE_TFP_PRINTF  1
#define TINYPRINTF_DEFINE_TFP_SPRINTF 1
#define TINYPRINTF_OVERRIDE_LIBC      0
#include "tinyprintf.h"

// buffer of this size is used 3 times for every UART device: tx_accumulator, tx_buffer, rx_buffer.
#define BUF_SIZE 512 + 256

// Number of simultaneous UARTs available on the system
#define UART_COUNT XPAR_XUARTLITE_NUM_INSTANCES

#define UART_PC_ID  XPAR_UARTLITE_0_DEVICE_ID
//#define UART_MDM_ID XPAR_UARTLITE_1_DEVICE_ID

#define UART_PC_INTC_ID  XPAR_INTC_0_UARTLITE_0_VEC_ID
//#define UART_MDM_INTC_ID XPAR_INTC_0_UARTLITE_1_VEC_ID

void uart_init(XUartLite *xuart, u8 device_id);

// process UART tx/rx in nonblocking way:
//   tx: start accumulated tx data transfer, if possible;
//   rx: return rx_len>0 when string is received and stored in rx_buf, return 0 otherwise;
//       rx buffer and its size are provided by user.
u32 handle_uart(u8 device_id, char *rx_buf, u32 rx_buf_size);

// Queue a string for transfer
void uart_write(u8 device_id, const char *str);

// wait until all data in tx buffer and tx accumulator is send
void tx_flush();

// limited implementation of stdlib sscanf
// tiny_sscanf returns number of matched parameters
// only 2 specifiers are supported:
//   %c - match single char
//   %d - match dec/hex/bin number (hex starts with '0x', bin starts with 'b')
u32 tiny_sscanf(char *str, char *format, ...);

#define traceback(err_code) \
    info("  - traceback: code %d, in %s, line %d", err_code, __FUNCTION__, __LINE__);

#endif /* UART_TOOLS_H_ */

