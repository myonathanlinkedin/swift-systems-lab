import Foundation

public enum Message {
    case prepare
    case voteCommit(participantId: Int)
    case voteAbort(participantId: Int)
    case commit
    case abort
}

public enum ParticipantState {
    case idle
    case prepared
    case committed
    case aborted
}

public enum CoordinatorState {
    case idle
    case waiting
    case committed
    case aborted
}

public struct Participant {
    public let id: Int
    public var state: ParticipantState = .idle
    let voteDecision: () -> Bool   // true → commit, false → abort

    public init(id: Int, voteDecision: @escaping () -> Bool) {
        self.id = id
        self.voteDecision = voteDecision
    }

    // Process incoming message and optionally produce a response
    public mutating func receive(_ message: Message) -> Message? {
        switch (state, message) {
        case (.idle, .prepare):
            state = .prepared
            let vote = voteDecision()
            return vote ? .voteCommit(participantId: id) : .voteAbort(participantId: id)

        case (.prepared, .commit):
            state = .committed
            return nil

        case (.prepared, .abort):
            state = .aborted
            return nil

        default:
            return nil
        }
    }
}

public struct Coordinator {
    public var participants: [Participant]
    public var state: CoordinatorState = .idle
    var pendingVotes: Set<Int> = []
    var commitDecision: Bool = true

    public init(participants: [Participant]) {
        self.participants = participants
    }

    // Phase‑1: send PREPARE to all participants
    public mutating func start() -> [Message] {
        guard !participants.isEmpty else {
            state = .committed
            return []
        }
        state = .waiting
        pendingVotes = Set(participants.map { $0.id })
        return participants.map { _ in .prepare }
    }

    // Receive a vote; when all votes are in, decide and return the final decision
    public mutating func receive(_ vote: Message) -> Message? {
        switch vote {
        case let .voteCommit(pid):
            pendingVotes.remove(pid)
            if pendingVotes.isEmpty { return finalize() }
            return nil

        case let .voteAbort(pid):
            commitDecision = false
            pendingVotes.remove(pid)
            if pendingVotes.isEmpty { return finalize() }
            return nil

        default:
            return nil
        }
    }

    private mutating func finalize() -> Message {
        state = commitDecision ? .committed : .aborted
        return commitDecision ? .commit : .abort
    }

    // Broadcast the final decision to every participant
    public mutating func broadcastDecision() -> [Message] {
        guard state == .committed || state == .aborted else { return [] }
        let decision: Message = (state == .committed) ? .commit : .abort
        return participants.map { _ in decision }
    }
}
