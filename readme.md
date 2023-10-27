# Hammerspoon Utilities Documentation

## Introduction

This repository provides a set of utility functions built for the Hammerspoon macOS automation tool. These functions allow you to manage your clipboard history, control the positions of your mouse across applications, and execute custom shell commands via keybindings. With this toolset, you can enhance your productivity and make your macOS experience smoother and more streamlined.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Usage](#usage)
    - [Clipboard Manager](#clipboard-manager)
    - [Mouse Position Control](#mouse-position-control)
    - [Shell Commands Execution](#shell-commands-execution)
4. [Contributing](#contributing)
5. [License](#license)
6. [FAQs](#faqs)
7. [Troubleshooting](#troubleshooting)
8. [Known Issues](#known-issues)

## Prerequisites

- **macOS**: The scripts are tailored for macOS, leveraging the capabilities of Hammerspoon.
  
- **Hammerspoon**: Ensure that you have [Hammerspoon](https://www.hammerspoon.org/) installed. It's a bridge between the operating system and a Lua scripting engine.

## Installation

1. **Clone this Repository**: 
    ```bash
    git clone https://github.com/zengtianli/hammerspoon.git
    ```

2. **Navigate to Hammerspoon Configuration Folder**:
    ```bash
    cd ~/.hammerspoon/
    ```

3. **Copy the Script**: Move the cloned Lua script to the Hammerspoon configuration directory or incorporate its functionalities into your existing `init.lua`.

4. **Reload Hammerspoon**: Use the Hammerspoon menu icon to reload the configuration or press the default `cmd + ctrl + shift + reload` key combination.

## Usage

### Clipboard Manager

#### Keybindings:
- Combine Clipboard Histories: `cmd + alt + C`
- Clear Clipboard History: `cmd + alt + ctrl + C`

### Mouse Position Control

Record, recall, and manipulate mouse positions across different apps.

#### Keybindings:
- Record mouse position for the active app: `cmd + ctrl + shift + R`
- Clear recorded positions for the active app: `cmd + ctrl + shift + C`
- Move mouse to a specified position (1, 2, or 3) for the active app: `cmd + ctrl + shift + [1/2/3]`
- Move mouse to next/previous recorded position: `alt + tab` / `alt + shift + tab`

### Shell Commands Execution

Trigger specific shell commands via keybindings.

#### Keybindings:
(Replace `shellScripts.[command]` with actual commands or scripts you've defined.)

- Toggle Yabai: `cmd + shift + y`
- Close Window: `cmd + shift + w`
- Toggle Floating Tiling: `cmd + shift + l`
- Swap with Next or Move to First: `cmd + shift + j`
- Toggle Fullscreen: `cmd + ctrl + f`
- Focus on Next or Move to First: `cmd + j`

### Application Quick Launch

Launch frequently-used applications with custom shortcuts.

#### Keybindings:
- Arc: `cmd + ctrl + shift + A`
- DingTalk: `cmd + ctrl + shift + D`
- Finder: `cmd + ctrl + shift + F`
... *(list continues for each application)* ...
- Obsidian: `cmd + ctrl + shift + /`
- Custom Script (obs.sh): `cmd + ctrl + alt + shift + o`
- System Settings: `cmd + option + ,`

Additionally, some apps like `ClashX Pro` have extra functions:
- Open `ClashX Pro` in rule mode: `cmd + ctrl + shift + l`
- Open `ClashX Pro` in global mode: `cmd + ctrl + shift + g`

### Application Hotkey Toggle

Enable or disable the application launch shortcuts.

- Enable/Disable App Hotkeys: `cmd + ctrl + shift + alt + t`

### Quick Note Dialog Hotkey

Toggle the hotkey for the Quick Note Dialog feature.

- Enable/Disable Quick Note Hotkey: `cmd + shift + alt + ctrl + N`

---

Note: The script initializes with application hotkeys enabled by default. Adjust as necessary for your personal preference.
## Contributing

Contributions are welcome! If you find a bug or would like to add a new feature, feel free to create an issue or open a pull request.

## License

This project is licensed under the MIT License. For more details, see the [LICENSE](./LICENSE) file.

## FAQs

* **Q**: I'm new to Hammerspoon. How can I get started?
  
  **A**: Check out the [official Hammerspoon documentation](https://www.hammerspoon.org/docs/) for a comprehensive introduction.

## Troubleshooting

- **Script not executing?** Ensure that Hammerspoon has the necessary accessibility permissions under System Preferences > Security & Privacy > Privacy.

## Known Issues

- Moving the mouse to recorded positions may not work seamlessly across multiple monitors or virtual desktops. Ensure that the app is on the same screen as the original recording.

---

For more details, questions, or feedback, please raise an issue or get in touch. Happy coding! 🚀
