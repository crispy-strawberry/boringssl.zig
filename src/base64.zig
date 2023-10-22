const std = @import("std");

const boringssl = @import("boring_raw.zig");

pub fn encodeBlock(dst: *u8, src: *u8, src_len: usize) usize {
    boringssl.EVP_EncodeBlock(dst, src, src_len);
    boringssl.
}

pub fn encodedLength(len: usize) !usize {
    var out_len: usize = undefined;
    if (boringssl.EVP_EncodedLength(&out_len, len) == 1) {
        return out_len;
    }
    return error.Base64Error;
}

pub fn encodeBuffer(allocator: std.mem.Allocator, buf: []u8) ![:0]u8 {
    var out_buf: [:0]u8 = try allocator.alloc(try encodedLength(buf.len));
    encodeBlock(out_buf.ptr, buf.ptr, buf.len);
    return out_buf;
}

pub fn decodedLength(len: usize) !usize {
    var out_len: usize = undefined;
    if (boringssl.EVP_DecodedLength(&out_len, len) == 1) {
        return out_len;
    }
    return error.Base64Error;
}

pub fn decodeBase64(out: *u8, out_len: *u8, max_out: *u8, in: *u8, in_len: usize) !void {
    const err = boringssl.EVP_DecodeBase64(out, out_len, max_out, in, in_len);
    switch (err) {
        1 => return,
        0 => return error.Base64_DecodeError,
        _ => unreachable,
    }
}
