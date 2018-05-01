//
//  AKStepper.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

/// Incrementor view, normally used for MIDI presets, but could be useful elsehwere
open class AKStepper: UIView {

    @IBInspectable open var text: String = "Stepper"
    var label: UILabel! //fixme
    var valueLabel: UILabel! //fixme}
    open var showsValue: Bool = true
    public var plusButton: AKButton!
    public var minusButton: AKButton!
    @IBInspectable public var currentValue: Double = 0.5 {
        didSet{
            DispatchQueue.main.async {
                self.valueLabel.text = String(format: "%.3f", self.currentValue)
            }
            
        }
    }
    @IBInspectable public var increment: Double = 0.1
    @IBInspectable public var minimum: Double = 0
    @IBInspectable public var maximum: Double = 1
    internal var originalValue:Double = 0.5
    open var callback: (Double)->Void = {val in
        print("callback: \(val)")
    }

    internal func doPlusAction(){
        currentValue += min(increment, maximum - currentValue)
        callback(currentValue)
    }
    internal func doMinusAction(){
        currentValue -= min(increment, currentValue - minimum)
        callback(currentValue)
    }
    /// Initialize the stepper view
    public init(text: String, value: Double, minimum: Double, maximum: Double, increment: Double,
                frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100),
                callback: @escaping (Double) -> Void) {
        self.callback = callback
        self.minimum = minimum
        self.maximum = maximum
        self.increment = increment
        self.currentValue = value
        self.originalValue = value
        self.text = text
        super.init(frame: frame)
        checkValues()
        setupButtons()
    }

    /// Initialize within Interface Builder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        checkValues()
        self.originalValue = currentValue
        setupButtons()
    }
    override open func awakeFromNib() {
        checkValues()
        super.awakeFromNib()
    }
    /// Draw the stepper
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        genStackViews(rect: rect)
    }
    
    private func genStackViews(rect: CGRect){
        let borderWidth = minusButton!.borderWidth
        label = UILabel(frame: CGRect(x: rect.origin.x + borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3))
        label.text = text
        label.textAlignment = .left
        valueLabel = UILabel(frame: CGRect(x: rect.origin.x - borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3))
        valueLabel.text = "\(currentValue)"
        valueLabel.textAlignment = .right
        
        let buttons = UIStackView(frame: CGRect(x: rect.origin.x, y: rect.origin.y + label.frame.height, width: rect.width, height: rect.height * 0.7))
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 5
        
        addToStackIfPossible(view: minusButton, stack: buttons)
        addToStackIfPossible(view: plusButton, stack: buttons)
        
        self.addSubview(label)
        self.addSubview(buttons)
        if showsValue {
            self.addSubview(valueLabel)
        }
    }
    
    /// Require constraint-based layout
    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }
    override open func layoutSubviews() {
        minusButton?.setNeedsDisplay()
        plusButton?.setNeedsDisplay()
    }
    private func addToStackIfPossible(view: UIView?, stack: UIStackView){
        if view != nil{
            stack.addArrangedSubview(view!)
        }
    }
    internal func checkValues(){
        assert(minimum < maximum)
        assert(currentValue >= minimum)
        assert(currentValue <= maximum)
        assert(increment < maximum - minimum)
        originalValue = currentValue
    }
    internal func setupButtons(){
        plusButton = AKButton(title: "+", callback: {_ in
            self.doPlusAction()
        })
        minusButton = AKButton(title: "-", callback: {_ in
            self.doMinusAction()
        })
    }
}
