mkdir -p data-output2

query="SELECT EntityDefinition.QualifiedApiName, QualifiedApiName  FROM FieldDefinition WHERE EntityDefinition.IsCustomSetting = true"
# sf data query -q "$query" -o dreamhouse -r csv --output-file  "data-output2/custom-settings.csv"

while IFS=$'\t' read -r customSetting fields; do
  echo "customSetting:  $customSetting"
  echo "fields: $fields"
  sf data query -q "SELECT SetupOwner.Name, $fields FROM $customSetting" -o dreamhouse -r csv --output-file  "data-output2/$customSetting.csv" &
done < <(yq  data-output2/custom-settings.csv --output-format json | yq 'group_by(."EntityDefinition.QualifiedApiName")' -o json | yq '[.[] | {"CustomSetting": .[0]."EntityDefinition.QualifiedApiName", "Fields": [.[].QualifiedApiName]|join(",")}]' -o tsv)

wait 
echo "Done"




