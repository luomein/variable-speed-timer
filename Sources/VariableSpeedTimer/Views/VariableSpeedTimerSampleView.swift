//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2022/12/31.
//

import SwiftUI
import ComposableArchitecture

public struct VariableSpeedTimerSampleView: View {
    let store: StoreOf<VariableSpeedTimerReducer>
    public init(store: StoreOf<VariableSpeedTimerReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form{
                HStack{
                    Toggle(isOn: viewStore.binding(get: \.isTimerOn, send: VariableSpeedTimerReducer.Action.toggleTimer), label: {Text("isTimerOn")})
                    Text("\(Int(viewStore.currentTick))")
                    Slider(value: viewStore.binding(get: \.currentTick, send: VariableSpeedTimerReducer.Action.startFromTick), in: 0...viewStore.totalTicks)
                }
                HStack{
                    Text("Timer Speed")
                    Slider(value: viewStore.binding(get: \.timerSpeed, send: VariableSpeedTimerReducer.Action.setTimerSpeed),
                           in: 0...VariableSpeedTimerReducer.TimerSpeedParameter.timerSpeedMax, label: {Text("Timer Speed")},
                           minimumValueLabel: {Text(Image(systemName: "tortoise"))},
                           maximumValueLabel: {Text(Image(systemName: "hare"))}
                    )
                    
                }
            }
            .onAppear(perform: {
                viewStore.send(.startFromTick(0))
                viewStore.send(.toggleTimer(true))
            })
            .onDisappear(perform: {
                viewStore.send(.toggleTimer(false))
            })
        }
    }
}


struct VariableSpeedTimerSampleView_Previews: PreviewProvider {
    static var previews: some View {
        VariableSpeedTimerSampleView(store: Store(initialState: .init(), reducer: VariableSpeedTimerReducer()) )
    }
}
