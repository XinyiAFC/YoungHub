import SwiftUI

struct FloatingParticles: View {
    @State private var particles: [Particle] = []
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                particle.color.opacity(0.8),
                                particle.color.opacity(0.1)
                            ]),
                            center: .center,
                            startRadius: 1,
                            endRadius: 15
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .animation(
                        .easeInOut(duration: particle.duration)
                        .repeatForever(autoreverses: true),
                        value: particle.scale
                    )
            }
        }
        .onReceive(timer) { _ in
            addParticle()
        }
        .onAppear {
            // 初始化一些粒子
            for _ in 0..<5 {
                addParticle()
            }
        }
    }
    
    private func addParticle() {
        let newParticle = Particle()
        particles.append(newParticle)
        
        // 移除老的粒子
        if particles.count > 15 {
            particles.removeFirst()
        }
        
        // 让粒子淡出
        DispatchQueue.main.asyncAfter(deadline: .now() + newParticle.lifetime) {
            if let index = particles.firstIndex(where: { $0.id == newParticle.id }) {
                particles.remove(at: index)
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let size: CGFloat
    let duration: Double
    let lifetime: Double
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    
    init() {
        self.position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
        )
        
        let colors: [Color] = [.pink, .orange, .yellow, .mint, .cyan, .purple]
        self.color = colors.randomElement() ?? .pink
        
        self.size = CGFloat.random(in: 8...25)
        self.duration = Double.random(in: 3...8)
        self.lifetime = Double.random(in: 5...12)
        self.scale = CGFloat.random(in: 0.3...1.2)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1)
            .ignoresSafeArea()
        
        FloatingParticles()
    }
}