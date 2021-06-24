//
//  ViewController.swift
//  DraggablePoints
//
//  Created by Amir Rimal on 21/06/2021.
//

import UIKit
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}

class CustomCAShapeLayer: CAShapeLayer {
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomLineLayer: CAShapeLayer {
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ViewController : UIViewController {
    var allPaths = [CGMutablePath]()
    
    var path1 = CGMutablePath()
    var path2 = CGMutablePath()
    
    var shapeLayers = [CustomCAShapeLayer()]
    var paths = [CGMutablePath()]
    
    var shapeLayer1 = CustomCAShapeLayer()
    var shapeLayer2 = CustomCAShapeLayer()
    
    var path3 = CGMutablePath()
    
    var shapeLayer3 = CustomCAShapeLayer()
    
    //    var circleCount = 0
    var currentPath = CGMutablePath()
    var allShapeLayers = [CustomCAShapeLayer]()
    var currentShapeLayer =  CustomCAShapeLayer()
    var allLineLayers = [CustomLineLayer]()
    var currentLineLayer = CustomLineLayer()
    typealias ArrayOfCircles = [CircleView]
    var currentRegionIndex: Int = 0 {
        didSet {
            print("Changed")
        }
    }
    var currentColor = UIColor.random()
    var currentRegion = ArrayOfCircles() {
        didSet {
            if currentRegion != ArrayOfCircles() {
                addCircles(circle: currentRegion.last!)
            }
        }
    }
    var arrayOfCircles = [ArrayOfCircles]()
    //    {
    //        didSet {
    //            addCircles(circle: arrayOfCircles[currentRegionIndex].last!)
    //        }
    //    }
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
        
        
    }
    
    private func addCircles(circle: CircleView) {
        circle.backgroundColor = currentColor
        view.addSubview(circle)
        
        
        circle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:))))
        if currentRegion.count > 1 {
            view.layer.addSublayer(currentRegion[currentRegion.count - 2].lineTo(circle: circle))
        }
        var distanceFromFirstPoint: CGFloat = 100.0
        if currentRegion.count > 3 {
            distanceFromFirstPoint = CGPoint(x: circle.frame.midX, y: circle.frame.midY).distance(from: CGPoint(x: currentRegion.first!.frame.midX, y: currentRegion.first!.frame.midY))
            if (20 ... 50).contains(distanceFromFirstPoint) {
                view.layer.addSublayer(currentRegion[currentRegion.count - 1].lineTo(circle: currentRegion.first!))
            }
        }
        
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.gray.cgColor
        
        circle.alpha = 0.6
        circle.layer.zPosition = 100
        drawOnlayer(pointOnRegionWithIndex: currentRegionIndex)
        if (20 ... 50).contains(distanceFromFirstPoint) {
            closePath()
        }
        
        
    }
    
    private func drawOnlayer(pointOnRegionWithIndex: Int) {
        //        if !allPaths.isEmpty {
        //            currentPath = CGMutablePath()//allPaths[currentRegionIndex]//CGMutablePath()
        //        } else {
        //            currentPath = CGMutablePath()
        //        }
        currentPath = CGMutablePath()//paths[pointOnRegionWithIndex]
        currentShapeLayer = shapeLayers[pointOnRegionWithIndex]
        /*   if pointOnRegionWithIndex == 0 {
         path1 = CGMutablePath()
         currentPath = path1
         shapeLayer1.fillColor = UIColor.blue.withAlphaComponent(0.5).cgColor
         currentShapeLayer = shapeLayer1
         
         } else if pointOnRegionWithIndex == 1 {
         path2 = CGMutablePath()
         currentPath = path2
         shapeLayer2.fillColor = UIColor.blue.withAlphaComponent(0.5).cgColor
         currentShapeLayer = shapeLayer2
         
         }
         
         else if pointOnRegionWithIndex == 2 {
         path3 = CGMutablePath()
         currentPath = path3
         shapeLayer3.fillColor = UIColor.blue.withAlphaComponent(0.5).cgColor
         currentShapeLayer = shapeLayer3
         
         } */
        //        currentPath = CGMutablePath()
        //        currentShapeLayer.path = nil
        
        var tempAllElements = arrayOfCircles
        tempAllElements.append(currentRegion)
        for (index, points) in tempAllElements[pointOnRegionWithIndex].enumerated() {
            if index == 0 {
                currentPath.move(to: points.center)
            } else {
                currentPath.addLine(to: points.center)
            }
        }
        
        currentShapeLayer.path = currentPath
        currentShapeLayer.fillRule = .nonZero
        currentShapeLayer.allowsGroupOpacity = true
        currentShapeLayer.fillColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        view.layer.insertSublayer(currentShapeLayer, at: 98)
        
    }
    
    private func closePath() {
        currentRegion.forEach { _circle in
            _circle.backgroundColor = .systemPink
        }
        paths.append(CGMutablePath())
        shapeLayers.append(CustomCAShapeLayer())
        currentRegionIndex += 1
        arrayOfCircles.append(currentRegion)
        
        currentColor = UIColor.random()
        
        currentRegion = ArrayOfCircles()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let location = touches.first?.location(in: view) else { return }
        
        if checkIfExists(for: location) {
            //            if currentRegion.count == 0 {
            //                let circle = CircleView(frame: CGRect(x: location.x, y: location.y, width: 20, height: 20))
            //                currentRegion.append(circle)
            //            }
        } else {
            let circle = CircleView(frame: CGRect(x: location.x - 10, y: location.y - 10, width: 20, height: 20), id: currentRegionIndex)
            currentRegion.append(circle)
        }
    }
    //To move
    private func checkIfExists(for point: CGPoint) -> Bool {
        
        var _pointsToCheckAgainst = arrayOfCircles.flatMap { _view in
            return _view
        }
        
        _pointsToCheckAgainst.append(contentsOf: currentRegion)
        
        
        let exists = !_pointsToCheckAgainst.allSatisfy { circle in
            circle.frame.origin.distance(from: point) > 20
        }
        
        for circle in _pointsToCheckAgainst {
            let distance = circle.frame.origin.distance(from: point)
            print(distance)
        }
        
        print(exists)
        
        return exists
        
    }
    
    @objc func didPan(gesture: UIPanGestureRecognizer) {
        guard let circle = gesture.view as? CircleView else {
            return
        }
        if (gesture.state == .began) {
            circle.center = gesture.location(in: self.view)
        }
        let newCenter: CGPoint = gesture.location(in: self.view)
        let dX = newCenter.x - circle.center.x
        let dY = newCenter.y - circle.center.y
        circle.center = CGPoint(x: circle.center.x + dX, y: circle.center.y + dY)
        
        
        if let outGoingCircle = circle.outGoingCircle, let line = circle.outGoingLine, let path = circle.outGoingLine?.path {
            
            let newPath = UIBezierPath(cgPath: path)
            newPath.removeAllPoints()
            newPath.move(to: circle.center)
            newPath.addLine(to: outGoingCircle.center)
            line.path = newPath.cgPath
        }
        
        if let inComingCircle = circle.inComingCircle, let line = circle.inComingLine, let path = circle.inComingLine?.path {
            
            let newPath = UIBezierPath(cgPath: path)
            newPath.removeAllPoints()
            newPath.move(to: inComingCircle.center)
            newPath.addLine(to: circle.center)
            line.path = newPath.cgPath
        }
        
        drawOnlayer(pointOnRegionWithIndex: circle.idOfRegion!)
    }
}

class CircleView : UIView {
    var idOfRegion: Int?
    var outGoingLine : CAShapeLayer?
    var inComingLine : CAShapeLayer?
    var inComingCircle : CircleView?
    var outGoingCircle : CircleView?
    
    convenience init(frame: CGRect, id: Int) {
        
        self.init(frame: frame)
        self.idOfRegion = id
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func lineTo(circle: CircleView) -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: self.center)
        path.addLine(to: circle.center)
        
        let line = CAShapeLayer()
        line.path = path.cgPath
        line.lineWidth = 2
        line.strokeColor = UIColor.blue.withAlphaComponent(0.25).cgColor
        circle.inComingLine = line
        outGoingLine = line
        outGoingCircle = circle
        circle.inComingCircle = self
        return line
    }
}


extension CGPoint {
    func distance(from destination: CGPoint) -> CGFloat {
        return hypot(self.x.distance(to: destination.x), self.y.distance(to: destination.y))
    }
}
