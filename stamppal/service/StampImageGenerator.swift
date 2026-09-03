import UIKit
import ImagePlayground

@available(iOS 26.0, *)
@MainActor
final class StampImageGenerator {

    func generateImage(
        prompt: String
    ) async throws -> UIImage {

        let cleanedPrompt = prompt
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedPrompt.isEmpty else {
            throw StampGenerationError.emptyMessage
        }

        print("================================")
        print("🎨 IMAGE GENERATION STARTED")
        print("================================")

        print("📝 Prompt:")
        print(cleanedPrompt)

        // Create ImageCreator.
        // This does NOT present Image Playground UI.
        let creator = try await ImageCreator()

        let availableStyles = creator.availableStyles

        print("🎨 Available styles:")

        for style in availableStyles {
            print("   \(style)")
        }

        guard !availableStyles.isEmpty else {
            print("❌ No styles available.")
            throw StampGenerationError.noAvailableStyle
        }

        // Prefer illustration for a postage stamp.
        let style =
            availableStyles.first(where: {
                $0 == .illustration
            })
            ??
            availableStyles.first(where: {
                $0 == .sketch
            })
            ??
            availableStyles.first!

        print("🎨 Selected style:")
        print(style)

        let concepts: [ImagePlaygroundConcept] = [
            .text(cleanedPrompt)
        ]

        print("🚀 Requesting image from ImageCreator...")

        let images = creator.images(
            for: concepts,
            style: style,
            limit: 1
        )

        do {

            for try await generatedImage in images {

                print("================================")
                print("✅ IMAGE GENERATED SUCCESSFULLY")
                print("================================")

                return UIImage(
                    cgImage: generatedImage.cgImage
                )
            }

        } catch {

            print("================================")
            print("❌ IMAGE GENERATION FAILED")
            print("================================")

            print("Error:")
            print(error)

            print("Localized:")
            print(error.localizedDescription)

            throw error
        }

        print("❌ ImageCreator finished without an image.")

        throw StampGenerationError.noImageGenerated
    }
}
