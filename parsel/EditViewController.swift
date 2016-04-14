//
//  EditViewController.swift
//  Snapstahp
//
//  Created by Kyle Bashour on 4/13/16.
//  Copyright © 2016 Kyle Bashour. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
