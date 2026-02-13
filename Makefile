TARGET := nv-offsetter
SERVICE_FILE := ${TARGET}.service
SERVICE_DIR := /usr/lib/systemd/system

CXX := g++
CXXFLAGS := -O3 -Wall -Wpedantic
LDFLAGS := -lnvidia-ml -lconfuse

SRC := ./src/main.cpp
BUILD_DIR := ./build
INSTALL_DIR := /usr/sbin

all: ${SRC} get-nvml-header
	@if [[ ! -d ${BUILD_DIR} ]]; then mkdir ${BUILD_DIR}; fi
	${CXX} ${CXXFLAGS} ${LDFLAGS} ${SRC} -o ${BUILD_DIR}/${TARGET}

clean-build:
	if [[ -d ${BUILD_DIR} ]]; then rm -r ${BUILD_DIR}; fi

install: all
	install -Dm755 ${BUILD_DIR}/${TARGET} ${INSTALL_DIR}

install-systemd: install
	install -Dm644 ${SERVICE_FILE} ${SERVICE_DIR}

clean: clean-build
	if [[ -f ${INSTALL_DIR}/${TARGET} ]]; then rm ${INSTALL_DIR}/${TARGET}; fi
	if [[ -f ${SERVICE_DIR}/${SERVICE_FILE} ]]; then rm ${SERVICE_DIR}/${SERVICE_FILE}; fi

run: all
	${BUILD_DIR}/${TARGET}

get-nvml-header:
	@if [[ ! -d ./include ]]; then mkdir ./include ; fi
	@# It might not work for you, kind of hacky
	cp /opt/cuda/targets/x86_64-linux/include/nvml.h ./include/
