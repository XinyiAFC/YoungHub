import SwiftUI
import Foundation
import WebKit

// MARK: - 数据模型
struct TrendyArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let contentURL: String
    let category: String
    let readingTime: Int
    let isBookmarked: Bool
    let excerpt: String
    let publishDate: Date
    let imageURL: String // 真实图片URL
    
    var categoryInfo: (color: Color, icon: String) {
        switch category {
        case "科技": return (.blue, "cpu")
        case "时尚": return (.pink, "sparkles")
        case "旅行": return (.green, "airplane.departure")
        case "美食": return (.orange, "fork.knife.circle")
        case "音乐": return (.purple, "music.note")
        case "摄影": return (.teal, "camera.aperture")
        case "运动": return (.red, "figure.run.circle")
        default: return (.gray, "doc.text")
        }
    }
}

// MARK: - ViewModel
class TrendyArticleManager: ObservableObject {
    @Published var trendingArticles: [TrendyArticle] = []
    @Published var recentArticles: [TrendyArticle] = []
    @Published var categories: [String] = ["全部", "科技", "时尚", "旅行", "美食", "音乐", "摄影", "运动"]
    @Published var selectedCategory = "全部"
    @Published var isLoading = false
    
    let sampleArticles: [TrendyArticle] = [
        TrendyArticle(title: "AI艺术革命：当代码遇见创意", author: "未来设计师", contentURL: "https://example.com", category: "科技", readingTime: 6, isBookmarked: false, excerpt: "探索人工智能如何重新定义艺术创作的边界", publishDate: Date().addingTimeInterval(-3600), imageURL: "https://picsum.photos/400/300?random=1"),
        
        TrendyArticle(title: "2024春夏潮流预测：可持续时尚崛起", author: "时尚先锋", contentURL: "https://example.com", category: "时尚", readingTime: 4, isBookmarked: true, excerpt: "环保材料与前卫设计的完美融合", publishDate: Date().addingTimeInterval(-7200), imageURL: "https://picsum.photos/400/300?random=2"),
        
        TrendyArticle(title: "城市漫游指南：发现身边的小确幸", author: "城市探索者", contentURL: "https://example.com", category: "旅行", readingTime: 8, isBookmarked: false, excerpt: "用全新视角重新认识你生活的城市", publishDate: Date().addingTimeInterval(-10800), imageURL: "https://picsum.photos/400/300?random=3"),
        
        TrendyArticle(title: "咖啡文化深度解析：从豆子到杯子", author: "咖啡达人", contentURL: "https://example.com", category: "美食", readingTime: 5, isBookmarked: true, excerpt: "深入了解每一杯咖啡背后的故事", publishDate: Date().addingTimeInterval(-14400), imageURL: "https://picsum.photos/400/300?random=4"),
        
        TrendyArticle(title: "独立音乐人的创作之路", author: "音乐制作人", contentURL: "https://example.com", category: "音乐", readingTime: 7, isBookmarked: false, excerpt: "记录那些在音乐路上坚持梦想的年轻人", publishDate: Date().addingTimeInterval(-18000), imageURL: "https://picsum.photos/400/300?random=5"),
        
        TrendyArticle(title: "手机摄影技巧：光影的艺术", author: "摄影师", contentURL: "https://example.com", category: "摄影", readingTime: 6, isBookmarked: true, excerpt: "用手机也能拍出专业级的照片", publishDate: Date().addingTimeInterval(-21600), imageURL: "https://picsum.photos/400/300?random=6")
    ]
    
    func fetchData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.trendingArticles = Array(self.sampleArticles.prefix(3))
            self.recentArticles = self.sampleArticles
            self.isLoading = false
        }
    }
    
    var filteredArticles: [TrendyArticle] {
        if selectedCategory == "全部" {
            return recentArticles
        } else {
            return recentArticles.filter { $0.category == selectedCategory }
        }
    }
}

// MARK: - 简化文章卡片
struct ModernArticleCard: View {
    let article: TrendyArticle
    let style: CardStyle
    @State private var isPressed = false
    @State private var isBookmarked: Bool
    
    enum CardStyle {
        case trending, regular
    }
    
