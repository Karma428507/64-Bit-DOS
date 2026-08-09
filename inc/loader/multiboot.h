#ifndef LOADER_MULTIBOOT_H
#define LOADER_MULTIBOOT_H

#include <stdtype.h>

typedef struct {
    // Required
    uint32_t                flags;

    // Bit[0]
    uint32_t                mem_lower;
    uint32_t                mem_upper;

    // Bit[1]
    uint32_t                boot_device;
    
    // Bit[2]
    uint32_t                cmdline;

    // Bit[3]
    uint32_t                mods_count;
    uint32_t                mods_length;

    // Bit[4 & 5]
    uint32_t                syms[4];        // Work on later

    // Bit[6]
    uint32_t                mmap_length;
    uint32_t                mmap_addr;

    // Bit[7]
    uint32_t                drives_length;
    uint32_t                drives_addr;

    // Bit[8]
    uint32_t                config_table;

    // Bit[9]
    uint32_t                boot_loader_name;

    // Bit[10]
    uint32_t                amp_table;

    // Bit[11]
    uint32_t                vbe_control_info;
    uint32_t                vbe_mode_info;
    uint32_t                vbe_mode;
    uint32_t                vbe_interface_seg;
    uint32_t                vbe_interface_off;
    uint32_t                vbe_interface_len;

    // Bit[12]
    uint32_t                framebuffer_addr;
    uint32_t                framebuffer_pitch;
    uint32_t                framebuffer_width;
    uint32_t                framebuffer_height;
    uint32_t                framebuffer_bpp;
    uint32_t                framebuffer_type;
    uint32_t                color_info;


} MULTIBOOT_INFO;

#endif
