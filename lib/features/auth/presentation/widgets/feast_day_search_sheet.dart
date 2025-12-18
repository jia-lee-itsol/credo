import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../profile/data/providers/saint_feast_day_providers.dart';

/// 축일 검색 시트 위젯
class FeastDaySearchSheet extends ConsumerStatefulWidget {
  final Color primaryColor;
  final String? selectedFeastDayId;
  final String? customBaptismalName;
  final int? customFeastMonth;
  final int? customFeastDay;
  final void Function(SaintFeastDayModel saint) onFeastDaySelected;
  final void Function(String baptismalName, int month, int day) onCustomInput;

  const FeastDaySearchSheet({
    super.key,
    required this.primaryColor,
    this.selectedFeastDayId,
    this.customBaptismalName,
    this.customFeastMonth,
    this.customFeastDay,
    required this.onFeastDaySelected,
    required this.onCustomInput,
  });

  @override
  ConsumerState<FeastDaySearchSheet> createState() => _FeastDaySearchSheetState();
}

class _FeastDaySearchSheetState extends ConsumerState<FeastDaySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final allSaintsAsync = ref.watch(_allSaintsProvider);

    return Column(
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        // 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.auth.selectFeastDayTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.search.saintSearchHint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const SizedBox(height: 16),

        // 성인 목록
        Expanded(
          child: allSaintsAsync.when(
            data: (allSaints) {
              // 검색 필터링
              final filteredSaints = _searchQuery.isEmpty
                  ? allSaints
                  : allSaints.where((saint) {
                      final name = saint.name.toLowerCase();
                      final nameEn = saint.nameEn?.toLowerCase() ?? '';
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || nameEn.contains(query);
                    }).toList();

              if (filteredSaints.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.search.noResults,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final isCustomSelected =
                  widget.customBaptismalName != null &&
                  widget.customFeastMonth != null &&
                  widget.customFeastDay != null;

              return ListView(
                children: [
                  // 기타 옵션
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: widget.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.edit,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'その他（直接入力）',
                      style: TextStyle(
                        fontWeight: isCustomSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: isCustomSelected
                        ? Text(
                            '${widget.customBaptismalName} (${widget.customFeastMonth}${l10n.profile.month}${widget.customFeastDay}${l10n.profile.day})',
                            style: theme.textTheme.bodySmall,
                          )
                        : Text(l10n.profile.directInputTitle),
                    trailing: isCustomSelected
                        ? Icon(Icons.check, color: widget.primaryColor)
                        : Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                    onTap: () => _showCustomInputDialog(context, theme),
                  ),
                  const Divider(),
                  // 성인 목록
                  ...filteredSaints.map((saint) {
                    final feastDayId = '${saint.month}-${saint.day}';
                    final isSelected = widget.selectedFeastDayId == feastDayId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: widget.primaryColor.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.celebration,
                          color: widget.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        saint.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${saint.month}${l10n.profile.month}${saint.day}${l10n.profile.day}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: widget.primaryColor)
                          : null,
                      onTap: () => widget.onFeastDaySelected(saint),
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) {
              final l10n = ref.read(appLocalizationsSyncProvider);
              return Center(child: Text('${l10n.common.error}: $error'));
            },
          ),
        ),
      ],
    );
  }

  void _showCustomInputDialog(BuildContext context, ThemeData theme) {
    final baptismalNameController = TextEditingController(
      text: widget.customBaptismalName ?? '',
    );
    final monthController = TextEditingController(
      text: widget.customFeastMonth?.toString() ?? '',
    );
    final dayController = TextEditingController(
      text: widget.customFeastDay?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(dialogL10n.profile.directInputDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baptismalNameController,
                  decoration: InputDecoration(
                    labelText: dialogL10n.auth.baptismName,
                    hintText: dialogL10n.auth.baptismNameHint,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: monthController,
                        decoration: InputDecoration(
                          labelText: dialogL10n.profile.month,
                          hintText: '1-12',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: dayController,
                        decoration: InputDecoration(
                          labelText: dialogL10n.profile.day,
                          hintText: '1-31',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogL10n.common.cancel),
            ),
            TextButton(
              onPressed: () {
                final baptismalName = baptismalNameController.text.trim();
                final monthStr = monthController.text.trim();
                final dayStr = dayController.text.trim();

                if (baptismalName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dialogL10n.validation.baptismNameRequired),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final month = int.tryParse(monthStr);
                final day = int.tryParse(dayStr);

                if (month == null || month < 1 || month > 12) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dialogL10n.validation.monthInvalid),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (day == null || day < 1 || day > 31) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dialogL10n.validation.dayInvalid),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                widget.onCustomInput(baptismalName, month, day);
                Navigator.pop(dialogContext);
              },
              child: Text(dialogL10n.common.save),
            ),
          ],
        );
      },
    );
  }
}

/// 모든 성인 목록 Provider
final _allSaintsProvider = FutureProvider<List<SaintFeastDayModel>>((ref) async {
  final repository = ref.read(saintFeastDayRepositoryProvider);
  final result = await repository.loadSaintsFeastDays();
  return result.fold(
    (_) => <SaintFeastDayModel>[],
    (saints) => saints
        .map(
          (saint) => SaintFeastDayModel(
            month: saint.month,
            day: saint.day,
            name: saint.name,
            nameEn: saint.nameEnglish,
            type: saint.type,
            isJapanese: saint.isJapanese,
            greeting: saint.greeting,
            description: saint.description,
          ),
        )
        .toList(),
  );
});

