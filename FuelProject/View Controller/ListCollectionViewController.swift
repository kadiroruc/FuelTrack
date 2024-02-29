//
//  ListCollectionViewController.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 27.02.2024.
//

import UIKit

private let reuseIdentifier = "Cell"

class ListCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var purchases = [FuelPurchase]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        
        
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor(red: 255/255, green: 206/255, blue: 28/255, alpha: 1)

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 20
            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20) 
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Örneğin, 20 öğe olduğunu varsayalım.
        return purchases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ListCollectionViewCell
        cell.backgroundColor = .black
        cell.layer.cornerRadius = 15
        
        let purchaseObject = purchases[indexPath.item]
        var formattedString = ""
        if let date = purchaseObject.date{
            formattedString = formatDate(date: date)
        }
        let string = "Date: \(formattedString)\nPrevios Km: \(purchaseObject.previousKM)\nNext Km: \(purchaseObject.nextKM)\n Fuel Liter: \(purchaseObject.liter)"
        cell.label.text = string
        
        return cell
    }
    func formatDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"

        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    // UICollectionViewDelegateFlowLayout protokolünden gelen metot, hücre boyutlarını ayarlar.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Kare şeklinde yan yana iki hücre olduğu için collectionView'ın yarısını kaplayacak şekilde boyut belirleyebiliriz.
        let collectionViewWidth = collectionView.bounds.width
        let itemWidth = (collectionViewWidth - 40) // Kenar boşluklar düşüldü.
        
        return CGSize(width:itemWidth , height: 100)
    }

}
