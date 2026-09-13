# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0-pre-alpha] - 2026-09-14
### Added
- Aligned repository structure with CH4rch Linux Architectural Plan v3.0.
- Separated AI Supervision Platform (infrastructure) from autonomous agent roles (Research tier).
- Defined practical Qubes-inspired isolation stack (microVM, NetVM, Disposable VM, Wayland+waypipe).
- Introduced Agent Profile (YAML) and one-click state-machine for agent provisioning.
- Established strict "secure by default, powerful on demand" dogma for AI and isolation features.
- Added ADR directory structure for granular architectural decision tracking.

### Changed
- Downgraded risk assessment for Phases 1-2 (Toolchain, Minimal Bootable Core) due to proven local QEMU prototype history.
- Replaced abstract Xen-based isolation concepts with concrete, achievable KVM/microVM stack (ADR-06 revised).

### Security
- Explicitly documented real-root risks and mandatory TTL/confirmation requirements for AI agent escalation.
- Mandated external artifact backup policy to prevent hardware-loss-related progress destruction.