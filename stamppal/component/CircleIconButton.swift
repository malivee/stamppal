import SwiftUI

struct CircleIconButton: View {

    let icon: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(
                    .system(
                        size: 16,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    Color(
                        red: 0.08,
                        green: 0.14,
                        blue: 0.28
                    )
                )
                .frame(
                    width: 44,
                    height: 44
                )
                .background(
                    Color.white
                )
                .clipShape(
                    Circle()
                )
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 16) {
        CircleIconButton(
            icon: "house.fill"
        )

        CircleIconButton(
            icon: "questionmark"
        )
    }
    .padding()
    .background(
        Color(
            red: 0.88,
            green: 0.94,
            blue: 1.0
        )
    )
}
