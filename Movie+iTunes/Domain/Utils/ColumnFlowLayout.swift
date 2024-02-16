//
//  ColumnFlowLayout.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit

/// A custom collection view flow layout with column-based arrangement.
class ColumnFlowLayout: UICollectionViewFlowLayout {
	/// The height of the items in the collection view.
	let height: CGFloat
	/// The total number of columns in the layout.
	let totalColumn: CGFloat
	/// The spacing between content items.
	let contentInterSpacing: CGFloat
	
	/// Initializes the flow layout with the specified parameters.
	///
	/// - Parameters:
	///   - height: The height of the items.
	///   - totalColumn: The total number of columns.
	///   - contentInterSpacing: The spacing between content items. Default is 0.
	init(height: CGFloat, totalColumn: CGFloat, contentInterSpacing: CGFloat = 0) {
		self.height = height
		self.totalColumn = totalColumn
		self.contentInterSpacing = contentInterSpacing
		super.init()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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

