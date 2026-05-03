# Rust Bridge

本项目使用 `flutter_rust_bridge` 从 Flutter 调用 Rust 代码。

## 当前桥接了什么

现在接的是一个最小冒烟示例：

```rust
#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}
```

Rust 函数在 `rust/src/api/simple.rs`。生成出来的 Dart 包装函数在
`lib/src/rust/api/simple.dart`：

```dart
String greet({required String name}) =>
    RustLib.instance.api.crateApiSimpleGreet(name: name);
```

Flutter 里直接调用这个 Dart 包装函数即可：

```dart
final text = greet(name: 'Home');
```

当前 `SimplePage` 会显示这个返回值，所以运行 app 后可以看到类似：

```text
Hello, Home!
```

## 返回值怎么获取

返回值就是生成 Dart 函数的返回值。

同步 Rust 函数：

```rust
#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}
```

生成的 Dart 函数也是同步的：

```dart
final result = greet(name: 'Home'); // String
```

异步 Rust 函数如果不标 `sync`，生成的 Dart 函数通常会返回 `Future<T>`：

```rust
pub fn load_title() -> String {
    "Kukuri".to_owned()
}
```

在 Dart 里按异步结果取：

```dart
final title = await loadTitle(); // String
```

简单理解：

```text
Rust 返回 T       -> Dart 拿到 T 或 Future<T>
Rust 返回 Result<T, E> -> Dart 成功拿 T，失败抛异常
```

## 类型映射

常用基础类型会自动映射：

```text
Rust                  Dart
String                String
bool                  bool
i8/i16/i32/u8/u16/u32 int
i64/u64/isize/usize   int 或 BigInt，按 codegen 支持生成
f32/f64               double
Vec<T>                List<T>
Option<T>             T?
()                    void
```

结构体会映射成 Dart class：

```rust
pub struct BirdInfo {
    pub name: String,
    pub count: u32,
}
```

大致会生成可在 Dart 使用的类型：

```dart
final bird = BirdInfo(name: 'Sparrow', count: 3);
```

枚举会映射成 Dart sealed class / enum 风格的生成类型，具体形态看
`lib/src/rust/` 里的生成代码。

复杂类型建议先写 Rust API，再运行 codegen，看生成的 Dart 文件如何暴露。

## 调用链路

```text
Flutter widget
  -> lib/src/rust/api/simple.dart 里的生成 Dart API
  -> lib/src/rust/frb_generated.dart 里的 RustLib 运行时
  -> rust/ 编译出的原生动态库
  -> rust/src/api/simple.rs 里的 Rust 函数
```

`main.dart` 在启动 app 前初始化生成的 Rust 运行时：

```dart
await RustLib.init();
```

## 目录结构

```text
flutter_rust_bridge.yaml   代码生成配置
rust/                      真正写 Rust 代码的 crate
rust_builder/              用来构建 Rust crate 的 Flutter plugin 包装层
lib/src/rust/              自动生成的 Dart 绑定代码
```

不要手动改 `lib/src/rust/` 下面的生成文件。

## 重新生成绑定

修改 `rust/src/api/` 下面的 Rust API 后，运行：

```sh
flutter_rust_bridge_codegen generate
```

然后验证 Rust 和 Flutter 两边：

```sh
cargo check --manifest-path rust/Cargo.toml
flutter analyze
```

## 构建

Windows debug 构建：

```sh
flutter build windows --debug
```

如果 codegen 提示缺少 `cargo expand`，当前简单桥接仍然可以工作。
后面 Rust API 复杂起来后，可以安装：

```sh
cargo install cargo-expand
```
