// `fast-glob` is a fork of [`oxc-project/fast-glob`](https://github.com/oxc-project/fast-glob), which is a fork of [`devongovett/glob-match`](https://github.com/devongovett/glob-match).

const std = @import("std");

const Error = error{BraceNestingTooDeep};

const BraceStack = struct {
    elements: [10]Entry = undefined,
    len: u8 = 0,

    const Entry = struct {
        open_brace_index: u32,
        branch_index: u32,
    };

    fn append(self: *BraceStack, item: Entry) Error!void {
        if (self.len >= self.elements.len) {
            return Error.BraceNestingTooDeep;
        }
        self.elements[self.len] = item;
        self.len += 1;
    }

    fn pop(self: *BraceStack) Entry {
        self.len -= 1;
        return self.elements[self.len];
    }

    fn slice(self: *const BraceStack) []const Entry {
        return self.elements[0..self.len];
    }
};

pub fn match(glob: []const u8, path: []const u8) Error!bool {
    var state = State.init(glob, path);

    var negated = false;
    while (state.glob_index < glob.len and glob[state.glob_index] == '!') {
        negated = !negated;
        state.glob_index += 1;
    }

    var brace_stack = BraceStack{};

    return negated != try state.globMatchFrom(0, &brace_stack);
}

fn isSeparator(c: u8) bool {
    return c == '/' or c == '\\';
}

