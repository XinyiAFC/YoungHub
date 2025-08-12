import SwiftUI
import Foundation
import WebKit

// MARK: - 数据模型
struct ArticleCard: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let contentURL: String
    let category: String
    let readingTime: Int
    let likes: Int
    let isBookmarked: Bool
    let excerpt: String
    
    var categoryColor: Color {
        switch category {
        case "科技": return .blue
        case "旅行": return .green
        case "美食": return .orange
        case "教育": return .purple
        case "健康": return .mint
        default: return .pink
        }
    }
    
    var categoryIcon: String {
        switch category {
        case "科技": return "laptopcomputer"
        case "旅行": return "airplane"
        case "美食": return "fork.knife"
        case "教育": return "graduationcap.fill"
        case "健康": return "cross.fill"
        default: return "heart.fill"
        }
    }
}

// MARK: - ViewModel
class ArticleList: ObservableObject {
    @Published var featuredArticles: [ArticleCard] = []
    @Published var recentArticles: [ArticleCard] = []
    @Published var isLoading = false
    
    let sampleCards: [ArticleCard] = [
        ArticleCard(title: "探索AI的无限可能：未来科技趋势解析", author: "科技前沿", contentURL: "https://example.com", category: "科技", readingTime: 5, likes: 324, isBookmarked: false, excerpt: "人工智能正在重塑我们的世界，从日常生活到工作方式，AI的影响无处不在..."),
        ArticleCard(title: "青春旅行指南：最值得去的10个城市", author: "旅行达人", contentURL: "https://example.com", category: "旅行", readingTime: 8, likes: 567, isBookmarked: true, excerpt: "背上行囊，开启一场说走就走的旅行，这些城市绝对不能错过..."),
        ArticleCard(title: "健康生活新主张：年轻人的养生之道", author: "健康专家", contentURL: "https://example.com", category: "健康", readingTime: 6, likes: 423, isBookmarked: false, excerpt: "在快节奏的现代生活中，保持身心健康比以往任何时候都更重要..."),
        ArticleCard(title: "美食探店指南：隐藏在城市角落的宝藏小店", author: "美食家", contentURL: "https://example.com", category: "美食", readingTime: 4, likes: 289, isBookmarked: true, excerpt: "每个城市都有那么几家隐藏的美食宝地，等待着被发现..."),
        ArticleCard(title: "大学生活攻略：如何度过充实的校园时光", author: "学长学姐", contentURL: "https://example.com", category: "教育", readingTime: 7, likes: 612, isBookmarked: false, excerpt: "大学四年是人生中最宝贵的时光，如何让这段时间过得有意义...")
    ]
    
    func fetchData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.featuredArticles = Array(self.sampleCards.prefix(3))
            self.recentArticles = self.sampleCards
            self.isLoading = false
        }
    }
}

// MARK: - 文章卡片组件
struct ArticleCardView: View {
    let card: ArticleCard
    let fixedHeight: Bool
    @State private var isPressed = false
    @State private var isBookmarked: Bool
    
    init(card: ArticleCard, fixedHeight: Bool = false) {
        self.card = card
        self.fixedHeight = fixedHeight
        self._isBookmarked = State(initialValue: card.isBookmarked)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部渐变区域
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [
                        card.categoryColor.opacity(0.3),
                        card.categoryColor.opacity(0.7),
                        card.categoryColor
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: fixedHeight ? 160 : 120)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: card.categoryIcon)
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.white.opacity(0.3))
                        .padding()
                }
                
                // 收藏按钮
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isBookmarked.toggle()
                    }
                } label: {
                    Image(systemName: isBookmarked ? "heart.fill" : "heart")
                        .foregroundColor(isBookmarked ? .pink : .white)
                        .font(.system(size: 16, weight: .medium))
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding()
                .scaleEffect(isBookmarked ? 1.1 : 1.0)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // 内容区域
            VStack(alignment: .leading, spacing: 8) {
                // 分类标签
                HStack {
                    Label(card.category, systemImage: card.categoryIcon)
                        .font(.caption)
                        .foregroundColor(card.categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(card.categoryColor.opacity(0.1), in: Capsule())
                    
                    Spacer()
                    
                    Text("\(card.readingTime)分钟")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // 标题
                Text(card.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                // 摘要（仅在非固定高度时显示）
                if !fixedHeight {
                    Text(card.excerpt)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 底部信息
                HStack {
                    // 作者
                    HStack(spacing: 6) {
                        Circle()
                            .fill(card.categoryColor.gradient)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Text(String(card.author.prefix(1)))
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        
                        Text(card.author)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // 点赞数
                    Label("\(card.likes)", systemImage: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(isPressed ? 0.2 : 0.1), radius: isPressed ? 8 : 4, y: isPressed ? 4 : 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = pressing
            }
        } perform: {}
    }
}

// MARK: - WebView
struct WebView: UIViewRepresentable {
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
    @StateObject private var viewModel = ArticleList()
    @State private var showingSearch = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        .pink.opacity(0.05),
                        .orange.opacity(0.05),
                        .yellow.opacity(0.05),
                        .mint.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // 头部
                        headerSection
                        
                        // 搜索栏
                        if showingSearch {
                            searchSection
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // 精选推荐
                        if !viewModel.featuredArticles.isEmpty {
                            featuredSection
                        }
                        
                        // 最近更新
                        if !viewModel.recentArticles.isEmpty {
                            recentSection
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                }
                
                // 加载指示器
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("加载精彩内容中...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("YoungHub")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("探索青春无限可能 ✨")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // 搜索按钮
                Button {
                    withAnimation(.spring()) {
                        showingSearch.toggle()
                    }
                } label: {
                    Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                
                // 用户头像
                Button {} label: {
                    Circle()
                        .fill(LinearGradient(colors: [.pink, .orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("Y")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .shadow(color: .pink.opacity(0.3), radius: 4, y: 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - 搜索区域
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索有趣的内容...", text: $searchText)
            
            if !searchText.isEmpty {
                Button("清除", action: { searchText = "" })
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    // MARK: - 精选推荐区域
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("✨ 精选推荐")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("编辑为你精心挑选")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("更多") {}
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredArticles) { card in
                        NavigationLink {
                            if let url = URL(string: card.contentURL) {
                                WebView(url: url)
                                    .navigationTitle("文章详情")
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        } label: {
                            ArticleCardView(card: card, fixedHeight: true)
                                .frame(width: 250, height: 300)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 最近更新区域
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("🔥 最近更新")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("新鲜出炉的优质内容")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            LazyVStack(spacing: 16) {
                ForEach(viewModel.recentArticles) { card in
                    NavigationLink {
                        if let url = URL(string: card.contentURL) {
                            WebView(url: url)
                                .navigationTitle("文章详情")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    } label: {
                        ArticleCardView(card: card)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    ContentView()
}