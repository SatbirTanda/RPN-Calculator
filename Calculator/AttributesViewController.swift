//
//  AttributesViewController.swift
//  Calculator
//
//  Created by Satbir Tanda on 4/19/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

class AttributesViewController: UIViewController
{

    @IBOutlet weak var textView: UITextView! {
        didSet {
            if minimumYValue != nil && maximumYValue != nil {
                textView.text = "Maximum Y-Value: \(maximumYValue!)\nMinimum Y-Value: \(minimumYValue!)"
            } else {
                textView.text = "Maximum Y-Value:\nMinimum Y-Value:"
            }
        }
    }
    
    var minimumYValue: Double?
    var maximumYValue: Double?
    
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil {
                return textView.sizeThatFits(presentingViewController!.view.bounds.size)
            } else {
                return super.preferredContentSize
            }
        } set {
            super.preferredContentSize = newValue
        }
    }

}
