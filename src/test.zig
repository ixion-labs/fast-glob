const std = @import("std");

const fast_glob = @import("fast_glob.zig");

fn glob_match(input: []const u8, output: []const u8) bool {
    return fast_glob.match(input, output) catch unreachable;
}

test "generic_input" {
    try std.testing.expect(glob_match("**/*", "foo"));
    try std.testing.expect(glob_match("**/*", "foo"));
    try std.testing.expect(glob_match("**/*", "foo"));
    try std.testing.expect(glob_match("**/*", "foo"));
    try std.testing.expect(glob_match("**/*", "foo"));

    // try std.testing.expect(glob_match("**/*".as_bytes(), "foo"));
    // try std.testing.expect(glob_match("**/*".as_bytes(), "foo".as_bytes()));
    // try std.testing.expect(glob_match("**/*".as_bytes(), "foo"));
}

test "webpack" {
    // Match everything
    try std.testing.expect(glob_match("**/*", "foo"));

    // Match the end
    try std.testing.expect(glob_match("**/f*", "foo"));

    // Match the start
    try std.testing.expect(glob_match("**/*o", "foo"));

    // Match the middle
    try std.testing.expect(glob_match("**/f*uck", "firetruck"));

    // Don't match without Regexp 'g'
    try std.testing.expect(!glob_match("**/uc", "firetruck"));

    // Match zero characters
    try std.testing.expect(glob_match("**/f*uck", "fuck"));

    // More complex matches
    try std.testing.expect(glob_match("**/*.min.js", "some/jquery.min.js"));
    try std.testing.expect(glob_match("**/*.min.*", "some/jquery.min.js"));
    try std.testing.expect(glob_match("*/js/*.js", "some/js/jquery.min.js"));

    // More complex matches with RegExp 'g' flag (complex regression)
    try std.testing.expect(glob_match("**/*.min.*", "some/jquery.min.js"));
    try std.testing.expect(glob_match("**/*.min.js", "some/jquery.min.js"));
    try std.testing.expect(glob_match("*/js/*.js", "some/js/jquery.min.js"));

    try std.testing.expect(!glob_match("\\\\/$^+?.()=!|{},[].*", "\\/$^+?.()=!|{},[].*"));

    // Equivalent matches without/with using RegExp 'g'
    try std.testing.expect(!glob_match("**/.min.", "some/jquery.min.js"));
    try std.testing.expect(glob_match("**/*.min.*", "some/jquery.min.js"));
    try std.testing.expect(!glob_match("**/.min.", "some/jquery.min.js"));

    try std.testing.expect(!glob_match("**/min.js", "some/jquery.min.js"));
    try std.testing.expect(glob_match("**/*.min.js", "some/jquery.min.js"));
    try std.testing.expect(!glob_match("**/min.js", "some/jquery.min.js"));

    // Match anywhere (globally) using RegExp 'g'
    try std.testing.expect(!glob_match("**/min", "some/jquery.min.js"));
    try std.testing.expect(!glob_match("/js/", "some/js/jquery.min.js"));

    try std.testing.expect(!glob_match("/js*jq*.js", "some/js/jquery.min.js"));

    // Extended mode

    // ?: Match one character, no more and no less
    try std.testing.expect(glob_match("**/f?o", "foo"));
    try std.testing.expect(!glob_match("**/f?o", "fooo"));
    try std.testing.expect(!glob_match("**/f?oo", "foo"));

    // ?: Match one character with RegExp 'g'
    try std.testing.expect(glob_match("**/f?o", "foo"));
    try std.testing.expect(!glob_match("**/f?o", "fooo"));
    try std.testing.expect(glob_match("**/f?o?", "fooo"));
    try std.testing.expect(!glob_match("**/?fo", "fooo"));
    try std.testing.expect(!glob_match("**/f?oo", "foo"));
    try std.testing.expect(!glob_match("**/foo?", "foo"));

    // []: Match a character range
    try std.testing.expect(glob_match("**/fo[oz]", "foo"));
    try std.testing.expect(glob_match("**/fo[oz]", "foz"));
    try std.testing.expect(!glob_match("**/fo[oz]", "fog"));

    // []: Match a character range and RegExp 'g' (regresion)
    try std.testing.expect(glob_match("**/fo[oz]", "foo"));
    try std.testing.expect(glob_match("**/fo[oz]", "foz"));
    try std.testing.expect(!glob_match("**/fo[oz]", "fog"));

    // {}: Match a choice of different substrings
    try std.testing.expect(glob_match("**/foo{bar,baaz}", "foobaaz"));
    try std.testing.expect(glob_match("**/foo{bar,baaz}", "foobar"));
    try std.testing.expect(!glob_match("**/foo{bar,baaz}", "foobuzz"));
    try std.testing.expect(glob_match("**/foo{bar,b*z}", "foobuzz"));

    // {}: Match a choice of different substrings and RegExp 'g' (regression)
    try std.testing.expect(glob_match("**/foo{bar,baaz}", "foobaaz"));
    try std.testing.expect(glob_match("**/foo{bar,baaz}", "foobar"));
    try std.testing.expect(!glob_match("**/foo{bar,baaz}", "foobuzz"));

    // More complex extended matches
    try std.testing.expect(glob_match("?o[oz].b*z.com/{*.js,*.html}", "foo.baaz.com/jquery.min.js"));
    try std.testing.expect(glob_match("?o[oz].b*z.com/{*.js,*.html}", "moz.buzz.com/index.html"));
    try std.testing.expect(!glob_match("?o[oz].b*z.com/{*.js,*.html}", "moz.buzz.com/index.htm"));
    try std.testing.expect(!glob_match("?o[oz].b*z.com/{*.js,*.html}", "moz.bar.com/index.html"));
    try std.testing.expect(!glob_match("?o[oz].b*z.com/{*.js,*.html}", "flozz.buzz.com/index.html"));

    // More complex extended matches and RegExp 'g' (regresion)
    try std.testing.expect(glob_match("?o[oz].b*z.com/{*.js,*.html}", "foo.baaz.com/jquery.min.js"));
    try std.testing.expect(glob_match("?o[oz].b*z.com/{*.js,*.html}", "moz.buzz.com/index.html"));
    try std.testing.expect(!glob_match("?o[oz].b*z.com/{*.js,*.html}", "moz.buzz.com/index.htm"));
    try std.testing.expect(!glob_match("?o[oz].b*z.com/{*.js,*.html}", "moz.bar.com/index.html"));
    try std.testing.expect(!glob_match("?o[oz].b*z.com/{*.js,*.html}", "flozz.buzz.com/index.html"));

    // globstar
    try std.testing.expect(glob_match("some/**/{*.js,*.html}", "some/bar/jquery.min.js"));
    try std.testing.expect(glob_match("some/**/{*.js,*.html}", "some/bar/baz/jquery.min.js"));
    try std.testing.expect(glob_match("some/**", "some/bar/baz/jquery.min.js"));

    try std.testing.expect(glob_match("\\\\/$^+.()=!|,.*", "\\/$^+.()=!|,.*"));

    // globstar specific tests
    try std.testing.expect(glob_match("/foo/*", "/foo/bar.txt"));
    try std.testing.expect(glob_match("/foo/**", "/foo/baz.txt"));
    try std.testing.expect(glob_match("/foo/**", "/foo/bar/baz.txt"));
    try std.testing.expect(glob_match("/foo/*/*.txt", "/foo/bar/baz.txt"));
    try std.testing.expect(glob_match("/foo/**/*.txt", "/foo/bar/baz.txt"));
    try std.testing.expect(glob_match("/foo/**/*.txt", "/foo/bar/baz/qux.txt"));
    try std.testing.expect(glob_match("/foo/**/bar.txt", "/foo/bar.txt"));
    try std.testing.expect(glob_match("/foo/**/**/bar.txt", "/foo/bar.txt"));
    try std.testing.expect(glob_match("/foo/**/*/baz.txt", "/foo/bar/baz.txt"));
    try std.testing.expect(glob_match("/foo/**/*.txt", "/foo/bar.txt"));
    try std.testing.expect(glob_match("/foo/**/**/*.txt", "/foo/bar.txt"));
    try std.testing.expect(glob_match("/foo/**/*/*.txt", "/foo/bar/baz.txt"));
    try std.testing.expect(glob_match("**/*.txt", "/foo/bar/baz/qux.txt"));
    try std.testing.expect(glob_match("**/foo.txt", "foo.txt"));
    try std.testing.expect(glob_match("**/*.txt", "foo.txt"));

    try std.testing.expect(!glob_match("/foo/*", "/foo/bar/baz.txt"));
    try std.testing.expect(!glob_match("/foo/*.txt", "/foo/bar/baz.txt"));
    try std.testing.expect(!glob_match("/foo/*/*.txt", "/foo/bar/baz/qux.txt"));
    try std.testing.expect(!glob_match("/foo/*/bar.txt", "/foo/bar.txt"));
    try std.testing.expect(!glob_match("/foo/*/*/baz.txt", "/foo/bar/baz.txt"));
    try std.testing.expect(!glob_match("/foo/**.txt", "/foo/bar/baz/qux.txt"));
    try std.testing.expect(!glob_match("/foo/bar**/*.txt", "/foo/bar/baz/qux.txt"));
    try std.testing.expect(!glob_match("/foo/bar**", "/foo/bar/baz.txt"));
    try std.testing.expect(!glob_match("**/.txt", "/foo/bar/baz/qux.txt"));
    try std.testing.expect(!glob_match("*/*.txt", "/foo/bar/baz/qux.txt"));
    try std.testing.expect(!glob_match("*/*.txt", "foo.txt"));

    try std.testing.expect(!glob_match("some/*", "some/bar/baz/jquery.min.js"));

    try std.testing.expect(!glob_match("some/*", "some/bar/baz/jquery.min.js"));
    try std.testing.expect(glob_match("some/**", "some/bar/baz/jquery.min.js"));

    try std.testing.expect(glob_match("some/*/*/jquery.min.js", "some/bar/baz/jquery.min.js"));
    try std.testing.expect(glob_match("some/**/jquery.min.js", "some/bar/baz/jquery.min.js"));
    try std.testing.expect(glob_match("some/*/*/jquery.min.js", "some/bar/baz/jquery.min.js"));
    try std.testing.expect(!glob_match("some/*/jquery.min.js", "some/bar/baz/jquery.min.js"));
    try std.testing.expect(!glob_match("some/*/jquery.min.js", "some/bar/baz/jquery.min.js"));
}

