#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --tuples-only -c"
CHK_VALUES() {
  NUMBER_TO_GUESS=$1
    if [[ ! $NUMBER_TO_GUESS =~ ^[0-9]+$ ]]
       then
        echo "That is not an integer, guess again:"
     fi
      if [[ $NUMBER_TO_GUESS -gt $SECRET_NUMBER ]]
        then
          echo -e "\nIt's lower than that, guess again:"
        
           elif [[ $NUMBER_TO_GUESS -lt $SECRET_NUMBER ]]
           then
            echo -e "\nIt's higher than that, guess again:"      
    fi       
    }
COUNT_GAME=0
NUMBER_OF_GUESSES=0

echo -e "\n~~~ Number Guessing Game ~~~\n"
#ask for the username and read username
echo -e "\nEnter your username:\n"
read USERNAME
#randomly generate a number
SECRET_NUMBER=$(( RANDOM % 1000 +1 ))
TEXT="The numbers is"
echo $TEXT : $SECRET_NUMBER
#username_used_before
USER_ON_DATABASE=$($PSQL "SELECT username FROM usergame WHERE EXISTS(SELECT 1 FROM usergame WHERE username = '$USERNAME')")
if [[ -z $USER_ON_DATABASE ]]
  then
      INSERT_USER_INTO_DATABASE=$($PSQL "INSERT INTO usergame(username) VALUES('$USERNAME')")
      USERNAME_ON_DB=$($PSQL "SELECT username FROM usergame where username = '$USERNAME'") 
      echo "Welcome, $USERNAME_ON_DB! It looks like this is your first time here."
  else
      QUERYS_TO_HISTORIAL_GAME=$($PSQL "SELECT username, games_played, best_game FROM games INNER JOIN usergame USING(user_id) WHERE usergame.username='$USERNAME'")
      echo "$QUERYS_TO_HISTORIAL_GAME" | while read USER BAR GAMES_PLAYED BAR BEST_GAME 
      do
       echo -e "\nWelcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
      done         
fi
#Print to star the game
echo -e "\nGuess the secret number between 1 and 1000:\n"
((COUNT_GAME++))
until [[ $NUMBER_TO_GUESS == $SECRET_NUMBER ]]
  do 
   read NUMBER_TO_GUESS
    ((NUMBER_OF_GUESSES++))
    CHK_VALUES $NUMBER_TO_GUESS 
  done
      if [[ -z $USER_ON_DATABASE ]]
       then
        USER_ID=$($PSQL "SELECT user_id FROM usergame where username='$USERNAME'")
        
        INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(games_played, best_game, user_id) values($COUNT_GAME,$NUMBER_OF_GUESSES,$USER_ID)")
       else
        USER_ID=$($PSQL "SELECT user_id FROM usergame where username='$USERNAME'")
        COUNT_GAMES=$($PSQL "SELECT (games_played+$COUNT_GAME) as games_played from games where user_id=$USER_ID")
        UPDATE=$($PSQL "UPDATE games SET games_played = $COUNT_GAMES, best_game = $NUMBER_OF_GUESSES")
      fi
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!\n"
