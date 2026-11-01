# Day 8 labs: declarations and integers in depth
DAY_TITLE="Declarations and integers in depth"

ctask 1 twos.c "The program gets one argument, an 8-character binary string with the most significant bit first (index 0), e.g. 11101011. Print its value as an 8-bit TWO'S COMPLEMENT signed number in decimal, then a newline (11101011 prints -21, 01101011 prints 107). Remember: the leftmost bit is worth -128, the others 64, 32, 16, 8, 4, 2, 1. You may assume each character is '0' or '1'. Exit status 0. If the number of arguments is not exactly one, or the argument is not 8 characters long, print a usage message to standard error and exit with status 1."
crun '11101011'
crun '01101011'
crun '10000000'
crun '01111111'
crun '11111111'
crun '00000000'
crun '1010'
crun ''

ctask 2 tobin8.c "The program gets one integer argument n (convert it with atoi). If n is between -128 and 127, print its 8-bit two's complement bit pattern (8 characters '0'/'1', most significant first), then a newline: -1 prints 11111111, 5 prints 00000101, -56 prints 11001000. Hint: assign n to an unsigned char variable; a negative n becomes n + 256, and then you can find its bits with % 2 and / 2 from the right. Build the bits in a char array of 9 and remember the '\\0'. Exit status 0. With the wrong number of arguments, or n outside -128..127, print a message to standard error and exit with status 1."
crun '5'
crun '-1'
crun '-56'
crun '127'
crun '-128'
crun '0'
crun '128'
crun ''

ctask 3 wrap8.c "The program gets two integer arguments a and b, each 0 to 255 (convert with atoi). Store them in unsigned char variables, then compute a + b, a - b and a * b, storing each result in an unsigned char variable, so each result wraps around modulo 256. Print the three results on one line separated by single spaces (print an unsigned char with %d), then a newline. Example: 200 100 prints 44 100 32. Exit status 0. With the wrong number of arguments, or a value outside 0..255, print a message to standard error and exit with status 1."
crun '200 100'
crun '3 5'
crun '255 255'
crun '0 0'
crun '16 16'
crun '300 1'
crun '7'

ctask 4 fits.c "The program gets one integer argument (convert it with atoll from <stdlib.h>, which is like atoi but returns a long long). Using the constants in <limits.h>, print five lines saying whether the value fits in each type, in this order and format:
signed char: yes
unsigned char: no
short: yes
int: yes
unsigned int: no
(that example is for -5). Each line ends with yes or no. Exit status 0. If the number of arguments is not exactly one, print a usage message to standard error and exit with status 1."
crun '-5'
crun '200'
crun '127'
crun '-129'
crun '40000'
crun '-32768'
crun '3000000000'
crun '5000000000'
crun ''
