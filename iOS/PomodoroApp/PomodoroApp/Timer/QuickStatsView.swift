import UIKit

class QuickStatsView: UIView {
    weak var workDayDataSource: WorkDayDataSource!
    
    override func draw(_ rect: CGRect) {
        let workingLog = workDayDataSource.workingLogForCurrentDay()
        
        let topMargin = bounds.height * Constants.SizeRatios.quickStatsTopMarginToBoundsHeight
        let rightMargin = bounds.height * Constants.SizeRatios.quickStatsRightMarginToBoundsWidth
        let tinySpace = bounds.width * Constants.SizeRatios.tinySpaceToBoundsWidth
        
        // set the font size for the axis values
        let axisValuesFontSize = Constants.SizeRatios.axisValuesFontSizeToBoundHeight * bounds.width
        var axisValuesFont = UIFont.monospacedDigitSystemFont(ofSize: axisValuesFontSize, weight: UIFont.Weight.regular)
        axisValuesFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: axisValuesFont)
        
        // creates the value to be drawn at the top of the y axis
        let yValuesMax: Int
        if let workTimeGoal = Settings.workTimeGoal, (workTimeGoal / 60) > Records.longestWorkingTime {
            yValuesMax = workTimeGoal / 60
        } else {
            yValuesMax = Records.longestWorkingTime
        }
        let maxYTickLabel = NSAttributedString(string: (yValuesMax * 60).asHM, attributes: [.font: axisValuesFont])
        maxYTickLabel.draw(at: CGPoint(x: (5 * tinySpace), y: bounds.minY + (3 * tinySpace)))
        
        let yAxisOffset = tinySpace // space required to draw a value next to the y axis
        
        // finds out the limits of the x axis and draws its values
        var xValuesMin: Int!
        var xValuesMax: Int!
        let minXTickLabel: NSAttributedString
        let maxXTickLabel: NSAttributedString
        
        var bestPossibleEndTime: Int? = nil
        var expectedEndTime: Int? = nil
        var predictedEndTime: Int? = nil
        
        if let earliestTransition = Records.earliestTransition {
            xValuesMin = earliestTransition
            
            if let mostRecentTransition = workingLog.mostRecentTransition {
                xValuesMax = mostRecentTransition.time
                
                if let remainingWorkingTime = workDayDataSource.workTimeRemainingForCurrentDay() {
                    bestPossibleEndTime = mostRecentTransition.time + Int(ceil(Double(remainingWorkingTime / 60)))
                    xValuesMax = bestPossibleEndTime
                }
                
                if let timeOnPauseLeft = workDayDataSource.timeOnPauseRemainingForCurrentDay() {
                    expectedEndTime = bestPossibleEndTime! + (timeOnPauseLeft / 60)
                    xValuesMax = expectedEndTime
                }
                
                if let timeAtStart = workingLog.startTime {
                    let currentWorkTime = mostRecentTransition.workedTime
                    let currentTime = mostRecentTransition.time
                    let timeRange = currentTime - timeAtStart
                    
                    if (currentWorkTime != 0) {
                        predictedEndTime = Int(floor(
                            (Double(timeRange) / Double(currentWorkTime)) *
                                Double(Settings.workTimeGoal! / 60) +
                                Double(timeAtStart)
                        ))
                        
                        if predictedEndTime! > xValuesMax {
                            xValuesMax = predictedEndTime!
                        }
                        
                        print("predictedEndTime: \(predictedEndTime!)")
                    }
                }
                
                if let latestTransition = Records.latestTransition {
                    if latestTransition > xValuesMax {
                        xValuesMax = Records.latestTransition
                    }
                }
            } else {
                xValuesMax = earliestTransition + 1
            }
            
            minXTickLabel = NSAttributedString(string: (xValuesMin * 60).asHM, attributes: [.font: axisValuesFont])
            
            if xValuesMax < 24 * 60 {
                maxXTickLabel = NSAttributedString(string: (xValuesMax * 60).asHM, attributes: [.font: axisValuesFont])
            } else {
                maxXTickLabel = NSAttributedString(string: "∞", attributes: [.font: axisValuesFont])
                xValuesMax = 24 * 60
            }
        } else { // happens only when the app is initialized for the first time
            minXTickLabel = NSAttributedString(string: "--:--", attributes: [.font: axisValuesFont])
            maxXTickLabel = minXTickLabel
        }
        
        let minXTickLabelHeight = minXTickLabel.size().height
        let maxXTickLabelWidth = maxXTickLabel.size().width
        
