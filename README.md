# Routez-
is it possible to implement liquid glass on the navigation tab?

1. Liquid Glass Effect on Navigation Tab
Yes, absolutely! Implementing a Liquid Glass (Glassmorphic Blur) effect on the bottom navigation bar is not only possible in Flutter, but will give Routez a premium, modern aesthetic.

To achieve liquid glass in Flutter:

Wrap the bottom navigation bar inside a floating ClipRRect with BackdropFilter using ImageFilter.blur(sigmaX: 15, sigmaY: 15).
Use a semi-transparent background container (Colors.white.withOpacity(0.15) in light mode, or Colors.black.withOpacity(0.35) in dark mode).
Add a subtle white/gradient border line around the top edge for the translucent edge reflection.
2. Frontend UI Breakdown & Action Plan
Here is the exact breakdown of missing pages, incomplete pages, and frontend tasks to tackle first in the Flutter app (routez/).

A. New Pages Yet to be Implemented (Completely Missing)
Screen Name	File Path	Purpose / Description
Route Detail View	lib/features/route_results/presentation/screens/route_detail_screen.dart	Pre-trip inspection screen showing step-by-step walk/bus breakdown on a map preview before starting a trip.
Edit Profile Screen	lib/features/profile/presentation/screens/edit_profile_screen.dart	Form for editing full name, email, phone number, avatar picture, and default transport preference.
Add / Edit Saved Location	lib/features/saved_routes/presentation/screens/add_saved_location_screen.dart	Screen/modal to pick a pin on a map, label it (Home, Work, School), and save it.
Help & Support Screen	lib/features/profile/presentation/screens/help_support_screen.dart	FAQ accordion list, contact support form, emergency matatu/stage safety report form.
Legal / Policy Screens	lib/features/settings/presentation/screens/terms_conditions_screen.dart	Document viewer screens for Terms & Conditions and Privacy Policy.
Security & Password Screen	lib/features/settings/presentation/screens/change_password_screen.dart	Password change form and biometric configuration screen.
B. Incomplete Pages & What Needs to be Done
1. Bottom Navigation Shell (lib/core/navigation/bottom_nav_shell.dart)
❌ Current state: Standard Material BottomNavigationBar.
🛠️ Needs to be done:
Convert to liquid glass floating navigation bar with backdrop blur filters.
Add active tab indicator pill animation and unread badge on Profile/Settings.
2. Home Screen (lib/features/home/presentation/screens/home_screen.dart)
❌ Current state: Layout created, but map is a static icon (Icon(Icons.map)).
🛠️ Needs to be done:
Replace Icon(Icons.map) with interactive map view widget (Google Maps / Mapbox) showing current user location pin and nearby stage markers.
Implement quick action button callbacks ("Work", "Home", "Popular") to auto-fill search destination.
Connect floating location button (Icons.my_location) to re-center the map on current location.
Make Draggable Bottom Sheet tiles interactive (tapping a nearby stage opens stage details).
3. Search Screen (lib/features/search/presentation/screens/search_screen.dart)
❌ Current state: Text fields and static list of recent searches.
🛠️ Needs to be done:
Add "Choose on Map" button tile next to input fields.
Integrate live search autocomplete dropdown list under inputs.
Add "Clear All" / delete button for recent search history items.
4. Route Results Screen (lib/features/route_results/presentation/screens/route_results_screen.dart)
❌ Current state: Displays 2 hardcoded static cards.
🛠️ Needs to be done:
Add Filter & Sort bar header at the top (e.g., "Fastest", "Cheapest", "Least Walking").
Add map preview container above or behind the route cards showing route paths.
Add bookmark button on route cards to directly save a route to "Saved Routes".
5. Active Trip Screen (lib/features/active_trip/presentation/screens/active_trip_screen.dart)
❌ Current state: Static placeholder showing single step ("Walk to Pipeline Stage").
🛠️ Needs to be done:
Build multi-step trip wizard progression view (Step 1: Walk to Stage $\rightarrow$ Step 2: Board Matatu 23 $\rightarrow$ Step 3: Alight at Destination).
Add map polyline rendering showing real-time GPS progress along the route.
Add voice navigation toggle button and destination arrival alert popup.
Add confirmation dialog modal before ending a trip.
6. Saved Routes Screen (lib/features/saved_routes/presentation/screens/saved_routes_screen.dart)
❌ Current state: Renders empty state, but edit/delete buttons have empty callbacks.
🛠️ Needs to be done:
Add Floating Action Button (+ Add Route).
Implement edit dialog modal and delete confirmation popup for list items.
7. Trip History Screen (lib/features/trip_history/presentation/screens/trip_history_screen.dart)
❌ Current state: Renders mock list with a simple dialog.
🛠️ Needs to be done:
Add "Repeat Trip" quick action button on past trip cards.
Replace basic dialog with a detailed trip summary sheet (route path, total fare spent, departure/arrival timestamps).
Add search bar / date range filter for trip history.
8. Profile Screen (lib/features/profile/presentation/screens/profile_screen.dart)
❌ Current state: Static profile card with dummy text ("Jane Doe").
🛠️ Needs to be done:
Connect "Edit Profile", "Help & Support", and "About" tiles to navigate to their respective new screens.
Add avatar photo upload / edit icon button.
Add confirmation modal when clicking "Logout".
9. Settings Screen (lib/features/settings/presentation/screens/settings_screen.dart)
❌ Current state: Theme toggle works; other options are non-interactive.
🛠️ Needs to be done:
Implement Language selector modal (English / Swahili).
Wire up "Change Password", "Manage Data", "Terms & Conditions", and "Privacy Policy" navigation handlers.
Add "Clear Trip History" confirmation dialog with destructive warning styling.
3. Recommended Priorities (What to do first)
Step 1: Implement Liquid Glass Navigation Bar in bottom_nav_shell.dart to establish the visual aesthetic.
Step 2: Upgrade home_screen.dart with a map widget UI and working quick action buttons.
Step 3: Enhance search_screen.dart with map picker UI & location autocomplete dropdown.
Step 4: Build route_detail_screen.dart and enhance active_trip_screen.dart with multi-step trip navigation.
Step 5: Create missing secondary screens (edit_profile_screen.dart, help_support_screen.dart).