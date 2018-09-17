import UIKit

struct Constants {
    static let timeAtom = 0.01
    
    struct SizeRatios {
        static let mainTimerFontSizeToBoundsHeight: CGFloat = 1 / 13
        static let infoPanelTitlesFontSizeToBoundsHeight: CGFloat = 1 / 73
        static let infoPanelValuesFontSizeToBoundsHeight: CGFloat = 1 / 37
        static let infoPanelSpacingToBoundsHeight: CGFloat = 1 / 24
        
        static let quickStatsLineWidthToBoundsHeight: CGFloat = 1 / 100
    }
    
    struct NotificationKeys {
        static let aSecondHasPassed = "io.github.lfmiranda.aSecondHasPassed"
    }
}
