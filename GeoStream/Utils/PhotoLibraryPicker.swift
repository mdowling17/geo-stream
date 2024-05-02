//
//  PhotoLibraryPicker.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoLibraryPicker
        
        init(parent: PhotoLibraryPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let uiImage = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImage = uiImage
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
    
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
}


#Preview {
    PhotoLibraryPicker(selectedImage: .constant(nil))
}
