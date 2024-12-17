#!/bin/bash

# Charger les variables depuis le fichier .env
set -o allexport
source "$(dirname "$0")/.env" 2>/dev/null || { echo "Erreur : fichier .env introuvable." >> "$DEBUG_LOG"; exit 1; }
set +o allexport

# Vérification des chemins et fichiers
echo "Copie du fichier .env vers $SCRIPT_DIR..." >> "$DEBUG_LOG"
if [[ ! -f "$ENV_SOURCE" ]]; then
    echo "Erreur : le fichier .env source est introuvable." >> "$DEBUG_LOG"
    exit 1
fi
sudo cp "$ENV_SOURCE" "$ENV_FILE" || {
    echo "Erreur lors de la copie du fichier .env avec sudo." >> "$DEBUG_LOG"
    exit 1
}
echo "Fichier .env copié avec succès." >> "$DEBUG_LOG"

# Copier le script vers /usr/local/bin avec sudo
echo "Copie du script vers $SCRIPT_DIR..." >> "$DEBUG_LOG"
if [[ ! -f "$SCRIPT_FILE" ]]; then
    sudo cp "$HOME/Documents/Dev/Perso/jira-tickets/Scripts/jira_notes.sh" "$SCRIPT_FILE" || {
        echo "Erreur lors de la copie du script avec sudo." >> "$DEBUG_LOG"
        exit 1
    }
    echo "Script copié avec succès." >> "$DEBUG_LOG"
fi

# Copier le fichier .plist dans LaunchAgents (pas besoin de sudo ici)
echo "Copie du fichier plist vers $AGENT_DIR..." >> "$DEBUG_LOG"
cp "$AGENT_PLIST" "$AGENT_DIR/" || {
    echo "Erreur lors de la copie du fichier plist." >> "$DEBUG_LOG"
    exit 1
}
echo "Fichier plist copié avec succès." >> "$DEBUG_LOG"

# Charger le LaunchAgent
echo "Chargement de l'agent avec launchctl..." >> "$DEBUG_LOG"
launchctl unload "$AGENT_DIR/$(basename "$AGENT_PLIST")" 2>/dev/null
launchctl load "$AGENT_DIR/$(basename "$AGENT_PLIST")" || {
    echo "Erreur lors du chargement de l'agent." >> "$DEBUG_LOG"
    exit 1
}
echo "Agent chargé avec succès." >> "$DEBUG_LOG"

echo "Agent Jira Notes installé et lancé avec succès." >> "$DEBUG_LOG"
