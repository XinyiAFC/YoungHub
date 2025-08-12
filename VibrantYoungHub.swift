import SwiftUI
import Foundation
import WebKit

// MARK: - Cosmos DB 配置
struct CosmosConfig {
    static let endpoint = "YOUR_COSMOS_ENDPOINT"
    static let key = "YOUR_COSMOS_KEY"
    static let databaseId = "YoungHubDB"
    static let containerId = "Articles"
}

// MARK: - 数据模型
struct Article: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let contentURL: String
    let category: String
    let readingTime: Int
    let isBookmarked: Bool
    let excerpt: String
    let publishDate: Date
    let imageURL: String
    let tags: [String]
    
    // Cosmos DB字段映射
    enum CodingKeys: String, CodingKey {
        case title, author, contentURL, category, readingTime, isBookmarked, excerpt, publishDate, imageURL, tags
    }
    
    var categoryInfo: (color: Color, gradient: [Color], icon: String) {
        switch category {
        case "科技": return (.blue, [.blue, .cyan], "cpu")
        case "时尚": return (.pink, [.pink, .purple], "sparkles")
        case "旅行": return (.green, [.green, .mint], "airplane.departure")
        case "美食": return (.orange, [.orange, .yellow], "fork.knife.circle")
        case "音乐": return (.purple, [.purple, .indigo], "music.note")
        case "摄影": return (.teal, [.teal, .blue], "camera.aperture")
        case "运动": return (.red, [.red, .orange], "figure.run.circle")
        default: return (.gray, [.gray, .secondary], "doc.text")
        }
    }
}

// MARK: - Cosmos DB 搜索管理器
class CosmosSearchManager: ObservableObject {
    @Published var searchResults: [Article] = []
    @Published var isSearching = false
    @Published var searchError: String?
    
    func searchArticles(query: String) async {
        guard !query.isEmpty else {
            await MainActor.run {
                searchResults = []
            }
            return
        }
        
        await MainActor.run {
            isSearching = true
            searchError = nil
        }
        
        do {
            // 模拟Cosmos DB搜索请求
            let results = await performCosmosSearch(query: query)
            
            await MainActor.run {
                self.searchResults = results
                self.isSearching = false
            }
        } catch {
            await MainActor.run {
                self.searchError = error.localizedDescription
                self.isSearching = false
            }
        }
    }
    
    private func performCosmosSearch(query: String) async -> [Article] {
        // 实际的Cosmos DB查询
        /*
        let cosmosQuery = """
        SELECT * FROM c 
        WHERE CONTAINS(LOWER(c.title), LOWER(@query)) 
        OR CONTAINS(LOWER(c.excerpt), LOWER(@query))
        OR ARRAY_CONTAINS(c.tags, @query, true)
        ORDER BY c.publishDate DESC
        """
        */
        
        // 模拟延迟和结果
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        return mockSearchResults(for: query)
    }
    
    private func mockSearchResults(for query: String) -> [Article] {
        // 模拟搜索结果
        let allArticles = [
            Article(title: "AI革命：机器学习的未来趋势", author: "科技探索者", contentURL: "https://example.com", category: "科技", readingTime: 8, isBookmarked: false, excerpt: "深入探讨人工智能在各行各业的应用前景", publishDate: Date(), imageURL: "https://picsum.photos/400/300?random=10", tags: ["AI", "机器学习", "科技"]),
            
            Article(title: "街拍时尚：2024年春季穿搭指南", author: "时尚达人", contentURL: "https://example.com", category: "时尚", readingTime: 6, isBookmarked: true, excerpt: "最新潮流趋势和搭配技巧分享", publishDate: Date(), imageURL: "https://picsum.photos/400/300?random=11", tags: ["时尚", "穿搭", "春季"]),
            
            Article(title: "美食探秘：隐藏在城市角落的小店", author: "美食猎人", contentURL: "https://example.com", category: "美食", readingTime: 5, isBookmarked: false, excerpt: "发现那些不为人知的美味珍宝", publishDate: Date(), imageURL: "https://picsum.photos/400/300?random=12", tags: ["美食", "探店", "城市"])
        ]
        
        return allArticles.filter { article in
            article.title.lowercased().contains(query.lowercased()) ||
            article.excerpt.lowercased().contains(query.lowercased()) ||
            article.tags.contains { $0.lowercased().contains(query.lowercased()) }
        }
    }
}

