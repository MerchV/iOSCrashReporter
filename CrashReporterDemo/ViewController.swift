//
//  ViewController.swift
//  CrashReporterDemo
//
//  Created by Merch on 2018-01-18.
//  Copyright © 2018 Merch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBAction func causeExceptionCrash(_ sender: UIButton) {
        performSegue(withIdentifier: "ThisSegueIdentifierDoesNotExist", sender: nil) // this will cause an exception
    }

    @IBAction func causeSignalCrash(_ sender: UIButton) {
        let a = [Int]()
        let _ = a[0] // this will cause a signal
    }


}

