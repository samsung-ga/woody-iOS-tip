//
//  PulseViewController.swift
//  ReactorKitSample
//
//  Created by Woody on 2022/10/02.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class PulseViewController: UIViewController, View {

    typealias Reactor = PulseReactor

    lazy var stateButton: UIButton = {
        let v = UIButton(type: .system)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("상태 테스트", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        return v
    }()

    lazy var pulseButton: UIButton = {
        let v = UIButton(type: .system)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("펄스 테스트", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        return v
    }()
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stateButton)
        view.addSubview(pulseButton)

        NSLayoutConstraint.activate([
            stateButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stateButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),

            pulseButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pulseButton.topAnchor.constraint(equalTo: self.stateButton.bottomAnchor, constant: 100),
        ])
    }

    func bind(reactor: Reactor) {

        stateButton.rx.tap.map { .didTapStateButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pulseButton.rx.tap.map { .didTapPulseButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { "\($0.value)" }
            .distinctUntilChanged()
            .subscribe(onNext: { 
                print("👋🏻👋🏻👋🏻 상태 1")
            }).disposed(by: disposeBag)

        reactor.state
            .map { $0.message }
            .subscribe(onNext: { message in
                print("🚀🚀🚀 상태 2")
            }).disposed(by: disposeBag)

        reactor.pulse(\.$error)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("✨✨✨ 펄스 ")
            }).disposed(by: disposeBag)
    }
}

class PulseReactor: Reactor {

    enum Action {
        case didTapStateButton
        case didTapPulseButton
    }

    struct State {
        var message: String = ""
        var value: String = ""

        @Pulse var error: String?
    }

    var initialState: State = State()

    func reduce(state: State, mutation: Action) -> State {
        var newState = state
        switch mutation {
        case .didTapStateButton:
            newState.message = "메세지"
        case .didTapPulseButton:
            newState.error = "펄스"
        }
        return newState
    }
}
