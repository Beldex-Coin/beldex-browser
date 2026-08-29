import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/folder_tab_system.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:uuid/uuid.dart';










class ItemModel {
  final String id;
  final String title;

  ItemModel({
    required this.id,
    required this.title,
  });
}





class GroupModel {

  final String id;

 String name;

   Color color;

   bool isClosed;

  final List<WebViewModel> tabs;

    /// True = automatically created by domain grouping.
  /// False = created by the user.
  bool isAutoGroup;

  /// Domain used for automatic grouping.
  String? domain;

  GroupModel( {
    required this.id,
    required this.tabs,
    required this.name, required this.color,this.isClosed = false,
    this.isAutoGroup = false,
    this.domain,
  });
}

// For search tabs

class TabSearchResult {

  final WebViewModel? tab;
  final GroupModel? group;

  bool get isGroup => group != null;

  TabSearchResult.tab(this.tab)
      : group = null;

  TabSearchResult.group(this.group)
      : tab = null;
}



enum ViewMode {
  all,
  groupsOnly,
}

class GroupProvider extends ChangeNotifier {

  BrowserModel? browserProvider;

  //GroupProvider(this.browserProvider);

  ViewMode currentMode = ViewMode.all;


  bool selectionMode = false;

  bool _groupNameEditMode = false;

  bool get groupNameEditMode => _groupNameEditMode; 

 List<WebViewModel>
    selectedTabs = [];

  List<GroupModel> groups = [];

 List<WebViewModel> get outsideTabs {

  if (browserProvider == null) {
    return [];
  }

  /// ALL GROUPED TAB IDS
  final groupedIds = groups

      .expand((g) => g.tabs)

      .map((e) => e.uuid)

      .toSet();

  return browserProvider!
      .webViewTabs

      .map((e) => e.webViewModel)

      /// HIDE ALL GROUPED TABS
      .where(
        (e) =>
            !groupedIds.contains(
          e.uuid,
        ),
      )

      .toList();
}

//   List<WebViewModel> get outsideTabs {

//      if (browserProvider == null) {
//     return [];
//   }

//   final groupedIds = groups
//       .expand((g) => g.tabs)
//       .map((e) => e.hashCode)
//       .toSet();

//   return browserProvider!.webViewTabs
//       .map((e) => e.webViewModel)
//       .where(
//         (e) =>
//             !groupedIds.contains(
//           e.hashCode,
//         ),
//       )
//       .toList();
// }


int get totalOpenTabsCount {
  if (browserProvider == null) {
    return 0;
  }

  // Tab IDs from closed groups
  final closedGroupTabIds = groups
      .where((group) => group.isClosed)
      .expand((group) => group.tabs)
      .map((tab) => tab.uuid)
      .toSet();

  return browserProvider!.webViewTabs
      .map((tab) => tab.webViewModel)
      .where(
        (tab) => !closedGroupTabIds.contains(tab.uuid),
      )
      .length;
}





  void changeViewMode(ViewMode mode) {
    currentMode = mode;
    notifyListeners();
  }

  List<Widget> getHomeWidgets() {

    if (currentMode ==
        ViewMode.groupsOnly) {

      return groups.map((e) {
        return GroupWidget(group: e);
      }).toList();
    }

    return [

  ...outsideTabs.map((e) {
    return ItemWidget(tab: e);
  }),

  ...groups.where((e) => !e.isClosed).map((e) {
    return GroupWidget(group: e);
  }),
];
  }


/// AUTO GROUPING ////


String? getDomain(WebViewModel tab) {
  final urlString = tab.url?.toString();

  if (urlString == null || urlString.isEmpty) {
    return null;
  }

  try {
    final uri = Uri.tryParse(urlString);

    if (uri == null) {
      return null;
    }

    final host = uri.host.toLowerCase().trim();

    if (host.isEmpty) {
      return null;
    }

    // Remove www.
    if (host.startsWith('www.')) {
      return host.substring(4);
    }

    return host;
  } catch (_) {
    return null;
  }
}


GroupModel? getManualGroupForTab(WebViewModel tab) {
  for (final group in groups) {
    if (!group.isAutoGroup &&
        group.tabs.any((e) => e.uuid == tab.uuid)) {
      return group;
    }
  }

  return null;
}


void autoGroupAllTabs() {
  if (browserProvider == null) {
    return;
  }

  final allTabs = browserProvider!.webViewTabs
      .map((e) => e.webViewModel)
      .toList();

  // ------------------------------------------------------------
  // Tabs belonging to MANUAL groups.
  // These are never controlled by auto grouping.
  // ------------------------------------------------------------

  final manualTabIds = groups
      .where((group) => !group.isAutoGroup)
      .expand((group) => group.tabs)
      .map((tab) => tab.uuid)
      .toSet();

  // ------------------------------------------------------------
  // CLOSED AUTO GROUP TAB IDS
  //
  // These tabs are already inside closed auto groups.
  // Do NOT move them around.
  // ------------------------------------------------------------

  final closedAutoTabIds = groups
      .where(
        (group) =>
            group.isAutoGroup &&
            group.isClosed,
      )
      .expand((group) => group.tabs)
      .map((tab) => tab.uuid)
      .toSet();

  // ------------------------------------------------------------
  // Build domain -> OPEN/UNGROUPED tabs
  //
  // IMPORTANT:
  // Closed-group tabs are excluded.
  // ------------------------------------------------------------

  final Map<String, List<WebViewModel>> domainTabs = {};

  for (final tab in allTabs) {
    // Manual group tab
    if (manualTabIds.contains(tab.uuid)) {
      continue;
    }

    // Existing closed auto-group tab
    if (closedAutoTabIds.contains(tab.uuid)) {
      continue;
    }

    final domain = getDomain(tab);

    if (domain == null || domain.isEmpty) {
      continue;
    }

    domainTabs.putIfAbsent(
      domain,
      () => [],
    );

    domainTabs[domain]!.add(tab);
  }

  // ------------------------------------------------------------
  // UPDATE ONLY OPEN AUTO GROUPS
  // ------------------------------------------------------------

  for (final group in groups) {
    if (!group.isAutoGroup) {
      continue;
    }

    // VERY IMPORTANT:
    // Never touch a closed auto group.
    if (group.isClosed) {
      continue;
    }

    final domain = group.domain;

    if (domain == null || domain.isEmpty) {
      continue;
    }

    final matchingTabs =
        domainTabs[domain] ?? [];

    group.tabs
      ..clear()
      ..addAll(matchingTabs);
  }

  // ------------------------------------------------------------
  // Remove EMPTY OPEN auto groups.
  //
  // Closed auto groups are NEVER removed here.
  // ------------------------------------------------------------

  groups.removeWhere(
    (group) =>
        group.isAutoGroup &&
        !group.isClosed &&
        group.tabs.isEmpty,
  );

  // ------------------------------------------------------------
  // CREATE NEW AUTO GROUPS
  //
  // Only when 2+ OPEN tabs have the same domain.
  // ------------------------------------------------------------

  for (final entry in domainTabs.entries) {
    final domain = entry.key;
    final tabs = entry.value;

    if (tabs.length < 2) {
      continue;
    }

    // Check only OPEN auto groups.
    final existingOpenGroup = groups.any(
      (group) =>
          group.isAutoGroup &&
          !group.isClosed &&
          group.domain == domain,
    );

    if (existingOpenGroup) {
      continue;
    }

    // IMPORTANT:
    // If a CLOSED auto group already exists for this domain,
    // DON'T add these new tabs to that closed group.
    //
    // Create a NEW open auto group instead.
    final newGroup = GroupModel(
      id: 'auto_${domain}_${DateTime.now().microsecondsSinceEpoch}',
      name: domain,
      domain: domain,
      isAutoGroup: true,
      isClosed: false,
      color: const Color(0xff6C63FF),
      tabs: List<WebViewModel>.from(tabs),
    );

    groups.add(newGroup);
  }

  notifyListeners();
}


void autoGroupTab(
  WebViewModel tab, {
  bool notify = true,
}) {
  if (browserProvider == null) {
    return;
  }

  // Manual group always wins.
  if (getManualGroupForTab(tab) != null) {
    return;
  }

  final domain = getDomain(tab);

  if (domain == null || domain.isEmpty) {
    return;
  }

  // Find existing auto group.
  GroupModel? existingGroup;

  for (final group in groups) {
    if (group.isAutoGroup &&
        group.domain == domain) {
      existingGroup = group;
      break;
    }
  }

  // If there is an existing CLOSED auto group,
  // don't automatically reopen it.
  if (existingGroup != null &&
      existingGroup.isClosed) {
    return;
  }

  // Recalculate automatic grouping.
  autoGroupAllTabs();
}



Future<WebViewModel?> createNewAutoGroupedTab() async {
  if (browserProvider == null) {
    return null;
  }

  final settings = browserProvider!.getSettings();

  browserProvider!.addTab(
    WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
        uuid: Uuid().v4(),
        url: WebUri(
          settings.searchEngine.url,
        ),
      ),
    ),
  );

  final newTab =
      browserProvider!
          .webViewTabs
          .last
          .webViewModel;

  autoGroupTab(newTab);

  return newTab;
}


