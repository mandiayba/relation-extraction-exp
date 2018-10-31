##!/bin/bash
set -o xtrace
LIST="Binds_To Composes_Primary_Structure Composes_Protein_Complex Exists_At_Stage Exists_In_Genotype Has_Sequence_Identical_To Interacts_With Is_Functionally_Equivalent_To Is_Involved_In_Process Is_Linked_To directed Is_Localized_In Is_Member_Of_Family Is_Protein_Domain_Of Occurs_During Occurs_In_Genotype Regulates_Accumulation Regulates_Development_Phase Regulates_Expression Regulates_Molecule_Activity Regulates_Process Regulates_Tissue_Development Transcribes_Or_Translates_To"
for R in $LIST; do
{
cd $PWD/corpus/ && \
rm -rf BioNLP-ST-2016_SeeDev-binary_train && \
rm -rf BioNLP-ST-2016_SeeDev-binary_dev && \
rm -rf BioNLP-ST-2016_SeeDev-binary_test && \
unzip BioNLP-ST-2016_SeeDev-binary_train.zip && \
cd BioNLP-ST-2016_SeeDev-binary_train/ && sed -n -i -e "/$R/p" *.a2 && cd .. && \
unzip BioNLP-ST-2016_SeeDev-binary_dev.zip && \
cd BioNLP-ST-2016_SeeDev-binary_dev/ && sed -n -i -e "/$R/p" *.a2 && cd .. && \
unzip BioNLP-ST-2016_SeeDev-binary_test.zip && \
cd ../
}
## we are at SEEDEV-binary
MODEL='model-'${R}
{
python $PWD/../../TEES-Alvis/preprocess.py -i $PWD/corpus/BioNLP-ST-2016_SeeDev-binary_train/ -o $PWD/corpus/train/i-train-pped-${R}.xml --steps LOAD,GENIA_SPLITTER,BLLIP_BIO,STANFORD_CONVERT,SPLIT_NAMES,FIND_HEADS,SAVE
python $PWD/../../TEES-Alvis/preprocess.py -i $PWD/corpus/BioNLP-ST-2016_SeeDev-binary_dev/ -o $PWD/corpus/dev/i-dev-pped-${R}.xml --steps LOAD,GENIA_SPLITTER,BLLIP_BIO,STANFORD_CONVERT,SPLIT_NAMES,FIND_HEADS,SAVE
python $PWD/../../TEES-Alvis/preprocess.py -i $PWD/corpus/BioNLP-ST-2016_SeeDev-binary_test/ -o $PWD/corpus/test/i-test-pped-${R}.xml --steps LOAD,GENIA_SPLITTER,BLLIP_BIO,STANFORD_CONVERT,SPLIT_NAMES,FIND_HEADS,SAVE
} && \
python $PWD/../../TEES-Alvis/train.py \
--trainFile $PWD/corpus/train/i-train-pped-${R}.xml \
--develFile $PWD/corpus/dev/i-dev-pped-${R}.xml \
--testFile $PWD/corpus/test/i-test-pped-${R}.xml \
-o ${PWD}/models/${MODEL} \
--debug \
-t None \
--clearAll \
--detector Detectors.EventDetector && \
cd $PWD/models/$MODEL/classification-test/ && \
mkdir test-events && \
tar -xvf test-events.tar.gz -C test-events && \
cd test-events/ && \
sed -i '/^X/d' *.a2 && \
cd ../.. && \
java -jar ../../../bionlp-st-core-0.1.1.jar -task SeeDev-binary -test -prediction classification-test/test-events -force -alternate > eval.txt && \
cd ../..

done
