"""Run UI regressions with the official Luau CLI (LUAU or luau on PATH)."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
before, after = (root / 'tests/ui.luau').read_text().split('-- INSERT ESP SCRIPT HERE')
with tempfile.TemporaryDirectory() as directory:
    script = Path(directory) / 'ui.luau'
    script.write_text(before + (root / 'esp.lua').read_text() + after)
    subprocess.run([os.environ.get('LUAU', 'luau'), str(script)], check=True)
