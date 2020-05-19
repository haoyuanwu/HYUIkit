//
//  PushAnimation.swift
//  FloatPoint
//
//  Created by 吴昊原 on 2019/5/21.
//  Copyright © 2019 FloatPoint. All rights reserved.
//

import UIKit

class PushAnimation: NSObject,UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
  
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let container: UIView = transitionContext.containerView
        
        let floatV = FloatPointView.floatPoint
        
        toVC!.view.frame = floatV.pointView.frame;
        toVC?.view.layer.cornerRadius = floatV.pointView.frame.size.height/2
        toVC?.view.layer.masksToBounds = true;
        
        // 都添加到container中。注意顺序
        if let view = toVC?.view {
            container.addSubview(view)
        }
        
        // 执行动画
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeLinear, animations: {
            toVC?.view.frame = fromVC!.view.frame;
            toVC?.view.layer.cornerRadius = 0
            
        }) { finished in
            
            //一定要记得动画完成后执行此方法，让系统管理 navigation
            transitionContext.completeTransition(true)
        }
        
    }
}
