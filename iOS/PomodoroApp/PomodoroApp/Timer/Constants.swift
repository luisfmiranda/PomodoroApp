import UIKit

struct Constants {
    static let timeAtom = 0.01
    
    struct SizeRatios {
        static let mainTimerFontSizeToBoundsHeight: CGFloat = 1 / 13
        static let infoPanelTitlesFontSizeToBoundsHeight: CGFloat = 1 / 73
        static let infoPanelValuesFontSizeToBoundsHeight: CGFloat = 1 / 37
        static let infoPanelSpacingToBoundsHeight: CGFloat = 1 / 24
        
        static let quickStatsAxisLineWidthToBoundsHeight: CGFloat = 1 / 400
        static let quickStatsLineWidthToBoundsHeight: CGFloat = 1 / 100
        static let quickStatsAxisOffsetToBoundsHeight: CGFloat = 1 / 10
        static let quickStatsTopMarginToBoundsHeight: CGFloat = 1 / 100
        static let quickStatsRightMarginToBoundsWidth: CGFloat = 1 / 100
        static let quickStatsAxisValuesFontSizetoBoundHeight: CGFloat = 1 / 73
    }
    
    struct NotificationKeys {
        static let aSecondHasPassed = "io.github.lfmiranda.aSecondHasPassed"
    }
}
