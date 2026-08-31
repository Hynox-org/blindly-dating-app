-- ============================================================================
-- Test profiles: 30 fully-filled, pre-verified people around Chennai.
--
-- No Google sign-in involved: each one is an email/password auth user created
-- straight in auth.users, so photos can be uploaded as that user by
-- scripts/seed_test_profiles_photos.sh. Verification is set to full_verified
-- by hand and photo moderation to approved — Veriff/liveness and the AWS
-- moderation lambda are skipped on purpose.
--
-- Ids are fixed and greppable, which is what makes this re-runnable and makes
-- cleanup one DELETE (see the bottom of this file):
--   auth user     aaaaaaaa-0000-4000-8000-0000000000NN
--   profile       bbbbbbbb-0000-4000-8000-0000000000NN
--   date mode     cccccccc-0000-4000-8000-0000000000NN
--   bff  mode     dddddddd-0000-4000-8000-0000000000NN
-- Login for any of them: seedNN@blindly.test / Seed@12345
--
-- Run order:
--   1. this file (section 1 + 2 + 3)
--   2. scripts/seed_test_profiles_photos.sh   (uploads the JPEGs)
--   3. section 4 of this file                 (registers the photo rows)
--
-- _seed_data is dropped once section 4 is done, so re-running section 4 alone
-- means re-running section 1 first.
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 1. Staging table. Everything below reads from here, so the 30 people are
--    described once, in one place, in the shape a person can actually edit.
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS public._seed_data;
CREATE TABLE public._seed_data AS
SELECT * FROM jsonb_to_recordset($json$
[
{"idx":1,"name":"Aditi Raghavan","gender":"F","pronouns":"she_her","birth":"1998-03-14","orient":"Straight","height":163,"title":"UX Designer","company":"Zoho","edu":"Post Graduate","school":"Anna University","hometown":"Coimbatore","religion":"Hindu","sign":"Pisces","politics":"Moderate","kids":"Want Kids","drink":"Socially","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Tamil","Hindi"],"causes":["Environmentalism","Feminism"],"qualities":["Empathy","Humor"],"bio":"Designer by day, filter-coffee snob always. I will absolutely drag you to a Besant Nagar sunset walk.","looking":["Long-term relationship"],"lat":13.0012,"lng":80.2565,"sex":"female","photos":[1,31,61],"interests":["Coffee","Design","Beaches","Yoga","Movie","Art"],"lifestyle":["Foodie","Planner","Active"],"prompts":[{"q":"My perfect weekend looks like…","a":"Filter coffee at 7, a long Elliot's Beach walk, and absolutely nothing scheduled after 4pm."},{"q":"A hobby I can talk about for hours is…","a":"Typography. I have opinions about the signage on Mount Road."},{"q":"My comfort food is…","a":"Curd rice with a spoon of thokku. Non-negotiable."}]},
{"idx":2,"name":"Meera Krishnan","gender":"F","pronouns":"she_her","birth":"1996-07-22","orient":"Straight","height":158,"title":"Pediatric Resident","company":"Apollo Hospitals","edu":"Doctorate","school":"Madras Medical College","hometown":"Madurai","religion":"Hindu","sign":"Cancer","politics":"Apolitical","kids":"Want Kids","drink":"Never drink","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Life partner","langs":["English","Tamil"],"causes":["Human Rights","Reproductive Rights"],"qualities":["Kindness","Ambition"],"bio":"Doctor with terrible sleep hygiene and a great dosa list. Tell me about your day, I actually want to hear it.","looking":["Life partner"],"lat":13.0604,"lng":80.2496,"sex":"female","photos":[2,32,62],"interests":["Nutrition","Fitness","Coffee","Singing","Dogs"],"lifestyle":["Active","Gym enthusiast","Introvert"],"prompts":[{"q":"My go-to way to recharge is…","a":"A 12-hour sleep debt repayment plan and my mother's rasam."},{"q":"A skill I want to learn next is…","a":"Swimming, properly. I can float and that is the whole résumé."},{"q":"Something I’m currently excited about is…","a":"Finishing residency and finally having weekends that exist."}]},
{"idx":3,"name":"Sanjana Iyer","gender":"F","pronouns":"she_her","birth":"2000-11-02","orient":"Bisexual","height":167,"title":"Product Analyst","company":"Freshworks","edu":"Under Graduate","school":"Loyola College","hometown":"Chennai","religion":"Agnostic","sign":"Scorpio","politics":"Socialist","kids":"Not Sure","drink":"Occasionally","smoke":"Social smoker","exercise":"Weekly","rel":"Open to exploring","intent":"Short-term, open to long","langs":["English","Tamil","Telugu"],"causes":["LGBTQ Rights","Feminism"],"qualities":["Openness","Sassiness"],"bio":"Spreadsheets at work, live gigs on weekends. I own three ukuleles and can play one badly.","looking":["Short-term, open to long"],"lat":13.0827,"lng":80.2707,"sex":"female","photos":[3,33,63],"interests":["Rock","Club","Photography","LGBTQ","Cocktail","Museum"],"lifestyle":["Night owl","Spontaneous","Extrovert"],"prompts":[{"q":"My perfect weekend looks like…","a":"Something loud on Saturday, something horizontal on Sunday."},{"q":"My most random talent is…","a":"I can name a song from four seconds of the intro. Test me."},{"q":"A hobby I can talk about for hours is…","a":"Digging through second-hand record stores in Mylapore."}]},
{"idx":4,"name":"Divya Sundaram","gender":"F","pronouns":"she_her","birth":"1995-01-19","orient":"Straight","height":161,"title":"Architect","company":"Studio Kaarigar","edu":"Post Graduate","school":"School of Architecture and Planning","hometown":"Trichy","religion":"Hindu","sign":"Capricorn","politics":"Moderate","kids":"Open to kids","drink":"Socially","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Tamil","Hindi"],"causes":["Environmentalism","Indigenous Rights"],"qualities":["Ambition","Empathy"],"bio":"I notice your building's staircase before I notice you. Chettinad houses are my personality.","looking":["Long-term relationship"],"lat":12.9800,"lng":80.2200,"sex":"female","photos":[4,34,64],"interests":["Art","Painting","Photography","Hiking trips","Coffee","Theater"],"lifestyle":["Planner","Home body","Foodie"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Heritage buildings. I will make you look up at a ceiling."},{"q":"My comfort food is…","a":"Kothu parotta at 11pm, no apologies."},{"q":"A skill I want to learn next is…","a":"Pottery. I want to make one bowl that is not tragic."}]},
{"idx":5,"name":"Nithya Balan","gender":"F","pronouns":"she_her","birth":"1999-05-30","orient":"Straight","height":155,"title":"Content Strategist","company":"Chargebee","edu":"Under Graduate","school":"Stella Maris College","hometown":"Chennai","religion":"Christian","sign":"Gemini","politics":"Moderate","kids":"Not Sure","drink":"Occasionally","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term, open to short","langs":["English","Tamil"],"causes":["Feminism","Neuro diversity"],"qualities":["Humor","Optimism"],"bio":"Professional word-arranger. I laugh at my own jokes so you don't have to feel obligated.","looking":["Long-term, open to short"],"lat":13.0450,"lng":80.2500,"sex":"female","photos":[5,35,65],"interests":["Cafe","Movie","Cake","Cats","Fashion","Theater"],"lifestyle":["Foodie","Extrovert","Relaxer"],"prompts":[{"q":"My comfort food is…","a":"Anything from that one bakery in Alwarpet that closes too early."},{"q":"Something I’m currently excited about is…","a":"A stand-up open mic I have signed up for and am quietly terrified about."},{"q":"My go-to way to recharge is…","a":"Rewatching a show I have already seen nine times."}]},
{"idx":6,"name":"Priya Venkatesh","gender":"F","pronouns":"she_her","birth":"1994-09-08","orient":"Straight","height":170,"title":"Corporate Lawyer","company":"Sundaram & Associates","edu":"Post Graduate","school":"NLSIU","hometown":"Bengaluru","religion":"Hindu","sign":"Virgo","politics":"Moderate","kids":"Want Kids","drink":"Socially","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Life partner","langs":["English","Tamil","Kannada"],"causes":["Human Rights","Voter Rights"],"qualities":["Confidence","Ambition"],"bio":"I argue for a living so I have learned to lose gracefully at home. Runner, reader, early sleeper.","looking":["Life partner"],"lat":13.1200,"lng":80.2300,"sex":"female","photos":[6,36,66],"interests":["Fitness","Coffee","Museum","Wine tasting","Tennis"],"lifestyle":["Gym enthusiast","Planner","Active"],"prompts":[{"q":"My perfect weekend looks like…","a":"A 15k run on Saturday morning and being in bed by ten on Sunday."},{"q":"A skill I want to learn next is…","a":"Cooking something that takes more than one pan."},{"q":"My go-to way to recharge is…","a":"Long drives on ECR with the phone in the glovebox."}]},
{"idx":7,"name":"Kavya Nair","gender":"F","pronouns":"she_her","birth":"2001-02-11","orient":"Straight","height":159,"title":"Graphic Designer","company":"Freelance","edu":"Diploma","school":"DJ Academy of Design","hometown":"Kochi","religion":"Hindu","sign":"Aquarius","politics":"Not Interested","kids":"Not Sure","drink":"Occasionally","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Casual dating","langs":["English","Malayalam","Tamil"],"causes":["Environmentalism"],"qualities":["Openness","Humor"],"bio":"Freelance illustrator, full-time cat staff. Will draw you badly on a napkin as a first date.","looking":["Casual dating"],"lat":13.0290,"lng":80.2100,"sex":"female","photos":[7,37,67],"interests":["Art","Painting","Cats","Coffee","Design","K-pop"],"lifestyle":["Home body","Introvert","Night owl"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Ink pens. Yes, there is a difference. No, I will not stop."},{"q":"My comfort food is…","a":"Appam and stew, made by anyone who is not me."},{"q":"Something I’m currently excited about is…","a":"My first solo zine, which is 60% finished and 100% overdue."}]},
{"idx":8,"name":"Anjali Menon","gender":"F","pronouns":"she_her","birth":"1997-12-05","orient":"Straight","height":165,"title":"Data Scientist","company":"Amazon","edu":"Post Graduate","school":"IIT Madras","hometown":"Thiruvananthapuram","religion":"Atheist","sign":"Sagittarius","politics":"Socialist","kids":"Don't want kids","drink":"Socially","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Malayalam","Hindi"],"causes":["Environmentalism","Human Rights"],"qualities":["Ambition","Openness"],"bio":"I build models that are wrong in useful ways. Climber, chess dabbler, terrible singer.","looking":["Long-term relationship"],"lat":12.9900,"lng":80.2400,"sex":"female","photos":[8,38,68],"interests":["Hiking trips","Fitness","Coffee","Solo trips","Photography","Basket ball"],"lifestyle":["Adventurer","Active","Introvert"],"prompts":[{"q":"My perfect weekend looks like…","a":"Bouldering gym Saturday, a stack of pancakes Sunday, no small talk in between."},{"q":"A skill I want to learn next is…","a":"Lead climbing outdoors without narrating my fear out loud."},{"q":"My go-to way to recharge is…","a":"Solo trip somewhere with bad phone signal."}]},
{"idx":9,"name":"Shruti Ramesh","gender":"F","pronouns":"she_her","birth":"1993-06-17","orient":"Straight","height":162,"title":"Marketing Manager","company":"Titan","edu":"Post Graduate","school":"Great Lakes Institute","hometown":"Salem","religion":"Hindu","sign":"Gemini","politics":"Moderate","kids":"Have kids","drink":"Socially","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Tamil","Hindi"],"causes":["Feminism","Disability Rights"],"qualities":["Kindness","Confidence"],"bio":"Mum to a very opinionated six-year-old. Weekends are non-negotiable and usually involve a beach.","looking":["Long-term relationship"],"lat":13.1000,"lng":80.2800,"sex":"female","photos":[9,39,69],"interests":["Beaches","Coffee","Movie","Dance","Biryani"],"lifestyle":["Foodie","Planner","Extrovert"],"prompts":[{"q":"My comfort food is…","a":"Ambur biryani, and I will fight about which shop."},{"q":"My go-to way to recharge is…","a":"An hour alone in the car in the parking lot. Parents will understand."},{"q":"Something I’m currently excited about is…","a":"Teaching my daughter to swim without her teaching me new fears."}]},
{"idx":10,"name":"Farah Sheikh","gender":"F","pronouns":"she_her","birth":"1998-08-25","orient":"Straight","height":168,"title":"Journalist","company":"The Hindu","edu":"Post Graduate","school":"Asian College of Journalism","hometown":"Hyderabad","religion":"Muslim","sign":"Virgo","politics":"Socialist","kids":"Open to kids","drink":"Never drink","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Hindi","Tamil","Arabic"],"causes":["End Religious Hate","Human Rights","Immigrant Rights"],"qualities":["Empathy","Confidence"],"bio":"I ask too many questions for a living and do not switch it off at dinner. Fair warning.","looking":["Long-term relationship"],"lat":13.0700,"lng":80.2200,"sex":"female","photos":[10,40,70],"interests":["Coffee","Museum","Theater","Biryani","Photography","Festival"],"lifestyle":["Foodie","Extrovert","Night owl"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Old Chennai food history. There is a reason the Triplicane biryani argument never ends."},{"q":"My perfect weekend looks like…","a":"One long interview I am not paid for, and a very slow breakfast."},{"q":"A skill I want to learn next is…","a":"Film photography, developing my own rolls included."}]},
{"idx":11,"name":"Ritika Agarwal","gender":"F","pronouns":"she_her","birth":"2002-04-03","orient":"Straight","height":157,"title":"Final Year Student","company":"IIT Madras","edu":"Under Graduate","school":"IIT Madras","hometown":"Jaipur","religion":"Jain","sign":"Aries","politics":"Apolitical","kids":"Not Sure","drink":"Never drink","smoke":"Non-smoker","exercise":"Daily","rel":"Open to exploring","intent":"Still figuring it out","langs":["English","Hindi"],"causes":["Environmentalism"],"qualities":["Optimism","Humor"],"bio":"Engineering student, competitive badminton player, chronically two deadlines behind. Feed me and I am yours.","looking":["Still figuring it out"],"lat":12.9915,"lng":80.2337,"sex":"female","photos":[11,41,71],"interests":["Tennis","Fitness","Cake","Coffee","Movie","Dance"],"lifestyle":["Active","Extrovert","Spontaneous"],"prompts":[{"q":"Something I’m currently excited about is…","a":"Graduating, mostly so I can stop explaining what my project is about."},{"q":"My comfort food is…","a":"Dal baati that my grandmother couriers across three states."},{"q":"My go-to way to recharge is…","a":"Badminton until my legs stop working."}]},
{"idx":12,"name":"Tanvi Deshpande","gender":"F","pronouns":"she_her","birth":"1996-10-14","orient":"Bisexual","height":164,"title":"Clinical Psychologist","company":"Private Practice","edu":"Doctorate","school":"TISS","hometown":"Pune","religion":"Spiritual","sign":"Libra","politics":"Moderate","kids":"Open to kids","drink":"Occasionally","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Marathi","Hindi"],"causes":["Neuro diversity","Feminism","Disability Rights"],"qualities":["Empathy","Openness"],"bio":"No, I am not analysing you. Yes, I noticed that. Yoga at sunrise, terrible reality TV at night.","looking":["Long-term relationship"],"lat":13.0350,"lng":80.2650,"sex":"female","photos":[12,42,72],"interests":["Yoga","Therapy","Coffee","Movie","Spa","Astrology"],"lifestyle":["Relaxer","Introvert","Active"],"prompts":[{"q":"My go-to way to recharge is…","a":"Silence. Genuinely. An hour of it and I am a new person."},{"q":"A hobby I can talk about for hours is…","a":"Bad television. The worse it is, the more I have to say."},{"q":"My perfect weekend looks like…","a":"Sunrise yoga, a long lunch, and no group plans."}]},
{"idx":13,"name":"Lakshmi Pillai","gender":"F","pronouns":"she_her","birth":"1995-03-27","orient":"Straight","height":160,"title":"Chef de Partie","company":"Taj Coromandel","edu":"Diploma","school":"IHM Chennai","hometown":"Alappuzha","religion":"Hindu","sign":"Aries","politics":"Not Interested","kids":"Want Kids","drink":"Socially","smoke":"Smoker when drinking","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Malayalam","Tamil"],"causes":["Environmentalism"],"qualities":["Ambition","Kindness"],"bio":"I cook for 200 people a night and still make Maggi at home. Bring me to a fish market, not a fancy restaurant.","looking":["Long-term relationship"],"lat":13.0580,"lng":80.2450,"sex":"female","photos":[13,43,73],"interests":["BBQ","Fish","Pasta","Coffee","Wine tasting","Beaches"],"lifestyle":["Foodie","Night owl","Spontaneous"],"prompts":[{"q":"My comfort food is…","a":"Kappa and meen curry. Everything else is a negotiation."},{"q":"A skill I want to learn next is…","a":"Proper sourdough, in Chennai humidity, which may be impossible."},{"q":"Something I’m currently excited about is…","a":"A pop-up dinner I am doing next month with a friend."}]},
{"idx":14,"name":"Neha Gupta","gender":"F","pronouns":"she_her","birth":"1999-07-09","orient":"Straight","height":166,"title":"Software Engineer","company":"Zoho","edu":"Under Graduate","school":"VIT Vellore","hometown":"Lucknow","religion":"Hindu","sign":"Cancer","politics":"Apolitical","kids":"Not Sure","drink":"Occasionally","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term, open to short","langs":["English","Hindi","Tamil"],"causes":["Feminism"],"qualities":["Humor","Kindness"],"bio":"Backend engineer, front-end disaster. I have strong feelings about semicolons and biryani.","looking":["Long-term, open to short"],"lat":12.9700,"lng":80.2500,"sex":"female","photos":[14,44,74],"interests":["Coffee","Movie","Biryani","Cats","K-pop","Singing"],"lifestyle":["Home body","Introvert","Foodie"],"prompts":[{"q":"My perfect weekend looks like…","a":"Nothing on the calendar and a fridge that is already stocked."},{"q":"The most useless skill I’m great at is…","a":"Remembering every password except my own."},{"q":"My comfort food is…","a":"Instant noodles at 1am, upgraded with one egg."}]},
{"idx":15,"name":"Sneha Rao","gender":"F","pronouns":"she_her","birth":"1994-11-21","orient":"Straight","height":169,"title":"Yoga Instructor","company":"Self-employed","edu":"Under Graduate","school":"Mount Carmel College","hometown":"Mangalore","religion":"Spiritual","sign":"Scorpio","politics":"Moderate","kids":"Open to kids","drink":"Never drink","smoke":"Non-smoker","exercise":"Daily","rel":"Open to exploring","intent":"Long-term relationship","langs":["English","Kannada","Tamil","Hindi"],"causes":["Environmentalism","Neuro diversity"],"qualities":["Optimism","Empathy"],"bio":"Up at five, useless after nine. I teach yoga and I promise not to correct your posture unasked.","looking":["Long-term relationship"],"lat":13.1100,"lng":80.2900,"sex":"female","photos":[15,45,75],"interests":["Yoga","Nutrition","Beaches","Sleeping well","Fitness","Spa"],"lifestyle":["Active","Relaxer","Vegan"],"prompts":[{"q":"My go-to way to recharge is…","a":"A sunrise on the beach before anyone else is awake."},{"q":"A skill I want to learn next is…","a":"Surfing. Kovalam is right there and I keep making excuses."},{"q":"Something I’m currently excited about is…","a":"A retreat I am running in the hills this December."}]},
{"idx":16,"name":"Ishita Bose","gender":"F","pronouns":"she_her","birth":"1997-01-08","orient":"Lesbian","height":172,"title":"Film Editor","company":"Freelance","edu":"Post Graduate","school":"Jadavpur University","hometown":"Kolkata","religion":"Atheist","sign":"Capricorn","politics":"Communist","kids":"Don't want kids","drink":"Socially","smoke":"Social smoker","exercise":"Weekly","rel":"Non-monogamy","intent":"Short-term, open to long","langs":["English","Bengali","Hindi"],"causes":["LGBTQ Rights","Feminism","Human Rights"],"qualities":["Openness","Sassiness"],"bio":"I cut films and overthink endings. Tall enough to reach your top shelf, petty enough to mention it.","looking":["Short-term, open to long"],"lat":13.0480,"lng":80.2600,"sex":"female","photos":[16,46,76],"interests":["Movie","Theater","LGBTQ","Coffee","Jazz","Museum"],"lifestyle":["Night owl","Introvert","Spontaneous"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Editing rhythm. Why a cut two frames later changes everything."},{"q":"My perfect weekend looks like…","a":"A double feature at a half-empty theatre and dinner after midnight."},{"q":"My comfort food is…","a":"Kosha mangsho, the way only my mashi makes it."}]},
{"idx":17,"name":"Pooja Shetty","gender":"F","pronouns":"she_her","birth":"2000-09-16","orient":"Straight","height":154,"title":"Dance Instructor","company":"Bhoomika Creative Dance","edu":"Under Graduate","school":"Ethiraj College","hometown":"Udupi","religion":"Hindu","sign":"Virgo","politics":"Apolitical","kids":"Want Kids","drink":"Occasionally","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Casual dating","langs":["English","Kannada","Tamil"],"causes":["Feminism"],"qualities":["Optimism","Sassiness"],"bio":"Bharatanatyam trained, hip-hop obsessed. If the song is good I will dance in the queue at the billing counter.","looking":["Casual dating"],"lat":13.0150,"lng":80.2280,"sex":"female","photos":[17,47,77],"interests":["Dance","Festival","Desi","Movie","Fitness","Singing"],"lifestyle":["Extrovert","Active","Spontaneous"],"prompts":[{"q":"Something I’m currently excited about is…","a":"A showcase in December that I have been choreographing since June."},{"q":"My go-to way to recharge is…","a":"Two hours in an empty studio with the mirrors and a speaker."},{"q":"My comfort food is…","a":"Neer dosa with coconut chutney. Simple, correct."}]},
{"idx":18,"name":"Zoya Khan","gender":"F","pronouns":"she_her","birth":"1996-05-04","orient":"Straight","height":161,"title":"Veterinarian","company":"Blue Cross of India","edu":"Post Graduate","school":"TANUVAS","hometown":"Chennai","religion":"Muslim","sign":"Taurus","politics":"Moderate","kids":"Open to kids","drink":"Never drink","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Life partner","langs":["English","Tamil","Hindi","Arabic"],"causes":["Environmentalism","End Religious Hate"],"qualities":["Kindness","Empathy"],"bio":"Three rescue dogs, one very unimpressed cat. If you are allergic, this is going to be difficult.","looking":["Life partner"],"lat":13.0900,"lng":80.2600,"sex":"female","photos":[18,48,78],"interests":["Dogs","Cats","Birds","Turtle","Coffee","Nutrition"],"lifestyle":["Home body","Foodie","Relaxer"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Street dog rescue. Ask me and clear your afternoon."},{"q":"My comfort food is…","a":"Haleem in Ramzan. The rest of the year is just waiting."},{"q":"A skill I want to learn next is…","a":"Sign language, properly, not the ten words I know."}]},
{"idx":19,"name":"Radhika Varma","gender":"F","pronouns":"she_her","birth":"1993-02-26","orient":"Straight","height":163,"title":"Investment Banker","company":"Kotak","edu":"Post Graduate","school":"IIM Bangalore","hometown":"Delhi","religion":"Hindu","sign":"Pisces","politics":"Moderate","kids":"Not Sure","drink":"Socially","smoke":"Trying to quit","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Hindi","Punjabi"],"causes":["Feminism","Voter Rights"],"qualities":["Ambition","Confidence"],"bio":"Long hours, short patience for bad coffee. I travel badly planned and love it that way.","looking":["Long-term relationship"],"lat":13.0050,"lng":80.2480,"sex":"female","photos":[19,49,60],"interests":["Wine tasting","Solo trips","City breaks","Coffee","Whiskey","Fitness"],"lifestyle":["Planner","Extrovert","Foodie"],"prompts":[{"q":"My perfect weekend looks like…","a":"A flight I booked on Thursday to a city I have never seen."},{"q":"My go-to way to recharge is…","a":"Airport lounges. I know how that sounds."},{"q":"Something I’m currently excited about is…","a":"Finally taking three weeks off in a row, for the first time in six years."}]},
{"idx":20,"name":"Ananya Reddy","gender":"F","pronouns":"she_her","birth":"1998-12-12","orient":"Straight","height":168,"title":"Civil Services Aspirant","company":"Preparing for UPSC","edu":"Post Graduate","school":"University of Hyderabad","hometown":"Vijayawada","religion":"Hindu","sign":"Sagittarius","politics":"Moderate","kids":"Want Kids","drink":"Never drink","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Life partner","langs":["English","Telugu","Hindi","Tamil"],"causes":["Human Rights","Voter Rights","Environmentalism"],"qualities":["Ambition","Kindness"],"bio":"Currently living inside a syllabus. Ask me anything about the Constitution, nothing about pop culture.","looking":["Life partner"],"lat":13.0750,"lng":80.2050,"sex":"female","photos":[20,50,59],"interests":["Coffee","Museum","Fitness","Classical","Nutrition"],"lifestyle":["Planner","Introvert","Active"],"prompts":[{"q":"My go-to way to recharge is…","a":"A walk without headphones. Rare, and therefore precious."},{"q":"A skill I want to learn next is…","a":"Carnatic vocals. My mother has been suggesting it for 20 years."},{"q":"My comfort food is…","a":"Pesarattu with upma. Sunday morning, no substitutes."}]},
{"idx":21,"name":"Arjun Subramanian","gender":"M","pronouns":"he_him","birth":"1995-06-11","orient":"Straight","height":178,"title":"Backend Engineer","company":"Freshworks","edu":"Under Graduate","school":"CEG Anna University","hometown":"Chennai","religion":"Hindu","sign":"Gemini","politics":"Moderate","kids":"Want Kids","drink":"Socially","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Tamil"],"causes":["Environmentalism"],"qualities":["Humor","Kindness"],"bio":"I run at 5am, which is the most annoying thing about me. Cricket on weekends, filter coffee always.","looking":["Long-term relationship"],"lat":13.0330,"lng":80.2410,"sex":"male","photos":[1,31,61],"interests":["Cricket","Fitness","Coffee","Movie","Beaches","Rock"],"lifestyle":["Active","Gym enthusiast","Planner"],"prompts":[{"q":"My perfect weekend looks like…","a":"Sunday morning gully cricket, then doing absolutely nothing until Monday."},{"q":"My comfort food is…","a":"Two idlis, extra podi, from the cart near my flat."},{"q":"A skill I want to learn next is…","a":"Playing the guitar past the four chords I have known since college."}]},
{"idx":22,"name":"Rohan Mehta","gender":"M","pronouns":"he_him","birth":"1992-10-30","orient":"Straight","height":183,"title":"Startup Founder","company":"Kettle Labs","edu":"Post Graduate","school":"BITS Pilani","hometown":"Ahmedabad","religion":"Jain","sign":"Scorpio","politics":"Moderate","kids":"Open to kids","drink":"Occasionally","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Hindi","Gujarati"],"causes":["Environmentalism","Neuro diversity"],"qualities":["Ambition","Optimism"],"bio":"Building something small and stubborn. I cook well, sleep badly, and will listen to your idea properly.","looking":["Long-term relationship"],"lat":12.9950,"lng":80.2600,"sex":"male","photos":[2,32,62],"interests":["Coffee","Pasta","Solo trips","Photography","Techno","Museum"],"lifestyle":["Night owl","Foodie","Adventurer"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Cooking for eight people who were supposed to be four."},{"q":"Something I’m currently excited about is…","a":"Our first paying customer, who is not a friend of mine."},{"q":"My go-to way to recharge is…","a":"A long ride down ECR at 6am with no destination."}]},
{"idx":23,"name":"Karthik Rajan","gender":"M","pronouns":"he_him","birth":"1997-04-18","orient":"Straight","height":175,"title":"Physiotherapist","company":"MIOT International","edu":"Post Graduate","school":"Sri Ramachandra University","hometown":"Tirunelveli","religion":"Hindu","sign":"Aries","politics":"Apolitical","kids":"Want Kids","drink":"Never drink","smoke":"Non-smoker","exercise":"Daily","rel":"Monogamy","intent":"Life partner","langs":["English","Tamil"],"causes":["Disability Rights"],"qualities":["Empathy","Kindness"],"bio":"I fix people's knees and then tell them to stop running. Marathon runner, so the irony is not lost.","looking":["Life partner"],"lat":13.0180,"lng":80.1990,"sex":"male","photos":[3,33,63],"interests":["Fitness","Nutrition","Yoga","Hiking trips","Coffee"],"lifestyle":["Gym enthusiast","Active","Home body"],"prompts":[{"q":"My go-to way to recharge is…","a":"A very long run and a very cold shower."},{"q":"A skill I want to learn next is…","a":"Cooking anything that is not chicken and rice."},{"q":"My comfort food is…","a":"My grandmother's mutton kuzhambu. Nothing comes close."}]},
{"idx":24,"name":"Vikram Nair","gender":"M","pronouns":"he_him","birth":"1994-08-07","orient":"Straight","height":180,"title":"Cinematographer","company":"Freelance","edu":"Diploma","school":"LV Prasad Film Institute","hometown":"Kozhikode","religion":"Hindu","sign":"Leo","politics":"Socialist","kids":"Not Sure","drink":"Socially","smoke":"Smoker","exercise":"Weekly","rel":"Open to exploring","intent":"Short-term, open to long","langs":["English","Malayalam","Tamil","Hindi"],"causes":["Human Rights","Indigenous Rights"],"qualities":["Openness","Confidence"],"bio":"I chase light for a living. Unpredictable schedule, very predictable order at every restaurant.","looking":["Short-term, open to long"],"lat":13.0620,"lng":80.2750,"sex":"male","photos":[4,34,64],"interests":["Photography","Movie","Solo trips","Coffee","Jazz","Whiskey"],"lifestyle":["Night owl","Adventurer","Spontaneous"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Available light. I have never met a golden hour I did not overshoot."},{"q":"My perfect weekend looks like…","a":"A drive to somewhere green, camera in the back, phone off."},{"q":"Something I’m currently excited about is…","a":"A short film I shot entirely on one 35mm lens."}]},
{"idx":25,"name":"Aditya Sharma","gender":"M","pronouns":"he_him","birth":"1999-03-02","orient":"Straight","height":172,"title":"Financial Analyst","company":"World Bank Group","edu":"Post Graduate","school":"Madras School of Economics","hometown":"Bhopal","religion":"Hindu","sign":"Pisces","politics":"Moderate","kids":"Want Kids","drink":"Occasionally","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term, open to short","langs":["English","Hindi","Tamil"],"causes":["Voter Rights","Environmentalism"],"qualities":["Humor","Ambition"],"bio":"Numbers all day, board games all evening. I lose gracefully at Catan roughly 40% of the time.","looking":["Long-term, open to short"],"lat":13.0850,"lng":80.2350,"sex":"male","photos":[5,35,65],"interests":["Coffee","Movie","Pizza","Basket ball","Museum","Beer"],"lifestyle":["Planner","Foodie","Introvert"],"prompts":[{"q":"My perfect weekend looks like…","a":"Board game night that runs three hours past when everyone said they would leave."},{"q":"My comfort food is…","a":"Poha, made properly, which almost nobody in this city does."},{"q":"A skill I want to learn next is…","a":"Chess openings beyond just moving a pawn and hoping."}]},
{"idx":26,"name":"Imran Qureshi","gender":"M","pronouns":"he_him","birth":"1996-12-20","orient":"Straight","height":177,"title":"Music Producer","company":"Freelance","edu":"Under Graduate","school":"KM Music Conservatory","hometown":"Chennai","religion":"Muslim","sign":"Sagittarius","politics":"Not Interested","kids":"Not Sure","drink":"Never drink","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Casual dating","langs":["English","Tamil","Hindi"],"causes":["End Religious Hate","LGBTQ Rights"],"qualities":["Openness","Humor"],"bio":"I make beats in a room with bad acoustics and good intentions. Will play you something unfinished.","looking":["Casual dating"],"lat":13.0980,"lng":80.2450,"sex":"male","photos":[6,36,66],"interests":["Techno","Jazz","Singing","Club","Coffee","K-pop"],"lifestyle":["Night owl","Introvert","Spontaneous"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Sampling. Half my tracks start with a sound I recorded on a bus."},{"q":"My go-to way to recharge is…","a":"Headphones on, walking Marina at midnight."},{"q":"Something I’m currently excited about is…","a":"An EP that is 80% done and has been 80% done for five months."}]},
{"idx":27,"name":"Nikhil Joseph","gender":"M","pronouns":"he_him","birth":"1993-05-15","orient":"Straight","height":185,"title":"Secondary School Teacher","company":"DAV Public School","edu":"Post Graduate","school":"Madras Christian College","hometown":"Chennai","religion":"Christian","sign":"Taurus","politics":"Moderate","kids":"Have kids","drink":"Socially","smoke":"Non-smoker","exercise":"Weekly","rel":"Monogamy","intent":"Long-term relationship","langs":["English","Tamil","Malayalam"],"causes":["Disability Rights","Human Rights"],"qualities":["Kindness","Empathy"],"bio":"I teach history to teenagers, so very little intimidates me now. Dad to one small, loud person.","looking":["Long-term relationship"],"lat":13.1250,"lng":80.2150,"sex":"male","photos":[7,37,67],"interests":["Museum","Movie","Football","Coffee","Theater","Birds"],"lifestyle":["Home body","Planner","Foodie"],"prompts":[{"q":"My comfort food is…","a":"Appam and mutton stew, Christmas morning, every single year."},{"q":"My perfect weekend looks like…","a":"Football in the morning with my son, and a nap I have fully earned."},{"q":"A skill I want to learn next is…","a":"Carpentry. I have watched enough videos to be dangerous."}]},
{"idx":28,"name":"Siddharth Rao","gender":"M","pronouns":"he_him","birth":"2000-01-25","orient":"Bisexual","height":174,"title":"UI Developer","company":"Zoho","edu":"Under Graduate","school":"SSN College of Engineering","hometown":"Chennai","religion":"Agnostic","sign":"Aquarius","politics":"Socialist","kids":"Don't want kids","drink":"Occasionally","smoke":"Social smoker","exercise":"Weekly","rel":"Non-monogamy","intent":"Short-term relationship","langs":["English","Tamil","Telugu"],"causes":["LGBTQ Rights","Neuro diversity"],"qualities":["Sassiness","Openness"],"bio":"I care far too much about button states. Skateboard in the boot, mostly for looks at this point.","looking":["Short-term relationship"],"lat":12.9750,"lng":80.2300,"sex":"male","photos":[8,38,68],"interests":["Design","LGBTQ","Techno","Coffee","Club","Fashion"],"lifestyle":["Night owl","Extrovert","Spontaneous"],"prompts":[{"q":"The most useless skill I’m great at is…","a":"Spotting a misaligned icon from across the room."},{"q":"My perfect weekend looks like…","a":"Skate park at 6am when it is empty, then sleeping till 3."},{"q":"Something I’m currently excited about is…","a":"A side project nobody asked for that I am building anyway."}]},
{"idx":29,"name":"Kiran Anand","gender":"NB","pronouns":"they_them","birth":"1997-09-19","orient":"Pansexual","height":170,"title":"Illustrator","company":"Freelance","edu":"Under Graduate","school":"Srishti Institute","hometown":"Bengaluru","religion":"Agnostic","sign":"Virgo","politics":"Socialist","kids":"Don't want kids","drink":"Occasionally","smoke":"Non-smoker","exercise":"Weekly","rel":"Open to exploring","intent":"Still figuring it out","langs":["English","Kannada","Tamil"],"causes":["LGBTQ Rights","Neuro diversity","Feminism"],"qualities":["Openness","Empathy"],"bio":"I draw comics about small awkward moments. Plant collection is out of hand and getting worse.","looking":["Still figuring it out"],"lat":13.0400,"lng":80.2200,"sex":"female","photos":[21,51,58],"interests":["Art","Painting","LGBTQ","Coffee","Cats","Museum"],"lifestyle":["Home body","Introvert","Relaxer"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Comics. Specifically the quiet ones where nothing much happens."},{"q":"My go-to way to recharge is…","a":"Repotting plants and pretending it is not procrastination."},{"q":"My comfort food is…","a":"Curd rice. It is a whole personality and I accept that."}]},
{"idx":30,"name":"Aarav Krishnan","gender":"NB","pronouns":"they_them","birth":"1998-06-28","orient":"Queer","height":168,"title":"Environmental Researcher","company":"Care Earth Trust","edu":"Post Graduate","school":"Pondicherry University","hometown":"Puducherry","religion":"Atheist","sign":"Cancer","politics":"Communist","kids":"Not Sure","drink":"Never drink","smoke":"Non-smoker","exercise":"Daily","rel":"Non-monogamy","intent":"Long-term, open to short","langs":["English","Tamil","French"],"causes":["Environmentalism","LGBTQ Rights","Indigenous Rights"],"qualities":["Ambition","Openness"],"bio":"I count birds in wetlands and get unreasonably happy about it. Cycles everywhere, owns no car.","looking":["Long-term, open to short"],"lat":12.9880,"lng":80.2480,"sex":"male","photos":[9,39,69],"interests":["Birds","Hiking trips","Beaches","Turtle","Coffee","Photography"],"lifestyle":["Adventurer","Active","Vegan"],"prompts":[{"q":"A hobby I can talk about for hours is…","a":"Pallikaranai marsh. It is a wetland, it is under threat, and it is magnificent."},{"q":"My perfect weekend looks like…","a":"A 5am bird count and a very long nap afterwards."},{"q":"A skill I want to learn next is…","a":"Bird calls by ear alone, without cheating with the app."}]}
]
$json$::jsonb) AS x(
  idx int, name text, gender text, pronouns text, birth date, orient text, height int,
  title text, company text, edu text, school text, hometown text, religion text,
  sign text, politics text, kids text, drink text, smoke text, exercise text,
  rel text, intent text, langs text[], causes text[], qualities text[], bio text,
  looking text[], lat double precision, lng double precision, sex text,
  photos int[], interests text[], lifestyle text[], prompts jsonb
);

-- Ids derived from idx so every step below finds its rows without threading a
-- RETURNING clause through five inserts.
ALTER TABLE public._seed_data
  ADD COLUMN user_id uuid GENERATED ALWAYS AS
    (('aaaaaaaa-0000-4000-8000-' || lpad(idx::text, 12, '0'))::uuid) STORED,
  ADD COLUMN profile_id uuid GENERATED ALWAYS AS
    (('bbbbbbbb-0000-4000-8000-' || lpad(idx::text, 12, '0'))::uuid) STORED,
  ADD COLUMN date_mode_id uuid GENERATED ALWAYS AS
    (('cccccccc-0000-4000-8000-' || lpad(idx::text, 12, '0'))::uuid) STORED,
  ADD COLUMN bff_mode_id uuid GENERATED ALWAYS AS
    (('dddddddd-0000-4000-8000-' || lpad(idx::text, 12, '0'))::uuid) STORED;


-- ---------------------------------------------------------------------------
-- 2. Auth users. Email/password, pre-confirmed — the app's Google flow is
--    bypassed entirely, and the photo uploader signs in as these.
-- ---------------------------------------------------------------------------
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  created_at, updated_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  d.user_id,
  'authenticated',
  'authenticated',
  'seed' || lpad(d.idx::text, 2, '0') || '@blindly.test',
  extensions.crypt('Seed@12345', extensions.gen_salt('bf')),
  now(), now(), now(), now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object('full_name', d.name, 'seed', true),
  '', '', '', ''
FROM public._seed_data d
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------------
-- 3. Profiles + both modes + interests + lifestyle + prompts.
--
--    is_verified / full_verified / trust_score are set here rather than earned:
--    these exist to test discovery, swipes and chat, not the verification
--    pipeline. last_active is staggered so "Recently Active" has an order.
-- ---------------------------------------------------------------------------
INSERT INTO public.profiles (
  id, user_id, display_name, birth_date, gender, pronouns,
  location_geom, city, state, country,
  trust_score, is_verified, verification_level, profile_completeness,
  last_active, is_active, is_deleted, created_at, updated_at,
  onboarding_status, steps_progress,
  hometown_city, height_cm,
  work_title, work_company, education_school, education_level, educated_at,
  graduation_year, politics, religion, star_sign, kids_preference, have_kids,
  drinking, smoking, exercise, current_mode, relationship_type,
  sexual_orientation, dating_intention, languages, causes_communities, qualities
)
SELECT
  d.profile_id, d.user_id, d.name, d.birth, d.gender::gender_enum,
  d.pronouns::pronouns_enum,
  ST_SetSRID(ST_MakePoint(d.lng, d.lat), 4326)::geography,
  'Chennai', 'Tamil Nadu', 'IN',
  -- 62..96, deterministic, so trust-score ordering is visibly varied.
  62 + (d.idx * 7) % 35,
  true, 'full_verified'::verification_level, 100,
  -- 2h apart, newest first, so "Recently Active" is not one timestamp.
  now() - ((d.idx * 2) || ' hours')::interval,
  true, false,
  now() - (d.idx || ' days')::interval,
  now(),
  'completed', '{}'::jsonb,
  d.hometown, d.height,
  d.title, d.company, d.school, d.edu, d.school,
  EXTRACT(YEAR FROM d.birth)::int + 22,
  d.politics, d.religion, d.sign, d.kids, (d.kids = 'Have kids'),
  d.drink, d.smoke, d.exercise, 'date', d.rel,
  d.orient, d.intent, d.langs, d.causes, d.qualities
FROM public._seed_data d
ON CONFLICT (id) DO NOTHING;

-- Both modes for everyone, so the Date and BFF tabs are equally populated.
INSERT INTO public.profile_modes (id, profile_id, mode, bio, is_active, looking_for, filters)
SELECT d.date_mode_id, d.profile_id, 'date', d.bio, true, d.looking, '{}'::jsonb
FROM public._seed_data d
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profile_modes (id, profile_id, mode, bio, is_active, looking_for, filters)
SELECT d.bff_mode_id, d.profile_id, 'bff', d.bio, true,
       ARRAY['New friends','Activity partners'], '{}'::jsonb
FROM public._seed_data d
ON CONFLICT (id) DO NOTHING;

-- Chip labels are not unique in interest_chips/lifestyle_chips ("Yoga",
-- "Never", "Occasionally" and "Frequently" each exist twice), so pick one id
-- per label or the same chip lands on a profile twice.
INSERT INTO public.profile_mode_interestchips (profile_mode_id, chip_id)
SELECT m.mode_id, c.chip_id
FROM public._seed_data d
CROSS JOIN LATERAL (VALUES (d.date_mode_id), (d.bff_mode_id)) AS m(mode_id)
CROSS JOIN LATERAL unnest(d.interests) AS lbl
JOIN LATERAL (
  SELECT ic.id AS chip_id FROM public.interest_chips ic WHERE ic.label = lbl ORDER BY ic.id LIMIT 1
) c ON true
ON CONFLICT DO NOTHING;

INSERT INTO public.profile_mode_lifestylechips (profile_mode_id, chip_id)
SELECT m.mode_id, c.chip_id
FROM public._seed_data d
CROSS JOIN LATERAL (VALUES (d.date_mode_id), (d.bff_mode_id)) AS m(mode_id)
CROSS JOIN LATERAL unnest(d.lifestyle) AS lbl
JOIN LATERAL (
  SELECT lc.id AS chip_id FROM public.lifestyle_chips lc WHERE lc.label = lbl ORDER BY lc.id LIMIT 1
) c ON true
ON CONFLICT DO NOTHING;

INSERT INTO public.profile_mode_prompts (profile_mode_id, prompt_template_id, user_response, display_order)
SELECT d.date_mode_id, pt.id, p.value->>'a', p.ordinality::smallint
FROM public._seed_data d
CROSS JOIN LATERAL jsonb_array_elements(d.prompts) WITH ORDINALITY AS p(value, ordinality)
JOIN public.prompt_templates pt ON pt.prompt_text = p.value->>'q'
ON CONFLICT DO NOTHING;


-- ---------------------------------------------------------------------------
-- 4. Photo rows. Run this ONLY after scripts/seed_test_profiles_photos.sh has
--    uploaded the files — the paths below are the ones that script writes.
--    moderation_status is forced to approved: the AWS moderation lambda never
--    saw these, and an unapproved photo would not render.
-- ---------------------------------------------------------------------------
INSERT INTO public.profile_mode_media (
  profile_mode_id, media_url, media_type, display_order, is_primary,
  moderation_status, is_deleted
)
SELECT
  m.mode_id,
  d.user_id::text || '/' || n.ord || '.jpg',
  'photo',
  (n.ord - 1)::smallint,
  (n.ord = 1),
  'approved'::moderation_status,
  false
FROM public._seed_data d
CROSS JOIN LATERAL (VALUES (d.date_mode_id), (d.bff_mode_id)) AS m(mode_id)
CROSS JOIN generate_series(1, 3) AS n(ord)
ON CONFLICT DO NOTHING;


-- ---------------------------------------------------------------------------
-- Cleanup, when you are done with them. Deleting the auth users cascades to
-- profiles, modes, media rows, swipes and matches.
--
--   DELETE FROM auth.users WHERE email LIKE 'seed__@blindly.test';
--   DROP TABLE IF EXISTS public._seed_data;
--
-- The storage objects are not cascaded; drop them with:
--   DELETE FROM storage.objects
--    WHERE bucket_id = 'user_photos'
--      AND (storage.foldername(name))[1] LIKE 'aaaaaaaa-0000-4000-8000-%';
-- ---------------------------------------------------------------------------
