# Cloud Foundations Kickoff Meeting
**Date:** 2026-04-14
**Attendees:** Arjun Mehta (platform lead), Hamza Mohammed (cloud foundations), Saraj Krishna Singh (platform engineer), Winkletinkle (developer)

## Agenda
1. Scope and goals for cloud foundations initiative
2. Technology decisions
3. Timeline and milestones

## Discussion

### Scope
Cloud foundations initiative delivers a repeatable, automated AWS account baseline: VPC module, IAM baseline, security baseline (CloudTrail, GuardDuty, Config), and Crossplane compositions for workload resources.

### Technology Decisions
- IaC: Terraform for account-level infrastructure (VPC, IAM, DNS). Crossplane for workload resources. Rationale: Terraform handles complex dependency graphs better at account level; Crossplane reconciliation loop adds value for workload resources that drift.
- State: Terraform Cloud (Arjun to provision workspaces)
- Module registry: GitHub-based, versioned via semver tags

### Timeline
- Week 1: VPC module design and first PR
- Week 2: IAM baseline module
- Week 3: Security baseline + Crossplane XRD design

## Decisions
1. Terraform for account-level foundations, Crossplane for workload resources
2. Module versioning via Git tags (semver), CHANGELOG per module
3. First deliverable: VPC module (April 22)
4. Second deliverable: IAM baseline (April 29)

## Action Items
| Owner | Action | Due |
|-------|--------|-----|
| Hamza | Draft VPC module | 2026-04-16 |
| Hamza | Research AWS Control Tower AFT customizations | 2026-04-21 |
| Arjun | Provision Terraform Cloud workspaces | 2026-04-16 |
| Saraj | Document TCS required tags | 2026-04-15 |
| Winkletinkle | Set up GitHub Actions CI template | 2026-04-18 |
