//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Ahmet Emin Yalçınkaya on 20.11.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

	
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameText: UITextField!
	@IBOutlet weak var artistText: UITextField!
	@IBOutlet weak var yearText: UITextField!
	
	
	
	@IBOutlet weak var saveButton: UIButton!
	
	
	var chosenPainting = ""
	var chosenPaintingId : UUID?
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = view.bounds


		let startColor = hexStringToUIColor(hex: "C4B0AF")
		let endColor = UIColor.systemBlue

		gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint(x: 1, y: 1)

		view.layer.insertSublayer(gradientLayer, at: 0)
		
		
		if chosenPainting != ""{
			saveButton.isHidden = true

			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			let context = appDelegate.persistentContainer.viewContext
			
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
			
			
			let idString = chosenPaintingId?.uuidString
			
			fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
			fetchRequest.returnsObjectsAsFaults = false
			
			do {
				let results = try context.fetch(fetchRequest)
				
				if  results.count > 0 {
					for result in results as! [NSManagedObject]{
						if let name  = result.value(forKey: "name") as? String {
							nameText.text = name
						}
						if let artist  = result.value(forKey: "artist") as? String {
							artistText.text = artist
						}
						
						if let year = result.value(forKey: "year") as? Int {
							yearText.text = String(year)
						}
						
						if let imageData = result.value(forKey: "image") as? Data {
							let image = UIImage(data: imageData)
							imageView.image = image
						}
						
					}
					
				}
				
				
			}catch {
				print("error")
				
				
				
				
			}
			
			
			fetchRequest.returnsObjectsAsFaults = false
		}else {
			saveButton.isHidden = false
			saveButton.isEnabled = false
			nameText.text = ""
			artistText.text = ""
			yearText.text = ""
			
		}
		
		
		//Recognizers
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		view.addGestureRecognizer(gestureRecognizer)
		
		
		imageView.isUserInteractionEnabled = true
		let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
		imageView.addGestureRecognizer(imageTapRecognizer)
		
		
		
		
	}
	
	
	//color
	func hexStringToUIColor (hex: String) -> UIColor {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt64 = 0

		Scanner(string: hexSanitized).scanHexInt64(&rgb)

		let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
		let blue = CGFloat(rgb & 0x0000FF) / 255.0

		return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
	}
	
	
	
	
	
	@objc func selectImage() {
		
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.sourceType = .photoLibrary
		picker.allowsEditing = true
		present(picker, animated: true, completion: nil)
		
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		imageView.image = info[.originalImage] as? UIImage
		saveButton.isEnabled = true 
		self.dismiss(animated: true,completion: nil)
	}
	
	
		
		@objc func hideKeyboard() {
			
			view.endEditing(true)
			
			
			
		

    }
    


	
	@IBAction func saveButtonClicked(_ sender: Any) {
		print("button activated")
		  
		  let appDelegate = UIApplication.shared.delegate as! AppDelegate
		  let context = appDelegate.persistentContainer.viewContext
		  
		  let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
		  
		  // Attributes
		  
		  newPainting.setValue(nameText.text!, forKey: "name")
		  
		  // Extract text from artistText field and set it as NSString
		  if let artist = artistText.text {
			  newPainting.setValue(artist as NSString, forKey: "artist")
		  }
		  
		  if let year = Int(yearText.text!) {
			  newPainting.setValue(year, forKey: "year")
		  }
		  
		  newPainting.setValue(UUID(), forKey: "id")
		  
		  let data = imageView.image?.jpegData(compressionQuality: 0.5)
		  
		  newPainting.setValue(data, forKey: "image")
		  
		  do {
			  try context.save()
		  } catch {
			  print(error)
		  }
		
		NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
		self.navigationController?.popViewController(animated: true)
		
		
	}
	
	
	
	

}
