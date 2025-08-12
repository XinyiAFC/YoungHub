import SwiftUI
import Foundation
import WebKit

// MARK: - 数据模型

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
        case "科技": return .blue
        case "生活": return .pink
        case "旅行": return .green
        case "美食": return .orange
        case "教育": return .purple
        case "娱乐": return .red
        case "运动": return .cyan
        case "健康": return .mint
        default: return .gray
        }
    }
    
    var categoryIcon: String {
        switch category.lowercased() {
        case "科技": return "laptopcomputer"
        case "生活": return "heart.fill"
        case "旅行": return "airplane"
        case "美食": return "fork.knife"
        case "教育": return "graduationcap.fill"
        case "娱乐": return "play.circle.fill"
        case "运动": return "figure.run"
        case "健康": return "cross.fill"
        default: return "doc.text"
        }
    }
    
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

// MARK: - ViewModel

class ArticleList: ObservableObject {
    @Published var featuredArticles: [ArticleCard] = []
    @Published var recentArticles: [ArticleCard] = []
    @Published var isLoading = false
    
    func fetchData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.featuredArticles = Array(ArticleCard.sampleCards.prefix(3))
            self.recentArticles = Array(ArticleCard.sampleCards.suffix(4))
            self.isLoading = false
        }
    }
    
    func refreshData() {
        fetchData()
    }
}

// MARK: - WebView组件

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
    }
}

// MARK: - 文章卡片组件

struct ArticleCardView: View {
    let card: ArticleCard
    let fixedTitleHeight: Bool
    @State private var isPressed = false
    @State private var isBookmarked: Bool
    
    init(card: ArticleCard, fixedTitleHeight: Bool = false) {
        self.card = card
        self.fixedTitleHeight = fixedTitleHeight
        self._isBookmarked = State(initialValue: card.isBookmarked)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区域
            ZStack(alignment: .topTrailing) {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        card.categoryColor.opacity(0.3),
                        card.categoryColor.opacity(0.6),
                        card.categoryColor
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: fixedTitleHeight ? 180 : 140)
                .overlay {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: card.categoryIcon)
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.bottom, 20)
                                .padding(.trailing, 20)
                        }
                    }
                }
                
                // 收藏按钮
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isBookmarked.toggle()
                    }
                }) {
                    Image(systemName: isBookmarked ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isBookmarked ? .pink : .white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
                .scaleEffect(isBookmarked ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBookmarked)
            }
            .clipped()
            .cornerRadius(16, corners: [.topLeft, .topRight])
            
            // 内容区域
            VStack(alignment: .leading, spacing: 12) {
                // 分类标签
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: card.categoryIcon)
                            .font(.system(size: 12, weight: .medium))
                        Text(card.category)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(card.categoryColor.opacity(0.1))
                    )
                    .foregroundColor(card.categoryColor)
                    
                    Spacer()
                    
                    // 阅读时间
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text("\(card.readingTime)分钟")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
                
                // 标题
                Text(card.title)
                    .font(.system(size: fixedTitleHeight ? 16 : 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(fixedTitleHeight ? 2 : 3)
                    .frame(minHeight: fixedTitleHeight ? 44 : nil, alignment: .top)
                
                // 摘要
                if !fixedTitleHeight {
                    Text(card.excerpt)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 底部信息
                HStack {
                    // 作者信息
                    HStack(spacing: 8) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [card.categoryColor.opacity(0.6), card.categoryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 24, height: 24)
                            .overlay {
                                Text(String(card.author.prefix(1)))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(card.author)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                            Text(card.formattedDate)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 点赞数
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.pink)
                        Text("\(card.likes)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: isPressed ? card.categoryColor.opacity(0.3) : .black.opacity(0.1),
                    radius: isPressed ? 12 : 8,
                    x: 0,
                    y: isPressed ? 6 : 4
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
}

// MARK: - 圆角扩展

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 主界面

struct YoungHubApp: View {
    @StateObject private var viewModel = ArticleList()
    @State private var showingSearch = false
    @State private var searchText = ""
    @State private var refreshing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 动态渐变背景
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.pink.opacity(0.05), location: 0.0),
                        .init(color: Color.orange.opacity(0.05), location: 0.3),
                        .init(color: Color.yellow.opacity(0.05), location: 0.6),
                        .init(color: Color.mint.opacity(0.05), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: viewModel.isLoading)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // 顶部标题区域
                        headerSection
                        
                        // 搜索栏
                        if showingSearch {
                            searchSection
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // 精选推荐区
                        if !viewModel.featuredArticles.isEmpty {
                            featuredSection
                        }
                        
                        // 最近更新区
                        if !viewModel.recentArticles.isEmpty {
                            recentSection
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                }
                .refreshable {
                    await refreshData()
                }
                
                // 加载指示器
                if viewModel.isLoading {
                    loadingView
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    // MARK: - 头部区域
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("YoungHub")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("探索青春无限可能 ✨")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showingSearch.toggle()
                        }
                    }) {
                        Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    }
                    
                    Button(action: {}) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.pink, .orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Text("Y")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
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
                
                TextField("搜索有趣的内容...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - 精选推荐区域
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("✨ 精选推荐")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("编辑为你精心挑选")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("更多")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(viewModel.featuredArticles.enumerated()), id: \.element.id) { index, card in
                        if let url = URL(string: card.contentURL) {
                            NavigationLink(destination: WebView(url: url)) {
                                ArticleCardView(card: card, fixedTitleHeight: true)
                                    .frame(width: 280, height: 340)
                                    .rotation3DEffect(
                                        .degrees(5),
                                        axis: (x: 0, y: 1, z: 0),
                                        perspective: 0.3
                                    )
                                    .scaleEffect(0.95)
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.1),
                                        value: viewModel.featuredArticles.count
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.leading, 10)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 最近更新区域
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔥 最近更新")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("新鲜出炉的优质内容")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.recentArticles.enumerated()), id: \.element.id) { index, card in
                    if let url = URL(string: card.contentURL) {
                        NavigationLink(destination: WebView(url: url)) {
                            ArticleCardView(card: card)
                                .padding(.horizontal, 20)
                                .transition(.slide.combined(with: .opacity))
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                    value: viewModel.recentArticles.count
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 加载视图
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.pink.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(
                        LinearGradient(
                            colors: [.pink, .orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.isLoading)
            }
            
            Text("加载精彩内容中...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 刷新数据
    private func refreshData() async {
        refreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        viewModel.refreshData()
        refreshing = false
    }
}

// MARK: - 应用入口

@main
struct YoungHubCompleteApp: App {
    var body: some Scene {
        WindowGroup {
            YoungHubApp()
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - Preview

#Preview {
    YoungHubApp()
}