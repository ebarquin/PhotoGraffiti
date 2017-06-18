//
//  GraffitiImageViewController.swift
//  Graffiti
//
//  Created by Eugenio Barquín on 18/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import UIKit

class GraffitiImageViewController: UIViewController {
    var selectedCallout : UIImage?
    
    @IBOutlet weak var graffitiImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedCallout = selectedCallout {
            graffitiImage.image = selectedCallout
        }
    
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
  }
