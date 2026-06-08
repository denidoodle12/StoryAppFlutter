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
import '../widgets/staggered_slide_transition.dart';
import '../widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StoryListProvider>().fetchNextPage();
    }
  }

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
              _buildThemeToggle(context),
              _buildOverflowMenu(context),
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

  Widget _buildOverflowMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isId = localeProvider.locale.languageCode == 'id';

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          tooltip: l10n.language,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'locale':
                localeProvider.setLocale(Locale(isId ? 'en' : 'id'));
              case 'logout':
                _showLogoutDialog(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'locale',
              child: Row(
                children: [
                  Text(
                    isId ? '🇬🇧' : '🇮🇩',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isId ? 'EN' : 'ID',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.logout,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
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
                ResultSuccess<List<Story>>() => _buildStoryList(
                  context,
                  provider,
                ),
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

  Widget _buildStoryList(BuildContext context, StoryListProvider provider) {
    final stories = provider.stories;

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => provider.fetchStories(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        itemCount: stories.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == stories.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            );
          }

          final story = stories[index];
          return StaggeredSlideTransition(
            index: index,
            child: StoryCard(
              story: story,
              onTap: () => context.push(AppRoutes.detail(story.id)),
            ),
          );
        },
      ),
    );
  }
}
