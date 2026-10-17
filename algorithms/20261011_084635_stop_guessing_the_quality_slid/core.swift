import Foundation

/// A utility that binary‑searches JPEG quality values (0…100) to approach a desired file size.
///
/// The caller supplies a deterministic, monotonic‑decreasing function `sizeForQuality` that
/// returns the (simulated) JPEG size in bytes for a given quality.  The search returns the
/// highest quality whose size is within `tolerance` bytes of `targetSize`, or `nil` if no
/// such quality exists.
///
/// Time Complexity: O(log Q) where Q = 101 (the number of possible quality values).
/// Space Complexity: O(1).
public struct JPEGQualitySearcher {
    /// Function mapping a quality (0…100) to a file size in bytes.
    public let sizeForQuality: (Int) -> Int

    /// Inclusive range of valid JPEG quality values.
    public let qualityRange: ClosedRange<Int> = 0...100

    /// Searches for a quality that yields a size within `tolerance` of `targetSize`.
    ///
    /// - Parameters:
    ///   - targetSize: Desired JPEG size in bytes.
    ///   - tolerance: Acceptable deviation in bytes (default 0 for exact match).
    /// - Returns: The highest quality satisfying the tolerance, or `nil` if impossible.
    public func search(targetSize: Int, tolerance: Int = 0) -> Int? {
        // Validate bounds using the monotonic property.
        let minQuality = qualityRange.lowerBound          // 0
        let maxQuality = qualityRange.upperBound          // 100
        let sizeAtMin = sizeForQuality(minQuality)        // largest size
        let sizeAtMax = sizeForQuality(maxQuality)        // smallest size

        // If the target is outside the achievable interval (even with tolerance) → failure.
        if targetSize > sizeAtMin + tolerance || targetSize < sizeAtMax - tolerance {
            return nil
        }

        var low = minQuality
        var high = maxQuality
        var bestQuality: Int? = nil

        // Classic integer binary search.
        while low <= high {
            let mid = (low + high) / 2
            let size = sizeForQuality(mid)
            let diff = size - targetSize

            if abs(diff) <= tolerance {
                // Acceptable; remember and try to improve quality (increase `mid`).
                bestQuality = mid
                low = mid + 1
            } else if size > targetSize {
                // Size too big → need higher quality (which reduces size).
                low = mid + 1
            } else {
                // Size too small → need lower quality.
                high = mid - 1
            }
        }
        return bestQuality
    }
}
