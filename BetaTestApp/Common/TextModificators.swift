import Foundation
import SwiftUI

// Test fonts
extension View {
    func headerFont() -> some View {
        modifier(HeaderFont())
    }
    func titleFont() -> some View {
        modifier(TitleFont())
    }
    func subtitleFont() -> some View {
        modifier(SubtitleFont())
    }
    func articleFont() -> some View {
        modifier(ArticleFont())
    }
    func articleBoldFont() -> some View {
        modifier(ArticleBoldFont())
    }
    func lightFont() -> some View {
        modifier(LightFont())
    }
}

struct HeaderFont: ViewModifier {
    private let color = Color("TextColor")
    private let font = Font.custom("Nunito-ExtraBold", size: 25)
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

struct TitleFont: ViewModifier {
    private let color = Color("TextColor")
    private let font = Font.custom("Nunito-Bold", size: 21)
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

struct SubtitleFont: ViewModifier {
    private let color = Color("TextColor")
    private let font = Font.custom("Nunito-ExtraBold", size: 19)
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

struct ArticleFont: ViewModifier {
    private let color = Color("TextColor")
    private let font = Font.custom("Nunito-Regular", size: 15)
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

struct ArticleBoldFont: ViewModifier {
    private let color = Color("TextColor")
    private let font = Font.custom("Nunito-ExtraBold", size: 15)
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

struct LightFont: ViewModifier {
    private let color = Color("TextColor")
    private let font = Font.custom("Nunito-Light", size: 13)
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

struct Fonts_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Header Font").headerFont()
                Text("Title Font").titleFont()
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Subtitle Font").subtitleFont()
                Text("Article bold Font").articleBoldFont()
                Text("Article Font").articleFont()
            }
            Text("Light Font").lightFont()
        }
    }
}
