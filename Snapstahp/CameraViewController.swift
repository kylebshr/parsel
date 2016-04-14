//
//  ViewController.swift
//  Snapstahp
//
//  Created by Kyle Bashour on 4/13/16.
//  Copyright © 2016 Kyle Bashour. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    let session = CameraSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.addSublayer(session.previewLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let singleGesture = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))

        doubleGesture.numberOfTapsRequired = 2
        singleGesture.requireGestureRecognizerToFail(doubleGesture)

        view.addGestureRecognizer(singleGesture)
        view.addGestureRecognizer(doubleGesture)

        session.previewLayer.frame = view.layer.bounds
    }

    @objc func cameraTapped() {
        session.capturePhoto { [weak self] image in
            let editVC = R.storyboard.main.editViewController()!
            editVC.image = image
            self?.presentViewController(editVC, animated: false, completion: nil)
        }
    }

    @objc func doubleTapped() {
        session.switchPosition()
    }

    @IBAction func unwind(segue: UIStoryboardSegue) { }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
