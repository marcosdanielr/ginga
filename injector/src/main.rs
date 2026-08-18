use std::{env, fs, process::Command};

use include_dir::{include_dir, Dir};

static DIST: Dir = include_dir!("$CARGO_MANIFEST_DIR/assets/dist");

#[cfg(target_os = "linux")]
const CLI_BYTES: &[u8] = include_bytes!("../assets/cli/VencordInstallerCli-linux");
#[cfg(target_os = "windows")]
const CLI_BYTES: &[u8] = include_bytes!("../assets/cli/VencordInstallerCli.exe");
#[cfg(target_os = "macos")]
const CLI_BYTES: &[u8] = include_bytes!("../assets/cli/VencordInstaller-macos");

#[cfg(target_os = "windows")]
const CLI_NAME: &str = "installer.exe";
#[cfg(not(target_os = "windows"))]
const CLI_NAME: &str = "installer";

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let uninstall = args
        .iter()
        .any(|a| matches!(a.as_str(), "uninject" | "uninstall" | "remove" | "-u"));
    let branch = args
        .iter()
        .find(|a| matches!(a.as_str(), "stable" | "ptb" | "canary"))
        .map(String::as_str)
        .unwrap_or("stable");

    let data = match dirs::data_local_dir() {
        Some(d) => d.join("ginga"),
        None => {
            eprintln!("Could not resolve a local data directory.");
            std::process::exit(1);
        }
    };
    let dist = data.join("dist");

    if let Err(e) = fs::create_dir_all(&dist) {
        eprintln!("Failed to create {}: {e}", dist.display());
        std::process::exit(1);
    }

    for file in DIST.files() {
        let out = dist.join(file.path());
        if let Err(e) = fs::write(&out, file.contents()) {
            eprintln!("Failed to write {}: {e}", out.display());
            std::process::exit(1);
        }
    }

    let cli = data.join(CLI_NAME);
    // Unlink any prior copy first: rewriting a just-executed binary in place
    // fails with ETXTBSY on Unix. Removing it gives a fresh inode.
    let _ = fs::remove_file(&cli);
    if let Err(e) = fs::write(&cli, CLI_BYTES) {
        eprintln!("Failed to write installer: {e}");
        std::process::exit(1);
    }
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let _ = fs::set_permissions(&cli, fs::Permissions::from_mode(0o755));
    }

    let action = if uninstall { "-uninstall" } else { "-install" };
    println!(
        "Ginga: {} (branch: {branch})...",
        if uninstall { "removing" } else { "installing" }
    );

    let status = Command::new(&cli)
        .args([action, "-branch", branch])
        .env("VENCORD_USER_DATA_DIR", &data)
        .env("VENCORD_DEV_INSTALL", "1")
        .status();

    match status {
        Ok(s) if s.success() => {
            if uninstall {
                println!("\nDone. Restart Discord to finish removing Ginga.");
            } else {
                println!(
                    "\nDone. Now:\n  1. Fully quit and reopen Discord.\n  \
                     2. Settings > Vencord > Plugins > enable \"Ginga\".\n  \
                     3. Restart Discord once more."
                );
            }
        }
        Ok(_) => {
            eprintln!("\nThe installer reported an error (see output above).");
            std::process::exit(1);
        }
        Err(e) => {
            eprintln!("\nFailed to run the installer: {e}");
            std::process::exit(1);
        }
    }
}
