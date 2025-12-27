#!/bin/bash

# --- Configuration ---
GIT_USER="Jammy555"
GIT_EMAIL="prathap.venkata@gmail.com"
SIGNATURE="Signed-off-by: $GIT_USER <$GIT_EMAIL>"
HOOK_URL="http://review.lineageos.org/tools/hooks/commit-msg"

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Setup ---
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"

if [ ! -f .git/hooks/commit-msg ]; then
    echo -e "${BLUE}Downloading commit-msg hook...${NC}"
    curl -Lo .git/hooks/commit-msg "$HOOK_URL"
    chmod u+x .git/hooks/commit-msg
fi

echo -e "${GREEN}=== Ultimate Auto-Picker (Jammy555) ===${NC}"
echo -e "${CYAN}Type 'help' for commands.${NC}"

while true; do
    echo -e -n "\n${BLUE}Command > ${NC}"
    read -r INPUT
    
    CMD=$(echo "$INPUT" | awk '{print $1}')
    ARG=$(echo "$INPUT" | awk '{$1=""; print $0}' | xargs)

    if [[ -z "$CMD" ]]; then continue; fi

    case "$CMD" in
        # --- HELP ---
        help)
            echo -e "${YELLOW}--- Shortcuts ---${NC}"
            echo -e "  rv <hash>   : Revert a commit (Create anti-commit)"
            echo -e "  undo        : Undo last commit (Soft reset)"
            echo -e "  res <path>  : Restore file (Discard local changes)"
            echo -e "  rr[1-9]     : Reword Nth commit back"
            echo -e "  re[1-9]     : Edit Nth commit back"
            echo -e "  cc / am     : Commit / Amend"
            echo -e "  <hash>      : Cherry-pick"
            ;;

        # --- REVERT COMMIT (rv) ---
        rv)
            if [[ -z "$ARG" ]]; then echo -e "${RED}Missing hash.${NC}"; continue; fi
            echo -e "${CYAN}Reverting $ARG...${NC}"
            # --no-edit skips the text editor and commits immediately
            git revert --no-edit "$ARG"
            ;;

        # --- UNDO LAST COMMIT (undo) ---
        undo)
            echo -e "${CYAN}Undoing last commit (Soft Reset)...${NC}"
            git reset --soft HEAD~1
            ;;

        # --- GIT ADD (a) ---
        a)
            if [[ -z "$ARG" ]]; then echo -e "${RED}Specify path.${NC}"; 
            else echo -e "${CYAN}Adding $ARG...${NC}"; git add "$ARG"; fi
            ;;

        # --- GIT RESTORE (res) ---
        res)
            if [[ -z "$ARG" ]]; then
                echo -e "${CYAN}Skipping Rebase commit...${NC}"
                git rebase --skip
            else
                echo -e "${CYAN}Restoring $ARG...${NC}"
                git restore "$ARG"
            fi
            ;;

        # --- CONFLICT RESOLUTION ---
        cpc) git cherry-pick --continue ;;
        cpa) git cherry-pick --abort ;;
        cps) git cherry-pick --skip ;;
        rec) git rebase --continue ;;
        rea) git rebase --abort ;;

        # --- REBASE SHORTCUTS ---
        rrr)
            if [[ -z "$ARG" ]]; then ARG="10"; fi 
            git rebase -i HEAD~"$ARG"
            ;;
        
        # --- REWORD Nth COMMIT ---
        rr[1-9])
            COUNT=${CMD:2:1}
            echo -e "${CYAN}Rewording commit $COUNT steps back...${NC}"
            GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/reword/'" git rebase -i HEAD~"$COUNT"
            ;;

        # --- EDIT Nth COMMIT ---
        re[1-9])
            COUNT=${CMD:2:1}
            echo -e "${CYAN}Editing commit $COUNT steps back...${NC}"
            GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/edit/'" git rebase -i HEAD~"$COUNT"
            ;;
        
        # --- REWORD SPECIFIC HASH ---
        rr)
            if [[ -z "$ARG" ]]; then echo -e "${RED}Missing hash.${NC}"; continue; fi
            GIT_SEQUENCE_EDITOR="sed -i 's/^pick $ARG/reword $ARG/'" git rebase -i "$ARG"^
            ;;

        # --- EDIT SPECIFIC HASH ---
        re)
            if [[ -z "$ARG" ]]; then echo -e "${RED}Missing hash.${NC}"; continue; fi
            GIT_SEQUENCE_EDITOR="sed -i 's/^pick $ARG/edit $ARG/'" git rebase -i "$ARG"^
            ;;

        # --- SQUASH (rs) ---
        rs)
             echo -e "${YELLOW}Opening rebase interaction.${NC}"
             git rebase -i HEAD~10
             ;;

        # --- AMEND (am) ---
        am)
            echo -e "${CYAN}Enter NEW Commit Message:${NC}"
            read -r MSG
            if [[ -z "$MSG" ]]; then echo -e "${RED}Empty message.${NC}"; continue; fi
            
            if [[ "$MSG" == *"$SIGNATURE"* ]]; then
                 git commit --amend -m "$MSG"
            else
                 git commit --amend -s -m "$MSG"
            fi
            echo -e "${GREEN}✓ Amended.${NC}"
            ;;

        # --- COMMIT (cc) ---
        cc)
            echo -e "${CYAN}Enter Commit Message:${NC}"
            read -r MSG
            if [[ "$MSG" == *"$SIGNATURE"* ]]; then
                git commit -m "$MSG"
            else
                git commit -s -m "$MSG"
            fi
            ;;

        # --- DEFAULT HANDLER (URL or HASH) ---
        *)
            if [[ "$CMD" == http* ]] || [[ "$CMD" == git@* ]]; then
                if [[ "$CMD" == *"/tree/"* ]]; then
                    REPO_URL=${CMD%%/tree/*}
                    BRANCH=${CMD#*tree/}
                    echo -e "${CYAN}Fetching Branch: $BRANCH${NC}"
                    git fetch "$REPO_URL" "$BRANCH"
                else
                    echo -e "${CYAN}Fetching default...${NC}"
                    git fetch "$CMD"
                fi
            else
                FULL_INPUT="$CMD $ARG"
                for HASH in $FULL_INPUT; do
                    echo -e "${CYAN}Picking $HASH...${NC}"
                    git cherry-pick "$HASH"
                    if [ $? -eq 0 ]; then
                        LAST_MSG=$(git log -1 --pretty=%B)
                        if [[ "$LAST_MSG" == *"$SIGNATURE"* ]]; then
                            git commit --amend --no-edit --quiet
                        else
                            git commit --amend -s --no-edit --quiet
                        fi
                        echo -e "${GREEN}✓ Picked $HASH${NC}"
                    else
                        echo -e "${RED}❌ Conflict on $HASH.${NC}"
                        echo -e "${RED}Type 'cpc' to continue, 'res' to restore files.${NC}"
                        break 
                    fi
                done
            fi
            ;;
    esac
done