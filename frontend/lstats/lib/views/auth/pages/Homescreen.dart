import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loadingindicator.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String displayName;

  const HomeScreen({
    super.key,
    required this.username,
    required this.displayName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isDarkMode = true;
  bool isLoading = true;
  bool hasError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Use the theme colors from the separate file
  Map<String, Color> get colors => AppThemeColors.getColors(isDarkMode);

  // API data
  int easySolved = 0, mediumSolved = 0, hardSolved = 0;
  int totaleasy = 0, totalmedium = 0, totalhard = 0;
  String globalRank = "-";

  // Analytics data
  int thisWeekSolved = 0;
  int lastWeekSolved = 0;
  double consistencyScore = 0.0;

  Map<DateTime, int> calendarData = {};
  List<FlSpot> monthlyData = [];

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    fetchLeetCodeStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> fetchLeetCodeStats() async {
    final String username = widget.username;
    final uri = Uri.parse("https://lstats.onrender.com/leetcode/$username");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final calendarRaw = data['calendar'];
        Map<DateTime, int> parsedData = {};
        if (calendarRaw != null && calendarRaw.isNotEmpty) {
          final Map<String, dynamic> cal = json.decode(calendarRaw);
          cal.forEach((key, value) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              int.parse(key) * 1000,
            );
            final normalizedDate = DateTime(date.year, date.month, date.day);

            // Bucket values for shades
            int v = value as int;
            if (v >= 10) {
              v = 10;
            } else if (v >= 5) {
              v = 5;
            } else if (v >= 3) {
              v = 3;
            } else if (v >= 1) {
              v = 1;
            } else {
              v = 0;
            }

            parsedData[normalizedDate] = v;
          });
        }

        setState(() {
          easySolved = data['easySolved'];
          mediumSolved = data['mediumSolved'];
          hardSolved = data['hardSolved'];
          globalRank = "#${data['ranking']}";
          calendarData = parsedData;
          monthlyData = _generateMonthlyData(parsedData);
          totaleasy = data["easyTotal"];
          totalmedium = data["mediumTotal"];
          totalhard = data["hardTotal"];

          // Calculate analytics
          thisWeekSolved = _calculateWeekSolved(parsedData, 0);
          lastWeekSolved = _calculateWeekSolved(parsedData, 1);
          consistencyScore = _calculateConsistencyScore(parsedData);

          isLoading = false;
        });

        _animationController.forward();
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  int _calculateWeekSolved(Map<DateTime, int> calendar, int weeksAgo) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1 + (weeksAgo * 7)),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    int solved = 0;
    calendar.forEach((date, value) {
      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        solved += value;
      }
    });
    return solved;
  }

  double _calculateConsistencyScore(Map<DateTime, int> calendar) {
    if (calendar.isEmpty) return 0.0;

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    int activeDays = 0;
    int totalDays = 0;

    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      if (date.isAfter(thirtyDaysAgo.subtract(const Duration(days: 1)))) {
        totalDays++;
        if (calendar.containsKey(date) && calendar[date]! > 0) {
          activeDays++;
        }
      }
    }

    if (totalDays == 0) return 0.0;
    return (activeDays / totalDays) * 100;
  }

  List<FlSpot> _generateMonthlyData(Map<DateTime, int> calendarData) {
    Map<String, int> monthlyActivity = {};

    // Initialize last 12 months
    final now = DateTime.now();
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      monthlyActivity[monthKey] = 0;
    }

    // Aggregate calendar data by month
    calendarData.forEach((date, value) {
      final monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      if (monthlyActivity.containsKey(monthKey)) {
        monthlyActivity[monthKey] = monthlyActivity[monthKey]! + value;
      }
    });

    List<FlSpot> spots = [];
    int index = 0;
    monthlyActivity.forEach((key, value) {
      spots.add(FlSpot(index.toDouble(), value.toDouble()));
      index++;
    });

    return spots;
  }

  List<String> _getMonthLabels() {
    List<String> labels = [];
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][date.month];
      labels.add(monthName);
    }

    return labels;
  }

  int _calculateMonthlySolved(Map<DateTime, int> calendarData) {
    if (calendarData.isEmpty) return 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    int solved = 0;
    calendarData.forEach((date, value) {
      if (date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        solved += value;
      }
    });

    return solved;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppThemeColors.getBackgroundColor(isDarkMode),
        body: isLoading
            ? LStatsLoadingIndicator(colors: colors)
            : hasError
            ? _buildErrorState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  slivers: [
                    _buildEnhancedAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.all(20.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Weekly Summary
                          _buildWeeklySummaryCard(),
                          const SizedBox(height: 20),

                          // Consistency Score
                          _buildConsistencyCard(),
                          const SizedBox(height: 20),

                          // Problems Solved
                          _buildProblemsCard(),
                          const SizedBox(height: 20),

                          // Stats Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Current Streak",
                                  "${_calculateStreak()}",
                                  "days",
                                  Icons.local_fire_department_outlined,
                                  AppThemeColors.getPrimaryColor(isDarkMode),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  "Global Rank",
                                  globalRank.replaceAll('#', ''),
                                  "worldwide",
                                  Icons.emoji_events_outlined,
                                  AppThemeColors.getPrimaryColor(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Monthly Activity Graph
                          _buildMonthlyActivityCard(),
                          const SizedBox(height: 20),

                          // Total Solved
                          _buildTotalSolvedCard(),
                          const SizedBox(height: 20),

                          // Heatmap Calendar
                          _buildHeatmapCard(),
                          const SizedBox(height: 20),

                          TargetStatCard(
                            currentProgress: _calculateMonthlySolved(
                              calendarData,
                            ),
                            target: 50,
                            colors: colors,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      stretch: false,
      backgroundColor: AppThemeColors.getBackgroundColor(isDarkMode),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeColors.getPrimaryColor(isDarkMode).withOpacity(0.1),
                AppThemeColors.getSurfaceColor(isDarkMode),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppThemeColors.getBorderColor(isDarkMode),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemeColors.getPrimaryColor(
                  isDarkMode,
                ).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Enhanced Avatar with gradient border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppThemeColors.getPrimaryColor(isDarkMode),
                        AppThemeColors.getPrimaryColor(
                          isDarkMode,
                        ).withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeColors.getPrimaryColor(
                          isDarkMode,
                        ).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppThemeColors.getSurfaceColor(isDarkMode),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppThemeColors.getPrimaryColor(
                        isDarkMode,
                      ),
                      child: Text(
                        widget.displayName.isNotEmpty
                            ? widget.displayName[0].toUpperCase()
                            : widget.username[0].toUpperCase(),
                        style: TextStyle(
                          color: AppThemeColors.getBackgroundColor(isDarkMode),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // User info with better typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppThemeColors.getTextPrimaryColor(isDarkMode),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${widget.username}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppThemeColors.getTextSecondaryColor(
                            isDarkMode,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Theme toggle with better styling
                Container(
                  decoration: BoxDecoration(
                    color: AppThemeColors.getPrimaryColor(
                      isDarkMode,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: AppThemeColors.getPrimaryColor(isDarkMode),
                    ),
                    onPressed: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                      _saveThemePreference(isDarkMode);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Logo with better styling
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset("assets/image.png", fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard() {
    final difference = thisWeekSolved - lastWeekSolved;
    final isPositive = difference >= 0;

    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeColors.getPrimaryColor(
                    isDarkMode,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_view_week,
                  color: AppThemeColors.getPrimaryColor(isDarkMode),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildWeekCard(
                  'This Week',
                  thisWeekSolved,
                  AppThemeColors.getPrimaryColor(isDarkMode),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeekCard(
                  'Last Week',
                  lastWeekSolved,
                  AppThemeColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  (isPositive
                          ? AppThemeColors.getEasyColor(isDarkMode)
                          : AppThemeColors.getHardColor(isDarkMode))
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive
                      ? AppThemeColors.getEasyColor(isDarkMode)
                      : AppThemeColors.getHardColor(isDarkMode),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isPositive ? '+' : ''}$difference from last week',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPositive
                        ? AppThemeColors.getEasyColor(isDarkMode)
                        : AppThemeColors.getHardColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppThemeColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            'problems',
            style: TextStyle(
              fontSize: 12,
              color: AppThemeColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard() {
    final scoreColor = consistencyScore >= 70
        ? AppThemeColors.getEasyColor(isDarkMode)
        : consistencyScore >= 40
        ? AppThemeColors.getMediumColor(isDarkMode)
        : AppThemeColors.getHardColor(isDarkMode);

    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: scoreColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Consistency Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Based on your activity in the last 30 days',
            style: TextStyle(
              fontSize: 13,
              color: AppThemeColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: consistencyScore / 100,
                      strokeWidth: 8,
                      backgroundColor: AppThemeColors.getBorderColor(
                        isDarkMode,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${consistencyScore.toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.getTextPrimaryColor(isDarkMode),
                        ),
                      ),
                      Text(
                        'consistent',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppThemeColors.getTextSecondaryColor(
                            isDarkMode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  _getConsistencyMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppThemeColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getConsistencyMessage() {
    if (consistencyScore >= 70) {
      return 'Excellent! You\'re maintaining a great coding routine.';
    } else if (consistencyScore >= 40) {
      return 'Good progress! Try to code more regularly.';
    } else {
      return 'Let\'s work on building a more consistent habit.';
    }
  }

  Widget _buildProblemsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeColors.getBorderColor(isDarkMode)),
      ),
      child: Column(
        children: [
          Text(
            "Problems Solved",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.getTextPrimaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressCircle(
                "Easy",
                easySolved,
                totaleasy,
                AppThemeColors.getEasyColor(isDarkMode),
              ),
              _buildProgressCircle(
                "Medium",
                mediumSolved,
                totalmedium,
                AppThemeColors.getMediumColor(isDarkMode),
              ),
              _buildProgressCircle(
                "Hard",
                hardSolved,
                totalhard,
                AppThemeColors.getHardColor(isDarkMode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyActivityCard() {
    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_outlined,
                size: 20,
                color: AppThemeColors.getPrimaryColor(isDarkMode),
              ),
              const SizedBox(width: 8),
              Text(
                "Monthly Activity - Last 12 Months",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Problems solved each month",
            style: TextStyle(
              fontSize: 13,
              color: AppThemeColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          monthlyData.isEmpty
              ? Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 24,
                        color: AppThemeColors.getTextSecondaryColor(isDarkMode),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No monthly data available",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppThemeColors.getTextSecondaryColor(
                            isDarkMode,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppThemeColors.getBackgroundColor(isDarkMode),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppThemeColors.getBorderColor(isDarkMode),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppThemeColors.getBorderColor(isDarkMode),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final labels = _getMonthLabels();
                              if (value.toInt() >= 0 &&
                                  value.toInt() < labels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                  ), // adjust spacing
                                  child: Text(
                                    labels[value.toInt()],
                                    style: TextStyle(
                                      color:
                                          AppThemeColors.getTextSecondaryColor(
                                            isDarkMode,
                                          ),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 35,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: AppThemeColors.getTextSecondaryColor(
                                    isDarkMode,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: AppThemeColors.getBorderColor(isDarkMode),
                          width: 1,
                        ),
                      ),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      maxY: monthlyData.isNotEmpty
                          ? monthlyData
                                    .map((e) => e.y)
                                    .reduce((a, b) => a > b ? a : b) +
                                10
                          : 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: monthlyData,
                          isCurved: true,
                          color: AppThemeColors.getPrimaryColor(isDarkMode),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppThemeColors.getPrimaryColor(
                                  isDarkMode,
                                ),
                                strokeWidth: 2,
                                strokeColor: AppThemeColors.getSurfaceColor(
                                  isDarkMode,
                                ),
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppThemeColors.getPrimaryColor(
                              isDarkMode,
                            ).withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final labels = _getMonthLabels();
                              final monthLabel = labels[barSpot.x.toInt()];
                              return LineTooltipItem(
                                '$monthLabel\n${barSpot.y.toInt()} problems',
                                TextStyle(
                                  color: AppThemeColors.getTextPrimaryColor(
                                    isDarkMode,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                          getTooltipColor: (touchedSpot) =>
                              AppThemeColors.getSurfaceColor(isDarkMode),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTotalSolvedCard() {
    return _buildEnhancedCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppThemeColors.getPrimaryColor(
                isDarkMode,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 24,
              color: AppThemeColors.getPrimaryColor(isDarkMode),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Problems Solved",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppThemeColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${easySolved + mediumSolved + hardSolved}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.getTextPrimaryColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCard() {
    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: AppThemeColors.getPrimaryColor(isDarkMode),
              ),
              const SizedBox(width: 8),
              Text(
                "Activity Calendar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Your coding activity over the past year",
            style: TextStyle(
              fontSize: 13,
              color: AppThemeColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          calendarData.isEmpty
              ? Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.data_usage_outlined,
                        size: 24,
                        color: AppThemeColors.getTextSecondaryColor(isDarkMode),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No activity data available",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppThemeColors.getTextSecondaryColor(
                            isDarkMode,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppThemeColors.getBackgroundColor(isDarkMode),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppThemeColors.getBorderColor(isDarkMode),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: HeatMap(
                      datasets: calendarData,
                      colorMode: ColorMode.color,
                      showColorTip: false,
                      showText: false,
                      scrollable: false,
                      size: 12,
                      fontSize: 8,
                      defaultColor: AppThemeColors.getHeatmapDefaultColor(
                        isDarkMode,
                      ),
                      textColor: AppThemeColors.getTextPrimaryColor(isDarkMode),
                      colorsets: AppThemeColors.getHeatmapColorsets(isDarkMode),
                      margin: const EdgeInsets.all(2),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppThemeColors.getTextSecondaryColor(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            "Failed to load data",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.getTextPrimaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please check your connection and try again",
            style: TextStyle(
              fontSize: 14,
              color: AppThemeColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeColors.getPrimaryColor(isDarkMode),
              foregroundColor: AppThemeColors.getBackgroundColor(isDarkMode),
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
                hasError = false;
              });
              fetchLeetCodeStats();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

 

  int _calculateStreak() {
    if (calendarData.isEmpty) return 0;
    DateTime currentDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    int streak = 0;

    while (calendarData.containsKey(currentDate) &&
        calendarData[currentDate]! > 0) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Widget _buildProgressCircle(
    String label,
    int solved,
    int total,
    Color color,
  ) {
    double progress = total > 0 ? solved / total : 0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: colors['border']!.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              children: [
                Text(
                  "$solved",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors['textPrimary'],
                  ),
                ),
                Text(
                  "/$total",
                  style: TextStyle(
                    fontSize: 10,
                    color: colors['textSecondary'],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors['textPrimary'],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return _buildEnhancedCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: colors['textSecondary'],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors['textPrimary'],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: colors['textSecondary']),
          ),
        ],
      ),
    );
  }
}
// Widget _buildProblemsCard() {
//   return _buildEnhancedCard(
//     gradientStart: const Color(0xFF1A1D29),
//     gradientEnd: const Color(0xFF312E81),
//     borderColor: const Color(0xFF8B5CF6).withOpacity(0.3),
//     borderWidth: 1,
//     customShadows: [
//       BoxShadow(
//         color: const Color(0xFF8B5CF6).withOpacity(0.1),
//         blurRadius: 20,
//         offset: const Offset(0, 8),
//       ),
//     ],
//     child: Column(
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.quiz_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             const Text(
//               "Problems Solved",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 32),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildColorfulProgressCircle(
//               "Easy",
//               easySolved,
//               totaleasy,
//               const Color(0xFF10B981),
//               const Color(0xFF059669),
//             ),
//             _buildColorfulProgressCircle(
//               "Medium",
//               mediumSolved,
//               totalmedium,
//               const Color(0xFFF59E0B),
//               const Color(0xFFD97706),
//             ),
//             _buildColorfulProgressCircle(
//               "Hard",
//               hardSolved,
//               totalhard,
//               const Color(0xFFEF4444),
//               const Color(0xFFDC2626),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
Widget _buildColorfulProgressCircle(
  String label,
  int solved,
  int total,
  Color primaryColor,
  Color secondaryColor,
) {
  double progress = total > 0 ? solved / total : 0;
  
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1A1D29),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$solved",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "/$total",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.2), secondaryColor.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ),
    ],
  );
}

class TargetStatCard extends StatefulWidget {
  final int currentProgress;
  final int target;
  final Map<String, Color> colors;

  const TargetStatCard({
    super.key,
    required this.currentProgress,
    required this.target,
    required this.colors,
  });

  @override
  State<TargetStatCard> createState() => _TargetStatCardState();
}

class _TargetStatCardState extends State<TargetStatCard> {
  late int _target;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _target = widget.target;
    _controller = TextEditingController(text: _target.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.currentProgress / (_target == 0 ? 1 : _target);
    progress = progress.clamp(0, 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.colors['surface'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.colors['border']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Target",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.colors['textPrimary'],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: widget.colors['textPrimary'],
                  size: 20,
                ),
                onPressed: () => _showTargetDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: widget.colors['border'],
            color: widget.colors['primary'],
          ),
          const SizedBox(height: 12),

          // Progress text
          Text(
            "${widget.currentProgress} / $_target completed",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.colors['textPrimary'],
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(
          context,
        ).copyWith(dialogBackgroundColor: widget.colors['surface']),
        child: AlertDialog(
          backgroundColor: widget.colors['surface'],
          title: Text(
            "Set Monthly Target",
            style: TextStyle(color: widget.colors['textPrimary']),
          ),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: widget.colors['textPrimary']),
            decoration: InputDecoration(
              hintText: "Enter target",
              hintStyle: TextStyle(color: widget.colors['textSecondary']),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['primary']!),
              ),
              filled: true,
              fillColor: widget.colors['background'],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: widget.colors['textSecondary'],
              ),
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colors['primary'],
                foregroundColor: widget.colors['background'],
              ),
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  _target = int.tryParse(_controller.text) ?? _target;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEnhancedCard({
  required Widget child,
  Color? gradientStart,
  Color? gradientEnd,
  Color? borderColor,
  double borderWidth = 0,
  List<BoxShadow>? customShadows,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: gradientStart != null && gradientEnd != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradientStart, gradientEnd],
            )
          : null,
      color: gradientStart == null ? const Color(0xFF1A1D29) : null,
      borderRadius: BorderRadius.circular(16),
      border: borderWidth > 0 && borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: customShadows ?? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