///////////////////////////////



 void createGroup({
  required String name,
  required Color color,
  required WebViewModel first,
  required WebViewModel second,
}) {
  /// Remove selected tabs from AUTO groups.
  for (final group in groups) {
    if (!group.isAutoGroup) {
      continue;
    }

    group.tabs.removeWhere(
      (tab) =>
          tab.uuid == first.uuid ||
          tab.uuid == second.uuid,
    );
  }

  /// Remove empty auto groups.
  groups.removeWhere(
    (group) =>
        group.isAutoGroup &&
        group.tabs.isEmpty,
  );

  /// Don't allow tabs already inside a USER group.
  final alreadyInManualGroup = groups.any(
    (group) =>
        !group.isAutoGroup &&
        group.tabs.any(
          (tab) =>
              tab.uuid == first.uuid ||
              tab.uuid == second.uuid,
        ),
  );

  if (alreadyInManualGroup) {
    return;
  }

  final group = GroupModel(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: name,
    color: color,
    isClosed: false,

    // User-created group
    isAutoGroup: false,

    domain: null,

    tabs: [
      first,
      second,
    ],
  );

  groups.add(group);

  notifyListeners();
}


// void closeGroup(
//   GroupModel group,
// ) {

//   group.isClosed = true;

//   notifyListeners();
// }


void closeGroup(
  GroupModel group, {
  bool closeTabsIfNoOtherTabs = true,
}) {
  if (browserProvider == null) {
    return;
  }

  final browser = browserProvider!;

  final currentTab = browser.getCurrentTab();

  final currentTabId =
      currentTab?.webViewModel.uuid;

  final groupContainsCurrentTab =
      currentTabId != null &&
      group.tabs.any(
        (tab) =>
            tab.uuid == currentTabId,
      );

  if (groupContainsCurrentTab) {
    final groupTabIds = group.tabs
        .map((tab) => tab.uuid)
        .toSet();

    final otherTabIndex =
        browser.webViewTabs.indexWhere(
      (tab) =>
          !groupTabIds.contains(
        tab.webViewModel.uuid,
      ),
    );

    if (otherTabIndex != -1) {
      browser.showTab(otherTabIndex);
    } else if (closeTabsIfNoOtherTabs) {
      while (browser.webViewTabs.isNotEmpty) {
        final index =
            browser.webViewTabs.indexWhere(
          (tab) =>
              groupTabIds.contains(
            tab.webViewModel.uuid,
          ),
        );

        if (index == -1) {
          break;
        }

        browser.closeTab(index);
      }
    }
  }

  // IMPORTANT
  // Do not remove the group.
  // Do not remove its tabs.

  group.isClosed = true;

  notifyListeners();
}


void reOpenCloseGroup(
  GroupModel group,
) {

  group.isClosed = false;
  changeViewMode(ViewMode.all);
  notifyListeners();
}

void editGroup({
  required GroupModel group,
  required String name,
  required Color color,
}) {

  group.name = name;
  group.color = color;

  notifyListeners();
}



void editGroupColor({
  required GroupModel group,
  required Color color,
}) {

  group.color = color;

  notifyListeners();
}


void enableGroupNameEditMode(){
  _groupNameEditMode = true;
  notifyListeners();
}

void disableGroupNameEditMode(){
  _groupNameEditMode = false;
  notifyListeners();
}

void editGroupname({
  required GroupModel group,
  required String name,
}) {

  group.name = name;

  notifyListeners();
}


// Ungroup all tabs
void ungroupAllTabs(
  GroupModel group,
) {
  final tabs = List<WebViewModel>.from(
    group.tabs,
  );

  groups.removeWhere(
    (e) => e.id == group.id,
  );

  /// Return tabs to automatic grouping
  if (!group.isAutoGroup) {
    for (final tab in tabs) {
      autoGroupTab(tab);
    }
  }

  notifyListeners();
}

void ungroupSelectedTabs() {
  final selectedIds =
      selectedTabs.map((e) => e.uuid).toSet();

  for (final group in groups) {
    print("UNGROUP Before: ${group.tabs.length}");
    group.tabs.removeWhere(
      (tab) => selectedIds.contains(tab.uuid),
    );
    print("UNGROUP After: ${group.tabs.length}");
  }

  groups.removeWhere(
    (group) => group.tabs.isEmpty,
  );

disableSelectionMode();
  // selectedTabs.clear();
  // selectionMode = false;

  notifyListeners();
}
// void ungroupSelectedTabs(GroupModel group) {

//   // if (selectedTabs.isEmpty) {
//   //   return;
//   // }

//   for (final tab in selectedTabs) {

//     for (final group in groups) {

//       group.tabs.removeWhere(
//         (e) => e.uuid == tab.uuid,
//       );
//     }
//   }

//   /// Remove empty groups
//   groups.removeWhere(
//     (group) => group.tabs.isEmpty,
//   );

//   selectedTabs.clear();

//   selectionMode = false;

//   notifyListeners();
// }

void deleteGroup(
  GroupModel group,
) {

  groups.removeWhere(
    (e) => e.id == group.id,
  );

  notifyListeners();
}



