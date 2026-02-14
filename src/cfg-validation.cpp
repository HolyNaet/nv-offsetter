#include <confuse.h>

// Arbitrary safeguard value
#define FREQ_LIMIT 2750

int validate_clk_cap_limit(cfg_t *cfg, cfg_opt_t *opt) {
    int value = cfg_opt_getnint(opt, cfg_opt_size(opt) - 1);
    if (value < 0) {
        cfg_error(cfg, "\"%s\" must be positive, found \"%d\"", opt->name,
                  value);
        return CFG_PARSE_ERROR;
    }
    if (value > FREQ_LIMIT) {
        cfg_error(cfg, "\"%s\" must be lower than %d, found \"%d\"", opt->name,
                  FREQ_LIMIT, value);
        return CFG_PARSE_ERROR;
    }
    return CFG_SUCCESS;
}

int validate_offset_limit(cfg_t *cfg, cfg_opt_t *opt) {
    int value = cfg_opt_getnint(opt, cfg_opt_size(opt) - 1);
    if (value < -FREQ_LIMIT || value > FREQ_LIMIT) {
        cfg_error(cfg, "\"%s\" must be within [-%d, %d], found \"%d\"",
                  opt->name, FREQ_LIMIT, FREQ_LIMIT, value);
        return CFG_PARSE_ERROR;
    }
    return CFG_SUCCESS;
}
