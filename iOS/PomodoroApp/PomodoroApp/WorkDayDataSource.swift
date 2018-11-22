import Foundation

protocol WorkDayDataSource: AnyObject {
    func workingLogForCurrentDay() -> WorkingLog
    func workTimeRemainingForCurrentDay() -> Int?
    func timeOnPauseRemainingForCurrentDay() -> Int?
}
