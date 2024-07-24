const std = @import("std");

pub fn build(b: *std.Build) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const docs = b.addTest("src/root.zig");
    docs.setBuildMode(mode);
    docs.emit_docs = .emit;

    const docs_step = b.step("docs", "Generate documentation");
    docs_step.dependOn(&docs.step);

    const kcov = b.addSystemCommand(&.{ "kcov", "kcov-out", "--include-path=src" });
    kcov.addArtifactArg(unit_tests);

    const coverage_step = b.step("coverage", "Generate test coverage (kcov)");
    coverage_step.dependOn(&kcov.step);
}