test "basic" {
    try std.testing.expect(glob_match("abc", "abc"));
    try std.testing.expect(glob_match("*", "abc"));
    try std.testing.expect(glob_match("*", ""));
    try std.testing.expect(glob_match("**", ""));
    try std.testing.expect(glob_match("*c", "abc"));
    try std.testing.expect(!glob_match("*b", "abc"));
    try std.testing.expect(glob_match("a*", "abc"));
    try std.testing.expect(!glob_match("b*", "abc"));
    try std.testing.expect(glob_match("a*", "a"));
    try std.testing.expect(glob_match("*a", "a"));
    try std.testing.expect(glob_match("a*b*c*d*e*", "axbxcxdxe"));
    try std.testing.expect(glob_match("a*b*c*d*e*", "axbxcxdxexxx"));
    try std.testing.expect(glob_match("a*b?c*x", "abxbbxdbxebxczzx"));
    try std.testing.expect(!glob_match("a*b?c*x", "abxbbxdbxebxczzy"));

    try std.testing.expect(glob_match("a/*/test", "a/foo/test"));
    try std.testing.expect(!glob_match("a/*/test", "a/foo/bar/test"));
    try std.testing.expect(glob_match("a/**/test", "a/foo/test"));
    try std.testing.expect(glob_match("a/**/test", "a/foo/bar/test"));
    try std.testing.expect(glob_match("a/**/b/c", "a/foo/bar/b/c"));
    try std.testing.expect(glob_match("a\\*b", "a*b"));
    try std.testing.expect(!glob_match("a\\*b", "axb"));

    try std.testing.expect(glob_match("[abc]", "a"));
    try std.testing.expect(glob_match("[abc]", "b"));
    try std.testing.expect(glob_match("[abc]", "c"));
    try std.testing.expect(!glob_match("[abc]", "d"));
    try std.testing.expect(glob_match("x[abc]x", "xax"));
    try std.testing.expect(glob_match("x[abc]x", "xbx"));
    try std.testing.expect(glob_match("x[abc]x", "xcx"));
    try std.testing.expect(!glob_match("x[abc]x", "xdx"));
    try std.testing.expect(!glob_match("x[abc]x", "xay"));
    try std.testing.expect(glob_match("[?]", "?"));
    try std.testing.expect(!glob_match("[?]", "a"));
    try std.testing.expect(glob_match("[*]", "*"));
    try std.testing.expect(!glob_match("[*]", "a"));

    try std.testing.expect(glob_match("[a-cx]", "a"));
    try std.testing.expect(glob_match("[a-cx]", "b"));
    try std.testing.expect(glob_match("[a-cx]", "c"));
    try std.testing.expect(!glob_match("[a-cx]", "d"));
    try std.testing.expect(glob_match("[a-cx]", "x"));

    try std.testing.expect(!glob_match("[^abc]", "a"));
    try std.testing.expect(!glob_match("[^abc]", "b"));
    try std.testing.expect(!glob_match("[^abc]", "c"));
    try std.testing.expect(glob_match("[^abc]", "d"));
    try std.testing.expect(!glob_match("[!abc]", "a"));
    try std.testing.expect(!glob_match("[!abc]", "b"));
    try std.testing.expect(!glob_match("[!abc]", "c"));
    try std.testing.expect(glob_match("[!abc]", "d"));
    try std.testing.expect(glob_match("[\\!]", "!"));

    try std.testing.expect(glob_match("a*b*[cy]*d*e*", "axbxcxdxexxx"));
    try std.testing.expect(glob_match("a*b*[cy]*d*e*", "axbxyxdxexxx"));
    try std.testing.expect(glob_match("a*b*[cy]*d*e*", "axbxxxyxdxexxx"));

    try std.testing.expect(glob_match("test.{jpg,png}", "test.jpg"));
    try std.testing.expect(glob_match("test.{jpg,png}", "test.png"));
    try std.testing.expect(glob_match("test.{j*g,p*g}", "test.jpg"));
    try std.testing.expect(glob_match("test.{j*g,p*g}", "test.jpxxxg"));
    try std.testing.expect(glob_match("test.{j*g,p*g}", "test.jxg"));
    try std.testing.expect(!glob_match("test.{j*g,p*g}", "test.jnt"));

    try std.testing.expect(glob_match("test.{j*g,j*c}", "test.jnc"));
    try std.testing.expect(glob_match("test.{jpg,p*g}", "test.png"));
    try std.testing.expect(glob_match("test.{jpg,p*g}", "test.pxg"));
    try std.testing.expect(!glob_match("test.{jpg,p*g}", "test.pnt"));
    try std.testing.expect(glob_match("test.{jpeg,png}", "test.jpeg"));
    try std.testing.expect(!glob_match("test.{jpeg,png}", "test.jpg"));
    try std.testing.expect(glob_match("test.{jpeg,png}", "test.png"));
    try std.testing.expect(glob_match("test.{jp\\,g,png}", "test.jp,g"));
    try std.testing.expect(!glob_match("test.{jp\\,g,png}", "test.jxg"));
    try std.testing.expect(glob_match("test/{foo,bar}/baz", "test/foo/baz"));
    try std.testing.expect(glob_match("test/{foo,bar}/baz", "test/bar/baz"));
    try std.testing.expect(!glob_match("test/{foo,bar}/baz", "test/baz/baz"));
    try std.testing.expect(glob_match("test/{foo*,bar*}/baz", "test/foooooo/baz"));
    try std.testing.expect(glob_match("test/{foo*,bar*}/baz", "test/barrrrr/baz"));
    try std.testing.expect(glob_match("test/{*foo,*bar}/baz", "test/xxxxfoo/baz"));
    try std.testing.expect(glob_match("test/{*foo,*bar}/baz", "test/xxxxbar/baz"));
    try std.testing.expect(glob_match("test/{foo/**,bar}/baz", "test/bar/baz"));
    try std.testing.expect(!glob_match("test/{foo/**,bar}/baz", "test/bar/test/baz"));

    try std.testing.expect(!glob_match("*.txt", "some/big/path/to/the/needle.txt"));
    try std.testing.expect(glob_match("some/**/needle.{js,tsx,mdx,ts,jsx,txt}", "some/a/bigger/path/to/the/crazy/needle.txt"));
    try std.testing.expect(glob_match("some/**/{a,b,c}/**/needle.txt", "some/foo/a/bigger/path/to/the/crazy/needle.txt"));
    try std.testing.expect(!glob_match("some/**/{a,b,c}/**/needle.txt", "some/foo/d/bigger/path/to/the/crazy/needle.txt"));

    try std.testing.expect(glob_match("a/{a{a,b},b}", "a/aa"));
    try std.testing.expect(glob_match("a/{a{a,b},b}", "a/ab"));
    try std.testing.expect(!glob_match("a/{a{a,b},b}", "a/ac"));
    try std.testing.expect(glob_match("a/{a{a,b},b}", "a/b"));
    try std.testing.expect(!glob_match("a/{a{a,b},b}", "a/c"));
    try std.testing.expect(glob_match("a/{b,c[}]*}", "a/b"));
    try std.testing.expect(glob_match("a/{b,c[}]*}", "a/c}xx"));

    try std.testing.expect(glob_match("/**/*a", "/a/a"));
    try std.testing.expect(glob_match("**/*.js", "a/b.c/c.js"));
    try std.testing.expect(glob_match("**/**/*.js", "a/b.c/c.js"));
    try std.testing.expect(glob_match("a/**/*.d", "a/b/c.d"));
    try std.testing.expect(glob_match("a/**/*.d", "a/.b/c.d"));

    try std.testing.expect(glob_match("**/*/**", "a/b/c"));
    try std.testing.expect(glob_match("**/*/c.js", "a/b/c.js"));
}

// The below tests are based on Bash and micromatch.
// https://github.com/micromatch/picomatch/blob/master/test/bash.js
// Converted using the following find and replace regex:
// find: assert\(([!])?isMatch\('(.*?)', ['"](.*?)['"]\)\);
// replace: assert!($1glob_match("$3", "$2"));

test "bash" {
    try std.testing.expect(!glob_match("a*", "*"));
    try std.testing.expect(!glob_match("a*", "**"));
    try std.testing.expect(!glob_match("a*", "\\*"));
    try std.testing.expect(!glob_match("a*", "a/*"));
    try std.testing.expect(!glob_match("a*", "b"));
    try std.testing.expect(!glob_match("a*", "bc"));
    try std.testing.expect(!glob_match("a*", "bcd"));
    try std.testing.expect(!glob_match("a*", "bdir/"));
    try std.testing.expect(!glob_match("a*", "Beware"));
    try std.testing.expect(glob_match("a*", "a"));
    try std.testing.expect(glob_match("a*", "ab"));
    try std.testing.expect(glob_match("a*", "abc"));

    try std.testing.expect(!glob_match("\\a*", "*"));
    try std.testing.expect(!glob_match("\\a*", "**"));
    try std.testing.expect(!glob_match("\\a*", "\\*"));

    try std.testing.expect(glob_match("\\a*", "a"));
    try std.testing.expect(!glob_match("\\a*", "a/*"));
    try std.testing.expect(glob_match("\\a*", "abc"));
    try std.testing.expect(glob_match("\\a*", "abd"));
    try std.testing.expect(glob_match("\\a*", "abe"));
    try std.testing.expect(!glob_match("\\a*", "b"));
    try std.testing.expect(!glob_match("\\a*", "bb"));
    try std.testing.expect(!glob_match("\\a*", "bcd"));
    try std.testing.expect(!glob_match("\\a*", "bdir/"));
    try std.testing.expect(!glob_match("\\a*", "Beware"));
    try std.testing.expect(!glob_match("\\a*", "c"));
    try std.testing.expect(!glob_match("\\a*", "ca"));
    try std.testing.expect(!glob_match("\\a*", "cb"));
    try std.testing.expect(!glob_match("\\a*", "d"));
    try std.testing.expect(!glob_match("\\a*", "dd"));
    try std.testing.expect(!glob_match("\\a*", "de"));
}

test "bash_directories" {
    try std.testing.expect(!glob_match("b*/", "*"));
    try std.testing.expect(!glob_match("b*/", "**"));
    try std.testing.expect(!glob_match("b*/", "\\*"));
    try std.testing.expect(!glob_match("b*/", "a"));
    try std.testing.expect(!glob_match("b*/", "a/*"));
    try std.testing.expect(!glob_match("b*/", "abc"));
    try std.testing.expect(!glob_match("b*/", "abd"));
    try std.testing.expect(!glob_match("b*/", "abe"));
    try std.testing.expect(!glob_match("b*/", "b"));
    try std.testing.expect(!glob_match("b*/", "bb"));
    try std.testing.expect(!glob_match("b*/", "bcd"));
    try std.testing.expect(glob_match("b*/", "bdir/"));
    try std.testing.expect(!glob_match("b*/", "Beware"));
    try std.testing.expect(!glob_match("b*/", "c"));
    try std.testing.expect(!glob_match("b*/", "ca"));
    try std.testing.expect(!glob_match("b*/", "cb"));
    try std.testing.expect(!glob_match("b*/", "d"));
    try std.testing.expect(!glob_match("b*/", "dd"));
    try std.testing.expect(!glob_match("b*/", "de"));
}

test "bash_escaping" {
    try std.testing.expect(!glob_match("\\^", "*"));
    try std.testing.expect(!glob_match("\\^", "**"));
    try std.testing.expect(!glob_match("\\^", "\\*"));
    try std.testing.expect(!glob_match("\\^", "a"));
    try std.testing.expect(!glob_match("\\^", "a/*"));
    try std.testing.expect(!glob_match("\\^", "abc"));
    try std.testing.expect(!glob_match("\\^", "abd"));
    try std.testing.expect(!glob_match("\\^", "abe"));
    try std.testing.expect(!glob_match("\\^", "b"));
    try std.testing.expect(!glob_match("\\^", "bb"));
    try std.testing.expect(!glob_match("\\^", "bcd"));
    try std.testing.expect(!glob_match("\\^", "bdir/"));
    try std.testing.expect(!glob_match("\\^", "Beware"));
    try std.testing.expect(!glob_match("\\^", "c"));
    try std.testing.expect(!glob_match("\\^", "ca"));
    try std.testing.expect(!glob_match("\\^", "cb"));
    try std.testing.expect(!glob_match("\\^", "d"));
    try std.testing.expect(!glob_match("\\^", "dd"));
    try std.testing.expect(!glob_match("\\^", "de"));

    try std.testing.expect(glob_match("\\*", "*"));
    // try std.testing.expect(glob_match("\\*", "\\*"));
    try std.testing.expect(!glob_match("\\*", "**"));
    try std.testing.expect(!glob_match("\\*", "a"));
    try std.testing.expect(!glob_match("\\*", "a/*"));
    try std.testing.expect(!glob_match("\\*", "abc"));
    try std.testing.expect(!glob_match("\\*", "abd"));
    try std.testing.expect(!glob_match("\\*", "abe"));
    try std.testing.expect(!glob_match("\\*", "b"));
    try std.testing.expect(!glob_match("\\*", "bb"));
    try std.testing.expect(!glob_match("\\*", "bcd"));
    try std.testing.expect(!glob_match("\\*", "bdir/"));
    try std.testing.expect(!glob_match("\\*", "Beware"));
    try std.testing.expect(!glob_match("\\*", "c"));
    try std.testing.expect(!glob_match("\\*", "ca"));
    try std.testing.expect(!glob_match("\\*", "cb"));
    try std.testing.expect(!glob_match("\\*", "d"));
    try std.testing.expect(!glob_match("\\*", "dd"));
    try std.testing.expect(!glob_match("\\*", "de"));

    try std.testing.expect(!glob_match("a\\*", "*"));
    try std.testing.expect(!glob_match("a\\*", "**"));
    try std.testing.expect(!glob_match("a\\*", "\\*"));
    try std.testing.expect(!glob_match("a\\*", "a"));
    try std.testing.expect(!glob_match("a\\*", "a/*"));
    try std.testing.expect(!glob_match("a\\*", "abc"));
    try std.testing.expect(!glob_match("a\\*", "abd"));
    try std.testing.expect(!glob_match("a\\*", "abe"));
    try std.testing.expect(!glob_match("a\\*", "b"));
    try std.testing.expect(!glob_match("a\\*", "bb"));
    try std.testing.expect(!glob_match("a\\*", "bcd"));
    try std.testing.expect(!glob_match("a\\*", "bdir/"));
    try std.testing.expect(!glob_match("a\\*", "Beware"));
    try std.testing.expect(!glob_match("a\\*", "c"));
    try std.testing.expect(!glob_match("a\\*", "ca"));
    try std.testing.expect(!glob_match("a\\*", "cb"));
    try std.testing.expect(!glob_match("a\\*", "d"));
    try std.testing.expect(!glob_match("a\\*", "dd"));
    try std.testing.expect(!glob_match("a\\*", "de"));

    try std.testing.expect(glob_match("*q*", "aqa"));
    try std.testing.expect(glob_match("*q*", "aaqaa"));
    try std.testing.expect(!glob_match("*q*", "*"));
    try std.testing.expect(!glob_match("*q*", "**"));
    try std.testing.expect(!glob_match("*q*", "\\*"));
    try std.testing.expect(!glob_match("*q*", "a"));
    try std.testing.expect(!glob_match("*q*", "a/*"));
    try std.testing.expect(!glob_match("*q*", "abc"));
    try std.testing.expect(!glob_match("*q*", "abd"));
    try std.testing.expect(!glob_match("*q*", "abe"));
    try std.testing.expect(!glob_match("*q*", "b"));
    try std.testing.expect(!glob_match("*q*", "bb"));
    try std.testing.expect(!glob_match("*q*", "bcd"));
    try std.testing.expect(!glob_match("*q*", "bdir/"));
    try std.testing.expect(!glob_match("*q*", "Beware"));
    try std.testing.expect(!glob_match("*q*", "c"));
    try std.testing.expect(!glob_match("*q*", "ca"));
    try std.testing.expect(!glob_match("*q*", "cb"));
    try std.testing.expect(!glob_match("*q*", "d"));
    try std.testing.expect(!glob_match("*q*", "dd"));
    try std.testing.expect(!glob_match("*q*", "de"));

    try std.testing.expect(glob_match("\\**", "*"));
    try std.testing.expect(glob_match("\\**", "**"));
    try std.testing.expect(!glob_match("\\**", "\\*"));
    try std.testing.expect(!glob_match("\\**", "a"));
    try std.testing.expect(!glob_match("\\**", "a/*"));
    try std.testing.expect(!glob_match("\\**", "abc"));
    try std.testing.expect(!glob_match("\\**", "abd"));
    try std.testing.expect(!glob_match("\\**", "abe"));
    try std.testing.expect(!glob_match("\\**", "b"));
    try std.testing.expect(!glob_match("\\**", "bb"));
    try std.testing.expect(!glob_match("\\**", "bcd"));
    try std.testing.expect(!glob_match("\\**", "bdir/"));
    try std.testing.expect(!glob_match("\\**", "Beware"));
    try std.testing.expect(!glob_match("\\**", "c"));
    try std.testing.expect(!glob_match("\\**", "ca"));
    try std.testing.expect(!glob_match("\\**", "cb"));
    try std.testing.expect(!glob_match("\\**", "d"));
    try std.testing.expect(!glob_match("\\**", "dd"));
    try std.testing.expect(!glob_match("\\**", "de"));
}

