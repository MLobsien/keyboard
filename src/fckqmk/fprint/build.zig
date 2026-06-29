const std = @import("std");
const cflags = @import("cflags.zig");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
        .os_tag = .freestanding,
        .abi = .eabi,
    });

    const mod = b.addModule("fprint", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "fprint",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = .ReleaseSmall,
            .imports = &.{
                .{ .name = "fprint", .module = mod },
            },
        }),
    });

    // ── QMK config include (mirrors QMK's -include for every config.h) ──
    // Generates qmk_config.h that #include's all QMK config files in the
    // keyboard/keymap/board hierarchy.  Keeps Zig and Make in sync: when a
    // config.h changes in the QMK tree, the generated wrapper picks it up.
    const qmk_config_write = b.addWriteFiles();
    _ = qmk_config_write.add("qmk_config.h",
        \\#pragma once
        \\// Auto-generated QMK config include  --  mirrors QMK's -include mechanism
        \\// Keyboard config
        \\#include "keyboards/fckqmk/config.h"
        \\// Board config
        \\#include "platforms/chibios/boards/GENERIC_PROMICRO_RP2040/configs/config.h"
        \\
    );
    lib.root_module.addIncludePath(qmk_config_write.getDirectory());

    cflags.addDefines(lib.root_module);
    cflags.addIncludePaths(lib.root_module);

    // Use arm-none-eabi newlib via libc config (like QMK's arm-none-eabi-gcc does)
    // This tells Zig's Clang to search the newlib headers for <assert.h>, <sys/cdefs.h>, etc.
    lib.root_module.link_libc = true;
    lib.setLibCFile(b.path("arm-eabi-newlib.conf"));

    // The libc config sets include_dir but also need explicit -isystem for Clang
    const gcc_arm = "/nix/store/mmkh2v78liwvll9ikdamv3iqwy5drm1g-gcc-arm-embedded-15.2.rel1";
    lib.root_module.addSystemIncludePath(.{ .cwd_relative = gcc_arm ++ "/arm-none-eabi/include" });
    lib.root_module.addSystemIncludePath(.{ .cwd_relative = gcc_arm ++ "/lib/gcc/arm-none-eabi/15.2.1/include" });
    lib.root_module.addSystemIncludePath(.{ .cwd_relative = gcc_arm ++ "/lib/gcc/arm-none-eabi/15.2.1/include-fixed" });

    // Generate pico/version.h from CMake template (Pico SDK 1.5.1)
    const pico_version_h = b.addConfigHeader(.{
        .style = .{ .cmake = .{ .cwd_relative = "/home/mad5/qmk_firmware/lib/pico-sdk/src/common/pico_base/include/pico/version.h.in" } },
        .include_path = "pico/version.h",
    }, .{
        .PICO_SDK_VERSION_MAJOR = 1,
        .PICO_SDK_VERSION_MINOR = 5,
        .PICO_SDK_VERSION_REVISION = 1,
        .PICO_SDK_VERSION_STRING = "1.5.1",
    });
    lib.root_module.addIncludePath(pico_version_h.getOutputDir());

    // Compile and link uart.c from the Pico SDK (declarations imported via @cImport above)
    lib.root_module.addCSourceFile(.{
        .file = .{ .cwd_relative = "/home/mad5/qmk_firmware/lib/pico-sdk/src/rp2_common/hardware_uart/uart.c" },
    });

    // ChibiOS SIO (Serial I/O) driver for RP2040 UART
    lib.root_module.addCSourceFile(.{
        .file = .{ .cwd_relative = "/home/mad5/qmk_firmware/lib/chibios/os/hal/ports/RP/LLD/UARTv1/hal_sio_lld.c" },
    });
    lib.root_module.addCSourceFile(.{
        .file = .{ .cwd_relative = "/home/mad5/qmk_firmware/lib/chibios/os/hal/src/hal_sio.c" },
    });
    // QMK platform UART driver wrapping ChibiOS SIO
    // Board-specific QMK macros (-D instead of -include to avoid zig cache bug with -include + WriteFiles)
    lib.root_module.addCSourceFile(.{
        .file = .{ .cwd_relative = "/home/mad5/qmk_firmware/platforms/chibios/drivers/uart_sio.c" },
        .flags = &.{
            "-DUART_DRIVER=SIOD0",
            "-DUART_TX_PIN=GP0",
            "-DUART_RX_PIN=GP1",
            "-DUART_CTS_PIN=GP2",
            "-DUART_RTS_PIN=GP3",
        },
    });
    b.installArtifact(lib);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(lib);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const lib_tests = b.addTest(.{
        .root_module = lib.root_module,
    });
    const run_lib_tests = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_lib_tests.step);
}
