//
//  HomeViewController.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/01/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit


class HomeViewController: UIViewController, View {
    
    // MARK: ViewModel
    
    lazy var homeReactor = HomeViewReactor()
    
    // MARK: Properties
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>!
    var disposeBag = DisposeBag()

    // MARK: - UI Component
    lazy var homeView = HomeView()
    
    lazy var brandSearchButton = UIButton().makeImageButton(UIImage(named: "homeMenu")!)
    
    lazy var searchButton = UIButton().makeImageButton(UIImage(named: "search")!)
    
    lazy var bellButton = UIButton().makeImageButton(UIImage(named: "bell")!)
    
    var headerViewReactor: HomeHeaderReactor!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        configureCollectionViewDataSource()
        bind(reactor: homeReactor)
    }
    
    // MARK: objc functions
    
    @objc func menuButtonClicked() {
    }
    
    @objc func searchButtonClicked() {
        presentSearchViewController()
    }
    
    @objc func bellButtonClicked() {
    }
}

// MARK: - Functions
extension HomeViewController {
    
    // MARK: - Bind
    
    func bind(reactor: HomeViewReactor) {

        // MARK: - Action
        
        // viewDidLoad
        Observable.just(())
            .map { Reactor.Action.viewDidLoad}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // collectionView item 클릭
        self.homeView.collectionView.rx.itemSelected
            .map { Reactor.Action.itemSelected($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // 브랜드 검색 버튼 클릭
        brandSearchButton.rx.tap
            .map { Reactor.Action.didTapBrandSearchButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 종합 검색 버튼 클릭
        searchButton.rx.tap
            .map { Reactor.Action.didTapSearchButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 알림 버튼 클릭
        bellButton.rx.tap
            .map { Reactor.Action.didTapBellButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: - State
        
        //snapshot 설정
        reactor.state
            .map { $0.sections }
            .asDriver(onErrorRecover: { _ in return .empty() })
            .drive(with: self, onNext: { owner, sections in
                
                var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
                snapshot.appendSections(sections)
                        
                sections.forEach { section in
                    snapshot.appendItems(section.items, toSection: section)
                }
    
                DispatchQueue.main.async {
                    owner.dataSource.apply(snapshot)
                }
                
            }).disposed(by: disposeBag)

        // 향수 디테일 페이지로 이동
        reactor.state
            .map { $0.selectedPerfumeId }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: presentDatailViewController)
            .disposed(by: disposeBag)
        
        // 브랜드 검색 페이지로 이동
        reactor.state
            .map { $0.isPresentBrandSearchVC }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in }
            .bind(onNext: presentBrandSearchViewController)
            .disposed(by: disposeBag)
        
        // 종합 검색 화면으로 이동
        reactor.state
            .map { $0.isPresentSearchVC }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in }
            .bind(onNext: presentSearchViewController)
            .disposed(by: disposeBag)
    }
    
    func bindHeader(reactor: HomeHeaderReactor) {
        
        // MARK: - Action
        
        // MARK: - State
        
        reactor.state
            .map { $0.isPersentMoreVC }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: presentTotalPerfumeViewController)
            .disposed(by: disposeBag)
    }
    
    func configureCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem> (collectionView: homeView.collectionView, cellProvider: { collectionView, indexPath, item in
            
            switch item {
            case .topCell(let imageUrl, _):
                guard let homeTopCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HomeTopCell.identifier,
                    for: indexPath) as? HomeTopCell else {
                    return UICollectionViewCell()
                }
                
                homeTopCell.setImage(imageUrl)
                
                return homeTopCell
                
            case .recommendCell(let data, _, _):
                guard let firstCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HomeFirstCell.identifier,
                    for: indexPath) as? HomeFirstCell else {
                    return UICollectionViewCell()
                }
                
                guard let otherCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HomeCell.identifier,
                    for: indexPath) as? HomeCell else {
                    return UICollectionViewCell()
                }
                                
                if indexPath.section == 1 {
                    firstCell.bindUI(data)
                    return firstCell
                } else {
                    otherCell.bindUI(data)
                    return otherCell
                }
            }
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            
            var header = UICollectionReusableView()
            
            guard let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            else { return header }
            
            switch section {
            case .topSection(_):
                return header
                
            case .recommendSection(let title, _):
                guard let homeFirstCellHeader = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: HomeFirstCellHeaderView.identifier,
                    for: indexPath) as? HomeFirstCellHeaderView else {
                    return UICollectionReusableView()
                }
                
                homeFirstCellHeader.bindUI(title: title)
                homeFirstCellHeader.reactor = HomeHeaderReactor(title, 1)
                self.bindHeader(reactor: homeFirstCellHeader.reactor!)
                header = homeFirstCellHeader
                
                return header
            }
        }
    }
    
    func configureNavigationBar() {
        
        setNavigationColor()
        
        let titleLabel = UILabel().then {
            $0.text = "H  M  O  A"
            $0.font = .customFont(.pretendard_medium, 20)
            $0.textColor = .black
        }
                
        let bracnSearchButtonItem = UIBarButtonItem(customView: brandSearchButton)
        let searchButtonItem = UIBarButtonItem(customView: searchButton)
        let bellButtonItem = UIBarButtonItem(customView: bellButton)
        
        navigationItem.titleView = titleLabel
        
        navigationItem.leftBarButtonItems = [spacerItem(13), bracnSearchButtonItem]
        
        navigationItem.rightBarButtonItems = [bellButtonItem, spacerItem(15), searchButtonItem]
    }
    
    func configureUI() {
        view.backgroundColor = UIColor.white
        
        homeView.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        [homeView] .forEach { view.addSubview($0) }

        homeView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
                
        if indexPath.section == 1 && indexPath.row == 1 {
            if !homeReactor.currentState.isPaging {
                homeReactor.action.onNext(.scrollCollectionView)
            }
        }
    }
}
