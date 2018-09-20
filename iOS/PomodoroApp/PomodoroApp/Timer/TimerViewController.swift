import UIKit

class TimerViewController: UIViewController {
    private var currentDay = WorkDay() {
        didSet {
            workSessionsLabel.text = "\(currentDay.workSessionsCount) / \(Settings.workSessionsGoal)"
            timeWorkedLabel.text = "\(currentDay.workTime.asHM) / \(Settings.workTimeGoal.asHM)"
            timeOnPauseLabel.text = "\(currentDay.timeOnPause.asHM) / \(Settings.timeOnPauseGoal.asHM)"
        }
    }
    
    @IBOutlet weak var quickStatsView: QuickStatsView!
    
    private var currentWorkSession = WorkSession() {
        didSet {
            if currentWorkSession.remainingTime == 0 {
                currentWorkSession.status = .completed
                currentDay.workSessions.append(currentWorkSession)
                
                // now that the work session is concluded, the transition points become permanent
                for transition in quickStatsView.workingLog.transitionsInTheCurrentSession {
                    quickStatsView.workingLog.transitionsInCompletedSessions.append(transition)
                }
                
                // then we create the last transition (triggered when the session is completed)
                let minutesSinceMidnight = countMinutesSinceMidnight()
                let transitionOnCompletion = Transition(id: "Completed.", time: minutesSinceMidnight, workedTime: currentDay.workTime / 60)
                
                // and if it happened after the temporary transition (regarding a real clock), we have to include the
                // temporary transition
                if let mostRecentTransition = quickStatsView.workingLog.temporaryTransition {
                    if transitionOnCompletion.time != mostRecentTransition.time {
                        quickStatsView.workingLog.transitionsInCompletedSessions.append(mostRecentTransition)
                    }
                }
                
                // and then we save the last transition
                quickStatsView.workingLog.transitionsInCompletedSessions.append(transitionOnCompletion)
                
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
            } else if ((oldValue.status != .notStartedYet) && ((currentWorkSession.remainingTime % 60) == 0))
                || ((currentWorkSession.timeOnPause != 0) && ((currentWorkSession.timeOnPause % 60) == 0)) {
                
                // check if there are a new (and provisional) longest working time
                let totalTimeWorkedToday = currentDay.workTime + currentWorkSession.elapsedTime
                if (totalTimeWorkedToday / 60) > Records.longestWorkingTime {
                    Records.longestWorkingTime = totalTimeWorkedToday / 60
                    print("Records.longestWorkingTime: \(Records.longestWorkingTime)")
                }
                
                // creates a transition corresponding to the round minute
                let minutesSinceMidnight = countMinutesSinceMidnight()
                let transitionTriggeredByTheTimer = Transition(id: "\(currentWorkSession.status)...", time: minutesSinceMidnight, workedTime: totalTimeWorkedToday / 60)
                
                // if it happened in a different minute compared to the most recent transition (regarding a real clock),
                // we have to add it to the list of transitions in the current session
                if let mostRecentTransition = quickStatsView.workingLog.temporaryTransition {
                    if transitionTriggeredByTheTimer.time != mostRecentTransition.time {
                        quickStatsView.workingLog.transitionsInTheCurrentSession.append(mostRecentTransition)
                    }
                }
                
                quickStatsView.workingLog.temporaryTransition = transitionTriggeredByTheTimer
                
                // checks if the new transition is the latest so far
                if Records.latestTransition == nil || minutesSinceMidnight > Records.latestTransition! {
                    Records.latestTransition = minutesSinceMidnight
                }
            }
            
            mainTimerLabel.text = currentWorkSession.remainingTime.asHMS
        }
    }

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
        
        mainTimerLabel.text = currentWorkSession.remainingTime.asHMS
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
        switch currentWorkSession.status {
        case .onGoing:
            currentWorkSession.remainingTime -= 1
        case .onPause:
            currentWorkSession.timeOnPause += 1
        default:
            break
        }
    }
    
    @IBAction func touchStartButton(_ sender: UIButton) {
        mainTimer.start()
        currentWorkSession.status = .onGoing
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
        quickStatsView.workingLog.transitionsInTheCurrentSession.append(transition)
    }
    
    @IBAction func touchPauseButton(_ sender: UIButton) {
        mainTimer.stop()
        timeOnPauseTimer.start()
        currentWorkSession.status = .onPause
        animateButtons(faddingIn: [resumeButton], faddingOut: [pauseButton])
        
        let minutesSinceMidnight = countMinutesSinceMidnight()
        
        // checks if the new transition is the latest so far
        if let latestTransition = Records.latestTransition, minutesSinceMidnight > latestTransition {
            Records.latestTransition = minutesSinceMidnight
        }
        
        // creates a transition corresponding to the moment in which the pause button was pressed
        let totalTimeWorkedToday = currentDay.workTime + currentWorkSession.elapsedTime
        let transitionOnPause = Transition(id: "Paused.", time: minutesSinceMidnight, workedTime: totalTimeWorkedToday / 60)
        
        // if it happened in a different minute compared to the most recent transition (regarding a real clock),
        // we have to add it to the list of transitions in the current session
        if let mostRecentTransition = quickStatsView.workingLog.temporaryTransition {
            if transitionOnPause.time != mostRecentTransition.time {
                quickStatsView.workingLog.transitionsInTheCurrentSession.append(mostRecentTransition)
            }
        }
        
        quickStatsView.workingLog.temporaryTransition = transitionOnPause
    }
    
    @IBAction func touchResumeButton(_ sender: UIButton) {
        timeOnPauseTimer.stop()
        mainTimer.start()
        currentWorkSession.status = .onGoing
        animateButtons(faddingIn: [pauseButton], faddingOut: [resumeButton])
        
        let minutesSinceMidnight = countMinutesSinceMidnight()
        
        // checks if the new transition is the latest so far
        if let latestTransition = Records.latestTransition, minutesSinceMidnight > latestTransition {
            Records.latestTransition = minutesSinceMidnight
        }
        
        // creates a transition corresponding to the moment in which the resume button was pressed
        let totalTimeWorkedToday = currentDay.workTime + currentWorkSession.elapsedTime
        let transitionOnResume = Transition(id: "Resumed.", time: minutesSinceMidnight, workedTime: totalTimeWorkedToday / 60)
        
        // if it happened in a different minute compared to the most recent transition (regarding a real clock),
        // we have to add it to the list of transitions in the current session
        if let mostRecentTransition = quickStatsView.workingLog.temporaryTransition {
            if transitionOnResume.time != mostRecentTransition.time {
                quickStatsView.workingLog.transitionsInTheCurrentSession.append(mostRecentTransition)
            }
        }
        
        quickStatsView.workingLog.temporaryTransition = transitionOnResume
    }
    
    @IBAction func touchStopButton() {
        currentWorkSession = WorkSession()
        mainTimer.stop()
        timeOnPauseTimer.stop()
        animateButtons(faddingIn: [startButton], faddingOut: [pauseButton, resumeButton, stopButton])
        
        quickStatsView.workingLog.transitionsInTheCurrentSession.removeAll()
        quickStatsView.workingLog.temporaryTransition = nil
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
