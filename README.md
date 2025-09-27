Arch Linux AUR Helper Installer (yay-paru.sh)
This script provides a straightforward, interactive way to install one of the two most popular Arch User Repository (AUR) helpers: Yay or Paru.

AUR helpers simplify the process of installing packages that are not available in the official Arch repositories by automating the cloning, building, and installation process. The script ensures necessary dependencies are installed before building.

Prerequisites
Before running this script, ensure you have:

An Arch Linux system (or a derivative).

Bash

chmod +x yay-paru.sh
How to Run the Script
The script must be run by your regular user account (not root) using sudo for the initial checks and package installations, but the AUR helper building process is performed as the non-root user for security reasons.

Command:

Bash

./yay-paru.sh
Script Execution Steps
When you run the script, it will follow these steps:

Initial Checks: It verifies if a pacman lock exists and checks for valid sudo authentication.

Dependency Check: It ensures that necessary packages like git and base-devel are installed.

User Choice: It presents a menu for you to select which AUR helper to install:

=====================================
AUR Helper Selection
=====================================

1) Install Yay
2) Install Paru

Please enter your choice (1 or 2):
Installation: Based on your choice, the script will:

Clone the helper's git repository into /tmp.

Use makepkg -si to build and install the package.

Cleanup: The temporary directory used for building is removed.

Example Output:

$ ./yay-paru.sh

... (Initial checks) ...

=====================================
AUR Helper Selection
=====================================
1) Install Yay
2) Install Paru

Please enter your choice (1 or 2): 1

=====================================
Installing Yay
=====================================
... (Cloning and building process messages) ...
Yay installed successfully!
Troubleshooting
If you encounter issues, consider the following:

Problem	Solution	Command
"Pacman database is locked"	Manually remove the lock file.	sudo rm /var/lib/pacman/db.lck
Missing base-devel	Install the group manually.	sudo pacman -S --noconfirm base-devel
git command not found	Install git manually.	sudo pacman -S --noconfirm git
Build failure (makepkg error)	Ensure you have successfully run the base-devel installation and check the error output. You may need to update your system first.	sudo pacman -Syu
