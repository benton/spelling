Dixie School District Spelling Bee Trainer
================
Presents spelling bee words using the OS X `say` command, and invites the user to attempt to spell the word (using the keyboard). Gives feedback.

----------------
Overview
----------------
This app is a quick hack, written to help my child study for an upcoming (5th grade) spelling bee. (If you just want to look at the words, they're in the `data` directory.)


----------------
Installation
----------------
Download the latest binary for OS X [releases page][1]. (It's OS X only, sorry.)

Unzip the App and copy it anywhere you like. You'll probably have to open your Security Preferences, select `General` and then `Anywhere` from the `Allow apps downloaded from` section of the window.


----------------
Usage
----------------
Just double-click on it. No biggie.

Use the spacebar or `enter` to get a new word. 
Use `ESC` if you need the word to be read again.
Use `TAB` if you would like the word's description to be read aloud.

----------------
Known Limitations / Bugs
----------------

* Sometimes doesn't seem to show the initial word's definition.
* Gives feed back on whether the guess was right or wrong, but keeps no stats.


----------------
Contribution / Development
----------------
This software was created by Benton Roberts _(benton@bentonroberts.com)_

1) Fetch the project code:

    git clone git@github.com:benton/spelling.git
    cd spelling

2) Download the [latest Gosu app wrapper][2] as `build/Ruby.app.zip`.
  It can be found at `https://github.com/gosu/ruby-app/releases/latest`

3) Build

    ./make.sh

3) Run

    open './build/Dixie Spelling Trainer.app'

--------
[1]: https://github.com/benton/spelling/releases
[2]: https://github.com/gosu/ruby-app/releases/latest
