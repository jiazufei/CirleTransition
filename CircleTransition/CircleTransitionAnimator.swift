//
//  CircleTransitionAnimator.swift
//  CircleTransition
//
//  Created by Rounak Jain on 23/10/14.
//  Copyright (c) 2014 Rounak Jain. All rights reserved.
//

import UIKit

class CircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//  你会需要它来储存转场上下文环境
  weak var transitionContext: UIViewControllerContextTransitioning?
//  你需要返回动画的持续时间。如果你希望动画持续0.5s，那可以返回0.5
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.5;
  }






  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    self.transitionContext = transitionContext
    
    //  1.在超出该方法范围外保持对transitionContext的引用，以便将来访问。
    var containerView = transitionContext.containerView()
    //
    //  2.创建从容器视图到视图控制器的引用。容器视图是动画发生的地方，切换的视图控制器是动画的一部分。
    var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ViewController
    //
    //  3.添加toViewController作为containerView的子视图。
    var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ViewController
    var button = fromViewController.button
    
    containerView.addSubview(toViewController.view)
    //
    //  4.创建两个圆形UIBezierPath实例：一个是按钮的尺寸，一个实例的半径范围可覆盖整个屏幕。最终的动画将位于这两个Bezier路径间。
    var circleMaskPathInitial = UIBezierPath(ovalInRect: button.frame)
    var extremePoint = CGPoint(x: button.center.x - 0, y: button.center.y - CGRectGetHeight(toViewController.view.bounds))
    var radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
    
    var circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(button.frame, -radius, -radius))
    
    //
    //  5.创建一个新的CAShapeLayer来展示圆形遮罩。你可以在动画之后使用最终的循环路径指定其路径值，以避免图层在动画完成后回弹。
    var maskLayer = CAShapeLayer()
    maskLayer.path = circleMaskPathFinal.CGPath
    toViewController.view.layer.mask = maskLayer
    
    //
    //  6.在关键路径上创建一个CABasicAnimation，从circleMaskPathInitial到circleMaskPathFinal.你也要注册一个委托，因为你要在动画完成后做一些清理工作。
    var maskLayerAnimation = CABasicAnimation(keyPath: "path")
    maskLayerAnimation.fromValue = circleMaskPathInitial.CGPath
    maskLayerAnimation.toValue = circleMaskPathFinal.CGPath
    maskLayerAnimation.duration = self.transitionDuration(transitionContext)
    maskLayerAnimation.delegate = self
    maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
  }
//  第一行是告知iOS动画的完成。由于动画已经完成了，所以你可以移除遮罩。最后一步是实际使用CircleTransitionAnimator.
  override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
    self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled())
    self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
  }
  
}
