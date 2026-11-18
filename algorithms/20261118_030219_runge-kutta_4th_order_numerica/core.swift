import Foundation

/// A type representing a first‑order ordinary differential equation (ODE) of the form dy/dt = f(t, y).
public struct ODE {
    /// The derivative function f(t, y).
    public let derivative: (Double, Double) -> Double
    
    /// Initializes an ODE with the given derivative closure.
    /// - Parameter derivative: A closure that computes dy/dt given the current time `t` and state `y`.
    public init(derivative: @escaping (Double, Double) -> Double) {
        self.derivative = derivative
    }
}

/// A fourth‑order Runge‑Kutta (RK4) integrator for scalar ODEs.
public struct RK4Integrator {
    /// Fixed step size used for integration. Must be positive.
    public let stepSize: Double
    
    /// The ODE to integrate.
    public let ode: ODE
    
    /// Initializes the integrator.
    /// - Parameters:
    ///   - stepSize: Desired step size (must be > 0).
    ///   - ode: The ODE to solve.
    public init(stepSize: Double, ode: ODE) {
        precondition(stepSize > 0, "stepSize must be positive")
        self.stepSize = stepSize
        self.ode = ode
    }
    
    /// Integrates the ODE from `t0` to `tEnd` starting with initial value `y0`.
    /// Returns an array of `(t, y)` tuples including the initial point.
    /// - Parameters:
    ///   - y0: Initial state at time `t0`.
    ///   - t0: Start time.
    ///   - tEnd: End time (must be >= t0).
    /// - Returns: Sequence of sampled points.
    public func integrate(y0: Double, t0: Double, tEnd: Double) -> [(t: Double, y: Double)] {
        precondition(tEnd >= t0, "tEnd must be greater than or equal to t0")
        var result: [(t: Double, y: Double)] = []
        var t = t0
        var y = y0
        result.append((t, y))
        
        while t < tEnd {
            // Adjust final step to land exactly on tEnd.
            let h = min(stepSize, tEnd - t)
            // RK4 coefficients.
            let k1 = ode.derivative(t, y)
            let k2 = ode.derivative(t + 0.5 * h, y + 0.5 * h * k1)
            let k3 = ode.derivative(t + 0.5 * h, y + 0.5 * h * k2)
            let k4 = ode.derivative(t + h, y + h * k3)
            // Update state.
            y += (h / 6.0) * (k1 + 2.0 * k2 + 2.0 * k3 + k4)
            t += h
            result.append((t, y))
        }
        return result
    }
}
