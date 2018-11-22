import Foundation

struct WorkDay {
    var sessions = [WorkSession]()
    var sessionsCount: Int { return sessions.count }
    var completedSessionsCount: Int { return sessions.filter { $0.status == .completed }.count }
    var currentSession: WorkSession! { return sessions.last }
    
    var workTime: Int { return sessions.reduce(0) { $0 + $1.elapsedTime } }
    var workTimeRemaining: Int? {
        if let workTimeGoal = Settings.workTimeGoal {
            return workTimeGoal - workTime
        } else {
            return nil
        }
    }
    
    var timeOnPause: Int { return sessions.reduce(0) { $0 + $1.timeOnPause } }
    var timeOnPauseRemaining: Int? {
        if let timeOnPauseGoal = Settings.timeOnPauseGoal {
            return timeOnPauseGoal - timeOnPause
        } else {
            return nil
        }
    }
    
    var overallTime: Int { return sessions.reduce(0) { $0 + $1.overallElapsedTime } }
    var efficiency: Int { return workTime / overallTime }
    
    var workingLog = WorkingLog()
}
