import Foundation

/// A pure Runge‑Kutta 4th order integrator for scalar first‑order ODEs of the form dy/dt = f(t, y).
public struct RK4Integrator {
    /// Integrates the ODE from `t0` to `tEnd` using a fixed step size `h`.
    ///
    /// - Parameters:
    ///   - y0: Initial value y(t0).
    ///   - t0: Start time.
    ///   - tEnd: End time (must be reachable from `t0` using steps of size `h`).
    ///   - h: Step size (must be non‑zero; sign determines integration direction).
    ///   - f: Derivative function `f(t, y) = dy/dt`.
    /// - Returns: An array of `ODEPoint` containing the solution at each step, including the initial point.
    public func integrate(
        y0: Double,
        t0: Double,
        tEnd: Double,
        h: Double,
        f: (Double, Double) -> Double
    ) -> [ODEPoint] {
        // Guard against non‑progressing integration.
        guard h != 0.0 else {
            return [ODEPoint(t: t0, y: y0)]
        }
        
        var points: [ODEPoint] = []
        var currentT = t0
        var currentY = y0
        
        points.append(ODEPoint(t: currentT, y: currentY))
        
        // Determine integration direction.
        let step = h > 0 ? h : -h
        let direction = h > 0 ? 1.0 : -1.0
        
        // Continue while we have not passed the target time.
        while (direction > 0 && currentT < tEnd) || (direction < 0 && currentT > tEnd) {
            // Adjust final step to land exactly on tEnd.
            let remaining = tEnd - currentT
            let actualStep = direction > 0
                ? min(step, remaining)
                : max(-step, remaining)
            
            // RK4 coefficients.
            let k1 = f(currentT, currentY)
            let k2 = f(currentT + 0.5 * actualStep, currentY + 0.5 * actualStep * k1)
            let k3 = f(currentT + 0.5 * actualStep, currentY + 0.5 * actualStep * k2)
            let k4 = f(currentT + actualStep, currentY + actualStep * k3)
            
            // Update state.
            let deltaY = (actualStep / 6.0) * (k1 + 2.0 * k2 + 2.0 * k3 + k4)
            currentY += deltaY
            currentT += actualStep
            
            points.append(ODEPoint(t: currentT, y: currentY))
        }
        
        return points
    }
}
