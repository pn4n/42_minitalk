#include "header.h"

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
			free(mes);
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
	client->bit_counter++;
	if (client->bit_counter == 8)
	{
		// getting size 
		if (client->idx < 0) 
		{
			// add byte to size
			if ((int)client->bit)
			{
				client->size <<= 8;
				client->size |= (int)client->bit;
				client->bit = client->bit_counter = 0;
			}
			else { // end of size
				client->mes = malloc(client->size + 1);
				if (!client->mes)
					return -1;
				client->idx = client->bit = client->bit_counter = 0;
			}
		} // getting message 
		else {
			client->mes[client->idx++] = client->bit;

			if (client->bit == 0)
			{
				ft_write(client->mes);
				del_client(client -> pid);

			} else {
				client->bit = client->bit_counter = 0;
			}
		}
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
	kill(pid, signum);
	(void)ucontext;
}

int main(int argc, char **argv)
{
	struct sigaction sa;

	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_SIGINFO;
	sa.sa_sigaction = sig_handler;
	sigaction(HIGHSIG, &sa, NULL);
	sigaction(LOWSIG, &sa, NULL);
	if (argc == 1)
		pid_print();
	while (1)
		sleep(1);
	(void)argv;
	return 0;
}
