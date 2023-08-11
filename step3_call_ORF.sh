#!/bin/sh

#SBATCH --job-name=call_ORF        # 作业名
#SBATCH --partition=64c512g      # small 队列
#SBATCH -n 8                # 总核数需 <=20
#SBATCH --ntasks-per-node=8   # 每节点核数
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


# 软件在 riboseq 环境
source ./utils.sh
source activate riboseq



# 文件夹不存在则创建文件夹
batch_test_folder ../mapping ../log/call_ORF ../call_ORF


# 检查软件
batch_test_software RiboCode

############################################################## 
# 参数传递
############################################################## 

help()
{
  Usage="Usage: bash step3_call_ORF.sh  [OPTION]  \n \
  这个脚本不支持多线程


  Options:\n\
        [ -n | --sample_name ] 样品名称 \n \
        [ -i | --input_bam ] 输入的 bam 文件，要求是去除重复后的 \n \
        [ -r | --RiboCode_annot ] RiboCode 处理的注释文件\n \
        [ -h | --help ]   帮助信息  \n \
        "
  echo -e $Usage
  exit 2
}

ARGS=$(getopt  -o  i:n:r:h --long input_bam:,sample_name:,reference_genome:,help -- "$@")

# 脚本开始
echo -e "\033[32m 
############################################################## 
Begin call ORF
args = step3_call_ORF.sh  $ARGS 
############################################################## 
\033[0m" 



if [  "$ARGS" == " --" ]; then  
  help  
fi

eval set -- "$ARGS"
while :
do
  case "$1" in
    -r | --RiboCode_annot)  RiboCode_annot="$2" ; shift 2 ;;
    -n | --sample_name)    sample_name="$2"    ; shift 2  ;;
    -i | --input_bam)  input_bam="$2" ; shift 2 ;;
    -h | --help)             help; exit 0 ; shift    ;;    
    --) shift; break ;;
  esac
done


############################################################## 
# 处理数据 
############################################################## 

# -a 是 prepare_transcripts 准备出的 index 输出的文件路径
metaplots -a ${RiboCode_annot} \
  -r $input_bam \
  -o ../call_ORF/${sample_name}  \
  -m 26 -M 50 -s yes -pv1 1 -pv2 1

echo -e "\033[32m metaplots  ${sample_name} complete \033[0m" 

# 这个 -c 输入的 config 文件是上一步 metaplot 的输出
RiboCode -a ${RiboCode_annot} -l no -g -b -c ../call_ORF/${sample_name}_pre_config.txt -o ../call_ORF/${sample_name}

echo -e "\033[32m RiboCode  ${sample_name} complete \033[0m" 

echo -e "\033[32m 
############################################################## 
End call ORF  $sample_name 
############################################################## 
\033[0m" 

# 移动一下 log 到文件夹

mv  ./${SLURM_JOB_NAME}_${SLURM_JOB_ID}.err ../log/call_ORF/${SLURM_JOB_NAME}_${sample_name}_${SLURM_JOB_ID}.err
mv  ./${SLURM_JOB_NAME}_${SLURM_JOB_ID}.out ../log/call_ORF/${SLURM_JOB_NAME}_${sample_name}_${SLURM_JOB_ID}.out

