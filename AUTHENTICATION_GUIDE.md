# Authentication & Scoreboard Guide

## Overview

The Typing Game now includes a complete user authentication system and global leaderboard! Track your progress, compete with friends, and see your typing skills improve over time.

## New Features

### 1. User Authentication
- **Register**: Create a new account with username and password
- **Login**: Securely login to access your profile
- **Password Protection**: Passwords are hashed using base64 encoding
- **User Isolation**: Each user has their own score history

### 2. Score Tracking
Every game you play is automatically saved with:
- Date and time of the game
- Difficulty level (Easy/Medium/Hard)
- Accuracy percentage
- Words Per Minute (WPM)
- Number of correct/total sentences

### 3. Leaderboards
- **Global Leaderboard**: Top 10 players ranked by WPM
- **Personal History**: View your last 10 games
- **Statistics**: Track your improvement over time

## How to Use

### First Time Setup

1. **Start the game**
   ```bash
   # Using Docker with persistent data
   docker run --rm -it -v typing-game-data:/root/.typing_game typing-game
   
   # Or using WSL
   wsl bash -c "./typing_game.sh"
   ```

2. **Register a new account**
   - Select option `2` (Register)
   - Enter a unique username (no spaces)
   - Enter a password
   - Confirm your password
   - You'll see: ✓ Registration successful!

3. **Login**
   - Select option `1` (Login)
   - Enter your username and password
   - You'll be taken to the main menu

### Playing Games

After logging in:
1. Select `1` to Play Game
2. Choose difficulty (Easy/Medium/Hard)
3. Choose category (Programming/Linux/Quotes/General)
4. Type the sentences as they appear
5. Your score is automatically saved!

### Viewing Statistics

From the main menu:
1. Select `2` for Statistics & Leaderboard
2. Choose:
   - `1` to see the Global Leaderboard (top players)
   - `2` to see Your Score History (your recent games)

### Sample Session

```
TYPING GAME - AUTHENTICATION
═══════════════════════════════
1) Login
2) Register
3) Exit

Enter your choice: 2

USER REGISTRATION
═══════════════════════════════
Enter username: alice
Enter password: ****
Confirm password: ****

✓ Registration successful! You can now login.

Enter your choice: 1

USER LOGIN
═══════════════════════════════
Enter username: alice
Enter password: ****

✓ Login successful! Welcome, alice!

TYPING GAME - Welcome alice!
═══════════════════════════════
1) Play Game
2) View Statistics & Leaderboard
3) Logout
```

## Data Persistence

### Using Docker with Volumes (Recommended)

Data is stored in a named Docker volume and persists between sessions:

```bash
# Create and use persistent volume
docker run --rm -it -v typing-game-data:/root/.typing_game typing-game

# Your scores and login info are saved!
# Run again later with the same volume:
docker run --rm -it -v typing-game-data:/root/.typing_game typing-game
```

### Without Docker (Local)

Data is stored in `~/.typing_game/` directory:
- `users.txt` - User credentials
- `scores.txt` - All game scores

## Security Notes

⚠️ **Important**: This implementation uses simple base64 encoding for passwords. This is **NOT secure** for production use. For a real application, you should use proper password hashing algorithms like bcrypt, scrypt, or argon2.

The current implementation is designed for:
- Educational purposes
- Local single-user systems
- Practice and learning

## Tips for Best Scores

1. **Start with Easy**: Build accuracy before speed
2. **Choose Your Category**: Pick topics you're familiar with
3. **Practice Regularly**: Your WPM will improve over time
4. **Check the Leaderboard**: See what the top players achieve
5. **Review Your History**: Track your improvement trends

## Leaderboard Ranking

Players are ranked by:
1. **Primary**: WPM (Words Per Minute) - higher is better
2. **Secondary**: Accuracy percentage
3. **Display**: Top 10 scores are shown

## Troubleshooting

### "Username already exists"
- The username is taken. Try logging in or choose a different username.

### "Passwords don't match"
- Make sure you type the same password twice during registration.

### "Username not found"
- You need to register first. Select option 2 from the login menu.

### Data not persisting in Docker
- Make sure you're using a volume: `-v typing-game-data:/root/.typing_game`
- Use the same volume name each time you run the container

### Can't see my old scores
- Ensure you're logged in with the correct username
- Check that you used the persistent volume (Docker)

## Advanced: Manual Data Management

### View all users (Linux/WSL)
```bash
cat ~/.typing_game/users.txt
```

### View all scores
```bash
cat ~/.typing_game/scores.txt
```

### Backup your data
```bash
# Local
cp -r ~/.typing_game ~/.typing_game.backup

# Docker volume
docker run --rm -v typing-game-data:/data -v $(pwd):/backup ubuntu tar czf /backup/typing-game-backup.tar.gz /data
```

### Reset everything
```bash
# Local
rm -rf ~/.typing_game

# Docker volume
docker volume rm typing-game-data
```

## Future Enhancements Ideas

- Export scores to CSV
- Challenge mode (compete against previous scores)
- Achievements and badges
- Daily/weekly challenges
- Friend system and direct challenges
- More secure password hashing
- Email verification
- Password reset functionality

Enjoy the game and happy typing! 🎮⌨️
