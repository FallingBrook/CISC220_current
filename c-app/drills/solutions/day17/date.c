#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: date YYYY-MM-DD\n");
        exit(1);
    }
    unsigned int year;
    unsigned int month;
    unsigned int day;
    int n = sscanf(argv[1], "%4u-%2u-%2u", &year, &month, &day);
    if (n != 3) {
        fprintf(stderr, "date: could not read a date from %s (%d numbers read)\n", argv[1], n);
        exit(1);
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
        fprintf(stderr, "date: month or day out of range\n");
        exit(1);
    }
    char out[11];   // dd/mm/yyyy + '\0'
    sprintf(out, "%02u/%02u/%04u", day, month, year);
    puts(out);
    return 0;
}
