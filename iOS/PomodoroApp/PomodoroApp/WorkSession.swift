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
    var elapsedTime: Int { return duration - remainingTime }
    
    var timeOnPause = 0
    
    var overallElapsedTime: Int { return elapsedTime + timeOnPause }
}
