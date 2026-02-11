#include <confuse.h>
#include <nvml.h>
#include <unistd.h>

#include <cstring>

#include "./offset.cu"
#include "./select-device.cu"

#define FREQ_LIMIT 2500

#define GRAPHICS "graphics"
#define GRAPHICS_MIN "graphics_min"
#define GRAPHICS_MAX "graphics_max"
#define MEMORY "mem"
#define MEM_MULT 2

#define STRING_BUF_SIZE 32

int validate_clk_cap_limit(cfg_t* cfg, cfg_opt_t* opt) {
  int value = cfg_opt_getnint(opt, cfg_opt_size(opt) - 1);
  if (value < 0) {
    cfg_error(cfg, "\"%s\" must be positive, found \"%d\"", opt->name, value);
    return CFG_PARSE_ERROR;
  }
  if (value > FREQ_LIMIT) {
    cfg_error(cfg, "\"%s\" must be lower than %d, found \"%d\"", opt->name,
              FREQ_LIMIT, value);
    return CFG_PARSE_ERROR;
  }
  return CFG_SUCCESS;
}

int validate_clk_limit(cfg_t* cfg, cfg_opt_t* opt) {
  int value = cfg_opt_getnint(opt, cfg_opt_size(opt) - 1);
  if (value < -FREQ_LIMIT || value > FREQ_LIMIT) {
    cfg_error(cfg, "\"%s\" must be within [-%d, %d], found \"%d\"", opt->name,
              FREQ_LIMIT, FREQ_LIMIT, value);
    return CFG_PARSE_ERROR;
  }
  return CFG_SUCCESS;
}

int main(int argc, char* argv[]) {
  if (getuid()) {
    printf("Root priviledges required\n");
    return EXIT_FAILURE;
  }

  // A very sloppy implementation indeed ;)
  // But then it's not like you can use C++ strings anyway
  // https://stackoverflow.com/a/9917145
  char conf_path[STRING_BUF_SIZE];
  const char* strings[] = {"/etc/", basename(argv[0]), ".conf"};

  for (auto str : *&strings)
    strncat(conf_path, str, sizeof(conf_path) - strlen(conf_path) - 1);

  cfg_opt_t opts[] = {CFG_INT(GRAPHICS, 0, CFGF_NONE),
                      CFG_INT(GRAPHICS_MIN, 0, CFGF_NONE),
                      CFG_INT(GRAPHICS_MAX, FREQ_LIMIT - 50, CFGF_NONE),
                      CFG_INT(MEMORY, 0, CFGF_NONE), CFG_END()};

  cfg_t* cfg = cfg_init(opts, CFGF_NONE);

  cfg_set_validate_func(cfg, GRAPHICS, validate_clk_limit);
  cfg_set_validate_func(cfg, GRAPHICS_MIN, validate_clk_cap_limit);
  cfg_set_validate_func(cfg, GRAPHICS_MAX, validate_clk_cap_limit);
  cfg_set_validate_func(cfg, MEMORY, validate_clk_limit);

  switch (cfg_parse(cfg, conf_path)) {
    case CFG_SUCCESS:
      break;
    case CFG_FILE_ERROR:
    case CFG_PARSE_ERROR:
      printf("Failed to open file \"%s\"\n", conf_path);
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
