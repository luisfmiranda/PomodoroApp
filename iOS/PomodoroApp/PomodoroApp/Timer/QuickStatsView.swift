import UIKit

class QuickStatsView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        UIColor(red: 37 / 255, green: 176 / 255, blue: 189 / 255, alpha: 1.0).setStroke()
        path.lineWidth = bounds.height * CGFloat(Constants.SizeRatios.quickStatsLineWidthToBoundsHeight)
        path.stroke()
    }
}
