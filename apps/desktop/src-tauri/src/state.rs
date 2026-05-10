use std::{path::PathBuf, sync::Arc};

use kukuri_desktop_runtime::{DesktopRuntime, resolve_db_path_from_env};
use tauri::Manager;

pub(crate) struct DesktopState {
    pub(crate) runtime: Option<Arc<DesktopRuntime>>,
    pub(crate) db_path: PathBuf,
}

pub(crate) fn map_error(error: impl std::fmt::Display) -> String {
    error.to_string()
}

pub(crate) fn require_runtime(
    state: &tauri::State<'_, DesktopState>,
) -> Result<Arc<DesktopRuntime>, String> {
    state
        .runtime
        .clone()
        .ok_or_else(|| "runtime not initialized".to_string())
}

pub(crate) fn resolve_db_path(app_handle: &tauri::AppHandle) -> Result<PathBuf, String> {
    let app_data_dir = app_handle
        .path()
        .app_data_dir()
        .map_err(|e| format!("failed to resolve app data dir: {e}"))?;
    resolve_db_path_from_env(&app_data_dir).map_err(map_error)
}

fn identity_exists(db_path: &PathBuf) -> bool {
    db_path.with_extension("identity-key").exists()
        || db_path.with_extension("identity-store").exists()
}

pub(crate) fn build_desktop_state(
    app_handle: &tauri::AppHandle,
) -> Result<DesktopState, String> {
    let db_path = resolve_db_path(app_handle)?;

    if !identity_exists(&db_path) {
        return Ok(DesktopState {
            runtime: None,
            db_path,
        });
    }

    let runtime =
        tauri::async_runtime::block_on(DesktopRuntime::from_env(db_path.clone()))
            .map_err(map_error)?;

    Ok(DesktopState {
        runtime: Some(Arc::new(runtime)),
        db_path,
    })
}
