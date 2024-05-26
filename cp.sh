#!/bin/bash

# --- Configuration ---
GIT_USER="Jammy555"
GIT_EMAIL="prathap.venkata@gmail.com"
SIGNATURE="Signed-off-by: $GIT_USER <$GIT_EMAIL>"
HOOK_URL="http://review.lineageos.org/tools/hooks/commit-msg"

# Force Nano for the Ctrl+X experience
export EDITOR=nano

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
echo -e "${CYAN}Tip: Use '&' to chain commands (e.g., 'a . & am')${NC}"

while true; do
    # 1. READ INPUT WITH CURSOR SUPPORT (-e)
    echo -e -n "\n${BLUE}Command > ${NC}"
    read -e -r MAIN_INPUT

    if [[ -z "$MAIN_INPUT" ]]; then continue; fi

    # 2. CHAINING LOGIC: Split input by '&'
    IFS='&' read -ra COMMAND_LIST <<< "$MAIN_INPUT"

    # Process each command in the chain
    for RAW_CMD in "${COMMAND_LIST[@]}"; do
        
        # Trim whitespace from the command
        INPUT=$(echo "$RAW_CMD" | xargs)
        
        # Split into Command (CMD) and Arguments (ARG)
        CMD=$(echo "$INPUT" | awk '{print $1}')
        ARG=$(echo "$INPUT" | awk '{$1=""; print $0}' | xargs)

        if [[ -z "$CMD" ]]; then continue; fi

        case "$CMD" in
            # --- HELP ---
            help)
                echo -e "${YELLOW}--- Shortcuts ---${NC}"
                echo -e "  a <path>    : Git Add"
                echo -e "  res <path>  : Restore file"
                echo -e "  cc          : Commit (Opens Nano for multi-line)"
                echo -e "  am          : Amend (Opens Nano for multi-line)"
                echo -e "  rv <hash>   : Revert commit"
                echo -e "  undo        : Undo last commit (Soft reset)"
                echo -e "  rr[1-9]     : Reword Nth commit"
                echo -e "  <link>      : Fetch"
                echo -e "  <hash>      : Cherry-pick"
                ;;

            # --- GIT ADD (a) ---
            a)
                if [[ -z "$ARG" ]]; then echo -e "${RED}Specify path.${NC}"; 
                else echo -e "${CYAN}Adding $ARG...${NC}"; git add "$ARG"; fi
                ;;

            # --- GIT RESTORE / REBASE SKIP (res) ---
            res)
                if [[ -z "$ARG" ]]; then
                    echo -e "${CYAN}Skipping Rebase commit...${NC}"
                    git rebase --skip
                else
                    echo -e "${CYAN}Restoring $ARG...${NC}"
                    git restore "$ARG"
                fi
                ;;

            # --- AMEND (am) ---
            am)
                if [[ -n "$ARG" ]]; then
                    # User provided a one-line message (e.g., am "fix bug")
                    if [[ "$ARG" == *"$SIGNATURE"* ]]; then
                         git commit --amend -m "$ARG"
                    else
                         git commit --amend -s -m "$ARG"
                    fi
                else
                    # 3. MULTI-LINE SUPPORT (Opens Nano)
                    echo -e "${CYAN}Opening Editor... (Ctrl+X to Save & Exit)${NC}"
                    # -s adds the sign-off inside the editor automatically
                    git commit --amend -s
                fi
                echo -e "${GREEN}✓ Amended.${NC}"
                ;;

            # --- COMMIT (cc) ---
            cc)
                if [[ -n "$ARG" ]]; then
                    # One-line message
                    if [[ "$ARG" == *"$SIGNATURE"* ]]; then
                        git commit -m "$ARG"
                    else
                        git commit -s -m "$ARG"
                    fi
                else
                    # 3. MULTI-LINE SUPPORT (Opens Nano)
                    echo -e "${CYAN}Opening Editor... (Ctrl+X to Save & Exit)${NC}"
                    git commit -s
                fi
                ;;

            # --- UNDO / REVERT ---
            undo) git reset --soft HEAD~1; echo -e "${CYAN}Undone.${NC}" ;;
            rv)   git revert --no-edit "$ARG" ;;

            # --- CONFLICTS ---
            cpc) git cherry-pick --continue ;;
            cpa) git cherry-pick --abort ;;
            cps) git cherry-pick --skip ;;
            rec) git rebase --continue ;;
            rea) git rebase --abort ;;

            # --- REBASE/REWORD ---
            rrr)
                if [[ -z "$ARG" ]]; then ARG="10"; fi 
                git rebase -i HEAD~"$ARG"
                ;;
            rr[1-9])
                COUNT=${CMD:2:1}
                echo -e "${CYAN}Rewording commit $COUNT steps back...${NC}"
                GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/reword/'" git rebase -i HEAD~"$COUNT"
                ;;
            re[1-9])
                COUNT=${CMD:2:1}
                echo -e "${CYAN}Editing commit $COUNT steps back...${NC}"
                GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/edit/'" git rebase -i HEAD~"$COUNT"
                ;;
            rr)
                if [[ -z "$ARG" ]]; then echo -e "${RED}Missing hash.${NC}"; continue; fi
                GIT_SEQUENCE_EDITOR="sed -i 's/^pick $ARG/reword $ARG/'" git rebase -i "$ARG"^
                ;;
            re)
                if [[ -z "$ARG" ]]; then echo -e "${RED}Missing hash.${NC}"; continue; fi
                GIT_SEQUENCE_EDITOR="sed -i 's/^pick $ARG/edit $ARG/'" git rebase -i "$ARG"^
                ;;
            rs)
                 echo -e "${YELLOW}Opening rebase interaction.${NC}"
                 git rebase -i HEAD~10
                 ;;

            # --- DEFAULT (URL / HASH) ---
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
                    # Cherry Pick Logic
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
                            break 
                        fi
                    done
                fi
                ;;
        esac
    done
done