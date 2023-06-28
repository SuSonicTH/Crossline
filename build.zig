const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "crossline",
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath("./");
    lib.addCSourceFiles(&[_][]const u8{
        "./crossline.c",
    }, &[_][]const u8{"-std=gnu99"});
    lib.linkLibC();

    b.installArtifact(lib);
}
