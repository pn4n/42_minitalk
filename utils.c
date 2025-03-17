#include "header.h"
#define _OPEN_SYS_ITOA_EXT
#include <stdlib.h>


int ft_strlen(char *str)
{
	int i = 0;
	while (str[i])
		i++;
	return i;
}

int ft_write(char *mes)
{
	write(1, mes, ft_strlen(mes));
	return 0;
}

void ft_putu(unsigned int n)
{
    if (n >= 10)
    {
        ft_putu(n / 10);
        ft_putu(n % 10);
    }
    else 
       write(1, (char []){ n + '0', 0}, 1);   
}


void pid_print() {
	ft_write("=== SERVER STARTED WITH PID: ");
	ft_putu(getpid());
	ft_write(" ===\n");
}