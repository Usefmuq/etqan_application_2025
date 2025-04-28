import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_header.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? titleIcon;
  final List<Widget>? tilteActions;
  final List<Widget>? body;
  final List<Widget>? extraActions;
  final List<Widget>? extraDrawerItems;
  final Widget? floatingActionButton;
  final bool showExpandableBar;
  final bool showDrawer;
  final Widget? expandableBarContent;

  // 👉 new fields
  final TabController? tabController;
  final List<Tab>? tabs;

  const CustomScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.titleIcon,
    this.tilteActions,
    this.body,
    this.extraActions,
    this.extraDrawerItems,
    this.floatingActionButton,
    this.showExpandableBar = false,
    this.showDrawer = true,
    this.expandableBarContent,
    this.tabController,
    this.tabs,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabs?.length ?? 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Etqan'),
          leading: ModalRoute.of(context)?.canPop == true && !widget.showDrawer
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          actions: [
            ..._defaultActions(),
            if (widget.extraActions != null) ...widget.extraActions!,
          ],
          bottom: widget.tabs != null
              ? TabBar(
                  controller: widget.tabController,
                  tabs: widget.tabs!,
                )
              : widget.showExpandableBar
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild:
                            widget.expandableBarContent ?? const SizedBox(),
                        secondChild: const SizedBox(height: 0),
                      ),
                    )
                  : null,
        ),
        drawer: widget.showDrawer
            ? Drawer(
                child: ListView(
                  children: [
                    _buildDrawer(context),
                    if (widget.extraDrawerItems != null)
                      ...widget.extraDrawerItems!,
                  ],
                ),
              )
            : null,
        body: widget.tabs != null && widget.tabController != null
            ? TabBarView(
                controller: widget.tabController,
                children: widget.body ?? [],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomHeader(
                      title: widget.title,
                      subtitle: widget.subtitle != null
                          ? Text(widget.subtitle!)
                          : null,
                      leading: widget.titleIcon,
                      actions: widget.tilteActions,
                    ),
                    if (widget.body != null) ...widget.body!,
                  ],
                ),
              ),
        floatingActionButton: widget.floatingActionButton,
      ),
    );
  }

  List<Widget> _defaultActions() {
    return [
      IconButton(
        icon: const Icon(Icons.home),
        tooltip: AppLocalizations.of(context)!.homePage,
        onPressed: () {
          context.go('/');
        },
      ),
      if (widget.showExpandableBar)
        IconButton(
          icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          tooltip: _isExpanded ? 'Collapse' : 'Expand',
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    final state = context.read<AppUserCubit>().state;
    if (state is! AppUserSignedIn) {
      return const SizedBox();
    } else {
      final user = state.user;
      return Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppPallete.gradient1,
                    AppPallete.gradient2,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                "${user.firstNameEn} ${user.lastNameEn}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.whiteColor,
                ),
              ),
              accountEmail: Text(
                user.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppPallete.whiteColor,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundColor: AppPallete.whiteColor,
                child: Text(
                  "${user.firstNameEn.isNotEmpty ? user.firstNameEn[0].toUpperCase() : ''}${user.lastNameEn.isNotEmpty ? user.lastNameEn[0].toUpperCase() : ''}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.gradient1,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(AppLocalizations.of(context)!.homePage),
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(AppLocalizations.of(context)!.blogsService),
              onTap: () {
                context.push('/blogs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(AppLocalizations.of(context)!.onboardingsService),
              onTap: () {
                context.push('/onboardings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.settings),
              onTap: () {
                context.push('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
          ],
        ),
      );
    }
  }
}
