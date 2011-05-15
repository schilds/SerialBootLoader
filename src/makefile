ASM = nasm
JAVAC = javac
JAR = jar
BIN = ../bin

JAVA_SRC := $(wildcard serialclient/*.java)
JAVA_OBJ = serialclient/*.class


all: $(BIN)/loader.bin $(BIN)/serialclient.jar

$(BIN)/loader.bin: loader/loader.asm
	$(ASM) -f bin -w+orphan-labels loader/loader.asm -o loader.bin
	mv loader.bin $(BIN)
	
$(BIN)/serialclient.jar: $(JAVA_SRC)
	$(JAVAC) -Xlint:deprecation -Xlint:unchecked $(JAVA_SRC)
	$(JAR) cvfm serialclient.jar serialclient.mf $(JAVA_OBJ)
	rm `find -name '*.class'`
	mv serialclient.jar $(BIN)

clean:
	rm $(BIN)/loader.bin $(BIN)/serialclient.jar