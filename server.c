#include "header.h"

// void sig_handler(int signum, siginfo_t *siginfo, void *ucontext)
// {
//     printf("Received signal %d\n", signum);
//         static int cnt = 0;
//     (void)ucontext;

//     cnt++;
//     if (siginfo->si_code == SI_USER || siginfo->si_code == SI_QUEUE)
//         kill(siginfo->si_pid, SIGUSR1);
//     else 
//         kill(siginfo->si_pid, SIGUSR2);

//     printf("#%d\n", cnt);
//     printf("\tsi_signo: %d \n", siginfo->si_signo);
//     printf("\tsi_code.: %d\n", siginfo->si_code);
//     printf("\tsi_errno: %d\n", siginfo->si_errno);
//     if (siginfo->si_code == SI_USER || siginfo->si_code == SI_QUEUE) {
//       printf("\tsi_pid..: %d\n", siginfo->si_pid);
//       printf("\tsi_uid..: %d\n", siginfo->si_uid);
//     }
// }
Client *head = NULL;

Client *new_client(pid_t pid) {
    Client *new;

    new = malloc(sizeof(Client));
    if (!new)
        return 0;
    new -> pid = pid;
    new -> mes = 0;
    new -> idx = -1;
    new -> size = 0;
    new -> bit = 0;
    new -> bit_counter = 0;
    printf("client %d created\n", pid);

    return new;
}

Client *get_client(pid_t pid) {
    Client *client = head;
    while (client)
     {
        if (client->pid == pid)
            return client;
        client = client->next;
     }
    client = new_client(pid);
    if (!client)
        return 0;
    client -> next = head;
    head = client;
    return client;
}

void del_client(pid_t pid) {
    Client *cur = head;
    Client *prev = NULL;
    while (cur)
    {
        if (cur->pid == pid)
        {
            if (prev)
                prev->next = cur->next;
            else
                head = cur->next;
            free(cur);
            return;
        }
        prev = cur;
        cur = cur->next;
    }
}

int add_char(Client *client, int signum)
{
    client -> bit <<= 1;
    client -> bit |= (signum == HIGHSIG);
    // printf("%d", signum == HIGHSIG);
    // if (signum == HIGHSIG)
        // client->bin |= 1 << client->idx;
    client->bit_counter++;
    if (client->bit_counter == 8)
    {
        // getting size 
        if (client->idx < 0) 
        {
            client->size = (int)client->bit;
            client->mes = malloc(client->size + 1);
            if (!client->mes)
                return -1;
            client->idx = client->bit = client->bit_counter = 0;
        } // getting message 
        else {
            client->mes[client->idx++] = client->bit;
            // printf("added char to %d: %c\nsize: %d, idx:%d\n", client->pid, client->bit, client->size, client->idx);

            if (client->bit == 0)
            // if (client->idx == client->size + 1)
            {
                client->mes[client->idx] = 0;
                ft_write(client->mes);
                del_client(client -> pid);
                printf("\nclient deleted\n");

                // client->idx = client->size = client->bit = client->bit_counter = 0;
            } else {
                client->bit = client->bit_counter = 0;
            }
        }
        // if (client->bin == 0)
        // {
        //     printf("ДОН\n");
        //     return;
        // }
        // printf("%c", client->bin);
        // client->bin = 0;
        // client->idx = 0;
    }
    return 0;
}

// send the opposite signal to notice the client that an error has occured
void send_error(pid_t pid, int signum) {
    if (signum == HIGHSIG)
        kill(pid, LOWSIG);
    else
        kill(pid, HIGHSIG);
}

void sig_handler(int signum, siginfo_t *siginfo, void *ucontext)
{
    Client *client;
    int pid;

    pid = siginfo->si_pid;
    client = get_client(pid);
    if (!client || add_char(client, signum))
        return (send_error(pid, signum));
    // printf("\nsending sig:%d\tbin:%d\tmes:%s\n", signum == HIGHSIG, client->bit, client->mes);
    kill(pid, signum);
    (void)ucontext;
}

int main()
{
    struct sigaction sa;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO;
    sa.sa_sigaction = sig_handler;
    sigaction(HIGHSIG, &sa, NULL);
    sigaction(LOWSIG, &sa, NULL);
    printf("=== SERVER STARTED WITH PID: %d ===\n",getpid());


    while (1)
    {
        sleep(1);
    }
    return 0;
}