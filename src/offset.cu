// https://docs.nvidia.com/deploy/nvidia-smi/index.html

// Thank lord they sorted the pstate out already:
// https://forums.developer.nvidia.com/t/nvmldevicegetminmaxclockofpstate-nvmldevicesetclockoffsets-issues/318332

// Personal observation in 2026-02-05: nvmlDeviceGetClockOffsets channges all
// pstate clocks regardless of the specified pstate. Therefore it is
// unnecessary to use a loop when offseting clocks of any domains.

#pragma once

#include <nvml.h>
#include <stdio.h>

#include <cstdio>
#include <cstdlib>

nvmlReturn_t offset_clock(const nvmlDevice_t gpu_handle,
                          nvmlClockOffset_v1_t clk_offset) {
  nvmlReturn_t ret_code = NVML_SUCCESS;
  nvmlClockOffset_v1_t temp_offset = clk_offset;

  ret_code = nvmlDeviceGetClockOffsets(gpu_handle, &temp_offset);
  if (ret_code != NVML_SUCCESS)
    printf("Warning: Failed to retrieve current clock offsets, ignoring\n");
  else if (clk_offset.clockOffsetMHz == temp_offset.clockOffsetMHz) {
    printf("Target offset clock not changed, skipping\n");
    return ret_code;
  }
  ret_code = nvmlDeviceSetClockOffsets(gpu_handle, &clk_offset);

  return ret_code;
}

int offset_clocks(const nvmlDevice_t gpu_handle, const int core_offset,
                  const unsigned int core_clk_range[2], const int mem_offset,
                  const int mem_mult) {
  nvmlReturn_t ret_code;
  nvmlClockOffset_v1_t clk_offset = {nvmlClockOffset_v1};

  printf("Clamping graphics clocks to [%u, %u]MHz\n", core_clk_range[0],
         core_clk_range[1]);
  ret_code = nvmlDeviceSetGpuLockedClocks(gpu_handle, core_clk_range[0],
                                          core_clk_range[1]);
  if (ret_code != NVML_SUCCESS) {
    printf("Failed to clamp: %s", nvmlErrorString(ret_code));
    return EXIT_FAILURE;
  }

  clk_offset.type = NVML_CLOCK_GRAPHICS;
  clk_offset.clockOffsetMHz = core_offset;
  printf("Attempting to offset core clock by %dMHz\n",
         clk_offset.clockOffsetMHz);
  ret_code = offset_clock(gpu_handle, clk_offset);
  if (ret_code != NVML_SUCCESS) {
    printf("Failed to offset: %s\n", nvmlErrorString(ret_code));
    return EXIT_FAILURE;
  }

  clk_offset.type = NVML_CLOCK_MEM;
  clk_offset.clockOffsetMHz = mem_mult * mem_offset;
  printf("Attempting to offfset memory clocks by %dMHz\n",
         clk_offset.clockOffsetMHz / mem_mult);
  ret_code = offset_clock(gpu_handle, clk_offset);
  if (ret_code != NVML_SUCCESS) {
    printf("Failed to offset: %s\n", nvmlErrorString(ret_code));
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
