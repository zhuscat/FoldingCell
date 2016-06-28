//
//  FoldingCell.swift
//  FoldingCell
//
//  Created by Leaf on 16/6/19.
//  Copyright © 2016年 zhuscat. All rights reserved.
//

import UIKit
import QuartzCore

class FoldingCell: UITableViewCell {
    
    @IBOutlet weak var foldedView: RotationView!
    @IBOutlet weak var unfoldedView: RotationView!
    @IBOutlet weak var foldedViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var unfoldedViewTopCons: NSLayoutConstraint!
    
    var totalDuration: NSTimeInterval {
        get {
            return duration * NSTimeInterval(itemCount)
        }
    }
    
    var duration: NSTimeInterval = 0.1
    
    var itemCount = 5
    
    var open = false
    
    // animationView 是用来展现动画的一个视图
    var animationView: UIView?
    
    // 放置动画需要的元素
    var animationItems: [RotationView] = []
    // 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        unfoldedViewTopCons.constant = foldedViewTopCons.constant
        unfoldedView.alpha = 0
        foldedView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        foldedView.transform3D()
        // 消除anchorPoint移动造成的偏移
        foldedViewTopCons.constant += foldedView.bounds.height * 0.5
        
        foldedView.layer.cornerRadius = 10
        foldedView.layer.masksToBounds = true
        unfoldedView.layer.cornerRadius = 10
        unfoldedView.layer.masksToBounds = true
        
        createAnimationView()
        self.contentView.bringSubviewToFront(foldedView)
        print("setup called")
    }
    
    func createAnimationView() {
        let animView = UIView(frame: CGRect.zero)
        animView.alpha = 0
        animView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animView)
        // 添加contentView里面的约束
        for constraint in self.contentView.constraints {
            if let itemView = constraint.firstItem as? UIView where itemView == unfoldedView{
                let itemConstraint = NSLayoutConstraint(item: animView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
                self.contentView.addConstraint(itemConstraint)
            }
            if let itemView = constraint.secondItem as? UIView where itemView == unfoldedView {
                let itemConstraint = NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: animView, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
                self.contentView.addConstraint(itemConstraint)
            }
        }
        // 添加unfoled里面的高度约束
        for constraint in unfoldedView.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                let itemConstraint = NSLayoutConstraint(item: animView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
                animView.addConstraint(itemConstraint)
            }
        }
        animationView = animView
    }
    
    func prepareAnimation() {
        for view in animationView!.subviews.filter({$0 is RotationView}) {
            view.alpha = 0
        }
    }
    
    func cellTouched() {
        open = !open
        if open {
            startOpenAnimation()
        } else {
            startCloseAnimation()
        }
    }
    
    func startOpenAnimation() {
        removeSnapshots()
        addSnapshots()
        prepareAnimation()
        
        unfoldedView.alpha = 0
        animationView?.alpha = 1
        // 参数配置
        var from:CGFloat = 0.0
        var to = CGFloat(-M_PI / 2)
        var duration = 0.1
        var delay: NSTimeInterval = 0
        var timing = kCAMediaTimingFunctionEaseIn
        var hidden = true
        for i in 0..<animationItems.count {
            animationItems[i].startFoldingAnimation(from, to: to, duration: duration, delay: delay, timing: timing, hidden: hidden)
            from = (from == 0.0) ? CGFloat(M_PI / 2) : 0.0
            to = (to == 0.0) ? CGFloat(-M_PI / 2) : 0.0
            hidden = !hidden
            timing = (timing == kCAMediaTimingFunctionEaseIn) ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn
            delay += 0.1
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.animationView?.alpha = 0
            self.unfoldedView.alpha = 1
        })
    }
    
    func prepareCloseAnimation() {
        // 将所有旋转的视图显示出来，其背部视图隐藏
        for view in animationView!.subviews.filter({$0 is RotationView}) {
            (view as! RotationView).alpha = 1
            (view as! RotationView).backView?.alpha = 0
        }
    }
    
    func startCloseAnimation() {
        removeSnapshots()
        addSnapshots()
        prepareCloseAnimation()
        unfoldedView.alpha = 0
        animationView?.alpha = 1
        // 参数配置
        var from: CGFloat = 0.0
        var to: CGFloat = CGFloat(M_PI / 2)
        var duration = 0.1
        var delay: NSTimeInterval = 0
        var timing = kCAMediaTimingFunctionEaseIn
        var hidden = true
        for i in (0...animationItems.count - 1).reverse() {
            animationItems[i].startFoldingAnimation(from, to: to, duration: duration, delay: delay, timing: timing, hidden: hidden)
            from = (from == 0.0) ? CGFloat(-M_PI / 2) : 0.0
            to = (to == 0.0) ? CGFloat(M_PI / 2) : 0.0
            hidden = !hidden
            timing = (timing == kCAMediaTimingFunctionEaseIn) ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn
            delay += 0.1
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { 
            self.animationView?.alpha = 0
            self.foldedView.alpha = 1
        }
    }
    
    func removeSnapshots() {
        if let animView = animationView {
            for view in animView.subviews {
                view.removeFromSuperview()
            }
        }
        animationItems.removeAll()
    }
    
    // 添加 rotationView 到 animationView 上面
    func addSnapshots() {
        guard let animView = animationView else {
            fatalError("animationView is nil")
        }
        unfoldedView.alpha = 1
        // 第一张截图，与foldedView相同大小的, 取自unfoldedView中
        let foldedViewBounds = foldedView.bounds
        let unfoldedViewBounds = unfoldedView.bounds
        print(foldedViewBounds)
        let firstImage = unfoldedView.takeSnapShot(CGRect(x: 0, y: 0, width: unfoldedViewBounds.width, height: foldedViewBounds.height))
        let firstImageView = UIImageView(image: firstImage)
        firstImageView.tag = 100
        animView.addSubview(firstImageView)
        firstImageView.frame.origin = CGPoint(x: 0, y: 0)
        // 第二张图片，与foldedView相同大小的，取自unfoledView中，第二张视图是可以旋转的视图，所以要包装到RotationView里面
        let secondImage = unfoldedView.takeSnapShot(CGRect(x: 0, y: foldedViewBounds.height, width: unfoldedViewBounds.width, height: foldedViewBounds.height))
        let secondImageView = UIImageView(image: secondImage)
        let rotationView = RotationView(frame: secondImageView.frame)
        rotationView.addSubview(secondImageView)
        rotationView.transform3D()
        rotationView.tag = 101
//        rotationView.addBackView(UIColor.redColor())
        animView.addSubview(rotationView)
        rotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        rotationView.frame.origin = CGPoint(x: 0, y: foldedViewBounds.height)
        // 接着按照给的参数来获取剩余需要的
        let itemHeight = (unfoldedViewBounds.height - 2 * foldedViewBounds.height) / CGFloat(itemCount - 2)
        var positionY = foldedViewBounds.height * 2
        var tag = 102
        for i in 0..<itemCount - 2 {
            let image = unfoldedView.takeSnapShot(CGRect(x: 0, y: positionY, width: unfoldedViewBounds.width, height: itemHeight))
            let imageView = UIImageView(image: image)
            let rotationView = RotationView(frame: imageView.frame)
            rotationView.addSubview(imageView)
//            if i != itemCount - 3 {
//                rotationView.addBackView(UIColor.redColor())
//            }
            rotationView.tag = tag
            rotationView.transform3D()
            animView.addSubview(rotationView)
            rotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            rotationView.frame.origin = CGPoint(x: 0, y: positionY)
            positionY = positionY + itemHeight
            tag = tag + 1
        }
        unfoldedView.alpha = 0
        
        var previousView: RotationView?
        
        for view in animView.subviews.filter({$0.tag > 100 && $0.tag < 100 + itemCount && $0 is RotationView}).sort({$0.tag < $1.tag}) {
            previousView?.addBackView(view.frame.height, color: UIColor.lightGrayColor())
            previousView = (view as! RotationView)
        }
        
        addAnimationItems()
    }
    
    func addAnimationItems() {
        guard let animationViewSubviews = animationView?.subviews else {
            fatalError("animationView is nil")
        }
        var items = [RotationView]()
        items.append(foldedView)
        animationViewSubviews.sort { (view1, view2) -> Bool in
            return view1.tag < view2.tag
        }.filter { (view) -> Bool in
            return (view.tag > 100) && (view.tag < 100 + itemCount) && (view is RotationView)
        }.forEach { (view) in
            if let v = view as? RotationView {
                items.append(v)
                if let backView = v.backView {
                    items.append(backView)
                }
            }
        }
        print(items.count)
        animationItems = items
    }
}

