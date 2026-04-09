import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/animated_card_wrapper.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportsPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const ReportsPage(),
      );

  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<String>? permissions;

  @override
  void initState() {
    super.initState();
    // Fetch data using Bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<AppUserCubit>().state;
      if (userState is AppUserSignedIn) {
        context.read<ReportsBloc>().add(ReportsGetAllReportssEvent());
      }
    });

    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is! AppUserSignedIn) return;
    final user = appUserState.user;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(user.id);

      if (!mounted) return;
      setState(() {
        permissions = fetchedPermissions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return CustomScaffold(
      title: AppLocalizations.of(context)!.reportsService,
      subtitle: AppLocalizations.of(context)!.reportsServiceSubtitle,
      body: [
        BlocConsumer<ReportsBloc, ReportsState>(
          listener: (context, state) {
            if (state is ReportsFailure) {
              SmartNotifier.error(
                context,
                title: AppLocalizations.of(context)!.error,
                message: state.error,
              );
            }
          },
          builder: (context, state) {
            if (state is ReportsLoading) {
              return const Loader();
            }

            if (state is ReportsShowAllSuccess) {
              final availableReports = state.reportsPage;

              if (availableReports.reportssView.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.noResults),
                );
              }
              final user =
                  (context.read<AppUserCubit>().state as AppUserSignedIn).user;

              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: availableReports.reportssView.length,
                    itemBuilder: (context, index) {
                      final report = availableReports.reportssView[index];

                      final title = locale == 'ar'
                          ? report.reportInfo.titleAr
                          : report.reportInfo.titleEn;

                      final desc = locale == 'ar'
                          ? report.reportInfo.descriptionAr
                          : report.reportInfo.descriptionEn;
                      final perm = report.reportInfo.reportKey;
                      if (isUserHasPermissionsView(
                        permissions ?? [],
                        perm,
                      )) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: AnimatedCardWrapper(
                            index: index,
                            child: _ReportDirectoryCard(
                              title: title,
                              subtitle: desc ?? '',
                              onTap: () {
                                context.push(
                                  '/reports/${report.reportInfo.id}',
                                  extra: ReportsViewerPageEntity(
                                    reportssView: report,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: AnimatedCardWrapper(
                      index: availableReports.reportssView.length,
                      child: _ReportDirectoryCard(
                        title:
                            locale == 'ar' ? 'سجل الحضور' : 'Attendance Report',
                        subtitle: locale == 'ar'
                            ? 'عرض تقارير الحضور والانصراف'
                            : 'View attendance and departure reports',
                        onTap: () {
                          context.push(
                            '/reports/attendance',
                            extra: user,
                          );
                        },
                      ),
                    ),
                  )
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _ReportDirectoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportDirectoryCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.blue.shade700,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
