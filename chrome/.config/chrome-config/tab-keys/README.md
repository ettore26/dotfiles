# Tab Keys

Tab and tab-group shortcuts for Chrome on macOS. Chrome handles extension commands itself, so they work on
every page, including the New Tab page and `chrome://` pages, where content-script tools like Surfingkeys
can't run.

## The scheme

- **⌘ acts on tabs, ⌃⌘ on tab groups.** Same letter, same action, one level up. Chrome's own group keys
  are already ⌃⌘.
- **Letters:** N next, P previous (as in Vim and tmux), T new, W close (Chrome's own).
- **⇧ moves** the tab or group instead of switching to it.
- **Chrome menu items that lose their key move to ⌘⌥**, adding ⇧ if that's taken.

## Tabs

| Action | Chrome built-in | Tab Keys |
|---|---|---|
| Next tab | ⌘⌥→ · ⌘⇧] · ⌃Tab · ⌃PgDn | **⌘N** |
| Previous tab | ⌘⌥← · ⌘⇧[ · ⌃⇧Tab · ⌃PgUp | **⌘P** |
| Move tab right | ⌃⇧PgDn | **⌘⇧N** |
| Move tab left | ⌃⇧PgUp | **⌘⇧P** |
| New tab | ⌘T | none |
| Close tab | ⌘W | none |
| Reopen closed tab | ⌘⇧T | none |
| Go to tab 1–8 / last | ⌘1–⌘8 / ⌘9 | none |
| Search tabs | ⌘⇧A (⌃N / ⌃P in the list) | none |

Moving a tab follows Chrome's own rules (`TabStripModel::MoveTabRelative`):
- At a group's edge, the tab first leaves the group, or joins the neighbouring expanded group, without moving.
- It steps over a collapsed group in one go.

## Groups

| Action | Chrome built-in | Tab Keys |
|---|---|---|
| Next group (its most recent tab) | none | **⌃⌘N** |
| Previous group | none | **⌃⌘P** (replaces Chrome's "create new tab group") |
| New tab in a new group | ⌃⌘P | **⌃⌘T** (unnamed; click the group to name it) |
| Move group right / left | none | ⌃⌘⇧N / ⌃⌘⇧P, **inactive** (see below) |
| Close group | ⌃⌘W | none |
| New tab in the current group | ⌃⌘C | none |
| Focus next / previous group | ⌃⌘X / ⌃⌘Z | none |

## Setup

1. Load the extension: `chrome://extensions` → Developer mode → **Load unpacked** →
   `~/.config/chrome-config/tab-keys`.
2. Set the keys in `chrome://extensions/shortcuts`. Each command's name shows its key.
   - Chrome only pre-fills keys that aren't its own shortcuts, and at most four, so set the rest by hand.
   - Use **reload** after edits, never remove: removing the extension forgets the keys.
   - A key can have at most two modifiers. That's why ⌃⌘⇧N/P can't work, and move group still needs other keys.
3. Move the Chrome menu items that lost their keys, then relaunch Chrome:

   ```sh
   defaults write com.google.Chrome NSUserKeyEquivalents -dict-add \
     'Print…' '@~p' 'Print Using System Dialog…' '@~$p' 'New Incognito Window' '@~$n'
   ```

   | Menu item | Chrome built-in | Moved to |
   |---|---|---|
   | Print… | ⌘P | ⌘⌥P |
   | Print Using System Dialog… | ⌘⌥P | ⌘⌥⇧P |
   | New Incognito Window | ⌘⇧N | ⌘⌥⇧N (⌘⌥N is Chrome's New Split View) |
   | New Window | ⌘N | no key |
