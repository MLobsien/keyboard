const std = @import("std");

pub const qmk_firmware = "/home/mad5/qmk_firmware";

/// All `-D` defines from QMK cflags, organized by category.
pub fn addDefines(mod: *std.Build.Module) void {
    // ── Architecture / Platform ──
    mod.addCMacro("THUMB_PRESENT", "");
    mod.addCMacro("THUMB_NO_INTERWORKING", "");
    mod.addCMacro("PICO_NO_FPGA_CHECK", "1");
    // NDEBUG is defined by Zig for ReleaseSmall; skip to avoid redefinition

    // ── C library compatibility (for Aro C translation) ──
    // Zig's @cImport uses Aro, not Clang. Aro's built-in stddef.h does not
    // handle __need_wint_t, so newlib headers (via sys/_types.h) fail with
    // "unknown type name 'wint_t'". Defining wint_t as a macro works around this.
    mod.addCMacro("wint_t", "unsigned int");
    mod.addCMacro("CORTEX_USE_FPU", "FALSE");
    mod.addCMacro("PROTOCOL_CHIBIOS", "");
    mod.addCMacro("MCU_RP", "");
    mod.addCMacro("PLATFORM_SUPPORTS_SYNCHRONIZATION", "");
    mod.addCMacro("PORT_IGNORE_GCC_VERSION_CHECK", "1");
    mod.addCMacro("FIXED_CONTROL_ENDPOINT_SIZE", "64");
    mod.addCMacro("FIXED_NUM_CONFIGURATIONS", "1");
    mod.addCMacro("HAL_USE_SIO", "TRUE");
    mod.addCMacro("RP_SIO_USE_UART0", "TRUE");
    mod.addCMacro("BOOTLOADER_RP2040", "");

    // ── QMK Keyboard Identity ──
    mod.addCMacro("QMK_KEYBOARD", "fckqmk");
    mod.addCMacro("QMK_KEYBOARD_H", ".build/obj_fckqmk_default/src/default_keyboard.h");
    mod.addCMacro("QMK_KEYMAP", "default");
    mod.addCMacro("QMK_KEYMAP_H", "default.h");
    mod.addCMacro("QMK_KEYMAP_CONFIG_H", "keyboards/fckqmk/keymaps/default/config.h");
    mod.addCMacro("KEYBOARD_", "");
    mod.addCMacro("KEYBOARD_fckqmk", "");
    mod.addCMacro("KEYMAP_C", "keyboards/fckqmk/keymaps/default/keymap.c");

    // ── Feature enables ──
    mod.addCMacro("NVM_DRIVER_EEPROM", "");
    mod.addCMacro("NVM_DRIVER", "eeprom");
    mod.addCMacro("EEPROM_ENABLE", "");
    mod.addCMacro("EEPROM_VENDOR", "");
    mod.addCMacro("EEPROM_DRIVER", "");
    mod.addCMacro("EEPROM_WEAR_LEVELING", "");
    mod.addCMacro("WEAR_LEVELING_ENABLE", "");
    mod.addCMacro("WEAR_LEVELING_RP2040_FLASH", "");
    mod.addCMacro("FNV_ENABLE", "");
    mod.addCMacro("SPLIT_KEYBOARD", "");
    mod.addCMacro("SPLIT_COMMON_TRANSACTIONS", "");
    mod.addCMacro("SERIAL_DRIVER_VENDOR", "");
    mod.addCMacro("BOOTMAGIC_ENABLE", "");
    mod.addCMacro("CRC_ENABLE", "");
    mod.addCMacro("GRAVE_ESC_ENABLE", "");
    mod.addCMacro("MAGIC_ENABLE", "");
    mod.addCMacro("MOUSEKEY_ENABLE", "");
    mod.addCMacro("SEND_STRING_ENABLE", "");
    mod.addCMacro("SPACE_CADET_ENABLE", "");
    mod.addCMacro("MOUSE_ENABLE", "");
    mod.addCMacro("MOUSE_SHARED_EP", "");
    mod.addCMacro("EXTRAKEY_ENABLE", "");
    mod.addCMacro("NO_DEBUG", "");
    mod.addCMacro("NKRO_ENABLE", "");
    mod.addCMacro("SHARED_EP_ENABLE", "");

    // ── Pico SDK / platform tuning ──
    mod.addCMacro("PICO_DIVIDER_IN_RAM", "1");
    mod.addCMacro("PICO_DIVIDER_DISABLE_INTERRUPTS", "1");
    mod.addCMacro("PICO_INT64_OPS_IN_RAM", "1");

    // ── printf config ──
    mod.addCMacro("PRINTF_SUPPORT_DECIMAL_SPECIFIERS", "0");
    mod.addCMacro("PRINTF_SUPPORT_EXPONENTIAL_SPECIFIERS", "0");
    mod.addCMacro("PRINTF_SUPPORT_LONG_LONG", "0");
    mod.addCMacro("PRINTF_SUPPORT_WRITEBACK_SPECIFIER", "0");
    mod.addCMacro("SUPPORT_MSVC_STYLE_INTEGER_SPECIFIERS", "0");
    mod.addCMacro("PRINTF_ALIAS_STANDARD_FUNCTION_NAMES", "1");

    // ── Auto-generated QMK MCU identity ──
    mod.addCMacro("QMK_MCU", "RP2040");
    mod.addCMacro("QMK_MCU_RP2040", "");
    mod.addCMacro("QMK_MCU_ARCH", "cortex-m0plus");
    mod.addCMacro("QMK_MCU_ARCH_CORTEX_M0PLUS", "");
    mod.addCMacro("QMK_MCU_PORT_NAME", "RP");
    mod.addCMacro("QMK_MCU_PORT_NAME_RP", "");
    mod.addCMacro("QMK_MCU_FAMILY", "RP");
    mod.addCMacro("QMK_MCU_FAMILY_RP", "");
    mod.addCMacro("QMK_MCU_SERIES", "RP2040");
    mod.addCMacro("QMK_MCU_SERIES_RP2040", "");
    mod.addCMacro("QMK_BOARD", "GENERIC_PROMICRO_RP2040");
    mod.addCMacro("QMK_BOARD_GENERIC_PROMICRO_RP2040", "");
}

