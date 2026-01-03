//
//  DummyData.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.06.2025.
//
import Foundation

//#if DEBUG
struct DummyData {
    
    static let oldDate = Date.init(timeIntervalSince1970: 1739297798)
    static let mediumDate = Date.init(timeIntervalSince1970: 1742297798)
    static let newDate = Date.init(timeIntervalSince1970: 1749297798)
    
    static let oldDateFormatted = DateTimeUtil.shared.formatDate(date: oldDate, format: "dd.MM.yyyy", timeZone: .current, type: .absolute)
    static let mediumDateFormatted = DateTimeUtil.shared.formatDate(date: mediumDate, format: "dd.MM.yyyy", timeZone: .current, type: .absolute)
    static let newDateFormatted = DateTimeUtil.shared.formatDate(date: newDate, format: "dd.MM.yyyy", timeZone: .current, type: .absolute)
    
    static let user1Json = """
        {
            "userId": "456",
            "vorname": "Peter",
            "nachname": "Müller",
            "pfadiname": "Tarantula",
            "email": "test@test.ch",
            "role": "hitobito_user",
            "profilePictureUrl": null,
            "created": "2023-01-01T12:00:00Z",
            "createdFormatted": "01.01.2023",
            "modified": "2023-01-01T12:00:00Z",
            "modifiedFormatted": "01.01.2023"
        }
    """
    static let user2Json = """
        {
            "userId": "456",
            "vorname": "Maia",
            "nachname": "Tanner",
            "pfadiname": null,
            "email": "test@test2.ch",
            "role": "hitobito_user",
            "profilePictureUrl": null,
            "created": "2023-06-01T12:00:00Z",
            "createdFormatted": "01.06.2023",
            "modified": "2023-06-01T12:00:00Z",
            "modifiedFormatted": "01.06.2023"
        }
    """
    static let user3Json = """
        {
            "userId": "789",
            "vorname": "Hans",
            "nachname": "Blatter",
            "pfadiname": "Elch",
            "email": "test@test3.ch",
            "role": "hitobito_user",
            "profilePictureUrl": "https://s3.eu-west-2.amazonaws.com/img.creativepool.com/files/candidate/portfolio/_w680/641887.jpg",
            "created": "2024-01-01T12:00:00Z",
            "createdFormatted": "01.01.2024",
            "modified": "2024-01-01T12:00:00Z",
            "modifiedFormatted": "01.01.2024"
        }
    """
    static let user1 = try! FirebaseHitobitoUser(try! FirebaseHitobitoUserDto(jsonString: user1Json))
    static let user2 = try! FirebaseHitobitoUser(try! FirebaseHitobitoUserDto(jsonString: user2Json))
    static let user3 = try! FirebaseHitobitoUser(try! FirebaseHitobitoUserDto(jsonString: user3Json))
    
    static let documents: [WordpressDocument] = try! JSONDecoder().decode(
        [WordpressDocumentDto].self,
        from: """
                [
                  {
                    "id": "24644",
                    "thumbnailUrl": "https://seesturm.ch/wp-content/uploads/2025/05/Infobroschuere-pdf-212x300.jpg",
                    "thumbnailWidth": 212,
                    "thumbnailHeight": 300,
                    "title": "Infobroschüre Pfadi Seesturm",
                    "url": "https://seesturm.ch/wp-content/uploads/2025/05/Infobroschuere.pdf",
                    "published": "2025-05-12T19:08:28+00:00"
                  },
                  {
                    "id": "24261",
                    "thumbnailUrl": "https://seesturm.ch/wp-content/uploads/2024/12/Jahresprogramm_2025-pdf-212x300.jpg",
                    "thumbnailWidth": 212,
                    "thumbnailHeight": 300,
                    "title": "Jahresprogramm 2025",
                    "url": "https://seesturm.ch/wp-content/uploads/2024/12/Jahresprogramm_2025.pdf",
                    "published": "2024-12-17T20:13:55+00:00"
                  },
                  {
                    "id": "23410",
                    "thumbnailUrl": "https://seesturm.ch/wp-content/uploads/2024/05/Beitrittserkaerung-pdf-212x300.jpg",
                    "thumbnailWidth": 212,
                    "thumbnailHeight": 300,
                    "title": "Beitrittserklärung Pfadi Seesturm",
                    "url": "https://seesturm.ch/wp-content/uploads/2024/05/Beitrittserkaerung.pdf",
                    "published": "2024-05-07T19:53:53+00:00"
                  },
                  {
                    "id": "18896",
                    "thumbnailUrl": "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau-pdf-212x300.jpg",
                    "thumbnailWidth": 212,
                    "thumbnailHeight": 300,
                    "title": "Infobroschüre Pfadi Thurgau",
                    "url": "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau.pdf",
                    "published": "2022-04-22T13:26:20+00:00"
                  }
                ]
        """.data(using: .utf8)!
    ).map { try! $0.toWordpressDocument()}
    
