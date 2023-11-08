.PHONY: all build test

all: build test clean

build:
	mkdir build
	as -o build/mergesort.o mergesort.s
	ld -macos_version_min 13.0.0 -o build/MERGESORT build/mergesort.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _main -arch arm64 

test:
	build/MERGESORT

clean:
	rm -rf build