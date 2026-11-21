import Foundation

// MARK: - Fermionic operator helpers

/// Attempts to apply a fermionic creation operator to a given occupation state.
/// - Parameters:
///   - state: Current occupation bitmask.
///   - orbital: Orbital index to create.
/// - Returns: Tuple of new state and sign (+1 or -1) if creation is possible; otherwise nil.
func applyCreation(state: UInt64, orbital: Int) -> (UInt64, Int)? {
    let mask = UInt64(1) << orbital
    if state & mask != 0 { return nil } // already occupied
    let newState = state | mask
    let parity = (state & (mask - 1)).nonzeroBitCount
    let sign = parity % 2 == 0 ? 1 : -1
    return (newState, sign)
}

/// Attempts to apply a fermionic annihilation operator to a given occupation state.
/// - Parameters:
///   - state: Current occupation bitmask.
///   - orbital: Orbital index to annihilate.
/// - Returns: Tuple of new state and sign (+1 or -1) if annihilation is possible; otherwise nil.
func applyAnnihilation(state: UInt64, orbital: Int) -> (UInt64, Int)? {
    let mask = UInt64(1) << orbital
    if state & mask == 0 { return nil } // not occupied
    let newState = state & ~mask
    let parity = (state & (mask - 1)).nonzeroBitCount
    let sign = parity % 2 == 0 ? 1 : -1
    return (newState, sign)
}

/// Generates all occupation bitmasks with a fixed number of electrons.
/// - Parameters:
///   - numOrbitals: Total number of orbitals.
///   - numElectrons: Number of electrons.
/// - Returns: Array of occupation states.
func basisStates(numOrbitals: Int, numElectrons: Int) -> [UInt64] {
    var states: [UInt64] = []
    func generate(_ index: Int, _ remaining: Int, _ current: UInt64) {
        if remaining == 0 {
            states.append(current)
            return
        }
        if index >= numOrbitals { return }
        // Occupy this orbital
        generate(index + 1, remaining - 1, current | (UInt64(1) << index))
        // Leave it empty
        generate(index + 1, remaining, current)
    }
    generate(0, numElectrons, 0)
    return states
}

// MARK: - Symmetric matrix and Jacobi eigenvalue solver

/// Represents a real symmetric matrix.
struct SymmetricMatrix {
    let size: Int
}
