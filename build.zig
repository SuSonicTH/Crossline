const std = @import("std");

const flags = [_][]const u8{"-std=gnu99"};

pub fn build(b: *std.Build) void {
    const lib = b.addStaticLibrary(.{
        .name = "crossline",
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    lib.addCSourceFiles(&[_][]const u8{
        "./crossline.c",
    }, &flags);
    lib.linkLibC();

    b.installArtifact(lib);
    b.installLibFile("crossline.h", "crossline.h");

    exeStep(b, lib, "example");
    exeStep(b, lib, "example2");
    exeStep(b, lib, "example_sql");
}

fn exeStep(b: *std.Build, lib: *std.build.CompileStep, comptime name: []const u8) void {
    const exe = b.addExecutable(.{
        .name = name,
        .target = lib.target,
        .optimize = lib.optimize,
    });

    exe.linkLibrary(lib);
    exe.addCSourceFiles(&[_][]const u8{
        "./" ++ name ++ ".c",
    }, &flags);

    //run exe
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run_" ++ name, "Run example '" ++ name ++ "'");
    run_step.dependOn(&run_cmd.step);
}