test "bash_classes" {
    try std.testing.expect(!glob_match("a*[^c]", "*"));
    try std.testing.expect(!glob_match("a*[^c]", "**"));
    try std.testing.expect(!glob_match("a*[^c]", "\\*"));
    try std.testing.expect(!glob_match("a*[^c]", "a"));
    try std.testing.expect(!glob_match("a*[^c]", "a/*"));
    try std.testing.expect(!glob_match("a*[^c]", "abc"));
    try std.testing.expect(glob_match("a*[^c]", "abd"));
    try std.testing.expect(glob_match("a*[^c]", "abe"));
    try std.testing.expect(!glob_match("a*[^c]", "b"));
    try std.testing.expect(!glob_match("a*[^c]", "bb"));
    try std.testing.expect(!glob_match("a*[^c]", "bcd"));
    try std.testing.expect(!glob_match("a*[^c]", "bdir/"));
    try std.testing.expect(!glob_match("a*[^c]", "Beware"));
    try std.testing.expect(!glob_match("a*[^c]", "c"));
    try std.testing.expect(!glob_match("a*[^c]", "ca"));
    try std.testing.expect(!glob_match("a*[^c]", "cb"));
    try std.testing.expect(!glob_match("a*[^c]", "d"));
    try std.testing.expect(!glob_match("a*[^c]", "dd"));
    try std.testing.expect(!glob_match("a*[^c]", "de"));
    try std.testing.expect(!glob_match("a*[^c]", "baz"));
    try std.testing.expect(!glob_match("a*[^c]", "bzz"));
    try std.testing.expect(!glob_match("a*[^c]", "BZZ"));
    try std.testing.expect(!glob_match("a*[^c]", "beware"));
    try std.testing.expect(!glob_match("a*[^c]", "BewAre"));

    try std.testing.expect(glob_match("a[X-]b", "a-b"));
    try std.testing.expect(glob_match("a[X-]b", "aXb"));

    try std.testing.expect(!glob_match("[a-y]*[^c]", "*"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "a*"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "**"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "\\*"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "a"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "a123b"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "a123c"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "ab"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "a/*"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "abc"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "abd"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "abe"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "b"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "bd"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "bb"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "bcd"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "bdir/"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "Beware"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "c"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "ca"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "cb"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "d"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "dd"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "de"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "baz"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "bzz"));
    // try std.testing.expect(!isMatch('bzz', '[a-y]*[^c]', { regex: true }));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "BZZ"));
    try std.testing.expect(glob_match("[a-y]*[^c]", "beware"));
    try std.testing.expect(!glob_match("[a-y]*[^c]", "BewAre"));

    try std.testing.expect(glob_match("a\\*b/*", "a*b/ooo"));
    try std.testing.expect(glob_match("a\\*?/*", "a*b/ooo"));

    try std.testing.expect(!glob_match("a[b]c", "*"));
    try std.testing.expect(!glob_match("a[b]c", "**"));
    try std.testing.expect(!glob_match("a[b]c", "\\*"));
    try std.testing.expect(!glob_match("a[b]c", "a"));
    try std.testing.expect(!glob_match("a[b]c", "a/*"));
    try std.testing.expect(glob_match("a[b]c", "abc"));
    try std.testing.expect(!glob_match("a[b]c", "abd"));
    try std.testing.expect(!glob_match("a[b]c", "abe"));
    try std.testing.expect(!glob_match("a[b]c", "b"));
    try std.testing.expect(!glob_match("a[b]c", "bb"));
    try std.testing.expect(!glob_match("a[b]c", "bcd"));
    try std.testing.expect(!glob_match("a[b]c", "bdir/"));
    try std.testing.expect(!glob_match("a[b]c", "Beware"));
    try std.testing.expect(!glob_match("a[b]c", "c"));
    try std.testing.expect(!glob_match("a[b]c", "ca"));
    try std.testing.expect(!glob_match("a[b]c", "cb"));
    try std.testing.expect(!glob_match("a[b]c", "d"));
    try std.testing.expect(!glob_match("a[b]c", "dd"));
    try std.testing.expect(!glob_match("a[b]c", "de"));
    try std.testing.expect(!glob_match("a[b]c", "baz"));
    try std.testing.expect(!glob_match("a[b]c", "bzz"));
    try std.testing.expect(!glob_match("a[b]c", "BZZ"));
    try std.testing.expect(!glob_match("a[b]c", "beware"));
    try std.testing.expect(!glob_match("a[b]c", "BewAre"));

    try std.testing.expect(!glob_match("a[\"b\"]c", "*"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "**"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "\\*"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "a"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "a/*"));
    try std.testing.expect(glob_match("a[\"b\"]c", "abc"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "abd"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "abe"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "b"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "bb"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "bcd"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "bdir/"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "Beware"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "c"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "ca"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "cb"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "d"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "dd"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "de"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "baz"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "bzz"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "BZZ"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "beware"));
    try std.testing.expect(!glob_match("a[\"b\"]c", "BewAre"));

    try std.testing.expect(!glob_match("a[\\\\b]c", "*"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "**"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "\\*"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "a"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "a/*"));
    try std.testing.expect(glob_match("a[\\\\b]c", "abc"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "abd"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "abe"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "b"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "bb"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "bcd"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "bdir/"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "Beware"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "c"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "ca"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "cb"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "d"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "dd"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "de"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "baz"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "bzz"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "BZZ"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "beware"));
    try std.testing.expect(!glob_match("a[\\\\b]c", "BewAre"));

    try std.testing.expect(!glob_match("a[\\b]c", "*"));
    try std.testing.expect(!glob_match("a[\\b]c", "**"));
    try std.testing.expect(!glob_match("a[\\b]c", "\\*"));
    try std.testing.expect(!glob_match("a[\\b]c", "a"));
    try std.testing.expect(!glob_match("a[\\b]c", "a/*"));
    try std.testing.expect(!glob_match("a[\\b]c", "abc"));
    try std.testing.expect(!glob_match("a[\\b]c", "abd"));
    try std.testing.expect(!glob_match("a[\\b]c", "abe"));
    try std.testing.expect(!glob_match("a[\\b]c", "b"));
    try std.testing.expect(!glob_match("a[\\b]c", "bb"));
    try std.testing.expect(!glob_match("a[\\b]c", "bcd"));
    try std.testing.expect(!glob_match("a[\\b]c", "bdir/"));
    try std.testing.expect(!glob_match("a[\\b]c", "Beware"));
    try std.testing.expect(!glob_match("a[\\b]c", "c"));
    try std.testing.expect(!glob_match("a[\\b]c", "ca"));
    try std.testing.expect(!glob_match("a[\\b]c", "cb"));
    try std.testing.expect(!glob_match("a[\\b]c", "d"));
    try std.testing.expect(!glob_match("a[\\b]c", "dd"));
    try std.testing.expect(!glob_match("a[\\b]c", "de"));
    try std.testing.expect(!glob_match("a[\\b]c", "baz"));
    try std.testing.expect(!glob_match("a[\\b]c", "bzz"));
    try std.testing.expect(!glob_match("a[\\b]c", "BZZ"));
    try std.testing.expect(!glob_match("a[\\b]c", "beware"));
    try std.testing.expect(!glob_match("a[\\b]c", "BewAre"));

    try std.testing.expect(!glob_match("a[b-d]c", "*"));
    try std.testing.expect(!glob_match("a[b-d]c", "**"));
    try std.testing.expect(!glob_match("a[b-d]c", "\\*"));
    try std.testing.expect(!glob_match("a[b-d]c", "a"));
    try std.testing.expect(!glob_match("a[b-d]c", "a/*"));
    try std.testing.expect(glob_match("a[b-d]c", "abc"));
    try std.testing.expect(!glob_match("a[b-d]c", "abd"));
    try std.testing.expect(!glob_match("a[b-d]c", "abe"));
    try std.testing.expect(!glob_match("a[b-d]c", "b"));
    try std.testing.expect(!glob_match("a[b-d]c", "bb"));
    try std.testing.expect(!glob_match("a[b-d]c", "bcd"));
    try std.testing.expect(!glob_match("a[b-d]c", "bdir/"));
    try std.testing.expect(!glob_match("a[b-d]c", "Beware"));
    try std.testing.expect(!glob_match("a[b-d]c", "c"));
    try std.testing.expect(!glob_match("a[b-d]c", "ca"));
    try std.testing.expect(!glob_match("a[b-d]c", "cb"));
    try std.testing.expect(!glob_match("a[b-d]c", "d"));
    try std.testing.expect(!glob_match("a[b-d]c", "dd"));
    try std.testing.expect(!glob_match("a[b-d]c", "de"));
    try std.testing.expect(!glob_match("a[b-d]c", "baz"));
    try std.testing.expect(!glob_match("a[b-d]c", "bzz"));
    try std.testing.expect(!glob_match("a[b-d]c", "BZZ"));
    try std.testing.expect(!glob_match("a[b-d]c", "beware"));
    try std.testing.expect(!glob_match("a[b-d]c", "BewAre"));

    try std.testing.expect(!glob_match("a?c", "*"));
    try std.testing.expect(!glob_match("a?c", "**"));
    try std.testing.expect(!glob_match("a?c", "\\*"));
    try std.testing.expect(!glob_match("a?c", "a"));
    try std.testing.expect(!glob_match("a?c", "a/*"));
    try std.testing.expect(glob_match("a?c", "abc"));
    try std.testing.expect(!glob_match("a?c", "abd"));
    try std.testing.expect(!glob_match("a?c", "abe"));
    try std.testing.expect(!glob_match("a?c", "b"));
    try std.testing.expect(!glob_match("a?c", "bb"));
    try std.testing.expect(!glob_match("a?c", "bcd"));
    try std.testing.expect(!glob_match("a?c", "bdir/"));
    try std.testing.expect(!glob_match("a?c", "Beware"));
    try std.testing.expect(!glob_match("a?c", "c"));
    try std.testing.expect(!glob_match("a?c", "ca"));
    try std.testing.expect(!glob_match("a?c", "cb"));
    try std.testing.expect(!glob_match("a?c", "d"));
    try std.testing.expect(!glob_match("a?c", "dd"));
    try std.testing.expect(!glob_match("a?c", "de"));
    try std.testing.expect(!glob_match("a?c", "baz"));
    try std.testing.expect(!glob_match("a?c", "bzz"));
    try std.testing.expect(!glob_match("a?c", "BZZ"));
    try std.testing.expect(!glob_match("a?c", "beware"));
    try std.testing.expect(!glob_match("a?c", "BewAre"));

    try std.testing.expect(glob_match("*/man*/bash.*", "man/man1/bash.1"));

    try std.testing.expect(glob_match("[^a-c]*", "*"));
    try std.testing.expect(glob_match("[^a-c]*", "**"));
    try std.testing.expect(!glob_match("[^a-c]*", "a"));
    try std.testing.expect(!glob_match("[^a-c]*", "a/*"));
    try std.testing.expect(!glob_match("[^a-c]*", "abc"));
    try std.testing.expect(!glob_match("[^a-c]*", "abd"));
    try std.testing.expect(!glob_match("[^a-c]*", "abe"));
    try std.testing.expect(!glob_match("[^a-c]*", "b"));
    try std.testing.expect(!glob_match("[^a-c]*", "bb"));
    try std.testing.expect(!glob_match("[^a-c]*", "bcd"));
    try std.testing.expect(!glob_match("[^a-c]*", "bdir/"));
    try std.testing.expect(glob_match("[^a-c]*", "Beware"));
    try std.testing.expect(!glob_match("[^a-c]*", "c"));
    try std.testing.expect(!glob_match("[^a-c]*", "ca"));
    try std.testing.expect(!glob_match("[^a-c]*", "cb"));
    try std.testing.expect(glob_match("[^a-c]*", "d"));
    try std.testing.expect(glob_match("[^a-c]*", "dd"));
    try std.testing.expect(glob_match("[^a-c]*", "de"));
    try std.testing.expect(!glob_match("[^a-c]*", "baz"));
    try std.testing.expect(!glob_match("[^a-c]*", "bzz"));
    try std.testing.expect(glob_match("[^a-c]*", "BZZ"));
    try std.testing.expect(!glob_match("[^a-c]*", "beware"));
    try std.testing.expect(glob_match("[^a-c]*", "BewAre"));
}

