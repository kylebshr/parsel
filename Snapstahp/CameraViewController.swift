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

        let gesture = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))

        view.addGestureRecognizer(gesture)

        session.previewLayer.frame = view.layer.bounds
    }

    @objc func cameraTapped() {
        session.capturePhoto { [weak self] image in
            let editVC = R.storyboard.main.editViewController()!
            editVC.image = image
            self?.presentViewController(editVC, animated: false, completion: nil)
        }
    }
}
