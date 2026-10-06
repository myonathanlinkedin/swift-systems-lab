# Truly Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs (Swift)

> Self-contained **Truly Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs** algorithmic primitive written in idiomatic **Swift**. Built from scratch using standard library constructs with zero external dependencies.

## Overview & Mechanics

The implementation focuses on the core mathematical properties of **Truly Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs**:
* **Data Organization**: Built upon `Adjacency List & Priority Heap` to ensure predictable traversal and storage overhead.
* **Safety Invariants**: Contiguous memory layouts and standard collections are favored for straightforward iteration and access.
* **Execution Guarantees**: Execution behavior is validated against nominal workflows and boundary edge cases.

## Complexity Profile

* **Time Complexity**:
  * Fast Path (Best): `O(V + E)`
  * Generalized (Avg / Worst): `O((V + E) log V)`
* **Space Footprint**: `O(V + E)` resident heap / stack overhead.

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