    static let foodOrders = [
        FoodOrder(
            id: UUID().uuidString,
            itemDescription: "Döner",
            totalCount: 1,
            userIds: ["123"],
            users: [user1],
            ordersString: "Döner 1x Test"
        ),
        FoodOrder(
            id: UUID().uuidString,
            itemDescription: "Dürüm",
            totalCount: 2,
            userIds: ["123", "789"],
            users: [user1, user3],
            ordersString: "Dürüm 2x Test"
        ),
        FoodOrder(
            id: UUID().uuidString,
            itemDescription: "Pizza",
            totalCount: 1,
            userIds: ["456"],
            users: [user2],
            ordersString: "Dürüm 1x Test"
        )
    ]
    
    static let schoepflialarmReaction1 = SchoepflialarmReaction(
        id: UUID().uuidString,
        created: oldDate,
        modified: oldDate,
        createdFormatted: oldDateFormatted,
        modifiedFormatted: oldDateFormatted,
        user: user1,
        reaction: .coming
    )
    static let schoepflialarmReaction2 = SchoepflialarmReaction(
        id: UUID().uuidString,
        created: mediumDate,
        modified: mediumDate,
        createdFormatted: mediumDateFormatted,
        modifiedFormatted: mediumDateFormatted,
        user: user2,
        reaction: .notComing
    )
    static let schoepflialarmReaction3 = SchoepflialarmReaction(
        id: UUID().uuidString,
        created: newDate,
        modified: newDate,
        createdFormatted: newDateFormatted,
        modifiedFormatted: newDateFormatted,
        user: user3,
        reaction: .coming
    )
    
    static let schoepflialarm = Schoepflialarm(
        id: UUID().uuidString,
        created: oldDate,
        modified: oldDate,
        createdFormatted: oldDateFormatted,
        modifiedFormatted: oldDateFormatted,
        message: "Testalarm für Preview in Android Studio und XCode (extra ein bisschen länger)",
        user: user1,
        reactions: [schoepflialarmReaction1, schoepflialarmReaction2, schoepflialarmReaction3]
    )
    
    static let allDayOneDayEvent: GoogleCalendarEvent = try! GoogleCalendarEventDto(
        id: "02i2p1qa6lealcck1mb1sguldk",
        summary: "Keine Aktivitäten für alle Stufen!",
        description: "Da sich das Leitungsteam an einem kantonalen Anlass weiterbildet, fallen die Aktivitäten an diesem Samstag aus.",
        location: "Pfadiheim Neukirch (Egnach), Amriswilerstrasse 31, 9315 Egnach, Schweiz",
        created: "2022-08-28T15:25:45.701Z",
        updated: "2022-08-28T15:25:45.726Z",
        start: GoogleCalendarEventStartEndDto(
            dateTime: nil,
            date: "2022-09-24"
        ),
        end: GoogleCalendarEventStartEndDto(
            dateTime: nil,
            date: "2022-09-25"
        )
    ).toGoogleCalendarEvent()
    
