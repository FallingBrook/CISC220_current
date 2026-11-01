# Day 4 labs: functions, the math library, and errors
DAY_TITLE="Functions, the math library, and errors"

ctask 1 power.c "Write power.c. It takes exactly two command line arguments, a number x (convert it with atof) and a whole number n >= 0 (convert it with atoi), and prints x to the power n with printf(\"%f\\n\", ...). Do NOT use pow: write your own function double power(double x, unsigned int n) that multiplies in a loop (x to the power 0 is 1). If the number of arguments is not 2, print a usage message such as Usage: power x n to standard error and exit with status 1. Example: ./power 2 10 prints 1024.000000"
crun '2 10'
crun '1.5 3'
crun '-2 3'
crun '7 0'
crun '0.5 1'
crun ''
crun '2'
crun '2 3 4'

ctask 2 hyp.c "Write hyp.c. It takes exactly two command line arguments a and b (convert them with atof) and prints the length of the hypotenuse, the square root of a*a + b*b, using sqrt from <math.h>, with printf(\"%.4f\\n\", ...). If the number of arguments is not 2, print a usage message such as Usage: hyp a b to standard error and exit with status 1. Example: ./hyp 3 4 prints 5.0000"
libs -lm
crun '3 4'
crun '1 1'
crun '5 12'
crun '-3 4'
crun 'abc 4'
crun ''
crun '3'
crun '1 2 3'

ctask 3 average.c "Write average.c. It prints the average (mean) of ALL its command line arguments, each converted with atof, with printf(\"%.3f\\n\", ...). Any number of arguments (one or more) is allowed. If there are no arguments at all, print a usage message such as Usage: average x1 x2 ... to standard error and exit with status 1 (try exit(1) from <stdlib.h>). Example: ./average 1 2 3 4 prints 2.500"
crun '5'
crun '1 2'
crun '1 2 3 4'
crun '-1.5 2.5 abc'
crun '0.1 0.2 0.3 0.4 0.5 0.6 0.7'
crun ''

ctask 4 geometric.c "Write geometric.c. It takes exactly two command line arguments, a number r (atof) and a whole number n >= 0 (atoi), and prints the sum of the first n terms of the geometric series 1 + r + r^2 + r^3 + ... with printf(\"%.10f\\n\", ...). Use a function double geometric(double r, int n) with a running total; you may use pow. With n = 0 there are no terms, so the sum is 0. If the number of arguments is not 2, print a usage message such as Usage: geometric r n to standard error and exit with status 1. Example: ./geometric 0.5 3 prints 1.7500000000"
libs -lm
crun '0.5 3'
crun '0.5 30'
crun '2 5'
crun '-0.5 4'
crun '1 3'
crun '0.5 0'
crun ''
crun '0.5'
