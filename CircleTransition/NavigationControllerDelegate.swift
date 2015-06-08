//
//  NavigationControllerDelegate.swift
//  CircleTransition
//
//  Created by Rounak Jain on 23/10/14.
//  Copyright (c) 2014 Rounak Jain. All rights reserved.
//

import UIKit
//要实现这一步，可在右边库中搜索object,并拖拽到左侧Navigation Controller Source的下面
//现在点击object，在右边Identity Inspector中，将其类更改为NavigationControllerDelegate.
//接下来，右击左面板中的UINavigationController，将object赋给UINavigationController的委托，并将其委托属性拖拽到NavigationControllerDelegate 对象上：
class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
  
//  打开Main.storyboard,右击左侧Navigation Controller Delegate object，将属性和导航控制器连接起来，然后从navigationController属性中 拖到storyboard中的导航控制器上。
  @IBOutlet weak var navigationController: UINavigationController?
  
  var interactionController: UIPercentDrivenInteractiveTransition?
  
//  这一步会创建UIPanGestureRecognizer，并将该对象添加到导航控制器的视图上，并得到panned:方法中的手势回调函数
  override func awakeFromNib() {
    super.awakeFromNib()
    var panGesture = UIPanGestureRecognizer(target: self, action: Selector("panned:"))
    self.navigationController!.view.addGestureRecognizer(panGesture)
  }
  
  

  
  @IBAction func panned(gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
      //  .Began: 只要识别了手势，那么它会初始化一个UIPercentDrivenInteractiveTransition对象并将其赋给interactionController属性。
      //  如果你切换到第一个视图控制器，它初始化了一个push，如果是在第二个视图控制器，那么初始化的是pop。Pop非常简单，但是对于push，你需要从此前创建的按钮底部手动完成segue.
      //  反过来，push/pop调用触发了NavigationControllerDelegate方法调用返回self.interactionController.这样属性就有了non-nil值。
    case .Began:
      self.interactionController = UIPercentDrivenInteractiveTransition()
      if self.navigationController?.viewControllers.count > 1 {
        self.navigationController?.popViewControllerAnimated(true)
      } else {
        self.navigationController?.topViewController.performSegueWithIdentifier("PushSegue", sender: nil)
      }
//      Changed: 这种状态下，你完成了手势的进程并更新了interactionController.插入动画是项艰苦的工作，不过苹果已经做了这部分的工作，你无需做什么事情。
    case .Changed:
      var translation = gestureRecognizer.translationInView(self.navigationController!.view)
      var completionProgress = translation.x/CGRectGetWidth(self.navigationController!.view.bounds)
      self.interactionController?.updateInteractiveTransition(completionProgress)
//      Ended: 你已经看到了pan手势的速度。如果是正数，转场就完成了；如果不是，就是被取消了。你也可以将interactionController设置为nil，这样她就承担了清理的任务。
    case .Ended:
      if (gestureRecognizer.velocityInView(self.navigationController!.view).x > 0) {
        self.interactionController?.finishInteractiveTransition()
      } else {
        self.interactionController?.cancelInteractiveTransition()
      }
      self.interactionController = nil
//      如果是其他任何状态，你可以简单取消转场并将interactionController设置为nil.
    default:
      self.interactionController?.cancelInteractiveTransition()
      self.interactionController = nil
    }
  }
//  返回NavigationControllerDelegate，并添加如下占位符方法： 
//  该方法接受两个需要转场的视图控制器，这将返回一个实现UIViewControllerAnimatedTransitioning的对象。
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return CircleTransitionAnimator()
  }
  
  func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return self.interactionController
  }
}