    static let allDayMultiDayEvent = try! GoogleCalendarEventDto(
        id: "3c4904s4q0dj4ldtc149kvq56m",
        summary: "Weihnachtsferien",
        description: "Keine Pfadi",
        location: nil,
        created: "2022-08-28T15:25:45.701Z",
        updated: "2022-08-28T15:25:45.726Z",
        start: GoogleCalendarEventStartEndDto(
            dateTime: nil,
            date: "2022-12-24"
        ),
        end: GoogleCalendarEventStartEndDto(
            dateTime: nil,
            date: "2023-01-08"
        )
    ).toGoogleCalendarEvent()
    
    static let oneDayEvent = try! GoogleCalendarEventDto(
        id: "17v15laf167s75oq47elh17a3t",
        summary: "Pfadi-Chlaus",
        description: "Ob uns wohl der Pfadi-Chlaus dieses Jahr wieder viele Nüssli und Schöggeli bringt? Die genauen Zeiten werden später kommuniziert.",
        location: "Geiserparkplatz",
        created: "2022-08-28T15:25:45.701Z",
        updated: "2022-08-27T15:19:45.726Z",
        start: GoogleCalendarEventStartEndDto(
            dateTime: "2022-12-10T13:00:00Z",
            date: nil
        ),
        end: GoogleCalendarEventStartEndDto(
            dateTime: "2022-12-10T15:00:00Z",
            date: nil
        )
    ).toGoogleCalendarEvent()
    
    static let multiDayEvent = try! GoogleCalendarEventDto(
        id: "429ri9n9l4ic0q9c00q5tj3hgf",
        summary: "Wolfsstufen-Weekend",
        description: "Die Wolfsstufe erlebt zusammen mit den Prinzen und dem Froschkönig ein spannendes Weekend. Sei auch du dabei und melde dich an!",
        location: nil,
        created: "2022-08-28T15:25:45.701Z",
        updated: "2022-08-28T15:25:45.726Z",
        start: GoogleCalendarEventStartEndDto(
            dateTime: "2022-10-01T08:00:00Z",
            date: nil
        ),
        end: GoogleCalendarEventStartEndDto(
            dateTime: "2022-10-02T09:00:00Z",
            date: nil
        )
    ).toGoogleCalendarEvent()
    
    static let aktivitaetTemplate1 = AktivitaetTemplate(
        id: UUID().uuidString,
        created: newDate,
        modified: newDate,
        stufe: .pio,
        description: """
                <div>
                <div>
                <div><b>Anfang</b>: 10:00 Uhr, Pfadiheim</div>
                </div>
                <div><b>Ende</b>: 12:00 Uhr, Pfadiheim</div>
                <div><b>Motto</b>: Süess oder salzig?</div>
                <div><b>Mitnehmen</b>: Z’Trinke, z'Nüni, Finke</div>
                <div><b>Kleidung</b>: dem Wetter entsprechend</div>
                <div>&nbsp;</div>
                </div>
                <div style="caret-color: #000000; color: #000000; font-style: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px; -webkit-tap-highlight-color: rgba(26, 26, 26, 0.3); -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; text-decoration: none;">
                <div>&nbsp;</div>
                <div><b>Fragen/Anmeldung:</b></div>
                <div>Dominique Vogt v/o Mulan</div>
                <div><a href="mailto:mulan@seesturm.ch" target="_blank" rel="noopener">mulan@seesturm.ch</a></div>
                <div>Oder direkt in der Pfadi Seesturm App</div>
                </div>
                <div>&nbsp;</div>
            """
    )
    static let aktivitaetTemplate2 = AktivitaetTemplate(
        id: UUID().uuidString,
        created: mediumDate,
        modified: mediumDate,
        stufe: .pio,
        description: """
                <div>&nbsp;</div>
                <div>&nbsp;</div>
                <div><b>Melde dich jetzt für das Pfila an! Hier findest du die&nbsp;<a href="https://1drv.ms/b/c/14a946e93845aa27/ERY7Ge-INglIk4Iv3M7nnAUB2YLBbUgqPMB6Bdh_J2PUKg">Anmeldung fürs Pfila</a>.&nbsp;</b></div>
                <div><b>&nbsp;</b></div>
                <div><b>Anfang</b>: 10:00 Pfadiheim</div>
                <div><b>Ende</b>: 12:00 Pfadiheim</div>
                <div><b>Motto</b>: Tag der guten Tat!</div>
                <div><b>Mitnehmen</b>: Sackmesser, pro Kind einen 6er-Eierkarton leer, einen kleinen Plastiksack, Z' Trinken</div>
                <div><b>Anziehen</b>: Pfadikrawatte, Zeckenschutz, dem Wetter entsprechend</div>
                <div>&nbsp;</div>
                <div style="caret-color: #000000; color: #000000; font-style: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px; -webkit-tap-highlight-color: rgba(26, 26, 26, 0.3); -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; text-decoration: none;">
                <div>
                <div>————————–</div>
                </div>
                <div><b>Fragen und Abmeldung:</b></div>
                <div>Ladina Kobler v/o Chili</div>
                <div>Tel: 078 734 53 85</div>
                <div>oder in der Pfadi Seesturm App</div>
                </div>
                <div>&nbsp;</div>
            """
    )
    