// MARK: - 文章管理器
class ArticleManager: ObservableObject {
    @Published var trendingArticles: [Article] = []
    @Published var recentArticles: [Article] = []
    @Published var categories: [String] = ["全部", "科技", "时尚", "旅行", "美食", "音乐", "摄影", "运动"]
    @Published var selectedCategory = "全部"
    @Published var isLoading = false
    
    let sampleArticles: [Article] = [
        Article(title: "元宇宙时代：虚拟与现实的完美融合", author: "未来学家", contentURL: "https://example.com", category: "科技", readingTime: 10, isBookmarked: false, excerpt: "探索虚拟世界如何改变我们的生活方式", publishDate: Date().addingTimeInterval(-3600), imageURL: "https://picsum.photos/400/300?random=1", tags: ["元宇宙", "VR", "科技"]),
        
        Article(title: "可持续时尚：环保与美学的新平衡", author: "绿色时尚", contentURL: "https://example.com", category: "时尚", readingTime: 7, isBookmarked: true, excerpt: "了解如何在追求美的同时保护地球", publishDate: Date().addingTimeInterval(-7200), imageURL: "https://picsum.photos/400/300?random=2", tags: ["环保", "时尚", "可持续"]),
        
        Article(title: "数字游牧生活：远程工作的艺术", author: "自由职业者", contentURL: "https://example.com", category: "旅行", readingTime: 9, isBookmarked: false, excerpt: "边旅行边工作的完整指南", publishDate: Date().addingTimeInterval(-10800), imageURL: "https://picsum.photos/400/300?random=3", tags: ["远程工作", "旅行", "生活方式"]),
        
        Article(title: "分子料理：科学与美味的碰撞", author: "创意厨师", contentURL: "https://example.com", category: "美食", readingTime: 6, isBookmarked: true, excerpt: "现代烹饪技术如何重新定义美食", publishDate: Date().addingTimeInterval(-14400), imageURL: "https://picsum.photos/400/300?random=4", tags: ["分子料理", "创新", "美食"]),
        
        Article(title: "Lo-Fi音乐的治愈力量", author: "音乐治疗师", contentURL: "https://example.com", category: "音乐", readingTime: 5, isBookmarked: false, excerpt: "为什么这种简单的音乐能让人放松", publishDate: Date().addingTimeInterval(-18000), imageURL: "https://picsum.photos/400/300?random=5", tags: ["Lo-Fi", "音乐", "治愈"]),
        
        Article(title: "夜景摄影：捕捉城市的另一面", author: "夜行摄影师", contentURL: "https://example.com", category: "摄影", readingTime: 8, isBookmarked: true, excerpt: "掌握夜晚拍摄的技巧和设备选择", publishDate: Date().addingTimeInterval(-21600), imageURL: "https://picsum.photos/400/300?random=6", tags: ["夜景", "摄影", "城市"])
    ]
    
    func fetchData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.trendingArticles = Array(self.sampleArticles.prefix(4))
            self.recentArticles = self.sampleArticles
            self.isLoading = false
        }
    }
    
    var filteredArticles: [Article] {
        if selectedCategory == "全部" {
            return recentArticles
        } else {
            return recentArticles.filter { $0.category == selectedCategory }
        }
    }
}

// MARK: - 动态背景
struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // 主背景渐变
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.98, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.97, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 浮动圆形装饰
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                [Color.pink.opacity(0.3), Color.orange.opacity(0.2)],
                                [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                                [Color.green.opacity(0.3), Color.mint.opacity(0.2)],
                                [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                [Color.indigo.opacity(0.3), Color.purple.opacity(0.2)],
                                [Color.teal.opacity(0.3), Color.cyan.opacity(0.2)]
                            ][index],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 100...200))
                    .offset(
                        x: animate ? CGFloat.random(in: -50...50) : CGFloat.random(in: -30...30),
                        y: animate ? CGFloat.random(in: -50...50) : CGFloat.random(in: -30...30)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animate
                    )
                    .blur(radius: 30)
                    .offset(
                        x: CGFloat(index % 3 - 1) * 150,
                        y: CGFloat(index / 3 - 1) * 200
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .ignoresSafeArea()
    }
}

