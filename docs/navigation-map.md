# Navigation Map Document

This document outlines the complete navigation structure for the Money Tracker app, defining every required screen, its clean URI path, and the blocs it depends on. This will drive RouteInformationParser and deep-link handling implementation.

## Screen Navigation Map

| Screen | Path | Required Bloc(s) | Notes |
|--------|------|------------------|-------|
| **Home/Dashboard** | `/` | OnboardingBloc, ExpenseBloc, CategoryBloc | Main landing screen with expense overview and quick actions |
| **Expense List** | `/expenses` | ExpenseBloc, CategoryBloc | Full list view of all expenses with filtering |
| **Add Expense** | `/expense/add` | ExpenseBloc, CategoryBloc | Full-screen form for adding new expenses |
| **Edit Expense** | `/expense/:id/edit` | ExpenseBloc, CategoryBloc | Full-screen form for editing existing expenses |
| **Expense Details** | `/expense/:id` | ExpenseBloc, CategoryBloc | Detailed view of a single expense |
| **Categories Management** | `/categories` | CategoryBloc | Manage expense categories (CRUD operations) |
| **Add Category** | `/category/add` | CategoryBloc | Form for creating new categories |
| **Edit Category** | `/category/:id/edit` | CategoryBloc | Form for editing existing categories |
| **Statistics/Analytics** | `/stats` | ExpenseBloc, CategoryBloc | Charts and analytics for spending patterns |
| **Monthly Report** | `/stats/monthly/:year/:month` | ExpenseBloc, CategoryBloc | Detailed monthly spending report |
| **Category Report** | `/stats/category/:id` | ExpenseBloc, CategoryBloc | Spending analysis for specific category |
| **Settings** | `/settings` | — | App settings and preferences |
| **Profile/Account** | `/profile` | — | User profile and account settings |
| **Export Data** | `/export` | ExpenseBloc | Data export functionality |
| **Import Data** | `/import` | ExpenseBloc, CategoryBloc | Data import functionality |
| **Budget Management** | `/budget` | ExpenseBloc, CategoryBloc, BudgetBloc | Budget setting and tracking (future feature) |
| **Search** | `/search` | ExpenseBloc, CategoryBloc | Global search across expenses |

## Modal/Bottom Sheet Components

These are not full screens but modal components that can be triggered from various screens:

| Component | Trigger Paths | Required Bloc(s) | Notes |
|-----------|---------------|------------------|-------|
| **Add Expense Modal** | Any screen + FAB | ExpenseBloc, CategoryBloc | Quick expense entry modal |
| **Category Selection** | `/expense/*` modals | CategoryBloc | Category picker bottom sheet |
| **Date Selection** | `/expense/*` modals | — | Date picker bottom sheet |
| **Filter Options** | `/expenses`, `/stats` | ExpenseBloc, CategoryBloc | Filter and sort options |
| **Delete Confirmation** | Various screens | — | Confirmation dialog for deletions |
| **Export Options** | `/export` | — | Export format and options selector |

## Navigation Structure

### Bottom Navigation (Main Tabs)
- **Home** (`/`) - Dashboard with quick overview
- **Expenses** (`/expenses`) - Full expense list
- **Stats** (`/stats`) - Analytics and reports
- **Settings** (`/settings`) - App settings

### Floating Action Button
- **Add Expense** - Opens Add Expense Modal from any main tab

### Deep Link Support

All screens should support deep linking with the following considerations:

1. **Parameter Validation**: Validate ID parameters (`:id`, `:year`, `:month`) before navigation
2. **Fallback Routes**: Invalid IDs should redirect to appropriate list screens
3. **Authentication**: Future auth implementation should redirect to login if needed
4. **State Restoration**: Preserve navigation state across app restarts

### Route Examples

```
// Basic routes
https://moneytracker.app/
https://moneytracker.app/expenses
https://moneytracker.app/categories
https://moneytracker.app/stats

// Parameterized routes
https://moneytracker.app/expense/123
https://moneytracker.app/expense/123/edit
https://moneytracker.app/category/456/edit
https://moneytracker.app/stats/monthly/2024/03
https://moneytracker.app/stats/category/456

// Search with query parameters
https://moneytracker.app/search?q=coffee&category=food&from=2024-01-01&to=2024-03-31
```

## Implementation Priority

### Phase 1 (Current - Basic Functionality)
- ✅ Home/Dashboard (`/`)
- ✅ Add Expense Modal (existing)
- 🔄 Expense List (`/expenses`) 
- 🔄 Edit Expense (`/expense/:id/edit`)

### Phase 2 (Core Features)
- Categories Management (`/categories`)
- Add/Edit Category forms
- Expense Details (`/expense/:id`)
- Basic Statistics (`/stats`)

### Phase 3 (Advanced Features)
- Advanced analytics and reports
- Search functionality
- Data import/export
- Settings and profile management

### Phase 4 (Future Enhancements)
- Budget management
- Recurring expenses
- Notification settings
- Data synchronization

## Bloc Dependencies Summary

### OnboardingBloc
- Screens: Home/Dashboard
- Purpose: Handle first-time user experience and app initialization

### ExpenseBloc  
- Screens: Home, Expense List, Add/Edit Expense, Expense Details, Statistics, Search, Export, Import
- Purpose: Manage all expense-related operations (CRUD, filtering, searching)

### CategoryBloc
- Screens: All expense-related screens, Categories Management, Add/Edit Category, Statistics 
- Purpose: Manage expense categories (CRUD, selection, validation)

### BudgetBloc (Future)
- Screens: Budget Management, Statistics (budget vs actual)
- Purpose: Handle budget creation, tracking, and alerts

## Navigation State Management

The app should implement:

1. **Route Information Parser**: Parse URLs into route objects
2. **Router Delegate**: Manage navigation stack and route transitions  
3. **Route Information Provider**: Generate URLs from app state
4. **Deep Link Handler**: Process incoming deep links and validate parameters
5. **Navigation Guards**: Protect routes that require certain conditions
6. **State Restoration**: Restore navigation state after app restart

This navigation map will serve as the foundation for implementing Go Router or similar declarative routing solution with full deep link support.
