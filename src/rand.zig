const std = @import("std");
const boringssl = @import("boringssl");

// const mem = @import("mem.zig");


/// Gets random bytes
pub fn getRandomBytesAlloc(allocator: std.mem.Allocator, len: usize) ![]u8 {
    // var buf_ptr: [*]u8 = @ptrCast(boringssl.OPENSSL_malloc(len) orelse return error.AllocationFailure);
    var buf: []u8 = try allocator.alloc(u8, len);
    getRandomBytes(buf);
    return buf;
}

pub inline fn getRandomBytes(buf: []u8) void {
    _ = boringssl.RAND_bytes(buf.ptr, buf.len); 
}
