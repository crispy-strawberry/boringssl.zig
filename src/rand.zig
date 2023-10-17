const mem = @import("mem.zig");

const boringssl = @cImport({
    @cInclude("openssl/rand.h");
});

/// Gets random bytes
pub fn getRandomBytes(len: usize) ![]u8 {
    // var buf_ptr: [*]u8 = @ptrCast(boringssl.OPENSSL_malloc(len) orelse return error.AllocationFailure);
    var buf_ptr = try mem.mallocElements(u8, len); 
    getRandomBytesToBuffer(buf_ptr, len);
    return buf_ptr[0..len];
}

pub inline fn getRandomBytesToBuffer(buf: [*]u8, len: usize) void {
    _ = boringssl.RAND_bytes(buf, len);
}
