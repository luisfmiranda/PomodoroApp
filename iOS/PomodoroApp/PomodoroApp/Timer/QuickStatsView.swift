import UIKit

class QuickStatsView: UIView {
    var workingLog = WorkingLog() { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath()
        let axisOffset = bounds.height * Constants.SizeRatios.quickStatsAxisOffsetToBoundsHeight
        let topMargin = bounds.height * Constants.SizeRatios.quickStatsTopMarginToBoundsHeight
        let rightMargin = bounds.height * Constants.SizeRatios.quickStatsRightMarginToBoundsWidth
        
//        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
//        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
//        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
//        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
//        path.close()
        
        // draw the goal line
// path.move(to: CGPoint(x: bounds.minX + axisOffset, y: bounds.midY))
        
        // draws the axis (without tick labels)
        path.move(to: getOrigin(offsetBy: axisOffset))
        path.addLine(to: CGPoint(x: bounds.maxX - rightMargin, y: bounds.maxY - axisOffset))
        path.move(to: getOrigin(offsetBy: axisOffset))
        path.addLine(to: CGPoint(x: bounds.minX + axisOffset, y: bounds.minY + topMargin))

        UIColor.black.setStroke()
        path.lineWidth = bounds.height * CGFloat(Constants.SizeRatios.quickStatsAxisLineWidthToBoundsHeight)
        path.stroke()
        
        // only the axis are drawn when there are no transition points
        if Records.earliestTransition == nil { return }
        
        path = UIBezierPath()
        configureBasicProperties(path)
        
        let xAxisMin = bounds.minX + axisOffset
        let xAxisMax = bounds.maxX - rightMargin
        let xValuesMin = Records.earliestTransition!
        let xValuesMax = Records.latestTransition ?? Records.earliestTransition! + 1
        
        let xAxisRange = xAxisMax - xAxisMin
        let xValuesRange = xValuesMax - xValuesMin
        
        let yAxisMin = bounds.minY + topMargin
        let yAxisMax = bounds.maxY - axisOffset
        let yValuesMax = Records.longestWorkingTime > 0 ? Records.longestWorkingTime : 1
        
        let yAxisRange = yAxisMax - yAxisMin
        
        path.move(to: getOrigin(offsetBy: axisOffset))
        
        print(">> transitionPointsInCompletedWorkSessions: \(workingLog.transitionsInCompletedSessions.count)")
        var nextPoint: CGPoint?
        for transition in workingLog.transitionsInCompletedSessions {
            let x = convertValueToChartCoordinates(
                value: transition.time - xValuesMin,
                valuesRange: xValuesRange,
                axisRange: xAxisRange
            )
            
            let y = convertValueToChartCoordinates(
                value: transition.workedTime,
                valuesRange: yValuesMax,
                axisRange: yAxisRange
            )
            
            nextPoint = CGPoint(x: x + axisOffset, y: yAxisMax - y)
            path.addLine(to: nextPoint!)
            print("\(transition)")
        }
        
        path.stroke()
        path = UIBezierPath()
        // move the start of the new line to the end of the first one
        path.move(to: nextPoint ?? getOrigin(offsetBy: axisOffset))
        configureBasicProperties(path)
        path.setLineDash([10,10], count: 2, phase: 20)
        
        print(">> transitionPointsInTheCurrentWorkSession: \(workingLog.transitionsInTheCurrentSession.count)")
        for transition in workingLog.transitionsInTheCurrentSession {
            let x = convertValueToChartCoordinates(
                value: transition.time - xValuesMin,
                valuesRange: xValuesRange,
                axisRange: xAxisRange
            )
            
            let y = convertValueToChartCoordinates(
                value: transition.workedTime,
                valuesRange: yValuesMax,
                axisRange: yAxisRange
            )
            
            path.addLine(to: CGPoint(x: x + axisOffset, y: yAxisMax - y))
            print("\(transition)")
        }
        
        if let transition = workingLog.temporaryTransition {
            let x = convertValueToChartCoordinates(
                value: transition.time - xValuesMin,
                valuesRange: xValuesRange,
                axisRange: xAxisRange
            )
            
            let y = convertValueToChartCoordinates(
                value: transition.workedTime,
                valuesRange: yValuesMax,
                axisRange: yAxisRange
            )
            
            path.addLine(to: CGPoint(x: x + axisOffset, y: yAxisMax - y))
            print(">> temporaryTransition:\n\(transition)")
        }
        
        path.stroke()
        print("\n--- xValuesMin: \(xValuesMin), xValuesMax: \(xValuesMax), yValuesMax: \(yValuesMax) ---\n")
        
        plotAxisValues(yValuesMax, axisOffset, topMargin, xValuesMin, xValuesMax, xAxisMax)
    }
    
    private func configureBasicProperties(_ path: UIBezierPath) {
        UIColor(red: 37 / 255, green: 176 / 255, blue: 189 / 255, alpha: 1.0).setStroke()
        path.lineWidth = bounds.height * CGFloat(Constants.SizeRatios.quickStatsLineWidthToBoundsHeight)
    }
    
    private func getOrigin(offsetBy axisOffset: CGFloat) -> CGPoint {
        return CGPoint(x: bounds.minX + axisOffset, y: bounds.maxY - axisOffset)
    }
    
    private func convertValueToChartCoordinates(value: Int, valuesRange: Int, axisRange: CGFloat) -> CGFloat {
        return CGFloat(value) / CGFloat(valuesRange) * axisRange
    }
    
    private func plotAxisValues(_ yValuesMax: Int, _ axisOffset: CGFloat, _ topMargin: CGFloat, _ xValuesMin: Int,
                                _ xValuesMax: Int, _ xAxisMax: CGFloat) {
        var axisValuesFont = UIFont.monospacedDigitSystemFont(ofSize: 18.0, weight: UIFont.Weight.regular)
        axisValuesFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: axisValuesFont)
        
        var axisValue = NSAttributedString(string: (yValuesMax * 60).asHM, attributes: [.font: axisValuesFont])
        var axisValueWidth = axisValue.size().width
        axisValue.draw(at: CGPoint(x: axisOffset - axisValueWidth, y: bounds.minY + topMargin))
        
        axisValue = NSAttributedString(string: (xValuesMin * 60).asHM, attributes: [.font: axisValuesFont])
        axisValueWidth = axisValue.size().width
        axisValue.draw(at: CGPoint(x: axisOffset - (axisValueWidth / 2), y: bounds.maxY - axisOffset))
        
        axisValue = NSAttributedString(string: (xValuesMax * 60).asHM, attributes: [.font: axisValuesFont])
        axisValueWidth = axisValue.size().width
        axisValue.draw(at: CGPoint(x: xAxisMax - axisValueWidth, y: bounds.maxY - axisOffset))
    }
}
