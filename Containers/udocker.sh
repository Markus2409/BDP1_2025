================================================================================
GUIDA: INSTALLAZIONE E UTILIZZO DI UDOCKER
================================================================================

udocker è un tool che permette di eseguire container Docker in spazio utente, 
ovvero SENZA richiedere i permessi di root (amministratore). È molto utile in 
ambienti condivisi o HPC dove non si ha accesso a Docker.

--- 1. INSTALLAZIONE UDOCKER (Come utente normale) ---

1. wget https://github.com/.../udocker-1.3.17.tar.gz
   Scarica l'archivio compresso contenente i file di udocker (versione 1.3.17) 
   direttamente da GitHub.

2. tar zxvf udocker-1.3.17.tar.gz
   Estrae (scompatta) l'archivio appena scaricato nella directory corrente.

3. export PATH=`pwd`/udocker-1.3.17/udocker:$PATH
   Aggiunge temporaneamente il percorso dell'eseguibile di udocker alla 
   variabile d'ambiente PATH. 
   - `pwd`: Restituisce la directory corrente.
   - Questo permette di lanciare il comando 'udocker' da qualsiasi posizione 
     senza dover digitare tutto il percorso ogni volta.

4. udocker install
   Avvia la procedura di installazione interna di udocker. Questo scarica e 
   configura le librerie necessarie (come PRoot) nella home dell'utente 
   (solitamente in ~/.udocker).


--- 2. PULL DI UN'IMMAGINE (Download da Docker Hub) ---

5. udocker pull dcesini/hpqc_2025:ubuntu_with_fortune_5.0
   Scarica l'immagine specificata dal Docker Hub pubblico e la salva nel 
   repository locale di udocker.
   Nota: L'immagine è quella creata negli esercizi precedenti (Ubuntu con fortune).

6. udocker images
   Elenca le immagini disponibili localmente per verificare che il download 
   sia avvenuto con successo.


--- 3. ESECUZIONE DEL CONTAINER ---

7. udocker run dcesini/hpqc_2025:ubuntu_with_fortune_5.0
   Avvia un container basato sull'immagine scaricata.
   - A differenza di Docker standard, questo processo gira con i permessi 
     dell'utente corrente, non come root.
   - Eseguirà l'ENTRYPOINT definito nell'immagine (fortune | cowsay | lolcat).
