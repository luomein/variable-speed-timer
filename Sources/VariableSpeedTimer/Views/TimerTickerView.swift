//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2022/12/31.
//

import SwiftUI
import ComposableArchitecture

public struct TimerTickerView: View {
    let store: StoreOf<VariableSpeedTimerReducer>
    public init(store: StoreOf<VariableSpeedTimerReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            VStack{
                
                HStack{
                    Spacer()
                    Button {
                        viewStore.send(.toggleTimer(!viewStore.isTimerOn))
                    } label: {
                        Text(Image(systemName: (viewStore.state.isTimerOn) ? "pause.rectangle.fill" : "play.rectangle.fill"))
                            .font(.title)
                        
                    }
                    
                    Slider(value: viewStore.binding(get: \.currentTick, send: VariableSpeedTimerReducer.Action.startFromTick), in: 0...viewStore.totalTicks)
                        .frame(width:150)
                        .padding()
                }
                
                Spacer()
            }
            .onAppear(perform: {
                viewStore.send(.startFromTick(0))
                viewStore.send(.toggleTimer(true))
            })
            .onDisappear(perform: {
                //on iPhone, when rotating device, it will cause the view to disappear
                //the event is, onAppear -> onDisappear
                viewStore.send(.toggleTimer(false))
            })
        }
    }
}
struct TimerTickerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerTickerView(store: Store(initialState: .init(), reducer: VariableSpeedTimerReducer()) )
    }
}
