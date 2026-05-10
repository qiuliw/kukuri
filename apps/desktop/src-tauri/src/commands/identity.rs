use kukuri_core::{KukuriKeys, encode_secret_key_bech32, LEGACY_SECRET_HRP};
use kukuri_desktop_runtime::{delete_identity_files, write_identity_to_file};
use tauri::Manager;

use crate::state::{DesktopState, map_error};

#[derive(serde::Serialize)]
pub struct GuideStatus {
    pub ready: bool,
    pub pubkey_hex: Option<String>,
    pub secret_nsec: Option<String>,
}

#[tauri::command]
pub async fn get_guide_status(
    state: tauri::State<'_, DesktopState>,
) -> Result<GuideStatus, String> {
    match state.runtime.as_ref() {
        Some(rt) => Ok(GuideStatus {
            ready: true,
            pubkey_hex: Some(rt.author_keys_pubkey_hex()),
            secret_nsec: None,
        }),
        None => Ok(GuideStatus {
            ready: false,
            pubkey_hex: None,
            secret_nsec: None,
        }),
    }
}

#[tauri::command]
pub async fn create_identity(
    state: tauri::State<'_, DesktopState>,
) -> Result<GuideStatus, String> {
    let db_path = state.db_path.clone();

    // 先删旧文件，确保每次都是全新随机密钥
    delete_identity_files(&db_path).map_err(map_error)?;

    let keys = KukuriKeys::generate();
    let hex = keys.export_secret_hex();

    write_identity_to_file(&db_path, &hex).map_err(map_error)?;

    let nsec = encode_secret_key_bech32(&hex, LEGACY_SECRET_HRP).map_err(map_error)?;

    Ok(GuideStatus {
        ready: false,
        pubkey_hex: Some(keys.public_key_hex()),
        secret_nsec: Some(nsec),
    })
}

#[tauri::command]
pub async fn confirm_guide(app: tauri::AppHandle) -> Result<(), String> {
    tauri::process::restart(&app.env());
}

#[tauri::command]
pub async fn import_identity(
    state: tauri::State<'_, DesktopState>,
    app: tauri::AppHandle,
    secret: String,
) -> Result<(), String> {
    let db_path = state.db_path.clone();

    delete_identity_files(&db_path).map_err(map_error)?;

    let keys = KukuriKeys::parse(secret.trim()).map_err(map_error)?;
    let hex = keys.export_secret_hex();

    write_identity_to_file(&db_path, &hex).map_err(map_error)?;

    tauri::process::restart(&app.env());
}

#[tauri::command]
pub async fn logout(
    state: tauri::State<'_, DesktopState>,
    app: tauri::AppHandle,
) -> Result<(), String> {
    let db_path = state.db_path.clone();
    delete_identity_files(&db_path).map_err(map_error)?;
    tauri::process::restart(&app.env());
}
