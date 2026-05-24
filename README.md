
# CCMS — Cloud Customer Management Solution

**CCMS (Cloud Customer Management Solution)** is an open-source Business Central app designed to revolutionize how partners manage and support their customers. Built collaboratively by a consortium of Microsoft Dynamics 365 Business Central partners, CCMS provides a secure, modular, and automated way to handle the entire lifecycle of customer environments — dramatically reducing the need for direct access and manual intervention.

## ⚙️ Installation

Download the latest release of CCMS here: https://github.com/directions4partners/CCMS/releases and unpack the .zip file.

In Business Central, open Extension Management.

Choose Upload Extension from the action bar.

Select your .app file

Review the version and dependencies, then click Deploy.

Wait for the installation to complete — the extension will appear in the list once deployed.
 
## 🔗 Setup BC AdminCenter API Connection App Registration

For connecting CCMS to the AdminCenter APIs of your customers, there are two ways:

### Explicit App registration

For environments in your own tenants, without GDAP access or if you prefer, you can set up explicit App Registrations in each of the tenants.

See the [Microsoft Learn documentation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/administration-center-api#authenticate-using-service-to-service-microsoft-entra-apps-client-credentials-flow)

### Shared App registration

If you have set up GDAP you can just set up a central App Registration in your own tenant and each customer just has to grant access via "Authorized Microsoft Entra Apps".

see the How To from the BCTech Repo
[BC TEch AdminCenter API Authentication](https://github.com/microsoft/BCTech/blob/master/samples/AdminCenterApi/Authentication.md)

## ⚙ Set Up D365BC Entra Tenants

In the CCMS Page "D365BC Entra Tenants" set up an entry for each tenant and enter Tenant ID, App Registration Client ID and Client Secret in the appropriate fields.
 
## 📌 Project Vision

In a cloud-first world, partners should not need to log into customer environments for everyday maintenance tasks.  
**CCMS aims to make that a reality.**

By centralizing critical management functions into a single, extensible Business Central app, CCMS empowers partners to deliver more secure, scalable, and consistent service while maintaining strong customer trust and compliance.

## 🧭 Design Principles

CCMS is built on a set of guiding principles derived from the partner community:

- 🧩 **Modular by design** — Each capability is implemented as a standalone building block. Partners can adopt the entire system or only the parts they need.
- ☁️ **Cloud-native and future-proof** — CCMS focuses exclusively on cloud deployments and will not support on-premises scenarios.
- 🔐 **Security-first** — All features must follow secure-by-default principles, including proper logging, monitoring, and permission models.
- 📊 **Actionable insight, not data hoarding** — We collect and store only what’s necessary to operate and improve customer environments.
- 🤝 **Partner-centric** — The solution is built for and with partners, enabling them to manage customers as they grow — and manage themselves like customers, too.
- 🪶 **Simplicity over complexity** — Every feature should add clear value. Over-complication is considered a bug.

## 🚀 Key Objectives

- 🔧 **Minimize direct access** — Enable partners to manage customers without logging into production environments except in rare, exceptional circumstances.
- 🛠️ **Automate routine tasks** — Streamline provisioning, configuration, updates, license tracking, test environments, and lifecycle operations.
- 🔐 **Improve security and compliance** — Reduce the operational and regulatory risks of environment access.
- 🤝 **Enable collaboration** — Provide a common, open foundation built by and for the partner ecosystem.
- 📈 **Scalable and extensible** — Designed to integrate with partner processes, third-party solutions, and Microsoft APIs.

## 🧭 Core Features (Planned)

While CCMS is under active development, its roadmap focuses on delivering a comprehensive partner management platform, including:

- **Customer Overview** — A unified view of all customer environments, apps, versions, PTEs, and storage usage.
- **Change History & Audit** — Track what changed, when, and why — including app installs, updates, and configuration modifications.
- **Automated Maintenance Workflows** — Tasks like environment refresh, permission resets, AppSource updates, and PTE lifecycle operations.
- **Monitoring & Health Checks** — Job queue tracking, storage capacity warnings, database growth predictions, and system health dashboards.
- **Test Environment Automation** — Spawn test environments and run customer-recorded test scripts.
- **Partner Self-Service Tools** — Provide partner-centric views, similar to how customers manage their own environments.

> 💡 CCMS is evolving rapidly. See the [project board](https://github.com/directions4partners/ccms/issues) for upcoming features and milestones.

## 🏗️ Architecture Overview

CCMS is implemented as a **Business Central extension (AL)** and is designed to integrate seamlessly with Microsoft’s cloud services. Its modular design enables partners to extend the solution with their own logic, connectors, or business rules.

High-level components include:

- **Core Extension** — The foundation app deployed into partner-managed environments.
- **API Layer** — Integrations with Microsoft Admin APIs, telemetry services, and third-party systems.
- **Workflow Engine** — Extensible automation for maintenance tasks.
- **UI Modules** — Role-based pages and dashboards for partners and service teams.

## 📉 Out of Scope

CCMS deliberately avoids certain areas to stay focused and deliver real value:

- ❌ **On-premises support** — CCMS is a cloud-only solution.
- ❌ **Backend lock-in** — It will not be tied to a specific DevOps or CI/CD platform.
- ❌ **Unnecessary data retention** — We will not collect or store telemetry that doesn’t serve a clear operational purpose.
- ❌ **Over-engineering** — We will prioritize simplicity and usability over excessive configurability.

## 👩‍💻 Contributing

CCMS is a community-driven project. We welcome contributions from all partners, ISVs, and individuals who share our vision.

- Read our [Governance model](./GOVERNANCE.md) to understand how decisions are made.
- Review the [Code of Conduct](./CODEOFCONDUCT.md) — we are committed to a welcoming and inclusive community.
- See [MAINTAINERS.md](./MAINTAINERS.md) to learn how to become a maintainer.

Please open issues or submit pull requests via our GitHub repository:  
👉 [https://github.com/directions4partners/ccms](https://github.com/directions4partners/ccms)

## Contributor License Agreement (CLA)
Before we can accept your pull request, you must sign our Contributor License Agreement (CLA).  
You’ll be prompted to do this automatically when you open your first pull request.

This agreement ensures that you have the right to contribute and that we can distribute your contributions under our open source license.

## 🛠️ Getting Started (Coming Soon)

Installation, configuration, and usage documentation will be published as part of the first public release.  
In the meantime, you can:

- Watch the repository for release announcements
- Join community discussions in the Issues section
- Contribute to the design and feature roadmap

## 📞 Support & Security

- 📬 **Support:** See [SUPPORT.md](./SUPPORT.md) or email [freddy@directions4partners.com](mailto:freddy@directions4partners.com)
- 🔐 **Security:** See [SECURITY.md](./SECURITY.md) for vulnerability disclosure guidelines.

---

### 📜 License

CCMS is open source and released under the [MIT License](./LICENSE).
