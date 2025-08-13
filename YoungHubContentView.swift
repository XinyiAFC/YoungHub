import SwiftUI

struct YoungHubContentView: View {
    @State private var selectedCategory = "推荐"
    @State private var isRefreshing = false
    
    let categories = ["推荐", "科技", "生活", "创意", "成长"]
    let sampleArticles = [
        Article(title: "年轻人如何找到人生方向", author: "成长导师", readCount: "2.3k", category: "成长", imageName: "star.fill", color: .orange),
        Article(title: "AI时代的创新思维", author: "科技前沿", readCount: "1.8k", category: "科技", imageName: "brain.head.profile", color: .blue),
        Article(title: "生活中的小确幸", author: "生活美学", readCount: "3.1k", category: "生活", imageName: "heart.fill", color: .pink),
        Article(title: "创意设计的无限可能", author: "创意工作室", readCount: "1.5k", category: "创意", imageName: "paintbrush.fill", color: .purple),
        Article(title: "高效学习的秘密武器", author: "学习达人", readCount: "4.2k", category: "成长", imageName: "book.fill", color: .green)
    ]
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.6, blue: 1.0),
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 1.0, green: 0.8, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部标题栏
                headerView
                
                // 分类选择器
                categorySelector
                
                // 文章列表
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(sampleArticles) { article in
                            ArticleCard(article: article)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .refreshable {
                    await refreshData()
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("YoungHub")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("发现属于你的精彩")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                // 搜索功能
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    private func refreshData() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isRefreshing = false
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? .white.opacity(0.3) : .clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

struct ArticleCard: View {
    let article: Article
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // 文章详情
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: article.imageName)
                        .font(.title2)
                        .foregroundColor(article.color)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(article.author)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(article.readCount) 阅读")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack {
                    Text(article.category)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(article.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(article.color.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(article.color)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let readCount: String
    let category: String
    let imageName: String
    let color: Color
}

#Preview {
    YoungHubContentView()
}