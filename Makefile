
CC ?= gcc
BUILD ?= release

build.release:=-O3
build.debug:=-O0 -g3
BUILD_FLAGS:=$(build.$(BUILD))

INC:=-Idep/swill/Include -Idep/lodepng -Idep/logc -Idep/fann/src/include
CFLAGS ?= -Wall -Werror -Wextra -Wno-cast-function-type -O0 $(INC) $(BUILD_FLAGS)
LDFLAGS:=-lm -Ldep/swill/ -lswill -Ldep/fann -lfann

FILES:=src/swell.c dep/lodepng/lodepng.c dep/logc/log.c

.PHONY: all
all: swell

swell: dep/swill/libswill.a dep/fann/libfann.a
	mkdir -p build
	$(CC) $(FILES) $(CFLAGS) $(LDFLAGS) -o build/swell

.ONESHELL:
dep/swill/libswill.a:
	cd dep 
	-git clone https://github.com/dspinellis/swill
	cd dep/swill
	git checkout fafde7646c39bfc3b30521dbcda9efaa94396b0e
	./configure
	make -j

.ONESHELL:
dep/fann/libfann.a:
	cd dep 
	-git clone https://github.com/libfann/fann
	cd fann
	git checkout 7ec1fc7e5bd734f1d3c89b095e630e83c86b9be1
	mkdir build
	cd build
	cmake ..
	make -j fann_static
	cp src/libfann.a ..


.PHONY: clean
clean:
	rm build -rf

