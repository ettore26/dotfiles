# Tab Keys

Tab and tab-group shortcuts for Chrome on macOS and Linux. Chrome handles extension commands itself, so they
work on every page, including the New Tab page and `chrome://` pages, where content-script tools like
Surfingkeys can't run.

## The scheme

- **⌘ acts on tabs, ⌃⌘ on tab groups.** Same letter, same action, one level up. Chrome's own group keys
  are already ⌃⌘.
  - On Linux, ⌘ becomes Ctrl and ⌃⌘ becomes Alt. Chrome doesn't allow Super in extension shortcuts.
- **Letters:** N next, P previous (as in Vim and tmux), T new, W close (Chrome's own).
- **⇧ moves** the tab or group instead of switching to it.
- **Chrome menu items that lose their key move to ⌘⌥** (macOS only), adding ⇧ if that's taken.

## Tabs

| Action | Chrome built-in (macOS · Linux) | Tab Keys macOS | Tab Keys Linux |
|---|---|---|---|
| Next tab | ⌘⌥→ · ⌃Tab · ⌃PgDn | **⌘N** | **Ctrl+N** |
| Previous tab | ⌘⌥← · ⌃⇧Tab · ⌃PgUp | **⌘P** | **Ctrl+P** |
| Move tab right | ⌃⇧PgDn | **⌘⇧N** | **Ctrl+Shift+N** |
| Move tab left | ⌃⇧PgUp | **⌘⇧P** | **Ctrl+Shift+P** |
| New tab | ⌘T · Ctrl+T | none | none |
| Close tab | ⌘W · Ctrl+W | none | none |
| Reopen closed tab | ⌘⇧T · Ctrl+Shift+T | none | none |
| Go to tab 1–8 / last | ⌘1–⌘8 / ⌘9 · Ctrl or Alt+1–8 / 9 | none | none |
| Search tabs | ⌘⇧A · Ctrl+Shift+A (⌃N / ⌃P in the list) | none | none |

Moving a tab follows Chrome's own rules (`TabStripModel::MoveTabRelative`):
- At a group's edge, the tab first leaves the group, or joins the neighbouring expanded group, without moving.
- It steps over a collapsed group in one go.

## Groups

| Action | Chrome built-in (macOS · Linux) | Tab Keys macOS | Tab Keys Linux |
|---|---|---|---|
| Next group (its most recent tab) | none | **⌃⌘N** | **Alt+N** |
| Previous group | none | **⌃⌘P** | **Alt+P** |
| New tab in a new group | ⌃⌘P · Alt+Shift+P | **⌃⌘T** | **Alt+T** |
| Move group right | none | ⌃⌘⇧N, **inactive** (see below) | **Alt+Shift+N** |
| Move group left | none | ⌃⌘⇧P, **inactive** (see below) | **Alt+Shift+P** |
| Close group | ⌃⌘W · Alt+Shift+W | none | none |
| New tab in the current group | ⌃⌘C · Alt+Shift+C | none | none |
| Focus next / previous group | ⌃⌘X / ⌃⌘Z · Alt+Shift+X / Z | none | none |

New groups are created unnamed; click the group to name it.

## Chrome keys this replaces

| Key | macOS | Linux |
|---|---|---|
| Next / previous tab | New Window (⌘N), Print (⌘P) | New Window (Ctrl+N), Print (Ctrl+P) |
| Move tab right / left | New Incognito Window (⌘⇧N) | New Incognito Window (Ctrl+Shift+N), Print using system dialog (Ctrl+Shift+P) |
| Previous group | Create new tab group (⌃⌘P) | none |
| Move group right / left | none | New Split View (Alt+Shift+N), Create new tab group (Alt+Shift+P) |

On Linux, Alt+letter also triggers a page's own access keys, so sites lose any they set on N, P or T.

## Setup

1. Link and load the extension.
   - Run `stow chrome` from the dotfiles repo.
   - In `chrome://extensions`, turn on Developer mode, click **Load unpacked**, and pick
     `~/.config/chrome-config/tab-keys`.
2. Set the keys in `chrome://extensions/shortcuts`. Each command's name shows its macOS and Linux keys.
   - Chrome only pre-fills keys that aren't its own shortcuts, and at most four, so set the rest by hand. On
     Linux it pre-fills Alt+N, Alt+P and Alt+T.
   - Use **reload** after edits, never remove: removing the extension forgets the keys.
   - A key can have at most two modifiers. That's why ⌃⌘⇧N/P can't work on macOS, where move group still
     needs other keys.
3. **macOS only:** move the Chrome menu items that lost their keys, then relaunch Chrome. Linux has no
   equivalent, so those keys are simply lost there.

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
