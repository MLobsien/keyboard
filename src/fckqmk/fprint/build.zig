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
