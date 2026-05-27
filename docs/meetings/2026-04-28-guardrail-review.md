# Cloud Foundations Guardrail Review
**Date:** 2026-04-28
**Attendees:** Arjun Mehta, Hamza Mohammed, Saraj Krishna Singh, Winkletinkle

## Agenda
1. Review VPC module (merged)
2. Review IAM baseline module (in review)
3. Guardrail checklist sign-off
4. Crossplane design review

## Discussion

### VPC Module
Merged. Follow-up: IAM role naming for flow logs needs to include vpc_name to prevent collision when module is used multiple times per account. Tracking in issue.

### IAM Baseline
In PR review. BreakGlass CloudWatch alarm feature requested - added as optional submodule. OIDC subject scoping note added to README.

### Guardrail Checklist
Decision: PR template for manual checks + `checkov` in GitHub Actions for automatable checks. Arjun to wire up workflow by May 2.

### Crossplane Design
Saraj's XRD schema for PostgresDatabase reviewed. Approved with changes:
- Add `engineVersion` parameter (default "15.4")
- Default `deletionPolicy` to `Orphan`
- Namespace-label patch for multiAZ production override
- Subnet group naming must include namespace + claim name to prevent collisions

## Decisions
1. Guardrail checklist: PR template + checkov CI (Arjun owns)
2. PostgresDatabase XRD schema approved with noted changes
3. Crossplane provider: crossplane-contrib/provider-aws for now, Upbound official revisit in 6 months

## Action Items
| Owner | Action | Due |
|-------|--------|-----|
| Arjun | Add checkov GitHub Actions workflow | 2026-05-02 |
| Hamza | Write Crossplane XRD YAML for PostgresDatabase | 2026-05-05 |
| Saraj | Write Crossplane composition | 2026-05-09 |
| Winkletinkle | Draft contributing guide and versioning docs | 2026-05-05 |
| Hamza | Write ADR for Crossplane provider decision | 2026-05-03 |
