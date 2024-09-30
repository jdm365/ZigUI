const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL.h");
});


pub const Window = struct {
    sdl_window: *sdl.SDL_Window,

    pub fn init(
        window_title: []const u8,
        x: i32, 
        y: i32, 
        w: i32, 
        h: i32,
        ) !Window {

        const window = sdl.SDL_CreateWindow(
            std.mem.asBytes(window_title),
            x,
            y,
            w,
            h,
            sdl.SDL_WINDOW_SHOWN,
        );

        if (window == null) return error.WindowCreationError;

        return Window{
            .sdl_window = window.?,
        };
    }

    pub fn deinit(self: *Window) void {
        sdl.SDL_DestroyWindow(self.sdl_window);
    }

    pub fn resize(self: *Window, w: i32, h: i32) void {
        sdl.SDL_SetWindowSize(self.sdl_window, w, h);
    }
};

pub fn main() !void {
    // Basic open window
    _ = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    defer sdl.SDL_Quit();

    var window: Window = try Window.init("Hello, World", 100, 100, 640, 480);
    defer window.deinit();

    const renderer = sdl.SDL_CreateRenderer(
        window.sdl_window,
        -1,
        sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC,
    );
    defer sdl.SDL_DestroyRenderer(renderer);

    _ = sdl.SDL_SetRenderDrawColor(renderer.?, 0, 0, 0, 255);
    _ = sdl.SDL_RenderClear(renderer.?);
    _ = sdl.SDL_RenderPresent(renderer.?);

    var running = true;

    while (running) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_QUIT => running = false,
                sdl.SDL_KEYDOWN => {
                    const key = event.key.keysym.sym;
                    if (key == sdl.SDLK_ESCAPE) {
                        running = false;
                    }

                    if (key == sdl.SDLK_SPACE) {
                        window.resize(1000, 800);
                    }
                },
                else => continue,
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer.?, 0, 0, 0, 255);
        _ = sdl.SDL_RenderClear(renderer.?);

        _ = sdl.SDL_SetRenderDrawColor(renderer.?, 255, 255, 255, 255);
        var rect = sdl.SDL_Rect{
            .x = 0, 
            .y = 0, 
            .w = 800,
            .h = 600,
        };
        _ = sdl.SDL_RenderFillRect(renderer.?, &rect);

        _ = sdl.SDL_RenderPresent(renderer.?);

        // Log window pos. Get info from sdl not rect.
        var x: i32 = 0;
        var y: i32 = 0;
        var w: i32 = 0;
        var h: i32 = 0;
        _ = sdl.SDL_GetWindowPosition(
            window.sdl_window, 
            &x,
            &y,
            );
        _ = sdl.SDL_GetWindowSize(
            window.sdl_window, 
            &w,
            &h,
            );

        std.debug.print("Window pos: {d} {d} {d} {d}\n", .{
            x,
            y,
            w,
            h,
        });

        sdl.SDL_Delay(16);
    }
}
