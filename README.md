# AI Prompts & Extracted Skills (`AI-model-Prompt-by-mynul`)

All 17 original prompt files have been extracted into clean `SKILL.md` skills and organized into `public/`, `private/`, and `archive/` with zero data loss — complete with a standalone **`install.sh`** that works across **Antigravity**, **Claude Code**, and **GitHub Copilot** using an isolated `.ai-prompts-mynul.manifest` tracker.

> Every `bash` code block below is a **single standalone command** for one-click copy-paste.
> *(If this repository is set to **Private** on GitHub, clone it locally and run `bash install.sh ...` with the exact same flags — it works 100% offline.)*

---

## Quick Start (Remote One-Line `curl` Install)

### Interactive 2-Step Wizard (Choose Agent + Public / Private / All / Specific Skill)

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash
```

### List All 10 Skills (`public/` + `private/`)

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --list
```

### Install Public Pack (`--public`, Default — 5 Generalized Skills)

**Antigravity — Current Project (`./.agents/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --local
```

**Antigravity — Global (`~/.gemini/config/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --global
```

**Claude Code — Current Project (`./.claude/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --claude --local
```

**GitHub Copilot — Current Project (`./.github/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --copilot --local
```

### Install Private Pack (`--private` — 5 Personal Skills) or All 10 (`--all`)

**Antigravity — Global Private Pack (`~/.gemini/config/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --global --private
```

**Claude Code — Global Private Pack (`~/.claude/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --claude --global --private
```

**GitHub Copilot — Global Private Pack (`~/.copilot/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --copilot --global --private
```

**Antigravity — Global All 10 Skills (`public/` + `private/`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --global --all
```

### Update or Uninstall

**Update existing installation (auto-detects local & global):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --update
```

**Uninstall managed skills (global Antigravity):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --global --uninstall
```

---

## 1. `public/` — Generalized, PII-Free Skills (5 Skills)

| Skill | Purpose | Original Source(s) | GitHub Link |
| :--- | :--- | :--- | :--- |
| `book-mentor` | Chapter-by-chapter interactive book tutor | `BookGPT.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/public/book-mentor) |
| `dse-stock-analyst` | Dhaka Stock Exchange (DSE) analyst, recaps & Bangla educational scripts | `Financial Analysis Name Tareq.txt`, `Stock Market Information Analysis.txt`, `stockgpt-youtube-helper.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/public/dse-stock-analyst) |
| `mock-tech-interview` | Candidate-side technical/HR mock interviewer & daily micro-learning coach | `Interview Preparation.txt`, `regular learning from senior dev.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/public/mock-tech-interview) |
| `job-application-email` | Tech job-application email builder + remote company Boolean search | `Email Builder.txt`, `Job search Company Name Search Prompt.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/public/job-application-email) |
| `coding-prompt-spec` | Pre-code specification gate (Goal, Rules, Examples, Edge Cases, Mistake Check) | `AI_PROMPT_RULE_FOR_CODDING.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/public/coding-prompt-spec) |

### Install Individual Public Skills

*(Swap `--local` for `--global`, or add `--claude` / `--copilot` before `--local` as needed.)*

**`book-mentor`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --local --skill book-mentor
```

**`dse-stock-analyst`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --local --skill dse-stock-analyst
```

**`mock-tech-interview`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --local --skill mock-tech-interview
```

**`job-application-email`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --local --skill job-application-email
```

**`coding-prompt-spec`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/AI-model-Prompt-by-mynul/main/install.sh | bash -s -- --local --skill coding-prompt-spec
```

---

## 2. `private/` — Personal Skills (5 Skills)

| Skill | Purpose | Original Source(s) | GitHub Link |
| :--- | :--- | :--- | :--- |
| `demotivateprogrammer-youtube` | YouTube channel profile, 6-min structure, title formulas & editing notes | `youtube helper.txt`, `Youtube future video Idea.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/private/demotivateprogrammer-youtube) |
| `my-personal-secretary` | Schedule-aware personal secretary & 3-day interview rotation | `Personal assistences command And My status track.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/private/my-personal-secretary) |
| `my-linkedin-and-career-coach` | Personal MERN/Next.js LinkedIn strategist & career advisor | `Linkedin Post Idea Genarator.txt`, `Linkedin helper.txt`, `personal assistence.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/private/my-linkedin-and-career-coach) |
| `my-dse-stockgpt-bangla` | Personal Tareq / StockGPT DSE Bangla YouTube co-creator preset | `Financial Analysis Name Tareq.txt`, `Stock Market Information Analysis.txt`, `stockgpt-youtube-helper.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/private/my-dse-stockgpt-bangla) |
| `my-job-hunt-profile` | Personal Nayeem mock interviewer + MERN job-application preset | `Interview Preparation.txt`, `Email Builder.txt`, `regular learning from senior dev.txt` | [View Skill](https://github.com/Mynul-Sakil/AI-model-Prompt-by-mynul/tree/main/private/my-job-hunt-profile) |

---

## 3. Local Clone Usage (Offline / Private Repo)

Run directly inside a cloned copy of this repository:

**Interactive wizard:**

```bash
bash install.sh
```

**Install all 5 private skills globally:**

```bash
bash install.sh --global --private
```

**Install specific skill(s) (public or private):**

```bash
bash install.sh --global --skill book-mentor,my-job-hunt-profile
```

---

## 4. `archive/` & Automated Tests

- `archive/originals/` — All 15 original `.txt` prompt files preserved verbatim
- `archive/claude-prompt-old-29-11-24.txt` — Finished one-off Git & GitHub YouTube video script (Nov 2024)
- `archive/data-2025-02-06-21-54-43.zip` — Raw account export (`users.json`) — **keep repo private**

**Run the self-cleaning 10-suite test harness:**

```bash
bash tests/test_installer.sh
```
