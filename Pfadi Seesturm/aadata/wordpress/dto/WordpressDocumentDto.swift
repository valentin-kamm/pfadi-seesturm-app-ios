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
        return WordpressDocument(
            id: id,
            thumbnailUrl: thumbnailUrl,
            thumbnailWidth: thumbnailWidth,
            thumbnailHeight: thumbnailHeight,
            title: title,
            url: url,
            published: DateTimeUtil.shared.formatDate(
                date: try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: published),
                format: "EEEE, d. MMMM yyyy",
                withRelativeDateFormatting: true,
                timeZone: .current
            )
        )
    }
}
