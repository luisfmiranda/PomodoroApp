import Foundation

class TimeHandler {
    private var timeAtomsCount = 0
    private var timer = Timer()
    
    func start() {
        timer = Timer.init(timeInterval: Constants.timeAtom, repeats: true) { _ in
            self.timeAtomsCount += 1
             
            if self.timeAtomsCount == Int(1 / Constants.timeAtom) {
                let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.aSecondHasPassed)
                NotificationCenter.default.post(name: notificationName, object: nil)
                
                self.timeAtomsCount = 0
            }
        }
        
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func stop() {
        timer.invalidate()
    }
}
