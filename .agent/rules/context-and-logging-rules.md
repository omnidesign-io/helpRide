---
trigger: always_on
---

# Context and logging rules for this workspace

You are working in a multi-account, multi-agent setup. Different human users and different Google accounts may open this same workspace.

Your job is not only to complete tasks, but to **write down what you learn** into the repository so that other agents and accounts can pick up where you left off.

Always apply these rules:

1. Boot sequence
   - Before doing any work:
     - Read `/docs/PROJECT_BRIEF.md` to understand goals and non-negotiables.
     - Read `/docs/ARCHITECTURE_OVERVIEW.md` to understand current system structure.
     - Skim the last 30 lines of `/docs/AGENT_CHANGELOG.md` if it exists.

2. When you change behaviour, architecture or UX
   - For any change that affects APIs, data models, navigation, or core user journeys:
     - Update `/docs/ARCHITECTURE_OVERVIEW.md` so it stays accurate.
     - Append a short entry to `/docs/DECISION_LOG.md` with:
       - Date and time (UTC)
       - What you changed
       - Why you changed it
       - Any tradeoffs or open questions

3. Session log
   - At the end of a substantial task or workflow:
     - Append a short Markdown section to `/docs/AGENT_CHANGELOG.md`:
       - `## <YYYY-MM-DD> - <short title>`
       - “Context I used”
       - “What I did”
       - “Important follow-ups”
   - Keep each entry concise (5 - 15 lines) and scannable.

4. Respect existing docs
   - Never delete context docs. Instead:
     - Mark outdated sections with “Deprecated” and explain what replaced them.
   - If you find contradictions between code and docs:
     - Fix the code first if the docs reflect the intended behaviour.
     - Otherwise, update the docs and clearly explain the new source of truth in the decision log.

5. Use Artifacts to feed the docs
   - When you create Artifacts like plans or walkthroughs:
     - Summarise only the *useful* parts into `/docs/ARCHITECTURE_OVERVIEW.md` or `/docs/DECISION_LOG.md`.
     - Do not copy large raw logs into the repo.

6. Multi-agent hygiene
   - Assume another agent will continue the work without talking to you.
   - Before finishing a task:
     - Make sure the code builds/tests.
     - Make sure docs and logs reflect any important changes you made.
