//
//  ChartViewController.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 4.03.2024.
//

import UIKit

class ChartViewController: UIViewController {
    
    var consumptions = [Double]()

    @IBOutlet var chartView: ColumnChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        
        var dataPoints = [Double]()
        
        if consumptions.count < 7{
            for index in 0..<consumptions.count {

                dataPoints.append(consumptions[index])
            }
        }else{
            for index in 0..<7 {

                dataPoints.append(consumptions[index])
            }
        }
        
        chartView.setData(dataPoints)
        
    }
    
    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        
        
        
        let numSegments = sender.selectedSegmentIndex
        var dataCount = 0
        var dataPoints = [Double]()
        
        switch numSegments{
        case 0:
            dataCount = 7
        case 1:
            dataCount = 30
        case 2:
            dataCount = 90
        case 3:
            dataCount = 365
        default:
            dataCount = 7
        }
        
        
        if consumptions.count < dataCount{
            for index in 0..<consumptions.count {

                dataPoints.append(consumptions[index])
            }
        }else{
            for index in 0..<dataCount {

                dataPoints.append(consumptions[index])
            }
        }
        
        chartView.setData(dataPoints)
    }
    
}
