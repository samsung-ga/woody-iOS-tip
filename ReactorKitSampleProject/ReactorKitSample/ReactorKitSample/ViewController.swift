//
//  ViewController.swift
//  ReactorKitSample
//
//  Created by Woody on 2022/08/04.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController, View {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!

    var disposeBag = DisposeBag()
    let counterViewReactor: CounterViewReactor = CounterViewReactor()

    override func viewDidLoad() {
        bind(reactor: counterViewReactor)
    }

    func bind(reactor: CounterViewReactor) {
        plusButton.rx.tap
            .map { CounterViewReactor.Action.plus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        minusButton.rx.tap
            .map { CounterViewReactor.Action.minus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { "\($0.number)" }
            .distinctUntilChanged()
            .bind(to: numberLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        reactor.state
            .map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                let alertViewController = UIAlertController(
                    title: nil,
                    message: message,
                    preferredStyle: .alert
                )
                alertViewController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default
                ))
                self?.present(alertViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}


class CounterViewReactor: Reactor {

    enum Action {
        case plus
        case minus
    }

    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
        case setAlertMessage(String)
    }

    struct State {
        var number: Int
        var isLoading: Bool

        @Pulse var alertMessage: String?
    }

    let initialState: State

    init() {
        self.initialState = State(
            number: 0,
            isLoading: false
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .plus:
            return Observable.concat([
                .just(Mutation.setLoading(true)),
                .just(Mutation.increaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(Mutation.setLoading(false)),
                .just(Mutation.setAlertMessage("increased!"))
            ])
        case .minus:
            return Observable.concat([
                .just(Mutation.setLoading(true)),
                .just(Mutation.decreaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(Mutation.setLoading(false)),
                .just(Mutation.setAlertMessage("decreased!"))
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .increaseValue:
            state.number += 1
        case .decreaseValue:
            state.number -= 1
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setAlertMessage(let message):
            state.alertMessage = message
        }

        return state
    }
}

