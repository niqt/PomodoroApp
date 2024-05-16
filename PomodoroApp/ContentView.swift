//
//  ContentView.swift
//  PomodoroApp
//
//  Created by Nicola De Filippo on 15/05/24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    let pomodoroLength = 1 * 60
    @State var counter = 0
    @State var timeString = "25:00"
    @State var hasPermission = false
    
    var body: some View {
        VStack(spacing: 10) {
            Button("Start pomodoro") {
                if hasPermission {
                    counter = 0
                    timeString = "25:00"
                    setTimer()
                    timer.connect()
                    addNotification()
                }
            }
            Text("\(timeString)").onReceive(timer, perform: { _ in
                counter += 1
                
                let remaining = pomodoroLength - counter
                let minutes = remaining / 60
                let secs = remaining % 60
                timeString = "\(minutes):\(secs)"
                if counter == pomodoroLength {
                    timer.connect().cancel()
                }
            })
        }.onAppear {
            checkAuthorization()
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                hasPermission = true
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func addNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro elapsed"
        content.subtitle = "Take a break"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(pomodoroLength), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func setTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common)
    }
}


#Preview {
    ContentView()
}

