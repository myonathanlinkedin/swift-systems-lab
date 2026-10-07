# Tarjan Strongly Connected Components Search in Directed Graphs in Swift

Core **Swift** implementation for **Tarjan Strongly Connected Components Search in Directed Graphs**, structured for computational clarity, explicit data structures, and deterministic unit test coverage.

## Implementation Details

* **Category**: `Graph Topology & Traversal`
* **Data Structure Foundation**: `Adjacency List & Priority Heap`
* **Allocation Pattern**: Buffer boundaries and collection indices are explicitly validated to prevent out-of-bounds access.
* **Invariant Integrity**: State consistency is verified after mutations through assertion test coverage.

## Performance Characteristics

* **Time**: `O((V + E) log V)` average, with `O(V + E)` best-case response under ideal conditions.
* **Space**: `O(V + E)` memory usage.

## Test Harness

To compile and execute the test assertions for this module:

```bash
swift main.swift
```

---

*Part of the Polyglot Systems Lab • Maintained by [@myonathanlinkedin](https://github.com/myonathanlinkedin)*