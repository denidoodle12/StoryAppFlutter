import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common/app_colors.dart';
import '../../common/app_routes.dart';
import '../../common/localization.dart';
import '../../data/models/story.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/story_list_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/result_state.dart';
import '../widgets/empty_display.dart';
import '../widgets/error_display.dart';
import '../widgets/shimmer_story_list.dart';
import '../widgets/story_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(child: _buildBody(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.upload),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: Text(
          l10n.addStory,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.appName,
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              _buildLocaleToggle(context),
              _buildThemeToggle(context),
              _buildLogoutButton(context),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.sora(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.8,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: l10n.discoverPart1),
                      TextSpan(
                        text: l10n.discoverHighlight,
                        style: const TextStyle(color: AppColors.primaryColor),
                      ),
                      TextSpan(text: l10n.discoverPart2),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.discoverSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLocaleToggle(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isId = localeProvider.locale.languageCode == 'id';
        return IconButton(
          tooltip: AppLocalizations.of(context).language,
          icon: Text(
            isId ? '🇮🇩' : '🇬🇧',
            style: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            localeProvider.setLocale(Locale(isId ? 'en' : 'id'));
          },
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return IconButton(
          tooltip: AppLocalizations.of(context).darkMode,
          icon: Icon(
            themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      tooltip: l10n.logout,
      icon: const Icon(Icons.logout_rounded),
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.logout),
            content: Text(l10n.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.read<AuthProvider>().logout();
                },
                child: Text(l10n.yes),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Consumer<StoryListProvider>(
            builder: (context, provider, _) {
              return switch (provider.state) {
                ResultLoading() => const ShimmerStoryList(),
                ResultSuccess<List<Story>>(data: final stories) =>
                  _buildStoryList(context, stories),
                ResultError(message: final msg) => ErrorDisplay(
                  message: msg,
                  onRetry: () => provider.fetchStories(),
                ),
                ResultEmpty() => EmptyDisplay(
                  message: AppLocalizations.of(context).noStories,
                  subtitle: AppLocalizations.of(context).noStoriesSubtitle,
                  icon: Icons.auto_stories_rounded,
                ),
              };
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryList(BuildContext context, List<Story> stories) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => context.read<StoryListProvider>().fetchStories(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return StoryCard(
            story: story,
            onTap: () => context.push(AppRoutes.detail(story.id)),
          );
        },
      ),
    );
  }
}
