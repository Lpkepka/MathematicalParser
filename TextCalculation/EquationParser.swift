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
            print("Incorrect characters")
            completion(nil)
            return
        }
        
        let unifiedEquation = equation.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")
        
        guard checkParanthesisOrderAndCount(inEquation: unifiedEquation) else {
            completion(nil)
            return
        }
        
        recursiveStringCalculation(fromString: unifiedEquation, completion: { result in
            completion(result)
        })
    }
    
    //MARK: - Main processing method
    
    private func recursiveStringCalculation(fromString equation: String, completion: (Double?)->()) {
        let bufferedEquation = equation
        //This if else structure provides us with the correct order of executing mathematical operations
        if equation.contains("(") && equation.contains(")") {
            let stringAfterLastOpenParanthesis = equation.split(separator: "(").last!
            let equationWithoutParanthesis = stringAfterLastOpenParanthesis.split(separator: ")").first!
            recursiveStringCalculation(fromString: String(equationWithoutParanthesis)) { (paranthesisResult) in
                guard paranthesisResult != nil else {
                    completion(nil)
                    return
                }
                let newEquation = bufferedEquation.replacingOccurrences(of: "(\(equationWithoutParanthesis))", with: "\(paranthesisResult!)")
                recursiveStringCalculation(fromString: newEquation, completion: completion)
            }
        } else if equation.contains("*") {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "*")
            guard let unwrappedNewEquation = newEquation else {
                completion(nil)
                return
            }
            recursiveStringCalculation(fromString: unwrappedNewEquation, completion: completion)
        } else if equation.contains("/") {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "/")
            guard let unwrappedNewEquation = newEquation else {
                completion(nil)
                return
            }
            recursiveStringCalculation(fromString: unwrappedNewEquation, completion: completion)
        } else if equation.contains("-") && equation.prefix(1) != "-" {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "-")
            guard let unwrappedNewEquation = newEquation else {
                completion(nil)
                return
            }
            recursiveStringCalculation(fromString: unwrappedNewEquation, completion: completion)
        } else if equation.contains("+") {
            let newEquation = computeOneBlockOfText(ofEquation: equation, withOperation: "+")
            guard let unwrappedNewEquation = newEquation else {
                completion(nil)
                return
            }
            recursiveStringCalculation(fromString: unwrappedNewEquation, completion: completion)
        } else {
            completion(Double(equation))
        }
    }
    
    //MARK: - Finding previous/next operations
    private func getIndex(forOperation operation: String, inEquation equation: String, searchingForNext isNext: Bool) -> Int {
        //Worst case scenario for first index and last index
        let defaultValue = isNext ? equation.count - 1 : 0
        if isNext {
            return equation.firstIndex(of: operation.first!)?.utf16Offset(in: equation) ?? defaultValue
        } else {
            return equation.lastIndex(of: operation.first!)?.utf16Offset(in: equation) ?? defaultValue
        }
    }
    
    
    private func getIndexOfOperation(fromString equation: String, searchingForNextOperation isNext: Bool) -> Int? {
        let plusIndex = getIndex(forOperation: "+", inEquation: equation, searchingForNext: isNext)
        let minusIndex = getIndex(forOperation: "-", inEquation: equation, searchingForNext: isNext)
        let divisionIndex = getIndex(forOperation: "/", inEquation: equation, searchingForNext: isNext)
        let multiplicationIndex = getIndex(forOperation: "*", inEquation: equation, searchingForNext: isNext)
        
        let defaultValue = isNext ? equation.count - 1 : 0
        
        guard plusIndex != defaultValue || minusIndex != defaultValue || divisionIndex != defaultValue || multiplicationIndex != defaultValue else {
            return nil
        }
        
        if isNext {
            return min(plusIndex, minusIndex, divisionIndex, multiplicationIndex)
        } else {
            return max(plusIndex, minusIndex, divisionIndex, multiplicationIndex)
        }
    }
    
    //MARK: - Processing a simple equation
    
    private func computeOneBlockOfText(ofEquation equation: String, withOperation operation: String) -> String? {
        print(equation)
        let splitEquation = equation.split(separator: operation.first!)
        
        let indexOfPreviousOperation = getIndexOfOperation(fromString: String(splitEquation[0]), searchingForNextOperation: false)
        let indexOfNextOperation = getIndexOfOperation(fromString: String(splitEquation[1]), searchingForNextOperation: true)
        
        var firstComponent: String.SubSequence
        var secondComponent: String.SubSequence
        
        if indexOfPreviousOperation == nil {
            //There is no operation in front of the current one
            firstComponent = splitEquation[0]
        } else {
            firstComponent = splitEquation[0].suffix(splitEquation[0].count - indexOfPreviousOperation! - 1)
        }
 
        if indexOfNextOperation == nil {
            //There is no operation behind the current one
            secondComponent = splitEquation[1]
        } else {
            secondComponent = splitEquation[1].prefix(indexOfNextOperation!)
        }
        
        let result = executeBasicOperation(firstComponent: String(firstComponent),
                                           secondComponent: String(secondComponent),
                                           withOperation: operation)
        
        guard result != nil else {
            return nil
        }
        
        let range = equation.range(of: firstComponent + operation + secondComponent)!
        let newEquation = equation.replacingCharacters(in: range, with: "\(result!)")
        return newEquation
    }
    
    //MARK: - Supplementary
    
    private func checkParanthesisOrderAndCount(inEquation equation: String) -> Bool {
        var counter = 0
        
        //Checking if the paranthesis are in correct order
        for character in equation {
            if character == "(" {
                counter += 1
            } else if character == ")" {
                counter -= 1
            }
            
            if counter < 0 {
                return false
            }
        }
        
        guard !equation.contains("()") else {
            return false
        }
        
        //Checking if the number of opening paranthesis is the same as of the closing ones
        if counter == 0 {
            return true
        } else {
            return false
        }
        
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
