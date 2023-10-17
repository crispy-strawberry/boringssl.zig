const std = @import("std");
const mem = @import("mem.zig");
const rand = @import("rand.zig");

const testing = std.testing;

test "basic getRandomBytes" {
    for (0..10) |_| {
        const bytes = try rand.getRandomBytes(32);
        defer mem.free(bytes.ptr);

        std.debug.print("{any}\n\n", .{bytes});
    }
}

test "basic getRandomBytesToBuffer" {
    for (0..10) |_| {
        var bytes: [32]u8 = undefined;
        rand.getRandomBytesToBuffer(&bytes,bytes.len);
        std.debug.print("{any}\n\n", .{bytes});
    }
}
