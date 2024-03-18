//
//  ColumnChartView.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 4.03.2024.
//

import UIKit

class ColumnChartView: UIView {
    var viewModel = ChartViewModel()
    var tapRecognizer:UITapGestureRecognizer!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tapRecognizer = UITapGestureRecognizer(
        target: self, action: #selector(handleBarTap))
        
        addGestureRecognizer(tapRecognizer)
    }
    
    deinit {
        removeGestureRecognizer(tapRecognizer)
    }
    
    func setData(_ dataPoints: [Double]) {
        viewModel.dataPoints = dataPoints
        
        clearViews()
        
        // Do not continue if no bar has height > 0
        guard viewModel.maxY > 0.0 else { return }
    
        createChart()
    }
    
    func clearViews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    func createChart() {
        var lastBar:UIView?
        
        for (i, dataPoint) in viewModel.dataPoints.enumerated() {
            let barView = createBarView(barNumber: i,
                                        barValue: dataPoint)
            
            if let lastBar = lastBar {
                // there is a bar to the left of this one, add a gap
                let gapView = createGapView(lastBar: lastBar)
                barView.leftAnchor.constraint(
                    equalTo: gapView.rightAnchor).isActive = true
            } else{
                // this is the 1st bar in the chart
                barView.leftAnchor.constraint(
                    equalTo: leftAnchor).isActive = true
                }
        
        // Pin the right edge of the last bar to view's right side
        if i == viewModel.dataPoints.count - 1 {
            barView.rightAnchor.constraint(
                equalTo: rightAnchor).isActive = true
        }
        
        // All bars pinned to bottom of containing view
        barView.bottomAnchor.constraint(
            equalTo: bottomAnchor).isActive = true
        
        // calculate height of bar relative to maxY
        barView.heightAnchor.constraint(
            equalTo: heightAnchor,
            multiplier: CGFloat(dataPoint /
                                viewModel.maxY)).isActive = true
        
        lastBar = barView
    }
}
    
    func createBarView(barNumber: Int, barValue: Double) -> UIView {
        let barView = UIView()
        addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false
        
        barView.widthAnchor.constraint(
                      equalTo: widthAnchor,
                      multiplier: viewModel.barWidthPctOfTotal).isActive = true
        
        barView.tag = barNumber + 1000
        barView.backgroundColor = viewModel.barColor
        barView.layer.cornerRadius = viewModel.barCornerRadius
        
        return barView
    }
    
    func createGapView(lastBar: UIView) -> UIView {
        let gapView = UIView()
        addSubview(gapView)
        gapView.translatesAutoresizingMaskIntoConstraints = false
        gapView.heightAnchor.constraint(
                            equalToConstant: 1.0).isActive = true
        gapView.centerYAnchor.constraint(
                            equalTo: centerYAnchor).isActive = true
        gapView.widthAnchor.constraint(equalTo: widthAnchor,
             multiplier: viewModel.barGapPctOfTotal).isActive = true
        gapView.leftAnchor.constraint(
                        equalTo: lastBar.rightAnchor).isActive = true
        return gapView
    }
    
    @objc func handleBarTap() {
        if let hitView = tapRecognizer.view {
            let loc = tapRecognizer.location(in: self)
            if let barViewTapped = hitView.hitTest(loc, with: nil) {
                for barView in subviews where barView.tag >= 1000 {
                    if barView.tag == barViewTapped.tag {
                        barView.backgroundColor = viewModel.barColor.withAlphaComponent(0.4)
                        
                        // Tıklanan değeri al ve göstermek için label oluştur
                        let dataIndex = barView.tag - 1000
                        let dataValue = viewModel.dataPoints[dataIndex]
                        
                        // Label oluştur
                        let label = UILabel()
                        let liter = String(format: "%.2f", dataValue)
                        label.text = "\(liter)L"
                        label.font = UIFont.systemFont(ofSize: 20)
                        label.textAlignment = .center
                        label.textColor = viewModel.barColor
                        label.backgroundColor = .clear
                        label.sizeToFit()
                        label.center = CGPoint(x: barView.center.x, y: barView.frame.minY - label.frame.height )
                        
                        // Eğer daha önce bir label eklenmişse, sil
                        if let existingLabel = barView.superview?.viewWithTag(999) {
                            existingLabel.removeFromSuperview()
                        }
                        
                        // Label'i ekle
                        label.tag = 999
                        addSubview(label)
                    } else {
                        barView.backgroundColor = viewModel.barColor
                    }
                }
            }
        }
    }

}
