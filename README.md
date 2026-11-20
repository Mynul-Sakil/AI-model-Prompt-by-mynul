# AI Prompts & Extracted Skills (Public + Private Organization)

All 17 original prompt files from this folder have been extracted into clean `SKILL.md` skills and organized into three directories with zero data loss:

## 1. `public/` — Generalized, PII-Free Skills (Published to `.agents/skills/`)

These 5 skills are stripped of personal details and synced into the public `antigravity-skills` repository:

| Skill | Purpose | Original Source(s) |
| :--- | :--- | :--- |
| `public/book-mentor/` | Chapter-by-chapter interactive book tutor | `BookGPT.txt` |
| `public/dse-stock-analyst/` | Dhaka Stock Exchange (DSE) analyst, recaps & Bangla educational scripts | `Financial Analysis Name Tareq.txt`, `Stock Market Information Analysis.txt`, `stockgpt-youtube-helper.txt` |
| `public/mock-tech-interview/` | Candidate-side technical/HR mock interviewer & daily micro-learning coach | `Interview Preparation.txt`, `regular learning from senior dev.txt` |
| `public/job-application-email/` | Tech job-application email builder + remote company Boolean search | `Email Builder.txt`, `Job search Company Name Search Prompt.txt` |
| `public/coding-prompt-spec/` | Pre-code specification gate (Goal, Rules, Examples, Edge Cases, Mistake Check) | `AI_PROMPT_RULE_FOR_CODDING.txt` |

## 2. `private/` — Personal Skills (Strictly Local — Never Push to Public GitHub)

These 5 skills preserve your personal identity, channel (*DemotivateProgrammer*), schedule, projects, and personas:

| Skill | Purpose | Original Source(s) |
| :--- | :--- | :--- |
| `private/demotivateprogrammer-youtube/` | YouTube channel profile, 6-min structure, title formulas & Tamanna editing notes | `youtube helper.txt`, `Youtube future video Idea.txt` |
| `private/my-personal-secretary/` | Sakil's schedule-aware personal secretary & 3-day interview rotation | `Personal assistences command And My status track.txt` |
| `private/my-linkedin-and-career-coach/` | Personal MERN/Next.js LinkedIn strategist & career advisor | `Linkedin Post Idea Genarator.txt`, `Linkedin helper.txt`, `personal assistence.txt` |
| `private/my-dse-stockgpt-bangla/` | Personal Tareq / StockGPT DSE Bangla YouTube co-creator preset | `Financial Analysis Name Tareq.txt`, `Stock Market Information Analysis.txt`, `stockgpt-youtube-helper.txt` |
| `private/my-job-hunt-profile/` | Personal Nayeem mock interviewer + MERN job-application preset | `Interview Preparation.txt`, `Email Builder.txt`, `regular learning from senior dev.txt` |

> To use any private skill globally in Antigravity on your Mac without pushing it to GitHub, copy its folder into `~/.gemini/config/skills/` (or `~/.claude/skills/` / `~/.copilot/skills/`).

## 3. `archive/` — Untouched Original Files

- `archive/originals/` — All 15 original `.txt` prompt files preserved verbatim
- `archive/claude-prompt-old-29-11-24.txt` — Finished one-off Git & GitHub YouTube video script (Nov 2024)
- `archive/data-2025-02-06-21-54-43.zip` — Raw account export (`users.json`) — **keep strictly private**
