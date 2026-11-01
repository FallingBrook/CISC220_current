# Day 9 labs: bitwise operations, part 1
DAY_TITLE="Bitwise operations: & | ^ ~, shifts, and masks"

ctask 1 showbits.c "The program gets one argument, a whole number n from 0 to 255 (read it with atoi). Print n in decimal, then a space, then 0x and n in hex with exactly two UPPERCASE digits (%02X), then a space, then its 8 bits, most significant first, then a newline. Example: 23 prints '23 0x17 00010111'. Get each bit with a shift and a mask: (x >> i) & 1u, for i from 7 down to 0. Store n in an unsigned int and print it with %u. Exit status 0. If the number of arguments is not exactly one, or n is not from 0 to 255, print a message to standard error and exit with status 1."
crun '23'
crun '0'
crun '255'
crun '128'
crun '10'
crun '256'
crun ''

ctask 2 bitops.c "The program gets two arguments a and b, each from 0 to 255 (atoi). Store them in uint8_t variables (from <stdint.h>). Print six lines, each as LABEL = BITS = DECIMAL, where BITS is the 8 bits of the value: the labels are exactly 'a    ', 'b    ', 'a & b', 'a | b', 'a ^ b', '~a   ' (each padded to 5 characters). Example for 18 206, first and last lines: 'a     = 00010010 = 18' and '~a    = 11101101 = 237'. Store each result in a uint8_t before printing it, so ~a has only 8 bits. Exit status 0. If there are not exactly two arguments or one is outside 0 to 255, print a message to standard error and exit with status 1."
crun '18 206'
crun '0 0'
crun '255 15'
crun '170 85'
crun '300 1'
crun '5'

ctask 3 bitset.c "The program gets three arguments: an operation (a single letter: t = test, s = set, c = clear, f = flip/toggle), a bit number k from 0 to 7, and a value x from 0 to 255. Build the mask 1u << k. For t, print 1 if bit k of x is 1 and 0 if it is 0, then a newline. For s, c and f, set, clear or toggle bit k of x and print the result's 8 bits, a space, and the result in decimal, then a newline (s 0 18 prints '00010011 19'). Exit status 0. Print a message to standard error and exit with status 1 if there are not exactly three arguments, k or x is out of range, or the operation is not exactly one of the four letters."
crun 't 1 18'
crun 't 0 18'
crun 's 0 18'
crun 's 1 18'
crun 'c 4 18'
crun 'c 0 18'
crun 'f 7 18'
crun 'f 1 18'
crun 'x 1 18'
crun 'set 1 18'
crun 's 8 18'
crun 's 1'

ctask 4 countbits.c "The program gets one argument, a whole number n that is 0 or more (atoi; you may assume it fits in an int). Copy it into an unsigned int x and count how many of its bits are 1: while x is not 0, add x & 1u to a count and shift x right by one. Print the count and a newline. Exit status 0. If the number of arguments is not exactly one, or n is negative, print a message to standard error and exit with status 1."
crun '0'
crun '1'
crun '7'
crun '255'
crun '256'
crun '2147483647'
crun '-5'
crun ''

ctask 5 swapcase.c "The program gets one or more words. Print them on one line separated by single spaces, with the case of every LETTER swapped using XOR with 32 (bit 5): 'A' (65) becomes 'a' (97) and back. Characters that are not letters (digits, punctuation) are printed unchanged: check that a character is from 'A' to 'Z' or from 'a' to 'z' before you toggle it. Then a newline; exit status 0. With no arguments, print a usage message to standard error and exit with status 1."
crun 'Hello'
crun 'hELLO wORLD'
crun 'CISC220 is Fun!'
crun 'abc-XYZ_123'
crun ''
