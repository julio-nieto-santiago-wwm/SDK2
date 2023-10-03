import SwiftUI

public struct SDK2 {
    
    class __ {}
    
    public class FontLoader {
        static public func loadFont() {
            if let fontUrl = Bundle(for: FontLoader.self).url(forResource: "Montserrat-Regular", withExtension: "ttf"),
               let dataProvider = CGDataProvider(url: fontUrl as CFURL),
               let newFont = CGFont(dataProvider) {
                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(newFont, &error)
                    {
                        print("Error loading Font!")
                } else {
                    print("Loaded font")
                }
            } else {
                assertionFailure("Error loading font")
            }
        }
    }
    
    static var SDK2Bundle: Bundle { return Bundle(for: SDK2.__.self) }
    
    public private(set) var text = "Hello, World!"

    public init() {
        FontLoader.loadFont()
    }
    
    public func showTimely() -> some View {
        Timely()
    }
    
    public static func registerFonts() {
       Montserrat.allCases.forEach {
           registerFont(bundle: SDK2Bundle, fontName: $0.rawValue, fontExtension: "ttf")
       }
    }

    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {

        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
                  fatalError("Couldn't create font from data")
        }

        var error: Unmanaged<CFError>?

        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}

struct VehicleInformation: View {
    var body: some View {
        VStack {
            HStack (spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Seat Mii")
                        .font(Font.custom("Montserrat", size: 24))
                    License()
                }
                Spacer()
                Image("FIAT_App_lat_izdo", bundle: SDK2.SDK2Bundle)
//                Image("FIAT_App_lat_izdo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150.0)
            }
            Separator()
        }
        .padding(.top, -30)
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

struct License: View {
    var body: some View {
        Text("1111 JNS")
            .font(Font.custom("Montserrat", size: 16))
            .foregroundColor(.black.opacity(0.6))
            .padding(2)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
    }
}

struct Separator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .stroke(.gray.opacity(0.5), lineWidth: 1)
            .frame(height: 0.5)
    }
}

struct InfoVehicle: View {
    var body: some View {
        HStack {
            
        }
    }
}

public struct Timely: View {
    @State public var showingAlert = false
    @State private var bottomSheetShown = false

    @ViewBuilder
    public var body: some View {
        GeometryReader { geometry in
            Color.clear
            ZStack {
                BottomSheetView(
                    isOpen: $bottomSheetShown,
                    maxHeight: geometry.size.height * 0.7
                ) {
                    VehicleInformation()
                }.edgesIgnoringSafeArea(.all)
                if showingAlert {
                    GenericAlert(titleAlert: "Estábamos en la UVI", subTitleAlert: "Nadie daba un duro por nosotros", firstButton: GenericAlertAction(title: "OK", style: .lightBlue), close: {showingAlert.toggle()})
                }
            }
        }
    }
    
    private func accion() {
        showingAlert.toggle()
    }
    
    fileprivate enum Constants {
        static let radius: CGFloat = 16
        static let indicatorHeight: CGFloat = 6
        static let indicatorWidth: CGFloat = 60
        static let snapRatio: CGFloat = 0.25
        static let minHeightRatio: CGFloat = 0.3
    }

    struct BottomSheetView<Content: View>: View {
        @Binding var isOpen: Bool

        let maxHeight: CGFloat
        let minHeight: CGFloat
        let content: Content

        @GestureState private var translation: CGFloat = 0

        private var offset: CGFloat {
            isOpen ? 0 : maxHeight - minHeight
        }

        private var indicator: some View {
            RoundedRectangle(cornerRadius: Constants.radius)
                .fill(Color.secondary.opacity(0.3))
                .frame(
                    width: Constants.indicatorWidth,
                    height: Constants.indicatorHeight
            ).onTapGesture {
                self.isOpen.toggle()
            }
            .padding()
        }

        init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
            self.minHeight = maxHeight * Constants.minHeightRatio
            self.maxHeight = maxHeight
            self.content = content()
            self._isOpen = isOpen
        }

        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    self.indicator
                    self.content
                }
                .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(Constants.radius)
                .frame(height: geometry.size.height, alignment: .bottom)
                .offset(y: max(self.offset + self.translation, 0))
                .animation(.interactiveSpring())
                .gesture(
                    DragGesture().updating(self.$translation) { value, state, _ in
                        state = value.translation.height
                    }.onEnded { value in
                        let snapDistance = self.maxHeight * Constants.snapRatio
                        guard abs(value.translation.height) > snapDistance else {
                            return
                        }
                        self.isOpen = value.translation.height < 0
                    }
                )
            }
        }
    }
}

struct GenericAlertAction: Hashable {
    enum Style {
        case lightBlue
        case navyBlue
    }
    
    static func == (lhs: GenericAlertAction, rhs: GenericAlertAction) -> Bool {
        lhs.title == rhs.title
    }
    
    var title: String
    var style: Style
    var action: (() -> Void)?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

struct GenericAlert: View {
    var titleAlert: String
    var subTitleAlert: String
    var firstButton: GenericAlertAction
    var moreButtons: [GenericAlertAction]?
    var showCross: Bool?
    var closeButton: Bool?
    var okButton: Bool?
    var close: (() -> Void)

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .circular)
                        .fill(Color.white)
                    VStack {
                        if let showCross, showCross {
                            HStack {
                                Spacer()
                                Button {
                                    close()
                                } label: {
                                    Image("ic_close_semibold").padding()
                                }
                                .padding(.trailing, -10)
                                .padding(.top, -10)
                            }
                        }
                        Text(titleAlert)
//                            .font(Font(UIFont.myBoldSystemFont(ofSize: 20)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0, green: 0.22, blue: 0.58))
                            .padding(.top, showCross ?? false ? -15 : 10)
                            .padding(.bottom, 10)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(subTitleAlert)
                            .font(Font.custom("Outfit", size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.47, green: 0.48, blue: 0.55))
                            .padding(.bottom, 20)
                        drawCapsuleButton(alertAction: firstButton)
                        if let moreButtons {
                            ForEach(moreButtons, id: \.self) { button in
                                drawCapsuleButton(alertAction: button)
                            }
                        }
                        Spacer()
                        if let closeButton, closeButton {
                            CapsuleButton(title: "Cerrar", backgroundColor: .red, textColor: .white) {
                                close()
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: 380, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.clear)
                .padding()
                .cornerRadius(20)
                Spacer()
            }
        }
    }
    
    private func drawCapsuleButton(alertAction: GenericAlertAction) -> CapsuleButton {
        CapsuleButton(title: alertAction.title, backgroundColor: alertAction.style == .navyBlue ? .blue : .green, textColor: alertAction.style == .navyBlue ? .white : .blue) {
            if let action = alertAction.action {
                action()
            } else {
                close()
            }
        }
    }
    
    struct CapsuleButton: View {
        var title: String
        var backgroundColor: Color
        var textColor: Color
        var isActive: Bool = true
        var action: () -> Void
        var closeButton: Bool = false

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isActive ? textColor : Color.black.opacity(0.9))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isActive ? backgroundColor : Color.yellow)
                    .cornerRadius(25)
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(isActive ? 1.0 : 0.5)
            .disabled(!isActive)
        }
    }
}

struct Previews_SDK2_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
