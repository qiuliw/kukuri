use kukuri_desktop_runtime::{
    BookmarkCustomReactionRequest, CreateCustomReactionAssetRequest,
    ListRecentReactionsRequest, RemoveBookmarkedCustomReactionRequest, ToggleReactionRequest,
};

use crate::state::{DesktopState, map_error, require_runtime};

#[tauri::command]
pub async fn toggle_reaction(
    state: tauri::State<'_, DesktopState>,
    request: ToggleReactionRequest,
) -> Result<kukuri_app_api::ReactionStateView, String> {
    require_runtime(&state)?.toggle_reaction(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn list_my_custom_reaction_assets(
    state: tauri::State<'_, DesktopState>,
) -> Result<Vec<kukuri_app_api::CustomReactionAssetView>, String> {
    require_runtime(&state)?
        .list_my_custom_reaction_assets()
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn list_recent_reactions(
    state: tauri::State<'_, DesktopState>,
    request: ListRecentReactionsRequest,
) -> Result<Vec<kukuri_app_api::RecentReactionView>, String> {
    require_runtime(&state)?.list_recent_reactions(request).await.map_err(map_error)
}

#[tauri::command]
pub async fn create_custom_reaction_asset(
    state: tauri::State<'_, DesktopState>,
    request: CreateCustomReactionAssetRequest,
) -> Result<kukuri_app_api::CustomReactionAssetView, String> {
    require_runtime(&state)?
        .create_custom_reaction_asset(request)
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn list_bookmarked_custom_reactions(
    state: tauri::State<'_, DesktopState>,
) -> Result<Vec<kukuri_app_api::BookmarkedCustomReactionView>, String> {
    require_runtime(&state)?
        .list_bookmarked_custom_reactions()
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn bookmark_custom_reaction(
    state: tauri::State<'_, DesktopState>,
    request: BookmarkCustomReactionRequest,
) -> Result<kukuri_app_api::BookmarkedCustomReactionView, String> {
    require_runtime(&state)?
        .bookmark_custom_reaction(request)
        .await
        .map_err(map_error)
}

#[tauri::command]
pub async fn remove_bookmarked_custom_reaction(
    state: tauri::State<'_, DesktopState>,
    request: RemoveBookmarkedCustomReactionRequest,
) -> Result<(), String> {
    require_runtime(&state)?
        .remove_bookmarked_custom_reaction(request)
        .await
        .map_err(map_error)
}
