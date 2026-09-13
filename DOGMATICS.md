# CH4rch Linux Dogmatics

## 1. Core Engineering Principles
- **KISS / YAGNI / DRY / SOLID**: Applied rigorously across all system components.
- **TDD & XP**: Test-Driven Development and Extreme Programming practices are mandatory. Red → Green → Refactor.
- **Reproducibility**: Every build must be deterministic. If an artifact cannot be rebuilt from the repository in 10 minutes, it must be backed up externally (S3/NAS).

## 2. Security & Isolation Dogma
- **Secure by Default, Powerful on Demand**: Any dangerous capability (real-root access, auto-remediation, full network scanning) is **disabled by default**. 
- Enabling such features requires explicit, unambiguous operator action and leaves an immutable trace in the hash-chain audit log.
- Process isolation (Core) and VM-based isolation (Extended/Research) are strictly separated. 

## 3. AI Supervision Platform Dogma
- The platform is agent-agnostic. GLaDOS_DAEMON-SYSTEM is the reference implementation, but the API must remain open for extension, closed for modification (Open/Closed Principle).
- Autonomous decision-making (Security/Package Auditor) is strictly gated behind independent security reviews and agent maturity (Research tier). Until then, only Advisor mode (human-initiated) is permitted.

## 4. Configuration & State
- Declarative configuration layer sits strictly *above* pacman.
- Rollbacks are handled exclusively via Btrfs snapshots, not secondary package stores.