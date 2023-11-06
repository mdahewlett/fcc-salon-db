#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display services
  echo -e "\nWhich service number would you like?"
  echo -e "\n1) Cut\n2) Perm\n3) Highlight"

  # ask for service selection
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  # if did not select an existing service
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
  then

    # return to service options
    SERVICE_MENU "Please pick one of the displayed service numbers."
  
  else

    # check if existing customer
    echo -e "\nPlease enter your phone number in the format XXX-XXX-XXXX"
    read CUSTOMER_PHONE
    PHONE_RESULT=$($PSQL "SELECT customer_id, phone, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
   
    # if not existing customer
    if [[ -z $PHONE_RESULT ]]
    then

      # ask for name
      echo -e "\nPlease provide your name."
      read CUSTOMER_NAME

      # add customer to customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    
    else
      
      # get existing customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    fi

    # get customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # ask for appointment time
    echo -e "\nWhat time would you like for your appointment?"
    read SERVICE_TIME

    # add appointment to appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # confirm appointment
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')."
  fi
}

SERVICE_MENU
