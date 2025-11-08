# Quick Start Guide

## For Windows Users (PowerShell)

### Option 1: Using WSL (Fastest - No Docker needed)

```powershell
# Navigate to project directory
cd "C:\Users\aljap\Downloads\typing-game-container-main\typing-game-container-main"

# Run the game in WSL
wsl bash -c "cd /mnt/c/Users/aljap/Downloads/typing-game-container-main/typing-game-container-main && chmod +x typing_game.sh && ./typing_game.sh"
```

### Option 2: Using Docker (With Persistent Scores)

First, make sure Docker Desktop is running, then:

```powershell
# Navigate to project directory
cd "C:\Users\aljap\Downloads\typing-game-container-main\typing-game-container-main"

# Build the image (first time only)
docker build -t typing-game .

# Run with persistent data (scores and users saved)
docker run --rm -it -v typing-game-data:/root/.typing_game typing-game
```

### Option 3: Using Docker (No Persistence)

```powershell
# Build the image (if not already built)
docker build -t typing-game .

# Run without saving data
docker run --rm -it typing-game
```

## For Linux/Mac Users

### Option 1: Run Directly

```bash
cd /path/to/typing-game-container-main
chmod +x typing_game.sh
./typing_game.sh
```

### Option 2: Using Docker

```bash
# Build
docker build -t typing-game .

# Run with persistence
docker run --rm -it -v typing-game-data:/root/.typing_game typing-game
```

## First Time Playing

1. **Register** a new account:
   - Choose option `2` at login screen
   - Enter username (no spaces)
   - Create password
   - Confirm password

2. **Login**:
   - Choose option `1`
   - Enter your credentials

3. **Play**:
   - Select `Play Game` from main menu
   - Choose difficulty level
   - Choose category
   - Start typing!

4. **View Scores**:
   - Select `View Statistics & Leaderboard`
   - See global rankings or your personal history

## Managing Docker Volume (Persistent Data)

### View your saved data location
```powershell
docker volume inspect typing-game-data
```

### Backup your data
```powershell
docker run --rm -v typing-game-data:/data -v ${PWD}:/backup ubuntu tar czf /backup/typing-game-backup.tar.gz -C /data .
```

### Delete all data (start fresh)
```powershell
docker volume rm typing-game-data
```

## Troubleshooting

### Docker error: "cannot find file specified"
- Start Docker Desktop and wait for it to fully initialize
- Look for the whale icon in system tray (should be steady, not animated)

### Can't run bash script on Windows
- Use WSL or Docker (bash doesn't run natively in PowerShell)
- Or install Git Bash and run from there

### Scores not saving
- Make sure you use the `-v` volume flag with Docker
- Use the same volume name each time: `typing-game-data:/root/.typing_game`

### Colors not showing properly
- Use Windows Terminal, WSL, or Docker (better ANSI color support)
- Avoid old cmd.exe or basic PowerShell console

## Quick Commands Cheat Sheet

```powershell
# WSL - Quick run
wsl bash typing_game.sh

# Docker - Build
docker build -t typing-game .

# Docker - Run with data saved
docker run --rm -it -v typing-game-data:/root/.typing_game typing-game

# Docker - Run without saving
docker run --rm -it typing-game

# Check if WSL is available
wsl --list

# Check if Docker is running
docker ps
```

That's it! Enjoy the game! 🎮
