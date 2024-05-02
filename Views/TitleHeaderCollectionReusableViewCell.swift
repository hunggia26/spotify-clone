//
//  TitleHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Hung Truong on 24/04/2024.
//

import UIKit

class TitleHeaderCollectionReusableViewCell: UICollectionReusableView {
    static let identifier = "TitleHeaderCollectionReusableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: width-30, height: height)
    }
    func configure(with title: String) {
        label.text = title
    }
}
