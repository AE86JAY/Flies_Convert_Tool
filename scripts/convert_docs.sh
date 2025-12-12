#!/bin/bash

source scripts/utils.sh

log "开始转换文档文件..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 遍历源文件
counter=1
for input_file in $SOURCE_FILES; do
    if [ ! -f "$input_file" ]; then
        continue
    fi
    
    log "处理文件: $input_file"
    
    # 生成输出文件名
    output_file="转换后/$(generate_filename "$input_file" "$OUTPUT_FORMAT" "$counter")"
    
    # 根据页面选项设置参数
    case "$PAGE_OPTION" in
        "横向")
            orientation_param="--landscape"
            ;;
        "竖向")
            orientation_param="--portrait"
            ;;
        *)
            orientation_param=""
            ;;
    esac
    
    # 根据输入输出格式执行转换
    case "${input_file##*.}" in
        doc|docx|rtf)
            case "$OUTPUT_FORMAT" in
                .pdf)
                    libreoffice --headless --convert-to pdf $orientation_param "$input_file" --outdir "转换后"
                    ;;
                .docx)
                    libreoffice --headless --convert-to docx "$input_file" --outdir "转换后"
                    ;;
                .xlsx)
                    # 可能需要特殊处理
                    log "文档转表格格式需要特殊处理"
                    ;;
            esac
            ;;
        
        xls|xlsx)
            case "$OUTPUT_FORMAT" in
                .pdf)
                    libreoffice --headless --convert-to pdf $orientation_param "$input_file" --outdir "转换后"
                    ;;
                .xlsx)
                    libreoffice --headless --convert-to xlsx "$input_file" --outdir "转换后"
                    ;;
            esac
            ;;
        
        pdf)
            case "$OUTPUT_FORMAT" in
                .docx)
                    # 使用pdf2docx
                    python3 -c "
import sys
from pdf2docx import Converter
cv = Converter('$input_file')
cv.convert('$output_file')
cv.close()
"
                    ;;
                .xlsx)
                    # PDF转Excel需要特殊处理
                    log "PDF转Excel格式需要OCR支持"
                    ;;
                *)
                    # 使用GhostScript进行PDF处理
                    if [ -n "$orientation_param" ]; then
                        gs -sDEVICE=pdfwrite -dAutoRotatePages=/None \
                           -dPDFSETTINGS=/prepress -o "$output_file" "$input_file"
                    else
                        cp "$input_file" "$output_file"
                    fi
                    ;;
            esac
            ;;
    esac
    
    # 如果文件有目录，为每个输出文件生成目录
    if [ -f "$input_file" ]; then
        create_toc "$input_file" "转换后"
    fi
    
    counter=$((counter + 1))
done

log "文档转换完成"