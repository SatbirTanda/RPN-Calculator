//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Satbir Tanda on 3/19/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var opStack = [Op]()
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newStack.append(.Operand(operand))
                    }
                }
                opStack = newStack
            }
        }
    }
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case ConstantOperation(String, Double)
        case VariableOperation(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let operation, _):
                    return operation
                case .BinaryOperation(let operation, _):
                    return operation
                case .ConstantOperation(let symbol, _):
                    return symbol
                case .VariableOperation(let variable):
                    return variable
                }
            }
        }
    }
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(.BinaryOperation("×", *))
        learnOp(.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("−") {$1 - $0})
        learnOp(.UnaryOperation("√", sqrt))
        learnOp(.UnaryOperation("cos", cos))
        learnOp(.UnaryOperation("sin", sin))
        learnOp(.ConstantOperation("π", M_PI))
        learnOp(.VariableOperation("M"))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .ConstantOperation(_, let constant):
                return (constant, remainingOps)
            case .VariableOperation(let variable):
                return (variableValues[variable], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    
     var description: String {
        get {
            if let history = historySeparatedByCommas(opStack) {
                return "\(history) ="
            }
            return " "
        }
    }
    
    private func historySeparatedByCommas(remainingOps: [Op], var history: [String] = []) -> String? {
        let (stackHistory, remainder) = describe(remainingOps)
        history.insert((stackHistory ?? " "), atIndex: 0)
        if remainder.isEmpty {
            return ", ".join(history)
        } else {
            return historySeparatedByCommas(remainder, history: history)
        }
    }
    
    private func describe(ops: [Op]) -> (description: String?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .ConstantOperation(let constant, _):
                return (constant, remainingOps)
            case .VariableOperation(let variable):
                return (variable, remainingOps)
            case .UnaryOperation(let operation, _):
                let next = describe(remainingOps)
                if let description = next.description {
                    return (operation + "(\(description))", next.remainingOps)
                } else {
                    return (operation + "(?)", next.remainingOps)
                }
            case .BinaryOperation(let operation, _):
                let next = describe(remainingOps)
                if let descriptionOfNext = next.description {
                    let nextAfter = describe(next.remainingOps)
                    if let descriptionOfNextAfter = nextAfter.description {
                        return ("(\(descriptionOfNextAfter)\(operation)\(descriptionOfNext))" , nextAfter.remainingOps)
                    } else {
                        return ("(\(descriptionOfNext)\(operation)?)" , nextAfter.remainingOps)
                    }
                } else {
                    return ("(?\(operation)?)" , next.remainingOps)
                }
            }
        }
        return (nil, ops)
    }
    
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        println(self.description)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.VariableOperation(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOpStack(){
        opStack.removeAll(keepCapacity: false)
        variableValues.removeAll(keepCapacity: false)
    }
    
    func undo() {
        if count(opStack) > 0 {
            opStack.removeLast()
        }
    }
}