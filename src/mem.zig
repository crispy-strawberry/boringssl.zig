const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const boringssl_mem = @This();

const boringssl = @import("boring_raw.zig");

const MemoryError = error{AllocationError};

// pub fn malloc(len: usize) ?*anyopaque {
//     return boringssl.OPENSSL_malloc(len) orelse null;
// }

/// A helper function to allocate `n` elements of type `T`
/// and return a pointer.
pub fn mallocElements(comptime T: type, n: usize) ![*]T {
    var opaque_ptr = boringssl.OPENSSL_malloc(n * @sizeOf(T)) orelse return error.AllocationError;
    return @ptrCast(opaque_ptr);
}

// pub fn zalloc(len: usize) ?*anyopaque {
//     return boringssl.OPENSSL_zalloc(len) orelse return null;
// }

/// A helper function to zallocate `n` elements of type `T`
/// and return a pointer.
pub fn zallocElements(comptime T: type, n: usize) ![*]T {
    var opaque_ptr = boringssl.OPENSSL_zalloc(n * @sizeOf(T)) orelse return error.AllocationError;
    return @ptrCast(opaque_ptr);
}

// pub fn realloc(ptr: *anyopaque, new_size: usize) ?*anyopaque {
//     return boringssl.OPENSSL_realloc(ptr, new_size) orelse null;
// }

pub fn calloc(comptime T: type, n: usize) ?[*]T {
    return boringssl.OPENSSL_calloc(n, @sizeOf(T)) orelse MemoryError.AllocationError;
}

/// Zeroes out len elements at ptr.
pub fn cleanse(ptr: *anyopaque, len: usize) void {
    boringssl.OPENSSL_cleanse(ptr, len);
}

// pub fn free(ptr: *anyopaque) void {
//     boringssl.OPENSSL_free(ptr);
// }

pub fn freeBuffer(buf: []type) void {
    boringssl.OPENSSL_free(buf.ptr);
}

pub fn memcmp(a: *anyopaque, b: *anyopaque, len: usize) bool {
    switch (boringssl.CRYPTO_memcmp(a, b, len)) {
        0 => return true,
        else => return false,
    }
}

pub fn hash32(ptr: *anyopaque, len: usize) u32 {
    return boringssl.OPENSSL_hash32(ptr, len);
}

pub fn hash32Buffer(buf: []type) u32 {
    return hash32(buf.ptr, buf.len);
}

pub const boringssl_allocator: Allocator = .{ .ptr = undefined, .vtable = &BoringVTable };

const BoringVTable: Allocator.VTable = .{
    .alloc = BoringAllocator.alloc,
    .free = BoringAllocator.free,
    .resize = BoringAllocator.resize,
};

/// Copied from `std.heap.c_allocator`;
const BoringAllocator = struct {
    fn getHeader(ptr: [*]u8) *[*]u8 {
        return @as(*[*]u8, @ptrFromInt(@intFromPtr(ptr) - @sizeOf(usize)));
    }

    fn alignedAlloc(len: usize, log2_align: u8) ?[*]u8 {
        const alignment = @as(usize, 1) << @as(Allocator.Log2Align, @intCast(log2_align));
        // Thin wrapper around regular malloc, overallocate to account for

        // alignment padding and store the original malloc()'ed pointer before

        // the aligned address.

        var unaligned_ptr = @as([*]u8, @ptrCast(boringssl.malloc(len + alignment - 1 + @sizeOf(usize)) orelse return null));
        const unaligned_addr = @intFromPtr(unaligned_ptr);
        const aligned_addr = mem.alignForward(usize, unaligned_addr + @sizeOf(usize), alignment);
        var aligned_ptr = unaligned_ptr + (aligned_addr - unaligned_addr);
        getHeader(aligned_ptr).* = unaligned_ptr;

        return aligned_ptr;
    }

    fn alignedFree(ptr: [*]u8) void {
        const unaligned_ptr = getHeader(ptr).*;
        boringssl.free(unaligned_ptr);
    }

    fn alloc(
        _: *anyopaque,
        len: usize,
        log2_align: u8,
        return_address: usize,
    ) ?[*]u8 {
        _ = return_address;
        std.debug.assert(len > 0);
        return alignedAlloc(len, log2_align);
    }

    fn resize(
        _: *anyopaque,
        buf: []u8,
        log2_buf_align: u8,
        new_len: usize,
        return_address: usize,
    ) bool {
        _ = log2_buf_align;
        _ = return_address;
        if (new_len <= buf.len) {
            return true;
        }
        return false;
    }

    fn free(
        _: *anyopaque,
        buf: []u8,
        log2_buf_align: u8,
        return_address: usize,
    ) void {
        _ = log2_buf_align;
        _ = return_address;
        alignedFree(buf.ptr);
    }
};
