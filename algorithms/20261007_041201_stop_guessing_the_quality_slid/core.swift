import Foundation

/// A utility that binary‑searches JPEG quality values (0…100) to match a desired file size.
/// The caller provides a monotonic decreasing size‑for‑quality closure.
/// - Returns: The exact quality that yields `targetSize`, or `nil` if no exact match exists.
public struct JPEGQualityFinder {
    /// Finds the JPEG quality that produces the exact `targetSize`.
    /// - Parameters:
    ///   - targetSize: Desired file size in bytes.
    ///   - sizeForQuality: Closure mapping a quality (0…100) to the resulting file size.
    /// - Returns: Quality value (0…100) that yields `targetSize`, or `nil` if none.
    public func findExactQuality(
        targetSize: Int,
        sizeForQuality: (Int) -> Int
    ) -> Int? {
        var low = 0
        var high = 100
        var result: Int? = nil
        
        while low <= high {
            let mid = (low + high) / 2
            let size = sizeForQuality(mid)
            
            if size == targetSize {
                result = mid
                break
            } else if size > targetSize {
                // Size too big → need lower quality (which reduces size)
                low = mid + 1
            } else {
                // Size too small → need higher quality
                high = mid - 1
            }
        }
        return result
    }
    
    /// Finds the quality that yields the closest size not exceeding `targetSize`.
    /// If multiple qualities produce the same size, the highest quality is returned.
    /// - Parameters:
    ///   - targetSize: Desired maximum file size.
    ///   - sizeForQuality: Closure mapping a quality (0…100) to the resulting file size.
    /// - Returns: Quality value (0…100) whose size is ≤ `targetSize` and as large as possible.
    public func findBestFitQuality(
        targetSize: Int,
        sizeForQuality: (Int) -> Int
    ) -> Int {
        var low = 0
        var high = 100
        var bestQuality = 0   // default to lowest quality (smallest size)
        var bestSize = sizeForQuality(0)
        
        while low <= high {
            let mid = (low + high) / 2
            let size = sizeForQuality(mid)
            
            if size == targetSize {
                return mid   // exact match
            } else if size > targetSize {
                // Too large → lower quality needed
                low = mid + 1
            } else {
                // Size fits, remember it and try higher quality for larger size
                if size > bestSize || (size == bestSize && mid > bestQuality) {
                    bestQuality = mid
                    bestSize = size
                }
                high = mid - 1
            }
        }
        return bestQuality
    }
}
