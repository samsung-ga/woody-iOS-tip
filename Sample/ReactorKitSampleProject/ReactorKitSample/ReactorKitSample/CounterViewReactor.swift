//
//  CounterViewReactor.swift
//  ReactorKitSample
//
//  Created by Woody on 2022/10/02.
//

import Foundation
import ReactorKit

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
