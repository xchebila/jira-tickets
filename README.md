# Automatisation des tickets Jira vers Notes (macOS)

Ce projet permet de récupérer automatiquement vos tickets Jira assignés et de les synchroniser avec l'application Notes sur macOS.

## Prérequis

- macOS
- Un compte Jira avec API Token
- jq (pour traiter le JSON)

## Installation

1. **Clonez le projet** :

    ```bash
    git clone https://github.com/xchebila/jira-tickets.git
    cd jira-notes
    ```

2. **Configurez vos variables d'environnement** :

    Copiez le fichier `.env.example` en `.env` et remplissez vos informations personnelles :

    ```bash
    cp Scripts/.env.example Scripts/.env
    ```

    Ouvrez ensuite le fichier `.env` et modifiez les valeurs en fonction de votre configuration (comme votre token API Jira, etc.).

3. **Rendez le script d'installation exécutable** (une seule fois) :

    ```bash
    chmod +x Scripts/install_agent.sh
    ```

4. **Exécutez le script d'installation** :

    Lancez le script d'installation pour configurer automatiquement l'automatisation, copier les fichiers nécessaires et charger le service :

    ```bash
    ./Scripts/install_agent.sh
    ```

    Le script va automatiquement configurer l'automatisation, copier le fichier `.env`, et mettre en place le service dans `LaunchAgents`.

## Vérification de l'exécution

- **Pour forcer l'exécution immédiatement** :

    ```bash
    launchctl start com.jira.notes
    ```

- **Pour voir les logs** :

    ```bash
    cat /tmp/jira_notes_stdout.log
    cat /tmp/jira_notes_stderr.log
    ```

## Désinstallation

Pour supprimer l'automatisation :

    launchctl unload ~/Library/LaunchAgents/com.jira.notes.plist
    rm ~/Library/LaunchAgents/com.jira.notes.plist
    

## Dépannage

### 1. La tâche ne semble pas s'exécuter
- Vérifiez que la tâche est chargée :

    ```bash
    launchctl list | grep com.jira.notes
    ```

- Assurez-vous que le chemin du script dans `com.jira.notes.plist` est correct.

### 2. Problèmes de permissions
Si le script ne s'exécute pas, ajoutez les permissions d'exécution :    

    chmod +x Scripts/jira_notes.sh

### 3. Modifier la planification
Pour modifier l'heure de l'exécution automatique, éditez le fichier `com.jira.notes.plist` et ajustez ces lignes :

    <key>Hour</key>
    <integer>8</integer>
    <key>Minute</key>
    <integer>0</integer>

Rechargez ensuite la tâche :

    launchctl unload ~/Library/LaunchAgents/com.jira.notes.plist
    launchctl load ~/Library/LaunchAgents/com.jira.notes.plist

## Références supplémentaires

Pour plus d'informations sur `launchd` et ses fonctionnalités, consultez la documentation officielle d'Apple :  
[launchd Manual Page](https://www.manpagez.com/man/1/launchctl/)
