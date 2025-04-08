# swiftui-metal-template

A lightweight standalone iOS app template project that combines SwiftUI with MetalKit to help developers quickly prototype and test fragment shaders. Ideal for GPU experimentation, real-time rendering, and visual effects development on Apple platforms.

---

## 🚀 Features

- Metal-based rendering pipeline

---

## 🛠 Requirements

- iOS 18+
- Xcode 16+
- Swift 5.9+
- Metal framework

---

## 🧪 Shader Example Overview

This project includes a sample fragment shader that simulates the dynamic appearance of a computer monitor processing and displaying its progress.

Using the Metal Framework on an iOS device:

- A **Core Image noise filter** generates a `CIImage` with random values.
- This `CIImage` is converted into a Metal texture.
- The texture is passed to a **fragment shader**.
- The shader uses the noise as input to randomly influence the **color and position of circles** on a grid.

The result is a continuously animated visual, evoking the sense of an **active, ongoing computation** — ideal for generative art, system visualizations, or shader exploration.

---


## 🎥 Example Shader Output

[![Watch the demo](https://img.youtube.com/vi/_kudm23sv3I/0.jpg)](https://www.youtube.com/watch?v=_kudm23sv3I)


---

## 📝 License

This project is licensed under the [MIT License](./LICENSE) © 2025 robertallenmartin

