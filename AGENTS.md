# Nestify eServices — Flutter Mobile App Development Guide

> This document provides a complete overview of the **Nestify** web application (built with Next.js 16 + Tailwind CSS 4) to guide the development of an equivalent **Flutter mobile app using FVM (Flutter Version Management)**.

---

## 1. Project Overview

**Nestify** is a home services marketplace platform that connects homeowners (clients) with trusted service providers for household needs such as cleaning, plumbing, electrical work, and garden maintenance.

### Core Concept
- **Clients** browse service gigs, view provider profiles, book services, and leave reviews.
- **Providers** register, create service gigs, manage bookings, and build their professional profile.
- **Admins** manage users, providers, bookings, and service categories from a dashboard.

### Tech Stack (Web)
| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 16 (App Router) + React 19 + TypeScript |
| Styling | Tailwind CSS 4 |
| Auth | Keycloak (OpenID Connect / OAuth 2.0 code flow) |
| Backend API | Spring Boot REST API (http://localhost:8080) |
| Validation | Zod |
| HTTP Client | Axios + Fetch API |
| Icons | Lucide React + React Icons |
| Animations | Lottie (@lottiefiles/dotlottie-react) |
| Alerts/Dialogs | SweetAlert2 |
| JWT | jwt-decode + jsonwebtoken |
| Cookies | js-cookie |

### Mobile Tech Stack (Target)
| Layer | Technology |
|-------|-----------|
| Framework | Flutter (managed via **FVM**) |
| State Management | TBD (Riverpod / BLoC / Provider recommended) |
| HTTP Client | Dio or http package |
| Auth | Keycloak via AppAuth or flutter_appauth |
| Local Storage | flutter_secure_storage (for tokens) |
| Routing | go_router |

---

## 2. Color Palette & Design System

### Primary Colors — Deep Blue & Sapphire

| Token | Hex Code | Usage |
|-------|----------|-------|
| `primary-900` | `#0A192F` | Footer background, darkest primary |
| `primary-800` | `#112240` | Dark accents |
| `primary-700` | `#233554` | Footer divider, secondary dark |
| `primary-600` | `#495670` | Muted dark text |

### Accent Colors — Blue

| Token | Hex Code | Usage |
|-------|----------|-------|
| `accent-600` | `#1D4ED8` | **Primary buttons**, CTA, links, borders, focus states |
| `accent-500` | `#2563EB` | Button hover state, active toggle |
| `accent-400` | `#3B82F6` | Social link hover, lighter accents |
| `accent-100` | `#DBEAFE` | Light blue background on hover |

### Surface Colors — Snow & Ice (Aqua-tinged)

| Token | Hex Code | Usage |
|-------|----------|-------|
| `surface-snow` | `#FFFFFF` | Card backgrounds, navbar, modals |
| `surface-ice-100` | `#F4F7F7` | Input backgrounds, inactive toggle, subtle bg |
| `surface-ice-200` | `#EAF2F1` | Navbar border, section gradients, card borders |
| `surface-aqua-pale` | `#D1E3E2` | Gradient backgrounds |
| `surface-aqua-muted` | `#B9D5D3` | Gradient endpoints |

### Neutral Colors

| Token | Hex Code | Usage |
|-------|----------|-------|
| `neutral-800` | `#1E293B` | Primary body text, headings |
| `neutral-600` | `#475569` | Nav links, secondary text |
| `neutral-400` | `#94A3B8` | Placeholder text, footer text, subtle labels |
| `neutral-200` | `#E2E8F0` | Input borders, dividers |

### Semantic Colors

| Token | Hex Code | Usage |
|-------|----------|-------|
| `success` | `#059669` | Verified badges, success states |
| `success-bg` | `#D1FAE5` | Success background |
| `warning` | `#D97706` | Warning states |
| `warning-bg` | `#FEF3C7` | Warning background |
| `error` | `#DC2626` | Error states, validation errors |
| `error-bg` | `#FEE2E2` | Error background |
| `rating` | `#F59E0B` | Star ratings |

### Background & Foreground

| Token | Hex Code | Usage |
|-------|----------|-------|
| `background` | `#FAFBFC` | App-wide background |
| `foreground` | `#1E293B` | Default text color |

### Typography
- **Primary Font**: `Inter` (sans-serif) — used for all body text and UI
- **Display Font**: `Playfair Display` (serif) — used for hero headings
- **Flutter equivalents**: Use Google Fonts package with `Inter` and `Playfair Display`

### Flutter Color Implementation

```dart
// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary - Deep Blue & Sapphire
  static const Color primary900 = Color(0xFF0A192F);
  static const Color primary800 = Color(0xFF112240);
  static const Color primary700 = Color(0xFF233554);
  static const Color primary600 = Color(0xFF495670);

  // Accent - Blue
  static const Color accent600 = Color(0xFF1D4ED8);
  static const Color accent500 = Color(0xFF2563EB);
  static const Color accent400 = Color(0xFF3B82F6);
  static const Color accent100 = Color(0xFFDBEAFE);

  // Surface - Snow & Ice
  static const Color surfaceSnow = Color(0xFFFFFFFF);
  static const Color surfaceIce100 = Color(0xFFF4F7F7);
  static const Color surfaceIce200 = Color(0xFFEAF2F1);
  static const Color surfaceAquaPale = Color(0xFFD1E3E2);
  static const Color surfaceAquaMuted = Color(0xFFB9D5D3);

  // Neutral
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral200 = Color(0xFFE2E8F0);

  // Semantic
  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color rating = Color(0xFFF59E0B);

  // Background & Foreground
  static const Color background = Color(0xFFFAFBFC);
  static const Color foreground = Color(0xFF1E293B);
}
```

---

## 3. User Roles & Permissions

The app has **3 user roles** managed via Keycloak realm roles:

| Role | Access |
|------|--------|
| `user` (Client) | Home, Services, Providers, About, Booking, User Profile Dashboard |
| `provider` | Home, Services, Providers, About, Provider Dashboard (gigs, bookings, personal info) |
| `admin` | Home, Services, Providers, About, Site Admin Dashboard (manage users, providers, bookings, categories) |
| `notLogin` (Guest) | Home, Services, Providers, About, Login, Register |

### Protected Routes
- `/users/profile/*` — requires `user` or `admin` role
- `/site-admin/*` — requires `admin` role
- `/provider/profile/*` — requires `provider` or `admin` role

---

## 4. Screens / Pages Mapping

### 4.1 Public Screens (Guest + All Roles)

#### 🏠 Home Screen (`/`)
- **Components**: Navbar → Hero Section (with search bar) → Service Categories List → Popular Providers List → Footer
- **Features**:
  - Full-screen hero with gradient background (`#FAFBFC → #EAF2F1`)
  - Search bar with category dropdown filter
  - Service category cards grid
  - Popular providers carousel/list
  - Popular search tags

#### 📋 Service Gigs List (`/service-gigs`)
- Paginated list of all active service gigs
- Each gig card shows: title, description, price, price type, category, provider info, booking count
- Search and category filter functionality

#### 📝 Service Gig Detail (`/service-gigs/details/[id]`)
- Full service details: title, description, pricing, service location, provider info
- Booking button (opens booking modal)
- Review section with average rating, review list, and review submission form
- Gradient background: `#d9edee → #e6f3f3 → #ebf7f7`

#### 👥 Providers List (`/providers`)
- Paginated grid of all service providers
- Each card shows: name, expertise, verification badge, categories, review count, average rating

#### 👤 Provider Detail (`/providers/details/[id]`)
- Full provider profile: name, expertise, verification status, contact
- List of their service gigs
- Reviews and ratings

#### ℹ️ About Page (`/about`)
- **Sections**: Hero → Mission → Journey Timeline → How We Work (4 steps) → Why Choose Us
- Gradient sections between content blocks

#### 🔐 Login (`/login`)
- Redirects to Keycloak OpenID Connect authorization endpoint
- OAuth 2.0 Authorization Code flow

#### 🔐 Login Callback (`/login-callback`)
- Handles OAuth callback, exchanges code for tokens
- Shows loading spinner during authentication
- Redirects to original page or home on success

#### 📝 Register (`/register`)
- Toggle between **Client** and **Provider** registration forms
- **Client form fields**: firstName, lastName, username, email, password, confirmPassword
- **Provider form fields**: firstName, lastName, username, email, password, confirmPassword, contactNo
- Lottie animation on client registration
- Zod schema validation
- SweetAlert2 for success/error feedback

#### 🚫 Forbidden (`/forbidden`)
- 403 error page with image and "Go to Home" link

---

### 4.2 Client Dashboard Screens (Role: `user`)

#### User Profile Layout (`/users/profile/[id]`)
- **Profile Navbar** with tabs: Dashboard, Security, Bookings, Preferences
- Mobile hamburger menu for navigation
- Logout button
- Gradient background: `surface-snow → surface-ice-100 → surface-ice-200`

#### 📊 Dashboard Tab (`/users/profile/[id]` — default)
- Account info summary
- Personal information form (editable: firstName, lastName, username, contact, address)
- Profile photo with edit capability

#### 🔒 Security Tab (`/users/profile/[id]/security`)
- Password update form (current password, new password, confirm)
- Two-factor authentication settings

#### 📅 Bookings Tab (`/users/profile/[id]/booking`)
- List of user's bookings with booking cards
- Each booking card shows: service gig info, provider info, status, date/time
- Actions: Cancel booking, Reschedule, Mark complete

#### ⚙️ Preferences Tab (`/users/profile/[id]/preferences`)
- Notification preferences (toggles for email, SMS, push notifications)

---

### 4.3 Provider Dashboard Screens (Role: `provider`)

#### Provider Dashboard (`/providers/dashboard`)
- **Gig Management Form**: Create new service gigs with fields:
  - title, shortDescription, fullDescription, basePrice, priceType (Hourly/Per Job/Per Day), durationByHours, currency (LKR/USD), category
- **My Gigs** list: View and manage existing gigs
- **My Bookings**: View incoming booking requests
- **Personal Information**: Editable profile with verification badge

#### Provider Personal Info (`/providers/dashboard/providerPersonalInfomation`)
- Edit mode toggle
- Profile photo with camera icon on edit
- Fields: firstName, lastName, username, contact, address
- Professional Details: expertise (category dropdown), years of experience, description
- Verified badge display

---

### 4.4 Admin Dashboard Screens (Role: `admin`)

#### Site Admin Dashboard (`/site-admin`)
- **Admin Navbar** (separate from main navbar)
- **Overview Section**: Platform statistics/metrics
- **Category Management**: Add, edit, delete service categories

#### Admin - Users (`/site-admin/users`)
- User management panel (list, details)

#### Admin - Providers (`/site-admin/providers`)
- Provider management panel (verify, review)

#### Admin - Bookings (`/site-admin/booking`)
- Booking management overview

---

### 4.5 Shared Modal / Overlay Screens

#### 📅 Booking Form (Modal)
- Triggered from Service Gig Detail page
- Fields: Full name, Email, Contact, Address, Starting Date, Starting Time, Additional Information
- Overlay with backdrop click to close
- Submit sends booking to API

#### ⭐ Review Form
- Rating (1-5 stars)
- Comment text area
- Submit creates review for a specific gig and provider

#### 🔄 Reschedule Form
- Update booking date and time

---

## 5. Data Models (DTOs)

### ServiceGigDto
```
id: String
title: String
shortDescription: String
fullDescription: String
basePrice: double
priceType: String  // "Hourly" | "Per Job" | "Per Day"
durationByHours: double
currency: String   // "LKR" | "USD"
isActive: bool
createdAt: DateTime
updatedAt: DateTime
```

### ServiceGigResponseDto (with relations)
```
id: String
title: String
serviceLocation: String
description: String
basePrice: double
priceType: String
totalBookingCount: int
currency: String
isActive: bool
createdAt: DateTime
updatedAt: DateTime
provider: ProviderDto
category: CategoryResponseDto
```

### ProviderDto
```
id: String
userName: String
firstName: String
lastName: String
email: String
contactNo: String
expertise: String
isVerified: bool
address: String
experience: String
jobCount: int
shortDescription: String
```

### ProviderWithCategory
```
providerDto: ProviderDto
categoriesSet: List<CategoryResponseDto>
reviews: int
avgRate: double
```

### UserResponseDto
```
id: String
address: String
contact: String
email: String
paymentMethod: String
firstName: String
lastName: String
username: String
createdAt: String
```

### BookingRequestDto
```
name: String
email: String
contactNo: String
address: String
additionalInformation: String
status: BookingStatus  // "pending" | "completed" | "cancelled"
startingTime: String
startingDate: String
providerId: String
gigId: String
```

### BookingResponseDto
```
id: String
name: String
email: String
contactNo: String
address: String
additionalInformation: String
status: String
startingTime: String
startingDate: String
providerDto: ProviderDto
serviceGigResponseDto: ServiceGigResponseDto
```

### ReviewDto
```
id: String
rating: int
comment: String
providerResponse: String
reviewsClient: UserDto
createdAt: DateTime
```

### ReviewRequestDto
```
rating: int
comment: String
serviceGigId: String? (nullable)
providerId: String
clientId: String? (nullable)
```

### CategoryResponseDto
```
id: String
name: String
```

### LoginDto
```
username: String
password: String
token: String
```

---

## 6. Backend API Endpoints

The Next.js app acts as a **BFF (Backend For Frontend)** proxy to the Spring Boot API at `http://localhost:8080`. The mobile app should call the **Spring Boot API directly** (or through an API gateway).

### API Base URL
```
http://<your-server>:8080/api/v1
```

### Authentication
- **Keycloak** realm: `market-realm`
- **Client ID**: `spring-boot-api`
- OAuth 2.0 Authorization Code flow
- JWT tokens (access + refresh) stored in secure storage

### Endpoint Groups

#### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/callback` | Exchange auth code for tokens |
| POST | `/auth/logout` | Logout user |
| POST | `/auth/reset-password` | Reset password |
| GET | `/auth/token-functions` | Token utility functions |

#### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/users/register` | Register new client |
| GET | `/users/by-id` | Get user by ID |
| GET | `/users/data` | Get current user data |
| PUT | `/users/update-user-data` | Update user profile |
| GET | `/users/booking-count-with-id` | Get booking count for user |

#### Providers
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/provider/persist` | Register new provider |
| GET | `/provider/all` | Get all providers |
| GET | `/provider/with-id/{id}` | Get provider by ID |
| GET | `/provider/popular-providers` | Get popular providers |
| GET | `/provider/count` | Get total provider count |

#### Service Gigs
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/gig` | Create new gig |
| GET | `/gig/active-gigs` | Get all active gigs |
| GET | `/gig/all-gigs` | Get all gigs |
| GET | `/gig/by-id/{id}` | Get gig by ID |
| GET | `/gig/average-rating` | Get average rating for gig |
| GET | `/gig/count-of-active-gigs` | Get active gig count |

#### Bookings
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/booking/persist` | Create new booking |
| GET | `/booking/by-client-id` | Get bookings by client |
| PUT | `/booking/cancel` | Cancel a booking |
| PUT | `/booking/reschedule` | Reschedule a booking |
| PUT | `/booking/mark-complete` | Mark booking as complete |

#### Reviews
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/review/by-gig-id?id={id}` | Get reviews by gig ID |
| POST | `/review/add-review` | Submit a new review |

#### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/category/all` | Get all categories |
| POST | `/category/add` | Add new category (admin) |

---

## 7. Authentication Flow (Keycloak + Flutter)

### Recommended Flutter Implementation
1. Use `flutter_appauth` package for OAuth 2.0 code flow
2. Configure Keycloak redirect URI for mobile (e.g., `com.nestify.app://callback`)
3. Store tokens securely using `flutter_secure_storage`
4. Implement token refresh logic (access token expires, use refresh token)
5. Decode JWT to extract roles from `realm_access.roles`

### Token Structure (JWT decoded)
```json
{
  "realm_access": { "roles": ["user"] },
  "exp": 1234567890,
  "sub": "user-uuid",
  "name": "John Doe",
  "email": "john@example.com"
}
```

---

## 8. Navigation Structure (Flutter)

### Bottom Navigation Bar (for authenticated users)
```
┌──────┬──────────┬──────────┬─────────┐
│ Home │ Services │ Providers│ Profile │
└──────┴──────────┴──────────┴─────────┘
```

### Drawer / App Bar (Guest)
```
- Home
- Services
- Providers
- About
- Login / Register
```

### Provider Dashboard (Separate navigation)
```
- Personal Info
- My Gigs (Create/Manage)
- My Bookings
```

### Admin Dashboard (Separate navigation — possibly web-only or limited mobile)
```
- Overview
- Users Management
- Providers Management
- Bookings Management
- Category Management
```

---

## 9. Key UI Patterns & Components to Build

### Reusable Widgets
- **SearchBar** — Text input + category dropdown + search button
- **ServiceGigCard** — Card with title, description, price, provider, category badge
- **ProviderCard** — Card with name, expertise, rating, verification badge, categories
- **BookingCard** — Card with service info, date/time, status badge, action buttons
- **ReviewCard** — Card with star rating, comment, client name, date
- **ReviewForm** — Star selector + text field + submit
- **BookingForm** — Bottom sheet or full-page form with date/time pickers
- **PaginationControls** — Previous/Next page buttons
- **ToggleButton** — Client/Provider toggle on registration
- **ImageSlider** — Carousel for images
- **LoadingPage** — Full-screen spinner
- **DynamicIcon** — Icon resolver component

### Design Patterns
- **Gradient backgrounds**: Linear gradients using the aqua/ice surface colors
- **Card elevation**: White cards with subtle shadows (`rgba(10,25,47,0.12)`)
- **Border styling**: `surface-ice-200 (#EAF2F1)` borders
- **Button styles**: Rounded corners, accent-600 primary, with active scale animation
- **Input styles**: `surface-ice-100` background, `neutral-200` border, `accent-600` focus border
- **Animations**: Use Lottie for onboarding/registration, scale transitions on buttons

---

## 10. Feature Checklist for Mobile App

### Phase 1 — Core (MVP)
- [ ] Keycloak OAuth login/register flow
- [ ] Home screen with hero, services, providers
- [ ] Browse service gigs (list + detail)
- [ ] Browse providers (list + detail)
- [ ] Booking creation from gig detail
- [ ] User profile dashboard
- [ ] View & manage bookings (cancel, reschedule)

### Phase 2 — Enhanced
- [ ] Reviews (view + submit)
- [ ] Search with category filter
- [ ] Provider dashboard (create/manage gigs)
- [ ] Provider personal info editing
- [ ] Password reset / security settings
- [ ] Notification preferences
- [ ] About page

### Phase 3 — Admin & Polish
- [ ] Admin dashboard (mobile-optimized or web-only decision)
- [ ] Push notifications
- [ ] Image upload for profile photos
- [ ] Offline caching
- [ ] Dark mode (design tokens already support it)

---

## 11. Folder Structure Suggestion (Flutter)

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── constants/
│   │   └── api_constants.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── api_interceptor.dart
│   └── utils/
│       └── validators.dart
├── data/
│   ├── models/
│   │   ├── service_gig_dto.dart
│   │   ├── provider_dto.dart
│   │   ├── user_dto.dart
│   │   ├── booking_dto.dart
│   │   ├── review_dto.dart
│   │   └── category_dto.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── gig_repository.dart
│   │   ├── provider_repository.dart
│   │   ├── booking_repository.dart
│   │   ├── review_repository.dart
│   │   └── category_repository.dart
│   └── datasources/
│       ├── remote/
│       └── local/
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── login_callback_screen.dart
│   │   └── widgets/
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── hero_section.dart
│   │       ├── search_bar.dart
│   │       └── popular_providers_list.dart
│   ├── service_gigs/
│   │   ├── screens/
│   │   │   ├── gigs_list_screen.dart
│   │   │   └── gig_detail_screen.dart
│   │   └── widgets/
│   │       └── service_gig_card.dart
│   ├── providers/
│   │   ├── screens/
│   │   │   ├── providers_list_screen.dart
│   │   │   └── provider_detail_screen.dart
│   │   └── widgets/
│   │       └── provider_card.dart
│   ├── booking/
│   │   ├── screens/
│   │   │   └── booking_form_screen.dart
│   │   └── widgets/
│   │       ├── booking_card.dart
│   │       └── reschedule_form.dart
│   ├── reviews/
│   │   └── widgets/
│   │       ├── review_card.dart
│   │       ├── review_form.dart
│   │       └── review_section.dart
│   ├── user_profile/
│   │   ├── screens/
│   │   │   ├── profile_dashboard_screen.dart
│   │   │   ├── security_screen.dart
│   │   │   ├── bookings_screen.dart
│   │   │   └── preferences_screen.dart
│   │   └── widgets/
│   │       ├── personal_info_form.dart
│   │       └── account_info.dart
│   ├── provider_dashboard/
│   │   ├── screens/
│   │   │   ├── provider_dashboard_screen.dart
│   │   │   ├── gig_form_screen.dart
│   │   │   └── my_gigs_screen.dart
│   │   └── widgets/
│   │       └── provider_personal_info.dart
│   ├── admin/ (optional for mobile)
│   │   └── screens/
│   │       └── admin_dashboard_screen.dart
│   └── about/
│       ├── screens/
│       │   └── about_screen.dart
│       └── widgets/
│           ├── mission_section.dart
│           ├── journey_section.dart
│           ├── how_we_work.dart
│           └── choose_us.dart
├── shared/
│   └── widgets/
│       ├── app_navbar.dart
│       ├── app_footer.dart
│       ├── loading_widget.dart
│       ├── pagination_controls.dart
│       ├── image_slider.dart
│       └── toggle_button.dart
├── routes/
│   └── app_router.dart
└── main.dart
```

---

#  Flutter / FVM — Mobile Development Rules & Conventions

> These are binding rules for building the Nestify mobile app. Follow every rule without exception.

---

## Rule 1: Always Use FVM

- **NEVER** call `flutter` directly. Always use `fvm flutter` for every command.
- Before starting work, verify FVM is active:
  ```bash
  fvm use 3.44.9          # pin a version if not already pinned
  fvm flutter doctor       # verify environment
  fvm flutter pub get      # resolve dependencies
  ```
- Commit the `.fvmrc` file to the repo. Do NOT commit the `.fvm/` symlink directory.
- Add `.fvm/flutter_sdk` to `.gitignore`.

---

## Rule 2: Dart Coding Conventions

### Naming
| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case.dart` | `service_gig_card.dart` |
| Classes | `PascalCase` | `ServiceGigCard` |
| Variables / Functions | `camelCase` | `fetchActiveGigs()` |
| Constants | `camelCase` (Dart convention) | `static const primaryColor = ...` |
| Private members | prefix with `_` | `_isLoading` |
| Enums | `PascalCase` values | `BookingStatus.pending` |

### Imports
- Use **relative imports** within the same package (`import '../widgets/card.dart'`).
- Use **package imports** across packages (`import 'package:nestify/core/theme/app_colors.dart'`).
- Order imports: dart → package → relative. Separate groups with blank lines.

### Code Style
- Always use `const` constructors where possible.
- Prefer `final` for variables that never change.
- No `dynamic` types — always specify types explicitly.
- Maximum line length: **80 characters** (Dart standard).
- Use trailing commas on widget arguments for clean formatting.
- Run `fvm flutter analyze` before every commit — zero warnings allowed.

---

## Rule 3: Project Architecture

Use a **feature-first** architecture with clean separation:

```
lib/
├── core/          # Shared foundation: theme, network, utils, constants
├── data/          # Models (DTOs), repositories, data sources
├── features/      # One directory per feature (auth, home, booking, etc.)
│   └── <feature>/
│       ├── screens/   # Full-page widgets (1 per route)
│       └── widgets/   # Reusable sub-widgets scoped to this feature
├── shared/        # Cross-feature reusable widgets
├── routes/        # go_router configuration
└── main.dart
```

### Rules
- **Screens are thin**: They compose widgets, connect to state, and handle navigation. No business logic.
- **Widgets are dumb**: They receive data via constructor params. No direct API calls or repository access inside widgets.
- **Repositories** handle all data fetching, caching, and error mapping.
- **Models** (DTOs) are plain Dart classes with `fromJson` / `toJson` factory constructors.
- Never put UI code in `core/` or `data/`.
- Never put network/data code in `features/` screens or widgets.

---

## Rule 4: State Management

Use **Riverpod** (recommended) or **BLoC**. Whichever is chosen, apply these rules:

- Global state (auth, user session, categories) lives in `core/` providers/cubits.
- Feature-specific state lives inside `features/<name>/`.
- Never use `setState` for anything beyond trivial local UI state (like toggling a boolean).
- Always expose loading, error, and data states — never leave the UI in an undefined state.
- Use `AsyncValue` (Riverpod) or distinct states (BLoC) for async operations.

---

## Rule 5: Theme & Styling

### MANDATORY: Use the AppColors & AppTextStyles classes
- **NEVER** hard-code hex colors in widgets. Always reference `AppColors.accent600`, `AppColors.neutral800`, etc.
- **NEVER** hard-code font sizes or weights. Use `AppTextStyles` (e.g., `AppTextStyles.heading1`, `AppTextStyles.bodyMedium`).
- Define the full `ThemeData` in `app_theme.dart` using these tokens.
- Use `Theme.of(context)` where possible to pick up theme values.

### Gradients
- Replicate the web app's gradient patterns:
  - Hero: `LinearGradient(colors: [AppColors.background, AppColors.surfaceIce200])`
  - Service detail: `LinearGradient(colors: [Color(0xFFd9edee), Color(0xFFe6f3f3), Color(0xFFebf7f7)])`
  - Profile: `LinearGradient(colors: [AppColors.surfaceSnow, AppColors.surfaceIce100, AppColors.surfaceIce200])`

### Card Styling Pattern
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.surfaceSnow,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.surfaceIce200),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary900.withOpacity(0.12),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
    ],
  ),
)
```

### Button Styling Pattern
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent600,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
)
```

