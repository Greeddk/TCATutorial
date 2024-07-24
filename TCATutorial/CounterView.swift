//
//  CounterView.swift
//  TCATutorial
//
//  Created by Greed on 7/23/24.
//

import ComposableArchitecture
import SwiftUI

// MARK: - CounterFeature

@Reducer
struct CounterFeature {
    @ObservableState
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }

    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case toggleTimerButtonTapped
        case timerTick
    }

    enum CancelID { case timer }

    @Dependency(\.continuousClock)
    var clock

    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                let stringValue = "ASDf" as! String
                return .none
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true

                return .run { [count = state.count] send in
                    guard let url = URL(string: "http://numbersapi.com/\(count)") else {
                        return
                    }
                    let (data, _) = try await URLSession.shared
                        .data(from: url)
                    let fact = String(decoding: data, as: UTF8.self)
                    await send(.factResponse(fact))
                }
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
}

// MARK: - CounterView

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        VStack {
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)

                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            }
            Button(store.isTimerRunning ? "Stop timer" : "Start timer") {
                store.send(.toggleTimerButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)
            Button("Fact") {
                store.send(.factButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)

            if store.isLoading {
                ProgressView()
            } else if let fact = store.fact {
                Text(fact)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
        }
    )
}
