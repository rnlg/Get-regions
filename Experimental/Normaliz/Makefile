CC = g++
CFLAGS = -fPIC -O2 -shared
INCLUDES = -I/usr/local/Wolfram/Wolfram/15.0/SystemFiles/IncludeFiles/C -I/usr/include/libnormaliz
LIBS = -L/usr/lib/x86_64-linux-gnu -lnormaliz -lgmp

# Target library name
TARGET = ConvexHullNormaliz.so
SOURCE = ConvexHullNormaliz.cpp

# Compilation rule
$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(TARGET) $(SOURCE) $(LIBS)

# Clean rule
clean:
	rm -f $(TARGET)

# Install rule (optional, copies to a standard location)
install: $(TARGET)
	cp $(TARGET) ~/.Mathematica/SystemAdditions/Libraries/Linux-x86-64/

.PHONY: clean install