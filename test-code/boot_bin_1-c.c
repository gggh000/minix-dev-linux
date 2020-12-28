/*
 * A small program that illustrates how to call the maxofthree function we wrote in
 * assembly language.
 */

//#include <stdio.h>
//#include <inttypes.h>

long int maxofthree(long int, long int, long int);

int main() {
    maxofthree(1, -4, -7);
/*    printf("%ld\n", maxofthree(1, -4, -7));
    printf("%ld\n", maxofthree(2, -6, 1));
    printf("%ld\n", maxofthree(2, 3, 1));
    printf("%ld\n", maxofthree(-2, 4, 3));
    printf("%ld\n", maxofthree(2, -6, 5));
    printf("%ld\n", maxofthree(2, 4, 6));
*/
    return 0;
}


