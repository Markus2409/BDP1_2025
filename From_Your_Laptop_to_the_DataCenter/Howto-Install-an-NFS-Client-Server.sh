#on the server:
================================================================================
SPIEGAZIONE DEI COMANDI PER CONFIGURAZIONE NFS (DA CODICE DEL PROFESSORE)
================================================================================

--- LATO SERVER (On the server) ---

1. yum install nfs-utils rpcbind
   Installa i pacchetti software necessari: 'nfs-utils' per il protocollo NFS e 
   'rpcbind' per la gestione delle chiamate di procedura remota (RPC) necessarie 
   al funzionamento di NFS.

2. systemctl enable nfs-server
   systemctl enable rpcbind
   Abilita i servizi affinché partano automaticamente al prossimo riavvio (boot) 
   del sistema.

3. systemctl start rpcbind
   systemctl start nfs-server
   Avvia immediatamente i servizi nella sessione corrente per renderli operativi 
   senza dover riavviare la macchina.

4. systemctl status nfs-server
   Verifica lo stato del server NFS per confermare che sia attivo (active/running) 
   e che non ci siano stati errori durante l'avvio.

5. vim /etc/exports
   Apre l'editor di testo 'vim' per modificare il file di configurazione '/etc/exports'. 
   Questo file definisce quali cartelle locali devono essere condivise in rete e 
   con chi.

6. cat /etc/exports
   /data <destination_host IP - USE the private IP>(rw,sync,no_wdelay)
   Mostra il contenuto del file appena modificato.
   - /data: È la cartella del server che viene condivisa.
   - <destination_host IP>: È l'IP del client autorizzato ad accedere.
   - (rw): Concede permessi di lettura e scrittura (Read/Write).
   - (sync): I dati vengono scritti su disco prima di rispondere al client (più sicuro).
   - (no_wdelay): Forza la scrittura immediata senza attendere di raggruppare 
     pacchetti (utile se usato con sync).

7. exportfs -r
   Rilegge il file /etc/exports e applica le nuove condivisioni senza dover 
   riavviare l'intero servizio NFS.


--- LATO CLIENT (On the client) ---

1. yum install nfs-utils
   Installa il pacchetto necessario affinché il client possa gestire il file system 
   NFS e montare le cartelle remote.

2. # mount -t nfs -o ro,nosuid <your_server_ip>:/data /data
   (Comando commentato) Questo comando servirebbe per un mount manuale e temporaneo 
   della cartella '/data' del server sulla cartella '/data' locale in modalità 
   sola lettura (ro). Essendo commentato, viene saltato.

3. ll /data2/
   Elenca il contenuto della directory locale '/data2'. Serve a verificare 
   l'esistenza della cartella o il suo contenuto (prima o dopo il mount).

4. # umount /data
   (Comando commentato) Servirebbe a smontare la cartella '/data'. Essendo 
   commentato, viene saltato.

5. cat /etc/fstab
   <SERVER_PRIVATE_IP>:/data2 /data2   nfs defaults        0 0
   Visualizza/Modifica il file '/etc/fstab' che gestisce i mount automatici all'avvio.
   La riga aggiunta indica al sistema di:
   - Prendere la cartella remota '/data2' che si trova sull'IP <SERVER_PRIVATE_IP>.
   - Montarla nella cartella locale '/data2'.
   - Usare il tipo di filesystem 'nfs'.
   - Usare le opzioni di 'defaults'.
   - '0 0' indica di non fare backup/check del disco.
