<p align="center">
  <h3 align="center">fast-glob</h3>
</p>

---

<div align="center">

[![CodSpeed](https://img.shields.io/endpoint?url=https://codspeed.io/badge.json)](https://codspeed.io/ixion-labs/fast-glob)

</div>

---

This library is a Zig port of the [`oxc` fork](https://github.com/oxc-project/fast-glob) of [`devongovett/glob-match`](https://github.com/devongovett/glob-match).

The logic was mostly ported from Rust to Zig almost exclusively by Claude Sonnet 4. Each line almost identically maps over between the two versions with slight adjustments for Zig syntax and semantics.

## Installation

Add the library to your Zig project.

```sh
zig fetch --save=fast_glob git+https://github.com/ixion-labs/fast-glob
```

Then, in your `build.zig`, add the library to your exe or lib target.

```zig
main_exe.root_module.addImport(
    "fast_glob",
    b.dependency("fast_glob", .{ .target = target, .optimize = optimize }).module("fast_glob"),
);
```

## Usage

```zig
const fast_glob = @import("fast_glob");

const is_match = try fast_glob.match(
    "some/**/n*d[k-m]e?txt",
    "some/a/bigger/path/to/the/crazy/needle.txt",
);
```

## Syntax

| Syntax  | Meaning                                                                                                                                                                                             |
| ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `?`     | Matches any single character.                                                                                                                                                                       |
| `*`     | Matches zero or more characters, except for path separators (e.g. `/`).                                                                                                                             |
| `**`    | Matches zero or more characters, including path separators. Must match a complete path segment (i.e. followed by a `/` or the end of the pattern).                                                  |
| `[ab]`  | Matches one of the characters contained in the brackets. Character ranges, e.g. `[a-z]` are also supported. Use `[!ab]` or `[^ab]` to match any character _except_ those contained in the brackets. |
| `{a,b}` | Matches one of the patterns contained in the braces. Any of the wildcard characters can be used in the sub-patterns. Braces may be nested up to 10 levels deep.                                     |
| `!`     | When at the start of the glob, this negates the result. Multiple `!` characters negate the glob multiple times.                                                                                     |
| `\`     | A backslash character may be used to escape any of the above special characters.                                                                                                                    |

## Credits

- The [fast-glob](https://github.com/oxc-project/fast-glob) fork created by the `oxc` team.
- The [glob-match](https://github.com/devongovett/glob-match) project created by [@devongovett](https://github.com/devongovett) which is an extremely fast glob matching library in Rust.
