#include "header.h"

static volatile sig_atomic_t g_sigsent = 0;

void sig_handler(int signum)
{
	g_sigsent = signum;
}

int send_char(pid_t spid, char c)
{
	char sig;

	for (int i = 7; i >= 0; i--)
	{
		g_sigsent = 0;

		if (c & (1 << i))
			sig = HIGHSIG;
		else
			sig = LOWSIG;
		kill(spid, sig);
		while (!g_sigsent)
			pause();
		if (g_sigsent != sig) 
			return -1;
	}
	return 0;
}

int send_size(pid_t spid, uint size)
{
	char c;

	c = size & 0xFF;
	while (c) {
		printf("%d", c);
		if (send_char(spid, c))
			return -1;
		size >>= 8;
		c = size & 0xFF;
	}
	send_char(spid, 0);
	return 0;
}

int send_message(int spid, char *mes)
{
	struct sigaction sa = {0};
	sa.sa_handler = &sig_handler;
	sigaction(HIGHSIG, &sa, NULL);
	sigaction(LOWSIG, &sa, NULL);
	uint size = (uint)ft_strlen(mes);
	// if ((int)size != ft_strlen(mes))
	// 	return (ft_write("the message is too long\nmax size: 255\n"), -1);
	if (send_size(spid, size))
			return (ft_write("could not pass the size of message"), -1);
	while (*mes)
	{
		if (send_char(spid, *mes))
			return (ft_write("char was not sent:") || ft_write(mes) || 1);
		mes++;
	}
	send_char(spid, 0);
	return (0);
}

int main(int argc, char *argv[])
{
	if (argc != 3)
		ft_write("usage: ./client <pid> <message>\n");
	else
	{
		int spid = atoi(argv[1]);
		if (kill(spid, 0))
			return (ft_write("no proccess found with the given pid\n"), 0);
		else
		// pid_print();
		if (send_message(spid, argv[2])) 
			ft_write("error sending message\n");
	}
	return 0;
}