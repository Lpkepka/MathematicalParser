//
//  ViewController.swift
//  TextCalculation
//
//  Created by Lukasz Kepka on 29/06/2019.
//  Copyright © 2019 Lukasz Kepka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var formulaTextView: UITextView! {
        didSet {
            formulaTextView.isEditable = true
            formulaTextView.keyboardType = .default
            formulaTextView.layer.borderColor = UIColor.blue.cgColor
            formulaTextView.layer.borderWidth = 2
            formulaTextView.layer.cornerRadius = 10
        }
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Actions
    
    @IBAction func computeButtonWasPressed(_ sender: UIButton) {
        if let equation = formulaTextView.text {
            DispatchQueue.global(qos: .background).async {
            MathematicalEquationParser.shared.processEquation(fromString: equation, completion: { result in
                        self.showResultAlert(fromEquation: equation, withResult: result)
                })
            }
        } else {
            print("Couldn't get formula")
        }
    }
    
    //MARK: - Alert handling
    
    private func showResultAlert(fromEquation equation: String, withResult result: Double?) {
        var alertText = ""
        if let computedResult = result {
            alertText = "The result of \(equation) is \(computedResult)"
        } else {
            alertText = "Please make sure Your equation is correct"
        }
        
        let alertController = UIAlertController(title: "Result", message: alertText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

