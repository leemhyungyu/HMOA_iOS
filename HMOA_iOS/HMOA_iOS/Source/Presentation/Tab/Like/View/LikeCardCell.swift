//
//  CardCell.swift
//  HMOA_iOS
//
//  Created by 정지훈 on 2023/03/16.
//

import UIKit

import SnapKit
import Then

class LikeCardCell: UICollectionViewCell {
    
    // MARK: - Property
    static let identifier = "LikeCardCell"
    
    let topView = UIView().then {
        $0.backgroundColor = .black
    }
    let xButton = UIButton().then {
        $0.setImage(UIImage(named: "x"), for: .normal)
    }
    
    let brandNameLabel = UILabel().then {
        $0.setLabelUI("",
                      font: .pretendard_medium,
                      size: 14,
                      color: .white)
    }
    
    let perpumeImageView = UIImageView().then {
        $0.image = UIImage(named: "jomalon")
    }
    
    let tagTableView = UITableView().then {
        $0.register(TagCell.self, forCellReuseIdentifier: TagCell.identifier)
    }
    
    let nameStackView = UIStackView().then {
        $0.setStackViewUI(spacing: 8)
    }
    let korNameLabel = UILabel().then {
        $0.setLabelUI("",
                      font: .pretendard, size: 14, color: .black)
    }
    
    let engNameLabel = UILabel().then {
        $0.setLabelUI("",
                      font: .pretendard,
                      size: 12,
                      color: .black)
    }
    
    let priceTextLabel = UILabel().then {
        $0.setLabelUI("Price",
                      font: .pretendard,
                      size: 14,
                      color: .black)
    }
    
    let priceLabel = UILabel().then {
        $0.setLabelUI("",
                      font: .pretendard,
                      size: 14,
                      color: .black)
    }
    
    //MARK: - LifeCycle
    override func layoutSubviews() {
        super .layoutSubviews()
        setUpUI()
    }
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        setAddView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - SetUp
    private func setUpUI() {
        backgroundColor = .white
        
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: layer.cornerRadius).cgPath
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
    private func setAddView() {
        [xButton,
         brandNameLabel].forEach { topView.addSubview($0) }
        
        [tagTableView,
         korNameLabel,
         engNameLabel].forEach { nameStackView.addArrangedSubview($0) }
        
        [topView,
         perpumeImageView,
         nameStackView,
         priceTextLabel,
         priceLabel].forEach { contentView.addSubview($0) }
    }
    
    private func setConstraints() {
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        xButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(21)
            make.centerY.equalToSuperview()
        }
        
        brandNameLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        perpumeImageView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(120)
        }
        
        nameStackView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(24)
            make.top.equalTo(perpumeImageView.snp.bottom)
        }
        
        priceTextLabel.snp.makeConstraints { make in
            make.top.equalTo(nameStackView.snp.bottom).offset(28)
            make.bottom.equalToSuperview().inset(40)
            make.leading.equalToSuperview().inset(24)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameStackView.snp.bottom).offset(28)
            make.bottom.equalToSuperview().inset(40)
            make.trailing.equalToSuperview().inset(24)
        }
    }
    
    func configure(item: CardSection.Item) {
        brandNameLabel.text = item.brandName
        korNameLabel.text = item.korPerpumeName
        engNameLabel.text = item.engPerpumeName
        priceLabel.text = setPriceLabel(value: item.price)
    }
    
    func setPriceLabel(value: Int) -> String{
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let result = "₩" + numberFormatter.string(from: NSNumber(value: value))! + "~"
            
            return result
        }
}