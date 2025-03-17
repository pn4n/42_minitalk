#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>

#define HIGHSIG SIGUSR1
#define LOWSIG SIGUSR2

int ft_strlen(char *str);
int ft_write(char *mes);
void pid_print();

typedef struct Client {
	pid_t pid;
	char *mes;
	short idx;
	uint size;
	char bit;
	u_char bit_counter;
	struct Client *next;
} Client;