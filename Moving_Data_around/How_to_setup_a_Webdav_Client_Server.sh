================================================================================
SPIEGAZIONE CONFIGURAZIONE SERVER WEBDAV (DA CODICE FORNITO)
================================================================================

--- LATO SERVER (On The Server) ---

1. cat /etc/yum.repos.d/epel.repo
   Visualizza il contenuto del file di repository EPEL per confermare che sia 
   presente e configurato.

2. yum install httpd
   Installa il server web Apache.

3. sed -i 's/^/#&/g' /etc/httpd/conf.d/welcome.conf
   Modifica il file 'welcome.conf' inserendo un cancelletto (#) all'inizio di ogni 
   riga. Questo commenta tutto il file e disabilita la pagina di benvenuto 
   predefinita di Apache.

4. sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/httpd/conf/httpd.conf
   Modifica il file di configurazione principale 'httpd.conf'. Cerca la riga con 
   "Options Indexes FollowSymLinks" e la sostituisce rimuovendo "Indexes". 
   Questo impedisce al server di mostrare l'elenco dei file se si visita una 
   directory via browser.

5. systemctl start httpd.service
   Avvia il servizio Apache.

6. httpd -M | grep dav
   Esegue il comando 'httpd' con l'opzione -M (lista moduli) e filtra l'output 
   per mostrare solo le righe che contengono "dav", per verificare che i moduli 
   WebDAV siano caricati.

7. mkdir /var/www/html/webdav
   Crea la directory 'webdav' dentro il percorso web predefinito.

8. chown -R apache:apache /var/www/html
   Cambia il proprietario della cartella '/var/www/html' (e tutto il contenuto) 
   assegnandolo all'utente 'apache' e al gruppo 'apache'.

9. chmod -R 755 /var/www/html
   Imposta i permessi sulla cartella: il proprietario può leggere/scrivere/eseguire, 
   gli altri possono solo leggere ed eseguire (entrare nella cartella).

10. htpasswd -c /etc/httpd/.htpasswd user001
    Crea un nuovo file di password (opzione -c) nascosto in '/etc/httpd/.htpasswd' 
    e aggiunge l'utente 'user001'. Chiede di digitare la password.

11. chown root:apache /etc/httpd/.htpasswd
    Cambia la proprietà del file password: root è il proprietario, ma il gruppo 
    'apache' può accedervi.

12. chmod 640 /etc/httpd/.htpasswd
    Imposta i permessi sul file password: il proprietario legge/scrive, il gruppo 
    legge, gli altri non hanno accesso.

13. vim /etc/httpd/conf.d/webdav.conf
    Apre l'editor per creare il file di configurazione del sito WebDAV.
    
    Spiegazione del contenuto inserito nel file:
    - DavLockDB: Specifica dove salvare il database dei lock per i file.
    - <VirtualHost *:80>: Apre la configurazione per la porta 80.
    - Alias /webdav: Fa sì che l'indirizzo 'http://server/webdav' punti alla cartella su disco.
    - <Directory ...>: Configura la cartella specifica.
      - DAV On: Abilita la funzionalità WebDAV.
      - AuthType/AuthName: Imposta il tipo di autenticazione (Basic).
      - AuthUserFile: Indica al server di usare il file .htpasswd creato prima.
      - Require valid-user: Blocca l'accesso a chi non ha la password corretta.

14. setenforce 0
    Mette SELinux in modalità "Permissive" (non blocca le operazioni, ma le logga 
    soltanto), per evitare problemi di permessi di sicurezza.

15. systemctl restart httpd.service
    Riavvia il servizio Apache per caricare la nuova configurazione WebDAV e i 
    permessi.

================================================================================
SPIEGAZIONE CONFIGURAZIONE CLIENT WEBDAV (DA CODICE FORNITO)
================================================================================

--- LATO CLIENT (On the Client) ---

1. yum install cadaver
   Installa 'cadaver', un client a riga di comando per sistemi Unix/Linux che 
   permette di interagire con server WebDAV (simile a come funziona un client FTP).

2. cadaver http://<your-server-ip>/webdav/
   Avvia il programma e si connette alla cartella condivisa sul server.
   Nota: Al posto di <your-server-ip> va inserito l'indirizzo IP reale del server.
   A questo punto il server richiederà le credenziali (user001 e password) 
   configurate in precedenza.

--- COMANDI INTERNI ALLA SHELL "dav:/webdav/>" ---

3. put /home/user/abc.txt
   Prende il file locale 'abc.txt' (che deve esistere nel percorso specificato) 
   e lo carica (upload) sul server WebDAV.

4. mkdir dir1
   Crea una nuova directory chiamata 'dir1' direttamente sul server remoto.

5. exit
   Chiude la connessione con il server e termina il programma cadaver.

--- NOTE SULL'ACCESSO VIA BROWSER ---

6. Accesso via Browser (Note e commenti dello script)
   Lo script suggerisce di provare ad accedere anche via browser, ma avverte di 
   alcune limitazioni tecniche:
   
   - Accesso diretto ai file: È possibile scaricare un file specifico digitando 
     l'URL completo (es. https://dominio/webdav/cartella1/test.pdf).
   
   - Navigazione cartelle: I browser standard usano il metodo HTTP classico 
     (GET/POST) e non supportano nativamente i metodi estesi di WebDAV (come 
     PROPFIND) necessari per elencare il contenuto delle cartelle come un File 
     Explorer.
   
   - Soluzione per browser: Per "sfogliare" le cartelle via browser spesso serve 
     un plugin specifico o un client dedicato, altrimenti il browser non riuscirà 
     a mostrare la lista dei file.
