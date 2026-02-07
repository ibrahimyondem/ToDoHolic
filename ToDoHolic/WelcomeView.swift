import SwiftUI

//Create by Ibrahim Yondem and Baris Isci
//Welcome Screen

struct WelcomeView: View {
    
    @State private var name: String = ""
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                Text("Welcome To")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("ToDoHolic")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("What should we call you?")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                TextField("Enter your name here", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Spacer()
                
                NavigationLink(destination: DashboardView()) {
                    Text("Continue")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .disabled(name.isEmpty)
            }
            .padding(30)
        }
        }
        
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View{
        WelcomeView()
    }
}
