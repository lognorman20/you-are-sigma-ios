//
//  ContentView.swift
//  You Are Sigma
//
//  Created by Logan Norman on 7/5/26.
//

import SwiftUI

struct BibleExcerpt: Identifiable {
    let id = UUID()
    let reference: String
    let text: String
}

private let bibleExcerpts: [BibleExcerpt] = [
    BibleExcerpt(
        reference: "John 3:16",
        text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."
    ),
    BibleExcerpt(
        reference: "Psalm 23:1",
        text: "The Lord is my shepherd, I lack nothing."
    ),
    BibleExcerpt(
        reference: "Philippians 4:13",
        text: "I can do all this through him who gives me strength."
    ),
    BibleExcerpt(
        reference: "Proverbs 3:5-6",
        text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight."
    ),
    BibleExcerpt(
        reference: "Romans 8:28",
        text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose."
    ),
    BibleExcerpt(
        reference: "Matthew 11:28",
        text: "Come to me, all you who are weary and burdened, and I will give you rest."
    ),
    BibleExcerpt(
        reference: "Isaiah 41:10",
        text: "So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you; I will uphold you with my righteous right hand."
    ),
    BibleExcerpt(
        reference: "Jeremiah 29:11",
        text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future."
    ),
]

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(bibleExcerpts) { excerpt in
                        ExcerptCard(excerpt: excerpt)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Scripture")
        }
    }
}

private struct ExcerptCard: View {
    let excerpt: BibleExcerpt

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(excerpt.reference)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(excerpt.text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

#Preview {
    ContentView()
}
