================================================================================
SPIEGAZIONE INSTALLAZIONE DOCKER SU RHEL 9.3 (DA CODICE FORNITO)
================================================================================

--- 1. PREPARAZIONE SISTEMA ---

1. yum install vim wget
   Installa 'vim' (editor di testo avanzato) e 'wget' (strumento per scaricare file 
   dal web), necessari per i passaggi successivi.

2. vim /etc/yum.repos.d/docker-ce.repo
   Apre (o crea) il file di configurazione del repository Docker.
   
   Spiegazione del contenuto da inserire nel file:
   - [docker-ce-stable]: Nome identificativo del repository.
   - baseurl: L'indirizzo internet ufficiale da cui scaricare i pacchetti Docker 
     per RHEL 9.
   - enabled=1: Attiva il repository.
   - gpgcheck=1 e gpgkey: Attiva la verifica della firma digitale dei pacchetti 
     usando la chiave GPG ufficiale di Docker (per sicurezza).

--- 2. INSTALLAZIONE DIPENDENZE ---

3. yum install yum-utils device-mapper-persistent-data lvm2
   Installa pacchetti di utilità per yum e librerie necessarie per la gestione 
   dello storage (device mapper e logical volume manager) usate da Docker.

4. yum install container-selinux
   Installa le policy di sicurezza SELinux specifiche per i container. 
   Questo è fondamentale su sistemi RHEL/CentOS per permettere a Docker di 
   funzionare senza essere bloccato dal sistema di sicurezza.

--- 3. INSTALLAZIONE DOCKER ENGINE ---

5. yum install docker-ce docker-ce-cli containerd.io
   Installa i componenti principali:
   - docker-ce: Il demone/server Docker (Community Edition).
   - docker-ce-cli: Il comando 'docker' che usi nel terminale.
   - containerd.io: Il runtime di basso livello che gestisce i container.

--- 4. INSTALLAZIONE DOCKER COMPOSE (MANUALE) ---

6. wget https://github.com/.../docker-compose-linux-x86_64
   Scarica l'eseguibile di Docker Compose (versione 2.27.0) da GitHub.

7. mv docker-compose-linux-x86_64 docker-compose
   Rinomina il file scaricato in un nome più semplice ('docker-compose').

8. chmod +x docker-compose
   Rende il file eseguibile (permette di lanciarlo come programma).

9. mv docker-compose /usr/local/bin/
   Sposta il file nella cartella '/usr/local/bin/', rendendolo accessibile da 
   qualsiasi punto del terminale.

--- 5. AVVIO E CONFIGURAZIONE SERVIZIO ---

10. systemctl status docker
    Mostra lo stato attuale del servizio (probabilmente inattivo appena installato).

11. systemctl start docker
    Avvia il demone Docker immediatamente.

12. systemctl status docker
    Mostra di nuovo lo stato (ora dovrebbe essere "active/running").

13. systemctl enable docker
    Configura Docker per avviarsi automaticamente ogni volta che si accende il 
    server (boot).

--- 6. CONFIGURAZIONE UTENTE ---

14. usermod -g docker <username>
    Modifica l'utente specificato (<username>) assegnandolo al gruppo 'docker'.
    Questo serve per permettere all'utente di lanciare comandi docker senza 
    dover scrivere 'sudo' ogni volta.
================================================================================
GUIDA AI COMANDI DOCKER: UTILIZZO, COMMIT E DOCKER HUB
================================================================================

--- 1. UTILIZZO BASE DEI CONTAINER (Start using docker) ---

1. docker --version
   Verifica la versione installata di Docker.

2. docker search ubuntu
   Cerca nel registro pubblico (Docker Hub) immagini che contengono "ubuntu".

3. docker pull ubuntu
   Scarica l'immagine ufficiale 'ubuntu' dal registro alla macchina locale.

4. docker run ubuntu echo "hello from the container"
   Crea ed avvia un container basato su ubuntu, esegue il comando 'echo', stampa 
   il messaggio a video e poi il container termina (si spegne) immediatamente.

