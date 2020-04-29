import StandardCyborgFusion
import StandardCyborgUI
import UIKit
import Moya

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}

struct PrintJob: Decodable {
    let id: Int
    let USDZdata: String
}

class ViewController: UIViewController, ScanningViewControllerDelegate {
    
    // MARK: - IBOutlets and IBActions
    
    @IBOutlet private weak var showScanButton: UIButton!
    let networkProvider = MoyaProvider<PrintService>()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var id :Int?
    var USDZstr :String?
    
    @IBAction private func startScanning(_ sender: UIButton) {
        #if targetEnvironment(simulator)
        let alert = UIAlertController(title: "Simulator Unsupported", message: "There is no depth camera available on the iOS Simulator. Please build and run on an iOS device with TrueDepth", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        #else
        let scanningVC = ScanningViewController()
        scanningVC.delegate = self
        scanningVC.modalPresentationStyle = .fullScreen
        present(scanningVC, animated: true)
        #endif
    }
    
    @IBAction private func showScan(_ sender: UIButton) {
        guard let pointCloud = lastScanPointCloud else { return }
        
        pointCloudPreviewVC.pointCloud = pointCloud
        pointCloudPreviewVC.leftButton.setTitle("Delete", for: UIControl.State.normal)
        pointCloudPreviewVC.rightButton.setTitle("Dismiss", for: UIControl.State.normal)
        pointCloudPreviewVC.leftButton.backgroundColor = UIColor(named: "DestructiveAction")
        pointCloudPreviewVC.rightButton.backgroundColor = UIColor(named: "DefaultAction")
        pointCloudPreviewVC.modalPresentationStyle = .fullScreen
        
        present(pointCloudPreviewVC, animated: true)
    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        super.loadView()
        
        showScanButton.layer.borderColor = UIColor.white.cgColor
        showScanButton.imageView?.contentMode = .scaleAspectFill
    }
    
    override func viewDidLoad() {
        loadScan()
    }
    
    // MARK: - ScanningViewControllerDelegate
    
    func scanningViewControllerDidCancel(_ controller: ScanningViewController) {
        dismiss(animated: true)
    }
    
    func scanningViewController(_ controller: ScanningViewController, didScan pointCloud: SCPointCloud) {
        pointCloudPreviewVC.pointCloud = pointCloud
        pointCloudPreviewVC.leftButton.setTitle("Rescan", for: UIControl.State.normal)
        pointCloudPreviewVC.rightButton.setTitle("Print!", for: UIControl.State.normal)
        pointCloudPreviewVC.leftButton.backgroundColor = UIColor(named: "DestructiveAction")
        pointCloudPreviewVC.rightButton.backgroundColor = UIColor(named: "SaveAction")
        
        controller.present(pointCloudPreviewVC, animated: false)
    }
    
    @objc private func previewLeftButtonTapped(_ sender: UIButton) {
        let isExistingScan = pointCloudPreviewVC.pointCloud == lastScanPointCloud
        
        if isExistingScan {
            // Delete
            deleteScan()
            dismiss(animated: true)
        } else {
            // Retake
            dismiss(animated: false)
        }
    }
    
    @objc private func previewRightButtonTapped(_ sender: UIButton) {
        let isExistingScan = pointCloudPreviewVC.pointCloud == lastScanPointCloud
        
        if isExistingScan {
            // Dismiss
            dismiss(animated: true)
        } else {
            // Save
            saveScan(pointCloud: pointCloudPreviewVC.pointCloud!, thumbnail: pointCloudPreviewVC.renderedPointCloudImage)
            
        }
    }
    
    // MARK: - Private
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private lazy var pointCloudPreviewVC: PointCloudPreviewViewController = {
        let previewVC: PointCloudPreviewViewController = PointCloudPreviewViewController()
        previewVC.leftButton.addTarget(self, action: #selector(previewLeftButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        previewVC.rightButton.addTarget(self, action: #selector(previewRightButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        return previewVC
    }()
    
    private var lastScanPointCloud: SCPointCloud?
    private var lastScanDate: Date?
    private var lastScanThumbnail: UIImage?
    
    private lazy var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private lazy var scanPLYURL = documentsURL.appendingPathComponent("Scan.ply")
    private lazy var scanThumbnailURL = documentsURL.appendingPathComponent("Scan.jpeg")
    
    // MARK: -
    
    private func updateUI() {
        if lastScanThumbnail == nil {
            showScanButton.layer.borderWidth = 0
            showScanButton.setTitle("no scan yet", for: UIControl.State.normal)
        } else {
            showScanButton.layer.borderWidth = 1
            showScanButton.setTitle(nil, for: UIControl.State.normal)
        }
        
        showScanButton.setImage(lastScanThumbnail, for: UIControl.State.normal)
    }
    
    private func loadScan() {
        let scanPLYPath = scanPLYURL.path
        let scanThumbnailPath = scanThumbnailURL.path
        let fileManager = FileManager.default
        
        if
            fileManager.fileExists(atPath: scanPLYPath),
            let plyAttributes = try? fileManager.attributesOfItem(atPath: scanPLYPath),
            let dateCreated = plyAttributes[FileAttributeKey.creationDate] as? Date,
            let pointCloud = SCPointCloud(plyPath: scanPLYPath),
            pointCloud.pointCount > 0
        {
            lastScanPointCloud = pointCloud
            lastScanDate = dateCreated
            lastScanThumbnail = UIImage(contentsOfFile: scanThumbnailPath)
        }
        
        updateUI()
    }
    
    private func saveScan(pointCloud: SCPointCloud, thumbnail: UIImage?) {
        pointCloud.writeToPLY(atPath: scanPLYURL.path)
        print(scanPLYURL.path)
        var binaryData:[UInt8] = []
        
        if  let thumbnail = thumbnail,
            let jpegData = thumbnail.jpegData(compressionQuality: 0.8)
        {
            try? jpegData.write(to: scanThumbnailURL)
        }
        
        lastScanPointCloud = pointCloud
        lastScanThumbnail = thumbnail
        lastScanDate = Date()
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        print(scanPLYURL.path)
        
        //Ascii
        do {
            let text = try String(contentsOf: scanPLYURL, encoding: .utf8)
            // Split the file into separate lines
            networkProvider.request(.sendPLY(named: text.toBase64()!)) { (result) in
                switch result {
                case .success(let response):
                    let responseString = String(data: response.data, encoding: .utf8)
                    func convertToDictionary(text: String) -> [String: Any]? {
                        if let data = text.data(using: .utf8) {
                            do {
                                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        return nil
                    }

                    let dict = convertToDictionary(text: responseString!)
                    self.id = dict!["id"] as! Int
                    self.USDZstr = dict!["USDZdata"] as! String
                    self.PreviewScan()
                    
                case .failure(let error):
                    print(error)
                }
            }

        }
        catch {
            print("hello")

        }
        deleteScan()
        print("PK")
        let alert = UIAlertController(title: "Processing...",
                                      message: "Your object is currently converting",
                                      preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func Write(writefile: String,binaryData: [UInt8]) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let fileURL = dir!.appendingPathComponent(writefile)

        print(fileURL)
        
        do {
            let contents = Data(bytes: binaryData)

            try contents.write(to: fileURL)
            print("written")

        }
        catch {
            print("hello")

        }
        
    }
    
    private func topMostController() -> UIViewController {
    var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    private func PreviewScan() {
        networkProvider.request(.printJob(named: self.id!)) { (result) in
        switch result {
        case .success(let response):
            let alert = UIAlertController(title: "Printed!",
                                          message: "Your object is currently Printing",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.dismiss(animated: true)

            
            
            
            
        case .failure(let error):
            print(error)
        }
        }
    }
    
    private func deleteScan() {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: scanPLYURL.path) {
            try? fileManager.removeItem(at: scanPLYURL)
        }
        
        if fileManager.fileExists(atPath: scanThumbnailURL.path) {
            try? fileManager.removeItem(at: scanThumbnailURL)
        }
        
        lastScanPointCloud = nil
        lastScanThumbnail = nil
        lastScanDate = nil
        
        updateUI()
    }
    
}

