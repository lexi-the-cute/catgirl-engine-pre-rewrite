#[cfg(target_family = "wasm")]
use wasm_bindgen::prelude::wasm_bindgen;

/// Server side game loop
///
/// # Errors
///
/// Errors not implemented yet...
#[cfg_attr(target_family = "wasm", wasm_bindgen)]
pub fn server_game_loop() -> Result<(), String> {
    debug!("Started server game loop...");
    error!("Dedicated server game loop not implemented yet...");

    loop {
        if utils::exit::is_exiting() {
            break;
        }
    }

    Ok(())
}
