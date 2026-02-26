# AI/ML Internship - Week 1 Plan
**Project:** Blindly Dating App
**Duration:** 6 Days
**Structure:** 2 Interns, 3 Tasks per Intern (2 days per task)

## Overview
The goal of this week is for the interns to learn core ML concepts (NLP, Computer Vision, Data Clustering) while building prototypes that directly benefit the Blindly dating app ecosystem. They will research, prototype, and document their findings.

---

## 👩‍💻 Intern 1: Focus on NLP & Generative AI

### Task 1: Semantic Profile Matching (Days 1-2)
**Objective:** Move beyond simple keyword matching (like overlapping tags) to understand the *meaning* of user bios.
* **Requirements:**
  * Research and implement a lightweight text embedding model (e.g., Sentence-BERT or TF-IDF).
  * Write a Python script that takes two sample user bios and calculates a semantic similarity score (0.0 to 1.0).
  * Document how this could be added to our existing Smart Discovery scoring algorithm.

### Task 2: Chat Moderation & Toxicity Detection (Days 3-4)
**Objective:** Ensure a safe environment by automatically detecting offensive language in chat messages or profile prompts.
* **Requirements:**
  * Explore existing pre-trained toxicity classification models (e.g., Hugging Face `transformers`).
  * Build a simple FastAPI or Flask endpoint that accepts a text string and returns a "Safe" or "Flagged" status with a confidence score.
  * Test the model with 50 diverse sample sentences (clean, borderline, and toxic).

### Task 3: Intelligent Icebreaker Generation (Days 5-6)
**Objective:** Help users start conversations by generating personalized opening lines based on shared traits.
* **Requirements:**
  * Use a local LLM or API (like OpenAI API or Hugging Face) to generate 3 unique icebreakers given two users' interests and bios.
  * Define strict prompts to ensure the AI generates casual, natural, and non-creepy conversation starters.
  * Present a demo showing the inputs and the generated outputs.

---

## 👨‍💻 Intern 2: Focus on Computer Vision & Data Analytics

### Task 1: Profile Image Quality Assurance (Days 1-2)
**Objective:** Prevent users from uploading bad quality photos (blurry, dark, or no faces) to improve the dating pool quality.
* **Requirements:**
  * Research OpenCV and lightweight CNNs for image analysis.
  * Build a Python script that takes an image and outputs scores for: Blur level, Brightness, and Face Count (ensuring there is exactly 1 face for a profile picture).
  * Write a report on what thresholds (e.g., blur score < 50) Blindly should use to reject bad photos.

### Task 2: Photo Similarity & Verification Basics (Days 3-4)
**Objective:** Prototype the basics of profile verification to prevent catfishing.
* **Requirements:**
  * Use a library like `face_recognition` (dlib) or DeepFace.
  * Write a script that compares two images (e.g., a simulated "live selfie" and a "profile picture") and determines if they are the same person.
  * Document the false positive/false negative rates using a small test dataset of faces.

### Task 3: Swipe Behavior Clustering (Days 5-6)
**Objective:** Understand how different users interact with the app to improve the recommendation algorithm later.
* **Requirements:**
  * Generate a fake dataset (CSV) of 1,000 users containing their swipe history (e.g., total right swipes, total left swipes, time spent looking at a profile).
  * Use K-Means clustering (via `scikit-learn`) to group these users into behavioral archetypes (e.g., "The Selective Swiper", "The Mass Swiper").
  * Create visual graphs (using `matplotlib` or `seaborn`) to present these user segments to the team.

---

## 📅 Deliverables (End of Day 6)
On Day 6, both interns should have:
1. Python scripts/Jupyter Notebooks for each task.
2. A short slide presentation (10 minutes each) demonstrating their functional prototypes.
3. Recommendations on which feature is the most viable to integrate into the main Blindly codebase.

---

## 💡 Alternative Task Pool (Choose 3)
If you prefer different challenges, here is a fresh set of 6 tasks highly relevant to a dating app:

### Alternative 1: Ghosting & Churn Prediction (Tabular / Time Series)
**Objective:** Identify users who are likely to stop using the app (ghosting) based on their message reply times and session lengths.
* **Requirements:** Build a dummy dataset of chat frequencies and login sessions. Train a Random Forest or XGBoost model to predict a "Churn Risk Score" (0-100%).

### Alternative 2: Spam & Bot Detection Engine (Anomaly Detection)
**Objective:** Automatically flag suspicious profiles that might be bots or scammers.
* **Requirements:** Use Isolation Forests or basic heuristics to flag accounts that swipe right on *everyone* in less than 1 second, or accounts with bio texts containing crypto/Instagram links combined with suspicious IP distances.

### Alternative 3: Photo "Vibe" Tagging (Computer Vision Classification)
**Objective:** Automatically suggest lifestyle tags based on user photos (e.g., detecting a dog, a mountain, or gym equipment).
* **Requirements:** Use a pre-trained ResNet or MobileNet model. Write a script that takes a user's uploaded photo and outputs a JSON list of probable lifestyle tags (e.g., `["pet_owner", "outdoors", "fitness"]`).

### Alternative 4: Collaborative Filtering MVP (Recommendation Systems)
**Objective:** Recommend profiles based on what *similar* users liked, rather than just raw profile data ("Users who liked A also liked B").
* **Requirements:** Create a sparse matrix (Users x Swiped Profiles). Implement a basic collaborative filtering algorithm (using cosine similarity or Matrix Factorization) to predict if User X will like Profile Y.

### Alternative 5: Voice Intro Transcription & Vibe Check (Audio/NLP)
**Objective:** Transcribe the blind "Voice Intro" feature and analyze the sentiment to ensure it's positive and appropriate.
* **Requirements:** Use OpenAI's Whisper (local/open-source version) to convert an audio `.mp3` file to text. Run a basic sentiment analysis (Positive, Neutral, Negative) on the transcribed text.

### Alternative 6: Dynamic Push Notification Optimizer (Data Science)
**Objective:** Figure out the exact best time to send a push notification ("You have a new match!") to maximize the chance the user opens the app.
* **Requirements:** Analyze a simulated dataset of "app open times" per user. Write a script that predicts the optimal golden hour (e.g., 7:00 PM vs 9:00 AM) for a specific user to receive notifications.

### Alternative 7: "Blindly Plus" Conversion Predictor (Propensity Modeling)
**Objective:** Build a predictive machine learning model that analyzes free user behavior to identify which non-paying users have the highest statistical probability of purchasing a "Blindly Plus" premium subscription. This will allow the marketing team to launch hyper-targeted, high-conversion promotional campaigns.
* **Requirements:** Generate a mock dataset containing features like "daily swipes", "matches per week", "messages sent", "profile completion %", and a label "bought_premium (0 or 1)". Train a logistic regression, XGBoost, or Random Forest model to output a continuous "Propensity to Buy" score between 0.0 and 1.0 for each free user.
