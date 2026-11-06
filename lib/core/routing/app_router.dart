import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/bills/presentation/bills_screen.dart';
import '../../features/bills/presentation/bill_form_screen.dart';
import '../../features/spending/presentation/spending_screen.dart';
import '../../features/spending/presentation/transaction_form_screen.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/categories_screen.dart';
import '../../features/settings/presentation/category_form_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';

/// App router - declarative, type-safe navigation
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/bills',
      name: 'bills',
      builder: (context, state) => const BillsScreen(),
      routes: [
        GoRoute(
          path: 'add',
          name: 'addBill',
          builder: (context, state) => const BillFormScreen(),
        ),
        GoRoute(
          path: 'edit/:billId',
          name: 'editBill',
          builder: (context, state) => BillFormScreen(billId: state.pathParameters['billId']),
        ),
      ],
    ),
    GoRoute(
      path: '/spending',
      name: 'spending',
      builder: (context, state) => const SpendingScreen(),
      routes: [
        GoRoute(
          path: 'add',
          name: 'addTransaction',
          builder: (context, state) => const TransactionFormScreen(),
        ),
        GoRoute(
          path: 'edit/:transactionId',
          name: 'editTransaction',
          builder: (context, state) => TransactionFormScreen(transactionId: state.pathParameters['transactionId']),
        ),
      ],
    ),
    GoRoute(
      path: '/insights',
      name: 'insights',
      builder: (context, state) => const InsightsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'categories',
          name: 'categories',
          builder: (context, state) => const CategoriesScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'addCategory',
              builder: (context, state) => const CategoryFormScreen(),
            ),
            GoRoute(
              path: 'edit/:categoryId',
              name: 'editCategory',
              builder: (context, state) => CategoryFormScreen(categoryId: state.pathParameters['categoryId']),
            ),
          ],
        ),
        GoRoute(
          path: 'budget',
          name: 'budget',
          builder: (context, state) => const BudgetScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);