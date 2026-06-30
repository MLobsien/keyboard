{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    qmk = {
      url = "git+https://github.com/qmk/qmk_firmware?submodules=1";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    qmk,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    qmk_firmware = pkgs.runCommand "qmk_firmware" {} ''
      mkdir $out
      cp --no-preserve=mode -r ${qmk}/* $out
      cp -r ${../..}/fckqmk $out/keyboards/
    '';

    cc = pkgs.gcc-arm-embedded-15;

    fmt = f: v: let tab = "    "; in tab + (pkgs.lib.concatStringsSep ("\n" + tab) (f v));

    build.zig = let
      suffixes = [
        ""
        "/keyboards/fckqmk/keymaps/default"
        "/users/default"
        "/keyboards/fckqmk"
        "/platforms/chibios/boards/GENERIC_PROMICRO_RP2040/configs"
        "/platforms/chibios/boards/common/configs"
        "/tmk_core"
        "/tmk_core/protocol"
        "/tmk_core/protocol/chibios"
        "/tmk_core/protocol/chibios/lufa_utils"
        "/quantum"
        "/quantum/keymap_extras"
        "/quantum/process_keycode"
        "/quantum/sequencer"
        "/quantum/nvm"
        "/quantum/nvm/eeprom"
        "/quantum/logging"
        "/quantum/wear_leveling"
        "/quantum/split_common"
        "/quantum/bootmagic"
        "/quantum/send_string"
        "/drivers"
        "/drivers/eeprom"
        "/drivers/wear_leveling"
        "/platforms"
        "/platforms/chibios"
        "/platforms/chibios/drivers"
        "/platforms/chibios/drivers/eeprom"
        "/platforms/chibios/drivers/wear_leveling"
        "/platforms/chibios/drivers/vendor/RP/RP2040"
        "/platforms/chibios/vendors/RP"
        "/lib/chibios/os/license"
        "/lib/chibios/os/common/portability/GCC"
        "/lib/chibios/os/common/startup/ARMCMx/compilers/GCC"
        "/lib/chibios/os/common/startup/ARMCMx/devices/RP2040"
        "/lib/chibios/os/common/ext/ARM/CMSIS/Core/Include"
        "/lib/chibios/os/common/ext/RP/RP2040"
        "/lib/chibios/os/rt/include"
        "/lib/chibios/os/common/ports/ARM-common"
        "/lib/chibios/os/common/ports/ARMv6-M-RP2"
        "/lib/chibios/os/hal/osal/rt-nil"
        "/lib/chibios/os/oslib/include"
        "/lib/chibios/os/hal/include"
        "/lib/chibios/os/hal/ports/common/ARMCMx"
        "/lib/chibios/os/hal/ports/RP/RP2040"
        "/lib/chibios/os/hal/ports/RP/LLD/DMAv1"
        "/lib/chibios/os/hal/ports/RP/LLD/GPIOv1"
        "/lib/chibios/os/hal/ports/RP/LLD/SPIv1"
        "/lib/chibios/os/hal/ports/RP/LLD/TIMERv1"
        "/lib/chibios/os/hal/ports/RP/LLD/UARTv1"
        "/lib/chibios/os/hal/ports/RP/LLD/RTCv1"
        "/lib/chibios/os/hal/ports/RP/LLD/WDGv1"
        "/lib/chibios/os/hal/boards/RP_PICO_RP2040"
        "/lib/chibios/os/hal/lib/streams"
        "/lib/chibios/os/various"
        "/lib/chibios/os/various/pico_bindings/dumb/include"
        "/lib/chibios-contrib/os/hal/ports/RP/LLD/I2Cv1"
        "/lib/chibios-contrib/os/hal/ports/RP/LLD/PWMv1"
        "/lib/chibios-contrib/os/hal/ports/RP/LLD/ADCv1"
        "/lib/chibios-contrib/os/hal/ports/RP/LLD/USBDv1"
        "/lib/pico-sdk/src/common/pico_base/include"
        "/lib/pico-sdk/src/rp2_common/pico_platform/include"
        "/lib/pico-sdk/src/rp2_common/hardware_base/include"
        "/lib/pico-sdk/src/rp2_common/hardware_clocks/include"
        "/lib/pico-sdk/src/rp2_common/hardware_claim/include"
        "/lib/pico-sdk/src/rp2_common/hardware_flash/include"
        "/lib/pico-sdk/src/rp2_common/hardware_gpio/include"
        "/lib/pico-sdk/src/rp2_common/hardware_irq/include"
        "/lib/pico-sdk/src/rp2_common/hardware_pll/include"
        "/lib/pico-sdk/src/rp2_common/hardware_pio/include"
        "/lib/pico-sdk/src/rp2_common/hardware_sync/include"
        "/lib/pico-sdk/src/rp2_common/hardware_timer/include"
        "/lib/pico-sdk/src/rp2_common/hardware_resets/include"
        "/lib/pico-sdk/src/rp2_common/hardware_watchdog/include"
        "/lib/pico-sdk/src/rp2_common/hardware_xosc/include"
        "/lib/pico-sdk/src/rp2_common/hardware_divider/include"
        "/lib/pico-sdk/src/rp2_common/hardware_uart/include"
        "/lib/pico-sdk/src/rp2_common/hardware_uart"
        "/lib/pico-sdk/src/rp2_common/pico_bootrom/include"
        "/lib/pico-sdk/src/rp2040/hardware_regs/include"
        "/lib/pico-sdk/src/rp2040/hardware_structs/include"
        "/lib/pico-sdk/src/boards/include"
        "/lib/printf/src"
        "/lib/printf/src/printf"
        "/lib/fnv"
      ];

      macros = {
        "THUMB_PRESENT" = "";
        "THUMB_NO_INTERWORKING" = "";
        "PICO_NO_FPGA_CHECK" = "1";
        "wint_t" = "unsigned int";
        "CORTEX_USE_FPU" = "FALSE";
        "PROTOCOL_CHIBIOS" = "";
        "MCU_RP" = "";
        "PLATFORM_SUPPORTS_SYNCHRONIZATION" = "";
        "PORT_IGNORE_GCC_VERSION_CHECK" = "1";
        "FIXED_CONTROL_ENDPOINT_SIZE" = "64";
        "FIXED_NUM_CONFIGURATIONS" = "1";
        "HAL_USE_SIO" = "TRUE";
        "RP_SIO_USE_UART0" = "TRUE";
        "BOOTLOADER_RP2040" = "";
        "QMK_KEYBOARD" = "fckqmk";
        "QMK_KEYBOARD_H" = ".build/obj_fckqmk_default/src/default_keyboard.h";
        "QMK_KEYMAP" = "default";
        "QMK_KEYMAP_H" = "default.h";
        "QMK_KEYMAP_CONFIG_H" = "keyboards/fckqmk/keymaps/default/config.h";
        "KEYBOARD_" = "";
        "KEYBOARD_fckqmk" = "";
        "KEYMAP_C" = "keyboards/fckqmk/keymaps/default/keymap.c";
        "NVM_DRIVER_EEPROM" = "";
        "NVM_DRIVER" = "eeprom";
        "EEPROM_ENABLE" = "";
        "EEPROM_VENDOR" = "";
        "EEPROM_DRIVER" = "";
        "EEPROM_WEAR_LEVELING" = "";
        "WEAR_LEVELING_ENABLE" = "";
        "WEAR_LEVELING_RP2040_FLASH" = "";
        "FNV_ENABLE" = "";
        "SPLIT_KEYBOARD" = "";
        "SPLIT_COMMON_TRANSACTIONS" = "";
        "SERIAL_DRIVER_VENDOR" = "";
        "BOOTMAGIC_ENABLE" = "";
        "CRC_ENABLE" = "";
        "GRAVE_ESC_ENABLE" = "";
        "MAGIC_ENABLE" = "";
        "MOUSEKEY_ENABLE" = "";
        "SEND_STRING_ENABLE" = "";
        "SPACE_CADET_ENABLE" = "";
        "MOUSE_ENABLE" = "";
        "MOUSE_SHARED_EP" = "";
        "EXTRAKEY_ENABLE" = "";
        "NO_DEBUG" = "";
        "NKRO_ENABLE" = "";
        "SHARED_EP_ENABLE" = "";
        "PICO_DIVIDER_IN_RAM" = "1";
        "PICO_DIVIDER_DISABLE_INTERRUPTS" = "1";
        "PICO_INT64_OPS_IN_RAM" = "1";
        "PRINTF_SUPPORT_DECIMAL_SPECIFIERS" = "0";
        "PRINTF_SUPPORT_EXPONENTIAL_SPECIFIERS" = "0";
        "PRINTF_SUPPORT_LONG_LONG" = "0";
        "PRINTF_SUPPORT_WRITEBACK_SPECIFIER" = "0";
        "SUPPORT_MSVC_STYLE_INTEGER_SPECIFIERS" = "0";
        "PRINTF_ALIAS_STANDARD_FUNCTION_NAMES" = "1";
        "QMK_MCU" = "RP2040";
        "QMK_MCU_RP2040" = "";
        "QMK_MCU_ARCH" = "cortex-m0plus";
        "QMK_MCU_ARCH_CORTEX_M0PLUS" = "";
        "QMK_MCU_PORT_NAME" = "RP";
        "QMK_MCU_PORT_NAME_RP" = "";
        "QMK_MCU_FAMILY" = "RP";
        "QMK_MCU_FAMILY_RP" = "";
        "QMK_MCU_SERIES" = "RP2040";
        "QMK_MCU_SERIES_RP2040" = "";
        "QMK_BOARD" = "GENERIC_PROMICRO_RP2040";
        "QMK_BOARD_GENERIC_PROMICRO_RP2040" = "";
      };
    in
      pkgs.writeText "build.zig"
      /*
      zig
      */
      ''
        const std = @import("std");

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

        ${fmt (map (s: "lib.root_module.addIncludePath(.{ .cwd_relative = \"${qmk_firmware + s}\" });")) suffixes}
            lib.root_module.addIncludePath(.{ .cwd_relative = "${pkgs.writeTextDir "qmk_config.h" ''
          #pragma once
          #include "keyboards/fckqmk/config.h"
          #include "platforms/chibios/boards/GENERIC_PROMICRO_RP2040/configs/config.h"
        ''}" });
            lib.root_module.addSystemIncludePath(.{ .cwd_relative = "${cc}/lib/gcc/arm-none-eabi/${cc.version}/include" });
            lib.root_module.addSystemIncludePath(.{ .cwd_relative = "${cc}/lib/gcc/arm-none-eabi/${cc.version}/include-fixed" });
            lib.root_module.addSystemIncludePath(.{ .cwd_relative = "${cc}/arm-none-eabi/include" });

        ${fmt (pkgs.lib.mapAttrsToList (n: v: "lib.root_module.addCMacro(\"${n}\", \"${v}\");")) macros}

            lib.root_module.link_libc = true;
            lib.setLibCFile(.{ .cwd_relative = "${pkgs.writeText "arm-eabi-newlib.conf" ''
          include_dir=${cc}/arm-none-eabi/include
          sys_include_dir=${cc}/arm-none-eabi/include
          crt_dir=${cc}/arm-none-eabi/lib
          msvc_lib_dir=
          kernel32_lib_dir=
          gcc_dir=
        ''}" });

            lib.root_module.addCSourceFile(.{ .file = .{ .cwd_relative = "${qmk_firmware}/lib/pico-sdk/src/rp2_common/hardware_uart/uart.c" } });
            lib.root_module.addCSourceFile(.{ .file = .{ .cwd_relative = "${qmk_firmware}/lib/chibios/os/hal/ports/RP/LLD/UARTv1/hal_sio_lld.c" } });
            lib.root_module.addCSourceFile(.{ .file = .{ .cwd_relative = "${qmk_firmware}/lib/chibios/os/hal/src/hal_sio.c" } });
            lib.root_module.addCSourceFile(.{
                .file = .{ .cwd_relative = "${qmk_firmware}/platforms/chibios/drivers/uart_sio.c" },
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
            if (b.args) |args| run_cmd.addArgs(args);

            const mod_tests = b.addTest(.{ .root_module = mod });
            const lib_tests = b.addTest(.{ .root_module = lib.root_module });
            const test_step = b.step("test", "Run tests");
            test_step.dependOn(&b.addRunArtifact(mod_tests).step);
            test_step.dependOn(&b.addRunArtifact(lib_tests).step);
        }
      '';

    nativeBuildInputs = [pkgs.zig cc qmk_firmware];
  in {
    devShells.${system}.default = pkgs.mkShell {
      inherit nativeBuildInputs;

      shellHook = ''
        ln -sf ${build.zig} build.zig
      '';
    };

    packages.${system} = {
      default = pkgs.stdenv.mkDerivation {
        name = "fprint";
        src = ./.;
        inherit nativeBuildInputs;

        buildPhase = ''
          export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-cache
          export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache

          cp ${build.zig} build.zig

          zig build
        '';

        installPhase = ''
          mkdir -p $out/lib
          cp zig-out/lib/libfprint.a $out/lib
          cp -r include/ $out
        '';
      };

      inherit qmk_firmware;
    };
  };
}
