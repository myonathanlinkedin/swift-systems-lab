# Refinement E-Graphs (Swift)

> Production-ready implementation of the **Refinement E-Graphs** algorithm in **Swift**, adhering to idiomatic design patterns, cache-friendly data layouts, and comprehensive test assertions.

## Overview & Mechanics

The implementation focuses on the core mathematical properties of **Refinement E-Graphs**:
* **Data Organization**: Built upon `Adjacency List & Priority Heap` to ensure predictable traversal and storage overhead.
* **Safety Invariants**: Memory allocations are kept minimal to avoid allocator contention and preserve CPU cache locality.
* **Execution Guarantees**: Designed with reentrancy and thread isolation in mind, preventing data races under parallel workloads.

## Complexity Profile

* **Time Complexity**:
  * Fast Path (Best): `$O(V + E)$`
  * Generalized (Avg / Worst): `$O((V + E) \log V)$`
* **Space Footprint**: `$O(V + E)$` resident heap / stack overhead.

## Verification & Test Scenarios

The test suite in `core.swift` validates:
* Standard operational paths against expected outcomes.
* Extreme values and edge inputs to ensure robust failure handling.
* State stability across sequential and repeated operations.

```bash
# Execute local verification runner
swift core.swift
```

---

*Source code released under the MIT License • [@myonathanlinkedin](https://github.com/myonathanlinkedin)*