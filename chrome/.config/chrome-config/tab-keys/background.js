// Tab Keys. ⌘ acts on tabs and ⌃⌘ does the same action on tab groups. N is next, P previous, T new, and
// adding ⇧ moves the tab or group instead of switching to it. Chrome handles extension commands itself, so
// they work on every page, the New Tab page and chrome:// included.
// Chrome only pre-fills keys that aren't its own shortcuts, and at most four, so set the rest at
// chrome://extensions/shortcuts: each command's description names its key.
const COMMANDS = {
  'next-tab': (tabs, tab) => activate(tabs[(tab.index + 1) % tabs.length]),
  'previous-tab': (tabs, tab) => activate(tabs[(tab.index - 1 + tabs.length) % tabs.length]),
  'move-tab-right': (tabs, tab) => moveTab(tabs, tab, 1),
  'move-tab-left': (tabs, tab) => moveTab(tabs, tab, -1),
  'next-group': (tabs, tab) => focusGroup(tabs, tab, 1),
  'previous-group': (tabs, tab) => focusGroup(tabs, tab, -1),
  'move-group-right': (tabs, tab) => moveGroup(tabs, tab, 1),
  'move-group-left': (tabs, tab) => moveGroup(tabs, tab, -1),
  'new-group': (_tabs, tab) => newGroup(tab),
};

chrome.commands.onCommand.addListener(async (command, tab) => {
  const run = COMMANDS[command];
  if (!run) return;
  tab ??= (await chrome.tabs.query({ active: true, lastFocusedWindow: true }))[0];
  const tabs = (await chrome.tabs.query({ windowId: tab.windowId })).sort((a, b) => a.index - b.index);
  await run(tabs, tab);
});

function activate(tab) {
  return chrome.tabs.update(tab.id, { active: true });
}

// Chrome's own move-tab rules (TabStripModel::MoveTabRelative): at a group's edge the tab first leaves the
// group, or joins the neighbouring expanded group, without moving; a collapsed group is stepped over whole.
// No wrap-around, and pinned and unpinned tabs never swap.
async function moveTab(tabs, tab, step) {
  const none = chrome.tabGroups.TAB_GROUP_ID_NONE;
  const neighbour = tabs[tab.index + step];
  const canMove = neighbour !== undefined && neighbour.pinned === tab.pinned;
  const targetGroup = canMove ? neighbour.groupId : none;
  if (tab.groupId === targetGroup) {
    if (canMove) await chrome.tabs.move(tab.id, { index: tab.index + step });
  } else if (tab.groupId !== none) {
    await chrome.tabs.ungroup(tab.id);
  } else if (!(await chrome.tabGroups.get(targetGroup)).collapsed) {
    await chrome.tabs.group({ groupId: targetGroup, tabIds: [tab.id] });
  } else {
    const members = tabs.filter((candidate) => candidate.groupId === targetGroup);
    await chrome.tabs.move(tab.id, { index: step > 0 ? members.at(-1).index : members[0].index });
  }
}

// A group's tabs are always next to each other: { id, tabs } for each group, in tab-bar order
function groupsOf(tabs) {
  const groups = [];
  for (const tab of tabs) {
    if (tab.groupId === chrome.tabGroups.TAB_GROUP_ID_NONE) continue;
    if (groups.at(-1)?.id !== tab.groupId) groups.push({ id: tab.groupId, tabs: [] });
    groups.at(-1).tabs.push(tab);
  }
  return groups;
}

// The next / previous group in the tab bar, wrapping around: its most recently used tab, expanding the
// group if it is collapsed. From a tab outside any group, the nearest group after / before it.
async function focusGroup(tabs, active, step) {
  const groups = groupsOf(tabs);
  if (!groups.length) return;
  const current = groups.findIndex((group) => group.id === active.groupId);
  const target = current !== -1
    ? groups[(current + step + groups.length) % groups.length]
    : step > 0
      ? groups.find((group) => group.tabs[0].index > active.index) ?? groups[0]
      : groups.findLast((group) => group.tabs[0].index < active.index) ?? groups.at(-1);
  const recent = target.tabs.reduce((a, b) => ((b.lastAccessed ?? 0) > (a.lastAccessed ?? 0) ? b : a));
  if ((await chrome.tabGroups.get(target.id)).collapsed) await chrome.tabGroups.update(target.id, { collapsed: false });
  await activate(recent);
}

// The current tab's group past its neighbour on that side: a whole group, or one tab outside any group
async function moveGroup(tabs, active, step) {
  const group = groupsOf(tabs).find((candidate) => candidate.id === active.groupId);
  if (!group) return;
  const first = group.tabs[0].index;
  const neighbour = tabs[step > 0 ? group.tabs.at(-1).index + 1 : first - 1];
  if (!neighbour || neighbour.pinned) return;
  const size = neighbour.groupId === chrome.tabGroups.TAB_GROUP_ID_NONE
    ? 1
    : tabs.filter((tab) => tab.groupId === neighbour.groupId).length;
  await chrome.tabGroups.move(group.id, { index: first + step * size });
}

// A new tab at the end of the window, in a new unnamed group (click the group to name it)
async function newGroup(active) {
  const created = await chrome.tabs.create({ windowId: active.windowId });
  await chrome.tabs.group({ tabIds: [created.id] });
}
