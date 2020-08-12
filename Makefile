
CC ?= gcc
BUILD ?= release

build.release:=-O3
build.debug:=-O0 -g3
BUILD_FLAGS:=$(build.$(BUILD))

INC:=-Idep/swill/Include -Idep/lodepng -Idep/logc
CFLAGS ?= -Wall -Werror -Wextra -Wno-cast-function-type -O0 $(INC) $(BUILD_FLAGS)
LDFLAGS:=-Ldep/swill/ -lswill 

FILES:=src/swell.c dep/lodepng/lodepng.c dep/logc/log.c

.PHONY: all
all: swell

swell: dep/swill/libswill.a 
	mkdir -p build
	$(CC) $(FILES) $(CFLAGS) $(LDFLAGS) -o build/swell

.ONESHELL:
dep/swill/libswill.a:
	cd dep 
	-git clone https://github.com/dspinellis/swill
	cd dep/swill
	git checkout fafde7646c39bfc3b30521dbcda9efaa94396b0e
	./configure
	make


.PHONY: clean
clean:
	rm build -rf

