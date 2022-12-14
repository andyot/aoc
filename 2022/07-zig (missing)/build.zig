const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const exe = b.addExecutable("07-zig", "src/main.zig");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
