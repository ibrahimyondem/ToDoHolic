import SwiftUI

//Create by Ibrahim Yondem and Baris Isci
//Welcome Screen

struct WelcomeView: View {
    @AppStorage("userName") private var storedName: String = ""
    @State private var name: String = ""
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
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
                        .background(trimmedName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    storedName = trimmedName
                })
                .disabled(trimmedName.isEmpty)
            }
            .padding(30)
            .onAppear {
                if name.isEmpty {
                    name = storedName
                }
            }
        }
        }
        
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View{
        WelcomeView()
    }
}
