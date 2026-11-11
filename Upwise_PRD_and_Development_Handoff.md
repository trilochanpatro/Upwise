# Upwise --- Product Requirements & Development Handoff

**Document type:** Product Requirements Document (PRD) + Development
Continuity Brief\
**Version:** 1.0\
**Status:** Initial product definition; MVP implementation not yet
started\
**Platform priority:** Android first\
**Working product name:** Upwise

------------------------------------------------------------------------

## 1. Purpose of this document

This document captures the product decisions and technical direction
established so far. It is intended to let a future developer, AI
assistant, or product team resume work without needing to reconstruct
the earlier conversation.

Use this as the source of truth unless the product owner explicitly
changes a decision. Distinguish confirmed decisions from recommendations
and open questions.

## 2. Product vision

Upwise is an AI-powered personal growth and life-management
application. It helps people translate ambitions into realistic actions,
track progress, and adapt plans as their circumstances change.

**Core promise:** Understand the person, understand their reality, build
a practical plan, support action, measure progress, and adapt
continuously.

The product should be more than a generic chatbot, motivational app, or
habit tracker. Its differentiator is an interconnected AI life coach
that can reason across goals, career, income, skills, focus, health, and
future scenarios.

### Product principles

1.  Practical actions over generic motivation.
2.  Realistic plans that account for time, money, skills,
    responsibilities, and constraints.
3.  Adaptation rather than rigid schedules.
4.  User control, consent, privacy, and transparency.
5.  Measurable real-world progress rather than chat volume.
6.  Simple, premium, accessible UI with low cognitive load.

## 3. Confirmed product decisions

  -----------------------------------------------------------------------
  Area                                Confirmed decision
  ----------------------------------- -----------------------------------
  Product name                        Upwise (working name)

  Initial platform                    Android first

  Future platforms                    iOS and web may follow

  Audience                            Broad audience: students,
                                      employees, freelancers,
                                      professionals, and entrepreneurs

  Visual direction                    Minimal, premium, modern

  AI behavior                         Proactive AI life coach

  Immediate deliverable               Complete product blueprint and UI
                                      prototype

  Next implementation direction       Build an Android MVP, starting with
                                      onboarding, dashboard, goals, and
                                      AI Coach
  -----------------------------------------------------------------------

## 4. Target users

The initial product should support adults in different life stages,
including:

-   Students who want to build skills, focus, and career readiness.
-   Employees who want professional development, better routines, and
    career progression.
-   Freelancers who want to improve skills, find opportunities, and
    stabilize income.
-   Entrepreneurs who want to prioritize work, build capabilities, and
    manage goals.
-   People seeking structured personal growth across multiple life
    areas.

The onboarding flow must not assume that every user is employed, has
disposable income, has the same education, or has the same amount of
free time.

## 5. Product modules

The product vision includes eight connected modules.

### 5.1 Personal goals and life tracking

-   Short-, medium-, and long-term goals.
-   Milestones and target dates.
-   Daily and weekly action plans.
-   Habit tracking.
-   Goal progress and review history.

### 5.2 Career and professional growth

-   Career direction and role exploration.
-   Job readiness, interview preparation, and resume support.
-   Promotion and professional development plans.
-   Career skill gap analysis.
-   Practical projects and portfolio milestones.

### 5.3 Money and income growth

-   Optional income, expense, and savings tracking.
-   Income goals and budgeting.
-   Side-income and freelancing plans.
-   Business or earning-opportunity exploration.
-   Clear distinction between educational guidance and regulated
    financial advice.

### 5.4 Skills development

-   Hard skills and soft skills.
-   Current proficiency and target proficiency.
-   Learning roadmaps and practice tasks.
-   Portfolio projects and assessments.
-   Suggested learning resources.

### 5.5 Mental focus and mindset

-   Focus sessions and deep-work planning.
-   Distraction management.
-   Journaling and reflection.
-   Routine and consistency tracking.
-   Supportive, non-judgmental coaching.

### 5.6 Health and lifestyle

-   User-entered or permission-based sleep, exercise, nutrition,
    hydration, and wellness tracking.
-   Healthy routine planning.
-   Evidence-based general wellness information.
-   No diagnosis or replacement of professional medical care.

### 5.7 Future life simulator

