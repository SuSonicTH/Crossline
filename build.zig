const std = @import("std");

const flags = [_][]const u8{"-std=gnu99"};

pub const Options = struct {
    shared: bool = false,
};

pub fn build(b: *std.Build) void {
    const lib = buildLib(b, b.standardTargetOptions(.{}), b.standardOptimizeOption(.{}), .{});

    b.installArtifact(lib);

    exeStep(b, lib, "example");
    exeStep(b, lib, "example2");
    exeStep(b, lib, "example_sql");
}

pub fn link(b: *std.Build, step: *std.build.CompileStep, options: Options) void {
    const lib = buildLib(b, step.target, step.optimize, options);
    step.addIncludePath(dir());
    step.linkLibrary(lib);
}

fn dir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

fn buildLib(b: *std.Build, target: std.zig.CrossTarget, optimize: std.builtin.Mode, options: Options) *std.build.CompileStep {
    const lib = brk: {
        if (options.shared) break :brk b.addSharedLibrary(.{
            .name = "crossline",
            .target = target,
            .optimize = optimize,
        });

        break :brk b.addStaticLibrary(.{
            .name = "crossline",
            .target = target,
            .optimize = optimize,
        });
    };

    lib.addCSourceFiles(&[_][]const u8{
        std.fs.path.join(b.allocator, &.{ dir(), "crossline.c" }) catch unreachable,
    }, &flags);
    lib.linkLibC();

    return lib;
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