5. docker run -i -t ubuntu /bin/bash
   Avvia un container in modalità interattiva (-i per interattivo, -t per pseudo-TTY). 
   Fornisce una shell dentro il container. Per uscire si usa 'exit' o Ctrl+D.

6. docker images
   Elenca tutte le immagini Docker attualmente scaricate/presenti in locale.

7. time docker run ubuntu echo "..."
   Esegue il comando misurando il tempo impiegato. Dimostra la velocità di avvio 
   di un container (millisecondi/secondi) rispetto a una VM classica.

8. docker run ubuntu ping www.google.com
   Prova a eseguire 'ping' dentro un nuovo container. Fallirà perché l'immagine 
   base di Ubuntu è minimale e non contiene il pacchetto 'ping'.

9. docker run ubuntu /bin/bash -c "apt update; apt -y install iputils-ping"
   Avvia un container, aggiorna i repository (apt update) e installa il pacchetto 
   'iputils-ping'. Una volta finito, il container termina.
   NOTA: Le modifiche fatte qui restano dentro QUESTO specifico container, che ora è spento.

10. docker run ubuntu ping www.google.com
    Riprova il ping. Fallirà ancora! Perché 'docker run' crea sempre un NUOVO 
    container pulito dall'immagine base, non riusa quello precedente dove hai 
    installato il ping.

11. docker ps
    Mostra i container attivi (running).

12. docker ps -a
    Mostra TUTTI i container, inclusi quelli terminati (utile per trovare l'ID 
    del container dove abbiamo installato il ping al punto 9).


--- 2. CREAZIONE DI UNA NUOVA IMMAGINE (Commit) ---

13. docker commit <container_ID> ubuntu_with_ping
    Prende un container esistente (specificato dal suo ID, trovato con 'ps -a') 
    e ne salva lo stato attuale come una NUOVA immagine chiamata 'ubuntu_with_ping'.
    Bisogna usare l'ID del container del punto 9 (quello con l'installazione).

14. docker images
    Ora dovresti vedere la nuova immagine 'ubuntu_with_ping' nella lista.

15. docker run ubuntu_with_ping ping www.google.com
    Avvia un container dalla NUOVA immagine. Ora il ping funziona perché l'immagine 
    contiene le modifiche salvate.

16. docker system df
    Mostra l'utilizzo del disco da parte di Docker (immagini, container, volumi).

17. docker system prune
    Pulisce il sistema rimuovendo dati non utilizzati (container fermi, reti 
    inutilizzate, ecc.) per liberare spazio.


--- 3. INTERAZIONE CON DOCKER HUB (Interacting with docker-hub) ---

18. docker login -u <your_username>
    Effettua l'autenticazione al registro Docker Hub. Richiede la password.

19. docker tag 5c2538cecdc2 dcesini/hpqc_2025:ubuntu_with_ping_1.0
    Crea un "alias" (tag) per l'immagine locale.
    - 5c2538cecdc2: È l'IMAGE ID dell'immagine 'ubuntu_with_ping'.
    - dcesini/hpqc_2025: È il nome del repository remoto (utente/progetto).
    - :ubuntu_with_ping_1.0: È il tag (versione) specifico.

20. docker push dcesini/hpqc_2025:ubuntu_with_ping_1.0
    Carica (upload) l'immagine taggata sul repository pubblico Docker Hub, 
    rendendola accessibile da altre macchine.


--- 4. PREPARAZIONE BUILD AUTOMATICO (Building with Dockerfiles) ---

21. vim Dockerfile
    Crea/Edita il file 'Dockerfile', che conterrà le istruzioni per costruire 
    l'immagine automaticamente (invece di fare run -> install -> commit a mano).

22. vim index.html
    Crea/Edita un file HTML che verrà incluso nell'immagine (es. per un server web).

23. mkdir -p containers/simple
    Crea una struttura di directory per organizzare il lavoro.

24. cp Dockerfile index.html containers/simple/
    Copia i file appena creati nella cartella di lavoro.

25. cd containers/simple/
    Entra nella cartella per prepararsi a lanciare il comando di build (che vedremo dopo).
