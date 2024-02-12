//
//  AlertView.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 13/02/24.
//

import UIKit

class AlertView: UIView {
	
	private lazy var icon: UIView = {
		let icon = UIView()
		icon.backgroundColor = .black
		icon.layer.cornerRadius = 6.0
		return icon
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Incoming Message"
		label.font = UIFont(name: "Lato-Bold", size: 17.0)
		label.textColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1)
		return label
	}()
	
	let message: UILabel = {
		let label = UILabel()
		label.text = "This is an example alert..."
		label.font = UIFont(name: "Lato-Regular", size: 13.0)
		label.textColor = #colorLiteral(red: 0.7019607843, green: 0.7058823529, blue: 0.7137254902, alpha: 1)
		return label
	}()
	
	private lazy var alertStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [titleLabel, message])
		stackView.axis = .vertical
		stackView.alignment = .leading
		stackView.spacing = 4.0
		return stackView
	}()
	
	init() {
		super.init(frame: .zero)
		setupView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Layout
	
	private func setupView() {
		backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1137254902, blue: 0.1294117647, alpha: 1)
		layoutIcon()
		layoutStackView()
	}
	
	private func layoutIcon() {
		addSubview(icon)
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
		icon.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
		icon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14).isActive = true
		icon.widthAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
	}
	
	private func layoutStackView() {
		addSubview(alertStackView)
		alertStackView.translatesAutoresizingMaskIntoConstraints = false
		alertStackView.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
		alertStackView.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
		alertStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
		alertStackView.bottomAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
	}
}