test "bash_wildmatch" {
    try std.testing.expect(!glob_match("a[]-]b", "aab"));
    try std.testing.expect(!glob_match("[ten]", "ten"));
    try std.testing.expect(glob_match("]", "]"));
    try std.testing.expect(glob_match("a[]-]b", "a-b"));
    try std.testing.expect(glob_match("a[]-]b", "a]b"));
    try std.testing.expect(glob_match("a[]]b", "a]b"));
    try std.testing.expect(glob_match("a[\\]a\\-]b", "aab"));
    try std.testing.expect(glob_match("t[a-g]n", "ten"));
    try std.testing.expect(glob_match("t[^a-g]n", "ton"));
}

test "bash_slashmatch" {
    // try std.testing.expect(!glob_match("f[^eiu][^eiu][^eiu][^eiu][^eiu]r", "foo/bar"));
    try std.testing.expect(glob_match("foo[/]bar", "foo/bar"));
    try std.testing.expect(glob_match("f[^eiu][^eiu][^eiu][^eiu][^eiu]r", "foo-bar"));
}

test "bash_extra_stars" {
    try std.testing.expect(!glob_match("a**c", "bbc"));
    try std.testing.expect(glob_match("a**c", "abc"));
    try std.testing.expect(!glob_match("a**c", "bbd"));

    try std.testing.expect(!glob_match("a***c", "bbc"));
    try std.testing.expect(glob_match("a***c", "abc"));
    try std.testing.expect(!glob_match("a***c", "bbd"));

    try std.testing.expect(!glob_match("a*****?c", "bbc"));
    try std.testing.expect(glob_match("a*****?c", "abc"));
    try std.testing.expect(!glob_match("a*****?c", "bbc"));

    try std.testing.expect(glob_match("?*****??", "bbc"));
    try std.testing.expect(glob_match("?*****??", "abc"));

    try std.testing.expect(glob_match("*****??", "bbc"));
    try std.testing.expect(glob_match("*****??", "abc"));

    try std.testing.expect(glob_match("?*****?c", "bbc"));
    try std.testing.expect(glob_match("?*****?c", "abc"));

    try std.testing.expect(glob_match("?***?****c", "bbc"));
    try std.testing.expect(glob_match("?***?****c", "abc"));
    try std.testing.expect(!glob_match("?***?****c", "bbd"));

    try std.testing.expect(glob_match("?***?****?", "bbc"));
    try std.testing.expect(glob_match("?***?****?", "abc"));

    try std.testing.expect(glob_match("?***?****", "bbc"));
    try std.testing.expect(glob_match("?***?****", "abc"));

    try std.testing.expect(glob_match("*******c", "bbc"));
    try std.testing.expect(glob_match("*******c", "abc"));

    try std.testing.expect(glob_match("*******?", "bbc"));
    try std.testing.expect(glob_match("*******?", "abc"));

    try std.testing.expect(glob_match("a*cd**?**??k", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??k", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??k***", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??***k", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??***k**", "abcdecdhjk"));
    try std.testing.expect(glob_match("a****c**?**??*****", "abcdecdhjk"));
}

