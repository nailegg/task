//
//  ContentView.swift
//  toys
//
//  Created by 이상현 on 2021/10/21.
//

import SwiftUI
import Alamofire

extension Color {
    static let creamBlack = Color("creamBlack")
    static let brightNavy = Color("brightNavy")
}


struct ContentView: View {
    
    @ObservedObject var taskStore = TaskViewModel()
    @State var newtask: String = ""
    @State var newdue = Date()
    @State var userid: String = ""
    @State private var showaddpopup = false
    @State private var showloginpopup = false
    
    init(){
        UITableView.appearance().backgroundColor = UIColor(Color.creamBlack)
        getcurrentTasks()
        }
    //일정 입력
    var searchBar: some View {
        HStack{
            VStack{
                TextField("enter a new task", text: self.$newtask)
                DatePicker("enter a new due", selection: self.$newdue).datePickerStyle(WheelDatePickerStyle())
                
                Button(action: {
                    self.addNewtask()
                    withAnimation{
                        self.showaddpopup = false
                    }
                }, label: {Text("add")}).padding()
            }
            
        }
    }
    
    //일정추가
    func addNewtask(){
        let newid = UUID().uuidString
        //taskStore.tasks.append(Task(id: newid, content: newtask, due: newdue))
        postTask(id: newid, content: newtask, due: newdue)
        getcurrentTasks()
        self.newtask = ""
        self.newdue = Date()
    }
    //듀 입력 형식
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd - hh:mm a"
        return formatter
    }
    //메인화면에 출력되는 듀,
    //일정을 눌렀을때 입력한형식 듀를 보여주는 기능을 넣고 싶었으나..
    var shortdateFormatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    
    var body: some View {
        ZStack{
            Color.creamBlack.ignoresSafeArea()
            VStack{
                
                Text("TaskManager")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                
                ZStack{
                    Color.creamBlack.ignoresSafeArea()
                    List{
                        Section(header: Text("\(taskStore.tasks.count) Tasks available").foregroundColor(.white).font(.system(size: 20))){
                            ForEach(Array(self.taskStore.tasks.enumerated()), id:\.offset){
                                index, task in ZStack{
                                    Image("taskbar")
                                        .resizable()
                                        .frame(width: 320, height: 70)
                                        .contextMenu{
                                            Button(action: {
                                                delete(index: index)
                                            }){Text("delete")}
                                        }

                                    VStack(alignment: .leading, spacing: 0){
                                        Text("Task: \(task.content)")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                            
                                        Text("Due: \(task.due,  formatter:shortdateFormatter)")
                                            .foregroundColor(.gray)
                                    }.padding(.trailing, 140)
                                    //Taskcard(Content: task.content, due: task.due, bgColor: .brightNavy)
                                }
                                .frame(height: 60)
                                                            }
                            .onMove(perform:self.move)
                            //.onDelete(perform: self.delete)
                            .listRowInsets(EdgeInsets.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .listRowBackground(Color.creamBlack)
                        }
                    }
                }
                }
            Button(action: {withAnimation(.linear(duration: 1)){
                self.showaddpopup = true
            }}, label: {
                Image("addbutton").resizable().frame(width: 55, height:55)}).padding(.top, 650)
            
            
            if $showaddpopup.wrappedValue{
                addtaskpopup()
            }
        }
    }
    
    func move(source: IndexSet, destination: Int){
        taskStore.tasks.move(fromOffsets: source, toOffset: destination)
    }
    //delete 후 get
    func delete(index: Int){
        //taskStore.tasks.remove(atOffsets: del)
        //let index = del[del.startIndex]
        deleteTask(id: self.taskStore.tasks[index].id)
        getcurrentTasks()
    }
    //일정추가 팝업
    func addtaskpopup() -> some View {
        VStack(spacing: 10){
            searchBar.padding()
        }
        .padding()
        .frame(width: 340, height: 400)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20 )
            
    }
        //get
    func getcurrentTasks(){
        let url = "http://172.20.45.26:4500/tasks/"
        
        AF.request(url, method: .get).validate().responseDecodable(of: [getTask].self){
            (response) in
            switch response.result {
            case .success:
                //guard let taskSto = response.value else {return}
                guard let gettaskSto = response.value else { return }
                let taskSto = gettaskSto.map({(value:getTask) -> Task in
                    Task(id: value.id, content: value.content, due: dateFormatter.date(from: value.due)!)
                })
                self.taskStore.tasks = taskSto
            case .failure(let error):
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!), response: \(response)")            }
        }
    }
    //post
    func postTask(id: String, content: String, due:Date){
        
        let url = "http://172.20.45.26:4500/tasks"
        //let url = " https://ptsv2.com/t/4cs21-1635190703/post"
        //var request = URLRequest(url: URL(string: url)!)
        //request.httpMethod = "POST"
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.timeoutInterval = 10
        let dateform = DateFormatter()
        dateform.dateFormat = "yyyy.MM.dd - hh:mm a"
        let dueString = dateform.string(from: due)

        // POST 로 보낼 정보
        let params = ["id": id, "content":content, "due":dueString] as Dictionary

                
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseString { (response) in
            switch response.result {
            case .success:
                print(response)
            case .failure(let error):
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    //delete
    func deleteTask(id: String){
        let url = "http://172.20.45.26:4500/tasks/id/" + id
        AF.request(url, method: .delete).responseString {
            (response) in
            
            switch response.result{
            case .success:
                print(response)
            case .failure(let error):
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
