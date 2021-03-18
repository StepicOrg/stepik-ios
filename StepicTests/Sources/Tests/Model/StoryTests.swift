@testable
import Stepic

import Nimble
import Quick
import SwiftyJSON

class StorySpec: QuickSpec {
    override func spec() {
        describe("Story") {
            describe("JSON parsing") {
                it("successfully parses story with parts of type text") {
                    // Given
                    let json = TestData.textStoryTemplate

                    // When
                    let story = Story(json: json)

                    // Then
                    expect(story.id) == 47
                    expect(story.coverPath) == "https://stepik.org/media/stories/7206a18c8b46cef7db253010ee391fe8997dbbc2.png"
                    expect(story.title) == "Экономика"
                    expect(story.position) == 968
                    expect(story.parts.count) == 2

                    let firstStoryPart = story.parts[0] as! TextStoryPart
                    expect(firstStoryPart.type) == .text
                    expect(firstStoryPart.position) == 0
                    expect(firstStoryPart.duration) == 10
                    expect(firstStoryPart.storyID) == 47
                    expect(firstStoryPart.imagePath) == "https://ucarecdn.com/0d9a1830-2e43-4140-b2a0-c54a69b2688e/"
                    expect(firstStoryPart.text!.title) == "Экономика"
                    expect(firstStoryPart.text!.text) == "В экономических процессах полезно разбираться не только тем, кто работает в этой сфере!"
                    expect(firstStoryPart.text!.textColor) == UIColor(hex6: 0xfffff0)
                    expect(firstStoryPart.text!.backgroundStyle) == .dark
                    expect(firstStoryPart.button).to(beNil())

                    let secondStoryPart = story.parts[1] as! TextStoryPart
                    expect(secondStoryPart.type) == .text
                    expect(secondStoryPart.position) == 1
                    expect(secondStoryPart.duration) == 15
                    expect(secondStoryPart.storyID) == 47
                    expect(secondStoryPart.imagePath) == "https://ucarecdn.com/de5af33e-6d63-474f-98d0-7bb1ab3aa5fa/"
                    expect(secondStoryPart.text!.title) == "Микроэкономика: базовый курс. Теория спроса и предложения"
                    expect(secondStoryPart.text!.text) == "Новый курс на Stepik, который познакомит вас с основами микроэкономики. Хорошее введение для тех, кто только начинает разбираться!"
                    expect(secondStoryPart.text!.textColor) == UIColor(hex6: 0xfffff0)
                    expect(secondStoryPart.text!.backgroundStyle) == .dark
                    expect(secondStoryPart.button!.title) == "Начать учиться"
                    expect(secondStoryPart.button!.urlPath) == "https://stepik.org/course/58626/promo"
                    expect(secondStoryPart.button!.backgroundColor) == UIColor(hex6: 0x6C7BDF)
                    expect(secondStoryPart.button!.titleColor) == UIColor(hex6: 0xFFFFFF)
                }

                it("successfully parses story with parts of type feedback") {
                    // Given
                    let json = TestData.feedbackStoryTemplate

                    // When
                    let story = Story(json: json)

                    // Then
                    expect(story.id) == 32
                    expect(story.coverPath) == "http://stepik.org/media/stories/49d002fba3b5c419a87f557fda55fab235edfee9.jpg"
                    expect(story.title) == "Feedback Story"
                    expect(story.position) == 777
                    expect(story.parts.count) == 2
                    expect(story.parts[0].type) == .text

                    let feedbackStoryPart = story.parts[1] as! FeedbackStoryPart
                    expect(feedbackStoryPart.type) == .feedback
                    expect(feedbackStoryPart.position) == 1
                    expect(feedbackStoryPart.duration) == 20
                    expect(feedbackStoryPart.storyID) == 32
                    expect(feedbackStoryPart.imagePath) == "https://ucarecdn.com/de5af33e-6d63-474f-98d0-7bb1ab3aa5fa/"
                    // Text
                    expect(feedbackStoryPart.text!.title) == "Микроэкономика: базовый курс. Теория спроса и предложения"
                    expect(feedbackStoryPart.text!.textColor) == UIColor(hex6: 0xFFFFFF)
                    // Button
                    expect(feedbackStoryPart.button!.title) == "Send feedback"
                    expect(feedbackStoryPart.button!.backgroundColor) == UIColor(hex6: 0x6C7BDF)
                    expect(feedbackStoryPart.button!.titleColor) == UIColor(hex6: 0xFFFFFF)
                    expect(feedbackStoryPart.button!.feedbackTitle) == "Фидбек отправлен"
                    // Feedback
                    expect(feedbackStoryPart.feedback!.backgroundColor) == UIColor(hex6: 0xFFFFFF)
                    expect(feedbackStoryPart.feedback!.text) == "We need your feedback"
                    expect(feedbackStoryPart.feedback!.textColor) == UIColor(hex6: 0x000000)
                    expect(feedbackStoryPart.feedback!.iconStyle) == .light
                    expect(feedbackStoryPart.feedback!.inputBackgroundColor) == UIColor(hex6: 0x6C7BDF)
                    expect(feedbackStoryPart.feedback!.inputTextColor) == UIColor(hex6: 0xfffff0)
                    expect(feedbackStoryPart.feedback!.placeholderText) == "Type your feedback..."
                    expect(feedbackStoryPart.feedback!.placeholderTextColor) == UIColor(hex6: 0x5f5ef7)
                }
            }
        }
    }
}
