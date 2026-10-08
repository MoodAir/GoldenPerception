use axum::{Json, Router, routing::get};
use serde_json::{Value, json};

async fn health() -> Json<Value> {
    Json(json!({"status": "ok", "purpose": "development-environment-check"}))
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/api/health", get(health));
    let listener = tokio::net::TcpListener::bind("127.0.0.1:8080")
        .await
        .expect("bind development environment check server");
    axum::serve(listener, app).await.expect("serve health endpoint");
}
