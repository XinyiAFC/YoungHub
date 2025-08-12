import Foundation

struct Article: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let content: String
    let publishDate: Date
    let category: ArticleCategory
    let imageURL: String?
    let readingTime: Int // 阅读时间（分钟）
    let likes: Int
    let isBookmarked: Bool
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: publishDate)
    }
}

enum ArticleCategory: String, CaseIterable, Codable {
    case technology = "科技"
    case lifestyle = "生活"
    case travel = "旅行"
    case food = "美食"
    case education = "教育"
    case entertainment = "娱乐"
    case sports = "运动"
    case health = "健康"
    
    var color: Color {
        switch self {
        case .technology:
            return Color.blue
        case .lifestyle:
            return Color.pink
        case .travel:
            return Color.green
        case .food:
            return Color.orange
        case .education:
            return Color.purple
        case .entertainment:
            return Color.red
        case .sports:
            return Color.cyan
        case .health:
            return Color.mint
        }
    }
    
    var icon: String {
        switch self {
        case .technology:
            return "laptopcomputer"
        case .lifestyle:
            return "heart.fill"
        case .travel:
            return "airplane"
        case .food:
            return "fork.knife"
        case .education:
            return "graduationcap.fill"
        case .entertainment:
            return "play.circle.fill"
        case .sports:
            return "figure.run"
        case .health:
            return "cross.fill"
        }
    }
}

// 示例数据
extension Article {
    static let sampleArticles: [Article] = [
        Article(
            title: "探索未来科技：AI如何改变我们的生活",
            author: "科技小王",
            content: "人工智能正在以前所未有的速度改变着我们的生活方式...",
            publishDate: Date().addingTimeInterval(-86400),
            category: .technology,
            imageURL: "tech_ai",
            readingTime: 5,
            likes: 128,
            isBookmarked: false
        ),
        Article(
            title: "青春旅行日记：背包客的欧洲探险",
            author: "旅行达人小李",
            content: "这是一次说走就走的旅行，从巴黎的浪漫到意大利的激情...",
            publishDate: Date().addingTimeInterval(-172800),
            category: .travel,
            imageURL: "travel_europe",
            readingTime: 8,
            likes: 256,
            isBookmarked: true
        ),
        Article(
            title: "健康生活指南：年轻人的运动养生之道",
            author: "健康专家",
            content: "在快节奏的现代生活中，如何保持身心健康是每个年轻人都关心的话题...",
            publishDate: Date().addingTimeInterval(-259200),
            category: .health,
            imageURL: "health_fitness",
            readingTime: 6,
            likes: 189,
            isBookmarked: false
        ),
        Article(
            title: "美食探店：藏在城市角落的小众咖啡厅",
            author: "美食博主",
            content: "今天要为大家推荐几家藏在城市角落的小众咖啡厅...",
            publishDate: Date().addingTimeInterval(-345600),
            category: .food,
            imageURL: "food_coffee",
            readingTime: 4,
            likes: 97,
            isBookmarked: true
        ),
        Article(
            title: "大学生活指南：如何平衡学习与社交",
            author: "学长学姐",
            content: "进入大学，是人生的一个重要转折点，如何在学习和社交之间找到平衡...",
            publishDate: Date().addingTimeInterval(-432000),
            category: .education,
            imageURL: "education_student",
            readingTime: 7,
            likes: 342,
            isBookmarked: false
        )
    ]
}