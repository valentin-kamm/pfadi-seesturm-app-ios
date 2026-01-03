//
//  WordpressDocumentDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

struct WordpressDocumentDto: Codable {
    var id: String
    var thumbnailUrl: String
    var thumbnailWidth: Int
    var thumbnailHeight: Int
    var title: String
    var url: String
    var published: String
}

extension WordpressDocumentDto {
    func toWordpressDocument() throws -> WordpressDocument {
        
        let publishedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: published)
        
        return WordpressDocument(
            id: id,
            thumbnailUrl: thumbnailUrl,
            thumbnailWidth: thumbnailWidth,
            thumbnailHeight: thumbnailHeight,
            title: title,
            documentUrl: url,
            published: publishedDate,
            publishedFormatted: DateTimeUtil.shared.formatDate(
                date: publishedDate,
                format: "EEEE, d. MMMM yyyy",
                timeZone: .current,
                type: .relative(withTime: true)
            )
        )
    }
}
