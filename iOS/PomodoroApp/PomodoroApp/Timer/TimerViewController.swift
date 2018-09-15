import UIKit

class TimerViewController: UIViewController {
    private var currentDay = WorkDay()
    private var currentWorkSession: WorkSession? {
        didSet {
            mainTimerLabel.text = currentWorkSession?.remainingTime.asHMS
        }
    }
    
    private var mainTimer = TimeHandler()
    
    @IBOutlet private weak var mainTimerLabel: UILabel!
    
    @IBOutlet private weak var backButton: UIButton!
    
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var resumeButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    
    @IBOutlet private var infoPanelTitles: [UILabel]!
    @IBOutlet private var infoPanelValues: [UILabel]!
    
    @IBOutlet private weak var projectLabel: UILabel!
    
    override func viewDidLoad() {
        hideButtons()
        configureFonts()
        createObservers()
        
        //backButton.imageView?.contentMode = .scaleAspectFit
    }
    
    private func hideButtons() {
        resumeButton.alpha = 0.0
        pauseButton.alpha = 0.0
        stopButton.alpha = 0.0
    }
    
    private func configureFonts() {
        var baseFont = UIFont.monospacedDigitSystemFont(ofSize: mainTimerFontSize, weight: UIFont.Weight.light)
        mainTimerLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        
        baseFont = UIFont.monospacedDigitSystemFont(ofSize: infoPanelTitlesFontSize, weight: UIFont.Weight.regular)
        infoPanelTitles.forEach { $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont) }
        
        baseFont = UIFont.monospacedDigitSystemFont(ofSize: infoPanelValuesFontSize, weight: UIFont.Weight.semibold)
        infoPanelValues.forEach { $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont) }
    }
    
    private var mainTimerFontSize: CGFloat {
        return view.bounds.height * CGFloat(Constants.SizeRatios.mainTimerFontSizeToBoundsHeight)
    }
    
    private var infoPanelTitlesFontSize: CGFloat {
        return view.bounds.height * CGFloat(Constants.SizeRatios.infoPanelTitlesFontSizeToBoundsHeight)
    }
    
    private var infoPanelValuesFontSize: CGFloat {
        return view.bounds.height * CGFloat(Constants.SizeRatios.infoPanelValuesFontSizeToBoundsHeight)
    }
    
    private func createObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TimerViewController.updateTime),
            name: Notification.Name(rawValue: Constants.NotificationKeys.aSecondHasPassed),
            object: nil
        )
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
