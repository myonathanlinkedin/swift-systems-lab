import Foundation

// Run a full 2PC round and return final participant states and coordinator state
func runProtocol(participants initial: [Participant]) -> ([Participant], CoordinatorState) {
    var coordinator = Coordinator(participants: initial)
    var participants = coordinator.participants   // mutable copy

    // Phase 1: send PREPARE
    let prepareMsgs = coordinator.start()
    for i in 0..<participants.count {
        if let response = participants[i].receive(prepareMsgs[i]) {
            if let decision = coordinator.receive(response) {
                // Phase 2: broadcast decision
                let finalMsgs = coordinator.broadcastDecision()
                for j in 0..<participants.count {
                    _ = participants[j].receive(finalMsgs[j])
                }
                break
            }
        }
    }

    // If there were no participants, start() already set state to .committed
    return (participants, coordinator.state)
}

// ---------- Unit Tests ----------
func testAllCommit() {
    let p1 = Participant(id: 1, voteDecision: { true })
    let p2 = Participant(id: 2, voteDecision: { true })
    let (finalParticipants, finalState) = runProtocol(participants: [p1, p2])
    assert(finalState == .committed, "Coordinator should commit when all vote commit")
    for p in finalParticipants {
        assert(p.state == .committed, "Participant \(p.id) must be committed")
    }
}

func testOneAbort() {
    let p1 = Participant(id: 1, voteDecision: { true })
    let p2 = Participant(id: 2, voteDecision: { false })
    let (finalParticipants, finalState) = runProtocol(participants: [p1, p2])
    assert(finalState == .aborted, "Coordinator should abort when any vote abort")
    for p in finalParticipants {
        assert(p.state == .aborted, "Participant \(p.id) must be aborted")
    }
}

func testNoParticipants() {
    let (finalParticipants, finalState) = runProtocol(participants: [])
    assert(finalState == .committed, "Coordinator with zero participants should commit")
    assert(finalParticipants.isEmpty, "No participants should be returned")
}

// ---------- Entry Point ----------
func main() {
    testAllCommit()
    testOneAbort()
    testNoParticipants()
    print("All tests passed")
}

main()
