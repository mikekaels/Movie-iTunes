//
//  ColumnFlowLayout.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let height: CGFloat
	let totalColumn: CGFloat
	let contentInterSpacing: CGFloat
	
	init(height: CGFloat, totalColumn: CGFloat, contentInterSpacing: CGFloat = 0) {
		self.height = height
		self.totalColumn = totalColumn
		self.contentInterSpacing = contentInterSpacing
		super.init()
	}
	
	override func prepare() {
		super.prepare()
		
		guard let collectionView = collectionView else { return }
		
		let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
		let itemWidth = (availableWidth - minimumInteritemSpacing) / self.totalColumn
		
		
		minimumInteritemSpacing = self.contentInterSpacing
		itemSize =  CGSize(width: itemWidth - self.contentInterSpacing, height: self.height)
		minimumLineSpacing = (self.contentInterSpacing * 2)
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
}

