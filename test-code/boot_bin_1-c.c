//#include <stdio.h>
extern int putchar1(char ch);
int functionC() {
    printf("in functionC...");
    int a = 0xbeef;
    return a;
}

int functionC2int(int p1, int p2) {
    int c;
    c =  p1 * 2;
    return c;
}

int functionC2long(long int p1, long int p2) {
    long int c;
    c =  p1 * 2;
    return c;
}

void printf(char * pStr) {
	int i;
//	int counter = 0;
	while (pStr[i] != 0) {
		putchar1(pStr[i]);
/*		counter ++;
		if (counter > 100) {
			return 1;
		}
*/
	}

	return 0;
}
