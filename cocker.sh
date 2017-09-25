#!/bin/sh

# cocker
#
# Cocker è l'embrione di un complesso sistema di gestione 
# per container docker, un fantasticissimo sistema in grado
# di generare container basasti su template che possono
# essere facilmente personalizzati, il tutto vorrebbe essere 
# estremamente di facile utilizzo per venire incontro alle facoltà
# mentali dei soggetti che continuamente sottopongono le più assurde
# richieste al devops team.
#
# La cosa veramente fantastica di questo tool è che per ora è tutto e solo
# nella mia mente
#
# Usage: ./cocker.sh command
# -----------------------------------------------------------------------------

###############################################################################
#Funzioni

function log(){
    # Logger delle attività dello script stesso
    #
    # Accetta 2 parametri:
    #   $1 = stringa da aggiungere al logfile
    #   $2 = [opzionale] nome del file di log, in caso si volesse loggare separatamente qualche operazione.
    #
    # Sono state previste alcune parole chiave:
    #   new_line =     inserisce una riga vuota, va a capo
    #   break_line =   inserisce -----------------------------------------------------------------------------
    #   warning_line = inserisce #############################################################################
    #   error_line =   inserisce #############################################################################
    #                            #ERROR!                                                                      
    #                            #############################################################################
    
    if [ "$2" != "" ];
    then
        logfile=$2
    fi
    
    case $1 in
    "")             echo "" >> $logpath/$logfile ;;
    "new_line")     echo "" >> $logpath/$logfile ;;
    "break_line")   echo "-----------------------------------------------------------------------------" >> $logpath/$logfile ;;
    "warning_line") echo "#############################################################################" >> $logpath/$logfile ;;
    "error_line")   echo "#############################################################################" >> $logpath/$logfile 
                    echo "#ERROR!                                                                      " >> $logpath/$logfile 
                    echo "#############################################################################" >> $logpath/$logfile ;;
    *) echo "$date|$time => $1" >> $logpath/$logfile ;;
esac
    
}


function assign_port(){
    port=$(random_unused_port)
    echo "random generated port: $port"
    echo "used port list (from $confpath/$portfile file)"
    while read -r line
    do
        used_port="$line"
        echo "$used_port"
        if [ $used_port -eq $port ];
        then
            echo "random generated port is already assigned"
            assign_port
        fi
    done < "$confpath/$portfile"
    echo "port $port is free"
}


function random_unused_port() {
   (netstat --listening --all --tcp --numeric | 
    sed '1,2d; s/[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*:\([0-9]*\)[[:space:]]*.*/\1/g' |
    sort -n | uniq; seq 1 1000; seq 1 65535
    ) | sort -n | uniq -u | shuf -n 1
}

function parse_dockerfile(){
    # to do
    # parsa il Dockerfile alla ricerca della parola EXPOSE in modo da conoscere
    # quante e quali porte il container deve esporre
    # restituisce una stringa $ports=5432,8080,8433
}

function parse_cockerfile(){
    # to do
    # parsa il Cockerfile alla ricerca di eventuali path da condividere 
    # col filesystem e da montare nel container
    # restituisce una stringa $paths=/path:/path/in/container;/path:/path/in/container

}

function create_container(){
    # to do
    # si occupa della creazione del container, prendendo informazioni dal Dockerfile 
    # per quanto riguarda eventuali porte da eporre 
    # e dal Cockerfile per quanto riguarda cartelle da esporre
}
###############################################################################
#Variabili
home=$(dirname $0)
date=$(date +"%F")
time=$(date +"%T")
logpath=$home/logs
logfile=cocker.log
confpath=$home/conf
portfile=port.list

