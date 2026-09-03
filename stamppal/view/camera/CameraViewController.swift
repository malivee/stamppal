//
//  CameraViewController.swift
//  stamppal
//
//  Camera screen
//

import UIKit
import AVFoundation
import PhotosUI

final class CameraViewController: UIViewController {

    // MARK: - Camera

    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()

    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var currentCameraInput: AVCaptureDeviceInput?

    private var currentCameraPosition: AVCaptureDevice.Position = .back

    private var isCameraConfigured = false
    private var isCameraStarting = false

    // MARK: - Callback

    var onImageSelected: ((UIImage) -> Void)?

    // MARK: - UI

    private let closeButton = UIButton(type: .system)
    private let captureButton = UIButton(type: .system)
    private let switchCameraButton = UIButton(type: .system)
    private let galleryButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupUI()
        setupPreviewLayer()
        requestCameraPermission()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer?.frame = view.bounds

        layoutCameraControls()

        updateCameraOrientation()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)

        guard AVCaptureDevice.authorizationStatus(
            for: .video
        ) == .authorized else {
            return
        }

        startCamera()
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)

        stopCamera()
    }

    // MARK: - UI Setup

    private func setupUI() {

        // ==================================================
        // CLOSE BUTTON
        // ==================================================

        closeButton.setImage(
            UIImage(systemName: "xmark"),
            for: .normal
        )

        closeButton.tintColor = .white

        closeButton.backgroundColor =
            UIColor.black.withAlphaComponent(0.35)

        closeButton.layer.cornerRadius = 24

        closeButton.addTarget(
            self,
            action: #selector(closeTapped),
            for: .touchUpInside
        )

        view.addSubview(closeButton)

        // ==================================================
        // CAPTURE BUTTON
        // ==================================================

        captureButton.backgroundColor = .white

        captureButton.layer.cornerRadius = 38

        captureButton.layer.borderWidth = 5

        captureButton.layer.borderColor =
            UIColor.white.withAlphaComponent(0.5).cgColor

        captureButton.addTarget(
            self,
            action: #selector(capturePhoto),
            for: .touchUpInside
        )

        view.addSubview(captureButton)

        // ==================================================
        // SWITCH CAMERA BUTTON
        // ==================================================

        switchCameraButton.setImage(
            UIImage(
                systemName: "camera.rotate"
            ),
            for: .normal
        )

        switchCameraButton.tintColor = .white

        switchCameraButton.backgroundColor =
            UIColor.black.withAlphaComponent(0.35)

        switchCameraButton.layer.cornerRadius = 28

        switchCameraButton.addTarget(
            self,
            action: #selector(switchCamera),
            for: .touchUpInside
        )

        view.addSubview(switchCameraButton)

        // ==================================================
        // GALLERY BUTTON
        // ==================================================

        galleryButton.setImage(
            UIImage(
                systemName: "photo.on.rectangle"
            ),
            for: .normal
        )

        galleryButton.tintColor = .white

        galleryButton.backgroundColor =
            UIColor.black.withAlphaComponent(0.35)

        galleryButton.layer.cornerRadius = 28

        galleryButton.addTarget(
            self,
            action: #selector(openGallery),
            for: .touchUpInside
        )

        view.addSubview(galleryButton)
    }

    // MARK: - Camera Control Layout

    private func layoutCameraControls() {

        let width = view.bounds.width
        let height = view.bounds.height

        // ==================================================
        // CLOSE
        // ==================================================

        closeButton.frame = CGRect(
            x: 24,
            y: 24,
            width: 48,
            height: 48
        )

        // ==================================================
        // CAPTURE
        // ==================================================

        captureButton.frame = CGRect(
            x: (width - 76) / 2,
            y: height - 100,
            width: 76,
            height: 76
        )

        // ==================================================
        // GALLERY
        // ==================================================

        galleryButton.frame = CGRect(
            x: width / 2 - 130,
            y: height - 90,
            width: 56,
            height: 56
        )

        // ==================================================
        // SWITCH CAMERA
        // ==================================================

        switchCameraButton.frame = CGRect(
            x: width / 2 + 74,
            y: height - 90,
            width: 56,
            height: 56
        )
    }

    // MARK: - Preview

    private func setupPreviewLayer() {

        let preview =
            AVCaptureVideoPreviewLayer(
                session: captureSession
            )

        preview.videoGravity =
            .resizeAspectFill

        preview.frame =
            view.bounds

        view.layer.insertSublayer(
            preview,
            at: 0
        )

        previewLayer = preview
    }

    // MARK: - Permission

    private func requestCameraPermission() {

        switch AVCaptureDevice.authorizationStatus(
            for: .video
        ) {

        case .authorized:

            setupCamera()

        case .notDetermined:

            AVCaptureDevice.requestAccess(
                for: .video
            ) { [weak self] granted in

                guard let self else {
                    return
                }

                DispatchQueue.main.async {

                    if granted {

                        self.setupCamera()

                    } else {

                        self.showCameraPermissionAlert()
                    }
                }
            }

        case .denied,
             .restricted:

            showCameraPermissionAlert()

        @unknown default:

            showCameraPermissionAlert()
        }
    }

    // MARK: - Camera Setup

    private func setupCamera() {

        guard !isCameraConfigured else {
            return
        }

        captureSession.beginConfiguration()

        captureSession.sessionPreset = .photo

        defer {
            captureSession.commitConfiguration()
        }

        // ==================================================
        // CAMERA DEVICE
        // ==================================================

        guard let camera =
                AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: currentCameraPosition
                )
        else {

            print("Unable to find camera.")

            return
        }

        do {

            // ==================================================
            // INPUT
            // ==================================================

            let input =
                try AVCaptureDeviceInput(
                    device: camera
                )

            guard captureSession.canAddInput(
                input
            ) else {

                print(
                    "Unable to add camera input."
                )

                return
            }

            captureSession.addInput(
                input
            )

            currentCameraInput =
                input

            // ==================================================
            // OUTPUT
            // ==================================================

            guard captureSession.canAddOutput(
                photoOutput
            ) else {

                print(
                    "Unable to add photo output."
                )

                return
            }

            captureSession.addOutput(
                photoOutput
            )

            // ==================================================
            // HIGH RESOLUTION
            // ==================================================

            if photoOutput.isHighResolutionCaptureEnabled {

                photoOutput.isHighResolutionCaptureEnabled =
                    true
            }

            isCameraConfigured = true

            DispatchQueue.main.async { [weak self] in

                self?.updateCameraOrientation()
            }

        } catch {

            print(
                "Camera setup error:",
                error.localizedDescription
            )
        }
    }

    // MARK: - Start Camera

    private func startCamera() {

        guard isCameraConfigured else {

            setupCamera()

            return
        }

        guard !captureSession.isRunning else {
            return
        }

        guard !isCameraStarting else {
            return
        }

        isCameraStarting = true

        DispatchQueue.global(
            qos: .userInitiated
        ).async { [weak self] in

            guard let self else {
                return
            }

            self.captureSession.startRunning()

            DispatchQueue.main.async {

                self.isCameraStarting = false

                self.updateCameraOrientation()
            }
        }
    }

    // MARK: - Stop Camera

    private func stopCamera() {

        guard captureSession.isRunning else {
            return
        }

        DispatchQueue.global(
            qos: .userInitiated
        ).async { [weak self] in

            self?.captureSession.stopRunning()
        }
    }

    // MARK: - Orientation

    private func updateCameraOrientation() {

        let orientation =
            currentVideoOrientation()

        // ==================================================
        // PREVIEW ORIENTATION
        // ==================================================

        if let previewConnection =
            previewLayer?.connection {

            if previewConnection.isVideoOrientationSupported {

                previewConnection.videoOrientation =
                    orientation
            }

            if previewConnection.isVideoMirroringSupported {

                // IMPORTANT:
                //
                // Disable automatic mirroring BEFORE
                // setting isVideoMirrored.
                //

                previewConnection
                    .automaticallyAdjustsVideoMirroring =
                    false

                previewConnection.isVideoMirrored =
                    currentCameraPosition == .front
            }
        }

        // ==================================================
        // PHOTO OUTPUT ORIENTATION
        // ==================================================

        if let photoConnection =
            photoOutput.connection(
                with: .video
            ) {

            if photoConnection.isVideoOrientationSupported {

                photoConnection.videoOrientation =
                    orientation
            }

            if photoConnection.isVideoMirroringSupported {

                photoConnection
                    .automaticallyAdjustsVideoMirroring =
                    false

                photoConnection.isVideoMirrored =
                    currentCameraPosition == .front
            }
        }
    }

    // MARK: - Current Orientation

    private func currentVideoOrientation()
        -> AVCaptureVideoOrientation {

        // ==================================================
        // LANDSCAPE
        // ==================================================
        //
        // The camera screen is designed for landscape.
        //
        // If your device is held with the USB-C / Lightning
        // port on the RIGHT:
        //
        //      return .landscapeRight
        //
        // If it is on the LEFT:
        //
        //      return .landscapeLeft
        //
        // ==================================================

        return .landscapeRight
    }

    // MARK: - Capture Photo

    @objc
    private func capturePhoto() {

        guard captureSession.isRunning else {
            return
        }

        // ==================================================
        // MAKE SURE PHOTO OUTPUT HAS THE SAME ORIENTATION
        // AS THE PREVIEW
        // ==================================================

        if let connection =
            photoOutput.connection(
                with: .video
            ) {

            if connection.isVideoOrientationSupported {

                connection.videoOrientation =
                    currentVideoOrientation()
            }

            if connection.isVideoMirroringSupported {

                connection
                    .automaticallyAdjustsVideoMirroring =
                    false

                connection.isVideoMirrored =
                    currentCameraPosition == .front
            }
        }

        // ==================================================
        // PHOTO SETTINGS
        // ==================================================

        let settings =
            AVCapturePhotoSettings()

        if photoOutput.availablePhotoCodecTypes.contains(
            .jpeg
        ) {

            settings.flashMode = .off
        }

        // ==================================================
        // CAPTURE
        // ==================================================

        photoOutput.capturePhoto(
            with: settings,
            delegate: self
        )
    }

    // MARK: - Switch Camera

    @objc
    private func switchCamera() {

        guard isCameraConfigured else {
            return
        }

        guard let currentInput =
                currentCameraInput
        else {
            return
        }

        // ==================================================
        // DETERMINE NEW CAMERA
        // ==================================================

        let newPosition:
            AVCaptureDevice.Position =
            currentCameraPosition == .back
            ? .front
            : .back

        guard let newCamera =
                AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: newPosition
                )
        else {

            print(
                "Unable to find other camera."
            )

            return
        }

        do {

            let newInput =
                try AVCaptureDeviceInput(
                    device: newCamera
                )

            captureSession.beginConfiguration()

            defer {
                captureSession.commitConfiguration()
            }

            // ==================================================
            // CHECK INPUT
            // ==================================================

            guard captureSession.canAddInput(
                newInput
            ) else {

                print(
                    "Unable to add new camera input."
                )

                return
            }

            // ==================================================
            // CHANGE INPUT
            // ==================================================

            captureSession.removeInput(
                currentInput
            )

            captureSession.addInput(
                newInput
            )

            currentCameraInput =
                newInput

            currentCameraPosition =
                newPosition

            // ==================================================
            // UPDATE ORIENTATION
            // ==================================================

            DispatchQueue.main.async { [weak self] in

                self?.updateCameraOrientation()
            }

        } catch {

            print(
                "Switch camera error:",
                error.localizedDescription
            )
        }
    }

    // MARK: - Gallery

    @objc
    private func openGallery() {

        var configuration =
            PHPickerConfiguration(
                photoLibrary:
                    .shared()
            )

        configuration.filter =
            .images

        configuration.selectionLimit =
            1

        let picker =
            PHPickerViewController(
                configuration:
                    configuration
            )

        picker.delegate =
            self

        present(
            picker,
            animated: true
        )
    }

    // MARK: - Close

    @objc
    private func closeTapped() {

        dismiss(
            animated: true
        )
    }

    // MARK: - Permission Alert

    private func showCameraPermissionAlert() {

        let alert =
            UIAlertController(
                title:
                    "Camera Access Needed",
                message:
                    "Please allow camera access in Settings to take a postcard photo.",
                preferredStyle:
                    .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Settings",
                style: .default
            ) { _ in

                guard let url =
                        URL(
                            string:
                                UIApplication.openSettingsURLString
                        )
                else {
                    return
                }

                UIApplication.shared.open(
                    url
                )
            }
        )

        present(
            alert,
            animated: true
        )
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController:
    AVCapturePhotoCaptureDelegate {

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo:
            AVCapturePhoto,
        error: Error?
    ) {

        // ==================================================
        // ERROR
        // ==================================================

        if let error {

            print(
                "Photo capture error:",
                error.localizedDescription
            )

            return
        }

        // ==================================================
        // DATA
        // ==================================================

        guard let data =
                photo.fileDataRepresentation()
        else {

            print(
                "Unable to get photo data."
            )

            return
        }

        // ==================================================
        // IMAGE
        // ==================================================

        guard let image =
                UIImage(
                    data: data
                )
        else {

            print(
                "Unable to create UIImage."
            )

            return
        }

        // ==================================================
        // RETURN IMAGE TO SWIFTUI
        // ==================================================

        DispatchQueue.main.async { [weak self] in

            self?.onImageSelected?(
                image
            )
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CameraViewController:
    PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results:
            [PHPickerResult]
    ) {

        // Close picker first.

        picker.dismiss(
            animated: true
        )

        // ==================================================
        // GET RESULT
        // ==================================================

        guard let result =
                results.first
        else {
            return
        }

        // ==================================================
        // CHECK IMAGE
        // ==================================================

        guard result.itemProvider.canLoadObject(
            ofClass: UIImage.self
        ) else {

            print(
                "Selected item is not an image."
            )

            return
        }

        // ==================================================
        // LOAD IMAGE
        // ==================================================

        result.itemProvider.loadObject(
            ofClass: UIImage.self
        ) { [weak self] object, error in

            if let error {

                print(
                    "Gallery error:",
                    error.localizedDescription
                )

                return
            }

            guard let image =
                    object as? UIImage
            else {

                print(
                    "Unable to convert gallery item to UIImage."
                )

                return
            }

            // ==================================================
            // RETURN IMAGE TO SWIFTUI
            // ==================================================

            DispatchQueue.main.async {

                self?.onImageSelected?(
                    image
                )
            }
        }
    }
}

