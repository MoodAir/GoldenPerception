# GoldenPerception

GoldenPerception 计划使用 Rust + React 分析伦敦金 XAU/USD，辅助用户手动交易。当前提交提供云环境脚本、开发验证样例与[需求草案](docs/requirements.md)。样例验证健康接口和前后端联通；真实行情与趋势分析功能尚未实现，需求仍待用户补充确认。

## 云环境安装

脚本适用于 Linux x86_64，依赖已安装的 Node.js（20.19+ 或 22.12+）、npm、C 编译器、curl、sha256sum；HTTP 验证还需要 Python 3。当前云机器提供 Node 24.19.0 与 npm 11.9.0。

在已有仓库中运行，不需要创建 Git worktree：

```bash
cd /workspace/GoldenPerception
bash scripts/cloud-install.sh
source scripts/cloud-activate.sh
```

安装脚本通过官方 HTTPS 来源和 SHA256 校验安装 Rust 1.99.0、Rustfmt、Clippy，并使用锁文件安装和构建验证样例。React 19.3.0、Vite 8.3.4、TypeScript 7.0.2 已固定版本。

工具链、下载、npm 缓存和 Rust 构建输出默认放在仓库外的 `/workspace/.goldenperception-env`；可用非秘密变量 `GOLDENPERCEPTION_ENV_DIR` 指定其他目录。安装脚本根据自身位置查找仓库。依赖、构建输出和下载文件不纳入 Git。

## 启动验证样例

两个终端分别启动服务。环境恢复后需要重新启动进程。

后端：

```bash
source /workspace/GoldenPerception/scripts/cloud-activate.sh
cd /workspace/GoldenPerception/tools/environment-smoke/backend
cargo build --locked
exec "$CARGO_TARGET_DIR/debug/goldenperception-environment-check"
```

前端：

```bash
source /workspace/GoldenPerception/scripts/cloud-activate.sh
cd /workspace/GoldenPerception/tools/environment-smoke/frontend
exec node node_modules/vite/bin/vite.js --host 127.0.0.1 --port 5173 --strictPort
```

后端监听本机 8080 端口，提供 `/api/health`；Vite 监听本机 5173 端口并代理 `/api`。通过本地请求验证：

```bash
cd /workspace/GoldenPerception
python3 tools/environment-smoke/verify-http.py
```

验证包括后端 JSON、前端代理 JSON、HTML 入口和 Vite 转换后的 React 模块；不包含浏览器 UI 自动化或真实行情检查。云环境 onboarding 界面不提供本机地址预览链接。

只停止自己启动的样例进程，并确认两个端口已释放。本环境的命令包装进程退出时可能遗留子进程；必要时用 `ps -eo pid,ppid,pgid,stat,comm` 确认自己启动的进程组，再用 `kill -TERM -- -<PGID>` 终止该组。

## 验证构建

```bash
source scripts/cloud-activate.sh
cargo build --locked --manifest-path tools/environment-smoke/backend/Cargo.toml
cd tools/environment-smoke/frontend
npm run typecheck
npm run build
```

当前样例不需要行情或交易凭据。免费现货金数据源及一分钟延迟目标仍需验证，后续开发范围见需求草案。
