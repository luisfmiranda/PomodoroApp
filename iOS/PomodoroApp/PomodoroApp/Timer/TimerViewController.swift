import UIKit

class TimerViewController: UIViewController {
    private var currentDay = WorkDay() {
        didSet {
            mainTimerLabel.text = currentDay.currentSession.remainingTime.asHMS

            if currentDay.currentSession.remainingTime == 0 {
                currentDay.sessions[currentDay.sessionsCount - 1].status = .completed
                updateSessionInfo()
                
                // now that the work session is concluded, the transition points become permanent
                for transition in currentDay.workingLog.transitionsInTheCurrentSession {
                    currentDay.workingLog.transitionsInCompletedSessions.append(transition)
                }
                
                // then we create the last transition (triggered when the session is completed)
                let minutesSinceMidnight = countMinutesSinceMidnight()
                let transitionOnCompletion = Transition(id: "Completed.", time: minutesSinceMidnight, workedTime: currentDay.workTime / 60)
                
                // and if it happened after the temporary transition (regarding a real clock), we have to include the
                // temporary transition
                if let mostRecentTransition = currentDay.workingLog.temporaryTransition {
                    if transitionOnCompletion.time != mostRecentTransition.time {
                        currentDay.workingLog.transitionsInCompletedSessions.append(mostRecentTransition)
                    }
                }
                
                // and then we save the last transition
                currentDay.workingLog.transitionsInCompletedSessions.append(transitionOnCompletion)
                
                // checks if there are a new longest working time
                if (currentDay.workTime / 60) > Records.longestWorkingTime {
                    Records.longestWorkingTime = currentDay.workTime / 60
                }
                
                // checks if the end of the work session has the latest end so far
                if Records.latestTransition == nil || minutesSinceMidnight > Records.latestTransition! {
                    Records.latestTransition = minutesSinceMidnight
                }
                
                touchStopButton()
                
                // every round minute since a state change
            } else if ((currentDay.currentSession.elapsedTime != 0)
                && ((currentDay.currentSession.elapsedTime % 60) == 0))
                || ((currentDay.currentSession.timeOnPause != 0)
                && ((currentDay.currentSession.timeOnPause % 60) == 0)) {
                updateSessionInfo()
                
                // check if there are a new (and provisional) longest working time
                if (currentDay.workTime / 60) > Records.longestWorkingTime {
                    Records.longestWorkingTime = currentDay.workTime / 60
                    print("Records.longestWorkingTime: \(Records.longestWorkingTime)")
                }
                
                // creates a transition corresponding to the round minute
                let minutesSinceMidnight = countMinutesSinceMidnight()
                let transitionTriggeredByTheTimer = Transition(id: "\(currentDay.currentSession.status)...",
                    time: minutesSinceMidnight, workedTime: currentDay.workTime / 60)
                
                // if it happened in a different minute compared to the most recent transition (regarding a real clock),
                // we have to add it to the list of transitions in the current session
                if let mostRecentTransition = currentDay.workingLog.temporaryTransition {
                    if transitionTriggeredByTheTimer.time != mostRecentTransition.time {
                        currentDay.workingLog.transitionsInTheCurrentSession.append(mostRecentTransition)
                    }
                }
                
                currentDay.workingLog.temporaryTransition = transitionTriggeredByTheTimer
                
                // checks if the new transition is the latest so far
                if Records.latestTransition == nil || minutesSinceMidnight > Records.latestTransition! {
                    Records.latestTransition = minutesSinceMidnight
                }
                
                quickStatsView.setNeedsDisplay()
            }
        }
    }
    
    private func updateSessionInfo() {
        workSessionsLabel.text = "\(currentDay.completedSessionsCount) / \(Settings.workSessionsGoal)"
        
        if let workTimeGoal = Settings.workTimeGoal {
            timeWorkedLabel.text = "\(currentDay.workTime.asHM) / \(workTimeGoal.asHM)"
        } else {
            timeWorkedLabel.text = currentDay.workTime.asHM
        }
        
        if let timeOnPauseGoal = Settings.timeOnPauseGoal {
            timeOnPauseLabel.text = "\(currentDay.timeOnPause.asHM) / \(timeOnPauseGoal.asHM)"
        } else {
            timeOnPauseLabel.text = currentDay.timeOnPause.asHM
        }
    }
    
    @IBOutlet weak var quickStatsView: QuickStatsView!

    private var mainTimer = TimeHandler()
    private var timeOnPauseTimer = TimeHandler()
    
    @IBOutlet private weak var mainTimerLabel: UILabel!
    
