const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub fn main() anyerror!void {
    _ = c.glfwInit();
    defer c.glfwTerminate();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    var window: ?*c.GLFWwindow = c.glfwCreateWindow(800, 600, "LearnOpenGL", null, null);
    if (window == null) {
        c.glfwTerminate();
    }
    c.glfwMakeContextCurrent(window);

    if (0 == c.gladLoadGLLoader(@ptrCast((c.GLADloadproc), c.glfwGetProcAddress))) {
        std.debug.print("Failed to initialise GLAD", .{});
    }
    c.glViewport(0, 0, 800, 600);
    _ = c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    const vertices = [_]f32{
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        0.0,  0.5,  0.0,
    };
    var VBO: u32 = 0;
    c.glGenBuffers(1, &VBO);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices[0], c.GL_STATIC_DRAW);

    const vertexShaderSource =
        \\#version 330 core
        \\layout (location = 0) in vec3 aPos;
        \\void main()
        \\{
        \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
        \\}
    ;

    var vertexShader: u32 = 0;
    vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);

    c.glShaderSource(vertexShader, 1, @ptrCast([*c]const [*c]const u8, &vertexShaderSource), null);
    c.glCompileShader(vertexShader);

    var success: i32 = 0;
    var infoLog: [512]u8 = [_]u8{0} ** 512;
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        c.glGetShaderInfoLog(vertexShader, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n {s}\n", .{infoLog});
    }

    // Fragment shader
    const fragmentShaderSource =
        \\#version 330 core
        \\out vec4 FragColor;
        \\void main()
        \\{
        \\    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
        \\}
    ;

    var fragmentShader: u32 = 0;
    fragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(fragmentShader, 1, @ptrCast([*c]const [*c]const u8, &fragmentShaderSource), null);
    c.glCompileShader(fragmentShader);
    // TODO: check for compilation error here
    c.glGetShaderiv(fragmentShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        c.glGetShaderInfoLog(vertexShader, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n {s}\n", .{infoLog});
    }

    var shaderProgram: u32 = 0;
    shaderProgram = c.glCreateProgram();
    c.glAttachShader(shaderProgram, vertexShader);
    c.glAttachShader(shaderProgram, fragmentShader);
    c.glLinkProgram(shaderProgram);
    // TODO: check for compilation error here
    c.glGetProgramiv(shaderProgram, c.GL_LINK_STATUS, &success);
    if (success == 0) {
        c.glGetProgramInfoLog(shaderProgram, 512, null, &infoLog);
        std.debug.print("ERROR::PROGRAM::COMPILATION_FAILED\n {s}\n", .{infoLog});
    }

    c.glUseProgram(shaderProgram);
    // Since we linked them to the program and the program is already in use, we don't need them anymore
    //c.glDeleteShader(vertexShader);
    //c.glDeleteShader(fragmentShader);

    var VAO: u32 = 0;
    c.glGenVertexArrays(1, &VAO);
    c.glBindVertexArray(VAO);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices[0], c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    // render loop
    while (0 == c.glfwWindowShouldClose(window)) {
        //input
        processInput(window);

        //rendering commands here
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shaderProgram);
        c.glBindVertexArray(VAO);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        // check and call events and swap the buffers
        c.glfwPollEvents();
        c.glfwSwapBuffers(window);
    }
}

fn framebuffer_size_callback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}

fn processInput(window: ?*c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS)
        c.glfwSetWindowShouldClose(window, @boolToInt(true));
}
