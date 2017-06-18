//
//  GraffitiDetailsViewController.swift
//  Graffiti
//
//  Created by Eugenio Barquín on 17/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import UIKit

protocol GraffitiDetailsViewControllerDelegate: class {
    
    func graffitiDidFinishGetTagged(sender: GraffitiDetailsViewController, taggedGraffiti: Graffiti)
        
    
}

class GraffitiDetailsViewController: UIViewController {
    
    weak var delegate: GraffitiDetailsViewControllerDelegate?
    

    @IBOutlet weak var imgGraffiti: UIImageView!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var taggedGraffiti: Graffiti?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage(named: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)
        
        let takePictureGesture = UITapGestureRecognizer(target: self, action: #selector(takePictureTapped))
        self.imgGraffiti.addGestureRecognizer(takePictureGesture)
        
        configureLabels()
    }

    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func configureLabels() {
        latitudeLabel.text = String(format:"%.8f", (taggedGraffiti?.coordinate.latitude)!)
        longitudeLabel.text = String(format:"%.8f", (taggedGraffiti?.coordinate.longitude)!)
        addressLabel.text = taggedGraffiti?.graffitiAddress
    }
    
    @IBAction func saveGraffiti(_ sender: Any) {
        if let image = imgGraffiti.image {
            let ramdomName = UUID().uuidString.appending(".png")
            if let url = GraffitiManager.shared4Instance.imagesURL()?.appendingPathComponent(ramdomName),
                let imageData = UIImagePNGRepresentation(image) {
                do {
                    try imageData.write(to: url)
                } catch (let error) {
                    print("Error saving image: \(error)")
                }
            }
            
            taggedGraffiti = Graffiti(address: addressLabel.text!, latitude: Double(latitudeLabel.text!)!, longitude: Double(longitudeLabel.text!)!, image: ramdomName)
            
            if let taggedGraffiti = taggedGraffiti {
                delegate?.graffitiDidFinishGetTagged(sender: self, taggedGraffiti: taggedGraffiti)
            }
        }
    }
}

extension GraffitiDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePictureTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoMenu()
        } else {
            
            choosePhotoFromLibrary()
        }
    }
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAcction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(cancelAcction)
        
        let takePhotoAction = UIAlertAction(title: "Sacar foto", style: .default) { _ in
            self.takePhotoWithCamera()
        }
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Elegir de la librería", style: .default) { _ in
            self.choosePhotoFromLibrary()
        }
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Protocol methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTaken = info[UIImagePickerControllerEditedImage] as? UIImage
        imgGraffiti.image = imageTaken
        saveButton.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
