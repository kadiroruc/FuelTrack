//
//  ViewController.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 16.02.2024.
//

import UIKit

class ViewController: UIViewController {
    
    var viewModel = ViewModel()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        if let image = UIImage(named: "qr_code_image"){
            viewModel.readQRCode(from: image)
        }else{
            print("Error loading image")
        }
        
        
        
    }

}

//MARK: - view model
extension ViewController : ViewModelDelegate{
    func didUpdateQR() {
        
        getCurrentKMFromUser()
        
        
    }
    
    func getCurrentKMFromUser(){
        let alertController = UIAlertController(title: "", message: "Please Enter\nCurrent Km of Your Car", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "KM"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
            if let textField = alertController.textFields?.first, let userInput = textField.text {
                //print("Kullanıcıdan alınan bilgi: \(userInput)")
                if let userInputInt = Int16(userInput){
                    
                    let fuelLiter = self.viewModel.getFuelLiterFromQRMessage()
                    let nextKmOfLastObject = self.viewModel.getLastPurchaseKm()
                    
                    let purchaseObject = FuelPurchase(context: self.context)
                    purchaseObject.date = Date()
                    purchaseObject.liter = fuelLiter
                    
                    purchaseObject.previousKM = nextKmOfLastObject
                    purchaseObject.nextKM = userInputInt

                    self.viewModel.addPurchase(purchaseObject: purchaseObject)

                    print(self.viewModel.getLastPurchaseObject())
                }
                
            }
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    

}