// MARK: - 现代文章卡片
struct VibrantArticleCard: View {
    let article: Article
    let style: CardStyle
    @State private var isPressed = false
    @State private var isBookmarked: Bool
    @State private var cardRotation: Double = 0
    
    enum CardStyle {
        case trending, regular, search
    }
    
    init(article: Article, style: CardStyle = .regular) {
        self.article = article
        self.style = style
        self._isBookmarked = State(initialValue: article.isBookmarked)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 图片区域
            ZStack {
                // 渐变背景
                LinearGradient(
                    colors: article.categoryInfo.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.8)
                
                // 图片占位符
                RoundedRectangle(cornerRadius: 0)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        VStack {
                            Image(systemName: article.categoryInfo.icon)
                                .font(.system(size: 50, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            if style == .trending {
                                Text("HOT")
                                    .font(.caption2)
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.red)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                
                // 装饰性几何图形
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 30, height: 30)
                            .offset(x: 15, y: -15)
                    }
                    Spacer()
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.15))
                            .frame(width: 40, height: 20)
                            .offset(x: -20, y: 15)
                        Spacer()
                    }
                }
                
                // 收藏按钮
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                isBookmarked.toggle()
                            }
                        } label: {
                            Image(systemName: isBookmarked ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isBookmarked ? .red : .white)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .scaleEffect(isBookmarked ? 1.2 : 1.0)
                        }
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                    }
                    Spacer()
                }
            }
            .frame(height: style == .trending ? 180 : style == .search ? 120 : 160)
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            
            // 内容区域
            VStack(alignment: .leading, spacing: 12) {
                // 标签和时间
                HStack {
                    Text(article.category)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: article.categoryInfo.gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    if style != .search {
                        Label("\(article.readingTime)min", systemImage: "clock.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 标题
                Text(article.title)
                    .font(.system(
                        size: style == .trending ? 18 : style == .search ? 15 : 16,
                        weight: .bold,
                        design: .rounded
                    ))
                    .lineLimit(style == .search ? 2 : 3)
                    .foregroundColor(.primary)
                
                // 摘要
                if style != .search {
                    Text(article.excerpt)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 标签
                if !article.tags.isEmpty && style == .trending {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(article.tags.prefix(3)), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundColor(article.categoryInfo.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(article.categoryInfo.color.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // 作者信息
                HStack {
                    Text("by \(article.author)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if style == .trending {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("热门")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(
            color: article.categoryInfo.color.opacity(0.3),
            radius: isPressed ? 20 : 12,
            x: 0, y: isPressed ? 12 : 8
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .rotation3DEffect(
            .degrees(cardRotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPressed = pressing
                cardRotation = pressing ? 5 : 0
            }
        } perform: {}
    }
}

// MARK: - 搜索栏
struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let onSearchChange: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .scaleEffect(isSearching ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSearching)
                
                TextField("搜索文章、作者或标签...", text: $searchText)
                    .font(.system(size: 16))
                    .onChange(of: searchText) { _, newValue in
                        onSearchChange(newValue)
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        onSearchChange("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: isSearching ? [.pink, .orange] : [.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isSearching ? 2 : 0
                    )
                    .animation(.spring(response: 0.4), value: isSearching)
            )
        }
    }
}

// MARK: - 主界面
struct ContentView: View {
    @StateObject private var articleManager = ArticleManager()
    @StateObject private var searchManager = CosmosSearchManager()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingSearch = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 动态背景
                AnimatedBackground()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        // 顶部区域
                        headerSection
                        
                        // 搜索栏
                        searchSection
                        
                        // 搜索结果
                        if isSearching && !searchText.isEmpty {
                            searchResultsSection
                        } else {
                            // 正常内容
                            categorySection
                            
                            if !articleManager.trendingArticles.isEmpty {
                                trendingSection
                            }
                            
                            if !articleManager.filteredArticles.isEmpty {
                                latestSection
                            }
                        }
                        
                        Color.clear.frame(height: 120)
                    }
                }
                
                // 加载动画
                if articleManager.isLoading || searchManager.isSearching {
                    loadingOverlay
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            articleManager.fetchData()
        }
    }
    
    // MARK: - 顶部区域
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("欢迎回来! 🌟")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("YoungHub")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .orange, .purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("发现 • 探索 • 成长")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .tracking(3)
                        .textCase(.uppercase)
                }
                
                Spacer()
                
                // 装饰性元素
                VStack(spacing: 8) {
                    Circle()
                        .fill(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 20, height: 20)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .fill(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    // MARK: - 搜索区域
    private var searchSection: some View {
        VStack(spacing: 16) {
            SearchBar(
                searchText: $searchText,
                isSearching: $isSearching,
                onSearchChange: { query in
                    isSearching = !query.isEmpty
                    Task {
                        await searchManager.searchArticles(query: query)
                    }
                }
            )
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - 搜索结果
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .foregroundColor(.blue)
                        Text("搜索结果")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("找到 \(searchManager.searchResults.count) 篇相关文章")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if searchManager.searchResults.isEmpty && !searchManager.isSearching {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("没有找到相关内容")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("尝试使用不同的关键词")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(searchManager.searchResults) { article in
                        NavigationLink {
                            if let url = URL(string: article.contentURL) {
                                WebView(url: url)
                                    .navigationTitle("阅读")
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        } label: {
                            VibrantArticleCard(article: article, style: .search)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - 分类区域
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("探索分类")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(articleManager.categories, id: \.self) { category in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                articleManager.selectedCategory = category
                            }
                        } label: {
                            Text(category)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(articleManager.selectedCategory == category ? .white : .primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background {
                                    if articleManager.selectedCategory == category {
                                        LinearGradient(
                                            colors: [.pink, .orange, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .clipShape(Capsule())
                                    } else {
                                        Capsule()
                                            .fill(.regularMaterial)
                                    }
                                }
                        }
                        .scaleEffect(articleManager.selectedCategory == category ? 1.05 : 1.0)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - 热门趋势区域
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("热门趋势")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("最受欢迎的精彩内容")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("查看全部") {}
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(articleManager.trendingArticles) { article in
                        NavigationLink {
                            if let url = URL(string: article.contentURL) {
                                WebView(url: url)
                                    .navigationTitle("阅读")
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        } label: {
                            VibrantArticleCard(article: article, style: .trending)
                                .frame(width: 300)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - 最新文章区域
    private var latestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("最新发布")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("新鲜出炉的精彩内容")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            LazyVStack(spacing: 16) {
                ForEach(articleManager.filteredArticles) { article in
                    NavigationLink {
                        if let url = URL(string: article.contentURL) {
                            WebView(url: url)
                                .navigationTitle("阅读")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    } label: {
                        VibrantArticleCard(article: article, style: .regular)
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // MARK: - 加载动画
            private var loadingOverlay: some View {
                VStack(spacing: 24) {
                    ZStack {
                        ForEach(0..<4) { i in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            [.pink, .orange],
                                            [.orange, .yellow],
                                            [.purple, .blue],
                                            [.green, .mint]
                                        ][i],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 12, height: 12)
                                .offset(x: 0, y: -25)
                                .rotationEffect(.degrees(Double(i) * 90))
                                .animation(
                                    .easeInOut(duration: 1.0)
                                    .repeatForever()
                                    .delay(Double(i) * 0.15),
                                    value: articleManager.isLoading || searchManager.isSearching
                                )
                        }
                    }
                    
                    Text(searchManager.isSearching ? "搜索中..." : "加载精彩内容中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            }
        }
        
        // MARK: - WebView
        struct WebView: UIViewRepresentable {
            let url: URL
            
            func makeUIView(context: Context) -> WKWebView {
                WKWebView()
            }
            
            func updateUIView(_ webView: WKWebView, context: Context) {
            }
        }
        
        #Preview {
            ContentView()
        }