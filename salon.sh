#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#Collect service options
SHAMPOO=$($PSQL "SELECT name FROM services WHERE service_id=1;")
WASH=$($PSQL "SELECT name FROM services WHERE service_id=2;")
BLOWOUT=$($PSQL "SELECT name FROM services WHERE service_id=3;")

echo -e '\n~~~~ Offered Services ~~~~'
echo -e '\nWelcome to My Salon, how can I help you?\n'

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi
  
  #Display service options
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services;")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  #Handle selection
  read SERVICE_ID_SELECTED

  CHOSEN_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  VALIDATE_SELECTION
  
}

VALIDATE_SELECTION() {
#If service option doesn't exist
  if [[ -z $CHOSEN_SERVICE ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      COLLECT_PHONE_NUMBER

      #Check to see if the customer exists
      VALIDATE_CUSTOMER
  fi
}

COLLECT_PHONE_NUMBER() {
    #Collect the customer's phone number
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
}

VALIDATE_CUSTOMER() {
  #Check if customer is in the database
  CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE';")

  if [[ -z $CUSTOMER ]]
    #If customer doesn't exist. Collect their name and add name and number to database
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      CREATE_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    else
      #If customer DOES exists, collect their name from the database
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  fi
  
  # Request their appointment time.
  COLLECT_APPOINTMENT_TIME
}

COLLECT_APPOINTMENT_TIME() {
      
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

      ADD_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")

      if [[ $ADD_APPOINTMENT_TIME = "INSERT 0 1" ]]
        then
          echo -e "\nI have put you down for a$CHOSEN_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
        else
          echo -e "I'm sorry there seems to have been an issue scheduling your appointment. Please call our salon and schedule it that way."
      fi
}

MAIN_MENU