        minXTickLabel.draw(at: CGPoint(x: yAxisOffset, y: bounds.maxY - tinySpace - minXTickLabelHeight))
        maxXTickLabel.draw(at: CGPoint(x: bounds.maxX - rightMargin - maxXTickLabelWidth, y: bounds.maxY - tinySpace - minXTickLabelHeight))
        
        let xAxisOffset = minXTickLabelHeight + (tinySpace * 2) // space required to draw a value under the x axis
        
        let origin = CGPoint(x: yAxisOffset, y: bounds.maxY - xAxisOffset)
        
        // draw the axis
        var path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: CGPoint(x: bounds.maxX - rightMargin, y: bounds.maxY - xAxisOffset)) // x axis
        path.move(to: origin)
        path.addLine(to: CGPoint(x: yAxisOffset, y: topMargin)) // y axis
        path.stroke()
        
        let yAxisMin = bounds.minY + topMargin
        let yAxisMax = bounds.maxY - xAxisOffset
        let yAxisRange = yAxisMax - yAxisMin
        
        // draw the goal line
        if let workTimeGoal = Settings.workTimeGoal {
            path = UIBezierPath()
            
            let y = convertValueToChartCoordinates(value: workTimeGoal / 60, valuesRange: yValuesMax,
                                                   axisRange: yAxisRange)
            
            path.move(to: CGPoint(x: yAxisOffset, y: yAxisMax - y))
            path.addLine(to: CGPoint(x: bounds.maxX - rightMargin, y: yAxisMax - y))
            
            let goalLineDashLength = 4 * tinySpace
            path.setLineDash([goalLineDashLength, goalLineDashLength], count: 2, phase: 2 * goalLineDashLength)
            
            UIColor(named: "Green1")?.setStroke()
            path.stroke()
        }
        
        // draw the axis ticks
        path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: CGPoint(x: yAxisOffset, y: bounds.maxY - xAxisOffset + (4 * tinySpace))) // minXTick
        path.move(to: CGPoint(x: bounds.maxX - rightMargin, y: bounds.maxY - xAxisOffset))
        path.addLine(to: CGPoint(x: bounds.maxX - rightMargin, y: bounds.maxY - xAxisOffset + (4 * tinySpace)))
        path.move(to: CGPoint(x: yAxisOffset, y: topMargin))
        path.addLine(to: CGPoint(x: yAxisOffset + (4 * tinySpace), y: topMargin)) // maxYTick
        UIColor.black.setStroke()
        path.stroke()
        
        // draw the chart box
