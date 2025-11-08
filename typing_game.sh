#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
CORRECT=0
TOTAL=0
DIFFICULTY=1
START_TIME=0
TOTAL_CHARS=0

# Authentication and data files
DATA_DIR="$HOME/.typing_game"
USERS_FILE="$DATA_DIR/users.txt"
SCORES_FILE="$DATA_DIR/scores.txt"
CURRENT_USER=""

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"
touch "$USERS_FILE"
touch "$SCORES_FILE"

# ==================== AUTHENTICATION FUNCTIONS ====================

# Simple password hashing (using base64 encoding for simplicity)
hash_password() {
    local password="$1"
    echo -n "$password" | base64
}

# Register new user
register_user() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}          USER REGISTRATION            ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    
    read -p "Enter username: " username
    
    # Check if username already exists
    if grep -q "^$username:" "$USERS_FILE"; then
        echo -e "${RED}Username already exists! Please try logging in.${NC}"
        sleep 2
        return 1
    fi
    
    # Validate username
    if [[ -z "$username" ]] || [[ "$username" =~ [[:space:]] ]]; then
        echo -e "${RED}Invalid username! No spaces allowed.${NC}"
        sleep 2
        return 1
    fi
    
    read -s -p "Enter password: " password
    echo ""
    read -s -p "Confirm password: " password2
    echo ""
    
    if [ "$password" != "$password2" ]; then
        echo -e "${RED}Passwords don't match!${NC}"
        sleep 2
        return 1
    fi
    
    if [ -z "$password" ]; then
        echo -e "${RED}Password cannot be empty!${NC}"
        sleep 2
        return 1
    fi
    
    # Hash password and store
    local hashed=$(hash_password "$password")
    echo "$username:$hashed" >> "$USERS_FILE"
    
    echo ""
    echo -e "${GREEN}✓ Registration successful! You can now login.${NC}"
    sleep 2
    return 0
}

# Login user
login_user() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}             USER LOGIN                ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    
    read -p "Enter username: " username
    read -s -p "Enter password: " password
    echo ""
    
    # Check if user exists
    local stored_hash=$(grep "^$username:" "$USERS_FILE" | cut -d':' -f2)
    
    if [ -z "$stored_hash" ]; then
        echo -e "${RED}Username not found!${NC}"
        sleep 2
        return 1
    fi
    
    # Verify password
    local input_hash=$(hash_password "$password")
    
    if [ "$input_hash" = "$stored_hash" ]; then
        CURRENT_USER="$username"
        echo ""
        echo -e "${GREEN}✓ Login successful! Welcome, $username!${NC}"
        sleep 2
        return 0
    else
        echo -e "${RED}Incorrect password!${NC}"
        sleep 2
        return 1
    fi
}

# Authentication menu
auth_menu() {
    while true; do
        clear
        echo -e "${YELLOW}═══════════════════════════════════════${NC}"
        echo -e "${YELLOW}       TYPING GAME - AUTHENTICATION   ${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Login"
        echo -e "${GREEN}2)${NC} Register"
        echo -e "${GREEN}3)${NC} Exit"
        echo ""
        read -p "Enter your choice (1-3): " choice
        
        case $choice in
            1)
                if login_user; then
                    return 0
                fi
                ;;
            2)
                register_user
                ;;
            3)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                sleep 1
                ;;
        esac
    done
}

# ==================== SCOREBOARD FUNCTIONS ====================

# Save score to file
save_score() {
    local accuracy=$1
    local wpm=$2
    local difficulty=$3
    local date_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Format: username|date|difficulty|accuracy|wpm|correct|total
    echo "$CURRENT_USER|$date_time|$difficulty|$accuracy|$wpm|$CORRECT|$TOTAL" >> "$SCORES_FILE"
}