Future<void> deleteGroupAndTabs(
  BuildContext context,
  GroupModel group,
) async {

  if (browserProvider == null) {
    return;
  }

  final browser =
      browserProvider!;

  final tabsToDelete =
      List<WebViewModel>.from(
    group.tabs,
  );

  /// REMOVE GROUP FIRST
  groups.removeWhere(
    (e) => e.id == group.id,
  );

  notifyListeners();

  /// CLOSE DIALOG
  //Navigator.pop(context);

  await Future.delayed(
    const Duration(milliseconds: 300),
  );

  /// FIND SAFE TAB
  final remainingTabs =
      browser.webViewTabs
          .map((e) => e.webViewModel)
          .where(
            (e) => !tabsToDelete.any(
              (d) => d.uuid == e.uuid,
            ),
          )
          .toList();

  /// OPEN SAFE TAB
  // if (remainingTabs.isNotEmpty) {

  //   final safeIndex =
  //       browser.webViewTabs.indexWhere(
  //     (e) =>
  //         e.webViewModel.uuid ==
  //         remainingTabs.first.uuid,
  //   );

  //   if (safeIndex != -1) {

  //     browser.showTab(safeIndex);

  //     browser.showTabScroller =
  //         false;

  //     await Future.delayed(
  //       const Duration(
  //         milliseconds: 300,
  //       ),
  //     );
  //   }
  // }

  /// DELETE TABS ONE BY ONE SAFELY
  for (final tab in tabsToDelete) {

    final index =
        browser.webViewTabs.indexWhere(
      (e) =>
          e.webViewModel.uuid ==
          tab.uuid,
    );

    if (index == -1) continue;

    try {

      /// SMALL GAP BETWEEN DISPOSALS
      await Future.delayed(
        const Duration(
          milliseconds: 120,
        ),
      );

      browser.closeTab(index);

    } catch (e) {

      debugPrint(
        "Tab delete error: $e",
      );
    }
  }
}






//////////Highlight the current tabs


bool isCurrentTab(WebViewModel tab) {

  if (browserProvider == null) {
    return false;
  }

  final currentTab =
      browserProvider!.getCurrentTab();

  if (currentTab == null) {
    return false;
  }

  return currentTab.webViewModel.uuid ==
      tab.uuid;
}

bool groupContainsCurrentTab(
  GroupModel group,
) {

  if (browserProvider == null) {
    return false;
  }

  final currentTab =
      browserProvider!.getCurrentTab();

  if (currentTab == null) {
    return false;
  }

  return group.tabs.any(
    (tab) =>
        tab.uuid ==
        currentTab.webViewModel.uuid,
  );
}



void mergeGroups({
  required GroupModel sourceGroup,
  required GroupModel targetGroup,
}) {

  /// Prevent self merge
  if (sourceGroup.id == targetGroup.id) {
    return;
  }

  /// Add tabs from source into target
  for (final tab in sourceGroup.tabs) {

    final exists = targetGroup.tabs.any(
      (e) => e.uuid == tab.uuid,
    );

    if (!exists) {
      targetGroup.tabs.add(tab);
    }
  }

  /// Remove source group
  groups.removeWhere(
    (g) => g.id == sourceGroup.id,
  );

  notifyListeners();
}



//////////////////////////////

// void openTab(
//   BuildContext context,
//   GroupModel? group,
//   WebViewModel tab,
// ) {

//   if (browserProvider == null) {
//     return;
//   }

//   final webViewTab =
//       browserProvider!.tabGroups
//           .expand((g) => g.tabs)
//           .firstWhere(
//             (t) =>
//                 t.webViewModel.uuid ==
//                 tab.uuid,
//           );

//   final browserGroup =
//       browserProvider!.tabGroups
//           .firstWhere(
//             (g) =>
//                 g.tabs.contains(
//                   webViewTab,
//                 ),
//           );

//   Navigator.pop(context);

//   Future.delayed(
//     const Duration(milliseconds: 120),
//     () {

//       browserProvider!
//           .openGroupedTab(
//         webViewTab,
//         browserGroup,
//       );

//       browserProvider!
//           .showTabScroller = false;
//     },
//   );
// }



void openTab(
  BuildContext context,
  WebViewModel tab,
) {

  if (browserProvider == null) {
    return;
  }

  final index =
      browserProvider!.webViewTabs.indexWhere(
    (e) => e.webViewModel.uuid == tab.uuid,
  );

  if (index != -1) {

    browserProvider!.showTab(index);

    Navigator.pop(context);
  }
}

 void addToGroup(
  WebViewModel tab,
  GroupModel group,
) {
  /// Remove tab from AUTO groups
  for (final existingGroup in groups) {
    if (!existingGroup.isAutoGroup) {
      continue;
    }

    existingGroup.tabs.removeWhere(
      (existingTab) =>
          existingTab.uuid == tab.uuid,
    );
  }

  /// Remove empty auto groups
  groups.removeWhere(
    (existingGroup) =>
        existingGroup.isAutoGroup &&
        existingGroup.tabs.isEmpty,
  );

  /// Add to selected group
  final exists = group.tabs.any(
    (e) => e.uuid == tab.uuid,
  );

  if (!exists) {
    group.tabs.add(tab);
  }

  notifyListeners();
}


void removeFromGroup(
  WebViewModel tab,
  GroupModel group,
) {
  group.tabs.removeWhere(
    (e) => e.uuid == tab.uuid,
  );

  if (group.tabs.isEmpty) {
    groups.remove(group);
  }

  /// If this was a manual group,
  /// return the tab to automatic domain grouping.
  if (!group.isAutoGroup) {
    autoGroupTab(tab);
    return;
  }

  notifyListeners();
}


Future<void> addNewTabToGroup(
  GroupModel group,
) async {

  if (browserProvider == null) {
    return;
  }
 var settings = browserProvider!.getSettings();
  browserProvider!.addTab(WebViewTab(
                    key: GlobalKey(),
                    webViewModel: WebViewModel(uuid: Uuid().v4(),url: WebUri(settings.searchEngine.url)),
                  ));

  /// GET CREATED TAB
  final newTab =
      browserProvider!
          .webViewTabs
          .last
          .webViewModel;

  /// ADD TO GROUP
  group.tabs.add(newTab);

  notifyListeners();
}

Future<void> createEmptyGroup({
  required String name,
  required Color color,
}) async {

  if (browserProvider == null) {
    return;
  }
  var settings = browserProvider!.getSettings();
  browserProvider!.addTab(WebViewTab(
                    key: GlobalKey(),
                    webViewModel: WebViewModel(uuid: Uuid().v4(),url: WebUri(settings.searchEngine.url)),
                  ));

  // await browserProvider!.addTab(
  //   webViewModel: WebViewModel(
  //     uuid: DateTime.now()
  //         .microsecondsSinceEpoch
  //         .toString(),
  //   ),
  // );

  final newTab =
      browserProvider!
          .webViewTabs
          .last
          .webViewModel;

  final group = GroupModel(
    id: DateTime.now().toString(),
    name: name,
    color: color,
    isClosed: false,
    tabs: [newTab],
  );

  groups.add(group);

  notifyListeners();
}





///// Working with tab selection 
///
void enableSelectionMode() {

  selectionMode = true;

  selectedTabs.clear();

  notifyListeners();
}

void disableSelectionMode() {

  selectionMode = false;

  selectedTabs.clear();

  notifyListeners();
}


void toggleTabSelection(
  WebViewModel tab,
) {

  final exists =
      selectedTabs.any(
    (e) => e.uuid == tab.uuid,
  );

  if (exists) {

    selectedTabs.removeWhere(
      (e) => e.uuid == tab.uuid,
    );

  } else {

    selectedTabs.add(tab);
  }

  notifyListeners();
}


