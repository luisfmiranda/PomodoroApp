import Foundation

struct Settings {
    static var workSessionDuration = 25 * 60
    static var workSessionsGoal = 14
    static var workTimeGoal: Int? { return workSessionDuration * workSessionsGoal }
    static var timeOnPauseGoal: Int? = 30 * 60
}
