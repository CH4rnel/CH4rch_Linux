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
## [3.0.0-pre-alpha] - 2026-09-15
### Added
- **CORE TIER COMPLETE**: All 8 foundation phases implemented and tested
- Process isolation via bubblewrap (Phase 7)
- CI/CD pipeline with full test suite execution (Phase 8)
- ISO generation with GRUB bootloader configuration
- 10 automated tests covering all core components

### Changed
- GitHub Actions now runs complete test suite on every push
- Build pipeline includes declarative configuration application
- Snapshot management integrated into build process

### Security
- Hash-chain audit logging for all critical operations
- Strict package signature verification (SigLevel = Required)
- Process isolation sandbox for untrusted workloads
