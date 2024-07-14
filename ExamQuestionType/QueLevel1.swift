//
//  QueLevel1.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/21.
//

import UIKit

class QueLevel1: NSObject {
    
    let name: String
    
    let descri: String?
    
    let queLevel2Arr: [QueLevel2]
    
    init(name: String, descri: String?, queLevel2Arr: [QueLevel2]) {
        self.name = name
        self.descri = descri
        self.queLevel2Arr = queLevel2Arr
    }
}

extension QueLevel1 {
    
    static var closeModel: QueLevel1 {
        .init(name: "完形填空", descri: "阅读下面短文，从每题所给的A、B、C、D四个选项中选出可以填入空白处的最佳选项。", queLevel2Arr: [
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: [
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["B"], options: ["equal", "unique", "passive", "eager"], type: .Select, no: "1", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["C"], options: ["contact", "theme", "difficulties", "comfort"], type: .Select, no: "2", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["D"], options: ["hang over", "take in", "show off", "smooth out"], type: .Select, no: "3", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["A"], options: ["add", "escape", "attract", "prove"], type: .Select, no: "4", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["D"], options: ["contribute", "attack", "concentrate", "share"], type: .Select, no: "5", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["A"], options: ["move", "advance", "focus", "exchange"], type: .Select, no: "6", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["C"], options: ["which", "that", "where", "when"], type: .Select, no: "7", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["B"], options: ["viewed", "guided", "argued", "suffered"], type: .Select, no: "8", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["A"], options: ["responsible", "original", "secure", "positive"], type: .Select, no: "9", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["B"], options: ["Serbia", "China", "Bosnia", "Italy"], type: .Select, no: "10", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["C"], options: ["stress", "potential", "opportunity", "strength"], type: .Select, no: "11", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["D"], options: ["at", "for", "to", "against"], type: .Select, no: "12", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["C"], options: ["design", "judge", "play", "explode"], type: .Select, no: "13", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["B"], options: ["leaving", "graduating", "volunteering", "struggling"], type: .Select, no: "14", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk mlen=\"3\" mstyle></blk></p>", correctAnswers: ["D"], options: ["response", "judge", "play", "challenges"], type: .Select, no: "15", isNormal: true)
            ], content: "<p>        It is an honor for me to give this speech as one of the graduating students and welcome you to this special Graduating Ceremony 2020 in Tsinghua University.</p><p>        This is a （1）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>moment. We are stepping up to another period of our lives at a time of great hardship and global （2）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>. Tsinghua keeps in mind its global family, and hopes this ceremony will help （3）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>sad memories, refresh beautiful ones and （4）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>more wonderful memories into our lives.</p><p>        Each of us has different stories to share, of amazing life experiences and challenges. Please allow me to （5）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>with you the course of my journey which has made me what I am today.</p><p>        I was born in the middle of war, which caused my family to （6）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>Serbia for three years. When the war ended, we returned to Bosnia （7）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>I was unfortunately raised by a single parent. My mother, who is and will ever be my heroine, was the only figure who （8）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>me, supported me and kept me on the right way. I thanked her so much because only she is （9）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>for a huge part of my success. I will always remember her teachings, “to complain less and always find solutions at the price of whatever it takes”, which brought me to （10）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>, an ancient land of new hopes.</p><p>        During the COVID-19 outbreak, I got the best （11）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>to understand China. I saw millions of people united with one goal—to win the battle （12）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>this epidemic(流行病). Everyone has a role to （13）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>against the virus. In Tsinghua, I played a little but necessary role.</p><p>        Friends, we are now （14）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>from one of the world\'s best universities. Let us accept new （15）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>, think beyond our limits and keep in mind the truth of life.</p>", correctAnswers: nil, options: nil, type: .SelectFillBlank, no: nil, isNormal: false)
        ])
    }
    
    static var readComprehensionModel: QueLevel1 {
        .init(name: "阅读理解", descri: "阅读下列短文，从每题所给的A、B、C、D四个选项中选出最佳选项。", queLevel2Arr: [
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: [
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>What do the underlined words \"that problem\" in Paragraph 2 refer to?<blk  mlen=\"3\" mstyle></blk></p>", correctAnswers: ["C"], options: ["Few medical resources.", "Wrong ways to deliver vaccines.", "Lack of vaccination record-keeping.", "No vaccinations required in developing countries."], type: .Select, no: "1", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>What can we learn about quantum dots?<blk  mlen=\"3\" mstyle></blk></p>", correctAnswers: ["A"], options: ["They keep a record of the vaccination.", "They need to be connected to a database.", "They give away one\'s personal information.", "They can read light produced by smartphones."], type: .Select, no: "2", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>How will health providers access patients\' past vaccinations?<blk  mlen=\"3\" mstyle></blk></p>", correctAnswers: ["B"], options: ["By reading the QR code.", "By scanning the design.", "By interpreting external records.", "By increasing microneedles."], type: .Select, no: "3", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>What do the researchers expect of the new technology?<blk  mlen=\"3\" mstyle></blk></p>", correctAnswers: ["D"], options: ["It will be cost-saving.", "It will hit the market soon.", "It may ensure the accuracy of data.", "It may bring changes to medical care."], type: .Select, no: "4", isNormal: true)
            ], content: "<p>        Global health experts say that each year some of the 1.5 million people die from vaccine-preventable diseases due to gaping holes in medical record-keeping, especially in developing countries where resources to properly document immunizations（免疫接种）may be lacking．</p><p>        To solve <u>that problem</u>, researchers headed by a team at the Massachusetts Institute of Technology（MIT）have invented a way to deliver vaccines（疫苗）through a microneedle <i>patch</i>（贴片）that is buried in the skin. It\'s a record that can\'t be seen, written in <b>quantum dots</b>（量子点）that contain vaccination history and give off light only readable by a specially equipped smartphone. The scientists say it doesn\'t require any link to a database and it doesn\'t tie into any personal information.</p><p>        For now, the patch can only contain a handful of simple shapes. But adding more microneedles could make the designs more complex, potentially conveying information about a vaccination\'s date, dosage and more. From there, reading the dots becomes a lot like scanning a QR code（二维码）. These designs could be scanned and interpreted by smartphones, and someday allow health providers to access patients\' past vaccinations without chaos of external records．</p><p>        The next step, before trials in people, is to test its practicability among experts in the field. The researchers now plan to work with health care workers in developing nations in Africa to get input on the best way to carry out this type of vaccination record-keeping．</p><p>        \"Ultimately, we believe that this invisible \'on-body\' technology opens up new possibilities for data storage and biosensing applications that could influence the way medical care is provided, especially in the developing world,\" the researchers conclude．</p>", correctAnswers: nil, options: nil, type: .Select, no: nil, isNormal: false)
        ])
    }
    
    static var essayFillBlankModel: QueLevel1 {
        .init(name: "短文填空", descri: "阅读下面短文，在空白处填入适当的单词或括号内单词的正确形式。", queLevel2Arr: [
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>        Tu Youyou was awarded with Nobel Prize for Physiology or Medicine in 2015, because she has discovered artemisinin, which（1）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>(use) as a crucial new treatment for malaria to save millions of people.</p><p>        Born in Ningbo, China, she graduated（2）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>Peking University Medical School in 1955. She was among the first researchers（3）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>(choose) for the objective of discovering a new treatment for malaria. At first, she went to Hainan because there was more malaria（4）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>(patient). When she headed the project in 1969, she decided to find traditional（5）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>(botany) treatments for the disease, so her team examined over 2, 000 old medical texts and evaluated 280, 000 plants, from（6）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>they tested 380 distinct ancient Chinese medical treatments.</p><p>        Though Tu\'s team tested dried wormwood leaves and tried the liquid obtained by（7）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>(boil) fresh wormwood, they failed in vain. However, Tu didn\'t acknowledge defeat and analyzed the medical texts again, finding a new way（8）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>(treat) the wormwood. After failing over 190 times, the team（9）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>(final) succeeded in 1971. This medicine, which was called artemisinin, soon became a standard treatment for malaria.</p><p>        Tu owed the honor to the efforts of a team and she felt it（10）<blk mlen=\"3\"  mstyle=\"underline\" ></blk>honor to spread traditional Chinese medicine around the world.</p>", correctAnswers: ["was used", "from", "chosen", "patients", "botanical", "which", "boiling", "to treat", "finally", "an"], options: nil, type: .FillBlank, no: nil, isNormal: true)
        ])
    }
    
    static var scenarioModel: QueLevel1 {
        .init(name: "情景对话", descri: "根据场景填空", queLevel2Arr: [
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<table border=\"1\"><tbody><tr><td rowspan=\"6\" width=\"62\"><p>Kate</p></td><td width=\"252\"><p>How old is she?</p></td><td width=\"239\"><p>12.</p></td></tr><tr><td width=\"252\"><p>What is her favorite sport?</p></td><td width=\"239\"><p>Swimming.</p></td></tr><tr><td width=\"252\"><p><blk></blk> <blk></blk> has she been doing the sport?</p></td><td width=\"239\"><p>6 years.</p></td></tr><tr><td width=\"252\"><p>Why does she like it?</p></td><td width=\"239\"><p>Because her <blk></blk> <blk></blk> is Zhang Yufei.</p></td></tr><tr><td width=\"252\"><p>What\'s her goal?</p></td><td width=\"239\"><p>To be a <blk></blk> swimmer.</p></td></tr><tr><td width=\"252\"><p>What will she do in the future?</p></td><td width=\"239\"><p>Try <blk></blk> and <blk></blk>.</p></td></tr></tbody></table>", correctAnswers: nil, options: nil, type: .FillBlank, no: nil, isNormal: true)
        ])
    }
    
    static var wordPracticeModel: QueLevel1 {
        .init(name: "词汇专练", descri: "根据英文释义填写对应的单词。", queLevel2Arr: [
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: [
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk  mlen=\"3\" mstyle=\"underline\"></blk> (adj.) extremely important, because it will affect other things</p>", correctAnswers: ["crucial"], options: nil, type: .FillBlank, no: "1", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk  mlen=\"3\" mstyle=\"underline\"></blk> (adj.) connected with education, especially studying in schools and universities</p>", correctAnswers: ["academic"], options: nil, type: .FillBlank, no: "2", isNormal: true),
                .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p><blk  mlen=\"3\" mstyle=\"underline\"></blk> (v.) to form an opinion of the amount, value or quality of sth after thinking about it carefully</p>", correctAnswers: ["evaluate"], options: nil, type: .FillBlank, no: "3", isNormal: true)
            ], content: "<p>crucial       flow      academic      patent      conclusion</p><p>evaluate     politician   defeat         device     remarkable</p>", correctAnswers: nil, options: nil, type: .FillBlank, no: nil, isNormal: false)
        ])
    }
    
    static var grammarPracticeModel: QueLevel1 {
        .init(name: "语法专练", descri: "请从A、B、C、D四个选项中选择正确的答案。", queLevel2Arr: [
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>Celeste Ng\'s latest book, ___ plot is quite new and original, has received a lot of attention.<blk mlen=\"3\"   ></blk></p>", correctAnswers: ["C"], options: ["which", "where", "whose", "that"], type: .Select, no: "1", isNormal: true),
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>___ is known to everybody, the moon travels around the earth once every month.<blk     mlen=\"3\" mstyle></blk></p>", correctAnswers: ["C"], options: ["Which", "That", "As", "What"], type: .Select, no: "2", isNormal: true),
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>I walk through the doors into the waiting area, ___ there\'s a familiar atmosphere of boredom and tension.<blk  mlen=\"3\" mstyle></blk></p>", correctAnswers: ["D"], options: ["which", "that", "whose", "where"], type: .Select, no: "3", isNormal: true)
        ])
    }
    
    static var essayModel: QueLevel1 {
        .init(name: "书面表达", descri: "一、请根据下面的提示写 一封通知书。", queLevel2Arr: [
            .init(videoUrl: nil, voiceUrl: nil, subLevel2: nil, content: "<p>请你以你校学生会的名义写一则关于成立英语阅读俱乐部（English book club）的英语通知，内容包括：</p><p>1.阅读在生活中的重要性；</p><p>2.成立英语阅读俱乐部的目的；</p><p>3.欢迎报名参加及提供建议。</p><p>注意：</p><p>1.词数100左右；</p><p>2.可以适当增加细节，以使行文连贯；</p><table border=\"1\"><tbody><tr><td rowspan=\"6\" width=\"62\"><p>Kate</p></td><td width=\"252\"><p>How old is she?</p></td><td width=\"239\"><p>12.</p></td></tr><tr><td width=\"252\"><p>What is her favorite sport?</p></td><td width=\"239\"><p>Swimming.</p></td></tr><tr><td width=\"252\"><p>How long has she been doing the sport?</p></td><td width=\"239\"><p><u>       </u> years.</p></td></tr><tr><td width=\"252\"><p>Why does she like it?</p></td><td width=\"239\"><p>Because her <u>   </u><u>   </u> is Zhang Yufei.</p></td></tr><tr><td width=\"252\"><p>What\'s her goal?</p></td><td width=\"239\"><p>To be a <u>        </u> swimmer.</p></td></tr><tr><td width=\"252\"><p>What will she do in the future?</p></td><td width=\"239\"><p>Try <u>       </u> and <u>       </u>.</p></td></tr></tbody></table><p></p><p>转述开头：Kate is twelve years old.</p><p><blk mlen=\"3\"  mstyle=\"underline\" ></blk></p>", correctAnswers: nil, options: nil, type: .Essay, no: nil, isNormal: true)
        ])
    }
}
