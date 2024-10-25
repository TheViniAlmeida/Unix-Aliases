#!/bin/bash

# Configurações
REPO_URL="https://github.com/TheViniAlmeida/Unix-Aliases.git"
LOCAL_DIR="$HOME/.aliases-repo"
JSON_FILE="$LOCAL_DIR/AliasesList.json"
BASHRC="$HOME/.bashrc"  # Altere para ~/.zshrc se usar ZSH
TEMP_ALIAS_FILE="$LOCAL_DIR/.temp_aliases.sh"

# Função para clonar ou atualizar o repositório
sync_repo() {
    if [ -d "$LOCAL_DIR" ]; then
        echo "Atualizando repositório de aliases..."
        git -C "$LOCAL_DIR" pull origin main
    else
        echo "Clonando repositório de aliases..."
        git clone "$REPO_URL" "$LOCAL_DIR"
    fi
}

# Função para extrair aliases do JSON e formatá-los
generate_aliases() {
    echo "# Aliases sincronizados" > "$TEMP_ALIAS_FILE"

    jq -c '.[]' "$JSON_FILE" | while read -r alias_entry; do
        alias_name=$(echo "$alias_entry" | jq -r '.alias')
        command=$(echo "$alias_entry" | jq -r '.command')
        description=$(echo "$alias_entry" | jq -r '.description')

        echo "alias $alias_name='$command' # $description" >> "$TEMP_ALIAS_FILE"
    done
}

# Função para remover aliases antigos e adicionar novos ao .bashrc
update_bashrc() {
    # Remove aliases antigos sincronizados
    sed -i '/# Aliases sincronizados/,$d' "$BASHRC"

    # Adiciona os novos aliases
    cat "$TEMP_ALIAS_FILE" >> "$BASHRC"

    echo "Aliases atualizados com sucesso no $BASHRC."
}

# Executa as funções
sync_repo
generate_aliases
update_bashrc

# Carrega as alterações no .bashrc
source "$BASHRC"