### Input Styling Pattern
```dart
InputDecoration(
  filled: true,
  fillColor: AppColors.surfaceIce100,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.neutral200),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.accent600, width: 2),
  ),
  hintStyle: TextStyle(color: AppColors.neutral400),
)
```

---

## Rule 6: Networking & API

### HTTP Client
- Use **Dio** with interceptors for:
  - Automatically attaching `Authorization: Bearer <token>` header.
  - Token refresh on 401 responses.
  - Logging requests/responses in debug mode.
  - Centralized error handling.

### Base URL
```dart
static const String baseUrl = 'http://<server>:8080/api/v1';
```

### API Constants
Define all endpoints as constants in `api_constants.dart`:
```dart
class ApiEndpoints {
  static const String activeGigs = '/gig/active-gigs';
  static const String gigById = '/gig/by-id';       // append /{id}
  static const String allProviders = '/provider/all';
  static const String providerById = '/provider/with-id'; // append /{id}
  static const String createBooking = '/booking/persist';
  static const String reviewsByGig = '/review/by-gig-id'; // ?id={id}
  // ... etc
}
```

### Error Handling
- Wrap all API calls in try-catch.
- Map HTTP errors to user-friendly messages.
- Use a sealed `Result<T>` class or `Either<Failure, T>` pattern.
- Show `SnackBar` for recoverable errors, full-screen error widget for fatal ones.