# Show user's personal scores
show_personal_scores() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}              YOUR SCORE HISTORY - $CURRENT_USER                ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if ! grep -q "^$CURRENT_USER|" "$SCORES_FILE"; then
        echo -e "${YELLOW}No scores yet. Play a game to set your first score!${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${GREEN}Date & Time          | Difficulty | Accuracy | WPM  | Score${NC}"
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
    
    grep "^$CURRENT_USER|" "$SCORES_FILE" | tail -n 10 | while IFS='|' read -r user date_time difficulty accuracy wpm correct total; do
        printf "%-19s | %-10s | %7s%% | %4s | %d/%d\n" "$date_time" "$difficulty" "$accuracy" "$wpm" "$correct" "$total"
    done
    
    echo ""
    read -p "Press Enter to continue..."
}

# Show global leaderboard
show_leaderboard() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    GLOBAL LEADERBOARD                         ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ ! -s "$SCORES_FILE" ]; then
        echo -e "${YELLOW}No scores recorded yet. Be the first to play!${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${GREEN}Rank | Username        | WPM  | Accuracy | Difficulty | Date${NC}"
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
    
    # Sort by WPM (descending), then by accuracy
    sort -t'|' -k5 -nr "$SCORES_FILE" | head -n 10 | nl | while read -r rank line; do
        IFS='|' read -r user date_time difficulty accuracy wpm correct total <<< "$line"
        printf "%4d | %-15s | %4s | %7s%% | %-10s | %s\n" "$rank" "$user" "$wpm" "$accuracy" "$difficulty" "${date_time%% *}"
    done
    
    echo ""
    echo -e "${YELLOW}Top 10 players by WPM${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Show statistics menu
stats_menu() {
    while true; do
        clear
        echo -e "${YELLOW}═══════════════════════════════════════${NC}"
        echo -e "${YELLOW}          STATISTICS & SCORES          ${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} View Global Leaderboard"
        echo -e "${GREEN}2)${NC} View Your Score History"
        echo -e "${GREEN}3)${NC} Back to Main Menu"
        echo ""
        read -p "Enter your choice (1-3): " choice
        
        case $choice in
            1)
                show_leaderboard
                ;;
            2)
                show_personal_scores
                ;;
            3)
                return
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                sleep 1
                ;;
        esac
    done
}

# ==================== GAME FUNCTIONS ====================

draw_border() {
    local width=60
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
}

draw_bottom_border() {
    local width=60
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
}

# Function to center text
center_text() {
    local text="$1"
    local width=60
    local len=${#text}
    local padding=$(( (width - len) / 2 ))
    printf "${CYAN}║${NC}%*s%s%*s${CYAN}║${NC}\n" $padding "" "$text" $((width - padding - len)) ""
}

# Welcome screen
show_welcome() {
    clear
    draw_border
    center_text ""
    center_text "╔════════════════════════════════════════╗"
    center_text "║     🎮 TYPING SPEED GAME 🎮           ║"
    center_text "╚════════════════════════════════════════╝"
    center_text ""
    draw_bottom_border
    echo ""
    sleep 2
}

# Mode selection menu
select_difficulty() {
    clear
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}        Select Difficulty Level        ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}1)${NC} Easy   (5 sentences, short)"
    echo -e "${GREEN}2)${NC} Medium (8 sentences, medium length)"
    echo -e "${GREEN}3)${NC} Hard   (10 sentences, longer)"
    echo ""
    read -p "Enter your choice (1-3): " DIFFICULTY
    
    case $DIFFICULTY in
        1) ROUNDS=5; DIFF_LEVEL="EASY" ;;
        2) ROUNDS=8; DIFF_LEVEL="MEDIUM" ;;
        3) ROUNDS=10; DIFF_LEVEL="HARD" ;;
        *) ROUNDS=5; DIFF_LEVEL="EASY"; DIFFICULTY=1 ;;
    esac
}

# Category selection menu
select_category() {
    clear
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}      Select Typing Category          ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}1)${NC} Programming (code and tech terms)"
    echo -e "${GREEN}2)${NC} Linux Commands (shell commands)"
    echo -e "${GREEN}3)${NC} Quotes (inspirational quotes)"
    echo -e "${GREEN}4)${NC} General (everyday sentences)"
    echo ""
    read -p "Enter your choice (1-4): " CATEGORY
}

