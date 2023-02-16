//
//  ContentView.swift
//  MAutoClick
//
//  Created by 김지태 on 2023/02/15.
//

import SwiftUI



struct ContentView: View {
    // 작업 구조체
    struct InputUserAction: Hashable {
        let uuid = UUID()
        let locationX: Double
        let locationY: Double
        let delay: Double
        let mode: TaskType
    }

    // 작업 종류
    enum TaskType: String {
        case move
        case click
        case delay
        
        var modeName: String {
            switch self {
            case .move:
                return "Move"
            case .click:
                return "Click"
            case .delay:
                return "Delay"
            }
        }
    }
    
    // 마우스 위치
    var mouseLocation: NSPoint {
        NSEvent.mouseLocation
    }
    
    // 마우승 위치 coordinate
    @State var mouseLocationX: Double = 0.0
    @State var mouseLocationY: Double = 0.0
    
    // 입력된 위치
    @State var inputLocationX: Double = 0.0
    @State var inputLocationY: Double = 0.0
    // 입력된 Delay
    @State var inputDelay: Double = 0.0
    // 입력된 Repeat
    @State var inputRepeat: Int = 0
    // 수행 Repeat
    @State var runRepeat: Int = 0
    
    // 작업 리스트
    @State var userTaskList: [InputUserAction] = []
    
    // 선택된 item
    @State var selectedItem: UUID?
    
    
    
