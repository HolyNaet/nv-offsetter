#pragma once

// #include <stdio.h>

#include <cstdlib>

#include "../include/nvml.h"

int get_uuid(char *uuid) {
    int gpu_idx = 0;

    nvmlDevice_t device;
    nvmlReturn_t ret;

    ret = nvmlDeviceGetHandleByIndex_v2(gpu_idx, &device);
    if (ret != NVML_SUCCESS) return EXIT_FAILURE;
    ret = nvmlDeviceGetUUID(device, uuid, NVML_DEVICE_UUID_V2_BUFFER_SIZE);
    if (ret != NVML_SUCCESS) return EXIT_FAILURE;

    return EXIT_SUCCESS;
}
