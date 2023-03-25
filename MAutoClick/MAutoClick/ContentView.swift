//
//  ContentView.swift
//  MAutoClick
//
//  Created by 김지태 on 2023/02/15.
//

import SwiftUI
import CoreGraphics
import HotKey

struct ContentView: View {
    // 작업 구조체
    struct InputUserAction: Hashable, Codable {
        let uuid = UUID()
        let locationX: Double
        let locationY: Double
        let actionRepeat: Int
        let delay: Double
        let action: ActionType
    }

    // 작업 종류
    enum ActionType: String, Codable {
        case move
        case click
        case delay
        
        var actionName: String {
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
    // 각각 Action Repeat
    @State var inputActionRepeat: Int = 1
    // 각각 Action Delay
    @State var inputActionDelay: Double = 0.0
    
    // 입력된 Delay
    @State var inputDelay: Double = 0.5
    
    // 입력된 Repeat
    @State var inputRepeat: Int = 1
    
    // 수행 Repeat
    @State var runRepeat: Int = 0
    
    // 작업 리스트
    @State var userTaskList: [InputUserAction] = []
    
    // 선택된 item
    @State var selectedItem: UUID?
    
    
    // 도움말 화면
    @State var isHelpShow: Bool = false
    // 움직이는 동작
    @State var actionMove: Bool = false
    // 선택하는 동작
    @State var actionClick: Bool = false
    // Auto Location Input Mode
    @State private var isAutoLocationInput: Bool = false
    // loop Mode
    @State var isLoopMode: Bool = false
    // 멈춤 신호
    @State var stopSignal: Bool = false
    // 실행 중인지 확인하는 신호
    @State var isStarted: Bool = false
    
    
    
    // add 실패 Alert 변수
    @State var isShowAddFailAlert: Bool = false
    // start repeat 실패 Alert 변수
    @State var isRepeatCountFailAlert: Bool = false
    // start Task list 실패 Alert 변수
    @State var isTaskCountFailAlert: Bool = false
    // 각 반복 횟수 잘 못 입력
    @State var isEachRepeatCountFailAlert: Bool = false
    
    let startAndStopHotKey = HotKey(key: .s, modifiers: [.shift, .command])
    
    //MARK: - 메인 몸통
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                self.mouseLocationView()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 60)
                    .padding(.bottom, 0)
                
                Divider()
                
                HStack(spacing: 0) {
                    self.leftSideView()
                    
                    Divider()
                        .padding(.top, 0)
                        .padding(.bottom, 0)
                        .frame(minHeight: 0, maxHeight: .infinity)
                    
                    self.rightSideView()
                        .frame(width: 190)
                }
                .frame(height: 230)
                
                Divider()
                
                self.taskListView()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
            
        }
        .frame(width: 700, height: 420)
        .onAppear(perform: {
            do {
                let user = UserDefaults.standard
                let content = user.object(forKey: "userTaskList") as? Data
                let json = try JSONDecoder().decode([InputUserAction].self, from: content!)
                self.userTaskList = json
            } catch {
                
            }
            self.startAndStopHotKey.keyDownHandler = {
                
                DispatchQueue.main.async {
                    self.selectedItem = nil
                }
                
                if self.isStarted {
                    // 진행 상태
                    
                    // 한번 거르기
                    if !self.isStarted {
                        return
                    }
                    
                    // 진행 상태를 멈춤으로 변경
                    self.isStarted = false
                    // 멈춤 신호 발생
                    self.stopSignal = true
                } else {
                    // 멈춤 상태
                    
                    // 한번 거르기
                    if self.isStarted {
                        return
                    }
                    
                    // 반복 횟수가 0인 경우
                    if self.inputRepeat == 0 {
                        // 무한 모드 여부 확인
                        if !self.isLoopMode {
                            // 무한 모드가 아니면 시작 안함
                            self.isRepeatCountFailAlert = true
                            return
                        }
                    }
                    
                    // 작업 리스트 개수가 0인 경우
                    if self.userTaskList.count == 0 {
                        self.isTaskCountFailAlert = true
                        return
                    }
                    
                    // 진행 상태를 시작으로 변경
                    self.isStarted = true
                    // 시작
                    self.runMAutoClick()
                }
            }
            
            self.actionMove = true
            
            NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                self.mouseLocationX = self.mouseLocation.x
                self.mouseLocationY = self.mouseLocation.y
                
                if self.isAutoLocationInput {
                    self.inputLocationX = self.mouseLocation.x
                    self.inputLocationY = self.mouseLocation.y
                }
                
                return $0
            }
        })
        
        
        
    }
    
    
    
}

//MARK: - 3 마디 부분
extension ContentView {
    
