//
//  ViewModel.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 16.02.2024.
//

import UIKit
import CoreData

protocol ViewModelDelegate: AnyObject{
    func didUpdateQR()
}

class ViewModel{
    
    weak var delegate: ViewModelDelegate?
    var qrMessage: String?
    
    var fuelPurchases = [FuelPurchase]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init(){
        loadPurchases()
    }
    
    func readQRCode(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("CIImage conversion failed")
            return
        }
        
        let context = CIContext(options: nil)
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options) else {
            print("QR code detector setup failed")
            return
        }
        
        let features = detector.features(in: ciImage)
        for feature in features {
            if let qrCodeFeature = feature as? CIQRCodeFeature {
                self.qrMessage = qrCodeFeature.messageString
                self.delegate?.didUpdateQR()
                return
            }
        }
        
    }
    
    func getQRMessage() -> String{
        return qrMessage ?? ""
    }
    
    func getFuelLiterFromQRMessage() -> String{
        if let qrMessage = qrMessage{
            let separatedArray = qrMessage.split(separator: " ").map { String($0) }
            return separatedArray[4]
        }
        return ""
    }
    
    func getDate() -> Date{

        let currentTime = Date()
        let calender = Calendar.current

        let day = calender.component(.day, from: currentTime)
        let month = calender.component(.month, from: currentTime)
        let year = calender.component(.year, from: currentTime)

        let dateComponents = DateComponents(year: year, month: month, day: day)
        
        if let date = calender.date(from: dateComponents) {
            //print("Yeni oluşturulan tarih: \(date)")
            return date
        } else {
            return Date()
            //print("Geçersiz tarih bileşenleri")
        }

    }
    
}

//MARK: - Core Data

extension ViewModel{
    
    func savePurchases(){
        do {
            try context.save()
        } catch {
            print("Error saving purchase \(error)")
        }
        
    }
    
    func loadPurchases() {
        
        let request : NSFetchRequest<FuelPurchase> = FuelPurchase.fetchRequest()
        
        do{
            fuelPurchases = try context.fetch(request)
        } catch {
            print("Error loading purchases \(error)")
        }
        
    }
}

//MARK: - Data Manipulating
extension ViewModel{
    func addPurchase(purchaseObject: FuelPurchase){
        fuelPurchases.append(purchaseObject)
        self.savePurchases()
    }
    
    func getPurchases() -> [FuelPurchase]{
        return fuelPurchases
    }
}
