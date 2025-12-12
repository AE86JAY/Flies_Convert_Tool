#!/bin/bash

source scripts/utils.sh

log "开始转换电子书文件..."

counter=1
for input_file in $SOURCE_FILES; do
    if [ ! -f "$input_file" ]; then
        continue
    fi
    
    log "处理电子书: $input_file"
    
    # 生成输出文件名
    output_file="转换后/$(generate_filename "$input_file" "$OUTPUT_FORMAT" "$counter")"
    
    # 使用Calibre进行电子书转换
    case "${input_file##*.}" in
        chm)
            # 先使用unar解压CHM
            unar -o "$TEMP_DIR" "$input_file"
            # 转换为目标格式
            ebook-convert "$input_file" "$output_file" \
                --page-breaks-before="//*[name()='h1' or name()='h2']"
            ;;
            
        epub)
            ebook-convert "$input_file" "$output_file" \
                --page-breaks-before="//*[name()='h1' or name()='h2']"
            ;;
            
        pdf)
            if [ "$OUTPUT_FORMAT" = ".epub" ]; then
                ebook-convert "$input_file" "$output_file" \
                    --pdf-initial-zoom=100
            fi
            ;;
    esac
    
    # 生成目录
    create_toc "$input_file" "转换后"
    
    counter=$((counter + 1))
done

log "电子书转换完成"