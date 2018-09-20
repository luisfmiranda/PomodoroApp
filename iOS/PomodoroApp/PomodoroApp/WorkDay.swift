import Foundation

struct WorkDay {
    var workSessions = [WorkSession]()
    var workSessionsCount: Int { return workSessions.count }
    var workTime: Int { return workSessions.reduce(0) { $0 + $1.duration } }
    var timeOnPause = 0
}
