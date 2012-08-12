#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void) {
    int fd = open("/dev/zero", O_RDWR);
    void *pa = mmap(0x800000, 0x1000, PROT_READ | PROT_WRITE | PROT_EXEC, 
                    MAP_FIXED|MAP_PRIVATE, fd, 0);
    if(pa == MAP_FAILED) {
        perror("mmap");
        exit(EXIT_FAILURE);
    }
    printf("Mapped memory at address %p\n", pa);
    return 0;
}