    static let aktivitaet1 = try! GoogleCalendarEventDto(
        id: "17v15laf167s75oq47elh17a3t",
        summary: "Biberstufen-Aktivität",
        description: "Ob uns wohl der Pfadi-Chlaus dieses Jahr wieder viele Nüssli und Schöggeli bringt? Die genauen Zeiten werden später kommuniziert.",
        location: "Geiserparkplatz",
        created: "2022-08-28T15:25:45.701Z",
        updated: "2022-09-28T15:35:45.726Z",
        start: GoogleCalendarEventStartEndDto(
            dateTime: "2025-04-10T13:00:00Z",
            date: nil
        ),
        end: GoogleCalendarEventStartEndDto(
            dateTime: "2025-04-10T15:00:00Z",
            date: nil
        )
    ).toGoogleCalendarEvent()
    static let aktivitaet2 = try! GoogleCalendarEventDto(
        id: "17v15laf167s75oasdf47elh17a3t",
        summary: "Biberstufen-Aktivität",
        description: "Ob uns wohl der Pfadi-Chlaus dieses Jahr wieder viele Nüssli und Schöggeli bringt? Die genauen Zeiten werden später kommuniziert.",
        location: "Geiserparkplatz",
        created: "2022-08-28T15:25:45.701Z",
        updated: "2022-08-28T15:19:45.726Z",
        start: GoogleCalendarEventStartEndDto(
            dateTime: "2025-10-10T13:00:00Z",
            date: nil
        ),
        end: GoogleCalendarEventStartEndDto(
            dateTime: "2025-10-10T15:00:00Z",
            date: nil
        )
    ).toGoogleCalendarEvent()
    
    static let abmeldung1 = AktivitaetAnAbmeldung(
        id: "xcvxfdsfgdsf",
        eventId: "17v15laf167s75oq47elh17a3t",
        uid: nil,
        vorname: "Seppli",
        nachname: "Meier",
        type: .abmelden,
        stufe: .biber,
        created: Date(),
        modified: Date(),
        createdString: "Heute",
        modifiedString: "Morgen"
    )
    static let abmeldung2 = AktivitaetAnAbmeldung(
        id: "423wewerwer",
        eventId: "17v15laf167s75oq47elh17a3tsdfsf",
        uid: nil,
        vorname: "Peter",
        nachname: "Fatzer",
        type: .anmelden,
        stufe: .biber,
        created: Date(),
        modified: Date(),
        createdString: "Heute",
        modifiedString: "Morgen"
    )
    static let abmeldung3 = AktivitaetAnAbmeldung(
        id: "23423",
        eventId: "17v15laf167s75oq47elh17a3t",
        uid: nil,
        vorname: "Hans",
        nachname: "Müller",
        type: .abmelden,
        stufe: .wolf,
        created: Date(),
        modified: Date(),
        createdString: "Heute",
        modifiedString: "Morgen"
    )
    
