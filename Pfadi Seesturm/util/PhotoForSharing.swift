//
//  PhotoForSharing.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.06.2025.
//
import SwiftUI

struct PhotoForSharing: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    public var image: Image
}