bool isSelected(
  WebViewModel tab,
) {

  return selectedTabs.any(
    (e) => e.uuid == tab.uuid,
  );
}


bool get allTabsSelected {

  if (browserProvider == null) {
    return false;
  }

  return selectedTabs.length ==
      browserProvider!
          .webViewTabs
          .length;
}

void toggleSelectAllTabs() {

  if (browserProvider == null) {
    return;
  }

  /// DESELECT ALL
  if (allTabsSelected) {

    selectedTabs.clear();
  }

  /// SELECT ALL
  else {

    selectedTabs.clear();

    selectedTabs.addAll(

      browserProvider!
          .webViewTabs
          .map((e) => e.webViewModel),
    );
  }

  notifyListeners();
}


void selectAllTabs() {

  if (browserProvider == null) {
    return;
  }

  selectedTabs.clear();

  selectedTabs.addAll(

    browserProvider!
        .webViewTabs
        .map((e) => e.webViewModel),
  );

  notifyListeners();
}

Future<void> closeSelectedTabs(
  BuildContext context,
) async {

  if (browserProvider == null) {
    return;
  }

  final browser =
      browserProvider!;

  final tabs =
      List<WebViewModel>.from(
    selectedTabs,
  );

  /// REMOVE TABS FROM GROUPS
  for (final group in groups) {

    group.tabs.removeWhere(

      (groupTab) => tabs.any(
        (selected) =>
            selected.uuid ==
            groupTab.uuid,
      ),
    );
  }

  /// REMOVE EMPTY GROUPS
  groups.removeWhere(
    (g) => g.tabs.isEmpty,
  );

  notifyListeners();

  /// EXIT SELECTION MODE
  disableSelectionMode();

  Navigator.pop(context);

  await Future.delayed(
    const Duration(milliseconds: 300),
  );

  /// CLOSE TABS
  for (final tab in tabs) {

    final index =
        browser.webViewTabs.indexWhere(
      (e) =>
          e.webViewModel.uuid ==
          tab.uuid,
    );

    if (index == -1) continue;

    try {

      await Future.delayed(
        const Duration(
          milliseconds: 120,
        ),
      );

      browser.closeTab(index);

    } catch (_) {}
  }

  notifyListeners();
}


Future<void> closeSingleTab(
  BuildContext context,
  WebViewModel tab,
) async {
  if (browserProvider == null) {
    return;
  }

  final browser = browserProvider!;

  /// REMOVE TAB FROM GROUPS
  for (final group in groups) {
    group.tabs.removeWhere(
      (groupTab) => groupTab.uuid == tab.uuid,
    );
  }

  /// REMOVE EMPTY GROUPS
  groups.removeWhere(
    (g) => g.tabs.isEmpty,
  );

  notifyListeners();

  /// FIND TAB INDEX
  final index = browser.webViewTabs.indexWhere(
    (e) => e.webViewModel.uuid == tab.uuid,
  );

  if (index == -1) return;

  try {
    browser.closeTab(index);
  } catch (e) {
    debugPrint('Error closing tab: $e');
  }

  notifyListeners();
}








/////////////// add selected tab to group
///
// void addSelectedTabsToGroup(
//   GroupModel targetGroup,
// ) {

//   for (final tab in selectedTabs) {

//     /// Remove from current group if exists
//     for (final group in groups) {

//       group.tabs.removeWhere(
//         (e) => e.uuid == tab.uuid,
//       );
//     }

//     /// Add to target group
//     final exists =
//         targetGroup.tabs.any(
//       (e) => e.uuid == tab.uuid,
//     );

//     if (!exists) {

//       targetGroup.tabs.add(tab);
//     }
//   }

//   /// Remove empty groups
//   groups.removeWhere(
//     (e) => e.tabs.isEmpty,
//   );

//   selectedTabs.clear();

//   notifyListeners();
// }

void addSelectedTabsToGroup(
  GroupModel targetGroup,
) {
  final tabs = List<WebViewModel>.from(
    selectedTabs,
  );

  for (final tab in tabs) {
    /// Remove from ALL groups
    for (final group in groups) {
      group.tabs.removeWhere(
        (existingTab) =>
            existingTab.uuid == tab.uuid,
      );
    }

    /// Add to target
    final exists = targetGroup.tabs.any(
      (existingTab) =>
          existingTab.uuid == tab.uuid,
    );

    if (!exists) {
      targetGroup.tabs.add(tab);
    }
  }

  /// Remove empty groups
  groups.removeWhere(
    (group) => group.tabs.isEmpty,
  );

  selectedTabs.clear();

  selectionMode = false;

  notifyListeners();
}


void createGroupFromSelectedTabs({
  required String name,
  required Color color,
}) {
  if (selectedTabs.isEmpty) {
    return;
  }

  final selectedIds =
      selectedTabs.map((e) => e.uuid).toSet();

  /// Remove selected tabs from AUTO groups
  for (final group in groups) {
    if (!group.isAutoGroup) {
      continue;
    }

    group.tabs.removeWhere(
      (tab) => selectedIds.contains(tab.uuid),
    );
  }

  /// Remove empty auto groups
  groups.removeWhere(
    (group) =>
        group.isAutoGroup &&
        group.tabs.isEmpty,
  );

  /// Remove selected tabs from existing USER groups too
  for (final group in groups) {
    if (group.isAutoGroup) {
      continue;
    }

    group.tabs.removeWhere(
      (tab) => selectedIds.contains(tab.uuid),
    );
  }

  /// Remove empty manual groups
  groups.removeWhere(
    (group) =>
        !group.isAutoGroup &&
        group.tabs.isEmpty,
  );

  /// Create USER group
  groups.add(
    GroupModel(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      name: name,
      color: color,

      isClosed: false,

      // IMPORTANT
      isAutoGroup: false,

      domain: null,

      tabs: List<WebViewModel>.from(
        selectedTabs,
      ),
    ),
  );

  selectedTabs.clear();

  selectionMode = false;

  notifyListeners();
}

/// check if the selected items contains group and should not display in the add tab to groups list 
List<GroupModel> getSelectedGroups() {

  return groups.where((group) {

    return group.tabs.isNotEmpty &&
        group.tabs.every(
          (tab) => isSelected(tab),
        );

  }).toList();
}

//////////////////////////////////////////

// For search tab ot groups
List<TabSearchResult> searchTabs(
  String query,
) {

  if (query.trim().isEmpty) {
    return [];
  }

  final q =
      query.toLowerCase().trim();

  final List<TabSearchResult>
      results = [];

  /// Tabs
  for (final tab
      in browserProvider!
          .webViewTabs
          .map(
            (e) =>
                e.webViewModel,
          )) {

    final title =
        (tab.title ?? "")
            .toLowerCase();

    final url =
        (tab.url?.toString() ??
                "")
            .toLowerCase();

    if (title.contains(q) ||
        url.contains(q)) {

      results.add(
        TabSearchResult.tab(
          tab,
        ),
      );
    }
  }

  /// Groups
  for (final group in groups) {

    if (group.name
        .toLowerCase()
        .contains(q)) {

      results.add(
        TabSearchResult.group(
          group,
        ),
      );
    }
  }

  return results;
}


