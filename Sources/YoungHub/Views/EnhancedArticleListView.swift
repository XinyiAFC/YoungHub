import SwiftUI

struct EnhancedArticleListView: View {
    @StateObject private var viewModel = ArticleList()
    @State private var showingSearch = false
    @State private var searchText = ""
    @State private var refreshing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 动态渐变背景
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // 顶部标题区域
                        headerSection
                        
                        // 搜索栏
                        if showingSearch {
                            searchSection
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // 精选推荐区（横滑）
                        if !viewModel.featuredArticles.isEmpty {
                            featuredSection
                        }
                        
                        // 最近更新区（纵向）
                        if !viewModel.recentArticles.isEmpty {
                            recentSection
                        }
                        
                        // 底部间距
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
    
    // MARK: - 背景渐变
    private var backgroundGradient: some View {
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
    }
    
    // MARK: - 头部区域
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // YoungHub标题
                    Text("YoungHub")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // 副标题
                    Text("探索青春无限可能 ✨")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 搜索和头像按钮
                HStack(spacing: 12) {
                    // 搜索按钮
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
                    
                    // 头像
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
            // 标题
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
                
                // 更多按钮
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
            
            // 横向滚动卡片
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
            // 标题
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
            
            // 纵向卡片列表
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
            // 自定义加载动画
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
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒延迟
        viewModel.refreshData()
        refreshing = false
    }
}

#Preview {
    EnhancedArticleListView()
}