-   Scenario comparisons over 6 months, 1 year, and 5 years.
-   Career, learning, savings, and habit projections.
-   Explicit assumptions, uncertainty, risks, and sensitivity to changed
    inputs.
-   No claims to know or guarantee the future.

### 5.8 AI personal life coach

-   Conversational discovery and goal clarification.
-   Structured understanding of user context.
-   Personalized action planning.
-   Progress check-ins and reviews.
-   Recommendations and plan adaptation.
-   Proposed actions with user approval where needed.

## 6. Application navigation and screen inventory

Recommended bottom navigation has five destinations:

1.  **Home** --- daily overview, priorities, progress, and AI insights.
2.  **Goals** --- goals, milestones, habits, and action plans.
3.  **AI Coach** --- conversation, discovery, planning, and check-ins.
4.  **Growth** --- career, income, skills, focus, health, and future
    scenarios.
5.  **Profile** --- personal profile, preferences, privacy,
    notifications, and account.

### Initial screen inventory

  Screen                 Purpose                              MVP priority
  ---------------------- ------------------------------------ --------------
  Splash                 Brand and app loading                P0
  Welcome                Explain product value                P0
  Onboarding/discovery   Gather user context progressively    P0
  Goal selection         Capture priority outcomes            P0
  AI plan creation       Generate first plan                  P0
  Home dashboard         Daily actions and progress           P0
  Goals list/detail      Create and track goals               P0
  AI Coach chat          Conversational planning and review   P0
  Growth overview        Cross-domain growth summary          P1
  Career and skills      Roadmaps and learning progress       P1
  Income and budget      Optional financial tracking          P1
  Focus and wellness     Routines and tracking                P1
  Future simulator       Scenario planning                    P2
  Profile and settings   Preferences, privacy, account        P0

## 7. Onboarding requirements

Onboarding should feel like a conversation, not a long form. The AI
should ask one useful question at a time and allow users to skip
questions.

Suggested discovery areas:

-   Life stage and current situation.
-   Education, work, or business context.
-   Current skills and interests.
-   Goals and desired outcomes.
-   Time available each day or week.
-   Budget and resource constraints, if relevant.
-   Responsibilities and limitations.
-   Preferred learning and communication style.
-   Optional health and lifestyle context.

At the end, the app should summarize what it understood and ask the user
to confirm or correct it before creating a plan.

## 8. AI Coach requirements

### 8.1 Core coaching loop

1.  **Discover:** Understand goals, context, responsibilities, and
    constraints.
2.  **Analyze:** Identify gaps, opportunities, dependencies, and risks.
3.  **Prioritize:** Select a small number of high-value objectives.
4.  **Plan:** Create realistic daily, weekly, and monthly actions.
5.  **Execute:** Create tasks, reminders, and approved integrations.
6.  **Review:** Compare planned and actual progress.
7.  **Adapt:** Revise the plan when goals, capacity, or circumstances
    change.

### 8.2 Behavior rules

The AI must:

-   Ask for missing information when it materially affects a
    recommendation.
-   Never assume unlimited time, money, energy, or resources.
-   Convert broad ambitions into measurable outcomes and milestones.
-   Explain why a recommendation is relevant.
-   Keep daily plans achievable and prioritize rather than overload.
-   Respond to missed tasks without shame or punishment.
-   Distinguish user-reported facts from estimates and assumptions.
-   Clearly label proposed actions versus completed actions.
-   Never claim it sent a message, booked something, spent money, or
    changed data unless the action actually succeeded.
-   Request confirmation before consequential external actions.
-   Avoid presenting projections as guaranteed outcomes.
-   Escalate to appropriate professional support for medical,
    mental-health, legal, or financial matters when warranted.

### 8.3 Example structured user context

This is an illustrative schema only; it is not real user data.

``` json
{
  "profile": {
    "life_stage": null,
    "current_situation": null,
    "available_hours_per_week": null,
    "current_skills": [],
    "interests": [],
    "constraints": []
  },
  "goals": [],
  "habits": [],
  "active_plans": [],
  "progress_history": [],
  "preferences": {
    "communication_style": null,
    "check_in_frequency": null
  }
}
```

Store structured, user-correctable memory separately from raw
conversation history. Give users visibility and control over retained
personal context.

## 9. Proactive behavior and triggers

