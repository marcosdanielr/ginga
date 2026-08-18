// Fetches the official Vencord Installer CLI at build time instead of vendoring
// the binary. Pinned to a specific release tag and verified against a known
// SHA-256, so a moved/compromised "latest" cannot silently flow into the build.
// Uses the system `curl` (present on CI and on Windows 10+, macOS, and Linux)
// to avoid pulling a networking crate into the dependency tree.

use std::{env, fs, path::PathBuf, process::Command};

use sha2::{Digest, Sha256};

const TAG: &str = "v1.4.0";

fn main() {
    println!("cargo:rerun-if-changed=build.rs");

    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    let (file, expected) = match target_os.as_str() {
        "windows" => (
            "VencordInstallerCli.exe",
            "466d2a0be1f380ddffed052df3cc132125fa34dc1af29312e14f13f358c8d2a2",
        ),
        "linux" => (
            "VencordInstallerCli-linux",
            "815917a79391a4426022b395cc1d8e41ae80130edab98cbfbe08fbbe67cd2b28",
        ),
        other => panic!("unsupported target OS for the Ginga injector: {other}"),
    };

    let out = PathBuf::from(env::var("OUT_DIR").unwrap()).join("installer_cli");

    // Reuse a cached download only if it still matches the pinned checksum.
    if let Ok(cached) = fs::read(&out) {
        if hex(&Sha256::digest(&cached)) == expected {
            return;
        }
    }

    let url = format!("https://github.com/Vencord/Installer/releases/download/{TAG}/{file}");
    let status = Command::new("curl")
        .args(["-fsSL", "-o"])
        .arg(&out)
        .arg(&url)
        .status()
        .expect("failed to run `curl` (is it installed and on PATH?)");
    assert!(status.success(), "curl failed to download {url}");

    let bytes = fs::read(&out).expect("failed to read downloaded installer_cli");
    let got = hex(&Sha256::digest(&bytes));
    if got != expected {
        let _ = fs::remove_file(&out);
        panic!("checksum mismatch for {file}\n  expected {expected}\n  got      {got}");
    }
}

fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}
