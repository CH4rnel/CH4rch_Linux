# CH4rch Linux Roadmap

## TIER: CORE (Foundation)
- [x] Phase 0: Foundation & Repository Hygiene (v3.0 Alignment)
- [ ] Phase 1: Toolchain & Reproducible Build Environment
- [ ] Phase 2: Minimal Bootable Core (Arch + s6-rc restoration)
- [ ] Phase 3: Package Trust MVP (Hash-chain verification)
- [ ] Phase 4: Service Graph Engineering (s6-rc DAG)
- [ ] Phase 5: Rollback Mechanism (Btrfs snapshots integration)
- [x] Phase 6: Declarative Configuration MVP (plan/apply over pacman)
- [ ] Phase 7: Process Isolation MVP (bubblewrap/Podman basics)
- [ ] Phase 8: Release Engineering (CI/CD, ISO generation)

## TIER: EXTENDED
- [ ] Phase 9: PQC Rollout, Stage 2
- [x] Phase 10: Application-level Event Bus (s6-notifications + Unix-socket JSON) (s6-notifications + Unix-socket JSON)
- [x] Phase 11: Knowledge Graph v1 (SQLite-based metadata storage)
- [x] Phase 12: Adaptive System (telemetry + threshold-based reactions)
- [x] Phase 13: AI Supervision Platform Infrastructure (agent profiles, isolation, one-click UX) ✓ Complete (Agent Profiles, isolation backends, one-click UX)
- [ ] Phase 14: Agent Capability Catalog - Read-only (system.audit.read, cache.clean, network.scan.local report-only)

## TIER: RESEARCH
- [x] Phase 15: Qubes-inspired microVM Stack (Disposable VM, NetVM nftables, Wayland+waypipe GUI) ✓ Complete (NetVM, Disposable VM, Wayland+waypipe GUI isolation)
- [x] Phase 16: Agent Capability Catalog - Remediation (vuln.remediate with strict plan/confirm/apply flow) (vuln.remediate, network.scan.wan) *Requires security review*
- [ ] Phase 17: AI Supervisor Autonomous Roles (Security/Package Auditor) *Gated by GLaDOS Phase 7 completion*
- [ ] Phase 18: Predictive Maintenance (Weibull distribution modeling)