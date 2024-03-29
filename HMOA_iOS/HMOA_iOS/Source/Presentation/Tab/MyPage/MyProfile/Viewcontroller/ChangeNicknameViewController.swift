//
//  ChangeNicknameViewController.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/05/07.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class ChangeNicknameViewController: UIViewController, View {
    var reactor: ChangeNicknameReactor
    var disposeBag = DisposeBag()
    
    // MARK: - UI Component
    lazy var nicknameView = NicknameView("변경")
    
    // MARK: - Initialize
    init(reactor: ChangeNicknameReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MAKR: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackItemNaviBar("닉네임")
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        setBottomBorder(nicknameView.nicknameTextField,
                        width: nicknameView.nicknameTextField.frame.width,
                        height: nicknameView.nicknameTextField.frame.height)
    }
}

extension ChangeNicknameViewController {
    
    // MARK: - bind
    
    func bind(reactor: ChangeNicknameReactor) {
        //Input
        
        //중복확인 터치 이벤트
        nicknameView.duplicateCheckButton.rx.tap
            .map { ChangeNicknameReactor.Action.didTapDuplicateButton(self.nicknameView.nicknameTextField.text)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //다음 버튼 터치 이벤트
        nicknameView.bottomButton.rx.tap
            .map { ChangeNicknameReactor.Action.didTapStartButton}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //textfield return 터치 이벤트
        nicknameView.nicknameTextField.rx.controlEvent(.editingDidEndOnExit)
            .map { ChangeNicknameReactor.Action.didTapTextFieldReturn}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //닉네임 캡션 라벨 변경
        reactor.state
            .map { $0.isDuplicate }
            .compactMap { $0 }
            .bind(onNext: {
                self.changeCaptionLabelColor($0)
            }).disposed(by: disposeBag)
        
        //버튼 enable 상태 변경
        reactor.state
            .map { $0.isEnable }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: { isEnable in
                self.changeNextButtonEnable(isEnable)
            }).disposed(by: disposeBag)
        
        //return 터치 시 키보드 내리기
        reactor.state
            .map { $0.isTapReturn }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: { _ in
                self.nicknameView.nicknameTextField.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        // 이전 화면으로 pop
        reactor.state
            .map { $0.nicknameResponse }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .map { _ in }
            .bind(onNext: popViewController)
            .disposed(by: disposeBag)
            
        // 기존 닉네임 바인딩
        reactor.state
            .map { $0.currentNickname }
            .distinctUntilChanged()
            .bind(to: nicknameView.nicknameTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - configure
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(nicknameView)
        

        
        nicknameView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    //caption ui 변경
    private func changeCaptionLabelColor(_ isDuplicate: Bool) {
        if isDuplicate {
            nicknameView.nicknameCaptionLabel.text = "사용할 수 없는 닉네임 입니다."
            nicknameView.nicknameCaptionLabel.textColor = .customColor(.red)
        } else if !isDuplicate {
            nicknameView.nicknameCaptionLabel.text = "사용할 수 있는 닉네임 입니다."
            nicknameView.nicknameCaptionLabel.textColor = .customColor(.blue)
        }
    }
    
    //다음 버튼 ui변경
    private func changeNextButtonEnable(_ isEnable: Bool) {
        if isEnable  {
            self.nicknameView.bottomButton.isEnabled = true
            self.nicknameView.bottomButton.backgroundColor = .black
        } else {
            self.nicknameView.bottomButton.isEnabled = false
            self.nicknameView.bottomButton.backgroundColor = .customColor(.gray2)
        }
    }
    
    //빈 화면 터치 시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
}
