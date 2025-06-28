
# 🖱️ Maus

**Maus** is a lightweight macOS utility that brings **physics-based smooth scrolling** to your mouse, transforming discrete scroll wheel input into fluid, trackpad-like motion. Built using **SwiftUI**, it integrates seamlessly into the macOS **menu bar** and stays out of your way—unless you need it.

---

## 🚀 Overview

Maus enhances the native mouse scrolling experience on macOS by applying a **damped harmonic oscillator** model to scrolling behavior. This transforms traditional “tick-based” mouse wheel movement into a responsive, natural-feeling scroll—similar to what you’d find on a premium touchpad or high-end mouse.

Optimized for performance and minimal system impact, Maus includes smart features like **conflict detection**, **dock hiding**, and **automatic permission handling**, all wrapped in a modern, SwiftUI-driven interface.

---

## ✨ Features

- 🎯 **Physics-Based Smooth Scrolling**  
  Configurable stiffness, damping, and momentum for an ultra-fluid scrolling experience.

- 🧠 **Intelligent Conflict Detection**  
  Automatically disables itself when conflicting apps (e.g., ones with `mos` in the bundle ID) are detected.

- 🍎 **macOS Menu Bar Integration**  
  SwiftUI-powered UI in the menu bar for quick toggles and feedback.

- 🕵️ **Optional Dock Hiding**  
  Run Maus as a background utility without cluttering your dock.

- 🔐 **Accessibility Management**  
  Prompts for and monitors system permissions required to capture scroll input.

- ⚙️ **Responsive and Modern UI**  
  Lightweight, polished interface with real-time feedback and easy configuration.

---

## 🧰 Installation

### ✅ Requirements

- macOS 14.0 or later  
- Xcode 16 or later  
- Accessibility permissions (prompted on first run)

### 📦 Build from Source

```bash
git clone https://github.com/apexmacworkshop/Maus.git
```

1. Open `Maus.xcodeproj` in Xcode.
2. Select the `Maus` scheme.
3. Build (`Cmd + B`) and run (`Cmd + R`) the app on a macOS target.
4. Follow the prompt to grant Accessibility permissions:  
   `System Settings > Privacy & Security > Accessibility`.

---

## 🖥️ Usage

- Access Maus from the **menu bar** (magic mouse icon).
- Toggle **Smooth Scrolling** on or off.
- Use the **Hide from Dock** option to run Maus in the background.
- If permissions are missing, click **Open System Preferences** to resolve.
- Click **Quit** to exit the application.

---

## ⚙️ Physics-Based Scrolling System

At the heart of Maus is a **damped harmonic oscillator**—a physics model commonly used in simulations of springs and friction. It converts sudden wheel events into smooth, responsive movement.

### 📐 Model Components

- **Displacement**: Distance between current scroll and target scroll.
- **Velocity**: Simulates momentum.
- **Acceleration**: Derived from spring force and damping friction.

### 🧪 Equation

```
acceleration = (stiffness * displacement - damping * velocity) / mass
```

- `stiffness = 80.0`  
  Controls how quickly scrolling catches up to user input.

- `damping = 12.0`  
  Adds friction—lower values increase inertia, higher values stop sooner.

- `mass = 1.0`  
  Fixed to simplify control over damping and stiffness.

- `momentumFactor = 1.8`  
  Amplifies input ticks for a smooth “fling” effect.

- `scrollDistanceMultiplier = 1.5`  
  Fine-tunes how wheel ticks are converted to target scroll values.

- `maxVelocity = 3000.0`  
  Prevents runaway scrolling on fast input bursts.

- `directionMultiplier = 1.0`  
  Set to `-1.0` to reverse scrolling direction if desired.

---

## 🔧 Under the Hood

- **Event Capture**  
  Uses `CGEventTap` to intercept `scrollWheel` events and modify behavior.

- **Smooth Animation**  
  A `CVDisplayLink` tied to the display's refresh rate drives frame-accurate physics updates.

- **Precision Posting**  
  When accumulated scroll deltas reach a pixel boundary, Maus posts a custom `CGEvent` for ultra-smooth scrolling.

- **Resource Efficiency**  
  Automatically stops the simulation when scrolling comes to rest, conserving CPU.

---

## 🎛️ Customization

All scroll physics parameters can be adjusted in `ScrollManager.swift`. Fine-tune them to suit your personal preference:

```swift
let stiffness = 80.0
let damping = 12.0
let momentumFactor = 1.8
let maxVelocity = 3000.0
```

After making changes, rebuild the project to apply them.

---

## 🧠 Technical Details

| Component        | Description                                 |
|------------------|---------------------------------------------|
| **UI**           | Built with SwiftUI                          |
| **Event System** | `CGEventTap`, `CGEvent`, `CVDisplayLink`    |
| **Permissions**  | Uses `AXIsProcessTrustedWithOptions`        |
| **Scroll Engine**| Physics-based model with pixel precision    |
| **Optional Data**| Includes a SwiftData model for future use   |

---

## 🤝 Contributing

We welcome pull requests and ideas!

1. Fork the repository  
2. Create a feature branch:  
   ```bash
   git checkout -b feature/YourFeature
   ```
3. Commit your changes:  
   ```bash
   git commit -m "Add YourFeature"
   ```
4. Push to your fork and submit a pull request.

Please follow Swift best practices and include tests where appropriate.

---

## 📄 License

Maus is licensed under the [Apache License 2.0](LICENSE).

---

## 📬 Contact

Questions or feedback? Reach out:  
📧 [apexmacworkshop@outlook.com](mailto:apexmacworkshop@outlook.com)

---

## 👨‍💻 Credits

**Developed by:**  
**Gordon.H – Apex Mac Workshop**