Proactive messages should be user-configurable and should respect quiet
hours and notification permissions.

  -----------------------------------------------------------------------
  Trigger                             Possible response
  ----------------------------------- -----------------------------------
  Morning check-in                    Summarize today's top priorities

  Missed tasks                        Offer a smaller recovery plan

  Deadline approaching                Review milestone status and
                                      blockers

  Skill milestone completed           Suggest the next practical
                                      milestone

  Weekly review                       Summarize wins, missed actions, and
                                      adjustments

  Monthly review                      Reassess goals and future scenarios

  User reports stress or low capacity Reduce workload and offer
                                      supportive options
  -----------------------------------------------------------------------

Do not send excessive notifications. Users should control frequency,
channels, and quiet hours.

## 10. MVP scope

### P0 --- Must have for first usable release

-   Android app shell and navigation.
-   Sign-up, sign-in, and secure session management.
-   Progressive onboarding and user profile.
-   AI discovery conversation.
-   Goal creation, editing, and archiving.
-   Milestones and target dates.
-   AI-generated daily and weekly plans.
-   Task completion and progress tracking.
-   AI progress review and plan adaptation.
-   Basic reminders and notification preferences.
-   Privacy, consent, and account controls.
-   Error handling, analytics, and basic crash reporting.

### P1 --- After core MVP validation

-   Career and skill development roadmaps.
-   Learning resources and project milestones.
-   Income goals and basic budgeting.
-   Focus sessions and journaling.
-   Wellness and habit tracking.
-   Weekly and monthly growth reports.

### P2 --- Later releases

-   Future life simulator.
-   Calendar and health-platform integrations.
-   Advanced proactive automation.
-   iOS and web clients.
-   Additional integrations and personalization.

## 11. Recommended technical architecture

  -----------------------------------------------------------------------
  Layer                   Recommended technology  Notes
  ----------------------- ----------------------- -----------------------
  Android client          Flutter / Dart          Shared codebase can
                                                  support iOS later

  Backend API             Python / FastAPI        Owns business rules and
                                                  authorization

  Database                PostgreSQL, optionally  Relational source of
                          Supabase                truth

  Authentication          Supabase Auth or        Secure identity and
                          equivalent              sessions

  AI                      OpenAI API              Calls must be made
                                                  server-side

  Background jobs         Redis + Celery or       Scheduled reviews and
                          managed queue           reminders

  Push notifications      Firebase Cloud          Android notifications
                          Messaging               

  Analytics               PostHog or equivalent   Product usage and
                                                  funnel measurement

  Hosting                 AWS or managed cloud    Select based on cost,
                                                  region, and operational
                                                  needs
  -----------------------------------------------------------------------

### Architecture principle

The AI model must not have unrestricted direct database access. The
backend should validate structured model outputs, enforce permissions,
and perform authorized writes through application services.

Suggested flow:

``` text
Flutter Android App
        |
        v
FastAPI Backend
        |
        +---- Authentication / Authorization
        |
        +---- Goal and Task Services
        |
        +---- AI Orchestration Service
        |          |
        |          +---- OpenAI API
        |          +---- Context Retrieval
        |          +---- Structured Output Validation
        |
        +---- PostgreSQL
        |
        +---- Background Jobs / Notifications
```

## 12. Suggested data model

Initial entities:

-   `users`
-   `life_profiles`
-   `user_preferences`
-   `goals`
-   `milestones`
-   `tasks`
-   `habits`
-   `habit_logs`
-   `skill_profiles`
-   `learning_plans`
-   `financial_records` (optional and permission-controlled)
-   `health_records` (optional and permission-controlled)
-   `coach_conversations`
-   `coach_messages`
-   `coach_memory`
-   `progress_snapshots`
-   `forecasts`
-   `notifications`
-   `consent_records`

All user-owned records must have clear ownership and authorization
checks. Define retention, export, and deletion behavior before
production.

## 13. AI output contracts

Avoid relying on free-form text alone for actions. The AI should return
validated structured objects for plans and tasks.

Illustrative task contract:

``` json
{
  "title": "Practice spreadsheet analysis",
  "description": "Complete one guided data-cleaning exercise.",
  "category": "skill_development",
  "estimated_minutes": 30,
  "priority": "high",
  "due_date": null,
  "success_criteria": "Finish the exercise and record one learning."
}
```

