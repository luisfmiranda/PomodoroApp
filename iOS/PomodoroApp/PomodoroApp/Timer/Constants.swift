import Foundation

struct Constants {
    static let timeAtom = 0.01
    
    struct SizeRatios {
        static let mainTimerFontSizeToBoundsHeight: Double = 1 / 16
        static let infoPanelTitlesFontSizeToBoundsHeight: Double = 1 / 68
        static let infoPanelValuesFontSizeToBoundsHeight: Double = 1 / 40
    }
    
    struct NotificationKeys {
        static let aSecondHasPassed = "io.github.lfmiranda.aSecondHasPassed"
    }
}
