//
//  UICollectionViewLeftFlowLayout.m
//  BaiLingDoctor
//
//  Created by 吴昊原 on 2018/10/25.
//  Copyright © 2018 BaiLingDoctor. All rights reserved.
//

#import "UICollectionViewLeftFlowLayout.h"

@implementation UICollectionViewLeftFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSArray *attributesArr = [super layoutAttributesForElementsInRect:rect];
    
    for (int i = 0; i<attributesArr.count; i++) {
        if (i != attributesArr.count - 1) {
            UICollectionViewLayoutAttributes *curAtt = attributesArr[i];
            UICollectionViewLayoutAttributes *nextAtt = attributesArr[i+1];
            if (curAtt.frame.origin.y == nextAtt.frame.origin.y) {
                if (nextAtt.frame.origin.x - curAtt.frame.origin.x > self.minimumInteritemSpacing) {
                    CGRect rect = nextAtt.frame;
                    CGFloat x = curAtt.frame.origin.x + curAtt.frame.size.width + self.minimumInteritemSpacing;
                    rect = CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
                    nextAtt.frame = rect;
                }
            }else{
                CGRect rect = nextAtt.frame;
                rect = CGRectMake(self.sectionInset.left, rect.origin.y, rect.size.width, rect.size.height);
                nextAtt.frame = rect;
            }
        }
    }
    return attributesArr;
}

@end
