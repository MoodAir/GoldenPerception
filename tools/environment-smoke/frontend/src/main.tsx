import { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import "./style.css";

type HealthCheck = {
  state: "loading" | "ready" | "error";
  detail: string;
};

function EnvironmentCheck() {
  const [health, setHealth] = useState<HealthCheck>({
    state: "loading",
    detail: "正在请求 /api/health…",
  });

  useEffect(() => {
    const controller = new AbortController();
    const timeout = window.setTimeout(() => controller.abort(), 10_000);

    async function checkHealth() {
      try {
        const response = await fetch("/api/health", {
          signal: controller.signal,
        });
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        const payload: unknown = await response.json();
        setHealth({
          state: "ready",
          detail: `HTTP ${response.status}\n${JSON.stringify(payload, null, 2)}`,
        });
      } catch (error) {
        if (!controller.signal.aborted) {
          setHealth({
            state: "error",
            detail: error instanceof Error ? error.message : String(error),
          });
        } else {
          setHealth({ state: "error", detail: "健康检查请求超时或已取消。" });
        }
      } finally {
        window.clearTimeout(timeout);
      }
    }

    void checkHealth();
    return () => {
      window.clearTimeout(timeout);
      controller.abort();
    };
  }, []);

  const label = {
    loading: "检查中",
    ready: "API 已连接",
    error: "API 连接失败",
  }[health.state];

  return (
    <main>
      <h1>开发环境验证</h1>
      <p>React 前端已加载。此页面验证本地 Rust API 与前端代理的连接。</p>
      <section aria-label="API 健康检查">
        <h2 aria-live="polite" data-state={health.state}>{label}</h2>
        <pre>{health.detail}</pre>
      </section>
    </main>
  );
}

const root = document.getElementById("root");
if (!root) {
  throw new Error("Root element is missing.");
}
createRoot(root).render(<EnvironmentCheck />);