---

## Rule 7: Authentication

### Flow
1. User taps Login → open Keycloak auth page via `flutter_appauth`.
2. Keycloak redirects back with auth code → exchange for tokens.
3. Store access + refresh tokens in `flutter_secure_storage`.
4. Decode JWT to extract `realm_access.roles`, `sub` (user ID), `email`, `name`.
5. On token expiry → silently refresh using refresh token.
6. On refresh failure → redirect to login.

### Token Storage Keys
```dart
static const String accessTokenKey = 'auth_access_token';
static const String refreshTokenKey = 'auth_refresh_token';
static const String userIdKey = 'auth_user_id';
static const String userRolesKey = 'auth_user_roles';
```

### Route Guards
- Use `go_router` redirect logic to check auth state before navigating to protected routes.
- If no valid token → redirect to login screen.
- If token exists but wrong role → redirect to forbidden screen.

---

## Rule 8: Routing

Use **go_router** with this pattern:

```dart
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Auth guard logic here
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/services', builder: (_, __) => const GigsListScreen()),
    GoRoute(path: '/services/:id', builder: (_, state) => GigDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/providers', builder: (_, __) => const ProvidersListScreen()),
    GoRoute(path: '/providers/:id', builder: (_, state) => ProviderDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/forbidden', builder: (_, __) => const ForbiddenScreen()),
    // Protected routes
    ShellRoute(/* Bottom nav shell for authenticated users */),
    GoRoute(path: '/profile', builder: ...),
    GoRoute(path: '/profile/security', builder: ...),
    GoRoute(path: '/profile/bookings', builder: ...),
    GoRoute(path: '/profile/preferences', builder: ...),
    GoRoute(path: '/provider-dashboard', builder: ...),
    GoRoute(path: '/admin', builder: ...),
  ],
);
```

