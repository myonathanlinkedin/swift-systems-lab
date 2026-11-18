import Foundation

// Helper for floating‑point comparison.
@inline(__always)
func approxEqual(_ a: Double, _ b: Double, tolerance: Double = 1e-6) -> Bool {
    return abs(a - b) <= tolerance
}

// Unit Test 1: dy/dt = y  →  y(t) = exp(t)
func testExponentialGrowth() {
    let ode = ODE { (_, y) in y }               // dy/dt = y
    let step = 0.1
    var integrator = RK4Integrator(stepSize: step, ode: ode)
    let t0 = 0.0
    let tEnd = 1.0
    let y0 = 1.0                                 // y(0) = 1
    let trajectory = integrator.integrate(y0: y0, t0: t0, tEnd: tEnd)
    
    // Final value should be close to e^1.
    let final = trajectory.last!
    let expected = exp(tEnd)
    assert(approxEqual(final.y, expected, tolerance: 1e-5),
           "Exponential growth test failed: got \(final.y), expected \(expected)")
}

// Unit Test 2: dy/dt = -y  →  y(t) = exp(-t)
func testExponentialDecay() {
    let ode = ODE { (_, y) in -y }              // dy/dt = -y
    let step = 0.05
    var integrator = RK4Integrator(stepSize: step, ode: ode)
    let t0 = 0.0
    let tEnd = 2.0
    let y0 = 2.0                                 // y(0) = 2
    let trajectory = integrator.integrate(y0: y0, t0: t0, tEnd: tEnd)
    
    let final = trajectory.last!
    let expected = y0 * exp(-tEnd)
    assert(approxEqual(final.y, expected, tolerance: 1e-5),
           "Exponential decay test failed: got \(final.y), expected \(expected)")
}

// Unit Test 3: Verify that step size does not overshoot tEnd.
func testExactEndpoint() {
    let ode = ODE { (_, y) in y }               // dy/dt = y (any ODE works)
    let step = 0.3
    var integrator = RK4Integrator(stepSize: step, ode: ode)
    let t0 = 0.0
    let tEnd = 1.0
    let y0 = 1.0
    let trajectory = integrator.integrate(y0: y0, t0: t0, tEnd: tEnd)
    
    let last = trajectory.last!
    assert(approxEqual(last.t, tEnd, tolerance: 1e-12),
           "Endpoint test failed: last t = \(last.t), expected \(tEnd)")
}

// Run all tests.
func runAllTests() {
    testExponentialGrowth()
    testExponentialDecay()
    testExactEndpoint()
    print("All RK4 tests passed.")
}

// Entry point.
runAllTests()
