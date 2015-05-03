//
//  HipStickyHeaderFlowLayout.swift
//  IceFishing
//
//  Created by Annie Cheng on 5/2/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class HipStickyHeaderFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        var layoutAttributes: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElementsInRect(rect)! as! [UICollectionViewLayoutAttributes]
        let contentOffset = collectionView!.contentOffset
        
        var missingSections = NSMutableIndexSet()
        
        for attribute in layoutAttributes {
            if (attribute.representedElementCategory == .Cell) {
                if let indexPath = attribute.indexPath {
                    missingSections.addIndex(attribute.indexPath.section)
                }
            }
        }
        
        for attribute in layoutAttributes {
            if let kind = attribute.representedElementKind {
                if kind == UICollectionElementKindSectionHeader {
                    if let indexPath = attribute.indexPath {
                        missingSections.removeIndex(indexPath.section)
                    }
                }
            }
        }
        
        missingSections.enumerateIndexesUsingBlock { idx, stop in
            let indexPath = NSIndexPath(forItem: 0, inSection: idx)
            if let attribute = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) {
                layoutAttributes.append(attribute)
            }
        }
        
        for attribute in layoutAttributes {
            if let kind = attribute.representedElementKind {
                if kind == UICollectionElementKindSectionHeader {
                    let section = attribute.indexPath!.section
                    let numberOfItemsInSection = collectionView!.numberOfItemsInSection(section)
                    
                    let firstCellIndexPath = NSIndexPath(forItem: 0, inSection: section)!
                    let lastCellIndexPath = NSIndexPath(forItem: max(0, (numberOfItemsInSection - 1)), inSection: section)!
                    
                    
                    let (firstCellAttributes: UICollectionViewLayoutAttributes, lastCellAttributes: UICollectionViewLayoutAttributes) = {
                        if (self.collectionView!.numberOfItemsInSection(section) > 0) {
                            return (
                                self.layoutAttributesForItemAtIndexPath(firstCellIndexPath),
                                self.layoutAttributesForItemAtIndexPath(lastCellIndexPath))
                        } else {
                            return (
                                self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: firstCellIndexPath),
                                self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, atIndexPath: lastCellIndexPath))
                        }
                        }()
                    
                    let headerHeight = CGRectGetHeight(attribute.frame)
                    var origin = attribute.frame.origin
                    
                    origin.y = min(max(contentOffset.y, CGRectGetMinY(firstCellAttributes.frame)), CGRectGetMaxY(lastCellAttributes.frame))
                    
                    attribute.zIndex = 1024
                    attribute.frame = CGRect(origin: origin, size: attribute.frame.size)
                }
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}