---

## Rule 9: Widget Building Rules

- **Extract early**: If a build method exceeds ~50 lines, extract sub-widgets.
- **Prefer composition**: Build complex UIs by composing small, focused widgets.
- **Keys**: Use `ValueKey` on list items that can reorder.
- **Responsiveness**: Use `LayoutBuilder` / `MediaQuery` for adaptive layouts. Support both phone and tablet.
- **Loading states**: Every async screen MUST show a loading indicator (use `LoadingWidget` from shared).
- **Error states**: Every async screen MUST handle errors gracefully — never show a blank screen.
- **Empty states**: Lists MUST handle the empty case with a meaningful message/illustration.

---

## Rule 10: Assets & Resources

```
assets/
├── images/
│   ├── logo.png
│   ├── user_placeholder.jpg
│   └── forbidden_403.jpg
├── animations/
│   └── real_estate.lottie
└── icons/
    └── (any custom icons)
```

- Register all assets in `pubspec.yaml` under `flutter.assets`.
- Use `cached_network_image` for all remote images — never load URLs with raw `Image.network`.
- Provide placeholder and error widgets for every network image.

---

## Rule 11: Testing

- **Unit tests**: All repositories and models must have unit tests.
- **Widget tests**: All shared widgets and critical screens must have widget tests.
- **Naming**: Test files mirror source files with `_test.dart` suffix.
- **Mocking**: Use `mocktail` or `mockito` for repository mocks.
- Run all tests before merging: `fvm flutter test`.

