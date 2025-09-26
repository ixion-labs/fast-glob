const std = @import("std");

const Codspeed = @import("codspeed");

const fast_glob = @import("fast_glob.zig");

pub fn main() !void {
    const alloc = std.heap.c_allocator;

    const benchmarker = Benchmarker.init(alloc, "src/bench.zig");
    defer benchmarker.deinit();

    try bench(
        benchmarker.bench("simple_match"),
        "some/**/n*d[k-m]e?txt",
        "some/a/bigger/path/to/the/crazy/needle.txt",
    );

    try bench(
        benchmarker.bench("brace_expansion"),
        "some/**/{tob,crazy}/?*.{png,txt}",
        "some/a/bigger/path/to/the/crazy/needle.txt",
    );
}

const Benchmarker = struct {
    alloc: std.mem.Allocator,
    codspeed: Codspeed,

    pub fn init(alloc: std.mem.Allocator, file_name: []const u8) Benchmarker {
        return .{
            .alloc = alloc,
            .codspeed = Codspeed.init(alloc, file_name),
        };
    }

    pub fn deinit(self: Benchmarker) void {
        self.codspeed.deinit();
    }

    pub fn bench(self: Benchmarker, name: []const u8) Benchmark {
        return .{ .name = name, .benchmarker = self };
    }
};

const Benchmark = struct {
    name: []const u8,
    benchmarker: Benchmarker,

    pub fn start(self: Benchmark) !void {
        try self.benchmarker.codspeed.start(self.name);
    }

    pub fn stop(self: Benchmark) !void {
        try self.benchmarker.codspeed.stop(self.name);
    }
};

fn readFile(alloc: std.mem.Allocator, path: []const u8) ![]u8 {
    const input = try std.fs.cwd().openFile(path, .{});
    defer input.close();

    const input_stat = try input.stat();
    const input_buf = try input.readToEndAlloc(alloc, input_stat.size);

    return input_buf;
}

fn bench(b: Benchmark, glob: []const u8, path: []const u8) !void {
    try b.start();

    if (!try fast_glob.match(glob, path)) {
        std.log.err("expected success", .{});
        std.process.exit(1);
    }

    try b.stop();
}