Backend validation should check:

-   Required fields and allowed enums.
-   User authorization and goal ownership.
-   Reasonable task duration and due dates.
-   Duplicate tasks and conflicting schedules.
-   Whether user confirmation is required.
-   Whether the proposed action is within the app's allowed
    capabilities.

## 14. Privacy, safety, and trust requirements

Upwise may handle sensitive information. Build privacy into the product
from the start.

-   Collect only information needed for a clear product purpose.
-   Make financial and health tracking optional.
-   Request explicit permissions for integrations.
-   Encrypt data in transit and at rest.
-   Use least-privilege access and server-side authorization.
-   Do not expose API keys in the mobile app.
-   Provide understandable privacy notices and consent controls.
-   Provide data export and account deletion workflows.
-   Make AI memory visible and correctable.
-   Avoid medical diagnosis or treatment claims.
-   Avoid guaranteed income, investment, career, or future predictions.
-   Ask for confirmation before external or consequential actions.

## 15. Design system

### Visual direction

-   Minimal, premium, modern.
-   Light theme as the initial default; dark theme can follow.
-   Deep purple as the primary brand color.
-   Soft violet accents.
-   White and light-grey surfaces.
-   Rounded cards and restrained shadows.
-   Clear hierarchy and generous spacing.
-   Accessible contrast and readable text.
-   Simple icons and short labels.

### Suggested design tokens

  Token            Initial direction
  ---------------- -----------------------------
  Primary          Deep purple
  Accent           Soft violet
  Background       White / very light grey
  Surface          White
  Text             Near-black
  Secondary text   Neutral grey
  Success          Accessible green
  Warning          Accessible amber
  Error            Accessible red
  Typography       Inter or Manrope
  Corner radius    12--20 px
  Navigation       Five-item bottom navigation

Treat exact colors and measurements as design-system values to be
finalized in the UI implementation.

## 16. Product success metrics

Measure outcomes, not just engagement.

-   Onboarding completion rate.
-   Percentage of users creating a first goal.
-   Time to first useful plan.
-   Daily and weekly active users.
-   Task completion rate.
-   Weekly goal review completion.
-   Percentage of AI plans accepted or edited.
-   30-day and 90-day retention.
-   User-reported progress toward goals.
-   Notification opt-out and complaint rates.

The primary outcome metric should be meaningful user-reported progress
toward goals, supported by task and milestone evidence.

## 17. Development roadmap

### Stage 0 --- Product and engineering foundation

-   Confirm product requirements and MVP scope.
-   Create Flutter and FastAPI repositories.
-   Establish environments, configuration, and secrets handling.
-   Define database schema and API conventions.
-   Create UI design tokens and reusable components.

### Stage 1 --- Core Android application

-   Authentication.
-   Onboarding.
-   Main navigation.
-   Home dashboard.
-   Goals and milestones.
-   Task management.

### Stage 2 --- AI Coach

-   Secure server-side OpenAI integration.
-   Conversation storage.
-   Structured user context.
-   Discovery and goal clarification.
-   Structured plan generation.
-   Output validation and safe task creation.

### Stage 3 --- Progress and proactive support

-   Task completion and progress history.
-   Weekly review.
-   Plan adaptation.
-   Notifications and quiet hours.

### Stage 4 --- Beta and validation

-   Test with representative users.
-   Check AI output quality and safety.
-   Test privacy and authorization.
-   Measure activation and retention.
-   Prioritize improvements from observed usage.

### Stage 5 --- Expansion

-   Career and skills.
-   Income and budgeting.
-   Focus and wellness.
-   Future simulator.
-   Integrations and additional platforms.

## 18. Acceptance criteria for the first MVP

The first MVP is ready for controlled beta when:

1.  A user can create an account and securely sign in.
2.  A user can complete or skip onboarding questions.
3.  A user can create, edit, and archive goals.
4.  The AI can summarize user-confirmed context and ask clarifying
    questions.
5.  The AI can propose a structured plan with milestones and tasks.
6.  The backend validates and stores approved tasks.
7.  A user can mark tasks complete and see updated progress.
8.  The AI can review progress and propose plan changes.
9.  Notifications respect user preferences and permissions.
10. Users can inspect and manage personal data and AI memory.
11. Unauthorized users cannot access another user's data.
12. The app clearly communicates that forecasts and recommendations are
    estimates, not guarantees.

