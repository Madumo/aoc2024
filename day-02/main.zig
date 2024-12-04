const std = @import("std");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var safeReportsCount: u32 = 0;

    while (stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read line: {s}", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);

        var tokens = std.mem.tokenizeAny(u8, line, " ");
        var previousValue: i32 = try std.fmt.parseInt(i32, tokens.next() orelse unreachable, 10);
        var previousIsAscending: ?bool = null;
        var isSafe = true;

        while (tokens.next()) |token| {
            const value: i32 = try std.fmt.parseInt(i32, token, 10);

            if (value == previousValue) {
                isSafe = false;
                break;
            }

            const isAscending = value > previousValue;

            if (previousIsAscending == null) {
                previousIsAscending = isAscending;
            }

            if (isAscending != previousIsAscending) {
                isSafe = false;
                break;
            }

            const delta = @abs(value - previousValue);

            if (delta > 3) {
                isSafe = false;
                break;
            }

            previousValue = value;
        }

        if (isSafe) {
            safeReportsCount += 1;
        }
    }

    try stdout.print("Safe reports: {}\n", .{safeReportsCount});
}
