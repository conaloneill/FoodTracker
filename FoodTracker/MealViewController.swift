//
//  MealViewController.swift
//  FoodTrackerTest
//
//  Created by Conal O'Neill on 04/12/2017.
//  Copyright © 2017 Conal O'Neill. All rights reserved.
//

import os.log
import UIKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	//MARK: Properties
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var ratingControl: RatingControl!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
	/*
	This value is either passed by 'MealTableViewController' in
	'prepare(for: sender:)'
	or constructed as part of adding a new meal.
	*/
	var meal: Meal?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Handle the text fields's user input through delegate callbacks
		nameTextField.delegate = self
		
		// Set up views if editing an existing Meal.
		if let meal = meal {
			navigationItem.title = meal.name
			nameTextField.text = meal.name
			photoImageView.image = meal.photo
			ratingControl.rating = meal.rating
		}
		
		// Enable the Save button only if the text field has a valid Meal name.
		updateSaveButtonState()
	}
	
	
	//MARK: UITextFieldDelegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		// Hide the keyboard.
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		updateSaveButtonState()
		navigationItem.title = textField.text
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Disable the Save button while editing.
		saveButton.isEnabled = false
	}
	
	//MARK: UIImagePickerControllerDelegate
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		// Dismiss the picker if the user canceled.
		dismiss(animated: true, completion: nil)
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		// The info dictionary may contain multiple representations of the image. You want to use the original.
		guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			fatalError("Expected a dictionary containing an image, but was provided the following \(info)")
		}
		
		// Set photoImageView to display the selected image.
		photoImageView.image = selectedImage
		
		// Dismiss the picker
		dismiss(animated: true, completion: nil)
	}
	
	//MARK: Navigation
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		
		// Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
		let isPresentingInAddMealMode = presentingViewController is UINavigationController
		
		if isPresentingInAddMealMode {
			dismiss(animated: true, completion: nil)
		}
		else if let owningNavigationController = navigationController {
			owningNavigationController.popViewController(animated: true)
		}
		else {
			fatalError("The MealViewController is not inside a navigation controller.")
		}
		
	}
	
	// This method lets you configure a view controller before it's presented.
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		// Configure the destination view controller only when the save button is pressed.
		guard let button = sender as? UIBarButtonItem, button === saveButton else {
			os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
			return
		}
		
		let name = nameTextField.text ?? ""
		let photo = photoImageView.image
		let rating = ratingControl.rating
		
		// Set the meal to be passed to MealTableViewController after the unwind segue.
		meal = Meal(name: name, photo: photo, rating: rating)
	}
	
	
	//MARK: Actions
	@IBAction func selectPhotoFromUIAlertOption(_ sender: UITapGestureRecognizer) {
		let actionVc  = UIAlertController(title: "Photo import",	message: "Choose from saved photos or take a photo", preferredStyle: .actionSheet)
		actionVc.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: photoLibrary))
		actionVc.addAction(UIAlertAction(title: "Camera", style: .default, handler: camera))
		actionVc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(actionVc, animated: true, completion: nil)
	}
	
	
	//MARK: Private Methods
	private func updateSaveButtonState() {
		// Disable the Save button if the text field is empty.
		let text = nameTextField.text ?? ""
		saveButton.isEnabled = !text.isEmpty
	}
	
	private func photoLibrary(action: UIAlertAction) {
		// Hide the keyboard.
		nameTextField.resignFirstResponder()
		
		// UIImagePickerController is a view controller that lets a user pick media from their photo library
		let imagePickerController = UIImagePickerController()
		
		// Only allow photos to be picked, not taken.
		imagePickerController.sourceType = .photoLibrary
		
		// Make sure ViewController is notified when the user picks an image
		imagePickerController.delegate = self
		present(imagePickerController, animated: true, completion: nil)
	}
	
	private func camera(action: UIAlertAction) {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			// Hide the keyboard.
			nameTextField.resignFirstResponder()
			
			// UIImagePickerController is a view controller that lets a user pick media from their photo library
			let imagePickerController = UIImagePickerController()
			
			// Only allow photos to be picked, not taken.
			imagePickerController.sourceType = .camera
			
			// Make sure ViewController is notified when the user picks an image
			imagePickerController.delegate = self
			present(imagePickerController, animated: true, completion: nil)
		} else {
			noCamera()
		}
	}
	
	private func noCamera(){
		let alertVC = UIAlertController(title: "No Camera",	message: "Sorry, this device has no camera", preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
		present(alertVC, animated: true, completion: nil)
	}
	
}

