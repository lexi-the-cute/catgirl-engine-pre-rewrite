//! Server side component of the catgirl-engine crate

#![warn(missing_docs)]
#![warn(clippy::missing_docs_in_private_items)]

#[cfg(test)]
/// Handles testing the server side code
mod test;

#[macro_use]
extern crate tracing;

/// Handles server side game logic
pub mod game;
