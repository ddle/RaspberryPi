
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------

// The raspberry pi firmware at the time this was written defaults
// loading at address 0x8000.  Although this bootloader could easily
// load at 0x0000, it loads at 0x8000 so that the same binaries built
// for the SD card work with this bootloader.  Change the ARMBASE
// below to use a different location.

#define ARMBASE 0x8000
#define CS 0x20003000
#define CLO 0x20003004
#define C0 0x2000300C
#define C1 0x20003010
#define C2 0x20003014
#define C3 0x20003018

#define GPFSEL1 0x20200004
#define GPSET0  0x2020001C
#define GPCLR0  0x20200028

extern void PUT32 ( unsigned int, unsigned int );
extern unsigned int GET32 ( unsigned int );
//------------------------------------------------------------------------
extern void irq_enable ( void );
extern void irq_init ( void );
//------------------------------------------------------------------------
unsigned int ra;
unsigned int rx;
unsigned int interval;
//------------------------------------------------------------------------
volatile unsigned int irq_counter;
//-------------------------------------------------------------------------
void on()
{
	PUT32(GPCLR0,1<<16); //led on
}
void off()
{
	PUT32(GPSET0,1<<16); //led off
}
void c_irq_handler ( void )
{
	PUT32(CS,2);
	if (irq_counter == 0){
		on();
    	irq_counter = 1;
    }
    else
    {
    	off();
    	irq_counter = 0;
    }
    rx=GET32(CLO);    
    rx+=interval;
    PUT32(C1,rx);
}


//------------------------------------------------------------------------
int main ( void )
{
   	irq_init();
	
    //make gpio pin tied to the led an output
    ra=GET32(GPFSEL1);
    ra&=~(7<<18);
    ra|=1<<18;
    PUT32(GPFSEL1,ra);
    PUT32(GPSET0,1<<16); //led off
//    PUT32(GPCLR0,1<<16); //led on


//rely on the interrupt to measure time.

    irq_counter=0;
    ra=irq_counter;
    interval=0x14240;
    rx=GET32(CLO);
    rx+=interval;
    PUT32(C1,rx);
    PUT32(CS,2);
    PUT32(0x2000B210,0x00000002);
    irq_enable();
    
    while(1)
    {   
    }


    return(0);
}
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------


//-------------------------------------------------------------------------
//
// Copyright (c) 2012 David Welch dwelch@dwelch.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//-------------------------------------------------------------------------
