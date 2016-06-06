//
//  ElasticSegmentedControl.swift
//  ElasticSegmentedControl
//
//  Created by Lasha Efremidze on 6/4/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit

public class ElasticSegmentedControl: UIControl {
    
    public var titles: [String] {
        get { return containerView.titles }
        set { [containerView, selectedContainerView].forEach { $0.titles = newValue } }
    }
    
    public var titleColor: UIColor? {
        didSet { containerView.textColor = titleColor }
    }
    
    public var selectedTitleColor: UIColor? {
        didSet { selectedContainerView.textColor = selectedTitleColor }
    }
    
    public var font: UIFont? {
        didSet { [containerView, selectedContainerView].forEach { $0.font = font } }
    }
    
    public var cornerRadius: CGFloat? {
        didSet { layer.cornerRadius = cornerRadius ?? frame.height / 2 }
    }
    
    public var thumbColor: UIColor? {
        didSet { thumbView.backgroundColor = thumbColor }
    }
    
    public var thumbCornerRadius: CGFloat? {
        didSet { thumbView.layer.cornerRadius = thumbCornerRadius ?? thumbView.frame.height / 2 }
    }
    
    public var thumbInset: CGFloat = 2.0 {
        didSet { setNeedsLayout() }
    }
    
    public internal(set) var selectedIndex: Int = 0
    
    public var animationDuration: NSTimeInterval = 0.3
    public var animationSpringDamping: CGFloat = 0.75
    public var animationInitialSpringVelocity: CGFloat = 0
    
    // MARK: - Private Properties
    
    let containerView = ContainerView()
    let selectedContainerView = ContainerView()
    
    let thumbView = UIView()
    
    var initialX: CGFloat = 0
    
    // MARK: - Constructors
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    public convenience init(titles: [String]) {
        self.init(frame: CGRect())
        
        self.titles = titles
    }
        
    func commonInit() {
        layer.masksToBounds = true
        
        [containerView, thumbView, selectedContainerView].forEach { addSubview($0) }
        
        maskView = UIView()
        maskView?.backgroundColor = .blackColor()
        selectedContainerView.layer.mask = maskView?.layer
        
        // Gestures
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        addObserver(self, forKeyPath: "thumbView.frame", options: .New, context: nil)
        
        stackViews([containerView], axis: .Horizontal)
        stackViews([selectedContainerView], axis: .Horizontal)
    }
    
    // MARK: - Destructor
    
    deinit {
        removeObserver(self, forKeyPath: "thumbView.frame")
    }
    
}

// MARK: -
extension ElasticSegmentedControl {
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(self)
        let index = Int(location.x / (bounds.width / CGFloat(containerView.labels.count)))
        setSelectedIndex(index, animated: true)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            initialX = thumbView.frame.minX
        case .Changed:
            var frame = thumbView.frame
            frame.origin.x = initialX + recognizer.translationInView(self).x
            frame.origin.x = max(min(frame.origin.x, bounds.width - thumbInset - frame.width), thumbInset)
            thumbView.frame = frame
        default:
            let index = max(0, min(containerView.labels.count - 1, Int(thumbView.center.x / (bounds.width / CGFloat(containerView.labels.count)))))
            setSelectedIndex(index, animated: true)
        }
    }
    
    func setSelectedIndex(selectedIndex: Int, animated: Bool) {
        guard 0..<titles.count ~= selectedIndex else { return }
        
        // Reset switch on half pan gestures
        var catchHalfSwitch = false
        if self.selectedIndex == selectedIndex {
            catchHalfSwitch = true
        }
        
        self.selectedIndex = selectedIndex
        if animated {
            if (!catchHalfSwitch) {
                self.sendActionsForControlEvents(.ValueChanged)
            }
            userInteractionEnabled = false
            UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: animationSpringDamping, initialSpringVelocity: animationInitialSpringVelocity, options: [.BeginFromCurrentState, .CurveEaseOut], animations: {
                self.layoutSubviews()
            }, completion: { _ in
                self.userInteractionEnabled = true
            })
        } else {
            layoutSubviews()
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    
}

// MARK: - Layout
public extension ElasticSegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius ?? frame.height / 2
        thumbView.layer.cornerRadius = (thumbCornerRadius ?? thumbView.frame.height / 2)
        
        let width = bounds.width / CGFloat(containerView.labels.count) - thumbInset * 2.0
        thumbView.frame = CGRect(x: thumbInset + CGFloat(selectedIndex) * (width + thumbInset * 2.0), y: thumbInset, width: width, height: bounds.height - thumbInset * 2.0)
    }
    
}

// MARK: - KVO
public extension ElasticSegmentedControl {
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "thumbView.frame" {
            maskView?.frame = thumbView.frame
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension ElasticSegmentedControl: UIGestureRecognizerDelegate {
    
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return thumbView.frame.contains(gestureRecognizer.locationInView(self))
    }
    
}

// MARK: - ContainerView
class ContainerView: UIView {
    
    var labels = [UILabel]()
    
    var textColor: UIColor? {
        didSet { labels.forEach { $0.textColor = textColor } }
    }
    
    var font: UIFont? {
        didSet { labels.forEach { $0.font = font } }
    }
    
    var titles: [String] {
        get { return labels.flatMap { $0.text } }
        set {
            labels.forEach { $0.removeFromSuperview() }
            labels = newValue.map { title in
                let label = UILabel()
                label.text = title
                label.textColor = textColor
                label.font = font
                label.textAlignment = .Center
                addSubview(label)
                return label
            }
//            stackViews(labels, axis: .Horizontal)
        }
    }
    
}

extension UIView {
    
    enum Axis {
        case Horizontal, Vertical
    }
    
    func stackViews(views: [UIView], axis: Axis) {
        NSLayoutConstraint.deactivateConstraints(self.constraints)
        
        var dict = [String: UIView]()
        views.enumerate().forEach { dict["view\($0)"] = $1 }
        let keys = dict.keys.sort(<).map { "[" + $0 + "]" }
        
        switch axis {
        case .Horizontal:
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|\(keys.joinWithSeparator(""))|", options: [], metrics: nil, views: dict))
            keys.forEach {
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|\($0)|", options: [], metrics: nil, views: dict))
            }
        case .Vertical:
            keys.forEach {
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|\($0)|", options: [], metrics: nil, views: dict))
            }
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|\(keys.joinWithSeparator(""))|", options: [], metrics: nil, views: dict))
        }
        
        print(constraints)
    }
    
}
