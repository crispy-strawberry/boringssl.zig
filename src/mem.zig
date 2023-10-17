const boringssl = @cImport({
    @cInclude("openssl/mem.h");
});

const MemoryError = error{AllocationError};

pub fn malloc(len: usize) MemoryError!*anyopaque {
    return boringssl.OPENSSL_malloc(len) orelse error.AllocationError;
}

/// A helper function to allocate `n` elements of type `T`
/// and return a pointer.
pub fn mallocElements(comptime T: type, n: usize) ![*]T {
    var opaque_ptr = try malloc(n * @sizeOf(T));
    return @ptrCast(opaque_ptr);
}

pub fn zalloc(len: usize) MemoryError!*anyopaque {
    return boringssl.OPENSSL_zalloc(len) orelse error.AllocationError;
}

/// A helper function to zallocate `n` elements of type `T`
/// and return a pointer.
pub fn zallocElements(comptime T: type, n: usize) ![*]T {
    var opaque_ptr = try zalloc(n * @sizeOf(T));
    return @ptrCast(opaque_ptr);
}

pub fn calloc(n: usize, size: usize) ![*]anyopaque {
    return boringssl.OPENSSL_calloc(n, size) orelse error.AllocationError;
}

/// Zeroes out len elements at ptr.
pub fn cleanse(ptr: *anyopaque, len: usize) void {
    boringssl.OPENSSL_cleanse(ptr, len);
}

pub fn free(ptr: *anyopaque) void {
    boringssl.OPENSSL_free(ptr);
}
