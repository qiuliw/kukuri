use kukuri_desktop_runtime::{
    DeleteDirectMessageMessageRequest, DirectMessageRequest, ListDirectMessageMessagesRequest,
    SendDirectMessageRequest,
};

use crate::state::{DesktopState, map_error, require_runtime};

#[tauri::command]
pub async fn open_direct_message(
    state: tauri::State<'_, DesktopState>,
    request: DirectMessageRequest,
) -> Result<kukuri_app_api::DirectMessageConversationView, String> {
    require_runtime(&state)?.open_direct_message(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn list_direct_messages(
    state: tauri::State<'_, DesktopState>,
) -> Result<Vec<kukuri_app_api::DirectMessageConversationView>, String> {
    require_runtime(&state)?.list_direct_messages().await.map_err(map_error)
}

#[tauri::command]
pub async fn list_direct_message_messages(
    state: tauri::State<'_, DesktopState>,
    request: ListDirectMessageMessagesRequest,
) -> Result<kukuri_app_api::DirectMessageTimelineView, String> {
    require_runtime(&state)?
        .list_direct_message_messages(request)
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn send_direct_message(
    state: tauri::State<'_, DesktopState>,
    request: SendDirectMessageRequest,
) -> Result<String, String> {
    require_runtime(&state)?.send_direct_message(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn delete_direct_message_message(
    state: tauri::State<'_, DesktopState>,
    request: DeleteDirectMessageMessageRequest,
) -> Result<(), String> {
    require_runtime(&state)?
        .delete_direct_message_message(request)
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn clear_direct_message(
    state: tauri::State<'_, DesktopState>,
    request: DirectMessageRequest,
) -> Result<(), String> {
    require_runtime(&state)?.clear_direct_message(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn get_direct_message_status(
    state: tauri::State<'_, DesktopState>,
    request: DirectMessageRequest,
) -> Result<kukuri_app_api::DirectMessageStatusView, String> {
    require_runtime(&state)?.get_direct_message_status(request).await.map_err(map_error)
}