    // 0
    @State var moveMode: Bool = false
    // 1
    @State var clickMode: Bool = false
    // add 실패 Alert 변수
    @State var isShowAddFailAlert: Bool = false
    // start 실패 Alert 변수
    @State var isShowStartFailAlert: Bool = false
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    self.settingsView()
                    self.taskListView()
                }
                
                
            }
        }
        .frame(width: 500, height: 350)
        
    }
    
    @ViewBuilder
    private func settingsView() -> some View {
        VStack(spacing: 0) {
            
            self.mouseLocationView()
           
            Divider()
            
            self.actionView()
            
            
            Divider()
                .padding(.top, 8)
            
            
            self.delayView()
            
            Divider()
                .padding(.top, 8)
            
            
            self.repeatView()
            
            HStack {
                Button {
                    if self.inputRepeat == 0 {
                        self.isShowStartFailAlert = true
                        return
                    }
                    self.runMAutoClick()
                } label: {
                    Text("Start")
                }
                .alert(Text("Start Failed!"), isPresented: $isShowStartFailAlert) {
                    Button("OK") {
                        self.isShowStartFailAlert = false
                    }
                } message: {
                    Text("Please enter the number of repeat!")
                }
                
                Button {
                    print("Hi")
                } label: {
                    Text("Stop")
                }
                
                Text("\(self.runRepeat)/\(self.inputRepeat)")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 8)
            }
            .frame(height: 10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.all)
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
    
    // 마우스 위치 표시 화면
    @ViewBuilder
    private func mouseLocationView() -> some View {
        HStack(spacing: 0) {
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
            .padding(.leading, 10)
        }
    }
    
    // Action View
    @ViewBuilder
    private func actionView() -> some View {
        Text("Action")
            .font(.system(size: 14, weight: .bold))
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
        
        
        HStack {
            VStack {
                TextField("LocationX", value: $inputLocationX, format: .number)
                    .padding(.leading, 8)
                    .textFieldStyle(.roundedBorder)

                TextField("LocationY", value: $inputLocationY, format: .number)
                    .padding(.leading, 8)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                if !self.clickMode && !self.moveMode {
                    self.isShowAddFailAlert = true
                    return
                }
                let inputData = InputUserAction(locationX: self.inputLocationX,
                                                locationY: self.inputLocationY,
                                                delay: 0.0,
                                                mode: self.moveMode ? .move : .click)
                self.userTaskList.append(inputData)
            } label: {
                Text("Add")
            }
            .padding()
            .alert(Text("Add Failed!"), isPresented: $isShowAddFailAlert) {
                Button("OK") {
                    self.isShowAddFailAlert = false
                }
            } message: {
                Text("Please choose mode!")
            }
        }
        .padding(.top, 5)
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
    
    // 지연 View
    @ViewBuilder
    private func delayView() -> some View {
        Text("Dealy")
            .font(.system(size: 14, weight: .bold))
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
        
        HStack {
            TextField("Delay", value: $inputDelay, format: .number)
                .padding(.leading, 8)
                .textFieldStyle(.roundedBorder)

            Button {
                let inputData = InputUserAction(locationX: 0,
                                                locationY: 0,
                                                delay: self.inputDelay,
                                                mode: .delay)
                self.userTaskList.append(inputData)
            } label: {
                Text("Add")
            }
            .padding(.trailing)
            .padding(.leading)
        }
        .padding(.top, 5)
        .padding(.bottom, 5)
    }
    
    // 반복 View
    @ViewBuilder
    private func repeatView() -> some View {
        Text("Repeat")
            .font(.system(size: 14, weight: .bold))
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
        
        HStack {
            TextField("Repeat", value: $inputRepeat, format: .number)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .padding(.top, 5)
                .padding(.bottom, 5)
            
        }

    }
    
    private func deleteAction(at offsets: IndexSet) {
        self.userTaskList.remove(atOffsets: offsets)
    }
    
    // 리스트
    @ViewBuilder
    private func taskListView() -> some View {
        
        VStack(spacing: 0) {
            List {
                ForEach(Array(self.userTaskList.enumerated()), id: \.offset) { index, element in
                    if element.mode == .move || element.mode == .click {
                        self.listActionCellView(indexNumber: index, uuid: element.uuid, locationX: element.locationX, locationY: element.locationY, mode: element.mode == .move ? "Move" : "Click")
                    } else {
                        self.listDelayCellView(indexNumber: index, uuid: element.uuid, delay: element.delay)
                    }
                }
            }
            .frame(minHeight: 0, maxHeight: .infinity)
            
            
            HStack {
                Button {
                    guard let uuid = self.selectedItem else { return }
                    for (index, item) in self.userTaskList.enumerated() {
                        if item.uuid == uuid {
                            
                            if index == 0 {
                                return
                            }
                            self.userTaskList.swapAt(index - 1, index)
                        }
                    }
                    
                    
                } label: {
                    Text("UP")
                }

                Button {
                    guard let uuid = self.selectedItem else { return }
                    for (index, item) in self.userTaskList.enumerated() {
                        if item.uuid == uuid {
                            
                            if index == self.userTaskList.count - 1 {
                                return
                            }
                            self.userTaskList.swapAt(index, index + 1)
                        }
                    }
                } label: {
                    Text("Down")
                }

                Button {
                    guard let uuid = self.selectedItem else { return }
                    for (index, item) in self.userTaskList.enumerated() {
                        if item.uuid == uuid {
                            self.userTaskList.remove(at: index)
                            self.selectedItem = nil
                        }
                    }
                } label: {

                    Text("Delete")
                }
            }
            .frame(height: 10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.all)
        }
        .frame(minHeight: 0, maxHeight: .infinity)
        .frame(width: 200)
    }
    
    // 동작 Cell
    @ViewBuilder
    private func listActionCellView(indexNumber: Int, uuid: UUID, locationX: Double, locationY: Double, mode: String) -> some View {
        
        ZStack {
            HStack {
                Text("\(indexNumber)")
                
                Divider()
                
                VStack(spacing: 0) {
                    Text("X : \(locationX)")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .fontWeight(.semibold)
                    Text("Y : \(locationY)")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .fontWeight(.semibold)
                    Text("Mode : \(mode)")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .fontWeight(.semibold)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.all, 4)
                .background(self.selectedColor(currentUUID: uuid))
                .cornerRadius(5)
            }
            .onTapGesture {
                self.indexCheck(currentUUID: uuid)
            }
        }
       
        
    }
    
    
    private func selectedColor(currentUUID: UUID) -> Color {
        if let uuid = self.selectedItem {
            if uuid == currentUUID {
                return .blue
            } else {
                return .gray
            }
        } else {
            return .gray
        }
    }
    
    
    // 지연 Cell
    @ViewBuilder
    private func listDelayCellView(indexNumber: Int, uuid: UUID, delay: Double) -> some View {
        
        HStack {
            Text("\(indexNumber)")
            
            Divider()
            Text("Delay : \(delay)")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .fontWeight(.semibold)
                .padding(.all, 4)
                .background(self.selectedColor(currentUUID: uuid))
                .cornerRadius(5)
        }
        .onTapGesture {
            self.indexCheck(currentUUID: uuid)
        }
    }
    
    private func indexCheck(currentUUID: UUID) {
        if let uuid = self.selectedItem {
            if uuid == currentUUID {
                self.selectedItem = nil
            } else {
                self.selectedItem = currentUUID
            }
        } else {
            self.selectedItem = currentUUID
        }
    }
    
    private func runMAutoClick() {
        self.runRepeat = 0
        
        while true {
            self.runRepeat += 1
            
            
            
            for action in self.userTaskList {
                
                
                switch action.mode {
                case .move:
                    
                    if let screen = NSScreen.main {
                        let rect = screen.frame
                        let height = rect.size.height
                        
                        let source = CGEventSource.init(stateID: .hidSystemState)
                        let position = CGPoint(x: action.locationX, y: height - action.locationY)
                        let eventMove = CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: position, mouseButton: .left)
                        eventMove?.post(tap: .cghidEventTap)
                    }
                    print("move")
                case .click:
                    
                    if let screen = NSScreen.main {
                        let rect = screen.frame
                        let height = rect.size.height
                        
                        let source = CGEventSource.init(stateID: .hidSystemState)
                        let position = CGPoint(x: action.locationX, y: height - action.locationY)
                        
                        let eventDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: position , mouseButton: .left)
                        let eventUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: position , mouseButton: .left)
                        
                        eventDown?.post(tap: .cghidEventTap)
                        eventUp?.post(tap: .cghidEventTap)
                    }
                    
                    print("click")
                case .delay:
                    print("delay")
                    
                    
                    let second: Double = 1000000
                    let startTime = CFAbsoluteTimeGetCurrent()
                    usleep(useconds_t(action.delay * second))
                    let endTime = CFAbsoluteTimeGetCurrent() - startTime
                    
                    print("endtime : ", endTime)
                }
                
            }
            
            print("count : \(self.runRepeat)")
            
            if self.runRepeat == self.inputRepeat {
                break
            }
        }
        
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
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
