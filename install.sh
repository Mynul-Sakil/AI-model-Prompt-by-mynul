#!/usr/bin/env bash
# AI-model-Prompt-by-mynul — Selective Skill Installer, Updater & Uninstaller
# Targets: Antigravity (default) | --claude | --copilot
# Modes:   --public (default) | --private | --all | --skill <name[,name2]>
# Repo:    https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul

if [ -z "${BASH_VERSION:-}" ]; then
  echo "[ERR] Please run this script with bash (e.g., 'bash install.sh')." >&2
  exit 1
fi

set -euo pipefail

TMP_DIR=""
cleanup() {
  if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
    rm -rf -- "$TMP_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 130' INT TERM HUP

main() {
  local REPO_URL="${AI_PROMPTS_REPO:-https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul.git}"
  local BRANCH="${AI_PROMPTS_BRANCH:-main}"
  local MANIFEST_NAME=".ai-prompts-mynul.manifest"

  local AGENT="antigravity" EXPLICIT_AGENT=0 SCOPE="" ACTION="auto" EXPLICIT_BASE=""
  local REQ_SKILLS_CSV="" LIST_ONLY=0
  local PROJECT_DIR="$PWD" EXPLICIT_DIR=0 DRY_RUN=0 FORCE=0 ASSUME_YES=0

  local C_GREEN="" C_BLUE="" C_YELLOW="" C_RED="" C_BOLD="" C_RESET=""
  if [ -t 1 ]; then
    C_GREEN='\033[0;32m'; C_BLUE='\033[0;34m'; C_YELLOW='\033[1;33m'
    C_RED='\033[0;31m'; C_BOLD='\033[1m'; C_RESET='\033[0m'
  fi

  info() { printf "%b[INFO]%b %s\n" "$C_BLUE" "$C_RESET" "$*"; }
  ok()   { printf "%b[OK]%b   %s\n" "$C_GREEN" "$C_RESET" "$*"; }
  warn() { printf "%b[WARN]%b %s\n" "$C_YELLOW" "$C_RESET" "$*" >&2; }
  err()  { printf "%b[ERR]%b  %s\n" "$C_RED" "$C_RESET" "$*" >&2; }
  die()  { err "$1"; exit "${2:-1}"; }

  usage() {
    cat <<'EOF'
AI-model-Prompt-by-mynul — Selective Skill Installer, Updater & Uninstaller

Usage:
  bash install.sh [options]

Target Scope Options:
  --local, --workspace    Install in current/project directory
                          (Antigravity: ./.agents/skills | Claude: ./.claude/skills | Copilot: ./.github/skills)
  --global                Install globally across all projects
                          (Antigravity: ~/.gemini/config/skills | Claude: ~/.claude/skills | Copilot: ~/.copilot/skills)
  --claude                Target Claude Code instead of Antigravity
  --copilot               Target GitHub Copilot instead of Antigravity
  --dir <path>            Override target project directory (implies --local if scope omitted)

Install Mode Options (Default on fresh install: --public):
  --public                Install all 5 generalized public skills [DEFAULT]
  --private               Install all 5 personal private skills
  --all                   Install all 10 skills (public + private)
  --skill <name[,name2]>  Install specific skill(s) from public/ or private/ (additive)
  --list                  List all available public and private skills and exit

Action Options:
  --update                Update existing installation (preserves your installed mode/skills)
  --uninstall             Safely remove managed files (or combine with --skill <name>)
  --force                 Back up modified files to .backups/ and overwrite
  --yes, -y               Skip confirmation prompts (for --uninstall)
  --dry-run               Preview planned actions without modifying any files
  --help, -h              Show this help message
EOF
  }

  canon_dir() { (cd -- "$1" 2>/dev/null && pwd -P); }
  has_tty()   { (: </dev/tty) 2>/dev/null; }

  validate_tokens_csv() {
    local raw="$1" current="$2" normalized tok
    local -a toks=()
    normalized="$(printf "%s" "$raw" | tr ' \t' ',,')"
    IFS=',' read -r -a toks <<< "$normalized"
    for tok in "${toks[@]+"${toks[@]}"}"; do
      [ -n "$tok" ] || continue
      case "$tok" in
        *[!a-zA-Z0-9._-]*|..|.)
          die "Invalid skill identifier '$tok'. Only letters, digits, '.', '_', and '-' are allowed." 2 ;;
      esac
      current="${current:+$current,}$tok"
    done
    [ -n "$current" ] || die "Missing valid skill name." 2
    printf "%s" "$current"
  }

  prompt_confirm() {
    local msg="$1" reply=""
    [ "$ASSUME_YES" -eq 1 ] && return 0
    has_tty || die "Confirmation required in non-interactive session. Re-run with --yes." 2
    printf "%s [y/N]: " "$msg" >/dev/tty
    read -r reply </dev/tty || true
    case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
  }

  while [ $# -gt 0 ]; do
    case "$1" in
      --local|--workspace) [ "$SCOPE" = "global" ] && die "Cannot combine --local and --global." 2; SCOPE="local"; shift ;;
      --global) [ "$SCOPE" = "local" ] && die "Cannot combine --local and --global." 2; SCOPE="global"; shift ;;
      --claude) [ "$EXPLICIT_AGENT" -eq 1 ] && [ "$AGENT" != "claude" ] && die "Cannot combine multiple agent flags." 2; AGENT="claude"; EXPLICIT_AGENT=1; shift ;;
      --copilot|--github-copilot) [ "$EXPLICIT_AGENT" -eq 1 ] && [ "$AGENT" != "copilot" ] && die "Cannot combine multiple agent flags." 2; AGENT="copilot"; EXPLICIT_AGENT=1; shift ;;
      --antigravity) [ "$EXPLICIT_AGENT" -eq 1 ] && [ "$AGENT" != "antigravity" ] && die "Cannot combine multiple agent flags." 2; AGENT="antigravity"; EXPLICIT_AGENT=1; shift ;;
      --dir|--project-dir) [ $# -ge 2 ] || die "Missing path argument for $1" 2; PROJECT_DIR="$2"; EXPLICIT_DIR=1; shift 2 ;;
      --public) [ -n "$EXPLICIT_BASE" ] && [ "$EXPLICIT_BASE" != "public" ] && die "Cannot combine --public, --private, and --all." 2; EXPLICIT_BASE="public"; shift ;;
      --private) [ -n "$EXPLICIT_BASE" ] && [ "$EXPLICIT_BASE" != "private" ] && die "Cannot combine --public, --private, and --all." 2; EXPLICIT_BASE="private"; shift ;;
      --all) [ -n "$EXPLICIT_BASE" ] && [ "$EXPLICIT_BASE" != "all" ] && die "Cannot combine --public, --private, and --all." 2; EXPLICIT_BASE="all"; shift ;;
      --skill|--skills) [ $# -ge 2 ] || die "Missing skill name for $1" 2; REQ_SKILLS_CSV="$(validate_tokens_csv "$2" "$REQ_SKILLS_CSV")"; shift 2 ;;
      --list|--list-skills) LIST_ONLY=1; shift ;;
      --update) [ "$ACTION" = "uninstall" ] && die "Cannot combine --update and --uninstall." 2; ACTION="update"; shift ;;
      --uninstall) [ "$ACTION" = "update" ] && die "Cannot combine --update and --uninstall." 2; ACTION="uninstall"; shift ;;
      --force) FORCE=1; shift ;;
      --yes|-y) ASSUME_YES=1; shift ;;
      --dry-run) DRY_RUN=1; shift ;;
      --help|-h) usage; exit 0 ;;
      *) err "Unknown option: $1"; usage >&2; exit 2 ;;
    esac
  done

  if [ "$EXPLICIT_BASE" = "all" ] && [ -n "$REQ_SKILLS_CSV" ]; then
    die "Cannot combine --all with --skill." 2
  fi
  if [ "$ACTION" = "uninstall" ] && [ -n "$EXPLICIT_BASE" ]; then
    die "Cannot combine --uninstall with --public, --private, or --all (only --skill <name> is supported for partial removal)." 2
  fi

  local PYTHON_BIN=""
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' 2>/dev/null; then
    PYTHON_BIN="python"
  else
    die "'python3' (3.8+) is required for SHA-256 manifest sync." 1
  fi

  # Detect local source directory if run from a cloned repo (offline-first for private repos)
  local SRC_DIR="" SCRIPT_SRC="${BASH_SOURCE[0]:-}"
  if [ -n "${AI_PROMPTS_REPO:-}" ]; then
    if [ -d "$AI_PROMPTS_REPO/public" ] || [ -d "$AI_PROMPTS_REPO/private" ]; then
      SRC_DIR="$(canon_dir "$AI_PROMPTS_REPO")"
    fi
  elif [ -n "$SCRIPT_SRC" ] && [ -f "$SCRIPT_SRC" ]; then
    local sdir=""
    sdir="$(canon_dir "$(dirname -- "$SCRIPT_SRC")" || true)"
    if [ -n "$sdir" ] && { [ -d "$sdir/public" ] || [ -d "$sdir/private" ]; }; then
      SRC_DIR="$sdir"
    fi
  fi

  ensure_source_dir() {
    [ -n "$SRC_DIR" ] && [ -d "$SRC_DIR" ] && return 0
    command -v git >/dev/null 2>&1 || die "'git' is required for remote installation." 1
    TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'ai-prompts-mynul')"
    info "Fetching skills from ${REPO_URL} (${BRANCH})..."
    GIT_TERMINAL_PROMPT=0 git clone --quiet --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR/repo" \
      || die "Failed to clone ${REPO_URL}. If this is a private repository, clone it locally and run 'bash install.sh' from inside the folder." 1
    SRC_DIR="$TMP_DIR/repo"
  }

  run_py_engine() {
    "$PYTHON_BIN" -B - "$@" <<'PYEOF'
import difflib, hashlib, json, os, shutil, sys, time
from pathlib import Path

cmd = sys.argv[1]

def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()

def is_clean_rel(rel: str) -> bool:
    if not rel or rel.startswith("/") or "\\" in rel: return False
    p = Path(rel)
    return (not p.is_absolute()) and (".." not in p.parts) and ("." not in p.parts)

def safe_target_path(dst_root: Path, rel: str) -> Path:
    if not is_clean_rel(rel): sys.exit(f"[ERR]  Invalid relative path in manifest: '{rel}'")
    if dst_root.is_symlink(): sys.exit(f"[ERR]  Refusing to operate on symlinked root '{dst_root}'.")
    cur = dst_root
    for part in Path(rel).parts[:-1]:
        cur = cur / part
        if cur.is_symlink(): sys.exit(f"[ERR]  Refusing to traverse symlinked directory '{cur}'.")
    p = dst_root / rel
    r_real = os.path.realpath(str(dst_root))
    p_real = os.path.realpath(str(p.parent)) if p.parent.exists() else r_real
    if os.path.commonpath([r_real, p_real]) != r_real: sys.exit(f"[ERR]  Path containment check blocked '{rel}'")
    return p

def load_manifest(manifest_path: Path):
    empty = {"base": "none", "skills": [], "excluded": []}
    if manifest_path.is_symlink(): sys.exit(f"[ERR]  Refusing to read symlinked manifest '{manifest_path}'")
    if not manifest_path.is_file(): return False, empty, {}
    state, entries = {"base": "public", "skills": [], "excluded": []}, {}
    for idx, ln in enumerate(manifest_path.read_text(encoding="utf-8").splitlines()):
        if idx == 0 and ln.startswith("# @state "):
            try:
                p = json.loads(ln[len("# @state "):])
                state = {"base": p.get("base", "public"), "skills": list(p.get("skills", [])), "excluded": list(p.get("excluded", []))}
            except Exception: pass
        elif not ln.startswith("#") and "  " in ln:
            h, rel = ln.split("  ", 1)
            rel_s = rel.strip()
            if not is_clean_rel(rel_s): sys.exit(f"[ERR]  Corrupted path in {manifest_path}: '{rel_s}'")
            entries[rel_s] = h.strip()
    return True, state, entries

def save_manifest(manifest_path: Path, dst_root: Path, state: dict, entries: dict):
    dst_root.mkdir(parents=True, exist_ok=True)
    clean_state = {"base": state["base"], "skills": sorted(set(state["skills"]))}
    if state.get("excluded"): clean_state["excluded"] = sorted(set(state["excluded"]))
    header = "# @state " + json.dumps(clean_state, separators=(",", ":"))
    manifest_path.write_text("\n".join([header] + [f"{h}  {r}" for r, h in sorted(entries.items())]) + "\n", encoding="utf-8")

def prune_empty_parents(p: Path, stop_root: Path):
    parent = p.parent
    while parent != stop_root and parent.exists() and not parent.is_symlink():
        ds = parent / ".DS_Store"
        if ds.is_file() and not ds.is_symlink(): ds.unlink()
        if any(parent.iterdir()): break
        parent.rmdir(); parent = parent.parent

def discover_catalog(src_root: Path):
    pub, priv = {}, {}
    for bucket, store in (("public", pub), ("private", priv)):
        bdir = src_root / bucket
        if bdir.is_dir():
            for sd in sorted(d for d in bdir.iterdir() if d.is_dir() and (d / "SKILL.md").is_file()):
                store[sd.name] = sd
    return pub, priv

if cmd == "list":
    pub, priv = discover_catalog(Path(sys.argv[2]))
    print(f"Public Skills ({len(pub)}) [--public]:")
    for s in sorted(pub): print(f"  {s}")
    print(f"\nPrivate Skills ({len(priv)}) [--private]:")
    for s in sorted(priv): print(f"  {s}")

elif cmd == "sync":
    src_root, dst_root = Path(sys.argv[2]), Path(sys.argv[3])
    manifest_name, agent, cur_scope, explicit_base, skills_csv = sys.argv[4:9]
    dry_run, force = (sys.argv[9] == "1"), (sys.argv[10] == "1")
    manifest_path = dst_root / manifest_name

    pub, priv = discover_catalog(src_root)
    all_map = {**pub, **priv}
    all_names = sorted(all_map)
    cli_skills = [s.strip() for s in skills_csv.split(",") if s.strip()]

    for s in cli_skills:
        if s not in all_map:
            close = difflib.get_close_matches(s, all_names, n=5, cutoff=0.45)
            hints = f" Did you mean: {', '.join(close)}?" if close else " Run with --list to browse."
            sys.stderr.write(f"[ERR]  Skill '{s}' not found.{hints}\n")
            sys.exit(2)

    has_existing, old_state, old_manifest = load_manifest(manifest_path)
    old_excl = set(old_state.get("excluded", [])) - set(cli_skills)

    if explicit_base in ("public", "private", "all"):
        new_state, sync_mode = {"base": explicit_base, "skills": sorted(set(cli_skills)), "excluded": []}, "RECONCILE"
    elif cli_skills:
        sync_mode = "ADDITIVE"
        new_state = {"base": old_state["base"], "skills": sorted(set(old_state["skills"]) | set(cli_skills)), "excluded": sorted(old_excl)}
    else:
        sync_mode = "RECONCILE"
        new_state = old_state if has_existing else {"base": "public", "skills": [], "excluded": []}

    def resolve_names(st):
        out = set(st["skills"])
        if st["base"] == "public": out.update(pub)
        elif st["base"] == "private": out.update(priv)
        elif st["base"] == "all": out.update(all_map)
        out -= set(st.get("excluded", []))
        return sorted(out)

    selected = sorted(set(cli_skills)) if sync_mode == "ADDITIVE" else resolve_names(new_state)
    wanted_map = {}
    synced_prefixes = []
    for s in selected:
        sdir = all_map[s]
        synced_prefixes.append(f"skills/{s}/")
        for f in sorted(sdir.rglob("*")):
            if f.is_file() and not f.is_symlink() and "__pycache__" not in f.parts and not f.name.endswith((".pyc", ".DS_Store")):
                rel = f"skills/{s}/{f.relative_to(sdir).as_posix()}"
                wanted_map[rel] = f

    label = f"additive (skill={','.join(cli_skills)})" if sync_mode == "ADDITIVE" else (
        " + ".join([p for p in [new_state["base"] if new_state["base"] != "none" else "", f"skill={','.join(new_state['skills'])}" if new_state["skills"] else ""] if p]) or "custom"
    )
    print(f"[INFO] Syncing {agent} ({cur_scope}) [mode: {label}] -> {dst_root}")

    backup_root = dst_root / ".backups" / time.strftime("%Y%m%d-%H%M%S")
    added = updated = unchanged = preserved = pruned = 0
    new_manifest = {}

    for rel, sf in sorted(wanted_map.items()):
        s_hash = sha256_file(sf)
        df = safe_target_path(dst_root, rel)
        if df.is_symlink(): preserved += 1; continue
        if not df.exists():
            added += 1; new_manifest[rel] = s_hash
            if not dry_run: df.parent.mkdir(parents=True, exist_ok=True); shutil.copy2(sf, df)
        else:
            d_hash = sha256_file(df)
            if d_hash == s_hash:
                unchanged += 1; new_manifest[rel] = s_hash
            elif rel in old_manifest and old_manifest[rel] == d_hash:
                updated += 1; new_manifest[rel] = s_hash
                if not dry_run: shutil.copy2(sf, df)
            elif force:
                updated += 1; new_manifest[rel] = s_hash
                if not dry_run:
                    bf = backup_root / rel; bf.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(df, bf); shutil.copy2(sf, df)
            else:
                preserved += 1
                if rel in old_manifest: new_manifest[rel] = old_manifest[rel]

    for rel, old_hash in sorted(old_manifest.items()):
        if rel in wanted_map: continue
        in_scope = (sync_mode == "RECONCILE") or any(rel.startswith(p) for p in synced_prefixes)
        df = safe_target_path(dst_root, rel)
        if not in_scope:
            if not df.is_symlink() and df.is_file(): new_manifest[rel] = old_hash
            continue
        if not df.is_symlink() and df.is_file():
            if sha256_file(df) == old_hash:
                pruned += 1
                if not dry_run: df.unlink(); prune_empty_parents(df, dst_root)
            else:
                preserved += 1

    if not dry_run:
        save_manifest(manifest_path, dst_root, new_state, new_manifest)
    sk_cnt = len({r.split("/")[1] for r in new_manifest if r.startswith("skills/") and r.count("/") >= 2})
    pfx = "[DRY-RUN] " if dry_run else ""
    print(f"{pfx}Sync summary -> active skills: {sk_cnt} | added: {added}, updated: {updated}, unchanged: {unchanged}, preserved custom: {preserved}, pruned: {pruned}")

elif cmd == "uninstall":
    dst_root, manifest_name = Path(sys.argv[2]), sys.argv[3]
    dry_run, force = (sys.argv[4] == "1"), (sys.argv[5] == "1")
    target_skills = [s.strip() for s in sys.argv[6].split(",") if s.strip()]
    manifest_path = dst_root / manifest_name
    _, state, entries = load_manifest(manifest_path)

    removed = preserved = 0
    kept = {}
    for rel, old_hash in sorted(entries.items()):
        remove_it = (not target_skills) or any(rel.startswith(f"skills/{s}/") for s in target_skills)
        if not remove_it: kept[rel] = old_hash; continue
        df = safe_target_path(dst_root, rel)
        if df.is_symlink() or not df.is_file(): continue
        if force or sha256_file(df) == old_hash:
            removed += 1
            if not dry_run: df.unlink(); prune_empty_parents(df, dst_root)
        else:
            preserved += 1

    if target_skills:
        explicit_sk, excl = set(state.get("skills", [])), set(state.get("excluded", []))
        for s in target_skills:
            if s in explicit_sk: explicit_sk.discard(s)
            elif state.get("base") != "none": excl.add(s)
        state["skills"], state["excluded"] = sorted(explicit_sk), sorted(excl)

    if not dry_run:
        if kept: save_manifest(manifest_path, dst_root, state, kept)
        else:
            manifest_path.unlink()
            if dst_root.exists() and not dst_root.is_symlink() and not any(dst_root.iterdir()): dst_root.rmdir()
    pfx = "[DRY-RUN] " if dry_run else ""
    print(f"{pfx}Uninstall summary -> removed managed files: {removed}, preserved modified/custom files: {preserved}")
PYEOF
  }

  if [ "$LIST_ONLY" -eq 1 ]; then
    ensure_source_dir
    run_py_engine "list" "$SRC_DIR"
    exit 0
  fi

  [ "$EXPLICIT_DIR" -eq 1 ] && [ -z "$SCOPE" ] && SCOPE="local"
  if [ "$SCOPE" != "global" ]; then
    if [ "$EXPLICIT_DIR" -eq 1 ]; then
      [ -d "$PROJECT_DIR" ] || { [ "$DRY_RUN" -eq 1 ] && info "[DRY-RUN] Would create project directory: $PROJECT_DIR" || mkdir -p -- "$PROJECT_DIR"; }
      [ -d "$PROJECT_DIR" ] && PROJECT_DIR="$(canon_dir "$PROJECT_DIR")"
    else
      PROJECT_DIR="$(canon_dir "$PROJECT_DIR")"
    fi
  fi

  target_for() {
    local ag="$1" sc="$2"
    if [ "$ag" = "antigravity" ]; then
      [ "$sc" = "local" ] && printf "%s/.agents" "$PROJECT_DIR" || printf "%s/.gemini/config" "$HOME"
    elif [ "$ag" = "copilot" ]; then
      [ "$sc" = "local" ] && printf "%s/.github" "$PROJECT_DIR" || printf "%s/.copilot" "$HOME"
    else
      [ "$sc" = "local" ] && printf "%s/.claude" "$PROJECT_DIR" || printf "%s/.claude" "$HOME"
    fi
  }

  if [ -z "$SCOPE" ] && [ "$ACTION" = "update" ]; then
    local has_local=0 has_global=0
    [ -f "$(target_for "$AGENT" local)/$MANIFEST_NAME" ] && has_local=1
    [ -f "$(target_for "$AGENT" global)/$MANIFEST_NAME" ] && has_global=1
    if [ "$has_local" -eq 1 ] && [ "$has_global" -eq 0 ]; then SCOPE="local"
    elif [ "$has_global" -eq 1 ] && [ "$has_local" -eq 0 ]; then SCOPE="global"
    elif [ "$has_local" -eq 1 ] && [ "$has_global" -eq 1 ]; then SCOPE="both"
    else die "No existing $AGENT installation detected to update. Pass --local or --global to install." 1; fi
  fi

  if [ -z "$SCOPE" ]; then
    has_tty || die "Non-interactive session detected without a scope flag. Pass --local or --global." 2
    local def_target="1"
    [ "$EXPLICIT_AGENT" -eq 1 ] && [ "$AGENT" = "claude" ] && def_target="3"
    [ "$EXPLICIT_AGENT" -eq 1 ] && [ "$AGENT" = "copilot" ] && def_target="5"
    printf "\n%bAI-model-Prompt-by-mynul — Step 1/2: Choose Target Location%b\n" "$C_BOLD" "$C_RESET" >/dev/tty
    printf "  1) Antigravity    — Current Directory (%s/.agents/skills)\n" "$PROJECT_DIR" >/dev/tty
    printf "  2) Antigravity    — Global            (%s/.gemini/config/skills)\n" "$HOME" >/dev/tty
    printf "  3) Claude Code    — Current Directory (%s/.claude/skills)\n" "$PROJECT_DIR" >/dev/tty
    printf "  4) Claude Code    — Global            (%s/.claude/skills)\n" "$HOME" >/dev/tty
    printf "  5) GitHub Copilot — Current Directory (%s/.github/skills)\n" "$PROJECT_DIR" >/dev/tty
    printf "  6) GitHub Copilot — Global            (%s/.copilot/skills)\n" "$HOME" >/dev/tty
    printf "\nSelect target [1-6] (default: %s): " "$def_target" >/dev/tty
    local choice=""
    read -r choice </dev/tty || true
    case "${choice:-$def_target}" in
      1) AGENT="antigravity"; SCOPE="local" ;;
      2) AGENT="antigravity"; SCOPE="global" ;;
      3) AGENT="claude";      SCOPE="local" ;;
      4) AGENT="claude";      SCOPE="global" ;;
      5) AGENT="copilot";     SCOPE="local" ;;
      6) AGENT="copilot";     SCOPE="global" ;;
      *) die "Invalid selection: $choice" 2 ;;
    esac

    if [ "$ACTION" = "auto" ] && [ -z "$EXPLICIT_BASE" ] && [ -z "$REQ_SKILLS_CSV" ]; then
      printf "\n%bAI-model-Prompt-by-mynul — Step 2/2: Choose Skill Pack%b\n" "$C_BOLD" "$C_RESET" >/dev/tty
      printf "  1) Public   — 5 generalized skills (book-mentor, dse-stock-analyst, mock-tech-interview, job-application-email, coding-prompt-spec) [default]\n" >/dev/tty
      printf "  2) Private  — 5 personal skills (DemotivateProgrammer, secretary, LinkedIn coach, StockGPT, job-hunt profile)\n" >/dev/tty
      printf "  3) All      — All 10 skills (public + private)\n" >/dev/tty
      printf "  4) Skill    — Pick specific skill name(s)\n" >/dev/tty
      printf "\nSelect pack [1-4] (default: 1): " >/dev/tty
      local mchoice=""
      read -r mchoice </dev/tty || true
      case "${mchoice:-1}" in
        1) EXPLICIT_BASE="public" ;;
        2) EXPLICIT_BASE="private" ;;
        3) EXPLICIT_BASE="all" ;;
        4)
          printf "Enter skill name(s) (comma/space separated, e.g. book-mentor,my-job-hunt-profile): " >/dev/tty
          local sinput=""
          read -r sinput </dev/tty || true
          REQ_SKILLS_CSV="$(validate_tokens_csv "$sinput" "")" ;;
        *) die "Invalid pack selection: $mchoice" 2 ;;
      esac
    fi
  fi

  run_for_scope() {
    local cur_scope="$1" target_dir=""
    target_dir="$(target_for "$AGENT" "$cur_scope")"
    if [ "$ACTION" = "uninstall" ]; then
      [ -f "$target_dir/$MANIFEST_NAME" ] || { warn "No managed installation manifest found at $target_dir/$MANIFEST_NAME."; return 0; }
      if [ "$DRY_RUN" -eq 0 ]; then
        if [ -n "$REQ_SKILLS_CSV" ]; then
          prompt_confirm "Remove skill(s) [$REQ_SKILLS_CSV] from $target_dir?" || { warn "Uninstall cancelled."; return 0; }
        else
          prompt_confirm "Remove AI-model-Prompt-by-mynul managed skills from $target_dir (other skills preserved)?" || { warn "Uninstall cancelled."; return 0; }
        fi
      fi
      run_py_engine "uninstall" "$target_dir" "$MANIFEST_NAME" "$DRY_RUN" "$FORCE" "$REQ_SKILLS_CSV"
      return 0
    fi
    if [ "$ACTION" = "update" ] && [ ! -f "$target_dir/$MANIFEST_NAME" ]; then
      die "No existing $AGENT installation manifest found at $target_dir. Run without --update to install." 1
    fi
    ensure_source_dir
    run_py_engine "sync" "$SRC_DIR" "$target_dir" "$MANIFEST_NAME" "$AGENT" "$cur_scope" "$EXPLICIT_BASE" "$REQ_SKILLS_CSV" "$DRY_RUN" "$FORCE"
    ok "$AGENT skills ready in $target_dir/skills"
  }

  if [ "$SCOPE" = "both" ]; then run_for_scope "local"; run_for_scope "global"; else run_for_scope "$SCOPE"; fi
}

main "$@"
