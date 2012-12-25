/*
 * Raspberry PI Remote Serial Protocol.
 * Copyright 2012 Jamie Iles, jamie@jamieiles.com.
 * Licensed under GPLv2.
 */
#include "gdbstub.h"
#include "io.h"
#include "gpio.h"
#include "kernel.h"
#include "uart.h"
#include "debug.h"
#include "regs.h"
#include "printk.h"
#include "types.h"

#define GPFSEL0     0x20200000
#define GPFSEL2     0x20200008
#define GPPUD       0x20200094
#define GPPUDCLK0   0x20200098

static inline void delay_n_cycles(unsigned long n)
{
	n /= 2;
	asm volatile("1:	subs	%0, %0, #1\n"
		     "		bne	1b" : "+r"(n) : "r"(n) : "memory");
}

static void pinmux_cfg(void)
{
	struct pinmux_cfg cfg[] = {
		PINMUX(14, PUD_UP, FN_0),
		PINMUX(15, PUD_UP, FN_0),
		PINMUX(16, PUD_OFF, FN_OUT),
	};
	int err = pinmux_cfg_many(cfg, ARRAY_SIZE(cfg));
	BUG_ON(err, "failed to configure pinmux");
}

static void platform_init(void)
{
	uart_disable();
	pinmux_cfg();
}

static void jtag_init(void)
{
	int ra = 0;	
	
	//PUT32(GPPUD,0);
	writel(GPPUD, 0);
	
    //for(ra=0;ra<150;ra++) dummy(ra);
    delay_n_cycles(150);
    	
    //PUT32(GPPUDCLK0,(1<<4)|(1<<22)|(1<<24)|(1<<25)|(1<<27));
    writel(GPPUDCLK0, (1<<4)|(1<<22)|(1<<24)|(1<<25)|(1<<27) );
    
    //for(ra=0;ra<150;ra++) dummy(ra);
	delay_n_cycles(150);
	
    //PUT32(GPPUDCLK0,0);
    writel(GPPUDCLK0, 0);
    
	
   	ra = readl(GPFSEL0);
    ra &= ~(7<<12); //gpio4
    ra |= 2<<12; //gpio4 alt5 ARM_TDI
    writel(GPFSEL0,ra);

    ra = readl(GPFSEL2);
    ra&=~(7<<6); //gpio22
    ra|=3<<6; //alt4 ARM_TRST
    ra&=~(7<<12); //gpio24
    ra|=3<<12; //alt4 ARM_TDO
    ra&=~(7<<15); //gpio25
    ra|=3<<15; //alt4 ARM_TCK
    ra&=~(7<<21); //gpio27
    ra|=3<<21; //alt4 ARM_TMS
    writel(GPFSEL2,ra);
}


static void __used init_bss(void)
{
	extern char __bss_start, __bss_end;
	char *p;

	for (p = &__bss_start; p < &__bss_end; ++p)
		*p = 0;
}

void dump_regs(struct arm_regs *regs)
{
	int i;
	const char * const reg_names[] = {
		"r0 ", "r1 ", "r2 ", "r3 ",
		"r4 ", "r5 ", "r6 ", "r7 ",
		"r8 ", "r9 ", "r10", "r11",
		"r12", "sp ", "lr ", "pc ",
	};

	for (i = 0; i < 16; ++i) {
		puts(reg_names[i]);
		puts(": ");
		print_hex(regs->r[i]);
		puts("\n");
	}
	puts("cpsr: ");
	print_hex(regs->r[CPSR]);
	puts("\n");
}

void panic(void)
{
	BUG("panic!, entering infinite loop...");
}

static const struct bug_entry *find_bug(unsigned long addr)
{
	extern const struct bug_entry __bug_start, __bug_end;
	const struct bug_entry *b;

	for (b = &__bug_start; b < &__bug_end; ++b)
		if (b->addr == addr)
			return b;

	return NULL;
}

static void show_bug(const struct bug_entry *b,
		     struct arm_regs *regs)
{
	puts("\nBUG: ");
	puts(b->filename);
	puts(":");
	print_hex(b->line);
	puts(" ");
	puts(b->msg);
	puts("\n");
	dump_regs(regs);
}

static void handle_bugs(struct arm_regs *regs)
{
	const struct bug_entry *b = find_bug(regs->r[PC]);

	if (!b)
		return;

	show_bug(b, regs);

	for (;;)
		continue;
}

void do_undef(struct arm_regs *regs)
{
	handle_bugs(regs);
	dump_regs(regs);
	panic();

	regs->r[PC] += 4;
}

void do_prefetch(struct arm_regs *regs)
{
	BUG("prefetch abort\n");

	regs->r[PC] += 4;
}

void do_dabort(struct arm_regs *regs)
{
	BUG("prefetch abort\n");

	regs->r[PC] += 4;
}

void do_reserved(struct arm_regs *regs)
{
	BUG("unhandled exception\n");

	regs->r[PC] += 4;
}

void do_swi(struct arm_regs *regs)
{
	puts("in monitor mode!\n");

	regs->r[PC] += 4;
}

void do_irq(struct arm_regs *regs)
{
	puts("in irq handler\n");
}

void do_fiq(struct arm_regs *regs)
{
	puts("in fiq handler\n");
}



void start_kernel(void)
{
	platform_init();
	gdbstub_init();
	jtag_init();
	asm volatile("cpsie	if");

	for (;;) {
		writel(PERIPH_BASE + 0x00200000 + 0x1c, 1 << 16);
		delay_n_cycles(50000000);
		writel(PERIPH_BASE + 0x00200000 + 0x28, 1 << 16);
		delay_n_cycles(50000000);
	}
}
