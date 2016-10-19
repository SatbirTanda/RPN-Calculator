//
//  CalculatorViewController
//  Calculator
//
//  Created by Satbir Tanda on 3/7/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    /*Properties*/
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInMiddleOfTypingNumber = false
    
    var displayValue: Double? {
        get{
            if display.text != " " {
                return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
            return nil
        }
        set{
            history.text = brain.description
            if newValue == nil {
                display.text = " "
            } else {
                display.text = "\(newValue!)"
            }
            userIsInMiddleOfTypingNumber = false
        }
    }
    
    var brain = CalculatorBrain()
    
    /*Properties*/
    
    @IBAction func displayDigit(sender: UIButton)
    {
        let digit = sender.currentTitle!
        if userIsInMiddleOfTypingNumber {
            if (digit == "." && display.text!.rangeOfString(".") != nil){}
            else { display.text = display.text! + digit }
        } else {
            if (digit == ".") {
                if display.text == " " {
                    display.text = "0."
                }
            } else {
                display.text = digit
            }
            userIsInMiddleOfTypingNumber = true
        }
    }
    
    @IBAction func clearButton()
    {
        brain.clearOpStack()
        displayValue = nil
        history.text = " "
    }
    
    
    @IBAction func enter()
    {
        userIsInMiddleOfTypingNumber = false
        if let result = displayValue {
            displayValue = brain.pushOperand(result)
        } else {
            //display value is nil, error
            displayValue = nil
        }
    }
    
    
    @IBAction func operate(sender: UIButton)
    {
        if userIsInMiddleOfTypingNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }

    @IBAction func pushMVariable(sender: UIButton) {
        if let variable = sender.currentTitle {
            enter()
            brain.pushOperand(variable)
        }
    }

    @IBAction func setMVariable() {
        brain.variableValues["M"] = displayValue
        userIsInMiddleOfTypingNumber = false
        displayValue = brain.evaluate()
    }
    
    /*@IBAction func undoButton() {
        if userIsInMiddleOfTypingNumber {
            if count(display.text!) > 1 {
                display.text = dropLast(display.text!)
            } else {
                displayValue = 0
                userIsInMiddleOfTypingNumber = false
            }
        } else {
            brain.undo()
            displayValue = brain.evaluate()
        }
    }*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "Graph Current Expression":
                    let functions = brain.description.componentsSeparatedByString(", ")
                    if let function = functions.last {
                        gvc.title = function + " f(M)"
                        gvc.program = brain.program
                    }
                default: break
                }
            }
        }
    }
}

