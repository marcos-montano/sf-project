mkdir -p data-output
# TODO: need two separate methods, for lists and hierarchy custom settings

grep -rl "customSettingsType" "compare-orgs/src/dreamhouse" | grep -oP '(\w+)(?=\.object-meta)' | while read custom_setting; do
  echo "Processing Custom Setting: $custom_setting"

  sf data query -q "SELECT Id, Name, SetupOwner.Name FROM $custom_setting" -o dreamhouse -r csv --output-file  "data-output/$custom_setting.csv"

  while IFS=',' read -r id name
  do
    echo "Get Record Name: $name"
    sf data get record --sobject List_Setting__c --record-id "$id" -o dreamhouse > "data-output/$custom_setting-$name"
  done < "data-output/$custom_setting.csv"

done




exit 1
sf data query -q "SELECT Id, Name FROM List_Setting__c" -o dreamhouse -r csv --output-file data.csv

mkdir -p data-output

while IFS=',' read -r id name
do
  echo "Name: $name, Age: $age, City: $city"
  sf data get record --sobject List_Setting__c --record-id "$id" -o dreamhouse > "data-output/LS__c-$name"
done < data.csv
