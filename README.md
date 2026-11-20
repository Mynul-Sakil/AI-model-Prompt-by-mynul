# AI Prompts & Extracted Skills (Public + Private Organization)

All 17 original prompt files from this folder have been extracted into clean `SKILL.md` skills and organized into `public/`, `private/`, and `archive/` with zero data loss — complete with a standalone **`install.sh`** installer that works across **Antigravity**, **Claude Code**, and **GitHub Copilot** and coexists safely alongside **[Mynul-Sakil/antigravity-skills](https://github.com/Mynul-Sakil/antigravity-skills)** (`.ai-prompts-mynul.manifest`).

> Every `bash` code block below is a **single standalone command** for one-click copy-paste.

---

## Quick Install Using This Repo's `install.sh` (Works Offline & With Private Repos)

### Interactive 2-Step Wizard (Choose Agent + Public / Private / All / Specific Skill)

```bash
bash install.sh
```

### List All 10 Skills (`public/` + `private/`)

```bash
bash install.sh --list
```

### Install All 5 Private Skills Globally (Antigravity: `~/.gemini/config/skills`)

```bash
bash install.sh --global --private
```

### Install All 5 Private Skills Globally (Claude Code: `~/.claude/skills`)

```bash
bash install.sh --claude --global --private
```

### Install All 5 Private Skills Globally (GitHub Copilot: `~/.copilot/skills`)

```bash
bash install.sh --copilot --global --private
```

### Install All 10 Skills (`public/` + `private/`) Globally in Antigravity

```bash
bash install.sh --global --all
```

### Install Specific Skill(s) Only (Works for Both `public/` and `private/`)

```bash
bash install.sh --global --skill book-mentor,my-job-hunt-profile
```

### Update or Uninstall Managed Skills (Never Touches `antigravity-skills` Files)

**Update installed skills:**

```bash
bash install.sh --update
```

**Uninstall all managed skills (global Antigravity):**

```bash
bash install.sh --global --uninstall
```

---

## 1. `public/` — Generalized, PII-Free Skills (Also Published in `antigravity-skills`)

| Skill | Purpose | Original Source(s) | GitHub Link |
| :--- | :--- | :--- | :--- |
| `book-mentor` | Chapter-by-chapter interactive book tutor | `BookGPT.txt` | [View Skill](https://github.com/Mynul-Sakil/antigravity-skills/tree/main/skills/book-mentor) |
| `dse-stock-analyst` | Dhaka Stock Exchange (DSE) analyst, recaps & Bangla educational scripts | `Financial Analysis Name Tareq.txt`, `Stock Market Information Analysis.txt`, `stockgpt-youtube-helper.txt` | [View Skill](https://github.com/Mynul-Sakil/antigravity-skills/tree/main/skills/dse-stock-analyst) |
| `mock-tech-interview` | Candidate-side technical/HR mock interviewer & daily micro-learning coach | `Interview Preparation.txt`, `regular learning from senior dev.txt` | [View Skill](https://github.com/Mynul-Sakil/antigravity-skills/tree/main/skills/mock-tech-interview) |
| `job-application-email` | Tech job-application email builder + remote company Boolean search | `Email Builder.txt`, `Job search Company Name Search Prompt.txt` | [View Skill](https://github.com/Mynul-Sakil/antigravity-skills/tree/main/skills/job-application-email) |
| `coding-prompt-spec` | Pre-code specification gate (Goal, Rules, Examples, Edge Cases, Mistake Check) | `AI_PROMPT_RULE_FOR_CODDING.txt` | [View Skill](https://github.com/Mynul-Sakil/antigravity-skills/tree/main/skills/coding-prompt-spec) |

### Remote One-Line Install for Anyone (Without Cloning This Repo)

**All 5 Public Skills — Antigravity Current Project (`./.agents/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --local --skill book-mentor,dse-stock-analyst,mock-tech-interview,job-application-email,coding-prompt-spec
```

**All 5 Public Skills — Claude Code Current Project (`./.claude/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --claude --local --skill book-mentor,dse-stock-analyst,mock-tech-interview,job-application-email,coding-prompt-spec
```

**All 5 Public Skills — GitHub Copilot Current Project (`./.github/skills`):**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --copilot --local --skill book-mentor,dse-stock-analyst,mock-tech-interview,job-application-email,coding-prompt-spec
```

### Install Each Public Skill Individually

**`book-mentor`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --local --skill book-mentor
```

**`dse-stock-analyst`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --local --skill dse-stock-analyst
```

**`mock-tech-interview`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --local --skill mock-tech-interview
```

**`job-application-email`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --local --skill job-application-email
```

**`coding-prompt-spec`:**

```bash
curl -fsSL https://raw.githubusercontent.com/Mynul-Sakil/antigravity-skills/main/install.sh | bash -s -- --local --skill coding-prompt-spec
```

---

## 2. `private/` — Personal Skills (Strictly Local — Keep Repo Private)

| Skill | Purpose | Original Source(s) |
| :--- | :--- | :--- |
| `private/demotivateprogrammer-youtube/` | YouTube channel profile, 6-min structure, title formulas & editing notes | `youtube helper.txt`, `Youtube future video Idea.txt` |
| `private/my-personal-secretary/` | Schedule-aware personal secretary & 3-day interview rotation | `Personal assistences command And My status track.txt` |
| `private/my-linkedin-and-career-coach/` | Personal MERN/Next.js LinkedIn strategist & career advisor | `Linkedin Post Idea Genarator.txt`, `Linkedin helper.txt`, `personal assistence.txt` |
| `private/my-dse-stockgpt-bangla/` | Personal Tareq / StockGPT DSE Bangla YouTube co-creator preset | `Financial Analysis Name Tareq.txt`, `Stock Market Information Analysis.txt`, `stockgpt-youtube-helper.txt` |
| `private/my-job-hunt-profile/` | Personal Nayeem mock interviewer + MERN job-application preset | `Interview Preparation.txt`, `Email Builder.txt`, `regular learning from senior dev.txt` |

---

## 3. `archive/` & Testing

- `archive/originals/` — All 15 original `.txt` prompt files preserved verbatim
- `archive/claude-prompt-old-29-11-24.txt` — Finished one-off Git & GitHub YouTube video script (Nov 2024)
- `archive/data-2025-02-06-21-54-43.zip` — Raw account export (`users.json`) — **keep strictly private**

**Run the self-cleaning 10-suite test harness:**

```bash
bash tests/test_installer.sh
```
