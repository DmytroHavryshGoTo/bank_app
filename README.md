# Bank App [![Build Status](https://app.travis-ci.com/DmytroHavryshGoTo/bank_app.svg?branch=main)](https://app.travis-ci.com/DmytroHavryshGoTo/bank_app)

Simple banking app, that allows users to send money to each other from different cards(currency conversion supported)

## Requirements

- ruby 2.7.3
- Redis

## Installation

```
./bin/setup
```

## Tests

```
rspec
```

## Usage

There are 2 options given:

- create new user through UI and add balance via Rails Console (`user.accounts.first.add_money(100_000)`)
- use existing users with prefilled balance:
  > 1. email: user1@example.com, password: `123456`
  > 2. email: user2@example.com, password: `123456`

## Screenshots

![screenshot_1](https://github.com/DmytroHavryshGoTo/bank_app/blob/main/screenshots/bank_app_screen_1.png)

---

![screenshot_2](https://github.com/DmytroHavryshGoTo/bank_app/blob/main/screenshots/bank_app_screen_2.png)

---

![screenshot_3](https://github.com/DmytroHavryshGoTo/bank_app/blob/main/screenshots/bank_app_screen_3.png)
