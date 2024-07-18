# Game Blockchain Project

## Overview
This project implements a blockchain system to manage game money (DBS) in a game developed with Godot 4. The blockchain tracks transactions, mints new game money, and distributes starting capital to players. This README provides instructions on setting up and using the blockchain system in your game.

## Features
- **Blockchain**: Manages a chain of blocks, each containing transactions.
- **Mining**: Automated minting process for creating new game money (DBS).
- **Transactions**: Tracks transfers of game money between players.
- **Game Treasury**: Initializes the game treasury with a specified amount of DBS.
- **Player Capital**: Distributes starting capital to players when they join the game.
- **User Interface**: Visualizes the blockchain, minting process, and transaction logs.

## Usage

### Initial Setup

#### Blockchain Initialization:
- The blockchain is initialized automatically when the project runs. The genesis block is created at this stage.
- The game treasury is set to 1,125,000 DBS by default.

#### Minting Game Money:
- Press the "Mint" button to start the automated minting process. The system will mint 1 DBS at a time until the total minted money reaches the game treasury amount.
- Progress and status updates will be displayed in the `RichTextLabel`.

#### Saving and Loading the Blockchain:
- Use the "Save" button to save the current state of the blockchain to a file.
- Use the "Load" button to load the blockchain from a saved file. This will update the UI with the loaded blockchain data.

#### Visualizing the Blockchain:
- Press the "Visualize" button to display the entire blockchain. A popup will show each block, its transactions, and the associated hashes.

## Requirements
- Godot 4.2.2 or later

## Contributing
Contributions are welcome! Please fork the repository and submit pull requests for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
