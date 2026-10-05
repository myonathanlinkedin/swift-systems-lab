# Garnet - Garnet is a remote cache-store from Microsoft Research that offers strong

A clean, dependency-free **Swift** implementation of **Garnet - Garnet is a remote cache-store from Microsoft Research that offers strong**, focused on predictable latency, strict memory layout, and deterministic execution.

### Core Highlights
* **Language & Standard**: Modern `Swift` standard library conventions.
* **Architecture Pattern**: Designed for `Algorithmic Engineering` using `Standard Memory Primitives`.
* **Runtime Overhead**: Memory allocations are kept minimal to avoid allocator contention and preserve CPU cache locality.
* **Concurrency & Safety**: Designed with reentrancy and thread isolation in mind, preventing data races under parallel workloads.

---

### Complexity Analysis

| Dimension | Bound |
| :--- | :--- |
| **Time (Best Case)** | `$O(1)$` |
| **Time (Worst Case)** | `$O(N \log N)$` |
| **Auxiliary Space** | `$O(N)$` |

---

### Test Suite Execution

Self-contained verification drivers are embedded directly in `main.swift` to validate happy paths, boundary inputs, and invariant preservation.

```bash
swift main.swift
```

---

<sub>Crafted with modern Swift standards • Maintained by [@myonathanlinkedin](https://github.com/myonathanlinkedin)</sub>