# Truly Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs (Swift)

> High-performance **Truly Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs** primitive implemented in idiomatic **Swift**. Built from scratch using standard library constructs with zero external dependencies.

## Overview & Mechanics

The implementation focuses on the core mathematical properties of **Truly Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs**:
* **Data Organization**: Built upon `Adjacency List & Priority Heap` to ensure predictable traversal and storage overhead.
* **Safety Invariants**: Contiguous memory layouts are favored over scattered heap allocations for optimal traversal speed.
* **Execution Guarantees**: Deterministic behavior across all execution cycles, resilient against asynchronous edge conditions.

## Complexity Profile

* **Time Complexity**:
  * Fast Path (Best): `$O(V + E)$`
  * Generalized (Avg / Worst): `$O((V + E) \log V)$`
* **Space Footprint**: `$O(V + E)$` resident heap / stack overhead.

## Verification & Test Scenarios

The test suite in `main.swift` validates:
* Standard operational paths against expected outcomes.
* Extreme values and edge inputs to ensure robust failure handling.
* State stability across sequential and repeated operations.

```bash
# Execute local verification runner
swift main.swift
```

---

*Source code released under the MIT License • [@myonathanlinkedin](https://github.com/myonathanlinkedin)*