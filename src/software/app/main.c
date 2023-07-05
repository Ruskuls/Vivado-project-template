#include <stdio.h>

#include "xintc.h"

#include "platform.h"
#include "xparameters.h"
#include "xstatus.h"
#include "io_tools.h"
#include "uart_tools.h"

XIOModule xio;

XIntc xintc;
XUartLite xuart_pc;

#define MAX_ADDRESS 65536

void intc_init()
{
    XIntc_Initialize(&xintc, XPAR_INTC_0_DEVICE_ID);
    XIntc_Start(&xintc, XIN_REAL_MODE);

    // connect xiomodule interrupts
    XIntc_Connect(&xintc, XPAR_INTC_0_IOMODULE_0_VEC_ID,
        (XInterruptHandler)XIOModule_InterruptHandler, &xio);
    XIntc_Enable(&xintc, XPAR_INTC_0_IOMODULE_0_VEC_ID);

    // connect xuart interrupts
    XIntc_Connect(&xintc, UART_PC_INTC_ID,
        (XInterruptHandler)XUartLite_InterruptHandler, &xuart_pc);
    XIntc_Enable(&xintc, UART_PC_INTC_ID);

    // register xintc as first level interrupt handler
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
        (Xil_ExceptionHandler)XIntc_InterruptHandler, &xintc);
    Xil_ExceptionEnable();
}

void mcs_init()
{
    uart_init(&xuart_pc, UART_PC_ID);
    intc_init();
}

int main(void)
{

    mcs_init();

    print("Hello World!\n\r");

    print("--Run HyperRam memory test--\n\r");
    print("--Write data--\n\r");
    for (int i = 0; i < MAX_ADDRESS; i++)
    {
    	Xil_Out32(XPAR_AVM_HYPERRAM_BASEADDR+i*4, i);
    }

    print("--Read data--\n\r");
    for (int i = 0; i < MAX_ADDRESS; i++)
    {
    	int data = Xil_In32(XPAR_AVM_HYPERRAM_BASEADDR+i*4);
    	if (data != i)
    	{
    		print("readback error\n\r");
    	}
    	//printf("addr = %d, received data = %d\n\r",XPAR_M_AXI_HYPERRAM_BASEADDR+i*4, data);
    }
    print("--done--\n\r");


    return 0;
}
