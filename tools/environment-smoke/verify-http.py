import json
import urllib.request

opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
for origin in ["http://127.0.0.1:8080", "http://127.0.0.1:5173"]:
    with opener.open(origin + "/api/health", timeout=5) as response:
        data = json.load(response)
        assert response.status == 200 and data == {
            "status": "ok",
            "purpose": "development-environment-check",
        }, data
        print("PASS", origin, "health JSON and HTTP 200")

with opener.open("http://127.0.0.1:5173/", timeout=5) as response:
    html = response.read().decode()
    assert response.status == 200 and "/src/main.tsx" in html
    print("PASS React development HTML entry")

with opener.open("http://127.0.0.1:5173/src/main.tsx", timeout=5) as response:
    js = response.read().decode()
    assert response.status == 200 and "/api/health" in js and "开发环境验证" in js
    assert "react" in js and "createRoot" in js
    print("PASS Vite transforms and serves React component with health request")
