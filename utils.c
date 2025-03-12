#include <unistd.h>

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