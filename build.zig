const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "ZigUI",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "ZigUI",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link SDL
    exe.addIncludePath(b.path("src/SDL/include"));
    exe.linkSystemLibrary("SDL2");
    exe.linkLibC();

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "run");

    run_step.dependOn(&run_cmd.step);

    b.installArtifact(exe);
}
