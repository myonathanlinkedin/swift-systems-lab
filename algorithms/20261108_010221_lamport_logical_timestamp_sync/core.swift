import Foundation

public struct LamportTimestamp: Comparable, Hashable {
    public let processId: Int
    public let counter: UInt64

    public init(processId: Int, counter: UInt64) {
        self.processId = processId
        self.counter = counter
    }

    // Comparable conformance
    public static func < (lhs: LamportTimestamp, rhs: LamportTimestamp) -> Bool {
        if lhs.counter == rhs.counter {
            return lhs.processId < rhs.processId
        } else {
            return lhs.counter < rhs.counter
        }
    }

    public static func == (lhs: LamportTimestamp, rhs: LamportTimestamp) -> Bool {
        return lhs.counter == rhs.counter && lhs.processId == rhs.processId
    }
}

public struct LamportMessage {
    public let timestamp: LamportTimestamp
    public let senderId: Int

    public init(timestamp: LamportTimestamp, senderId: Int) {
        self.timestamp = timestamp
        self.senderId = senderId
    }
}

public struct LamportEngine {
    public let processId: Int
    public var counter: UInt64 = 0

    public init(processId: Int) {
        self.processId = processId
    }

    // Internal (local) event
    public mutating func internalEvent() -> LamportTimestamp {
        counter += 1
        return LamportTimestamp(processId: processId, counter: counter)
    }

    // Send a message (implicitly performs an internal event)
    public mutating func sendMessage() -> LamportMessage {
        let ts = internalEvent()
        return LamportMessage(timestamp: ts, senderId: processId)
    }

    // Receive a message and update the local clock
    public mutating func receive(message: LamportMessage) -> LamportTimestamp {
        let incoming = message.timestamp.counter
        if incoming > counter {
            counter = incoming
        }
        counter += 1
        return LamportTimestamp(processId: processId, counter: counter)
    }
}
