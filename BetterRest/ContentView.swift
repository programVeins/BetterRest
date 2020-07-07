//
//  ContentView.swift
//  BetterRest
//
//  Created by Sabesh Bharathi on 27/06/20.
//  Copyright © 2020 Sabesh Bharathi. All rights reserved.
//

import SwiftUI

struct ContentView: View {
 
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertMessage = ""
    
    let model = SleepCalculator()
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        
        let binding1 = Binding(
            get: { self.coffeeAmount },
            set: {
                self.coffeeAmount = $0
                self.calculateBedTime()
            }
        )
        
        let binding2 = Binding(
            get: { self.sleepAmount },
            set: {
                self.sleepAmount = $0
                self.calculateBedTime()
            }
        )
        
        let binding3 = Binding(
            get: { self.wakeUp },
            set: {
                self.wakeUp = $0
                self.calculateBedTime()
            }
        )
        
        return NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("Please enter a time", selection: binding3, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                }
                
                
                Section(header: Text("Desired amount of sleep")) {
                    Stepper(value: binding2, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                Section(header: Text("Daily coffee intake")) {
                    Picker(selection: binding1, label: Text("Coffee Amount")) {
                        ForEach(1..<20) { number in
                            Text( number > 1 ? "\(number) cups" : "\(number) cup")
                        }
                    }
                }
                
                Section(header: Text("Recommended time to hit bed")) {
                    HStack {
                        Text("\(alertMessage)")
                            .font(.largeTitle)
                    }
                    

                }
                    
            }
            .navigationBarTitle("BetterRest")
        }
        
    }
    
    func calculateBedTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            alertMessage = formatter.string(from: sleepTime)
            
        } catch {
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }

    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
