# ADR-06 (Revised): Practical Qubes-Inspired Isolation Stack

## Status
Accepted

## Context
Full Xen-based Qubes OS replication is out of scope for the current project timeline. We need a realistic, achievable multi-domain isolation model using Linux/KVM.

## Decision
We will implement a Qubes-inspired stack using the following technologies:
- **Host**: Hardened Linux kernel (lockdown mode, minimal modules, mandatory IOMMU/VT-d).
- **Per-qube VM**: `cloud-hypervisor` or `crosvm` (Rust-based, minimal VMM) as primary; QEMU as fallback.
- **NetVM**: Dedicated microVM owning the physical NIC (VFIO passthrough if possible, else virtio-net) running `nftables`.
- **Disposable VM**: Ephemeral microVM with read-only golden image (erofs/qcow2) + tmpfs-overlay, utilizing snapshot/restore for fast boot.
- **GUI Isolation**: Wayland compositor inside VM + `waypipe` over virtio-vsock to host compositor (with domain-colored window borders).
- **Inter-qube Transfer**: Trusted broker service for explicit, logged copy/paste and file transfers.

## Consequences
- **Pros**: Achievable without Xen, lower overhead than full QEMU, strong isolation for untrusted tasks.
- **Cons**: Shared host kernel remains a single point of failure for 0-day exploits (mitigated by hardening, not eliminated). Must be documented as "Qubes-inspired", not "Qubes-level security".