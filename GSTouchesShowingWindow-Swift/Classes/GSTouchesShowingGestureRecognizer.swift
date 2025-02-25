//
//  GSTouchesShowingGestureRecognizer.swift
//  GSTouchesShowingWindow-Swift
//
//  Created by Lukas Petr on 8/25/17.
//  Copyright © 2017 Glimsoft. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public class GSTouchesShowingGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    let touchesShowingController = GSTouchesShowingController()
    
    public init() {
        super.init(target: nil, action: nil)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        delegate = self
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            touchesShowingController.touchBegan(touch, view: view!)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            touchesShowingController.touchMoved(touch, view: view!)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            touchesShowingController.touchEnded(touch, view: view!)
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            touchesShowingController.touchEnded(touch, view: view!)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
