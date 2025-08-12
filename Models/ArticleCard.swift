import Foundation
import SwiftUI

struct ArticleCard: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let contentURL: String
    let imageURL: String?
    let publishDate: Date
    let category: String
    let readingTime: Int
    let likes: Int
    let isBookmarked: Bool
    let excerpt: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: publishDate)
    }
    
    var categoryColor: Color {
        switch category.lowercased() {
        case "科技":
            return .blue
        case "生活":
            return .pink
        case "旅行":
            return .green
        case "美食":
            return .orange
        case "教育":
            return .purple
        case "娱乐":
            return .red
        case "运动":
            return .cyan
        case "健康":
            return .mint
        default:
            return .gray
        }
    }
    
    var categoryIcon: String {
        switch category.lowercased() {
        case "科技":
            return "laptopcomputer"
        case "生活":
            return "heart.fill"
        case "旅行":
            return "airplane"
        case "美食":
            return "fork.knife"
        case "教育":
            return "graduationcap.fill"
        case "娱乐":
            return "play.circle.fill"
        case "运动":
            return "figure.run"
        case "健康":
            return "cross.fill"
        default:
            return "doc.text"
        }
    }
}

// 示例数据
extension ArticleCard {
    static let sampleCards: [ArticleCard] = [
        ArticleCard(
            title: "探索AI的无限可能：未来科技趋势解析",
            author: "科技前沿",
            contentURL: "https://example.com/ai-future",
            imageURL: "tech_ai",
            publishDate: Date().addingTimeInterval(-86400),
            category: "科技",
            readingTime: 5,
            likes: 324,
            isBookmarked: false,
            excerpt: "人工智能正在重塑我们的世界，从日常生活到工作方式，AI的影响无处不在..."
        ),
        ArticleCard(
            title: "青春旅行指南：最值得去的10个城市",
            author: "旅行达人",
            contentURL: "https://example.com/travel-guide",
            imageURL: "travel_cities",
            publishDate: Date().addingTimeInterval(-172800),
            category: "旅行",
            readingTime: 8,
            likes: 567,
            isBookmarked: true,
            excerpt: "背上行囊，开启一场说走就走的旅行，这些城市绝对不能错过..."
        ),
        ArticleCard(
            title: "健康生活新主张：年轻人的养生之道",
            author: "健康专家",
            contentURL: "https://example.com/healthy-living",
            imageURL: "health_lifestyle",
            publishDate: Date().addingTimeInterval(-259200),
            category: "健康",
            readingTime: 6,
            likes: 423,
            isBookmarked: false,
            excerpt: "在快节奏的现代生活中，保持身心健康比以往任何时候都更重要..."
        ),
        ArticleCard(
            title: "美食探店：隐藏在城市角落的宝藏小店",
            author: "美食家",
            contentURL: "https://example.com/food-discovery",
            imageURL: "food_hidden",
            publishDate: Date().addingTimeInterval(-345600),
            category: "美食",
            readingTime: 4,
            likes: 289,
            isBookmarked: true,
            excerpt: "每个城市都有那么几家隐藏的美食宝地，等待着被发现..."
        ),
        ArticleCard(
            title: "大学生活攻略：如何度过充实的校园时光",
            author: "学长学姐",
            contentURL: "https://example.com/campus-life",
            imageURL: "education_campus",
            publishDate: Date().addingTimeInterval(-432000),
            category: "教育",
            readingTime: 7,
            likes: 612,
            isBookmarked: false,
            excerpt: "大学四年是人生中最宝贵的时光，如何让这段时间过得有意义..."
        )
    ]
}