// Future<void> closeAllTabs(BuildContext context) async {
//   if (browserProvider == null) {
//     return;
//   }

//   final browser = browserProvider!;

//   if (browser.webViewTabs.isEmpty) {
//     return;
//   }

//   // Exit selection mode
//   selectionMode = false;
//   selectedTabs.clear();

//   // Close all OPEN groups using closeGroup().
//   // Their tabs are preserved.
//   for (final group in groups) {
//     if (!group.isClosed) {
//       closeGroup(
//         group,
//         closeTabsIfNoOtherTabs: false,
//       );
//     }
//   }

//   // Get all grouped tab IDs.
//   final groupedTabIds = groups
//       .expand((group) => group.tabs)
//       .map((tab) => tab.uuid)
//       .toSet();

//   // Close dialog FIRST.
//   if (Navigator.canPop(context)) {
//     Navigator.pop(context);
//   }

//   // Close only ungrouped tabs.
//   while (true) {
//     final index = browser.webViewTabs.indexWhere(
//       (tab) => !groupedTabIds.contains(
//         tab.webViewModel.uuid,
//       ),
//     );

//     if (index == -1) {
//       break;
//     }

//     try {
//       browser.closeTab(index);

//       // Give Flutter/WebView a small amount of time
//       // between disposals if needed.
//       await Future.delayed(
//         const Duration(milliseconds: 30),
//       );
//     } catch (e) {
//       debugPrint('Error closing tab: $e');
//       break;
//     }
//   }

//   // Notify only after the operation is complete.
//   notifyListeners();
// }

Future<void> closeAllTabs(BuildContext context) async {
  if (browserProvider == null) {
    return;
  }

  final browser = browserProvider!;

  if (browser.webViewTabs.isEmpty) {
    return;
  }

  // ------------------------------------------------------------
  // Exit selection mode
  // ------------------------------------------------------------

  selectionMode = false;
  selectedTabs.clear();

  // ------------------------------------------------------------
  // Close all currently OPEN groups.
  //
  // This only changes isClosed.
  // Their tabs remain alive.
  // ------------------------------------------------------------

  final allGroups = List<GroupModel>.from(groups);

  for (final group in allGroups) {
    if (!group.isClosed) {
      closeGroup(
        group,
        closeTabsIfNoOtherTabs: false,
      );
    }
  }

  // ------------------------------------------------------------
  // IMPORTANT:
  // Capture the IDs of tabs that are NOT inside a group
  // RIGHT NOW.
  //
  // Only these tabs should be closed.
  // ------------------------------------------------------------

  final groupedTabIds = groups
      .expand((group) => group.tabs)
      .map((tab) => tab.uuid)
      .toSet();

  final tabsToClose = browser.webViewTabs
      .map((e) => e.webViewModel)
      .where(
        (tab) => !groupedTabIds.contains(
          tab.uuid,
        ),
      )
      .map((tab) => tab.uuid)
      .toSet();

  // ------------------------------------------------------------
  // Close dialog
  // ------------------------------------------------------------

  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }

  // ------------------------------------------------------------
  // Close ONLY the tabs captured above.
  //
  // New tabs created after this point are NOT affected.
  // ------------------------------------------------------------

  for (final tabId in tabsToClose) {
    final index = browser.webViewTabs.indexWhere(
      (tab) =>
          tab.webViewModel.uuid == tabId,
    );

    if (index == -1) {
      continue;
    }

    try {
      browser.closeTab(index);

      await Future.delayed(
        const Duration(milliseconds: 30),
      );
    } catch (e) {
      debugPrint(
        'Error closing tab: $e',
      );
    }
  }

  notifyListeners();
}



// Future<void> closeSelectedTabs(
//   BuildContext context,
// ) async {

//   if (browserProvider == null) {
//     return;
//   }

//   final browser =
//       browserProvider!;

//   final tabs =
//       List<WebViewModel>.from(
//     selectedTabs,
//   );

//   /// EXIT SELECTION MODE
//   disableSelectionMode();

//   Navigator.pop(context);

//   await Future.delayed(
//     const Duration(milliseconds: 300),
//   );

//   for (final tab in tabs) {

//     final index =
//         browser.webViewTabs.indexWhere(
//       (e) =>
//           e.webViewModel.uuid ==
//           tab.uuid,
//     );

//     if (index == -1) continue;

//     try {

//       await Future.delayed(
//         const Duration(
//           milliseconds: 120,
//         ),
//       );

//       browser.closeTab(index);

//     } catch (_) {}
//   }
// }



}










// class ItemModel {
//   final String id;
//   final String title;

//   ItemModel({
//     required this.id,
//     required this.title,
//   });
// }





// class GroupModel {

//   final String id;

//  String name;

//    Color color;

//    bool isClosed;

//   final List<WebViewModel> tabs;

//   GroupModel( {
//     required this.id,
//     required this.tabs,
//     required this.name, required this.color,this.isClosed = false,
//   });
// }

// // For search tabs

// class TabSearchResult {

//   final WebViewModel? tab;
//   final GroupModel? group;

//   bool get isGroup => group != null;

//   TabSearchResult.tab(this.tab)
//       : group = null;

//   TabSearchResult.group(this.group)
//       : tab = null;
// }



// enum ViewMode {
//   all,
//   groupsOnly,
// }

// class GroupProvider extends ChangeNotifier {

//   BrowserModel? browserProvider;

//   //GroupProvider(this.browserProvider);

//   ViewMode currentMode = ViewMode.all;


//   bool selectionMode = false;

//   bool _groupNameEditMode = false;

//   bool get groupNameEditMode => _groupNameEditMode; 

//  List<WebViewModel>
//     selectedTabs = [];

//   List<GroupModel> groups = [];

//  List<WebViewModel> get outsideTabs {

//   if (browserProvider == null) {
//     return [];
//   }

//   /// ALL GROUPED TAB IDS
//   final groupedIds = groups

//       .expand((g) => g.tabs)

//       .map((e) => e.uuid)

//       .toSet();

//   return browserProvider!
//       .webViewTabs

//       .map((e) => e.webViewModel)

//       /// HIDE ALL GROUPED TABS
//       .where(
//         (e) =>
//             !groupedIds.contains(
//           e.uuid,
//         ),
//       )

//       .toList();
// }

// //   List<WebViewModel> get outsideTabs {

// //      if (browserProvider == null) {
// //     return [];
// //   }

// //   final groupedIds = groups
// //       .expand((g) => g.tabs)
// //       .map((e) => e.hashCode)
// //       .toSet();

// //   return browserProvider!.webViewTabs
// //       .map((e) => e.webViewModel)
// //       .where(
// //         (e) =>
// //             !groupedIds.contains(
// //           e.hashCode,
// //         ),
// //       )
// //       .toList();
// // }


// int get totalOpenTabsCount {
//   if (browserProvider == null) {
//     return 0;
//   }

//   // Tab IDs from closed groups
//   final closedGroupTabIds = groups
//       .where((group) => group.isClosed)
//       .expand((group) => group.tabs)
//       .map((tab) => tab.uuid)
//       .toSet();

//   return browserProvider!.webViewTabs
//       .map((tab) => tab.webViewModel)
//       .where(
//         (tab) => !closedGroupTabIds.contains(tab.uuid),
//       )
//       .length;
// }





