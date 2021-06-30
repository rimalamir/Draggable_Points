//
//  ViewController.swift
//  DraggablePoints
//
//  Created by Amir Rimal on 21/06/2021.
//

import UIKit

extension CGFloat {
    
    /// Generate random number between 0 to 1
    /// - Returns: Random number in region 0 to 1
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    /// Generate random color
    /// - Returns: Random color based on random RGB values
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}

/// Custom shape layer, so that specific shapes can be manipulated leaving other layers intact, can be achieved same using protocols too
class CustomCAShapeLayer: CAShapeLayer {
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/*class CustomLineLayer: CAShapeLayer {
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 } */

class ViewController : UIViewController {

    /// Collecrion of shape layers
    var shapeLayers = [CustomCAShapeLayer()]
    /// Collection of different paths, paths are used to define shape layer and manipulate its properties
    var paths = [CGMutablePath()]

    
    /// Path which is being manipulated, path of current shape layer
    var currentPath = CGMutablePath()
    
    /// Shape which is being manipulated,
    var currentShapeLayer =  CustomCAShapeLayer()
    
    
    typealias ArrayOfCircles = [CircleView]
    
    
    /// Unique value associated with each region, region is a collection of points forming an area
    var currentRegionIndex: Int = 0
    
    var currentColor = UIColor.random()
    
    var currentRegion = ArrayOfCircles() {
        didSet {
            if currentRegion != ArrayOfCircles() {
                addCircles(circle: currentRegion.last!)
            }
        }
    }
    
    /// [[CircleView]] -> All regions in current view: Regions are collection of points that form a shape
    var arrayOfCircles = [ArrayOfCircles]()
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
        
        
    }
    
    /// Adds unique circle at point touched on screen
    /// - Parameter circle: The circular point that is to be added on screen
    private func addCircles(circle: CircleView) {
        circle.backgroundColor = currentColor
        view.addSubview(circle)
        
        //Add tap gesture recognizer to the point, so that it can be moved about the screen
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
        
        ///If distance is too close to first point, close the path
        if (20 ... 50).contains(distanceFromFirstPoint) {
            closePath()
        }
        
        
    }
    
    /// Shade current path with required color
    /// - Parameter pointOnRegionWithIndex: The index that uniquely identifies each region
    private func drawOnlayer(pointOnRegionWithIndex: Int) {
        
        currentPath = CGMutablePath()//paths[pointOnRegionWithIndex]
        currentShapeLayer = shapeLayers[pointOnRegionWithIndex]
        
        
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
        ///Insert shape on top of most layers, except point and lines
        view.layer.insertSublayer(currentShapeLayer, at: 98)
        
    }
    
    
    /// Current path is complete, start working on next path:
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let location = touches.first?.location(in: view) else { return }
        // For other manipulations, when touch is close to any point on screen
        if checkIfExists(for: location) {
            
        } else {
            let circle = CircleView(frame: CGRect(x: location.x - 10, y: location.y - 10, width: 20, height: 20), id: currentRegionIndex)
            currentRegion.append(circle)
        }
    }
    
    /// Whether there exists a point in vicinity to touched location
    /// - Parameter point: touch location
    /// - Returns: Whether there is circle(point) on vicinity of touched location
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
    
    /// Move the points based on pan gesture
    /// - Parameter gesture: Normal pan gesture
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

/// Circle view that is used to denote points
/// All circle points have id, that associates them to region
/// Circle (point) can have incoming line and outgoing line: Visualize edge and vertices
/// Incoming circle: circle corresponding to incoming line
/// Outgoint circle: circle corresponding to outgoing line
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
    
    /// Draw line from current circle(point) to outgoing and incoming circle
    /// - Parameter circle: Circle (point) under discussion
    /// - Returns: line originating and going out from current circle
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
