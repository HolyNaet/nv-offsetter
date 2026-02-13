#pragma once

// #include <stdio.h>

#include <cstdlib>

#include "../include/nvml.h"
// #include "./printing.cpp"

// int select_device_index(const unsigned int dev_count) {
//   int devIdx = -1;
//
//   while (1) {
//     for (unsigned int i = 0; i < dev_count; ++i) printDevice(i);
//
//     printf("Choose which device to select: ");
//     scanf("%d", &devIdx);
//
//     if (devIdx >= 0 && devIdx < dev_count) break;
//     printf("Invalid Device ID, try again.\n");
//   }
//
//   return devIdx;
// }

int get_uuid(char* uuid) {
  int gpu_idx = 0;
  // unsigned int device_count = 0;

  nvmlDevice_t device;
  nvmlReturn_t ret;

  // code = nvmlDeviceGetCount_v2(&device_count);
  // if (!device_count || code != NVML_SUCCESS) return EXIT_FAILURE;

  // SLI is dead, typical laptops or desktop setups only have one dGPU
  // NVML is smart enough anyway, is it even worth implementing this?
  // if (device_count > 1) {
  //   printf("\nMultiple GPU devices detected.\n");
  //   gpu_idx = select_device_index(device_count);
  // }
  // if (gpu_idx == -1) return EXIT_FAILURE;

  ret = nvmlDeviceGetHandleByIndex_v2(gpu_idx, &device);
  if (ret != NVML_SUCCESS) return EXIT_FAILURE;
  ret = nvmlDeviceGetUUID(device, uuid, NVML_DEVICE_UUID_V2_BUFFER_SIZE);
  if (ret != NVML_SUCCESS) return EXIT_FAILURE;

  return EXIT_SUCCESS;
}
