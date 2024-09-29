#coding:utf-8
import os

def count_lines_in_folder(folder_path):
    total_lines = 0

    for file_name in os.listdir(folder_path):
        print(file_name)
        if file_name.endswith('.v'):
            file_path = os.path.join(folder_path, file_name)
            try:
                with open(file_path, 'r', encoding='gbk') as file:
                    lines = file.readlines()
                    total_lines += len(lines)
            except:
                continue

    return total_lines

# folder_path = '"C:\Users\Winters\OneDrive\Cloud Factory\Octopus_Green_Label\project\Octopus_workspace\VPE_Octo_Green\VPE_Octo_Green_Xilinx\src_code\count_lines.py"'  # 替换为你要统计的文件夹路径
folder_path = '.\\'  # 替换为你要统计的文件夹路径
total_lines = count_lines_in_folder(folder_path)
print(f'Total lines in folder: {total_lines}')