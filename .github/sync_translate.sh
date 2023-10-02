key="5Tqp1dLHQSk98s-twNF6RpwZu7lZSLLM"
wget -O assets/translations/strings.i18n.json  "https://localise.biz/api/export/locale/en-US.json?index=id&key=$key"
wget -O assets/translations/strings_fa.i18n.json  "https://localise.biz/api/export/locale/fa.json?index=id&key=$key"
wget -O assets/translations/strings_zh.i18n.json  "https://localise.biz/api/export/locale/zh.json?index=id&key=$key"
wget -O assets/translations/strings_pt.i18n.json  "https://localise.biz/api/export/locale/pt.json?index=id&key=$key"
wget -O assets/translations/strings_ru.i18n.json  "https://localise.biz/api/export/locale/ru.json?index=id&key=$key"


pip install polib deep-translator python-i18n

python3 auto_translate.py fa en
python3 auto_translate.py en fa
python3 auto_translate.py en zh
python3 auto_translate.py en pt



function update_localise(){
    lang=$1
	pat="assets/translations/strings_${lang}.i18n.json"
	if [[ $lang == 'en' ]];then
		pat="assets/translations/strings.i18n.json"
	fi
curl "https://localise.biz/api/import/json?index=id&delete-absent=false&ignore-existing=false&locale=$lang&flag-new=Provisional&key=$LOCALIZ_KEY" \
  -H 'Accept: application/json' \
  --data-binary $pat \
  --compressed
  }

function update_localise2(){
    lang=$1
	pat="assets/translations/strings_${lang}.i18n.json"
	if [[ $lang == 'en' ]];then
		pat="assets/translations/strings.i18n.json"
	fi
curl "https://localise.biz/api/import/json?index=id&delete-absent=false&ignore-existing=false&locale=$lang&flag-new=Provisional&key=$LOCALIZ_KEY2" \
  -H 'Accept: application/json' \
  --data-binary $pat \
  --compressed
  }

update_localise fa
update_localise en
update_localise zh

update_localise2 en
update_localise2 pt