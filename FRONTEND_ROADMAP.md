# Routez Frontend Implementation Roadmap

This document outlines the step-by-step phased implementation roadmap for the **Routez** mobile application (`routez/`).

---

## 🎨 Phase 1: Visual Design & Glassmorphic Navigation Shell
> **Focus:** Elevating the app's visual identity and bottom navigation tab.

- [x] **1.1 Liquid Glass Navigation Bar (`lib/core/navigation/bottom_nav_shell.dart`)**
  - Wrap `BottomNavigationBar` in a floating `ClipRRect` with `BackdropFilter` (`ImageFilter.blur(sigmaX: 15, sigmaY: 15)`).
  - Add translucent background container with subtle white border reflection.
  - Implement active tab selection indicator pill animation.
- [x] **1.2 Glassmorphic Theme Tokens (`lib/core/theme/app_theme.dart` & `lib/core/constants/app_colors.dart`)**
  - Define light and dark glassmorphic container styles and gradient accents.

---

## 🔍 Phase 2: Route Search & Selection Flow
> **Focus:** Making destination searching and route comparison smooth and intuitive.

- [x] **2.1 Search Screen Enhancements (`lib/features/search/presentation/screens/search_screen.dart`)**
  - Add *"Choose location on map"* action button tile.
  - Add *"Clear History"* button and interactive recent search list.
  - Add search input clear `(X)` buttons.
- [x] **2.2 Route Results Enhancements (`lib/features/route_results/presentation/screens/route_results_screen.dart`)**
  - Add Filter & Sort bar header (*"Fastest"*, *"Cheapest"*, *"Least Walking"*).
  - Add bookmark icon button on route cards to directly save routes.
- [x] **2.3 Create [NEW] Route Detail Screen (`lib/features/route_results/presentation/screens/route_detail_screen.dart`)**
  - Build pre-trip inspection screen displaying step-by-step walking/bus segments, stage details, fare breakdowns, and start trip button.
  - Register route `/route-detail` in `lib/core/navigation/app_router.dart`.

---

## 🗺️ Phase 3: Interactive Map & Live Active Trip View
> **Focus:** Transforming static placeholders into an interactive transit map and navigation dashboard.

- [ ] **3.1 Home Screen Map & Interactions (`lib/features/home/presentation/screens/home_screen.dart`)**
  - Replace static `Icon(Icons.map)` with an interactive map container/widget ready for map layers (user pin & nearby Matatu stage pins).
  - Wire up quick action buttons (*"Home"*, *"Work"*, *"Popular"*) to auto-fill search routes.
  - Wire up floating location button `(Icons.my_location)` to re-center location.
  - Make Draggable Bottom Sheet stage items clickable.
- [ ] **3.2 Active Trip Navigation Wizard (`lib/features/active_trip/presentation/screens/active_trip_screen.dart`)**
  - Implement multi-step trip wizard view (*Step 1: Walk to Stage* → *Step 2: Board Matatu* → *Step 3: Alight*).
  - Add route polyline overview container.
  - Add voice navigation toggle and proximity arrival alert dialog.
  - Add "End Trip" confirmation modal dialog.

---

## 👤 Phase 4: User Profile, Saved Locations & Trip Management
> **Focus:** Personalization, saved places, and past trip management.

- [ ] **4.1 Saved Routes & Locations (`lib/features/saved_routes/presentation/screens/saved_routes_screen.dart`)**
  - Add `+ Add Location` Floating Action Button.
  - Implement Edit and Delete confirmation dialogs for saved route cards.
  - Create **[NEW] Add Saved Location Screen (`lib/features/saved_routes/presentation/screens/add_saved_location_screen.dart`)**.
- [ ] **4.2 Trip History Enhancements (`lib/features/trip_history/presentation/screens/trip_history_screen.dart`)**
  - Add *"Repeat Trip"* quick action button on past trip cards.
  - Replace simple alert dialog with a rich **Trip Details Summary Bottom Sheet**.
  - Add search bar / filter for past trips.
- [ ] **4.3 Create [NEW] Edit Profile Screen (`lib/features/profile/presentation/screens/edit_profile_screen.dart`)**
  - Avatar image picker/editor, full name, phone number, and preferred transit mode form.
  - Add Logout confirmation modal to `lib/features/profile/presentation/screens/profile_screen.dart`.

---

## ⚙️ Phase 5: Settings, Safety & Support
> **Focus:** App configuration, help resources, and security.

- [ ] **5.1 Settings Screen Enhancements (`lib/features/settings/presentation/screens/settings_screen.dart`)**
  - Add Language selector modal (*English / Swahili*).
  - Add *"Clear Trip History"* destructive confirmation dialog.
- [ ] **5.2 Create [NEW] Help & Support Screen (`lib/features/profile/presentation/screens/help_support_screen.dart`)**
  - FAQ accordion list, support contact form, and emergency Matatu stage safety report button.
- [ ] **5.3 Create [NEW] Security & Legal Screens**
  - **Change Password Screen** (`lib/features/settings/presentation/screens/change_password_screen.dart`).
  - **Terms & Privacy Policy Screen** (`lib/features/settings/presentation/screens/terms_conditions_screen.dart`).
