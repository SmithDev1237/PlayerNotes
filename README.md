# PlayerNotes

**PlayerNotes** is an Ashita addon for Final Fantasy XI that allows you to record and view notes, ratings, and linkshell details for other players. When you target a player, any saved information is displayed, helping you remember interactions, impressions, and key details about other players.

## Features
- **Record Notes**: Save custom notes for each player.
- **Player Ratings**: Rate players on a 5-star scale, with color-coded feedback.
- **Linkshell Tracking**: Track players' linkshell affiliations for easy reference.
- **Configurable UI**: Advanced window for viewing and managing all recorded players.

## Installation

1. **Download the repository**:
git clone https://github.com/SmithDev1237/PlayerNotes.git

2. **Place the Addon in the Ashita Addons Folder**:  
Copy the `PlayerNotes` folder to your Ashita `addons` directory:  
`Ashita\addons\PlayerNotes`

3. **Load the Addon**:  
Launch Ashita and load the addon using:  
`/addon load PlayerNotes`

## Usage

- **Viewing Notes**: Target any player to see their saved notes, rating, and linkshell information in an ImGui overlay.
- **Adding Notes**: Click on the "Config" button to open the advanced window where you can add new players or edit existing notes and ratings.
- **Editing Notes**: Use the "Edit" button next to each player’s name in the advanced window to update notes, ratings, or linkshell information.

## Configuration

PlayerNotes uses a JSON-based configuration that automatically saves your data, so notes, ratings, and linkshell details are persistent across sessions.

## Screenshots

![Main Interface](https://github.com/SmithDev1237/PlayerNotes/blob/main/img/main_interface.png)  
*Main interface displaying notes and ratings for targeted players.*

![Advanced Window](https://github.com/SmithDev1237/PlayerNotes/blob/main/img/advanced_window.png)  
*Advanced window for managing all saved player data.*

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions for improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