---

## Rule 12: Packages (Required)

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` or `flutter_bloc` | State management |
| `go_router` | Navigation/routing |
| `dio` | HTTP client |
| `flutter_appauth` | Keycloak OAuth |
| `flutter_secure_storage` | Secure token storage |
| `google_fonts` | Inter + Playfair Display fonts |
| `cached_network_image` | Image caching |
| `lottie` | Lottie animations |
| `json_annotation` + `json_serializable` | JSON serialization |
| `build_runner` | Code generation |
| `freezed` (optional) | Immutable models + unions |
| `intl` | Date/time formatting |
| `flutter_svg` | SVG rendering |
| `shimmer` | Loading shimmer effects |

---

## Rule 13: Git & Code Quality

### Git Rules

* Use commit message prefixes when suggesting commit messages:

  * `feat:` — new feature
  * `fix:` — bug fix
  * `refactor:` — code restructuring
  * `chore:` — maintenance
  * `docs:` — documentation-only changes

* **NEVER create a Git commit automatically.**

* **NEVER run `git commit` unless the user explicitly asks you to commit.**

* **NEVER run `git push` automatically.**

* The user is responsible for reviewing changes and deciding when to commit and push.

* After completing a task, show the user what was changed and leave the working tree ready for review.

* If useful, provide a suggested commit message, but do not execute the commit.

### Code Quality Before Completion

Run the appropriate validation commands after making changes:

```bash
fvm flutter analyze
fvm flutter test
fvm dart format .
```

* `fvm flutter analyze` must have zero warnings/errors.
* `fvm flutter test` must pass.
* `fvm dart format .` must be applied to maintain consistent formatting.
* Fix issues discovered during validation before considering the implementation successful.

### Generated Files

* Never manually commit generated files such as:

  * `*.g.dart`
  * `*.freezed.dart`
* Add generated files to `.gitignore` when appropriate.
* Generated files may be created locally by build/code-generation commands.
* Keep `pubspec.lock` committed.

### Completion Flow

The agent must follow this sequence:

```text
Implement change
      ↓
