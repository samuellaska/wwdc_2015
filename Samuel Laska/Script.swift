//
//  Script.swift
//  Samuel Laska
//
//  Created by Samuel Laska on 4/26/15.
//  Copyright (c) 2015 Samuel Laska. All rights reserved.
//


class Script {
    
    // Ids & Names
    
    let names: [String: String] = [
        "xxx" : "",             // interviewer
        "sam" : "Samuel Laska",
        "woz" : "Steve Wozniak",
        "cook": "Tim Cook"
    ]
    
    let imageNames: [String : String] = [
        // interviewer is never called
        "sam" : "sam",
        "woz" : "schiller",
        "cook": "cook"
    ]
    
    let bubbles: [String: JSQMessagesBubbleImage] = [
        "xxx" : JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(Script.colorForIndex(7, alpha: 0.9)),
        "sam" : JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(Script.colorForIndex(1, alpha: 0.75)),
        "woz" : JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(Script.colorForIndex(6, alpha: 0.75)),
        "cook": JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(Script.colorForIndex(2, alpha: 0.75)),
    ]
    
    // template    [ id  , message , delay ]
    var messages = [["sam", "Hello!", 1.0]]
    
    var avatars = [String: JSQMessageAvatarImageDataSource]()
    
    init() {
        // init avatars
        for (id, imageName) in imageNames {
            avatars[id] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: imageName), diameter: 30)
        }
        
        // has to init here, because Xcode keeps indexing forever when otherwise
        messages.append(["sam", "I am Sam and you are now part of fully automated interview.", 1.5])
        messages.append(["sam", "Don't worry, this won't take long and wont require much brainpower", 1.5])
        messages.append(["sam", "Questions will be subtly suggested to you ..", 1.5])
        messages.append(["sam", "Like the one down below 👇 \r\n*tap Send*", 0.25])
        
        messages.append(["xxx", "Ok, where are you from?", 1.0])
        messages.append(["sam", "Oh, what a great question! 😏", 1.0])
        messages.append(["sam", "I am from Slovakia, small country in heart of Europe", 1.0])
        messages.append(["sam", "Long story short:", 1.0])
        messages.append(["sam", "heavenly nature, beautiful women and bacon-rich food", 3.0])
        messages.append(["sam", "[vysoke_tatry]", 1.0])
        messages.append(["sam", "[girls]", 1.0])
        messages.append(["sam", "[bryndzove_halusky]", 1.0])
        messages.append(["sam", "#mustVisitCountry 🇸🇰", 1.0])
        messages.append(["sam", "btw. you can tap and zoom images", 1.0])
        
        messages.append(["xxx", "What do you study? 🎓📚", 1.0])
        messages.append(["sam", "I study physics 🔭 ", 1.0])
        messages.append(["sam", "on Comenius University in Bratislava", 2.0])
        messages.append(["sam", "..that is the reason why I made WWDC15 logo spin like some small solar system 😀", 0.5])
        
        messages.append(["xxx", "Physics? Wow 😯 But how did you get to programming?", 1.0])
        messages.append(["sam", "I always wondered how computers work", 1.0])
        messages.append(["sam", "I taught myself when I was ~17", 1.0])
        messages.append(["sam", "First simple static webpages", 1.0])
        messages.append(["sam", "Then more complicated, dynamic stuff 💪", 1.0])
        messages.append(["sam", "HTML, CSS, PHP, MySQL..", 1.0])
        messages.append(["sam", "although lately I am falling in love with meteor.js", 2.5])
        messages.append(["sam", "My biggest web project to date is www.kickresume.com", 1.5])
        messages.append(["sam", "[kickresume]", 1.5])
        messages.append(["sam", "- online design resume builder", 1.0])
        messages.append(["sam", "25K uniques a month", 1.5])
        messages.append(["sam", ".. ads almost cover webhosting costs 😀😂😭", 0.5])
        
        messages.append(["xxx", "What has led you to iOS development? 📱", 1.0])
        
        messages.append(["sam", "I was big fan of Stanford free online compsci courses", 1.5])
        messages.append(["sam", "and I noticed Paul Hegarty's CS193P iOS dev class",1.0])
        messages.append(["sam", "[paul_hegarty]", 2.0])
        messages.append(["sam", "and I got hooked instantly ✊", 1.0])
        messages.append(["sam", "that guy is pure awesome, he puts great effort into his lectures and his explanation skills are top notch 🙏🙌", 4.0])
        messages.append(["sam", "I believe his course is one of the reasons why iOS is so popular between developers", 2.5])
        messages.append(["sam", "Apple should shower him in gold..", 3.0])
        messages.append(["cook", "Ok, understood!", 1.0])
        messages.append(["cook", "I am on it 🛁💵💵💵", 0.5])
        
        messages.append(["xxx", "😆😆😆 \r\nDo you have any notable iOS projects?", 1.5])
        messages.append(["sam", "Yes I do!", 1.0])
        messages.append(["sam", "iLetterz, simple guess word game", 1.0])
        messages.append(["sam", "[iLetterz1]", 1.0])
        messages.append(["sam", "[iLetterz2]", 1.0])
        messages.append(["sam", "my first appstore app, design done also by me 🎨", 1.5])
        messages.append(["sam", "next..", 1.0])
        messages.append(["sam", "I programmed StartupWeekend Bratislava winning  app called Approach", 1.5])
        messages.append(["sam", "[approach]", 1.0])
        messages.append(["sam", "like Tinder, but we matched people over p2p WiFi", 1.0])
        messages.append(["sam", "sounded like a good idea back then.. 😔", 1.0])
        messages.append(["sam", "I am the one in the middle with the closed eyes", 1.0])
        messages.append(["sam", "next..", 1.0])
        messages.append(["sam", "I won third place in Empatica Hackmed Hackathon", 2.0])
        messages.append(["sam", "Empatica makes wristband that measures skin conductivity", 2.0])
        messages.append(["sam", "we made an app using that data to detect level of dehydratation (had scientist in team)", 3.0])
        messages.append(["sam", "dehydratation is big problem for people over 50, because with age you are losing sense to your hydratation levels 💧", 4.0])
        messages.append(["sam", "[empatica]", 1.0])
        messages.append(["sam", "in the end it turned out to be unusable because too many factors were affecting the readings", 3.0])
        messages.append(["sam", "..but it got me interested in wearables and their inpact on health 👍⌚️💜", 0.5])
        
        messages.append(["xxx", "Have you tried WatchKit?", 1.5])
        messages.append(["sam", "Yes!!", 1.0])
        messages.append(["sam", "I made CryptoWatch", 1.0])
        messages.append(["sam", "app showing latest price of cryptocurrencies like Bitcoin, Litecoin, Dogecoin..", 2.0])
        messages.append(["sam", "[list]", 1.0])
        messages.append(["sam", "[bitcoin]", 1.0])
        messages.append(["sam", "little more than 0 downloads 😝", 1.0])
        messages.append(["sam", "but I am still super proud 😎\r\nbecause that is my first app on my own Developer Account 😊", 3.0])
        messages.append(["xxx", "Congrats 👏 \r\nWhat are you working on now?", 1.5])
        messages.append(["sam", "All my free time is going to GoDiscover", 1.0])
        messages.append(["sam", "app that will be like a Tinder for city spots", 1.0])
        messages.append(["sam", "You can swipe through places and create your own city guide in 3 minutes or less", 1.5])
        messages.append(["sam", "[godiscover]", 1.0])
        messages.append(["sam", "(mockup)", 1.0])
        messages.append(["sam", "Should be out in June", 1.0])
        messages.append(["sam", "to be ready for summer 🌞", 1.0])
        messages.append(["xxx", "That would be awesome for photographers - to scout out best looking places!", 1.5])
        messages.append(["sam", "Yes, we have a ton of instagrammers in our waitlist on www.godiscoverapp.co", 1.5])
        messages.append(["sam", "Ok, so this is all I have", 1.5])
        messages.append(["sam", "Thanks for your time 😊", 1.5])
        messages.append(["sam", "I hope to see you at WWDC", 2.0])
        messages.append(["sam", "P.S.", 1.5])
        messages.append(["sam", "I unlocked the textfield for you", 1.5])
        messages.append(["sam", "Anything you now type in and send will be forwarded to my email", 1.5])
        messages.append(["sam", "I would be happy for any feedback", 1.5])
        messages.append(["sam", "If you don't have any, just type in and send \r\ngoodbye\r\n-you will be brought back to homescreen", 1.5])
        messages.append(["sam", "Goodbye from Slovakia ✋😉", 1.5])
        messages.append(["sam", "[samuel]", 1.5])
    }
    
    //MARK:- helper methods
    
    // additional method to keep original data simple to write
    func parseImageName(string: String) -> String {
        let first = string.substringWithRange(Range<String.Index>(start:string.startIndex, end: advance(string.startIndex, 1)))
        let last = string.substringWithRange(Range<String.Index>(start:advance(string.endIndex,-1), end: string.endIndex))
        if (first == "[" && last == "]") {
            return string.substringWithRange(Range<String.Index>(start: advance(string.startIndex, 1), end: advance(string.endIndex,-1)))
        }
        return ""
    }
    
    func isByInterviewer(index: Int) -> Bool {
        if messages[index][0] == "xxx" {
            return true
        }
        return false
    }
    
    //MARK:- WWDC colors
    
    class func colorForIndex(index: Int, alpha: Float) -> UIColor {
        switch (index) {
        case 0: return color(16, g: 63, b: 236, a: alpha)  // blue
        case 7: return color(22, g: 172, b: 162, a: alpha) // green
        case 6: return color(233, g: 124, b: 32, a: alpha) // orange
        case 5: return color(235, g: 67, b: 35, a: alpha)  // red
        case 4: return color(190, g: 28, b: 65, a: alpha)  // red
        case 3: return color(208, g: 57, b: 159, a: alpha) // pink
        case 2: return color(150, g: 32, b: 198, a: alpha) // purple
        case 1: return color(95, g: 33, b: 203, a: alpha)  // violet
        default: return UIColor.blackColor()
        }
    }
    
    class func color(r: Float,g: Float, b: Float, a: Float) -> UIColor {
        return UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a))
    }
}
