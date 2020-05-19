//
//  FloatPointView.swift
//  FloatPoint
//
//  Created by 吴昊原 on 2019/5/20.
//  Copyright © 2019 FloatPoint. All rights reserved.
//

import UIKit

class FloatPointView: NSObject,UIGestureRecognizerDelegate,UINavigationControllerDelegate{
    
    @objc static public let floatPoint = FloatPointView();
    
    let window = UIApplication.shared.keyWindow
    let screenWith = UIScreen.main.bounds.width
    let screenHright = UIScreen.main.bounds.height
    let bgImg = UIImageView()
    @objc let imageView = UIImageView()
    let floatImg = UIImageView()
    let floatLabel = UILabel()
    var formViewController:UIViewController? = nil
    var isOpenVC = false;
    var tmpViewController:UIViewController? = nil
    
    open var openPointVC:((_ viewConttoller:UIViewController) -> Void)? = nil;
    
    lazy var pointView: UIView = {
        let pointV = UIView(frame: CGRect(x: UIScreen.main.bounds.width-70, y: UIScreen.main.bounds.height/3, width: 60, height: 60))
        pointV.layer.cornerRadius = pointV.frame.size.height/2;
        pointV.layer.masksToBounds = true
        pointV.isHidden = true;
        pointV.backgroundColor = UIColor(hexString: "#")
        
        self.imageView.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
        self.imageView.image = UIImage(named: "pointLine")
        self.imageView.isUserInteractionEnabled = true;
        self.imageView.contentMode = UIView.ContentMode.scaleToFill;
        pointV.addSubview(self.imageView)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openViewController(sender:)))
        pointV.addGestureRecognizer(tap)
        return pointV
    }()
    
    lazy var floatView: UIView = {
        
        let floatV = UIView(frame: CGRect(x: self.screenWith, y: self.screenHright, width: self.screenWith/3, height: self.screenWith/3))
        
        self.bgImg.frame = CGRect(x: 0, y: 0, width: floatV.frame.size.width, height: floatV.frame.size.height)
        self.bgImg.contentMode = .scaleToFill
        self.bgImg.image = UIImage(named: "floatWindow")
        floatV.addSubview(self.bgImg)
        
        self.floatImg.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.floatImg.center = bgImg.center
        self.floatImg.image = UIImage(named: "floatPoint")
        self.floatImg.contentMode = .scaleToFill
        bgImg.addSubview(self.floatImg)
        
        self.floatLabel.frame = CGRect(x: 0, y: floatV.frame.size.height-40, width: floatV.frame.size.width, height: 30)
        self.floatLabel.font = UIFont.systemFont(ofSize: 15)
        self.floatLabel.textColor = UIColor.white
        self.floatLabel.textAlignment = NSTextAlignment.center
        self.floatLabel.text = "浮窗"
        bgImg.addSubview(self.floatLabel)
        
        
        return floatV
    }()
    
    override init() {
        super.init()
        

    }
    
    open func isPushVCAnimation() -> PushAnimation? {
        let FPControl = FloatPointView.floatPoint
        if FPControl.isOpenVC {
            return PushAnimation()
        }else{
            return nil;
        }
    }
    
    open func isPopVCAmoation() -> PopAnimation? {
        let FPControl = FloatPointView.floatPoint
        if FPControl.isOpenVC{
            return PopAnimation()
        }else{
            return nil;
        }
    }
    
    @objc func openViewController(sender:UIViewController) {
        let FPControl = FloatPointView.floatPoint
        if FPControl.openPointVC != nil {
            FPControl.openPointVC!(FloatPointView.floatPoint.formViewController!)
        }
    }
    
    
    open func openPoint() {
        let FPControl = FloatPointView.floatPoint
        if (!FPControl.window!.subviews.contains(FPControl.floatView)) {
            FPControl.window!.addSubview(FPControl.floatView)
            FPControl.window!.addSubview(FPControl.pointView)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(sender:)))
            FPControl.pointView.addGestureRecognizer(pan);
        }
    }
    
    @objc func panGestureAction(sender:UIPanGestureRecognizer) {
        let FPControl = FloatPointView.floatPoint
        let points = sender.location(in: FPControl.window)
        
        var rect = FPControl.pointView.frame;
        switch sender.state {
        case .began:
            
            UIView.animate(withDuration: 0.25) {
                self.floatView.transform = CGAffineTransform(translationX: -self.screenWith/3, y: -self.screenWith/3)
            }
            
            break
        case .changed:
            rect.origin = CGPoint(x: points.x-25, y: points.y-25)
            FPControl.pointView.frame = rect;
            if FPControl.floatView.frame.contains(FPControl.pointView.frame) {
                FPControl.bgImg.image = UIImage(named: "floatWindowCancel")
                FPControl.floatImg.image = UIImage(named: "floatPointCancel")
                FPControl.floatLabel.text = "取消浮窗"
            }else{
                FPControl.bgImg.image = UIImage(named: "floatWindow")
                FPControl.floatImg.image = UIImage(named: "floatPoint")
                FPControl.floatLabel.text = "浮窗"
            }
            break
        case .ended:
            let screenWidth = UIScreen.main.bounds.width;
            let max = screenWidth-60;
            let min:CGFloat = 0.0;
            let max_x = FPControl.pointView.frame.origin.x;
            UIView.animate(withDuration: 0.25) {
                if max_x >= max || (max_x < max && max_x > screenWidth/2.0) {
                    var rect = FPControl.pointView.frame;
                    rect.origin.x = max - 10
                    FPControl.pointView.frame = rect;
                }else if max_x <= min || (max_x > min && max_x < screenWidth/2.0)  {
                    var rect = FPControl.pointView.frame;
                    rect.origin.x = min + 10
                    FPControl.pointView.frame = rect;
                }
            }
            if FPControl.floatView.frame.contains(FPControl.pointView.frame) {
                FPControl.pointView.isHidden = true
                FPControl.pointView.frame = CGRect(x: UIScreen.main.bounds.width-70, y: UIScreen.main.bounds.height/3, width: 60, height: 60)
                FPControl.formViewController = FPControl.tmpViewController
                FPControl.bgImg.image = UIImage(named: "floatWindow")
                FPControl.floatImg.image = UIImage(named: "floatPoint")
                FPControl.floatLabel.text = "浮窗"
            }
            UIView.animate(withDuration: 0.25) {
                FPControl.floatView.transform = CGAffineTransform.identity
            }
            
            break
        default:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    internal func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (operation == .push){
            return FloatPointView.floatPoint.isPushVCAnimation()
        }else{
            return FloatPointView.floatPoint.isPopVCAmoation()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = (viewController.navigationController!.viewControllers.count > 1) ? true : false
    }
    
    @objc func closePointView() {
        let FPControl = FloatPointView.floatPoint
        FPControl.floatView.removeFromSuperview()
        FPControl.pointView.removeFromSuperview()
        FPControl.formViewController = nil
        FPControl.pointView.isHidden = true
        FPControl.isOpenVC = false
    }
    
}
