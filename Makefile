CC = cc
CFLAGS = -Wall -Wextra -Werror -std=c11

SERVER =  server
SERVER_C = $(SERVER:=.c)
SERVER_O = $(SERVER_C:.c=.o)

CLIENT = client
CLIENT_C = $(CLIENT:=.o)
CLIENT_O = $(CLIENT_C:.c=.o)

all: $(SERVER) $(CLIENT)

$(SERVER): $(SERVER_O)
	$(CC) $(CFLAGS) $(SERVER_O) -o $(SERVER)
	
# ./$(SERVER)

$(CLIENT): $(CLIENT_O)
	$(CC) $(CFLAGS) $(CLIENT_O) -o $(CLIENT)
	
# ./$(CLIENT) $(pgrep -n server)

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

# run:
# 	./$(SERVER)
# 	./$(CLIENT) $(pgrep -n server)

.PHONY: all clean fclean re run
