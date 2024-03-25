//
//  ViewModel.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 16.02.2024.
//

import UIKit
import CoreData

protocol ViewModelDelegate: AnyObject{
    func didUpdate()
}

class ViewModel{
    
    weak var delegate: ViewModelDelegate?
    private var _qrMessage: String = ""
    
    var qrMessage: String{
        get{
            return _qrMessage
        }
        set{
            _qrMessage = newValue
        }
    }
    
    var fuelPurchases = [FuelPurchase]()
    var filteredPurchases = [FuelPurchase]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init(){
        
        loadPurchases()
        loadMonthPurchaseDatas()
    }
    
    
    func getFuelLiterFromQRMessage() -> Float{
        let separatedArray = qrMessage.split(separator: " ").map { String($0) }
        var liter = separatedArray[4]
        
        if let commaIndex = liter.firstIndex(of: ","){
            liter.replaceSubrange(commaIndex...commaIndex, with: ".")
            if let literFloat = Float(liter){
                return literFloat
            }
        }
        return 0
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
    
    private func loadPurchases() {
        
        let request : NSFetchRequest<FuelPurchase> = FuelPurchase.fetchRequest()
        
        do{
            fuelPurchases = try context.fetch(request)
        } catch {
            print("Error loading purchases \(error)")
        }
        
    }
    
    func getLastPurchaseObject() -> NSManagedObject?{
        let fetchRequest : NSFetchRequest<FuelPurchase> = FuelPurchase.fetchRequest()
    
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let lastPurchase = try context.fetch(fetchRequest)
            return lastPurchase.first
        } catch let error as NSError {
            print("Son objeyi getirirken hata oluştu: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func getLastPurchaseKm() -> Int16{
        if let lastObject = self.getLastPurchaseObject() as? FuelPurchase{
            
            return lastObject.nextKM
        }else{
            return 0
        }
    }
    
    
    private func loadMonthPurchaseDatas(){
        let currentDate = Date()
        
        let calendar = Calendar.current
        
        var startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate ))
        startDate = calendar.date(byAdding: DateComponents(hour: 3), to: startDate!)

        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: 0), to: startDate!)
        
        
        let fetchRequest: NSFetchRequest<FuelPurchase> = FuelPurchase.fetchRequest()
        
        
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate! as NSDate, endDate! as NSDate)
        
        
        do {
            let results = try context.fetch(fetchRequest)
            self.filteredPurchases = results
            self.delegate?.didUpdate()
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    func deleteAllDatas(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FuelPurchase")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            fuelPurchases.removeAll()
            filteredPurchases.removeAll()
            self.loadMonthPurchaseDatas()
            print("All records deleted.")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
}

//MARK: - Data Manipulating
extension ViewModel{
    func addPurchase(purchaseObject: FuelPurchase){
        fuelPurchases.append(purchaseObject)
        self.savePurchases()
        self.loadMonthPurchaseDatas()
    }
    
    func getPurchases() -> [FuelPurchase]{
        return fuelPurchases
    }
    func getMonthPurchases() -> [FuelPurchase]{
        return filteredPurchases
    }
    
    func getMonthlyFuelCost() -> Float {
        
        var totalLiter:Float = 0.0
    
        for purchase in filteredPurchases{
            
            totalLiter += purchase.liter
        }
        return totalLiter
    }
    
    func getMonthlyKm() -> Int16{
        
        guard let firstObj = filteredPurchases.first else{return 0}
        guard let lastObj = filteredPurchases.last else{return 0}
        
        let totalKm = lastObj.nextKM - firstObj.previousKM
        return totalKm
    }
    
    func getMonthlyAverageFuelConsumption() -> Float{
        let totalLiter = getMonthlyFuelCost()
        
        let totalKm = getMonthlyKm()
        
        let averageConsumption = (totalLiter / Float(totalKm)) * 100 // in 100 km
        
        return averageConsumption
    }
    
    func getConsumptionsForChart() -> [Double]{
        var consumptions = [Double]()
        
        for purchase in fuelPurchases{
            let liter = purchase.liter
            let km = purchase.nextKM - purchase.previousKM
            let consumption = (Double(liter) / Double(km)) * 100
            consumptions.append(consumption)
            
        }
        return consumptions
    }
    

}
