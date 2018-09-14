import Foundation

struct WorkDay {
    var workSessions = [WorkSession]()
    var workSessionsCount: Int { return workSessions.count }
}
