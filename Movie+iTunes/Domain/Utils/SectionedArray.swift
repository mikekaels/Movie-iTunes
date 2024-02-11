//
//  SectionedArray.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation

public struct SectionedDataSource<Section: Hashable, Element: Hashable> {
	var section: Section
	var items: [Element]
}

public struct SectionedArrayOf<Section: Hashable, Element: Hashable> {
	var sectionedData: [SectionedDataSource<Section, Element>] = [] {
		didSet {
			numberOfSection = sectionedData.count
			numberOfItemInSection = sectionedData.map {
				$0.items.count
			}
		}
	}
	
	var numberOfSection: Int = 0
	var numberOfItemInSection: [Int] = []
	
	mutating func append(_ newElement: SectionedDataSource<Section, Element>) {
		
		sectionedData.append(newElement)
	}
	
	func getElement(_ indexPath: IndexPath) -> Element {
		return sectionedData[indexPath.section].items[indexPath.row]
	}
}

