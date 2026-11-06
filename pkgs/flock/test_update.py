import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


VERSION = "0.1.8-nightly.20261105.25"
HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="


def release(version=VERSION, published_at="2026-11-05T14:46:15Z", draft=False):
    return {
        "tag_name": f"v{version}",
        "published_at": published_at,
        "draft": draft,
        "assets": [
            {
                "name": f"Flock-{version}-{arch}.AppImage",
                "browser_download_url": (
                    f"https://github.com/seatedro/t3code/releases/download/v{version}/"
                    f"Flock-{version}-{arch}.AppImage"
                ),
            }
            for arch in ("x86_64", "arm64")
        ],
    }


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        shutil.copy(Path(__file__).with_name("update.sh"), self.root / "update.sh")
        self.source = self.root / "source.json"
        self.original = '{"version": "old", "sources": {}}\n'
        self.source.write_text(self.original)
        self.releases = self.root / "releases.json"
        self.releases.write_text(json.dumps([release()]))
        self.calls = self.root / "nix-calls"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.mock("curl", '#!/usr/bin/env bash\nprintf "%s\\n" "$(<"$RELEASES")"\n')
        self.mock(
            "nix",
            '#!/usr/bin/env bash\nprintf "%s\\n" "$*" >> "$CALLS"\n'
            'if [[ "${FAIL_PREFETCH:-}" == 1 ]]; then exit 1; fi\n'
            f"printf '%s\\n' '{{\"hash\": \"{HASH}\"}}'\n",
        )
        self.env = {
            **os.environ,
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "RELEASES": str(self.releases),
            "CALLS": str(self.calls),
        }

    def mock(self, name, content):
        path = self.bin / name
        path.write_text(content)
        path.chmod(0o755)

    def run_update(self):
        return subprocess.run(
            ["bash", str(self.root / "update.sh")],
            env=self.env,
            capture_output=True,
            text=True,
        )

    def test_latest_nightly_and_both_architectures(self):
        self.releases.write_text(json.dumps([
            release("99.0.0", "2026-12-01T00:00:00Z"),
            release(),
            release("0.1.8-nightly.20261106.26", "2026-11-06T00:00:00Z", True),
            release("0.1.6-nightly.20261104.23", "2026-11-04T00:00:00Z"),
        ]))
        result = self.run_update()
        self.assertEqual(result.returncode, 0, result.stderr)
        source = json.loads(self.source.read_text())
        self.assertEqual(source["version"], VERSION)
        self.assertEqual(set(source["sources"]), {"x86_64-linux", "aarch64-linux"})
        self.assertEqual(len(self.calls.read_text().splitlines()), 2)

    def test_idempotent_without_prefetch(self):
        self.assertEqual(self.run_update().returncode, 0)
        self.calls.unlink()
        previous = self.source.read_bytes()
        result = self.run_update()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("already at", result.stdout)
        self.assertEqual(self.source.read_bytes(), previous)
        self.assertFalse(self.calls.exists())

    def test_incomplete_release_preserves_pins(self):
        incomplete = release()
        incomplete["assets"].pop()
        self.releases.write_text(json.dumps([incomplete]))
        result = self.run_update()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.source.read_text(), self.original)
        self.assertEqual(list(self.root.glob("source.json.*")), [])

    def test_failed_prefetch_preserves_pins(self):
        self.env["FAIL_PREFETCH"] = "1"
        self.assertNotEqual(self.run_update().returncode, 0)
        self.assertEqual(self.source.read_text(), self.original)
        self.assertEqual(list(self.root.glob("source.json.*")), [])

    def test_no_nightly_preserves_pins(self):
        self.releases.write_text(json.dumps([release("1.0.0")]))
        self.assertNotEqual(self.run_update().returncode, 0)
        self.assertEqual(self.source.read_text(), self.original)

    def test_unexpected_url_is_rejected(self):
        unexpected = release()
        unexpected["assets"][0]["browser_download_url"] = "https://example.com/app.AppImage"
        self.releases.write_text(json.dumps([unexpected]))
        self.assertNotEqual(self.run_update().returncode, 0)
        self.assertEqual(self.source.read_text(), self.original)
        self.assertFalse(self.calls.exists())


if __name__ == "__main__":
    unittest.main()
