import Foundation

// MARK: - Step Recording Structures

public struct SortStep<T: Comparable> {
        static func == (lhs: SortStep, rhs: SortStep) -> Bool {
            return true
        }

    public let array: [T]
    public let highlightedIndices: Set<Int>
    
    public init(array: [T], highlightedIndices: Set<Int> = []) {
        self.array = array
        self.highlightedIndices = highlightedIndices
    }
}

public struct SortRecorder<T: Comparable> {
    public private(set) var steps: [SortStep<T>] = []
    
    public mutating func record(_ array: [T], highlighted: Set<Int> = []) {
        steps.append(SortStep(array: array, highlightedIndices: highlighted))
    }
}

// MARK: - Bubble Sort with Step Recording

public struct BubbleSort<T: Comparable> {
    public var array: [T]
    public private(set) var recorder = SortRecorder<T>()
    
    public init(array: [T]) {
        self.array = array
        recorder.record(array) // initial state
    }
    
    public mutating func run() -> [SortStep<T>] {
        var arr = array
        let n = arr.count
        if n <= 1 {
            recorder.record(arr)
            return recorder.steps
        }
        for i in 0..<n {
            var swapped = false
            for j in 0..<(n - i - 1) {
                if arr[j] > arr[j + 1] {
                    arr.swapAt(j, j + 1)
                    swapped = true
                    recorder.record(arr, highlighted: [j, j + 1])
                }
            }
            if !swapped { break }
        }
        recorder.record(arr) // final sorted state
        return recorder.steps
    }
}

// MARK: - Search Step Recording Structures

public struct SearchStep<T: Comparable> {
    public let array: [T]
    public let low: Int?
    public let high: Int?
    public let mid: Int?
    public let found: Bool?
    
    public init(array: [T],
                low: Int? = nil,
                high: Int? = nil,
                mid: Int? = nil,
                found: Bool? = nil) {
        self.array = array
        self.low = low
        self.high = high
        self.mid = mid
        self.found = found
    }
}

public struct SearchRecorder<T: Comparable> {
    public private(set) var steps: [SearchStep<T>] = []
    
    public mutating func record(_ array: [T],
                                low: Int? = nil,
                                high: Int? = nil,
                                mid: Int? = nil,
                                found: Bool? = nil) {
        steps.append(SearchStep(array: array,
                                low: low,
                                high: high,
                                mid: mid,
                                found: found))
    }
}

// MARK: - Binary Search with Step Recording

public struct BinarySearch<T: Comparable> {
    public var array: [T]          // Must be sorted
    public var target: T
    public private(set) var recorder = SearchRecorder<T>()
    
    public init(array: [T], target: T) {
        self.array = array
        self.target = target
        recorder.record(array) // initial empty state
    }
    
    public mutating func run() -> (found: Bool, index: Int?, steps: [SearchStep<T>]) {
        var low = 0
        var high = array.count - 1
        
        while low <= high {
            let mid = (low + high) / 2
            recorder.record(array, low: low, high: high, mid: mid)
            
            if array[mid] == target {
                recorder.record(array, low: low, high: high, mid: mid, found: true)
                return (true, mid, recorder.steps)
            } else if array[mid] < target {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        recorder.record(array, found: false)
        return (false, nil, recorder.steps)
    }
}
