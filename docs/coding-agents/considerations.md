# Coding Agent Considerations

This document outlines initial guidance for using AI coding agents — including **GitHub Copilot** and **Google Gemini Code Assist** — within TCS Cloud Foundations engineering workflows.

---

## Purpose

AI coding agents can accelerate Terraform authoring, policy-as-code generation, and documentation. Adopting them without guardrails introduces risks around secret leakage, license contamination, and drift from TCS-approved patterns. This document records the decisions and constraints that apply before agent-assisted code reaches this repository.

---

## Approved Tools

| Tool | Vendor | Approved use cases |
|------|--------|--------------------|
| GitHub Copilot (Chat + completions) | Microsoft / GitHub | Terraform module scaffolding, inline completions, unit-test generation |
| Gemini Code Assist | Google | Code review suggestions, docstring / README generation, refactoring assistance |

Other AI tools require explicit approval from the platform team before use in this repository.

---

## General Principles

1. **Human review is mandatory.** Every AI-generated change must be reviewed and understood by the engineer before it is committed. Copilot and Gemini suggestions are a starting point, not a final answer.
2. **No secrets in prompts.** Do not paste AWS account IDs, access keys, ARNs that identify production accounts, or any credential material into a chat or inline prompt. Use placeholders (`<ACCOUNT_ID>`) instead.
3. **Validate against TCS patterns.** Generated Terraform must pass the guardrail checklist (issue #2) and conform to the module interfaces in `modules/`. Agents are unaware of internal conventions; engineers must reconcile the gap.
4. **Licence awareness.** Treat agent-generated code with the same scrutiny as third-party code. If a suggestion is a verbatim copy of a known library, confirm the license is compatible with the repository's license before committing.
5. **Reproducibility.** Commit messages must describe the intent of the change. If an agent wrote a substantial portion of the diff, note it (e.g., `co-authored-by: GitHub Copilot`). This preserves the audit trail and helps future reviewers understand provenance.

---

## GitHub Copilot — Specific Guidance

### Configuration

- Enable Copilot only through the organization-managed GitHub license; do not use personal free-tier accounts on TCS work items.
- In VS Code / JetBrains, set `editor.inlineSuggest.enabled = true` and review each suggestion before accepting.
- Use **Copilot Chat** (`/explain`, `/fix`, `/tests`) to interrogate unfamiliar resources before copying suggestions.

### Copilot Agent Mode (Copilot Coding Agent)

- Copilot Coding Agent (agentic / background tasks) is approved for prototyping and draft PRs only.
- All PRs opened by the agent must be reviewed by a human before merge — auto-merge is disabled on this repository.
- Provide a precise, scoped `copilot-instructions.md` (or `.github/copilot-instructions.md`) to constrain the agent to TCS module patterns and naming conventions. A starter file is tracked under `.github/copilot-instructions.md`.
- Do not grant the agent write access to protected branches (`main`, `release/*`).

### What Copilot Does Well Here

- Generating `variable` and `output` blocks for new Terraform modules.
- Drafting `README.md` sections from existing code.
- Writing `terraform test` (`.tftest.hcl`) stubs for module unit tests.

### Watch-outs

- Copilot may suggest deprecated provider argument names — always cross-reference with the AWS provider changelog.
- Copilot does not know your Terraform Cloud workspace names, remote state paths, or TFE variable sets. Fill these in manually.

---

## Gemini Code Assist — Specific Guidance

### Configuration

- Use the Google Cloud-managed Gemini Code Assist extension through the organization's GCP project; do not authenticate with personal Google accounts.
- Ensure the Gemini Code Assist IDE plugin is pinned to an approved version listed in the platform wiki.

### Recommended Use Cases

- **Code review in GitHub PR:** Gemini can be enabled as a PR reviewer bot. Its comments appear alongside human reviewer comments and must be treated as suggestions, not approvals.
- **Documentation generation:** `/doc` commands generate docstrings and README prose that teams can refine.
- **Refactoring:** `@gemini /refactor` is useful for extracting repeated resource blocks into reusable modules.

### Watch-outs

- Gemini's Terraform knowledge lags slightly behind HCL syntax changes; verify `moved` blocks and `check` assertions against official docs.
- Gemini PR review comments count toward the PR review thread but do **not** satisfy branch protection rules requiring human approvals.

---

## Data-Handling Constraints

Both tools send prompt context to external APIs. Apply the following constraints:

| Data type | Allowed in prompt? | Mitigation if needed |
|-----------|-------------------|----------------------|
| Public architecture diagrams | ✅ Yes | — |
| Terraform variable names / resource types | ✅ Yes | — |
| AWS account IDs | ❌ No | Use `<ACCOUNT_ID>` placeholder |
| IAM role ARNs with account IDs | ❌ No | Redact account segment |
| S3 bucket names containing client identifiers | ❌ No | Use generic names in prompts |
| Access keys / secrets | ❌ Never | Remove entirely before prompting |
| Client-confidential architecture | ❌ No | Use an air-gapped local model or consult the security team |

---

## Workflow Integration

```
Engineer writes intent / ticket
        │
        ▼
Agent drafts Terraform / docs
        │
        ▼
Engineer reviews, edits, validates
  - terraform validate
  - terraform plan (non-prod)
  - guardrail checklist (issue #2)
        │
        ▼
PR opened (agent noted in commit if applicable)
        │
        ▼
Human peer review + automated checks
        │
        ▼
Merge to main
```

---

## Open Questions / Next Steps

- [ ] Decide whether to enable Copilot Coding Agent on protected branches after a 30-day trial period.
- [ ] Evaluate Gemini Code Assist PR review bot — pilot on one active module PR.
- [ ] Document approved local/self-hosted model options for air-gapped client engagements.
- [ ] Add agent-awareness note to the contributor guide (`CONTRIBUTING.md`) once it is created.
- [ ] Review and update this document after the first quarterly retrospective.
