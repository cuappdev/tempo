//
//  HipStickyHeaderFlowLayout.swift
//  Tempo
//
//  Created by Annie Cheng on 5/2/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class HipStickyHeaderFlowLayout: UICollectionViewFlowLayout {
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		
		var layoutAttributes = super.layoutAttributesForElements(in: rect)!
		let contentOffset = collectionView!.contentOffset
		
		let missingSections = NSMutableIndexSet()
		
		for attribute in layoutAttributes {
			if attribute.representedElementCategory == .cell {
				missingSections.add(attribute.indexPath.section)
			}
		}
		
		for attribute in layoutAttributes {
			if let kind = attribute.representedElementKind {
				if kind == UICollectionElementKindSectionHeader {
					missingSections.remove(attribute.indexPath.section)
				}
			}
		}
		
		missingSections.enumerate({ idx, stop in
			let indexPath = IndexPath(item: 0, section: idx)
			if let attribute = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath) {
				layoutAttributes.append(attribute)
			}
		})
		
		for attribute in layoutAttributes {
			if let kind = attribute.representedElementKind {
				if kind == UICollectionElementKindSectionHeader {
					let section = attribute.indexPath.section
					let numberOfItemsInSection = collectionView!.numberOfItems(inSection: section)
					
					let firstCellIndexPath = IndexPath(item: 0, section: section)
					let lastCellIndexPath = IndexPath(item: max(0, (numberOfItemsInSection - 1)), section: section)
					
					let (firstCellAttributes, lastCellAttributes): (UICollectionViewLayoutAttributes?, UICollectionViewLayoutAttributes?) = {
						if self.collectionView!.numberOfItems(inSection: section) > 0 {
							return (
								layoutAttributesForItem(at: firstCellIndexPath),
								layoutAttributesForItem(at: lastCellIndexPath))
						} else {
							return (
								layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: firstCellIndexPath),
								layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: lastCellIndexPath))
						}
					}()
					var origin = attribute.frame.origin
					
					origin.y = min(max(contentOffset.y, (firstCellAttributes?.frame.minY)!), (lastCellAttributes?.frame.maxY)!)
					
					attribute.zIndex = 1024
					attribute.frame = CGRect(origin: origin, size: attribute.frame.size)
				}
			}
		}
		
		return layoutAttributes
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
	
}
