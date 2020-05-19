//
//  PopAnimation.swift
//  FloatPoint
//
//  Created by 吴昊原 on 2019/5/21.
//  Copyright © 2019 FloatPoint. All rights reserved.
//

import UIKit

class PopAnimation: NSObject,UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let container: UIView = transitionContext.containerView
        
        let fpView = FloatPointView.floatPoint
        fromVC?.view.layer.cornerRadius = fpView.pointView.frame.size.height/2
        
        container.addSubview(toVC!.view)
        container.sendSubviewToBack(toVC!.view)
        // 执行动画
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeLinear, animations: {
            fromVC?.view.frame = fpView.pointView.frame
            let view = FloatPointView.floatPoint
            view.pointView.alpha = 1
            view.isOpenVC = false
        }) { finished in
            
            fromVC!.view.removeFromSuperview()
            //一定要记得动画完成后执行此方法，让系统管理 navigation
            transitionContext.completeTransition(true)
        }
    }
    
    
}
