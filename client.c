#include "header.h"
// #include <sys/types.h>

// unsigned int_to_int(unsigned k) {
//     if (k == 0) return 0;
//     if (k == 1) return 1;                       /* optional */
//     return (k % 2) + 10 * int_to_int(k / 2);
// }
static volatile sig_atomic_t g_sigsent = 0;

void sig_handler(int signum)
{
    g_sigsent = signum;
}

int send_char(pid_t spid, char c)
{
    char sig;

    printf("char to send:%d\n", c);

    for (int i = 7; i >= 0; i--)
    {
        printf("[%d] ", i);

        g_sigsent = 0;

        if (c & (1 << i))
            sig = HIGHSIG;
        else
            sig = LOWSIG;
        printf("%d ", sig == HIGHSIG);
    
        kill(spid, sig);
        while (!g_sigsent) {printf("pause\twaitingfor:%d ", sig);  pause();}
        if (g_sigsent != sig) 
            return -1;
        printf(" sig recieved\n");
    }
    printf("send_end\n");
    return 0;
}

void send0(pid_t spid) {
    int i;

    i = 0;

    while (i++ < 8)
    kill(spid, LOWSIG);
    // for (int i = 0; i < 7; i++)
    // {
    //     g_sigsent = 0;
    //     kill(spid, LOWSIG);
    //     printf("0[%d] \n", i);
    //     while (!g_sigsent) {printf("pause\twaitingfor:%d ", LOWSIG);  pause();}
    //     if (g_sigsent != LOWSIG)
    //         printf("error\n");
    // }

}
int send_message(int spid, char *mes)
{
    struct sigaction sa = {0};
    sa.sa_handler = &sig_handler;
    sigaction(HIGHSIG, &sa, NULL);
    sigaction(LOWSIG, &sa, NULL);
    u_char size = (u_char)ft_strlen(mes);
    if ((int)size != ft_strlen(mes))
        return (ft_write("The message is too long\nMax size: 255\n"), -1);
    if (send_char(spid, size))
            return (ft_write("Could not pass the size of message"), -1);
    while (*mes)
    {
        if (send_char(spid, *mes))
            return (ft_write("Char was not sent:") || ft_write(mes) || 1);
        mes++;
    }
    printf("huyamba\n");
    send_char(spid, 0);
    // send0(spid);
    printf("afterhuyamba\n");
    return (0);
}

int main(int argc, char *argv[])
{
    int pid = getpid();
    if (argc != 3)
        printf("[пидарасина #%d] сука пидор где пид и месаг?\nпошел нахуй!\n", pid);
    else
    {
        int spid = atoi(argv[1]);
        printf("[пидарасина #%d] ща посмотрим че в твоем %d\n", pid, spid);
        if (kill(spid, 0))
            return (printf("[пидарасина #%d] та хули ты пиздишь уебок там бля нет нихуя\nпошел нахуй!\n", pid), 0);
        else

        // printf("[пидарасина #%d] > %s\nзакинул тебе за щеку проверяй)\n", pid, argv[2]);
        if (send_message(spid, argv[2])) 
            ft_write("Error sending message\n");
        else printf("hui!");
    }
    return 0;
}