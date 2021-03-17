//
//  MultiValueChartImage.swift
//
//  Created by Peter Easdown on 12/3/20.
//
// Built upon the foundations provided by https://github.com/yasuoza/YOChartImageKit to provide
// a bar chart where a bar can have multiple values.  
//

import Foundation
import UIKit

class MultiValueChartImage {

    enum BarStyle {
        case vertical
        case horizontal
    }

    /// The maximum number of values in a bar.  A bar can br broken into this many sections, each
    /// given it's own colour.  It is expected that for each bar, the values property will contain an
    /// array of numbers, each representing a value between 0 and maxValues.
    var maxValues : Int = 0

    /// The value of a given cell within a bar, and it's associated colour.
    struct BarCellValue {
        var value : Int
        var colour : UIColor
    }

    /// This structure will represent a set of values for a single bar.  There should never be more than
    /// maxValues elements in the array, any extras will be ignored.
    struct BarValue {
        var values: Array<BarCellValue>
    }

    /** @name Multi Value chart rendering properties */

    /**
     *  The array of values for the bar chart. `values` should be an array of BarValue.
     */
    var values: Array<BarValue> = []

    /**
     *  The style of the bar chart,  defaults to vertical.
     */
    var style: BarStyle = .vertical

    /**
     *  The padding of each bars.
     *  The default padding is automatically calculated by count of values.
     *  Use this property when you want to set the bar padding explicitly.
     */
    var barPadding : CGFloat = 0.0

    /**
     *  The width of chart's stroke.
     *  The default width is `0.0`.
     */
    var strokeWidth: CGFloat = 0.0

    /**
     *  The color of chart's stroke.
     *  The default color is `white`.
     */
    var strokeColor: UIColor = .white

    //-------Rounded caps settings-------//
    /**
     *  If TRUE, the bars will end with rounded caps
     */
    var roundedCaps : Bool = true

    /**
     *  The corner radius for the bars rounded caps
     *  (used only if "roundedCaps" property is true
     */
    var capsCornerRadius: CGFloat = 5.0

    /** @name Drawing a chart **/

    private let kBarPaddingMultiplier : CGFloat = 20.0


    /**
     *  Draws a image of bar chart.
     *
     *  @param frame The frame rectangle for the chart image.
     *  @param scale The scale factor for chart image.
     *
     *  @return An bar chart drawed `UIImage` object.
     */
    func draw(_ frame: CGRect, atScale scale: CGFloat) -> UIImage? {
        if values.count > 0 {
            let maxValue = CGFloat(self.maxValues)
            let dataCount = CGFloat(self.values.count)

            let padding = (barPadding > 0.0) ? barPadding : ceil(1.0 / dataCount * kBarPaddingMultiplier)

            let totalPadding = (dataCount - 1.0) * padding
            let totalWidth = (style == .vertical) ? (frame.size.width - totalPadding) : (frame.size.height - totalPadding)
            let barWidth = totalWidth / dataCount

            UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
            
            // start by drawing horizontal lines across the graph area for each step of 1 up to maxValue - 1
            //
            for lineValue in 1 ..< self.maxValues {
                let normalizedValue = CGFloat(lineValue) / maxValue

                let rect = CGRect(x: CGFloat(0.0),
                                  y: (frame.size.height * (1.0 - normalizedValue)),
                                  width: frame.size.width,
                                  height: 1.0)

                let path : UIBezierPath

                path = UIBezierPath(rect: rect)
                path.lineWidth = strokeWidth
                UIColor.gray.setFill()
                path.fill()

                strokeColor.setStroke()
                path.stroke()
            }

            var barIndex = 0

            // for every bar of data
            self.values.makeIterator().forEach { (barValue) in
                var startPos : CGFloat = 0.0

//                print("bar(\(barIndex)) has \(barValue.values.count) values")

                var valueIndex = 0

                // need to work out which cell is the last with a value.
                let lastFilledIndex : Int = barValue.values.lastIndex { (value) -> Bool in
                    return value.value > 0
                    } ?? 0

                // for every value in that bar
                barValue.values.makeIterator().forEach { (value) in
                    // each value represents a value between 0 and maxValues.
                    // we need to draw a bar made up of rectangles, one for each non-zero
                    // value, where the stretch dimension of the rectangle is a relative
                    // to the maxvalue.
                    //
                    let normalizedValue = CGFloat(value.value) / maxValue

//                    print("bar(\(barIndex), \(valueIndex) value: \(value.value), normalized: \(normalizedValue), startPos: \(startPos)")

                    var rect: CGRect

                    if style == .vertical {
                        rect = CGRect(x: CGFloat(barIndex) * (barWidth + padding) + strokeWidth / 2.0,
                                      y: (frame.size.height * (1.0 - normalizedValue)) + (strokeWidth / 2.0) - startPos,
                                      width: barWidth - strokeWidth,
                                      height: frame.size.height * normalizedValue)

                        startPos = startPos + rect.height
                    } else {
                        rect = CGRect(x: -strokeWidth,
                                      y: CGFloat(barIndex) * (barWidth + padding) + self.strokeWidth / 2.0,
                                      width: frame.size.width * startPos + normalizedValue + strokeWidth / 2.0,
                                      height: barWidth - strokeWidth)

                        startPos = startPos + rect.width
                    }

//                    print("bar(\(barIndex), \(valueIndex) startPos: \(startPos), rec: \(rect)")

                    let path : UIBezierPath

                    if self.roundedCaps && (valueIndex == lastFilledIndex) {
                        path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner(arrayLiteral: .topLeft, .topRight), cornerRadii: CGSize(width: self.capsCornerRadius, height: self.capsCornerRadius))
                    } else {
                        path = UIBezierPath(rect: rect)
                    }
                    path.lineWidth = strokeWidth
                    value.colour.withAlphaComponent(0.7).setFill()
                    path.fill()

                    strokeColor.setStroke()
                    path.stroke()

                    valueIndex = valueIndex + 1
                }

                barIndex = barIndex + 1
            }

            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return result
        }

        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result!
    }

}
