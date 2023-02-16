//
//  ContentView.swift
//  MAutoClick
//
//  Created by 김지태 on 2023/02/15.
//

import SwiftUI

struct InputLocationCoordinate: Hashable {
    let locationX: Double
    let locationY: Double
    let mode: Int
}


struct ContentView: View {
    
    
    var mouseLocation: NSPoint {
        NSEvent.mouseLocation
    }
    
    @State var mouseLocationX: Double = 0.0
    @State var mouseLocationY: Double = 0.0
    
    @State var inputLocationX: Double = 0.0
    @State var inputLocationY: Double = 0.0
    
    @State var userTaskList: [InputLocationCoordinate] = []
    
    // 0
    @State var moveMode: Bool = false
    // 1
    @State var clickMode: Bool = false
    
    @State var isShowAddFailAlert: Bool = false
    
    var body: some View {
        
        ZStack {
            
            
            HStack(spacing: 0) {
                self.settingsView()
                self.taskListView()
            }
            
//            VStack {
//
//                Image(systemName: "clock").resizable().frame(width: 200, height: 200)
//                            .onHover { over in
//                                overImg = over
//                            }
//                            .onAppear(perform: {
//                                NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
//                                    if overImg {
//                                        print("mouse: \(self.mouseLocation.x) \(self.mouseLocation.y)")
//                                    }
//                                    return $0
//                                }
//                            })
//
//                GeometryReader { geometry in
//                    VStack {
//                        Text("\(geometry.size.width) x \(geometry.size.height)")
//                    }.frame(width: geometry.size.width, height: geometry.size.height)
//                }
//
//                Text("Mouse \nLocationX : \(mouseLocation.x), \nLocationY : \(mouseLocation.y)")
//
//
//                Button {
//
//                    if let screen = NSScreen.main {
//                        let rect = screen.frame
//                        let height = rect.size.height
//                        let width = rect.size.width
//
//                        let source = CGEventSource.init(stateID: .hidSystemState)
////                        let position = NSPoint(x: 1521.18, y: height - 1570.183)
////                        let position = NSPoint(x: 1521.18, y: height - 1672.281)
//                        let position = CGPoint(x: 848, y: height - 435)
//
//                        print(CGPoint(x: mouseLocation.x, y: height - mouseLocation.y))
//                        let eventDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: position , mouseButton: .left)
//
//
//                        let positionTwo = CGPoint(x: 800, y: height - 435)
//                        let eventMove = CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: positionTwo , mouseButton: .left)
//
//                        let eventUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: positionTwo , mouseButton: .left)
//
//                        eventDown?.post(tap: .cghidEventTap)
//                        usleep(500_000)
//                        eventMove?.post(tap: .cghidEventTap)
//                        usleep(500_000)
//                        eventUp?.post(tap: .cghidEventTap)
//                    }
//
//
//                } label: {
//                    Text("나를 눌러")
//                }
//
//            }
        }
        .frame(width: 500, height: 300)
        
    }
    
    @ViewBuilder
    private func settingsView() -> some View {
        VStack {
            HStack {
                Text("Mouse Location")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 140)
                Divider()
                    .frame(width: 10)
                VStack {

                    Text("X : \(self.mouseLocationX)")
                        .lineLimit(1)
                        .frame(width: 150, alignment: .leading)

                    Text("Y : \(self.mouseLocationY)")
                        .lineLimit(1)
                        .frame(width: 150, alignment: .leading)
                }
            }
            .frame(height: 50)
           
            Divider()
            
            VStack {
                HStack {
                    VStack {
                        TextField("LocationX", value: $inputLocationX, format: .number)
                            .padding(.leading, 3)
                            
                        TextField("LocationY", value: $inputLocationY, format: .number)
                            .padding(.leading, 3)
                    }
                    
                    Button {
                        if !self.clickMode && !self.moveMode {
                            self.isShowAddFailAlert = true
                            return
                        }
                        let inputData = InputLocationCoordinate(locationX: self.inputLocationX,
                                                                locationY: self.inputLocationY,
                                                                mode: self.moveMode ? 0 : 1)
                        self.userTaskList.append(inputData)
                        print("받은 데이터 : \(self.userTaskList),", self.moveMode)
                        
                    } label: {
                        Text("Add")
                    }
                    .padding()
                    .alert(Text("Add Failed!"), isPresented: $isShowAddFailAlert) {
                        Button("OK") {
                            self.isShowAddFailAlert = false
                        }
                    }
                }
                
                HStack {
                    Toggle("Move Mode", isOn: $moveMode)
                        .onChange(of: self.moveMode) { newValue in
                            self.clickMode = !newValue
                            
                        }
                    Toggle("Click Mode", isOn: $clickMode)
                        .onChange(of: self.clickMode) { newValue in
                            self.moveMode = !newValue
                        }
                }
            }
            
            Spacer()
            
        }
        .frame(width: 300)
        .onAppear(perform: {
            NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                self.mouseLocationX = self.mouseLocation.x
                self.mouseLocationY = self.mouseLocation.y
                return $0
            }
        })
    }
    
    @ViewBuilder
    private func taskListView() -> some View {
        List(self.userTaskList, id: \.self) {
            Text("X : \($0.locationX)")
            Text("Y : \($0.locationY)")
            Text($0.mode == 0 ? "Move Mode" : "Click Mode")
        }
        .frame(width: 200)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
