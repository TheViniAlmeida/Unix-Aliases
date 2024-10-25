#!/bin/bash

# Configurações
JSON_URL="https://raw.githubusercontent.com/TheViniAlmeida/Unix-Aliases/refs/heads/main/AliasesList.json"
BASHRC="$HOME/.bashrc"  # Ou ~/.zshrc se você usa ZSH
TEMP_ALIAS_FILE="/tmp/.temp_aliases.sh"

# Função para baixar o arquivo JSON de aliases
download_aliases() {
    echo "Baixando lista de aliases..."
    curl -s -o "$TEMP_ALIAS_FILE.json" "$JSON_URL"
    if [ $? -ne 0 ]; then
        echo "Erro ao baixar a lista de aliases. Verifique a conexão ou a URL."
        exit 1
    fi
}

# Função para extrair aliases do JSON e formatá-los
generate_aliases() {
    echo "# Aliases sincronizados" > "$TEMP_ALIAS_FILE"

    jq -c '.[]' "$TEMP_ALIAS_FILE.json" | while read -r alias_entry; do
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
download_aliases
generate_aliases
update_bashrc

# Carrega as alterações no .bashrc
source "$BASHRC"
echo "Novos aliases carregados com sucesso."
