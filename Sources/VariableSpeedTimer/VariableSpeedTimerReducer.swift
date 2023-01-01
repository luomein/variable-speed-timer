//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2022/12/31.
//

import Foundation
import ComposableArchitecture


public struct VariableSpeedTimerReducer: ReducerProtocol {
    public init(){
        
    }
    public class TimerSpeedParameter{
        public static let timerSpeedMax : Double = 100.0
#if SNAPSHOT
        public static let timerSpeedInitValue : Double = 90.0
#else
        public static let timerSpeedInitValue : Double = 15.0
#endif
        public static let timerTotalTicksMin = 1.0
        public static let timerTotalTicksMax = 100.0

        public static func getTimerInterval(timerSpeed: Double)->Double{
            return (TimerSpeedParameter.timerSpeedMax + 5 - timerSpeed) * 10
        }
    }
    //private var timerSpeedParameter = TimerSpeedParameter()
    private enum TimerID {}
    
    public struct State: Equatable{
        public var currentTick : Double = 0.0
        public var totalTicks : Double = 50.0
        public var isTimerOn = false
        public var timerSpeed: Double = TimerSpeedParameter.timerSpeedInitValue
        
        public var t : Double { currentTick / totalTicks  }
        
        public init(currentTick: Double = 0.0,
                    totalTicks: Double = 50.0,
                    isTimerOn: Bool = false,
                    timerSpeed: Double = TimerSpeedParameter.timerSpeedInitValue) {
            self.currentTick = currentTick
            self.totalTicks = totalTicks
            self.isTimerOn = isTimerOn
            self.timerSpeed = timerSpeed
        }
    }
    public enum Action : Equatable{
        case stepForward
        case startTask
        case toggleTimer(Bool)
        case startFromTick(Double)
        case setTimerSpeed(Double)
        case setTotalTicks(Double)
        case restartTimer
        
    }
    private struct DebounceID : Hashable{}
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .stepForward:
            if !state.isTimerOn{
                return EffectTask(value: .toggleTimer(false))
            }
            state.currentTick += 1
            if state.currentTick > state.totalTicks{
                return EffectTask(value: .startFromTick(0))
            }
            
            return .none
        case .restartTimer:
            return .concatenate(EffectTask(value: .toggleTimer(false)),
                                EffectTask(value: .toggleTimer(true))
            )
        case .toggleTimer(let value):
            state.isTimerOn = value
            if state.isTimerOn
            {
                return EffectTask(value: .startTask)
            }
            else{
                return .cancel(id: TimerID.self)
            }
            
        case .startTask:
            let clock = SuspendingClock()
            return .run {[timerSpeed = state.timerSpeed] sender in
                while !Task.isCancelled{
                    do{
                        try await clock.sleep(for: .milliseconds(TimerSpeedParameter.getTimerInterval(timerSpeed: timerSpeed)))
                        //print(timerSpeed)
                        await Task.yield()
                        await sender.send(.stepForward)
                    }
                    catch{
                        if !Task.isCancelled{fatalError()}
                    }
                }
            }
            .cancellable(id: TimerID.self,cancelInFlight: true)
        case .startFromTick(let value):
            state.currentTick = value
            return .none
        case .setTimerSpeed(let value):
            state.timerSpeed = value
            return EffectTask(value: .restartTimer)
                //.debounce(id: DebounceID(), for: 0.1, scheduler: DispatchQueue.main)
        case .setTotalTicks(let value):
            state.totalTicks = value
            
            return EffectTask(value: .startFromTick(0))
        }
    }
}

