TARGET = lola

BIN = /usr/local/bin

C = ./bootstrap

SRC = src/Lola.Mod

FLAGS = elf64 \
	-tab 2 \
	-stk 2 \
	-upper \
	-out $(TARGET)

$(TARGET):
	$(C) $(SRC) $(FLAGS)
install:
	cp $(TARGET) $(BIN)
uninstall:
	-rm $(BIN)/$(TARGET)
clean:
	-rm $(TARGET)
