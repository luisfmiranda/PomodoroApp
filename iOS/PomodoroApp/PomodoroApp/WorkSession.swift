import Foundation

struct WorkSession {
    var status = Status.notStartedYet
    
    enum Status {
        case notStartedYet
        case onGoing
        case onPause
        case completed
    }
    
    let duration = Settings.workSessionDuration
    var remainingTime = Settings.workSessionDuration
}
