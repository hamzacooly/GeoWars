// put implementations for functions, explain how it works
// put your names here, date
#include <stdint.h>
#include "tm4c123gh6pm.h"

uint8_t x = 0;
void DAC_Init(void){
 SYSCTL_RCGCGPIO_R |= 0x02;//clock
	x = 4;//delay
	x = x*x;//delay
	x = x+x+x;//delay
 while((SYSCTL_RCGCGPIO_R&0X02)==0){};//delay
	 
	GPIO_PORTB_CR_R |= 0xFF;
	GPIO_PORTB_DIR_R |= 0xFF;
	GPIO_PORTB_DEN_R |= 0xFF;
	GPIO_PORTB_AFSEL_R &= ~0xFF;
		
	
}

// **************DAC_Out*********************
// output to DAC
// Input: 6-bit data, 0 to 63
// Output: none
void DAC_Out(uint32_t data)
{
		GPIO_PORTB_DATA_R = data;
}

