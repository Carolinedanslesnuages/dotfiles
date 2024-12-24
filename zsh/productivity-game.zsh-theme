
# Répertoires et fichiers de configuration
SCORE_DIR="${HOME}/.config/terminal_game"
SCORE_FILE="${SCORE_DIR}/score"
SCORE_HISTORY_FILE="${SCORE_DIR}/score_history"

# Initialisation
mkdir -p "$SCORE_DIR"
[[ ! -f "$SCORE_FILE" ]] && echo "0" > "$SCORE_FILE"
[[ ! -f "$SCORE_HISTORY_FILE" ]] && touch "$SCORE_HISTORY_FILE"

# Décor spécial pour Noël (25 décembre)
christmas_decor() {
  local today=$(date "+%m-%d")
  if [[ "$today" == "12-25" ]]; then
    echo "🎄🎁 Joyeux Noël ! 🌟❄️"
  fi
}

# Notification pour Noël (macOS et Linux)
christmas_notification() {
  local today=$(date "+%m-%d")
  if [[ "$today" == "12-25" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
      osascript -e "display notification 'Joyeux Noël ! Passe une merveilleuse journée !' with title '🎄🎁 Productivity Game'"
    elif [[ "$(uname)" == "Linux" ]]; then
      notify-send "🎄🎁 Productivity Game" "Joyeux Noël ! Passe une merveilleuse journée !"
    fi
  fi
}

# Récupérer les informations Git
git_prompt_info() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git branch --show-current 2>/dev/null)
    local git_status=$(git status --porcelain 2>/dev/null)
    local modified=$(echo "$git_status" | grep '^ M' | wc -l)
    local added=$(echo "$git_status" | grep '^A ' | wc -l)
    local deleted=$(echo "$git_status" | grep '^ D' | wc -l)
    local last_commit=$(git log -1 --pretty=format:"%s" 2>/dev/null)
    local branch_icon="🌿"
    local icons=""

    if (( modified > 0 )); then
      icons+="📝 $modified "
    fi
    if (( added > 0 )); then
      icons+="✨ $added "
    fi
    if (( deleted > 0 )); then
      icons+="❌ $deleted "
    fi

    echo "${branch_icon} ${branch} (Last: ${last_commit}) ${icons}"
  fi
}

# Chargement du score
load_score() {
  SCORE=$(<"$SCORE_FILE")
}

# Sauvegarde du score
save_score() {
  echo "$SCORE" > "$SCORE_FILE"
}

# Incrémentation du score
increment_score() {
  SCORE=$((SCORE + 1))
  save_score
}

# Gestion des niveaux
calculate_level() {
  LEVEL=$((SCORE / 50 + 1))
}

calculate_progress() {
  PROGRESS=$((SCORE % 50))
}


draw_progress_bar() {
  local progress=$((SCORE % 50)) 
  local bar_length=10
  local filled=$((progress * bar_length / 50))
  local empty=$((bar_length - filled))

  local bar_filled=$(printf "█%.0s" $(seq 1 $filled))
  local bar_empty=$(printf "-%.0s" $(seq 1 $empty))

  echo -n "${bar_filled}${bar_empty}"
}

get_level_badge() {
  case $LEVEL in
    1) LEVEL_BADGE="🌱 Débutant" ;;
    2) LEVEL_BADGE="🔥 Intermédiaire" ;;
    3) LEVEL_BADGE="🏅 Expert" ;;
    *) LEVEL_BADGE="🌟 Maître" ;;
  esac
}

