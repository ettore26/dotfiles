// Commands are handled by Chrome itself, so they fire on every page, unlike Surfingkeys'
// content-script keys. Bind or change them at chrome://extensions/shortcuts.
chrome.commands.onCommand.addListener((command, tab) => {
  if (command === 'new-tab') {
    // Right after the current tab, like Surfingkeys' newTabPosition = 'right'
    chrome.tabs.create(tab ? { index: tab.index + 1 } : {});
  }
});
