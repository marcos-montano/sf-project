#!/bin/bash

# > bin/compare-orgs.sh org1 org2

if [ $# -ne 2 ]; then
    echo "Error: Expected two arguments."
    exit 1
fi

echo "org alias 1: $1"
echo "org alias 2: $2"

clean_folders() {
  rm -rf $1  && mkdir $1
  mkdir $1/src
  mkdir $1/data
  mkdir $1/manifest

}

retrieve_org() {
  local org_alias="$1"
}

data_to_compare() {
  local queries_dir="$1" 
  local data_dir="$2/$3" 
  local org_alias="$3" 

  mkdir -p $data_dir

  if [ -d "$queries_dir" ]; then
    for file in "$queries_dir"/*; do
      if [ -f "$file" ]; then 
        local file_name=$(basename $file)
        echo "Retrieving data from: $file" && \
        sf data query --file $file --output-file "$data_dir/$file_name.csv" --result-format csv --target-org $org_alias && \
        echo "" 
      fi
    done
  else
    echo "Error: Directory not found: $queries_dir"
  fi
}


SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd $SCRIPT_PATH/..

# Set parameters
COMPARE_FOLDER="compare-orgs"
QUERIES_FOLDER="scripts/compare-queries"
LOCAL_CODE_PATH="force-app/main/default"
ORG_ALIAS_1="$1"
ORG_ALIAS_2="$2"


echo ""
echo "Starting Compare org: ($ORG_ALIAS_1) ($ORG_ALIAS_2)"
echo ""


# echo "Cleaning folder..."
# clean_folders $COMPARE_FOLDER &> /dev/null
# echo ""

# # exit 1

# # org1
# echo "Generating package xml file for org $ORG_ALIAS_1..." && \
# sf project generate manifest --output-dir "$COMPARE_FOLDER/manifest" --name $ORG_ALIAS_1 --from-org $ORG_ALIAS_1 && \
# echo "" && \

# echo "Retrieveing metadaa from org $ORG_ALIAS_1..." && \
# sf project retrieve start --manifest "$COMPARE_FOLDER/manifest/$ORG_ALIAS_1.xml"  --output-dir "$COMPARE_FOLDER/src/$ORG_ALIAS_1" --target-org $ORG_ALIAS_1 --ignore-conflicts && \
# echo "" 

# # org2
# echo "Generating package xml file for org $ORG_ALIAS_2..." && \
# sf project generate manifest --output-dir "$COMPARE_FOLDER/manifest" --name $ORG_ALIAS_2 --from-org $ORG_ALIAS_2 && \
# echo "" && \

# echo "Retrieveing metadaa from org $ORG_ALIAS_2..." && \
# sf project retrieve start --manifest "$COMPARE_FOLDER/manifest/$ORG_ALIAS_2.xml"  --output-dir "$COMPARE_FOLDER/src/$ORG_ALIAS_2" --target-org $ORG_ALIAS_2 --ignore-conflicts && \
# echo "" 

# get data
data_to_compare $QUERIES_FOLDER "$COMPARE_FOLDER/data" $ORG_ALIAS_1
data_to_compare $QUERIES_FOLDER "$COMPARE_FOLDER/data" $ORG_ALIAS_2

# generate diffs

echo "Preparing diff between local and $ORG_ALIAS_1..." && \
git diff --no-index $LOCAL_CODE_PATH "$COMPARE_FOLDER/src/$ORG_ALIAS_1" > "$COMPARE_FOLDER/local-$ORG_ALIAS_1.diff" && \
echo "" 

echo "Preparing diff between local and $ORG_ALIAS_2..." && \
git diff --no-index $LOCAL_CODE_PATH "$COMPARE_FOLDER/src/$ORG_ALIAS_2" > "$COMPARE_FOLDER/local-$ORG_ALIAS_2.diff" && \
echo "" 

echo "Preparing diff between $ORG_ALIAS_1 and $ORG_ALIAS_2..." && \
git diff --no-index "$COMPARE_FOLDER/src/$ORG_ALIAS_1" "$COMPARE_FOLDER/src/$ORG_ALIAS_2" > "$COMPARE_FOLDER/$ORG_ALIAS_1-$ORG_ALIAS_2.diff" && \
echo "" 

# Compare data
echo "Preparing data diff between $ORG_ALIAS_1 and $ORG_ALIAS_2..." && \
git diff --no-index "$COMPARE_FOLDER/data/$ORG_ALIAS_1" "$COMPARE_FOLDER/data/$ORG_ALIAS_2" > "$COMPARE_FOLDER/$ORG_ALIAS_1-$ORG_ALIAS_2-data.diff" && \
echo "" 


echo "Diff ready."


EXIT_CODE="$?"
echo ""

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Comparation completed."
else
    echo "Comparation failed."
fi
exit $EXIT_CODE
