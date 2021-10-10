const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const glfw_prebuild = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-B",
        "build/libs/glfw-3.3.4",
        "-S",
        "libs/glfw-3.3.4",
    });
    try glfw_prebuild.step.make();

    const glfw_build = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "--build",
        "build/libs/glfw-3.3.4",
    });
    try glfw_build.step.make();

    const exe = b.addExecutable("learnOpenGl", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addCSourceFile("libs/glad/src/glad.c", &[_][]const u8{});
    exe.addIncludeDir("libs/glad/include");

    exe.addLibPath("build/libs/glfw-3.3.4/src");
    exe.addIncludeDir("libs/glfw-3.3.4/include");
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("GL");
    exe.linkSystemLibrary("X11");
    exe.linkSystemLibrary("pthread");
    exe.linkSystemLibrary("Xrandr");
    exe.linkSystemLibrary("Xi");
    exe.linkSystemLibrary("dl");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
