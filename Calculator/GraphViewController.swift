//
//  GraphViewController.swift
//  Calculator
//
//  Created by Satbir Tanda on 4/10/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDelegate, UIPopoverPresentationControllerDelegate {
    
    typealias PropertyList = AnyObject
    var program: PropertyList?

    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "changeOrigin:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
            graphView.dataSource = self
        }
    }
    
    @IBAction func zoomIn(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            graphView.pointsPerUnit *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    
    func getYValueFromX(xValue: CGFloat) -> CGFloat? {
        if program != nil {
            var brain = CalculatorBrain()
            brain.program = program!
            brain.variableValues["M"] = Double(xValue)
            if brain.evaluate() != nil {
                if let calculation = brain.evaluate() {
                    if graphView.minimumYValue > calculation || graphView.minimumYValue == nil {
                        graphView.minimumYValue = calculation
                    }
                    if graphView.maximumYValue < calculation || graphView.maximumYValue == nil {
                        graphView.maximumYValue = calculation
                    }
                    let yValue = CGFloat(calculation)
                    return yValue
                }
            }
        }
        return nil
    }
    
    private struct Segues {
        static let ToAttributesPopOver = "Show Attributes"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Segues.ToAttributesPopOver {
                if let avc = segue.destinationViewController as? AttributesViewController {
                    avc.popoverPresentationController?.delegate = self
                    avc.maximumYValue = graphView.maximumYValue
                    avc.minimumYValue = graphView.minimumYValue
                }
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}
