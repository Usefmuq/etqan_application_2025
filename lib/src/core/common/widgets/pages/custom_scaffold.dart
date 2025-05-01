import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? titleIcon;
  final List<Widget>? tilteActions;
  final List<Widget>? body;
  final List<Tab>? tabs;
  final TabController? tabController;
  final List<List<Widget>>? bodyPerTab;
  final List<Widget>? extraActions;
  final List<Widget>? extraDrawerItems;
  final Widget? floatingActionButton;
  final bool showExpandableBar;
  final bool showDrawer;
  final Widget? expandableBarContent;

  const CustomScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.titleIcon,
    this.tilteActions,
    this.body,
    this.tabs,
    this.tabController,
    this.bodyPerTab,
    this.extraActions,
    this.extraDrawerItems,
    this.floatingActionButton,
    this.showExpandableBar = false,
    this.showDrawer = true,
    this.expandableBarContent,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabs?.length ?? 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Etqan'),
          leading: ModalRoute.of(context)?.canPop == true && !widget.showDrawer
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          actions: [
            ..._defaultActions(),
            if (widget.extraActions != null) ...widget.extraActions!,
          ],
          bottom: (widget.tabs != null && widget.tabController != null)
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Colors.white, // 👈 New background color
                    child: TabBar(
                      controller: widget.tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: widget.tabs!,
                    ),
                  ),
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
        drawer: widget.showDrawer ? _buildDrawer(context) : null,
        body: (widget.tabs != null && widget.tabController != null)
            ? TabBarView(
                controller: widget.tabController,
                children: List.generate(
                  widget.tabs!.length,
                  (index) => SingleChildScrollView(
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
                        if (widget.bodyPerTab != null &&
                            widget.bodyPerTab!.length > index)
                          ...widget.bodyPerTab![index],
                      ],
                    ),
                  ),
                ),
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
      return SizedBox();
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
                ),
              ),
              accountName: Text(
                "${user.firstNameEn} ${user.lastNameEn}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.whiteColor),
              ),
              accountEmail: Text(
                user.email,
                style:
                    const TextStyle(fontSize: 14, color: AppPallete.whiteColor),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppPallete.whiteColor,
                child: Text(
                  "${user.firstNameEn.isNotEmpty ? user.firstNameEn[0] : ''}${user.lastNameEn.isNotEmpty ? user.lastNameEn[0] : ''}",
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
            if (widget.extraDrawerItems != null) ...widget.extraDrawerItems!,
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
