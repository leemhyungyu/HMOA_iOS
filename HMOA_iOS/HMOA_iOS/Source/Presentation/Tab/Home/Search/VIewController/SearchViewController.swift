//
//  SearchViewController.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/02/20.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

class SearchViewController: UIViewController, View {
    typealias Reactor = SearchReactor
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Component
    
    private lazy var listVC = SearchListViewController()
    private lazy var ResultVC = SearchResultViewController()
    private lazy var containerView = UIView()
    private var previousSection: Int = -1
    lazy var backButton = UIButton().makeImageButton(UIImage(named: "backButton")!)
    
    lazy var searchBar = UISearchBar().then {
        $0.showsBookmarkButton = true
        $0.setImage(UIImage(named: "clearButton"), for: .clear, state: .normal)
        $0.setImage(UIImage(named: "search")?.withTintColor(.customColor(.gray3)), for: .bookmark, state: .normal)
        $0.searchTextField.leftView = UIView()
        $0.searchTextField.backgroundColor = .white
        $0.searchTextField.textAlignment = .left
        $0.searchTextField.font = .customFont(.pretendard_light, 16)
        $0.placeholder = "제품/브랜드/키워드 검색"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
    }
}

extension SearchViewController {
    
    
    // MARK: - Binding
    func bind(reactor: SearchReactor) {
        // MARK: - Action
        
        // 뒤로 가기 버튼 클릭
        backButton.rx.tap
            .map { Reactor.Action.didTapBackButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Text 입력
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.didChangeTextField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // TextField의 값이 없어질 때
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .filter { $0 == "" }
            .map { _ in Reactor.Action.didClearTextField }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 검색 버튼 클릭
        searchBar.rx.searchButtonClicked
            .map { Reactor.Action.didEndTextField }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 상품 버튼 클릭
        ResultVC.topView.productButton.rx.tap
            .map { Reactor.Action.didTapProductButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 브랜드 버튼 클릭
        ResultVC.topView.brandButton.rx.tap
            .map { Reactor.Action.didTapBrandButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 포스트 버튼 클릭
        ResultVC.topView.postButton.rx.tap
            .map { Reactor.Action.didTapPostButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Hpedia 버튼 클릭
        ResultVC.topView.hpediaButton.rx.tap
            .map { Reactor.Action.didTapHpediaButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 연관 검색어 List Cell 클릭
        listVC.tableView.rx.itemSelected
            .map { Reactor.Action.didTapSearchListCell($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 검색 결과 Result Cell 클릭
        ResultVC.collectionView.rx.itemSelected
            .map { Reactor.Action.didTapSearchResultCell($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: - State
        
        // 이전 뷰 컨트롤러로 이동
        reactor.state
            .map { $0.isPopVC }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in }
            .bind(onNext: self.popViewController)
            .disposed(by: disposeBag)
        
        // 텍스트 값이 변경되면 listVC으로 이동
        reactor.state
            .map { $0.isChangeTextField }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in }
            .bind(onNext: { self.changeViewController(self.listVC) })
            .disposed(by: disposeBag)
        
        // 검색 버튼 눌러지면 ResultVC으로 이동
        reactor.state
            .map { $0.isEndTextField }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in }
            .bind(onNext: { self.changeViewController(self.ResultVC) })
            .disposed(by: disposeBag)

        // 서버로부터 검색 결과 값을 받아오면 collectionView에 바인딩
        reactor.state
            .map { $0.resultProduct }
            .distinctUntilChanged()
            .bind(to: self.ResultVC.collectionView.rx.items(
                cellIdentifier: SearchResultCollectionViewCell.identifier, cellType: SearchResultCollectionViewCell.self)) { index, item, cell in
                    cell.updateCell(item)
            }
            .disposed(by: disposeBag)
        
        // 연관 검색어 값이 바뀌면 tableView에 바인딩
        reactor.state
            .map { $0.lists }
            .distinctUntilChanged()
            .bind(to: self.listVC.tableView.rx.items(
                cellIdentifier: SearchListTableViewCell.identifier,
                cellType: SearchListTableViewCell.self)) { index, item, cell in
                    cell.updateCell(item)
            }
            .disposed(by: disposeBag)

        // 화면이 바뀌면 이전 페이지(VC)의 자식관계를 해지시켜줌
        reactor.state
            .map { $0.prePage }
            .distinctUntilChanged()
            .bind(onNext: {
                switch $0 {
                case 2:
                    self.removeChiledViewController(self.listVC)
                case 3:
                    self.removeChiledViewController(self.ResultVC)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // 상품 버튼 상태 변화
        reactor.state
            .map { $0.isSelectedProductButton }
            .distinctUntilChanged()
            .bind(to: ResultVC.topView.productButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // 브랜드 버튼 상태 변화
        reactor.state
            .map { $0.isSelectedBrandButton }
            .distinctUntilChanged()
            .bind(to: ResultVC.topView.brandButton.rx.isSelected )
            .disposed(by: disposeBag)
        
        // 포스트 버튼 상태 변화
        reactor.state
            .map { $0.isSelectedPostButton }
            .distinctUntilChanged()
            .bind(to: ResultVC.topView.postButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // Hepdia 버튼 상태 변화
        reactor.state
            .map { $0.isSelectedHpediaButton }
            .distinctUntilChanged()
            .bind(to: ResultVC.topView.hpediaButton.rx.isSelected )
            .disposed(by: disposeBag)
        
        // 연관 검색어를 클릭하면 해당 값을 searchBar의 text에 바인딩
        reactor.state
            .map { $0.listContent }
            .distinctUntilChanged()
            .filter { $0 != "" }
            .bind(onNext: { content in
                self.searchBar.endEditing(false)
                self.searchBar.text = content
            })
            .disposed(by: disposeBag)
        
        // 검새 결과를 클릭하면 해당 PerfumeId가지고 향수 상세보기 페이지로 이동
        reactor.state
            .map { $0.selectedPerfumeId }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: presentDatailViewController)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    func configureUI() {
        
        view.backgroundColor = .white
        
        
        
        listVC.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        ResultVC.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        [   listVC,
            ResultVC
        ]   .forEach {  self.addChild($0)   }
        
        [   containerView
        ]   .forEach { view.addSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }
    
    
    func configureNavigationBar() {
     
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        let searchBarWrapper = SearchBarContainerView(customSearchBar: searchBar)
        
        searchBarWrapper.frame = CGRect(x: 0, y: 0, width: self.navigationController!.view.frame.size.width - 42, height: 30)
        
        self.navigationItem.leftBarButtonItems = [backButtonItem]
        
        self.navigationItem.titleView = searchBarWrapper
    }
    
    // MARK: - functions
    
    // 입력받은 VC를 containerView에 호출
    func changeViewController(_ vc: UIViewController) {
        containerView.addSubview(vc.view)
        vc.view.frame = containerView.bounds
        vc.didMove(toParent: self)
    }
    
    // 입력받은 VC의 자식관계 해제
    func removeChiledViewController(_ vc: UIViewController) {
        vc.willMove(toParent: self)
        vc.removeFromParent()
        vc.view.removeFromSuperview()
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item == tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1 {
            reactor?.action.onNext(.scrollTableView(indexPath))
            print(indexPath.item + 1)
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (UIScreen.main.bounds.width - 40) / 2
        let height = width + 82
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1) - 1 {
            reactor?.action.onNext(.scrollCollectionView(indexPath))
        }
    }
    
}
