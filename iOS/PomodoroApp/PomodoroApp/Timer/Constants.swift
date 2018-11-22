import UIKit

struct Constants {
    static let timeAtom = 0.01
    
    struct SizeRatios {
        static let mainTimerFontSizeToBoundsHeight: CGFloat = 1 / 13
        static let infoPanelTitlesFontSizeToBoundsHeight: CGFloat = 1 / 73
        static let infoPanelValuesFontSizeToBoundsHeight: CGFloat = 1 / 37
        static let infoPanelSpacingToBoundsHeight: CGFloat = 1 / 24
        
        static let chartsLineWidthToChartHeight: CGFloat = 1 / 103
        
        static let quickStatsAxisOffsetToBoundsHeight: CGFloat = 1 / 10
        static let quickStatsTopMarginToBoundsHeight: CGFloat = 1 / 100
        static let quickStatsRightMarginToBoundsWidth: CGFloat = 1 / 100
        
        static let axisValuesFontSizeToBoundHeight: CGFloat = 1 / 36
        
        static let dashLengthForMainLineToChartWidth: CGFloat = 1 / 80
        
        static let tinySpaceToBoundsWidth: CGFloat = 1 / 400
    }
    
    struct NotificationKeys {
        static let aSecondHasPassed = "io.github.lfmiranda.aSecondHasPassed"
    }
}
