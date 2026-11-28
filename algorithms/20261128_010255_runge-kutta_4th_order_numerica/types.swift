import Foundation

/// Represents a single point (time, value) of the solution of an ODE.
public struct ODEPoint {
    public var t: Double
    public var y: Double
    
    public init(t: Double, y: Double) {
        self.t = t
        self.y = y
    }
}