#########################################
================================================================================
GUIDA: BUILD ED ESECUZIONE DI UN WEB SERVER CON DOCKERFILE
================================================================================

Questa sezione illustra come creare un'immagine Docker personalizzata (un server 
web Apache che serve una pagina HTML specifica) usando un Dockerfile, e come 
eseguirla esponendo le porte corrette.

--- 1. PREPARAZIONE IMMAGINE (Build) ---

1. docker images
   Mostra le immagini presenti prima del build (per confronto).

2. docker build -t ubuntu_web_server .
   Costruisce una nuova immagine leggendo il 'Dockerfile' presente nella directory 
   corrente (indicata dal punto finale '.').
   - L'opzione '-t ubuntu_web_server' assegna il nome (tag) alla nuova immagine.
   - Durante il build, Docker esegue i passaggi descritti nel Dockerfile: scarica 
     Ubuntu, installa Apache, copia il file index.html locale dentro l'immagine 
     e imposta il comando di avvio.

3. docker images
   Verifica che la nuova immagine 'ubuntu_web_server' sia stata creata e appaia 
   nella lista.


--- 2. ESECUZIONE DEL CONTAINER (Run) ---

4. docker ps -a
   Controlla se ci sono container vecchi o fermi che potrebbero dare fastidio 
   (opzionale, ma buona pratica).

5. docker run -d -p 8080:80 ubuntu_web_server
   Avvia un container basato sulla nuova immagine.
   - '-d' (detached): Esegue il container in background (non blocca il terminale).
   - '-p 8080:80': Mappa la porta 8080 della macchina ospite (la VM) sulla porta 
     80 del container (dove Apache è in ascolto).
   
   IMPORTANTE: Grazie a questo mapping, per vedere il sito web dovrai collegarti 
   alla porta 8080 della VM, non alla 80.

6. docker ps
   Verifica che il container sia in stato "Up" (acceso). Se non appare qui, 
   significa che è crashato all'avvio (controlla con 'docker ps -a').


--- 3. VERIFICA E ACCESSO ---

7. ifconfig
   Mostra la configurazione di rete per individuare l'indirizzo IP pubblico o 
   privato della VM.

8. Accesso via Browser
   Apri il browser e vai a: http://<IP_DELLA_VM>:8080/
   
   NOTA FONDAMENTALE SULLA SICUREZZA (Security Group):
   Se sei su AWS o un altro cloud provider, assicurati che il Security Group (firewall) 
   permetta il traffico in entrata TCP sulla porta 8080. Se la porta è chiusa, 
   il browser non caricherà nulla.

--- 4. GESTIONE E DEBUG ---

9. docker stop e960d33524a0
   Ferma il container. 
   Nota: 'e960d33524a0' è un ID di esempio; devi sostituirlo con il vero 
   CONTAINER ID che leggi dal comando 'docker ps'.

10. docker exec -ti <docker ID> /bin/bash
    Permette di entrare dentro un container che è già in esecuzione per esplorare 
    i file o fare debug.
    - '-ti': Alloca un terminale interattivo.
    - '/bin/bash': Apre la shell bash dentro il container.
    - Per uscire senza fermare il container: premi Ctrl+D o digita 'exit'.
================================================================================
GUIDA: VOLUMI, PORTABILITÀ E DOCKER COMPOSE
================================================================================

Questa sezione copre la persistenza dei dati (evitando che i dati vadano persi 
quando un container si spegne), il salvataggio manuale delle immagini e 
l'orchestrazione di servizi multipli.

--- 1. DOCKER VOLUMES (Persistenza Dati) ---

I container sono effimeri: se li spegni, i dati al loro interno vengono persi. 
Per salvare i dati esistono due modi principali visti qui: Host Mounts e Docker Volumes.

