# ADR-09: AI Supervision Platform as an Optional Layer

## Status
Accepted

## Context
AI agent integration must be convenient ("one-click") but strictly isolated to minimize the attack surface for users who do not need it.

## Decision
- The AI Supervision Platform is a separate, optional system component (`ch4rch-ai-supervisor`), completely outside PID1 and the base `s6-rc` bundle.
- It is **disabled by default** immediately after system installation.
- The platform is agent-agnostic. It defines a capability-token and Unix-socket API, allowing GLaDOS_DAEMON-SYSTEM or any future agent to connect without modifying the platform core (Open/Closed Principle).
- All agent actions (connection, privilege escalation, high-risk capabilities) are logged to the unified hash-chain audit journal.

## Consequences
- Minimal attack surface for default installations.
- "Star" UX for users who explicitly enable it, with clear, state-machine-driven provisioning and teardown.