    init(article: TrendyArticle, style: CardStyle = .regular) {
        self.article = article
        self.style = style
        self._isBookmarked = State(initialValue: article.isBookmarked)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部图像区域
            ZStack {
                // 图片背景 (使用真实图片或占位图)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: style == .trending ? 200 : 160)
                    .overlay {
                        // 这里可以替换为 AsyncImage 来加载真实图片
                        // AsyncImage(url: URL(string: article.imageURL)) { image in
                        //     image.resizable().aspectRatio(contentMode: .fill)
                        // } placeholder: {
                        //     Color.gray.opacity(0.3)
                        // }
                        
                        // 临时占位图案
                        ZStack {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(article.categoryInfo.color.opacity(0.1))
                            
                            Image(systemName: article.categoryInfo.icon)
                                .font(.system(size: 40, weight: .ultraLight))
                                .foregroundColor(article.categoryInfo.color.opacity(0.3))
                        }
                    }
                
                // 渐变遮罩层 (让文字更清楚)
                LinearGradient(
                    colors: [
                        .clear,
                        .clear,
                        .black.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: style == .trending ? 200 : 160)
                
                // 收藏按钮
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                isBookmarked.toggle()
                            }
                        } label: {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .scaleEffect(isBookmarked ? 1.1 : 1.0)
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                    }
                    Spacer()
                }
            }
            
            // 内容区域
            VStack(alignment: .leading, spacing: 12) {
                // 标签行
                HStack {
                    // 分类标签
                    Text(article.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(article.categoryInfo.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(article.categoryInfo.color.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // 阅读时间
                    Label("\(article.readingTime)min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // 标题
                Text(article.title)
                    .font(.system(size: style == .trending ? 18 : 16, weight: .bold, design: .rounded))
                    .lineLimit(style == .trending ? 3 : 2)
                    .foregroundColor(.primary)
                
                // 摘要
                if style == .regular {
                    Text(article.excerpt)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 底部信息
                HStack {
                    // 作者 (仅文字，无头像)
                    Text("by \(article.author)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(16)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(isPressed ? 0.15 : 0.05), 
                radius: isPressed ? 15 : 8, 
                x: 0, y: isPressed ? 8 : 4)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        } perform: {}
    }
}

// MARK: - 分类选择器
struct CategorySelector: View {
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                if selectedCategory == category {
                                    LinearGradient(
                                        colors: [.pink, .orange],
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
                    .scaleEffect(selectedCategory == category ? 1.05 : 1.0)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - WebView
struct TrendyWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}

// MARK: - 主界面
struct ContentView: View {
    @StateObject private var articleManager = TrendyArticleManager()
    @State private var showingSearch = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 简洁背景
                LinearGradient(
                    colors: [
                        .pink.opacity(0.02),
                        .orange.opacity(0.02),
                        .purple.opacity(0.02),
                        .blue.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // 顶部区域
                        headerSection
                        
                        // 搜索栏
                        if showingSearch {
                            searchSection
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // 分类选择器
                        categorySection
                        
                        // 热门趋势
                        if !articleManager.trendingArticles.isEmpty {
                            trendingSection
                        }
                        
                        // 最新文章
                        if !articleManager.filteredArticles.isEmpty {
                            latestSection
                        }
                        
                        Color.clear.frame(height: 120)
                    }
                }
                
                // 加载动画
                if articleManager.isLoading {
                    loadingOverlay
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            articleManager.fetchData()
        }
    }
    
    // MARK: - 顶部区域 (简化，移除通知)
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // 问候语
                    Text("Hey there! 👋")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // 应用标题
                    Text("YoungHub")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .orange, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Discover • Create • Inspire")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .tracking(2)
                }
                
                Spacer()
                
                // 搜索按钮
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showingSearch.toggle()
                    }
                } label: {
                    Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    // MARK: - 搜索区域
    private var searchSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索你感兴趣的内容...", text: $searchText)
                    .font(.system(size: 16))
                
                if !searchText.isEmpty {
                    Button("清空") { searchText = "" }
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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
            
            CategorySelector(
                selectedCategory: $articleManager.selectedCategory,
                categories: articleManager.categories
            )
        }
        .padding(.bottom, 20)
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
                    
                    Text("最受欢迎的内容")
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
                                TrendyWebView(url: url)
                                    .navigationTitle("阅读")
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        } label: {
                            ModernArticleCard(article: article, style: .trending)
                                .frame(width: 280)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 30)
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
                            TrendyWebView(url: url)
                                .navigationTitle("阅读")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    } label: {
                        ModernArticleCard(article: article, style: .regular)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - 加载动画
    private var loadingOverlay: some View {
        VStack(spacing: 24) {
            // 自定义加载动画
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(LinearGradient(colors: [.pink, .orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 12, height: 12)
                        .offset(x: 0, y: -20)
                        .rotationEffect(.degrees(Double(i) * 120))
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                            value: articleManager.isLoading
                        )
                }
            }
            
            Text("探索精彩内容中...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

#Preview {
    ContentView()
}