A. Host Bind Mount (Mappare una cartella locale)
   Questo metodo collega una cartella specifica della tua VM (Host) a una cartella 
   dentro il container.

   1. mkdir -p $HOME/containers/scratch
      cd $HOME/containers/scratch
      Crea e entra in una cartella di lavoro sulla VM.

   2. head -c 10M < /dev/urandom > dummy_file
      Crea un file di test chiamato 'dummy_file' di 10MB contenente dati casuali. 
      Serve per verificare che il container riesca a "vedere" i file creati dall'host.

   3. docker run -v $HOME/containers/scratch/:/container_data -i -t ubuntu /bin/bash
      Avvia un container Ubuntu interattivo.
      - '-v': Opzione fondamentale. Mappa la cartella locale ($HOME/containers/scratch) 
        nella cartella interna al container (/container_data).
      
      NOTA: Se dentro il container esegui 'ls -l /container_data', vedrai il file 
      'dummy_file' creato al punto 2. I dati sono condivisi.

B. Docker Managed Volumes (Volumi gestiti da Docker)
   Questo è il metodo raccomandato. Docker crea uno spazio di archiviazione gestito 
   interamente da lui, indipendente dalla struttura delle cartelle dell'host.

   4. docker volume create some-volume
      Crea un volume logico chiamato 'some-volume'.

   5. docker volume ls
      Lista tutti i volumi presenti nel sistema.

   6. docker volume inspect some-volume
      Mostra i dettagli tecnici del volume (es. dove si trova fisicamente sul disco, 
      solitamente in /var/lib/docker/volumes/...).

   7. docker run -i -t --name myname -v some-volume:/app ubuntu /bin/bash
      Avvia un container e monta il volume 'some-volume' nella cartella interna '/app'.
      Tutto ciò che il container scrive in '/app' verrà salvato nel volume e non 
      verrà perso alla chiusura del container.

   8. docker volume rm some-volume
      Cancella il volume (attenzione: si perdono i dati). Non puoi cancellare un 
      volume se è ancora in uso da un container.

   9. docker volume prune
      Comando di pulizia: cancella tutti i volumi che non sono collegati a nessun 
      container attivo.


--- 2. PORTABILITÀ DELLE IMMAGINI (Moving Images) ---

Se devi spostare un'immagine su un server che non ha accesso a internet (e quindi 
non può usare Docker Hub), puoi salvarla come file.

10. docker save -o my_exported_image.tar my_local_image
    Salva l'immagine 'my_local_image' in un unico file archivio 'my_exported_image.tar'.

11. docker load -i my_exported_image.tar
    (Da eseguire sul server di destinazione) Carica l'immagine dal file tar dentro 
    il Docker Engine locale.


--- 3. DOCKER COMPOSE (Orchestrazione) ---

Docker Compose serve a gestire applicazioni complesse composte da più container 
(es. un sito web + un database) descrivendoli in un singolo file YAML.

Analisi del file 'docker-compose.yml':
   - services: Definisce i container da avviare.
     1. database:
        - Usa l'immagine 'mysql:5.7'.
        - Imposta variabili d'ambiente (environment) per configurare user e password 
          del DB.
        - Si collega alla rete interna 'backend'.
     2. wordpress:
        - Usa l'immagine 'wordpress:latest'.
        - depends_on: Dice a Docker di avviare questo container solo dopo il database.
        - environment: Configura WP per collegarsi all'host 'database' sulla porta 3306.
        - ports '8080:80': Rende il sito accessibile dall'esterno sulla porta 8080 
          della VM.
        - networks: Si collega sia a 'backend' (per parlare col DB) che a 'frontend' 
          (per essere raggiungibile).

Comandi Compose:

12. docker-compose up --build --no-start
    Legge il file yml, scarica le immagini necessarie, crea i container e le reti, 
    ma NON li avvia ancora (--no-start).

13. docker-compose start
    Avvia i container creati precedentemente.

14. docker-compose stop
    Ferma i container, ma non li distrugge (i dati nei container rimangono).

15. docker-compose down
    Ferma i container e DISTRUGGE tutto ciò che è stato creato (container e reti). 
    I dati non salvati su volumi esterni vengono persi.

16. docker system prune
    Pulizia generale del sistema (rimuove container fermi, reti inutilizzate, cache).
