#!/bin/bash

#######################function check Element exit on list##########################
#declaration of the function "exists_in_list" and this function will take 3 arguments (List, delimiter, value)
function exists_in_list() {
    #variable contain the list (argument 1)
    LIST=$1
    #variable contain the delimiter for get element on the list (argument 2)
    DELIMITER=$2
    #variable contain the value to seach in list (argument 3)
    VALUE=$3
    #create iterable list to for loop
    LIST_WHITESPACES=`echo $LIST | tr "$DELIMITER" " "`
    #for loop of all element of the list
    for x in $LIST_WHITESPACES; do
        #compare value x of the list with the value fill in
        if [ "$x" = "$VALUE" ]; then
            #return 0 if the value was found in the list
            return 0
        #end of if
        fi
    #end of do for the loop for
    done
    #return 1 if the value was not found(this not return element if value was found because a return statement stop the function and retrun the value)
    return 1
}
#######################function Get all interfaces in a list##########################
#declaration of the function "exists_in_list"
function Get_all_interfaces() {
    #create a empty list of interfaces
    list_of_interfaces="";
    #for loop of the interfaces contain an IPV4
    for interfacename in $(ip -4 -o a | awk '{print $2}'); do
        #check if the interface name was not in the list to eliminate duplicated interface (use the function created above with the "list_of_interfaces" variable, the delimiter " " and the variable "interfacename")
        if ! exists_in_list "$list_of_interfaces" " " $interfacename; then
            #add to the existent list "list_of_interfaces" the name of the new interface if this one is not in the list yet
            list_of_interfaces="$list_of_interfaces$interfacename ";
        #end of if
        fi
    #end of do for the loop for
    done
    #return the list of interface name if the call of this function is in "$()" and if not the list of interface was echo on the terminal 
    echo "$list_of_interfaces";
}
#######################function determinate if ip is public##########################
#declaration of the function "exists_in_list"
function check_IP_Public() {
    #this variable was the ip specified (in argument)
    ip=$1
    #check if the ip is not the 127.0.0.1 because this is a private address
    if [ $(echo $ip | tr '/' ' ' | awk '{print $1}') == "127.0.0.1" ]; then
        #return 1 if the if statement is true
        return 1
    #check if the ip is not the 127.0.0.1 because this is a private address
    elif [ $(echo $ip | tr '/' ' ' | awk '{print $1}') == "0.0.0.0" ]; then
        #return 1 if the if statement is true
        return 1
    #check if the ip start with 10 because the range 10.0.0.0 - 10.255.255.255 is private
    elif [ $(echo $ip | tr '/' ' ' | awk '{print $1}' | tr '.' ' ' | awk '{print $1}') -eq 10 ]; then
        #return 1 if the if statement is true
        return 1
    #check if the ip start with 172 and the second byte are between 16 and 31 because the range 172.16.0.0 - 172.31.255.255 is private
    elif [ $(echo $ip | tr '/' ' ' | awk '{print $1}' | tr '.' ' ' | awk '{print $1}') -eq 172 ] && [ $(echo $ip | tr '/' ' ' | awk '{print $1}' | tr '.' ' ' | awk '{print $2}') -ge 16 ] && [ $(echo $ip | tr '/' ' ' | awk '{print $1}' | tr '.' ' ' | awk '{print $2}') -le 31 ]; then
        #return 1 if the if statement is true
        return 1
    #check if the ip start with 192 and the second byte are 168 because the range 192.168.0.0 - 192.168.255.255 is private
    elif [ $(echo $ip | tr '/' ' ' | awk '{print $1}' | tr '.' ' ' | awk '{print $1}') -eq 192 ] && [ $(echo $ip | tr '/' ' ' | awk '{print $1}' | tr '.' ' ' | awk '{print $2}') -eq 168 ]; then
        #return 1 if the if statement is true
        return 1
    #else the ip was not in the private ip range and this ip was probably a public ip
    else
        #return 0 if all the verification are false (if ip is public)
        return 0
    fi
}
#######################IP filter and show##########################
#for loop of all interfaces contain an IPV4
for interfacename in $(Get_all_interfaces); do
    #for loop of all IP address of the specified interface (in the previous for)
    for IPpc in $(ip -4 -o addr show $interfacename | awk '{print $4}'); do
        #check if the IP is public or private with the function above and add the IP specified by the for loop as the argument 1
        if check_IP_Public $IPpc; then
            #if the IP is public this case was executed
            #this echo display the information with the format, the interface name is bold, the class is underline and this line was in light RED because is a public IP
            echo -e "\e[91m\e[1m${interfacename}\e[0m\e[91m ${IPpc} \e[4mpublic"
            #this echo reset all the attribute of terminal
            echo -e "\e[0m"
        #else the ip is private
        else
            #this echo display the information with the format, the interface name is bold, the class is underline and this line was in light GREEN because is a private IP
            echo -e "\e[92m\e[1m${interfacename}\e[0m\e[92m ${IPpc} \e[4mprivate"
            #this echo reset all the attribute of terminal
            echo -e "\e[0m"
        #end of if
        fi
    #end of do for the loop for
    done
#end of do for the loop for
done