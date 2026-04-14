# NeonGlow

NeonGlow 是一个 iOS 霓虹发光效果示例项目，用来展示和调试可配置的发光边框、流光动画与展示过渡效果。

项目包含三个部分：

- `NeonGlowKit`：Swift 实现的核心发光效果组件。
- `NeonGlow`：Swift Showcase 应用，用于预览和调节动画、边框、光晕等参数。
- `NeonGlowObjC`：Objective-C Showcase 应用，用于对照和验证 Objective-C 版本效果。

项目基于 `XcodeGen` 组织，最低支持 `iOS 17.0`。如需重新生成工程，可在仓库根目录执行：

```bash
xcodegen generate
```
