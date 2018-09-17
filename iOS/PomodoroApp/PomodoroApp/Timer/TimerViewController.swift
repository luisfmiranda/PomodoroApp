import UIKit

class TimerViewController: UIViewController {
    private var currentDay = WorkDay()
    private var currentWorkSession: WorkSession? {
        didSet {
            mainTimerLabel.text = currentWorkSession?.remainingTime.asHMS
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
    
    @IBOutlet private var infoPanelTitles: [UILabel]!
    @IBOutlet private var infoPanelValues: [UILabel]!
    
    @IBOutlet private weak var timeOnPauseTitle: UILabel!
    
    @IBOutlet private weak var timeOnPauseLabel: UILabel!
    
    @IBOutlet private weak var workInfoStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideButtons()
        createObservers()
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
        adjsutInfoPanelStackViews()
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
    
    private func adjsutInfoPanelStackViews() {
        if traitCollection.verticalSizeClass == .regular {
            workInfoStackView.spacing = view.bounds.height * Constants.SizeRatios.infoPanelSpacingToBoundsHeight
            infoPanelTitles.forEach { $0.textAlignment = .left }
            infoPanelValues.forEach { $0.textAlignment = .left }
            timeOnPauseTitle.textAlignment = .right
            timeOnPauseLabel.textAlignment = .right
        } else {
            workInfoStackView.spacing = 0.0
            infoPanelTitles.forEach { $0.textAlignment = .center }
            infoPanelValues.forEach { $0.textAlignment = .center }
        }
    }
    
    @objc private func updateTime() {
        currentWorkSession?.remainingTime -= 1
    }
    
    @IBAction func touchStartButton(_ sender: UIButton) {
        currentWorkSession = WorkSession()
        mainTimer.start()
        animateButtons(faddingIn: [pauseButton, stopButton], faddingOut: [startButton, resumeButton])
    }
    
    @IBAction func touchPauseButton(_ sender: UIButton) {
        mainTimer.stop()
        animateButtons(faddingIn: [resumeButton], faddingOut: [pauseButton])
    }
    
    @IBAction func touchResumeButton(_ sender: UIButton) {
        mainTimer.start()
        animateButtons(faddingIn: [pauseButton], faddingOut: [resumeButton])
    }
    
    @IBAction func touchStopButton(_ sender: UIButton) {
        currentWorkSession = WorkSession()
        mainTimer.stop()
        animateButtons(faddingIn: [startButton], faddingOut: [pauseButton, resumeButton, stopButton])
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
        
        return "\(hours):\(minutes)'"
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
