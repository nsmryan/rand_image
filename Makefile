
CC ?= gcc
BUILD ?= release

build.release:=-O3
build.debug:=-O0 -g3
BUILD_FLAGS:=$(build.$(BUILD))

INC:=-Idep/swill/Include -Idep/lodepng -Idep/logc
CFLAGS ?= -Wall -Werror -Wextra -Wno-cast-function-type -O0 $(INC) $(BUILD_FLAGS)
LDFLAGS:=-lm -Ldep/swill/ -lswill 

FILES:=dep/lodepng/lodepng.c dep/logc/log.c

.PHONY: all
all: rand_image

rand_image: dep/swill/libswill.a 
	mkdir -p build
	$(CC) src/rand_image.c $(FILES) $(CFLAGS) $(LDFLAGS) -o build/rand_image

.ONESHELL:
dep/swill/libswill.a:
	cd dep 
	-git clone https://github.com/dspinellis/swill
	cd dep/swill
	git checkout fafde7646c39bfc3b30521dbcda9efaa94396b0e
	./configure
	make -j

build/%.o: %.c
	$(CC) $^ -o $@ -c $(CFLAGS) $(INC)
	cp $@ build/

.PHONY: clean
clean:
	rm build -rf

