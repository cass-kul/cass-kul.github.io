TARGET = linked-list
LIBS =
CC = gcc
CFLAGS = -g -Wall -Werror

.PHONY: default all clean windows

default: $(TARGET)
	./$(TARGET)

all: default
windows: CFLAGS += -D_NO_MULTITHREAD
windows: default

OBJECTS = $(patsubst %.c, %.o, $(wildcard *.c))
HEADERS = $(wildcard *.h)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -Wall $(LIBS) -o $@

clean:
	-rm -f *.o
	-rm -f $(TARGET)

windows-clean:
	-del linked-list-test.o
	-del linked-list.o
	-del $(TARGET)
	-del $(TARGET).exe
