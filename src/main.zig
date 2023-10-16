const std = @import("std");

const boringssl = @cImport({
    @cInclude("openssl/mem.h");
    @cInclude("openssl/rand.h");
});

const testing = std.testing;

/// Gets random bytes 
pub fn getRandomBytes(len: usize) ![]u8 {
    var buf_ptr: [*]u8 = @ptrCast(boringssl.OPENSSL_malloc(len) orelse return error.AllocationFailure);
    _ = boringssl.RAND_bytes(buf_ptr, len);
    return buf_ptr[0..len];
}

pub fn freeBuffer(buf: []u8) void {
    boringssl.OPENSSL_free(buf.ptr);
}

pub fn getRandomBytesToBuffer(buf: []u8) void {
    _ = boringssl.RAND_bytes(buf.ptr, buf.len);
}

test "basic getRandomBytes" {
    for (0..10) |_| {
        const bytes = try getRandomBytes(32);
        defer freeBuffer(bytes);

        std.debug.print("{any}\n\n", .{bytes});
    }
}

test "basic getRandomBytesToBuffer" {
    for (0..10) |_| {
        var bytes: [32]u8 = undefined;
        getRandomBytesToBuffer((&bytes)[0..32]); 
        std.debug.print("{any}\n\n", .{bytes});
    }
}
