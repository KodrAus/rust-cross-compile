# Static linking and cross compiling Rust apps on Windows [![Build status](https://ci.appveyor.com/api/projects/status/ku7y70c7jwp8x7i8?svg=true)](https://ci.appveyor.com/project/KodrAus/cross-compile-example)

This example demonstrates how you can use just the tools that are readily accessible through [`rustup`](https://rustup.rs) to statically link and cross-compile Rust apps on Windows.

-----

Rust is compiled ahead-of-time to machine code that runs directly on an end-user's machine. That means you have to know upfront what platforms you're going to target and have the right build tools and libraries available for each of them.

Even when you do have compiled binaries, you can run into problems distributing them if you find yourself depending on the availability of C runtime libraries on the end-user's machine.

When your build environment is Windows and you also need to target Linux, it turns out we can solve both our cross-compilation and distribution problems at once by statically linking MSVCRT for Windows and by cross-compiling our Linux builds to target musl instead of glibc.

Let's start with a fresh _Hello World_ Rust app:

```shell
cargo new --bin cross-compile-sample
cd cross-compile-sample
```

## Statically linking MSVCRT

If we build our library for the MSVC target (which is the default for Windows) now, it'll dynamically link to MSVCRT:

```shell
cargo build --target x86_64-pc-windows-msvc
```

```shell
ls target/x86_64-pc-windows-msvc/debug
```

```shell
Length Name
------ ----
144384 cross-compile-sample.exe
```

In order to tell the Rust compiler to statically link MSVCRT, we need to add some configuration to a `./cargo/config` file:

```toml
[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "target-feature=+crt-static"]
```

The [`crt-static` target feature](https://github.com/rust-lang/rfcs/blob/master/text/1721-crt-static.md) is a code generation option that's only available for targets that are suitable for both static and dynamic linkage. MSVC is one of those targets. When `crt-static` is specified, the C runtime libraries will be linked statically instead of dynamically.

Building our app again results in a different binary:

```shell
cargo build --target x86_64-pc-windows-msvc
```

```shell
ls target/x86_64-pc-windows-msvc/debug
```

```shell
Length Name
------ ----
241152 cross-compile-sample.exe
```

It's bigger than before because we have the relevant pieces of MSVCRT included.

## Cross-compiling to Linux

For Windows, we statically link MSVCRT because it's more convenient for end-users. The `crt-static` feature solves our distribution problem. For Linux, we're going to statically link the [musl](https://www.musl-libc.org/intro.html) libc because it's more convenient for us at build time (and is more portable). musl is a complete, self-contained Linux libc with no system dependencies. That means we don't have to provide Linux system libraries to dynamically link to in our Windows build environment. musl solves our cross-compilation problem.

We can install musl as a target for Rust using `rustup`:

```shell
rustup target add x86_64-unknown-linux-musl
```

Attempting to build right now probably won't work though:

```shell
cargo build --target x86_64-unknown-linux-musl
```

```shell
error: linker `cc` not found
error: could not compile `cross-compile-sample`
```

We've got the runtime we need, but not the build tools to link up our final Linux binary. Well, actually we do have the build tools we need. We're just not using them yet. Rust [embeds LLVM's linker](https://github.com/rust-lang/rust/issues/39915), `lld`, which we can use instead of the unavailable `cc` to link our Linux binary on Windows.

Adding `rust-lld` as the linker for our musl target in our `./cargo/config` file will switch from `cc` to Rust's `lld`:

```toml
[target.x86_64-unknown-linux-musl]
linker = "rust-lld"
```

We should now be able to cross-compile a Linux binary from our Windows host:

```shell
cargo build --target x86_64-unknown-linux-musl
```

```shell
ls target/x86_64-unknown-linux-musl/debug
```

```shell
 Length Name
 ------ ----
3041624 cross-compile-sample
```

### Limitations

- You can't directly or transitively depend on any libraries that need to compile C code. That includes the `failure` crate with its `backtrace` dependency. You can build some reasonably complex projects though, including [this UDP server](https://github.com/datalust/sqelf) that depends on `tokio`.
- musl Binaries linked using LLD don't seem to be able to recover from panics (there's been [problems with LLVM's `libunwind` port that's used in Rust's musl target in the past](https://github.com/rust-lang/rust/issues/35599)).

### Other approaches for cross-compilation

This example uses a combination of musl and LLD to cross-compile a Linux binary from Windows without needing any tools that aren't readily available through `rustup`. Other approaches include:

- Use [LCOW](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/linux-containers) to build your Linux binaries natively.
- Use a separate Linux build agent.

They're probably more robust, but depend on the availability of those features, or additional build complexity to coordinate the bundling of artifacts produced in separate environments. Azure Pipelines makes this coordination fairly straightforward though. I've got an example of building a native library (in this case LLVM itself) in Azure Pipelines on several platforms and packaging their artifacts together at the end [here](https://github.com/KodrAus/libllvm).