//   void changeViewMode(ViewMode mode) {
//     currentMode = mode;
//     notifyListeners();
//   }

//   List<Widget> getHomeWidgets() {

//     if (currentMode ==
//         ViewMode.groupsOnly) {

//       return groups.map((e) {
//         return GroupWidget(group: e);
//       }).toList();
//     }

//     return [

//   ...outsideTabs.map((e) {
//     return ItemWidget(tab: e);
//   }),

//   ...groups.where((e) => !e.isClosed).map((e) {
//     return GroupWidget(group: e);
//   }),
// ];
//   }

//   void createGroup({
//      required String name,
//   required Color color,
//    required WebViewModel first,
//   required WebViewModel second,
//   }
 
// ) {
//   final alreadyGrouped =
//       groups.any((g) =>
//           g.tabs.any(
//             (e) => e.uuid == first.uuid,
//           ) ||
//           g.tabs.any(
//             (e) => e.uuid == second.uuid,
//           ));

//   if (alreadyGrouped) return;

//   final group = GroupModel(
//     id: DateTime.now().toString(),
//     name: name,
//     color: color,
//     isClosed: false,
//     tabs: [first, second],
//   );

//   groups.add(group);


//   // final group = GroupModel(
//   //   id: DateTime.now().toString(),
//   //   tabs: [first, second],
//   // );

//   // groups.add(group);

//   notifyListeners();
// }


// // void closeGroup(
// //   GroupModel group,
// // ) {

// //   group.isClosed = true;

// //   notifyListeners();
// // }


// void closeGroup(
//   GroupModel group, {
//   bool closeTabsIfNoOtherTabs = true,
// }) {
//   if (browserProvider == null) {
//     return;
//   }

//   final browser = browserProvider!;

//   final currentTab = browser.getCurrentTab();

//   final currentTabId = currentTab?.webViewModel.uuid;

//   final groupContainsCurrentTab =
//       currentTabId != null &&
//       group.tabs.any(
//         (tab) => tab.uuid == currentTabId,
//       );

//   if (groupContainsCurrentTab) {
//     final groupTabIds = group.tabs
//         .map((tab) => tab.uuid)
//         .toSet();

//     final otherTabIndex =
//         browser.webViewTabs.indexWhere(
//       (tab) => !groupTabIds.contains(
//         tab.webViewModel.uuid,
//       ),
//     );

//     if (otherTabIndex != -1) {
//       browser.showTab(otherTabIndex);
//     } else if (closeTabsIfNoOtherTabs) {
//       while (browser.webViewTabs.isNotEmpty) {
//         final index =
//             browser.webViewTabs.indexWhere(
//           (tab) => groupTabIds.contains(
//             tab.webViewModel.uuid,
//           ),
//         );

//         if (index == -1) {
//           break;
//         }

//         browser.closeTab(index);
//       }
//     }
//   }

//   // Keep the group.
//   group.isClosed = true;

//   notifyListeners();
// }



// void reOpenCloseGroup(
//   GroupModel group,
// ) {

//   group.isClosed = false;
//   changeViewMode(ViewMode.all);
//   notifyListeners();
// }

// void editGroup({
//   required GroupModel group,
//   required String name,
//   required Color color,
// }) {

//   group.name = name;
//   group.color = color;

//   notifyListeners();
// }



// void editGroupColor({
//   required GroupModel group,
//   required Color color,
// }) {

//   group.color = color;

//   notifyListeners();
// }


// void enableGroupNameEditMode(){
//   _groupNameEditMode = true;
//   notifyListeners();
// }

// void disableGroupNameEditMode(){
//   _groupNameEditMode = false;
//   notifyListeners();
// }

// void editGroupname({
//   required GroupModel group,
//   required String name,
// }) {

//   group.name = name;

//   notifyListeners();
// }


// // Ungroup all tabs
// void ungroupAllTabs(
//   GroupModel group,
// ) {

//   groups.removeWhere(
//     (e) => e.id == group.id,
//   );

//   notifyListeners();
// }

// void ungroupSelectedTabs() {
//   final selectedIds =
//       selectedTabs.map((e) => e.uuid).toSet();

//   for (final group in groups) {
//     print("UNGROUP Before: ${group.tabs.length}");
//     group.tabs.removeWhere(
//       (tab) => selectedIds.contains(tab.uuid),
//     );
//     print("UNGROUP After: ${group.tabs.length}");
//   }

//   groups.removeWhere(
//     (group) => group.tabs.isEmpty,
//   );

// disableSelectionMode();
//   // selectedTabs.clear();
//   // selectionMode = false;

//   notifyListeners();
// }
// // void ungroupSelectedTabs(GroupModel group) {

// //   // if (selectedTabs.isEmpty) {
// //   //   return;
// //   // }

// //   for (final tab in selectedTabs) {

// //     for (final group in groups) {

// //       group.tabs.removeWhere(
// //         (e) => e.uuid == tab.uuid,
// //       );
// //     }
// //   }

// //   /// Remove empty groups
// //   groups.removeWhere(
// //     (group) => group.tabs.isEmpty,
// //   );

// //   selectedTabs.clear();

// //   selectionMode = false;

// //   notifyListeners();
// // }

// void deleteGroup(
//   GroupModel group,
// ) {

//   groups.removeWhere(
//     (e) => e.id == group.id,
//   );

//   notifyListeners();
// }



// Future<void> deleteGroupAndTabs(
//   BuildContext context,
//   GroupModel group,
// ) async {

//   if (browserProvider == null) {
//     return;
//   }

//   final browser =
//       browserProvider!;

//   final tabsToDelete =
//       List<WebViewModel>.from(
//     group.tabs,
//   );

//   /// REMOVE GROUP FIRST
//   groups.removeWhere(
//     (e) => e.id == group.id,
//   );

//   notifyListeners();

//   /// CLOSE DIALOG
//   //Navigator.pop(context);

//   await Future.delayed(
//     const Duration(milliseconds: 300),
//   );

//   /// FIND SAFE TAB
//   final remainingTabs =
//       browser.webViewTabs
//           .map((e) => e.webViewModel)
//           .where(
//             (e) => !tabsToDelete.any(
//               (d) => d.uuid == e.uuid,
//             ),
//           )
//           .toList();

//   /// OPEN SAFE TAB
//   // if (remainingTabs.isNotEmpty) {

//   //   final safeIndex =
//   //       browser.webViewTabs.indexWhere(
//   //     (e) =>
//   //         e.webViewModel.uuid ==
//   //         remainingTabs.first.uuid,
//   //   );

//   //   if (safeIndex != -1) {

//   //     browser.showTab(safeIndex);

//   //     browser.showTabScroller =
//   //         false;

//   //     await Future.delayed(
//   //       const Duration(
//   //         milliseconds: 300,
//   //       ),
//   //     );
//   //   }
//   // }

//   /// DELETE TABS ONE BY ONE SAFELY
//   for (final tab in tabsToDelete) {

//     final index =
//         browser.webViewTabs.indexWhere(
//       (e) =>
//           e.webViewModel.uuid ==
//           tab.uuid,
//     );

//     if (index == -1) continue;

//     try {

//       /// SMALL GAP BETWEEN DISPOSALS
//       await Future.delayed(
//         const Duration(
//           milliseconds: 120,
//         ),
//       );

//       browser.closeTab(index);

