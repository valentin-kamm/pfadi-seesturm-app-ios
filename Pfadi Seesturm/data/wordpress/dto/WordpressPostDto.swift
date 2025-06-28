//
//  WordpressPostDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//
import Foundation

struct WordpressPostDto: Identifiable, Codable {
    var id: Int
    var title: String
    var titleDecoded: String
    var content: String
    var contentPlain: String
    var imageUrl: String
    var imageHeight: Int
    var imageWidth: Int
    var author: String
    var published: String
    var modified: String
}

extension WordpressPostDto {
    func toWordpressPost() throws -> WordpressPost {
        
        let targetDisplayTimeZone = TimeZone.current
        let publishedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: published)
        let modifiedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: modified)
        
        return WordpressPost(
            id: id,
            publishedYear: DateTimeUtil.shared.formatDate(
                date: publishedDate,
                format: "yyyy",
                timeZone: targetDisplayTimeZone,
                type: .absolute
            ),
            publishedFormatted: DateTimeUtil.shared.formatDate(
                date: publishedDate,
                format: "EEEE, d. MMMM yyyy",
                timeZone: targetDisplayTimeZone,
                type: .relative(withTime: true)
            ),
            modifiedFormatted: DateTimeUtil.shared.formatDate(
                date: modifiedDate,
                format: "EEEE, d. MMMM yyyy",
                timeZone: targetDisplayTimeZone,
                type: .relative(withTime: true)
            ),
            imageUrl: imageUrl,
            title: title,
            titleDecoded: titleDecoded,
            content: content,
            contentPlain: contentPlain,
            imageAspectRatio: Double(imageWidth) < Double(imageHeight) ? 1.0 : Double(imageWidth) / Double(imageHeight),
            author: author
        )
    }
}
