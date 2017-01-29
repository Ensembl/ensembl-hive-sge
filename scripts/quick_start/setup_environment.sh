
export EHIVE_ROOT_DIR=$HOME/ensembl-hive
export PERL5LIB=$EHIVE_ROOT_DIR/modules:$HOME/ensembl-hive-sge/modules
export EHIVE_TEST_PIPELINE_URLS='sqlite:///ehive_test_pipeline_db'

echo -e '\n*******************\n* What about running "prove -rv ensembl-hive-sge/t" ?\n*******************\n'

