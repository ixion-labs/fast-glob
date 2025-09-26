_default:
    @just --list

fmt:
    zig fmt src

test +args='':
    zig build test --summary all --verbose {{ args }}

bench +args='':
    zig build bench -Doptimize=ReleaseFast {{ args }}
