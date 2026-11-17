import Foundation

func testBasic() {
    var canvas = Canvas()
    let red = Color(r: 255, g: 0, b: 0)
    let green = Color(r: 0, g: 255, b: 0)
    let blue = Color(r: 0, g: 0, b: 255)

    let p1 = Point(x: 10, y: 10)
    let v1 = canvas.draw(at: p1, color: red) // version 1
    assert(v1 == 1)
    assert(canvas.color(at: p1, version: 1) == red)

    let v2 = canvas.draw(at: p1, color: green) // version 2
    assert(v2 == 2)
    assert(canvas.color(at: p1, version: 2) == green)
    // earlier version still red
    assert(canvas.color(at: p1, version: 1) == red)

    // another point
    let p2 = Point(x: 5, y: 5)
    let v3 = canvas.draw(at: p2, color: blue) // version 3
    assert(v3 == 3)
    assert(canvas.color(at: p2, version: 3) == blue)
    assert(canvas.color(at: p2, version: 2) == nil) // not drawn yet

    // revert to version 2
    canvas.revert(to: 2)
    assert(canvas.version == 2)
    assert(canvas.color(at: p2, version: 2) == nil)
    assert(canvas.color(at: p1, version: 2) == green)

    // after revert, draw new color
    let v4 = canvas.draw(at: p2, color: red) // version 3 again
    assert(v4 == 3)
    assert(canvas.color(at: p2, version: 3) == red)
}

func testEdgeCases() {
    var canvas = Canvas()
    let point = Point(x: 0, y: 0)

    for i in 1...1000 {
        let color = Color(
            r: UInt8(i % 256),
            g: UInt8((i * 2) % 256),
            b: UInt8((i * 3) % 256)
        )
        let v = canvas.draw(at: point, color: color)
        assert(v == i)
        // latest version matches
        assert(canvas.color(at: point, version: i) == color)
        // previous version still matches
        if i > 1 {
            let prev = Color(
                r: UInt8((i - 1) % 256),
                g: UInt8(((i - 1) * 2) % 256),
                b: UInt8(((i - 1) * 3) % 256)
            )
            assert(canvas.color(at: point, version: i - 1) == prev)
        }
    }

    // Query beyond current version returns the most recent color
    let latest = Color(
        r: UInt8(1000 % 256),
        g: UInt8((1000 * 2) % 256),
        b: UInt8((1000 * 3) % 256)
    )
    assert(canvas.color(at: point, version: 2000) == latest)
}

testBasic()
testEdgeCases()
print("All Chronos-Canvas tests passed.")
