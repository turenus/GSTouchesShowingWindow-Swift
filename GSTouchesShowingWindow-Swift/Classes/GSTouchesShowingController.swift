//
//  GSTouchesShowingController.swift
//  GSTouchesShowingWindow-Swift
//
//  Created by Lukas Petr on 8/25/17.
//  Copyright © 2017 Glimsoft. All rights reserved.
//

import UIKit

class GSTouchesShowingController {
    
    var touchViewQueue = GSTouchViewQueue(touchesCount: 8)
    var touchViewsDict = Dictionary<String, UIView>()
    var touchesStartDateMapTable = NSMapTable<UITouch, NSDate>()
    var appearance:TouchAppearance = TouchAppearance()
    
    public func touchBegan(_ touch: UITouch, view: UIView) -> Void {
        let touchView = touchViewQueue.popTouchView()
        touchView.frame = CGRect(x: 0, y: 0, width: appearance.shortTapFinalCircleRadius, height: appearance.shortTapFinalCircleRadius )
        touchView.layer.cornerRadius = touchView.bounds.size.width / 2.0
        touchView.center = touch.location(in: view)
        touchView.backgroundColor = appearance.touchColor
        view.addSubview(touchView)
        
        touchView.alpha = 0.0
        touchView.transform = CGAffineTransform(scaleX: 1.13, y: 1.13)
        setTouchView(touchView, for: touch)
        
        UIView.animate(withDuration: 0.1) { 
            touchView.alpha = 1.0
            touchView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        touchesStartDateMapTable.setObject(NSDate(), forKey: touch)
    }
    
    public func touchMoved(_ touch: UITouch, view: UIView) -> Void {
        touchView(for: touch)?.center = touch.location(in: view)
    }
    
    public func touchEnded(_ touch: UITouch, view: UIView) -> Void {
        guard
            let touchView = touchView(for: touch),
            let touchStartDate = touchesStartDateMapTable.object(forKey: touch)
        else { return }
        let touchDuration = NSDate().timeIntervalSince(touchStartDate as Date)
        touchesStartDateMapTable.removeObject(forKey: touch)
        
        if touchDuration < appearance.shortTapTresholdDuration {
            showExpandingCircle(at: touch.location(in: view), in: view)
        }
        
        UIView.animate(withDuration: 0.1, animations: { 
            touchView.alpha = 0.0
            touchView.transform = CGAffineTransform(scaleX: 1.13, y: 1.13)
        }) { [unowned self] (completed) in
            touchView.removeFromSuperview()
            touchView.alpha = 1.0
            touchViewQueue.push(touchView)
            removeTouchView(for: touch)
        }
    }
    
    func showExpandingCircle(at position: CGPoint, in view: UIView) -> Void {
        let circleLayer = CAShapeLayer()
        let initialRadius = appearance.shortTapInitialCircleRadius
        let finalRadius = appearance.shortTapFinalCircleRadius
        circleLayer.position = CGPoint(x: position.x - initialRadius, y: position.y - initialRadius)
        
        let startPathRect = CGRect(x: 0, y: 0, width: initialRadius * 2, height: initialRadius * 2)
        let startPath = UIBezierPath(roundedRect: startPathRect, cornerRadius: initialRadius)
        
        let endPathOrigin = initialRadius - finalRadius
        let endPathRect = CGRect(x: endPathOrigin, y: endPathOrigin, width: finalRadius * 2, height: finalRadius * 2)
        let endPath = UIBezierPath(roundedRect: endPathRect, cornerRadius: finalRadius)
        
        circleLayer.path = startPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = appearance.touchColor.cgColor
        circleLayer.lineWidth = 2.0
        view.layer.addSublayer(circleLayer)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { 
            circleLayer.removeFromSuperlayer()
        }
        
        // Expanding animation
        let expandingAnimation = CABasicAnimation(keyPath: "path")
        expandingAnimation.fromValue = startPath.cgPath
        expandingAnimation.toValue = endPath.cgPath
        expandingAnimation.timingFunction = CAMediaTimingFunction(name: .linear )
        expandingAnimation.duration = 0.4
        expandingAnimation.repeatCount = 1.0
        circleLayer.add(expandingAnimation, forKey: "expandingAnimation")
        circleLayer.path = endPath.cgPath
        
        // Delayed fade out animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            let fadingOutAnimation = CABasicAnimation(keyPath: "opacity")
            fadingOutAnimation.fromValue = 1.0
            fadingOutAnimation.toValue = 0.0
          fadingOutAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut )
            fadingOutAnimation.duration = 0.15
            circleLayer.add(fadingOutAnimation, forKey: "fadeOutAnimation")
            circleLayer.opacity = 0.0
        }
        
        CATransaction.commit()
    }
    
    func touchView(for touch: UITouch) -> UIView? {
        return touchViewsDict["\(touch.hash)"]
    }
    
    func setTouchView(_ touchView: UIView, for touch: UITouch) {
        touchViewsDict["\(touch.hash)"] = touchView
    }
    
    func removeTouchView(for touch: UITouch) {
        touchViewsDict.removeValue(forKey: "\(touch.hash)")
    }
}

class GSTouchViewQueue {
    
    var backingArray = Array<UIView>();
    
    convenience init(touchesCount: Int) {
        self.init()
        
        for _ in 0..<touchesCount {
          let view = createTouchView()
          backingArray.append(view)
        }
    }
    
    func popTouchView() -> UIView {
        return backingArray.removeFirst()
    }
    
    func push(_ touchView: UIView) -> Void {
        backingArray.append(touchView)
    }
}

func createTouchView() -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    view.isUserInteractionEnabled = false
    return view
}