    static let aktuellPost1 = WordpressPost(
        id: 22566,
        publishedYear: "2023",
        publishedFormatted: "2023-06-28T16:29:56+00:00",
        modifiedFormatted: "2023-06-28T16:35:44+00:00",
        imageUrl: "https://seesturm.ch/wp-content/gallery/sola-2021-pfadi-piostufe/DSC1080.jpg",
        title: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
        titleDecoded: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
        content: "\n<p>Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende <strong>vom 23. und 24. September</strong> unter dem Motto <strong>«Die Piraten vom Bodamicus»</strong>.</p>\n\n\n\n<p>Das KaTre 2023 findet ganz in der Nähe statt, nämlich in <strong>Romanshorn direkt am schönen Bodensee</strong>. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter <a rel=\"noreferrer noopener\" href=\"http: //www.katre.ch\" target=\"_blank\">www.katre.ch</a> oder in unserem Mail vom 2. Juni.</p>\n\n\n\n<p>Leider haben wir bisher erst sehr <strong>wenige Anmeldungen</strong> erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2023/06/KaTre-23__Anmeldetalon.pdf\" target=\"_blank\" rel=\"noreferrer noopener\">Anmeldeformular</a> aus und sendet es <strong>bis am 01. Juli</strong> an <a href=\"mailto: al@seesturm.ch\" target=\"_blank\" rel=\"noreferrer noopener\">al@seesturm.ch</a>.</p>\n\n\n\n<p>Danke!</p>\n",
        contentPlain: "Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende vom 23. und 24. September unter dem Motto «Die Piraten vom Bodamicus».\n\n\n\nDas KaTre 2023 findet ganz in der Nähe statt, nämlich in Romanshorn direkt am schönen Bodensee. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter www.katre.ch oder in unserem Mail vom 2. Juni.\n\n\n\nLeider haben wir bisher erst sehr wenige Anmeldungen erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das Anmeldeformular aus und sendet es bis am 01. Juli an al@seesturm.ch.\n\n\n\nDanke!",
        imageAspectRatio: 5568/3712,
        author: "seesturm"
    )
    static let aktuellPost2 = WordpressPost(
        id: 225366,
        publishedYear: "2023",
        publishedFormatted: "2023-06-28T16:29:56+00:00",
        modifiedFormatted: "2023-06-28T16:35:44+00:00",
        imageUrl: "https://seesturm.ch/wp-content/uploads/2017/11/DSC_4041.sized_.jpg",
        title: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
        titleDecoded: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
        content: "\n<p>Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende <strong>vom 23. und 24. September</strong> unter dem Motto <strong>«Die Piraten vom Bodamicus»</strong>.</p>\n\n\n\n<p>Das KaTre 2023 findet ganz in der Nähe statt, nämlich in <strong>Romanshorn direkt am schönen Bodensee</strong>. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter <a rel=\"noreferrer noopener\" href=\"http: //www.katre.ch\" target=\"_blank\">www.katre.ch</a> oder in unserem Mail vom 2. Juni.</p>\n\n\n\n<p>Leider haben wir bisher erst sehr <strong>wenige Anmeldungen</strong> erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2023/06/KaTre-23__Anmeldetalon.pdf\" target=\"_blank\" rel=\"noreferrer noopener\">Anmeldeformular</a> aus und sendet es <strong>bis am 01. Juli</strong> an <a href=\"mailto: al@seesturm.ch\" target=\"_blank\" rel=\"noreferrer noopener\">al@seesturm.ch</a>.</p>\n\n\n\n<p>Danke!</p>\n",
        contentPlain: "Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende vom 23. und 24. September unter dem Motto «Die Piraten vom Bodamicus».\n\n\n\nDas KaTre 2023 findet ganz in der Nähe statt, nämlich in Romanshorn direkt am schönen Bodensee. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter www.katre.ch oder in unserem Mail vom 2. Juni.\n\n\n\nLeider haben wir bisher erst sehr wenige Anmeldungen erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das Anmeldeformular aus und sendet es bis am 01. Juli an al@seesturm.ch.\n\n\n\nDanke!",
        imageAspectRatio: 5568/3712,
        author: "seesturm"
    )
    static let aktuellPost3 = WordpressPost(
        id: 225646,
        publishedYear: "2023",
        publishedFormatted: "2023-06-28T16:29:56+00:00",
        modifiedFormatted: "2023-06-28T16:35:44+00:00",
        imageUrl: "",
        title: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
        titleDecoded: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
        content: "\n<p>Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende <strong>vom 23. und 24. September</strong> unter dem Motto <strong>«Die Piraten vom Bodamicus»</strong>.</p>\n\n\n\n<p>Das KaTre 2023 findet ganz in der Nähe statt, nämlich in <strong>Romanshorn direkt am schönen Bodensee</strong>. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter <a rel=\"noreferrer noopener\" href=\"http: //www.katre.ch\" target=\"_blank\">www.katre.ch</a> oder in unserem Mail vom 2. Juni.</p>\n\n\n\n<p>Leider haben wir bisher erst sehr <strong>wenige Anmeldungen</strong> erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2023/06/KaTre-23__Anmeldetalon.pdf\" target=\"_blank\" rel=\"noreferrer noopener\">Anmeldeformular</a> aus und sendet es <strong>bis am 01. Juli</strong> an <a href=\"mailto: al@seesturm.ch\" target=\"_blank\" rel=\"noreferrer noopener\">al@seesturm.ch</a>.</p>\n\n\n\n<p>Danke!</p>\n",
        contentPlain: "Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende vom 23. und 24. September unter dem Motto «Die Piraten vom Bodamicus».\n\n\n\nDas KaTre 2023 findet ganz in der Nähe statt, nämlich in Romanshorn direkt am schönen Bodensee. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter www.katre.ch oder in unserem Mail vom 2. Juni.\n\n\n\nLeider haben wir bisher erst sehr wenige Anmeldungen erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das Anmeldeformular aus und sendet es bis am 01. Juli an al@seesturm.ch.\n\n\n\nDanke!",
        imageAspectRatio: 5568/3712,
        author: "seesturm"
    )
    
