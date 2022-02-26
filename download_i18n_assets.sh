# unsupported = (ar_eg ga nn)
langs=(cs da de en es es_AR es_MX fr hu it ja ko nb nl no pl pt pt_BR ru sl sv tr vi zh_Hans zh_Hant)
base_url="https://raw.githubusercontent.com/Glimesh/glimesh.tv/dev/priv/gettext/"
end_url="/LC_MESSAGES/default.po"
assets_location="assets/i18n/"

for lang in ${langs[@]}
do
	download_url="$base_url$lang$end_url"
	curl -s $download_url -o "$assets_location$lang.po"
	echo "Downloaded $lang"
done
