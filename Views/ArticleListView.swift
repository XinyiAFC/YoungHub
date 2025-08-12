import SwiftUI

struct ArticleListView: View {
    @StateObject private var viewModel = ArticleList() // ViewModel with multiple articles

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 精选推荐区（横滑）
                if !viewModel.featuredArticles.isEmpty {
                    Text("精选推荐")
                        .font(.title2).bold()
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.featuredArticles) { card in
                                if let url = URL(string: card.contentURL) {
                                    NavigationLink(destination: WebView(url: url)) {
                                        ArticleCardView(card: card, fixedTitleHeight: true)
                                            .frame(width: 280, height: 320)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                }

                // 最近更新区（纵向）
                if !viewModel.recentArticles.isEmpty {
                    Text("最近更新")
                        .font(.title2).bold()
                        .padding(.horizontal)

                    VStack(spacing: 20) {
                        ForEach(viewModel.recentArticles) { card in
                            if let url = URL(string: card.contentURL) {
                                NavigationLink(destination: WebView(url: url)) {
                                    ArticleCardView(card: card)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

#Preview {
    NavigationStack {
        ArticleListView()
    }
}