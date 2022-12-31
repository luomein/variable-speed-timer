//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2022/12/31.
//

import SwiftUI
import ComposableArchitecture

public struct TimerConfigView: View {
    let store: StoreOf<VariableSpeedTimerReducer>
    public init(store: StoreOf<VariableSpeedTimerReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List{
                HStack{
                    Text("Timer Speed")
                    Slider(value: viewStore.binding(get: \.timerSpeed, send: VariableSpeedTimerReducer.Action.setTimerSpeed),
                           in: 0...VariableSpeedTimerReducer.TimerSpeedParameter.timerSpeedMax, label: {Text("Timer Speed")},
                           minimumValueLabel: {Text(Image(systemName: "tortoise"))},
                           maximumValueLabel: {Text(Image(systemName: "hare"))}
                    )
                    
                }
                HStack{
                    Text("Total Ticks")
                    
                    Slider(value: viewStore.binding(get: \.totalTicks, send: VariableSpeedTimerReducer.Action.setTotalTicks),
                           in: VariableSpeedTimerReducer.TimerSpeedParameter.timerTotalTicksMin...VariableSpeedTimerReducer.TimerSpeedParameter.timerTotalTicksMax, label: {Text("Total Ticks")},
                           minimumValueLabel: {Text(Int(VariableSpeedTimerReducer.TimerSpeedParameter.timerTotalTicksMin).description)},
                           maximumValueLabel: {Text(Int(VariableSpeedTimerReducer.TimerSpeedParameter.timerTotalTicksMax).description)}
                    )
                    
                }
            }
            
        }
    }
}



struct TimerConfigView_Previews: PreviewProvider {
    static var previews: some View {
        TimerConfigView(store: Store(initialState: .init(), reducer: VariableSpeedTimerReducer()) )
    }
}
