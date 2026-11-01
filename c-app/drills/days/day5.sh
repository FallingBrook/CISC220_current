# Day 5 labs: arrays in functions, characters as numbers, binary
DAY_TITLE="Arrays in functions, characters as numbers, and binary"

ctask 1 reverse.c "Read the integer command line arguments (at most 100) into an int array with atoi (from <stdlib.h>; like atof but gives an int). Write a function void reverse(int a[], size_t n) that reverses the array IN PLACE (swap the first and last, then the second and second-last, ...). main calls it, then prints the numbers on one line separated by single spaces, then a newline. Exit status 0. With no arguments: print a usage message to standard error and exit with status 1."
crun '1 2 3 4'
crun '5 -3 0 7 9'
crun '42'
crun '1 1 2 2'
crun ''

ctask 2 countones.c "The program gets one argument, an 8-character binary string such as 01001001 (you may assume it has exactly 8 characters, each '0' or '1'). Write a function int countones(const char str[static 8]) that returns how many characters are '1'. Print that count and a newline; exit status 0. If the number of arguments is not exactly one, print a usage message to standard error and exit with status 1."
crun '01001001'
crun '00000000'
crun '11111111'
crun '10000000'
crun ''
crun '0101 0101'

ctask 3 binvalue.c "The program gets one argument, an 8-character binary string with the most significant bit first (index 0), e.g. 01101011. Print its UNSIGNED value in decimal and a newline (01101011 prints 107). Hint: either add up bit times power of 2, or go left to right with value = value * 2 + bit, where bit = c - '0'. Exit status 0. If the number of arguments is not exactly one, print a usage message to standard error and exit with status 1."
crun '01101011'
crun '00000000'
crun '11111111'
crun '10000000'
crun '00000001'
crun ''

ctask 4 flipbits.c "The program gets one argument, an 8-character binary string. Print the string with every bit flipped ('0' becomes '1' and '1' becomes '0'), then a newline. In ones' complement this is the negation: 00111111 (63) becomes 11000000 (-63). Write the flipped bits into a char array of 9 elements and remember the '\\0'. Exit status 0. If the number of arguments is not exactly one, print a usage message to standard error and exit with status 1."
crun '00111111'
crun '00000000'
crun '11111111'
crun '01001001'
crun ''

ctask 5 adddec.c "The program gets two decimal digit strings of the SAME length (1 to 50 digits, leading zeros allowed), e.g. 0457 0368. Add them with long addition, right to left with a carry: digit = (a + b + carry) % 10, carry = (a + b + carry) / 10. Print the result with the same number of digits as the inputs (keep leading zeros), but if a carry is left at the end, print it first: 999 001 prints 1000. Then a newline; exit status 0. If there are not exactly two arguments, or their lengths differ, print a message to standard error and exit with status 1."
crun '0457 0368'
crun '999 001'
crun '0 0'
crun '9 9'
crun '0000 0000'
crun '12345678901234567890 98765432109876543210'
crun '123 45'
crun '12'
