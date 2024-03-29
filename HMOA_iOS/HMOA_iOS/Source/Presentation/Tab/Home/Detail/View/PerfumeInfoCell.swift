//
//  PerfumeInfoCell.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/02/05.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxCocoa
import RxSwift

class PerfumeInfoCell: UICollectionViewCell, View {
    
    typealias Reactor = PerfumeInfoViewReactor
    
    // MARK: - identifier
    
    static let identifier = "PerfumeInfoCell"
    var disposeBag = DisposeBag()

    // MARK: - View
    
    let perfumeInfoView = PerfumeInfoView()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Functions

extension PerfumeInfoCell {
    
    // MARK: - Bind
    
    func bind(reactor: PerfumeInfoViewReactor) {
        perfumeInfoView.perfumeImageView.image = reactor.currentState.perfumeImage
        perfumeInfoView.titleKoreanLabel.text = reactor.currentState.koreanName
        perfumeInfoView.titleEnglishLabel.text = reactor.currentState.englishName
        // 나중에 수정
//        perfumeInfoView.keywordTagListView.addTags(reactor.currentState.category)
        perfumeInfoView.priceLabel.text = reactor.currentState.price.numberFormatterToWon()
        perfumeInfoView.ageLabel.text = "\(reactor.currentState.age)"
        perfumeInfoView.gendarLabel.text = reactor.currentState.gender
        perfumeInfoView.productInfoContentLabel.text = reactor.currentState.productInfo
        perfumeInfoView.topNote.nameLabel.text = reactor.currentState.topTasting
        perfumeInfoView.heartNote.nameLabel.text = reactor.currentState.heartTasting
        perfumeInfoView.baseNote.nameLabel.text = reactor.currentState.baseTasting
        
        // MARK: - Ation
        
        // 향수 좋아요 버튼 클릭
        perfumeInfoView.perfumeLikeButton.rx.tap
            .map { Reactor.Action.didTapPerfumeLikeButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 향수 브랜드 좋아요 버튼 클릭
        perfumeInfoView.brandView.likeButton.rx.tap
            .do(onNext: { print("Clicked")} )
            .map { Reactor.Action.didTapBrandLikeButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: - State
        
        // 향수 좋아요 상태 변경
        reactor.state
            .map { $0.isLikePerfume }
            .distinctUntilChanged()
            .bind(to:
                    perfumeInfoView.perfumeLikeButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // 향수 브랜드 좋아요 상태 변경
        reactor.state
            .map { $0.isLikeBrand }
            .distinctUntilChanged()
            .bind(to: perfumeInfoView.brandView.likeButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // 향수 좋아요 개수 변경
        reactor.state
            .map { $0.likeCount }
            .distinctUntilChanged()
            .map { String($0) }
            .bind(onNext: {
                self.perfumeInfoView.perfumeLikeButton.configuration?.attributedTitle = self.setLikeButtonText($0)
            })
            .disposed(by: disposeBag)
    }
    
    func configureUI() {
        [   perfumeInfoView ] .forEach { addSubview($0) }
        
        perfumeInfoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(48)
        }
    }
    
    func setLikeButtonText(_ text: String) -> AttributedString {
        var attri = AttributedString.init(text)
        attri.font = .customFont(.pretendard_light, 12)
        
        return attri
    }
    
    func updateCell(_ item: PerfumeDetail) {
        perfumeInfoView.perfumeImageView.image = item.perfumeImage
        perfumeInfoView.titleKoreanLabel.text = item.koreanName
        perfumeInfoView.titleEnglishLabel.text = item.englishName
        perfumeInfoView.priceLabel.text = "\(item.price)"
        perfumeInfoView.ageLabel.text = "\(item.age)"
        perfumeInfoView.gendarLabel.text = item.gender
        perfumeInfoView.productInfoContentLabel.text = item.productInfo
        perfumeInfoView.topNote.nameLabel.text = item.topTasting
        perfumeInfoView.heartNote.nameLabel.text = item.heartTasting
        perfumeInfoView.baseNote.nameLabel.text = item.baseTasting
    }
}
