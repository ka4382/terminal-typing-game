
## Features

- **User Authentication**: Register and login with secure password hashing
- **Personal Score Tracking**: Track your typing progress over time
- **Global Leaderboard**: Compete with other players for the top WPM score
- **Multiple Difficulty Levels**: Easy, Medium, and Hard modes
- **Multiple Categories**: Programming, Linux Commands, Quotes, and General text
- **Real-time Accuracy Tracking**: See your progress as you type
- **WPM (Words Per Minute) Calculation**: Measure your typing speed
- **Colorful Terminal UI**: Beautiful ANSI colors and special characters
- **Persistent Data**: Scores and user accounts saved between sessions

## How to Run

### Option 1: Using Docker (Recommended)

1. **Build the Docker image:**
```bash
docker build -t typing-game .
```

2. **Run with persistent data (saves your scores and login):**
```bash
docker run --rm -it -v typing-game-data:/root/.typing_game typing-game
```

3. **Run without persistence (data lost after exit):**
```bash
docker run --rm -it typing-game
```

### Option 2: Using Podman

```bash
podman build -t typing-game .
podman run --rm -it -v typing-game-data:/root/.typing_game typing-game
```

### Option 3: Run Locally (Linux/WSL/Git Bash)

```bash
chmod +x typing_game.sh
./typing_game.sh
```

For Windows PowerShell with WSL:
```powershell
wsl bash -c "cd /mnt/c/path/to/project && chmod +x typing_game.sh && ./typing_game.sh"
```

## Game Flow

1. **Register/Login**: Create an account or login with existing credentials
2. **Main Menu**: Choose to play game or view statistics
3. **Select Difficulty**: Easy (5 sentences), Medium (8), or Hard (10)
4. **Select Category**: Programming, Linux Commands, Quotes, or General
5. **Play**: Type the sentences as accurately and quickly as possible
6. **View Results**: See your accuracy, WPM, and score
7. **Leaderboard**: Compare your scores with other players

## Data Storage

User data is stored in `~/.typing_game/` directory:
- `users.txt`: Usernames and hashed passwords
- `scores.txt`: All game scores with timestamps

When using Docker with volumes, data persists between container runs.

## Technologies Used

- **Bash**: Core game logic
- **Ubuntu 22.04**: Base container image
- **Podman/Docker**: Containerization
- **Base64**: Password hashing (for demonstration purposes)
- **BC (Basic Calculator)**: WPM calculations

## Learning Outcomes

- Shell scripting fundamentals
- Terminal UI design with colors and special characters
- User input handling
- Signal handling in Bash
- Container technology (Podman/Docker)
- GitHub workflow

## Author
KARTHIK ,HEMA SAI ,RAHUL


## License
 MIT License
