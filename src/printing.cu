// I keep files like this mostly for convenience, please don't delete it for no
// good reason, the compiler won't even touch it
#pragma once

#include <nvml.h>
#include <stdio.h>

/**
 * For debugging purpose
 */
void printPstateInfo(const nvmlClockOffset_v1_t obj) {
  printf(
      "version:%d\ntype:%d\npstate:%d\noffsetMHz:%d\nminClk:%d\nmaxClk:%d\n\n",
      obj.version, obj.type, obj.pstate, obj.clockOffsetMHz,
      obj.minClockOffsetMHz, obj.maxClockOffsetMHz);
}

/**
 * For debugging purpose
 */
void printThingy(const nvmlDevice_t gpuHandle,
                 nvmlClockOffset_v1_t* clkOffset) {
  printf("Pre:\n");
  printPstateInfo(*clkOffset);
  nvmlDeviceGetClockOffsets(gpuHandle, clkOffset);
  printf("Post:\n");
  printPstateInfo(*clkOffset);
}

void printDevice(const unsigned int index) {
  nvmlDevice_t tempDevice;
  nvmlDeviceGetHandleByIndex_v2(index, &tempDevice);

  char name[NVML_DEVICE_UUID_V2_BUFFER_SIZE];
  nvmlDeviceGetName(tempDevice, name, NVML_DEVICE_UUID_V2_BUFFER_SIZE);

  char uuid[NVML_DEVICE_UUID_V2_BUFFER_SIZE];
  nvmlDeviceGetUUID(tempDevice, uuid, NVML_DEVICE_UUID_V2_BUFFER_SIZE);

  printf("Device Index: %d\n", index);
  printf("Device Name: %s\n", name);
  printf("UUID: %s\n\n", uuid);
}
