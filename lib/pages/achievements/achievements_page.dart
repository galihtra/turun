import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/model/achievement/achievement_model.dart';
import 'package:turun/data/providers/achievement/achievement_provider.dart';
import 'package:turun/resources/colors_app.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().loadUserAchievements();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<AchievementProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const Gap(16),
                    Text('Error: ${provider.error}'),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () => provider.loadUserAchievements(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildHeader(provider),
                _buildStats(provider),
                const Gap(8),
                _buildTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllTab(provider),
                      _buildTypeTab(provider, AchievementType.distance),
                      _buildTypeTab(provider, AchievementType.streak),
                      _buildTypeTab(provider, AchievementType.runs),
                      _buildTypeTab(provider, AchievementType.territory),
                      _buildTypeTab(provider, AchievementType.landmark),
                      _buildTypeTab(provider, AchievementType.special),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AchievementProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blueLogo,
            AppColors.blueLogo.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(AchievementProvider provider) {
    final totalAchievements = Achievement.all.length;
    final unlockedCount = provider.unlockedAchievements.length;
    final percentage = ((unlockedCount / totalAchievements) * 100).toInt();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF6366F1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.emoji_events,
                label: 'Unlocked',
                value: '$unlockedCount/$totalAchievements',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                icon: Icons.stars,
                label: 'Total Points',
                value: '${provider.totalPoints}',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                icon: Icons.trending_up,
                label: 'Progress',
                value: '$percentage%',
              ),
            ],
          ),
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: unlockedCount / totalAchievements,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const Gap(8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.blueLogo,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.blueLogo,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Distance'),
          Tab(text: 'Streak'),
          Tab(text: 'Runs'),
          Tab(text: 'Territory'),
          Tab(text: 'Landmark'),
          Tab(text: 'Special'),
        ],
      ),
    );
  }

  Widget _buildAllTab(AchievementProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadUserAchievements(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (provider.unlockedAchievements.isNotEmpty) ...[
            const Text(
              'Unlocked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const Gap(12),
            ...provider.unlockedAchievements
                .map((ua) => _buildAchievementCard(ua, true)),
            const Gap(24),
          ],
          if (provider.lockedAchievements.isNotEmpty) ...[
            const Text(
              'Locked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const Gap(12),
            ...provider.lockedAchievements
                .map((ua) => _buildAchievementCard(ua, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeTab(AchievementProvider provider, AchievementType type) {
    final achievements = provider.getAchievementsByType(type);
    final unlocked = achievements.where((ua) => ua.isUnlocked).toList();
    final locked = achievements.where((ua) => !ua.isUnlocked).toList();

    return RefreshIndicator(
      onRefresh: () => provider.loadUserAchievements(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (unlocked.isNotEmpty) ...[
            const Text(
              'Unlocked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const Gap(12),
            ...unlocked.map((ua) => _buildAchievementCard(ua, true)),
            const Gap(24),
          ],
          if (locked.isNotEmpty) ...[
            const Text(
              'Locked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const Gap(12),
            ...locked.map((ua) => _buildAchievementCard(ua, false)),
          ],
          if (achievements.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No achievements in this category yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(UserAchievement userAchievement, bool isUnlocked) {
    final achievement = userAchievement.achievement;
    if (achievement == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? achievement.tier.color.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? achievement.tier.color.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon with tier color
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          achievement.tier.color,
                          achievement.tier.color.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: isUnlocked ? null : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  achievement.icon,
                  color: isUnlocked ? Colors.white : Colors.grey[400],
                  size: 36,
                ),
              ),
            ),
            const Gap(16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? const Color(0xFF0D1B2A)
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: achievement.tier.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: achievement.tier.color,
                            ),
                            const Gap(4),
                            Text(
                              '${achievement.points}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: achievement.tier.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Gap(12),
                  // Progress bar
                  if (!isUnlocked) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: userAchievement.progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement.tier.color,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          '${userAchievement.progressPercentage}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: achievement.tier.color,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      '${userAchievement.currentProgress.toStringAsFixed(achievement.type == AchievementType.distance ? 1 : 0)} / ${achievement.targetValue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: achievement.tier.color,
                        ),
                        const Gap(6),
                        Text(
                          'Unlocked!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: achievement.tier.color,
                          ),
                        ),
                        if (userAchievement.unlockedAt != null) ...[
                          const Gap(8),
                          Text(
                            _formatUnlockedDate(userAchievement.unlockedAt!),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUnlockedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
