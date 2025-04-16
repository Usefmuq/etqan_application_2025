import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_header.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        bottom: widget.showExpandableBar
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: widget.expandableBarContent ?? const SizedBox(),
                  secondChild: const SizedBox(height: 0),
                ),
              )
            : null,
      ),
      drawer: widget.showDrawer
          ? Drawer(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        ..._defaultDrawerItems(),
                        if (widget.extraDrawerItems != null)
                          ...widget.extraDrawerItems!,
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeader(
              title: widget.title,
              subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
              leading: widget.titleIcon,
              actions: widget.tilteActions,
            ),
            if (widget.body != null) ...widget.body!,
          ],
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  List<Widget> _defaultActions() {
    return [
      IconButton(
        icon: const Icon(Icons.home),
        tooltip: 'Home',
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

  List<Widget> _defaultDrawerItems() {
    final user = (context.read<AppUserCubit>().state as AppUserSignedIn).user;

    return [
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
        leading: Icon(Icons.home),
        title: Text('Home'),
        onTap: () {
          context.go('/');
        },
      ),
      ListTile(
        leading: Icon(Icons.add),
        title: Text('Blogs'),
        onTap: () {
          context.push('/blogs');
        },
      ),
      ListTile(
        leading: Icon(Icons.add),
        title: Text('Onboardings'),
        onTap: () {
          context.push('/onboardings');
        },
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        onTap: () {
          context.push('/settings'); // Make sure this route exists
        },
      ),
      const Divider(),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('Logout'),
        onTap: () async {
          logout(context);
        },
      ),
    ];
  }
}

void logout(BuildContext context) async {
  await Supabase.instance.client.auth.signOut();

  // Optional: Navigate to login or splash screen
  if (context.mounted) {
    context.go('/'); // or context.pushReplacementNamed('login')
  }
}