## 19. Open decisions to resolve during implementation

These are not yet confirmed:

-   Final brand name and domain availability.
-   Exact Flutter state-management approach.
-   Supabase-managed backend versus separately hosted
    FastAPI/PostgreSQL.
-   Initial supported languages and localization.
-   Whether the first release includes email/password, Google sign-in,
    or both.
-   Exact subscription tiers and pricing.
-   Whether any calendar, wearable, or health integrations are in MVP.
-   AI model selection and budget limits.
-   Data hosting region and legal/compliance requirements.
-   Final UI color tokens and component specifications.

Do not silently treat these as settled decisions.

## 20. Continuation brief for the next development session

### Current status

Product concept, high-level blueprint, navigation structure, MVP
priorities, technical recommendations, AI behavior principles, and a
conceptual interactive dashboard have been defined.

A visual UI concept has also been generated. It is a design reference,
not production-ready Flutter code.

**No production Flutter application, backend, database, authentication,
or live AI integration has been implemented yet.**

### Immediate next tasks

Work in this order:

1.  Create the Flutter Android project structure.
2.  Implement theme tokens, typography, spacing, buttons, cards, and
    navigation.
3.  Build the onboarding flow.
4.  Build the home dashboard.
5.  Build goals, milestones, and tasks.
6.  Build the AI Coach chat UI with a mock service.
7.  Create the FastAPI backend and PostgreSQL schema.
8.  Implement authentication and user-owned data access.
9.  Add secure OpenAI integration and structured output validation.
10. Connect the app to the backend and test the end-to-end MVP.

### Suggested initial repository structure

``` text
upwise/
├── README.md
├── docs/
│   ├── PRD.md
│   ├── DEVELOPMENT_HANDOFF.md
│   └── API_CONTRACTS.md
├── mobile/
│   └── Flutter application
├── backend/
│   └── FastAPI application
├── infrastructure/
│   └── deployment and environment configuration
└── design/
    └── design tokens and UI references
```

### Suggested Flutter feature structure

``` text
mobile/lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
├── core/
│   ├── networking/
│   ├── storage/
│   ├── widgets/
│   └── utils/
└── features/
    ├── onboarding/
    ├── home/
    ├── goals/
    ├── tasks/
    ├── ai_coach/
    ├── growth/
    └── profile/
```

### Suggested backend structure

``` text
backend/app/
├── main.py
├── api/
├── core/
├── models/
├── schemas/
├── services/
│   ├── ai/
│   ├── goals/
│   ├── tasks/
│   └── progress/
├── repositories/
└── workers/
```

### Instructions for a future AI developer

When this handoff document is supplied in a future conversation:

-   Read this document before proposing changes.
-   Preserve confirmed product decisions.
-   Identify what has actually been implemented versus what is only
    planned.
-   Inspect the current repository and existing files before changing
    code.
-   Continue from the latest verified implementation state.
-   Do not recreate completed work unnecessarily.
-   Prefer small, testable implementation steps.
-   Update this handoff document whenever architecture, scope, or
    implementation status materially changes.
-   Record completed tasks, pending tasks, known issues, and the next
    recommended action.

### Current development checkpoint

**Checkpoint:** Product definition complete; implementation not started.

**Next recommended action:** Initialize the Flutter Android project and
implement the visual foundation plus onboarding and five-tab navigation.
Use mock data initially; connect the backend and live AI after the
primary UI flow is stable.

------------------------------------------------------------------------

## 21. Change log

  -----------------------------------------------------------------------
  Version                             Change
  ----------------------------------- -----------------------------------
  1.0                                 Captured initial Upwise vision,
                                      confirmed decisions, product
                                      requirements, MVP scope,
                                      architecture, safety principles,
                                      roadmap, and continuation
                                      instructions.

  -----------------------------------------------------------------------

**End of document.**


## 22. Implementation checkpoint update — Flutter starter scaffold

A first Flutter source scaffold has now been generated in `upwise_flutter_starter/`.

### Included in the scaffold
- Material 3 theme and app shell.
- Five-tab navigation: Home, Goals, AI Coach, Growth, Profile.
- Demo task completion and progress calculation.
- Local goal creation.
- Mock AI conversation interface.
- Growth module placeholders and profile/settings placeholders.

