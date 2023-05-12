//
//  NicknameViewController.swift
//  HMOA_iOS
//
//  Created by 정지훈 on 2023/03/21.
//

import UIKit

import Then
import SnapKit
import RxCocoa
import RxSwift

class NicknameViewController: UIViewController {
    
    //MARK: - Property
    
    lazy var nicknameView = NicknameView("다음")
    
    let disposeBag = DisposeBag()
    let reactor = NicknameReactor()
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setAddView()
        setConstraints()
        bind(reactor: reactor)
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        
        let frame = nicknameView.nicknameTextField.frame
        setBottomBorder(nicknameView.nicknameTextField,
                        width: frame.width,
                        height: frame.height)
    }
    
    //MARK: - SetUp
    private func setUpUI() {
        view.backgroundColor = .white
        setNavigationBarTitle(title: "1/2", color: .white, isHidden: false, isScroll: false)
    }
    
    private func setAddView() {
        view.addSubview(nicknameView)
    }
    
    private func setConstraints() {
        nicknameView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    
    //MARK: - Bind
    private func bind(reactor: NicknameReactor) {
        //Input
        
        //중복확인 터치 이벤트
        nicknameView.duplicateCheckButton.rx.tap
            .map { NicknameReactor.Action.didTapDuplicateButton(self.nicknameView.nicknameTextField.text)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //다음 버튼 터치 이벤트
        nicknameView.bottomButton.rx.tap
            .map { NicknameReactor.Action.didTapStartButton}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //textfield return 터치 이벤트
        nicknameView.nicknameTextField.rx.controlEvent(.editingDidEndOnExit)
            .map { NicknameReactor.Action.didTapTextFieldReturn}
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
        
        //연도 VC로 화면 전환
        reactor.state
            .map { $0.nicknameResponse }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .bind(onNext: {
                print($0)
                let vc = UserInformationViewController(reactor.currentState.nickname!)
                self.navigationController?.pushViewController(vc,
                                                              animated: true)
            }).disposed(by: disposeBag)
            
    }
    
}

extension NicknameViewController {
    
    //MARK: - Functions
    
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
