const wapc = @import("wapc");
const std = @import("std");
const mem = std.mem;
const json = std.json;
const testing = std.testing;
const fmt = std.fmt;

const RndGen = std.rand.DefaultPrng;

extern "wapc" fn __console_log(ptr: [*]u8, len: usize) void;

export fn __guest_call(operation_size: usize, payload_size: usize) bool {
    return wapc.handleCall(std.heap.page_allocator, operation_size, payload_size, &functions);
}

const functions = [_]wapc.Function{
    wapc.Function{ .name = "hello", .invoke = sayHello },
    wapc.Function{ .name = "zigCallJs", .invoke = zigCallJs },
};

// example of receiving and sending json objects
const HelloRequest = struct { name: []u8 };
const HelloResponse = struct { msg: []u8 };

fn sayHello(allocator: mem.Allocator, payload: []u8) !?[]u8 {
    // parse request payload
    var stream = json.TokenStream.init(payload);
    const parse_options = .{ .allocator = allocator };
    const res = try json.parse(HelloRequest, &stream, parse_options);
    defer json.parseFree(HelloRequest, res, parse_options);

    // build response
    var message = std.ArrayList(u8).init(allocator);
    defer message.deinit();
    try message.appendSlice("Hello, ");
    try message.appendSlice(res.name);
    try message.appendSlice("!");
    const resp = HelloResponse{ .msg = message.items };

    // serialize response
    var buffer = std.ArrayList(u8).init(allocator);
    const options = json.StringifyOptions{};
    try json.stringify(resp, options, buffer.writer());
    return buffer.items;
}

var rnd = RndGen.init(0);

// ignore incoming payload and send no payload out
fn zigCallJs(allocator: mem.Allocator, _: []u8) !?[]u8 {
    var message = std.ArrayList(u8).init(allocator);
    defer message.deinit();
    try message.appendSlice("Hello from zig ");

    var buf = try allocator.alloc(u8, 11);
    defer allocator.free(buf);
    try message.appendSlice(try fmt.bufPrint(buf, "{}", .{rnd.random().int(i32)}));
    try message.appendSlice("!");

    // example call from zig to js
    const resp = try wapc.hostCall(allocator, "app", "window", "alert", message.items);
    allocator.free(resp);
    return null;
}
