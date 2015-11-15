//
//  KeyboardViewController.swift
//  ableBoard
//
//  Created by Arun Marsten on 11/14/15.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import AudioToolbox // Needed Vibrate the iPhone

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet weak var distLabel: UILabel!
    var xPos = CGPoint().x
    var yPos = CGPoint().y
    var xChange = CGFloat()
    var yChange = CGFloat()
    
    var currentDirection = "up"
    
    var position = 0;
    
    let label = UILabel()
    
    var circles = [UITouch: CircleWithLabel]()
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    
    

    @IBOutlet var nextKeyboardButton: UIButton!
    var heightConstraint:NSLayoutConstraint!
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    
    
        // Add custom view sizing constraints here


    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        
        view.multipleTouchEnabled = true
        
        label.text = ""
        
        label.textAlignment = NSTextAlignment.Center
        
        view.addSubview(label)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePans:")
        view.addGestureRecognizer(gestureRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinches:")
        view.addGestureRecognizer(pinchRecognizer)
    
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .System)
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("🌐", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
    
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.nextKeyboardButton)
    
        let nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let constraint = NSLayoutConstraint(item: self.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 400.0)
        constraint.priority = UILayoutPriority(999)
        self.view.addConstraint(constraint)
    }
    
    
    func handlePans(sender:UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
            
            let translation = sender.translationInView(self.view);
            xChange = (translation.x)
            yChange = (translation.y)
            spot.length = round(100*sqrt((xChange * xChange) + (yChange * yChange)) / 100)
            
            if (translation.x >= 0) {
                if (translation.y >= translation.x) {
//                    print("Swipe Down")
                    currentDirection = "down"
//                    distLabel.text = ("Swiping Down \(spot.length) pixels")
                }
                if (translation.y < 0 && abs(translation.y) >= translation.x) {
//                    print("Swipe Up")
                    currentDirection = "up"
//                    distLabel.text = ("Swiping Up \(spot.length) pixels")
                }
                if (translation.x > abs(translation.y)) {
//                    print("Swipe Right")
                    currentDirection = "right"
//                    distLabel.text = ("Swiping Right \(spot.length) pixels")
                }
            }
            else {
                if (translation.y >= abs(translation.x)) {
//                    print("Swipe Down")
                    currentDirection = "down"
//                    distLabel.text = ("Swiping Down \(spot.length) pixels")
                }
                if (translation.y < 0 && abs(translation.y) > abs(translation.x)) {
//                    print("Swipe Up")
                    currentDirection = "up"
//                    distLabel.text = ("Swiping Up \(spot.length) pixels")
                }
                if (abs(translation.x) > abs(translation.y)) {
//                    print("Swipe Left")
                    currentDirection = "left"
//                    distLabel.text = ("Swiping Left \(spot.length) pixels")
                }
            }
            
            // THIS TELLS US WHAT LETTER IS CURRENTLY SELECTED
            print(circles[circles.startIndex].1.getSelectedLetter(currentDirection, distance: Double(spot.length)))
            
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            keyPressed(circles[circles.startIndex].1.getSelectedLetter(currentDirection, distance: Double(spot.length)))
        }

        
    }
    
    func handlePinches(sender:UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            (textDocumentProxy as UIKeyInput).deleteBackward()
        }
    }
    
    func keyPressed(letter: AnyObject?) {
        (textDocumentProxy as UIKeyInput).insertText(letter! as! String)
    }
    
    class Distance {
        var position = CGPoint()
        var length = CGFloat()
    }
    
    let spot = Distance()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        label.hidden = false
        
        if let touch = touches.first {
            let place = touch.locationInView(view)
            spot.position = place
        }
        
        
        
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
        
        //        if let touch = touches.first {
        //            xPos = touch.locationInView(view).x
        //            yPos = touch.locationInView(view).y
        //            print(xPos, yPos)
        //
        //            xChange = (xPos - spot.position.x)
        //            yChange = (yPos - spot.position.y)
        //            spot.length = sqrt((xChange * xChange) + (yChange * yChange))
        //            distLabel.text = ("\(spot.length)")
        //        }
        
        for touch in touches where circles[touch] != nil
        {
            let circle = circles[touch]!
            
            circle.drawAtPoint(circle.startTouchLocation,
                force: touch.force / touch.maximumPossibleForce)
            
            circle.myForce = Double(touch.force / touch.maximumPossibleForce)
            
            //            print(circle.myForce)
            
        }
        
        highlightHeaviest()
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if (touches.count == 2){
            keyPressed(" ")
        }
        
        //        for touch in touches where circles[touch] != nil
        //        {
        //            let circle = circles[touch]!
        //
        //            circles.removeValueForKey(touch)
        //            circle.removeFromSuperlayer()
        //        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
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
//            let circle = circles[touch]!
            
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
    var letters = [0: ["up": "", "farUp": "", "right": "", "farRight": "", "down": "", "farDown": "", "left": "", "farLeft": ""],       1: ["up": "a", "farUp": "b", "right": "c", "farRight": "d", "down": "e", "farDown": "f", "left": "g", "farLeft": "h"],      2: ["up": "i", "farUp": "j", "right": "j", "farRight": "l", "down": "m", "farDown": "n", "left": "o", "farLeft": "p"],      3: ["up": "q", "farUp": "r", "right": "s", "farRight": "t", "down": "u", "farDown": "v", "left": "w", "farLeft": "x"],      4: ["up": "y", "farUp": "z", "right": "c", "farRight": "d", "down": "e", "farDown": "f", "left": "g", "farLeft": "h" ]]
    
    let innerLettersBoundary = 100.0
    
    override init()
    {
        super.init()
        
        text.foregroundColor = UIColor.whiteColor().CGColor
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
    
    func getSelectedLetter(direction: String, distance: Double) -> String {
        

        let levelLetters = letters[level] // CHANGE




        
        if(direction == "up"){
            if (distance > innerLettersBoundary){
                return (levelLetters?["farUp"])!
            }
            else{
                return (levelLetters?["up"])!
            }
            
        }
        if(direction == "right"){
            if (distance > innerLettersBoundary){
                return (levelLetters?["farRight"])!
            }
            else{
                return (levelLetters?["right"])!
            }
        }
        if(direction == "down"){
            if (distance > innerLettersBoundary){
                return (levelLetters?["farDown"])!
            }
            else{
                return (levelLetters?["down"])!
            }
            
        }
        if(direction == "left"){
            if (distance > innerLettersBoundary){
                return (levelLetters?["farLeft"])!
            }
            else{
                return (levelLetters?["left"])!
            }
        }
        
        return "Uh-oh"
    }
    
    func drawAtPoint(location: CGPoint, force: CGFloat)
    {
        
        text.string = String(format: "%.1f%%", force * 100)
        
        var radius = CGFloat()
        
        switch force * 100 {
        case 0:
            level = 0
            text.string = String(format: "No Level")
            
            radius = CGFloat(0)
            
        case 0.1..<25:
            level = 1
            text.string = String(format: "Level %d", level)
            
            radius = CGFloat(60 + (0.10 * 120))
            
        case 25..<50:
            level = 2
            text.string = String(format: "Level %d", level)
            
            radius = CGFloat(60 + (0.40 * 120))
        case 50..<75:
            level = 3
            text.string = String(format: "Level %d", level)
            
            radius = CGFloat(60 + (0.70 * 120))
        case 75..<200:
            level = 4
            text.string = String(format: "Level %d", level)
            
            radius = CGFloat(60 + (1 * 120))
            //                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        default:
            text.string = String(format: "No level")
        }
        
        text.frame = CGRect(origin: location.offset(dx: 75, dy: -radius), size: CGSize(width: 150, height: 40))
        
        path = UIBezierPath(
            ovalInRect: CGRect(
                origin: location.offset(dx: radius, dy: radius),
                size: CGSize(width: radius * 2, height: radius * 2))).CGPath
        
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
