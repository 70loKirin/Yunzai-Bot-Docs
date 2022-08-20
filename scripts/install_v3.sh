#!/bin/bash

set -e
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;36m'
plain='\033[0m'

echo -e "${yellow}
===========================================================
    Description: Yunzai-bot Docker 部署辅助脚本
    Author: @Xm798
    Github: https://github.com/Xm798/Yunzai-Bot-Docs
===========================================================${plain}
"

echo -e "将在当前目录下创建 yunzai-bot 文件夹并在其中完成后续工作..."
echo -e ${blue}
read -e -r -p "是否继续? [Y/n]" input
echo -e ${plain}
case $input in
[yY][eE][sS] | [yY]) ;;

[nN][oO] | [nN])
    exit 0
    ;;
*)
    exit 0
    ;;
esac

echo -e ${blue}
read -e -r -p "是否使用国内镜像完成后续配置? [Y/n]" mirror
echo -e ${plain}
case $mirror in
[yY][eE][sS] | [yY])
    CN=true
    ;;
[nN][oO] | [nN]) ;;

*) ;;

esac

if [[ -z "${CN}" ]]; then
    GITHUB_RAW_URL="https://raw.githubusercontent.com/Xm798/Yunzai-Bot/docker"
    YUNZAI_RAW_URL="https://raw.githubusercontent.com/yoimiya-kokomi/Yunzai-Bot/master"
    MIAO_PLUGIN_REPO="https://github.com/yoimiya-kokomi/miao-plugin.git"
    PYTHON_PLUGIN_REPO="https://github.com/TimeRainStarSky/Yunzai-python-plugin"
else
    GITHUB_RAW_URL="https://jihulab.com/Xm798/Yunzai-Bot/-/raw/docker"
    YUNZAI_RAW_URL="https://gitee.com/yoimiya-kokomi/Yunzai-Bot/raw/master"
    MIAO_PLUGIN_REPO="https://gitee.com/yoimiya-kokomi/miao-plugin.git"
    PYTHON_PLUGIN_REPO="https://jihulab.com/Xm798/yunzai-python-plugin.git"
fi

echo -e "${green}\n创建所需文件夹...${plain}"

[ -d yunzai-bot ] || mkdir yunzai-bot
cd yunzai-bot

folder_list="yunzai/logs yunzai/data yunzai/global_img
    yunzai/global_record yunzai/lib/example yunzai/plugins
    redis/data redis/logs"

for folder in $folder_list; do
    if [ ! -d $folder ]; then
        echo -e "  - 创建 $folder"
        mkdir -p $folder
    else
        echo -e "${red}  - $folder already exists."
    fi
done

echo -e "${green}\n下载配置文件...${plain}"
curl -sL ${YUNZAI_RAW_URL}/config/config_default.js -o ./yunzai/config.js
sed -i 's|"127.0.0.1"|"redis"|g' ./yunzai/config.js

echo -e "${green}\n下载docker-compose文件...${plain}"
curl -sL ${GITHUB_RAW_URL}/docker-compose.yaml -o ./docker-compose.yaml

echo -e ${blue}
read -e -r -p "是否加载ffmpeg支持和Python环境？ [Y/n] " input
echo -e ${plain}
case $input in
[yY][eE][sS] | [yY])
    PYTHON=true
    ;;
[nN][oO] | [nN]) ;;

*) ;;

esac

echo -e "
${blue}请选择要使用的 Docker 镜像${plain}
根据云服务商和地域选择，海外机器可选择位于DockerHub的镜像。
"

if [[ -z "${PYTHON}" ]]; then
    select num in "[华为云]" "[DockerHub]"; do
        case "${num}" in
        "[华为云]")
            DOCKER_IMG="swr.cn-south-1.myhuaweicloud.com/sirly/yunzai-bot:latest"
            break
            ;;
        "[DockerHub]")
            DOCKER_IMG="sirly/yunzai-bot:latest"
            break
            ;;
        *)
            echo -e "${red}请输入正确的选项 [1-6]${plain}"
            ;;
        esac
    done
else
    select num in "[华为云]" "[DockerHub]"; do
        case "${num}" in
        "[华为云]")
            DOCKER_IMG="swr.cn-south-1.myhuaweicloud.com/sirly/yunzai-bot:plus"
            break
            ;;
        "[DockerHub]")
            DOCKER_IMG="sirly/yunzai-bot:plus"
            break
            ;;
        *)
            echo -e "${red}请输入正确的选项 [1-2]${plain}"
            ;;
        esac
    done
fi

sed -i "s|xm798/yunzai-bot:latest|${DOCKER_IMG}|g" ./docker-compose.yaml

echo -e ${blue}
read -e -r -p "是否安装喵喵插件(Miao-Plugin)？ [Y/n] " input
echo -e ${plain}
case $input in
[yY][eE][sS] | [yY])
    echo -e "安装位置：./yunzai/plugins/python-plugin"
    if [ ! -d ./yunzai/plugins/miao-plugin ]; then
        set +e
        git clone $MIAO_PLUGIN_REPO ./yunzai/plugins/miao-plugin
        if [ "$?" -ne "0" ]; then
            echo -e "${red}喵喵插件安装失败！\n"
        else
            echo -e "${green}喵喵插件安装成功！\n"
        fi
        set -e
    else
        echo -e "${red}喵喵插件文件夹已存在！\n"
    fi
    ;;
[nN][oO] | [nN])
    echo -e "${plain}跳过喵喵插件安装...\n"
    ;;
*)
    echo -e "${plain}跳过喵喵插件安装...\n"
    ;;
esac

if [[ ! -z "${PYTHON}" ]]; then
    echo -e ${blue}
    read -e -r -p "是否安装Python插件(Python-Plugin)？ [Y/n] " input
    echo -e ${plain}
    case $input in
    [yY][eE][sS] | [yY])
        echo -e "安装位置：./yunzai/plugins/python-plugin"
        if [ ! -d ./yunzai/plugins/python-plugin ]; then
            set +e
            git clone $PYTHON_PLUGIN_REPO ./yunzai/plugins/python-plugin
            if [ "$?" -ne "0" ]; then
                echo -e "${red}Python插件安装失败！\n"
            else
                echo -e "${green}Python插件安装成功！\n"
            fi
            set -e
        else
            echo -e "${red}Python插件文件夹已存在！\n"
        fi
        ;;
    [nN][oO] | [nN])
        echo -e "${plain}跳过Python插件安装...\n"
        ;;
    *)
        echo -e "${plain}跳过Python插件安装...\n"
        ;;
    esac
fi

echo -e "${green}------------------------------
 已准备就绪。
------------------------------${plain}
 请使用 ${yellow}cd yunzai-bot${plain} 进入工作目录，
 使用 ${yellow}docker-compose up -d${plain} 启动容器，
 使用 ${yellow}docker-compose logs -f --tail 100${plain} 查看日志。
 首次登录可能需要使用 ${yellow}docker exec -it yunzai-bot /bin/sh${plain} 进入容器完成QQ登录验证，详情参见帮助链接。
 如需修改配置，请手动修改 ${yellow}./yunzai-bot/yunzai/config.js${plain} 文件。
------------------------------
${yellow} 更多帮助请参见： https://docs.yunzai.org/deploy/linux/Docker.html
"