const State = struct {
    path_index: usize = 0,
    glob_index: usize = 0,
    brace_depth: usize = 0,

    wildcard: Wildcard = .{ .glob_index = 0, .path_index = 0, .brace_depth = 0 },
    globstar: Wildcard = .{ .glob_index = 0, .path_index = 0, .brace_depth = 0 },

    glob: []const u8,
    path: []const u8,

    const Wildcard = struct {
        glob_index: u32,
        path_index: u32,
        brace_depth: u32,
    };

    fn init(glob: []const u8, path: []const u8) State {
        return .{ .glob = glob, .path = path };
    }

    fn unescape(self: *State, c: *u8) bool {
        if (c.* == '\\') {
            self.glob_index += 1;
            if (self.glob_index >= self.glob.len) {
                return false;
            }
            c.* = switch (self.glob[self.glob_index]) {
                'a' => '\x61',
                'b' => '\x08',
                'n' => '\n',
                'r' => '\r',
                't' => '\t',
                else => |ch| ch,
            };
        }
        return true;
    }

    fn backtrack(self: *State) void {
        self.glob_index = self.wildcard.glob_index;
        self.path_index = self.wildcard.path_index;
        self.brace_depth = self.wildcard.brace_depth;
    }

    fn skipGlobstars(self: *State) void {
        var glob_index = self.glob_index + 2;

        while (glob_index + 4 <= self.glob.len and std.mem.eql(u8, self.glob[glob_index .. glob_index + 4], "/**/")) {
            glob_index += 3;
        }

        if (std.mem.eql(u8, self.glob[glob_index..], "/**")) {
            glob_index += 3;
        }

        self.glob_index = glob_index - 2;
    }

    fn skipToSeparator(self: *State, is_end_invalid: bool) void {
        if (self.path_index == self.path.len) {
            self.wildcard.path_index += 1;
            return;
        }

        var path_index = self.path_index;
        while (path_index < self.path.len and !isSeparator(self.path[path_index])) {
            path_index += 1;
        }

        if (is_end_invalid or path_index != self.path.len) {
            path_index += 1;
        }

        self.wildcard.path_index = @intCast(path_index);
        self.globstar = self.wildcard;
    }

    fn skipBranch(self: *State) void {
        var in_brackets = false;
        const end_brace_depth = self.brace_depth - 1;

        while (self.glob_index < self.glob.len) {
            switch (self.glob[self.glob_index]) {
                '{' => {
                    if (!in_brackets) {
                        self.brace_depth += 1;
                    }
                },
                '}' => {
                    if (!in_brackets) {
                        self.brace_depth -= 1;
                        if (self.brace_depth == end_brace_depth) {
                            self.glob_index += 1;
                            return;
                        }
                    }
                },
                '[' => {
                    if (!in_brackets) {
                        in_brackets = true;
                    }
                },
                ']' => in_brackets = false,
                '\\' => self.glob_index += 1,
                else => {},
            }
            self.glob_index += 1;
        }
    }

    fn matchBraceBranch(
        self: *const State,
        open_brace_index: usize,
        branch_index: usize,
        brace_stack: *BraceStack,
    ) Error!bool {
        try brace_stack.append(.{
            .open_brace_index = @intCast(open_brace_index),
            .branch_index = @intCast(branch_index),
        });

        var branch_state = self.*;
        branch_state.glob_index = branch_index;
        branch_state.brace_depth = brace_stack.len;

        const matched = try branch_state.globMatchFrom(branch_index, brace_stack);

        _ = brace_stack.pop();

        return matched;
    }

    fn matchBrace(self: *State, brace_stack: *BraceStack) Error!bool {
        var brace_depth: usize = 0;
        var in_brackets = false;

        const open_brace_index = self.glob_index;
        var branch_index: usize = 0;

        while (self.glob_index < self.glob.len) {
            switch (self.glob[self.glob_index]) {
                '{' => if (!in_brackets) {
                    brace_depth += 1;
                    if (brace_depth == 1) {
                        branch_index = self.glob_index + 1;
                    }
                },
                '}' => if (!in_brackets) {
                    brace_depth -= 1;
                    if (brace_depth == 0) {
                        if (try self.matchBraceBranch(open_brace_index, branch_index, brace_stack)) {
                            return true;
                        }
                        break;
                    }
                },
                ',' => if (brace_depth == 1) {
                    if (try self.matchBraceBranch(open_brace_index, branch_index, brace_stack)) {
                        return true;
                    }
                    branch_index = self.glob_index + 1;
                },
                '[' => if (!in_brackets) {
                    in_brackets = true;
                },
                ']' => in_brackets = false,
                '\\' => self.glob_index += 1,
                else => {},
            }
            self.glob_index += 1;
        }

        return false;
    }

    fn globMatchFrom(self: *State, match_start: usize, brace_stack: *BraceStack) Error!bool {
        outer: while (self.glob_index < self.glob.len or self.path_index < self.path.len) {
            if (self.glob_index < self.glob.len) {
                switch (self.glob[self.glob_index]) {
                    '*' => {
                        const is_globstar = self.glob_index + 1 < self.glob.len and self.glob[self.glob_index + 1] == '*';
                        if (is_globstar) {
                            self.skipGlobstars();
                        }

                        self.wildcard.glob_index = @intCast(self.glob_index);
                        self.wildcard.path_index = @intCast(self.path_index + 1);
                        self.wildcard.brace_depth = @intCast(self.brace_depth);

                        var in_globstar = false;
                        if (is_globstar) {
                            self.glob_index += 2;

                            const is_end_invalid = self.glob_index != self.glob.len;

                            if ((self.glob_index -| match_start < 3 or self.glob[self.glob_index - 3] == '/') and
                                (!is_end_invalid or self.glob[self.glob_index] == '/'))
                            {
                                if (is_end_invalid) {
                                    self.glob_index += 1;
                                }

                                self.skipToSeparator(is_end_invalid);
                                in_globstar = true;
                            }
                        } else {
                            self.glob_index += 1;
                        }

                        if (!in_globstar and self.path_index < self.path.len and isSeparator(self.path[self.path_index])) {
                            self.wildcard = self.globstar;
                        }

                        continue;
                    },
                    '?' => {
                        if (self.path_index < self.path.len) {
                            if (!isSeparator(self.path[self.path_index])) {
                                self.glob_index += 1;
                                self.path_index += 1;
                                continue;
                            }
                        }
                    },
                    '[' => {
                        if (self.path_index < self.path.len) {
                            self.glob_index += 1;

                            var negated = false;
                            if (self.glob_index < self.glob.len and (self.glob[self.glob_index] == '^' or self.glob[self.glob_index] == '!')) {
                                negated = true;
                                self.glob_index += 1;
                            }

                            var first = true;
                            var is_match = false;
                            const c = self.path[self.path_index];

                            while (self.glob_index < self.glob.len and (first or self.glob[self.glob_index] != ']')) {
                                var low = self.glob[self.glob_index];
                                if (!self.unescape(&low)) {
                                    return false;
                                }

                                self.glob_index += 1;

                                const high = if (self.glob_index + 1 < self.glob.len and
                                    self.glob[self.glob_index] == '-' and
                                    self.glob[self.glob_index + 1] != ']')
                                blk: {
                                    self.glob_index += 1;

                                    var high = self.glob[self.glob_index];
                                    if (!self.unescape(&high)) {
                                        return false;
                                    }

                                    self.glob_index += 1;
                                    break :blk high;
                                } else low;

                                if (low <= c and c <= high) {
                                    is_match = true;
                                }

                                first = false;
                            }

                            if (self.glob_index >= self.glob.len) {
                                return false;
                            }

                            self.glob_index += 1;
                            if (is_match != negated) {
                                self.path_index += 1;
                                continue;
                            }
                        }
                    },
                    '{' => {
                        // Check if this brace is already in the stack
                        for (brace_stack.slice()) |entry| {
                            if (entry.open_brace_index == self.glob_index) {
                                self.glob_index = entry.branch_index;
                                self.brace_depth += 1;
                                continue :outer;
                            }
                        }
                        return self.matchBrace(brace_stack);
                    },
                    else => |c| {
                        switch (c) {
                            ',', '}' => if (self.brace_depth > 0) {
                                self.skipBranch();
                                continue;
                            },
                            else => {},
                        }

                        if (self.path_index < self.path.len) {
                            var char = c;
                            if (!self.unescape(&char)) {
                                return false;
                            }

                            const is_match = if (char == '/')
                                isSeparator(self.path[self.path_index])
                            else
                                self.path[self.path_index] == char;

                            if (is_match) {
                                self.glob_index += 1;
                                self.path_index += 1;

                                if (char == '/') {
                                    self.wildcard = self.globstar;
                                }

                                continue;
                            }
                        }
                    },
                }
            }

            if (self.wildcard.path_index > 0 and self.wildcard.path_index <= self.path.len) {
                self.backtrack();
                continue;
            }

            return false;
        }

        return true;
    }
};
