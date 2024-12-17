#!/bin/bash

echo "Le script commence à s'exécuter" >> "$DEBUG_LOG"

# Charger les variables depuis le fichier .env
set -o allexport
source "$(dirname "$0")/.env" 2>/dev/null || { echo "Erreur : fichier .env introuvable." >> "$DEBUG_LOG"; exit 1; }
set +o allexport

echo "Variables chargées" >> "$DEBUG_LOG"

# Fichiers temporaires
TEMP_FILE="${TEMP_FILE:-/tmp/jira_tickets.txt}"
DEBUG_LOG="${DEBUG_LOG:-/tmp/jira_notes_debug.log}"
echo "TEMP_FILE défini : $TEMP_FILE" >> "$DEBUG_LOG"
echo "DEBUG_LOG défini : $DEBUG_LOG" >> "$DEBUG_LOG"

# Forcer l'encodage UTF-8
export LANG="${LANG:-fr_FR.UTF-8}"
export LC_ALL="${LC_ALL:-fr_FR.UTF-8}"

# Titre de la note
NOTE_TITLE="${NOTE_TITLE:-Mes tickets Jira}"
echo "NOTE_TITLE défini : $NOTE_TITLE" >> "$DEBUG_LOG"

# Requête API pour récupérer les tickets
curl -s -u "$EMAIL:$TOKEN" \
-X GET "$JIRA_API_URL?jql=$JQL_QUERY" \
-H "Accept: application/json" | jq -r '
    .issues[] | 
    "<b>• Ticket:</b> \(.key)<br><b>➡️ Résumé:</b> \(.fields.summary)<br><b>🏷️ Priorité:</b> \(.fields.priority.name)<br><b>📌 Statut:</b> \(.fields.status.name)<br><br>"
' > "$TEMP_FILE"

# Si le fichier est vide, ajouter un message par défaut
if [[ ! -s "$TEMP_FILE" ]]; then
    echo "<b>Aucun ticket assigné actuellement.</b>" > "$TEMP_FILE"
fi

# Ajouter le titre de manière persistante au contenu
FULL_CONTENT="<h1>$NOTE_TITLE</h1><br>$(cat $TEMP_FILE)"

# Mettre à jour l'application Notes via AppleScript
osascript <<EOF
tell application "Notes"
    set noteTitle to "$NOTE_TITLE"
    
    -- Ajouter le titre directement dans le contenu
    set ticketContent to "$FULL_CONTENT"
    
    try
        tell folder "Notes"
            set myNote to first note whose name is noteTitle
            -- Réaffecter le contenu, y compris le titre
            set body of myNote to ticketContent
        end tell
    on error
        tell folder "Notes"
            make new note with properties {name:noteTitle, body:ticketContent}
        end tell
    end try
end tell
EOF

# Afficher un message de confirmation
echo "Tickets Jira mis à jour dans Notes" >> "$DEBUG_LOG"
