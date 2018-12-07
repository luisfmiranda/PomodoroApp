import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var workIntervalTextField: CustomUITextField!
    @IBOutlet weak var shortBreakTextField: CustomUITextField!
    @IBOutlet weak var sessionsTargetTextField: CustomUITextField!
    @IBOutlet weak var timeOnPauseTextField: CustomUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        createToolBar()
        
        let workIntervalTimePicker = UIDatePicker()
        let shortBreakTimePicker = UIDatePicker()
        let timeOnPauseTimePicker = UIDatePicker()
        
        workIntervalTimePicker.datePickerMode = .time
        shortBreakTimePicker.datePickerMode = .time
        timeOnPauseTimePicker.datePickerMode = .time
        
        workIntervalTimePicker.locale = Locale(identifier: "en_GB")
        shortBreakTimePicker.locale = Locale(identifier: "en_GB")
        timeOnPauseTimePicker.locale = Locale(identifier: "en_GB")
        
        workIntervalTimePicker.backgroundColor = UIColor.white
        shortBreakTimePicker.backgroundColor = UIColor.white
        timeOnPauseTimePicker.backgroundColor = UIColor.white
        
        workIntervalTimePicker.countDownDuration = 25 * 60
        shortBreakTimePicker.countDownDuration = 5 * 60
        timeOnPauseTimePicker.countDownDuration = 30 * 60
        
        workIntervalTextField.inputView = workIntervalTimePicker
        shortBreakTextField.inputView = shortBreakTimePicker
        timeOnPauseTextField.inputView = timeOnPauseTimePicker
        
        workIntervalTextField.tintColor = UIColor.clear
        shortBreakTextField.tintColor = UIColor.clear
        sessionsTargetTextField.tintColor = UIColor.clear
        timeOnPauseTextField.tintColor = UIColor.clear
        
        workIntervalTimePicker.addTarget(self, action: #selector(workIntervalTimeChanged(sender:)), for: .valueChanged)
        shortBreakTimePicker.addTarget(self, action: #selector(shortBreakTimeChanged(sender:)), for: .valueChanged)
        sessionsTargetTextField.addTarget(self, action: #selector(sessionsTargetChanged), for: .editingDidEnd)
        timeOnPauseTimePicker.addTarget(self, action: #selector(timeOnPauseChanged(sender:)), for: .valueChanged)
    }
    
    private func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.tintColor = UIColor.black
        
        workIntervalTextField.inputAccessoryView = toolBar
        shortBreakTextField.inputAccessoryView = toolBar
        sessionsTargetTextField.inputAccessoryView = toolBar
        timeOnPauseTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func workIntervalTimeChanged(sender: UIDatePicker) {
        workIntervalTextField.text = Int(sender.countDownDuration).asTimeDescription
        Settings.workSessionDuration = Int(sender.countDownDuration)
    }
    
    @objc func shortBreakTimeChanged(sender: UIDatePicker) {
        shortBreakTextField.text = Int(sender.countDownDuration).asTimeDescription
    }
    
    @objc func sessionsTargetChanged() {
        if let sessionsTargetText = sessionsTargetTextField.text {
            if var sessionsTarget = Int(sessionsTargetText) {
                if sessionsTarget < 1 { sessionsTarget = 1 }
                else if sessionsTarget > (24 * 60 * 60) { sessionsTarget = (24 * 60 * 60) }
                
                sessionsTargetTextField.text = "\(sessionsTarget) session"
                if sessionsTarget > 1 { sessionsTargetTextField.text?.append("s") }
                Settings.workSessionsGoal = sessionsTarget
            } else {
                sessionsTargetTextField.text = "1 session"
                Settings.workSessionsGoal = 1
            }
        }
    }
    
    @objc func timeOnPauseChanged(sender: UIDatePicker) {
        let timeDescription = Int(sender.countDownDuration).asTimeDescription
        timeOnPauseTextField.text = (timeDescription != "" ? timeDescription : "None")
    }
}

extension Int {
    var asTimeDescription: String {
        let hours = self / 3_600
        let minutes = (self % 3_600) / 60
        
        var timeDescription = ""
        
        if hours != 0 {
            timeDescription += "\(hours) hour"
            if hours > 1 { timeDescription += "s" }
        }
        
        if (hours != 0 && minutes != 0) { timeDescription += ", " }
        
        if minutes != 0 {
            timeDescription += "\(minutes) minute"
            if minutes > 1 { timeDescription += "s" }
        }
        
        return timeDescription
    }
}
