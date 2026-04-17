# 部署指南：泰国旅行协作应用

## 部署后修改代码会变复杂吗？

**不会，反而更简单。**

部署前：每次改代码 → 重启本地后端 → 重新打开前端
部署后：改代码 → `git push` → Render 自动部署 → 所有人直接看到更新

只有 **1 处需要改**：前端 `lib/utils/constants.dart` 里的 API 地址（从 localhost 换成 Render 的公网 URL）。

---

## 推荐平台：Render（免费，足够 4 人小团队）

Render 提供：
- 免费 Web Service（NestJS 后端）
- 免费 PostgreSQL 数据库
- 自动部署（Git push 后自动更新）
- 自动 HTTPS
- 无需信用卡

---

## 部署步骤（约 10 分钟）

### 第 1 步：把代码推送到 GitHub

1. 去 [github.com](https://github.com) 创建一个公开仓库，比如叫 `thailand-trip-planner`。
2. 在本地 PowerShell 里运行：

```powershell
cd E:\Download\Thailand
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/你的用户名/thailand-trip-planner.git
git push -u origin main
```

### 第 2 步：在 Render 上部署

1. 去 [render.com](https://render.com) 注册账号（用 GitHub 账号一键登录）。
2. 点击 **"New +"** → **"Blueprint"**。
3. 连接你的 GitHub 仓库 `thailand-trip-planner`。
4. Render 会自动读取根目录的 `render.yaml`，创建：
   - 一个 Web Service（运行 NestJS 后端）
   - 一个 PostgreSQL 数据库
5. 点击 **"Apply"**，等待部署完成（约 3-5 分钟）。

### 第 3 步：获取公网地址

部署完成后，Render 会给你一个类似这样的 URL：
```
https://thailand-trip-api.onrender.com
```

记下来，等下前端要用。

### 第 4 步：修改前端 API 地址

打开 `frontend/lib/utils/constants.dart`，把地址换成你的 Render URL：

```dart
const String apiBaseUrl = 'https://thailand-trip-api.onrender.com/api';
const String socketUrl = 'https://thailand-trip-api.onrender.com/collab';
```

然后重新编译前端：
```powershell
cd E:\Download\Thailand\frontend
flutter build apk --release
```

生成的 APK 在 `build/app/outputs/flutter-apk/app-release.apk`，发给朋友安装即可。

---

## 后续修改代码的流程

```
1. 本地修改代码（后端或前端）
2. git add . && git commit -m "xxx" && git push
3. Render 检测到 push，自动重新部署后端（约 1-2 分钟）
4. 如果是前端改动，重新 flutter build apk 打包发给朋友
```

**完全不需要手动登录服务器、不需要重启数据库。**

---

## 注意事项

1. **Render 免费 Web Service 15 分钟无访问会自动休眠**，下次访问会慢 30 秒左右唤醒。如果希望 24 小时在线，可以付费 $7/月 升级，或定期用 UptimeRobot 免费 ping 一下保持唤醒。

2. **数据库 synchronize=true** 会在启动时自动建表。生产环境建议后续改为 migration 模式（我可以帮你改）。

3. **JWT 密钥** 在 `render.yaml` 里设置成自动生成，每次重新部署可能会变（导致旧 token 失效）。建议去 Render Dashboard → Environment 里手动设置固定的 `JWT_SECRET` 和 `JWT_REFRESH_SECRET`。

4. **WebSocket 在 Render 免费 tier 上可能会有延迟**，但功能正常。如果后期用户多了，可以升级到付费 tier。

---

## 备选平台

如果 Render 不满意，也可以用：

- **Railway**：同样免费 PostgreSQL + Node.js，国内访问可能更快一点
- **Fly.io**：性能更好，但需要绑定信用卡
- **阿里云/腾讯云轻量服务器**：一年几十块，完全自己控制，适合长期使用
