import Foundation

/// Represents the state of a memory block in the buddy system.
enum BlockState: Equatable {
    case free
    case allocated
}

/// A single memory block in the buddy allocation system.
struct MemoryBlock: Equatable {
    /// The starting address of this block.
    let address: Int
    /// The size of this block (must be a power of 2).
    let size: Int
    /// The current state of the block.
    var state: BlockState
    /// The index of the buddy block (the other half of the parent block).
    var buddyIndex: Int?
    /// The index of the parent block (if this block was created by splitting).
    var parentIndex: Int?
    
    init(address: Int, size: Int, state: BlockState = .free, buddyIndex: Int? = nil, parentIndex: Int? = nil) {
        self.address = address
        self.size = size
        self.state = state
        self.buddyIndex = buddyIndex
        self.parentIndex = parentIndex
    }
    
    /// Returns the end address of this block (exclusive).
    var endAddress: Int {
        return address + size
    }
    
    /// Returns the buddy address for this block.
    var buddyAddress: Int {
        if address % (size * 2) == 0 {
            return address + size
        } else {
            return address - size
        }
    }
    
    /// Returns the parent address for this block.
    var parentAddress: Int {
        if address % (size * 2) == 0 {
            return address
        } else {
            return address - size
        }
    }
}

/// Represents a request for memory allocation.
struct AllocationRequest: Equatable {
    let size: Int
    let id: Int
}

/// Represents a successful allocation result.
struct AllocationResult: Equatable {
    let blockIndex: Int
    let address: Int
    let size: Int
    let requestId: Int
}

/// Represents a deallocation request.
struct DeallocationRequest: Equatable {
    let blockIndex: Int
    let requestId: Int
}

/// Statistics about the memory allocator.
struct AllocatorStats: Equatable {
    var totalAllocations: Int = 0
    var totalDeallocations: Int = 0
    var totalSplits: Int = 0
    var totalMerges: Int = 0
    var currentFreeBlocks: Int = 0
    var currentAllocatedBlocks: Int = 0
    var totalWastedBytes: Int = 0
    var peakAllocatedBytes: Int = 0
    var currentAllocatedBytes: Int = 0
}