# Afficher les succès cachés débloqués
secret_achievements() {
  echo "🎖️ Succès Secrets Débloqués: "

  if (( SCORE == 123 )); then
    echo "✅ Succès '123 Magic Number' débloqué ! Vous avez atteint le score 123."
  fi
  if (( SCORE >= 1000 )); then
    echo "✅ Succès 'Champion' débloqué ! Score supérieur à 1000."
  fi

  # Succès basés sur le niveau
  if (( LEVEL >= 10 )); then
    echo "✅ Succès 'Expert' débloqué ! Vous avez atteint le niveau 10."
  fi
  if (( LEVEL >= 20 )); then
    echo "✅ Succès 'Légende' débloqué ! Vous êtes au niveau 20 ou plus."
  fi

  # Succès liés à des commandes spécifiques
  if [[ $HISTCMD -eq 42 ]]; then
    echo "✅ Succès 'The Answer' débloqué ! Vous avez atteint la commande numéro 42."
  fi
  if [[ "$LAST_COMMAND" == "ls" ]]; then
    echo "✅ Succès 'Explorateur' débloqué ! Vous avez exécuté la commande 'ls'."
  fi

  # Succès pour Noël
  if [[ "$(date "+%m-%d")" == "12-25" ]]; then
    echo "✅ Succès 'Esprit de Noël' débloqué ! 🎄 Joyeux Noël !"
  fi

  # Succès combinés (score + commande)
  if (( SCORE >= 500 && HISTCMD == 100 )); then
    echo "✅ Succès 'Commandant' débloqué ! Vous avez atteint 500 points et exécuté 100 commandes."
  fi
}

notify_milestone() {
  if [[ "$(uname)" == "Darwin" ]]; then
    osascript -e "display notification \"$1\" with title \"Terminal Game\""
  fi
}

check_milestone() {
  if (( PROGRESS == 0 )); then
    local message="Félicitations ! Vous avez atteint le Niveau $LEVEL."
    echo "$(date): Niveau $LEVEL atteint (Score: $SCORE)" >> "$SCORE_HISTORY_FILE"
    notify_milestone "$message"
  fi
}

# Afficher le tableau de bord
show_dashboard() {
  load_score  # Charger les scores et niveaux
  echo "🎮 Tableau de Bord"
  echo "----------------------"
  echo "👤 Utilisateur   : $USER"
  echo "📂 Chemin Actuel : $(pwd)"
  echo "⌨️ Commandes     : $HISTCMD"
  echo "🏆 Score         : $SCORE"
  echo "🎖️ Niveau        : $LEVEL $(get_level_badge)"  || echo "Aucun badge trouvé"
  echo "🔗 Branche Git   : $(git_prompt_info)"
  echo ""
  echo "📜 Succès Débloqués :"
  secret_achievements
  echo ""
  echo "🔄 Historique des Scores :"
  tail -n 5 "$SCORE_HISTORY_FILE" 2>/dev/null || echo "Aucun historique disponible."
  echo ""
  echo "🔋 Progression   : [$(draw_progress_bar)]"
}

update_terminal_game() {
  load_score
  calculate_level
  calculate_progress
  draw_progress_bar
  get_level_badge
  check_milestone
}

build_prompt() {
  # Couleurs dynamiques pour différents éléments
  local user_color="%F{cyan}"         # Couleur pour l'utilisateur
  local path_color="%F{blue}"         # Couleur pour le chemin
  local git_color="%F{yellow}"        # Couleur pour Git
  local points_color="%F{green}"      # Couleur pour les points
  local level_color="%F{magenta}"     # Couleur pour le niveau
  local badge_color="%F{red}"         # Couleur pour les badges
  local progress_color="%F{yellow}"   # Couleur pour la barre de progression

  PROMPT="
${path_color}📂 %~%f ${git_color}$(git_prompt_info)%f
${points_color}🎮 Points:%f ${points_color}$SCORE%f | ${level_color}Niveau:%f ${level_color}$LEVEL%f ${progress_color}[$PROGRESS_BAR]%f ${badge_color}$LEVEL_BADGE%f
${badge_color}$(christmas_decor)%f
❯ "
}

# Précommande
precmd() {
  increment_score
  update_terminal_game
  build_prompt
  christmas_notification
}

# Commande dangereuse
check_dangerous_commands() {
  if [[ $1 == *"rm -rf /"* ]]; then
    echo "❗ Attention : Commande dangereuse détectée !" >&2
    return 1
  fi
}

# Événements liés aux commandes
preexec() {
  check_dangerous_commands "$1"
}

# Initialisation
update_terminal_game
build_prompt

# Application du prompt
PROMPT_COMMAND="precmd"
