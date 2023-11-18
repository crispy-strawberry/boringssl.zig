const std = @import("std");
const mem = @import("mem.zig");

const boringssl = @import("boringssl");

/// Gets random bytes
pub fn getRandomBytes(allocator: std.mem.Allocator, len: usize) ![]u8 {
    // var buf_ptr: [*]u8 = @ptrCast(boringssl.OPENSSL_malloc(len) orelse return error.AllocationFailure);
    var buf_ptr: []u8 = try allocator.alloc(u8, len);
    getRandomBytesToBuffer(buf_ptr.ptr, len);
    return buf_ptr[0..len];
}

pub inline fn getRandomBytesToBuffer(buf: [*]u8, len: usize) void {
    _ = boringssl.RAND_bytes(buf, len); 
}
