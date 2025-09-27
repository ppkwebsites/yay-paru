#!/bin/bash

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check for pacman database lock
check_pacman_lock() {
    if [ -f /var/lib/pacman/db.lck ]; then
        echo -e "${RED}Pacman database is locked (/var/lib/pacman/db.lck).${NC}"
        echo -e "${YELLOW}Please remove the lock file with 'sudo rm /var/lib/pacman/db.lck' and try again.${NC}"
        exit 1
    fi
}

# Function to check sudo authentication
check_sudo() {
    echo -e "${YELLOW}Testing sudo authentication...${NC}"
    sudo -v || {
        echo -e "${RED}Sudo authentication failed. Please ensure you can run sudo commands and try again.${NC}"
        exit 1
    }
}

# Function to remove package with multiple attempts
remove_package() {
    local pkg=$1
    if pacman -Q "$pkg" >/dev/null 2>&1; then
        echo -e "${YELLOW}Attempting to remove $pkg...${NC}"
        # Attempt 1: Standard removal
        sudo pacman -Rns --noconfirm "$pkg" && return 0
        echo -e "${RED}Standard removal failed for $pkg. Trying with --noconfirm and --nodeps...${NC}"
        # Attempt 2: Force removal with --nodeps
        sudo pacman -Rns --noconfirm --nodeps "$pkg" && return 0
        echo -e "${RED}Force removal failed for $pkg. Trying to remove package database entry...${NC}"
        # Attempt 3: Remove from pacman database
        sudo pacman -Rdd --noconfirm "$pkg" && return 0
        echo -e "${RED}All attempts to remove $pkg failed. Please check manually and try again.${NC}"
        exit 1
    fi
}

# Function to remove directory with multiple attempts
remove_directory() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}Attempting to remove directory $dir...${NC}"
        # Attempt 1: Standard removal
        rm -rf "$dir" && return 0
        echo -e "${RED}Standard removal failed for $dir. Trying with sudo...${NC}"
        # Attempt 2: Sudo removal
        sudo rm -rf "$dir" && return 0
        echo -e "${RED}Sudo removal failed for $dir. Trying to fix permissions and remove...${NC}"
        # Attempt 3: Fix permissions and remove
        sudo chmod -R 777 "$dir" && sudo rm -rf "$dir" && return 0
        echo -e "${RED}All attempts to remove $dir failed. Please check manually and try again.${NC}"
        exit 1
    fi
}

# Run full system update
print_header "Running Full Arch System Update"
check_pacman_lock
check_sudo
echo -e "${YELLOW}Updating your Arch Linux system...${NC}"
sudo pacman -Syu --noconfirm || {
    echo -e "${RED}Failed to update system. Exiting...${NC}"
    exit 1
}
echo -e "${GREEN}System update completed successfully!${NC}"
echo

# Introduction and explanation
print_header "AUR Helper Installation Script"
echo -e "${YELLOW}This script will install an AUR helper on your Arch Linux system.${NC}"
echo
echo -e "${GREEN}What are AUR Helpers?${NC}"
echo "AUR helpers simplify installing and managing packages from the Arch User Repository (AUR)."
echo
echo -e "${GREEN}Yay vs Paru:${NC}"
echo -e "  ${YELLOW}Yay:${NC} Written in Go, user-friendly, fast, and widely used. Great for most users."
echo -e "  ${YELLOW}Paru:${NC} Written in Rust, lightweight, similar to Yay but with a focus on simplicity and speed."
echo
echo -e "${GREEN}Please choose an AUR helper to install:${NC}"
echo -e "  ${YELLOW}1)${NC} Yay"
echo -e "  ${YELLOW}2)${NC} Paru"
echo

# Prompt for user choice
read -p "Enter your choice (1 or 2): " choice

# Check if git is installed (required for both yay and paru)
if ! command_exists git; then
    echo -e "${RED}Error: git is not installed. Installing it now...${NC}"
    check_pacman_lock
    check_sudo
    sudo pacman -S --noconfirm git || {
        echo -e "${RED}Failed to install git. Exiting...${NC}"
        exit 1
    }
fi

