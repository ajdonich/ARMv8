#include <cstdio>

const int LEN = 9;
int array[LEN] = {12, 33, 18, 32, 55, 78, 15, 42, 7};
int swap[LEN] = {0};

void mergesort(int lo, int hi) {
    if (lo == hi) return;

    int mid = (lo+hi)/2;
    mergesort(lo, mid);
    mergesort(mid+1, hi);

    int i = lo;
    int j = mid+1;
    int sz = hi-lo+1;

    for (int k=0; k<sz; ++k) {
        if (i > mid) {
            swap[k] = array[j];
            j += 1;
        }
        else if (j > hi) {
            swap[k] = array[i];
            i += 1;
        }
        else if (array[i] < array[j]) {
            swap[k] = array[i];
            i += 1;
        }
        else {
            swap[k] = array[j];
            j += 1;
        }
    }

    for (int k=0; k<sz; ++k)
        array[lo+k] = swap[k];
}

int main(int argc, char *argv[]) {
    mergesort(0, LEN-1);

    printf("[");
    for (int i=0; i<(LEN-1); ++i)
        printf("%d,", array[i]);
    printf("%d]\n", array[LEN-1]);

    return 0;
}
