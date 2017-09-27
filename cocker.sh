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
    # richiede una porta che al momento non sia in uso dal sistema e verifica che non sia stata assegnata
    # a qualche container che al momento non è attivo
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
    #sceglie randomicamente una porta su cui comunicare e verifica che non sia già in uso dal sistema 
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
    ports=$(grep EXPOSE $templates_home/$1/Dockerfile)
    
    # questa parte va portata fuori nella parte che si occuperà di generare
    # la stringa di parametri con cui avviare il container
    ports=${ports:7}
    IFS=',' read -r -a array <<< "$ports"
    for element in "${array[@]}"
        do
            echo "$element"
        done
    
}

function parse_cockerfile(){
    # to do
    # parsa il Cockerfile alla ricerca di eventuali path da condividere 
    # col filesystem e da montare nel container
    # restituisce una stringa $paths=/path:/path/in/container;/path:/path/in/container
    patti=$(sed -n '/<volumes>/{:a;n;/<volumes>/b;p;ba}' $templates_home/$1/Cockerfile)
    echo $patti
}


function create_instance_from_template(){
    # to do
    # si occupa della creazione dela box che conterrà tutto il necessario a dare vita al container 
    # partendo da un template, creerà la struttura e i file necessari alla creazione del container.
    # fondamentalmente farà una copia della cartella del template, che doverbbe contenere:
    #   cartella "config" per le configurazioni necessarie
    #   cartella "custom" per eventuali customizzazioni
    #   cartella "data" in cui saranno montati i volumi che espone il container
    #   Dockerfile file con cui verrà generato il container
    #   Cockerfile file con info aggiuntive per la generazione del container, tipo volumi da montare
    #   read.me  file con le info sul container, da valutare se incorporare le info direttamente nel cockerfile
    sleep 1
}

function clone_template(){
    # to do
    # si occupa di clonare un template, ovvero fare una copia della cartella del template, prendendo in ingresso il nome del template da clonare e il nome del clone.
    free_space=$(df --output=avail $templates_home | tail -n +2)
    template_size=$(du -s $templates_home/$1 | cut -d'/' -f1)
    if [ $free_space -gt $template_size ];
    then
        cp -rf $templates_home/$1 $templates_home/$2
    else
        echo "Not enough free space"
    fi
}

function list_templates(){
    # to do
    # restituisce la lista dei template presenti nel sistema, banalmente un "ls" della cartella templates
    current_dir=$(pwd)
    cd ./templates
    echo
    for i in $(ls -d */); do echo ${i%%/}; done
    echo
    cd $current_dir
}

function template_info(){
    # to do
    # restituisce info dettagliate del template passato come parametro. 
    # Le informazioni sono contenute nel Cockerfile
    sed -n '/<template-info>/{:a;n;/<template-info>/b;p;ba}' $templates_home/$1/Cockerfile
}

function template_structure(){
    # restituisce la struttura e il contenuto di un template passato come parametro
    echo
    echo "Structure of template $1"
    echo
    tree --noreport --dirsfirst -C -F --du -h $templates_home/$1 | sed -n '1!p'
    echo 
}

function delete_template(){
    # to do
    # rimuove un template dal sistema.
    sleep 1
}

function backup_template(){
    # to do
    # effettua il backup di un template passato come parametro. Crea un archivio tar.gz della cartella del template
    # nella cartella backups
    # NON ELIMINA il template.
    tar -zcvf $templates_home/backups/$1.tar.gz $templates_home/$1
    
}

function export_template(){
    # to do
    # crea un archivio tar.gz del template passato come parametro in ingresso e lo salva in un percorso passato dall'utente come parametro
    # fa la stessa cosa di backup_template(), con la differenza che il path per il salvataggio è obbligatorio
    # NON ELIMINA il template
    sleep 1
}

function import_template(){
    #to do
    # prende un archivio tar.gz contenente un template (la validazione è demandata all'utente) e lo installa nel sistema,
    # ossia lo decomprime nella cartella templates.
    # Dovrebbe verificare se esista nel sistema il template che si sta per importare, ovvero se esiste già una cartella con
    # lo stesso nome della cartella presente nell'archivio.
    #
    # Sarebbe bello prevedere alcuni switch per questa funzione, tipo 
    # -f per forzare l'installazione, ovvero se è presente già una cartella con lo stesso nome, ne sovrascrive/integra il contenuto
    # -l per fornire un path locale del file system, dove è presente l'archivio tar.gz
    # -r per fornire un url da cui il sistema scaricherà l'archivio tar.gz (un market  di template...)
    sleep 1
}

function create_container(){
    # to do
    # si occupa della creazione del container, prendendo informazioni dal Dockerfile 
    # per quanto riguarda eventuali porte da eporre 
    # e dal Cockerfile per quanto riguarda cartelle da esporre
    # inserisce una riga alla fine del Cockerfile <mapped-ports>45564,25670<mapped-ports>
    # che contiene le porte della macchina host assegnate alle porte esposte dal container
    # in modo che in fase di rimozione, il sistema le possa rimuovere dal file ./conf/port.list
    # e renderle nuovamente disponibili
    sleep 1
}

function start_container(){
    # to do 
    # avvia un dato container, usando le api di docker
}

function stop_container(){
    # to do 
    # ferma un dato container, usando le api di docker
}

function delete_container(){
    # to do
    # rimuove un container, usando le api di docker
    # deve rimuovere anche le porte random che sono state assegnate
    # al container stesso, rimuovendole dal file ./conf/port.list
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
templates_home=/home/fpellizz/Git_repos/cocker/cocker/templates
