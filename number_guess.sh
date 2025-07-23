#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

number=$((1 + $RANDOM%1000))

echo "Enter your username: "
read user_input

user_id=$($PSQL "select user_id from users where username='$user_input'")

if [[ -z $user_id ]] # if new user
then
  # enter user into database
  enter_user_result=$($PSQL "insert into users(username) values('$user_input')")
  # get user_id
  user_id=$($PSQL "select user_id from users where username='$user_input'")
  # print welcome
  echo "Welcome, $user_input! It looks like this is your first time here."

else # if user exists in database
  username=$($PSQL "select username from users where user_id=$user_id")

  # get info about best game played from database
  games_played=$($PSQL "select count(*) from games where user_id=$user_id group by user_id")
  best_game=$($PSQL "select min(guesses) from games where user_id=$user_id")

  # print welcome
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# start new game
echo "Guess the secret number between 1 and 1000: "
# enter game loop
guess_num=0
while true
do
  read guess
  # check for valid input
  if [[ ! $guess =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again: "
    continue
  fi

  ((guess_num++))

  if [[ $guess -gt $number ]] # if guess was too high
  then
    echo "It's lower than that, guess again: "
    continue

  elif [[ $guess -lt $number ]] # if guess was too low
  then
    echo "It's higher than that, guess again: "
    continue

  elif [[ $guess -eq $number ]] # correct!!!
  then
    # add game to database
    add_game_result=$($PSQL "insert into games(user_id, guesses) values($user_id, $guess_num)")
    # print victory message
    echo "You guessed it in $guess_num tries. The secret number was $number. Nice job!"
    break
  fi
done

