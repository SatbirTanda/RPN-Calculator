//
//  GraphView.swift
//  Calculator
//
//  Created by Satbir Tanda on 4/10/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

protocol GraphViewDelegate: class {
    func getYValueFromX(xValue: CGFloat) -> CGFloat?
}

@IBDesignable class GraphView: UIView {
    
    var maximumYValue: Double?
    var minimumYValue: Double?
    
    private struct Constants {
        static let PointsPerUnit: CGFloat = 50
        static let NumberOfTapsRequired = 2
        static let ColorOfAxis = UIColor.redColor()
    }
    
    weak var dataSource: GraphViewDelegate?
    
    private var cartesianGraph: AxesDrawer {
        return AxesDrawer(color: axisColor, contentScaleFactor: contentScaleFactor)
    }
    
    @IBInspectable var axisColor: UIColor = Constants.ColorOfAxis {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    @IBInspectable var pointsPerUnit: CGFloat = Constants.PointsPerUnit {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var origin: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if origin != nil {
                let xValueOffset = origin!.x - oldValue.size.width/2
                let yValueOffset = origin!.y - oldValue.size.height/2
                origin! = CGPointMake(bounds.size.width/2 + xValueOffset, bounds.size.height/2 + yValueOffset)
                setNeedsDisplay()
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        if origin != nil {
            cartesianGraph.drawAxesInRect(bounds, origin: origin!, pointsPerUnit: pointsPerUnit)
        } else {
            origin = CGPointMake(CGFloat(bounds.size.width/2), CGFloat(bounds.size.height/2))
            cartesianGraph.drawAxesInRect(bounds, origin: origin!, pointsPerUnit: pointsPerUnit)
        }
        drawFunction()
    }
    
    func changeOrigin(gesture: UITapGestureRecognizer) {
        gesture.numberOfTapsRequired = Constants.NumberOfTapsRequired
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            origin = gesture.locationInView(self)
        default: break
        }
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            origin?.x += translation.x
            origin?.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    private func drawFunction() {
        //not my code
        let path = UIBezierPath()
        var firstValue = true
        var point = CGPoint()
        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            point.x = CGFloat(i) / contentScaleFactor
            if let y = dataSource?.getYValueFromX((point.x - origin!.x) / pointsPerUnit) {
                if !y.isNormal && !y.isZero {
                    firstValue = true
                    continue
                }
                point.y = origin!.y - y * pointsPerUnit
                if firstValue {
                    path.moveToPoint(point)
                    firstValue = false
                } else {
                    path.addLineToPoint(point)
                }
            } else {
                firstValue = true
            }
        }
        path.stroke()
        //not my code
    }
    
    
        
}
