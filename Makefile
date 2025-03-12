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
