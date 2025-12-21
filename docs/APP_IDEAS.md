# Quiz App Ideas

A curated list of quiz app ideas that can be built using the quiz_engine architecture. Each idea includes target audience, content requirements, and monetization potential.

## Table of Contents
- [Geography & Travel](#geography--travel)
- [Language & Education](#language--education)
- [Entertainment & Pop Culture](#entertainment--pop-culture)
- [Nature & Science](#nature--science)
- [Sports & Games](#sports--games)
- [Food & Cooking](#food--cooking)
- [Music & Audio](#music--audio)
- [Kids & Family](#kids--family)
- [Professional & Skills](#professional--skills)

---

## Geography & Travel

### 1. Capital Cities Quiz ⭐ High Potential
**Concept:** Show country flag → guess the capital city

**Content:**
- 195 countries and capitals
- Regional categories (Europe, Asia, Africa, etc.)
- Difficulty levels (easy: France → Paris, hard: Nauru → Yaren)

**Features:**
- Learn mode with facts
- Timed challenges
- Progressive difficulty

**Target Audience:** Geography enthusiasts, students, travelers

**Monetization:**
- Free: 50 questions + ads
- Premium: All 195 countries, no ads ($2.99)
- Regional packs: $0.99 each

**Data Required:**
- Country flags (PNG)
- capitals.json with country-capital mapping

**Estimated Revenue:** $3k-10k/month

---

### 2. Landmark Recognition Quiz
**Concept:** Show landmark photo → guess location/name

**Content:**
- 500+ famous landmarks
- Categories: Ancient wonders, modern architecture, natural wonders
- Multiple angles per landmark

**Features:**
- Photo hints (zoom, different angle)
- Historical facts
- "Been there" checklist

**Target Audience:** Travelers, geography lovers, culture enthusiasts

**Monetization:**
- Free: 100 landmarks + ads
- Premium: All landmarks + offline mode ($3.99)
- Regional packs: $1.99 each

**Data Required:**
- High-quality landmark photos
- landmarks.json with location, facts

**Estimated Revenue:** $2k-8k/month

---

### 3. State/Province Shapes Quiz
**Concept:** Show state/province outline → guess the state

**Content:**
- US states (50)
- Canadian provinces (13)
- European countries (44)
- Indian states (28)

**Features:**
- Rotation challenge (random orientation)
- Size comparison mode
- Capital cities bonus round

**Target Audience:** Students, geography enthusiasts, locals

**Monetization:**
- Free: US states + ads
- Premium: All regions ($1.99)

**Data Required:**
- SVG/PNG outlines
- states.json

**Estimated Revenue:** $1k-5k/month

---

## Language & Education

### 4. Language Learning Quiz ⭐ High Potential
**Concept:** Audio pronunciation → match the word/phrase

**Content:**
- Common phrases in 20+ languages
- Categories: Greetings, numbers, food, directions
- Native speaker audio

**Features:**
- Slow playback option
- Phonetic hints
- Spaced repetition system

**Target Audience:** Language learners, travelers

**Monetization:**
- Free: 1 language (50 phrases) + ads
- Per language: $2.99
- All languages subscription: $4.99/month

**Data Required:**
- Audio files (MP3)
- translations.json

**Estimated Revenue:** $5k-20k/month (high engagement)

---

### 5. Math Facts Speed Quiz
**Concept:** Show equation → solve quickly

**Content:**
- Addition (1-100)
- Subtraction (1-100)
- Multiplication tables (1-12)
- Division (1-144)

**Features:**
- Timed mode
- Leaderboards
- Progress tracking
- Daily challenges

**Target Audience:** Kids (6-14), parents, teachers

**Monetization:**
- Free: Addition + ads
- Premium: All operations, no ads ($1.99)
- School license: $49.99/year

**Data Required:**
- Programmatically generated (no JSON needed)

**Estimated Revenue:** $2k-10k/month

---

### 6. Vocabulary Builder Quiz
**Concept:** Show word → choose correct definition

**Content:**
- SAT/GRE vocabulary (1000+ words)
- Academic levels (elementary, middle school, high school, college)
- Subject-specific (medical, legal, technical)

**Features:**
- Word of the day
- Flashcard mode
- Usage examples
- Etymology information

**Target Audience:** Students, test prep, professionals

**Monetization:**
- Free: 100 words + ads
- SAT pack: $4.99
- GRE pack: $6.99
- All packs: $9.99

**Data Required:**
- vocabulary.json with definitions, examples

**Estimated Revenue:** $3k-15k/month

---

## Entertainment & Pop Culture

### 7. Movie Posters Quiz ⭐ High Potential
**Concept:** Show movie poster → guess the movie

**Content:**
- 1000+ classic and modern movies
- Categories by decade (80s, 90s, 2000s, 2010s, 2020s)
- Categories by genre (action, comedy, horror, etc.)

**Features:**
- Partial reveal (show more of poster as hint)
- Actor hints
- Release year hints

**Target Audience:** Movie enthusiasts, all ages

**Monetization:**
- Free: 200 movies + ads
- Premium: All movies ($3.99)
- Decade packs: $1.99 each

**Data Required:**
- Movie posters (ensure public domain or licensed)
- movies.json

**Estimated Revenue:** $4k-12k/month

---

### 8. Celebrity Face Quiz
**Concept:** Show celebrity photo → guess the name

**Content:**
- 500+ celebrities
- Categories: Actors, musicians, athletes, historical figures
- Different eras

**Features:**
- Career hints
- Famous role hints
- Age progression (young vs old photos)

**Target Audience:** Pop culture fans, all ages

**Monetization:**
- Free: 100 celebrities + ads
- Premium: All celebrities ($2.99)

**Data Required:**
- Celebrity photos (public domain/creative commons)
- celebrities.json

**Estimated Revenue:** $2k-8k/month

---

### 9. TV Show Intro Quiz
**Concept:** Play TV show intro music → guess the show

**Content:**
- 300+ TV show themes
- Categories by era, genre, network

**Features:**
- Partial playback (first 5 seconds, then more)
- Visual hints (show logo blur)
- Streaming service tags

**Target Audience:** TV enthusiasts, nostalgia seekers

**Monetization:**
- Free: 50 shows + ads
- Premium: All shows ($4.99)

**Data Required:**
- Intro music clips (15-30 seconds, licensed)
- tv_shows.json

**Estimated Revenue:** $3k-10k/month

---

## Nature & Science

### 10. Animal Sounds Quiz ⭐ High Potential
**Concept:** Play animal sound → guess the animal

**Content:**
- 200+ animals
- Categories: Farm, wild, birds, marine, insects
- Baby animal sounds variant

**Features:**
- Sound visualization
- Habitat information
- Conservation status

**Target Audience:** Kids, families, nature lovers

**Monetization:**
- Free: 50 animals + ads
- Premium: All animals ($2.99)
- Educational bundle: $4.99 (with facts pack)

**Data Required:**
- Animal sound files (MP3/WAV)
- animals.json

**Estimated Revenue:** $2k-7k/month

---

### 11. Bird Call Identification
**Concept:** Play bird call → identify the species

**Content:**
- 300+ bird species
- Regional collections (North America, Europe, etc.)
- Seasonal variants

**Features:**
- Spectrogram visualization
- Range maps
- Field guide integration

**Target Audience:** Birdwatchers, naturalists

**Monetization:**
- Free: 50 common birds + ads
- Regional packs: $3.99 each
- Premium: All regions ($9.99)

**Data Required:**
- Bird call audio
- birds.json with range, season info

**Estimated Revenue:** $1k-5k/month (niche but dedicated)

---

### 12. Dinosaur Quiz
**Concept:** Show dinosaur illustration → guess the species

**Content:**
- 100+ dinosaurs
- Categories: Periods (Triassic, Jurassic, Cretaceous)
- Diet types (herbivore, carnivore, omnivore)

**Features:**
- Size comparison
- Fossil locations
- Pronunciation audio
- Diet and habitat info

**Target Audience:** Kids (5-12), dinosaur enthusiasts

**Monetization:**
- Free: 30 dinosaurs + ads
- Premium: All dinosaurs + AR viewer ($3.99)

**Data Required:**
- Dinosaur illustrations
- dinosaurs.json

**Estimated Revenue:** $2k-6k/month

---

### 13. Periodic Table Quiz
**Concept:** Show element symbol → name the element

**Content:**
- All 118 elements
- Modes: Symbol → Name, Atomic Number → Name, Properties → Element

**Features:**
- Electron configuration
- Uses in daily life
- Discovery history

**Target Audience:** Students (high school, college), chemistry enthusiasts

**Monetization:**
- Free: First 20 elements + ads
- Premium: All elements + lab simulator ($4.99)

**Data Required:**
- elements.json with properties

**Estimated Revenue:** $1k-4k/month

---

## Sports & Games

### 14. Sports Logo Quiz
**Concept:** Show team logo → guess the team

**Content:**
- NFL (32 teams)
- NBA (30 teams)
- MLB (30 teams)
- NHL (32 teams)
- Soccer clubs worldwide (500+)

**Features:**
- League filtering
- Historical logos
- Stadium photos

**Target Audience:** Sports fans

**Monetization:**
- Free: NFL + ads
- Per league: $1.99
- All sports: $4.99

**Data Required:**
- Team logos
- teams.json

**Estimated Revenue:** $3k-10k/month

---

### 15. Video Game Screenshots Quiz
**Concept:** Show game screenshot → guess the game

**Content:**
- 500+ popular games
- Categories: Platform, genre, era
- Retro to modern

**Features:**
- Pixelated hints (gradually reveal)
- Release year hints
- Developer/publisher hints

**Target Audience:** Gamers, all ages

**Monetization:**
- Free: 100 games + ads
- Premium: All games ($3.99)
- Retro pack: $1.99

**Data Required:**
- Screenshots (fair use/promotional)
- games.json

**Estimated Revenue:** $3k-9k/month

---

## Food & Cooking

### 16. World Dishes Quiz
**Concept:** Show dish photo → guess the dish name/country

**Content:**
- 300+ dishes from 50+ countries
- Categories by region, diet type
- Difficulty levels

**Features:**
- Ingredient hints
- Recipe links
- Dietary tags (vegan, gluten-free, etc.)

**Target Audience:** Foodies, travelers, cooking enthusiasts

**Monetization:**
- Free: 50 dishes + ads
- Regional packs: $1.99
- Premium: All dishes + recipes ($4.99)

**Data Required:**
- Dish photos
- dishes.json

**Estimated Revenue:** $2k-6k/month

---

### 17. Fruit & Vegetable Quiz
**Concept:** Show produce photo → identify the fruit/vegetable

**Content:**
- 200+ varieties
- Exotic and common
- Whole vs cut views

**Features:**
- Nutrition facts
- Growing season
- Recipe suggestions

**Target Audience:** Kids, health-conscious adults, gardeners

**Monetization:**
- Free: Common produce + ads
- Premium: All varieties ($2.99)

**Data Required:**
- Photos of produce
- produce.json

**Estimated Revenue:** $1k-4k/month

---

## Music & Audio

### 18. Song Intro Quiz ⭐ High Potential
**Concept:** Play first 5 seconds of song → guess title/artist

**Content:**
- Top hits by decade (60s-2020s)
- Genre collections
- 1000+ songs

**Features:**
- Progressive reveal (more seconds)
- Lyrics hints
- Artist photo hints

**Target Audience:** Music lovers, all ages, nostalgia

**Monetization:**
- Free: 100 songs + ads
- Decade packs: $2.99 each
- Premium: All songs ($9.99)

**Data Required:**
- Song clips (licensed, 15-30 seconds)
- songs.json

**Estimated Revenue:** $5k-15k/month

**⚠️ Licensing:** Requires music licensing (complex/expensive)

---

### 19. Classical Music Quiz
**Concept:** Play classical piece → identify composer/work

**Content:**
- 200+ famous pieces
- Major composers (Bach, Mozart, Beethoven, etc.)
- Periods (Baroque, Classical, Romantic, Modern)

**Features:**
- Full piece playback (premium)
- Composer biographies
- Era information

**Target Audience:** Classical music fans, students

**Monetization:**
- Free: 50 pieces + ads
- Premium: All pieces ($4.99)

**Data Required:**
- Classical music clips (many public domain)
- classical.json

**Estimated Revenue:** $1k-3k/month (niche)

---

### 20. Instrument Sounds Quiz
**Concept:** Play instrument sound → identify the instrument

**Content:**
- 50+ instruments
- Categories: String, wind, brass, percussion, electronic
- Solo vs ensemble

**Features:**
- Visual of instrument
- Playing technique info
- Famous musicians

**Target Audience:** Music students, educators, enthusiasts

**Monetization:**
- Free: 20 instruments + ads
- Premium: All instruments ($2.99)

**Data Required:**
- Instrument audio samples
- instruments.json

**Estimated Revenue:** $1k-3k/month

---

## Kids & Family

### 21. Alphabet & Phonics Quiz
**Concept:** Play letter sound → match the letter

**Content:**
- Uppercase letters (A-Z)
- Lowercase letters (a-z)
- Letter sounds (phonics)
- Simple words

**Features:**
- Colorful animations
- Encouraging feedback
- Parental progress tracking

**Target Audience:** Kids (3-6), parents, preschools

**Monetization:**
- Free: Letters A-M + ads
- Premium: All letters, no ads ($1.99)
- School license: $29.99/year

**Data Required:**
- Letter audio
- letters.json

**Estimated Revenue:** $2k-8k/month

---

### 22. Shape & Color Quiz
**Concept:** Show shape/color → identify name

**Content:**
- Basic shapes (circle, square, triangle, etc.)
- Colors (red, blue, green, etc.)
- Combinations (red square, blue circle)

**Features:**
- Audio names
- Real-world examples
- Drawing mode

**Target Audience:** Toddlers (2-5), parents

**Monetization:**
- Free: Basic shapes + ads
- Premium: All shapes/colors ($1.99)

**Data Required:**
- Shape/color images
- shapes.json

**Estimated Revenue:** $1k-4k/month

---

### 23. Emoji Meanings Quiz
**Concept:** Show emoji → guess the meaning/name

**Content:**
- 500+ emojis
- Categories: Faces, animals, food, objects, symbols
- Combination challenges (emoji sentences)

**Features:**
- Unicode name
- Common usage
- History of emoji

**Target Audience:** Teens, young adults

**Monetization:**
- Free: 100 emojis + ads
- Premium: All emojis ($0.99)

**Data Required:**
- Emoji images/unicode
- emojis.json

**Estimated Revenue:** $2k-5k/month

---

## Professional & Skills

### 24. Medical Terminology Quiz
**Concept:** Show medical term → choose definition

**Content:**
- 1000+ medical terms
- Categories: Anatomy, conditions, procedures, medications
- Difficulty levels

**Features:**
- Pronunciation audio
- Etymology
- Related terms

**Target Audience:** Medical students, nurses, healthcare professionals

**Monetization:**
- Free: 100 terms + ads
- Student bundle: $9.99
- Professional bundle: $19.99

**Data Required:**
- medical_terms.json

**Estimated Revenue:** $2k-8k/month

---

### 25. Programming Quiz
**Concept:** Show code snippet → identify the language/output

**Content:**
- 20+ programming languages
- Syntax challenges
- Algorithm identification
- Debugging challenges

**Features:**
- Code highlighting
- Difficulty levels (beginner to expert)
- Leaderboards

**Target Audience:** Developers, CS students

**Monetization:**
- Free: Basic challenges + ads
- Premium: All languages + expert challenges ($4.99)
- Interview prep bundle: $9.99

**Data Required:**
- code_challenges.json

**Estimated Revenue:** $3k-10k/month

---

### 26. Legal Terms Quiz
**Concept:** Show legal term → match definition

**Content:**
- Common legal terms (500+)
- Categories: Criminal, civil, contracts, torts
- Latin phrases

**Features:**
- Case examples
- Jurisdiction notes
- Pronunciation

**Target Audience:** Law students, paralegals, legal enthusiasts

**Monetization:**
- Free: 100 terms + ads
- Premium: All terms ($7.99)
- Bar prep bundle: $19.99

**Data Required:**
- legal_terms.json

**Estimated Revenue:** $1k-5k/month

---

## Quick Start Recommendations

### Best for Beginners (Easy to Create)
1. **Capital Cities Quiz** - Simple data, broad appeal
2. **State Shapes Quiz** - Visual, educational
3. **Emoji Meanings Quiz** - Fun, trending

### High Revenue Potential
1. **Movie Posters Quiz** - Mass appeal, nostalgia
2. **Song Intro Quiz** - High engagement (if licensed)
3. **Language Learning Quiz** - Recurring subscription model
4. **Animal Sounds Quiz** - Family-friendly, educational

### Niche but Profitable
1. **Bird Call Identification** - Dedicated audience, willing to pay
2. **Programming Quiz** - Professional audience, higher prices
3. **Medical Terminology** - Educational necessity

### Easy Data Acquisition
1. **Math Facts Quiz** - Programmatically generated
2. **Periodic Table Quiz** - Public data
3. **Alphabet Quiz** - Standard content

---

## Implementation Priority

### Phase 1: Launch Portfolio (3 apps)
1. **Capital Cities Quiz** (proven model)
2. **Animal Sounds Quiz** (family appeal)
3. **Movie Posters Quiz** (mass market)

### Phase 2: Expand (5 more apps)
4. **Language Learning Quiz** (subscription revenue)
5. **Landmark Recognition**
6. **Math Facts Speed Quiz**
7. **World Dishes Quiz**
8. **Sports Logo Quiz**

### Phase 3: Premium/Niche (Long-term)
9. **Bird Call Identification**
10. **Programming Quiz**
11. **Medical Terminology**

---

## Data Considerations

### Public Domain Sources
- Country flags: Wikimedia Commons
- Periodic table: Public data
- Classical music: Many pieces are public domain
- Dinosaur facts: Scientific databases

### Requires Licensing
- Movie posters: Studios/distributors
- Song clips: Music publishers (expensive)
- Celebrity photos: Rights holders
- Modern game screenshots: Publishers

### User-Generated Option
- Community-submitted questions
- Moderation required
- Legal review needed

---

## Marketing Angles

**Educational:**
- "Learn while playing"
- "Perfect for students"
- "Teacher-approved"

**Entertainment:**
- "Test your knowledge"
- "Challenge your friends"
- "How well do you know..."

**Nostalgia:**
- "Remember the classics"
- "From your childhood"
- "The ultimate throwback quiz"

**Competitive:**
- "Climb the leaderboards"
- "Beat your high score"
- "Are you smarter than..."

---

## Cross-Promotion Strategy

Once you have multiple apps:
1. Cross-promote in end screens
2. Bundle discounts (buy 3, get 2 free)
3. Unified leaderboards
4. Shared accounts/progress
5. "Mega Quiz Bundle" subscription ($9.99/mo for all apps)

**Expected Synergy:**
- Each new app boosts others by 10-20%
- Unified subscription increases LTV by 3-5x
- Reduced CAC through cross-promotion

---

Start with 1-2 apps, validate the model, then scale to a portfolio of 5-10 apps for maximum revenue potential.
