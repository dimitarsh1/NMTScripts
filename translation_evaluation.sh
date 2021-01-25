SCRIPTNAME=`basename $0`
SCRIPTDIR=`dirname $0`
#Arguments
MODELDIR=$1
TESTFILE=$2
REFFILE=$3
LANGPAIR=$4

#export ENGINEDIR=
#export SKIPBPE=
#export SUFFIX=
#export GPUID=

BASE_MODEL=$MODELDIR
RES_PATH=$( dirname "$TESTFILE" )
SUM_RES_FILE1=${RES_PATH}/TRANS.eval_score.out
SUM_RES_FILE2=${RES_PATH}/TRANS.lex_diversity.out

if [ $# -ne 4 ];then
        echo "Invalid number of arguments. Please provide atleast 3 arguments while running this script."
        echo "Args 1 : Model Directory"
        echo "Args 2 : Test translation file name"
        echo "Args 3 : Reference translation file name"
        echo "Args 4 : Language pair"
        echo "Script Usage : sh ${SCRIPTNAME} /home/usenname sample_eng.txt ref_sample_eng.txt en-fr"
        exit 1
fi

modelfilecount=`ls -1tr ${MODELDIR} 2>/dev/null | wc -l`

if [ ${modelfilecount} -gt 0 ];then
        echo "Total [ ${modelfilecount} ] models found in the directory [ ${MODELDIR} ]."
else
        echo "ERROR! No models found in the model directory [ ${MODELDIR} ]."
        exit 2
fi

rm -f ${SUM_RES_FILE}

# To get rid of @@ that come from BP
REFTRANSFILE=${REFFILE}.nobpe
sed 's/@@ //g' ${REFFILE} > ${REFTRANSFILE}

#Get the target language
LANG=$( echo $LANGPAIR | rev | cut -d '-' -f 1 | rev | tr '[:upper:]' '[:lower:]' )
export LANGUAGE=$LANG

#iterating thorugh different models
for model in `ls -1tr ${MODELDIR}/model*`
do
        #Translate the test file
        SUFFIX=$( basename $model )
        TRANS_OUTFILE=${TESTFILE}.${SUFFIX}.out
	echo "TRANS OUTFILE" $TRANS_OUTFILE
	echo "REF TRANSFILE" ${REFTRANSFILE}
        sh $SCRIPTDIR/5_translate_simple.sh ${TESTFILE} ${MODELDIR}/$( basename $model ) $SUFFIX
        #if [ -f ${TRANS_OUTFILE} ];then
                #echo "Output file [ ${TRANS_OUTFILE} ] not generated as it is supposed to be.."
                #exit 3
        #fi

        #Compute and store output of bleu, ter, etc.
        python3 ${SCRIPTDIR}/score_bleu_ter.py -r ${REFTRANSFILE} -t ${TRANS_OUTFILE} -l ${LANG} > ${RES_PATH}/${SUFFIX}_eval_score.out
        #echo "${model}" >> ${SUM_RES_FILE1}
        cat ${RES_PATH}/${SUFFIX}_eval_score.out >> ${SUM_RES_FILE1}

        #Compute and store output of lexical diversity
        python3 ${SCRIPTDIR}/score_lexical_diversity.py -f ${TRANS_OUTFILE} > ${RES_PATH}/${SUFFIX}_lex_diversity.out
        #echo "${model}" >> ${SUM_RES_FILE2}
        cat ${RES_PATH}/${SUFFIX}_lex_diversity.out >> ${SUM_RES_FILE2}
done

#Dimitar: We need to compute and store the lexical diversity for the reference file too.
#Dimitar: this we need to do only for the lexical diversity (no need for BLEU and TER).
python3 ${SCRIPTDIR}/score_lexical_diversity.py -f ${REFTRANSFILE} > ${RES_PATH}/tmp_${LANG}_REF_lex_diversity.out
echo "Reference" >> ${SUM_RES_FILE2}
cat ${RES_PATH}/tmp_${LANG}_REF_lex_diversity.out >> ${SUM_RES_FILE2}

