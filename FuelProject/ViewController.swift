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
    var userInputKm: Int16?

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
        let fuelLiter = self.viewModel.getFuelLiterFromQRMessage()
        getCurrentKMFromUser()
        
        let purchaseObject = FuelPurchase(context: self.context)
        purchaseObject.date = self.viewModel.getDate()
        
        if let fuelLiterInt = Float(fuelLiter){
            purchaseObject.liter = fuelLiterInt
        }
        
        purchaseObject.previousKM = 1200
        
        if let userInputKm = userInputKm{
            purchaseObject.nextKM = userInputKm
        }
        
        self.viewModel.addPurchase(purchaseObject: purchaseObject)
        
        print(self.viewModel.getPurchases())
        
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
                    self.userInputKm = userInputInt
                }
                
            }
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    

}

