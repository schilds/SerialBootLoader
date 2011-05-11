ASM=nasm
JAVAC=javac
JAR=jar
BIN=../bin
all:
	$(JAVAC) -Xlint:deprecation -Xlint:unchecked serialclient/*.java
	$(JAR) cvfm serialclient.jar serialclient.mf serialclient/*.class
	$(ASM) -f bin -w+orphan-labels loader/loader.asm -o loader.bin
	mv serialclient.jar $(BIN)
	mv loader.bin $(BIN)
	
clean:
	rm `find -name '*.class'`
	rm `find -name '*.obj'`
