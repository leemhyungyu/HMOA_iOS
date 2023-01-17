//
//  HomeViewController.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/01/12.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: Properties
    
    lazy var homeView = HomeView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: - Functions
extension HomeViewController {
    
    func configureUI() {
        
        view.backgroundColor = UIColor.white
        
        [homeView] .forEach { view.addSubview($0) }

        homeView.collectionView.delegate = self
        homeView.collectionView.dataSource = self
        homeView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
        }
    }
}


// MARK: CollectionView - Deleagte
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let homeCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.identifier, for: indexPath) as? HomeCell else { return UICollectionViewCell() }
        
        guard let homeTopCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTopCell.identifier, for: indexPath) as? HomeTopCell else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 0:
            return homeTopCell
        default:
            homeCell.perfumeImageView.image = UIImage(named: "jomalon")
            homeCell.perfumeTitleLabel.text = "조 말론 런던"
            homeCell.perfumeInfoLabel.text = "우드 세이지 앤 씨 쏠트 코롱 100ml"
            return homeCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCellHeaderView.identifier, for: indexPath) as? HomeCellHeaderView else { return UICollectionReusableView() }
     
        guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HomeTopCellFooterView.identifier, for: indexPath) as? HomeTopCellFooterView else { return UICollectionReusableView() }
        
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return footer
        default:
            return header
        }
    }
}

// MARK: CollectionView - DataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("클릭")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}
