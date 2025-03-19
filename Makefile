CC = cc
CFLAGS = -Wall -Wextra -Werror -std=c11

SERVER =  server
SERVER_C = $(SERVER:=.c)
# SERVER_O = $(SERVER_C:.c=.o)

CLIENT = client
CLIENT_C = $(CLIENT:=.c)
# CLIENT_O = $(CLIENT_C:.c=.o)

DEPS = header.h utils.c
all: $(SERVER) $(CLIENT)

$(SERVER): $(SERVER_C) $(DEPS)
	$(CC) $(CFLAGS) $(SERVER_C) $(DEPS) -o $(SERVER)
	
$(CLIENT): $(CLIENT_C) $(DEPS)
	$(CC) $(CFLAGS) $(CLIENT_C) $(DEPS) -o $(CLIENT)
	

kill:
	@pids=$$(ps aux | grep -P "./server(\s+\d+)?$$" | grep -v grep | awk '{print $$2}'); \
	if [ -n "$$pids" ]; then \
		echo "killed: $$pids"; \
		kill -9 $$pids 2>/dev/null || true; \
	else \
		echo "No server processes found."; \
	fi

slist:
	@pids=$$(ps aux | grep -P "./server(\s+\d+)?$$" | grep -v grep | awk '{print $$2}'); \
	if [ -n "$$pids" ]; then \
		echo "$$pids"; \
	else \
		echo "no servers found"; \
	fi


clean:
	rm -f $(SERVER) $(CLIENT)

fclean: clean

re: fclean all

# run:
# 	./$(SERVER)
# 	./$(CLIENT) $(pgrep -n server)

.PHONY: all clean fclean re run
