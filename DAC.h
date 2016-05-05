
// put your names here, date
#include <stdint.h>

// **************DAC_Init*********************
// Initialize 6-bit DAC, called once 
// Input: none
// Output: none
void DAC_Init(void);


// **************DAC_Out*********************
// output to DAC
// Input: 6-bit data, 0 to 64
// Output: none
void DAC_Out(uint32_t data);
