import SwiftUI

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
                // 背景渐变（模拟图片）
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
                    // 分类图标
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

// 扩展用于圆角
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

#Preview {
    VStack(spacing: 20) {
        ArticleCardView(card: ArticleCard.sampleCards[0])
            .frame(maxWidth: 350)
        
        ArticleCardView(card: ArticleCard.sampleCards[1], fixedTitleHeight: true)
            .frame(width: 280, height: 320)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}