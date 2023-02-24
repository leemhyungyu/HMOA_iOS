//
//  CommentListViewController.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/02/21.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import RxAppState

class CommentListViewController: UIViewController, View {
    
    // MARK: - Properties
    var perfumeId: Int = 0

    private var dataSource: RxCollectionViewSectionedReloadDataSource<CommentSection>!
    lazy var commendReactor = CommentListReactor(perfumeId)
    var disposeBag = DisposeBag()

    // MARK: - UI Component
    
    let topView = CommentListTopView()
    let bottomView = CommentListBottomView()
    
    lazy var layout = UICollectionViewFlowLayout()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.alwaysBounceVertical = true
        $0.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackItemNaviBar("댓글")
        configureUI()
        configureCollectionViewDataSource()
        bind(reactor: commendReactor)
    }
}

extension CommentListViewController {

    // MARK: - Bind
    
    func bind(reactor: CommentListReactor) {
        
        // MARK: - Action
        
        // viewWillAppear
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // collectionView item 선택
        collectionView.rx.itemSelected
            .map { Reactor.Action.didTapCell($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 댓글 작성 버튼 클릭
        bottomView.writeButton.rx.tap
            .map { Reactor.Action.didTapWriteButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: - State

        // collectionView 바인딩
        reactor.state
            .map { $0.comments }
            .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        // 댓글 개수 반응
        reactor.state
            .map { $0.commentCount }
            .distinctUntilChanged()
            .map { String($0) }
            .bind(to: topView.commentCountLabel.rx.text )
            .disposed(by: disposeBag)
        
        // 댓글 디테일 페이지로 이동
        reactor.state
            .map { $0.presentCommentId }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: presentCommentDetailViewController)
            .disposed(by: disposeBag)
        
        // 댓글 작성 페이지로 이동
        reactor.state
            .map { $0.isPresentCommentWriteVC }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: presentCommentWriteViewController)
            .disposed(by: disposeBag)
    }
    
    func configureCollectionViewDataSource() {
        
        dataSource = RxCollectionViewSectionedReloadDataSource<CommentSection>(configureCell: { _, collectionView, indexPath, item -> UICollectionViewCell in
            switch item {
            case .commentCell(let reactor, _):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell else { return UICollectionViewCell() }
                
                cell.reactor = reactor
                
                return cell
            }
        })
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        [   topView,
            collectionView,
            bottomView
        ]   .forEach { view.addSubview($0) }
        
        topView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
    }
}

extension CommentListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 102)
    }
}