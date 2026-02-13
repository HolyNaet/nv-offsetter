TARGET := nv-offsetter

CXX := g++
CXXFLAGS := -O3 -Wall -Wpedantic
# CU := nvcc
# CUFLAGS := -O3 -arch=sm_86
LDFLAGS := -lnvidia-ml -lconfuse

SRC := ./src/main.cpp
BUILD_DIR := ./build
INSTALL_DIR := /usr/local/bin/

.PHONY: all
all: ${SRC} get-nvml-header
	@if [[ ! -d ${BUILD_DIR} ]]; then mkdir ${BUILD_DIR}; fi
	@# ${CU} ${CUFLAGS} ${LDFLAGS} ${SRC} -o ${BUILD_DIR}/${TARGET}
	${CXX} ${CXXFLAGS} ${LDFLAGS} ${SRC} -o ${BUILD_DIR}/${TARGET}

# It might not work for you, kind of hacky
get-nvml-header:
	@if [[ ! -d ./include ]]; then mkdir ./include ; fi
	cp /opt/cuda/targets/x86_64-linux/include/nvml.h ./include/

# Yeah, it's sloppy, but what are you going to do do about it?
install-local: all
	install -Dm755 ${BUILD_DIR}/${TARGET} ${INSTALL_DIR}

.PHONY: test
test: all
	@echo "There isn't proper test yet, sorry!"
	${BUILD_DIR}/${TARGET}

.PHONY: clean
clean:
	rm -r ${BUILD_DIR}
	rm ${INSTALL_DIR}${TARGET}
