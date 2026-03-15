inputs: [
  (
    final: prev:
    {
      zjstatus = inputs.zjstatus.packages.${prev.system}.default;
    }
    // {

      opencode-desktop =
        final.callPackage
          (
            {
              lib,
              stdenv,
              rustPlatform,
              pkg-config,
              cargo-tauri,
              bun,
              nodejs,
              cargo,
              rustc,
              jq,
              wrapGAppsHook4,
              makeWrapper,
              dbus,
              glib,
              gtk4,
              libsoup_3,
              librsvg,
              libappindicator,
              glib-networking,
              openssl,
              webkitgtk_4_1,
              gst_all_1,
              opencode,
            }:
            rustPlatform.buildRustPackage (finalAttrs: {
              pname = "opencode-desktop";
              inherit (opencode)
                version
                src
                node_modules
                patches
                ;

              cargoRoot = "packages/desktop/src-tauri";
              cargoLock = {
                lockFile = "${finalAttrs.src}/packages/desktop/src-tauri/Cargo.lock";
                allowBuiltinFetchGit = true;
              };
              buildAndTestSubdir = finalAttrs.cargoRoot;

              nativeBuildInputs = [
                pkg-config
                cargo-tauri.hook
                bun
                nodejs
                cargo
                rustc
                jq
                makeWrapper
              ]
              ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

              buildInputs = lib.optionals stdenv.isLinux [
                dbus
                glib
                gtk4
                libsoup_3
                librsvg
                libappindicator
                glib-networking
                openssl
                webkitgtk_4_1
                gst_all_1.gstreamer
                gst_all_1.gst-plugins-base
                gst_all_1.gst-plugins-good
                gst_all_1.gst-plugins-bad
              ];

              strictDeps = true;

              preBuild = ''
                cp -a ${finalAttrs.node_modules}/{node_modules,packages} .
                chmod -R u+w node_modules packages
                patchShebangs node_modules
                patchShebangs packages/desktop/node_modules

                mkdir -p packages/desktop/src-tauri/sidecars
                cp ${opencode}/bin/opencode packages/desktop/src-tauri/sidecars/opencode-cli-${stdenv.hostPlatform.rust.rustcTarget}
              '';

              tauriBuildFlags = [
                "--config"
                "tauri.prod.conf.json"
                "--no-sign"
              ];

              postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
                mv $out/bin/OpenCode $out/bin/opencode-desktop
                sed -i 's|^Exec=OpenCode$|Exec=opencode-desktop|' $out/share/applications/OpenCode.desktop
              '';

              meta = {
                description = "OpenCode Desktop App";
                homepage = "https://opencode.ai";
                license = lib.licenses.mit;
                mainProgram = "opencode-desktop";
                inherit (opencode.meta) platforms;
              };
            })
          )
          {
            opencode = inputs.opencode.packages.${prev.system}.opencode;
          };
    }
  )
]