# Check and install dependencies based on user choice
case $choice in
    1)
        print_header "Checking and Removing Paru"
        check_pacman_lock
        check_sudo
        # Remove paru and paru-git if installed
        for pkg in paru paru-git; do
            remove_package "$pkg"
        done
        # Remove any leftover paru directories
        remove_directory "/tmp/paru"
        remove_directory "$HOME/.cache/paru"

        print_header "Checking Yay Dependencies"
        # Check if base-devel is installed
        if ! pacman -Q base-devel >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing base-devel for Yay...${NC}"
            sudo pacman -S --noconfirm base-devel || {
                echo -e "${RED}Failed to install base-devel. Exiting...${NC}"
                exit 1
            }
        else
            echo -e "${GREEN}base-devel is already installed.${NC}"
        fi
        # Remove yay and yay-git if installed
        for pkg in yay yay-git; do
            remove_package "$pkg"
        done
        echo -e "${GREEN}Yay dependencies and conflicts checked!${NC}"
        echo
        ;;
    2)
        print_header "Checking and Removing Yay"
        check_pacman_lock
        check_sudo
        # Remove yay and yay-git if installed
        for pkg in yay yay-git; do
            remove_package "$pkg"
        done
        # Remove any leftover yay directories
        remove_directory "/tmp/yay"
        remove_directory "$HOME/.cache/yay"

        print_header "Checking Paru Dependencies"
        # Check if base-devel is installed
        if ! pacman -Q base-devel >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing base-devel for Paru...${NC}"
            sudo pacman -S --noconfirm base-devel || {
                echo -e "${RED}Failed to install base-devel. Exiting...${NC}"
                exit 1
            }
        else
            echo -e "${GREEN}base-devel is already installed.${NC}"
        fi
        # Check if cargo is installed
        if ! command_exists cargo; then
            echo -e "${YELLOW}Installing cargo for Paru...${NC}"
            sudo pacman -S --noconfirm cargo || {
                echo -e "${RED}Failed to install cargo. Exiting...${NC}"
                exit 1
            }
        else
            echo -e "${GREEN}cargo is already installed.${NC}"
        fi
        echo -e "${GREEN}Paru dependencies and conflicts checked!${NC}"
        echo
        ;;
    *)
        echo -e "${RED}Invalid choice. Please run the script again and select 1 or 2.${NC}"
        exit 1
        ;;
esac

# Install Yay or Paru based on user choice
case $choice in
    1)
        print_header "Installing Yay"
        remove_directory "/tmp/yay"
        mkdir -p "/tmp/yay" || {
            echo -e "${RED}Failed to create /tmp/yay. Exiting...${NC}"
            exit 1
        }
        chmod 700 "/tmp/yay" || {
            echo -e "${RED}Failed to set permissions for /tmp/yay. Exiting...${NC}"
            exit 1
        }
        git clone https://aur.archlinux.org/yay.git /tmp/yay || {
            echo -e "${RED}Failed to clone Yay repository. Exiting...${NC}"
            exit 1
        }
        cd /tmp/yay
        makepkg -si --noconfirm || {
            echo -e "${RED}Failed to install Yay. Exiting...${NC}"
            exit 1
        }
        echo -e "${GREEN}Yay installed successfully!${NC}"
        ;;
    2)
        print_header "Installing Paru"
        remove_directory "/tmp/paru"
        mkdir -p "/tmp/paru" || {
            echo -e "${RED}Failed to create /tmp/paru. Exiting...${NC}"
            exit 1
        }
        chmod 700 "/tmp/paru" || {
            echo -e "${RED}Failed to set permissions for /tmp/paru. Exiting...${NC}"
            exit 1
        }
        git clone https://aur.archlinux.org/paru.git /tmp/paru || {
            echo -e "${RED}Failed to clone Paru repository. Exiting...${NC}"
            exit 1
        }
        cd /tmp/paru
        makepkg -si --noconfirm || {
            echo -e "${RED}Failed to install Paru. Exiting...${NC}"
            exit 1
        }
        echo -e "${GREEN}Paru installed successfully!${NC}"
        ;;
esac

# Clean up
remove_directory "/tmp/yay"
remove_directory "/tmp/paru"
echo -e "${GREEN}Cleanup completed. You're all set!${NC}"
echo -e "${BLUE}=====================================${NC}"
