#!/bin/bash
# 🎨 Cores ANSI
VERDE="\e[32m"
LARANJA="\e[33m"
AMARELO="\e[93m"
VERMELHO="\e[31m"
RESET="\e[0m"

# 📑 Lista de arquivos locais e URLs correspondentes
declare -A ARQUIVOS_URLS=(
    ["/home/melman/Suricata-Evebox-Compose/rules/ET.ip.compromised"]="https://rules.emergingthreats.net/open/suricata-7.0.3/rules/compromised.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/ET.shellcode"]="https://rules.emergingthreats.net/open/suricata-7.0.3/rules/emerging-shellcode.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/ET.exploits"]="https://rules.emergingthreats.net/open/suricata-7.0.3/rules/emerging-exploit.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/ET.malware"]="https://rules.emergingthreats.net/open/suricata-7.0.3/rules/emerging-malware.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/ET.tor"]="https://rules.emergingthreats.net/open/suricata-7.0.3/rules/tor.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/ET.scan"]="https://rules.emergingthreats.net/open/suricata-7.0.3/rules/emerging-scan.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/ET.scada"]="https://rules.emergingthreats.net/open/suricata-7.0.3/rules/emerging-scada.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/Abuse.ch.ids.rules"]="https://urlhaus.abuse.ch/downloads/suricata-ids/"
    ["/home/melman/Suricata-Evebox-Compose/rules/Abuse.ch.ja3.rules"]="https://sslbl.abuse.ch/blacklist/ja3_fingerprints.rules"
    ["/home/melman/Suricata-Evebox-Compose/rules/Abuse.ch.tls.rules"]="https://sslbl.abuse.ch/blacklist/sslblacklist_tls_cert.rules"
)

for ARQUIVO_LOCAL in "${!ARQUIVOS_URLS[@]}"; do
    URL="${ARQUIVOS_URLS[$ARQUIVO_LOCAL]}"
    TEMP_FILE=$(mktemp)
    
    echo -e "${LARANJA}🔄 Verificando $ARQUIVO_LOCAL com conteúdo de $URL${RESET}"
    
    curl -s "$URL" -o "$TEMP_FILE"
    
    if [[ ! -f "$ARQUIVO_LOCAL" ]]; then
        echo -e "${VERMELHO}❌ Melman Rule $ARQUIVO_LOCAL não encontrado.${RESET}""${VERDE}Criando novo arquivo...${RESET}"
        mv "$TEMP_FILE" "$ARQUIVO_LOCAL"
        continue
    fi
    
    if ! cmp -s "$TEMP_FILE" "$ARQUIVO_LOCAL"; then
        echo -e "${VERMELHO}⚠️ Melman Rules desatualizadas!${RESET}""${VERDE}Atualizando $ARQUIVO_LOCAL...${RESET}"
        mv "$TEMP_FILE" "$ARQUIVO_LOCAL"
    else
        echo -e "${VERDE}✅ Melman Rules seguem iguais. Nenhuma alteração feita em $ARQUIVO_LOCAL.${RESET}"
        rm "$TEMP_FILE"
    fi
done

echo -e "${VERDE}🚀 Verificação concluída para todos os arquivos!${RESET}"


git --git-dir=/home/melman/Suricata-Evebox-Compose/.git --work-tree=/home/melman/Suricata-Evebox-Compose/ add ./rules

git --git-dir=/home/melman/Suricata-Evebox-Compose/.git --work-tree=/home/melman/Suricata-Evebox-Compose/ commit -m "Update: /rules"

git --git-dir=/home/melman/Suricata-Evebox-Compose/.git --work-tree=/home/melman/Suricata-Evebox-Compose/ push -u origin main
