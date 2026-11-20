#!/usr/bin/env bash
# Self-cleaning 10-suite test harness for AI-model-Prompt-by-mynul/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SRC_REPO="$(cd "$SCRIPT_DIR/.." && pwd -P)"
INSTALLER="$SRC_REPO/install.sh"

TEST_ROOT="$(mktemp -d /tmp/ai-prompts-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

pass() { printf "✅ PASS: %s\n" "$*"; }
fail() { printf "❌ FAIL: %s\n" "$*" >&2; exit 1; }

assert_eq() {
  local actual="$1" expected="$2" label="$3"
  [ "$actual" = "$expected" ] || fail "$label (expected '$expected', got '$actual')"
}

count_dirs() {
  find "$1" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' '
}

cleanup_case() {
  local p
  for p in "$@"; do
    case "$p" in
      "$TEST_ROOT"/*) rm -rf -- "$p" ;;
      *) fail "Refusing to clean outside TEST_ROOT: $p" ;;
    esac
  done
}

# Work on an isolated copy of SRC_REPO so TC-08 can safely simulate upstream edits
UPSTREAM="$TEST_ROOT/src-copy"
cp -R "$SRC_REPO" "$UPSTREAM"
EMPTY_HOME="$TEST_ROOT/empty-home"
mkdir -p "$EMPTY_HOME"

export AI_PROMPTS_REPO="$UPSTREAM"

echo "=== Test Sandbox: $TEST_ROOT ==="

# TC-01: Syntax, <800 line limit, & README.md 1-command bash block audit
/bin/bash -n "$INSTALLER"
bash -n "$INSTALLER"
LINES="$(wc -l < "$INSTALLER" | tr -d ' ')"
[ "$LINES" -lt 800 ] || fail "install.sh exceeded 800 lines ($LINES)"
python3 -B - "$SRC_REPO/README.md" <<'PYEOF'
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text(encoding="utf-8")
blocks = re.findall(r"```bash\n(.*?)```", text, flags=re.DOTALL)
assert blocks, "No bash blocks in README.md"
for i, blk in enumerate(blocks, 1):
    lines = [ln.strip() for ln in blk.strip().splitlines() if ln.strip()]
    assert len(lines) == 1 and not lines[0].startswith("#"), f"README.md bash block #{i} invalid: {lines}"
PYEOF
pass "TC-01: Syntax valid (/bin/bash & bash), line count ${LINES}/800, README.md bash blocks 100% single-command"

# TC-02: --list & --dry-run immutability
LIST_OUT="$(HOME="$EMPTY_HOME" bash "$INSTALLER" --list)"
echo "$LIST_OUT" | grep -q "Public Skills (5)" || fail "--list missing 5 public skills"
echo "$LIST_OUT" | grep -q "Private Skills (5)" || fail "--list missing 5 private skills"
DRY_WS="$TEST_ROOT/dry-ws"
mkdir -p "$DRY_WS"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$DRY_WS" --all --dry-run >/dev/null
[ ! -e "$DRY_WS/.agents" ] || fail "--dry-run created .agents"
cleanup_case "$DRY_WS"
pass "TC-02: --list (5 public + 5 private) and --dry-run immutability verified (cleaned up)"

# TC-03: Default --public for Antigravity --local & --global
PUB_WS="$TEST_ROOT/pub-ws"
PUB_HOME="$TEST_ROOT/pub-home"
mkdir -p "$PUB_WS" "$PUB_HOME"
HOME="$PUB_HOME" bash "$INSTALLER" --local --dir "$PUB_WS" >/dev/null
assert_eq "$(count_dirs "$PUB_WS/.agents/skills")" "5" "local default public count"
HOME="$PUB_HOME" bash "$INSTALLER" --global >/dev/null
assert_eq "$(count_dirs "$PUB_HOME/.gemini/config/skills")" "5" "global default public count"
cleanup_case "$PUB_WS" "$PUB_HOME"
pass "TC-03: Default --public installs 5 skills for both --local and --global (cleaned up)"

# TC-04: --private (5) & --all (10)
PRIV_WS="$TEST_ROOT/priv-ws"
ALL_WS="$TEST_ROOT/all-ws"
mkdir -p "$PRIV_WS" "$ALL_WS"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$PRIV_WS" --private >/dev/null
assert_eq "$(count_dirs "$PRIV_WS/.agents/skills")" "5" "private skill count"
[ -f "$PRIV_WS/.agents/skills/demotivateprogrammer-youtube/SKILL.md" ] || fail "missing private skill"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$ALL_WS" --all >/dev/null
assert_eq "$(count_dirs "$ALL_WS/.agents/skills")" "10" "all skill count"
cleanup_case "$PRIV_WS" "$ALL_WS"
pass "TC-04: --private (5) and --all (10) verified (cleaned up)"

# TC-05: Specific --skill across public + private, typo hint & traversal block
SK_WS="$TEST_ROOT/sk-ws"
mkdir -p "$SK_WS"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$SK_WS" --skill dse-stock-analyst,my-job-hunt-profile >/dev/null
assert_eq "$(count_dirs "$SK_WS/.agents/skills")" "2" "2 specific skills installed"
set +e
TYPO_OUT="$(HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$SK_WS" --skill book-mentr 2>&1)"
TYPO_RC=$?
TRAV_OUT="$(HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$SK_WS" --skill ../etc/passwd 2>&1)"
TRAV_RC=$?
set -e
assert_eq "$TYPO_RC" "2" "typo exit code"
echo "$TYPO_OUT" | grep -q "book-mentor" || fail "missing fuzzy hint book-mentor"
assert_eq "$TRAV_RC" "2" "path traversal exit code"
cleanup_case "$SK_WS"
pass "TC-05: --skill across public/private, fuzzy typo hint & path traversal guard verified (cleaned up)"

# TC-06: Claude Code (--claude) & GitHub Copilot (--copilot) local + global
MULTI_WS="$TEST_ROOT/multi-ws"
MULTI_HOME="$TEST_ROOT/multi-home"
mkdir -p "$MULTI_WS" "$MULTI_HOME"
HOME="$MULTI_HOME" bash "$INSTALLER" --claude --local --dir "$MULTI_WS" --public >/dev/null
assert_eq "$(count_dirs "$MULTI_WS/.claude/skills")" "5" "claude local skills"
HOME="$MULTI_HOME" bash "$INSTALLER" --claude --global --private >/dev/null
assert_eq "$(count_dirs "$MULTI_HOME/.claude/skills")" "5" "claude global private skills"
HOME="$MULTI_HOME" bash "$INSTALLER" --copilot --local --dir "$MULTI_WS" --public >/dev/null
assert_eq "$(count_dirs "$MULTI_WS/.github/skills")" "5" "copilot local skills"
HOME="$MULTI_HOME" bash "$INSTALLER" --copilot --global --all >/dev/null
assert_eq "$(count_dirs "$MULTI_HOME/.copilot/skills")" "10" "copilot global all skills"
cleanup_case "$MULTI_WS" "$MULTI_HOME"
pass "TC-06: --claude and --copilot verified across --local and --global (cleaned up)"

# TC-07: Coexistence with antigravity-skills & .github/workflows/
COEX_WS="$TEST_ROOT/coex-ws"
mkdir -p "$COEX_WS/.github/workflows" "$COEX_WS/.github/skills/existing-agy-skill"
echo "name: CI" > "$COEX_WS/.github/workflows/ci.yml"
echo "agy" > "$COEX_WS/.github/skills/existing-agy-skill/SKILL.md"
echo '# @state {"base":"minimal","roles":[],"skills":[]}' > "$COEX_WS/.github/.antigravity-skills.manifest"
HOME="$EMPTY_HOME" bash "$INSTALLER" --copilot --local --dir "$COEX_WS" --public >/dev/null
assert_eq "$(count_dirs "$COEX_WS/.github/skills")" "6" "5 prompt skills + 1 existing antigravity skill"
HOME="$EMPTY_HOME" bash "$INSTALLER" --copilot --local --dir "$COEX_WS" --uninstall --yes >/dev/null
assert_eq "$(count_dirs "$COEX_WS/.github/skills")" "1" "only existing antigravity skill remains"
[ -f "$COEX_WS/.github/workflows/ci.yml" ] || fail ".github/workflows/ci.yml deleted"
[ -f "$COEX_WS/.github/.antigravity-skills.manifest" ] || fail "antigravity manifest touched"
cleanup_case "$COEX_WS"
pass "TC-07: Coexistence with antigravity-skills & .github/workflows/ verified (cleaned up)"

# TC-08: Stateful --update without bloating --public into --private
UPD_WS="$TEST_ROOT/upd-ws"
mkdir -p "$UPD_WS"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$UPD_WS" --public >/dev/null
echo "<!-- v2 update -->" >> "$UPSTREAM/public/book-mentor/SKILL.md"
(cd "$UPD_WS" && HOME="$EMPTY_HOME" bash "$INSTALLER" --update >/dev/null)
assert_eq "$(count_dirs "$UPD_WS/.agents/skills")" "5" "--update kept exact 5 public skills"
grep -q "v2 update" "$UPD_WS/.agents/skills/book-mentor/SKILL.md" || fail "book-mentor did not update"
[ ! -d "$UPD_WS/.agents/skills/my-personal-secretary" ] || fail "--update leaked private skill"
cleanup_case "$UPD_WS"
pass "TC-08: Stateful --update refreshes installed pack without leaking private skills (cleaned up)"

# TC-09: Selective --uninstall --skill & full --uninstall preserving custom edits
UN_WS="$TEST_ROOT/un-ws"
mkdir -p "$UN_WS"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$UN_WS" --public >/dev/null
echo "<!-- my custom edit -->" >> "$UN_WS/.agents/skills/book-mentor/SKILL.md"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$UN_WS" --uninstall --skill coding-prompt-spec --yes >/dev/null
assert_eq "$(count_dirs "$UN_WS/.agents/skills")" "4" "4 skills after selective uninstall"
HOME="$EMPTY_HOME" bash "$INSTALLER" --local --dir "$UN_WS" --uninstall --yes >/dev/null
[ -f "$UN_WS/.agents/skills/book-mentor/SKILL.md" ] || fail "custom-edited book-mentor was deleted"
[ ! -d "$UN_WS/.agents/skills/dse-stock-analyst" ] || fail "unmodified dse-stock-analyst not removed"
cleanup_case "$UN_WS"
pass "TC-09: Selective & full --uninstall preserve custom edits cleanly (cleaned up)"

# TC-10: Interactive PTY wizard (Target 5 Copilot Local -> Pack 2 Private)
PTY_WS="$TEST_ROOT/pty-ws"
mkdir -p "$PTY_WS"
python3 -B - "$INSTALLER" "$PTY_WS" "$UPSTREAM" <<'PYEOF'
import os, pty, select, sys, time
installer, ws_dir, upstream = sys.argv[1], sys.argv[2], sys.argv[3]
pid, master = pty.fork()
if pid == 0:
    os.chdir(ws_dir)
    os.environ["AI_PROMPTS_REPO"] = upstream
    os.environ["HOME"] = ws_dir + "-home"
    os.execvp("bash", ["bash", installer])
buf = ""
s1 = s2 = False
deadline = time.time() + 25
while time.time() < deadline:
    r, _, _ = select.select([master], [], [], 0.2)
    if r:
        try:
            chunk = os.read(master, 4096).decode("utf-8", errors="replace")
            if not chunk: break
            buf += chunk
        except OSError: break
    if not s1 and "Select target [1-6]" in buf:
        os.write(master, b"5\n"); s1 = True
    if s1 and not s2 and "Select pack [1-4]" in buf:
        os.write(master, b"2\n"); s2 = True
    wpid, status = os.waitpid(pid, os.WNOHANG)
    if wpid == pid:
        os.close(master)
        assert (os.WEXITSTATUS(status) if os.WIFEXITED(status) else 1) == 0, f"PTY failed:\n{buf}"
        sys.exit(0)
os.close(master)
_, status = os.waitpid(pid, 0)
assert (os.WEXITSTATUS(status) if os.WIFEXITED(status) else 1) == 0, f"PTY failed:\n{buf}"
PYEOF
assert_eq "$(count_dirs "$PTY_WS/.github/skills")" "5" "PTY copilot private skills"
cleanup_case "$PTY_WS"
pass "TC-10: Interactive PTY wizard (Target 5 Copilot + Pack 2 Private) verified (cleaned up)"

echo ""
echo "🎉 ALL 10 TEST SUITES PASSED SUCCESSFULLY!"