    //MARK: - 왼쪽 기본 기능 부분
    @ViewBuilder
    private func leftSideView() -> some View {
       
        VStack(spacing: 0) {
            
            self.actionView()
            
            Divider()
                .padding(.top, 8)
            
            self.delayView()
        }
        .frame(minHeight: 0, maxHeight: .infinity)
    }
    
    //MARK: - 가운데 앱 설정 부분
    @ViewBuilder
    private func rightSideView() -> some View {
        VStack {
            
            Spacer()
            Toggle("Auto Location", isOn: $isAutoLocationInput)
                .onChange(of: isAutoLocationInput) { value in
                    if self.isAutoLocationInput {
                        // 입력된 위치
                        self.inputLocationX = self.mouseLocationX
                        self.inputLocationY = self.mouseLocationY
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .disabled(self.isStarted)
                .keyboardShortcut("p", modifiers: [.command, .shift])
            
            Toggle("Loop Mode", isOn: $isLoopMode)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .disabled(self.isStarted)
                .keyboardShortcut("l", modifiers: [.command, .shift])
            
            Spacer()
            
            
            self.repeatView()
            
            HStack {
                Text("State")
                    .padding(.leading, 8)
                
                
                if self.isStarted {
                    Text("Started")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                        .foregroundColor(.green)
                } else {
                    Text("Stop")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                        .foregroundColor(.red)
                }
                
                
            }
            
            
            HStack {
                Text("Repeat")
                    .padding(.leading, 8)
                    
                
                if self.isLoopMode {
                    Text("LoopMode")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                } else {
                    Text("\(self.runRepeat)/\(self.inputRepeat)")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                }
            }
            
            
            
            HStack {
                // 시작 버튼
                Button {
                    
                    if self.isStarted {
                        return
                    }
                    
                    if self.inputRepeat == 0 {
                        if !self.isLoopMode {
                            self.isRepeatCountFailAlert = true
                            return
                        }
                    }
                    
                    if self.userTaskList.count == 0 {
                        self.isTaskCountFailAlert = true
                        return
                    }
                    
                    
                    self.isStarted = true
                    self.runMAutoClick()
                } label: {
                    Text("Start")
                }
                .alert(Text("Start Failed!"), isPresented: $isRepeatCountFailAlert) {
                    Button("OK") {
                        self.isRepeatCountFailAlert = false
                    }
                } message: {
                    Text("Please enter the number of repeat!")
                }
                .alert(Text("Start Failed!"), isPresented: $isTaskCountFailAlert) {
                    Button("OK") {
                        self.isTaskCountFailAlert = false
                    }
                } message: {
                    Text("Please add Action!")
                }
                .disabled(self.isStarted)
                
                // 종료 버튼
                Button {
                    
                    if !self.isStarted {
                        return
                    }
                    
                    self.isStarted = false
                    self.stopSignal = true
                } label: {
                    Text("Stop")
                }
                .disabled(!self.isStarted)
                
                Button {
                    self.isHelpShow = true
                } label: {
                    Text("Help")
                }
                .disabled(self.isStarted)
                .sheet(isPresented: $isHelpShow) {
                    HelpView(isHelpShow: $isHelpShow)
                }
            }
            .frame(height: 10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.all)
        }
        
        
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
                    HStack(spacing: 3) {
                        Text("LocationX")
                        TextField("LocationX", value: $inputLocationX, format: .number)
                            .padding(.leading, 30)
                            .textFieldStyle(.roundedBorder)
                            .disabled(self.isAutoLocationInput)
                            .disabled(self.isStarted)
                    }
                    .padding(.leading, 10)
                    
                    HStack(spacing: 3) {
                        Text("LocationY")
                        TextField("LocationY", value: $inputLocationY, format: .number)
                            .padding(.leading, 31)
                            .textFieldStyle(.roundedBorder)
                            .disabled(self.isAutoLocationInput)
                            .disabled(self.isStarted)
                    }
                    .padding(.leading, 10)
                    
                    HStack(spacing: 3) {
                        Text("Action Repeat")
                        TextField("Action Repeat", value: $inputActionRepeat, format: .number)
                            .padding(.leading, 6)
                            .textFieldStyle(.roundedBorder)
                            .disabled(self.isStarted)
                    }
                    .padding(.leading, 10)
                    
                    HStack(spacing: 3) {
                        Text("Action Delay")
                        TextField("Action Delay", value: $inputActionDelay, format: .number)
                            .padding(.leading, 15)
                            .textFieldStyle(.roundedBorder)
                            .disabled(self.isStarted)
                    }
                    .padding(.leading, 10)
                }
                
                VStack {
                    Toggle("Move", isOn: $actionMove)
                        .onChange(of: self.actionMove) { newValue in
                            self.actionClick = !newValue
                        }
                        .keyboardShortcut("c", modifiers: [.command, .shift])
                        .disabled(self.isStarted)
                    
                    Toggle("Click", isOn: $actionClick)
                        .onChange(of: self.actionClick) { newValue in
                            self.actionMove = !newValue
                        }
                    
                    
                    
                    Button {
                        DispatchQueue.main.async {
                            NSApp.keyWindow?.makeFirstResponder(nil)
                        }
                        if !self.actionClick && !self.actionMove {
                            self.isShowAddFailAlert = true
                            return
                        }
                        
                        if self.inputActionRepeat == 0 {
                            self.isEachRepeatCountFailAlert = true
                            return
                        }
                        
                        let inputData = InputUserAction(locationX: self.inputLocationX,
                                                        locationY: self.inputLocationY,
                                                        actionRepeat: self.inputActionRepeat,
                                                        delay: self.inputActionDelay,
                                                        action: self.actionMove ? .move : .click)
                        self.userTaskList.append(inputData)
                        DispatchQueue.main.async {
                            self.inputActionRepeat = 1
                            self.inputActionDelay = 0
                        }
                        
                    } label: {
                        Text("Add")
                    }
                    .padding()
                    .alert(Text("Add Failed!"), isPresented: $isShowAddFailAlert) {
                        Button("OK") {
                            self.isShowAddFailAlert = false
                        }
                    } message: {
                        Text("Please choose action!")
                    }
                    .alert(Text("Add Failed!"), isPresented: $isEachRepeatCountFailAlert) {
                        Button("OK") {
                            DispatchQueue.main.async {
                                NSApp.keyWindow?.makeFirstResponder(nil)
                                self.inputActionRepeat = 1
                            }
                            self.isEachRepeatCountFailAlert = false
                        }
                    } message: {
                        Text("Please enter each repeat count!")
                    }
                    .disabled(self.isStarted)
                    .keyboardShortcut("a", modifiers: [.command, .shift])
                    .frame(height: 30)
                    
                }
            }
            .padding(.top, 5)
        
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
                .disabled(self.isStarted)

            Button {
                let inputData = InputUserAction(locationX: 0,
                                                locationY: 0,
                                                actionRepeat: 1,
                                                delay: self.inputDelay,
                                                action: .delay)
                self.userTaskList.append(inputData)
            } label: {
                Text("Add")
            }
            .padding(.trailing)
            .padding(.leading)
            .disabled(self.isStarted)
            .keyboardShortcut("d", modifiers: [.command, .shift])
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
                .disabled(self.isLoopMode)
                .disabled(self.isStarted)
            
        }

    }
    
    private func deleteAction(at offsets: IndexSet) {
        self.userTaskList.remove(atOffsets: offsets)
    }
    
    //MARK: - 오른쪽 리스트
    @ViewBuilder
    private func taskListView() -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    
                    // 600
                    Text("No")
                        .frame(width: 80)
                    Text("X")
                        .frame(width: 115)
                    Text("Y")
                        .frame(width: 115)
                    Text("Action")
                        .frame(width: 70)
                    Text("Action Repeat")
                        .frame(width: 110)
                    Text("Action Delay")
                        .frame(width: 110)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .frame(height: 25)
                
                
                List {
                    ForEach(Array(self.userTaskList.enumerated()), id: \.offset) { index, element in
                        if element.action == .move || element.action == .click {
                            self.listActionCellView(indexNumber: index + 1,
                                                    uuid: element.uuid,
                                                    locationX: element.locationX,
                                                    locationY: element.locationY,
                                                    actionRepeat: element.actionRepeat,
                                                    actionDelay: element.delay,
                                                    mode: element.action == .move ? "Move" : "Click")
                        } else {
                            self.listDelayCellView(indexNumber: index + 1, uuid: element.uuid, delay: element.delay)
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            
            
            VStack {
                Button {
                    self.SaveUserTaskList()
                } label: {
                    Text("Save")
                }
                
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
            .frame(minHeight: 0, maxHeight: .infinity)
            .frame(width: 100)
        }
        .frame(minHeight: 0, maxHeight: .infinity)
        .disabled(self.isStarted)
    }
    
    // 동작 Cell
    @ViewBuilder
    private func listActionCellView(indexNumber: Int, uuid: UUID, locationX: Double, locationY: Double, actionRepeat: Int, actionDelay: Double, mode: String) -> some View {
        
        HStack(spacing: 0) {
            Text("\(indexNumber)")
                .frame(width: 80)
                .fontWeight(.semibold)
            Text(String(format: "%.03f", locationX))
                .frame(width: 115)
                .fontWeight(.semibold)
            Text(String(format: "%.03f", locationY))
                .frame(width: 115)
                .fontWeight(.semibold)
            Text(mode)
                .frame(width: 70)
                .fontWeight(.semibold)
            Text("\(actionRepeat)")
                .frame(width: 110)
                .fontWeight(.semibold)
            Text("\(actionDelay.removeZerosFromEnd())")
                .frame(width: 110)
                .fontWeight(.semibold)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)
        .background(self.selectedColor(currentUUID: uuid))
        .onTapGesture {
            self.indexCheck(currentUUID: uuid)
        }
    }
    
    
    private func selectedColor(currentUUID: UUID) -> Color {
        if let uuid = self.selectedItem {
            if uuid == currentUUID {
                return .blue
            } else {
                return .clear
            }
        } else {
            return .clear
        }
    }
    
    
    // 지연 Cell
    @ViewBuilder
    private func listDelayCellView(indexNumber: Int, uuid: UUID, delay: Double) -> some View {
        
        HStack(spacing: 0) {
            Text("\(indexNumber)")
                .frame(width: 80)
                .fontWeight(.semibold)
            
            Text("0")
                .frame(width: 115)
                .fontWeight(.semibold)
            Text("0")
                .frame(width: 115)
                .fontWeight(.semibold)
            Text("Delay")
                .frame(width: 70)
                .fontWeight(.semibold)
            Text("1")
                .frame(width: 110)
                .fontWeight(.semibold)
            Text("\(delay.removeZerosFromEnd())")
                .frame(width: 110)
                .fontWeight(.semibold)
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)
        .background(self.selectedColor(currentUUID: uuid))
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
        
        
        DispatchQueue.global().async {
            while true {
                self.runRepeat += 1
                
                for action in self.userTaskList {
                    
                    DispatchQueue.main.async {
                        self.indexCheck(currentUUID: action.uuid)
                    }
                    
                    
                    var count = 0
                    
                    // 각 동작별 반복
                    while count < action.actionRepeat {
                        
                        // 멈춤 신호
                        if self.stopSignal {
                            break
                        }
                        
                        self.switchAction(action: action)
                        
                        
                        count += 1
                    }
                    
                }
                
                // 멈춤 신호
                if self.stopSignal {
                    // 정지 신호면 멈춤
                    self.stopSignal = false
                    break
                }
                
                // Loop Mode면 처음으로
                if self.isLoopMode {
                    continue
                }
                
                // 횟수 모드 체크
                if self.runRepeat == self.inputRepeat {
                    // 횟수가 같으면 멈춤
                    self.isStarted = false
                    break
                }
            }
            
            self.runRepeat = 0
        }
        
        
    }
    
    
    private func switchAction(action: InputUserAction) {
        switch action.action {
        case .move:
            if let screen = NSScreen.main {
                let rect = screen.frame
                let height = rect.size.height
                
                let newCursorPosition = CGPoint(x: action.locationX, y: height - action.locationY)
                CGWarpMouseCursorPosition(newCursorPosition)
                
                let second: Double = 1000000
                usleep(useconds_t(action.delay * second))
            }
        case .click:
            if let screen = NSScreen.main {
                let rect = screen.frame
                let height = rect.size.height
                
                
                // Git Hub
                let source = CGEventSource.init(stateID: .hidSystemState)
                let position = CGPoint(x: action.locationX, y: height - action.locationY)


                let eventDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: position , mouseButton: .left)
                let eventUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: position , mouseButton: .left)


                eventDown?.post(tap: .cghidEventTap)
                eventUp?.post(tap: .cghidEventTap)
                
                let second: Double = 1000000
                usleep(useconds_t(action.delay * second))
            }
        case .delay:
            let second: Double = 1000000
            usleep(useconds_t(action.delay * second))
        }
    }
    
    private func SaveUserTaskList() {
        do {
            let list = try JSONEncoder().encode(self.userTaskList)
            let user = UserDefaults.standard
            user.set(list, forKey: "userTaskList")
        } catch {
            
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
 
 1. 레이아웃 변경
 2. Auto Location 추가 - 마우스 현재 위치를 자동으로 입력하는 모드
 3. Loop Mode 추가 - Repeat 제한 없이 계속 실행하는 모드
 4. Start, Stop 로직 추가
 5. 단축키 추가
    5-1 - Command + Shift(left) + C = action 상태를 move와 click 사이를 스위칭
    5-2 - Command + Shift(left) + A = 설정된 action을 List에 추가함
    5-3 - Command + Shift(left) + D = 설정된 delay를 List에 추가함
    5-4 - Command + Shift(left) + S = Start/Stop 기능
    5-5 - Command + Shift(left) + L = Loop Mode 기능 활성화
    5-6 - Command + Shift(left) + P = Auto Location 기능 활성화
 
 
 */

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}