//     } catch (e) {

//       debugPrint(
//         "Tab delete error: $e",
//       );
//     }
//   }
// }






// //////////Highlight the current tabs


// bool isCurrentTab(WebViewModel tab) {

//   if (browserProvider == null) {
//     return false;
//   }

//   final currentTab =
//       browserProvider!.getCurrentTab();

//   if (currentTab == null) {
//     return false;
//   }

//   return currentTab.webViewModel.uuid ==
//       tab.uuid;
// }

// bool groupContainsCurrentTab(
//   GroupModel group,
// ) {

//   if (browserProvider == null) {
//     return false;
//   }

//   final currentTab =
//       browserProvider!.getCurrentTab();

//   if (currentTab == null) {
//     return false;
//   }

//   return group.tabs.any(
//     (tab) =>
//         tab.uuid ==
//         currentTab.webViewModel.uuid,
//   );
// }



// void mergeGroups({
//   required GroupModel sourceGroup,
//   required GroupModel targetGroup,
// }) {

//   /// Prevent self merge
//   if (sourceGroup.id == targetGroup.id) {
//     return;
//   }

//   /// Add tabs from source into target
//   for (final tab in sourceGroup.tabs) {

//     final exists = targetGroup.tabs.any(
//       (e) => e.uuid == tab.uuid,
//     );

//     if (!exists) {
//       targetGroup.tabs.add(tab);
//     }
//   }

//   /// Remove source group
//   groups.removeWhere(
//     (g) => g.id == sourceGroup.id,
//   );

//   notifyListeners();
// }



// //////////////////////////////

// // void openTab(
// //   BuildContext context,
// //   GroupModel? group,
// //   WebViewModel tab,
// // ) {

// //   if (browserProvider == null) {
// //     return;
// //   }

// //   final webViewTab =
// //       browserProvider!.tabGroups
// //           .expand((g) => g.tabs)
// //           .firstWhere(
// //             (t) =>
// //                 t.webViewModel.uuid ==
// //                 tab.uuid,
// //           );

// //   final browserGroup =
// //       browserProvider!.tabGroups
// //           .firstWhere(
// //             (g) =>
// //                 g.tabs.contains(
// //                   webViewTab,
// //                 ),
// //           );

// //   Navigator.pop(context);

// //   Future.delayed(
// //     const Duration(milliseconds: 120),
// //     () {

// //       browserProvider!
// //           .openGroupedTab(
// //         webViewTab,
// //         browserGroup,
// //       );

// //       browserProvider!
// //           .showTabScroller = false;
// //     },
// //   );
// // }



// void openTab(
//   BuildContext context,
//   WebViewModel tab,
// ) {

//   if (browserProvider == null) {
//     return;
//   }

//   final index =
//       browserProvider!.webViewTabs.indexWhere(
//     (e) => e.webViewModel.uuid == tab.uuid,
//   );

//   if (index != -1) {

//     browserProvider!.showTab(index);

//     Navigator.pop(context);
//   }
// }

//   void addToGroup(
//   WebViewModel tab,
//   GroupModel group,
// ) {

//   final exists =
//       group.tabs.any(
//     (e) => e.uuid == tab.uuid,
//   );

//   if (exists) return;

//   group.tabs.add(tab);

//   notifyListeners();
// }

// void removeFromGroup(
//   WebViewModel tab,
//   GroupModel group,
// ) {

//   group.tabs.removeWhere(
//     (e) => e.uuid == tab.uuid,
//   );

//   if (group.tabs.isEmpty) {
//     groups.remove(group);
//   }

//   notifyListeners();
// }

// Future<void> addNewTabToGroup(
//   GroupModel group,
// ) async {

//   if (browserProvider == null) {
//     return;
//   }
//  var settings = browserProvider!.getSettings();
//   browserProvider!.addTab(WebViewTab(
//                     key: GlobalKey(),
//                     webViewModel: WebViewModel(uuid: Uuid().v4(),url: WebUri(settings.searchEngine.url)),
//                   ));

//   /// GET CREATED TAB
//   final newTab =
//       browserProvider!
//           .webViewTabs
//           .last
//           .webViewModel;

//   /// ADD TO GROUP
//   group.tabs.add(newTab);

//   notifyListeners();
// }

// Future<void> createEmptyGroup({
//   required String name,
//   required Color color,
// }) async {

//   if (browserProvider == null) {
//     return;
//   }
//   var settings = browserProvider!.getSettings();
//   browserProvider!.addTab(WebViewTab(
//                     key: GlobalKey(),
//                     webViewModel: WebViewModel(uuid: Uuid().v4(),url: WebUri(settings.searchEngine.url)),
//                   ));

//   // await browserProvider!.addTab(
//   //   webViewModel: WebViewModel(
//   //     uuid: DateTime.now()
//   //         .microsecondsSinceEpoch
//   //         .toString(),
//   //   ),
//   // );

//   final newTab =
//       browserProvider!
//           .webViewTabs
//           .last
//           .webViewModel;

//   final group = GroupModel(
//     id: DateTime.now().toString(),
//     name: name,
//     color: color,
//     isClosed: false,
//     tabs: [newTab],
//   );

//   groups.add(group);

//   notifyListeners();
// }





// ///// Working with tab selection 
// ///
// void enableSelectionMode() {

//   selectionMode = true;

//   selectedTabs.clear();

//   notifyListeners();
// }

// void disableSelectionMode() {

//   selectionMode = false;

//   selectedTabs.clear();

//   notifyListeners();
// }


// void toggleTabSelection(
//   WebViewModel tab,
// ) {

//   final exists =
//       selectedTabs.any(
//     (e) => e.uuid == tab.uuid,
//   );

//   if (exists) {

//     selectedTabs.removeWhere(
//       (e) => e.uuid == tab.uuid,
//     );

//   } else {

//     selectedTabs.add(tab);
//   }

//   notifyListeners();
// }


// bool isSelected(
//   WebViewModel tab,
// ) {

//   return selectedTabs.any(
//     (e) => e.uuid == tab.uuid,
//   );
// }


// bool get allTabsSelected {

//   if (browserProvider == null) {
//     return false;
//   }

//   return selectedTabs.length ==
//       browserProvider!
//           .webViewTabs
//           .length;
// }

// void toggleSelectAllTabs() {

//   if (browserProvider == null) {
//     return;
//   }

//   /// DESELECT ALL
//   if (allTabsSelected) {

//     selectedTabs.clear();
//   }

//   /// SELECT ALL
//   else {

//     selectedTabs.clear();

//     selectedTabs.addAll(

//       browserProvider!
//           .webViewTabs
//           .map((e) => e.webViewModel),
//     );
//   }

//   notifyListeners();
// }


// void selectAllTabs() {

//   if (browserProvider == null) {
//     return;
//   }

//   selectedTabs.clear();

//   selectedTabs.addAll(

//     browserProvider!
//         .webViewTabs
//         .map((e) => e.webViewModel),
//   );

//   notifyListeners();
// }

// Future<void> closeSelectedTabs(
//   BuildContext context,
// ) async {

//   if (browserProvider == null) {
//     return;
//   }

//   final browser =
//       browserProvider!;

//   final tabs =
//       List<WebViewModel>.from(
//     selectedTabs,
//   );

//   /// REMOVE TABS FROM GROUPS
//   for (final group in groups) {

