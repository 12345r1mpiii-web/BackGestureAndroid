# Back Gesture Android

Early experimental prototype of a two-sided Android-inspired edge gesture for jailbroken iOS.

## Prototype behavior
- Detects horizontal swipes beginning within a narrow left or right screen-edge zone.
- Draws a black, droplet-like shape at the active edge and updates it as the finger moves.
- On completion, attempts to pop a UIKit navigation controller, or dismiss a presented view controller.
- On cancellation, fades the indicator away.

## Important limitations
This is **not a finished or device-tested tweak**. It is a proof-of-concept and may not behave correctly in many apps:
- It does not hook each app's private navigation implementation.
- It does not implement a true interactive predictive-back transition for the previous app screen.
- It may conflict with app-native edge gestures.
- It has not been compiled or tested on an iPhone.
- Compatibility with a jailbreak/bootstrap must be confirmed separately. This repository does not claim Dopamine/RootHide support on iOS 26.

## Build
Requires Theos, an iOS SDK and theos toolchain dependencies.

For standard Dopamine rootless:
```sh
make clean package THEOS_PACKAGE_SCHEME=rootless
```

A RootHide package must be built with a RootHide-compatible packaging toolchain and its correct package scheme. Do not install the standard rootless artifact as a RootHide package.
