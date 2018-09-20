import Foundation

struct WorkingLog {
    var transitionsInCompletedSessions = [Transition]()
    var transitionsInTheCurrentSession = [Transition]()
    var temporaryTransition: Transition?
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
