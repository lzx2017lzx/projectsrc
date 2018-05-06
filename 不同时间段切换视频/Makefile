
CC=g++
CPPFLAGS=
CFLAGS=-Wall -Wno-unused-but-set-variable
LIBS=

main=whentimeisupchangename
target=$(main)

src=whentimeisupchangename.cpp make_log.c
ALL:$(target)

$(main):$(src)
	$(CC) -o $@ $^ $(CFLAGS) 

clean:
	-rm -rf $(target) 

.PHONY: clean target