    static let weather = try! JSONDecoder().decode(
        WeatherDto.self,
        from: """
         {
           "attributionURL": "https://developer.apple.com/weatherkit/data-source-attribution/",
           "readTime": "2025-02-01T15:16:10Z",
           "daily": {
             "forecastStart": "2025-02-01T07:00:00Z",
             "forecastEnd": "2025-02-01T19:00:00Z",
             "conditionCode": "MostlyCloudy",
             "temperatureMax": 4.25,
             "temperatureMin": 0.61,
             "precipitationAmount": 0,
             "precipitationChance": 0,
             "snowfallAmount": 0,
             "cloudCover": 0.74,
             "humidity": 0.83,
             "windDirection": 24,
             "windSpeed": 7.19,
             "sunrise": "2025-02-01T06:48:49Z",
             "sunset": "2025-02-01T16:24:22Z"
           },
           "hourly": [
             {
               "forecastStart": "2025-02-01T05:00:00Z",
               "cloudCover": 0.96,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 1.17,
               "windSpeed": 10.54,
               "windGust": 17.63
             },
             {
               "forecastStart": "2025-02-01T06:00:00Z",
               "cloudCover": 0.97,
               "precipitationType": "clear",
               "precipitationAmount": 10,
               "snowfallAmount": 0,
               "temperature": 1.12,
               "windSpeed": 10.01,
               "windGust": 17.21
             },
             {
               "forecastStart": "2025-02-01T07:00:00Z",
               "cloudCover": 0.97,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 0.66,
               "windSpeed": 8.06,
               "windGust": 15.66
             },
             {
               "forecastStart": "2025-02-01T08:00:00Z",
               "cloudCover": 0.93,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 0.7,
               "windSpeed": 8.09,
               "windGust": 15.55
             },
             {
               "forecastStart": "2025-02-01T09:00:00Z",
               "cloudCover": 0.96,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 1.37,
               "windSpeed": 8.5,
               "windGust": 16.54
             },
             {
               "forecastStart": "2025-02-01T10:00:00Z",
               "cloudCover": 0.95,
               "precipitationType": "clear",
               "precipitationAmount": 20,
               "snowfallAmount": 0,
               "temperature": 2,
               "windSpeed": 8.42,
               "windGust": 16.27
             },
             {
               "forecastStart": "2025-02-01T11:00:00Z",
               "cloudCover": 0.95,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 2.59,
               "windSpeed": 8.13,
               "windGust": 16.17
             },
             {
               "forecastStart": "2025-02-01T12:00:00Z",
               "cloudCover": 0.82,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 3.24,
               "windSpeed": 7.16,
               "windGust": 15.4
             },
             {
               "forecastStart": "2025-02-01T13:00:00Z",
               "cloudCover": 0.59,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 3.69,
               "windSpeed": 6.07,
               "windGust": 14.28
             },
             {
               "forecastStart": "2025-02-01T14:00:00Z",
               "cloudCover": 0.58,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 4.16,
               "windSpeed": 6.54,
               "windGust": 13.83
             },
             {
               "forecastStart": "2025-02-01T15:00:00Z",
               "cloudCover": 0.6,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 4.21,
               "windSpeed": 7.39,
               "windGust": 14.86
             },
             {
               "forecastStart": "2025-02-01T16:00:00Z",
               "cloudCover": 0.59,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 3.68,
               "windSpeed": 7.28,
               "windGust": 13.59
             },
             {
               "forecastStart": "2025-02-01T17:00:00Z",
               "cloudCover": 0.62,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 2.64,
               "windSpeed": 6.46,
               "windGust": 11.82
             },
             {
               "forecastStart": "2025-02-01T18:00:00Z",
               "cloudCover": 0.52,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 2.04,
               "windSpeed": 5.94,
               "windGust": 11.39
             },
             {
               "forecastStart": "2025-02-01T19:00:00Z",
               "cloudCover": 0.46,
               "precipitationType": "clear",
               "precipitationAmount": 0,
               "snowfallAmount": 0,
               "temperature": 1.35,
               "windSpeed": 4.44,
               "windGust": 10.22
             }
           ]
         }
         """.data(using: .utf8)!
    ).toWeather()
    
