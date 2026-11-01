# Day 10 labs: shifts, bit fields, floating point
DAY_TITLE="Shifts, bit fields, and floating point"

ctask 1 bits.c "The program gets one argument, a decimal number n from 0 to 255 (convert it with atoi). Print n as 8 binary digits, most significant bit first, using shifts and & (not division or %): bit i is (x >> i) & 1. Then print one space, the number of 1 bits, and a newline. Example: ./bits 37 prints 00100101 3. Exit status 0. If the number of arguments is not exactly one, or n is not between 0 and 255, print a message to standard error and exit with status 1."
crun '37'
crun '0'
crun '255'
crun '128'
crun '1'
crun '256'
crun ''

ctask 2 field.c "The program gets three decimal arguments x pos len (convert with atoi; store x in an unsigned int). Write a function unsigned int getfield(unsigned int x, unsigned int pos, unsigned int len) that returns the len bits of x starting at bit pos (bit 0 is the rightmost bit): shift right by pos, then AND with a mask of len ones, (1u << len) - 1. Print the result with %u and a newline. Example: ./field 1000 3 5 prints 29. Exit status 0. If there are not exactly three arguments, or pos < 0, len < 1 or pos + len > 31, print a message to standard error and exit with status 1."
crun '1000 3 5'
crun '240 4 4'
crun '255 0 8'
crun '5 0 1'
crun '5 1 1'
crun '3355443 8 8'
crun '7 30 2'
crun '1 2'

ctask 3 rwx.c "The program gets one argument: a permission mode written as exactly three octal digits, like the ones you gave chmod (e.g. 754). Build the mode as a number: for each digit d, mode = (mode << 3) | d. Then print the 9 permission letters as ls -l does, using a mask for each bit: 0400 is user read (r), 0200 user write (w), 0100 user execute (x), and so on down to 0001 other execute; print - for a bit that is 0. Example: ./rwx 754 prints rwxr-xr--. Exit status 0. If the number of arguments is not exactly one, the argument does not have exactly 3 characters, or a character is not 0 to 7, print a message to standard error and exit with status 1."
crun '754'
crun '644'
crun '000'
crun '777'
crun '421'
crun '701'
crun '78'
crun '758'
crun ''

ctask 4 tenths.c "The program gets one argument n (atoi). Add 0.1 to a double sum (starting at 0.0) n times in a loop, and compute exact = n / 10.0. Print sum and exact with %.17f, one per line. Then print equal if sum == exact; otherwise close if fabs(sum - exact) <= 1e-9; otherwise different. Example: ./tenths 10 prints 0.99999999999999989, then 1.00000000000000000, then close. Compile with -lm. Exit status 0. If the number of arguments is not exactly one, print a usage message to standard error and exit with status 1."
crun '10'
crun '3'
crun '0'
crun '1'
crun '4'
crun '1000'
crun ''
libs -lm

ctask 5 fmt.c "The program gets one argument x (convert with atof). Print x five times, one per line, with these conversions in this order: %f, %.2f, %e, %.3e, %g. Example: ./fmt 1234.5678 prints 1234.567800, 1234.57, 1.234568e+03, 1.235e+03, 1234.57. Exit status 0. If the number of arguments is not exactly one, print a usage message to standard error and exit with status 1."
crun '1234.5678'
crun '0.000012'
crun '2.5'
crun '-98765432.1'
crun '0'
crun ''
