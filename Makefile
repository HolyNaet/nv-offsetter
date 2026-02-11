TARGET := nv-offsetter

ESCALATE := sudo
CU := nvcc
CUFLAGS := -O3 -arch=sm_86
LINKS := -lnvidia-ml -lconfuse

SRC := ./src/main.cu
BUILD_DIR := ./build
INSTALL_DIR := /usr/local/bin/

.PHONY: all
all: ${SRC}
	@if [[ ! -d ${BUILD_DIR} ]]; then mkdir ${BUILD_DIR}; fi
	${CU} ${CUFLAGS} ${LINKS} ${SRC} -o ${BUILD_DIR}/${TARGET}

# Yeah, it's sloppy, but what are you going to do do about it?
install: all
	${ESCALATE} install -Dm755 ${BUILD_DIR}/${TARGET} ${INSTALL_DIR}

.PHONY: test
test: all
	@echo "There isn't proper test yet, sorry!"
	${ESCALATE} ${BUILD_DIR}/${TARGET}

.PHONY: clean
clean:
	rm -r ${BUILD_DIR}
	${ESCALATE} rm ${INSTALL_DIR}${TARGET}
