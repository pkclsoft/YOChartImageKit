//
//  YODonutChartImage.swift
//
//  Created by Peter Easdown on 12/3/20.
//
// Built upon the foundations provided by https://github.com/yasuoza/YOChartImageKit to provide
// a swift implementation of YODonutChartImage.
//
import Foundation
import UIKit

/**
 *  A donut chart image generator provides a donut chart image without `QuartzCore.framework` and `UIView`.
 */
class YODonutChartImage {
    
    
    /** @name Donut chart rendering properties */
    
    /**
     *  The array of values for the donut chart. `values` should be an array of NSNumber.
     *  You must provide `values`, otherwise raises an exception.
     */
    var values : Array<NSNumber>
    
    /**
     *  The array of colors for the donut chart. `colors` should be an array of UIColor.
     *  You must provide `colors`, otherwise raises an exception.
     */
    var colors : Array<UIColor>
    
    /**
     *  The point where the donut starts
     *  The default width is `pi / 2.0`, which means the degree 0 of the circle.
     */
    var startAngle : CGFloat
    
    /**
     *  The width of donut.
     *  The default width is `1.0`.
     */
    var donutWidth : CGFloat
    
    /**
     *  The text of center label in donut chart.
     *  The default text is `nil`.
     */
    var labelText : String?
    
    /**
     *  The color of center label in donut chart.
     *  The default color is black.
     */
    var labelColor : UIColor
    
    /**
     *  The font of center label in donut chart.
     *  The default font is UIFont with UIFontTextStyleBody.
     */
    var labelFont : UIFont
    
    init() {
        self.startAngle = CGFloat.pi / 2.0
        self.donutWidth = 1.0
        self.labelColor = .black
        self.labelFont = UIFont.preferredFont(forTextStyle: .body)
        self.colors = Array()
        self.values = Array()
    }
    
    func drawImage(inFrame frame: CGRect, scale: CGFloat) -> UIImage {
        assert(values.count > 0, "YODonutChartImage // must assign values property which is an array of NSNumber")
        assert(colors.count >= values.count, "YOGraphPieChartImage // must assign colors property which is an array of UIColor")
        
        #if os(iOS)
        return self.drawImagePreferringImageRenderer(inFrame: frame, scale: scale)
        #else
        return self.drawImageForGeneral(inFrame: frame, scale: scale)
        #endif
    }
    
    // MARK: - Draw Image(Private)
    
    #if os(iOS)
    private func drawImagePreferringImageRenderer(inFrame frame: CGRect, scale: CGFloat) -> UIImage {
        return UIGraphicsImageRenderer(size: frame.size).image { (context) in
            self.drawPath(inFrame: frame)
        }
    }
    #endif
    
    private func drawImageForGeneral(inFrame frame: CGRect, scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        self.drawPath(inFrame: frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // MARK: - Draw Paths(Private)
    
    private func drawPath(inFrame frame: CGRect) {
        let totalValue : Float = values.reduce(into: 0.0, { (total, number) in
            total += number.floatValue
        })
        
        let center = frame.size.centreOf().toPoint()
        
        let maxLength : CGFloat = min(frame.size.width, frame.size.height)
        let radius : CGFloat = maxLength / 2 - self.donutWidth / 2
        
        if let text = self.labelText {
            let attributes = [NSAttributedString.Key.foregroundColor : self.labelColor,
                              NSAttributedString.Key.font : self.labelFont]
            
            let size = text.boundingRect(with: CGSize(width: maxLength, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine] , attributes: attributes, context: nil).size
            
            text.draw(at: CGPoint(x: center.x - size.width/2.0, y: center.y - size.height/2.0), withAttributes: attributes)
        }
        
        self.values.enumerated().forEach { (element) in
            let normalizedValue = CGFloat(element.element.floatValue / totalValue)
            let strokeColor = self.colors[element.offset]
            
            let endAngle = self.startAngle + 2.0 * CGFloat.pi * normalizedValue
            let donutPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: self.startAngle, endAngle: endAngle, clockwise: true)
            donutPath.lineWidth = self.donutWidth
            strokeColor.setStroke()
            donutPath.stroke()
            self.startAngle = endAngle
        }
    }
    
}
