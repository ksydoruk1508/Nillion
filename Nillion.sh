#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # Нет цвета (сброс цвета)

# Проверка наличия curl и установка, если не установлен
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

echo -e "${GREEN}"
cat << "EOF"
███    ██ ██ ██      ██      ██  ██████  ███    ██ 
████   ██ ██ ██      ██      ██ ██    ██ ████   ██ 
██ ██  ██ ██ ██      ██      ██ ██    ██ ██ ██  ██ 
██  ██ ██ ██ ██      ██      ██ ██    ██ ██  ██ ██ 
██   ████ ██ ███████ ███████ ██  ██████  ██   ████ 
                                    
________________________________________________________________________________________________________________________________________


███████  ██████  ██████      ██   ██ ███████ ███████ ██████      ██ ████████     ████████ ██████   █████  ██████  ██ ███    ██  ██████  
██      ██    ██ ██   ██     ██  ██  ██      ██      ██   ██     ██    ██           ██    ██   ██ ██   ██ ██   ██ ██ ████   ██ ██       
█████   ██    ██ ██████      █████   █████   █████   ██████      ██    ██           ██    ██████  ███████ ██   ██ ██ ██ ██  ██ ██   ███ 
██      ██    ██ ██   ██     ██  ██  ██      ██      ██          ██    ██           ██    ██   ██ ██   ██ ██   ██ ██ ██  ██ ██ ██    ██ 
██       ██████  ██   ██     ██   ██ ███████ ███████ ██          ██    ██           ██    ██   ██ ██   ██ ██████  ██ ██   ████  ██████  
                                                                                                                                         
                                                                                                                                         
 ██  ██████  ██       █████  ███    ██ ██████   █████  ███    ██ ████████ ███████                                                         
██  ██        ██     ██   ██ ████   ██ ██   ██ ██   ██ ████   ██    ██    ██                                                             
██  ██        ██     ███████ ██ ██  ██ ██   ██ ███████ ██ ██  ██    ██    █████                                                          
██  ██        ██     ██   ██ ██  ██ ██ ██   ██ ██   ██ ██  ██ ██    ██    ██                                                             
 ██  ██████  ██      ██   ██ ██   ████ ██████  ██   ██ ██   ████    ██    ███████

Donate: 0x0004230c13c3890F34Bb9C9683b91f539E809000
EOF
echo -e "${NC}"

function install_node {
    echo -e "${BLUE}Обновляем сервер и устанавливаем необходимые инструменты...${NC}"
    sudo apt-get update -y && sudo apt upgrade -y
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    echo -e "${GREEN}Prerequisites и Docker успешно установлены.${NC}"

    echo -e "${BLUE}Запускаем Docker контейнер Hello-World...${NC}"
    docker container run --rm hello-world
    echo -e "${GREEN}Hello-World контейнер успешно запущен.${NC}"

    echo -e "${BLUE}Устанавливаем образ Accuser...${NC}"
    docker pull nillion/verifier:v1.0.1
    echo -e "${GREEN}Образ Accuser успешно установлен.${NC}"

    echo -e "${BLUE}Создаем директорию для Accuser...${NC}"
    mkdir -p nillion/verifier
    echo -e "${GREEN}Директория nillion/verifier успешно создана.${NC}"

    echo -e "${BLUE}Запускаем контейнер для инициализации Accuser и регистрации...${NC}"
    docker run -v ./nillion/verifier:/var/tmp nillion/verifier:v1.0.1 initialise
    echo -e "${YELLOW}Сохраните Verifier account id (адрес кошелька) и Public Key в надежное место.${NC}"
}

function extract_private_key {
    echo -e "${BLUE}Извлекаем приватный ключ...${NC}"
    nano nillion/verifier/credentials.json
    echo -e "${YELLOW}Сохраните приватный ключ в безопасное место. Для выхода нажмите Ctrl+X.${NC}"
}

function run_node {
    echo -e "${BLUE}Запускаем ноду...${NC}"
    docker run -d -v ./nillion/verifier:/var/tmp nillion/verifier:v1.0.1 verify --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com"
    echo -e "${GREEN}Нода успешно запущена.${NC}"
}

function remove_node {
    echo -e "${BLUE}Останавливаем и удаляем контейнер ноды...${NC}"
    container_id=$(docker ps -q --filter ancestor=nillion/verifier:v1.0.1)
    if [ -n "$container_id" ]; then
        docker stop $container_id
        docker rm $container_id
        echo -e "${GREEN}Контейнер ноды успешно остановлен и удален.${NC}"
    else
        echo -e "${RED}Контейнер ноды не найден.${NC}"
    fi

    echo -e "${BLUE}Удаляем директорию Accuser...${NC}"
    rm -rf nillion/verifier
    echo -e "${GREEN}Директория Accuser успешно удалена.${NC}"
}

function view_logs {
    echo -e "${YELLOW}Просмотр логов контейнера (выход из логов CTRL+C)...${NC}"
    echo -e "${BLUE}Получаем ID запущенного контейнера...${NC}"
    docker ps
    echo -e "${YELLOW}Введите ID контейнера для просмотра логов:${NC}"
    read container_id
    docker logs -f $container_id --tail=50
}

function main_menu {
    while true; do
        echo -e "${YELLOW}Выберите действие:${NC}"
        echo -e "${CYAN}1. Установить ноду${NC}"
        echo -e "${CYAN}2. Извлечь приватный ключ${NC}"
        echo -e "${CYAN}3. Запустить ноду${NC}"
        echo -e "${CYAN}4. Удалить ноду${NC}"
        echo -e "${CYAN}5. Просмотр логов${NC}"
        echo -e "${CYAN}6. Выход${NC}"

        echo -e "${PURPLE}Ссылка на текстовый гайд: https://teletype.in/@c6zr7/Nillion${NC} "

        echo -e "${YELLOW}Введите номер действия:${NC}"
        read choice
        case $choice in
            1) install_node ;;
            2) extract_private_key ;;
            3) run_node ;;
            4) remove_node ;;
            5) view_logs ;;
            6) break ;;
            *) echo -e "${RED}Неверный выбор, попробуйте снова.${NC}" ;;
        esac
    done
}

main_menu