Run validation
      ↓
Fix any issues
      ↓
Confirm implementation works
      ↓
Update README.md if required
      ↓
Validate README.md
      ↓
Show changes to user
      ↓
STOP — DO NOT COMMIT
```

**The agent's job is to implement and validate the changes.
The user's job is to review, commit, and push the changes.**
--

## Rule 14: README Maintenance

**MANDATORY: Always keep `README.md` synchronized with the actual project state.**

After **every successful change**, feature implementation, bug fix, refactor, configuration change, dependency change, architectural change, or meaningful UI change, the agent MUST review and update `README.md` if the change affects the documented project state.

### Required Workflow

After successfully completing a change:

1. **Verify the implementation**

   * Confirm the requested change is actually working.
   * Run the relevant tests, analyzer, formatter, or other validation required for the change.
   * Do NOT update the README for a change that has not been successfully implemented.

2. **Review the current `README.md`**

   * Check whether the change is already documented.
   * Identify sections that are now outdated or incomplete.
   * Preserve the existing README structure and writing style.

3. **Update `README.md`**

   * Add newly implemented features.
   * Update completed items in feature checklists.
   * Update setup or installation instructions when dependencies/configuration change.
   * Update folder structure when new important directories/files are introduced.
   * Update architecture or technical documentation when the implementation changes the architecture.
   * Update API information when endpoints or API behavior change.
   * Update configuration/environment-variable documentation when required.
   * Remove or correct documentation that is no longer accurate.

4. **Keep documentation factual**

   * Document only functionality that has actually been implemented.
   * Do NOT mark unfinished, experimental, or broken functionality as completed.
   * Do NOT invent features, APIs, configurations, or implementation details.
   * If something is partially implemented, clearly describe it as partial/in progress.

5. **Keep the README concise**

   * Do not dump implementation details or large code blocks into the README unless they are necessary.
   * Prefer short explanations, tables, checklists, and examples.
   * Keep detailed implementation knowledge in the appropriate documentation files.

6. **Validate the README**

   * Check Markdown formatting.
   * Check that file paths, commands, package names, and configuration examples are accurate.
   * Make sure newly added documentation does not contradict the actual implementation.

### README Update Checklist

For every successful change, ask:

* [ ] Does this change introduce a new feature?
* [ ] Does this change complete an existing feature?
* [ ] Does this change modify an existing feature?
* [ ] Does this change affect setup or installation?
* [ ] Does this change add/remove a dependency?
* [ ] Does this change modify the project structure?
* [ ] Does this change modify an API or integration?
* [ ] Does this change modify authentication, authorization, or routing?
* [ ] Does this change modify the architecture?
* [ ] Does this change require new configuration or environment variables?
* [ ] Does the README need to be updated?

If **any answer is YES**, update `README.md` before considering the task complete.

### Important Rule

**A successful implementation is NOT considered complete until the corresponding `README.md` documentation has also been updated when documentation is affected.**

The normal completion sequence is:

```text
Implement change
      ↓
Run validation
      ↓
Confirm change works
      ↓
Review README.md
      ↓
Update README.md if required
      ↓
Validate README.md
      ↓
Task complete
```

### Git Convention

When the README is updated as part of a feature or fix, keep the documentation change with the related implementation change unless there is a specific reason to separate it.

Use the existing commit conventions:

```text
feat: add booking cancellation
fix: resolve provider loading issue
refactor: simplify authentication flow
docs: update README
```

If the README update is directly part of the same feature/fix, it may remain within the same commit:

```text
feat: add booking cancellation and update documentation
```