# Generate sentence based on category and difficulty
generate_sentence() {
    local diff=$1
    
    case $CATEGORY in
        1) # Programming
            case $diff in
                "EASY")
                    sentences=(
                        "print hello world"
                        "def main function"
                        "return true"
                        "import sys os"
                        "class MyClass"
                        "for i in range"
                        "if x equals y"
                        "while loop true"
                        "try except block"
                        "list append item"
                    )
                    ;;
                "MEDIUM")
                    sentences=(
                        "docker run -it ubuntu bash"
                        "git commit -m initial commit"
                        "pip install numpy pandas"
                        "function getData() returns array"
                        "const express require express"
                        "sudo apt-get update upgrade"
                        "npm install react redux"
                        "import pandas as pd"
                        "kubectl get pods all namespaces"
                        "terraform apply auto approve"
                    )
                    ;;
                "HARD")
                    sentences=(
                        "podman run --name mycontainer -v /data:/mnt ubuntu:latest"
                        "git rebase -i HEAD~3 && git push origin main --force"
                        "docker-compose up -d --build --scale web=3"
                        "const result = await fetch(url).then(res => res.json())"
                        "SELECT users.name FROM users JOIN orders ON users.id = orders.user_id"
                        "kubectl apply -f deployment.yaml --namespace production"
                        "find . -type f -name '*.log' -mtime +7 -delete"
                        "awk '{sum+=\$1} END {print sum/NR}' data.txt"
                        "sed -i 's/old-text/new-text/g' *.conf"
                        "tar -czf backup-$(date +%Y%m%d).tar.gz /home/user"
                    )
                    ;;
            esac
            ;;
        2) # Linux Commands
            case $diff in
                "EASY")
                    sentences=(
                        "ls -la"
                        "cd /home"
                        "mkdir new_folder"
                        "pwd"
                        "cat file.txt"
                        "cp file dest"
                        "mv old new"
                        "rm file.txt"
                        "chmod +x script"
                        "echo hello world"
                    )
                    ;;
                "MEDIUM")
                    sentences=(
                        "grep -r pattern ."
                        "find . -name *.txt"
                        "ps aux | grep process"
                        "tar -xzf archive.tar.gz"
                        "curl -X GET https://api.example.com"
                        "ssh user@hostname"
                        "scp file.txt user@server:/path"
                        "df -h"
                        "du -sh *"
                        "top -n 1"
                    )
                    ;;
                "HARD")
                    sentences=(
                        "rsync -avz --progress /source/ user@remote:/destination/"
                        "iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
                        "for file in *.txt; do sed -i 's/old/new/g' \$file; done"
                        "netstat -tulpn | grep LISTEN"
                        "journalctl -u nginx.service --since today"
                        "lsof -i :8080 | awk 'NR!=1 {print \$2}' | xargs kill -9"
                        "strace -p \$(pgrep -f process_name) -o output.log"
                        "watch -n 5 'docker ps --format \"table {{.Names}}\\t{{.Status}}\"'"
                        "systemctl list-units --type=service --state=running"
                        "mount -t nfs server:/export /mnt/nfs -o nolock"
                    )
                    ;;
            esac
            ;;
        3) # Quotes
            case $diff in
                "EASY")
                    sentences=(
                        "Practice makes perfect."
                        "Time is precious."
                        "Knowledge is power."
                        "Dream big and dare."
                        "Never give up trying."
                        "Be kind to others."
                        "Learn something new daily."
                        "Stay positive always."
                        "Work hard play hard."
                        "Believe in yourself."
                    )
                    ;;
                "MEDIUM")
                    sentences=(
                        "The only way to do great work is to love what you do."
                        "Success is not final failure is not fatal."
                        "Innovation distinguishes between a leader and a follower."
                        "Your time is limited so don't waste it living someone else's life."
                        "The best time to plant a tree was twenty years ago."
                        "Code is like humor. When you have to explain it, it's bad."
                        "First solve the problem. Then write the code."
                        "Any fool can write code that a computer can understand."
                        "Simplicity is the soul of efficiency."
                        "Make it work make it right make it fast."
                    )
                    ;;
                "HARD")
                    sentences=(
                        "The function of good software is to make the complex appear to be simple."
                        "Programming isn't about what you know it's about what you can figure out."
                        "The most disastrous thing that you can ever learn is your first programming language."
                        "Debugging is twice as hard as writing the code in the first place."
                        "Any sufficiently advanced technology is indistinguishable from magic."
                        "The best error message is the one that never shows up."
                        "If you optimize everything you will always be unhappy."
                        "Premature optimization is the root of all evil in programming."
                        "Walking on water and developing software from a specification are easy if both are frozen."
                        "There are only two hard things in Computer Science cache invalidation and naming things."
                    )
                    ;;
            esac
            ;;
        4) # General
            case $diff in
                "EASY")
                    sentences=(
                        "The sun is shining."
                        "Coffee tastes great."
                        "Music makes me happy."
                        "I love learning."
                        "Books are wonderful."
                        "Exercise is healthy."
                        "Friends are important."
                        "Travel broadens minds."
                        "Nature is beautiful."
                        "Kindness matters most."
                    )
                    ;;
                "MEDIUM")
                    sentences=(
                        "The quick brown fox jumps over the lazy dog."
                        "A journey of a thousand miles begins with a single step."
                        "Technology is best when it brings people together."
                        "Reading is to the mind what exercise is to the body."
                        "The only impossible journey is the one you never begin."
                        "Life is what happens when you're busy making other plans."
                        "The future belongs to those who believe in their dreams."
                        "Every accomplishment starts with the decision to try."
                        "Success is the sum of small efforts repeated daily."
                        "Change your thoughts and you change your world."
                    )
                    ;;
                "HARD")
                    sentences=(
                        "In the midst of chaos there is also opportunity to learn and grow stronger."
                        "The difference between ordinary and extraordinary is that little extra effort you put in."
                        "Twenty years from now you will be more disappointed by the things you didn't do."
                        "Education is the most powerful weapon which you can use to change the world completely."
                        "The greatest glory in living lies not in never falling but in rising every time we fall."
                        "Your work is going to fill a large part of your life and the only way to be truly satisfied."
                        "If you set your goals ridiculously high and it's a failure you will fail above everyone else's success."
                        "The way to get started is to quit talking and begin doing what needs to be done right now."
                        "Don't watch the clock do what it does keep going and never stop until you reach your goal."
                        "Believe you can and you're halfway there to achieving everything you've ever dreamed about."
                    )
                    ;;
            esac
            ;;
    esac
    
    # Return random sentence from array
    echo "${sentences[$((RANDOM % ${#sentences[@]}))]}"
}

