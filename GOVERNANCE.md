# CCMS Governance (TSC Model)

CCMS (Cloud Customer Management System) is governed by a **Technical Steering Committee (TSC)** that provides technical leadership, ensures project health, and stewards the community.

**Repository:** https://github.com/directions4partners/ccms

---

## 1) Scope & Principles

- **Open by default:** Design, discussion, issues, and decisions happen publicly unless security-sensitive.
- **Merit & stewardship:** Authority grows with sustained, high-quality contribution and community trust.
- **Neutrality & balance:** Multi-company collaboration is encouraged; no single vendor should dominate.

---

## 2) Transitional Governance (Bootstrap → Maintainer-Elected)

### 2.1 Bootstrap Period (18 months)
- Duration: **18 months**, starting November 1st 2025.
- **TSC Composition (Bootstrap):** One seat per founding organization listed below (7 total). Each organization appoints its representative.
  - Abakion
  - Acadon
  - ArcherPoint
  - Directions for Partners *(permanent seat; appointed by the CEO)*
  - iFacto
  - Innovia
  - Tecman
- **Foundation contributors:** One seat for the contribution of the foundation for CCMS goes to:
  - [Stefano Demiliani](https://github.com/demiliani)
  - [Duilio Tacconi](https://github.com/duiliotacconi)
- **Permanent Seat:** Because CCMS is hosted by **Directions for Partners**, **one (1) permanent TSC seat** is reserved for Directions for Partners and appointed by its CEO. During and after the Bootstrap Period, this seat is part of the overall TSC size described below.

### 2.2 Post-Bootstrap (12 months - Maintainer-Elected TSC)
- After the Bootstrap Period, the TSC transitions to a **maintainer-elected model**.
- **TSC Size:** **7 seats total**, including the **permanent seat for Directions for Partners**.
- **Seat Allocation:**
  - **1 permanent seat**: Directions for Partners (appointed by the CEO of Directions for Partners).
  - **6 elected seats**: Elected by eligible voters as defined in §4.3.
- Terms are **12 months**, renewable.
- Vacancies are filled by a special election for the remainder of the term. The permanent seat is refilled by appointment as needed.

### 2.3 Chair

The TSC shall elect a **Chair** for the full duration of the TSC’s term by **simple majority vote** of its seated members.  
The Chair is responsible for:
- Setting meeting agendas and facilitating TSC discussions  
- Ensuring decisions are documented and communicated  
- Acting as the primary liaison for the project to external communities, organizations, or foundations  

The Chair remains a voting TSC member and may be re-elected for subsequent terms.
---

## 3) Decision-Making

### 3.1 Lazy Consensus
Routine decisions (issue triage, standard PRs, minor features) follow **lazy consensus**. If no explicit objection is raised by a maintainer within **5 business days**, the proposal may proceed.

### 3.2 TSC Votes
Major decisions require a TSC vote. **Quorum:** ≥ 2/3 of seated TSC members. **Passing threshold:** simple majority of those present unless otherwise noted.

Examples:
- Material architectural changes, deprecations, or API breaks
- Creation/retirement of subprojects or repos
- Changes to release or security policy
- Amendments to this governance

### 3.3 Conflict Resolution
- Disagreements should be resolved in public discussion (issues/PRs, design docs).
- If unresolved, escalate to maintainers; if still unresolved, the **TSC decision is final**.

---

## 4) Community Structure

### 4.1 Contributors
Anyone who contributes (code, docs, reviews, design, tests, triage) is a **contributor**. All contributors must follow the Code Of Conduct defined here: [`CODEOFCONDUCT.md`](CODEOFCONDUCT.md).

### 4.2 Maintainers
Maintainers have merge/review privileges in one or more areas. New maintainers are nominated by an existing maintainer and confirmed by a simple majority vote of the TSC. Inactive maintainers (no meaningful activity for 6+ months) may be moved to **Emeritus** status by TSC vote.

### 4.3 Voters for TSC Elections (Post-Bootstrap)
- **Who can vote:**  
  - **Maintainers** with **significant contributions** (see §5).  
  - **Current TSC members**.
- **Who can run (elected seats):** Any maintainer with significant contributions can run or appoint a runner
- **In case of doubt** about whether contributions are *significant*, the **current TSC decides by simple majority**.

**Election Method:** Ranked-choice or simple majority (defined ahead of each election and recorded in the election notice). Ties are broken by a runoff between tied candidates.

---

## 5) “Significant Contributions”

“Significant contributions” are intentionally **definition-by-examples** to avoid gaming and to include non-code work. Indicative examples include (non-exhaustive):

- Consistent code contributions and reviews over multiple releases
- Design proposals/RFCs authored and followed through
- Meaningful documentation, testing, release engineering, or CI work
- Sustained issue triage or community support
- Operating project infrastructure or release management

If eligibility is unclear, **the current TSC votes by simple majority** (see §4.3).

---

## 6) Meetings & Transparency

- The TSC meets at least **monthly** via public video call; agenda and notes are published.
- Security or personnel topics may be handled in private.
- All binding decisions are captured in **Decision Records** (e.g., ADRs) linked from issues/PRs.

---

## 7) Security & Responsible Disclosure

Security reports follow the process in [`SECURITY.md`](SECURITY.md). Do not open public issues for sensitive vulnerabilities.

---

## 8) Amendments

This document may be amended by a **2/3 majority vote** of the seated TSC.

---

## 9) Supporting Docs

- [`CODEOFCONDUCT.md`](CODEOFCONDUCT.md) — Contributor Covenant Code of Conduct
- [`MAINTAINERS.md`](MAINTAINERS.md) — maintainer roles, responsibilities, nomination/removal
- [`SECURITY.md`](SECURITY.md) — vulnerability reporting and disclosure
- [`SUPPORT.md`](SUPPORT.md) — where and how to get help
- [`LICENSE`](LICENSE) — license terms (MIT)
