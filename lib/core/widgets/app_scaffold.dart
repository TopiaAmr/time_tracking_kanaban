import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/widgets/responsive.dart';
import 'package:time_tracking_kanaban/core/widgets/sidebar.dart';

/// Main app scaffold with responsive sidebar and content area.
///
/// On mobile: Uses drawer for navigation
/// On desktop: Uses persistent sidebar
class AppScaffold extends StatelessWidget {
  /// Current route path for sidebar highlighting.
  final String currentPath;

  /// Main content widget.
  final Widget body;

  /// Optional header widget.
  final Widget? header;

  /// Optional right sidebar widget (e.g., filters).
  final Widget? rightSidebar;

  /// Whether right sidebar is open.
  final bool rightSidebarOpen;

  /// Callback to toggle right sidebar.
  final VoidCallback? onToggleRightSidebar;

  const AppScaffold({
    super.key,
    required this.currentPath,
    required this.body,
    this.header,
    this.rightSidebar,
    this.rightSidebarOpen = false,
    this.onToggleRightSidebar,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    if (isMobile) {
      return Scaffold(
        drawer: Drawer(
          width: 280,
          child: Sidebar(currentPath: currentPath),
        ),
        body: _buildBody(context),
      );
    }

    // Desktop/Tablet layout
    return Scaffold(
      body: Row(
        children: [
          // Left sidebar
          Sidebar(currentPath: currentPath),
          
          // Main content
          Expanded(
            child: _buildBody(context),
          ),
          
          // Right sidebar (filters)
          if (rightSidebar != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: rightSidebarOpen ? (isTablet ? 280 : 320) : 0,
              child: rightSidebarOpen
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: rightSidebar!,
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Header
        if (header != null) header!,
        
        // Main content
        Expanded(
          child: body,
        ),
      ],
    );
  }
}

