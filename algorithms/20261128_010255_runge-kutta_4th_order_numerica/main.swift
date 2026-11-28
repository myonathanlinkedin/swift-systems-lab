import Foundation

// Helper for approximate equality.
func approxEqual(_ a: Double, _ b: Double, tolerance: Double = 1e-6) -> Bool {
    return abs(a - b) <= tolerance
}

// Test 1: dy/dt = y, y(0) = 1 => y(t) = exp(t)
do {
    let integrator = RK4Integrator()
    let y0 = 1.0
    let t0 = 0.0
    let tEnd = 1.0
    let h = 0.1
    let derivative: (Double, Double) -> Double = { (_, y) in y }
    
    let result = integrator.integrate(y0: y0, t0: t0, tEnd: tEnd, h: h, f: derivative)
    
    // The last point should be close to exp(1)
    guard let last = result.last else {
        assertionFailure("Result array is empty")
        exit(1)
    }
    let expected = exp(1.0)
    assert(approxEqual(last.y, expected, tolerance: 1e-5), "Test 1 failed: expected \(expected), got \(last.y)")
}

// Test 2: dy/dt = -2*y, y(0) = 3 => y(t) = 3 * exp(-2t)
do {
    let integrator = RK4Integrator()
    let y0 = 3.0
    let t0 = 0.0
    let tEnd = 0.75
    let h = 0.05
    let derivative: (Double, Double) -> Double = { (_, y) in -2.0 * y }
    
    let result = integrator.integrate(y0: y0, t0: t0, tEnd: tEnd, h: h, f: derivative)
    
    guard let last = result.last else {
        assertionFailure("Result array is empty")
        exit(1)
    }
    let expected = y0 * exp(-2.0 * tEnd)
    assert(approxEqual(last.y, expected, tolerance: 1e-5), "Test 2 failed: expected \(expected), got \(last.y)")
}

// Test 3: Zero step size should return only the initial point.
do {
    let integrator = RK4Integrator()
    let result = integrator.integrate(y0: 5.0, t0: 2.0, tEnd: 5.0, h: 0.0) { (_, y) in y }
    assert(result.count == 1, "Test 3 failed: expected single point")
    assert(result[0].t == 2.0 && result[0].y == 5.0, "Test 3 failed: incorrect initial point")
}

// Test 4: Negative step size (integrate backwards).
do {
    let integrator = RK4Integrator()
    let y0 = 1.0
    let t0 = 1.0
    let tEnd = 0.0
    let h = -0.2
    let derivative: (Double, Double) -> Double = { (_, y) in y } // dy/dt = y
    
    let result = integrator.integrate(y0: y0, t0: t0, tEnd: tEnd, h: h, f: derivative)
    
    guard let first = result.first, let last = result.last else {
        assertionFailure("Result array is empty")
        exit(1)
    }
    // First point should be the initial condition.
    assert(first.t == t0 && first.y == y0, "Test 4 failed: initial point mismatch")
    // Last point should be close to exp(0) = 1
    let expected = exp(0.0)
    assert(approxEqual(last.y, expected, tolerance: 1e-5), "Test 4 failed: expected \(expected), got \(last.y)")
}

// Demo: Print a short table for dy/dt = sin(t), y(0)=0 from 0 to π with step 0.2
do {
    let integrator = RK4Integrator()
    let derivative: (Double, Double) -> Double = { (t, _) in sin(t) }
    let points = integrator.integrate(y0: 0.0, t0: 0.0, tEnd: Double.pi, h: 0.2, f: derivative)
    
    print("t\t\ty")
    for p in points {
        print(String(format: "%.4f\t%.6f", p.t, p.y))
    }
}

// If execution reaches this point, all assertions passed.
print("All RK4 tests passed.")
