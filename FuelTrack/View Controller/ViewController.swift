//
//  ViewController.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 16.02.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var kmLabel: UILabel!
    var viewModel = ViewModel()
    @IBOutlet var fuelLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        viewModel.delegate = self
        
        if let image = UIImage(named: "h"){
            viewModel.readQRCode(from: image)
        }else{
            print("Error loading image")
        }
        
        
        setupUI()
        setupLabels()
        
    }

    func setupUI(){
        
        let circleView = UIView(frame: averageLabel.bounds)
        circleView.layer.cornerRadius = averageLabel.bounds.width / 2
        circleView.layer.borderWidth = 4.0
        circleView.layer.borderColor = UIColor.black.cgColor
        circleView.clipsToBounds = true
        
        let circleView2 = UIView(frame: averageLabel.bounds)
        circleView2.layer.cornerRadius = averageLabel.bounds.width / 2
        circleView2.layer.borderWidth = 4.0
        circleView2.layer.borderColor = UIColor.black.cgColor
        circleView2.clipsToBounds = true
        
        let circleView3 = UIView(frame: averageLabel.bounds)
        circleView3.layer.cornerRadius = averageLabel.bounds.width / 2
        circleView3.layer.borderWidth = 4.0
        circleView3.layer.borderColor = UIColor.black.cgColor
        circleView3.clipsToBounds = true
        averageLabel.addSubview(circleView)
        averageLabel.backgroundColor = .clear
        kmLabel.addSubview(circleView2)
        kmLabel.backgroundColor = .clear
        fuelLabel.addSubview(circleView3)
        fuelLabel.backgroundColor = .clear

        navigationController?.navigationBar.tintColor = .black
        
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(handleTrash))
        let qrButton = UIBarButtonItem(image: UIImage(systemName: "qrcode"), style: .done, target: self, action: #selector(handleInputs))
        
        navigationItem.setRightBarButtonItems([qrButton,deleteButton], animated: true)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .done, target: self, action: #selector(showTableView))
        

    }
    
    func setupLabels(){
        let average = self.viewModel.getMonthlyAverageFuelConsumption()
        
        
        let km = self.viewModel.getMonthlyKm()
        let fuel = self.viewModel.getMonthlyFuelCost()

        
        averageLabel.text = String(format: "%.2f", average)
        kmLabel.text = String(km)
        fuelLabel.text = String(format: "%.1f", fuel)
        
    }
    
    @objc func showTableView(){
        let collectionVC = ListCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        collectionVC.purchases = self.viewModel.getMonthPurchases()
        navigationController?.pushViewController(collectionVC, animated: true)
    }
    
    @objc func handleTrash(){
        let ac = UIAlertController(title: "Are you sure you want to delete all data?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default,handler: { [weak self] action in
            self?.viewModel.deleteAllDatas()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
}

//MARK: - view model
extension ViewController : ViewModelDelegate{
    func didUpdate() {
        
        setupLabels()
    }
    
    @objc func handleInputs(){
        if self.viewModel.getLastPurchaseKm() == 0{
            getFirstKmValue()
        }else{
            getCurrentKMFromUser()
        }
    }
    
    func getCurrentKMFromUser(){
        
        let nextKmOfLastObject = self.viewModel.getLastPurchaseKm()
        
        let alertController = UIAlertController(title: "New Record", message: "Please Enter Current Km of Your Car\nLast Km: \(nextKmOfLastObject)", preferredStyle: .alert)
        
        
        alertController.addTextField { textField in
            textField.placeholder = "KM"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
            if let textField = alertController.textFields?.first, let userInput = textField.text {
                
                if let userInputInt = Int16(userInput){
                    
                    let fuelLiter = self.viewModel.getFuelLiterFromQRMessage()

                    let purchaseObject = FuelPurchase(context: self.context)
                    purchaseObject.date = Date()
                    purchaseObject.liter = fuelLiter
                    
                    purchaseObject.previousKM = nextKmOfLastObject
                    purchaseObject.nextKM = userInputInt

                    self.viewModel.addPurchase(purchaseObject: purchaseObject)
                    
                    
                }
                
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func getFirstKmValue(){
        let alertController = UIAlertController(title: "First Registration", message: "Please Enter The Km of Your Car as This is The First Registration", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "KM Before Refueling"
        }
        alertController.addTextField { textField in
            textField.placeholder = "KM After Refueling"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
            var purchaseObject: FuelPurchase?
            if let textField = alertController.textFields?.first, let userInput = textField.text {
                
                if let userInputInt = Int16(userInput){
                    
                    let fuelLiter = self.viewModel.getFuelLiterFromQRMessage()

                    purchaseObject = FuelPurchase(context: self.context)
                    purchaseObject!.date = Date()
                    purchaseObject!.liter = fuelLiter
                    
                    purchaseObject!.previousKM = userInputInt

                }
            }
            if let textField = alertController.textFields?.last, let userInput = textField.text{
                if let userInputInt = Int16(userInput){
                    purchaseObject!.nextKM = userInputInt
                    
                    self.viewModel.addPurchase(purchaseObject: purchaseObject!)
                }
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

