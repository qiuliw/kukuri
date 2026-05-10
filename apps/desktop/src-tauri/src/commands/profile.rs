use kukuri_desktop_runtime::{
    AuthorRequest, ListSocialConnectionsRequest, NotificationIdRequest, SetMyProfileRequest,
};

use crate::state::{DesktopState, map_error, require_runtime};

#[tauri::command]
pub async fn get_my_profile(
    state: tauri::State<'_, DesktopState>,
) -> Result<kukuri_core::Profile, String> {
    require_runtime(&state)?.get_my_profile().await.map_err(map_error)
}

#[tauri::command]
pub async fn set_my_profile(
    state: tauri::State<'_, DesktopState>,
    request: SetMyProfileRequest,
) -> Result<kukuri_core::Profile, String> {
    require_runtime(&state)?.set_my_profile(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn follow_author(
    state: tauri::State<'_, DesktopState>,
    request: AuthorRequest,
) -> Result<kukuri_app_api::AuthorSocialView, String> {
    require_runtime(&state)?.follow_author(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn unfollow_author(
    state: tauri::State<'_, DesktopState>,
    request: AuthorRequest,
) -> Result<kukuri_app_api::AuthorSocialView, String> {
    require_runtime(&state)?.unfollow_author(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn get_author_social_view(
    state: tauri::State<'_, DesktopState>,
    request: AuthorRequest,
) -> Result<kukuri_app_api::AuthorSocialView, String> {
    require_runtime(&state)?.get_author_social_view(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn mute_author(
    state: tauri::State<'_, DesktopState>,
    request: AuthorRequest,
) -> Result<kukuri_app_api::AuthorSocialView, String> {
    require_runtime(&state)?.mute_author(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn unmute_author(
    state: tauri::State<'_, DesktopState>,
    request: AuthorRequest,
) -> Result<kukuri_app_api::AuthorSocialView, String> {
    require_runtime(&state)?.unmute_author(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn list_social_connections(
    state: tauri::State<'_, DesktopState>,
    request: ListSocialConnectionsRequest,
) -> Result<Vec<kukuri_app_api::AuthorSocialView>, String> {
    require_runtime(&state)?
        .list_social_connections(request)
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn list_notifications(
    state: tauri::State<'_, DesktopState>,
) -> Result<Vec<kukuri_app_api::NotificationView>, String> {
    require_runtime(&state)?.list_notifications().await.map_err(map_error)
}

#[tauri::command]
pub async fn mark_notification_read(
    state: tauri::State<'_, DesktopState>,
    request: NotificationIdRequest,
) -> Result<kukuri_app_api::NotificationStatusView, String> {
    require_runtime(&state)?.mark_notification_read(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn mark_all_notifications_read(
    state: tauri::State<'_, DesktopState>,
) -> Result<kukuri_app_api::NotificationStatusView, String> {
    require_runtime(&state)?
        .mark_all_notifications_read()
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn get_notification_status(
    state: tauri::State<'_, DesktopState>,
) -> Result<kukuri_app_api::NotificationStatusView, String> {
    require_runtime(&state)?.get_notification_status().await.map_err(map_error)
}
