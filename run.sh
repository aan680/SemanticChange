./pkl_to_json.py ../source/vols_EN.pkl "consec-words" "consec-years" "consec-values"
./pkl_to_json.py ../source/disps_EN.pkl "vsnow-words" "vsnow-years" "vsnow-values"
sed -i '.original' 's/NaN/"NaN"/g' consec-values #extension for backup needed on mac
sed -i '.original' 's/NaN/"NaN"/g' vsnow-values