### Not implemented
- Authentication, backend, database, live AI, persistent storage, push notifications, or external integrations.

### Validation status
The environment used to generate this scaffold did not have Flutter or Dart installed. The source has therefore **not been compiled, analyzed, or tested on an Android device**. Treat it as an initial source scaffold pending local validation.

### Next steps
1. Install Flutter stable and Android Studio.
2. Run `flutter doctor`, `flutter pub get`, `flutter analyze`, and `flutter run`.
3. Fix any compile or SDK compatibility issues.
4. Refactor the initial single-file prototype into feature folders and reusable widgets.
5. Implement FastAPI, PostgreSQL, authentication, and secure AI orchestration.
6. Replace mock coach responses with validated server-generated plans.

**Updated checkpoint:** Flutter source scaffold created; local toolchain validation pending.

## 23. Backend architecture decision and implementation checkpoint

### Confirmed decision
Backend architecture selected: **Supabase + FastAPI**.

### Generated backend scaffold
The `backend/` directory now contains:
- FastAPI app with `/health`.
- Supabase Auth access-token validation through the Supabase Auth user endpoint.
- Async SQLAlchemy PostgreSQL models for goals and tasks.
- User-scoped goal/task list, create, progress, and completion endpoints.
- AI Coach endpoint using the OpenAI Responses API.
- `.env.example` and backend setup documentation.

### API routes
- `GET /health`
- `GET /api/v1/goals`
- `POST /api/v1/goals`
- `PATCH /api/v1/goals/{goal_id}/progress`
- `GET /api/v1/tasks`
- `POST /api/v1/tasks`
- `PATCH /api/v1/tasks/{task_id}/completion`
- `POST /api/v1/coach/chat`

### Security and implementation notes
- OpenAI API key is server-side only.
- Requests other than `/health` require a Supabase access token.
- Goal and task queries are scoped to the authenticated user.
- AI chat does not silently create tasks.
- Local `create_all` is a development convenience; production requires migrations and a security review.
- Add and test PostgreSQL RLS policies, rate limits, CORS allowlists, monitoring, and sensitive-data redaction before production.

### Not yet complete
No Supabase project credentials were supplied. The backend has not been run against a live database or tested. Chat persistence, AI memory, approved AI task creation, Flutter API integration, migrations, and automated tests remain pending.

## 24. Flutter modular feature refactoring & onboarding flow checkpoint

### Completed tasks
1. **Modular Architecture Restructuring:**
   - Decomposed single-file `main.dart` into feature and domain modules following Section 20 guidelines:
     - `app/`: Top-level app routing, theme tokens (`app_colors.dart`, `app_typography.dart`, `app_theme.dart`).
     - `core/widgets/`: Reusable UI elements (`UpwiseCard`, `ProgressBar`, `SectionHeader`).
     - `features/onboarding/`: Conversational discovery onboarding flow, models, and summary confirmation screen.
     - `features/home/`: Daily overview dashboard, priority checklist, progress tracker, and AI daily insight.
     - `features/goals/`: Goal models, list view, progress adjuster bottom sheet, and goal creation dialog.
     - `features/tasks/`: Domain task model with categories, durations, and priorities matching backend schemas.
     - `features/ai_coach/`: Smart conversational coach service with adaptive responses, quick prompt suggestions, and 1-tap accept proposed tasks.
     - `features/growth/`: Connected 6-dimension personal development grid with diagnostic modal sheets.
     - `features/profile/`: User profile context, AI memory management dialog, notification preferences, and privacy controls.
     - `features/shell/`: 5-tab persistent navigation shell with interconnected task and goal state.

2. **Onboarding Requirements (PRD Section 7):**
   - Implemented progressive multi-step conversational discovery asking one question at a time.
   - Added user choice pills, optional custom input, and skip functionality.
   - Built discovery summary confirmation screen allowing user to review and confirm AI understanding before entering the dashboard.

### Next engineering actions
1. Connect Flutter app with Supabase Auth (Sign-up, Sign-in, session persistence).
2. Wire HTTP/REST client in `core/networking/` to consume FastAPI endpoints (`/api/v1/goals`, `/api/v1/tasks`, `/api/v1/coach/chat`).
3. Deploy or provision Supabase PostgreSQL instance and configure `.env`.