const path = std.Build.LazyPath;

/// All `-I` include paths from QMK cflags, organized by category.
/// Deduplicates automatically.
pub fn addIncludePaths(mod: *std.Build.Module) void {
    const qmk = qmk_firmware;
    var seen = std.StringHashMap(void).init(mod.owner.allocator);

    const entries = [_][]const u8{
        // ── Keyboard / user ──
        qmk ++ "/keyboards/fckqmk/keymaps/default",
        qmk ++ "/users/default",
        qmk ++ "/keyboards/fckqmk",

        // ── ChibiOS board configs ──
        qmk ++ "/platforms/chibios/boards/GENERIC_PROMICRO_RP2040/configs",
        qmk ++ "/platforms/chibios/boards/common/configs",

        // ── QMK core ──
        qmk,
        qmk ++ "/tmk_core",
        qmk ++ "/tmk_core/protocol",
        qmk ++ "/tmk_core/protocol/chibios",
        qmk ++ "/tmk_core/protocol/chibios/lufa_utils",
        qmk ++ "/quantum",
        qmk ++ "/quantum/keymap_extras",
        qmk ++ "/quantum/process_keycode",
        qmk ++ "/quantum/sequencer",
        qmk ++ "/quantum/nvm",
        qmk ++ "/quantum/nvm/eeprom",
        qmk ++ "/quantum/logging",
        qmk ++ "/quantum/wear_leveling",
        qmk ++ "/quantum/split_common",
        qmk ++ "/quantum/bootmagic",
        qmk ++ "/quantum/send_string",

        // ── Drivers ──
        qmk ++ "/drivers",
        qmk ++ "/drivers/eeprom",
        qmk ++ "/drivers/wear_leveling",

        // ── Platforms ──
        qmk ++ "/platforms",
        qmk ++ "/platforms/chibios",
        qmk ++ "/platforms/chibios/drivers",
        qmk ++ "/platforms/chibios/drivers/eeprom",
        qmk ++ "/platforms/chibios/drivers/wear_leveling",
        qmk ++ "/platforms/chibios/drivers/vendor/RP/RP2040",
        qmk ++ "/platforms/chibios/vendors/RP",

        // ── ChibiOS ──
        qmk ++ "/lib/chibios/os/license",
        qmk ++ "/lib/chibios/os/common/portability/GCC",
        qmk ++ "/lib/chibios/os/common/startup/ARMCMx/compilers/GCC",
        qmk ++ "/lib/chibios/os/common/startup/ARMCMx/devices/RP2040",
        qmk ++ "/lib/chibios/os/common/ext/ARM/CMSIS/Core/Include",
        qmk ++ "/lib/chibios/os/common/ext/RP/RP2040",
        qmk ++ "/lib/chibios/os/rt/include",
        qmk ++ "/lib/chibios/os/common/ports/ARM-common",
        qmk ++ "/lib/chibios/os/common/ports/ARMv6-M-RP2",
        qmk ++ "/lib/chibios/os/hal/osal/rt-nil",
        qmk ++ "/lib/chibios/os/oslib/include",
        qmk ++ "/lib/chibios/os/hal/include",
        qmk ++ "/lib/chibios/os/hal/ports/common/ARMCMx",
        qmk ++ "/lib/chibios/os/hal/ports/RP/RP2040",
        qmk ++ "/lib/chibios/os/hal/ports/RP/LLD/DMAv1",
        qmk ++ "/lib/chibios/os/hal/ports/RP/LLD/GPIOv1",
        qmk ++ "/lib/chibios/os/hal/ports/RP/LLD/SPIv1",
        qmk ++ "/lib/chibios/os/hal/ports/RP/LLD/TIMERv1",
        qmk ++ "/lib/chibios/os/hal/ports/RP/LLD/UARTv1",
        qmk ++ "/lib/chibios/os/hal/ports/RP/LLD/RTCv1",
        qmk ++ "/lib/chibios/os/hal/ports/RP/LLD/WDGv1",
        qmk ++ "/lib/chibios/os/hal/boards/RP_PICO_RP2040",
        qmk ++ "/lib/chibios/os/hal/lib/streams",
        qmk ++ "/lib/chibios/os/various",
        qmk ++ "/lib/chibios/os/various/pico_bindings/dumb/include",

        // ── ChibiOS-Contrib ──
        qmk ++ "/lib/chibios-contrib/os/hal/ports/RP/LLD/I2Cv1",
        qmk ++ "/lib/chibios-contrib/os/hal/ports/RP/LLD/PWMv1",
        qmk ++ "/lib/chibios-contrib/os/hal/ports/RP/LLD/ADCv1",
        qmk ++ "/lib/chibios-contrib/os/hal/ports/RP/LLD/USBDv1",

        // ── Pico SDK ──
        qmk ++ "/lib/pico-sdk/src/common/pico_base/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/pico_platform/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_base/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_clocks/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_claim/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_flash/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_gpio/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_irq/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_pll/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_pio/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_sync/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_timer/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_resets/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_watchdog/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_xosc/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_divider/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_uart/include",
        qmk ++ "/lib/pico-sdk/src/rp2_common/hardware_uart",
        qmk ++ "/lib/pico-sdk/src/rp2_common/pico_bootrom/include",
        qmk ++ "/lib/pico-sdk/src/rp2040/hardware_regs/include",
        qmk ++ "/lib/pico-sdk/src/rp2040/hardware_structs/include",
        qmk ++ "/lib/pico-sdk/src/boards/include",

        // ── Build artifacts ──
        // qmk ++ "/.build/obj_fckqmk_default/src",

        // ── Libraries ──
        qmk ++ "/lib/printf/src",
        qmk ++ "/lib/printf/src/printf",
        qmk ++ "/lib/fnv",
    };

    for (entries) |entry| {
        if (seen.contains(entry)) continue;
        seen.put(entry, {}) catch {};
        mod.addIncludePath(path{ .cwd_relative = entry });
    }
}

/// `-Wl,--wrap=` symbols from QMK cflags. These intercept ARM AEABI helpers
/// (div/mul) so QMK can provide its own implementations. In Zig's build
/// system they are not applied as linker flags (no ldflags API on Module);
/// they are only meaningful at final link time with mixed Zig+C objects.
pub const linker_wraps = [_][]const u8{
    "__aeabi_idiv",
    "__aeabi_idivmod",
    "__aeabi_ldivmod",
    "__aeabi_uidiv",
    "__aeabi_uidivmod",
    "__aeabi_uldivmod",
    "__aeabi_lmul",
};
