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
    
    private func calculateResult(firstComponent: String, secondComponent: String, operation: String) -> Double? {
        
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
    
    func processEquation(fromString equation: String, completion: (Double?)->()){
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
    
    private func getIndexOfOperation(fromString equation: String, nextOperation: Bool) -> Int {
        //Worst case scenario for first index and last index
        let defaultValue = nextOperation ? equation.count - 1 : 0
        
        if nextOperation {
            let plusIndex = equation.firstIndex(of: "+")?.utf16Offset(in: equation) ?? defaultValue
            let minusIndex = equation.firstIndex(of: "-")?.utf16Offset(in: equation) ?? defaultValue
            let divisionIndex = equation.firstIndex(of: "/")?.utf16Offset(in: equation) ?? defaultValue
            let multiplicationIndex = equation.firstIndex(of: "*")?.utf16Offset(in: equation) ?? defaultValue
            
            guard plusIndex != defaultValue || minusIndex != defaultValue || divisionIndex != defaultValue || multiplicationIndex != defaultValue else {
                return defaultValue
            }
            
            return min(plusIndex, minusIndex, divisionIndex, multiplicationIndex)
        } else {
            let plusIndex = equation.lastIndex(of: "+")?.utf16Offset(in: equation) ?? defaultValue
            let minusIndex = equation.lastIndex(of: "-")?.utf16Offset(in: equation) ?? defaultValue
            let divisionIndex = equation.lastIndex(of: "/")?.utf16Offset(in: equation) ?? defaultValue
            let multiplicationIndex = equation.lastIndex(of: "*")?.utf16Offset(in: equation) ?? defaultValue
            
            guard plusIndex != defaultValue || minusIndex != defaultValue || divisionIndex != defaultValue || multiplicationIndex != defaultValue else {
                return defaultValue
            }
            
            return max(plusIndex, minusIndex, divisionIndex, multiplicationIndex)
        }
    }
    
    private func recursiveStringCalculation(fromString equation: String, completion: (Double?)->()) {
        let bufferedEquation = equation
        print(equation)
        if equation.contains("(") && equation.contains(")") {
            let stringAfterLastOpenParanthesis = equation.split(separator: "(").last!
            let equationWithoutParanthesis = stringAfterLastOpenParanthesis.split(separator: ")").first!
            let stringWithoutParanthesis = equationWithoutParanthesis.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            recursiveStringCalculation(fromString: stringWithoutParanthesis) { (result) in
                let newEquation = bufferedEquation.replacingOccurrences(of: "(\(equationWithoutParanthesis))", with: "\(result!)")
                recursiveStringCalculation(fromString: newEquation, completion: completion)
            }
        } else if equation.contains("*") {
            let splitEquation = equation.split(separator: "*")
            let indexOfPreviousOperation = getIndexOfOperation(fromString: String(splitEquation[0]), nextOperation: false)
            let indexOfNextOperation = getIndexOfOperation(fromString: String(splitEquation[1]), nextOperation: true)
            var firstComponent = splitEquation[0].suffix(splitEquation[0].count - indexOfPreviousOperation-1)
            if indexOfPreviousOperation == 0 {
                firstComponent = splitEquation[0]
            }
            var secondComponent = splitEquation[1].prefix(indexOfNextOperation)
            if indexOfNextOperation == splitEquation[1].count - 1 {
                secondComponent = splitEquation[1]
            }
            let result = calculateResult(firstComponent: firstComponent.description, secondComponent: secondComponent.description, operation: "*")
            let range = bufferedEquation.range(of: firstComponent + "*" + secondComponent)!
            let newEquation = bufferedEquation.replacingCharacters(in: range, with: "\(result!)")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else if equation.contains("/") {
            let splitEquation = equation.split(separator: "/")
            let indexOfPreviousOperation = getIndexOfOperation(fromString: String(splitEquation[0]), nextOperation: false)
            let indexOfNextOperation = getIndexOfOperation(fromString: String(splitEquation[1]), nextOperation: true)
            var firstComponent = splitEquation[0].suffix(splitEquation[0].count - indexOfPreviousOperation-1)
            if indexOfPreviousOperation == 0 {
                firstComponent = splitEquation[0]
            }
            var secondComponent = splitEquation[1].prefix(indexOfNextOperation)
            if indexOfNextOperation == splitEquation[1].count - 1 {
                secondComponent = splitEquation[1]
            }
            let result = calculateResult(firstComponent: firstComponent.description, secondComponent: secondComponent.description, operation: "/")
            let range = bufferedEquation.range(of: firstComponent + "/" + secondComponent)!
            let newEquation = bufferedEquation.replacingCharacters(in: range, with: "\(result!)")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else if equation.contains("+") {
            let splitEquation = equation.split(separator: "+")
            let indexOfPreviousOperation = getIndexOfOperation(fromString: String(splitEquation[0]), nextOperation: false)
            let indexOfNextOperation = getIndexOfOperation(fromString: String(splitEquation[1]), nextOperation: true)
            var firstComponent = splitEquation[0].suffix(splitEquation[0].count - indexOfPreviousOperation-1)
            if indexOfPreviousOperation == 0 {
                firstComponent = splitEquation[0]
            }
            var secondComponent = splitEquation[1].prefix(indexOfNextOperation)
            if indexOfNextOperation == splitEquation[1].count - 1 {
                secondComponent = splitEquation[1]
            }
            let result = calculateResult(firstComponent: firstComponent.description, secondComponent: secondComponent.description, operation: "+")
            let range = bufferedEquation.range(of: firstComponent + "+" + secondComponent)!
            let newEquation = bufferedEquation.replacingCharacters(in: range, with: "\(result!)")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else if equation.contains("-") && equation.prefix(1) != "-" {
            let splitEquation = equation.split(separator: "-")
            let indexOfPreviousOperation = getIndexOfOperation(fromString: String(splitEquation[0]), nextOperation: false)
            let indexOfNextOperation = getIndexOfOperation(fromString: String(splitEquation[1]), nextOperation: true)
            var firstComponent = splitEquation[0].suffix(splitEquation[0].count - indexOfPreviousOperation-1)
            if indexOfPreviousOperation == 0 {
                firstComponent = splitEquation[0]
            }
            var secondComponent = splitEquation[1].prefix(indexOfNextOperation)
            if indexOfNextOperation == splitEquation[1].count - 1 {
                secondComponent = splitEquation[1]
            }
            let result = calculateResult(firstComponent: firstComponent.description, secondComponent: secondComponent.description, operation: "-")
            let range = bufferedEquation.range(of: firstComponent + "-" + secondComponent)!
            let newEquation = bufferedEquation.replacingCharacters(in: range, with: "\(result!)")
            recursiveStringCalculation(fromString: newEquation, completion: completion)
        } else {
            print("Final result = ", equation)
            completion(Double(equation))
        }
    }
}
