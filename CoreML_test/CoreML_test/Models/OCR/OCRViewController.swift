//
//  OCRViewController.swift
//  CoreML_test
//
//  Created Осина П.М. on 19.02.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import UIKit

class OCRViewController: UIViewController {

	var presenter: OCRPresenter!

	override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension OCRViewController: OCRView {
    
}
