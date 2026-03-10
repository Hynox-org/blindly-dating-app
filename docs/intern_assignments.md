# WEEK PLAN – BLINDLY APP FEATURE IMPLEMENTATION

**Intern 1 – Saravanan**  
**Track:** AI Compatibility & Engagement Intelligence  

**Intern 2 – Sailappan**  
**Track:** Chat Security & Global Accessibility  

---

### DAY 1: Foundation & Data Analysis
**Saravanan – Compatibility Score Refinement**
*   **Task:** Analyze `ml_lambda/lambda_function.py`. Currently, it uses Interests (40%), Distance (25%), Lifestyle (20%), and Recency (15%).
*   **Deliverables:**
    *   Propose and implement a revised weighting system.
    *   Add a "Profile Completeness" factor to the score.
    *   Generate a "Matching Confidence" percentage.
    *   Provide a report on how different weights affect top-match quality.

**Sailappan – Content Moderation Strategy**
*   **Task:** Define the moderation architecture for the chat system.
*   **Deliverables:**
    *   Research and select a moderation approach (Regex-based vs. Perspective API vs. OpenAI Moderation).
    *   Define a "Toxic Keyword" list for initial local filtering.
    *   Create a schema for `moderation_logs` in Supabase.
    *   Document the flow: Message -> Filter -> Flag/Block -> Send.

---

### DAY 2: Logic Development
**Saravanan – AI Compatibility Explanations**
*   **Task:** Build the logic to explain *why* two users matched based on shared features.
*   **Deliverables:**
    *   Implement function to find top 2 shared interests or lifestyle traits.
    *   Generate human-readable strings (e.g., "You both enjoy *Indie Music* and *Hiking*").
    *   Update Lambda response to include `explanation_string`.
    *   Test explanations across 5 diverse profile pairs.

**Sailappan – Real-time Filtering Engine**
*   **Task:** Implement the core moderation logic in a Supabase Edge Function or Backend service.
*   **Deliverables:**
    *   Build the `check_message_safety` function.
    *   Implement "Warning" response for toxic content.
    *   Integrate the selected Moderation API.
    *   Ensure latency remains under 200ms for safety checks.

---

### DAY 3: Intelligence Features
**Saravanan – AI-Powered Icebreaker Engine**
*   **Task:** Create a system to generate conversation starters based on profile data.
*   **Deliverables:**
    *   Implement icebreaker generation prompt/logic using interests and bio.
    *   Generate 3 unique icebreakers per match (e.g., One question, one observation, one fun fact).
    *   Create a test script to verify icebreaker relevance for 10 mock profiles.

**Sailappan – Implementation of Chat Translation**
*   **Task:** Set up the translation pipeline for the chat interface.
*   **Deliverables:**
    *   Integrate a Translation API (Google/DeepL).
    *   Implement auto-detection of the sender's language.
    *   Write a translation function that accepts `text` and `target_language`.
    *   Implement caching for translated messages to reduce API costs.

---

### DAY 4: UI/UX Integration (Flutter)
**Saravanan – Discovery UI Enhancements**
*   **Task:** Update the Discovery/Match screen to show AI insights.
*   **Deliverables:**
    *   Display the "Compatibility Confidence" percentage.
    *   Render the "Compatibility Explanation" bubble.
    *   Ensure design follows `theme-handler.md` (white backgrounds/premium feel).

**Sailappan – Chat UI Enhancements**
*   **Task:** Integrate moderation feedback and translation buttons in the Chat screen.
*   **Deliverables:**
    *   Add "Translate" icon/button to incoming messages.
    *   Implement "Toggle" between original and translated text.
    *   Add placeholder/warning UI for blocked/moderated messages.

---

### DAY 5: Specialized Pipelines
**Saravanan – Icebreaker "Magic Wand" UI**
*   **Task:** Implement the interactive "Magic Wand" in the chat input area.
*   **Deliverables:**
    *   Add Magic Wand icon to `ChatInputWidget`.
    *   Implement popup/overlay showing the 3 generated icebreakers.
    *   One-tap functionality to populate the text field with a selected icebreaker.

**Sailappan – Multilingual Profile Support**
*   **Task:** Extend translation to user profiles.
*   **Deliverables:**
    *   "Translate Bio" button on Profile screens.
    *   Handle RTL (Right-to-Left) language rendering if necessary.
    *   Ensure translation state is maintained during navigation.

---

### DAY 6: Joint Integration & Edge Cases
**Saravanan and Sailappan – Secure & Smart Chat Flow**
*   **Task:** Ensure AI features (Icebreakers/Translation) respect security (Moderation).
*   **Deliverables:**
    *   Verify that generated icebreakers are passed through the moderation filter.
    *   Verify that translations do not bypass or accidentally introduce toxic terms.
    *   Run end-to-end "Match -> Icebreaker -> Conversation -> Translation" flow tests.

---

### DAY 7: Executive Review Deliverables

**Saravanan and Sailappan must each submit:**
1.  **Code Repository:** Clean, commented code in respective feature branches.
2.  **Logic Diagrams:** Visual flow of the AI/Moderation logic.
3.  **UI Walkthrough:** Video or screenshots of the implemented features.
4.  **Performance Report:** API latency and scoring accuracy metrics.
5.  **Next-Phase Plan:** Roadmap for future AI enhancements (e.g., Voice AI or Video moderation).
