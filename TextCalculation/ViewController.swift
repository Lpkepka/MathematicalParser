//
//  ViewController.swift
//  TextCalculation
//
//  Created by Lukasz Kepka on 29/06/2019.
//  Copyright © 2019 Lukasz Kepka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let equation = "(-3.6+7.2)*(-2.5 + 3.3*(((5.4+5,2))))"
        MathematicalEquationParser.shared.processEquation(fromString: equation, completion: { result in
            print(result)
        })
    }
}

