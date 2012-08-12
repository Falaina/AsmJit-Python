#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    char *newargv[] = {"/lib/ld-linux.so", "./hello", NULL};
    char *newenviron[] = { NULL };

    execve("/lib/ld-linux.so.2", newargv, newenviron);
    perror("execve");   /* execve() only returns on error */
    exit(EXIT_FAILURE);
}