    @IBOutlet private weak var backButton: UIButton!
    
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var resumeButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    
    @IBOutlet private weak var infoPanelStackView: UIStackView!
    
    @IBOutlet private var infoPanelTitles: [UILabel]!
    @IBOutlet private var infoPanelValues: [UILabel]!
    
    @IBOutlet private weak var timeOnPauseTitle: UILabel!
    
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var workSessionsLabel: UILabel!
    @IBOutlet weak var timeWorkedLabel: UILabel!
    @IBOutlet private weak var timeOnPauseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideButtons()
        createObservers()
        
        quickStatsView.workDayDataSource = self
        currentDay.sessions.append(WorkSession())
        mainTimerLabel.text = currentDay.currentSession.duration.asHMS
        updateSessionInfo()
    }
    
    private func hideButtons() {
        resumeButton.alpha = 0.0
        pauseButton.alpha = 0.0
        stopButton.alpha = 0.0
    }
    
    private func createObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TimerViewController.updateTime),
            name: Notification.Name(rawValue: Constants.NotificationKeys.aSecondHasPassed),
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        largestDimension = view.bounds.height > view.bounds.width ? view.bounds.height : view.bounds.width
        configureFonts()
        adjustInfoPanelStackViews()
    }
    
    private func configureFonts() {
        var baseFont = UIFont.monospacedDigitSystemFont(ofSize: mainTimerFontSize, weight: UIFont.Weight.light)
        mainTimerLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        
        baseFont = UIFont.monospacedDigitSystemFont(ofSize: infoPanelTitlesFontSize, weight: UIFont.Weight.light)
        infoPanelTitles.forEach { $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont) }
        
        baseFont = UIFont.monospacedDigitSystemFont(ofSize: infoPanelValuesFontSize, weight: UIFont.Weight.regular)
        infoPanelValues.forEach { $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont) }
    }
    
    var largestDimension: CGFloat?
    
    private var mainTimerFontSize: CGFloat {
        return largestDimension! * Constants.SizeRatios.mainTimerFontSizeToBoundsHeight
    }
    
    private var infoPanelTitlesFontSize: CGFloat {
        return largestDimension! * Constants.SizeRatios.infoPanelTitlesFontSizeToBoundsHeight
    }
    
    private var infoPanelValuesFontSize: CGFloat {
        return largestDimension! * Constants.SizeRatios.infoPanelValuesFontSizeToBoundsHeight
    }
    
    private func adjustInfoPanelStackViews() {
        if traitCollection.verticalSizeClass == .regular {
            infoPanelStackView.spacing = view.bounds.height * Constants.SizeRatios.infoPanelSpacingToBoundsHeight
            infoPanelTitles.forEach { $0.textAlignment = .left }
            infoPanelValues.forEach { $0.textAlignment = .left }
            timeOnPauseTitle.textAlignment = .right
            timeOnPauseLabel.textAlignment = .right
        } else {
            infoPanelStackView.spacing = 0.0
            infoPanelTitles.forEach { $0.textAlignment = .center }
            infoPanelValues.forEach { $0.textAlignment = .center }
        }
    }
    
    @objc private func updateTime() {
        switch currentDay.currentSession.status {
        case .onGoing:
            currentDay.sessions[currentDay.sessionsCount - 1].remainingTime -= 1
        case .onPause:
            currentDay.sessions[currentDay.sessionsCount - 1].timeOnPause += 1
        default:
            break
        }
    }
    
    @IBAction func touchStartButton(_ sender: UIButton) {
        mainTimer.start()
        currentDay.sessions[currentDay.sessionsCount - 1].status = .onGoing
        animateButtons(faddingIn: [pauseButton, stopButton], faddingOut: [startButton, resumeButton])
        
        // checks if the start of the working session has the earliest or latest beginning so far
        let minutesSinceMidnight = countMinutesSinceMidnight()
        if Records.earliestTransition == nil || minutesSinceMidnight < Records.earliestTransition! {
            Records.earliestTransition = minutesSinceMidnight
        }
        if let latestTransition = Records.latestTransition, minutesSinceMidnight > latestTransition {
            Records.latestTransition = minutesSinceMidnight
        }
        
        // adds a new transition point as the first one in the current session
        let transition = Transition(id: "Started", time: minutesSinceMidnight, workedTime: currentDay.workTime / 60)
        currentDay.workingLog.transitionsInTheCurrentSession.append(transition)
        
        // registers the start of the working log
        if currentDay.workingLog.startTime == nil {
           currentDay.workingLog.startTime = minutesSinceMidnight
        }
        
        quickStatsView.setNeedsDisplay()
    }
    
    @IBAction func touchPauseButton(_ sender: UIButton) {
        mainTimer.stop()
        timeOnPauseTimer.start()
        currentDay.sessions[currentDay.sessionsCount - 1].status = .onPause
        animateButtons(faddingIn: [resumeButton], faddingOut: [pauseButton])
        
        // checks if the new transition is the latest so far
        let minutesSinceMidnight = countMinutesSinceMidnight()
        if let latestTransition = Records.latestTransition, minutesSinceMidnight > latestTransition {
            Records.latestTransition = minutesSinceMidnight
        }
        
        // creates a transition corresponding to the moment in which the pause button was pressed
        let transitionOnPause = Transition(id: "Paused.", time: minutesSinceMidnight,
                                           workedTime: currentDay.workTime / 60)
        
        // if it happened in a different minute compared to the most recent transition (regarding a real clock),
        // we have to add it to the list of transitions in the current session
        if let mostRecentTransition = currentDay.workingLog.temporaryTransition {
            if transitionOnPause.time != mostRecentTransition.time {
                currentDay.workingLog.transitionsInTheCurrentSession.append(mostRecentTransition)
            }
        }
        
        currentDay.workingLog.temporaryTransition = transitionOnPause
        quickStatsView.setNeedsDisplay()
    }
    
    @IBAction func touchResumeButton(_ sender: UIButton) {
        timeOnPauseTimer.stop()
        mainTimer.start()
        currentDay.sessions[currentDay.sessionsCount - 1].status = .onGoing
        animateButtons(faddingIn: [pauseButton], faddingOut: [resumeButton])
        
        let minutesSinceMidnight = countMinutesSinceMidnight()
        
        // checks if the new transition is the latest so far
        if let latestTransition = Records.latestTransition, minutesSinceMidnight > latestTransition {
            Records.latestTransition = minutesSinceMidnight
        }
        
        // creates a transition corresponding to the moment in which the resume button was pressed
        let transitionOnResume = Transition(id: "Resumed.", time: minutesSinceMidnight,
                                            workedTime: currentDay.workTime / 60)
        
        // if it happened in a different minute compared to the most recent transition (regarding a real clock),
        // we have to add it to the list of transitions in the current session
        if let mostRecentTransition = currentDay.workingLog.temporaryTransition {
            if transitionOnResume.time != mostRecentTransition.time {
                currentDay.workingLog.transitionsInTheCurrentSession.append(mostRecentTransition)
            }
        }
        
        currentDay.workingLog.temporaryTransition = transitionOnResume
        quickStatsView.setNeedsDisplay()
    }
    
    @IBAction func touchStopButton() {
        currentDay.sessions.append(WorkSession())
        mainTimer.stop()
        timeOnPauseTimer.stop()
        animateButtons(faddingIn: [startButton], faddingOut: [pauseButton, resumeButton, stopButton])
        
        currentDay.workingLog.transitionsInTheCurrentSession.removeAll()
        currentDay.workingLog.temporaryTransition = nil
        quickStatsView.setNeedsDisplay()
    }
    
    let calendar = Calendar(identifier: .gregorian)
    private func countMinutesSinceMidnight() -> Int {
        let currentTime = Date()
        let midnight = calendar.startOfDay(for: currentTime)
        return Int(currentTime.timeIntervalSince(midnight) / 60)
    }
    
    private func animateButtons(faddingIn: [UIButton], faddingOut: [UIButton]) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.25,
            delay: 0.0,
            options: [],
            animations: {
                faddingIn.forEach { $0.alpha = 1.0 }
                faddingOut.forEach { $0.alpha = 0.0 }
            }
        )
    }
}

extension TimerViewController: WorkDayDataSource {
    func workingLogForCurrentDay() -> WorkingLog {
        return currentDay.workingLog
    }
    
    func workTimeRemainingForCurrentDay() -> Int? {
        return currentDay.workTimeRemaining
    }
    
    func timeOnPauseRemainingForCurrentDay() -> Int? {
        return currentDay.timeOnPauseRemaining
    }
}

extension Int {
    var asHM: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        
        let hours = self / 3_600
        let minutes = numberFormatter.string(from: ((self % 3_600) / 60) as NSNumber)!
        
        return "\(hours):\(minutes)"
    }
    
    var asHMS: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        
        let hours = self / 3_600
        let minutes = hours > 0 ? numberFormatter.string(from: ((self % 3_600) / 60) as NSNumber)! : String(self / 60)
        let seconds = numberFormatter.string(from: (self % 60) as NSNumber)!
        
        return hours > 0 ? "\(hours):\(minutes):\(seconds)" : "\(minutes):\(seconds)"
    }
}
