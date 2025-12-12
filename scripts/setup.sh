#!/bin/bash

echo "安装必要的转换工具..."

# 更新包列表
sudo apt-get update

# 安装LibreOffice用于Office文档转换
sudo apt-get install -y libreoffice libreoffice-writer libreoffice-calc

# 安装Calibre用于电子书转换
sudo wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# 安装PDF工具
sudo apt-get install -y ghostscript poppler-utils pdftk

# 安装Python和相关库
sudo apt-get install -y python3 python3-pip
pip3 install pdf2docx pypdf2 pdfminer.six ebooklib chm

# 安装其他依赖
sudo apt-get install -y unar p7zip-full

# 安装字体
sudo apt-get install -y fonts-noto-cjk fonts-wqy-microhei

echo "工具安装完成"