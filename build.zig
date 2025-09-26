const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Module
    {
        _ = b.addModule("fast_glob", .{
            .root_source_file = b.path("src/fast_glob.zig"),
            .target = target,
            .optimize = optimize,
        });
    }

    // test
    {
        const test_step = b.step("test", "Run all tests");

        const test_filter = b.option([]const u8, "test-filter", "Filter for tests");

        const test_exe = b.addTest(.{
            .name = "fast-glob-test",
            .filters = if (test_filter) |f| &.{f} else &.{},
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/test.zig"),
                .target = target,
                .optimize = optimize,
                .omit_frame_pointer = false,
                .strip = false,
            }),
            .use_llvm = true,
        });

        const test_run = b.addRunArtifact(test_exe);
        test_step.dependOn(&test_run.step);
    }

    // bench
    {
        const bench_step = b.step("bench", "Run benchmark");

        const bench_exe = b.addExecutable(.{
            .name = "fast-glob-bench",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/bench.zig"),
                .target = target,
                .optimize = optimize,
            }),
        });

        bench_exe.root_module.addImport(
            "codspeed",
            b.dependency("codspeed", .{ .target = target, .optimize = optimize }).module("codspeed"),
        );

        const bench_install = b.addInstallArtifact(bench_exe, .{});
        bench_step.dependOn(&bench_install.step);

        b.getInstallStep().dependOn(bench_step);
    }
}
