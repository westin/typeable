//
//  ViewController.swift
//  Plum-o-Meter
//
//  Created by Simon Gladman on 24/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import AudioToolbox // Needed Vibrate the iPhone

class ViewController: UIViewController{
    
    let label = UILabel()
    
    var circles = [UITouch: CircleWithLabel]()
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.multipleTouchEnabled = true
        
        label.text = "typeable"
        
        label.textAlignment = NSTextAlignment.Center
        
        view.addSubview(label)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePans:")
        view.addGestureRecognizer(gestureRecognizer)

    }

    func handlePans(sender:UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
            
            let translation = sender.translationInView(self.view);
            // note: 'view' is optional and need to be unwrapped
            
            
            //            sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)

            if (translation.x >= 0) {
                if (translation.y > translation.x) {
                    print("Swipe Down")
                }
                if (translation.y < 0 && abs(translation.y) > translation.x) {
                    print("Swipe Up")
                }
                else {print("Swipe Right")}
            }
            else {
                if (translation.y > abs(translation.x)) {
                    print("Swipe Down")
                }
                if (translation.y < 0 && abs(translation.y) > abs(translation.x)) {
                    print("Swipe Up")
                }
                else {print("Swipe Left")}
            }
        }
        
    }
        

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        label.hidden = true
        
        // this clears out all other circle objects on the screen
        circles.forEach
        {
            circles.removeValueForKey($0.0)
            $0.1.removeFromSuperlayer()
        }

        for touch in touches
        {
            let circle = CircleWithLabel()
            circle.startTouchLocation = touch.locationInView(view)
            
            circle.drawAtPoint(touch.locationInView(view),
                force: touch.force / touch.maximumPossibleForce)
            
//            circle.myForce = Double(touch.force / touch.maximumPossibleForce)
            
            circles[touch] = circle
            view.layer.addSublayer(circle)
        }
        
        highlightHeaviest()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches where circles[touch] != nil
        {
            let circle = circles[touch]!
            
            circle.drawAtPoint(circle.startTouchLocation,
                force: touch.force / touch.maximumPossibleForce)

            circle.myForce = Double(touch.force / touch.maximumPossibleForce)
            
            print(circle.myForce)
            
        }
        
        highlightHeaviest()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
//        for touch in touches where circles[touch] != nil
//        {
//            let circle = circles[touch]!
//            
//            circles.removeValueForKey(touch)
//            circle.removeFromSuperlayer()
//        }
        
        highlightHeaviest()
    }

    
    // this part gets called immeditely after we notice you're swiping in a certain direction
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        guard let touches = touches else
        {
            return
        }
        
        for touch in touches where circles[touch] != nil
        {
            let circle = circles[touch]!
            
//            circle.removeFromSuperlayer()
        }
    }
    
    func highlightHeaviest()
    {
        func getMaxTouch() -> UITouch?
        {
            return circles.sort({
                (a: (UITouch, CircleWithLabel), b: (UITouch, CircleWithLabel)) -> Bool in
                
                return a.0.force > b.0.force
            }).first?.0
        }
        
        circles.forEach
        {
            $0.1.isMax = $0.0 == getMaxTouch()
        }
    }
    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
//    {
//        return UIInterfaceOrientationMask.Landscape
//    }
    
    override func viewDidLayoutSubviews()
    {
        label.frame = view.bounds
    }
}

// -------------

class CircleWithLabel: CAShapeLayer
{
    let text = CATextLayer()
    var myForce = 0.0
    var startTouchLocation = CGPoint()
    var level: Int = 0 {
        didSet {
            if level != oldValue{
                UIDevice.currentDevice().tapticEngine().actuateFeedback(UITapticEngineFeedbackPeek)
            }
        }
    }
    
    override init()
    {
        super.init()
        
        text.foregroundColor = UIColor.blueColor().CGColor
        text.alignmentMode = kCAAlignmentCenter
        addSublayer(text)
        
        strokeColor = UIColor.blueColor().CGColor
        lineWidth = 1
        fillColor = nil
    }
    
    override init(layer: AnyObject)
    {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isMax: Bool = false
    {
        didSet
        {
            fillColor = isMax ? UIColor.whiteColor().CGColor : nil
        }
    }
    
    func drawAtPoint(location: CGPoint, force: CGFloat)
    {
        
        text.string = String(format: "%.1f%%", force * 100)
        
        switch force * 100 {
            case 0:
                level = 0
                text.string = String(format: "No Level")
            
                let radius = CGFloat(0)
                text.frame = CGRect(origin: location.offset(dx: 75, dy: -radius), size: CGSize(width: 150, height: 40))
                
                path = UIBezierPath(
                    ovalInRect: CGRect(
                        origin: location.offset(dx: radius, dy: radius),
                        size: CGSize(width: radius * 2, height: radius * 2))).CGPath
            case 0.1..<25:
                level = 1
                text.string = String(format: "Level %d", level)
            
                let radius = CGFloat(60 + (0.10 * 120))
                text.frame = CGRect(origin: location.offset(dx: 75, dy: -radius), size: CGSize(width: 150, height: 40))
                
                path = UIBezierPath(
                    ovalInRect: CGRect(
                        origin: location.offset(dx: radius, dy: radius),
                        size: CGSize(width: radius * 2, height: radius * 2))).CGPath
            case 25..<50:
                level = 2
                text.string = String(format: "Level %d", level)
            
                let radius = CGFloat(60 + (0.40 * 120))
                text.frame = CGRect(origin: location.offset(dx: 75, dy: -radius), size: CGSize(width: 150, height: 40))
                
                path = UIBezierPath(
                    ovalInRect: CGRect(
                        origin: location.offset(dx: radius, dy: radius),
                        size: CGSize(width: radius * 2, height: radius * 2))).CGPath
            case 50..<75:
                level = 3
                text.string = String(format: "Level %d", level)
            
                let radius = CGFloat(60 + (0.70 * 120))
                text.frame = CGRect(origin: location.offset(dx: 75, dy: -radius), size: CGSize(width: 150, height: 40))
                
                path = UIBezierPath(
                    ovalInRect: CGRect(
                        origin: location.offset(dx: radius, dy: radius),
                        size: CGSize(width: radius * 2, height: radius * 2))).CGPath
            case 75..<200:
                level = 4
                text.string = String(format: "Level %d", level)
                
                let radius = CGFloat(60 + (1 * 120))
                
                path = UIBezierPath(
                    ovalInRect: CGRect(
                        origin: location.offset(dx: radius, dy: radius),
                        size: CGSize(width: radius * 2, height: radius * 2))).CGPath

                print(force * 100)
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            default:
                text.string = String(format: "No level")
        }
        
    }
}

// -------------

extension CGPoint
{
    func offset(dx dx: CGFloat, dy: CGFloat) -> CGPoint
    {
        return CGPoint(x: self.x - dx, y: self.y - dy)
    }
}