/// 能够绕着一根轴旋转的UIView
class RotationView: UIView {
    
    var hiddenAfterAnimation = false
    
    var backView: RotationView?
    
    // 修改layer的transform值
    func rotateX(angle: CGFloat) {
        var transform = CATransform3DIdentity
        let rotateTransform = CATransform3DMakeRotation(angle, 1, 0, 0)
        transform = CATransform3DConcat(transform, rotateTransform)
        transform = CATransform3DConcat(transform, transform3D())
        self.layer.transform = transform
    }
    
    // 返回一个修改过m34的transform值
    func transform3D() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 500
        return transform
    }
    
    func addBackView(height: CGFloat, color: UIColor) {
        let rotationView = RotationView(frame: CGRect.zero)
        rotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        rotationView.translatesAutoresizingMaskIntoConstraints = false
        rotationView.transform3D()
        rotationView.backgroundColor = color
        addSubview(rotationView)
        // 添加约束
        let constraintHeight = NSLayoutConstraint(item: rotationView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: height)
        
        let constraintLeft = NSLayoutConstraint(item: rotationView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        let constraintRight = NSLayoutConstraint(item: rotationView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0)
        let constraintTop = NSLayoutConstraint(item: rotationView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: self.bounds.height - height + height / 2)
        self.addConstraints([constraintLeft, constraintRight, constraintTop, constraintHeight])
        
        backView = rotationView
    }
    
    // 旋转
    func startFoldingAnimation(from: CGFloat, to: CGFloat, duration: NSTimeInterval, delay: NSTimeInterval, timing: String, hidden: Bool) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.x")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: timing)
        animation.removedOnCompletion = false
        animation.delegate = self
        
        self.hiddenAfterAnimation = hidden
        
        self.layer.addAnimation(animation, forKey: "rotate.x")
    }
    
    // delegate
    override func animationDidStart(anim: CAAnimation) {
        self.alpha = 1
        self.layer.shouldRasterize = true
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if hiddenAfterAnimation {
            self.alpha = 0
        }
        self.layer.shouldRasterize = false
        rotateX(0)
    }
}

extension UIView {
    func takeSnapShot(frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, frame.origin.x * -1, frame.origin.y * -1)
        
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.renderInContext(currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}