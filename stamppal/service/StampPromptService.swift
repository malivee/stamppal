//
//  StampPromptService.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@MainActor
final class StampPromptService {

    func generatePrompt(
        from message: String
    ) async throws -> String {

        let cleanedMessage =
            message.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedMessage.isEmpty else {
            throw StampGenerationError.emptyMessage
        }

        print("========================================")
        print("STAMP PROMPT REQUEST")
        print("========================================")

        let instructions = """
        Create an English visual concept for a
        commemorative postage stamp based on the
        user's postcard message.

        The final image must NOT contain:

        - people
        - human figures
        - human faces
        - portraits
        - soldiers
        - historical figures
        - children
        - weapons
        - violence
        - blood
        - gore
        - combat

        Represent the message using visual elements
        such as:

        - objects
        - landscapes
        - architecture
        - vehicles
        - landmarks
        - flowers
        - animals
        - symbolic objects
        - historical environments

        The result should look like a beautiful
        commemorative postage stamp.

        Include:

        - vintage postage stamp aesthetic
        - decorative perforated border
        - detailed engraved illustration
        - aged paper texture
        - nostalgic mood
        - respectful composition

        Return ONLY the English visual description.
        """

        print(instructions)

        let session =
            LanguageModelSession(
                instructions: instructions
            )

        let response =
            try await session.respond(
                to: cleanedMessage
            )

        let visualPrompt =
            response.content
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        guard !visualPrompt.isEmpty else {
            throw StampGenerationError.noImageGenerated
        }

        print("========================================")
        print("STAMP VISUAL DESCRIPTION")
        print("========================================")

        print(visualPrompt)

        print("========================================")
        print("✅ Generated visual prompt:")
        print("========================================")

        print(visualPrompt)

        return visualPrompt
    }
}

// MARK: - Stamp Generation Errors

enum StampGenerationError: LocalizedError {

    case emptyMessage

    case emptyResponse

    case foundationModelUnavailable

    case englishLocaleUnavailable

    case noAvailableStyle

    case noImageGenerated
    
    case viewControllerNotFound

    var errorDescription: String? {

        switch self {

        case .emptyMessage:

            return """
            Please write a postcard message first.
            """

        case .emptyResponse:

            return """
            Foundation Models returned an empty response.
            """

        case .foundationModelUnavailable:

            return """
            Foundation Models is currently unavailable.

            Please make sure Apple Intelligence
            is enabled and the model is ready.
            """

        case .englishLocaleUnavailable:

            return """
            English is not supported by the
            Foundation Model on this device.
            """

        case .noAvailableStyle:

            return """
            No image generation style is available.
            """

        case .noImageGenerated:

            return """
            No image was generated.
            """
            
        case .viewControllerNotFound:
            return "Unable to open Image Playground."
        }
    }
}