**Updated checkpoint:** Flutter modular architecture & conversational onboarding implemented; backend API scaffolding ready; live client-server auth/data integration pending.

## 25. Backend environment provisioning & local API verification checkpoint

### Completed tasks
1. **Python Environment Setup**: Created virtual environment at `backend/.venv` and installed all dependencies (`fastapi`, `uvicorn`, `sqlalchemy`, `asyncpg`, `aiosqlite`, `httpx`, `pydantic-settings`, `openai`, `pytest`, `pytest-asyncio`).
2. **Environment Configuration**: Configured `backend/.env` with Supabase project parameters, local SQLite async database fallback, and server-side OpenAI settings.
3. **Cross-Database Compatibility**: Updated SQLAlchemy models in `backend/app/models.py` and routes in `goals.py` / `tasks.py` to use universal `Uuid` types.
4. **Auth & Dev Mode**: Enhanced `backend/app/auth.py` to support both live Supabase `/auth/v1/user` token verification and local development testing (`dev-test-token`).
5. **Automated Verification**: Implemented and executed test suite in `backend/tests/test_api.py` with 100% pass rate:
   - `GET /health` -> 200 OK
   - `GET /api/v1/goals` -> 401 Unauthorized when unauthenticated
   - `POST /api/v1/goals` & `PATCH /api/v1/goals/{id}/progress` -> CRUD operations verified
   - `POST /api/v1/tasks` & `PATCH /api/v1/tasks/{id}/completion` -> Priority tasks linked to goals verified
   - `POST /api/v1/coach/chat` -> AI coach request and fallback response verified

**Updated checkpoint:** Backend environment provisioned, `.env` configured, and all FastAPI endpoints verified locally. Flutter client authentication and API integration pending.

## 26. Full database & AI feature integration checkpoint

### Completed tasks
1. **Backend Database & AI Persistence (`backend/app/`)**:
   - Added `UserProfile` and `ChatMessage` SQLAlchemy models in `models.py` for onboarding memory and coach conversation persistence.
   - Added `/api/v1/profile` (`GET`, `PUT`, `DELETE`) in `routes/profile.py` to persist onboarding context and allow clearing AI memory.
   - Added `DELETE /api/v1/goals/{goal_id}` and `DELETE /api/v1/tasks/{task_id}` for complete goal and task CRUD.
   - Upgraded `routes/coach.py` with `GET /api/v1/coach/history`, `DELETE /api/v1/coach/history`, `GET /api/v1/coach/insight`, and context-aware `POST /api/v1/coach/chat` feeding the user's real DB profile, goals, and tasks into OpenAI Responses API (via `httpx`) or the adaptive local coach engine, returning structured `proposed_task` suggestions.
2. **Flutter Client Database & AI Wiring (`lib/`)**:
   - Extended `UpwiseApiClient` in `lib/core/network/upwise_api_client.dart` with profile, goal/task deletion, coach history, chat, and daily insight endpoints.
   - Updated `lib/app/app.dart` to load and persist onboarding state from `/api/v1/profile` on sign-in and completion.
   - Connected `CoachScreen` to `/api/v1/coach/history` and `/api/v1/coach/chat` with persistent messages, server mode badge (`Live AI` / `Smart Coach`), history clearing, and 1-tap task acceptance into the database.
   - Connected `HomeScreen` to live AI daily insights (`/api/v1/coach/insight`) and task removal; updated `GoalsScreen` with goal deletion; converted `GrowthScreen` to compute live dimension scores and diagnostics from synced DB goals and tasks; wired `ProfileScreen` AI memory clearing to backend endpoints.
   - Fixed `UpwiseCard` to use `Material` so `ListTile` ink splashes render without Flutter framework assertions.
3. **Verification**:
   - `pytest` (`backend/tests/test_api.py`): 6 passed in 0.89s.
   - `flutter analyze`: 0 issues found.
   - `flutter test`: 5 passed (API client tests + signed-out & signed-in `AppShell` widget tests).

**Updated checkpoint:** All core Flutter app features (Onboarding/Profile, Home, Goals, Tasks, AI Coach, Growth, and Memory Controls) are wired to the FastAPI database and AI backend and verified by automated tests.
