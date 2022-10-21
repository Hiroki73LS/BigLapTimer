import SwiftUI
import RealmSwift
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import AVFoundation


struct AdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        // 以下は、バナー広告向けのテスト専用広告ユニットIDです。自身の広告ユニットIDと置き換えてください。
                        banner.adUnitID = "ca-app-pub-1023155372875273/2954960110"
        
        
//        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
    }
}

class UserProfile: ObservableObject {
    
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }}
    @Published var level: Int {
        didSet {
            UserDefaults.standard.set(level, forKey: "level")
        }}
    /// 利き手のモード値
    @Published var mode: Bool {
        didSet {
            UserDefaults.standard.set(mode, forKey: "mode")
        }}
    /// 初期化処理
    init() {
        username = UserDefaults.standard.string(forKey: "username") ?? ""
        level = UserDefaults.standard.object(forKey: "level") as? Int ?? 1
        mode = UserDefaults.standard.object(forKey: "mode") as? Bool ?? true
    }
}

struct ContentView: View {

    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let generator = UINotificationFeedbackGenerator()
    
    @State private var isActive = false
    @AppStorage("FirstLaunch") var firstLaunch = true
    @AppStorage("vbmode2") var vbmode2 = true

    @State var screen: CGSize?
    @ObservedObject var model = viewModel()
    @ObservedObject var profile = UserProfile()
    @ObservedObject var soundAlert = SoundAlert()
    @ObservedObject var stopWatchManeger = StopWatchManeger()
    @ObservedObject var stopWatchManeger2 = StopWatchManeger2()
    @State var total : [String]
    @State var laptime : [String]
    @State var finalLap : [String]
    @State var lapNo : [String]
    @State var lapn = 1
    @State var milliSecond = 0
    @State var Second = 0
    @State var minites = 0
    @State var hour = 0
    @State var oldMin = 0
    @State var flag = true
    @State var nowTime : Double
    @State var sheetAlert : Bool = false
    @State var sheetAlertRire : Bool = false
    @State var lap234Purchase : String = "false"
    
    var dateFormat: DateFormatter {
        let dformat = DateFormatter()
        dformat.dateFormat = "yyyy/M/d"
        return dformat
    }

    var body: some View {
        
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [.white, .green]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing:2) {
                if lap234Purchase == "false"
                {                AdView()
                        .frame(width: 320, height: 50)
                }
                Text("Total Time").font(.title)
                if stopWatchManeger.hour > 9 {
                    Text(String(format: "%02d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond))
                        .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.16))
//                        .font(Font.custom("HiraginoSans-W3", size: 60))
                        .font(.system(size: 60, design: .monospaced))
                } else if stopWatchManeger.hour > 0 {
                    Text(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond))
                        .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.17))
//                        .font(Font.custom("HiraginoSans-W3", size: 65))
                        .font(.system(size: 65, design: .monospaced))
                } else {
                    Text(String(format: "%02d:%02d.%02d", stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond))
                        .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.21))
//                        .font(Font.custom("HiraginoSans-W3", size: 80))
                        .font(.system(size: 0, design: .monospaced))
                }
//◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆右利きモード◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
                if profile.mode == true{
                    
                    HStack{
                        VStack{
                            HStack{
                                Button(action: {
                                    self.sheetAlert.toggle()
                                }) {
                                    Image(systemName: "gear")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.black)
                                        .padding(5)
                                }.sheet(isPresented: $sheetAlert) {
                                    SecondView(lap234Purchase: Binding(projectedValue: $lap234Purchase))
                                }
                                Spacer().frame(width: 20)
                                Toggle("", isOn: $profile.mode)
                                    .labelsHidden()
                                Text(profile.mode ? "Left mode" : "Right mode")
                            }
                            Text("現在のLapTime")
                                .font(.title)
                            if stopWatchManeger2.hour > 0 {
                                Text(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond))
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.105))
//                                    .font(Font.custom("HiraginoSans-W3", size: 40))
                                    .font(.system(size: 40, design: .monospaced))
                            } else {
                                Text(String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond))
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.13))
//                                    .font(Font.custom("HiraginoSans-W3", size: 50))
                                    .font(.system(size: 50, design: .monospaced))
                            }
                        }
                        
                        
                        if stopWatchManeger.mode == .stop{
                            VStack{
                                Button(action: {
                                    self.stopWatchManeger.start()
                                    self.stopWatchManeger2.start()
                                    self.soundAlert.start()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }
                                }){
                                    TextView(label : "スタート")
                                }
                                Spacer().frame(height: 10)
                                Button(action: {
                                    self.sheetAlertRire.toggle()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }
                                }){
                                    TextView(label : "履 歴")
                                }.sheet(isPresented: $sheetAlertRire) {
                                    Rireki()
                                }
                            }
                        }
                        if stopWatchManeger.mode == .start{
                            VStack{
                                Button(action: {
                                    self.stopWatchManeger.pause()
                                    self.stopWatchManeger2.pause()
                                    self.soundAlert.pause()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }

                                }){
                                    TextView(label : "一時停止")
                                }
                                Spacer().frame(height: 10)
                                Button(action: {
                                    
                                    if lap234Purchase == "false" {
                                        
                                        if laptime.count < 30 {

                                            if vbmode2 == true{
                                                impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                            }

                                            lapNo.insert(String(lapn), at: 0)
                                            if stopWatchManeger.hour > 0 {
                                                total.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            } else {
                                                total.insert(String(format: "%02d:%02d.%02d", stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            }
                                            if stopWatchManeger2.hour > 0 {
                                                laptime.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            } else {
                                                laptime.insert(String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            }
                                            self.stopWatchManeger2.pause()
                                            self.stopWatchManeger2.stop()
                                            self.stopWatchManeger2.start()
                                            lapn += 1
                                            
                                        }
                                    }
                                    if lap234Purchase == "true" {
                                        if laptime.count < 99 {

                                            if vbmode2 == true{
                                                impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                            }

                                            lapNo.insert(String(lapn), at: 0)
                                            if stopWatchManeger.hour > 0 {
                                                total.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            } else {
                                                total.insert(String(format: "%02d:%02d.%02d", stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            }
                                            if stopWatchManeger2.hour > 0 {
                                                laptime.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            } else {
                                                laptime.insert(String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            }
                                            self.stopWatchManeger2.pause()
                                            self.stopWatchManeger2.stop()
                                            self.stopWatchManeger2.start()
                                            lapn += 1
                                        }}
                                }){
                                    TextView(label : "ラップ")
                                }
                            }
                        }
                        
                        if stopWatchManeger.mode == .pause{
                            VStack{
                                Button(action: {
                                    self.stopWatchManeger.start()
                                    self.stopWatchManeger2.start()
                                    self.soundAlert.start()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }
          }){
                                    TextView(label : "再開")
                                }
                                Spacer().frame(height: 10)
                                Button(action: {
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }

//-書き込み---------------------------書き込み---------------------------書き込み--------------------------
                                    
                                    do {
                                        let realm = try Realm()
                                        try realm.write {
                                            let models = Model()
                                            models.condition = false
                                            models.lapsuu = laptime.count
                                            models.kirokuday = Date()
                                            
                                            if stopWatchManeger.hour > 0 {
                                                models.Rirekitotal = String(format: "%01d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond)
                                            } else {
                                                models.Rirekitotal = String(format: "%02d:%02d.%02d", stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond)
                                            }
                                            if stopWatchManeger2.hour > 0 {
                                                models.finalLap = String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond)
                                            } else {
                                                models.finalLap = String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond)
                                            }
                                            
                                            print("laptime:\(laptime)")
                                            print("models.tickets:\(models.tickets)")
                                            
                                            models.tickets.append(objectsIn: laptime) //Listへの追加処理
                                            models.ticketsTotal.append(objectsIn: total) //Listへの追加処理
                                            realm.add(models) // modelsをRealmデータベースに書き込みます
                                            
                                            print(models)
                                            
                                            // 読み込み処理 ↓
                                            //                                            let targets = realm.objects(Model.self) // RealmデータベースからModelオブジェクトをすべて取得します
                                            //                                            let target = targets.first { $0.id == models.id } // 取得したModelオブジェクト群から、ほしいものを1つ取り出します
                                            //                                            print(target?.tickets.joined(separator: ", ") ?? "空") // ticketsに格納されたラップタイムを表示します
                                            // 読み込み処理 ↑
                                        }
                                        
                                    } catch {
                                        print(error)
                                    }
                                    
                                        if lap234Purchase == "false" {
                                            do {
                                                let realm = try Realm()
                                                let kazu = realm.objects(Model.self).count
                                                print("\(kazu)")
                                                if kazu > 20 {
                                                for i in 20..<kazu {
                                                    try realm.write {
                                                        _ = Model()
                                                        let targets = realm.objects(Model.self)
                                                        let target = targets.first
                                                        realm.delete(target!)
                                                        print("i:\(i)")
                                                    }}}
                                            } catch {
                                                print(error)
                                            }} else {
                                                do {
                                                    let realm = try Realm()
                                                    let kazu = realm.objects(Model.self).count
                                                    print("\(kazu)")
                                                    
                                                    if kazu > 60 {
                                                    for i in 60..<kazu {
                                                        try realm.write {
                                                            _ = Model()
                                                            let targets = realm.objects(Model.self)
                                                            let target = targets.first
                                                            realm.delete(target!)
                                                            print("i:\(i)")
                                                        }}}
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                    
//-書き込み---------------------------書き込み---------------------------書き込み--------------------------
                                    total.removeAll()
                                    laptime.removeAll()
                                    lapNo.removeAll()
                                    lapn = 1
                                    soundAlert.oldMin = 0
                                    stopWatchManeger.minutes = 00
                                    stopWatchManeger.second = 00
                                    stopWatchManeger.milliSecond = 00
                                    stopWatchManeger.hour = 00
                                    stopWatchManeger2.minutes = 00
                                    stopWatchManeger2.second = 00
                                    stopWatchManeger2.milliSecond = 00
                                    stopWatchManeger2.hour = 00
                                    self.stopWatchManeger.stop()
                                    self.stopWatchManeger2.stop()
                                    self.soundAlert.stop()
                                }){
                                    TextView(label : "リセット")
                                }
                            }
                        }
                    }
                }
//◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆左利きモード◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
                if profile.mode == false{
                    
                    HStack{
                        if stopWatchManeger.mode == .stop{
                            VStack{
                                Button(action: {
                                    self.stopWatchManeger.start()
                                    self.stopWatchManeger2.start()
                                    self.soundAlert.start()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }
                                }){
                                    TextView(label : "スタート")
                                }
                                Spacer().frame(height: 10)
                                Button(action: {
                                    self.sheetAlertRire.toggle()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }
                                }){
                                    TextView(label : "履 歴")
                                }.sheet(isPresented: $sheetAlertRire) {
                                    Rireki()
                                }
                            }
                        }
                        
                        if stopWatchManeger.mode == .start{
                            VStack{
                                Button(action: {
                                    self.stopWatchManeger.pause()
                                    self.stopWatchManeger2.pause()
                                    self.soundAlert.pause()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }
                                }){
                                    TextView(label : "一時停止")
                                }
                                Spacer().frame(height: 10)
                                Button(action: {

                                    if lap234Purchase == "false" {
                                        if laptime.count < 30 {

                                            if vbmode2 == true{
                                                impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                            }
                                            lapNo.insert(String(lapn), at: 0)
                                            if stopWatchManeger.hour > 0 {
                                                total.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            } else {
                                                total.insert(String(format: "%02d:%02d.%02d", stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            }
                                            if stopWatchManeger2.hour > 0 {
                                                laptime.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            } else {
                                                laptime.insert(String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            }
                                            self.stopWatchManeger2.pause()
                                            self.stopWatchManeger2.stop()
                                            self.stopWatchManeger2.start()
                                            lapn += 1
                                            
                                        }
                                    }
                                    if lap234Purchase == "true" {
                                        if laptime.count < 99 {

                                            if vbmode2 == true{
                                                impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                            }
                                            lapNo.insert(String(lapn), at: 0)
                                            if stopWatchManeger.hour > 0 {
                                                total.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            } else {
                                                total.insert(String(format: "%02d:%02d.%02d", stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond), at: 0)
                                            }
                                            if stopWatchManeger2.hour > 0 {
                                                laptime.insert(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            } else {
                                                laptime.insert(String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond), at: 0)
                                            }
                                            self.stopWatchManeger2.pause()
                                            self.stopWatchManeger2.stop()
                                            self.stopWatchManeger2.start()
                                            lapn += 1
                                        }}
                                }){
                                    TextView(label : "ラップ")
                                }
                            }
                        }
                        
                        if stopWatchManeger.mode == .pause{
                            VStack{
                                Button(action: {
                                    self.stopWatchManeger.start()
                                    self.stopWatchManeger2.start()
                                    self.soundAlert.start()
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }

                                }){
                                    TextView(label : "再開")
                                }
                                Spacer().frame(height: 10)
                                Button(action: {
                                    
                                    if vbmode2 == true{
                                        impactHeavy.impactOccurred() //■■■■■■■■■■■■■■tapticengine feedback■■■■■■■■■■■■■■
                                    }

//-書き込み---------------------------書き込み---------------------------書き込み--------------------------
                                    
                                    do {
                                        let realm = try Realm()
                                        try realm.write {
                                            let models = Model()
                                            models.condition = false
                                            models.lapsuu = laptime.count
                                            models.kirokuday = Date()
                                            
                                            if stopWatchManeger.hour > 0 {
                                                models.Rirekitotal = String(format: "%01d:%02d:%02d.%02d", stopWatchManeger.hour, stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond)
                                            } else {
                                                models.Rirekitotal = String(format: "%02d:%02d.%02d", stopWatchManeger.minutes, stopWatchManeger.second, stopWatchManeger.milliSecond)
                                            }
                                            if stopWatchManeger2.hour > 0 {
                                                models.finalLap = String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond)
                                            } else {
                                                models.finalLap = String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond)
                                            }
                                            
                                            
                                            print("laptime:\(laptime)")
                                            print("models.tickets:\(models.tickets)")
                                            
                                            models.tickets.append(objectsIn: laptime) //Listへの追加処理
                                            models.ticketsTotal.append(objectsIn: total) //Listへの追加処理
                                            realm.add(models) // modelsをRealmデータベースに書き込みます
                                            
                                            print(models)
                                            
                                            // 読み込み処理 ↓
                                            //                                            let targets = realm.objects(Model.self) // RealmデータベースからModelオブジェクトをすべて取得します
                                            //                                            let target = targets.first { $0.id == models.id } // 取得したModelオブジェクト群から、ほしいものを1つ取り出します
                                            //                                            print(target?.tickets.joined(separator: ", ") ?? "空") // ticketsに格納されたラップタイムを表示します
                                            // 読み込み処理 ↑
                                        }
                                        
                                    } catch {
                                        print(error)
                                    }
                                    
                                    if lap234Purchase == "false" {
                                        do {
                                            let realm = try Realm()
                                            let kazu = realm.objects(Model.self).count
                                            print("\(kazu)")
                                            if kazu > 20 {
                                            for i in 20..<kazu {
                                                try realm.write {
                                                    _ = Model()
                                                    let targets = realm.objects(Model.self)
                                                    let target = targets.first
                                                    realm.delete(target!)
                                                    print("i:\(i)")
                                                }}}
                                        } catch {
                                            print(error)
                                        }} else {
                                            do {
                                                let realm = try Realm()
                                                let kazu = realm.objects(Model.self).count
                                                print("\(kazu)")
                                                
                                                if kazu > 60 {
                                                for i in 60..<kazu {
                                                    try realm.write {
                                                        _ = Model()
                                                        let targets = realm.objects(Model.self)
                                                        let target = targets.first
                                                        realm.delete(target!)
                                                        print("i:\(i)")
                                                    }}}
                                            } catch {
                                                print(error)
                                            }
                                        }
                                
                                    
//-書き込み---------------------------書き込み---------------------------書き込み--------------------------
                                    total.removeAll()
                                    laptime.removeAll()
                                    lapNo.removeAll()
                                    lapn = 1
                                    soundAlert.oldMin = 0
                                    stopWatchManeger.minutes = 00
                                    stopWatchManeger.second = 00
                                    stopWatchManeger.milliSecond = 00
                                    stopWatchManeger.hour = 00
                                    stopWatchManeger2.minutes = 00
                                    stopWatchManeger2.second = 00
                                    stopWatchManeger2.milliSecond = 00
                                    stopWatchManeger2.hour = 00
                                    self.stopWatchManeger.stop()
                                    self.stopWatchManeger2.stop()
                                    self.soundAlert.stop()

                                }){
                                    TextView(label : "リセット")
                                }
                            }
                        }
                        VStack{
                            HStack{
                                Text(profile.mode ? "Left mode" : "Right mode")
                                Toggle("", isOn: $profile.mode)
                                    .labelsHidden()
                                Spacer().frame(width: 20)
                                Button(action: {
                                    self.sheetAlert.toggle()
                                }) {
                                    Image(systemName: "gear")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.black)
                                        .padding(5)
                                    
                                }.sheet(isPresented: $sheetAlert) {
                                    SecondView(lap234Purchase: Binding(projectedValue: $lap234Purchase))
                                }
                            }
                            Text("現在のLapTime")
                                .font(.title)
                            if stopWatchManeger2.hour > 0 {
                                Text(String(format: "%01d:%02d:%02d.%02d", stopWatchManeger2.hour, stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond))
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.105))
//                                    .font(Font.custom("HiraginoSans-W3", size: 40))
                                    .font(.system(size: 40, design: .monospaced))
                            } else {
                                Text(String(format: "%02d:%02d.%02d", stopWatchManeger2.minutes, stopWatchManeger2.second, stopWatchManeger2.milliSecond))
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.13))
//                                    .font(Font.custom("HiraginoSans-W3", size: 50))
                                    .font(.system(size: 50, design: .monospaced))
                            }
                        }
                    }
                }
                
                
//◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆ラップタイム表示◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
                HStack{
                    Text("No.").font(.title2)
                    Spacer()
                    Text("Lap Time").font(.title2)
                    Spacer()
                    Text("Total Time ").font(.title2)
                }
                if stopWatchManeger.hour > 0 {
                    List {
                        ForEach(0 ..< laptime.count, id: \.self) { index in
                            HStack(spacing:2){
                                VStack{
                                    Text("Lap")
                                        .font(.system(size: 15, design: .monospaced))
                                    Text(lapNo[index])
                                        .font(.system(size: 25, design: .monospaced))
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                Spacer()
                                Text(laptime[index])
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.1))
//                                    .font(Font.custom("HiraginoSans-W3", size: 38))
                                    .font(.system(size: 40, design: .monospaced))
                                Spacer()
                                Text("\(total[index])")
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.053))
//                                    .font(Font.custom("HiraginoSans-W3", size: 20))
                                    .font(.system(size: 20, design: .monospaced))
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color("ColorOrange2"))
                            //                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                        }
                    }                .environment(\.defaultMinListRowHeight, 70)
                        .listStyle(PlainListStyle())
                        .font(.largeTitle)
                } else {
                    List {
                        ForEach(0 ..< laptime.count, id: \.self) { index in
                            HStack(spacing:2){
                                VStack{
                                    Text("Lap")
                                        .font(.system(size: 15, design: .monospaced))
                                    Text(lapNo[index])
                                        .font(.system(size: 25, design: .monospaced))
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                Spacer()
                                Text(laptime[index])
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.135))
//                                    .font(Font.custom("HiraginoSans-W3", size: 50))
                                    .font(.system(size: 50, design: .monospaced))
                                Spacer()
                                Text("\(total[index])")
                                    .font(Font.custom("HiraginoSans-W3", size: (screen?.width ?? 100) * 0.053))
//                                    .font(Font.custom("HiraginoSans-W3", size: 20))
                                    .font(.system(size: 20, design: .monospaced))
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color("ColorOrange2"))
                            .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                        }
                    }   .environment(\.defaultMinListRowHeight, 70)
                        .listStyle(PlainListStyle())
                        .font(.largeTitle)
                }
            }
        }
        .fullScreenCover(isPresented: self.$isActive){
            FirstLaunch(isAActive: $isActive, firstLaunch2: $firstLaunch).onDisappear{
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            })
        }
        }
        .onAppear {
            if firstLaunch {
            isActive = true
            }
            screen = UIScreen.main.bounds.size
            let userDefaults = UserDefaults.standard
            if let value2 = userDefaults.string(forKey: "lap234") {
                print("lap234:\(value2)")
                lap234Purchase = value2
            }
        }
        .onChange(of: profile.mode) { mode in
            UserDefaults.standard.set(profile.mode , forKey: "mode")
        }
        .navigationBarTitle("", displayMode: .inline)
    }
  }

