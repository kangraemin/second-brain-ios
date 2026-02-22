import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        URLExtractor.extractURL(from: extensionContext?.inputItems) { [weak self] url in
            if let url {
                do {
                    let container = try ShareExtensionSaver.makeContainer()
                    try ShareExtensionSaver.save(url: url, container: container)
                } catch {
                    // 저장 실패 시에도 Extension 종료
                }
            }
            // TODO: Step 3.3에서 토스트 피드백 구현
            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}
