// Opened by the prefix shortcut (Option-a): the next key picks the action, like a tmux prefix.
// Binding Option-a here means Surfingkeys never sees it, so its Option-a 1-9/c keys live here too.
// event.code, not event.key, so the key still matches if Option is held down.
const MODIFIERS = ['Alt', 'Control', 'Meta', 'Shift'];

async function activate(tabs, index) {
  const target = tabs.find((tab) => tab.index === index);
  if (target) await chrome.tabs.update(target.id, { active: true });
}

document.addEventListener('keydown', async (event) => {
  if (event.repeat || MODIFIERS.includes(event.key)) return;
  const tabs = await chrome.tabs.query({ currentWindow: true });
  const active = tabs.find((tab) => tab.active);
  const digit = /^Digit([1-9])$/.exec(event.code);
  if (event.code === 'KeyN') await activate(tabs, (active.index + 1) % tabs.length);
  else if (event.code === 'KeyP') await activate(tabs, (active.index - 1 + tabs.length) % tabs.length);
  else if (event.code === 'KeyX') await chrome.tabs.remove(active.id);
  else if (event.code === 'KeyC') await chrome.tabs.create({ index: active.index + 1 });
  else if (digit) await activate(tabs, digit[1] === '9' ? tabs.length - 1 : Number(digit[1]) - 1);
  window.close();  // any other key just cancels the prefix
});
