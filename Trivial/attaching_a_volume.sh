================================================================================
GUIDA: PARTIZIONAMENTO, FORMATTAZIONE E MOUNT DI UN VOLUME (DA CODICE FORNITO)
================================================================================

Questa procedura serve quando si aggiunge un nuovo disco (es. un volume EBS su AWS) 
a una macchina virtuale e lo si vuole rendere utilizzabile dal sistema operativo.

--- 1. IDENTIFICAZIONE DEL DISCO ---

1. df -h
   Mostra i filesystem attualmente montati e lo spazio disponibile. Serve per capire 
   cosa è già in uso.

2. fdisk -l
   Elenca tutti i dischi fisici/virtuali connessi alla macchina. Qui devi individuare 
   il nome del nuovo disco (nell'esempio è identificato come '/dev/nvme1n1').


--- 2. PARTIZIONAMENTO (fdisk) ---

3. fdisk /dev/nvme1n1
   Avvia l'utility interattiva per modificare la tabella delle partizioni del disco specificato.
   ATTENZIONE: Assicurarsi di non selezionare il disco di sistema (dove risiede l'OS) 
   per non perdere dati.
   
   Sequenza comandi interattivi suggerita nei commenti:
   - p: Print (stampa la tabella attuale delle partizioni).
   - n: New (crea una nuova partizione). Si accettano i valori di default per renderla primaria e grande quanto tutto il disco.
   - p: Print (per verificare che la nuova partizione sia stata creata).
   - w: Write (scrive le modifiche su disco ed esce).


--- 3. FORMATTAZIONE E PREPARAZIONE ---

4. mkfs.ext4 /dev/nvme1n1p1
   Crea un filesystem di tipo 'ext4' sulla nuova partizione appena creata.
   Nota: Si usa 'nvme1n1p1' (la partizione 1) e non 'nvme1n1' (l'intero disco).

5. mkdir /data2
   Crea la directory che fungerà da punto di mount (il punto di accesso ai dati del disco).

6. yum install vim
   Installa l'editor di testo vim (se non presente).


--- 4. PERSISTENZA (Mount automatico al boot) ---

7. vim /etc/fstab
   Apre il file '/etc/fstab', che contiene l'elenco dei dischi da montare all'avvio.

8. Aggiunta della riga di configurazione:
   /dev/nvme1n1p1    /data2    ext4    defaults    0 0
   - Dispositivo: /dev/nvme1n1p1
   - Punto di mount: /data2
   - Tipo filesystem: ext4
   - Opzioni: defaults
   - Dump/Pass: 0 0 (niente backup/controllo disco)

9. cat /etc/fstab
   Verifica che la riga sia stata inserita correttamente.


--- 5. ATTIVAZIONE E VERIFICA ---

10. systemctl daemon-reload
    Ricarica la configurazione di systemd (necessario dopo aver modificato fstab 
    su sistemi moderni per aggiornare le unità di mount generate).

11. mount -a
    Monta tutti i filesystem elencati in /etc/fstab che non sono ancora montati. 
    Se non dà errori, la configurazione in fstab è corretta.

12. df -h
    Verifica finale: dovresti vedere '/data2' nella lista con la dimensione corretta.

13. ll /data2
    Mostra il contenuto della nuova cartella (inizialmente vuota tranne per 'lost+found').

14. chmod 775 /data2/
    Modifica i permessi della cartella: 
    - Proprietario/Gruppo: Lettura, Scrittura, Esecuzione.
    - Altri: Lettura, Esecuzione.