test "stars" {
    try std.testing.expect(!glob_match("*.js", "a/b/c/z.js"));
    try std.testing.expect(!glob_match("*.js", "a/b/z.js"));
    try std.testing.expect(!glob_match("*.js", "a/z.js"));
    try std.testing.expect(glob_match("*.js", "z.js"));

    // try std.testing.expect(!glob_match("*/*", "a/.ab"));
    // try std.testing.expect(!glob_match("*", ".ab"));

    try std.testing.expect(glob_match("z*.js", "z.js"));
    try std.testing.expect(glob_match("*/*", "a/z"));
    try std.testing.expect(glob_match("*/z*.js", "a/z.js"));
    try std.testing.expect(glob_match("a/z*.js", "a/z.js"));

    try std.testing.expect(glob_match("*", "ab"));
    try std.testing.expect(glob_match("*", "abc"));

    try std.testing.expect(!glob_match("f*", "bar"));
    try std.testing.expect(!glob_match("*r", "foo"));
    try std.testing.expect(!glob_match("b*", "foo"));
    try std.testing.expect(!glob_match("*", "foo/bar"));
    try std.testing.expect(glob_match("*c", "abc"));
    try std.testing.expect(glob_match("a*", "abc"));
    try std.testing.expect(glob_match("a*c", "abc"));
    try std.testing.expect(glob_match("*r", "bar"));
    try std.testing.expect(glob_match("b*", "bar"));
    try std.testing.expect(glob_match("f*", "foo"));

    try std.testing.expect(glob_match("*abc*", "one abc two"));
    try std.testing.expect(glob_match("a*b", "a         b"));

    try std.testing.expect(!glob_match("*a*", "foo"));
    try std.testing.expect(glob_match("*a*", "bar"));
    try std.testing.expect(glob_match("*abc*", "oneabctwo"));
    try std.testing.expect(!glob_match("*-bc-*", "a-b.c-d"));
    try std.testing.expect(glob_match("*-*.*-*", "a-b.c-d"));
    try std.testing.expect(glob_match("*-b*c-*", "a-b.c-d"));
    try std.testing.expect(glob_match("*-b.c-*", "a-b.c-d"));
    try std.testing.expect(glob_match("*.*", "a-b.c-d"));
    try std.testing.expect(glob_match("*.*-*", "a-b.c-d"));
    try std.testing.expect(glob_match("*.*-d", "a-b.c-d"));
    try std.testing.expect(glob_match("*.c-*", "a-b.c-d"));
    try std.testing.expect(glob_match("*b.*d", "a-b.c-d"));
    try std.testing.expect(glob_match("a*.c*", "a-b.c-d"));
    try std.testing.expect(glob_match("a-*.*-d", "a-b.c-d"));
    try std.testing.expect(glob_match("*.*", "a.b"));
    try std.testing.expect(glob_match("*.b", "a.b"));
    try std.testing.expect(glob_match("a.*", "a.b"));
    try std.testing.expect(glob_match("a.b", "a.b"));

    try std.testing.expect(!glob_match("**-bc-**", "a-b.c-d"));
    try std.testing.expect(glob_match("**-**.**-**", "a-b.c-d"));
    try std.testing.expect(glob_match("**-b**c-**", "a-b.c-d"));
    try std.testing.expect(glob_match("**-b.c-**", "a-b.c-d"));
    try std.testing.expect(glob_match("**.**", "a-b.c-d"));
    try std.testing.expect(glob_match("**.**-**", "a-b.c-d"));
    try std.testing.expect(glob_match("**.**-d", "a-b.c-d"));
    try std.testing.expect(glob_match("**.c-**", "a-b.c-d"));
    try std.testing.expect(glob_match("**b.**d", "a-b.c-d"));
    try std.testing.expect(glob_match("a**.c**", "a-b.c-d"));
    try std.testing.expect(glob_match("a-**.**-d", "a-b.c-d"));
    try std.testing.expect(glob_match("**.**", "a.b"));
    try std.testing.expect(glob_match("**.b", "a.b"));
    try std.testing.expect(glob_match("a.**", "a.b"));
    try std.testing.expect(glob_match("a.b", "a.b"));

    try std.testing.expect(glob_match("*/*", "/ab"));
    try std.testing.expect(glob_match(".", "."));
    try std.testing.expect(!glob_match("a/", "a/.b"));
    try std.testing.expect(glob_match("/*", "/ab"));
    try std.testing.expect(glob_match("/??", "/ab"));
    try std.testing.expect(glob_match("/?b", "/ab"));
    try std.testing.expect(glob_match("/*", "/cd"));
    try std.testing.expect(glob_match("a", "a"));
    try std.testing.expect(glob_match("a/.*", "a/.b"));
    try std.testing.expect(glob_match("?/?", "a/b"));
    try std.testing.expect(glob_match("a/**/j/**/z/*.md", "a/b/c/d/e/j/n/p/o/z/c.md"));
    try std.testing.expect(glob_match("a/**/z/*.md", "a/b/c/d/e/z/c.md"));
    try std.testing.expect(glob_match("a/b/c/*.md", "a/b/c/xyz.md"));
    try std.testing.expect(glob_match("a/*/z/.a", "a/b/z/.a"));
    try std.testing.expect(!glob_match("bz", "a/b/z/.a"));
    try std.testing.expect(glob_match("a/**/c/*.md", "a/bb.bb/aa/b.b/aa/c/xyz.md"));
    try std.testing.expect(glob_match("a/**/c/*.md", "a/bb.bb/aa/bb/aa/c/xyz.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bb.bb/c/xyz.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bb/c/xyz.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bbbb/c/xyz.md"));
    try std.testing.expect(glob_match("*", "aaa"));
    try std.testing.expect(glob_match("*", "ab"));
    try std.testing.expect(glob_match("ab", "ab"));

    try std.testing.expect(!glob_match("*/*/*", "aaa"));
    try std.testing.expect(!glob_match("*/*/*", "aaa/bb/aa/rr"));
    try std.testing.expect(!glob_match("aaa*", "aaa/bba/ccc"));
    // try std.testing.expect(!glob_match("aaa**", "aaa/bba/ccc"));
    try std.testing.expect(!glob_match("aaa/*", "aaa/bba/ccc"));
    try std.testing.expect(!glob_match("aaa/*ccc", "aaa/bba/ccc"));
    try std.testing.expect(!glob_match("aaa/*z", "aaa/bba/ccc"));
    try std.testing.expect(!glob_match("*/*/*", "aaa/bbb"));
    try std.testing.expect(!glob_match("*/*jk*/*i", "ab/zzz/ejkl/hi"));
    try std.testing.expect(glob_match("*/*/*", "aaa/bba/ccc"));
    try std.testing.expect(glob_match("aaa/**", "aaa/bba/ccc"));
    try std.testing.expect(glob_match("aaa/*", "aaa/bbb"));
    try std.testing.expect(glob_match("*/*z*/*/*i", "ab/zzz/ejkl/hi"));
    try std.testing.expect(glob_match("*j*i", "abzzzejklhi"));

    try std.testing.expect(glob_match("*", "a"));
    try std.testing.expect(glob_match("*", "b"));
    try std.testing.expect(!glob_match("*", "a/a"));
    try std.testing.expect(!glob_match("*", "a/a/a"));
    try std.testing.expect(!glob_match("*", "a/a/b"));
    try std.testing.expect(!glob_match("*", "a/a/a/a"));
    try std.testing.expect(!glob_match("*", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("*/*", "a"));
    try std.testing.expect(glob_match("*/*", "a/a"));
    try std.testing.expect(!glob_match("*/*", "a/a/a"));

    try std.testing.expect(!glob_match("*/*/*", "a"));
    try std.testing.expect(!glob_match("*/*/*", "a/a"));
    try std.testing.expect(glob_match("*/*/*", "a/a/a"));
    try std.testing.expect(!glob_match("*/*/*", "a/a/a/a"));

    try std.testing.expect(!glob_match("*/*/*/*", "a"));
    try std.testing.expect(!glob_match("*/*/*/*", "a/a"));
    try std.testing.expect(!glob_match("*/*/*/*", "a/a/a"));
    try std.testing.expect(glob_match("*/*/*/*", "a/a/a/a"));
    try std.testing.expect(!glob_match("*/*/*/*", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("*/*/*/*/*", "a"));
    try std.testing.expect(!glob_match("*/*/*/*/*", "a/a"));
    try std.testing.expect(!glob_match("*/*/*/*/*", "a/a/a"));
    try std.testing.expect(!glob_match("*/*/*/*/*", "a/a/b"));
    try std.testing.expect(!glob_match("*/*/*/*/*", "a/a/a/a"));
    try std.testing.expect(glob_match("*/*/*/*/*", "a/a/a/a/a"));
    try std.testing.expect(!glob_match("*/*/*/*/*", "a/a/a/a/a/a"));

    try std.testing.expect(!glob_match("a/*", "a"));
    try std.testing.expect(glob_match("a/*", "a/a"));
    try std.testing.expect(!glob_match("a/*", "a/a/a"));
    try std.testing.expect(!glob_match("a/*", "a/a/a/a"));
    try std.testing.expect(!glob_match("a/*", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("a/*/*", "a"));
    try std.testing.expect(!glob_match("a/*/*", "a/a"));
    try std.testing.expect(glob_match("a/*/*", "a/a/a"));
    try std.testing.expect(!glob_match("a/*/*", "b/a/a"));
    try std.testing.expect(!glob_match("a/*/*", "a/a/a/a"));
    try std.testing.expect(!glob_match("a/*/*", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("a/*/*/*", "a"));
    try std.testing.expect(!glob_match("a/*/*/*", "a/a"));
    try std.testing.expect(!glob_match("a/*/*/*", "a/a/a"));
    try std.testing.expect(glob_match("a/*/*/*", "a/a/a/a"));
    try std.testing.expect(!glob_match("a/*/*/*", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("a/*/*/*/*", "a"));
    try std.testing.expect(!glob_match("a/*/*/*/*", "a/a"));
    try std.testing.expect(!glob_match("a/*/*/*/*", "a/a/a"));
    try std.testing.expect(!glob_match("a/*/*/*/*", "a/a/b"));
    try std.testing.expect(!glob_match("a/*/*/*/*", "a/a/a/a"));
    try std.testing.expect(glob_match("a/*/*/*/*", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("a/*/a", "a"));
    try std.testing.expect(!glob_match("a/*/a", "a/a"));
    try std.testing.expect(glob_match("a/*/a", "a/a/a"));
    try std.testing.expect(!glob_match("a/*/a", "a/a/b"));
    try std.testing.expect(!glob_match("a/*/a", "a/a/a/a"));
    try std.testing.expect(!glob_match("a/*/a", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("a/*/b", "a"));
    try std.testing.expect(!glob_match("a/*/b", "a/a"));
    try std.testing.expect(!glob_match("a/*/b", "a/a/a"));
    try std.testing.expect(glob_match("a/*/b", "a/a/b"));
    try std.testing.expect(!glob_match("a/*/b", "a/a/a/a"));
    try std.testing.expect(!glob_match("a/*/b", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("*/**/a", "a"));
    try std.testing.expect(!glob_match("*/**/a", "a/a/b"));
    try std.testing.expect(glob_match("*/**/a", "a/a"));
    try std.testing.expect(glob_match("*/**/a", "a/a/a"));
    try std.testing.expect(glob_match("*/**/a", "a/a/a/a"));
    try std.testing.expect(glob_match("*/**/a", "a/a/a/a/a"));

    try std.testing.expect(!glob_match("*/", "a"));
    try std.testing.expect(!glob_match("*/*", "a"));
    try std.testing.expect(!glob_match("a/*", "a"));
    // try std.testing.expect(!glob_match("*/*", "a/"));
    // try std.testing.expect(!glob_match("a/*", "a/"));
    try std.testing.expect(!glob_match("*", "a/a"));
    try std.testing.expect(!glob_match("*/", "a/a"));
    try std.testing.expect(!glob_match("*/", "a/x/y"));
    try std.testing.expect(!glob_match("*/*", "a/x/y"));
    try std.testing.expect(!glob_match("a/*", "a/x/y"));
    // try std.testing.expect(glob_match("*", "a/"));
    try std.testing.expect(glob_match("*", "a"));
    try std.testing.expect(glob_match("*/", "a/"));
    try std.testing.expect(glob_match("*{,/}", "a/"));
    try std.testing.expect(glob_match("*/*", "a/a"));
    try std.testing.expect(glob_match("a/*", "a/a"));

    try std.testing.expect(!glob_match("a/**/*.txt", "a.txt"));
    try std.testing.expect(glob_match("a/**/*.txt", "a/x/y.txt"));
    try std.testing.expect(!glob_match("a/**/*.txt", "a/x/y/z"));

    try std.testing.expect(!glob_match("a/*.txt", "a.txt"));
    try std.testing.expect(glob_match("a/*.txt", "a/b.txt"));
    try std.testing.expect(!glob_match("a/*.txt", "a/x/y.txt"));
    try std.testing.expect(!glob_match("a/*.txt", "a/x/y/z"));

    try std.testing.expect(glob_match("a*.txt", "a.txt"));
    try std.testing.expect(!glob_match("a*.txt", "a/b.txt"));
    try std.testing.expect(!glob_match("a*.txt", "a/x/y.txt"));
    try std.testing.expect(!glob_match("a*.txt", "a/x/y/z"));

    try std.testing.expect(glob_match("*.txt", "a.txt"));
    try std.testing.expect(!glob_match("*.txt", "a/b.txt"));
    try std.testing.expect(!glob_match("*.txt", "a/x/y.txt"));
    try std.testing.expect(!glob_match("*.txt", "a/x/y/z"));

    try std.testing.expect(!glob_match("a*", "a/b"));
    try std.testing.expect(!glob_match("a/**/b", "a/a/bb"));
    try std.testing.expect(!glob_match("a/**/b", "a/bb"));

    try std.testing.expect(!glob_match("*/**", "foo"));
    try std.testing.expect(!glob_match("**/", "foo/bar"));
    try std.testing.expect(!glob_match("**/*/", "foo/bar"));
    try std.testing.expect(!glob_match("*/*/", "foo/bar"));

    try std.testing.expect(glob_match("**/..", "/home/foo/.."));
    try std.testing.expect(glob_match("**/a", "a"));
    try std.testing.expect(glob_match("**", "a/a"));
    try std.testing.expect(glob_match("a/**", "a/a"));
    try std.testing.expect(glob_match("a/**", "a/"));
    // try std.testing.expect(glob_match("a/**", "a"));
    try std.testing.expect(!glob_match("**/", "a/a"));
    // try std.testing.expect(glob_match("**/a/**", "a"));
    // try std.testing.expect(glob_match("a/**", "a"));
    try std.testing.expect(!glob_match("**/", "a/a"));
    try std.testing.expect(glob_match("*/**/a", "a/a"));
    // try std.testing.expect(glob_match("a/**", "a"));
    try std.testing.expect(glob_match("*/**", "foo/"));
    try std.testing.expect(glob_match("**/*", "foo/bar"));
    try std.testing.expect(glob_match("*/*", "foo/bar"));
    try std.testing.expect(glob_match("*/**", "foo/bar"));
    try std.testing.expect(glob_match("**/", "foo/bar/"));
    // try std.testing.expect(glob_match("**/*", "foo/bar/"));
    try std.testing.expect(glob_match("**/*/", "foo/bar/"));
    try std.testing.expect(glob_match("*/**", "foo/bar/"));
    try std.testing.expect(glob_match("*/*/", "foo/bar/"));

    try std.testing.expect(!glob_match("*/foo", "bar/baz/foo"));
    try std.testing.expect(!glob_match("**/bar/*", "deep/foo/bar"));
    try std.testing.expect(!glob_match("*/bar/**", "deep/foo/bar/baz/x"));
    try std.testing.expect(!glob_match("/*", "ef"));
    try std.testing.expect(!glob_match("foo?bar", "foo/bar"));
    try std.testing.expect(!glob_match("**/bar*", "foo/bar/baz"));
    // try std.testing.expect(!glob_match("**/bar**", "foo/bar/baz"));
    try std.testing.expect(!glob_match("foo**bar", "foo/baz/bar"));
    try std.testing.expect(!glob_match("foo*bar", "foo/baz/bar"));
    // try std.testing.expect(glob_match("foo/**", "foo"));
    try std.testing.expect(glob_match("/*", "/ab"));
    try std.testing.expect(glob_match("/*", "/cd"));
    try std.testing.expect(glob_match("/*", "/ef"));
    try std.testing.expect(glob_match("a/**/j/**/z/*.md", "a/b/j/c/z/x.md"));
    try std.testing.expect(glob_match("a/**/j/**/z/*.md", "a/j/z/x.md"));

    try std.testing.expect(glob_match("**/foo", "bar/baz/foo"));
    try std.testing.expect(glob_match("**/bar/*", "deep/foo/bar/baz"));
    try std.testing.expect(glob_match("**/bar/**", "deep/foo/bar/baz/"));
    try std.testing.expect(glob_match("**/bar/*/*", "deep/foo/bar/baz/x"));
    try std.testing.expect(glob_match("foo/**/**/bar", "foo/b/a/z/bar"));
    try std.testing.expect(glob_match("foo/**/bar", "foo/b/a/z/bar"));
    try std.testing.expect(glob_match("foo/**/**/bar", "foo/bar"));
    try std.testing.expect(glob_match("foo/**/bar", "foo/bar"));
    try std.testing.expect(glob_match("*/bar/**", "foo/bar/baz/x"));
    try std.testing.expect(glob_match("foo/**/**/bar", "foo/baz/bar"));
    try std.testing.expect(glob_match("foo/**/bar", "foo/baz/bar"));
    try std.testing.expect(glob_match("**/foo", "XXX/foo"));
}

test "globstars" {
    try std.testing.expect(glob_match("**/*.js", "a/b/c/d.js"));
    try std.testing.expect(glob_match("**/*.js", "a/b/c.js"));
    try std.testing.expect(glob_match("**/*.js", "a/b.js"));
    try std.testing.expect(glob_match("a/b/**/*.js", "a/b/c/d/e/f.js"));
    try std.testing.expect(glob_match("a/b/**/*.js", "a/b/c/d/e.js"));
    try std.testing.expect(glob_match("a/b/c/**/*.js", "a/b/c/d.js"));
    try std.testing.expect(glob_match("a/b/**/*.js", "a/b/c/d.js"));
    try std.testing.expect(glob_match("a/b/**/*.js", "a/b/d.js"));
    try std.testing.expect(!glob_match("a/b/**/*.js", "a/d.js"));
    try std.testing.expect(!glob_match("a/b/**/*.js", "d.js"));

    try std.testing.expect(!glob_match("**c", "a/b/c"));
    try std.testing.expect(!glob_match("a/**c", "a/b/c"));
    try std.testing.expect(!glob_match("a/**z", "a/b/c"));
    try std.testing.expect(!glob_match("a/**b**/c", "a/b/c/b/c"));
    try std.testing.expect(!glob_match("a/b/c**/*.js", "a/b/c/d/e.js"));
    try std.testing.expect(glob_match("a/**/b/**/c", "a/b/c/b/c"));
    try std.testing.expect(glob_match("a/**b**/c", "a/aba/c"));
    try std.testing.expect(glob_match("a/**b**/c", "a/b/c"));
    try std.testing.expect(glob_match("a/b/c**/*.js", "a/b/c/d.js"));

    try std.testing.expect(!glob_match("a/**/*", "a"));
    try std.testing.expect(!glob_match("a/**/**/*", "a"));
    try std.testing.expect(!glob_match("a/**/**/**/*", "a"));
    try std.testing.expect(!glob_match("**/a", "a/"));
    try std.testing.expect(glob_match("a/**/*", "a/"));
    try std.testing.expect(glob_match("a/**/**/*", "a/"));
    try std.testing.expect(glob_match("a/**/**/**/*", "a/"));
    try std.testing.expect(!glob_match("**/a", "a/b"));
    try std.testing.expect(!glob_match("a/**/j/**/z/*.md", "a/b/c/j/e/z/c.txt"));
    try std.testing.expect(!glob_match("a/**/b", "a/bb"));
    try std.testing.expect(!glob_match("**/a", "a/c"));
    try std.testing.expect(!glob_match("**/a", "a/b"));
    try std.testing.expect(!glob_match("**/a", "a/x/y"));
    try std.testing.expect(!glob_match("**/a", "a/b/c/d"));
    try std.testing.expect(glob_match("**", "a"));
    try std.testing.expect(glob_match("**/a", "a"));
    // try std.testing.expect(glob_match("a/**", "a"));
    try std.testing.expect(glob_match("**", "a/"));
    try std.testing.expect(glob_match("**/a/**", "a/"));
    try std.testing.expect(glob_match("a/**", "a/"));
    try std.testing.expect(glob_match("a/**/**", "a/"));
    try std.testing.expect(glob_match("**/a", "a/a"));
    try std.testing.expect(glob_match("**", "a/b"));
    try std.testing.expect(glob_match("*/*", "a/b"));
    try std.testing.expect(glob_match("a/**", "a/b"));
    try std.testing.expect(glob_match("a/**/*", "a/b"));
    try std.testing.expect(glob_match("a/**/**/*", "a/b"));
    try std.testing.expect(glob_match("a/**/**/**/*", "a/b"));
    try std.testing.expect(glob_match("a/**/b", "a/b"));
    try std.testing.expect(glob_match("**", "a/b/c"));
    try std.testing.expect(glob_match("**/*", "a/b/c"));
    try std.testing.expect(glob_match("**/**", "a/b/c"));
    try std.testing.expect(glob_match("*/**", "a/b/c"));
    try std.testing.expect(glob_match("a/**", "a/b/c"));
    try std.testing.expect(glob_match("a/**/*", "a/b/c"));
    try std.testing.expect(glob_match("a/**/**/*", "a/b/c"));
    try std.testing.expect(glob_match("a/**/**/**/*", "a/b/c"));
    try std.testing.expect(glob_match("**", "a/b/c/d"));
    try std.testing.expect(glob_match("a/**", "a/b/c/d"));
    try std.testing.expect(glob_match("a/**/*", "a/b/c/d"));
    try std.testing.expect(glob_match("a/**/**/*", "a/b/c/d"));
    try std.testing.expect(glob_match("a/**/**/**/*", "a/b/c/d"));
    try std.testing.expect(glob_match("a/b/**/c/**/*.*", "a/b/c/d.e"));
    try std.testing.expect(glob_match("a/**/f/*.md", "a/b/c/d/e/f/g.md"));
    try std.testing.expect(glob_match("a/**/f/**/k/*.md", "a/b/c/d/e/f/g/h/i/j/k/l.md"));
    try std.testing.expect(glob_match("a/b/c/*.md", "a/b/c/def.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bb.bb/c/ddd.md"));
    try std.testing.expect(glob_match("a/**/f/*.md", "a/bb.bb/cc/d.d/ee/f/ggg.md"));
    try std.testing.expect(glob_match("a/**/f/*.md", "a/bb.bb/cc/dd/ee/f/ggg.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bb/c/ddd.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bbbb/c/ddd.md"));

    try std.testing.expect(glob_match("foo/bar/**/one/**/*.*", "foo/bar/baz/one/image.png"));
    try std.testing.expect(glob_match("foo/bar/**/one/**/*.*", "foo/bar/baz/one/two/image.png"));
    try std.testing.expect(glob_match("foo/bar/**/one/**/*.*", "foo/bar/baz/one/two/three/image.png"));
    try std.testing.expect(!glob_match("a/b/**/f", "a/b/c/d/"));
    // try std.testing.expect(glob_match("a/**", "a"));
    try std.testing.expect(glob_match("**", "a"));
    // try std.testing.expect(glob_match("a{,/**}", "a"));
    try std.testing.expect(glob_match("**", "a/"));
    try std.testing.expect(glob_match("a/**", "a/"));
    try std.testing.expect(glob_match("**", "a/b/c/d"));
    try std.testing.expect(glob_match("**", "a/b/c/d/"));
    try std.testing.expect(glob_match("**/**", "a/b/c/d/"));
    try std.testing.expect(glob_match("**/b/**", "a/b/c/d/"));
    try std.testing.expect(glob_match("a/b/**", "a/b/c/d/"));
    try std.testing.expect(glob_match("a/b/**/", "a/b/c/d/"));
    try std.testing.expect(glob_match("a/b/**/c/**/", "a/b/c/d/"));
    try std.testing.expect(glob_match("a/b/**/c/**/d/", "a/b/c/d/"));
    try std.testing.expect(glob_match("a/b/**/**/*.*", "a/b/c/d/e.f"));
    try std.testing.expect(glob_match("a/b/**/*.*", "a/b/c/d/e.f"));
    try std.testing.expect(glob_match("a/b/**/c/**/d/*.*", "a/b/c/d/e.f"));
    try std.testing.expect(glob_match("a/b/**/d/**/*.*", "a/b/c/d/e.f"));
    try std.testing.expect(glob_match("a/b/**/d/**/*.*", "a/b/c/d/g/e.f"));
    try std.testing.expect(glob_match("a/b/**/d/**/*.*", "a/b/c/d/g/g/e.f"));
    try std.testing.expect(glob_match("a/b-*/**/z.js", "a/b-c/z.js"));
    try std.testing.expect(glob_match("a/b-*/**/z.js", "a/b-c/d/e/z.js"));

    try std.testing.expect(glob_match("*/*", "a/b"));
    try std.testing.expect(glob_match("a/b/c/*.md", "a/b/c/xyz.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bb.bb/c/xyz.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bb/c/xyz.md"));
    try std.testing.expect(glob_match("a/*/c/*.md", "a/bbbb/c/xyz.md"));

    try std.testing.expect(glob_match("**/*", "a/b/c"));
    try std.testing.expect(glob_match("**/**", "a/b/c"));
    try std.testing.expect(glob_match("*/**", "a/b/c"));
    try std.testing.expect(glob_match("a/**/j/**/z/*.md", "a/b/c/d/e/j/n/p/o/z/c.md"));
    try std.testing.expect(glob_match("a/**/z/*.md", "a/b/c/d/e/z/c.md"));
    try std.testing.expect(glob_match("a/**/c/*.md", "a/bb.bb/aa/b.b/aa/c/xyz.md"));
    try std.testing.expect(glob_match("a/**/c/*.md", "a/bb.bb/aa/bb/aa/c/xyz.md"));
    try std.testing.expect(!glob_match("a/**/j/**/z/*.md", "a/b/c/j/e/z/c.txt"));
    try std.testing.expect(!glob_match("a/b/**/c{d,e}/**/xyz.md", "a/b/c/xyz.md"));
    try std.testing.expect(!glob_match("a/b/**/c{d,e}/**/xyz.md", "a/b/d/xyz.md"));
    try std.testing.expect(!glob_match("a/**/", "a/b"));
    // try std.testing.expect(!glob_match("**/*", "a/b/.js/c.txt"));
    try std.testing.expect(!glob_match("a/**/", "a/b/c/d"));
    try std.testing.expect(!glob_match("a/**/", "a/bb"));
    try std.testing.expect(!glob_match("a/**/", "a/cb"));
    try std.testing.expect(glob_match("/**", "/a/b"));
    try std.testing.expect(glob_match("**/*", "a.b"));
    try std.testing.expect(glob_match("**/*", "a.js"));
    try std.testing.expect(glob_match("**/*.js", "a.js"));
    // try std.testing.expect(glob_match("a/**/", "a/"));
    try std.testing.expect(glob_match("**/*.js", "a/a.js"));
    try std.testing.expect(glob_match("**/*.js", "a/a/b.js"));
    try std.testing.expect(glob_match("a/**/b", "a/b"));
    try std.testing.expect(glob_match("a/**b", "a/b"));
    try std.testing.expect(glob_match("**/*.md", "a/b.md"));
    try std.testing.expect(glob_match("**/*", "a/b/c.js"));
    try std.testing.expect(glob_match("**/*", "a/b/c.txt"));
    try std.testing.expect(glob_match("a/**/", "a/b/c/d/"));
    try std.testing.expect(glob_match("**/*", "a/b/c/d/a.js"));
    try std.testing.expect(glob_match("a/b/**/*.js", "a/b/c/z.js"));
    try std.testing.expect(glob_match("a/b/**/*.js", "a/b/z.js"));
    try std.testing.expect(glob_match("**/*", "ab"));
    try std.testing.expect(glob_match("**/*", "ab/c"));
    try std.testing.expect(glob_match("**/*", "ab/c/d"));
    try std.testing.expect(glob_match("**/*", "abc.js"));

    try std.testing.expect(!glob_match("**/", "a"));
    try std.testing.expect(!glob_match("**/a/*", "a"));
    try std.testing.expect(!glob_match("**/a/*/*", "a"));
    try std.testing.expect(!glob_match("*/a/**", "a"));
    try std.testing.expect(!glob_match("a/**/*", "a"));
    try std.testing.expect(!glob_match("a/**/**/*", "a"));
    try std.testing.expect(!glob_match("**/", "a/b"));
    try std.testing.expect(!glob_match("**/b/*", "a/b"));
    try std.testing.expect(!glob_match("**/b/*/*", "a/b"));
    try std.testing.expect(!glob_match("b/**", "a/b"));
    try std.testing.expect(!glob_match("**/", "a/b/c"));
    try std.testing.expect(!glob_match("**/**/b", "a/b/c"));
    try std.testing.expect(!glob_match("**/b", "a/b/c"));
    try std.testing.expect(!glob_match("**/b/*/*", "a/b/c"));
    try std.testing.expect(!glob_match("b/**", "a/b/c"));
    try std.testing.expect(!glob_match("**/", "a/b/c/d"));
    try std.testing.expect(!glob_match("**/d/*", "a/b/c/d"));
    try std.testing.expect(!glob_match("b/**", "a/b/c/d"));
    try std.testing.expect(glob_match("**", "a"));
    try std.testing.expect(glob_match("**/**", "a"));
    try std.testing.expect(glob_match("**/**/*", "a"));
    try std.testing.expect(glob_match("**/**/a", "a"));
    try std.testing.expect(glob_match("**/a", "a"));
    // try std.testing.expect(glob_match("**/a/**", "a"));
    // try std.testing.expect(glob_match("a/**", "a"));
    try std.testing.expect(glob_match("**", "a/b"));
    try std.testing.expect(glob_match("**/**", "a/b"));
    try std.testing.expect(glob_match("**/**/*", "a/b"));
    try std.testing.expect(glob_match("**/**/b", "a/b"));
    try std.testing.expect(glob_match("**/b", "a/b"));
    // try std.testing.expect(glob_match("**/b/**", "a/b"));
    // try std.testing.expect(glob_match("*/b/**", "a/b"));
    try std.testing.expect(glob_match("a/**", "a/b"));
    try std.testing.expect(glob_match("a/**/*", "a/b"));
    try std.testing.expect(glob_match("a/**/**/*", "a/b"));
    try std.testing.expect(glob_match("**", "a/b/c"));
    try std.testing.expect(glob_match("**/**", "a/b/c"));
    try std.testing.expect(glob_match("**/**/*", "a/b/c"));
    try std.testing.expect(glob_match("**/b/*", "a/b/c"));
    try std.testing.expect(glob_match("**/b/**", "a/b/c"));
    try std.testing.expect(glob_match("*/b/**", "a/b/c"));
    try std.testing.expect(glob_match("a/**", "a/b/c"));
    try std.testing.expect(glob_match("a/**/*", "a/b/c"));
    try std.testing.expect(glob_match("a/**/**/*", "a/b/c"));
    try std.testing.expect(glob_match("**", "a/b/c/d"));
    try std.testing.expect(glob_match("**/**", "a/b/c/d"));
    try std.testing.expect(glob_match("**/**/*", "a/b/c/d"));
    try std.testing.expect(glob_match("**/**/d", "a/b/c/d"));
    try std.testing.expect(glob_match("**/b/**", "a/b/c/d"));
    try std.testing.expect(glob_match("**/b/*/*", "a/b/c/d"));
    try std.testing.expect(glob_match("**/d", "a/b/c/d"));
    try std.testing.expect(glob_match("*/b/**", "a/b/c/d"));
    try std.testing.expect(glob_match("a/**", "a/b/c/d"));
    try std.testing.expect(glob_match("a/**/*", "a/b/c/d"));
    try std.testing.expect(glob_match("a/**/**/*", "a/b/c/d"));

    try std.testing.expect(glob_match("**/**.txt.js", "/foo/bar.txt.js"));
}

test "utf8" {
    try std.testing.expect(glob_match("フ*/**/*", "フォルダ/aaa.js"));
    try std.testing.expect(glob_match("フォ*/**/*", "フォルダ/aaa.js"));
    try std.testing.expect(glob_match("フォル*/**/*", "フォルダ/aaa.js"));
    try std.testing.expect(glob_match("フ*ル*/**/*", "フォルダ/aaa.js"));
    try std.testing.expect(glob_match("フォルダ/**/*", "フォルダ/aaa.js"));
}

test "negation" {
    try std.testing.expect(!glob_match("!*", "abc"));
    try std.testing.expect(!glob_match("!abc", "abc"));
    try std.testing.expect(!glob_match("*!.md", "bar.md"));
    try std.testing.expect(!glob_match("foo!.md", "bar.md"));
    try std.testing.expect(!glob_match("\\!*!*.md", "foo!.md"));
    try std.testing.expect(!glob_match("\\!*!*.md", "foo!bar.md"));
    try std.testing.expect(glob_match("*!*.md", "!foo!.md"));
    try std.testing.expect(glob_match("\\!*!*.md", "!foo!.md"));
    try std.testing.expect(glob_match("!*foo", "abc"));
    try std.testing.expect(glob_match("!foo*", "abc"));
    try std.testing.expect(glob_match("!xyz", "abc"));
    try std.testing.expect(glob_match("*!*.*", "ba!r.js"));
    try std.testing.expect(glob_match("*.md", "bar.md"));
    try std.testing.expect(glob_match("*!*.*", "foo!.md"));
    try std.testing.expect(glob_match("*!*.md", "foo!.md"));
    try std.testing.expect(glob_match("*!.md", "foo!.md"));
    try std.testing.expect(glob_match("*.md", "foo!.md"));
    try std.testing.expect(glob_match("foo!.md", "foo!.md"));
    try std.testing.expect(glob_match("*!*.md", "foo!bar.md"));
    try std.testing.expect(glob_match("*b*.md", "foobar.md"));

    try std.testing.expect(!glob_match("a!!b", "a"));
    try std.testing.expect(!glob_match("a!!b", "aa"));
    try std.testing.expect(!glob_match("a!!b", "a/b"));
    try std.testing.expect(!glob_match("a!!b", "a!b"));
    try std.testing.expect(glob_match("a!!b", "a!!b"));
    try std.testing.expect(!glob_match("a!!b", "a/!!/b"));

    try std.testing.expect(!glob_match("!a/b", "a/b"));
    try std.testing.expect(glob_match("!a/b", "a"));
    try std.testing.expect(glob_match("!a/b", "a.b"));
    try std.testing.expect(glob_match("!a/b", "a/a"));
    try std.testing.expect(glob_match("!a/b", "a/c"));
    try std.testing.expect(glob_match("!a/b", "b/a"));
    try std.testing.expect(glob_match("!a/b", "b/b"));
    try std.testing.expect(glob_match("!a/b", "b/c"));

    try std.testing.expect(!glob_match("!abc", "abc"));
    try std.testing.expect(glob_match("!!abc", "abc"));
    try std.testing.expect(!glob_match("!!!abc", "abc"));
    try std.testing.expect(glob_match("!!!!abc", "abc"));
    try std.testing.expect(!glob_match("!!!!!abc", "abc"));
    try std.testing.expect(glob_match("!!!!!!abc", "abc"));
    try std.testing.expect(!glob_match("!!!!!!!abc", "abc"));
    try std.testing.expect(glob_match("!!!!!!!!abc", "abc"));

    // try std.testing.expect(!glob_match("!(*/*)", "a/a"));
    // try std.testing.expect(!glob_match("!(*/*)", "a/b"));
    // try std.testing.expect(!glob_match("!(*/*)", "a/c"));
    // try std.testing.expect(!glob_match("!(*/*)", "b/a"));
    // try std.testing.expect(!glob_match("!(*/*)", "b/b"));
    // try std.testing.expect(!glob_match("!(*/*)", "b/c"));
    // try std.testing.expect(!glob_match("!(*/b)", "a/b"));
    // try std.testing.expect(!glob_match("!(*/b)", "b/b"));
    // try std.testing.expect(!glob_match("!(a/b)", "a/b"));
    try std.testing.expect(!glob_match("!*", "a"));
    try std.testing.expect(!glob_match("!*", "a.b"));
    try std.testing.expect(!glob_match("!*/*", "a/a"));
    try std.testing.expect(!glob_match("!*/*", "a/b"));
    try std.testing.expect(!glob_match("!*/*", "a/c"));
    try std.testing.expect(!glob_match("!*/*", "b/a"));
    try std.testing.expect(!glob_match("!*/*", "b/b"));
    try std.testing.expect(!glob_match("!*/*", "b/c"));
    try std.testing.expect(!glob_match("!*/b", "a/b"));
    try std.testing.expect(!glob_match("!*/b", "b/b"));
    try std.testing.expect(!glob_match("!*/c", "a/c"));
    try std.testing.expect(!glob_match("!*/c", "b/c"));
    try std.testing.expect(!glob_match("!*a*", "bar"));
    try std.testing.expect(!glob_match("!*a*", "fab"));
    // try std.testing.expect(!glob_match("!a/(*)", "a/a"));
    // try std.testing.expect(!glob_match("!a/(*)", "a/b"));
    // try std.testing.expect(!glob_match("!a/(*)", "a/c"));
    // try std.testing.expect(!glob_match("!a/(b)", "a/b"));
    try std.testing.expect(!glob_match("!a/*", "a/a"));
    try std.testing.expect(!glob_match("!a/*", "a/b"));
    try std.testing.expect(!glob_match("!a/*", "a/c"));
    try std.testing.expect(!glob_match("!f*b", "fab"));
    // try std.testing.expect(glob_match("!(*/*)", "a"));
    // try std.testing.expect(glob_match("!(*/*)", "a.b"));
    // try std.testing.expect(glob_match("!(*/b)", "a"));
    // try std.testing.expect(glob_match("!(*/b)", "a.b"));
    // try std.testing.expect(glob_match("!(*/b)", "a/a"));
    // try std.testing.expect(glob_match("!(*/b)", "a/c"));
    // try std.testing.expect(glob_match("!(*/b)", "b/a"));
    // try std.testing.expect(glob_match("!(*/b)", "b/c"));
    // try std.testing.expect(glob_match("!(a/b)", "a"));
    // try std.testing.expect(glob_match("!(a/b)", "a.b"));
    // try std.testing.expect(glob_match("!(a/b)", "a/a"));
    // try std.testing.expect(glob_match("!(a/b)", "a/c"));
    // try std.testing.expect(glob_match("!(a/b)", "b/a"));
    // try std.testing.expect(glob_match("!(a/b)", "b/b"));
    // try std.testing.expect(glob_match("!(a/b)", "b/c"));
    try std.testing.expect(glob_match("!*", "a/a"));
    try std.testing.expect(glob_match("!*", "a/b"));
    try std.testing.expect(glob_match("!*", "a/c"));
    try std.testing.expect(glob_match("!*", "b/a"));
    try std.testing.expect(glob_match("!*", "b/b"));
    try std.testing.expect(glob_match("!*", "b/c"));
    try std.testing.expect(glob_match("!*/*", "a"));
    try std.testing.expect(glob_match("!*/*", "a.b"));
    try std.testing.expect(glob_match("!*/b", "a"));
    try std.testing.expect(glob_match("!*/b", "a.b"));
    try std.testing.expect(glob_match("!*/b", "a/a"));
    try std.testing.expect(glob_match("!*/b", "a/c"));
    try std.testing.expect(glob_match("!*/b", "b/a"));
    try std.testing.expect(glob_match("!*/b", "b/c"));
    try std.testing.expect(glob_match("!*/c", "a"));
    try std.testing.expect(glob_match("!*/c", "a.b"));
    try std.testing.expect(glob_match("!*/c", "a/a"));
    try std.testing.expect(glob_match("!*/c", "a/b"));
    try std.testing.expect(glob_match("!*/c", "b/a"));
    try std.testing.expect(glob_match("!*/c", "b/b"));
    try std.testing.expect(glob_match("!*a*", "foo"));
    // try std.testing.expect(glob_match("!a/(*)", "a"));
    // try std.testing.expect(glob_match("!a/(*)", "a.b"));
    // try std.testing.expect(glob_match("!a/(*)", "b/a"));
    // try std.testing.expect(glob_match("!a/(*)", "b/b"));
    // try std.testing.expect(glob_match("!a/(*)", "b/c"));
    // try std.testing.expect(glob_match("!a/(b)", "a"));
    // try std.testing.expect(glob_match("!a/(b)", "a.b"));
    // try std.testing.expect(glob_match("!a/(b)", "a/a"));
    // try std.testing.expect(glob_match("!a/(b)", "a/c"));
    // try std.testing.expect(glob_match("!a/(b)", "b/a"));
    // try std.testing.expect(glob_match("!a/(b)", "b/b"));
    // try std.testing.expect(glob_match("!a/(b)", "b/c"));
    try std.testing.expect(glob_match("!a/*", "a"));
    try std.testing.expect(glob_match("!a/*", "a.b"));
    try std.testing.expect(glob_match("!a/*", "b/a"));
    try std.testing.expect(glob_match("!a/*", "b/b"));
    try std.testing.expect(glob_match("!a/*", "b/c"));
    try std.testing.expect(glob_match("!f*b", "bar"));
    try std.testing.expect(glob_match("!f*b", "foo"));

    try std.testing.expect(!glob_match("!.md", ".md"));
    try std.testing.expect(glob_match("!**/*.md", "a.js"));
    // try std.testing.expect(!glob_match("!**/*.md", "b.md"));
    try std.testing.expect(glob_match("!**/*.md", "c.txt"));
    try std.testing.expect(glob_match("!*.md", "a.js"));
    try std.testing.expect(!glob_match("!*.md", "b.md"));
    try std.testing.expect(glob_match("!*.md", "c.txt"));
    try std.testing.expect(!glob_match("!*.md", "abc.md"));
    try std.testing.expect(glob_match("!*.md", "abc.txt"));
    try std.testing.expect(!glob_match("!*.md", "foo.md"));
    try std.testing.expect(glob_match("!.md", "foo.md"));

    try std.testing.expect(glob_match("!*.md", "a.js"));
    try std.testing.expect(glob_match("!*.md", "b.txt"));
    try std.testing.expect(!glob_match("!*.md", "c.md"));
    try std.testing.expect(!glob_match("!a/*/a.js", "a/a/a.js"));
    try std.testing.expect(!glob_match("!a/*/a.js", "a/b/a.js"));
    try std.testing.expect(!glob_match("!a/*/a.js", "a/c/a.js"));
    try std.testing.expect(!glob_match("!a/*/*/a.js", "a/a/a/a.js"));
    try std.testing.expect(glob_match("!a/*/*/a.js", "b/a/b/a.js"));
    try std.testing.expect(glob_match("!a/*/*/a.js", "c/a/c/a.js"));
    try std.testing.expect(!glob_match("!a/a*.txt", "a/a.txt"));
    try std.testing.expect(glob_match("!a/a*.txt", "a/b.txt"));
    try std.testing.expect(glob_match("!a/a*.txt", "a/c.txt"));
    try std.testing.expect(!glob_match("!a.a*.txt", "a.a.txt"));
    try std.testing.expect(glob_match("!a.a*.txt", "a.b.txt"));
    try std.testing.expect(glob_match("!a.a*.txt", "a.c.txt"));
    try std.testing.expect(!glob_match("!a/*.txt", "a/a.txt"));
    try std.testing.expect(!glob_match("!a/*.txt", "a/b.txt"));
    try std.testing.expect(!glob_match("!a/*.txt", "a/c.txt"));

    try std.testing.expect(glob_match("!*.md", "a.js"));
    try std.testing.expect(glob_match("!*.md", "b.txt"));
    try std.testing.expect(!glob_match("!*.md", "c.md"));
    // try std.testing.expect(!glob_match("!**/a.js", "a/a/a.js"));
    // try std.testing.expect(!glob_match("!**/a.js", "a/b/a.js"));
    // try std.testing.expect(!glob_match("!**/a.js", "a/c/a.js"));
    try std.testing.expect(glob_match("!**/a.js", "a/a/b.js"));
    try std.testing.expect(!glob_match("!a/**/a.js", "a/a/a/a.js"));
    try std.testing.expect(glob_match("!a/**/a.js", "b/a/b/a.js"));
    try std.testing.expect(glob_match("!a/**/a.js", "c/a/c/a.js"));
    try std.testing.expect(glob_match("!**/*.md", "a/b.js"));
    try std.testing.expect(glob_match("!**/*.md", "a.js"));
    try std.testing.expect(!glob_match("!**/*.md", "a/b.md"));
    // try std.testing.expect(!glob_match("!**/*.md", "a.md"));
    try std.testing.expect(!glob_match("**/*.md", "a/b.js"));
    try std.testing.expect(!glob_match("**/*.md", "a.js"));
    try std.testing.expect(glob_match("**/*.md", "a/b.md"));
    try std.testing.expect(glob_match("**/*.md", "a.md"));
    try std.testing.expect(glob_match("!**/*.md", "a/b.js"));
    try std.testing.expect(glob_match("!**/*.md", "a.js"));
    try std.testing.expect(!glob_match("!**/*.md", "a/b.md"));
    // try std.testing.expect(!glob_match("!**/*.md", "a.md"));
    try std.testing.expect(glob_match("!*.md", "a/b.js"));
    try std.testing.expect(glob_match("!*.md", "a.js"));
    try std.testing.expect(glob_match("!*.md", "a/b.md"));
    try std.testing.expect(!glob_match("!*.md", "a.md"));
    try std.testing.expect(glob_match("!**/*.md", "a.js"));
    // try std.testing.expect(!glob_match("!**/*.md", "b.md"));
    try std.testing.expect(glob_match("!**/*.md", "c.txt"));
}

test "question_mark" {
    try std.testing.expect(glob_match("?", "a"));
    try std.testing.expect(!glob_match("?", "aa"));
    try std.testing.expect(!glob_match("?", "ab"));
    try std.testing.expect(!glob_match("?", "aaa"));
    try std.testing.expect(!glob_match("?", "abcdefg"));

    try std.testing.expect(!glob_match("??", "a"));
    try std.testing.expect(glob_match("??", "aa"));
    try std.testing.expect(glob_match("??", "ab"));
    try std.testing.expect(!glob_match("??", "aaa"));
    try std.testing.expect(!glob_match("??", "abcdefg"));

    try std.testing.expect(!glob_match("???", "a"));
    try std.testing.expect(!glob_match("???", "aa"));
    try std.testing.expect(!glob_match("???", "ab"));
    try std.testing.expect(glob_match("???", "aaa"));
    try std.testing.expect(!glob_match("???", "abcdefg"));

    try std.testing.expect(!glob_match("a?c", "aaa"));
    try std.testing.expect(glob_match("a?c", "aac"));
    try std.testing.expect(glob_match("a?c", "abc"));
    try std.testing.expect(!glob_match("ab?", "a"));
    try std.testing.expect(!glob_match("ab?", "aa"));
    try std.testing.expect(!glob_match("ab?", "ab"));
    try std.testing.expect(!glob_match("ab?", "ac"));
    try std.testing.expect(!glob_match("ab?", "abcd"));
    try std.testing.expect(!glob_match("ab?", "abbb"));
    try std.testing.expect(glob_match("a?b", "acb"));

    try std.testing.expect(!glob_match("a/?/c/?/e.md", "a/bb/c/dd/e.md"));
    try std.testing.expect(glob_match("a/??/c/??/e.md", "a/bb/c/dd/e.md"));
    try std.testing.expect(!glob_match("a/??/c.md", "a/bbb/c.md"));
    try std.testing.expect(glob_match("a/?/c.md", "a/b/c.md"));
    try std.testing.expect(glob_match("a/?/c/?/e.md", "a/b/c/d/e.md"));
    try std.testing.expect(!glob_match("a/?/c/???/e.md", "a/b/c/d/e.md"));
    try std.testing.expect(glob_match("a/?/c/???/e.md", "a/b/c/zzz/e.md"));
    try std.testing.expect(!glob_match("a/?/c.md", "a/bb/c.md"));
    try std.testing.expect(glob_match("a/??/c.md", "a/bb/c.md"));
    try std.testing.expect(glob_match("a/???/c.md", "a/bbb/c.md"));
    try std.testing.expect(glob_match("a/????/c.md", "a/bbbb/c.md"));
}

test "braces" {
    try std.testing.expect(glob_match("{a,b,c}", "a"));
    try std.testing.expect(glob_match("{a,b,c}", "b"));
    try std.testing.expect(glob_match("{a,b,c}", "c"));
    try std.testing.expect(!glob_match("{a,b,c}", "aa"));
    try std.testing.expect(!glob_match("{a,b,c}", "bb"));
    try std.testing.expect(!glob_match("{a,b,c}", "cc"));

    try std.testing.expect(glob_match("a/{a,b}", "a/a"));
    try std.testing.expect(glob_match("a/{a,b}", "a/b"));
    try std.testing.expect(!glob_match("a/{a,b}", "a/c"));
    try std.testing.expect(!glob_match("a/{a,b}", "b/b"));
    try std.testing.expect(!glob_match("a/{a,b,c}", "b/b"));
    try std.testing.expect(glob_match("a/{a,b,c}", "a/c"));
    try std.testing.expect(glob_match("a{b,bc}.txt", "abc.txt"));

    try std.testing.expect(glob_match("foo[{a,b}]baz", "foo{baz"));

    try std.testing.expect(!glob_match("a{,b}.txt", "abc.txt"));
    try std.testing.expect(!glob_match("a{a,b,}.txt", "abc.txt"));
    try std.testing.expect(!glob_match("a{b,}.txt", "abc.txt"));
    try std.testing.expect(glob_match("a{,b}.txt", "a.txt"));
    try std.testing.expect(glob_match("a{b,}.txt", "a.txt"));
    try std.testing.expect(glob_match("a{a,b,}.txt", "aa.txt"));
    try std.testing.expect(glob_match("a{,b}.txt", "ab.txt"));
    try std.testing.expect(glob_match("a{b,}.txt", "ab.txt"));

    // try std.testing.expect(glob_match("{a/,}a/**", "a"));
    try std.testing.expect(glob_match("a{a,b/}*.txt", "aa.txt"));
    try std.testing.expect(glob_match("a{a,b/}*.txt", "ab/.txt"));
    try std.testing.expect(glob_match("a{a,b/}*.txt", "ab/a.txt"));
    // try std.testing.expect(glob_match("{a/,}a/**", "a/"));
    try std.testing.expect(glob_match("{a/,}a/**", "a/a/"));
    // try std.testing.expect(glob_match("{a/,}a/**", "a/a"));
    try std.testing.expect(glob_match("{a/,}a/**", "a/a/a"));
    try std.testing.expect(glob_match("{a/,}a/**", "a/a/"));
    try std.testing.expect(glob_match("{a/,}a/**", "a/a/a/"));
    try std.testing.expect(glob_match("{a/,}b/**", "a/b/a/"));
    try std.testing.expect(glob_match("{a/,}b/**", "b/a/"));
    try std.testing.expect(glob_match("a{,/}*.txt", "a.txt"));
    try std.testing.expect(glob_match("a{,/}*.txt", "ab.txt"));
    try std.testing.expect(glob_match("a{,/}*.txt", "a/b.txt"));
    try std.testing.expect(glob_match("a{,/}*.txt", "a/ab.txt"));

    try std.testing.expect(glob_match("a{,.*{foo,db},\\(bar\\)}.txt", "a.txt"));
    try std.testing.expect(!glob_match("a{,.*{foo,db},\\(bar\\)}.txt", "adb.txt"));
    try std.testing.expect(glob_match("a{,.*{foo,db},\\(bar\\)}.txt", "a.db.txt"));

    try std.testing.expect(glob_match("a{,*.{foo,db},\\(bar\\)}.txt", "a.txt"));
    try std.testing.expect(!glob_match("a{,*.{foo,db},\\(bar\\)}.txt", "adb.txt"));
    try std.testing.expect(glob_match("a{,*.{foo,db},\\(bar\\)}.txt", "a.db.txt"));

    // try std.testing.expect(glob_match("a{,.*{foo,db},\\(bar\\)}", "a"));
    try std.testing.expect(!glob_match("a{,.*{foo,db},\\(bar\\)}", "adb"));
    try std.testing.expect(glob_match("a{,.*{foo,db},\\(bar\\)}", "a.db"));

    // try std.testing.expect(glob_match("a{,*.{foo,db},\\(bar\\)}", "a"));
    try std.testing.expect(!glob_match("a{,*.{foo,db},\\(bar\\)}", "adb"));
    try std.testing.expect(glob_match("a{,*.{foo,db},\\(bar\\)}", "a.db"));

    try std.testing.expect(!glob_match("{,.*{foo,db},\\(bar\\)}", "a"));
    try std.testing.expect(!glob_match("{,.*{foo,db},\\(bar\\)}", "adb"));
    try std.testing.expect(!glob_match("{,.*{foo,db},\\(bar\\)}", "a.db"));
    try std.testing.expect(glob_match("{,.*{foo,db},\\(bar\\)}", ".db"));

    try std.testing.expect(!glob_match("{,*.{foo,db},\\(bar\\)}", "a"));
    try std.testing.expect(glob_match("{*,*.{foo,db},\\(bar\\)}", "a"));
    try std.testing.expect(!glob_match("{,*.{foo,db},\\(bar\\)}", "adb"));
    try std.testing.expect(glob_match("{,*.{foo,db},\\(bar\\)}", "a.db"));

    try std.testing.expect(!glob_match("a/b/**/c{d,e}/**/xyz.md", "a/b/c/xyz.md"));
    try std.testing.expect(!glob_match("a/b/**/c{d,e}/**/xyz.md", "a/b/d/xyz.md"));
    try std.testing.expect(glob_match("a/b/**/c{d,e}/**/xyz.md", "a/b/cd/xyz.md"));
    try std.testing.expect(glob_match("a/b/**/{c,d,e}/**/xyz.md", "a/b/c/xyz.md"));
    try std.testing.expect(glob_match("a/b/**/{c,d,e}/**/xyz.md", "a/b/d/xyz.md"));
    try std.testing.expect(glob_match("a/b/**/{c,d,e}/**/xyz.md", "a/b/e/xyz.md"));

    try std.testing.expect(glob_match("*{a,b}*", "xax"));
    try std.testing.expect(glob_match("*{a,b}*", "xxax"));
    try std.testing.expect(glob_match("*{a,b}*", "xbx"));

    try std.testing.expect(glob_match("*{*a,b}", "xba"));
    try std.testing.expect(glob_match("*{*a,b}", "xb"));

    try std.testing.expect(!glob_match("*??", "a"));
    try std.testing.expect(!glob_match("*???", "aa"));
    try std.testing.expect(glob_match("*???", "aaa"));
    try std.testing.expect(!glob_match("*****??", "a"));
    try std.testing.expect(!glob_match("*****???", "aa"));
    try std.testing.expect(glob_match("*****???", "aaa"));

    try std.testing.expect(!glob_match("a*?c", "aaa"));
    try std.testing.expect(glob_match("a*?c", "aac"));
    try std.testing.expect(glob_match("a*?c", "abc"));

    try std.testing.expect(glob_match("a**?c", "abc"));
    try std.testing.expect(!glob_match("a**?c", "abb"));
    try std.testing.expect(glob_match("a**?c", "acc"));
    try std.testing.expect(glob_match("a*****?c", "abc"));

    try std.testing.expect(glob_match("*****?", "a"));
    try std.testing.expect(glob_match("*****?", "aa"));
    try std.testing.expect(glob_match("*****?", "abc"));
    try std.testing.expect(glob_match("*****?", "zzz"));
    try std.testing.expect(glob_match("*****?", "bbb"));
    try std.testing.expect(glob_match("*****?", "aaaa"));

    try std.testing.expect(!glob_match("*****??", "a"));
    try std.testing.expect(glob_match("*****??", "aa"));
    try std.testing.expect(glob_match("*****??", "abc"));
    try std.testing.expect(glob_match("*****??", "zzz"));
    try std.testing.expect(glob_match("*****??", "bbb"));
    try std.testing.expect(glob_match("*****??", "aaaa"));

    try std.testing.expect(!glob_match("?*****??", "a"));
    try std.testing.expect(!glob_match("?*****??", "aa"));
    try std.testing.expect(glob_match("?*****??", "abc"));
    try std.testing.expect(glob_match("?*****??", "zzz"));
    try std.testing.expect(glob_match("?*****??", "bbb"));
    try std.testing.expect(glob_match("?*****??", "aaaa"));

    try std.testing.expect(glob_match("?*****?c", "abc"));
    try std.testing.expect(!glob_match("?*****?c", "abb"));
    try std.testing.expect(!glob_match("?*****?c", "zzz"));

    try std.testing.expect(glob_match("?***?****c", "abc"));
    try std.testing.expect(!glob_match("?***?****c", "bbb"));
    try std.testing.expect(!glob_match("?***?****c", "zzz"));

    try std.testing.expect(glob_match("?***?****?", "abc"));
    try std.testing.expect(glob_match("?***?****?", "bbb"));
    try std.testing.expect(glob_match("?***?****?", "zzz"));

    try std.testing.expect(glob_match("?***?****", "abc"));
    try std.testing.expect(glob_match("*******c", "abc"));
    try std.testing.expect(glob_match("*******?", "abc"));
    try std.testing.expect(glob_match("a*cd**?**??k", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??k", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??k***", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??***k", "abcdecdhjk"));
    try std.testing.expect(glob_match("a**?**cd**?**??***k**", "abcdecdhjk"));
    try std.testing.expect(glob_match("a****c**?**??*****", "abcdecdhjk"));

    try std.testing.expect(!glob_match("a/?/c/?/*/e.md", "a/b/c/d/e.md"));
    try std.testing.expect(glob_match("a/?/c/?/*/e.md", "a/b/c/d/e/e.md"));
    try std.testing.expect(glob_match("a/?/c/?/*/e.md", "a/b/c/d/efghijk/e.md"));
    try std.testing.expect(glob_match("a/?/**/e.md", "a/b/c/d/efghijk/e.md"));
    try std.testing.expect(!glob_match("a/?/e.md", "a/bb/e.md"));
    try std.testing.expect(glob_match("a/??/e.md", "a/bb/e.md"));
    try std.testing.expect(!glob_match("a/?/**/e.md", "a/bb/e.md"));
    try std.testing.expect(glob_match("a/?/**/e.md", "a/b/ccc/e.md"));
    try std.testing.expect(glob_match("a/*/?/**/e.md", "a/b/c/d/efghijk/e.md"));
    try std.testing.expect(glob_match("a/*/?/**/e.md", "a/b/c/d/efgh.ijk/e.md"));
    try std.testing.expect(glob_match("a/*/?/**/e.md", "a/b.bb/c/d/efgh.ijk/e.md"));
    try std.testing.expect(glob_match("a/*/?/**/e.md", "a/bbb/c/d/efgh.ijk/e.md"));

    try std.testing.expect(glob_match("a/*/ab??.md", "a/bbb/abcd.md"));
    try std.testing.expect(glob_match("a/bbb/ab??.md", "a/bbb/abcd.md"));
    try std.testing.expect(glob_match("a/bbb/ab???md", "a/bbb/abcd.md"));

    try std.testing.expect(glob_match("{a,b}/c/{d,e}/**/*.ts", "a/c/d/one/two/three.test.ts"));
    try std.testing.expect(glob_match("{a,{d,e}b}/c", "a/c"));
    try std.testing.expect(glob_match("{**/a,**/b}", "b"));

    const patterns: [10][]const u8 = [_][]const u8{
        "{src,extensions}/**/test/**/{fixtures,browser,common}/**/*.{ts,js}",
        "{extensions,src}/**/{media,images,icons}/**/*.{svg,png,gif,jpg}",
        "{.github,build,test}/**/{workflows,azure-pipelines,integration,smoke}/**/*.{yml,yaml,json}",
        "src/vs/{base,editor,platform,workbench}/test/{browser,common,node}/**/[a-z]*[tT]est.ts",
        "src/vs/workbench/{contrib,services}/**/*{Editor,Workspace,Terminal}*.ts",
        "{extensions,src}/**/{markdown,json,javascript,typescript}/**/*.{ts,json}",
        "**/{electron-sandbox,electron-main,browser,node}/**/{*[sS]ervice*,*[cC]ontroller*}.ts",
        "{src,extensions}/**/{common,browser,electron-sandbox}/**/*{[cC]ontribution,[sS]ervice}.ts",
        "src/vs/{base,platform,workbench}/**/{test,browser}/**/*{[mM]odel,[cC]ontroller}*.ts",
        "extensions/**/{browser,common,node}/{**/*[sS]ervice*,**/*[pP]rovider*}.ts",
    };

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    for (1.., patterns) |idx, pattern| {
        const file = try std.fs.cwd().openFile("src/fixtures/input.txt", .{ .mode = .read_only });
        defer file.close();

        var reader_buf: [1024]u8 = undefined;
        var file_reader = file.readerStreaming(&reader_buf);

        var matches = try std.ArrayList([]u8).initCapacity(alloc, 0);
        defer matches.deinit(alloc);

        var mat_idx: usize = 0;
        while (file_reader.interface.takeDelimiterExclusive('\n')) |line| {
            if (glob_match(pattern, line)) {
                try matches.append(alloc, try alloc.dupe(u8, line));
                mat_idx += 1;
            }
        } else |err| switch (err) {
            error.EndOfStream => {},
            error.StreamTooLong => |e| return e,
            error.ReadFailed => |e| return e,
        }

        const expected_path = try std.fmt.allocPrint(alloc, "src/fixtures/matched-pattern-{}.txt", .{idx});
        defer alloc.free(expected_path);

        const expected_file = try std.fs.cwd().openFile(expected_path, .{ .mode = .read_only });
        defer expected_file.close();

        var exp_reader_buf: [1024]u8 = undefined;
        var exp_file_reader = expected_file.readerStreaming(&exp_reader_buf);

        var expected = try std.ArrayList([]u8).initCapacity(alloc, 0);
        defer expected.deinit(alloc);

        var exp_idx: usize = 0;
        while (exp_file_reader.interface.takeDelimiterExclusive('\n')) |line| {
            try std.testing.expectEqualStrings(line, matches.items[exp_idx]);
            exp_idx += 1;
        } else |err| switch (err) {
            error.EndOfStream => {},
            error.StreamTooLong => |e| return e,
            error.ReadFailed => |e| return e,
        }

        try std.testing.expectEqual(exp_idx, matches.items.len);
    }
}

test "not_paired_braces" {
    try std.testing.expect(!glob_match("{a,}}", "a"));
    try std.testing.expect(glob_match("{a,}}", "a}"));
}

test "fuzz_tests" {
    // https://github.com/devongovett/glob-match/issues/1
    const s = "{*{??*{??**,Uz*zz}w**{*{**a,z***b*[!}w??*azzzzzzzz*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!z[za,z&zz}w**z*z*}";
    try std.testing.expect(!glob_match(s, s));
    // const s2 = "**** *{*{??*{??***\u{5} *{*{??*{??***\u{5},\0U\0}]*****\u{1},\0***\0,\0\0}w****,\0U\0}]*****\u{1},\0***\0,\0\0}w*****\u{1}***{}*.*\0\0*\0";
    // try std.testing.expect(!glob_match(s2, s2));
}
