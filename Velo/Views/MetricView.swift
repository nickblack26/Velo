import SwiftUI

struct MetricView<Content: View>: View {
	@ViewBuilder var content: () -> Content
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Metric View")
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.lineLimit(1)
			
			content()
				.font(.largeTitle)
				.fontWeight(.semibold)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 12)
				.stroke(
					.secondary.opacity(0.2),
					lineWidth: 1
				)
				.shadow(
					color: .black,
					radius: .init(10),
					x: .init(10),
					y: .init(10),
				)
		}
	}
}

#Preview {
	HStack {
		MetricView {
			Text("12")
		}
		
		MetricView {
			Text("12")
		}
		
		MetricView {
			Text("12")
		}
		
		MetricView {
			Text("12")
		}
	}
	.padding()
}
