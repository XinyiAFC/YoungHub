import Foundation
import SwiftUI

class ArticleList: ObservableObject {
    @Published var featuredArticles: [ArticleCard] = []
    @Published var recentArticles: [ArticleCard] = []
    @Published var isLoading = false
    
    func fetchData() {
        isLoading = true
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.featuredArticles = Array(ArticleCard.sampleCards.prefix(3))
            self.recentArticles = Array(ArticleCard.sampleCards.suffix(4))
            self.isLoading = false
        }
    }
    
    func refreshData() {
        // 模拟刷新数据
        fetchData()
    }
}