//
//  CalendarTableViewCell.swift
//  Tempo
//
//  Created by Annie Cheng on 12/5/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

protocol CalendarTableViewCellDelegate {
	func didSelectCalendarCell(indexPath: IndexPath)
}

class CalendarTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	let padding: CGFloat = 5
	
	var calendarCollectionView: UICollectionView!
	var delegate: CalendarTableViewCellDelegate?
	
	var collectionViewAdded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
		
		selectionStyle = .none
		contentView.backgroundColor = .profileBackgroundBlack
    }
	
	func setUpCalendarCell(vc: UICollectionViewDataSource) -> UICollectionView {
		if !collectionViewAdded {
			let layout = HipStickyHeaderFlowLayout()
			layout.sectionInset = UIEdgeInsets(top: 0, left: padding*6, bottom: padding*2, right: 0)
			layout.minimumInteritemSpacing = 0
			layout.minimumLineSpacing = 0
			
			calendarCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), collectionViewLayout: layout)
			calendarCollectionView.delegate = self
			calendarCollectionView.dataSource = vc
			calendarCollectionView.backgroundColor = .profileBackgroundBlack
			calendarCollectionView.scrollsToTop = false
			calendarCollectionView.register(HipCalendarCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
			calendarCollectionView.register(HipCalendarDayCollectionViewCell.self, forCellWithReuseIdentifier: "DayCell")
			addSubview(calendarCollectionView)
			
			let divider = UIView(frame: CGRect(x: bounds.width/11, y: 0, width: 1, height: bounds.height))
			divider.backgroundColor = .tempoRed
			addSubview(divider)
			
			collectionViewAdded = true
		} 
		
		return calendarCollectionView
	}
	
	// MARK: - UICollectionViewDelegateFlowLayout Methods
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width - padding * 2, height: 30)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cols: CGFloat = 6
		let dayWidth = collectionView.frame.width / cols
		let dayHeight = dayWidth
		
		return CGSize(width: dayWidth, height: dayHeight)
	}
	
	// MARK: - UICollectionViewDelegate Methods
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let delegate = delegate else { return }
		delegate.didSelectCalendarCell(indexPath: indexPath)
	}

}
