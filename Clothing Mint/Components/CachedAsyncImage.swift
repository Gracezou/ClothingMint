//
//  CachedAsyncImage.swift
//  Clothing Mint
//
//  Kingfisher 封装，支持缓存的异步图片加载
//

import SwiftUI
import Kingfisher

/// 缓存异步图片视图
struct CachedAsyncImage: View {
    let url: String?
    var placeholder: String = "photo"

    var body: some View {
        if let url, let imageURL = URL(string: url) {
            Color.clear
                .overlay {
                    KFImage(imageURL)
                        .resizable()
                        .placeholder {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .overlay {
                                    ProgressView()
                                }
                        }
                        .fade(duration: 0.25)
                        .scaledToFill()
                }
                .clipped()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .overlay {
                    Image(systemName: placeholder)
                        .font(.title2)
                        .foregroundStyle(.gray.opacity(0.4))
                }
        }
    }
}