# Calculate WPM (Words Per Minute)
calculate_wpm() {
    local chars=$1
    local seconds=$2
    
    if [ $seconds -eq 0 ]; then
        echo "0"
    else
        local words=$(echo "scale=2; $chars / 5" | bc)
        local minutes=$(echo "scale=2; $seconds / 60" | bc)
        local wpm=$(echo "scale=0; $words / $minutes" | bc)
        echo $wpm
    fi
}

# Main game loop
play_game() {
    clear
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
    echo -e "${MAGENTA}         Game Starting in 3...         ${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
    sleep 1
    clear
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
    echo -e "${MAGENTA}         Game Starting in 2...         ${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
    sleep 1
    clear
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
    echo -e "${MAGENTA}         Game Starting in 1...         ${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
    sleep 1
    
    START_TIME=$(date +%s)
    
    for ((i=1; i<=ROUNDS; i++)); do
        clear
        TARGET=$(generate_sentence "$DIFF_LEVEL")
        TARGET_LEN=${#TARGET}
        TOTAL_CHARS=$((TOTAL_CHARS + TARGET_LEN))
        
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}Progress: [$i/$ROUNDS] | Accuracy: $((TOTAL == 0 ? 0 : CORRECT * 100 / TOTAL))%${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}Type this sentence:${NC}"
        echo -e "${RED}$TARGET${NC}"
        echo ""
        echo -e "${BLUE}Your input:${NC}"
        
        read USER_INPUT
        TOTAL=$((TOTAL + 1))
        
        if [ "$USER_INPUT" = "$TARGET" ]; then
            CORRECT=$((CORRECT + 1))
            echo ""
            echo -e "${GREEN}✓ Perfect! Exactly correct!${NC}"
        else
            echo ""
            echo -e "${RED}✗ Not quite right!${NC}"
            echo -e "${YELLOW}Expected: ${NC}$TARGET"
            echo -e "${YELLOW}You typed: ${NC}$USER_INPUT"
        fi
        sleep 2
    done
    
    show_results
}

