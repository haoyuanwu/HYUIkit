//
//  ViewControllerAnimatedFolatPoint.swift
//  FloatPoint
//
//  Created by 吴昊原 on 2019/5/20.
//  Copyright © 2019 FloatPoint. All rights reserved.
//

import UIKit

var FloatPointkey = "FloatPointkey"

extension UIViewController {
    
    var floatPoint: FloatPointView?{
        set {
            objc_setAssociatedObject(self, &FloatPointkey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &FloatPointkey) as? FloatPointView
        }
    }
    
    @objc func openPointView(){
        
        FloatPointView.floatPoint.tmpViewController = self
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(action(sender:)))
    }
    
    @objc func action(sender:UIPanGestureRecognizer) {
        
        floatPoint = FloatPointView.floatPoint
        if floatPoint?.openPointVC == nil {
            floatPoint!.openPointVC = { (viewController:UIViewController) in
                self.floatPoint?.pointView.alpha = 0
                self.floatPoint?.isOpenVC = true
                viewController.navigationController?.delegate = self.floatPoint
                viewController.navigationController?.transitioningDelegate = (self.floatPoint as! UIViewControllerTransitioningDelegate)
                let vc = UIApplication.shared.keyWindow?.rootViewController
                if (vc!.isKind(of: UINavigationController.classForCoder())) {
                    let nav = vc as! UINavigationController
                    nav.pushViewController(viewController, animated: true)
                }else if (vc!.isKind(of: UITabBarController.classForCoder())) {
                    let tabbatVC = vc as! UITabBarController
                    let nav = tabbatVC.selectedViewController as! UINavigationController
                    nav.pushViewController(viewController, animated: true)
                }
                
            }
        }
        
        let point = sender.translation(in: view)
        let points = sender.location(in: view)
        
        let screenWith = UIScreen.main.bounds.width
        switch sender.state {
        case .began:
        
            floatPoint!.openPoint()
            break
        case .changed:
            if (points.x < 0 ) {
                if (points.x <= -screenWith*2/3) {
                    UIView.animate(withDuration: 0.2) {
                        self.floatPoint!.floatView.transform = CGAffineTransform(translationX: -point.x, y: -point.x)
                    }
                }else{
                    floatPoint!.floatView.transform = CGAffineTransform(translationX: -screenWith/3, y: -screenWith/3)
                }
                if (floatPoint?.formViewController != nil) {
                    if floatPoint!.isOpenVC {
                        floatPoint?.pointView.alpha = (screenWith+points.x)/screenWith
                    }
                }
            }
            let tmpPoint:CGPoint?;
            if points.x < 0 {
                tmpPoint = CGPoint(x: screenWith+points.x, y: points.y)
            }else{
                tmpPoint = CGPoint(x: points.x, y: points.y)
            }
            
            if floatPoint!.floatView.frame.contains(tmpPoint!) {
                UIView.animate(withDuration: 0.25) {
                    self.floatPoint?.bgImg.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
            }else{
                UIView.animate(withDuration: 0.25) {
                    self.floatPoint?.bgImg.transform = CGAffineTransform.identity
                }
            }
            
            break
        case .ended:
            let tmpPoint:CGPoint?;
            if points.x < 0 {
               tmpPoint = CGPoint(x: screenWith+points.x, y: points.y)
            }else{
                tmpPoint = CGPoint(x: points.x, y: points.y)
            }
            
            if floatPoint!.isOpenVC {
                if points.x < 0 {
                    if (screenWith+points.x > screenWith/2) {
                        floatPoint?.pointView.alpha = 1
                    }else{
                        floatPoint?.pointView.alpha = 0
                    }
                }else{
                    if (points.x > screenWith/2) {
                        floatPoint?.pointView.alpha = 1
                    }else{
                        floatPoint?.pointView.alpha = 0
                    }
                }
            }
            
            if floatPoint!.floatView.frame.contains(tmpPoint!) {
                floatPoint!.pointView.isHidden = false;
                floatPoint?.pointView.alpha = 1
                floatPoint!.formViewController = FloatPointView.floatPoint.tmpViewController
            }
            UIView.animate(withDuration: 0.25) {
                self.floatPoint?.bgImg.transform = CGAffineTransform.identity
                self.floatPoint?.floatView.transform = CGAffineTransform.identity
            }
            break
        default:
            break
        }
    }
    
    @objc func popViewController(sender:UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        switch sender.state {
        case .began:
//            self.navigationController?.popViewController(animated: true)
            break
        case .changed:
            self.view.transform = CGAffineTransform(translationX: point.x, y: 0)
            break
        case .ended:
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform.identity
            }
            break
        default:
            break
        }
    }
}
