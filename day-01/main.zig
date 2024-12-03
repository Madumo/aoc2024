const std = @import("std");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const file = std.fs.cwd().openFile("input.txt", .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return;
    };
    defer file.close();

    // Can everything use the same allocator? No idea. I'm probably going to jail.
    var firstList = std.ArrayList(i32).init(allocator);
    defer firstList.deinit();
    var secondList = std.ArrayList(i32).init(allocator);
    defer secondList.deinit();

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read line: {s}", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);

        const firstValue = try std.fmt.parseInt(i32, line[0..5], 10);
        try firstList.append(firstValue);

        const secondValue = try std.fmt.parseInt(i32, line[8..13], 10);
        try secondList.append(secondValue);
    }

    std.mem.sort(i32, firstList.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, secondList.items, {}, comptime std.sort.asc(i32));

    var totalDistance: u32 = 0;

    for (firstList.items, 0..) |firstValue, index| {
        const secondValue = secondList.items[index];
        totalDistance += @abs(firstValue - secondValue);
    }

    std.debug.print("Total: {}\n", .{totalDistance});
}