    static let document1 = WordpressDocument(
        id: "123",
        thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau-pdf-212x300.jpg",
        thumbnailWidth: 212,
        thumbnailHeight: 300,
        title: "Infobroschüre Pfadi Thurgau",
        documentUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau.pdf",
        published: Date(),
        publishedFormatted: "test 2022-04-22T13:26:20+00:00"
    )
    static let document2 = WordpressDocument(
        id: "123",
        thumbnailUrl: "",
        thumbnailWidth: 212,
        thumbnailHeight: 300,
        title: "Infobroschüre Pfadi Thurgau",
        documentUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau.pdf",
        published: Date(),
        publishedFormatted: "test 2022-04-22T13:26:20+00:00"
    )
    
    static let gespeichertePerson1 = GespeichertePerson(
        id: UUID(),
        vorname: "Hans",
        nachname: "Meier",
        pfadiname: "Seppli"
    )
    static let gespeichertePerson2 = GespeichertePerson(
        id: UUID(),
        vorname: "Maria",
        nachname: "Müller",
        pfadiname: nil
    )
    static let gespeichertePerson3 = GespeichertePerson(
        id: UUID(),
        vorname: "Peter",
        nachname: "Mustermann",
        pfadiname: nil
    )
    
    static let leitungsteamMember = LeitungsteamMember(
        id: UUID(),
        name: "Test name / Pfadiname Pfadiname",
        job: "Stufenleitung Pfadistufe",
        contact: "xxx@yyy.ch",
        photo: "https://seesturm.ch/wp-content/uploads/2017/10/Wicky2021-scaled.jpg"
    )
}
//#endif