//        path = UIBezierPath()
//        path.move(to: CGPoint(x: 0.0, y: bounds.maxY))
//        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
//        path.addLine(to: CGPoint(x: bounds.maxX, y: 0.0))
//        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
//        path.close()
//        path.stroke()
        
        if Records.earliestTransition == nil { return }
        
        let xAxisMin = yAxisOffset
        let xAxisMax = bounds.maxX - rightMargin
        let xAxisRange = xAxisMax - xAxisMin
        let xValuesRange = xValuesMax - xValuesMin

        let chartHeight = bounds.height - topMargin - xAxisOffset

        path = UIBezierPath()
        path.move(to: origin)
        path.lineWidth = chartHeight * Constants.SizeRatios.chartsLineWidthToChartHeight
        UIColor(named: "SteelBlue")?.setStroke()

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

            nextPoint = CGPoint(x: x + yAxisOffset, y: yAxisMax - y)
            path.addLine(to: nextPoint!)
            print("\(transition)")
        }
        path.stroke()

        path = UIBezierPath()
        path.move(to: nextPoint ?? origin) // move the start of the new line to the end of the first one
        path.lineWidth = chartHeight * Constants.SizeRatios.chartsLineWidthToChartHeight
        UIColor(named: "SteelBlue")?.setStroke()
        
        let mainLineDashLength = 4 * tinySpace
        path.setLineDash([mainLineDashLength, mainLineDashLength], count: 2, phase: 2 * mainLineDashLength)

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

            path.addLine(to: CGPoint(x: x + yAxisOffset, y: yAxisMax - y))
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

            path.addLine(to: CGPoint(x: x + yAxisOffset, y: yAxisMax - y))
            print(">> temporaryTransition:\n\(transition)")
        }
        path.stroke()
        
        // when users define a workTimeGoal, we draw a vertical dashed line to represent earliest moment they can reach
        // their goal
        if let mostRecentTransition = workingLog.mostRecentTransition {
            print("bestPossibleEndTime: \(bestPossibleEndTime!)")
            
            var x = convertValueToChartCoordinates(
                value: bestPossibleEndTime! - xValuesMin,
                valuesRange: xValuesRange,
                axisRange: xAxisRange
            )
            
            path = UIBezierPath()
            path.move(to: CGPoint(x: x + xAxisMin, y: yAxisMin))
            path.addLine(to: CGPoint(x: x + xAxisMin, y: yAxisMax))
            UIColor(named: "Green1")?.setStroke()
            let goalLineDashLength = 4 * tinySpace
            path.setLineDash([goalLineDashLength, goalLineDashLength], count: 2, phase: 2 * goalLineDashLength)
            path.stroke()
            
            // when users define a timeOnPauseGoal, we draw a vertical dashed line to represent earliest moment they can
            // finish the working session taking this time into account
            print("expectedEndTime: \(expectedEndTime!)")
            
            x = convertValueToChartCoordinates(
                value: expectedEndTime! - xValuesMin,
                valuesRange: xValuesRange,
                axisRange: xAxisRange
            )
            
            path = UIBezierPath()
            path.move(to: CGPoint(x: x + xAxisMin, y: yAxisMin))
            path.addLine(to: CGPoint(x: x + xAxisMin, y: yAxisMax))
            
            UIColor(named: "DarkOrange")?.setStroke()
            path.setLineDash([goalLineDashLength, goalLineDashLength], count: 2, phase: 2 * goalLineDashLength)
            path.stroke()
            
            if mostRecentTransition.workedTime < Settings.workTimeGoal! {
                if predictedEndTime != nil {
                    var x = convertValueToChartCoordinates(
                        value: mostRecentTransition.time - xValuesMin,
                        valuesRange: xValuesRange,
                        axisRange: xAxisRange
                    )
                    
                    var y = convertValueToChartCoordinates(
                        value: mostRecentTransition.workedTime,
                        valuesRange: yValuesMax,
                        axisRange: yAxisRange
                    )
                    
                    path = UIBezierPath()
                    path.move(to: CGPoint(x: x + yAxisOffset, y: yAxisMax - y))
                    
                    x = convertValueToChartCoordinates(
                        value: predictedEndTime! - xValuesMin,
                        valuesRange: xValuesRange,
                        axisRange: xAxisRange
                    )
                    
                    y = convertValueToChartCoordinates(
                        value: Settings.workTimeGoal! / 60,
                        valuesRange: yValuesMax,
                        axisRange: yAxisRange
                    )
                    
                    path.addLine(to: CGPoint(x: x + xAxisMin, y: yAxisMax - y))
                    
                    if predictedEndTime != bestPossibleEndTime {
                        if predictedEndTime! < (24 * 60) { // TODO: passar a verificação para cima
                            if expectedEndTime != nil && predictedEndTime != expectedEndTime! {
                                path.addLine(to: CGPoint(x: x + xAxisMin, y: yAxisMax))
                                
                                UIColor(named: "SteelBlue")?.setStroke()
                                let goalLineDashLength = 4 * tinySpace
                                path.setLineDash([goalLineDashLength, goalLineDashLength], count: 2,
                                                 phase: 2 * goalLineDashLength)
                                path.stroke()
                            }
                        }
                    }
                }
            }
            
            x = convertValueToChartCoordinates(
                value: mostRecentTransition.time - xValuesMin,
                valuesRange: xValuesRange,
                axisRange: xAxisRange
            )
            
            let y = convertValueToChartCoordinates(
                value: mostRecentTransition.workedTime,
                valuesRange: yValuesMax,
                axisRange: yAxisRange
            )
            
            path = UIBezierPath(arcCenter: CGPoint(x: x + yAxisOffset, y: yAxisMax - y),
                                radius: 3.0, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            path.lineWidth = chartHeight * Constants.SizeRatios.chartsLineWidthToChartHeight * 1.5
            UIColor.white.setFill()
            UIColor(named: "SteelBlue")?.setStroke()
            path.fill()
            path.stroke()
        }
        
        print("\n\n")
    }
    
    private func getOrigin(offsetBy axisOffset: CGFloat) -> CGPoint {
        return CGPoint(x: axisOffset, y: bounds.maxY - axisOffset)
    }
    
    private func convertValueToChartCoordinates(value: Int, valuesRange: Int, axisRange: CGFloat) -> CGFloat {
        return CGFloat(value) / CGFloat(valuesRange) * axisRange
    }
}
