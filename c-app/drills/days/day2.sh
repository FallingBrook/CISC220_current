# Day 2 labs: variables, types, printf and control flow (all programs use int main(void): no command line arguments yet)
DAY_TITLE="Variables, types, printf and control flow"

ctask squares squares.c "Print a table of squares and cubes for n = 1 to 12. The first line is exactly ' n    n^2    n^3' (one space, n, four spaces, n^2, four spaces, n^3). Then one line per n: n in a field of width 2, a space, n*n in a field of width 6, a space, n*n*n in a field of width 6 (hint: printf(\"%2d %6d %6d\\n\", ...)). Use a for loop with the counter declared in the for. Exit status 0."
crun ''

ctask sumto sumto.c "Declare const int n = 24; and use a while loop (not the formula) to add 1 + 2 + ... + n into an int. Print three lines: 'sum of 1..24 = 300', then 'formula n*(n+1)/2 = 300' (compute it with the formula this time), then 'average = 12.50' where the average is the sum divided by n as a double, printed with %.2f. Careful: int / int throws away the fraction, so cast first. Print the numbers with %d from your variables, do not type them into the string. Exit status 0."
crun ''

ctask larger larger.c "Write a function int larger(int a, int b) ABOVE main that returns the larger of its two parameters (either one if they are equal). main must print, using calls to larger: 'larger(3, 7) = 7', 'larger(10, -4) = 10', 'larger(-2, -9) = -2', 'larger(5, 5) = 5', and 'largest of 8, 12, 3 = 12' (call larger twice, one call inside the other). Each on its own line. Then main returns larger(0, 3), so the exit status is 3 (check with echo \$?)."
crun ''

ctask widths widths.c "Store 22.0 / 7.0 in a double x. Print x inside square brackets six times, one per line, using these conversions in order: %f, %.3f, %8.2f, %24.17f, then -x with %24.17f, then x with %.0f. The first lines are '[3.142857]', '[3.143]', '[    3.14]'. Last, print the line '100% done' by printing the int 100 with %d followed by a literal percent sign (you need %% in the format string). Exit status 0."
crun ''

ctask grades grades.c "Use a for loop that starts mark at 45 and goes up by 10 (mark += 10) while mark <= 95. For each mark print the mark in a field of width 3, a colon and a space (printf(\"%3d: \", mark)), then on the same line one word followed by a newline: 'A' if mark >= 80, else 'B' if mark >= 70, else 'pass' if mark >= 50, else 'fail'. Use if / else if / else. The first line is ' 45: fail'. Exit status 0."
crun ''
