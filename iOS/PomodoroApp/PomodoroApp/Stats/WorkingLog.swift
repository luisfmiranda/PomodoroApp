import Foundation

struct WorkingLog {
    var transitionsInCompletedSessions = [Transition]()
    var transitionsInTheCurrentSession = [Transition]()
    var temporaryTransition: Transition?
    
    var mostRecentTransition: Transition? {
        if temporaryTransition != nil { return temporaryTransition! }
        if transitionsInTheCurrentSession.last != nil { return transitionsInTheCurrentSession.last! }
        if transitionsInCompletedSessions.last != nil { return transitionsInCompletedSessions.last! }
        return nil
    }
    
    var startTime: Int?
}

struct Transition {
    let id: String
    let time: Int
    let workedTime: Int
    
    init(id: String, time: Int, workedTime: Int) {
        self.id = id
        self.time = time
        self.workedTime = workedTime
    }
}