//     group.tabs.removeWhere(

//       (groupTab) => tabs.any(
//         (selected) =>
//             selected.uuid ==
//             groupTab.uuid,
//       ),
//     );
//   }

//   /// REMOVE EMPTY GROUPS
//   groups.removeWhere(
//     (g) => g.tabs.isEmpty,
//   );

//   notifyListeners();

//   /// EXIT SELECTION MODE
//   disableSelectionMode();

//   Navigator.pop(context);

//   await Future.delayed(
//     const Duration(milliseconds: 300),
//   );

//   /// CLOSE TABS
//   for (final tab in tabs) {

//     final index =
//         browser.webViewTabs.indexWhere(
//       (e) =>
//           e.webViewModel.uuid ==
//           tab.uuid,
//     );

//     if (index == -1) continue;

//     try {

//       await Future.delayed(
//         const Duration(
//           milliseconds: 120,
//         ),
//       );

//       browser.closeTab(index);

//     } catch (_) {}
//   }

//   notifyListeners();
// }


// Future<void> closeSingleTab(
//   BuildContext context,
//   WebViewModel tab,
// ) async {
//   if (browserProvider == null) {
//     return;
//   }

//   final browser = browserProvider!;

//   /// REMOVE TAB FROM GROUPS
//   for (final group in groups) {
//     group.tabs.removeWhere(
//       (groupTab) => groupTab.uuid == tab.uuid,
//     );
//   }

//   /// REMOVE EMPTY GROUPS
//   groups.removeWhere(
//     (g) => g.tabs.isEmpty,
//   );

//   notifyListeners();

//   /// FIND TAB INDEX
//   final index = browser.webViewTabs.indexWhere(
//     (e) => e.webViewModel.uuid == tab.uuid,
//   );

//   if (index == -1) return;

//   try {
//     browser.closeTab(index);
//   } catch (e) {
//     debugPrint('Error closing tab: $e');
//   }

//   notifyListeners();
// }








// /////////////// add selected tab to group
// ///
// void addSelectedTabsToGroup(
//   GroupModel targetGroup,
// ) {

//   for (final tab in selectedTabs) {

//     /// Remove from current group if exists
//     for (final group in groups) {

//       group.tabs.removeWhere(
//         (e) => e.uuid == tab.uuid,
//       );
//     }

//     /// Add to target group
//     final exists =
//         targetGroup.tabs.any(
//       (e) => e.uuid == tab.uuid,
//     );

//     if (!exists) {

//       targetGroup.tabs.add(tab);
//     }
//   }

//   /// Remove empty groups
//   groups.removeWhere(
//     (e) => e.tabs.isEmpty,
//   );

//   selectedTabs.clear();

//   notifyListeners();
// }



// void createGroupFromSelectedTabs({

//   required String name,
//   required Color color,

// }) {

//   if (selectedTabs.isEmpty) return;

//   /// Remove tabs from existing groups
//   for (final tab in selectedTabs) {

//     for (final group in groups) {

//       group.tabs.removeWhere(
//         (e) => e.uuid == tab.uuid,
//       );
//     }
//   }

//   groups.removeWhere(
//     (e) => e.tabs.isEmpty,
//   );

//   groups.add(

//     GroupModel(
//       id: DateTime.now().toString(),
//       name: name,

//       color: color,

//       tabs: List.from(
//         selectedTabs,
//       ),
//     ),
//   );

//   selectedTabs.clear();

//   notifyListeners();
// }

// /// check if the selected items contains group and should not display in the add tab to groups list 
// List<GroupModel> getSelectedGroups() {

//   return groups.where((group) {

//     return group.tabs.isNotEmpty &&
//         group.tabs.every(
//           (tab) => isSelected(tab),
//         );

//   }).toList();
// }

// //////////////////////////////////////////

// // For search tab ot groups
// List<TabSearchResult> searchTabs(
//   String query,
// ) {

//   if (query.trim().isEmpty) {
//     return [];
//   }

//   final q =
//       query.toLowerCase().trim();

//   final List<TabSearchResult>
//       results = [];

//   /// Tabs
//   for (final tab
//       in browserProvider!
//           .webViewTabs
//           .map(
//             (e) =>
//                 e.webViewModel,
//           )) {

//     final title =
//         (tab.title ?? "")
//             .toLowerCase();

//     final url =
//         (tab.url?.toString() ??
//                 "")
//             .toLowerCase();

//     if (title.contains(q) ||
//         url.contains(q)) {

//       results.add(
//         TabSearchResult.tab(
//           tab,
//         ),
//       );
//     }
//   }

//   /// Groups
//   for (final group in groups) {

//     if (group.name
//         .toLowerCase()
//         .contains(q)) {

//       results.add(
//         TabSearchResult.group(
//           group,
//         ),
//       );
//     }
//   }

//   return results;
// }


// Future<void> closeAllTabs(BuildContext context) async {
//   if (browserProvider == null) {
//     return;
//   }

//   final browser = browserProvider!;

//   if (browser.webViewTabs.isEmpty) {
//     return;
//   }

//   // Exit selection mode
//   selectionMode = false;
//   selectedTabs.clear();

//   // Close all OPEN groups using closeGroup().
//   // Their tabs are preserved.
//   for (final group in groups) {
//     if (!group.isClosed) {
//       closeGroup(
//         group,
//         closeTabsIfNoOtherTabs: false,
//       );
//     }
//   }

//   // Get all grouped tab IDs.
//   final groupedTabIds = groups
//       .expand((group) => group.tabs)
//       .map((tab) => tab.uuid)
//       .toSet();

//   // Close dialog FIRST.
//   if (Navigator.canPop(context)) {
//     Navigator.pop(context);
//   }

//   // Close only ungrouped tabs.
//   while (true) {
//     final index = browser.webViewTabs.indexWhere(
//       (tab) => !groupedTabIds.contains(
//         tab.webViewModel.uuid,
//       ),
//     );

//     if (index == -1) {
//       break;
//     }

//     try {
//       browser.closeTab(index);

//       // Give Flutter/WebView a small amount of time
//       // between disposals if needed.
//       await Future.delayed(
//         const Duration(milliseconds: 30),
//       );
//     } catch (e) {
//       debugPrint('Error closing tab: $e');
//       break;
//     }
//   }

//   // Notify only after the operation is complete.
//   notifyListeners();
// }


// // Future<void> closeSelectedTabs(
// //   BuildContext context,
// // ) async {

// //   if (browserProvider == null) {
// //     return;
// //   }

// //   final browser =
// //       browserProvider!;

// //   final tabs =
// //       List<WebViewModel>.from(
// //     selectedTabs,
// //   );

// //   /// EXIT SELECTION MODE
// //   disableSelectionMode();

// //   Navigator.pop(context);

// //   await Future.delayed(
// //     const Duration(milliseconds: 300),
// //   );

// //   for (final tab in tabs) {

// //     final index =
// //         browser.webViewTabs.indexWhere(
// //       (e) =>
// //           e.webViewModel.uuid ==
// //           tab.uuid,
// //     );

// //     if (index == -1) continue;

// //     try {

// //       await Future.delayed(
// //         const Duration(
// //           milliseconds: 120,
// //         ),
// //       );

// //       browser.closeTab(index);

// //     } catch (_) {}
// //   }
// // }



// }

