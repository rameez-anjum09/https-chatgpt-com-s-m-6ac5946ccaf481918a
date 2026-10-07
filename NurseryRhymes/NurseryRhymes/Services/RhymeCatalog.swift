import Foundation
import Combine

/// RhymeCatalog is the source of truth for the complete 50 nursery rhymes library.
public final class RhymeCatalog: ObservableObject {
    @Published public var rhymes: [Rhyme] = []
    @Published public var searchText: String = ""
    @Published public var selectedCategory: RhymeCategory = .all

    public static let shared = RhymeCatalog()

    public init() {
        loadCatalog()
    }

    /// Loads the bundled 50 nursery rhymes catalog from JSON.
    public func loadCatalog() {
        if let url = Bundle.main.url(forResource: "rhymes_data", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Rhyme].self, from: data) {
            self.rhymes = decoded
            return
        }

        // Fallback to built-in essential catalog if JSON file is missing in bundle
        self.rhymes = Self.builtInCatalog
    }

    /// Returns the filtered rhymes list applying both search query and category filter.
    public var filteredRhymes: [Rhyme] {
        rhymes.filter { rhyme in
            let matchesCategory: Bool
            if selectedCategory == .all {
                matchesCategory = true
            } else {
                matchesCategory = rhyme.category == selectedCategory
            }

            let matchesSearch: Bool
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = rhyme.title.localizedCaseInsensitiveContains(trimmed) ||
                    (rhyme.lyrics?.localizedCaseInsensitiveContains(trimmed) ?? false)
            }

            return matchesCategory && matchesSearch
        }
    }

    /// Find rhyme by unique ID
    public func rhyme(for id: String) -> Rhyme? {
        rhymes.first(where: { $0.id == id })
    }

    /// Fallback default 50 rhymes catalog ensuring 100% offline availability
    public static var builtInCatalog: [Rhyme] {
        [
            Rhyme(
                id: "twinkle_twinkle",
                title: "Twinkle Twinkle Little Star",
                category: .bedtime,
                assetName: "twinkle_twinkle",
                fullAssetName: "twinkle_twinkle_full",
                audioFileName: "twinkle_twinkle.wav",
                audioDuration: 31.5,
                lyrics: "Twinkle, twinkle, little star,\nHow I wonder what you are!\nUp above the world so high,\nLike a diamond in the sky.\nTwinkle, twinkle, little star,\nHow I wonder what you are!",
                timedLyrics: [
                    LyricSegment(start: 0.0, end: 5.5, text: "Twinkle, twinkle, little star,"),
                    LyricSegment(start: 5.5, end: 11.0, text: "How I wonder what you are!"),
                    LyricSegment(start: 11.0, end: 16.0, text: "Up above the world so high,"),
                    LyricSegment(start: 16.0, end: 21.0, text: "Like a diamond in the sky."),
                    LyricSegment(start: 21.0, end: 26.0, text: "Twinkle, twinkle, little star,"),
                    LyricSegment(start: 26.0, end: 31.5, text: "How I wonder what you are!")
                ]
            ),
            Rhyme(
                id: "baa_baa_black_sheep",
                title: "Baa Baa Black Sheep",
                category: .animals,
                assetName: "baa_baa_black_sheep",
                audioFileName: "baa_baa_black_sheep.wav",
                audioDuration: 26.4,
                lyrics: "Baa, baa, black sheep,\nHave you any wool?\nYes, sir, yes, sir,\nThree bags full;\nOne for the master,\nAnd one for the dame,\nAnd one for the little boy\nWho lives down the lane.",
                timedLyrics: [
                    LyricSegment(start: 0.0, end: 4.8, text: "Baa, baa, black sheep, have you any wool?"),
                    LyricSegment(start: 4.8, end: 9.5, text: "Yes, sir, yes, sir, three bags full;"),
                    LyricSegment(start: 9.5, end: 14.2, text: "One for the master, and one for the dame,"),
                    LyricSegment(start: 14.2, end: 20.0, text: "And one for the little boy who lives down the lane."),
                    LyricSegment(start: 20.0, end: 26.4, text: "Baa, baa, black sheep, have you any wool?")
                ]
            ),
            Rhyme(
                id: "humpty_dumpty",
                title: "Humpty Dumpty",
                category: .playful,
                assetName: "humpty_dumpty",
                lyrics: "Humpty Dumpty sat on a wall,\nHumpty Dumpty had a great fall;\nAll the king's horses and all the king's men\nCouldn't put Humpty together again."
            ),
            Rhyme(
                id: "jack_and_jill",
                title: "Jack and Jill",
                category: .action,
                assetName: "jack_and_jill",
                lyrics: "Jack and Jill went up the hill\nTo fetch a pail of water;\nJack fell down and broke his crown,\nAnd Jill came tumbling after."
            ),
            Rhyme(
                id: "row_your_boat",
                title: "Row Your Boat",
                category: .action,
                assetName: "row_your_boat",
                audioFileName: "row_your_boat.wav",
                audioDuration: 10.7,
                lyrics: "Row, row, row your boat\nGently down the stream,\nMerrily, merrily, merrily, merrily,\nLife is but a dream.",
                timedLyrics: [
                    LyricSegment(start: 0.0, end: 3.2, text: "Row, row, row your boat"),
                    LyricSegment(start: 3.2, end: 6.4, text: "Gently down the stream,"),
                    LyricSegment(start: 6.4, end: 8.8, text: "Merrily, merrily, merrily, merrily,"),
                    LyricSegment(start: 8.8, end: 10.7, text: "Life is but a dream.")
                ]
            ),
            Rhyme(
                id: "old_macdonald",
                title: "Old MacDonald Had a Farm",
                category: .animals,
                assetName: "old_macdonald",
                audioFileName: "old_macdonald.wav",
                audioDuration: 16.2,
                lyrics: "Old MacDonald had a farm, E-I-E-I-O!\nAnd on his farm he had a cow, E-I-E-I-O!\nWith a moo-moo here, and a moo-moo there,\nHere a moo, there a moo, everywhere a moo-moo,\nOld MacDonald had a farm, E-I-E-I-O!",
                timedLyrics: [
                    LyricSegment(start: 0.0, end: 4.5, text: "Old MacDonald had a farm, E-I-E-I-O!"),
                    LyricSegment(start: 4.5, end: 8.5, text: "And on his farm he had a cow, E-I-E-I-O!"),
                    LyricSegment(start: 8.5, end: 12.0, text: "With a moo-moo here, and a moo-moo there,"),
                    LyricSegment(start: 12.0, end: 16.2, text: "Old MacDonald had a farm, E-I-E-I-O!")
                ]
            ),
            Rhyme(id: "hickory_dickory_dock", title: "Hickory Dickory Dock", category: .animals, assetName: "hickory_dickory_dock", lyrics: "Hickory, dickory, dock,\nThe mouse ran up the clock.\nThe clock struck one,\nThe mouse ran down,\nHickory, dickory, dock."),
            Rhyme(id: "mary_had_a_little_lamb", title: "Mary Had a Little Lamb", category: .animals, assetName: "mary_had_a_little_lamb", lyrics: "Mary had a little lamb,\nIts fleece was white as snow;\nAnd everywhere that Mary went,\nThe lamb was sure to go."),
            Rhyme(id: "itsy_bitsy_spider", title: "The Itsy Bitsy Spider", category: .animals, assetName: "itsy_bitsy_spider", lyrics: "The itsy bitsy spider climbed up the waterspout.\nDown came the rain and washed the spider out.\nOut came the sun and dried up all the rain,\nAnd the itsy bitsy spider climbed up the spout again."),
            Rhyme(id: "wheels_on_the_bus", title: "The Wheels on the Bus", category: .action, assetName: "wheels_on_the_bus", lyrics: "The wheels on the bus go round and round,\nRound and round, round and round.\nThe wheels on the bus go round and round,\nAll through the town!"),
            Rhyme(id: "rock_a_bye_baby", title: "Rock-a-bye Baby", category: .bedtime, assetName: "rock_a_bye_baby", lyrics: "Rock-a-bye baby, in the treetop,\nWhen the wind blows, the cradle will rock;\nWhen the bough breaks, the cradle will fall,\nAnd down will come baby, cradle and all."),
            Rhyme(id: "hey_diddle_diddle", title: "Hey Diddle Diddle", category: .playful, assetName: "hey_diddle_diddle", lyrics: "Hey diddle diddle,\nThe cat and the fiddle,\nThe cow jumped over the moon;\nThe little dog laughed to see such sport,\nAnd the dish ran away with the spoon."),
            Rhyme(id: "london_bridge", title: "London Bridge Is Falling Down", category: .action, assetName: "london_bridge", lyrics: "London Bridge is falling down,\nFalling down, falling down.\nLondon Bridge is falling down,\nMy fair lady."),
            Rhyme(id: "five_little_monkeys", title: "Five Little Monkeys", category: .action, assetName: "five_little_monkeys", lyrics: "Five little monkeys jumping on the bed,\nOne fell off and bumped his head.\nMama called the doctor and the doctor said,\n\"No more monkeys jumping on the bed!\""),
            Rhyme(id: "this_little_piggy", title: "This Little Piggy", category: .playful, assetName: "this_little_piggy", lyrics: "This little piggy went to market,\nThis little piggy stayed home,\nThis little piggy had roast beef,\nThis little piggy had none,\nAnd this little piggy cried wee wee wee all the way home!"),
            Rhyme(id: "happy_and_you_know_it", title: "If You're Happy and You Know It", category: .action, assetName: "happy_and_you_know_it", lyrics: "If you're happy and you know it, clap your hands!\nIf you're happy and you know it, clap your hands!\nIf you're happy and you know it,\nAnd you really want to show it,\nIf you're happy and you know it, clap your hands!"),
            Rhyme(id: "ring_around_the_rosie", title: "Ring Around the Rosie", category: .action, assetName: "ring_around_the_rosie", lyrics: "Ring around the rosie,\nA pocket full of posies;\nAshes! Ashes!\nWe all fall down!"),
            Rhyme(id: "five_little_ducks", title: "Five Little Ducks", category: .animals, assetName: "five_little_ducks", lyrics: "Five little ducks went out one day,\nOver the hill and far away.\nMother duck said, \"Quack, quack, quack, quack,\"\nBut only four little ducks came back."),
            Rhyme(id: "three_blind_mice", title: "Three Blind Mice", category: .animals, assetName: "three_blind_mice", lyrics: "Three blind mice, three blind mice,\nSee how they run, see how they run!\nThey all ran after the farmer's wife,\nWho cut off their tails with a carving knife."),
            Rhyme(id: "pop_goes_the_weasel", title: "Pop Goes the Weasel", category: .playful, assetName: "pop_goes_the_weasel", lyrics: "All around the mulberry bush\nThe monkey chased the weasel;\nThe monkey thought 'twas all in good fun,\nPop! goes the weasel."),
            Rhyme(id: "little_bo_peep", title: "Little Bo-Peep", category: .animals, assetName: "little_bo_peep", lyrics: "Little Bo-Peep has lost her sheep,\nAnd can't tell where to find them;\nLeave them alone, and they'll come home,\nWagging their tails behind them."),
            Rhyme(id: "hot_cross_buns", title: "Hot Cross Buns", category: .playful, assetName: "hot_cross_buns", lyrics: "Hot cross buns! Hot cross buns!\nOne a penny, two a penny,\nHot cross buns!"),
            Rhyme(id: "pat_a_cake", title: "Pat-a-Cake", category: .playful, assetName: "pat_a_cake", lyrics: "Pat-a-cake, pat-a-cake, baker's man,\nBake me a cake as fast as you can;\nRoll it, and pat it, and mark it with \"B\",\nAnd put it in the oven for baby and me."),
            Rhyme(id: "bingo", title: "Bingo", category: .animals, assetName: "bingo", lyrics: "There was a farmer had a dog,\nAnd Bingo was his name-o.\nB-I-N-G-O!\nB-I-N-G-O!\nAnd Bingo was his name-o!"),
            Rhyme(id: "brahms_lullaby", title: "Brahms' Lullaby", category: .bedtime, assetName: "brahms_lullaby", lyrics: "Lullaby and good night, in the sky stars are bright;\nMay the moon's silvery beams bring you sweet happy dreams."),
            Rhyme(id: "one_two_buckle_my_shoe", title: "One, Two, Buckle My Shoe", category: .playful, assetName: "one_two_buckle_my_shoe", lyrics: "One, two, buckle my shoe;\nThree, four, shut the door;\nFive, six, pick up sticks;\nSeven, eight, lay them straight;\nNine, ten, a big fat hen!"),
            Rhyme(id: "rain_rain_go_away", title: "Rain, Rain, Go Away", category: .playful, assetName: "rain_rain_go_away", lyrics: "Rain, rain, go away,\nCome again another day;\nLittle children want to play,\nRain, rain, go away!"),
            Rhyme(id: "little_miss_muffet", title: "Little Miss Muffet", category: .animals, assetName: "little_miss_muffet", lyrics: "Little Miss Muffet sat on a tuffet,\nEating her curds and whey;\nAlong came a spider, who sat down beside her,\nAnd frightened Miss Muffet away."),
            Rhyme(id: "polly_put_the_kettle_on", title: "Polly Put the Kettle On", category: .playful, assetName: "polly_put_the_kettle_on", lyrics: "Polly, put the kettle on,\nPolly, put the kettle on,\nPolly, put the kettle on,\nWe'll all have tea."),
            Rhyme(id: "sing_a_song_of_sixpence", title: "Sing a Song of Sixpence", category: .playful, assetName: "sing_a_song_of_sixpence", lyrics: "Sing a song of sixpence, a pocket full of rye,\nFour and twenty blackbirds baked in a pie."),
            Rhyme(
                id: "hush_little_baby",
                title: "Hush, Little Baby",
                category: .bedtime,
                assetName: "hush_little_baby",
                audioFileName: "hush_little_baby.wav",
                audioDuration: 11.4,
                lyrics: "Hush, little baby, don't say a word,\nPapa's gonna buy you a mockingbird.\nAnd if that mockingbird don't sing,\nPapa's gonna buy you a diamond ring.",
                timedLyrics: [
                    LyricSegment(start: 0.0, end: 5.5, text: "Hush, little baby, don't say a word,"),
                    LyricSegment(start: 5.5, end: 11.4, text: "Papa's gonna buy you a mockingbird.")
                ]
            ),
            Rhyme(id: "the_farmer_in_the_dell", title: "The Farmer in the Dell", category: .animals, assetName: "the_farmer_in_the_dell", lyrics: "The farmer in the dell,\nThe farmer in the dell,\nHeigh-ho, the derry-o,\nThe farmer in the dell."),
            Rhyme(id: "baa_baa_white_sheep", title: "Baa Baa White Sheep", category: .animals, assetName: "baa_baa_white_sheep", lyrics: "Baa, baa, white sheep, have you any wool?\nYes, sir, yes, sir, three bags full."),
            Rhyme(id: "simple_simon", title: "Simple Simon", category: .playful, assetName: "simple_simon", lyrics: "Simple Simon met a pieman,\nGoing to the fair;\nSays Simple Simon to the pieman,\n\"Let me taste your ware.\""),
            Rhyme(id: "grand_old_duke_of_york", title: "The Grand Old Duke of York", category: .action, assetName: "grand_old_duke_of_york", lyrics: "Oh, the grand old Duke of York,\nHe had ten thousand men;\nHe marched them up to the top of the hill,\nAnd he marched them down again."),
            Rhyme(id: "georgie_porgie", title: "Georgie Porgie", category: .playful, assetName: "georgie_porgie", lyrics: "Georgie Porgie, pudding and pie,\nKissed the girls and made them cry;\nWhen the boys came out to play,\nGeorgie Porgie ran away."),
            Rhyme(id: "jack_be_nimble", title: "Jack Be Nimble", category: .action, assetName: "jack_be_nimble", lyrics: "Jack be nimble, Jack be quick,\nJack jump over the candlestick."),
            Rhyme(id: "old_woman_in_shoe", title: "There Was an Old Woman", category: .playful, assetName: "old_woman_in_shoe", lyrics: "There was an old woman who lived in a shoe,\nShe had so many children she didn't know what to do."),
            Rhyme(id: "goosey_goosey_gander", title: "Goosey Goosey Gander", category: .animals, assetName: "goosey_goosey_gander", lyrics: "Goosey, goosey, gander, whither dost thou wander?\nUpstairs and downstairs and in my lady's chamber."),
            Rhyme(id: "star_light_star_bright", title: "Star Light, Star Bright", category: .bedtime, assetName: "star_light_star_bright", lyrics: "Star light, star bright,\nFirst star I see tonight;\nI wish I may, I wish I might,\nHave the wish I wish tonight."),
            Rhyme(id: "rub_a_dub_dub", title: "Rub-a-Dub-Dub", category: .playful, assetName: "rub_a_dub_dub", lyrics: "Rub-a-dub-dub,\nThree men in a tub,\nAnd who do you think they be?\nThe butcher, the baker, the candlestick maker,\nAnd all of them out to sea!"),
            Rhyme(id: "frere_jacques", title: "Frère Jacques", category: .bedtime, assetName: "frere_jacques", lyrics: "Frère Jacques, Frère Jacques,\nDormez-vous? Dormez-vous?\nSonnez les matines! Din, dan, don!"),
            Rhyme(id: "ding_dong_bell", title: "Ding Dong Bell", category: .animals, assetName: "ding_dong_bell", lyrics: "Ding, dong, bell, pussy's in the well.\nWho put her in? Little Tommy Thin.\nWho pulled her out? Little Tommy Stout."),
            Rhyme(id: "lavenders_blue", title: "Lavender's Blue", category: .bedtime, assetName: "lavenders_blue", lyrics: "Lavender's blue, dilly dilly,\nLavender's green,\nWhen I am king, dilly dilly,\nYou shall be queen."),
            Rhyme(id: "wee_willie_winkie", title: "Wee Willie Winkie", category: .bedtime, assetName: "wee_willie_winkie", lyrics: "Wee Willie Winkie runs through the town,\nUpstairs and downstairs in his nightgown;\nTapping at the window, crying through the lock,\nAre all the children in their beds? For it's past eight o'clock!"),
            Rhyme(id: "over_in_the_meadow", title: "Over in the Meadow", category: .animals, assetName: "over_in_the_meadow", lyrics: "Over in the meadow, in the sand, in the sun,\nLived an old mother toadie and her little toadie one."),
            Rhyme(id: "round_and_round_the_garden", title: "Round and Round the Garden", category: .action, assetName: "round_and_round_the_garden", lyrics: "Round and round the garden\nLike a teddy bear,\nOne step, two step,\nTickle you under there!"),
            Rhyme(id: "wise_old_owl", title: "A Wise Old Owl", category: .animals, assetName: "wise_old_owl", lyrics: "A wise old owl sat in an oak,\nThe more he saw the less he spoke;\nThe less he spoke the more he heard;\nWhy can't we all be like that wise old bird?"),
            Rhyme(id: "peter_pumpkin_eater", title: "Peter Peter Pumpkin Eater", category: .playful, assetName: "peter_pumpkin_eater", lyrics: "Peter, Peter pumpkin eater,\nHad a wife and couldn't keep her;\nHe put her in a pumpkin shell\nAnd there he kept her very well."),
            Rhyme(id: "sleep_baby_sleep", title: "Sleep, Baby, Sleep", category: .bedtime, assetName: "sleep_baby_sleep", lyrics: "Sleep, baby, sleep,\nYour father guards the sheep;\nYour mother shakes the dreamland tree,\nDown falls a little dream on thee;\nSleep, baby, sleep.")
        ]
    }
}
