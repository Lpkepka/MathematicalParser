//
//  EquationParser.swift
//  TextCalculation
//
//  Created by Lukasz Kepka on 29/06/2019.
//  Copyright © 2019 Lukasz Kepka. All rights reserved.
//

import Foundation

class MathematicalEquationParser {
    
    static var shared = MathematicalEquationParser()
    
    func processEquation(fromString equation: String, completion: (Double?)->()) {
        let regex = "([0-9.,()+-/*])"
        
        guard equation.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil else {
            print("Not right characters")
            completion(nil)
            return
        }
        
        let openParanthesisCount = equation.filter { $0 == "(" }.count
        let closeParanthesisCount = equation.filter { $0 == ")" }.count
        
        guard openParanthesisCount == closeParanthesisCount else {
            print("Different number of paranthesis")
            completion(nil)
            return
        }
        
        let unifiedEquation = equation.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")
        
        recursiveStringCalculation(fromString: unifiedEquation, completion: { result in
            completion(result)
        })
    }
    
    private func recursiveStringCalculation(fromString equation: String, completion: (Double?)->()) {
        let bufferedEquation = equation
        
        //This if else structure provides us with the correct order of executing mathematical operations
        if equation.contains("(") && equation.contains(")") {
            let stringAfterLastOpenParanthesis = equation.split(separator: "(").last!
            let equationWithoutParanthesis = stringAfterLastOpenParanthesis.split(separator: ")").first!
            recursiveStringCalculation(fromString: String(equationWithoutParanthesis)) { (result) in
                let newEquation = bufferedEquation.replacingOccurrences(of: "(\(equationWithoutParanthesis))", with: "\(result!)")
                recursiveStringCalculation(fromString: newEquation, completion: completion)
            }
        } else if equation.contains("*") {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "*")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else if equation.contains("/") {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "/")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else if equation.contains("+") {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "+")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else if equation.contains("-") && equation.prefix(1) != "-" {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "-")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else {
            completion(Double(equation))
        }
    }
    
    func getIndex(forOperation operation: String, inEquation equation: String, searchingForNext isNext: Bool) -> Int {
        //Worst case scenario for first index and last index
        let defaultValue = isNext ? equation.count - 1 : 0
        if isNext {
            return equation.firstIndex(of: operation.first!)?.utf16Offset(in: equation) ?? defaultValue
        } else {
            return equation.lastIndex(of: operation.first!)?.utf16Offset(in: equation) ?? defaultValue
        }
    }
    
    
    private func getIndexOfOperation(fromString equation: String, searchingForNextOperation isNext: Bool) -> Int {
        let plusIndex = getIndex(forOperation: "+", inEquation: equation, searchingForNext: isNext)
        let minusIndex = getIndex(forOperation: "-", inEquation: equation, searchingForNext: isNext)
        let divisionIndex = getIndex(forOperation: "/", inEquation: equation, searchingForNext: isNext)
        let multiplicationIndex = getIndex(forOperation: "*", inEquation: equation, searchingForNext: isNext)
        
        let defaultValue = isNext ? equation.count - 1 : 0
        
        guard plusIndex != defaultValue || minusIndex != defaultValue || divisionIndex != defaultValue || multiplicationIndex != defaultValue else {
            return defaultValue
        }
        
        if isNext {
            return min(plusIndex, minusIndex, divisionIndex, multiplicationIndex)
        } else {
            return max(plusIndex, minusIndex, divisionIndex, multiplicationIndex)
        }
    }
    
    private func computeOneBlockOfText(ofEquation equation: String, withOperation operation: String) -> String {
        let splitEquation = equation.split(separator: operation.first!)
        let indexOfPreviousOperation = getIndexOfOperation(fromString: String(splitEquation[0]), searchingForNextOperation: false)
        let indexOfNextOperation = getIndexOfOperation(fromString: String(splitEquation[1]), searchingForNextOperation: true)
        
        var firstComponent = splitEquation[0].suffix(splitEquation[0].count - indexOfPreviousOperation-1)
        if indexOfPreviousOperation == 0 {
            firstComponent = splitEquation[0]
        }
        
        var secondComponent = splitEquation[1].prefix(indexOfNextOperation)
        if indexOfNextOperation == splitEquation[1].count - 1 {
            secondComponent = splitEquation[1]
        }
        
        let result = executeBasicOperation(firstComponent: String(firstComponent),
                                           secondComponent: String(secondComponent),
                                           withOperation: operation)
        
        let range = equation.range(of: firstComponent + operation + secondComponent)!
        let newEquation = equation.replacingCharacters(in: range, with: "\(result!)")
        return newEquation
    }
    
    
    
    private func executeBasicOperation(firstComponent: String, secondComponent: String, withOperation operation: String) -> Double? {
        
        guard let firstDouble = Double(firstComponent), let secondDouble = Double(secondComponent) else {
            return nil
        }
        
        switch operation {
        case "+":
            return firstDouble + secondDouble
        case "-":
            return firstDouble - secondDouble
        case "*":
            return firstDouble * secondDouble
        case "/":
            return firstDouble/secondDouble
        default:
            return nil
        }
    }
}
