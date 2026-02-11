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
                          const nvmlClockType_t clk_domain,
                          const int clk_offset) {
  // Too bad my GPU doesn't support SM nor Video clocks offset
  // Not like I expect it to be used on any enterprise stuff anyway
  if (clk_domain == 1 || clk_domain == 3) return NVML_ERROR_NOT_SUPPORTED;

  nvmlReturn_t ret_code = NVML_SUCCESS;
  nvmlClockOffset_v1_t clk_target = {
      .version = nvmlClockOffset_v1,
      .type = clk_domain,
  };

  ret_code = nvmlDeviceGetClockOffsets(gpu_handle, &clk_target);
  if (ret_code != NVML_SUCCESS)
    printf("Warning: Failed to retrieve current clock offsets, ignoring\n");
  else if (clk_offset == clk_target.clockOffsetMHz) {
    printf("Target offset clock not changed, skipping\n");
    return ret_code;
  }

  clk_target.clockOffsetMHz = clk_offset;
  ret_code = nvmlDeviceSetClockOffsets(gpu_handle, &clk_target);
  return ret_code;
}

int offset_device(const nvmlDevice_t gpu_handle, const int graphics_offset,
                  const unsigned int graphics_clk_range[2],
                  const int mem_offset, const int mem_mult) {
  nvmlReturn_t ret_code;

  printf("Clamping graphics clocks to [%u, %u]MHz\n", graphics_clk_range[0],
         graphics_clk_range[1]);
  ret_code = nvmlDeviceSetGpuLockedClocks(gpu_handle, graphics_clk_range[0],
                                          graphics_clk_range[1]);
  if (ret_code != NVML_SUCCESS) {
    printf("Failed to clamp: %s", nvmlErrorString(ret_code));
    return EXIT_FAILURE;
  }

  printf("Attempting to offset graphics clock by %dMHz\n", graphics_offset);
  ret_code = offset_clock(gpu_handle, NVML_CLOCK_GRAPHICS, graphics_offset);
  if (ret_code != NVML_SUCCESS) {
    printf("Failed to offset: %s\n", nvmlErrorString(ret_code));
    return EXIT_FAILURE;
  }

  printf("Attempting to offset memory clock by %dMHz\n", mem_offset);
  ret_code = offset_clock(gpu_handle, NVML_CLOCK_MEM, mem_offset * mem_mult);
  if (ret_code != NVML_SUCCESS) {
    printf("Failed to offset: %s\n", nvmlErrorString(ret_code));
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