# Show final results
show_results() {
    clear
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    ACCURACY=$((TOTAL == 0 ? 0 : CORRECT * 100 / TOTAL))
    WPM=$(calculate_wpm $TOTAL_CHARS $ELAPSED)
    
    # Save score to file
    save_score "$ACCURACY" "$WPM" "$DIFF_LEVEL"
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}              GAME OVER - RESULTS                      ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${MAGENTA}Player: $CURRENT_USER${NC}"
    echo ""
    echo -e "${GREEN}📊 Statistics:${NC}"
    echo -e "   Total Sentences: $TOTAL"
    echo -e "   Correct: $CORRECT"
    echo -e "   Wrong: $((TOTAL - CORRECT))"
    echo -e "   Accuracy: ${YELLOW}$ACCURACY%${NC}"
    echo ""
    echo -e "${BLUE}⚡ Speed:${NC}"
    echo -e "   Total Characters: $TOTAL_CHARS"
    echo -e "   Time Taken: ${ELAPSED}s"
    echo -e "   Speed (WPM): ${YELLOW}$WPM${NC} words per minute"
    echo ""
    
    if [ $ACCURACY -eq 100 ]; then
        echo -e "${GREEN}🏆 PERFECT SCORE! You're a typing legend!${NC}"
    elif [ $ACCURACY -ge 80 ]; then
        echo -e "${GREEN}🌟 Excellent! You're doing great!${NC}"
    elif [ $ACCURACY -ge 60 ]; then
        echo -e "${YELLOW}👍 Good job! Keep practicing!${NC}"
    else
        echo -e "${RED}💪 Keep practicing! You'll improve!${NC}"
    fi
    
    # WPM feedback
    if [ $WPM -ge 60 ]; then
        echo -e "${GREEN}🚀 Amazing speed! You type faster than average!${NC}"
    elif [ $WPM -ge 40 ]; then
        echo -e "${YELLOW}⚡ Good speed! Above average typist!${NC}"
    elif [ $WPM -ge 20 ]; then
        echo -e "${YELLOW}📈 Decent speed! Room for improvement!${NC}"
    else
        echo -e "${BLUE}🎯 Focus on accuracy first, speed will come!${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Score saved to your profile!${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Signal handler for graceful exit
trap 'echo -e "\n${RED}Game interrupted. Thanks for playing!${NC}"; exit 0' SIGINT SIGTERM

# Main menu after login
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${CYAN}     TYPING GAME - Welcome $CURRENT_USER! ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Play Game"
        echo -e "${GREEN}2)${NC} View Statistics & Leaderboard"
        echo -e "${GREEN}3)${NC} Logout"
        echo ""
        read -p "Enter your choice (1-3): " choice
        
        case $choice in
            1)
                CORRECT=0
                TOTAL=0
                TOTAL_CHARS=0
                show_welcome
                select_difficulty
                select_category
                play_game
                ;;
            2)
                stats_menu
                ;;
            3)
                echo -e "${GREEN}Logging out... Thanks for playing!${NC}"
                CURRENT_USER=""
                sleep 1
                return
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Main function
main() {
    # Authenticate user first
    auth_menu
    
    # Show main menu after successful login
    main_menu
}

# Start the game
main

