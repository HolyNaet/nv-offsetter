// uhh, yeah, string for std::string, the other for basename
#include <confuse.h>
#include <string.h>
#include <unistd.h>

#include <cstdlib>
#include <string>

#include "../include/nvml.h"
#include "./cfg-validation.cpp"
#include "./offset.cpp"
#include "./select-device.cpp"

#define GRAPHICS "graphics"
#define GRAPHICS_MIN "graphics_min"
#define GRAPHICS_MAX "graphics_max"
#define MEMORY "mem"
#define MEM_MULT 2

int main(int argc, char* argv[]) {
  if (getuid()) {
    printf("Root priviledges required\n");
    return EXIT_FAILURE;
  }

  // TODO: README.md
  std::string conf_path = "/etc/";
  const std::string strings[] = {basename(argv[0]), ".conf"};

  for (auto str : *&strings) conf_path.append(str);

  cfg_opt_t opts[] = {CFG_INT(GRAPHICS, 0, CFGF_NONE),
                      CFG_INT(GRAPHICS_MIN, 0, CFGF_NONE),
                      CFG_INT(GRAPHICS_MAX, FREQ_LIMIT - 50, CFGF_NONE),
                      CFG_INT(MEMORY, 0, CFGF_NONE), CFG_END()};

  cfg_t* cfg = cfg_init(opts, CFGF_NONE);

  cfg_set_validate_func(cfg, GRAPHICS, validate_clk_limit);
  cfg_set_validate_func(cfg, GRAPHICS_MIN, validate_clk_cap_limit);
  cfg_set_validate_func(cfg, GRAPHICS_MAX, validate_clk_cap_limit);
  cfg_set_validate_func(cfg, MEMORY, validate_clk_limit);

  switch (cfg_parse(cfg, conf_path.c_str())) {
    case CFG_SUCCESS:
      break;
    case CFG_FILE_ERROR:
    case CFG_PARSE_ERROR:
      printf("Failed to open file \"%s\"\n", conf_path.c_str());
      cfg_free(cfg);
      return EXIT_FAILURE;
  }

  // Should do something about this
  const int graphics_offset = cfg_getint(cfg, GRAPHICS);
  const unsigned int graphics_clk_range[] = {
      static_cast<unsigned int>(cfg_getint(cfg, GRAPHICS_MIN)),
      static_cast<unsigned int>(cfg_getint(cfg, GRAPHICS_MAX))};
  const int mem_offset = cfg_getint(cfg, MEMORY);

  cfg_free(cfg);

  char uuid[NVML_DEVICE_UUID_V2_BUFFER_SIZE];
  nvmlDevice_t gpu;
  nvmlReturn_t nvml_ret_code;
  int ret_code;

  nvml_ret_code = nvmlInit_v2();
  if (nvml_ret_code != NVML_SUCCESS) {
    printf("Failed to initialize NVML (%s)\n", nvmlErrorString(nvml_ret_code));
    return EXIT_FAILURE;
  }

  ret_code = get_uuid(uuid);
  if (ret_code != EXIT_SUCCESS) {
    printf("Failed to retrieve UUID\n");
    return EXIT_FAILURE;
  }
  if (!*uuid) {
    printf("No GPU device detected, exiting\n");
    return EXIT_FAILURE;
  }

  nvml_ret_code = nvmlDeviceGetHandleByUUID(uuid, &gpu);
  if (nvml_ret_code != NVML_SUCCESS) {
    printf("Failed to retrieve gpu %s: %s\n", uuid,
           nvmlErrorString(nvml_ret_code));
    return EXIT_FAILURE;
  }

  ret_code = offset_device(gpu, graphics_offset, graphics_clk_range, mem_offset,
                           MEM_MULT);
  if (ret_code != EXIT_SUCCESS) {
    printf("Something went wrong\n");
  }

  nvml_ret_code = nvmlShutdown();
  if (nvml_ret_code != NVML_SUCCESS) {
    printf("Failed to shut down NVML: %s\n", nvmlErrorString(nvml_ret_code));
    return EXIT_FAILURE;
  }

  printf("Exiting\n");
  return EXIT_SUCCESS;
}
