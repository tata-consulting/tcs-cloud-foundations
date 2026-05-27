# Cloud foundation working session - 2026-05-27

## Purpose

Seed the repository with a minimal AWS landing zone starter and the guardrail discussion needed for follow-on work.

## Decisions

- Use a small Terraform example as the initial artifact so the repo contains executable infrastructure content from day one.
- Start with centralized logging because it is a common control point across consulting engagements.
- Track the broader guardrail checklist in issue #2 rather than overloading the first commit.

## Action items

- Expand the landing zone example with encryption, lifecycle, and access controls.
- Add networking and identity modules after the guardrail checklist is documented.
- Publish provider-agnostic guidance alongside cloud-specific implementations.
