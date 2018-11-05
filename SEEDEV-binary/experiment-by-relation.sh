##!/bin/bash
set -o xtrace
#LIST="Regulates_Expression Regulates_Molecule_Activity Regulates_Process" 
#LIST="Regulates_Tissue_Development Transcribes_Or_Translates_To Is_Member_Of_Family"
#LIST="Is_Protein_Domain_Of Occurs_During Occurs_In_Genotype"
#LIST="Regulates_Accumulation Regulates_Development_Phase Has_Sequence_Identical_To"
#LIST="Interacts_With Is_Functionally_Equivalent_To Is_Involved_In_Process"
#LIST="Is_Linked_To Is_Localized_In Composes_Primary_Structure"
#LIST="Composes_Protein_Complex Exists_At_Stage Exists_In_Genotype"
#Regulates_Expression Regulates_Molecule_Activity Regulates_Process Regulates_Tissue_Development Transcribes_Or_Translates_To"
#Is_Member_Of_Family Is_Protein_Domain_Of Occurs_During Occurs_In_Genotype Regulates_Accumulation Regulates_Development_Phase"
#Has_Sequence_Identical_To Interacts_With Is_Functionally_Equivalent_To Is_Involved_In_Process Is_Linked_To Is_Localized_In"
#Composes_Primary_Structure Composes_Protein_Complex Exists_At_Stage Exists_In_Genotype"
WD=$PWD
for R in $LIST; do
{
mkdir -p $WD/corpora/corpus-$R/ && \
cp -r $WD/corpora/corpus/* $WD/corpora/corpus-$R/ && \
cd $WD/corpora/corpus-$R/ && \
rm -rf BioNLP-ST-2016_SeeDev-binary_train && \
rm -rf BioNLP-ST-2016_SeeDev-binary_dev && \
rm -rf BioNLP-ST-2016_SeeDev-binary_test && \
unzip BioNLP-ST-2016_SeeDev-binary_train.zip && \
cd BioNLP-ST-2016_SeeDev-binary_train/ && sed -n -i -e "/$R/p" *.a2 && cd .. && \
unzip BioNLP-ST-2016_SeeDev-binary_dev.zip && \
cd BioNLP-ST-2016_SeeDev-binary_dev/ && sed -n -i -e "/$R/p" *.a2 && cd .. && \
unzip BioNLP-ST-2016_SeeDev-binary_test.zip && \
cd $WD
}
## we are at SEEDEV-binary
MODEL="model-${R}"
CORPUS="corpus-$R"
{
python $WD/../../TEES-Alvis/preprocess.py -i $WD/corpora/$CORPUS/BioNLP-ST-2016_SeeDev-binary_train/ -o $WD/corpora/$CORPUS/train/i-train-pped-${R}.xml --steps LOAD,GENIA_SPLITTER,BLLIP_BIO,STANFORD_CONVERT,SPLIT_NAMES,FIND_HEADS,SAVE
python $WD/../../TEES-Alvis/preprocess.py -i $WD/corpora/$CORPUS/BioNLP-ST-2016_SeeDev-binary_dev/ -o $WD/corpora/$CORPUS/dev/i-dev-pped-${R}.xml --steps LOAD,GENIA_SPLITTER,BLLIP_BIO,STANFORD_CONVERT,SPLIT_NAMES,FIND_HEADS,SAVE
python $WD/../../TEES-Alvis/preprocess.py -i $WD/corpora/$CORPUS/BioNLP-ST-2016_SeeDev-binary_test/ -o $WD/corpora/$CORPUS/test/i-test-pped-${R}.xml --steps LOAD,GENIA_SPLITTER,BLLIP_BIO,STANFORD_CONVERT,SPLIT_NAMES,FIND_HEADS,SAVE
} && \
python $WD/../../TEES-Alvis/train.py \
--trainFile $WD/corpora/$CORPUS/train/i-train-pped-${R}.xml \
--develFile $WD/corpora/$CORPUS/dev/i-dev-pped-${R}.xml \
--testFile $WD/corpora/$CORPUS/test/i-test-pped-${R}.xml \
-o ${WD}/models_SDB/${MODEL} \
--debug \
-t None \
--clearAll \
--detector Detectors.EventDetector && \
cd $WD/models_SDB/$MODEL/classification-test/ && \
mkdir test-events && \
tar -xvf test-events.tar.gz -C test-events && \
cd test-events/ && \
sed -i '/^X/d' *.a2 && \
cd ../.. && \
java -jar ../../../bionlp-st-core-0.1.jar -task SeeDev-binary -test -prediction classification-test/test-events -force -alternate > $R.csv && \
cd $WD

done